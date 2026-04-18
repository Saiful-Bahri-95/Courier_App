# 📦 Courier App

Aplikasi manajemen pengiriman dokumen berbasis Flutter, terhubung ke backend Node.js dengan MongoDB Atlas. Dirancang untuk mengelola tanda terima pengiriman dokumen secara digital.

---

## ✨ Fitur Utama

- **Autentikasi** — Register, Login, Logout dengan JWT Token
- **Verifikasi Email OTP** — Validasi email saat register & reset password via Resend
- **Forgot Password** — Reset password menggunakan kode OTP
- **Manajemen Dokumen** — Buat, lihat, dan hapus data pengiriman dokumen
- **Tanda Tangan Digital** — Capture tanda tangan penerima langsung di app
- **Bukti Foto** — Upload foto bukti penerimaan via Cloudinary
- **Share PDF** — Generate & share Tanda Terima/Receipt dalam format PDF ke WhatsApp atau aplikasi lain
- **Update Profil** — Edit nama dan avatar pengguna

---

## 🛠️ Tech Stack

### Frontend (Flutter)
| Package | Versi | Kegunaan |
|---|---|---|
| `flutter_riverpod` | ^3.2.0 | State management |
| `flutter_secure_storage` | ^9.0.0 | Simpan token JWT |
| `http` | ^1.5.0 | HTTP request ke API |
| `image_picker` | ^1.0.7 | Pick foto dari galeri/kamera |
| `signature` | ^5.4.0 | Capture tanda tangan digital |
| `pdf` | ^3.10.8 | Generate PDF |
| `share_plus` | ^9.0.0 | Share file ke WhatsApp dll |
| `path_provider` | ^2.1.2 | Akses direktori temp |
| `cloudinary_public` | ^0.23.1 | Upload gambar ke Cloudinary |
| `google_fonts` | ^6.3.2 | Custom fonts |
| `intl` | ^0.19.0 | Format tanggal & waktu |
| `convex_bottom_bar` | ^3.2.0 | Bottom navigation bar |

### Backend (Node.js)
| Package | Kegunaan |
|---|---|
| `express` | Web framework |
| `mongoose` | ODM untuk MongoDB |
| `bcryptjs` | Hashing password |
| `jsonwebtoken` | JWT authentication |
| `resend` | Kirim email OTP |
| `multer` | Handle file upload |
| `cloudinary` | Upload gambar ke cloud |
| `cors` | Cross-Origin Resource Sharing |
| `dotenv` | Environment variables |

---

## 🏗️ Struktur Project

```
lib/
├── config/
│   └── globar_variable.dart        # Base URL API
├── controllers/
│   └── auth_controller.dart        # Logic autentikasi & OTP
├── models/
│   ├── document_data.dart          # Model data dokumen
│   ├── document_detail_model.dart  # Model detail dokumen
│   ├── document_list_model.dart    # Model list dokumen
│   └── user.dart                   # Model user
├── provider/
│   ├── auth_check_provider.dart    # Provider cek status login
│   └── user_provider.dart          # Provider data user global
├── services/
│   ├── auth_secure_storage.dart    # Simpan/ambil token & user
│   ├── cloudinary_service.dart     # Upload gambar ke Cloudinary
│   ├── document_service.dart       # CRUD dokumen
│   ├── manage_http_response.dart   # Handler response HTTP
│   └── pdf_service.dart            # Generate & share PDF
└── views/
    └── screens/
        ├── authentication_screens/
        │   ├── login_screen.dart
        │   ├── register_screen.dart
        │   ├── register_otp_screen.dart
        │   ├── forgot_password_screen.dart
        │   ├── otp_screen.dart
        │   └── reset_password_screen.dart
        └── nav_screens/
            └── widgets/
                └── send_form/      # Form input pengiriman dokumen
```

---

## ⚙️ Setup & Instalasi

### 1. Clone Repository
```bash
git clone https://github.com/username/courier_app.git
cd courier_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Konfigurasi Base URL

Buka `lib/config/globar_variable.dart` dan sesuaikan URL backend:
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend-url.railway.app';
}
```

### 4. Pastikan Assets Tersedia
```
assets/
├── fonts/
│   ├── NotoSans-Regular.ttf
│   └── NotoSans-Bold.ttf
├── icons/
│   ├── email.png
│   ├── password.png
│   ├── user.jpeg
│   ├── Office.png
│   └── penerima.png
└── images/
    └── banner2.png
```

### 5. Jalankan Aplikasi
```bash
flutter run
```

---

## 🔐 Alur Autentikasi

```
Register → Kirim OTP ke Email → Verifikasi OTP → Akun Dibuat → Login
                    ↓
         Forgot Password → Kirim OTP → Verifikasi OTP → Reset Password
```

---

## 📄 Fitur PDF Tanda Terima

PDF yang digenerate berisi:
- Header perusahaan (PT KGI Sekuritas Indonesia)
- Detail pengirim & penerima
- Jenis dokumen (Document / Invoice / BG Cheque / Cash / Others)
- Perihal / deskripsi
- Tanda tangan digital penerima
- Footer dengan timestamp

---

## 🌐 Backend

Repository backend: `https://github.com/username/backend_courier_app`

Production URL: `https://backendcourierapp.up.railway.app`

Health check: `https://backendcourierapp.up.railway.app/health`

### API Endpoints

| Method | Endpoint | Deskripsi |
|---|---|---|
| POST | `/api/signup` | Register user |
| POST | `/api/signin` | Login user |
| POST | `/api/send-register-otp` | Kirim OTP registrasi |
| POST | `/api/verify-register-otp` | Verifikasi OTP & buat akun |
| POST | `/api/forgot-password` | Kirim OTP reset password |
| POST | `/api/reset-password` | Reset password dengan OTP |
| PATCH | `/api/user/profile` | Update profil user |
| POST | `/api/upload/avatar` | Upload foto profil |
| POST | `/api/upload/document` | Upload foto dokumen |

---

## 📧 Email Service

- Provider: **Resend**
- Domain: `saifulbahri-ai.online`
- Free tier: 3.000 email/bulan

---

## ☁️ Cloud Services

| Service | Kegunaan |
|---|---|
| MongoDB Atlas | Database cloud |
| Railway | Deploy backend |
| Cloudinary | Storage gambar |
| Resend | Email OTP |

---

## 👨‍💻 Developer

Developed by **Saiful Bahri**
