# Requirements Document

## Introduction

Esta funcionalidade adiciona um indicador visual de porcentagem na página inicial do aplicativo que mostra a variação do saldo financeiro do usuário comparando o período atual do mês com o mesmo período do mês anterior. O indicador aparecerá próximo ao saldo principal, mostrando se o usuário está tendo um desempenho financeiro melhor ou pior em relação ao mês anterior.

## Requirements

### Requirement 1

**User Story:** Como usuário do aplicativo financeiro, eu quero ver um indicador de porcentagem que compare meu saldo atual do mês com o mesmo período do mês anterior, para que eu possa rapidamente identificar se estou melhorando ou piorando minha situação financeira.

#### Acceptance Criteria

1. WHEN o usuário visualiza a página inicial THEN o sistema SHALL exibir um indicador de porcentagem próximo ao saldo principal
2. WHEN o saldo atual do mês (até o dia de hoje) for maior que o saldo do mesmo período do mês anterior THEN o sistema SHALL exibir a porcentagem em cor verde com sinal positivo
3. WHEN o saldo atual do mês (até o dia de hoje) for menor que o saldo do mesmo período do mês anterior THEN o sistema SHALL exibir a porcentagem em cor vermelha com sinal negativo
4. WHEN o saldo atual for igual ao do período anterior THEN o sistema SHALL exibir 0% em cor neutra
5. WHEN não houver dados suficientes do mês anterior THEN o sistema SHALL não exibir o indicador

### Requirement 2

**User Story:** Como usuário, eu quero que o cálculo da porcentagem seja baseado apenas no período equivalente dos meses, para que a comparação seja justa e precisa.

#### Acceptance Criteria

1. WHEN for dia 15 do mês atual THEN o sistema SHALL comparar apenas as transações até o dia 15 do mês anterior
2. WHEN for o primeiro dia do mês THEN o sistema SHALL comparar com o primeiro dia do mês anterior
3. WHEN o mês anterior tiver menos dias que o atual THEN o sistema SHALL usar o último dia disponível do mês anterior
4. IF o mês anterior não tiver transações no período equivalente THEN o sistema SHALL não exibir o indicador

### Requirement 3

**User Story:** Como usuário, eu quero que o indicador seja visualmente claro e não intrusivo, para que eu possa rapidamente entender a informação sem que ela interfira na experiência principal.

#### Acceptance Criteria

1. WHEN o indicador for exibido THEN o sistema SHALL posicioná-lo próximo ao valor do saldo principal
2. WHEN o indicador for positivo THEN o sistema SHALL usar cor verde (#4CAF50 ou similar)
3. WHEN o indicador for negativo THEN o sistema SHALL usar cor vermelha (#F44336 ou similar)
4. WHEN o indicador for neutro (0%) THEN o sistema SHALL usar cor cinza
5. WHEN o usuário tocar no indicador THEN o sistema SHALL mostrar uma explicação do cálculo (opcional)

### Requirement 4

**User Story:** Como usuário, eu quero que o cálculo considere tanto receitas quanto despesas do período, para que o indicador reflita minha situação financeira real.

#### Acceptance Criteria

1. WHEN o sistema calcular a porcentagem THEN o sistema SHALL considerar o saldo líquido (receitas - despesas) do período
2. WHEN houver apenas receitas no período THEN o sistema SHALL calcular baseado apenas nas receitas
3. WHEN houver apenas despesas no período THEN o sistema SHALL calcular baseado apenas nas despesas
4. WHEN não houver transações no período atual THEN o sistema SHALL não exibir o indicador
5. IF o valor do mês anterior for zero THEN o sistema SHALL tratar como crescimento infinito e exibir "Novo" ou similar