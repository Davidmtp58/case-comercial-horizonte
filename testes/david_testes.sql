
USE [CaseHorizonte];
GO

/*
=========================================================
 CASE COMERCIAL HORIZONTE
 ARQUIVO: david_testes.sql

 OBJETIVO:
 Validar a Stored Procedure analitico.usp_CarregarVendas

 TESTES:
 01 - Duplicações
 02 - Consistência financeira
 03 - Cancelamento de vendas (RN-10)
 04 - ROLLBACK em falha simulada
=========================================================
*/

-- =====================================================
-- TESTE 01: REPROCESSAMENTO SEM DUPLICAÇÕES
-- =====================================================

EXEC analitico.usp_CarregarVendas;
GO

SELECT
    COUNT(*) AS TotalVendas,
    COUNT(DISTINCT VendaId) AS VendasUnicas,
    COUNT(*) - COUNT(DISTINCT VendaId) AS Duplicacoes
FROM analitico.Vendas;
GO


-- =====================================================
-- TESTE 02: CONSISTÊNCIA FINANCEIRA
-- =====================================================

SELECT
    COUNT(*) AS TotalVendas,
    SUM(ValorBruto) AS FaturamentoBruto,
    SUM(ValorDesconto) AS TotalDescontos,
    SUM(ValorLiquido) AS FaturamentoLiquido,

    SUM(
        CASE
            WHEN ValorLiquido <> ValorBruto - ValorDesconto
            THEN 1
            ELSE 0
        END
    ) AS DivergenciasFinanceiras

FROM analitico.Vendas;
GO


-- =====================================================
-- TESTE 03: CANCELAMENTO DE VENDA (RN-10)
-- =====================================================

-- Simula o cancelamento de uma venda concluída.
-- Executa a carga e verifica se a venda desapareceu.
-- Desfaz o cancelamento ao final da transação.

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @VendaIdTeste INT;

    SELECT TOP 1
        @VendaIdTeste = VendaId
    FROM base.Vendas
    WHERE StatusVenda = N'Concluída'
    ORDER BY VendaId;

    IF @VendaIdTeste IS NULL
        THROW 50002, 'Nenhuma venda concluída disponível.', 1;

    UPDATE base.Vendas
    SET
        StatusVenda = N'Cancelada',
        DataAtualizacao = SYSDATETIME()
    WHERE VendaId = @VendaIdTeste;

    EXEC analitico.usp_CarregarVendas;

    SELECT
        @VendaIdTeste AS VendaTestada,
        COUNT(*) AS RegistrosAposCancelamento
    FROM analitico.Vendas
    WHERE VendaId = @VendaIdTeste;

    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO

-- Restaurar tabela analítica após o teste
EXEC analitico.usp_CarregarVendas;
GO

SELECT
    COUNT(*) AS TotalFinal
FROM analitico.Vendas;
GO


-- =====================================================
-- TESTE 04: ROLLBACK EM FALHA SIMULADA
-- =====================================================

-- Testa o mecanismo de transação e ROLLBACK.
-- Não provoca falha dentro da Stored Procedure.
-- A exclusão é desfeita quando o erro é simulado.

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM analitico.Vendas;

    THROW 50001,
        'Erro simulado para testar ROLLBACK.', 1;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_MESSAGE() AS ErroSimulado,
        @@TRANCOUNT AS TransacoesAbertas;

END CATCH;
GO

SELECT
    COUNT(*) AS RegistrosAposFalha
FROM analitico.Vendas;
GO
