const Joi = require('joi');

const walletPassSchema = Joi.object({
  passTypeIdentifier: Joi.string()
    .pattern(/^pass\.[\w\.]+$/)
    .optional()
    .messages({
      'string.pattern.base': 'Pass type identifier must be in format: pass.domain.name'
    }),
  
  organizationName: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.empty': 'Organization name is required',
      'string.min': 'Organization name must be at least 2 characters long',
      'string.max': 'Organization name cannot exceed 100 characters'
    }),
  
  description: Joi.string()
    .max(500)
    .optional()
    .messages({
      'string.max': 'Description cannot exceed 500 characters'
    }),
  
  serialNumber: Joi.string()
    .optional()
    .messages({
      'string.base': 'Serial number must be a string'
    }),
  
  passType: Joi.string()
    .valid('storeCard', 'coupon', 'eventTicket', 'generic', 'boardingPass')
    .default('storeCard')
    .messages({
      'any.only': 'Pass type must be one of: storeCard, coupon, eventTicket, generic, boardingPass'
    }),
  
  backgroundColor: Joi.string()
    .pattern(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    .default('#1976D2')
    .messages({
      'string.pattern.base': 'Background color must be a valid hex color (e.g., #1976D2)'
    }),
  
  foregroundColor: Joi.string()
    .pattern(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    .default('#FFFFFF')
    .messages({
      'string.pattern.base': 'Foreground color must be a valid hex color (e.g., #FFFFFF)'
    }),
  
  fields: Joi.object({
    headerFields: Joi.array().items(Joi.object()).optional(),
    primaryFields: Joi.array().items(Joi.object()).optional(),
    secondaryFields: Joi.array().items(Joi.object()).optional(),
    auxiliaryFields: Joi.array().items(Joi.object()).optional(),
    backFields: Joi.array().items(Joi.object()).optional()
  }).optional(),
  
  barcodes: Joi.array().items(
    Joi.object({
      format: Joi.string().valid('PKBarcodeFormatQR', 'PKBarcodeFormatPDF417', 'PKBarcodeFormatAztec', 'PKBarcodeFormatCode128').required(),
      message: Joi.string().required(),
      messageEncoding: Joi.string().default('iso-8859-1')
    })
  ).optional(),
  
  logo: Joi.string()
    .optional()
    .messages({
      'string.base': 'Logo must be a valid file path'
    }),
  
  companyId: Joi.string()
    .uuid()
    .optional()
    .messages({
      'string.uuid': 'Company ID must be a valid UUID'
    }),
  
  loyaltyProgramId: Joi.string()
    .uuid()
    .optional()
    .messages({
      'string.uuid': 'Loyalty program ID must be a valid UUID'
    })
});

const validateWalletPass = (req, res, next) => {
  // Парсим данные из тела запроса
  let data;
  if (req.body.passData) {
    try {
      data = typeof req.body.passData === 'string' 
        ? JSON.parse(req.body.passData) 
        : req.body.passData;
    } catch (e) {
      return res.status(400).json({
        success: false,
        error: 'Invalid JSON in passData field'
      });
    }
  } else {
    data = req.body;
  }

  const { error } = walletPassSchema.validate(data, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    }));
    
    return res.status(400).json({
      success: false,
      error: 'Validation failed',
      details: errors
    });
  }
  
  // Сохраняем валидированные данные
  req.validatedPassData = data;
  next();
};

module.exports = {
  walletPassSchema,
  validateWalletPass
};