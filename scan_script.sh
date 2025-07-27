#!/bin/bash
# This script scans directories and files on a web server using gobuster and curl.
# It requires a target URL as an argument and logs the results.
# Usage: ./scan_script.sh <url>
# Example: ./scan_script.sh http://mydomain/
# Also show http server version and allow methods version


if [ -z "$1" ]; then
    echo "Usage: $0 <url>"
    echo "Example: $0 http://mydomain.com/"
    exit 1
else
    TARGET="$1"
fi

WORDLIST_DIR="/usr/share/wordlists/dirb"
LOG_DIR="/home/kali/scripts/logs/scan_dir"
mkdir -p "$LOG_DIR"

TARGET_CLEAN=$(echo "$TARGET" | sed 's|^[^/]*//||;s|/||g')
OUTPUT_FILE="$LOG_DIR/scan-${TARGET_CLEAN}-$(date +%Y%m%d-%H%M%S).log"

# 1. Directories found
echo -e "== [1]  $TARGET == " | tee "$OUTPUT_FILE"
SERVER=$(curl -s -I "$TARGET/" | grep -i '^Server:' | sed 's/^[Ss]erver:[ ]*//')
ALLOW=$(curl -s -X OPTIONS -i "$TARGET/" | grep -i '^Allow:' | sed 's/^[Aa]llow:[ ]*//')

echo "Server: ${SERVER:-Servidor não informado}" | tee -a "$OUTPUT_FILE"
echo "Allow: ${ALLOW:-nenhum método retornado}" | tee -a "$OUTPUT_FILE"

echo "Directories found:" | tee -a "$OUTPUT_FILE"
DIRS=$(gobuster dir -e -u "$TARGET/" -w "$WORDLIST_DIR/big.txt" -q 2>/dev/null | \
    sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | awk '{print $1}' | sed 's|/$||' | tr -d '\r' | sort -u)

for DIR in $DIRS; do
    echo "$DIR" | tee -a "$OUTPUT_FILE"
done

# 2. For each directory found, show HTTP methods and files
COUNT=2
for DIR in $DIRS; do
    DIR_PATH="/$(echo "$DIR" | sed "s|$TARGET||;s|^/||;s|/$||")/"
    FULL_URL="${TARGET%/}$DIR_PATH"

    # HTTP Allow
    URL_TRIMMED="${DIR%/}"
    HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}\n" -X OPTIONS "$URL_TRIMMED") 
    if [ "$HTTP_RESPONSE" == "403" ]; then
    continue
    fi 

    echo -e "\n-- [$COUNT]  $FULL_URL -- " | tee -a "$OUTPUT_FILE"

    ALLOW_HEADER=$(curl -s -X OPTIONS -i "${TARGET}${DIR_PATH}" | grep -i '^Allow:')
    if [ -n "$ALLOW_HEADER" ]; then
        
        ALLOW_HEADER=$(echo "$ALLOW_HEADER" | sed 's/^[Aa]llow:[ ]*//')
        echo "Allow: ${ALLOW_HEADER//$'\r'/} (HTTP $HTTP_RESPONSE)" | tee -a "$OUTPUT_FILE"
    else
        echo "Allow: (no methods returned) (HTTP $HTTP_RESPONSE)" | tee -a "$OUTPUT_FILE"
    fi

    if [ "$HTTP_RESPONSE" == "403" ]; then
        COUNT=$((COUNT+1))
        continue
    fi

    # Arquives found
    echo -n "Arquivos: " | tee -a "$OUTPUT_FILE"
    FILES=$(gobuster dir -e -u "$FULL_URL" -w "$WORDLIST_DIR/small.txt" -x .php,.txt,.sql,.bkp -q 2>/dev/null | \
        sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

    if [ -z "$FILES" ]; then
        echo "none" | tee -a "$OUTPUT_FILE"
    else
        echo -e "\n$FILES" | tee -a "$OUTPUT_FILE"
    fi

    COUNT=$((COUNT+1))
done

echo -e "\n==== FINISHED ====\nLog salvo em: $OUTPUT_FILE" | tee -a "$OUTPUT_FILE"
