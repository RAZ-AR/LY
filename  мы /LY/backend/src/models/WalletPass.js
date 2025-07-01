const db = require('../config/database');

class WalletPass {
  static tableName = 'wallet_passes';

  static async findAll(filters = {}) {
    let query = db(this.tableName)
      .leftJoin('companies', 'wallet_passes.company_id', 'companies.id')
      .leftJoin('loyalty_programs', 'wallet_passes.loyalty_program_id', 'loyalty_programs.id')
      .select(
        'wallet_passes.*',
        'companies.name as company_name',
        'loyalty_programs.name as loyalty_program_name'
      )
      .orderBy('wallet_passes.created_at', 'desc');

    // Применяем фильтры
    if (filters.companyId) {
      query = query.where('wallet_passes.company_id', filters.companyId);
    }
    
    if (filters.loyaltyProgramId) {
      query = query.where('wallet_passes.loyalty_program_id', filters.loyaltyProgramId);
    }
    
    if (filters.passType) {
      query = query.where('wallet_passes.pass_type', filters.passType);
    }

    return await query;
  }

  static async findById(id) {
    return await db(this.tableName)
      .leftJoin('companies', 'wallet_passes.company_id', 'companies.id')
      .leftJoin('loyalty_programs', 'wallet_passes.loyalty_program_id', 'loyalty_programs.id')
      .where('wallet_passes.id', id)
      .select(
        'wallet_passes.*',
        'companies.name as company_name',
        'loyalty_programs.name as loyalty_program_name'
      )
      .first();
  }

  static async findBySerialNumber(serialNumber) {
    return await db(this.tableName)
      .where('serial_number', serialNumber)
      .first();
  }

  static async create(passData) {
    // Генерируем уникальный serial number если не предоставлен
    if (!passData.serialNumber) {
      passData.serialNumber = `LY-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    }

    const [pass] = await db(this.tableName)
      .insert({
        pass_type_identifier: passData.passTypeIdentifier,
        organization_name: passData.organizationName,
        description: passData.description,
        serial_number: passData.serialNumber,
        pass_type: passData.passType || 'storeCard',
        background_color: passData.backgroundColor || '#1976D2',
        foreground_color: passData.foregroundColor || '#FFFFFF',
        fields: JSON.stringify(passData.fields || {}),
        barcodes: JSON.stringify(passData.barcodes || []),
        logo: passData.logo,
        company_id: passData.companyId,
        loyalty_program_id: passData.loyaltyProgramId,
        created_at: new Date(),
        updated_at: new Date()
      })
      .returning('*');
    
    // Возвращаем пасс с дополнительной информацией
    return await this.findById(pass.id);
  }

  static async update(id, passData) {
    const updateData = {
      updated_at: new Date()
    };

    if (passData.organizationName) updateData.organization_name = passData.organizationName;
    if (passData.description) updateData.description = passData.description;
    if (passData.passType) updateData.pass_type = passData.passType;
    if (passData.backgroundColor) updateData.background_color = passData.backgroundColor;
    if (passData.foregroundColor) updateData.foreground_color = passData.foregroundColor;
    if (passData.fields) updateData.fields = JSON.stringify(passData.fields);
    if (passData.barcodes) updateData.barcodes = JSON.stringify(passData.barcodes);
    if (passData.logo) updateData.logo = passData.logo;
    if (passData.companyId) updateData.company_id = passData.companyId;
    if (passData.loyaltyProgramId) updateData.loyalty_program_id = passData.loyaltyProgramId;

    await db(this.tableName)
      .where('id', id)
      .update(updateData);
    
    return await this.findById(id);
  }

  static async delete(id) {
    return await db(this.tableName)
      .where('id', id)
      .del();
  }

  static async findByCompanyId(companyId) {
    return await this.findAll({ companyId });
  }

  static async findByLoyaltyProgramId(loyaltyProgramId) {
    return await this.findAll({ loyaltyProgramId });
  }

  static async getStats() {
    const totalPasses = await db(this.tableName).count('id as count').first();
    
    const passByType = await db(this.tableName)
      .select('pass_type')
      .count('id as count')
      .groupBy('pass_type');
    
    const recentPasses = await db(this.tableName)
      .where('created_at', '>=', db.raw("NOW() - INTERVAL '30 days'"))
      .count('id as count')
      .first();

    return {
      total: parseInt(totalPasses.count),
      byType: passByType.reduce((acc, item) => {
        acc[item.pass_type] = parseInt(item.count);
        return acc;
      }, {}),
      recentCount: parseInt(recentPasses.count)
    };
  }

  // Метод для связи пасса с пользователем
  static async assignToUser(passId, userId) {
    // Проверяем существование пасса и пользователя
    const pass = await this.findById(passId);
    const User = require('./User');
    const user = await User.findById(userId);
    
    if (!pass || !user) {
      throw new Error('Pass or user not found');
    }

    // Создаем связь через таблицу user_wallet_passes
    await db('user_wallet_passes').insert({
      user_id: userId,
      wallet_pass_id: passId,
      assigned_at: new Date()
    });

    return { pass, user };
  }

  // Получить пассы пользователя
  static async findByUserId(userId) {
    return await db(this.tableName)
      .join('user_wallet_passes', 'wallet_passes.id', 'user_wallet_passes.wallet_pass_id')
      .leftJoin('companies', 'wallet_passes.company_id', 'companies.id')
      .leftJoin('loyalty_programs', 'wallet_passes.loyalty_program_id', 'loyalty_programs.id')
      .where('user_wallet_passes.user_id', userId)
      .select(
        'wallet_passes.*',
        'companies.name as company_name',
        'loyalty_programs.name as loyalty_program_name',
        'user_wallet_passes.assigned_at'
      )
      .orderBy('user_wallet_passes.assigned_at', 'desc');
  }
}

module.exports = WalletPass;