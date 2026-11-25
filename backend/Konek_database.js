const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '', // isi jika MySQL / Laragon kamu menggunakan password
  database: 'campus_blood_emergency',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;