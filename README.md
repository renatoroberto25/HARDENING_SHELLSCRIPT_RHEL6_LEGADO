# RHEL Based 8/9 Hardening Full
Automação de auditoria e remediação para RHEL 8/9 e Oracle Linux 8/9, organizada em shell script e executada por um orquestrador central.

## Visão geral
Este projeto foi criado para executar controles de hardening de forma sequencial, com auditoria, remediação e nova auditoria pós-ajuste.
A automação está concentrada no diretório `rhel_based_8_9_hardening_full`, enquanto a referência funcional do que é automático, manual ou sujeito a validação operacional está na baseline do projeto.

## Baseline de referência
Antes de usar ou adaptar qualquer script, consulte obrigatoriamente:
baseline/BASELINE_HITSS_DEFAULT_RHEL8_e_9.xlsx
Esse arquivo define o baseline esperado e deve ser tratado como fonte principal para entendimento do escopo dos controles.

## Estrutura principal
- `baseline/BASELINE_HITSS_DEFAULT_RHEL8_e_9.xlsx`: baseline de referência
- `rhel_based_8_9_hardening_full/AUDIT_SH/`: scripts de auditoria
- `rhel_based_8_9_hardening_full/REMED_SH/`: scripts de remediação
- `rhel_based_8_9_hardening_full/executor.sh`: orquestrador principal
- `rhel_based_8_9_hardening_full/logs/audit/`: logs de auditoria
- `rhel_based_8_9_hardening_full/logs/remed/`: logs de remediação
- `rhel_based_8_9_hardening_full/execucao_completa.txt`: exemplo de execução completa
- `rhel_based_8_9_hardening_full/rhel9_e_ol8_post_reboot_audit.jpg`: evidência visual de execução pós-reboot

## Auditoria
A auditoria está concentrada em:
AUDIT_SH/1_203.sh
Esse script executa os controles previstos e retorna os resultados em formato simples, usando `PASS` e `FAIL`.

## Remediação
As remediações estão divididas em blocos por faixa de controles dentro de `REMED_SH`.
Essa separação facilita manutenção, troubleshooting e execução ordenada por grupos de controles.

## Executor
O `executor.sh` é o ponto central da automação.
Ele é responsável por:
- localizar os scripts de auditoria e remediação
- executar os arquivos em ordem natural com `sort -V`
- criar os diretórios de log, se necessário
- registrar a saída em arquivos de log
- contar resultados `PASS` e `FAIL` na auditoria
- calcular percentual de aderência
- comparar auditoria pré e pós-remediação
- listar itens que permaneceram falhando no último `audit-post`

## Modos de execução
Menu interativo:
./executor.sh
Auditoria:
./executor.sh audit
Remediação:
./executor.sh remed
Execução completa:
./executor.sh full
Relatório de pendências do último pós-auditoria:
./executor.sh report

## Fluxo da execução completa
O modo `full` executa a seguinte sequência:
AUDIT PRÉ -> REMEDIAÇÃO -> AUDIT PÓS
Ao final, o executor exibe o comparativo entre antes e depois, indicando melhoria, ausência de alteração ou regressão.

## Logs
Os logs são gravados automaticamente em:
logs/audit/
logs/remed/
Exemplos:
logs/audit/audit-rhel-9-20260305-20260306-122044.log
logs/audit/audit-oracle-8-20260305-20260306-122119.log
logs/remed/remed-rhel-9-20260305-20260306-121902.log

## Requisitos de execução
A execução deve ser feita com privilégios administrativos.
Exemplo:
sudo su -
cd rhel_based_8_9_hardening_full
chmod -R +x .
./executor.sh

## Escopo
Projeto voltado para automação de hardening em ambientes baseados em:
- RHEL 8
- RHEL 9
- Oracle Linux 8
- Oracle Linux 9
A aplicabilidade final depende dos pacotes instalados, dos serviços habilitados, do perfil do host e das exceções aprovadas no ambiente.

## Observações
A automação não deve ser interpretada isoladamente da baseline.
Controles classificados como manuais, contextuais ou dependentes de operação devem ser avaliados conforme a referência funcional definida no arquivo `BASELINE_HITSS_DEFAULT_RHEL8_e_9.xlsx`.

## Exemplo de uso
cd rhel_based_8_9_hardening_full
./executor.sh full
