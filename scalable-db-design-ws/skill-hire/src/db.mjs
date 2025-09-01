import pg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const DB_URL = process.env.DATABASE_URL;
if (!DB_URL) {
	throw new Error('DATABASE_URL is not set');
}

export const dbClient = new pg.Pool({
	connectionString: DB_URL,
	max: 10,
	idleTimeoutMillis: 30000,
	connectionTimeoutMillis: 2000,
});
