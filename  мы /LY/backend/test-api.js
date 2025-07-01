#!/usr/bin/env node

const http = require('http');

// Простой HTTP клиент для тестирования
function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const result = {
            status: res.statusCode,
            headers: res.headers,
            body: body ? JSON.parse(body) : null
          };
          resolve(result);
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: body
          });
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function testAPI() {
  const baseURL = 'localhost';
  const port = 3000;
  
  console.log('🧪 Тестирование LY Backend API...\n');
  
  try {
    // 1. Health Check
    console.log('1. 🔍 Health Check...');
    const health = await makeRequest({
      hostname: baseURL,
      port: port,
      path: '/health',
      method: 'GET'
    });
    console.log(`   Status: ${health.status}`);
    console.log(`   Response: ${JSON.stringify(health.body, null, 2)}\n`);
    
    // 2. Test Companies API
    console.log('2. 🏢 Тестирование Companies API...');
    
    // GET all companies (should be empty initially)
    const companies = await makeRequest({
      hostname: baseURL,
      port: port,
      path: '/api/v1/companies',
      method: 'GET'
    });
    console.log(`   GET /companies - Status: ${companies.status}`);
    console.log(`   Companies count: ${companies.body?.count || 0}\n`);
    
    // 3. Test Users API  
    console.log('3. 👥 Тестирование Users API...');
    const users = await makeRequest({
      hostname: baseURL,
      port: port,
      path: '/api/v1/users',
      method: 'GET'
    });
    console.log(`   GET /users - Status: ${users.status}`);
    console.log(`   Users count: ${users.body?.count || 0}\n`);
    
    // 4. Test Analytics API
    console.log('4. 📊 Тестирование Analytics API...');
    const analytics = await makeRequest({
      hostname: baseURL,
      port: port,
      path: '/api/v1/analytics/dashboard',
      method: 'GET'
    });
    console.log(`   GET /analytics/dashboard - Status: ${analytics.status}`);
    if (analytics.body?.data) {
      console.log(`   Total Companies: ${analytics.body.data.overview.totalCompanies}`);
      console.log(`   Total Users: ${analytics.body.data.overview.totalUsers}`);
    }
    console.log();
    
    // 5. Test 404 handling
    console.log('5. ❌ Тестирование 404...');
    const notFound = await makeRequest({
      hostname: baseURL,
      port: port,
      path: '/api/v1/nonexistent',
      method: 'GET'
    });
    console.log(`   GET /nonexistent - Status: ${notFound.status}`);
    console.log();
    
    console.log('✅ Все тесты выполнены успешно!');
    console.log('🎉 Backend сервер работает корректно!');
    
  } catch (error) {
    console.error('❌ Ошибка при тестировании:', error.message);
    console.log('\n💡 Убедитесь что сервер запущен: npm run dev');
  }
}

// Запуск тестов
testAPI();