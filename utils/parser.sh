#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_DIR="$ROOT_DIR/logs"
AUDIT_DIR="$BASE_DIR/audit"
JSON_DIR="$BASE_DIR/json"
MANIFEST="$BASE_DIR/manifest.json"

mkdir -p "$AUDIT_DIR" "$JSON_DIR"

for LOG in "$AUDIT_DIR"/audit-*.log; do
    [ -f "$LOG" ] || continue

    FILE_NAME="$(basename "$LOG")"
    JSON_FILE="$JSON_DIR/${FILE_NAME%.log}.json"

    HOST="$(grep '^Host :' "$LOG" | head -1 | cut -d':' -f2- | xargs)"
    DATA="$(grep '^Data :' "$LOG" | head -1 | cut -d':' -f2- | xargs)"
    SO="$(grep '^SO' "$LOG" | head -1 | cut -d':' -f2- | xargs)"

    TOTAL="$(grep -E '^(PASS|FAIL|CHECK)$' "$LOG" | wc -l)"
    PASS="$(grep -c '^PASS$' "$LOG")"
    FAIL="$(grep -c '^FAIL$' "$LOG")"
    CHECK="$(grep -c '^CHECK$' "$LOG")"

    if [ "$TOTAL" -gt 0 ]; then
        ADERENCIA="$(( PASS * 100 / TOTAL ))"
    else
        ADERENCIA="0"
    fi

    {
        echo "{"
        echo "  \"host\": \"$HOST\","
        echo "  \"data\": \"$DATA\","
        echo "  \"so\": \"$SO\","
        echo "  \"total\": $TOTAL,"
        echo "  \"pass\": $PASS,"
        echo "  \"fail\": $FAIL,"
        echo "  \"check\": $CHECK,"
        echo "  \"aderencia\": $ADERENCIA,"
        echo "  \"items\": ["

        awk '
        BEGIN { first=1 }

        /^[0-9]+;/ {
            split($0,a,";")

            id=a[1]
            dominio=a[2]
            perfil=a[3]
            criticidade=a[4]
            descricao=a[5]

            status=""

            while (getline line) {
                if (line == "PASS" || line == "FAIL" || line == "CHECK") {
                    status=line
                    break
                }
            }

            gsub(/"/, "\\\"", dominio)
            gsub(/"/, "\\\"", perfil)
            gsub(/"/, "\\\"", criticidade)
            gsub(/"/, "\\\"", descricao)

            if (status != "") {
                if (!first) {
                    print ","
                }

                printf "    {"
                printf "\"id\": %s,", id
                printf "\"dominio\": \"%s\",", dominio
                printf "\"perfil\": \"%s\",", perfil
                printf "\"criticidade\": \"%s\",", criticidade
                printf "\"descricao\": \"%s\",", descricao
                printf "\"status\": \"%s\"", status
                printf "}"

                first=0
            }
        }
        ' "$LOG"

        echo ""
        echo "  ]"
        echo "}"
    } > "$JSON_FILE"
done

{
    echo "{"
    echo '  "audits": ['

    FIRST=1
    for JSON in "$JSON_DIR"/audit-*.json; do
        [ -f "$JSON" ] || continue
        FILE="$(basename "$JSON")"

        if [ "$FIRST" -eq 0 ]; then
            echo ","
        fi

        printf '    "%s"' "$FILE"
        FIRST=0
    done

    echo ""
    echo "  ]"
    echo "}"
} > "$MANIFEST"

echo "OK"