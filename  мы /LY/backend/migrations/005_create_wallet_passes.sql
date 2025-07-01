-- Create wallet_passes table
CREATE TABLE IF NOT EXISTS wallet_passes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pass_type_identifier VARCHAR(255) NOT NULL,
    organization_name VARCHAR(100) NOT NULL,
    description TEXT,
    serial_number VARCHAR(255) NOT NULL UNIQUE,
    pass_type VARCHAR(50) NOT NULL DEFAULT 'storeCard',
    background_color VARCHAR(7) DEFAULT '#1976D2',
    foreground_color VARCHAR(7) DEFAULT '#FFFFFF',
    fields JSONB DEFAULT '{}',
    barcodes JSONB DEFAULT '[]',
    logo VARCHAR(255),
    company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
    loyalty_program_id UUID REFERENCES loyalty_programs(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (pass_type IN ('storeCard', 'coupon', 'eventTicket', 'generic', 'boardingPass'))
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_wallet_passes_company_id ON wallet_passes(company_id);
CREATE INDEX IF NOT EXISTS idx_wallet_passes_loyalty_program_id ON wallet_passes(loyalty_program_id);
CREATE INDEX IF NOT EXISTS idx_wallet_passes_pass_type ON wallet_passes(pass_type);
CREATE UNIQUE INDEX IF NOT EXISTS idx_wallet_passes_serial_number ON wallet_passes(serial_number);

-- Create updated_at trigger
CREATE TRIGGER update_wallet_passes_updated_at BEFORE UPDATE ON wallet_passes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();