-- Create locations table if it doesn't exist
CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO locations (name, address, latitude, longitude) VALUES
    ('Central Park', 'New York, NY 10024, USA', 40.7828647, -73.9653551),
    ('Eiffel Tower', 'Champ de Mars, 5 Avenue Anatole France, 75007 Paris, France', 48.8583701, 2.2922926),
    ('Sydney Opera House', 'Bennelong Point, Sydney NSW 2000, Australia', -33.8567844, 151.2152967),
    ('Taj Mahal', 'Dharmapuri, Forest Colony, Tajganj, Agra, Uttar Pradesh 282001, India', 27.1751448, 78.0399535),
    ('Statue of Liberty', 'New York, NY 10004, USA', 40.6892494, -74.0445004)
ON CONFLICT DO NOTHING; 