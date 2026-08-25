# Capacitação de SQL e MySQL

![MySQL](https://img.shields.io/badge/MySQL-8.4_LTS-4479A1?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Fundamentos-336791)
![Publicação](https://img.shields.io/badge/GitHub_Pages-publicado-614AD3)
![Licença](https://img.shields.io/badge/conteúdo-CC_BY--SA_4.0-lightgrey)

Material público da capacitação introdutória de **SQL e MySQL**, com duração de
**2 horas**, sem pré-requisito de banco de dados.

### 📖 **[Acessar o material](https://andradasdev.github.io/sql/)**

| | |
|---|---|
| 📘 Apostila completa | [`docs/guia.pdf`](docs/guia.pdf) |
| 🖥️ Slides da apresentação | [`docs/apresentacao.pdf`](docs/apresentacao.pdf) |
| 💾 Script SQL da aula | [`materials/liga.sql`](materials/liga.sql) |

---

## 🧭 Este repositório é só de publicação

Aqui ficam apenas os **artefatos prontos**. Eles não são editados neste
repositório: chegam por automação, compilados a partir das fontes LaTeX.

> ### 👉 Para ver o código-fonte, ir ao repositório de código:
> ## **[github.com/ronidomingues/mysql-capacitation](https://github.com/ronidomingues/mysql-capacitation)**
>
> É lá que estão as fontes `.tex` do guia e dos slides, os scripts SQL, o
> ambiente Docker da aula e o histórico de desenvolvimento. **Correções e
> contribuições devem ser abertas lá** — qualquer alteração feita diretamente
> aqui será sobrescrita na próxima publicação.

### Como o material chega até aqui

```
  ronidomingues/mysql-capacitation                andradasdev/sql
  ────────────────────────────────                ───────────────
   fontes .tex, .sql, Docker
            │
            │  push na main
            v
   ┌──────────────────────┐
   │ workflow: build.yml  │
   │  1. compila LaTeX    │
   │  2. verifica os PDFs │
   │  3. commita lá       │
   │  4. envia para cá ───┼──────────────>  guia.pdf
   └──────────────────────┘                 apresentacao.pdf
                                            liga.sql
                                                  │
                                                  │ dispara
                                                  v
                                        ┌──────────────────────┐
                                        │ workflow: pages.yml  │
                                        │  publica o site      │
                                        └──────────┬───────────┘
                                                   v
                                     andradasdev.github.io/sql
```

A autenticação entre os dois repositórios está documentada em
**[`documentacao/autenticacao-github-actions.md`](documentacao/autenticacao-github-actions.md)**.

---

## 🎯 O que a capacitação cobre

Ao final, o participante é capaz de:

1. Explicar o que é um SGBD e o que significa "relacional"
2. Conectar-se a um servidor MySQL usando um cliente SQL
3. Criar banco e tabela com tipos, chave primária e restrições
4. Executar o CRUD: `INSERT`, `SELECT`, `UPDATE`, `DELETE`
5. Filtrar e ordenar com `WHERE`, `ORDER BY`, `LIMIT`
6. Relacionar duas tabelas com chave estrangeira e consultá-las com `JOIN`

**Fora do escopo:** Docker, normalização formal, índices, transações, *views*,
*procedures*, backup e NoSQL. Cada um é uma capacitação inteira por si só.

### Os 120 minutos

| # | Bloco | Início | Duração |
|---|---|---|---|
| 0 | Abertura, objetivos e escopo | 00:00 | 5 min |
| 1 | Conceitos-base: dado, banco, SGBD, relacional, SQL | 00:05 | 15 min |
| 2 | Ambiente e cliente SQL: todos conectados | 00:20 | 15 min |
| 3 | DDL: banco, tipos, tabela, chave primária | 00:35 | 20 min |
| — | *Pausa* | 00:55 | 5 min |
| 4 | `INSERT` e `SELECT` com filtros | 01:00 | 25 min |
| 5 | `UPDATE`, `DELETE` e o perigo do `WHERE` ausente | 01:25 | 10 min |
| 6 | Chave estrangeira e `JOIN` | 01:35 | 20 min |
| 7 | Erros comuns, próximos passos e dúvidas | 01:55 | 5 min |
| | **Total** | | **120 min** |

Cerca de 75 dos 120 minutos são de prática guiada.

---

## 🚀 Usando o material por conta própria

O guia e os slides bastam para estudar sozinho. Para **reaplicar** a
capacitação a uma turma, o repositório de código traz o ambiente completo:
MySQL 8.4 e phpMyAdmin em containers, com um túnel opcional para os
participantes acessarem pelo navegador, sem instalar nada.

O script [`materials/liga.sql`](materials/liga.sql) reconstrói todo o cenário
da aula — as tabelas `curso` e `membro`, os dados de exemplo e as consultas.
Basta trocar `liga_SEUNOME` pelo nome do seu banco e colar num cliente SQL.

---

## 📂 Estrutura

```
sql/
├── docs/
│   ├── guia.pdf              apostila (gerada, não editar aqui)
│   └── apresentacao.pdf      slides (gerados, não editar aqui)
├── materials/
│   └── liga.sql              script da aula (gerado, não editar aqui)
├── documentacao/
│   └── autenticacao-github-actions.md
├── index.html                página publicada no GitHub Pages
├── LICENSE                   MIT, para o código
├── LICENSE-CONTENT           CC BY-SA 4.0, para o conteúdo didático
└── README.md
```

---

## ⚖️ Licença

- **Conteúdo didático** (guia, slides, textos, exercícios) — [CC BY-SA 4.0](LICENSE-CONTENT)
- **Código** (scripts SQL, workflows, `index.html`) — [MIT](LICENSE)

Você pode usar, adaptar e reaplicar este material, inclusive comercialmente,
desde que dê o crédito e mantenha a mesma licença nas suas adaptações.

## 👨‍🏫 Autor

**Ronivaldo Domingues de Andrade**
LinkedIn: [ronidomingues](https://www.linkedin.com/in/ronidomingues/) ·
GitHub: [@ronidomingues](https://github.com/ronidomingues)
📍 Rio de Janeiro — RJ

### ⭐ Se este material foi útil, considere dar uma estrela no repositório!
