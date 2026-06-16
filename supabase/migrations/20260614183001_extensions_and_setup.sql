-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- untuk full-text search catatan

-- Timezone default
SET timezone = 'Asia/Jakarta';
