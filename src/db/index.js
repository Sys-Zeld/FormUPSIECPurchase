const { Pool } = require("pg");
const env = require("../config/env");

const pool = new Pool({
  connectionString: env.database.url,
  ssl: env.database.ssl ? { rejectUnauthorized: false } : false
});

module.exports = pool;
