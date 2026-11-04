#!/bin/bash

# Проверяем наличие аргумента
if [ -z "$1" ]; then
    echo "Ошибка: укажите URL API"
    echo "Использование: $0 <API_URL>"
    exit 1
fi

API_URL="$1"

# Выполняем HTTP-запрос и получаем код ответа
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL")

# Проверяем код ответа
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "API доступен"
    exit 0
else
    echo "API недоступен, код ответа: $HTTP_CODE"
    exit 1
fi

