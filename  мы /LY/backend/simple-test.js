const http = require('http');

console.log('🧪 Простой тест LY Backend API\n');

// Функция для HTTP запросов
function request(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(body)
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: body
          });
        }
      });
    });
    
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function runTests() {
  const baseOptions = {
    hostname: 'localhost',
    port: 3000,
    headers: { 'Content-Type': 'application/json' }
  };

  console.log('1. 🔍 Проверка health endpoint...');
  try {
    const health = await request({
      ...baseOptions,
      path: '/health',
      method: 'GET'
    });
    
    if (health.status === 200) {
      console.log('   ✅ Сервер работает');
      console.log(`   📊 Status: ${health.data.status}`);
      console.log(`   🕒 Time: ${health.data.timestamp}`);
    } else {
      console.log('   ❌ Сервер не отвечает правильно');
    }
  } catch (error) {
    console.log('   ❌ Сервер недоступен:', error.message);
    console.log('   💡 Запустите сервер: npm run dev');
    return;
  }

  console.log('\n2. 🏢 Тест Companies API...');
  try {
    const companies = await request({
      ...baseOptions,
      path: '/api/v1/companies',
      method: 'GET'
    });
    
    console.log(`   📈 Status: ${companies.status}`);
    if (companies.data.success) {
      console.log(`   📊 Компаний найдено: ${companies.data.count}`);
    } else {
      console.log(`   ⚠️  ${companies.data.error}`);
    }
  } catch (error) {
    console.log('   ❌ Ошибка:', error.message);
  }

  console.log('\n3. 👥 Тест Users API...');
  try {
    const users = await request({
      ...baseOptions,
      path: '/api/v1/users',
      method: 'GET'
    });
    
    console.log(`   📈 Status: ${users.status}`);
    if (users.data.success) {
      console.log(`   👤 Пользователей найдено: ${users.data.count}`);
    } else {
      console.log(`   ⚠️  ${users.data.error}`);
    }
  } catch (error) {
    console.log('   ❌ Ошибка:', error.message);
  }

  console.log('\n4. 📊 Тест Analytics API...');
  try {
    const analytics = await request({
      ...baseOptions,
      path: '/api/v1/analytics/dashboard',
      method: 'GET'
    });
    
    console.log(`   📈 Status: ${analytics.status}`);
    if (analytics.data.success) {
      console.log('   📊 Аналитика получена успешно');
    } else {
      console.log(`   ⚠️  ${analytics.data.error}`);
    }
  } catch (error) {
    console.log('   ❌ Ошибка:', error.message);
  }

  console.log('\n✅ Тестирование завершено!');
  console.log('\n📋 Для полного тестирования:');
  console.log('   🌐 Откройте: test-browser.html в браузере');
  console.log('   📱 Или используйте Postman/Insomnia');
  console.log('   🗄️  Для полной функциональности настройте PostgreSQL');
}

runTests();