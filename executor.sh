#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
AUDIT_DIR="$BASE_DIR/AUDIT_SH"
REMED_DIR="$BASE_DIR/REMED_SH"
LOG_DIR="$BASE_DIR/logs"
LOG_AUDIT="$LOG_DIR/audit"
LOG_REMED="$LOG_DIR/remed"
HOSTNAME="$(hostname -s)"
DATE="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_AUDIT" "$LOG_REMED"
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_REMED_OK=0
TOTAL_REMED_WARN=0
TOTAL_REMED_SKIP=0
TOTAL_REMED_INFO=0
TOTAL_REMED_ERR=0

banner() {
    local title="$1"
    echo ""
    echo "============================================================"
    echo "$title"
    echo "Host : $HOSTNAME"
    echo "Data : $(date '+%Y-%m-%d %H:%M:%S')"
    [ -r /etc/redhat-release ] && echo "SO   : $(cat /etc/redhat-release)"
    echo "============================================================"
}

need_root_warn() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "WARN: execute como root para resultados completos de audit/remed."
        echo ""
    fi
}
########################################
# Contador (usado apenas no AUDIT)
########################################
count_results() {
    local content="$1"
    local p f
    p=$(grep -c -E '^[[:space:]]*PASS[[:space:]]*$' <<< "$content" || true)
    f=$(grep -c -E '^[[:space:]]*FAIL[[:space:]]*$' <<< "$content" || true)
    echo "$p $f"
}

count_words() {
    local word="$1"
    local content="$2"
    grep -c -E "^[[:space:]]*${word}:" <<< "$content" || true
}
########################################
# Coleta scripts com glob robusto
########################################
collect_scripts() {
    local DIR="$1"
    shopt -s nullglob
    local arr=("$DIR"/*.sh)
    shopt -u nullglob
    (( ${#arr[@]} > 0 )) || return 1
    IFS=$'\n' printf "%s\n" "${arr[@]}" | sort -V
}
########################################
# EXECUTOR AUDIT
########################################
run_audit_scripts() {
    local DIR="$1"
    local LOGFILE="$2"
    : > "$LOGFILE"
    mapfile -t scripts < <(collect_scripts "$DIR") || {
        echo "Nenhum script encontrado em $DIR"
        return 1
    }
    for shfile in "${scripts[@]}"; do
        local name output p f rc
        name="$(basename "$shfile")"
        {
            echo ""
            echo "### $name"
        } >> "$LOGFILE"

        set +e
        output="$(bash "$shfile" 2>&1 | tee -a "$LOGFILE")"
        rc=$?
        set -e

        read p f <<< "$(count_results "$output")"
        TOTAL_PASS=$((TOTAL_PASS + p))
        TOTAL_FAIL=$((TOTAL_FAIL + f))
        if [ "$rc" -eq 0 ]; then
            printf "%-30s PASS(%-3s) FAIL(%-3s)\n" "$name" "$p" "$f"
        else
            printf "%-30s PASS(%-3s) FAIL(%-3s) RC(%s)\n" "$name" "$p" "$f" "$rc"
        fi
    done
}
########################################
# EXECUTOR REMEDIAÇÃO
########################################
run_remed_scripts() {
    local DIR="$1"
    local LOGFILE="$2"
    : > "$LOGFILE"
    mapfile -t scripts < <(collect_scripts "$DIR") || {
        echo "Nenhum script encontrado em $DIR"
        return 1
    }
    for shfile in "${scripts[@]}"; do
        local name output rc ok warn skip info
        name="$(basename "$shfile")"
        {
            echo ""
            echo "### $name"
        } >> "$LOGFILE"

        set +e
        output="$(bash "$shfile" 2>&1)"
        rc=$?
        set -e

        printf "%s\n" "$output" >> "$LOGFILE"

        ok="$(count_words OK "$output")"
        warn="$(count_words WARN "$output")"
        skip="$(count_words SKIP "$output")"
        info="$(count_words INFO "$output")"

        TOTAL_REMED_OK=$((TOTAL_REMED_OK + ok))
        TOTAL_REMED_WARN=$((TOTAL_REMED_WARN + warn))
        TOTAL_REMED_SKIP=$((TOTAL_REMED_SKIP + skip))
        TOTAL_REMED_INFO=$((TOTAL_REMED_INFO + info))
        [ "$rc" -ne 0 ] && TOTAL_REMED_ERR=$((TOTAL_REMED_ERR + 1))

        printf "%-30s OK(%-3s) WARN(%-3s) SKIP(%-3s) INFO(%-3s) RC(%s)\n" \
            "$name" "$ok" "$warn" "$skip" "$info" "$rc"
    done
}
########################################
# RESUMO
########################################
summary() {
    local total percent
    total=$((TOTAL_PASS + TOTAL_FAIL))
    percent=0
    (( total > 0 )) && percent=$(( (TOTAL_PASS * 100) / total ))
    echo ""
    echo "Resumo:"
    echo "TOTAL: $total"
    echo "PASS : $TOTAL_PASS"
    echo "FAIL : $TOTAL_FAIL"
    echo "Aderência: ${percent}%"
}

summary_remed() {
    echo ""
    echo "Resumo remediacao:"
    echo "OK   : $TOTAL_REMED_OK"
    echo "WARN : $TOTAL_REMED_WARN"
    echo "SKIP : $TOTAL_REMED_SKIP"
    echo "INFO : $TOTAL_REMED_INFO"
    echo "ERRO : $TOTAL_REMED_ERR"
}

print_failed_items() {
    local logfile="$1"

    awk '
        /^\[[0-9]+]/ { item=$0; next }
        /^[[:space:]]*FAIL[[:space:]]*$/ && item != "" {
            print item
        }
    ' "$logfile"
}

latest_audit_log() {
    { ls -1t "$LOG_AUDIT"/audit-post-* "$LOG_AUDIT"/audit-* 2>/dev/null || true; } | head -n 1
}
########################################
# RELATÓRIO RÁPIDO: Itens não remediados
########################################
report_unfixed() {
    local last_log
    last_log="$(latest_audit_log)"
    if [[ -z "$last_log" ]]; then
        echo "Nenhum log de audit encontrado."
        return 1
    fi
    echo "Ultimo log: $last_log"
    echo ""
    echo "Itens em FAIL:"
    print_failed_items "$last_log"
}

run_status() {
    local last_log p f total percent
    last_log="$(latest_audit_log)"
    if [[ -z "$last_log" ]]; then
        echo "Nenhum log de audit encontrado."
        return 1
    fi

    read p f <<< "$(count_results "$(cat "$last_log")")"
    total=$((p + f))
    percent=0
    (( total > 0 )) && percent=$(( (p * 100) / total ))

    echo "Ultimo audit: $last_log"
    echo "PASS: $p | FAIL: $f | Aderencia: ${percent}%"
    echo ""
    echo "Top FAIL:"
    print_failed_items "$last_log" | head -n 20
}

run_menu() {
    local opt

    while true; do
        echo ""
        echo "============================================================"
        echo "HARDENING RHEL6 - MENU"
        echo "============================================================"
        echo "1) Audit"
        echo "2) Remediacao"
        echo "3) Full (Audit -> Remed -> Audit)"
        echo "4) Itens em FAIL (ultimo audit)"
        echo "5) Status do ultimo audit"
        echo "0) Sair"
        echo ""
        read -rp "Escolha: " opt

        case "$opt" in
            1) run_audit ;;
            2) run_remed ;;
            3) run_full ;;
            4) report_unfixed ;;
            5) run_status ;;
            0|q|Q|sair|exit) break ;;
            *) echo "Opcao invalida." ;;
        esac

        echo ""
        read -rp "Pressione ENTER para voltar ao menu..." _
    done
}
########################################
# MODOS
########################################
run_audit() {
    TOTAL_PASS=0; TOTAL_FAIL=0
    LOG="$LOG_AUDIT/audit-${HOSTNAME}-${DATE}.log"
    need_root_warn
    banner "AUDIT"
    run_audit_scripts "$AUDIT_DIR" "$LOG"
    summary
    echo "Log: $LOG"
}
run_remed() {
    TOTAL_REMED_OK=0; TOTAL_REMED_WARN=0; TOTAL_REMED_SKIP=0; TOTAL_REMED_INFO=0; TOTAL_REMED_ERR=0
    LOG="$LOG_REMED/remed-${HOSTNAME}-${DATE}.log"
    need_root_warn
    banner "REMEDIACAO"
    run_remed_scripts "$REMED_DIR" "$LOG"
    summary_remed
    echo "Log: $LOG"
}
run_full() {
    LOG_PRE="$LOG_AUDIT/audit-pre-${HOSTNAME}-${DATE}.log"
    LOG_R="$LOG_REMED/remed-${HOSTNAME}-${DATE}.log"
    LOG_POST="$LOG_AUDIT/audit-post-${HOSTNAME}-${DATE}.log"
    need_root_warn
    banner "AUDIT PRE"
    TOTAL_PASS=0; TOTAL_FAIL=0
    run_audit_scripts "$AUDIT_DIR" "$LOG_PRE"
    pre_pass=$TOTAL_PASS
    pre_fail=$TOTAL_FAIL
    summary
    echo ""
    banner "REMEDIACAO"
    TOTAL_REMED_OK=0; TOTAL_REMED_WARN=0; TOTAL_REMED_SKIP=0; TOTAL_REMED_INFO=0; TOTAL_REMED_ERR=0
    run_remed_scripts "$REMED_DIR" "$LOG_R"
    summary_remed
    echo ""
    banner "AUDIT POS"
    TOTAL_PASS=0; TOTAL_FAIL=0
    run_audit_scripts "$AUDIT_DIR" "$LOG_POST"
    post_pass=$TOTAL_PASS
    post_fail=$TOTAL_FAIL
    summary
    echo ""
    echo "Comparativo:"
    echo "Antes : PASS $pre_pass | FAIL $pre_fail"
    echo "Depois: PASS $post_pass | FAIL $post_fail"
    improvement=$((pre_fail - post_fail))
    if (( improvement > 0 )); then
        echo "Melhoria em $improvement controles"
    elif (( improvement == 0 )); then
        echo "Sem alteração"
    else
        echo "Regressão detectada"
    fi
    echo ""
    echo "FAIL restantes:"
    print_failed_items "$LOG_POST" | head -n 30
    echo ""
    echo "Logs:"
    echo "PRE  : $LOG_PRE"
    echo "REMED: $LOG_R"
    echo "POST : $LOG_POST"
}
########################################
# ENTRADA
########################################
case "${1:-menu}" in
    audit)   run_audit ;;
    remed)   run_remed ;;
    full)    run_full ;;
    report)  report_unfixed ;;
    status)  run_status ;;
    menu)    run_menu ;;
    *)
        echo "Uso: $0 {audit|remed|full|report|status|menu}"
        exit 1
        ;;
esac
