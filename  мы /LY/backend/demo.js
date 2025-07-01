#!/usr/bin/env node
console.log('🎯 LY Backend Demo\n');

const express = require('express');
const app = express();

// Импортируем основной сервер
try {
  console.log('📦 Загрузка модулей...');
  
  // Проверяем что все модули загружаются
  const cors = require('cors');
  const helmet = require('helmet');
  const morgan = require('morgan');
  
  console.log('✅ Express модули загружены');
  
  // Загружаем наши маршруты
  const companiesRoutes = require('./src/routes/companies');
  const loyaltyRoutes = require('./src/routes/loyalty');
  const passesRoutes = require('./src/routes/passes');
  const usersRoutes = require('./src/routes/users');
  const analyticsRoutes = require('./src/routes/analytics');
  
  console.log('✅ API маршруты загружены');
  
  // Настройка Express
  app.use(helmet());
  app.use(cors());
  app.use(express.json());
  
  // Health check
  app.get('/health', (req, res) => {
    res.json({ 
      status: 'OK', 
      message: 'LY Backend is running!',
      timestamp: new Date().toISOString(),
      environment: 'demo'
    });
  });
  
  // API routes
  app.use('/api/v1/companies', companiesRoutes);
  app.use('/api/v1/loyalty-programs', loyaltyRoutes);
  app.use('/api/v1/passes', passesRoutes);
  app.use('/api/v1/users', usersRoutes);
  app.use('/api/v1/analytics', analyticsRoutes);
  
  // 404 handler
  app.use('*', (req, res) => {
    res.status(404).json({ error: 'Route not found' });
  });
  
  const PORT = 3000;
  const server = app.listen(PORT, () => {
    console.log('\n🚀 LY Backend успешно запущен!');
    console.log(`📡 Сервер: http://localhost:${PORT}`);
    console.log(`🔍 Health check: http://localhost:${PORT}/health`);
    console.log(`📚 API Base: http://localhost:${PORT}/api/v1`);
    console.log('\n📋 Доступные эндпоинты:');
    console.log('   GET /health');
    console.log('   GET /api/v1/companies');
    console.log('   GET /api/v1/users');
    console.log('   GET /api/v1/loyalty-programs');
    console.log('   GET /api/v1/passes');
    console.log('   GET /api/v1/analytics/dashboard');
    console.log('\n💡 Используется mock база данных (без PostgreSQL)');
    console.log('⏹️  Для остановки нажмите Ctrl+C');
  });
  
  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('\n⏹️  Остановка сервера...');
    server.close(() => {
      console.log('✅ Сервер остановлен');
      process.exit(0);
    });
  });
  
} catch (error) {
  console.error('❌ Ошибка запуска:', error.message);
  console.log('\n🔧 Возможные решения:');
  console.log('1. Установите зависимости: npm install');
  console.log('2. Проверьте .env файл');
  console.log('3. Убедитесь что все файлы созданы');
  process.exit(1);
}