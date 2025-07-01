const Joi = require('joi');

const userSchema = Joi.object({
  name: Joi.string()
    .min(2)
    .max(50)
    .required()
    .messages({
      'string.empty': 'Name is required',
      'string.min': 'Name must be at least 2 characters long',
      'string.max': 'Name cannot exceed 50 characters'
    }),
  
  email: Joi.string()
    .email()
    .allow(null, '')
    .optional()
    .messages({
      'string.email': 'Please provide a valid email address'
    }),
  
  phone: Joi.string()
    .pattern(/^\+?[\d\s\-\(\)]+$/)
    .allow(null, '')
    .optional()
    .messages({
      'string.pattern.base': 'Please provide a valid phone number'
    }),
  
  birthday: Joi.date()
    .iso()
    .allow(null)
    .optional()
    .messages({
      'date.format': 'Birthday must be a valid ISO date'
    }),
  
  points: Joi.number()
    .integer()
    .min(0)
    .default(0)
    .optional()
    .messages({
      'number.base': 'Points must be a number',
      'number.integer': 'Points must be an integer',
      'number.min': 'Points cannot be negative'
    }),
  
  walletPassUrl: Joi.string()
    .uri()
    .allow(null, '')
    .optional()
    .messages({
      'string.uri': 'Wallet pass URL must be a valid URL'
    }),
  
  loyaltyProgramId: Joi.string()
    .uuid()
    .optional()
    .messages({
      'string.uuid': 'Loyalty program ID must be a valid UUID'
    })
}).or('email', 'phone').messages({
  'object.missing': 'Either email or phone number is required'
});

const pointsOperationSchema = Joi.object({
  points: Joi.number()
    .integer()
    .min(1)
    .required()
    .messages({
      'number.base': 'Points must be a number',
      'number.integer': 'Points must be an integer',
      'number.min': 'Points must be at least 1',
      'number.required': 'Points amount is required'
    }),
  
  description: Joi.string()
    .max(200)
    .optional()
    .messages({
      'string.max': 'Description cannot exceed 200 characters'
    })
});

const validateUser = (req, res, next) => {
  const { error } = userSchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path[0],
      message: detail.message
    }));
    
    return res.status(400).json({
      success: false,
      error: 'Validation failed',
      details: errors
    });
  }
  
  next();
};

const validatePointsOperation = (req, res, next) => {
  const { error } = pointsOperationSchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path[0],
      message: detail.message
    }));
    
    return res.status(400).json({
      success: false,
      error: 'Validation failed',
      details: errors
    });
  }
  
  next();
};

module.exports = {
  userSchema,
  pointsOperationSchema,
  validateUser,
  validatePointsOperation
};