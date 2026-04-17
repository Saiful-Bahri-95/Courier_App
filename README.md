# 📦 Courier App - Sistem Manajemen Dokumen & Autentikasi

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State--Management-Riverpod-blue?style=for-the-badge)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Aplikasi mobile berbasis Flutter yang dirancang untuk menyederhanakan proses pengiriman, penerimaan, dan pengarsipan dokumen secara digital. Aplikasi ini dilengkapi dengan sistem keamanan JWT, manajemen profil pengguna, dan pelacakan status dokumen secara real-time.

## ✨ Fitur Utama

-   **🔐 Autentikasi Aman**: Login dan registrasi menggunakan JWT (JSON Web Token) dengan penyimpanan token yang aman melalui `Flutter Secure Storage`.
-   **📄 Manajemen Dokumen**:
    -   Daftar riwayat dokumen (dikirim/diterima).
    -   Detail lengkap dokumen termasuk informasi pengirim, penerima, dan jenis dokumen.
    -   Fitur penghapusan dokumen (Delete) yang terintegrasi dengan API.
-   **📸 Bukti Digital**: Mendukung integrasi gambar penerima (receiver image) dan tanda tangan digital sebagai bukti sah penerimaan.
-   **👤 Manajemen Profil**: Pengguna dapat memperbarui nama lengkap dan foto profil (avatar) secara langsung.
-   **🛠️ Manajemen State**: Menggunakan **Riverpod** untuk memastikan aliran data yang reaktif, bersih, dan mudah dikelola.

## 🚀 Teknologi yang Digunakan

-   **Frontend**: [Flutter](https://flutter.dev)
-   **Manajemen State**: [Riverpod](https://riverpod.dev)
-   **Networking**: [HTTP](https://pub.dev/packages/http) (REST API)
-   **Penyimpanan Lokal**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
-   **Arsitektur**: Model-View-Controller (MVC) yang dioptimalkan.

## 📂 Struktur File Penting

| Nama File | Deskripsi |
| :--- | :--- |
| `auth_controller.dart` | Mengelola logika bisnis untuk login, logout, dan pembaruan profil. |
| `document_service.dart` | Berkomunikasi dengan API untuk operasi CRUD dokumen (List, Detail, Submit, Delete). |
| `user_provider.dart` | Mengelola data pengguna (global state) menggunakan StateNotifier. |
| `document_data.dart` | Model data utama untuk penampung input pengiriman dokumen. |
| `manage_http_response.dart` | Utiliti terpusat untuk menangani respons HTTP dan menampilkan pesan error/sukses. |

## 🛠️ Cara Instalasi

1.  **Clone Repositori**
    ```bash
    git clone [https://github.com/Saiful-Bahri-95/store_app.git](https://github.com/Saiful-Bahri-95/store_app.git)
    cd store_app
    ```

2.  **Instal Dependensi**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi API**
    Pastikan `baseUrl` pada file `lib/config/global_variable.dart` sudah mengarah ke server backend Anda:
    ```dart
    class ApiConfig {
      static const String baseUrl = '[http://alamat-api-anda.com](http://alamat-api-anda.com)';
    }
    ```

4.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

## 📋 Contoh Penggunaan

### Mengambil Detail Dokumen
```dart
// Mengambil detail berdasarkan ID dokumen
final detail = await DocumentService.getDocumentDetail(documentId);

## 🤝 Kontribusi
Kontribusi selalu terbuka! Jika Anda menemukan bug atau ingin menambahkan fitur baru:

1. Fork repositori ini.

2. Buat branch fitur baru (git checkout -b fitur/FiturHebat).

3. Commit perubahan Anda (git commit -m 'Menambah FiturHebat').

4. Push ke branch tersebut (git push origin fitur/FiturHebat).

5. Buat Pull Request.

📄 Lisensi
Proyek ini berada di bawah Lisensi MIT. Lihat file LICENSE untuk informasi lebih lanjut.

Dibuat dengan ❤️ oleh Saiful Bahri