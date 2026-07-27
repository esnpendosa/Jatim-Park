<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CaptureAttemptRequest;
use App\Models\Capture;
use App\Models\Inventory;
use App\Models\SpawnPoint;
use App\Models\UserItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class CaptureController extends Controller
{
    public function attemptCapture(CaptureAttemptRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $spawnPoint = SpawnPoint::with('species')->find($validated['spawn_point_id']);

        if (!$spawnPoint || !$spawnPoint->active) {
            return response()->json([
                'success' => false,
                'message' => 'Monster ini sudah tidak aktif atau berpindah tempat.',
            ], 400);
        }

        // GPS distance calculation (radius check bypassed for unlimited testing mode)
        $distanceMeters = LocationController::haversineDistance(
            (float) $validated['lat'],
            (float) $validated['lng'],
            $spawnPoint->latitude,
            $spawnPoint->longitude
        ) * 1000.0;

        // Check & Deduct item stock
        $userItem = UserItem::where('user_id', $user->id)
            ->where('item_id', $validated['item_id'])
            ->first();

        if (!$userItem || $userItem->quantity < 1) {
            return response()->json([
                'success' => false,
                'message' => 'Stok Eko-Sphere / Item Anda habis! Silakan dapatkan di toko/misi.',
            ], 400);
        }

        $userItem->decrement('quantity');

        // Calculate Catch Probability based on species rarity
        $species = $spawnPoint->species;
        $baseRate = match ($species->rarity) {
            'common' => 0.85,
            'rare' => 0.65,
            'epic' => 0.45,
            'legendary' => 0.25,
            default => 0.50,
        };

        // Item type boost if applicable
        $item = $userItem->item;
        if ($item && $item->name === 'Eko-Sphere Great') {
            $baseRate += 0.20;
        }

        $roll = (float) rand(0, 100) / 100.0;
        $isSuccess = ($roll <= $baseRate);

        if (!$isSuccess) {
            return response()->json([
                'success' => false,
                'message' => 'Monster melarikan diri! Coba lagi dengan Eko-Sphere yang lebih kuat.',
            ]);
        }

        // Success flow
        $cpResult = $species->base_cp + rand(-50, 150);

        Capture::create([
            'user_id' => $user->id,
            'species_id' => $species->id,
            'captured_at' => now(),
            'latitude' => $validated['lat'],
            'longitude' => $validated['lng'],
            'cp_result' => $cpResult,
        ]);

        // Inventory update
        $inventory = Inventory::firstOrCreate(
            ['user_id' => $user->id, 'species_id' => $species->id],
            ['quantity' => 0, 'first_captured_at' => now()]
        );
        $isNewSpecies = ($inventory->quantity == 0);
        $inventory->increment('quantity');

        // Reward XP & Points to User
        $earnedXp = match ($species->rarity) {
            'common' => 50,
            'rare' => 100,
            'epic' => 200,
            'legendary' => 500,
            default => 50,
        };
        $earnedPoints = $earnedXp * 2;

        $user->increment('xp', $earnedXp);
        $user->increment('points', $earnedPoints);
        if ($isNewSpecies) {
            $user->increment('species_found');
        }

        return response()->json([
            'success' => true,
            'message' => "BERHASIL! {$species->name} telah berhasil diselamatkan!",
            'is_new_species' => $isNewSpecies,
            'cp_result' => $cpResult,
            'earned_xp' => $earnedXp,
            'earned_points' => $earnedPoints,
            'species' => $species,
        ]);
    }
}
