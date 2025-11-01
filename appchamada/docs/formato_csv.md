# Formato de Exportação CSV - Aplicativo de Chamada

## Estrutura das Colunas
ID,Nome,Data,Rodada,Status,TempoRegistro,Notas

## Descrição dos Campos
- **ID**: Identificador único do aluno
- **Nome**: Nome completo do aluno
- **Data**: Data da aula (formato: YYYY-MM-DD)
- **Rodada**: Número da rodada (1, 2, 3 ou 4)
- **Status**: P (Presente), F (Falta) ou A (Atraso)
- **TempoRegistro**: Hora do registro (formato: HH:MM:SS)
- **Notas**: Observações adicionais (opcional)

## Exemplo
```
ID,Nome,Data,Rodada,Status,TempoRegistro,Notas
1,Fernando Costa,2025-10-31,1,P,18:05:23,
1,Fernando Costa,2025-10-31,2,A,19:58:10,Atrasado 8 minutos
1,Fernando Costa,2025-10-31,3,P,21:02:45,
1,Fernando Costa,2025-10-31,4,F,,,Não registrou presença
```