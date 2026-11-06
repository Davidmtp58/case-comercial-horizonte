# Case Comercial Horizonte

## Sobre o projeto

Projeto prático desenvolvido durante uma mentoria orientada por Erick, com a participação de David, Amanda e Valber.

O objetivo foi construir uma estrutura analítica de vendas utilizando SQL Server, transformando dados transacionais em informações organizadas e prontas para análise.

A Comercial Horizonte é uma empresa fictícia utilizada como cenário para aplicação de conceitos de SQL, modelagem de dados e integração.

## Tecnologias utilizadas

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Stored Procedures
- Transações e tratamento de erros

## Arquitetura dos dados

O projeto utiliza quatro tabelas transacionais de origem:

- `base.Clientes`
- `base.Produtos`
- `base.Vendedores`
- `base.Vendas`

Os dados são integrados pela Stored Procedure `analitico.usp_CarregarVendas`, que alimenta a tabela `analitico.Vendas`.

A carga utiliza junções entre as tabelas, aplica as regras de negócio e calcula os valores financeiros.

## Funcionalidades implementadas

- Integração das tabelas transacionais.
- Filtragem de vendas concluídas.
- Cálculo de faturamento bruto, descontos e faturamento líquido.
- Registro da data e hora da carga.
- Reprocessamento sem duplicações.
- Atualização dos dados diante de cancelamentos.
- Controle de transações com `COMMIT` e `ROLLBACK`.
- Tratamento de erros com `TRY/CATCH`.

## Resultados dos testes

| Indicador | Resultado |
|---|---:|
| Vendas processadas | 901 |
| Duplicações | 0 |
| Divergências financeiras | 0 |
| Faturamento bruto | R$ 2.811.962,92 |
| Descontos | R$ 34.784,24 |
| Faturamento líquido | R$ 2.777.178,68 |

Também foram realizados testes de cancelamento e simulação de falha com `ROLLBACK`.

A simulação de falha validou o mecanismo transacional, mas não corresponde a um teste de falha interna da Stored Procedure.

## Estrutura do projeto

- `Scripts/` — Criação das tabelas e rotina de carga.
- `testes/` — Consultas para validação dos dados.
- `documentação/` — Documentação complementar.

## Limitações

A rotina utiliza carga completa, reconstruindo a tabela analítica a cada execução. O agendamento automático diário ainda não foi implementado.

Os resultados apresentados correspondem à base fictícia utilizada nos testes.

## Aprendizados

O case proporcionou a aplicação prática de SQL Server, integração de dados, transações, validação financeira e tratamento de alterações na origem.

Também reforçou a importância da colaboração, da definição de padrões e da validação das regras de negócio em projetos de dados.