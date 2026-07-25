<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Mission;
use Illuminate\Http\Request;

class AdminMissionController extends Controller
{
    public function index()
    {
        $missions = Mission::all();
        return view('admin.missions.index', compact('missions'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'type' => 'required|in:daily,weekly',
            'target_count' => 'required|integer|min:1',
            'xp_reward' => 'required|integer|min:10',
        ]);

        Mission::create($validated);

        return back()->with('success', 'Misi baru berhasil ditambahkan!');
    }

    public function destroy(Mission $mission)
    {
        $mission->delete();
        return back()->with('success', 'Misi berhasil dihapus!');
    }
}
