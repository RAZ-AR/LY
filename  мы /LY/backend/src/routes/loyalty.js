const express = require('express');
const router = express.Router();
const LoyaltyProgram = require('../models/LoyaltyProgram');
const { validateLoyaltyProgram } = require('../validators/loyaltyValidator');

// GET all loyalty programs
router.get('/', async (req, res) => {
  try {
    const { companyId } = req.query;
    
    let programs;
    if (companyId) {
      programs = await LoyaltyProgram.findByCompanyId(companyId);
    } else {
      programs = await LoyaltyProgram.findAll();
    }

    res.json({
      success: true,
      data: programs,
      count: programs.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch loyalty programs',
      message: error.message
    });
  }
});

// GET loyalty program by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { includeDetails } = req.query;
    
    let program;
    if (includeDetails === 'true') {
      program = await LoyaltyProgram.getWithDetails(id);
    } else {
      program = await LoyaltyProgram.findById(id);
      if (program) {
        const usersCount = await LoyaltyProgram.getUsersCount(id);
        program.usersCount = usersCount;
      }
    }
    
    if (!program) {
      return res.status(404).json({
        success: false,
        error: 'Loyalty program not found'
      });
    }

    res.json({
      success: true,
      data: program
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch loyalty program',
      message: error.message
    });
  }
});

// POST create new loyalty program
router.post('/', validateLoyaltyProgram, async (req, res) => {
  try {
    const programData = req.body;
    const program = await LoyaltyProgram.create(programData);
    
    res.status(201).json({
      success: true,
      data: program,
      message: 'Loyalty program created successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to create loyalty program',
      message: error.message
    });
  }
});

// PUT update loyalty program
router.put('/:id', validateLoyaltyProgram, async (req, res) => {
  try {
    const { id } = req.params;
    const programData = req.body;
    
    const program = await LoyaltyProgram.update(id, programData);
    
    if (!program) {
      return res.status(404).json({
        success: false,
        error: 'Loyalty program not found'
      });
    }

    res.json({
      success: true,
      data: program,
      message: 'Loyalty program updated successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to update loyalty program',
      message: error.message
    });
  }
});

// DELETE loyalty program
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await LoyaltyProgram.delete(id);
    
    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Loyalty program not found'
      });
    }

    res.json({
      success: true,
      message: 'Loyalty program deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to delete loyalty program',
      message: error.message
    });
  }
});

module.exports = router;