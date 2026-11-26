# 🩸 Campus Blood Emergency
Campus Blood Emergency merupakan proyek pengembangan aplikasi berbasis teknologi informasi yang dirancang untuk membantu pengelolaan informasi donor darah di lingkungan kampus.

Project ini dikembangkan sebagai bagian dari tugas mata kuliah Rekayasa Perangkat Lunak (RPL) Semester 3.

---

## 📌 About Project
Campus Blood Emergency merupakan aplikasi yang dikembangkan untuk mendukung penyampaian informasi dan pengelolaan kegiatan donor darah di lingkungan kampus.

Pengembangan aplikasi ini melibatkan sembilan anggota tim dengan pembagian tugas pada bagian UI/UX Design, Frontend Development, Backend Development, dan Database Management.

Project ini dikembangkan secara kolaboratif menggunakan GitHub sebagai media penyimpanan kode dan pengelolaan versi project.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 Login | Login pengguna ke dalam aplikasi. |
| 📝 Registrasi | Pembuatan akun pengguna baru. |
| 🏠 Dashboard | Ringkasan informasi aplikasi. |
| 🩸 Donor Darah | Informasi dan pendaftaran donor darah. |
| 👤 Data Pendonor | Pengelolaan data pendonor. |
| 🚨 Blood Request | Informasi permintaan kebutuhan darah. |
| 🆘 SOS | Akses bantuan dalam kondisi darurat. |
| 🩹 Pertolongan Pertama | Panduan dasar penanganan kondisi darurat. |

---

## 🛠️ Tech Stack

| Technology | Description |
|---|---|
| 📱 Flutter | Framework pengembangan aplikasi. |
| 🎯 Dart | Bahasa pemrograman aplikasi. |
| 🗄️ MySQL | Database aplikasi. |
| 🐙 GitHub | Penyimpanan kode dan kolaborasi tim. |
| 💻 Visual Studio Code | Code editor pengembangan aplikasi. |

---

## 📁 Project Structure

```text
campus-blood-emergency/
│
├── backend/          # Backend application
├── frontend/         # Frontend application
├── database/         # Database files (SQL)
├── assets/           # Images, logos, and UI/UX designs
├── docs/             # Project documentation
├── config/           # Application configuration
├── tests/            # Application testing
├── uploads/          # Uploaded files
│
├── README.md         # Project documentation
├── .gitignore        # Git ignore configuration
└── LICENSE           # Project license

```

## 🚀 Cara Instalasi dan Menjalankan

### install 
- [Node.js](https://nodejs.org) versi LTS
- MySQL 8 (XAMPP/Laragon) dan phpMyAdmin

### 1. Dapatkan kode
**Download ZIP**
1. Buka halaman repositori ini di GitHub.
2. Klik tombol hijau **Code**, lalu pilih **Download ZIP**.
3. Ekstrak file ZIP-nya (nama folder hasil ekstrak: `campus-blood-emergency-main`).

### 2. Siapkan database
1. Nyalakan MySQL, lalu buka phpMyAdmin.
2. Buat database baru bernama `campus_blood_emergency`.
3. Pilih database tersebut, buka tab **Import**, lalu pilih file `database/campus_blood_emergency.sql`.

### 3. Atur koneksi database
Buka `backend/server.js`, lalu sesuaikan bagian `createPool` dengan user dan password MySQL Anda.
Bawaannya: user `root` dan password kosong.

### 4. Jalankan server
Buka terminal di folder `backend` (di Windows, gunakan **Command Prompt**
agar tidak terblokir PowerShell), lalu jalankan:
```bash
npm install
npm start
```
Jika muncul `Server Campus Blood Emergency berjalan di http://localhost:3000`, server sudah aktif.

### 5. Buka aplikasi
Buka **http://localhost:3000** di browser (jangan klik dua kali `index.html`).

### Alur pemakaian
1. Klik **Daftar di sini**, isi email kampus dan password (minimal 6 karakter).
2. Lengkapi profil pendonor.
3. Anda masuk ke Beranda. Lain kali cukup **Masuk** dengan akun yang sama.

### Masalah umum
| Gejala | Solusi |
|---|---|
| `npm is not recognized` | Pasang Node.js, lalu buka ulang terminal/VS Code. |
| `running scripts is disabled` (PowerShell) | Gunakan Command Prompt, atau jalankan `npm.cmd install`. |
| `ECONNREFUSED` / `Access denied` | MySQL belum menyala, atau user/password di `server.js` salah. |
| `Unknown database` | Database `campus_blood_emergency` belum dibuat. |
| `EADDRINUSE: port 3000` | Port dipakai program lain, tutup program itu dulu. |
