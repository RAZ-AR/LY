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
    const { companyId, loyaltyProgramId } = req.query;
    
    let filteredPasses = passesData;
    
    if (companyId) {
      filteredPasses = filteredPasses.filter(pass => pass.companyId === companyId);
    }
    
    if (loyaltyProgramId) {
      filteredPasses = filteredPasses.filter(pass => pass.loyaltyProgramId === loyaltyProgramId);
    }

    res.json({
      success: true,
      data: filteredPasses,
      count: filteredPasses.length
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
    const pass = passesData.find(p => p.id === id);
    
    if (!pass) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
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
    const passData = JSON.parse(req.body.passData || '{}');
    
    const newPass = {
      id: uuidv4(),
      passTypeIdentifier: passData.passTypeIdentifier || `pass.com.ly.${uuidv4()}`,
      organizationName: passData.organizationName,
      description: passData.description,
      serialNumber: passData.serialNumber || uuidv4(),
      passType: passData.passType || 'storeCard',
      backgroundColor: passData.backgroundColor || '#1976D2',
      foregroundColor: passData.foregroundColor || '#FFFFFF',
      fields: passData.fields || {},
      barcodes: passData.barcodes || [],
      logo: req.file ? req.file.filename : null,
      companyId: passData.companyId,
      loyaltyProgramId: passData.loyaltyProgramId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    passesData.push(newPass);
    
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
    const passIndex = passesData.findIndex(p => p.id === id);
    
    if (passIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    const passData = JSON.parse(req.body.passData || '{}');
    const existingPass = passesData[passIndex];
    
    const updatedPass = {
      ...existingPass,
      organizationName: passData.organizationName || existingPass.organizationName,
      description: passData.description || existingPass.description,
      passType: passData.passType || existingPass.passType,
      backgroundColor: passData.backgroundColor || existingPass.backgroundColor,
      foregroundColor: passData.foregroundColor || existingPass.foregroundColor,
      fields: passData.fields || existingPass.fields,
      barcodes: passData.barcodes || existingPass.barcodes,
      logo: req.file ? req.file.filename : existingPass.logo,
      updatedAt: new Date().toISOString()
    };
    
    passesData[passIndex] = updatedPass;

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
    const pass = passesData.find(p => p.id === id);
    
    if (!pass) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    // In production, this would generate actual .pkpass file
    // For now, we return the pass data as JSON
    res.setHeader('Content-Type', 'application/vnd.apple.pkpass');
    res.setHeader('Content-Disposition', `attachment; filename="${pass.organizationName}-${pass.id}.pkpass"`);
    
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
    const passIndex = passesData.findIndex(p => p.id === id);
    
    if (passIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Pass not found'
      });
    }

    passesData.splice(passIndex, 1);

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

module.exports = router;