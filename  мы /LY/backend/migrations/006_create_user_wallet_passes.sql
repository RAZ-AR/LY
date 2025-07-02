-- Create user_wallet_passes junction table for pass assignments
CREATE TABLE IF NOT EXISTS user_wallet_passes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_pass_id UUID NOT NULL REFERENCES wallet_passes(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMP WITH TIME ZONE,
    usage_count INTEGER DEFAULT 0,
    UNIQUE(user_id, wallet_pass_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_wallet_passes_user_id ON user_wallet_passes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_wallet_passes_wallet_pass_id ON user_wallet_passes(wallet_pass_id);
CREATE INDEX IF NOT EXISTS idx_user_wallet_passes_assigned_at ON user_wallet_passes(assigned_at);
CREATE INDEX IF NOT EXISTS idx_user_wallet_passes_active ON user_wallet_passes(is_active);

-- Add some helpful comments
COMMENT ON TABLE user_wallet_passes IS 'Links users to their assigned wallet passes';
COMMENT ON COLUMN user_wallet_passes.usage_count IS 'Number of times the pass has been used/scanned';
COMMENT ON COLUMN user_wallet_passes.is_active IS 'Whether the pass assignment is currently active';
COMMENT ON COLUMN user_wallet_passes.last_used_at IS 'Last time the pass was scanned/used';