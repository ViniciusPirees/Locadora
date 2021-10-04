CREATE DATABASE LOCADORA;
GO
USE LOCADORA;
GO

DROP TABLE LOC_FILME
--
--
--
--
--
--
--
--
--
/*Tabela FILME*/
CREATE TABLE LOC_FILME(
FIL_IN_CODIGO INT NOT NULL IDENTITY CONSTRAINT LOC_PK_FILME PRIMARY KEY,
FIL_ST_NOME VARCHAR(100) NOT NULL,
FIL_IN_ANO INT NOT NULL CONSTRAINT LOC_CK_FIL_ANO CHECK(FIL_IN_ANO>=1870 AND FIL_IN_ANO<=2030),
FIL_ST_CATEGORIA VARCHAR(30) NOT NULL,
FIL_ST_DIRETOR VARCHAR(100) NOT NULL,
FIL_ST_DESCRICAO VARCHAR(1000) NULL,
FIL_DT_INCLUSAO SMALLDATETIME NULL CONSTRAINT LOC_DF_FIL_INCLUSAO DEFAULT GETDATE(),
)
-
-
-
-
-
INSERT INTO LOC_FILME (FIL_ST_NOME, FIL_IN_ANO, FIL_ST_CATEGORIA, FIL_ST_DIRETOR, FIL_ST_DESCRICAO) VALUES
('Candyman',2021,'Terror','Nia DaCosta','Um jovem artista cria uma exposição sobre Candyman, uma criatura maligna que, segundo as lendas, pode ser invocada diante de um
espelho. Aos poucos, o fascínio do rapaz pelo monstro o joga em uma trama de mistérios, sangue e morte.')
-
-
-
-
-
--
--
--

-- Procedure Consultar todos os registros
ALTER PROCEDURE SP_S_LOC_FILME 
AS
SELECT
	FIL_IN_CODIGO AS 'Código',
	TRIM(UPPER(FIL_ST_NOME)) AS 'Nome do Filme', FIL_IN_ANO AS 'Ano', TRIM(UPPER(FIL_ST_CATEGORIA)) AS 'Categoria',
	FIL_ST_DIRETOR AS 'Diretor(a)', FIL_ST_DESCRICAO AS 'Descrição', FIL_DT_INCLUSAO AS 'Inclusão'
	FROM LOC_FILME
	ORDER BY
	FIL_IN_CODIGO
GO
--
EXEC SP_S_LOC_FILME
--
--
--
--
---
--
--
--
--
--
--Procedure Consultar registros por nome
ALTER PROCEDURE SP_S_LOC_FILME_FILTRONOME(

@FILTRONOME VARCHAR(100))
AS
SET NOCOUNT ON
DECLARE @NR_NOMEFILME INT

SELECT @NR_NOMEFILME = COUNT(FIL_ST_NOME) 
FROM LOC_FILME 
WHERE FIL_ST_NOME LIKE '%'+@FILTRONOME+'%'

IF LEN(TRIM(@FILTRONOME)) < 1
BEGIN
   RAISERROR('O nome do filme deve possuir no mínimo 1 caracter!',15,1)
   RETURN
END

IF @NR_NOMEFILME = 0
BEGIN
   RAISERROR('O Filme informado não existe!',15,1)
   RETURN
END

SELECT
 FIL_IN_CODIGO AS 'Código',
	TRIM(UPPER(FIL_ST_NOME)) AS 'Nome do Filme', LTRIM(FIL_IN_ANO) AS 'Ano', TRIM(UPPER(FIL_ST_CATEGORIA)) AS 'Categoria',
	TRIM(UPPER(FIL_ST_DIRETOR)) AS 'Diretor(a)', TRIM(FIL_ST_DESCRICAO) AS 'Descrição'
	FROM 
	LOC_FILME
	WHERE
	FIL_ST_NOME LIKE '%'+@FILTRONOME+'%'
	ORDER BY
	FIL_ST_NOME
GO

--SELECT * FROM LOC_FILME WHERE FIL_ST_CATEGORIA LIKE '%Ação%'

EXEC SP_S_LOC_FILME_FILTRONOME ''
--
--
--
--
--
--
---
---
--
--INCLUIR FILME
ALTER PROCEDURE SP_I_LOC_FILME
@NOME VARCHAR(100), @ANO INT, @CATEGORIA VARCHAR(30), @DIRETOR VARCHAR(100), @DESCRICAO VARCHAR(1000), --PARÂMETRO DE ENTRADA
@CODIGOGERADO INT=0 OUT --PARÂMETRO DE SAÍDA
AS
SET NOCOUNT ON -- DESLIGA A MSG DE LINHAS AFETADAS

DECLARE @NR_NOME INT
DECLARE @NR_ANO INT

SELECT @NR_NOME = COUNT(FIL_ST_NOME) 
FROM LOC_FILME WHERE FIL_ST_NOME = @NOME

SELECT @NR_ANO = COUNT(FIL_IN_ANO) 
FROM LOC_FILME WHERE FIL_IN_ANO = @ANO

IF @NR_NOME > 0 AND @NR_ANO > 0
  BEGIN
	RAISERROR('Este filme já existe!',15,1)
	RETURN
  END

IF LTRIM(@ANO) > 2030 OR LTRIM(@ANO) < 1870
BEGIN
	RAISERROR('O ano do filme deve ser entre 1870 a 2030',15,1)	
	RETURN
END

IF LEN(TRIM(@NOME)) < 1
BEGIN
   RAISERROR('O nome do filme deve possuir no mínimo 1 caracter!',15,1)
   RETURN
END
INSERT INTO LOC_FILME(FIL_ST_NOME, FIL_IN_ANO, FIL_ST_CATEGORIA,FIL_ST_DIRETOR, FIL_ST_DESCRICAO) VALUES (@NOME, @ANO, @CATEGORIA, @DIRETOR, @DESCRICAO)
SET @CODIGOGERADO = SCOPE_IDENTITY() /* RETORNA O VALOR DO IDENTITY ATUAL */
RETURN @CODIGOGERADO
GO
--

EXEC SP_I_LOC_FILME 'Piratas do Caribe: A Maldição do Pérola Negra', '2003', 'Aventura/Ação', 'Gore Verbinski', 'O pirata Jack Sparrow tem seu navio saqueado e roubado pelo capitão Barbossa e sua tripulação. Com o navio de Sparrow, Barbossa invade a cidade de Port Royal, levando consigo Elizabeth Swann, filha do governador. Para recuperar sua embarcação, Sparrow recebe a ajuda de Will Turner, um grande amigo de Elizabeth. Eles desbravam os mares em direção à misteriosa Ilha da Morte, tentando impedir que os piratas-esqueleto derramem o sangue de Elizabeth para desfazer a maldição que os assola.'

--
--
--
--
--
--
--
--
--UPDATE NOME DO FILME

ALTER PROCEDURE SP_U_LOC_FILME
@COD INT, @NOME VARCHAR(100)
AS
SET NOCOUNT ON -- DESLIGA A MSG DE LINHAS AFETADAS

DECLARE @NR_CODFILME INT

SELECT @NR_CODFILME = COUNT(FIL_IN_CODIGO) 
FROM LOC_FILME 
WHERE FIL_IN_CODIGO = @COD

IF @NR_CODFILME = 0
BEGIN
   RAISERROR('O código informado não existe!',15,1)
   RETURN
END

IF LEN(TRIM(@NOME)) < 1
BEGIN
   RAISERROR('O nome do filme deve possuir no mínimo 1 caracter!',15,1)
   RETURN
END


UPDATE LOC_FILME
	SET FIL_ST_NOME = @NOME 
	WHERE FIL_IN_CODIGO = @COD
RETURN
GO
--
EXEC SP_U_LOC_FILME '1008', 'Tubarão'
--
--
--
--
--
--
--
--DELETE FILME

ALTER PROCEDURE SP_D_LOC_FILME(
@COD INT) AS
SET NOCOUNT ON
DECLARE @CODFILME INT

SELECT @CODFILME = COUNT(FIL_IN_CODIGO) 
FROM LOC_FILME 
WHERE FIL_IN_CODIGO = @COD

IF @CODFILME = 0
BEGIN
	RAISERROR('O código do filme informado não existe!',15,1)
	RETURN
END

DELETE FROM LOC_FILME WHERE FIL_IN_CODIGO = @COD 
RETURN
GO

EXEC SP_D_LOC_FILME '1006'
--
--
--
--
--
--
--
--
-- FILTRO CATEGORIA
ALTER PROCEDURE SP_S_LOC_FILME_FILTROCATEGORIA
@FILTROCATEGORIA VARCHAR(100)
AS
SET NOCOUNT ON

DECLARE @NR_CATFILME INT

SELECT @NR_CATFILME = COUNT(FIL_ST_CATEGORIA) 
FROM LOC_FILME 
WHERE FIL_ST_CATEGORIA LIKE '%'+@FILTROCATEGORIA+'%'

IF LEN(TRIM(@FILTROCATEGORIA)) < 1
BEGIN
   RAISERROR('O nome da categoria deve possuir no mínimo 1 caracter!',15,1)
   RETURN
END

IF @NR_CATFILME = 0
BEGIN
   RAISERROR('A categoria informada não existe!',15,1)
   RETURN
END



SELECT
 FIL_IN_CODIGO AS 'Código',
	TRIM(UPPER(FIL_ST_NOME)) AS 'Nome do Filme', LTRIM(FIL_IN_ANO) AS 'Ano', TRIM(UPPER(FIL_ST_CATEGORIA)) AS 'Categoria',
	TRIM(UPPER(FIL_ST_DIRETOR)) AS 'Diretor(a)', TRIM(FIL_ST_DESCRICAO) AS 'Descrição'
	FROM 
	LOC_FILME
	WHERE
	FIL_ST_CATEGORIA LIKE '%'+@FILTROCATEGORIA+'%'
	ORDER BY
	FIL_ST_CATEGORIA

GO
--
--
EXEC SP_S_LOC_FILME_FILTROCATEGORIA 'Drama'
--
--
--
--
--
-- FILTRO ANO
ALTER PROCEDURE SP_S_LOC_FILME_FILTROANO
@FILTROANO INT
AS
SET NOCOUNT ON

DECLARE @NR_ANO INT

SELECT @NR_ANO = COUNT(FIL_IN_ANO) 
FROM LOC_FILME 
WHERE FIL_IN_ANO = @FILTROANO

IF LTRIM(@FILTROANO) > 2030 OR LTRIM(@FILTROANO) < 1870
BEGIN
	RAISERROR('O ano do filme deve ser entre 1870 a 2030',15,1)	
	RETURN
END

IF @NR_ANO = 0
BEGIN
   RAISERROR('Não existe filme do ano informado na Locadora!',15,1)
   RETURN
END

SELECT
 FIL_IN_CODIGO AS 'Código',
	TRIM(UPPER(FIL_ST_NOME)) AS 'Nome do Filme', LTRIM(FIL_IN_ANO) AS 'Ano', TRIM(UPPER(FIL_ST_CATEGORIA)) AS 'Categoria',
	TRIM(UPPER(FIL_ST_DIRETOR)) AS 'Diretor(a)', TRIM(FIL_ST_DESCRICAO) AS 'Descrição'
	FROM 
	LOC_FILME
	WHERE
	FIL_IN_ANO = @FILTROANO
	ORDER BY
	FIL_ST_NOME

GO

EXEC SP_S_LOC_FILME_FILTROANO '2021'
