const Joi = require('joi');

const companySchema = Joi.object({
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.empty': 'Company name is required',
      'string.min': 'Company name must be at least 2 characters long',
      'string.max': 'Company name cannot exceed 100 characters'
    }),
  
  adminEmail: Joi.string()
    .email()
    .required()
    .messages({
      'string.empty': 'Admin email is required',
      'string.email': 'Please provide a valid email address'
    }),
  
  logo: Joi.string()
    .uri()
    .allow(null, '')
    .optional()
    .messages({
      'string.uri': 'Logo must be a valid URL'
    })
});

const validateCompany = (req, res, next) => {
  const { error } = companySchema.validate(req.body, { abortEarly: false });
  
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
  companySchema,
  validateCompany
};