const db = require('../config/database');

class LoyaltyProgram {
  static tableName = 'loyalty_programs';

  static async findAll() {
    return await db(this.tableName)
      .join('companies', 'loyalty_programs.company_id', 'companies.id')
      .select(
        'loyalty_programs.*',
        'companies.name as company_name'
      )
      .orderBy('loyalty_programs.created_at', 'desc');
  }

  static async findById(id) {
    return await db(this.tableName)
      .join('companies', 'loyalty_programs.company_id', 'companies.id')
      .where('loyalty_programs.id', id)
      .select(
        'loyalty_programs.*',
        'companies.name as company_name'
      )
      .first();
  }

  static async findByCompanyId(companyId) {
    return await db(this.tableName)
      .where('company_id', companyId)
      .select('*')
      .orderBy('created_at', 'desc');
  }

  static async create(programData) {
    const [program] = await db(this.tableName)
      .insert({
        company_id: programData.companyId,
        name: programData.name,
        template: programData.template,
        invite_link: programData.inviteLink,
        created_at: new Date(),
        updated_at: new Date()
      })
      .returning('*');
    
    return program;
  }

  static async update(id, programData) {
    const [program] = await db(this.tableName)
      .where('id', id)
      .update({
        name: programData.name,
        template: programData.template,
        invite_link: programData.inviteLink,
        updated_at: new Date()
      })
      .returning('*');
    
    return program;
  }

  static async delete(id) {
    return await db(this.tableName)
      .where('id', id)
      .del();
  }

  static async getUsersCount(id) {
    const result = await db('users')
      .join('loyalty_program_users', 'users.id', 'loyalty_program_users.user_id')
      .where('loyalty_program_users.loyalty_program_id', id)
      .count('users.id as count')
      .first();
    
    return parseInt(result.count);
  }
}

module.exports = LoyaltyProgram;