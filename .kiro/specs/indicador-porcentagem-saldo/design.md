# Design Document

## Overview

O indicador de porcentagem será implementado como um componente visual que aparece próximo ao saldo principal na página inicial. Ele calculará a diferença percentual entre o saldo atual do mês (até o dia de hoje) e o saldo do mesmo período do mês anterior, exibindo o resultado com cores apropriadas (verde para positivo, vermelho para negativo).

## Architecture

### Component Structure
```
FinanceSummaryWidget (existing)
├── Balance Display (existing)
├── PercentageIndicator (new)
│   ├── PercentageCalculationService
│   └── PercentageDisplayWidget
└── Income/Expenses Display (existing)
```

### Data Flow
1. TransactionController fornece dados de transações
2. PercentageCalculationService calcula a porcentagem comparativa
3. PercentageDisplayWidget renderiza o indicador visual
4. FinanceSummaryWidget integra o indicador ao layout existente

## Components and Interfaces

### 1. PercentageCalculationService

**Responsabilidade:** Calcular a porcentagem de variação entre períodos equivalentes

**Interface:**
```dart
class PercentageCalculationService {
  static PercentageResult calculateMonthlyComparison(
    List<TransactionModel> transactions,
    DateTime currentDate
  );
  
  static double _getBalanceForPeriod(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate
  );
  
  static double _parseValue(String value);
}

class PercentageResult {
  final double percentage;
  final bool hasData;
  final PercentageType type;
  
  PercentageResult({
    required this.percentage,
    required this.hasData,
    required this.type,
  });
}

enum PercentageType {
  positive,
  negative,
  neutral,
  newData
}
```

**Métodos principais:**
- `calculateMonthlyComparison()`: Calcula a comparação entre mês atual e anterior
- `_getBalanceForPeriod()`: Obtém saldo líquido para um período específico
- `_parseValue()`: Converte string de valor para double

### 2. PercentageDisplayWidget

**Responsabilidade:** Renderizar o indicador visual de porcentagem

**Interface:**
```dart
class PercentageDisplayWidget extends StatelessWidget {
  final PercentageResult result;
  final bool showTooltip;
  
  const PercentageDisplayWidget({
    Key? key,
    required this.result,
    this.showTooltip = false,
  }) : super(key: key);
}
```

**Propriedades visuais:**
- Cores: Verde (#4CAF50), Vermelho (#F44336), Cinza (#9E9E9E)
- Ícones: Seta para cima (↑), Seta para baixo (↓), Traço (—)
- Tamanho: Pequeno, não intrusivo
- Posição: Próximo ao saldo principal

### 3. Extensão do TransactionController

**Novos métodos a serem adicionados:**

```dart
extension PercentageCalculation on TransactionController {
  PercentageResult get monthlyPercentageComparison;
  
  double getBalanceForDateRange(DateTime startDate, DateTime endDate);
  
  List<TransactionModel> getTransactionsForDateRange(
    DateTime startDate, 
    DateTime endDate
  );
}
```

## Data Models

### PercentageResult
```dart
class PercentageResult {
  final double percentage;      // Valor da porcentagem (-100 a +∞)
  final bool hasData;          // Se há dados suficientes para cálculo
  final PercentageType type;   // Tipo do resultado (positivo/negativo/neutro/novo)
  final String displayText;   // Texto formatado para exibição
  
  // Getters para propriedades visuais
  Color get color;
  IconData get icon;
  String get formattedPercentage;
}
```

## Error Handling

### Cenários de Erro
1. **Dados insuficientes:** Quando não há transações no mês anterior
   - Ação: Não exibir o indicador
   - Log: Registrar ausência de dados para análise

2. **Divisão por zero:** Quando saldo anterior é zero mas atual não é
   - Ação: Exibir "Novo" ou ícone especial
   - Tratamento: Usar PercentageType.newData

3. **Dados corrompidos:** Valores de transação inválidos
   - Ação: Ignorar transações com valores inválidos
   - Fallback: Continuar cálculo com dados válidos

4. **Erro de parsing de data:** Datas de transação inválidas
   - Ação: Ignorar transações com datas inválidas
   - Log: Registrar erro para correção

### Tratamento de Edge Cases
```dart
// Exemplo de tratamento robusto
double _parseValue(String value) {
  try {
    String cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.parse(cleanValue);
  } catch (e) {
    // Log error and return 0 to avoid breaking calculation
    print('Error parsing value: $value - $e');
    return 0.0;
  }
}
```

## Testing Strategy

### Unit Tests
1. **PercentageCalculationService**
   - Teste de cálculo com valores positivos e negativos
   - Teste de cenários edge (zero, valores iguais)
   - Teste de parsing de valores em diferentes formatos
   - Teste de filtros de data

2. **PercentageDisplayWidget**
   - Teste de renderização para diferentes tipos de resultado
   - Teste de cores e ícones corretos
   - Teste de formatação de texto

### Integration Tests
1. **Integração com TransactionController**
   - Teste de fluxo completo de dados
   - Teste de performance com grandes volumes de transações
   - Teste de atualização em tempo real

### Widget Tests
1. **FinanceSummaryWidget com indicador**
   - Teste de layout e posicionamento
   - Teste de responsividade
   - Teste de interação do usuário

### Test Data Scenarios
```dart
// Cenários de teste
final testScenarios = [
  // Crescimento positivo
  TestScenario(
    currentBalance: 1000.0,
    previousBalance: 800.0,
    expectedPercentage: 25.0,
    expectedType: PercentageType.positive,
  ),
  
  // Decréscimo
  TestScenario(
    currentBalance: 600.0,
    previousBalance: 800.0,
    expectedPercentage: -25.0,
    expectedType: PercentageType.negative,
  ),
  
  // Sem mudança
  TestScenario(
    currentBalance: 800.0,
    previousBalance: 800.0,
    expectedPercentage: 0.0,
    expectedType: PercentageType.neutral,
  ),
  
  // Primeiro mês (sem dados anteriores)
  TestScenario(
    currentBalance: 1000.0,
    previousBalance: null,
    expectedHasData: false,
  ),
];
```

## Implementation Considerations

### Performance
- Cálculos devem ser eficientes para grandes volumes de transações
- Cache de resultados para evitar recálculos desnecessários
- Filtros otimizados por data para reduzir processamento

### Accessibility
- Suporte a leitores de tela com descrições adequadas
- Contraste de cores adequado para visibilidade
- Tamanho de toque adequado se interativo

### Internationalization
- Formatação de porcentagem respeitando locale
- Textos localizáveis para diferentes idiomas
- Formatação de números conforme região

### Responsive Design
- Adaptação para diferentes tamanhos de tela
- Posicionamento flexível no layout
- Legibilidade em dispositivos pequenos