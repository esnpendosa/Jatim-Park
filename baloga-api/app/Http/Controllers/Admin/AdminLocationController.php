<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\GameLocation;
use App\Models\SpawnPoint;
use App\Models\Species;
use Illuminate\Http\Request;

class AdminLocationController extends Controller
{
    public function index()
    {
        $locations = GameLocation::all();
        $spawnPoints = SpawnPoint::with('species')->orderBy('id', 'desc')->paginate(10);
        $species = Species::all();

        return view('admin.locations.index', compact('locations', 'spawnPoints', 'species'));
    }

    public function storeLocation(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius_meters' => 'required|integer|min:10',
        ]);

        GameLocation::create($validated);
        return back()->with('success', 'Area Game berhasil ditambahkan!');
    }

    public function storeSpawnPoint(Request $request)
    {
        $validated = $request->validate([
            'species_id' => 'required|exists:species,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'respawn_minutes' => 'required|integer|min:1',
        ]);

        $validated['active'] = true;
        SpawnPoint::create($validated);

        return back()->with('success', 'Spawn Point monster berhasil ditambahkan!');
    }

    public function destroySpawnPoint(SpawnPoint $spawnPoint)
    {
        $spawnPoint->delete();
        return back()->with('success', 'Spawn Point berhasil dihapus!');
    }
}
