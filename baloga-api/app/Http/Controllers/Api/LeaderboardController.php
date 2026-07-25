<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class LeaderboardController extends Controller
{
    public function getLeaderboard(): JsonResponse
    {
        $leaderboard = Cache::remember('leaderboard_top_users', 300, function () {
            return User::select(['id', 'name', 'avatar_url', 'level', 'points', 'species_found'])
                ->orderBy('points', 'desc')
                ->limit(20)
                ->get();
        });

        return response()->json([
            'data' => $leaderboard,
        ]);
    }
}
