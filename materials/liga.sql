-- ============================================================
-- Capacitação de MySQL — Liga Acadêmica
-- Script completo da aula (Anexo B do guia)
-- ============================================================
-- COMO USAR
--   1. Troque `liga_SEUNOME` pelo seu banco nas linhas 22, 23 e 24.
--      Ex.: liga_ana, liga_joao, liga_maria.
--      Só letras minúsculas, sem acento e sem espaço.
--   2. Cole no phpMyAdmin, aba SQL, e execute.
--
-- O login da turma só tem permissão em bancos que começam com
-- "liga_". Qualquer outro nome retorna ERROR 1044.
-- ============================================================

-- ============================================================
-- Capacitação MySQL — Liga Acadêmica
-- Cenário: cadastro de membros e cursos
-- ============================================================

-- 1. BANCO ---------------------------------------------------
-- O DROP zera SÓ o seu banco, para o script poder ser rodado de novo.
DROP DATABASE IF EXISTS liga_SEUNOME;
CREATE DATABASE liga_SEUNOME CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE liga_SEUNOME;

-- 2. ESTRUTURA (DDL) -----------------------------------------
CREATE TABLE curso (
  id   INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE membro (
  id            INT           AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(120)  NOT NULL,
  email         VARCHAR(160)  NOT NULL UNIQUE,
  periodo       TINYINT       NOT NULL,
  data_ingresso DATE          NOT NULL,
  ativo         BOOLEAN       NOT NULL DEFAULT TRUE,
  curso_id      INT           NULL,
  criado_em     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_membro_curso
    FOREIGN KEY (curso_id) REFERENCES curso(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. DADOS (INSERT) ------------------------------------------
INSERT INTO curso (nome) VALUES
  ('Engenharia de Software'),
  ('Ciência da Computação'),
  ('Sistemas de Informação'),
  ('Engenharia de Produção');

INSERT INTO membro (nome, email, periodo, data_ingresso, curso_id) VALUES
  ('Ana Souza',   'ana@liga.edu.br',   7, '2024-03-11', 1),
  ('Bruno Lima',  'bruno@liga.edu.br', 3, '2025-02-20', 2),
  ('Carla Dias',  'carla@liga.edu.br', 5, '2024-08-05', 1),
  ('Diego Rocha', 'diego@liga.edu.br', 9, '2023-09-14', 3),
  ('Elisa Prado', 'elisa@liga.edu.br', 1, '2026-03-02', NULL);

-- 4. CONSULTAS (SELECT) --------------------------------------
SELECT * FROM membro;
SELECT nome, email FROM membro WHERE periodo > 5;
SELECT * FROM membro WHERE nome LIKE 'A%';
SELECT * FROM membro WHERE curso_id IS NULL;
SELECT nome, periodo FROM membro ORDER BY periodo DESC;
SELECT nome FROM membro ORDER BY data_ingresso ASC LIMIT 3;

-- 5. ALTERAÇÃO E REMOÇÃO -------------------------------------
SELECT * FROM membro WHERE id = 1;          -- confira ANTES
UPDATE membro SET periodo = 8 WHERE id = 1;

-- registro descartável, criado só para ser apagado
INSERT INTO membro (nome, email, periodo, data_ingresso)
VALUES ('Registro Teste', 'teste@liga.edu.br', 1, '2026-01-01');

SELECT * FROM membro WHERE email = 'teste@liga.edu.br';   -- confira ANTES
DELETE FROM membro WHERE email = 'teste@liga.edu.br';

-- 6. RELACIONAMENTO (JOIN) -----------------------------------
SELECT m.nome AS membro, c.nome AS curso, m.periodo
FROM   membro m
INNER  JOIN curso c ON m.curso_id = c.id
ORDER  BY c.nome, m.nome;

SELECT m.nome AS membro, c.nome AS curso
FROM   membro m
LEFT   JOIN curso c ON m.curso_id = c.id;

-- 7. BÔNUS: AGREGAÇÃO ----------------------------------------
SELECT c.nome AS curso, COUNT(m.id) AS total_membros
FROM   curso c
LEFT   JOIN membro m ON m.curso_id = c.id
GROUP  BY c.id, c.nome
ORDER  BY total_membros DESC;
