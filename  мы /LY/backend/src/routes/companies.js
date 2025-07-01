const express = require('express');
const router = express.Router();
const Company = require('../models/Company');
const { validateCompany } = require('../validators/companyValidator');

// GET all companies
router.get('/', async (req, res) => {
  try {
    const companies = await Company.findAll();
    res.json({
      success: true,
      data: companies,
      count: companies.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch companies',
      message: error.message
    });
  }
});

// GET company by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const company = await Company.findWithLoyaltyPrograms(id);
    
    if (!company) {
      return res.status(404).json({
        success: false,
        error: 'Company not found'
      });
    }

    res.json({
      success: true,
      data: company
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch company',
      message: error.message
    });
  }
});

// POST create new company
router.post('/', validateCompany, async (req, res) => {
  try {
    const companyData = req.body;
    const company = await Company.create(companyData);
    
    res.status(201).json({
      success: true,
      data: company,
      message: 'Company created successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to create company',
      message: error.message
    });
  }
});

// PUT update company
router.put('/:id', validateCompany, async (req, res) => {
  try {
    const { id } = req.params;
    const companyData = req.body;
    
    const company = await Company.update(id, companyData);
    
    if (!company) {
      return res.status(404).json({
        success: false,
        error: 'Company not found'
      });
    }

    res.json({
      success: true,
      data: company,
      message: 'Company updated successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to update company',
      message: error.message
    });
  }
});

// DELETE company
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Company.delete(id);
    
    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Company not found'
      });
    }

    res.json({
      success: true,
      message: 'Company deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to delete company',
      message: error.message
    });
  }
});

module.exports = router;