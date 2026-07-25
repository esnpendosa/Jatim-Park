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
- **Android App Package**: `com.baloga.baloga_ar_rescue`

---

## 🚀 Fitur Utama Sistem

### 📱 Frontend Flutter App (`baloga_ar_rescue`)
1. **Splash & Auto Auth Check**: Animasi pembuka dan pengecekan token JWT/Sanctum otomatis.
2. **Autentikasi Ranger**: Login & Register akun baru dengan enkripsi token via `flutter_secure_storage`.
3. **Peta Interaktif Real-Time (`MapScreen`)**:
   - Peta OpenStreetMap interaktif menggunakan `flutter_map` & `latlong2`.
   - Marker posisi user bergerak secara real-time berdasarkan GPS.
   - Monster spawn point muncul di peta dengan highlight warna sesuai *rarity*.
   - Filter radius otomatis: Marker monster menjadi *tappable* (dapat diselamatkan) hanya jika jarak user `< 10 meter`.
   - Validasi Geofencing: Peringatan visual jika user berada di luar radius area resmi Baloga (1000m).
4. **2D Capture Scene (`CaptureScreen`)**:
   - Game Loop 2D performa tinggi menggunakan **Flame Engine**.
   - Animasi *idle bobbing* monster spesies.
   - Kontrol gesture *drag & swipe* Eko-Sphere (bola penangkap).
   - Deteksi *collision trajectory* antara Eko-Sphere dan bounding box monster.
   - Kalkulasi probabilitas penangkapan & validasi server-side.
   - Display kartu hasil penyelamatan, perolehan XP (+50 sd +500), poin, dan penanda *Spesies Baru*.
5. **Ensiklopedia Spesies (`EncyclopediaScreen`)**:
   - Grid card seluruh spesies hewan & tumbuhan Baloga.
   - Tab filter: *Semua*, *Hewan*, *Tumbuhan*.
   - Badge warna per rarity (*Common*, *Rare*, *Epic*, *Legendary*).
   - Modal detail spesies: foto, nama latin, habitat, makanan, peran ekologi, status konservasi IUCN (warna merah untuk Kritis), dan fakta unik.
6. **Sistem Misi (`MissionsScreen`)**:
   - Tab *Misi Harian* & *Misi Mingguan*.
   - Progress bar pencapaian misi.
   - Tombol klaim reward aktif saat progress 100%.
7. **Profil Ranger (`ProfileScreen`)**:
   - Avatar & Level Ranger.
   - Progress bar XP ke level berikutnya (`user.level * 200 XP`).
   - Statistik perolehan spesies, total poin, dan badge.
   - Grid badge pencapaian (*Penyelamat Muda*, *Pelindung Satwa*, *Botanis Baloga*).
8. **Inventori Ranger (`InventoryScreen`)**:
   - **Tab Item**: Stok Eko-Sphere Standard, Eko-Sphere Great, Eco Scanner, Nature Radar, Lucky Leaf.
   - **Tab Koleksi**: Hasil tangkapan spesies beserta jumlah (*quantity*).

---

### ⚙️ Backend Laravel REST API (`baloga-api`)
1. **Multi-layer Security**:
   - Middleware `auth:sanctum` untuk semua protected endpoint.
   - Laravel Form Request Validation untuk sanitasi semua input JSON.
   - Rate limiting throttle: 5 req/menit untuk Login/Register, 60 req/menit untuk API umum.
   - Server-side **Haversine Distance Re-validation** pada endpoint capture untuk mencegah manipulasi GPS / Fake GPS Spoofing (batas toleransi 50 meter).
   - Anti-cheat telemetry logging untuk percobaan capture berjarak tidak wajar.
2. **CORS Policy & HTTPS**:
   - Konfigurasi `config/cors.php` mendukung cross-origin resmi.
   - `AppServiceProvider` menangani SSL reverse proxy (`X-Forwarded-Proto`).
3. **Database Architecture**:
   - 12 Tabel terstruktur dengan relasi Eloquent FK cascades.

---

## 🛠️ Stack Teknologi

| Komponen | Teknologi / Package | Detail |
| :--- | :--- | :--- |
| **Backend Framework** | Laravel 13 | PHP 8.3+ |
| **Database** | MySQL / MariaDB | UTF8MB4 Unicode |
| **Auth & Security** | Laravel Sanctum & Fortify | Bearer Token Auth |
| **Frontend Framework** | Flutter 3.44.0 | Dart 3.12.0 |
| **State Management** | Flutter Riverpod 2.6 | Reactive State Notifiers |
| **Game Engine 2D** | Flame Engine 1.22 | Canvas gesture & collision |
| **Maps & Location** | Flutter Map + Geolocator | OpenStreetMap & GPS tracking |
| **HTTP Client** | Dio 5.7 + Flutter Secure Storage | Automatic Token Interceptor |
| **Navigation** | GoRouter 14 | Declarative Shell Routing |

---

## 🗄️ Skema Database (12 Tabel)

```
users
 ├── id (PK)
 ├── name, email (unique), password (hashed), avatar_url
 └── level, xp, points, species_found, badges_count

species (Master Monster/Hewan/Tumbuhan)
 ├── id (PK)
 ├── name, latin_name, category (enum: hewan/tumbuhan)
 ├── rarity (enum: common/rare/epic/legendary)
 ├── habitat, food, ecological_role, conservation_status, fun_fact
 └── model_3d_url, thumbnail_url, base_cp

game_locations (Radius Area Resmi)
 └── id (PK), name, latitude, longitude, radius_meters

spawn_points (Titik Kemunculan Monster)
 └── id (PK), species_id (FK), latitude, longitude, active, respawn_minutes

captures (History Log Penangkapan)
 └── id (PK), user_id (FK), species_id (FK), captured_at, latitude, longitude, cp_result

inventories (Koleksi Spesies User)
 └── id (PK), user_id (FK), species_id (FK), quantity, first_captured_at

items (Master Data Item/Bola)
 └── id (PK), name, description, icon_url, type (enum: capture_ball/scanner/radar/booster)

user_items (Stok Item User)
 └── id (PK), user_id (FK), item_id (FK), quantity

missions (Master Data Misi)
 └── id (PK), title, description, type (enum: daily/weekly), target_count, xp_reward, icon_url

user_missions (Progress Misi User)
 └── id (PK), user_id (FK), mission_id (FK), current_progress, is_completed, reset_at

badges (Master Data Badge)
 └── id (PK), name, description, icon_url, requirement_type, requirement_value

user_badges (Badge Milik User)
 └── id (PK), user_id (FK), badge_id (FK), earned_at
```

---

## 🔌 Dokumentasi REST API Endpoints

### Auth Endpoints
| Method | Endpoint | Auth Required | Rate Limit | Deskripsi |
| :--- | :--- | :---: | :---: | :--- |
| `POST` | `/api/register` | ❌ | 5 req/min | Registrasi akun Ranger baru + starter 10 Eko-Sphere |
| `POST` | `/api/login` | ❌ | 5 req/min | Login & dapatkan token Sanctum |
| `POST` | `/api/logout` | 🔐 Sanctum | 60 req/min | Hapus token session |
| `GET` | `/api/me` | 🔐 Sanctum | 60 req/min | Dapatkan profil & statistik user |

### Location & Map Endpoints
| Method | Endpoint | Auth Required | Deskripsi |
| :--- | :--- | :---: | :--- |
| `GET` | `/api/game-locations` | ❌ Public | Daftar koordinat & radius resmi area Baloga |
| `GET` | `/api/spawn-points/nearby` | 🔐 Sanctum | Fetch monster terdekat (`?lat=..&lng=..&radius=..`) |

### Capture Flow Endpoint
| Method | Endpoint | Auth Required | Payload Body |
| :--- | :--- | :---: | :--- |
| `POST` | `/api/captures/attempt` | 🔐 Sanctum | `{"spawn_point_id": 1, "lat": -7.892, "lng": 112.548, "item_id": 1}` |

> **Logika Backend `POST /api/captures/attempt`**:
> 1. Validasi keberadaan & status aktif `spawn_point_id`.
> 2. Re-kalkulasi jarak Haversine koordinat user ke spawn point (Server-Side). Jika `> 50 meter`, ditolak dengan error 400.
> 3. Cek stok item `item_id` milik user. Kurangi `quantity - 1`.
> 4. Hitung probabilitas sukses berdasarkan `rarity` spesies (*Common*: 85%, *Rare*: 65%, *Epic*: 45%, *Legendary*: 25%) + bonus item Eko-Sphere Great.
> 5. Jika sukses: simpan ke `captures` + `inventories`, tambahkan XP & Poin user, update `species_found`.

### Species, Inventory & Missions Endpoints
| Method | Endpoint | Auth Required | Deskripsi |
| :--- | :--- | :---: | :--- |
| `GET` | `/api/species` | 🔐 Sanctum | Daftar spesies (`?category=hewan|tumbuhan`) |
| `GET` | `/api/species/{id}` | 🔐 Sanctum | Detail spesies & status *is_discovered* |
| `GET` | `/api/inventory` | 🔐 Sanctum | Daftar spesies yang telah ditangkap user |
| `GET` | `/api/items` | 🔐 Sanctum | Daftar item & stok milik user |
| `GET` | `/api/missions` | 🔐 Sanctum | Daftar misi harian/mingguan & progress user |
| `POST` | `/api/missions/{id}/claim` | 🔐 Sanctum | Klaim XP reward untuk misi yang telah 100% |
| `GET` | `/api/leaderboard` | ❌ Public | Top 20 Ranger berdasarkan poin (Cache 5 menit) |

---

## 💻 Panduan Inisialisasi & Installasi Project

### 1. Setup Backend Laravel (`baloga-api`)

```bash
cd baloga-api

# Install Composer Dependencies
composer install

# Environment File Setup
cp .env.example .env

# Generate Application Key
php artisan key:generate

# Database Setup di .env (Laragon MySQL)
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=baloga_db
# DB_USERNAME=root
# DB_PASSWORD=

# Run Database Migrations & Seeders
php artisan migrate:fresh --seed

# Run Development Server
php artisan serve --port=8000
```

### 2. Setup Frontend Flutter (`baloga_ar_rescue`)

```bash
cd baloga_ar_rescue

# Install Flutter Dependencies
flutter pub get

# Setup File .env (sudah dikonfigurasi ke domain production)
# API_BASE_URL=https://balago.rozitech.co.id/api

# Run App (Chrome / Emulator / Device)
flutter run

# Build APK Release Android
flutter build apk --release

# Build Production Web Release
flutter build web --release
```

---

## 🎨 Asset Generation Prompts (Phase 7 Guide)

Gunakan prompt berikut di tool AI Image Generator (Midjourney / Leonardo.ai) untuk membuat ilustrasi spesies Baloga tambahan:

**Style Guide Suffix:**
```text
--style semi-realistic mobile game illustration, vibrant colors, soft rim lighting, clean background, centered composition, mascot-friendly, high detail fur/texture, similar to Pokemon GO creature card art
```

**Contoh Prompt Spesies (Harimau Sumatra):**
```text
A majestic Sumatran tiger (Panthera tigris sumatrae) standing confidently on grass, full body, epic rarity glow aura in blue-green, game creature illustration style, detailed fur texture, soft studio lighting, transparent-friendly background --style semi-realistic mobile game illustration, vibrant colors, soft rim lighting, clean background, centered composition, mascot-friendly, high detail fur/texture, similar to Pokemon GO creature card art
```

**Contoh Prompt Icon Item (Eko-Sphere):**
```text
A glowing spherical capture device icon, blue-green glass orb with glowing core, game UI icon style, isolated on transparent background, soft glow, flat perspective
```

---

## 🛡️ Checklist Security & Release Play Store (Phase 6)

- [x] **Obfuscation Build**: `flutter build appbundle --obfuscate --split-debug-info=build/debug-info`
- [x] **Secure Token Storage**: Menggunakan `flutter_secure_storage` untuk menyimpan JWT Bearer token.
- [x] **Network Security**: Mendukung HTTPS & Cleartext Traffic secara selektif di `AndroidManifest.xml`.
- [x] **Server Anti-Cheat**: Validasi ulang Haversine GPS distance di backend Laravel.
- [x] **Rate Limiting**: Throttling 5 req/min di Auth & 60 req/min di API.
- [x] **CORS Policy**: Restriksi header & origin terdaftar di `config/cors.php`.

---

## 📄 Lisensi & Hak Cipta

Project dikembangkan untuk **Batu Love Garden (Baloga) - Jatim Park Group**.  
Hak cipta dilindungi undang-undang.
