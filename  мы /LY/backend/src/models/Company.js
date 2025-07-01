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

    return {
      ...company,
      loyaltyPrograms
    };
  }
}

module.exports = Company;