<?php

// Universal polyfill for PHP finfo class when php_fileinfo extension is missing on server
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

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );
    })->create();
