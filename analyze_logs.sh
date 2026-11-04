#!/bin/bash

# Если путь не указан — генерируем тестовый access.log
LOG_FILE="${1:-access.log}"

if [ $# -eq 0 ]; then
    echo "Генерация тестового access.log..."

    IP_LIST=(
        "192.168.1.10"
        "10.0.0.5"
        "172.16.0.20"
        "192.168.1.15"
        "10.0.0.8"
    )

    METHODS=("GET" "POST" "PUT" "DELETE")
    URLS=("/api/users" "/api/login" "/api/orders" "/api/products")
    CODES=(200 201 301 400 401 403 404 500 502 503 504)

    > "$LOG_FILE"

    for i in $(seq 1 300); do
        IP=${IP_LIST[$((RANDOM % ${#IP_LIST[@]}))]}
        METHOD=${METHODS[$((RANDOM % ${#METHODS[@]}))]}
        URL=${URLS[$((RANDOM % ${#URLS[@]}))]}
        CODE=${CODES[$((RANDOM % ${#CODES[@]}))]}

        SECOND=$(printf "%02d" $((i % 60)))

        echo "$IP - - [15/Aug/2026:10:15:$SECOND] \"$METHOD $URL HTTP/1.1\" $CODE" >> "$LOG_FILE"
    done

    echo "Создан файл $LOG_FILE (300 записей)"
fi

# Проверяем существование файла
if [ ! -f "$LOG_FILE" ]; then
    echo "Ошибка: файл $LOG_FILE не найден"
    exit 1
fi

echo ""
echo "=================================="
echo "       АНАЛИЗ ACCESS.LOG"
echo "=================================="

# 1. Общее количество запросов
TOTAL=$(grep -Ec '^[0-9]{1,3}(\.[0-9]{1,3}){3} - - \[' "$LOG_FILE")

echo ""
echo "Общее количество запросов: $TOTAL"

# 2. Топ-3 IP-адреса
echo ""
echo "Топ-3 IP-адреса по количеству запросов:"

grep -Eo '^[0-9]{1,3}(\.[0-9]{1,3}){3}' "$LOG_FILE" |
    sort |
    uniq -c |
    sort -rn |
    head -3 |
    awk '{printf "%-15s %s запросов\n", $2, $1}'

# 3. Количество запросов с кодами 4xx
COUNT_4XX=$(awk '$NF ~ /^4[0-9][0-9]$/ {count++} END {print count+0}' "$LOG_FILE")

# 4. Количество запросов с кодами 5xx
COUNT_5XX=$(awk '$NF ~ /^5[0-9][0-9]$/ {count++} END {print count+0}' "$LOG_FILE")

echo ""
echo "Запросы с кодами 4xx: $COUNT_4XX"
echo "Запросы с кодами 5xx: $COUNT_5XX"

echo ""
echo "=================================="

exit 0
