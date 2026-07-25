<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Capture;
use App\Models\GameLocation;
use App\Models\Item;
use App\Models\Mission;
use App\Models\SpawnPoint;
use App\Models\Species;
use App\Models\User;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'total_users' => User::where('is_admin', false)->count(),
            'total_species' => Species::count(),
            'total_captures' => Capture::count(),
            'total_spawn_points' => SpawnPoint::count(),
            'total_items' => Item::count(),
            'total_missions' => Mission::count(),
        ];

        $latestCaptures = Capture::with(['user', 'species'])->orderBy('id', 'desc')->limit(8)->get();
        $recentUsers = User::where('is_admin', false)->orderBy('id', 'desc')->limit(5)->get();

        return view('admin.dashboard', compact('stats', 'latestCaptures', 'recentUsers'));
    }
}
