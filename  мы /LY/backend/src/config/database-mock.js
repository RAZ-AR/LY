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
  ],
  wallet_passes: [
    {
      id: '550e8400-e29b-41d4-a716-446655440030',
      pass_type_identifier: 'pass.com.ly.coffee',
      organization_name: 'Coffee House Demo',
      description: 'Карта лояльности кофейни',
      serial_number: 'LY-COFFEE-001',
      pass_type: 'storeCard',
      background_color: '#8B4513',
      foreground_color: '#FFFFFF',
      fields: JSON.stringify({
        headerFields: [{ key: 'points', label: 'Баллы', value: '150' }],
        primaryFields: [{ key: 'name', label: 'Имя', value: 'Иван Петров' }],
        secondaryFields: [{ key: 'level', label: 'Уровень', value: 'Серебряный' }]
      }),
      barcodes: JSON.stringify([{
        format: 'PKBarcodeFormatQR',
        message: 'LY-COFFEE-001',
        messageEncoding: 'iso-8859-1'
      }]),
      logo: null,
      company_id: '550e8400-e29b-41d4-a716-446655440001',
      loyalty_program_id: '550e8400-e29b-41d4-a716-446655440010',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440031',
      pass_type_identifier: 'pass.com.ly.beauty',
      organization_name: 'Beauty Salon Demo',
      description: 'Карта клиента салона красоты',
      serial_number: 'LY-BEAUTY-001',
      pass_type: 'storeCard',
      background_color: '#FF69B4',
      foreground_color: '#FFFFFF',
      fields: JSON.stringify({
        headerFields: [{ key: 'discount', label: 'Скидка', value: '15%' }],
        primaryFields: [{ key: 'name', label: 'Имя', value: 'Мария Сидорова' }],
        secondaryFields: [{ key: 'visits', label: 'Посещений', value: '8' }]
      }),
      barcodes: JSON.stringify([{
        format: 'PKBarcodeFormatQR',
        message: 'LY-BEAUTY-001',
        messageEncoding: 'iso-8859-1'
      }]),
      logo: null,
      company_id: '550e8400-e29b-41d4-a716-446655440002',
      loyalty_program_id: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  loyalty_program_users: [
    {
      id: '550e8400-e29b-41d4-a716-446655440040',
      loyalty_program_id: '550e8400-e29b-41d4-a716-446655440010',
      user_id: '550e8400-e29b-41d4-a716-446655440020',
      joined_at: new Date().toISOString()
    }
  ],
  user_wallet_passes: [
    {
      id: '550e8400-e29b-41d4-a716-446655440050',
      user_id: '550e8400-e29b-41d4-a716-446655440020',
      wallet_pass_id: '550e8400-e29b-41d4-a716-446655440030',
      assigned_at: new Date().toISOString(),
      is_active: true,
      usage_count: 5
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440051',
      user_id: '550e8400-e29b-41d4-a716-446655440021',
      wallet_pass_id: '550e8400-e29b-41d4-a716-446655440031',
      assigned_at: new Date().toISOString(),
      is_active: true,
      usage_count: 8
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
    leftJoin: (table, condition1, condition2) => {
      query.joins.push({ table, condition1, condition2, type: 'left' });
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
      
      // Обрабатываем JOIN'ы (упрощенно)
      if (query.joins.length > 0) {
        data = data.map(item => {
          const enrichedItem = { ...item };
          
          query.joins.forEach(join => {
            if (join.table === 'companies' && tableName === 'wallet_passes') {
              const company = mockData.companies.find(c => c.id === item.company_id);
              if (company) {
                enrichedItem.company_name = company.name;
              }
            }
            if (join.table === 'loyalty_programs' && tableName === 'wallet_passes') {
              const program = mockData.loyalty_programs.find(p => p.id === item.loyalty_program_id);
              if (program) {
                enrichedItem.loyalty_program_name = program.name;
              }
            }
            if (join.table === 'companies' && tableName === 'loyalty_programs') {
              const company = mockData.companies.find(c => c.id === item.company_id);
              if (company) {
                enrichedItem.company_name = company.name;
              }
            }
          });
          
          return enrichedItem;
        });
      }
      
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