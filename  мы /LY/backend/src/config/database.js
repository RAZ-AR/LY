// Проверяем доступность PostgreSQL
const USE_MOCK_DB = process.env.USE_MOCK_DB === 'true' || process.env.NODE_ENV === 'demo';

if (USE_MOCK_DB) {
  console.log('🔧 Используется mock база данных');
  module.exports = require('./database-mock');
} else {
  const knex = require('knex');

  const config = {
    client: 'pg',
    connection: {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'ly_loyalty',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'password'
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      directory: './migrations',
      tableName: 'knex_migrations'
    },
    seeds: {
      directory: './seeds'
    }
  };

  const db = knex(config);

  // Test database connection
  db.raw('SELECT 1')
    .then(() => {
      console.log('✅ Database connected successfully');
    })
    .catch((err) => {
      console.error('❌ Database connection failed:', err.message);
      console.log('💡 Для demo режима установите USE_MOCK_DB=true в .env');
    });

  module.exports = db;
}