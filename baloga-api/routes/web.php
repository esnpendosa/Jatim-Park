<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminItemController;
use App\Http\Controllers\Admin\AdminLocationController;
use App\Http\Controllers\Admin\AdminMissionController;
use App\Http\Controllers\Admin\AdminSpeciesController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\Admin\DashboardController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

// Admin Auth Routes
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLoginForm'])->name('admin.login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('admin.login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');

    // Protected Admin Routes
    Route::middleware(['auth'])->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');

        // Species Management
        Route::resource('species', AdminSpeciesController::class, ['as' => 'admin']);

        // Location & Spawn Points
        Route::get('/locations', [AdminLocationController::class, 'index'])->name('admin.locations.index');
        Route::post('/locations', [AdminLocationController::class, 'storeLocation'])->name('admin.locations.store');
        Route::post('/spawn-points', [AdminLocationController::class, 'storeSpawnPoint'])->name('admin.spawn_points.store');
        Route::delete('/spawn-points/{spawnPoint}', [AdminLocationController::class, 'destroySpawnPoint'])->name('admin.spawn_points.destroy');

        // Items & Missions
        Route::resource('items', AdminItemController::class, ['as' => 'admin']);
        Route::resource('missions', AdminMissionController::class, ['as' => 'admin']);

        // Settings & Branding
        Route::get('/settings', [\App\Http\Controllers\Admin\AdminSettingController::class, 'index'])->name('admin.settings.index');
        Route::post('/settings', [\App\Http\Controllers\Admin\AdminSettingController::class, 'update'])->name('admin.settings.update');

        // Users & Captures
        Route::get('/users', [AdminUserController::class, 'index'])->name('admin.users.index');
        Route::get('/captures', [AdminUserController::class, 'captures'])->name('admin.captures.index');
    });
});
