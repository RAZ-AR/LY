const db = require('../config/database');

class Company {
  static tableName = 'companies';

  static async findAll() {
    return await db(this.tableName)
      .select('*')
      .orderBy('created_at', 'desc');
  }

  static async findById(id) {
    return await db(this.tableName)
      .where('id', id)
      .first();
  }

  static async create(companyData) {
    const [company] = await db(this.tableName)
      .insert({
        name: companyData.name,
        admin_email: companyData.adminEmail,
        logo: companyData.logo,
        created_at: new Date(),
        updated_at: new Date()
      })
      .returning('*');
    
    return company;
  }

  static async update(id, companyData) {
    const [company] = await db(this.tableName)
      .where('id', id)
      .update({
        name: companyData.name,
        admin_email: companyData.adminEmail,
        logo: companyData.logo,
        updated_at: new Date()
      })
      .returning('*');
    
    return company;
  }

  static async delete(id) {
    return await db(this.tableName)
      .where('id', id)
      .del();
  }

  static async findWithLoyaltyPrograms(id) {
    const company = await this.findById(id);
    if (!company) return null;

    const loyaltyPrograms = await db('loyalty_programs')
      .where('company_id', id)
      .select('*');

    // Получаем пассы для компании
    const walletPasses = await db('wallet_passes')
      .where('company_id', id)
      .select('*');

    return {
      ...company,
      loyaltyPrograms,
      walletPasses,
      stats: {
        totalLoyaltyPrograms: loyaltyPrograms.length,
        totalWalletPasses: walletPasses.length
      }
    };
  }

  static async getStats(id) {
    const company = await this.findById(id);
    if (!company) return null;

    const loyaltyProgramsCount = await db('loyalty_programs')
      .where('company_id', id)
      .count('id as count')
      .first();

    const walletPassesCount = await db('wallet_passes')
      .where('company_id', id)
      .count('id as count')
      .first();

    const usersCount = await db('users')
      .join('loyalty_program_users', 'users.id', 'loyalty_program_users.user_id')
      .join('loyalty_programs', 'loyalty_program_users.loyalty_program_id', 'loyalty_programs.id')
      .where('loyalty_programs.company_id', id)
      .countDistinct('users.id as count')
      .first();

    return {
      loyaltyPrograms: parseInt(loyaltyProgramsCount.count),
      walletPasses: parseInt(walletPassesCount.count),
      users: parseInt(usersCount.count)
    };
  }
}

module.exports = Company;