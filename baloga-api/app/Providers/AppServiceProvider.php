<?php

namespace App\Providers;

use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;

// Polyfill for PHP finfo class when php_fileinfo extension is disabled on server
if (!class_exists('finfo')) {
    class finfo
    {
        public function __construct($flags = null, $magic_file = null) {}

        public function file($filename, $flags = null, $context = null)
        {
            $ext = pathinfo($filename, PATHINFO_EXTENSION);
            return match (strtolower($ext)) {
                'jpg', 'jpeg' => 'image/jpeg',
                'png' => 'image/png',
                'gif' => 'image/gif',
                'webp' => 'image/webp',
                'svg' => 'image/svg+xml',
                'pdf' => 'application/pdf',
                'zip' => 'application/zip',
                'glb' => 'model/gltf-binary',
                'gltf' => 'model/gltf+json',
                default => 'application/octet-stream',
            };
        }

        public function buffer($string, $flags = null, $context = null)
        {
            return 'application/octet-stream';
        }
    }
}

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (request()->header('X-Forwarded-Proto') === 'https' || request()->isSecure() || app()->environment('production')) {
            URL::forceScheme('https');
        }
    }
}
