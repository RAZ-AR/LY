const db = require('../config/database');

class User {
  static tableName = 'users';

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

  static async findByEmailOrPhone(email, phone) {
    let query = db(this.tableName);
    
    if (email && phone) {
      query = query.where('email', email).orWhere('phone', phone);
    } else if (email) {
      query = query.where('email', email);
    } else if (phone) {
      query = query.where('phone', phone);
    }
    
    return await query.first();
  }

  static async create(userData) {
    const [user] = await db(this.tableName)
      .insert({
        name: userData.name,
        email: userData.email,
        phone: userData.phone,
        birthday: userData.birthday,
        points: userData.points || 0,
        wallet_pass_url: userData.walletPassUrl,
        created_at: new Date(),
        updated_at: new Date()
      })
      .returning('*');
    
    return user;
  }

  static async update(id, userData) {
    const [user] = await db(this.tableName)
      .where('id', id)
      .update({
        name: userData.name,
        email: userData.email,
        phone: userData.phone,
        birthday: userData.birthday,
        points: userData.points,
        wallet_pass_url: userData.walletPassUrl,
        updated_at: new Date()
      })
      .returning('*');
    
    return user;
  }

  static async addPoints(id, points) {
    const [user] = await db(this.tableName)
      .where('id', id)
      .increment('points', points)
      .returning('*');
    
    return user;
  }

  static async redeemPoints(id, points) {
    const user = await this.findById(id);
    if (!user || user.points < points) {
      throw new Error('Insufficient points');
    }

    const [updatedUser] = await db(this.tableName)
      .where('id', id)
      .decrement('points', points)
      .returning('*');
    
    return updatedUser;
  }

  static async delete(id) {
    return await db(this.tableName)
      .where('id', id)
      .del();
  }

  static async findByLoyaltyProgram(loyaltyProgramId) {
    return await db(this.tableName)
      .join('loyalty_program_users', 'users.id', 'loyalty_program_users.user_id')
      .where('loyalty_program_users.loyalty_program_id', loyaltyProgramId)
      .select('users.*')
      .orderBy('users.created_at', 'desc');
  }

  static async addToLoyaltyProgram(userId, loyaltyProgramId) {
    return await db('loyalty_program_users')
      .insert({
        user_id: userId,
        loyalty_program_id: loyaltyProgramId,
        joined_at: new Date()
      });
  }
}

module.exports = User;