USE CaseHorizonte;
GO

IF SCHEMA_ID(N'analitico') IS NULL
    EXEC(N'CREATE SCHEMA analitico');
GO

USE [CaseHorizonte]
GO

/****** Objeto:  Table [analitico].[Vendas]    Data do Script: 05/11/2026 20:17:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [analitico].[Vendas](
	[VendaId] [int] NOT NULL,
	[DataVenda] [datetime2](7) NOT NULL,
	[AnoVenda] [smallint] NOT NULL,
	[MesVenda] [tinyint] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[NomeCliente] [nvarchar](150) NOT NULL,
	[TipoCliente] [char](2) NOT NULL,
	[Cidade] [nvarchar](60) NOT NULL,
	[UF] [nvarchar](20) NOT NULL,
	[VendedorId] [int] NOT NULL,
	[NomeVendedor] [nvarchar](100) NOT NULL,
	[Regiao] [nvarchar](50) NOT NULL,
	[ProdutoId] [int] NOT NULL,
	[NomeProduto] [nvarchar](100) NOT NULL,
	[Categoria] [nvarchar](50) NOT NULL,
	[Quantidade] [int] NOT NULL,
	[ValorUnitario] [decimal](10, 2) NOT NULL,
	[ValorBruto] [decimal](18, 2) NOT NULL,
	[ValorDesconto] [decimal](18, 2) NOT NULL,
	[ValorLiquido] [decimal](18, 2) NOT NULL,
	[DataCarga] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VendaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


