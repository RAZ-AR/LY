#!/bin/bash

echo "🚀 Запуск LY Backend сервера..."

# Переходим в директорию backend
cd "/Users/bari/Documents/GitHub/ мы /LY/backend"

# Запускаем сервер в фоне
npm run dev &
SERVER_PID=$!

echo "📡 Сервер запущен с PID: $SERVER_PID"
echo "⏰ Ожидание 3 секунды для инициализации..."

# Ждем 3 секунды для запуска сервера
sleep 3

echo "🧪 Запуск тестов API..."

# Запускаем тесты
node test-api.js

echo ""
echo "🔄 Для остановки сервера нажмите Ctrl+C"
echo "🌐 Сервер доступен по адресу: http://localhost:3000"
echo "📚 API документация: http://localhost:3000/health"

# Ждем пользовательского ввода
read -p "Нажмите Enter для остановки сервера..."

# Останавливаем сервер
kill $SERVER_PID
echo "✅ Сервер остановлен"