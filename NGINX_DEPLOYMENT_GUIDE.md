# 🌐 Panduan Konfigurasi Nginx Server Block untuk Production Server (`balago.rozitech.co.id`)

Masalah **403 Forbidden** dan **404 Not Found** pada domain `https://balago.rozitech.co.id` terjadi karena konfigurasi Nginx di server VPS belum mengarahkan `root` ke direktori `/public` milik Laravel dan belum mengaktifkan URL Rewriting (`try_files`).

---

## 🛠️ KONFIGURASI NGINX SERVER BLOCK (LENGKAP)

Buka atau edit file konfigurasi Nginx di VPS Anda (contoh: `/etc/nginx/sites-available/balago.rozitech.co.id` atau `/etc/nginx/conf.d/balago.conf`):

```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name balago.rozitech.co.id;

    # ⚠️ PENTING: Arahkan root langsung ke folder public milik Laravel (baloga-api/public)
    root /var/www/Jatim-Park/baloga-api/public;
    index index.php index.html index.htm;

    # SSL Certificate (Jika menggunakan SSL Let's Encrypt / Certbot)
    # ssl_certificate /etc/letsencrypt/live/balago.rozitech.co.id/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/balago.rozitech.co.id/privkey.pem;

    charset utf-8;

    # 💡 MENGATASI 404 Not Found di /admin, /api, /login
    # Mengarahkan seluruh request ke Laravel public/index.php
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Handling storage symlink asset (gambar & logo upload)
    location /storage {
        alias /var/www/Jatim-Park/baloga-api/storage/app/public;
        try_files $uri $uri/ =404;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    # Konfigurasi PHP-FPM (Sesuaikan versi PHP, contoh: php8.3-fpm atau php8.2-fpm)
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Blokir akses ke file tersembunyi (.env, .git, dll)
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

---

## 🚀 LANGKAH-LANGKAH PENERAPAN DI SERVER VPS

1. **Jalankan Command berikut di Terminal VPS**:
   ```bash
   # Masuk ke folder backend Laravel di VPS
   cd /var/www/Jatim-Park/baloga-api

   # Berikan izin akses folder storage & cache ke Nginx (www-data)
   chown -R www-data:www-data storage bootstrap/cache
   chmod -R 775 storage bootstrap/cache

   # Simlink storage publik
   php artisan storage:link

   # Jalankan migration & seeder
   php artisan migrate:fresh --seed
   ```

2. **Test & Restart Nginx**:
   ```bash
   # Cek sintaks Nginx
   sudo nginx -t

   # Restart Nginx
   sudo systemctl restart nginx
   ```

3. **Cek Kembali URL di Browser**:
   - 🟢 `https://balago.rozitech.co.id/admin/login` -> Halaman Login Admin Panel
   - 🟢 `https://balago.rozitech.co.id/api/app-config` -> Endpoint Config API
   - 🟢 `https://balago.rozitech.co.id/api/game-locations` -> Endpoint Public API
