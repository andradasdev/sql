# Autenticação entre repositórios no GitHub Actions

Como autorizar o workflow de um repositório a **escrever** em outro.

No nosso caso: o repositório de código
[`ronidomingues/mysql-capacitation`](https://github.com/ronidomingues/mysql-capacitation)
compila os PDFs e precisa enviá-los para
[`andradasdev/sql`](https://github.com/andradasdev/sql), que os publica.

---

## Por que o token padrão não serve

Todo workflow recebe automaticamente um token chamado `GITHUB_TOKEN`. Ele é
prático, mas tem **duas limitações** que inviabilizam o nosso caso:

| Limitação | Consequência aqui |
|---|---|
| Só tem permissão no **próprio repositório** onde o workflow roda | O `GITHUB_TOKEN` de `mysql-capacitation` **não escreve** em `andradasdev/sql` |
| Pushes feitos com ele **não disparam outros workflows** | Mesmo que escrevesse, o workflow de Pages do `sql` **não seria acionado** |

Essa segunda limitação existe de propósito, para evitar laços infinitos de
workflows disparando uns aos outros. Ela é o motivo de precisarmos de um token
de usuário (PAT): **push feito com PAT dispara workflows normalmente**, e é
exatamente disso que dependemos para o Pages publicar.

---

## O que vamos criar

```
┌─────────────────────────────────────┐
│  ronidomingues/mysql-capacitation   │   repositório de CÓDIGO
│                                     │
│  Settings > Secrets and variables   │
│    > Actions                        │
│      PUBLISH_TOKEN  ← o valor       │
└──────────────┬──────────────────────┘
               │  git push autenticado com PUBLISH_TOKEN
               v
┌─────────────────────────────────────┐
│  andradasdev/sql                    │   repositório de PUBLICAÇÃO
│                                     │
│  recebe: guia.pdf, apresentacao.pdf │
│          liga.sql                   │
│  dispara: workflow de Pages         │
└─────────────────────────────────────┘
```

---

## Passo 1 — Criar o token fine-grained

Um **PAT fine-grained** (*Personal Access Token*, granular) é preferível ao
clássico porque você escolhe **exatamente** qual repositório ele alcança e
**exatamente** o que ele pode fazer lá.

1. Acesse <https://github.com/settings/personal-access-tokens/new>
   (ou: foto do perfil → **Settings** → **Developer settings** →
   **Personal access tokens** → **Fine-grained tokens** → **Generate new token**)

2. Preencha:

   | Campo | Valor |
   |---|---|
   | **Token name** | `publicar-em-andradasdev-sql` |
   | **Description** | Envio de artefatos compilados do repositório de código |
   | **Resource owner** | **`andradasdev`** ← e não a sua conta pessoal |
   | **Expiration** | 90 dias (ou o menor prazo que você tolere renovar) |

   > ⚠️ **`Resource owner` é o campo que mais gera erro.** Se você deixar a sua
   > conta pessoal aqui, o token **não enxerga** os repositórios da
   > organização, e o push falha com `403` mesmo com todas as permissões
   > marcadas.
   >
   > Se `andradasdev` **não aparecer** na lista, vá para o
   > [Passo 2](#passo-2--liberar-pats-fine-grained-na-organização) primeiro.

3. Em **Repository access**, escolha **Only select repositories** e selecione
   apenas **`sql`**.

4. Em **Repository permissions**, encontre **Contents** e marque
   **Read and write**.

   > É a **única** permissão necessária. `Contents` cobre ler e gravar
   > arquivos, branches e commits. Não marque mais nada: cada permissão extra
   > aumenta o estrago caso o token vaze.
   >
   > A permissão **Metadata: Read-only** é marcada sozinha pelo GitHub e é
   > obrigatória. Isso é normal.

5. Clique em **Generate token** e **copie o valor imediatamente**. Ele começa
   com `github_pat_` e **não é exibido de novo**. Se perder, revogue e crie
   outro.

---

## Passo 2 — Liberar PATs fine-grained na organização

Este passo é necessário porque `andradasdev` é uma **organização**, não uma
conta pessoal. Você precisa ser *owner* dela.

1. Vá em <https://github.com/organizations/andradasdev/settings/personal-access-tokens-onboarding>
   (ou: organização → **Settings** → **Personal access tokens** → **Settings**)

2. Escolha uma das políticas:

   | Política | Efeito |
   |---|---|
   | **Allow access via fine-grained personal access tokens** | Habilita o recurso. **Obrigatório** |
   | **Require administrator approval** | Cada token novo espera aprovação de um owner. Mais seguro |
   | **Do not require administrator approval** | O token funciona assim que criado. Mais simples |

3. Se você deixou a aprovação exigida, aprove o token em
   **Settings** → **Personal access tokens** → **Pending requests**.

> Enquanto o token estiver pendente de aprovação, ele existe mas **não
> funciona** — o push falha com `403`, sem mensagem explicando o motivo. Se
> tudo parecer certo e mesmo assim der `403`, **cheque esta fila primeiro**.

---

## Passo 3 — Guardar o token como secret

O token vai para o repositório **de código**, que é quem precisa dele.

1. Acesse
   <https://github.com/ronidomingues/mysql-capacitation/settings/secrets/actions>
   (ou: repositório → **Settings** → **Secrets and variables** → **Actions**)

2. **New repository secret**:

   | Campo | Valor |
   |---|---|
   | **Name** | `PUBLISH_TOKEN` |
   | **Secret** | o valor `github_pat_...` copiado no Passo 1 |

3. **Add secret**.

> O nome precisa ser exatamente `PUBLISH_TOKEN` — é o que o workflow procura,
> em `.github/workflows/build.yml`.
>
> Depois de salvo, o valor **não pode mais ser lido** por ninguém, nem por
> você. Só é possível substituí-lo. O GitHub também **mascara** o valor
> automaticamente nos logs: se o workflow imprimir o token por acidente,
> aparece `***`.

---

## Passo 4 — Como o workflow usa o token

O trecho relevante de `.github/workflows/build.yml`, no repositório de código:

```yaml
- name: Enviar artefatos para andradasdev/sql
  env:
    PUBLISH_TOKEN: ${{ secrets.PUBLISH_TOKEN }}
  run: |
    git clone --depth 1 \
      "https://x-access-token:${PUBLISH_TOKEN}@github.com/andradasdev/sql.git" \
      /tmp/publicacao
    # ... copia os artefatos ...
    cd /tmp/publicacao
    git push origin HEAD:main
```

Três detalhes que valem entender:

**`x-access-token`** é o nome de usuário convencionado pelo GitHub para
autenticação por token via HTTPS. O que autentica de fato é a senha — o token.
Qualquer nome de usuário funcionaria, mas use este por convenção.

**O secret entra por `env:`, nunca interpolado no corpo do script.** Escrever
`if [ -z "${{ secrets.PUBLISH_TOKEN }}" ]` faz o valor virar parte do texto do
comando, o que quebra com caracteres especiais e é má prática de segurança. O
certo é declarar em `env:` e usar `${PUBLISH_TOKEN}`.

**Nunca use `set -x`** num passo que manipula o token: o modo de rastreamento
imprime cada comando expandido, incluindo a URL com o token dentro.

---

## Passo 5 — Configurar o Pages no repositório de publicação

1. Acesse <https://github.com/andradasdev/sql/settings/pages>
2. Em **Source**, escolha **GitHub Actions** (e não *Deploy from a branch*)

Sem isso, o passo `actions/deploy-pages` falha.

---

## Passo 6 — Testar

No repositório de código, **Actions** → **Compilar LaTeX e publicar em
andradasdev/sql** → **Run workflow**.

Fluxo esperado:

1. O workflow do código compila, verifica e commita os PDFs
2. Envia os artefatos para `andradasdev/sql`
3. O push dispara o workflow de Pages lá
4. O site sai em <https://andradasdev.github.io/sql/>

---

## Renovação

O token **expira** na data escolhida no Passo 1. Quando isso acontecer, o push
passa a falhar com `403` e o guia deixa de ser publicado, silenciosamente do
ponto de vista de quem só olha o site.

Para renovar: repita os passos 1 e 3 (o GitHub também oferece **Regenerate**
na página do token, o que preserva o nome e as permissões). O Passo 2 não
precisa ser refeito.

> O GitHub envia e-mail avisando da expiração próxima. Vale anotar a data no
> calendário mesmo assim.

---

## Diagnóstico de erros

| Sintoma | Causa provável | Correção |
|---|---|---|
| `remote: Permission ... denied` / `403` | Token pendente de aprovação na organização | Passo 2, fila **Pending requests** |
| `403` com o token já aprovado | `Resource owner` ficou como a conta pessoal | Recrie o token com owner `andradasdev` |
| `403` e o token está correto | Faltou **Contents: Read and write** | Edite as permissões do token |
| `could not read Username for 'https://github.com'` | O secret não existe ou o nome está diferente | Confira se é exatamente `PUBLISH_TOKEN` |
| `Repository not found` | O token não inclui o repositório `sql` | **Repository access** → selecione `sql` |
| Push funciona, mas o Pages não publica | Source do Pages não está em *GitHub Actions* | Passo 5 |
| Tudo verde, site com PDF velho | O passo detectou artefatos idênticos e não commitou | Comportamento esperado |
| `403` que começou do nada | O token expirou | Seção **Renovação** |

---

## Alternativas

O PAT não é a única forma. Fica registrado para quando fizer sentido trocar:

**Deploy Key (SSH).** Um par de chaves em que a pública vira *Deploy Key* com
escrita em `andradasdev/sql` e a privada vira secret no repositório de código.
**Não expira**, não depende de conta de usuário e alcança **um único**
repositório. É a opção mais segura e dispensa a aprovação de PAT na
organização. A desvantagem é ser SSH, exigindo configurar o agente de chaves
no runner.

**GitHub App.** Instalada na organização, gera tokens de curta duração sob
demanda. É o mais robusto para muitos repositórios, e o mais trabalhoso de
montar para apenas dois.

**`repository_dispatch`.** Em vez de dar escrita a outro repositório, o
primeiro só *avisa* o segundo, que busca os artefatos por conta própria. Troca
permissão de escrita por complexidade de coordenação.
