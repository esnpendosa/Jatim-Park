<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GameLocation;
use App\Models\SpawnPoint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    public function getGameLocations(): JsonResponse
    {
        $locations = GameLocation::all();
        return response()->json([
            'data' => $locations,
        ]);
    }

    public function getNearbySpawnPoints(Request $request): JsonResponse
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'radius' => 'nullable|numeric',
        ]);

        $userLat = (float) $request->lat;
        $userLng = (float) $request->lng;
        $radiusKm = ((float) ($request->radius ?? 1000)) / 1000.0;

        $spawnPoints = SpawnPoint::with('species')->where('active', true)->get();

        $nearby = $spawnPoints->filter(function ($sp) use ($userLat, $userLng, $radiusKm) {
            $distanceKm = $this->haversineDistance($userLat, $userLng, $sp->latitude, $sp->longitude);
            $sp->distance_meters = round($distanceKm * 1000, 2);
            $sp->is_tappable = ($sp->distance_meters <= 10.0);
            return $distanceKm <= $radiusKm;
        })->values();

        return response()->json([
            'data' => $nearby,
        ]);
    }

    public static function haversineDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadiusKm = 6371;

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadiusKm * $c;
    }
}
