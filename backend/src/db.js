import 'dotenv/config';
import sql from 'mssql';

const options = {
  encrypt: (process.env.DB_OPTIONS_ENCRYPT || 'false').toLowerCase() === 'true',
  trustServerCertificate: true
};

// Optional: named instance (e.g., SQLEXPRESS)
if (process.env.DB_INSTANCE_NAME) {
  options.instanceName = process.env.DB_INSTANCE_NAME;
}

// Optional: explicit port (default 1433)
if (process.env.DB_PORT) {
  options.port = parseInt(process.env.DB_PORT, 10);
}

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: (process.env.DB_SERVER ?? '').trim() || 'localhost',
  database: process.env.DB_DATABASE,
  options,
  pool: { max: 10, min: 1, idleTimeoutMillis: 30000 }
};

let poolPromise;
export const getPool = async () => {
  if (!poolPromise) poolPromise = sql.connect(config);
  return poolPromise;
};

export { sql };