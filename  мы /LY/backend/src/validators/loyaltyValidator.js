const Joi = require('joi');

const loyaltyProgramSchema = Joi.object({
  companyId: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.empty': 'Company ID is required',
      'string.uuid': 'Company ID must be a valid UUID'
    }),
  
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.empty': 'Program name is required',
      'string.min': 'Program name must be at least 2 characters long',
      'string.max': 'Program name cannot exceed 100 characters'
    }),
  
  template: Joi.string()
    .valid('basic', 'premium', 'coffee', 'retail', 'restaurant', 'beauty')
    .required()
    .messages({
      'string.empty': 'Template is required',
      'any.only': 'Template must be one of: basic, premium, coffee, retail, restaurant, beauty'
    }),
  
  inviteLink: Joi.string()
    .uri()
    .required()
    .messages({
      'string.empty': 'Invite link is required',
      'string.uri': 'Invite link must be a valid URL'
    })
});

const validateLoyaltyProgram = (req, res, next) => {
  const { error } = loyaltyProgramSchema.validate(req.body, { abortEarly: false });
  
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
  loyaltyProgramSchema,
  validateLoyaltyProgram
};