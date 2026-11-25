const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'rahasia_campus_blood_emergency_2026';

app.use(cors());
app.use(express.json());

// Middleware autentikasi JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token autentikasi tidak ditemukan' });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ message: 'Token tidak valid atau kadaluarsa' });
    }
    req.user = decoded; // { id_user, email_kampus }
    next();
  });
}

// Helper mengubah row tabel `pendonor` menjadi objek sesuai DonorProfile di Flutter
function mapPendonorRow(row) {
  if (!row) return null;
  return {
    id_pendonor: row.id_pendonor,
    user_id: row.user_id,
    nama_lengkap: row.nama_lengkap,
    nim_id_civitas: row.nim_id_civitas,
    no_telepon: row.no_telepon,
    fakultas_unit: row.fakultas_unit,
    golongan_darah: row.golongan_darah,
    bersedia_donor: Boolean(row.bersedia_donor),
  };
}

// ==========================================
// 1. REGISTER (Belum punya akun -> Daftar dulu)
// ==========================================
app.post('/api/register', async (req, res) => {
  const { email_kampus, password } = req.body;

  if (!email_kampus || !password) {
    return res.status(400).json({ message: 'Email kampus dan password wajib diisi' });
  }

  try {
    const [existing] = await db.query(
      'SELECT id_user FROM users WHERE email_kampus = ?',
      [email_kampus.trim()]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: 'Email kampus sudah terdaftar, silakan langsung masuk',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.query(
      'INSERT INTO users (email_kampus, password) VALUES (?, ?)',
      [email_kampus.trim(), hashedPassword]
    );

    const token = jwt.sign(
      { id_user: result.insertId, email_kampus: email_kampus.trim() },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'Registrasi berhasil, silakan lengkapi profil pendonor',
      token,
      hasProfile: false,
      profile: null,
    });
  } catch (err) {
    res.status(500).json({ message: 'Gagal mendaftarkan akun', error: err.message });
  }
});

// ==========================================
// 2. LOGIN (Sudah punya akun -> Langsung masuk)
// ==========================================
app.post('/api/login', async (req, res) => {
  const { email_kampus, password } = req.body;

  if (!email_kampus || !password) {
    return res.status(400).json({ message: 'Email kampus dan password wajib diisi' });
  }

  try {
    const [users] = await db.query(
      'SELECT id_user, email_kampus, password FROM users WHERE email_kampus = ?',
      [email_kampus.trim()]
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: 'Akun belum terdaftar, silakan daftar terlebih dahulu',
      });
    }

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Password salah' });
    }

    const [profiles] = await db.query(
      'SELECT * FROM pendonor WHERE user_id = ?',
      [user.id_user]
    );

    const token = jwt.sign(
      { id_user: user.id_user, email_kampus: user.email_kampus },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login berhasil',
      token,
      hasProfile: profiles.length > 0,
      profile: mapPendonorRow(profiles[0]),
    });
  } catch (err) {
    res.status(500).json({ message: 'Gagal login', error: err.message });
  }
});

// ==========================================
// 3. SIMPAN / UPDATE PROFIL PENDONOR
// ==========================================
app.post('/api/pendonor', authenticateToken, async (req, res) => {
  const userId = req.user.id_user;
  const {
    nama_lengkap,
    nim_id_civitas,
    no_telepon,
    fakultas_unit,
    golongan_darah,
    bersedia_donor,
  } = req.body;

  if (!nama_lengkap || !nim_id_civitas || !no_telepon || !fakultas_unit) {
    return res.status(400).json({ message: 'Semua field identitas wajib diisi' });
  }

  const allowedBlood = ['A', 'B', 'AB', 'O', 'Belum Tahu'];
  const bloodType = allowedBlood.includes(golongan_darah) ? golongan_darah : 'Belum Tahu';
  const willingFlag = bersedia_donor === false || bersedia_donor === 0 ? 0 : 1;

  try {
    // Cek duplikasi NIM / ID Civitas pada user lain
    const [nimUsed] = await db.query(
      'SELECT id_pendonor FROM pendonor WHERE nim_id_civitas = ? AND user_id != ?',
      [nim_id_civitas.trim(), userId]
    );

    if (nimUsed.length > 0) {
      return res.status(409).json({ message: 'NIM / ID Civitas sudah digunakan akun lain' });
    }

    const [existing] = await db.query(
      'SELECT id_pendonor FROM pendonor WHERE user_id = ?',
      [userId]
    );

    if (existing.length > 0) {
      await db.query(
        `UPDATE pendonor
         SET nama_lengkap = ?, nim_id_civitas = ?, no_telepon = ?, fakultas_unit = ?, golongan_darah = ?, bersedia_donor = ?
         WHERE user_id = ?`,
        [
          nama_lengkap.trim(),
          nim_id_civitas.trim(),
          no_telepon.trim(),
          fakultas_unit.trim(),
          bloodType,
          willingFlag,
          userId,
        ]
      );
    } else {
      await db.query(
        `INSERT INTO pendonor
         (user_id, nama_lengkap, nim_id_civitas, no_telepon, fakultas_unit, golongan_darah, bersedia_donor)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          nama_lengkap.trim(),
          nim_id_civitas.trim(),
          no_telepon.trim(),
          fakultas_unit.trim(),
          bloodType,
          willingFlag,
        ]
      );
    }

    const [rows] = await db.query('SELECT * FROM pendonor WHERE user_id = ?', [userId]);

    res.json({
      message: 'Profil pendonor berhasil disimpan',
      profile: mapPendonorRow(rows[0]),
    });
  } catch (err) {
    res.status(500).json({ message: 'Gagal menyimpan profil pendonor', error: err.message });
  }
});

// ==========================================
// 4. AMBIL DATA BERANDA
// ==========================================
app.get('/api/beranda', authenticateToken, async (req, res) => {
  const userId = req.user.id_user;

  try {
    const [rows] = await db.query(
      'SELECT * FROM pendonor WHERE user_id = ?',
      [userId]
    );

    res.json({
      message: 'Data beranda berhasil dimuat',
      profile: mapPendonorRow(rows[0]),
    });
  } catch (err) {
    res.status(500).json({ message: 'Gagal memuat data beranda', error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});