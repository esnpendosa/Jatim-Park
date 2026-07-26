# 🌿 Baloga AR Rescue: Penjaga Ekosistem Baloga (Jatim Park)

![Baloga AR Rescue](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Laravel](https://img.shields.io/badge/Backend-Laravel%2013-red)
![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.44-blue)
![Database](https://img.shields.io/badge/Database-MySQL-orange)
![License](https://img.shields.io/badge/License-MIT-green)

**Baloga AR Rescue** adalah platform game edukasi berbasis lokasi (GPS) dan Augmented Reality / 2D Game Engine yang dirancang untuk kawasan Batu Love Garden (Baloga) - Jatim Park Group. Aplikasi ini mengajak pengunjung (Ranger) untuk menjelajahi area Baloga, menyelamatkan spesies hewan & tumbuhan langka Indonesia yang terancam punah, mempelajari informasi ekologi, menyelesaikan misi harian/mingguan, serta mengumpulkan poin dan badge penghargaan.

---

## 🌐 Production Domain & Server

- **API Base URL**: `https://balago.rozitech.co.id/api`
- **Supported Protocols**: Dual Support HTTP (`http://`) & HTTPS (`https://`)
- **Admin Panel URL**: `https://balago.rozitech.co.id/admin/login` (atau `http://127.0.0.1:8000/admin/login`)
  - **Email Admin**: `admin@baloga.com`
  - **Password**: `admin123`

---

## 📲 CARA BUILD APK ANDROID (RELEASE & DEBUG)

Berikut adalah panduan lengkap cara melakukan *build* file APK Android untuk aplikasi **Baloga AR Rescue**:

### 📋 Prasyarat (Prerequisites)
1. **Flutter SDK**: Versi `^3.12.0` / Flutter 3.44+ sudah ter-install dan terhubung ke Environment Variables (`PATH`).
2. **Android SDK / Android Studio**: Android SDK Build-Tools & Java JDK (JDK 17+ disarankan).

---

### 🚀 LANGKAH-LANGKAH BUILD APK RELEASE

#### Langkah 1: Masuk ke Direktori Project Flutter
Buka terminal / Command Prompt (PowerShell) dan masuk ke direktori aplikasi Flutter:
```bash
cd "c:\laragon\www\Jatim Park\baloga_ar_rescue"
```

#### Langkah 2: Download & Update Dependencies
Pastikan seluruh package dependensi Flutter terunduh dengan sempurna:
```bash
flutter pub get
```

#### Langkah 3: Konfigurasi Environment API Target
Buka file `c:\laragon\www\Jatim Park\baloga_ar_rescue\.env` dan pastikan URL API sudah sesuai:
```env
API_BASE_URL=https://balago.rozitech.co.id/api
```
*(Catatan: `ApiClient` sudah memiliki fitur **Automatic Dual Fallback**. Jika domain production unreachable saat testing lokal, aplikasi akan otomatis menggunakan fallback `http://10.0.2.2:8000/api` di emulator atau `http://127.0.0.1:8000/api` di desktop/web).*

#### Langkah 4: Jalankan Perintah Build APK Release
Eksekusi perintah berikut untuk memicu kompilasi Gradle ke bentuk APK Production:

```bash
flutter build apk --release
```

Jika Anda ingin menghasilkan APK berukuran lebih kecil per arsitektur prosesor (ARM64 / ARMv7), gunakan perintah:
```bash
flutter build apk --split-per-abi
```

#### 📍 Lokasi Hasil Output File APK:
Setelah proses kompilasi selesai (`Built build\app\outputs\flutter-apk\app-release.apk`), file APK siap diambil di lokasi:
```text
baloga_ar_rescue/build/app/outputs/flutter-apk/app-release.apk
```

---

### 🛠️ CARA INSTALASI APK KE HANDPHONE ANDROID
1. Transfer file `app-release.apk` ke HP Android via kabel USB / Google Drive / WhatsApp.
2. Buka File Manager di HP Android dan klik file `app-release.apk`.
3. Jika muncul peringatan *"Install dari Sumber Tidak Dikenal"* (*Unknown Sources*), izinkan (Allow).
4. Selesai! Aplikasi **Baloga AR Rescue** siap digunakan.

---

## 🚀 Fitur Utama Sistem

### 📱 Frontend Flutter App (`baloga_ar_rescue`)
1. **Splash & Auto Auth Check**: Animasi pembuka dan pengecekan token JWT/Sanctum otomatis.
2. **Autentikasi Ranger (Login & Register)**:
   - Login & Register dengan enkripsi token Sanctum via `flutter_secure_storage`.
   - **Tampilan Pesan Error Real-Time**: Menampilkan pesan kesalahan spesifik dari server (contoh: email sudah terdaftar, password min 8 karakter).
3. **Peta Interaktif Real-Time (`MapScreen`)**:
   - Peta OpenStreetMap interaktif menggunakan `flutter_map` & `latlong2`.
   - Marker posisi user bergerak secara real-time berdasarkan GPS.
   - Marker monster spawn point muncul di peta dengan highlight warna sesuai *rarity*.
   - Filter radius otomatis: Marker monster menjadi *tappable* (dapat diselamatkan) hanya jika jarak user `< 10 meter`.
4. **2D Capture Scene (`CaptureScreen`)**:
   - Game Loop 2D performa tinggi menggunakan **Flame Engine**.
   - Animasi *idle bobbing* monster spesies.
   - Kontrol gesture *drag & swipe* Eko-Sphere (bola penangkap).
   - Deteksi *collision trajectory* antara Eko-Sphere dan bounding box monster.
   - Kalkulasi probabilitas penangkapan & validasi server-side.
5. **Ensiklopedia Spesies (`EncyclopediaScreen`)**:
   - Grid card seluruh spesies hewan & tumbuhan Baloga.
   - Tab filter: *Semua*, *Hewan*, *Tumbuhan*.
   - Modal detail spesies: foto, nama latin, habitat, makanan, peran ekologi, status konservasi IUCN.
6. **Dynamic Branding & App Configuration**:
   - Logo, Nama Aplikasi, dan Tagline dirender secara dinamis berdasarkan setting dari Admin Panel.

---

### ⚙️ Backend Laravel REST API (`baloga-api`) & Admin Panel
1. **Dynamic Admin Panel (`/admin`)**:
   - **Branding & Settings Management**: Kelola Nama Aplikasi, Slogan, dan Upload Logo Gambar secara dinamis.
   - **Master Spesies**: CRUD Spesies Hewan & Tumbuhan + Upload Thumbnail Gambar & Model 3D.
   - **Game Locations & Spawn Points**: Kelola area Baloga & titik koordinat kemunculan monster.
   - **Item & Misi**: Kelola Eko-Sphere, Radar, Scanner, & Misi Harian/Mingguan.
   - **User & Log Capture**: Monitoring akun Ranger & aktivitas penyelamatan.
2. **Multi-layer Security**:
   - Authentication via `Laravel Sanctum` (`personal_access_tokens`).
   - Server-side **Haversine Distance Re-validation** pada endpoint capture untuk mencegah manipulasi GPS (batas toleransi 50 meter).
   - Rate limiting: 5 req/menit untuk Login/Register.

---

## 💻 Panduan Setup & Installasi Local

### 1. Setup Backend Laravel (`baloga-api`)

```bash
cd baloga-api

# Install Composer Dependencies
composer install

# Environment File Setup
cp .env.example .env

# Generate Application Key & Storage Link
php artisan key:generate
php artisan storage:link

# Database Migration & Seeder (Sudah termasuk Sanctum & App Settings)
php artisan migrate:fresh --seed

# Run Development Server
php artisan serve --port=8000
```

### 2. Setup Frontend Flutter (`baloga_ar_rescue`)

```bash
cd baloga_ar_rescue

# Install Flutter Dependencies
flutter pub get

# Run Development (Chrome / Emulator / Mobile)
flutter run
```

---

## 📄 Lisensi & Hak Cipta

Project dikembangkan untuk **Batu Love Garden (Baloga) - Jatim Park Group**.  
Hak cipta dilindungi undang-undang.
