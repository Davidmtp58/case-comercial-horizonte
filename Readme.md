# Case Comercial Horizonte — SQL Server

Projeto prático de SQL Server desenvolvido para simular um processo de Engenharia de Dados em uma distribuidora fictícia.

O objetivo é transformar dados operacionais de vendas em uma estrutura analítica confiável, aplicando regras de negócio, integração de tabelas, automação de carga e testes de consistência.

## Equipe

- **Mentoria:** Erick
- **Participantes:** David Mangueira, Amanda e Valber

## Tecnologias utilizadas

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Stored Procedures
- Transações e tratamento de exceções

## Estrutura de dados

O banco contém quatro tabelas operacionais no esquema `base`:

- `base.Clientes`
- `base.Produtos`
- `base.Vendedores`
- `base.Vendas`

Essas tabelas alimentam `analitico.Vendas`, que reúne as informações necessárias para análises comerciais.

Cada registro da tabela analítica representa uma venda concluída.

## Processo de carga

A Stored Procedure `analitico.usp_CarregarVendas` executa o processamento utilizando:

1. Limpeza dos registros da carga anterior.
2. Integração das tabelas operacionais por meio de `INNER JOIN`.
3. Filtragem das vendas com status `Concluída`.
4. Cálculo dos valores bruto, desconto e líquido.
5. Registro da data e hora do processamento.
6. Controle transacional com `COMMIT`, `ROLLBACK` e `TRY...CATCH`.

A estratégia de recarga completa evita duplicações quando o procedimento é executado novamente.

## Como executar o projeto

**Pré-requisito:** SQL Server e um cliente de execução de scripts T-SQL, como o SSMS.

Em uma instância onde o banco `CaseHorizonte` ainda não exista:

1. Execute `Scripts/02_tabelas_base.sql` para criar o banco, as tabelas operacionais e inserir os dados.
2. Execute `Scripts/01_criar_tabela_analitica.sql` para criar a estrutura analítica.
3. Execute `Scripts/david_sp_carga.sql` para criar a Stored Procedure.
4. Execute a carga:

```sql
USE CaseHorizonte;
GO

EXEC analitico.usp_CarregarVendas;
GO
```

Para conferir o resultado:

```sql
SELECT
    COUNT(*) AS TotalVendas,
    COUNT(DISTINCT VendaId) AS VendasUnicas,
    COUNT(*) - COUNT(DISTINCT VendaId) AS Duplicacoes,
    SUM(ValorLiquido) AS FaturamentoLiquido
FROM analitico.Vendas;
```

**Atenção:** o script de criação das tabelas base foi preparado para uma instalação inicial. Não deve ser reexecutado sobre as mesmas tabelas já existentes sem avaliar o impacto.

## Resultados da homologação

A estrutura foi testada em um banco separado (`CaseHorizonte_HML2`), com reconstrução das tabelas e execução da carga.

| Indicador | Resultado |
|---|---:|
| Clientes na origem | 1.000 |
| Produtos | 30 |
| Vendedores | 20 |
| Vendas na origem | 1.000 |
| Vendas processadas | 901 |
| Vendas únicas | 901 |
| Duplicações | 0 |
| Faturamento bruto | R$ 2.811.962,92 |
| Descontos | R$ 34.784,24 |
| Faturamento líquido | R$ 2.777.178,68 |

As três chaves estrangeiras da tabela operacional de vendas também foram verificadas, sem restrições desabilitadas ou não confiáveis.

## Testes realizados

- Verificação de duplicações de vendas.
- Conferência dos cálculos financeiros e arredondamentos.
- Simulação de cancelamento de venda, seguida de recarga.
- Validação de reversão de alterações com `ROLLBACK`.
- Execução da carga em banco separado para homologação.

Os testes de transação foram simulações controladas. Não representam a implementação de uma suíte automatizada de testes.

## Limitações e melhorias futuras

- A carga utiliza a estratégia de recarga completa, e não processamento incremental.
- O agendamento automático pelo SQL Server Agent não foi implementado.
- Podem ser adicionados registros de execução, monitoramento e métricas de desempenho.
- A solução poderá evoluir para cargas incrementais e integração com ferramentas de Business Intelligence.

## Aprendizados

O projeto permitiu praticar não apenas consultas SQL, mas também organização de dados, aplicação de regras comerciais, consistência financeira, tratamento de falhas, procedimentos armazenados e validação de cargas analíticas.

O principal aprendizado foi compreender que uma carga de dados precisa ser **reproduzível, verificável e consistente**, além de produzir os resultados esperados.
