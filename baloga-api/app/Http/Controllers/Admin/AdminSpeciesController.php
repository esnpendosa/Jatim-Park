<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Species;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminSpeciesController extends Controller
{
    public function index()
    {
        $species = Species::orderBy('id', 'desc')->paginate(10);
        return view('admin.species.index', compact('species'));
    }

    public function create()
    {
        return view('admin.species.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'latin_name' => 'required|string|max:255',
            'category' => 'required|in:hewan,tumbuhan',
            'rarity' => 'required|in:common,rare,epic,legendary',
            'habitat' => 'required|string|max:255',
            'food' => 'nullable|string|max:255',
            'ecological_role' => 'required|string',
            'conservation_status' => 'required|string|max:255',
            'fun_fact' => 'required|string',
            'base_cp' => 'required|integer|min:10',
            'thumbnail_file' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:4096',
            'model_3d_file' => 'nullable|file|mimes:zip,glb,gltf,obj,fbx|max:20480',
        ]);

        if ($request->hasFile('thumbnail_file')) {
            $path = $request->file('thumbnail_file')->store('species/thumbnails', 'public');
            $validated['thumbnail_url'] = asset('storage/' . $path);
        }

        if ($request->hasFile('model_3d_file')) {
            $path = $request->file('model_3d_file')->store('species/models', 'public');
            $validated['model_3d_url'] = asset('storage/' . $path);
        }

        Species::create($validated);

        return redirect()->route('admin.species.index')->with('success', 'Spesies baru berhasil ditambahkan!');
    }

    public function edit(Species $species)
    {
        return view('admin.species.edit', compact('species'));
    }

    public function update(Request $request, Species $species)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'latin_name' => 'required|string|max:255',
            'category' => 'required|in:hewan,tumbuhan',
            'rarity' => 'required|in:common,rare,epic,legendary',
            'habitat' => 'required|string|max:255',
            'food' => 'nullable|string|max:255',
            'ecological_role' => 'required|string',
            'conservation_status' => 'required|string|max:255',
            'fun_fact' => 'required|string',
            'base_cp' => 'required|integer|min:10',
            'thumbnail_file' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:4096',
            'model_3d_file' => 'nullable|file|mimes:zip,glb,gltf,obj,fbx|max:20480',
        ]);

        if ($request->hasFile('thumbnail_file')) {
            $path = $request->file('thumbnail_file')->store('species/thumbnails', 'public');
            $validated['thumbnail_url'] = asset('storage/' . $path);
        }

        if ($request->hasFile('model_3d_file')) {
            $path = $request->file('model_3d_file')->store('species/models', 'public');
            $validated['model_3d_url'] = asset('storage/' . $path);
        }

        $species->update($validated);

        return redirect()->route('admin.species.index')->with('success', 'Data spesies berhasil diperbarui!');
    }

    public function destroy(Species $species)
    {
        $species->delete();
        return redirect()->route('admin.species.index')->with('success', 'Spesies berhasil dihapus!');
    }
}
