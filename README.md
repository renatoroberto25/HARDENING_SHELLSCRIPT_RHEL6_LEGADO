# HARDENING SHELLSCRIPT RHEL6 LEGADO

Automacao de auditoria e remediacao best effort para hardening de ambientes RHEL 6 e Oracle Linux 6 legados.

## Visao Geral

Este projeto organiza controles de hardening em shell script, com um audit consolidado e remediacoes separadas por faixa de controles. O objetivo e apoiar validacao e ajuste de servidores legados, respeitando as limitacoes do RHEL6: SysV init, `service`, `chkconfig`, `yum`, GRUB Legacy, `iptables` e configuracoes classicas em arquivos como `/etc/sysctl.conf`.

Nem todo controle e totalmente automatizavel com seguranca. Alguns itens dependem do papel do servidor, excecoes aprovadas, janelas de mudanca, repositorios disponiveis ou analise manual. Nesses casos, a remediacao deve ser tratada como orientacao operacional ou best effort.

## Baseline

A referencia funcional do projeto esta em:

```text
BASELINE_RHEL6.csv
```

Ela define o escopo dos controles, a criticidade, o tipo de aplicabilidade e a expectativa de auditoria/remediacao.

## Estrutura

```text
AUDIT_SH/
  1_203_rhel6.sh      Audit consolidado dos controles
  LISTA               Arquivo auxiliar
  REGEX               Arquivo auxiliar

REMED_SH/
  *.sh                Remediacoes por faixa de controles

executor.sh           Orquestrador de audit/remed/full/report
BASELINE_RHEL6.csv    Baseline de referencia
```

Os logs gerados pelo executor ficam em `logs/`, mas essa pasta e ignorada pelo git.

## Modos de Execucao

Menu interativo:

```bash
./executor.sh
```

Executar somente auditoria:

```bash
./executor.sh audit
```

Executar somente remediacao:

```bash
./executor.sh remed
```

Executar auditoria, remediacao e auditoria pos-ajuste:

```bash
./executor.sh full
```

Listar itens que continuaram falhando no ultimo audit pos-remediacao:

```bash
./executor.sh report
```

## Fluxo

O modo `full` executa:

```text
AUDIT PRE -> REMEDIACAO -> AUDIT POS
```

Ao final, o executor exibe o total de `PASS`, `FAIL`, percentual de aderencia e comparativo entre antes e depois.

## Requisitos

- Executar em RHEL 6 ou Oracle Linux 6 para validacao real.
- Usar usuario com privilegios administrativos.
- Revisar o baseline antes de aplicar remediacoes em servidores produtivos.
- Executar preferencialmente em VM, snapshot ou janela controlada antes de aplicar em ambiente real.

Exemplo:

```bash
sudo su -
cd HARDENING_SHELLSCRIPT_RHEL6_LEGADO
chmod -R +x .
./executor.sh audit
```

## Remediacao Best Effort

As remediacoes usam comandos e caminhos compativeis com RHEL6 sempre que possivel. Exemplos:

- `chkconfig` e `service` para servicos SysV
- `yum` para pacotes
- `/boot/grub/grub.conf` para GRUB Legacy
- `/etc/sysconfig/init` para single user mode
- `/etc/sysctl.conf` para sysctl persistente
- `iptables` para regras de rede

Alguns controles sao inerentemente contextuais ou manuais, por exemplo:

- processos SELinux `unconfined_t` ou `unconfined_service_t`
- PolicyKit legado
- aplicacao de patches de seguranca
- servicos que podem ser requeridos pelo papel do servidor
- senha do GRUB, que deve usar hash gerado previamente

Nesses casos, o script pode registrar `INFO`, `SKIP` ou `WARN`, e a decisao final deve seguir o baseline e a politica do ambiente.

## Senha do GRUB Legacy

O controle de senha do GRUB aceita remediacao automatica somente quando um hash MD5 ja foi gerado com `grub-md5-crypt`.

Exemplo:

```bash
export GRUB_MD5_PASSWORD='$1$hash-gerado'
./REMED_SH/49-51.sh
```

Sem essa variavel, o script nao grava senha em claro e trata o item como orientacao/manual.

## Logs e Evidencias

Arquivos de log, evidencias de desenvolvimento e saidas locais nao devem ser versionados. O `.gitignore` ignora, entre outros:

```text
logs/
*.log
*.jpg
*.png
execucao_completa.txt
*.bkp_*
*.bak.*
*.tmp
```

Se algum log ou evidencia precisar ser preservado, guarde fora do versionamento ou documente explicitamente a excecao.
