const express = require('express');
const router = express.Router();
const Company = require('../models/Company');
const LoyaltyProgram = require('../models/LoyaltyProgram');
const User = require('../models/User');

// GET analytics dashboard data
router.get('/dashboard', async (req, res) => {
  try {
    const { companyId, loyaltyProgramId, dateFrom, dateTo } = req.query;
    
    // Basic counts
    const companiesCount = await Company.findAll().then(data => data.length);
    const programsCount = await LoyaltyProgram.findAll().then(data => data.length);
    const usersCount = await User.findAll().then(data => data.length);
    
    // Mock analytics data - in production this would be calculated from actual data
    const analytics = {
      overview: {
        totalCompanies: companiesCount,
        totalLoyaltyPrograms: programsCount,
        totalUsers: usersCount,
        totalPasses: Math.floor(usersCount * 0.8), // Mock: 80% of users have passes
        activeUsers: Math.floor(usersCount * 0.6) // Mock: 60% active users
      },
      metrics: {
        averageOrderValue: 125.50,
        customerLifetimeValue: 890.25,
        retentionRate: 0.73,
        engagementRate: 0.45,
        pointsRedemptionRate: 0.32
      },
      growth: {
        usersGrowth: 15.2, // Percentage
        revenueGrowth: 23.8,
        engagementGrowth: 8.5,
        retentionImprovement: 12.1
      },
      chartData: {
        userRegistrations: generateMockChartData('users', 30),
        pointsActivity: generateMockChartData('points', 30),
        passUsage: generateMockChartData('usage', 30)
      }
    };

    res.json({
      success: true,
      data: analytics,
      generatedAt: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch analytics',
      message: error.message
    });
  }
});

// GET company analytics
router.get('/company/:companyId', async (req, res) => {
  try {
    const { companyId } = req.params;
    
    const company = await Company.findById(companyId);
    if (!company) {
      return res.status(404).json({
        success: false,
        error: 'Company not found'
      });
    }

    const loyaltyPrograms = await LoyaltyProgram.findByCompanyId(companyId);
    
    // Calculate metrics for this company
    let totalUsers = 0;
    const programMetrics = [];
    
    for (const program of loyaltyPrograms) {
      const users = await User.findByLoyaltyProgram(program.id);
      totalUsers += users.length;
      
      programMetrics.push({
        programId: program.id,
        programName: program.name,
        usersCount: users.length,
        totalPoints: users.reduce((sum, user) => sum + user.points, 0),
        averagePoints: users.length > 0 ? Math.round(users.reduce((sum, user) => sum + user.points, 0) / users.length) : 0
      });
    }

    const analytics = {
      company,
      overview: {
        totalPrograms: loyaltyPrograms.length,
        totalUsers,
        averageUsersPerProgram: loyaltyPrograms.length > 0 ? Math.round(totalUsers / loyaltyPrograms.length) : 0
      },
      programs: programMetrics,
      performance: {
        topPerformingProgram: programMetrics.sort((a, b) => b.usersCount - a.usersCount)[0] || null,
        totalPointsIssued: programMetrics.reduce((sum, p) => sum + p.totalPoints, 0),
        averageEngagement: Math.random() * 0.5 + 0.3 // Mock data
      }
    };

    res.json({
      success: true,
      data: analytics
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch company analytics',
      message: error.message
    });
  }
});

// GET loyalty program analytics
router.get('/loyalty-program/:programId', async (req, res) => {
  try {
    const { programId } = req.params;
    
    const program = await LoyaltyProgram.findById(programId);
    if (!program) {
      return res.status(404).json({
        success: false,
        error: 'Loyalty program not found'
      });
    }

    const users = await User.findByLoyaltyProgram(programId);
    
    // Calculate user segmentation
    const pointsDistribution = users.map(u => u.points).sort((a, b) => b - a);
    const totalPoints = pointsDistribution.reduce((sum, points) => sum + points, 0);
    
    const analytics = {
      program,
      overview: {
        totalUsers: users.length,
        totalPoints,
        averagePoints: users.length > 0 ? Math.round(totalPoints / users.length) : 0,
        topUser: users.sort((a, b) => b.points - a.points)[0] || null
      },
      userSegmentation: {
        highValue: users.filter(u => u.points >= 1000).length,
        mediumValue: users.filter(u => u.points >= 500 && u.points < 1000).length,
        lowValue: users.filter(u => u.points < 500).length
      },
      engagement: {
        activeUsers: Math.floor(users.length * 0.7), // Mock: 70% active
        averageSessionsPerUser: Math.floor(Math.random() * 10) + 5,
        averagePointsPerTransaction: Math.floor(Math.random() * 50) + 25
      },
      timeline: generateMockChartData('program', 30)
    };

    res.json({
      success: true,
      data: analytics
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch loyalty program analytics',
      message: error.message
    });
  }
});

// Helper function to generate mock chart data
function generateMockChartData(type, days) {
  const data = [];
  const now = new Date();
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(now);
    date.setDate(date.getDate() - i);
    
    let value;
    switch (type) {
      case 'users':
        value = Math.floor(Math.random() * 50) + 10;
        break;
      case 'points':
        value = Math.floor(Math.random() * 1000) + 200;
        break;
      case 'usage':
        value = Math.floor(Math.random() * 100) + 20;
        break;
      case 'program':
        value = Math.floor(Math.random() * 30) + 5;
        break;
      default:
        value = Math.floor(Math.random() * 100);
    }
    
    data.push({
      date: date.toISOString().split('T')[0],
      value
    });
  }
  
  return data;
}

module.exports = router;