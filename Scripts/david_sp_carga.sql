
USE [CaseHorizonte];
GO

CREATE OR ALTER PROCEDURE [analitico].[usp_CarregarVendas]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Linhas INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- RN-09: Limpa a carga anterior para evitar duplicações
        DELETE FROM analitico.Vendas;

        -- Insere os dados na tabela analítica
        INSERT INTO analitico.Vendas
        (
            VendaId,
            DataVenda,
            AnoVenda,
            MesVenda,
            ClienteId,
            NomeCliente,
            TipoCliente,
            Cidade,
            UF,
            VendedorId,
            NomeVendedor,
            Regiao,
            ProdutoId,
            NomeProduto,
            Categoria,
            Quantidade,
            ValorUnitario,
            ValorBruto,
            ValorDesconto,
            ValorLiquido,
            DataCarga
        )
        SELECT
            -- Dados da venda
            v.VendaId,
            v.DataVenda,
            CAST(YEAR(v.DataVenda) AS SMALLINT),
            CAST(MONTH(v.DataVenda) AS TINYINT),

            -- Dados do cliente
            c.ClienteId,
            c.NomeCliente,
            c.TipoCliente,
            COALESCE(
                NULLIF(LTRIM(RTRIM(c.Cidade)), ''),
                N'Não informado'
            ),
            COALESCE(
                NULLIF(LTRIM(RTRIM(c.UF)), ''),
                N'Não informado'
            ),

            -- Dados do vendedor
            vd.VendedorId,
            vd.NomeVendedor,
            vd.Regiao,

            -- Dados do produto
            p.ProdutoId,
            p.NomeProduto,
            p.Categoria,

            -- Quantidade e preço praticado
            v.Quantidade,
            v.ValorUnitario,

            -- RN-07: Valor bruto
            CAST(
                v.Quantidade * v.ValorUnitario
                AS DECIMAL(18,2)
            ),

            -- RN-07: Valor do desconto
            CAST(
                v.Quantidade * v.ValorUnitario
                * v.PercDesconto / 100.0
                AS DECIMAL(18,2)
            ),

            -- RN-07: Valor líquido
            -- Subtrai os valores já arredondados
            CAST(
                v.Quantidade * v.ValorUnitario
                AS DECIMAL(18,2)
            )
            -
            CAST(
                v.Quantidade * v.ValorUnitario
                * v.PercDesconto / 100.0
                AS DECIMAL(18,2)
            ),

            -- RN-08: Data e hora da carga
            SYSDATETIME()

        FROM base.Vendas AS v

        INNER JOIN base.Clientes AS c
            ON v.ClienteId = c.ClienteId

        INNER JOIN base.Vendedores AS vd
            ON v.VendedorId = vd.VendedorId

        INNER JOIN base.Produtos AS p
            ON v.ProdutoId = p.ProdutoId

        -- RN-02: Somente vendas concluídas
        WHERE v.StatusVenda = N'Concluída';

        SET @Linhas = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- Retorna quantidade de registros carregados
        SELECT @Linhas AS LinhasCarregadas;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
END;
GO
