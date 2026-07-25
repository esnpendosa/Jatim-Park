<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CaptureController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\LeaderboardController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\MissionController;
use App\Http\Controllers\Api\SpeciesController;
use Illuminate\Support\Facades\Route;

// Public Auth Endpoints (Rate Limited: 5 requests per minute)
Route::middleware(['throttle:5,1'])->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Public Endpoints
Route::get('/game-locations', [LocationController::class, 'getGameLocations']);
Route::get('/leaderboard', [LeaderboardController::class, 'getLeaderboard']);

// Protected API Endpoints (Sanctum Auth + Rate Limited: 60 requests per minute)
Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    // Auth & User Profile
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Map & Spawn Points
    Route::get('/spawn-points/nearby', [LocationController::class, 'getNearbySpawnPoints']);

    // Capture Flow
    Route::post('/captures/attempt', [CaptureController::class, 'attemptCapture']);

    // Species / Encyclopedia
    Route::get('/species', [SpeciesController::class, 'index']);
    Route::get('/species/{id}', [SpeciesController::class, 'show']);

    // Inventory & Items
    Route::get('/inventory', [InventoryController::class, 'getInventory']);
    Route::get('/items', [InventoryController::class, 'getItems']);

    // Missions
    Route::get('/missions', [MissionController::class, 'getMissions']);
    Route::post('/missions/{id}/claim', [MissionController::class, 'claimMission']);
});
