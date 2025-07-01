-- Create loyalty_programs table
CREATE TABLE IF NOT EXISTS loyalty_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    template VARCHAR(50) NOT NULL,
    invite_link TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_loyalty_programs_company_id ON loyalty_programs(company_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_programs_template ON loyalty_programs(template);

-- Create updated_at trigger
CREATE TRIGGER update_loyalty_programs_updated_at BEFORE UPDATE ON loyalty_programs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();