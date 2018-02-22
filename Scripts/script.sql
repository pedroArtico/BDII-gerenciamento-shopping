/***********************************************************************
Título: script de banco de dados para o gerenciamento de um shopping
Linguagem: T-SQL

Este script faz parte do trabalho desenvolvido para a disciplina de Banco de Dados II
na Faculdade de Tecnologia da Unicamp

Data: 22/11/2017

Dica: o script está dividido em áreas, para mudar rapidamente entre essas áreas pesquise por *MARK*
***********************************************************************/


USE [master]
GO
/*=========================================================================================================== 
*MARK*
## ARQUIVOS 
=============================================================================================================*/
/****** Object:  Database [bd_shopping]    Script Date: 22/11/2017 11:57:09 ******/
CREATE DATABASE [bd_shopping]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'bd_shopping', FILENAME = N'c:\Program Files (x86)\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\bd_shopping.mdf' , SIZE = 20480KB , MAXSIZE = UNLIMITED, FILEGROWTH = 5120KB )
 LOG ON 
( NAME = N'bd_shopping_log', FILENAME = N'c:\Program Files (x86)\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\bd_shopping_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [bd_shopping] SET COMPATIBILITY_LEVEL = 110
GO
ALTER DATABASE [bd_shopping] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [bd_shopping] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [bd_shopping] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [bd_shopping] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [bd_shopping] SET ARITHABORT OFF 
GO
ALTER DATABASE [bd_shopping] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [bd_shopping] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [bd_shopping] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [bd_shopping] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [bd_shopping] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [bd_shopping] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [bd_shopping] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [bd_shopping] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [bd_shopping] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [bd_shopping] SET  ENABLE_BROKER 
GO
ALTER DATABASE [bd_shopping] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [bd_shopping] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [bd_shopping] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [bd_shopping] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [bd_shopping] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [bd_shopping] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [bd_shopping] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [bd_shopping] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [bd_shopping] SET  MULTI_USER 
GO
ALTER DATABASE [bd_shopping] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [bd_shopping] SET DB_CHAINING OFF 
GO
ALTER DATABASE [bd_shopping] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [bd_shopping] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [bd_shopping]
GO
/*=========================================================================================================== 
*MARK*
## SCHEMAS
=============================================================================================================*/
/****** Object:  Schema [schem_estacionamento]    Script Date: 22/11/2017 11:57:10 ******/
CREATE SCHEMA [schem_estacionamento]
GO
/****** Object:  Schema [schem_locacao]    Script Date: 22/11/2017 11:57:10 ******/
CREATE SCHEMA [schem_locacao]
GO
/****** Object:  Schema [schem_prog_usp_usf]    Script Date: 22/11/2017 11:57:10 ******/
CREATE SCHEMA [schem_prog_usp_usf]
GO
/****** Object:  Schema [schem_standard]    Script Date: 22/11/2017 11:57:10 ******/
CREATE SCHEMA [schem_standard]
GO
/****** Object:  Schema [schem_views]    Script Date: 22/11/2017 11:57:10 ******/
CREATE SCHEMA [schem_views]
GO


/*=========================================================================================================== 
*MARK*
## FUNCTIONS
=============================================================================================================*/
/****** Object:  UserDefinedFunction [schem_prog_usp_usf].[usf_valida_cnpj]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [schem_prog_usp_usf].[usf_valida_cnpj](
	@CNPJ CHAR(14)
)RETURNS BIT
AS
-- Essa função foi baseada na versão disponível em [https://www.dirceuresende.com/blog/validando-cpf-cnpj-e-mail-telefone-e-cep-no-sql-server/] (18/11/2017)
BEGIN
  DECLARE @INDICE INT = 1 
  DECLARE @SOMA INT = 0 
  DECLARE @DIG1 INT 
  DECLARE @DIG2 INT 
  DECLARE @VAR1 INT 
  DECLARE @VAR2 INT
  DECLARE @RESULTADO BIT = 0
    
    /* CÁLCULO DO 1º DÍGITO */
    /* CÁLCULO DA 1ª PARTE DO ALGORÍTIOM 5432 */
    SET @VAR1 = 5 /* 1a Parte do Algorítimo começando de "5" */
    WHILE (@INDICE <= 4)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CNPJ,@INDICE,1)) * @VAR1
      SET @INDICE = @INDICE + 1 /* Navegando um-a-um até < = 4, as quatro primeira posições */
      SET @VAR1 = @VAR1 - 1       /* subtraindo o algorítimo de 5 até 2 */
    END
    /* CÁLCULO DA 2ª PARTE DO ALGORÍTIOM 98765432 */
    SET @VAR2 = 9
    WHILE (@INDICE <= 12)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CNPJ,@INDICE,1)) * @VAR2
      SET @INDICE = @INDICE + 1
      SET @VAR2 = @VAR2 - 1            
    END
       SET @DIG1 = (@soma % 11)
       /* SE O RESTO DA DIVISÃO FOR < 2, O DIGITO = 0 */
       IF @DIG1 < 2
            SET @DIG1 = 0;
       ELSE /* SE O RESTO DA DIVISÃO NÃO FOR < 2*/
            SET @DIG1 = 11 - (@soma % 11);
    /* CÁLCULO DO 2º DÍGITO */
    /* ZERANDO O INDICE E A SOMA PARA COMEÇAR A CALCULAR O 2º DÍGITO*/   
    SET @INDICE = 1
    SET @SOMA = 0
    /* CÁLCULO DA 1ª PARTE DO ALGORÍTIOM 65432 */
    SET @VAR1 = 6 /* 2a Parte do Algorítimo começando de "6" */
    SET @RESULTADO = 0
    WHILE (@INDICE <= 5)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CNPJ,@INDICE,1)) * @VAR1
      SET @INDICE = @INDICE + 1 /* Navegando um-a-um até < = 5, as quatro primeira posições */
      SET @VAR1 = @VAR1 - 1       /* subtraindo o algorítimo de 6 até 2 */
    END
    /* CÁLCULO DA 2ª PARTE DO ALGORÍTIOM 98765432 */
    SET @VAR2 = 9
    WHILE (@INDICE <= 13)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CNPJ,@INDICE,1)) * @VAR2
      SET @INDICE = @INDICE + 1
      SET @VAR2 = @VAR2 - 1            
    END
       SET @DIG2 = (@soma % 11)
       /* SE O RESTO DA DIVISÃO FOR < 2, O DIGITO = 0 */
       IF @DIG2 < 2
           SET @DIG2 = 0;
       ELSE /* SE O RESTO DA DIVISÃO NÃO FOR < 2*/
           SET @DIG2 = 11 - (@soma % 11);
-- Validando
    IF (@DIG1 = SUBSTRING(@CNPJ,LEN(@CNPJ)-1,1)) AND (@DIG2 = SUBSTRING(@CNPJ,LEN(@CNPJ),1)) BEGIN
      SET @RESULTADO = 1
	END
    ELSE BEGIN
      SET @RESULTADO = 0
	END
	RETURN @RESULTADO
  END


GO
/****** Object:  UserDefinedFunction [schem_prog_usp_usf].[usf_valida_email]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [schem_prog_usp_usf].[usf_valida_email] (@Ds_Email CHAR(100))
-- Essa função foi baseada na versão disponível em [https://www.dirceuresende.com/blog/validando-cpf-cnpj-e-mail-telefone-e-cep-no-sql-server/] (18/11/2017)
RETURNS BIT
AS
BEGIN
  DECLARE @Retorno BIT = 0
  SELECT
    @Retorno = 1
  WHERE @Ds_Email NOT LIKE '%[^a-z,0-9,@,.-_]%'
  AND @Ds_Email LIKE '%_@_%_.__%'
  RETURN @Retorno
END



GO
/****** Object:  Table [schem_estacionamento].[tbl_estacionamento]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=========================================================================================================== 
*MARK*
## TABELAS
=============================================================================================================*/
CREATE TABLE [schem_estacionamento].[tbl_estacionamento](
	[PK_idEstacionamento] [int] IDENTITY(1,1) NOT NULL,
	[total_vagas] [int] NOT NULL,
	[qtdeVagasCliente] [int] NOT NULL,
	[fluxo_diario] [int] NULL,
	[qtdVagasLojista] [int] NOT NULL,
	[preco_por_hora_para_cliente] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idEstacionamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_estacionamento].[tbl_situacao_vaga]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_estacionamento].[tbl_situacao_vaga](
	[PK_idEstadoVaga] [int] IDENTITY(1,1) NOT NULL,
	[texto_situacao] [char](16) NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idEstadoVaga] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_estacionamento].[tbl_tiquete]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_estacionamento].[tbl_tiquete](
	[PK_idTiquete] [int] IDENTITY(1,1) NOT NULL,
	[valor] [money] NOT NULL,
	[hora_saida] [datetime] NULL,
	[hora_entrada] [datetime] NULL,
	[FK_cliente_PK_idCliente] [int] NULL,
	[FK_vaga_cliente_PK_idVagaCliente] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idTiquete] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_estacionamento].[tbl_vaga_cliente]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_estacionamento].[tbl_vaga_cliente](
	[PK_idVagaCliente] [int] IDENTITY(1,1) NOT NULL,
	[FK_estacionamento_PK_idEstacionamento] [int] NOT NULL,
	[FK_estacionamento_PK_idEstadoVaga] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idVagaCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_estacionamento].[tbl_vaga_lojista]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_estacionamento].[tbl_vaga_lojista](
	[PK_idVagaLojista] [int] IDENTITY(1,1) NOT NULL,
	[FK_estacionamento_PK_idEstacionamento] [int] NOT NULL,
	[FK_estacionamento_PK_idEstadoVaga] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idVagaLojista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_locacao].[tbl_contrato]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_contrato](
	[PK_idContrato] [int] IDENTITY(1,1) NOT NULL,
	[prazo_expiracao] [date] NOT NULL,
	[staus_contrato] [char](20) NULL,
	[prazo_inicio] [date] NULL,
	[tipo_contrato] [char](20) NULL,
	[valor] [money] NULL,
	[FK_espaco_PK_idEspaco] [int] NOT NULL,
	[FK_administrador_PK_idAdm] [int] NOT NULL,
	[FK_interessado_idInteressado] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_fornece_para]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_fornece_para](
	[PK_fornecePara] [int] IDENTITY(1,1) NOT NULL,
	[FK_fornecedor_PK_idFornecedor] [int] NOT NULL,
	[FK_loja_PK_idLoja] [int] NOT NULL,
	[tipo_material] [char](25) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_fornecePara] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_fornecedor]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_fornecedor](
	[PK_idFornecedor] [int] IDENTITY(1,1) NOT NULL,
	[nome] [char](50) NOT NULL,
	[permissao] [char](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idFornecedor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_interessado]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_interessado](
	[idInteressado] [int] IDENTITY(1,1) NOT NULL,
	[nome] [char](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idInteressado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_loja]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_loja](
	[PK_idLoja] [int] IDENTITY(1,1) NOT NULL,
	[ramo_atuacao] [char](100) NULL,
	[nome] [char](30) NOT NULL,
	[FK_lojista_PK_idLojista] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idLoja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_lojista]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_lojista](
	[PK_idLojista] [int] IDENTITY(1,1) NOT NULL,
	[situacao] [char](20) NULL,
	[cnpj] [char](18) NOT NULL,
	[FK_vaga_lojista_PK_idVagaLojista] [int] NULL,
	[FK_interessado_idInteressado] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idLojista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_mensalidade]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_locacao].[tbl_mensalidade](
	[PK_idMensalidade] [int] IDENTITY(1,1) NOT NULL,
	[forma_pagamento] [char](100) NOT NULL,
	[data_dia] [datetime] NOT NULL,
	[status_do_pagamento] [char](20) NULL,
	[FK_contrato_interessado_PK_idContrato] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idMensalidade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_locacao].[tbl_procura]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_locacao].[tbl_procura](
	[PK_procura] [int] IDENTITY(1,1) NOT NULL,
	[FK_administrador_PK_idAdm] [int] NOT NULL,
	[FK_interessado_idInteressado] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_procura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_standard].[tbl_acessa]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_acessa](
	[PK_idAcessa] [int] IDENTITY(1,1) NOT NULL,
	[FK_conta_PK_login] [char](20) NOT NULL,
	[FK_wifi_PK_idWifi] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idAcessa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_achados_e_perdidos]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_standard].[tbl_achados_e_perdidos](
	[PK_idAchadosPerdidos] [int] IDENTITY(1,1) NOT NULL,
	[FK_administrador_PK_idAdm] [int] NOT NULL,
	[FK_espaco_PK_idEspaco] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idAchadosPerdidos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_standard].[tbl_administrador]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_administrador](
	[PK_idAdm] [int] IDENTITY(1,1) NOT NULL,
	[senha] [char](20) NOT NULL,
	[nome] [char](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idAdm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_classificacao]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_classificacao](
	[PK_idClasse] [int] IDENTITY(1,1) NOT NULL,
	[tipo] [char](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idClasse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_cliente]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_cliente](
	[PK_idCliente] [int] IDENTITY(1,1) NOT NULL,
	[telefone_numero] [char](20) NULL,
	[telefone_ddd] [char](4) NULL,
	[nome] [char](50) NOT NULL,
	[email] [char](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_conta]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_conta](
	[PK_login] [char](20) NOT NULL,
	[senha] [char](20) NOT NULL,
	[FK_cliente_PK_idCliente] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_empresa_manutencao]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_empresa_manutencao](
	
	[PK_cnpj] [char](18) NOT NULL,
	[ramo_atuacao] [char](30) NULL,
	[nome] [char](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_cnpj] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_espaco]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_espaco](
	[PK_idEspaco] [int] IDENTITY(1,1) NOT NULL,
	[tamanho] [int] NOT NULL,
	[nome_espaco] [char](50) NOT NULL,
	[FK_PK_localizacao_PK_localizacao] [int] NOT NULL,
	[FK_tipo_PK_idTipo] [int] NOT NULL,
	[FK_loja_PK_idLoja] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idEspaco] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_evento]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_evento](
	[PK_idEvento] [int] IDENTITY(1,1) NOT NULL,
	[data_dia] [datetime] NOT NULL,
	[descricao] [char](350) NULL,
	[tipo] [char](20) NULL,
	[nome] [char](40) NOT NULL,
	[FK_administrador_PK_idAdm] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idEvento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_fica_em_3]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_standard].[tbl_fica_em_3](
	[PK_ficaEm3] [int] IDENTITY(1,1) NOT NULL,
	[FK_espaco_PK_idEspaco] [int] NOT NULL,
	[FK_evento_PK_idEvento] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_ficaEm3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_standard].[tbl_fraldario]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_fraldario](
	[PK_idFraldario] [int] IDENTITY(1,1) NOT NULL,
	[situacao_produtos] [char](20) NULL,
	[FK_administrador_PK_idAdm] [int] NOT NULL,
	[quantidade] [int] NOT NULL,
	[tipo_produto] [char](50) NULL,
	[valor] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idFraldario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_inscricao]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_standard].[tbl_inscricao](
	[PK_idInscricao] [int] IDENTITY(1,1) NOT NULL,
	[FK_cliente_PK_idCliente] [int] NOT NULL,
	[FK_evento_PK_idEvento] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idInscricao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_standard].[tbl_localizacao]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [schem_standard].[tbl_localizacao](
	[PK_localizacao] [int] IDENTITY(1,1) NOT NULL,
	[numero_do_corredor] [tinyint] NOT NULL,
	[andar] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_localizacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [schem_standard].[tbl_objeto]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_objeto](
	[PK_idObjeto] [int] IDENTITY(1,1) NOT NULL,
	[nome] [char](25) NOT NULL,
	[descricao] [char](350) NULL,
	[FK_achados_e_perdidos_PK_idAchadosPerdidos] [int] NOT NULL,
	[data_dia] [datetime] NULL,
	[local_achado] [char](200) NULL,
	[FK_classificacao_PK_idClasse] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idObjeto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_servico_empresa_manutencao]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_servico_empresa_manutencao](
	[PK_id_sevico] [int] IDENTITY(1,1) NOT NULL,
	[nome_servico] [char](200) NOT NULL,
	[data_servico] [datetime] NOT NULL,
	[valor_servico] [money] NOT NULL,
	[FK_empresa_manutencao_cnpj] [char](18) NOT NULL,
	[FK_administrador_PK_idAdm] INT NOT NULL,
 CONSTRAINT [PK_tbl_servico_empresa_manutencao] PRIMARY KEY CLUSTERED 
(
	[PK_id_sevico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_tipo]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_tipo](
	[PK_idTipo] [int] IDENTITY(1,1) NOT NULL,
	[forma_utilizacao] [char](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [schem_standard].[tbl_wifi]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [schem_standard].[tbl_wifi](
	[PK_idWifi] [int] IDENTITY(1,1) NOT NULL,
	[login_do_administrador] [char](20) NULL,
	[senha_do_administrador] [char](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[PK_idWifi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/*=========================================================================================================== 
*MARK*
## VIEWS
=============================================================================================================*/
/****** Object:  View [schem_views].[view_contr_vencidos]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_contr_vencidos] 
AS 
SELECT  
	intr.nome, 
	con.prazo_inicio, 
	con.prazo_expiracao,  
	con.tipo_contrato  
 
FROM schem_locacao.tbl_contrato AS con 
	INNER JOIN schem_locacao.tbl_interessado AS intr ON (intr.idInteressado = con.FK_interessado_idInteressado) 
WHERE
	(
	con.staus_contrato LIKE 'nao esta em vigor'
	) 


GO

/****** Object:  View [schem_views].[view_relat_forns]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_relat_forns] AS 
	SELECT 
	frn.PK_idFornecedor AS forn_id, 
	frn.nome, 
	frn.permissao 
	FROM schem_locacao.tbl_fornecedor AS frn 
GO


/****** Object:  View [schem_views].[view_espacos_cont_fech_ano]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_espacos_cont_fech_ano] AS 
SELECT 
	esp.nome_espaco, 
	contr.tipo_contrato, 
	ntrs.nome AS nome_locatario, 
	tp.forma_utilizacao 
 
FROM schem_locacao.tbl_interessado AS ntrs 
	INNER JOIN schem_locacao.tbl_contrato AS contr ON(ntrs.idInteressado = contr.FK_interessado_idInteressado) 
	INNER JOIN schem_standard.tbl_espaco AS esp ON (esp.PK_idEspaco = contr.FK_espaco_PK_idEspaco) 
	INNER JOIN schem_standard.tbl_tipo AS tp ON (esp.FK_tipo_PK_idTipo = PK_idTipo) 
 
WHERE
	( 
	YEAR(contr.prazo_inicio) = YEAR(GETDATE()) 
	) 


GO
/****** Object:  View [schem_views].[view_event_inscritos]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_event_inscritos] 
AS 
/*SELECT
	DISTINCT schem_standard.tbl_evento.PK_idEvento AS id_evento, 
	schem_standard.tbl_evento.nome AS nome_evento,  
	schem_standard.tbl_evento.data_dia AS dia_evento, 
	schem_standard.tbl_evento.tipo AS tipo_evento, 
COUNT(schem_standard.tbl_inscricao.PK_enderecoEmail) OVER(PARTITION BY schem_standard.tbl_evento.PK_idEvento) AS inscritos 
FROM schem_standard.tbl_evento 
	INNER JOIN schem_standard.tbl_inscricao  ON schem_standard.tbl_evento.PK_idEvento = schem_standard.tbl_inscricao.FK_evento_PK_idEvento */

SELECT 
  ev.PK_idEvento AS id_evento,
  ev.nome AS nome_evento,
  ev.data_dia AS data_evento,
  ev.tipo AS tipo_evento,
  COUNT(cli.PK_idCliente) OVER(PARTITION BY ev.PK_idEvento) AS total_nscritos
  
  FROM schem_standard.tbl_evento AS ev 
  INNER JOIN schem_standard.tbl_inscricao AS insc
  ON ev.PK_idEvento = insc.FK_evento_PK_idEvento
  INNER JOIN schem_standard.tbl_cliente AS cli
  ON insc.FK_cliente_PK_idCliente = cli.PK_idCliente

GO
/****** Object:  View [schem_views].[view_fluxo_exd_cap_6meses]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [schem_views].[view_fluxo_exd_cap_6meses] AS 
SELECT 
	DISTINCT CONVERT(DATE, tiq.hora_saida, 101) AS data, 
	est.qtdeVagasCliente AS vagas_cliente_total, 
	COUNT(tiq.PK_idTiquete) OVER(PARTITION BY CONVERT(DATE, tiq.hora_saida, 101)) AS tiquetes_vendidos, 
	(est.qtdeVagasCliente - COUNT(tiq.PK_idTiquete) OVER(PARTITION BY CONVERT(DATE, tiq.hora_saida, 101))) AS max_vagas_livres, 
	SUM(tiq.valor) OVER(PARTITION BY CONVERT(DATE, tiq.hora_saida, 101)) AS total_arrecadado, 
	(CAST(COUNT(tiq.PK_idTiquete) OVER(PARTITION BY tiq.hora_saida) AS float) / CAST(est.qtdeVagasCliente AS float)) AS fluxo_diario 

FROM schem_estacionamento.tbl_estacionamento AS est 
	INNER JOIN schem_estacionamento.tbl_vaga_cliente AS cvag ON(cvag.FK_estacionamento_PK_idEstacionamento = est.PK_idEstacionamento) 
	INNER JOIN schem_estacionamento.tbl_tiquete AS tiq ON(tiq.FK_vaga_cliente_PK_idVagaCliente = cvag.PK_idVagaCliente) 
WHERE
	( 
	fluxo_diario > 1.0 
	AND 
	CONVERT(DATE, tiq.hora_saida, 101) > DATEADD(m, -6, GETDATE() - DATEPART(d, GETDATE()) + 1) 
	) 
GO
/****** Object:  View [schem_views].[view_forn_perm_neg]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_forn_perm_neg] AS 
SELECT  
	lj.nome AS nome_loja, 
	lj.ramo_atuacao AS ramo_loja, 
	forn.nome AS nome_fornecedor, 
	frnto.tipo_material AS material_fornecedor, 
	forn.permissao AS permissao_fornecedor 
 
FROM schem_locacao.tbl_loja AS lj 
	INNER JOIN schem_locacao.tbl_fornece_para AS frnto ON(frnto.FK_loja_PK_idLoja = lj.PK_idLoja) 
	INNER JOIN schem_locacao.tbl_fornecedor AS forn ON (frnto.FK_fornecedor_PK_idFornecedor = forn.PK_idFornecedor) 
	WHERE
		(
		forn.permissao = 'NEGADA'
		) 


GO
/****** Object:  View [schem_views].[view_relat_aloc_espacos_livres]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_relat_aloc_espacos_livres] AS 
SELECT 
	esp.PK_idEspaco, 
	esp.nome_espaco 
FROM schem_standard.tbl_espaco AS esp 
WHERE esp.FK_loja_PK_idLoja = NULL; 




GO
/****** Object:  View [schem_views].[view_relat_aloc_espacos_ocupados]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_relat_aloc_espacos_ocupados] AS 
SELECT 
	esp.PK_idEspaco, 
	esp.nome_espaco 
FROM schem_standard.tbl_espaco AS esp 
WHERE esp.FK_loja_PK_idLoja IS NOT NULL; 



GO
/****** Object:  View [schem_views].[view_relat_estac]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_relat_estac] AS 
SELECT 
	DISTINCT CONVERT(DATE, tiq.hora_saida, 101) AS data, 
	est.qtdeVagasCliente AS vagas_cliente_total, 
	COUNT(tiq.PK_idTiquete) OVER(PARTITION BY CONVERT(DATE, tiq.hora_saida, 101)) AS tiquetes_vendidos, 
	(est.qtdeVagasCliente - COUNT(tiq.PK_idTiquete) OVER(PARTITION BY CONVERT(DATE, tiq.hora_saida, 101))) AS max_vagas_livres, 
	SUM(tiq.valor) OVER(PARTITION BY CONVERT(DATE, tiq.hora_saida, 101)) AS total_arrecadado, 
	CAST(COUNT(tiq.PK_idTiquete) OVER(PARTITION BY tiq.hora_saida) AS float) / CAST(est.qtdeVagasCliente AS float) AS fluxo_diario 

FROM schem_estacionamento.tbl_estacionamento AS est 
INNER JOIN schem_estacionamento.tbl_vaga_cliente AS cvag ON(cvag.FK_estacionamento_PK_idEstacionamento = est.PK_idEstacionamento) 
INNER JOIN schem_estacionamento.tbl_tiquete AS tiq ON(tiq.FK_vaga_cliente_PK_idVagaCliente = cvag.PK_idVagaCliente) 
 



GO
/****** Object:  View [schem_views].[view_relat_lojistas]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [schem_views].[view_relat_lojistas] AS 
SELECT 
	ntrss.nome AS nome_lojista, 
	ljst.cnpj AS cnpj_lojista, 
	ljst.situacao AS situacao_lojista, 
	lj.nome AS nome_loja, 
	lj.ramo_atuacao AS ramo_loja, 
	cntr.prazo_inicio AS inicio_contrato, 
	cntr.prazo_expiracao AS expiracao_contrato, 
	cntr.staus_contrato, 
	cntr.tipo_contrato, 
	cntr.valor AS valor_contrato, 
	datediff(day, cntr.prazo_expiracao, cntr.prazo_inicio) AS tempo_vigencia 
 
FROM schem_locacao.tbl_loja AS lj  
	INNER JOIN schem_locacao.tbl_lojista AS ljst ON(lj.FK_lojista_PK_idLojista = ljst.PK_idLojista) 
	INNER JOIN schem_locacao.tbl_interessado AS ntrss ON(ntrss.idInteressado = ljst.FK_interessado_idInteressado) 
	INNER JOIN schem_locacao.tbl_contrato AS cntr ON(cntr.FK_interessado_idInteressado = ntrss.idInteressado) 



/*=========================================================================================================== 
*MARK*
## INDEXES
=============================================================================================================*/
GO
/****** Object:  Index [IX_tbl_vaga_lojista]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [IX_tbl_vaga_lojista] ON [schem_estacionamento].[tbl_vaga_lojista]
(
	[PK_idVagaLojista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [indx_ramo_atuacao_loja]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_ramo_atuacao_loja] ON [schem_locacao].[tbl_loja]
(
	[ramo_atuacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [indx_cpf_lojista]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_cpf_lojista] ON [schem_locacao].[tbl_lojista]
(
	[cnpj] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [indx_email_cliente]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_email_cliente] ON [schem_standard].[tbl_cliente]
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [indx_ramo_atuacao_emp_manutencao]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_ramo_atuacao_emp_manutencao] ON [schem_standard].[tbl_empresa_manutencao]
(
	[ramo_atuacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [indx_tipo_evento]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_tipo_evento] ON [schem_standard].[tbl_evento]
(
	[data_dia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [indx_tipo_produto]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_tipo_produto] ON [schem_standard].[tbl_fraldario]
(
	[tipo_produto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [indx_tipo_objeto]    Script Date: 22/11/2017 11:57:10 ******/
CREATE NONCLUSTERED INDEX [indx_tipo_objeto] ON [schem_standard].[tbl_objeto]
(
	[descricao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


/*=========================================================================================================== 
*MARK*
## CONSTRAINTS
=============================================================================================================*/
/*=========================================================================================================== 
*MARK*
### 		DEFAULT VALUES
=============================================================================================================*/
ALTER TABLE [schem_estacionamento].[tbl_situacao_vaga] ADD  DEFAULT ('LIVRE') FOR [texto_situacao]
GO
ALTER TABLE [schem_estacionamento].[tbl_tiquete] ADD  DEFAULT (getdate()) FOR [hora_entrada]
GO
ALTER TABLE [schem_locacao].[tbl_contrato] ADD  DEFAULT ('Nao esta em vigor') FOR [staus_contrato]
GO
ALTER TABLE [schem_locacao].[tbl_contrato] ADD  DEFAULT (getdate()) FOR [prazo_inicio]
GO
ALTER TABLE [schem_locacao].[tbl_contrato] ADD  DEFAULT ('Loja') FOR [tipo_contrato]
GO
ALTER TABLE [schem_locacao].[tbl_fornecedor] ADD  DEFAULT ('validar') FOR [permissao]
GO
ALTER TABLE [schem_locacao].[tbl_mensalidade] ADD  DEFAULT ('Nao pago') FOR [status_do_pagamento]
GO
ALTER TABLE [schem_standard].[tbl_cliente] ADD  DEFAULT ('019') FOR [telefone_ddd]
GO
ALTER TABLE [schem_standard].[tbl_objeto] ADD  DEFAULT (getdate()) FOR [data_dia]
GO
ALTER TABLE [schem_standard].[tbl_wifi] ADD  DEFAULT ('admin') FOR [login_do_administrador]
GO
ALTER TABLE [schem_standard].[tbl_wifi] ADD  DEFAULT ('admin') FOR [senha_do_administrador]
GO

/*=========================================================================================================== 
*MARK*
### 		FOREIGN KEYS
=============================================================================================================*/

ALTER TABLE [schem_estacionamento].[tbl_tiquete]  WITH CHECK ADD  CONSTRAINT [FK_tiquete_1] FOREIGN KEY([FK_cliente_PK_idCliente])
REFERENCES [schem_standard].[tbl_cliente] ([PK_idCliente])
GO
ALTER TABLE [schem_estacionamento].[tbl_tiquete] CHECK CONSTRAINT [FK_tiquete_1]
GO
ALTER TABLE [schem_estacionamento].[tbl_tiquete]  WITH CHECK ADD  CONSTRAINT [FK_tiquete_2] FOREIGN KEY([FK_vaga_cliente_PK_idVagaCliente])
REFERENCES [schem_estacionamento].[tbl_vaga_cliente] ([PK_idVagaCliente])
GO
ALTER TABLE [schem_estacionamento].[tbl_tiquete] CHECK CONSTRAINT [FK_tiquete_2]
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_cliente]  WITH CHECK ADD  CONSTRAINT [FK_estado_vaga_1] FOREIGN KEY([FK_estacionamento_PK_idEstadoVaga])
REFERENCES [schem_estacionamento].[tbl_situacao_vaga] ([PK_idEstadoVaga])
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_cliente] CHECK CONSTRAINT [FK_estado_vaga_1]
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_cliente]  WITH CHECK ADD  CONSTRAINT [FK_vaga_cliente_1] FOREIGN KEY([FK_estacionamento_PK_idEstacionamento])
REFERENCES [schem_estacionamento].[tbl_estacionamento] ([PK_idEstacionamento])
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_cliente] CHECK CONSTRAINT [FK_vaga_cliente_1]
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_lojista]  WITH CHECK ADD  CONSTRAINT [FK_estado_vaga_2] FOREIGN KEY([FK_estacionamento_PK_idEstadoVaga])
REFERENCES [schem_estacionamento].[tbl_situacao_vaga] ([PK_idEstadoVaga])
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_lojista] CHECK CONSTRAINT [FK_estado_vaga_2]
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_lojista]  WITH CHECK ADD  CONSTRAINT [FK_vaga_lojista_1] FOREIGN KEY([FK_estacionamento_PK_idEstacionamento])
REFERENCES [schem_estacionamento].[tbl_estacionamento] ([PK_idEstacionamento])
GO
ALTER TABLE [schem_estacionamento].[tbl_vaga_lojista] CHECK CONSTRAINT [FK_vaga_lojista_1]
GO
ALTER TABLE [schem_locacao].[tbl_contrato]  WITH CHECK ADD  CONSTRAINT [FK_contrato_1] FOREIGN KEY([FK_espaco_PK_idEspaco])
REFERENCES [schem_standard].[tbl_espaco] ([PK_idEspaco])
GO
ALTER TABLE [schem_locacao].[tbl_contrato] CHECK CONSTRAINT [FK_contrato_1]
GO
ALTER TABLE [schem_locacao].[tbl_contrato]  WITH CHECK ADD  CONSTRAINT [FK_contrato_2] FOREIGN KEY([FK_administrador_PK_idAdm])
REFERENCES [schem_standard].[tbl_administrador] ([PK_idAdm])
GO
ALTER TABLE [schem_locacao].[tbl_contrato] CHECK CONSTRAINT [FK_contrato_2]
GO
ALTER TABLE [schem_locacao].[tbl_contrato]  WITH CHECK ADD  CONSTRAINT [FK_contrato_3] FOREIGN KEY([FK_interessado_idInteressado])
REFERENCES [schem_locacao].[tbl_interessado] ([idInteressado])
GO
ALTER TABLE [schem_locacao].[tbl_contrato] CHECK CONSTRAINT [FK_contrato_3]
GO
ALTER TABLE [schem_locacao].[tbl_fornece_para]  WITH CHECK ADD  CONSTRAINT [FK_fornece_para_0] FOREIGN KEY([FK_fornecedor_PK_idFornecedor])
REFERENCES [schem_locacao].[tbl_fornecedor] ([PK_idFornecedor])
GO
ALTER TABLE [schem_locacao].[tbl_fornece_para] CHECK CONSTRAINT [FK_fornece_para_0]
GO
ALTER TABLE [schem_locacao].[tbl_fornece_para]  WITH CHECK ADD  CONSTRAINT [FK_fornece_para_1] FOREIGN KEY([FK_loja_PK_idLoja])
REFERENCES [schem_locacao].[tbl_loja] ([PK_idLoja])
GO
ALTER TABLE [schem_locacao].[tbl_fornece_para] CHECK CONSTRAINT [FK_fornece_para_1]
GO
ALTER TABLE [schem_locacao].[tbl_loja]  WITH CHECK ADD  CONSTRAINT [FK_loja_1] FOREIGN KEY([FK_lojista_PK_idLojista])
REFERENCES [schem_locacao].[tbl_lojista] ([PK_idLojista])
GO
ALTER TABLE [schem_locacao].[tbl_loja] CHECK CONSTRAINT [FK_loja_1]
GO
ALTER TABLE [schem_locacao].[tbl_lojista]  WITH CHECK ADD  CONSTRAINT [FK_lojista_1] FOREIGN KEY([FK_vaga_lojista_PK_idVagaLojista])
REFERENCES [schem_estacionamento].[tbl_vaga_lojista] ([PK_idVagaLojista])
GO
ALTER TABLE [schem_locacao].[tbl_lojista] CHECK CONSTRAINT [FK_lojista_1]
GO
ALTER TABLE [schem_locacao].[tbl_lojista]  WITH CHECK ADD  CONSTRAINT [FK_lojista_2] FOREIGN KEY([FK_interessado_idInteressado])
REFERENCES [schem_locacao].[tbl_interessado] ([idInteressado])
GO
ALTER TABLE [schem_locacao].[tbl_lojista] CHECK CONSTRAINT [FK_lojista_2]
GO
ALTER TABLE [schem_locacao].[tbl_mensalidade]  WITH CHECK ADD  CONSTRAINT [FK_mensalidade_1] FOREIGN KEY([FK_contrato_interessado_PK_idContrato])
REFERENCES [schem_locacao].[tbl_contrato] ([PK_idContrato])
GO
ALTER TABLE [schem_locacao].[tbl_mensalidade] CHECK CONSTRAINT [FK_mensalidade_1]
GO
ALTER TABLE [schem_locacao].[tbl_procura]  WITH CHECK ADD  CONSTRAINT [FK_procura_0] FOREIGN KEY([FK_administrador_PK_idAdm])
REFERENCES [schem_standard].[tbl_administrador] ([PK_idAdm])
GO
ALTER TABLE [schem_locacao].[tbl_procura] CHECK CONSTRAINT [FK_procura_0]
GO
ALTER TABLE [schem_locacao].[tbl_procura]  WITH CHECK ADD  CONSTRAINT [FK_procura_1] FOREIGN KEY([FK_interessado_idInteressado])
REFERENCES [schem_locacao].[tbl_interessado] ([idInteressado])
GO
ALTER TABLE [schem_locacao].[tbl_procura] CHECK CONSTRAINT [FK_procura_1]
GO
ALTER TABLE [schem_standard].[tbl_acessa]  WITH CHECK ADD  CONSTRAINT [FK_acessa_0] FOREIGN KEY([FK_conta_PK_login])
REFERENCES [schem_standard].[tbl_conta] ([PK_login])
GO
ALTER TABLE [schem_standard].[tbl_acessa] CHECK CONSTRAINT [FK_acessa_0]
GO
ALTER TABLE [schem_standard].[tbl_acessa]  WITH CHECK ADD  CONSTRAINT [FK_acessa_1] FOREIGN KEY([FK_wifi_PK_idWifi])
REFERENCES [schem_standard].[tbl_wifi] ([PK_idWifi])
GO
ALTER TABLE [schem_standard].[tbl_acessa] CHECK CONSTRAINT [FK_acessa_1]
GO
ALTER TABLE [schem_standard].[tbl_achados_e_perdidos]  WITH CHECK ADD  CONSTRAINT [FK_achados_e_perdidos_1] FOREIGN KEY([FK_administrador_PK_idAdm])
REFERENCES [schem_standard].[tbl_administrador] ([PK_idAdm])
GO
ALTER TABLE [schem_standard].[tbl_achados_e_perdidos] CHECK CONSTRAINT [FK_achados_e_perdidos_1]
GO
ALTER TABLE [schem_standard].[tbl_achados_e_perdidos]  WITH CHECK ADD  CONSTRAINT [FK_achados_e_perdidos_2] FOREIGN KEY([FK_espaco_PK_idEspaco])
REFERENCES [schem_standard].[tbl_espaco] ([PK_idEspaco])
GO
ALTER TABLE [schem_standard].[tbl_achados_e_perdidos] CHECK CONSTRAINT [FK_achados_e_perdidos_2]
GO
ALTER TABLE [schem_standard].[tbl_conta]  WITH CHECK ADD  CONSTRAINT [FK_conta_1] FOREIGN KEY([FK_cliente_PK_idCliente])
REFERENCES [schem_standard].[tbl_cliente] ([PK_idCliente])
GO
ALTER TABLE [schem_standard].[tbl_conta] CHECK CONSTRAINT [FK_conta_1]
GO
ALTER TABLE [schem_standard].[tbl_servico_empresa_manutencao]  WITH CHECK ADD  CONSTRAINT [FK_adm_contrata_1] FOREIGN KEY([FK_administrador_PK_idAdm])
REFERENCES [schem_standard].[tbl_administrador] ([PK_idAdm])
GO
ALTER TABLE [schem_standard].[tbl_servico_empresa_manutencao] CHECK CONSTRAINT [FK_adm_contrata_1]
GO
ALTER TABLE [schem_standard].[tbl_espaco]  WITH CHECK ADD  CONSTRAINT [FK_espaco_1] FOREIGN KEY([FK_PK_localizacao_PK_localizacao])
REFERENCES [schem_standard].[tbl_localizacao] ([PK_localizacao])
GO
ALTER TABLE [schem_standard].[tbl_espaco] CHECK CONSTRAINT [FK_espaco_1]
GO
ALTER TABLE [schem_standard].[tbl_espaco]  WITH CHECK ADD  CONSTRAINT [FK_espaco_2] FOREIGN KEY([FK_tipo_PK_idTipo])
REFERENCES [schem_standard].[tbl_tipo] ([PK_idTipo])
GO
ALTER TABLE [schem_standard].[tbl_espaco] CHECK CONSTRAINT [FK_espaco_2]
GO
ALTER TABLE [schem_standard].[tbl_espaco]  WITH CHECK ADD  CONSTRAINT [FK_espaco_3] FOREIGN KEY([FK_loja_PK_idLoja])
REFERENCES [schem_locacao].[tbl_loja] ([PK_idLoja])
GO
ALTER TABLE [schem_standard].[tbl_espaco] CHECK CONSTRAINT [FK_espaco_3]
GO
ALTER TABLE [schem_standard].[tbl_evento]  WITH CHECK ADD  CONSTRAINT [FK_evento_1] FOREIGN KEY([FK_administrador_PK_idAdm])
REFERENCES [schem_standard].[tbl_administrador] ([PK_idAdm])
GO
ALTER TABLE [schem_standard].[tbl_evento] CHECK CONSTRAINT [FK_evento_1]
GO
ALTER TABLE [schem_standard].[tbl_fica_em_3]  WITH CHECK ADD  CONSTRAINT [FK_fica_em_3_0] FOREIGN KEY([FK_espaco_PK_idEspaco])
REFERENCES [schem_standard].[tbl_espaco] ([PK_idEspaco])
GO
ALTER TABLE [schem_standard].[tbl_fica_em_3] CHECK CONSTRAINT [FK_fica_em_3_0]
GO
ALTER TABLE [schem_standard].[tbl_fica_em_3]  WITH CHECK ADD  CONSTRAINT [FK_fica_em_3_1] FOREIGN KEY([FK_evento_PK_idEvento])
REFERENCES [schem_standard].[tbl_evento] ([PK_idEvento])
GO
ALTER TABLE [schem_standard].[tbl_fica_em_3] CHECK CONSTRAINT [FK_fica_em_3_1]
GO
ALTER TABLE [schem_standard].[tbl_fraldario]  WITH CHECK ADD  CONSTRAINT [FK_fraldario_1] FOREIGN KEY([FK_administrador_PK_idAdm])
REFERENCES [schem_standard].[tbl_administrador] ([PK_idAdm])
GO
ALTER TABLE [schem_standard].[tbl_fraldario] CHECK CONSTRAINT [FK_fraldario_1]
GO
ALTER TABLE [schem_standard].[tbl_inscricao]  WITH CHECK ADD  CONSTRAINT [FK_inscricao_1] FOREIGN KEY([FK_cliente_PK_idCliente])
REFERENCES [schem_standard].[tbl_cliente] ([PK_idCliente])
GO
ALTER TABLE [schem_standard].[tbl_inscricao] CHECK CONSTRAINT [FK_inscricao_1]
GO
ALTER TABLE [schem_standard].[tbl_inscricao]  WITH CHECK ADD  CONSTRAINT [FK_inscricao_2] FOREIGN KEY([FK_evento_PK_idEvento])
REFERENCES [schem_standard].[tbl_evento] ([PK_idEvento])
GO
ALTER TABLE [schem_standard].[tbl_inscricao] CHECK CONSTRAINT [FK_inscricao_2]
GO
ALTER TABLE [schem_standard].[tbl_objeto]  WITH CHECK ADD  CONSTRAINT [FK_objeto_1] FOREIGN KEY([FK_achados_e_perdidos_PK_idAchadosPerdidos])
REFERENCES [schem_standard].[tbl_achados_e_perdidos] ([PK_idAchadosPerdidos])
GO
ALTER TABLE [schem_standard].[tbl_objeto] CHECK CONSTRAINT [FK_objeto_1]
GO
ALTER TABLE [schem_standard].[tbl_objeto]  WITH CHECK ADD  CONSTRAINT [FK_objeto_2] FOREIGN KEY([FK_classificacao_PK_idClasse])
REFERENCES [schem_standard].[tbl_classificacao] ([PK_idClasse])
GO
ALTER TABLE [schem_standard].[tbl_objeto] CHECK CONSTRAINT [FK_objeto_2]
GO
ALTER TABLE [schem_standard].[tbl_servico_empresa_manutencao]  WITH CHECK ADD  CONSTRAINT [FK_tbl_servico_empresa_manutencao_tbl_empresa_manutencao] FOREIGN KEY([FK_empresa_manutencao_cnpj])
REFERENCES [schem_standard].[tbl_empresa_manutencao] ([PK_cnpj])
GO
ALTER TABLE [schem_standard].[tbl_servico_empresa_manutencao] CHECK CONSTRAINT [FK_tbl_servico_empresa_manutencao_tbl_empresa_manutencao]
GO

/*=========================================================================================================== 
*MARK*
### 		CHECK CONSTRAINTS
=============================================================================================================*/

ALTER TABLE [schem_locacao].[tbl_contrato]  WITH CHECK ADD  CONSTRAINT [cons_chk_sts] CHECK  (([staus_contrato]='Em vigor' OR [staus_contrato]='Nao esta em vigor'))
GO
ALTER TABLE [schem_locacao].[tbl_contrato] CHECK CONSTRAINT [cons_chk_sts]
GO
ALTER TABLE [schem_locacao].[tbl_contrato]  WITH CHECK ADD  CONSTRAINT [cons_chk_tipo_contrato] CHECK  (([tipo_contrato]='Loja' OR [tipo_contrato]='Lazer'))
GO
ALTER TABLE [schem_locacao].[tbl_contrato] CHECK CONSTRAINT [cons_chk_tipo_contrato]
GO
ALTER TABLE [schem_locacao].[tbl_fornecedor]  WITH CHECK ADD  CONSTRAINT [cons_chk_permissao_forn] CHECK  (([permissao]='validar' OR [permissao]='concedida' OR [permissao]='negada'))
GO
ALTER TABLE [schem_locacao].[tbl_fornecedor] CHECK CONSTRAINT [cons_chk_permissao_forn]
GO
ALTER TABLE [schem_locacao].[tbl_mensalidade]  WITH CHECK ADD  CONSTRAINT [CHK_status_pgto] CHECK  (([status_do_pagamento]='Pago' OR [status_do_pagamento]='Nao pago'))
GO
ALTER TABLE [schem_locacao].[tbl_mensalidade] CHECK CONSTRAINT [CHK_status_pgto]
GO
ALTER TABLE [schem_standard].[tbl_fraldario]  WITH CHECK ADD  CONSTRAINT [CHK_sit_prod] CHECK  (([situacao_produtos]='Ha produtos' OR [situacao_produtos]='Nao ha'))
GO
ALTER TABLE [schem_standard].[tbl_fraldario] CHECK CONSTRAINT [CHK_sit_prod]
GO

/*=========================================================================================================== 
*MARK*
## 	STORED PROCEDURES
=============================================================================================================*/
/****** Object:  StoredProcedure [schem_prog_usp_usf].[usp_atualiza_vagas]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [schem_prog_usp_usf].[usp_atualiza_vagas]
	@IdEstacionamento INT
AS
BEGIN
	
	DECLARE @countVagasCliente INT SELECT COUNT(schem_estacionamento.tbl_vaga_cliente.PK_idVagaCliente) FROM schem_estacionamento.tbl_vaga_cliente
  DECLARE @countVagasLojista INT SELECT COUNT(schem_estacionamento.tbl_vaga_lojista.PK_idVagaLojista) FROM schem_estacionamento.tbl_vaga_lojista
  
  DECLARE @totalVagas INT = @countVagasCliente + @countVagasLojista


  UPDATE schem_estacionamento.tbl_estacionamento 
    SET
      total_vagas = @totalVagas,
      qtdeVagasCliente = @countVagasLojista,
      qtdVagasLojista = @countVagasCliente
    WHERE PK_idEstacionamento = @IdEstacionamento

END



GO
/****** Object:  StoredProcedure [schem_prog_usp_usf].[usp_cadastra_em_evento]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [schem_prog_usp_usf].[usp_cadastra_em_evento] 
  @idEvento INT,
  @emailcliente CHAR(100),
  @insNomeCli CHAR(50) = NULL
  

AS
  BEGIN
    DECLARE @nomeCli CHAR(50)
    DECLARE @idCli INT
    DECLARE @results INT
    
     SELECT @results = COUNT(PK_idCliente) FROM schem_standard.tbl_cliente WHERE email LIKE @emailcliente

    IF(@results > 0) BEGIN
      RAISERROR('O email digitado está duplicado.', 14, 1)
    END
    
    SELECT @nomeCli = nome, @idCli = PK_idCliente FROM schem_standard.tbl_cliente WHERE email LIKE @emailcliente

    IF(@results = 0) BEGIN
      INSERT INTO schem_standard.tbl_cliente (telefone_numero, telefone_ddd, nome, email) VALUES (NULL,NULL, @insNomeCli, @emailcliente);
      SET @idCli = @@IDENTITY
    END 
  INSERT INTO schem_standard.tbl_inscricao (FK_cliente_PK_idCliente, FK_evento_PK_idEvento) VALUES (@idCli, @idEvento);
  END


GO
/****** Object:  StoredProcedure [schem_prog_usp_usf].[usp_cobra_tiquete]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [schem_prog_usp_usf].[usp_cobra_tiquete]
  @IdTiquete INT
  

AS
  BEGIN
  BEGIN TRY
    BEGIN TRANSACTION

      DECLARE @idEstacionamento INT
      DECLARE @idVaga INT

       SELECT @idEstacionamento = est.PK_idEstacionamento, @idVaga = vag.PK_idVagaCliente 
        FROM schem_estacionamento.tbl_tiquete AS tiq 
        INNER JOIN schem_estacionamento.tbl_vaga_cliente AS vag 
          ON tiq.FK_vaga_cliente_PK_idVagaCliente = vag.PK_idVagaCliente
        INNER JOIN schem_estacionamento.tbl_estacionamento AS est
          ON est.PK_idEstacionamento = vag.FK_estacionamento_PK_idEstacionamento

      DECLARE @dataSaida DATETIME = GETDATE()
      DECLARE @dataEntrada DATETIME

      DECLARE @precoHora INT SELECT preco_por_hora_para_cliente FROM schem_estacionamento.tbl_estacionamento WHERE PK_idEstacionamento = @IdEstacionamento
      DECLARE @valor MONEY = CAST(DATEDIFF(hour, @dataEntrada, @dataSaida) * @precoHora AS MONEY)

      UPDATE schem_estacionamento.tbl_tiquete SET valor = @valor, hora_saida = @dataSaida WHERE PK_idTiquete = @IdTiquete
      
      DECLARE @idEstadoVaga INT SELECT TOP 1  PK_idEstadoVaga FROM bd_shopping.schem_estacionamento.tbl_situacao_vaga WHERE texto_situacao LIKE 'LIBERANDO'
      UPDATE schem_estacionamento.tbl_vaga_cliente SET FK_estacionamento_PK_idEstadoVaga = @idEstadoVaga

    COMMIT TRANSACTION
  END TRY  
  BEGIN CATCH  
    ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS Retorno
  END CATCH 


  END


GO
/****** Object:  StoredProcedure [schem_prog_usp_usf].[usp_entrega_tiquete]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [schem_prog_usp_usf].[usp_entrega_tiquete]
  @IdTiquete INT
  

AS
  BEGIN
  BEGIN TRY
    BEGIN TRANSACTION

      DECLARE @idEstacionamento INT
      DECLARE @idVaga INT
      DECLARE @horaPagamento DATETIME


       SELECT @horaPagamento = hora_saida FROM schem_estacionamento.tbl_tiquete WHERE PK_idTiquete = @IdTiquete
       DECLARE @horasPassadas INT = DATEDIFF(hour, @horaPagamento, GETDATE())

       IF(@horasPassadas >= 1)BEGIN
        RAISERROR('O tempo máximo de permanência após o pagamento foi excedido.', 14, 1)
       END

       SELECT @idVaga = vag.PK_idVagaCliente 
        FROM schem_estacionamento.tbl_tiquete AS tiq 
        INNER JOIN schem_estacionamento.tbl_vaga_cliente AS vag 
          ON tiq.FK_vaga_cliente_PK_idVagaCliente = vag.PK_idVagaCliente
        INNER JOIN schem_estacionamento.tbl_estacionamento AS est
          ON est.PK_idEstacionamento = vag.FK_estacionamento_PK_idEstacionamento
      
      DECLARE @idEstadoVaga INT SELECT TOP 1  PK_idEstadoVaga FROM bd_shopping.schem_estacionamento.tbl_situacao_vaga WHERE texto_situacao LIKE 'DISPONÍVEL'
      UPDATE schem_estacionamento.tbl_vaga_cliente SET FK_estacionamento_PK_idEstadoVaga = @idEstadoVaga WHERE PK_idVagaCliente = @idVaga

    COMMIT TRANSACTION
  END TRY  
  BEGIN CATCH  
    ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS Retorno
  END CATCH 


  END


GO
/****** Object:  StoredProcedure [schem_prog_usp_usf].[usp_gera_lista_evento]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [schem_prog_usp_usf].[usp_gera_lista_evento](@idEvento INT)
  AS
  BEGIN
     SELECT cli.nome, cli.email FROM schem_standard.tbl_evento AS ev
        INNER JOIN schem_standard.tbl_inscricao AS inscr
        ON inscr.FK_evento_PK_idEvento = ev.PK_idEvento
        INNER JOIN schem_standard.tbl_cliente AS cli
        ON cli.PK_idCliente = inscr.FK_cliente_PK_idCliente
        WHERE ev.PK_idEvento = @idEvento
  END

GO
/****** Object:  StoredProcedure [schem_prog_usp_usf].[usp_gera_tiquete]    Script Date: 22/11/2017 11:57:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [schem_prog_usp_usf].[usp_gera_tiquete]
@IdCliente INT = NULL

AS
BEGIN
  
  /*DECLARE @idVaga AS INT SELECT TOP 1 PK_idVagaCliente 
    FROM bd_shopping.schem_estacionamento.tbl_vaga_cliente AS vaga
    INNER JOIN bd_shopping.schem_estacionamento.tbl_esta_em_2 AS esta_em
      ON vaga.PK_idVagaCliente = esta_em.FK_vaga_cliente_PK_idVagaCliente
      INNER JOIN schem_estacionamento.tbl_situacao_vaga AS situac_vaga
        ON situac_vaga.PK_idEstadoVaga = esta_em.FK_Situacao_vaga_PK_idEstadoVaga
    WHERE situac_vaga.texto_situacao LIKE 'DISPONÍVEL'*/


  DECLARE @idVaga INT SELECT TOP 1 PK_idVagaCliente 
    FROM schem_estacionamento.tbl_vaga_cliente AS vaga
    INNER JOIN schem_estacionamento.tbl_situacao_vaga AS sit
      ON sit.PK_idEstadoVaga = vaga.FK_estacionamento_PK_idEstadoVaga
     
    WHERE sit.texto_situacao LIKE 'DISPONÍVEL'
  
  IF(@idVaga = NULL) BEGIN
    RAISERROR('Não há vagas disponíveis', 14, 1)
  END
  
  INSERT INTO schem_estacionamento.tbl_tiquete 
    (
    valor, 
    hora_saida, 
    hora_entrada, 
    FK_cliente_PK_idCliente, 
    FK_vaga_cliente_PK_idVagaCliente
    )
  VALUES (NULL, NULL, GETDATE(), @IdCliente, @idVaga);
END
GO

USE [bd_shopping]
GO



/*=========================================================================================================== 
*MARK*
## 	TRIGGERS
=============================================================================================================*/
/****** Object:  Trigger [schem_estacionamento].[trg_upd_qtdVagas_loj]    Script Date: 22/11/2017 12:10:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [schem_estacionamento].[trg_upd_qtdVagas_loj] ON [schem_estacionamento].[tbl_vaga_lojista]
AFTER INSERT, DELETE
AS
BEGIN

  DECLARE @estacId INT

	
  IF EXISTS(SELECT * FROM DELETED) BEGIN
    SELECT @estacId = FK_estacionamento_PK_idEstacionamento FROM DELETED
  END


  IF EXISTS(SELECT * FROM INSERTED) BEGIN
    SELECT @estacId = FK_estacionamento_PK_idEstacionamento FROM INSERTED
  END

	EXEC schem_prog_usp_usf.usp_atualiza_vagas @IdEstacionamento = @estacId

END
GO


/****** Object:  Trigger [schem_estacionamento].[trg_upd_qtdVagas_cli]    Script Date: 22/11/2017 12:09:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [schem_estacionamento].[trg_upd_qtdVagas_cli] ON [schem_estacionamento].[tbl_vaga_cliente]
AFTER INSERT, DELETE
AS
BEGIN

  DECLARE @estacId INT

	
  IF EXISTS(SELECT * FROM DELETED) BEGIN
    SELECT @estacId = FK_estacionamento_PK_idEstacionamento FROM DELETED
  END


  IF EXISTS(SELECT * FROM INSERTED) BEGIN
    SELECT @estacId = FK_estacionamento_PK_idEstacionamento FROM INSERTED
  END

	EXEC schem_prog_usp_usf.usp_atualiza_vagas @IdEstacionamento = @estacId

END
GO

/****** Object:  Trigger [schem_standard].[trg_validar_cli]    Script Date: 22/11/2017 12:11:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [schem_standard].[trg_validar_cli] ON [schem_standard].[tbl_cliente]
  INSTEAD OF INSERT, UPDATE
  AS
  BEGIN

    DECLARE @email CHAR(100),
     @telnum CHAR(20),
     @ddd CHAR(4),
     @nome CHAR(50)
    
    SELECT @email = email, @telnum = telefone_numero, @ddd = telefone_ddd, @nome = nome FROM INSERTED

    IF schem_prog_usp_usf.usf_valida_email(@email) = 1 BEGIN
      INSERT INTO schem_standard.tbl_cliente (telefone_numero, telefone_ddd, nome, email)VALUES (@telnum, @ddd, @nome, @email);
      SELECT 'sucesso.' AS retorno
    END
    SELECT 'E-mail inválido.' AS retorno
  END
GO


/****** Object:  Trigger [schem_locacao].[trg_validar_lojista]    Script Date: 22/11/2017 12:21:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [schem_locacao].[trg_validar_lojista] ON [schem_locacao].[tbl_lojista]
  INSTEAD OF INSERT, UPDATE
  AS
  BEGIN

    DECLARE @situac CHAR(20),
     @cnpj CHAR(18),
     @vaga INT,
     @interessado INT
    
    SELECT 
	@situac = situacao, 
	@cnpj = cnpj, 
	@interessado = FK_interessado_idInteressado, 
	@vaga = FK_vaga_lojista_PK_idVagaLojista 
	FROM INSERTED

    IF schem_prog_usp_usf.usf_valida_cnpj(@cnpj) = 1 BEGIN
      INSERT INTO schem_locacao.tbl_lojista (situacao, cnpj, FK_interessado_idInteressado, FK_vaga_lojista_PK_idVagaLojista) 
	  VALUES (@situac, @cnpj, @interessado, @vaga)
      SELECT 'sucesso.' AS retorno
    END
    SELECT 'CNPJ inválido.' AS retorno
  END
GO
/*=========================================== END =================================================*/



USE [master]
GO
ALTER DATABASE [bd_shopping] SET  READ_WRITE 
GO
