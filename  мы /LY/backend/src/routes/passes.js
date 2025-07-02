const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const WalletPass = require('../models/WalletPass');
const { validateWalletPass } = require('../validators/walletPassValidator');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, process.env.UPLOAD_DIR || 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880 // 5MB
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// GET all passes
router.get('/', async (req, res) => {
  try {
    const { companyId, loyaltyProgramId, passType, userId } = req.query;
    
    const filters = {};
    if (companyId) filters.companyId = companyId;
    if (loyaltyProgramId) filters.loyaltyProgramId = loyaltyProgramId;
    if (passType) filters.passType = passType;
    
    let passes;
    if (userId) {
      passes = await WalletPass.findByUserId(userId);
    } else {
      passes = await WalletPass.findAll(filters);
    }

    res.json({
      success: true,
      data: passes,
      count: passes.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch passes',
      message: error.message
    });
  }
});

// GET pass by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pass = await WalletPass.findById(id);
    
    if (!pass) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    // Парсим JSON поля если они есть
    if (typeof pass.fields === 'string') {
      pass.fields = JSON.parse(pass.fields);
    }
    if (typeof pass.barcodes === 'string') {
      pass.barcodes = JSON.parse(pass.barcodes);
    }

    res.json({
      success: true,
      data: pass
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch pass',
      message: error.message
    });
  }
});

// POST create new pass
router.post('/', upload.single('logo'), async (req, res) => {
  try {
    // Парсим данные пасса из тела запроса
    let passData;
    if (req.body.passData) {
      passData = typeof req.body.passData === 'string' 
        ? JSON.parse(req.body.passData) 
        : req.body.passData;
    } else {
      passData = req.body;
    }
    
    // Добавляем путь к загруженному файлу
    if (req.file) {
      passData.logo = req.file.filename;
    }
    
    // Генерируем passTypeIdentifier если не предоставлен
    if (!passData.passTypeIdentifier) {
      passData.passTypeIdentifier = `pass.com.ly.${uuidv4()}`;
    }
    
    const newPass = await WalletPass.create(passData);
    
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

// PUT update pass
router.put('/:id', upload.single('logo'), async (req, res) => {
  try {
    const { id } = req.params;
    
    // Парсим данные пасса
    let passData;
    if (req.body.passData) {
      passData = typeof req.body.passData === 'string' 
        ? JSON.parse(req.body.passData) 
        : req.body.passData;
    } else {
      passData = req.body;
    }
    
    // Добавляем путь к новому файлу если загружен
    if (req.file) {
      passData.logo = req.file.filename;
    }
    
    const updatedPass = await WalletPass.update(id, passData);
    
    if (!updatedPass) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    res.json({
      success: true,
      data: updatedPass,
      message: 'Pass updated successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to update pass',
      message: error.message
    });
  }
});

// GET download pass as .pkpass file
router.get('/:id/download', async (req, res) => {
  try {
    const { id } = req.params;
    const pass = await WalletPass.findById(id);
    
    if (!pass) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    // In production, this would generate actual .pkpass file
    // For now, we return the pass data as JSON
    res.setHeader('Content-Type', 'application/vnd.apple.pkpass');
    res.setHeader('Content-Disposition', `attachment; filename="${pass.organization_name}-${pass.id}.pkpass"`);
    
    // This is a mock implementation - real PassKit generation would require
    // Apple certificates and proper signing
    res.json({
      success: true,
      message: 'This is a mock download. Real implementation requires Apple PassKit certificates.',
      data: pass
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to download pass',
      message: error.message
    });
  }
});

// DELETE pass
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await WalletPass.delete(id);
    
    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    res.json({
      success: true,
      message: 'Pass deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to delete pass',
      message: error.message
    });
  }
});

// POST assign pass to user
router.post('/:id/assign', async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'User ID is required'
      });
    }
    
    const result = await WalletPass.assignToUser(id, userId);
    
    res.json({
      success: true,
      data: result,
      message: 'Pass assigned to user successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to assign pass to user',
      message: error.message
    });
  }
});

// GET passes stats
router.get('/stats/overview', async (req, res) => {
  try {
    const stats = await WalletPass.getStats();
    
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to get pass statistics',
      message: error.message
    });
  }
});

module.exports = router;