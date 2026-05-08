# HARDENING SHELLSCRIPT RHEL6 LEGADO

Automacao de auditoria e remediacao best effort para hardening de ambientes RHEL 6, CentOS 6 e Oracle Linux 6.

O projeto foi desenhado para sistemas legados em operacao real, normalmente com anos de configuracao acumulada, dependencias historicas e janelas de mudanca restritas. Por isso, os scripts priorizam comandos compativeis com RHEL6: `service`, `chkconfig`, `yum`, GRUB Legacy, `iptables`, PAM classico, `auditd`, `rsyslog` e arquivos de configuracao em `/etc`.

Nem todo controle deve ser corrigido automaticamente. Quando a acao depende do papel do servidor, risco operacional, dependencia de aplicacao ou validacao de excecao, a remediacao registra `INFO`, `WARN` ou `SKIP` e deixa a decisao para tratamento manual.

## Escopo de Entrega

O pacote operacional esperado e composto por:

```text
executor.sh
BASELINE_RHEL6.csv
AUDIT_SH/
REMED_SH/
utils/
logs/
```

`logs/` e usado como destino de execucao e pode conter arquivos de indice/manifesto, mas os logs gerados em runtime nao devem ser versionados.

Arquivos de laboratorio, evidencias de desenvolvimento, imagens, backups locais e artefatos pessoais nao fazem parte do pacote operacional.

## Baseline

A referencia dos controles fica em:

```text
BASELINE_RHEL6.csv
```

O audit principal imprime cada controle no formato do baseline:

```text
Topico;Subtopico;Perfil;Criticidade;Resumo;
```

Exemplo:

```text
1;Kernel;Light;Alta;Bloqueio cramfs;
PASS
```

Esse formato permite correlacionar diretamente log, evidencia, controle e linha do baseline.

## Estrutura

```text
AUDIT_SH/
  1_190_rhel6.sh      Audit consolidado dos controles RHEL6
  LISTA               Arquivo auxiliar
  REGEX               Arquivo auxiliar

REMED_SH/
  *.sh                Remediacoes por faixa de controles

utils/
  parser.sh           Utilitario auxiliar para tratamento/parse de saidas

logs/
  index.html          Estrutura de apresentacao/indice
  manifest.json       Manifesto de saidas

executor.sh           Menu e orquestrador audit/remed/full/report/status
BASELINE_RHEL6.csv    Baseline de referencia
```

## Executor

Menu interativo:

```bash
./executor.sh
```

Modos diretos:

```bash
./executor.sh audit
./executor.sh remed
./executor.sh full
./executor.sh report
./executor.sh status
```

O modo `full` executa:

```text
AUDIT PRE -> REMEDIACAO -> AUDIT POS
```

Ao final, o executor mostra totais de `PASS`, `FAIL`, aderencia, comparativo entre antes/depois e lista dos itens ainda em `FAIL`.

## Uso Operacional

Antes de executar remediacao em servidor real:

- Validar o escopo com o responsavel tecnico do servidor.
- Confirmar backup, console out-of-band ou outro plano de recuperacao.
- Executar primeiro `audit` e revisar os controles em `FAIL`.
- Aplicar remediacoes por janela controlada ou por blocos, quando necessario.
- Reexecutar `audit` apos a mudanca e preservar evidencias conforme processo interno.

Exemplo:

```bash
sudo su -
cd HARDENING_SHELLSCRIPT_RHEL6_LEGADO
chmod -R +x .
./executor.sh audit
```

Aplicacao completa, quando aprovada:

```bash
./executor.sh full
```

## Cuidados Tecnicos

Algumas remediacoes sao conservadoras por seguranca operacional:

- SELinux: o script pode ajustar configuracao persistente, mas nao deve forcar mudanca de estado em runtime sem validacao de contexto/relabel.
- DHCP: o controle mira servidor DHCP (`dhcpd`/pacote de servidor), sem remover componentes necessarios ao cliente de rede.
- SSH e firewall: qualquer endurecimento deve preservar acesso administrativo previsto ou contar com console de recuperacao.
- GRUB Legacy: senha automatica exige hash em `GRUB_MD5_PASSWORD`; senha em claro nao deve ser gravada.
- AIDE, SUID/SGID, ForceCommand/Chroot, servicos expostos e controles MAC podem exigir analise manual conforme funcao do servidor.

## Logs e Evidencias

O executor gera saidas em:

```text
logs/audit/
logs/remed/
logs/json/
```

Esses arquivos sao evidencias de execucao e devem seguir o processo interno de armazenamento do ambiente. Por padrao, logs gerados, imagens, backups temporarios e saidas locais ficam fora do versionamento.
