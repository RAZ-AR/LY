// Mock database для демонстрации без PostgreSQL
console.log('🔧 Используется mock база данных (без PostgreSQL)');

const mockData = {
  companies: [
    {
      id: '550e8400-e29b-41d4-a716-446655440001',
      name: 'Coffee House Demo',
      admin_email: 'admin@coffeehouse.com',
      logo: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440002', 
      name: 'Beauty Salon Demo',
      admin_email: 'admin@beautysalon.com',
      logo: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  loyalty_programs: [
    {
      id: '550e8400-e29b-41d4-a716-446655440010',
      company_id: '550e8400-e29b-41d4-a716-446655440001',
      name: 'Coffee Loyalty Program',
      template: 'coffee',
      invite_link: 'https://ly.app/join/coffee',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  users: [
    {
      id: '550e8400-e29b-41d4-a716-446655440020',
      name: 'Иван Петров',
      email: 'ivan@example.com',
      phone: '+7123456789',
      birthday: '1990-01-01',
      points: 150,
      wallet_pass_url: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440021',
      name: 'Мария Сидорова',
      email: 'maria@example.com',
      phone: '+7987654321',
      birthday: '1985-05-15',
      points: 320,
      wallet_pass_url: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ]
};

// Mock Knex API
const mockKnex = (tableName) => {
  const query = {
    tableName,
    conditions: [],
    joins: [],
    orderBy: null,
    selected: ['*']
  };

  const chainable = {
    select: (fields = '*') => {
      query.selected = fields === '*' ? ['*'] : (Array.isArray(fields) ? fields : [fields]);
      return chainable;
    },
    where: (field, value) => {
      query.conditions.push({ field, value, operator: '=' });
      return chainable;
    },
    join: (table, condition1, condition2) => {
      query.joins.push({ table, condition1, condition2 });
      return chainable;
    },
    orderBy: (field, direction = 'asc') => {
      query.orderBy = { field, direction };
      return chainable;
    },
    insert: (data) => {
      return {
        returning: () => {
          // Симуляция вставки
          const newItem = { ...data, id: `mock-${Date.now()}` };
          return Promise.resolve([newItem]);
        }
      };
    },
    update: (data) => {
      return {
        returning: () => {
          // Симуляция обновления
          return Promise.resolve([{ ...data, updated_at: new Date().toISOString() }]);
        }
      };
    },
    delete: () => chainable,
    del: () => Promise.resolve(1),
    increment: () => {
      return {
        returning: () => Promise.resolve([{ points: 200 }])
      };
    },
    decrement: () => {
      return {
        returning: () => Promise.resolve([{ points: 100 }])
      };
    },
    count: async () => ({ count: '2' }),
    first: async () => {
      const data = mockData[tableName] || [];
      return data.length > 0 ? data[0] : null;
    },
    then: async (callback) => {
      // Выполняем запрос и возвращаем данные
      let data = mockData[tableName] || [];
      
      // Применяем условия
      if (query.conditions.length > 0) {
        data = data.filter(item => {
          return query.conditions.every(condition => {
            return item[condition.field] === condition.value;
          });
        });
      }
      
      const result = callback ? callback(data) : data;
      return result;
    }
  };

  return chainable;
};

// Mock raw query
mockKnex.raw = async (sql) => {
  console.log('✅ Mock database connected successfully');
  return { rows: [] };
};

module.exports = mockKnex;