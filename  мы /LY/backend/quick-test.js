const express = require('express');
const app = express();

// Простой тест на запуск сервера
console.log('🔍 Проверка зависимостей...');

try {
  require('./src/server');
  console.log('✅ Все зависимости найдены');
  console.log('✅ Сервер может быть запущен');
  console.log('\n📋 Для полного тестирования:');
  console.log('1. Запустите: npm run dev');
  console.log('2. Откройте: http://localhost:3000/health');
  console.log('3. Тестируйте API endpoints в браузере или Postman');
} catch (error) {
  console.error('❌ Ошибка:', error.message);
}