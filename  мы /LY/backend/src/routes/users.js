const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { validateUser, validatePointsOperation } = require('../validators/userValidator');

// GET all users
router.get('/', async (req, res) => {
  try {
    const { loyaltyProgramId } = req.query;
    
    let users;
    if (loyaltyProgramId) {
      users = await User.findByLoyaltyProgram(loyaltyProgramId);
    } else {
      users = await User.findAll();
    }

    res.json({
      success: true,
      data: users,
      count: users.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch users',
      message: error.message
    });
  }
});

// GET user by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user',
      message: error.message
    });
  }
});

// POST create new user
router.post('/', validateUser, async (req, res) => {
  try {
    const userData = req.body;
    
    // Check if user already exists
    const existingUser = await User.findByEmailOrPhone(userData.email, userData.phone);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        error: 'User already exists with this email or phone'
      });
    }
    
    const user = await User.create(userData);
    
    // Add user to loyalty program if specified
    if (userData.loyaltyProgramId) {
      await User.addToLoyaltyProgram(user.id, userData.loyaltyProgramId);
    }
    
    res.status(201).json({
      success: true,
      data: user,
      message: 'User created successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to create user',
      message: error.message
    });
  }
});

// PUT update user
router.put('/:id', validateUser, async (req, res) => {
  try {
    const { id } = req.params;
    const userData = req.body;
    
    const user = await User.update(id, userData);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user,
      message: 'User updated successfully'
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to update user',
      message: error.message
    });
  }
});

// GET user points balance
router.get('/:id/points', async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: {
        userId: user.id,
        points: user.points,
        lastUpdated: user.updated_at
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user points',
      message: error.message
    });
  }
});

// POST add points to user
router.post('/:id/points/add', validatePointsOperation, async (req, res) => {
  try {
    const { id } = req.params;
    const { points, description } = req.body;
    
    const user = await User.addPoints(id, points);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: {
        userId: user.id,
        pointsAdded: points,
        totalPoints: user.points,
        description
      },
      message: `${points} points added successfully`
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to add points',
      message: error.message
    });
  }
});

// POST redeem points from user
router.post('/:id/points/redeem', validatePointsOperation, async (req, res) => {
  try {
    const { id } = req.params;
    const { points, description } = req.body;
    
    const user = await User.redeemPoints(id, points);
    
    res.json({
      success: true,
      data: {
        userId: user.id,
        pointsRedeemed: points,
        remainingPoints: user.points,
        description
      },
      message: `${points} points redeemed successfully`
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Failed to redeem points',
      message: error.message
    });
  }
});

// DELETE user
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await User.delete(id);
    
    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to delete user',
      message: error.message
    });
  }
});

module.exports = router;