-- Create loyalty_program_users junction table
CREATE TABLE IF NOT EXISTS loyalty_program_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_program_id UUID NOT NULL REFERENCES loyalty_programs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(loyalty_program_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_loyalty_program_users_program_id ON loyalty_program_users(loyalty_program_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_program_users_user_id ON loyalty_program_users(user_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_program_users_joined_at ON loyalty_program_users(joined_at);