#!/usr/bin/env node
const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json());

// Простое хранилище в памяти
let passes = [
  {
    id: '550e8400-e29b-41d4-a716-446655440030',
    organizationName: 'Coffee House Demo',
    description: 'Карта лояльности кофейни',
    serialNumber: 'LY-COFFEE-001',
    passType: 'storeCard',
    backgroundColor: '#8B4513',
    foregroundColor: '#FFFFFF',
    fields: {
      headerFields: [{ key: 'points', label: 'Баллы', value: '150' }],
      primaryFields: [{ key: 'name', label: 'Имя', value: 'Иван Петров' }],
      secondaryFields: [{ key: 'level', label: 'Уровень', value: 'Серебряный' }]
    },
    barcodes: [{
      format: 'PKBarcodeFormatQR',
      message: 'LY-COFFEE-001',
      messageEncoding: 'iso-8859-1'
    }],
    companyId: '550e8400-e29b-41d4-a716-446655440001',
    loyaltyProgramId: '550e8400-e29b-41d4-a716-446655440010',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440031',
    organizationName: 'Beauty Salon Demo',
    description: 'Карта клиента салона красоты',
    serialNumber: 'LY-BEAUTY-001',
    passType: 'storeCard',
    backgroundColor: '#FF69B4',
    foregroundColor: '#FFFFFF',
    fields: {
      headerFields: [{ key: 'discount', label: 'Скидка', value: '15%' }],
      primaryFields: [{ key: 'name', label: 'Имя', value: 'Мария Сидорова' }],
      secondaryFields: [{ key: 'visits', label: 'Посещений', value: '8' }]
    },
    barcodes: [{
      format: 'PKBarcodeFormatQR',
      message: 'LY-BEAUTY-001',
      messageEncoding: 'iso-8859-1'
    }],
    companyId: '550e8400-e29b-41d4-a716-446655440002',
    loyaltyProgramId: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

let companies = [
  {
    id: '550e8400-e29b-41d4-a716-446655440001',
    name: 'Coffee House Demo',
    adminEmail: 'admin@coffeehouse.com'
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440002',
    name: 'Beauty Salon Demo',
    adminEmail: 'admin@beautysalon.com'
  }
];

let users = [
  {
    id: '550e8400-e29b-41d4-a716-446655440020',
    name: 'Иван Петров',
    email: 'ivan@example.com',
    points: 150
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440021',
    name: 'Мария Сидорова',
    email: 'maria@example.com',
    points: 320
  }
];

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'LY Passes Demo API',
    timestamp: new Date().toISOString()
  });
});

// GET all passes
app.get('/api/v1/passes', (req, res) => {
  const { companyId, userId } = req.query;
  
  let filteredPasses = passes;
  
  if (companyId) {
    filteredPasses = passes.filter(p => p.companyId === companyId);
  }
  
  // Добавляем информацию о компании
  const enrichedPasses = filteredPasses.map(pass => {
    const company = companies.find(c => c.id === pass.companyId);
    return {
      ...pass,
      companyName: company ? company.name : null
    };
  });
  
  res.json({
    success: true,
    data: enrichedPasses,
    count: enrichedPasses.length
  });
});

// GET pass by ID
app.get('/api/v1/passes/:id', (req, res) => {
  const pass = passes.find(p => p.id === req.params.id);
  
  if (!pass) {
    return res.status(404).json({
      success: false,
      error: 'Pass not found'
    });
  }
  
  const company = companies.find(c => c.id === pass.companyId);
  
  res.json({
    success: true,
    data: {
      ...pass,
      companyName: company ? company.name : null
    }
  });
});

// POST create new pass
app.post('/api/v1/passes', (req, res) => {
  try {
    const passData = req.body;
    
    const newPass = {
      id: uuidv4(),
      organizationName: passData.organizationName,
      description: passData.description || '',
      serialNumber: passData.serialNumber || `LY-${Date.now()}`,
      passType: passData.passType || 'storeCard',
      backgroundColor: passData.backgroundColor || '#1976D2',
      foregroundColor: passData.foregroundColor || '#FFFFFF',
      fields: passData.fields || {
        headerFields: [{ key: 'points', label: 'Баллы', value: '0' }],
        primaryFields: [{ key: 'name', label: 'Владелец', value: 'Новый клиент' }]
      },
      barcodes: passData.barcodes || [{
        format: 'PKBarcodeFormatQR',
        message: passData.serialNumber || `LY-${Date.now()}`,
        messageEncoding: 'iso-8859-1'
      }],
      companyId: passData.companyId || null,
      loyaltyProgramId: passData.loyaltyProgramId || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    passes.push(newPass);
    
    res.status(201).json({
      success: true,
      data: newPass,
      message: 'Pass created successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to create pass',
      message: error.message
    });
  }
});

// DELETE pass
app.delete('/api/v1/passes/:id', (req, res) => {
  const index = passes.findIndex(p => p.id === req.params.id);
  
  if (index === -1) {
    return res.status(404).json({
      success: false,
      error: 'Pass not found'
    });
  }
  
  passes.splice(index, 1);
  
  res.json({
    success: true,
    message: 'Pass deleted successfully'
  });
});

// GET companies
app.get('/api/v1/companies', (req, res) => {
  res.json({
    success: true,
    data: companies,
    count: companies.length
  });
});

// GET users
app.get('/api/v1/users', (req, res) => {
  res.json({
    success: true,
    data: users,
    count: users.length
  });
});

// GET pass stats
app.get('/api/v1/passes/stats/overview', (req, res) => {
  const stats = {
    total: passes.length,
    byType: passes.reduce((acc, pass) => {
      acc[pass.passType] = (acc[pass.passType] || 0) + 1;
      return acc;
    }, {}),
    byCompany: passes.reduce((acc, pass) => {
      const company = companies.find(c => c.id === pass.companyId);
      const companyName = company ? company.name : 'Unknown';
      acc[companyName] = (acc[companyName] || 0) + 1;
      return acc;
    }, {})
  };
  
  res.json({
    success: true,
    data: stats
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

const PORT = 3001;
const server = app.listen(PORT, () => {
  console.log('\n🎯 LY Passes Demo API');
  console.log(`📡 Сервер: http://localhost:${PORT}`);
  console.log(`🔍 Health: http://localhost:${PORT}/health`);
  console.log(`📱 Пассы: http://localhost:${PORT}/api/v1/passes`);
  console.log('\n✨ Готов к тестированию пассов!');
  console.log('⏹️  Для остановки нажмите Ctrl+C');
});

process.on('SIGTERM', () => {
  console.log('\n⏹️  Остановка сервера...');
  server.close(() => {
    console.log('✅ Сервер остановлен');
    process.exit(0);
  });
});