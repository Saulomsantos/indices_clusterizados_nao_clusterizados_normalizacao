--SELECIONANDO O BANCO DE DADOS AdventureWorks2012
USE AdventureWorks2012;

--AdventureWorks � UMA BASE DE EXEMPLO DISPONIBILIZADO PELA MS
--PARA TUTORIAIS E TESTES DOS USU�RIOS SEM TER QUE FICAR CRIANDO
--EXEMPLOS DO ZERO

--SCRIPT PARA CLONAR A TABELA Person.Person
--VERIFICA SE A TABELA Person.Person_Teste EXISTE
--CASO EXISTA, A EXCLUI
--ESTE PASSO � IMPORTANTE POIS S� � POSS�VEL CLONAR UMA TABELA
--EM UMA NOVA CASO ESTA NOVA AINDA N�O EXISTA
IF EXISTS (SELECT * FROM sys.tables 
WHERE OBJECT_ID =  OBJECT_ID('Person.Person_Teste'))
	DROP TABLE Person.Person_Teste;

--BUSCA TODA A ESTRUTURA E DADOS DA TABELA Person.Person
--E CLONA NA TABELA Person.Person_Teste MESMO QUE ESTA N�O EXISTA
SELECT * INTO Person.Person_Teste FROM Person.Person

--OU SEJA
--PARA CLONAR UMA TABELA NO SQL, BASTA SEGUIR A SINTAXE ABAIXO
--SELECT * INTO NOVA_TABELA FROM TABELA_A_SER_COPIADA

--VERIFICA SE O �NDICE Name_Index EXISTE E O EXCLUI, CASO EXISTA
IF EXISTS (SELECT * FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('Person.Person_Teste') 
AND name = 'Name_Index')
	DROP INDEX Person.Person_Teste.Name_Index;

--VERIFICA SE O �NDICE IX_Person_LastName_FirstName_MiddleName EXISTE
--CASO EXISTA, O EXCLUI
IF EXISTS (SELECT * FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('Person.Person_Teste')
AND name = 'IX_Person_LastName_FirstName_MiddleName')
	DROP INDEX Person.Person_Teste.IX_Person_LastName_FirstName_MiddleName;

--HABILITANDO A IMPRESS�O DE DADOS ESTAT�STICOS
SET STATISTICS io ON
SET STATISTICS time ON

--HABILITAR O TABLE SCAN PARA EXIBIR AS INFORMA��ES ESTAT�STICAS 
--A CADA CONSULTA E SEU DESEMPENHO (CTRL+M)

-----------------------------------------------------------------------------

-------------------------CONSULTA SEM �NDICES--------------------------------

-----------------------------------------------------------------------------

--BUSCANDO O SOBRENOME(LastName) DE UMA PESSOA
--SEM �NDICE E ANALISANDO O DESEMPENHO

SELECT * FROM Person.Person_Teste WHERE LastName = 'Brown';

--O RESULTADO CONSISTE EM 92 LINHAS DE UM TOTAL DE 19.972 LINHAS DA TABELA

--VERIFICAR A ABA PLANO DE EXECU��O PR�XIMA � DE RESULTADOS

--AO POSICIONAR O MOUSE SOBRE A EXECU��O SELE��O, NOTA-SE QUE ESSA QUERY 
--GEROU UM "CUSTO ESTIMADO DE SUB�RVORE" DE 2,84451
--ISTO REPRESENTA O CUSTO TOTAL DO OTIMIZADOR DO SQL PARA EXECUTAR N�O S�
--ESSA BUSCA MAS TODAS AS OPERA��ES DEPENDENTES DELA
--QUANTO MENOR O N�MERO, MENOR A INTENSIDADE DA EXECU��O PARA O BANCO

-----------------------------------------------------------------------------

----------------CONSULTA COM �NDICE N�O-CLUSTERIZADO-------------------------

-----------------------------------------------------------------------------

--PARA REALIZAR ESTA BUSCA, AGORA ATRAV�S DE UM �NDICE N�O-CLUSTERIZADO,
--PRIMEIRO � PRECISO CRIAR O �NDICE ENVOLVENDO A COLUNA EM QUEST�O

--CRIANDO O �NDICE N�O-CLUSTERIZADO Name_Index
CREATE NONCLUSTERED INDEX Name_Index
ON	Person.Person_Teste(LastName)

--OU SEJA
--PARA CRIAR UM �NDICE N�O-CLUSTERIZADO BASTA INFORMAR QUE ELE N�O SER�
--CLUSTERIZADO (NONCLUSTERED INDEX) E DAR UM NOME A ELE (Name_Index)
--E APONTAR PARA A TABELA E A COLUNA (Person.Person_Teste(LastName))

--REALIZANDO NOVA CONSULTA NOS MESMOS MOLDES DA ANTERIOR
SELECT * FROM Person.Person_Teste WHERE LastName = 'Brown';

--OBVIAMENTE, SE OBT�M AS MESMAS 92 LINHAS DE UM TOTAL DE 19.972 LINHAS DA TABELA

--ANALISANDO O RESULTADO DO PLANO DE EXECU��O

--AGORA AO POSICIONAR O MOUSE SOBRE A EXECU��O SELE��O, NOTA-SE QUE ESSA QUERY 
--GEROU UM "CUSTO ESTIMADO DE SUB�RVORE" DE 0,299353
--UMA REDU��O DE APROXIMADAMENTE 90% DO CUSTO DO OTIMIZADOR
--J� ILUSTRA O GANHO EM QUALQUER TIPO DE CONSULTA REALIZADA COM	
--ESSE TIPO DE �NDICE

-----------------------------------------------------------------------------

--------------------CONSULTA COM �NDICE CLUSTERIZADO-------------------------

-----------------------------------------------------------------------------

--PARA REALIZAR O TESTE COM UM �NDICE CLUSTERIZADO, PRIMEIRO � PRECISO
--EXCLUIR O N�O-CLUSTERIZADO CRIADO ANTERIORMENTE
--E EM SEGUIDA CRIAR UM NOVO �NDICE, DESTA VEZ CLUSTERIZADO

--EXCLUINDO O �NDICE N�O-CLUSTERIZADO Name_Index
IF EXISTS (SELECT * FROM sys.indexes 
WHERE OBJECT_ID = OBJECT_ID('Person.Person_Teste')
AND name = 'Name_Index')
	DROP INDEX Person.Person_Teste.Name_Index;

--CRIANDO O �NDICE CLUSTERIZADO Name_Index
CREATE CLUSTERED INDEX Name_Index
ON	Person.Person_Teste(LastName);

--OU SEJA
--PARA CRIAR UM �NDICE CLUSTERIZADO BASTA INFORMAR QUE ELE SER�
--CLUSTERIZADO (CLUSTERED INDEX) E DAR UM NOME A ELE (Name_Index)
--E APONTAR PARA A TABELA E A COLUNA (Person.Person_Teste(LastName))

--REALIZANDO NOVA CONSULTA NOS MESMOS MOLDES DAS ANTERIORES
SELECT * FROM Person.Person_Teste WHERE LastName = 'Brown';

--NOVAMENTE, TEM-SE 92 LINHAS DE UM TOTAL DE 19.972 LINHAS DA TABELA

--ANALISANDO O RESULTADO DO PLANO DE EXECU��O

--AO POSICIONAR O MOUSE SOBRE A EXECU��O SELE��O, NOTA-SE QUE
--O "CUSTO ESTIMADO DE SUB�RVORE" DESTA VEZ FOI DE 0,0155985!
--COMPARANDO COM A BUSCA SEM �NDICE ONDE O CUSTO FOI DE 2,84451
--ISTO REPRESENTA UMA REDU��O DE APROXIMADAMENTE 99,5% (!!!) DO CUSTO DO OTIMIZADOR
--UM ENORME GANHO LEVANDO EM CONTA UMA MASSA EXPRESSIVA DE DADOS




--fonte do teste
--https://www.devmedia.com.br/indices-clusterizados-e-nao-clusterizados-no-sql-server/30288




-----------------------------------------------------------------------------

--------------------------------LINKS �TEIS----------------------------------

-----------------------------------------------------------------------------

--como restaurar um banco de dados atrav�s de um arquivo .bak
--https://docs.microsoft.com/pt-pt/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-2017

--reposit�rio do github com os arquivos .bak armazenados
--https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks

--tipos de �ndices
--https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/indexes?view=sql-server-2017

--descri��o dos conceitos
--https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described?view=sql-server-2017
