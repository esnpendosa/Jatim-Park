<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Species;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

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
            'thumbnail_file' => 'nullable|file|max:4096',
            'model_3d_file' => 'nullable|file|max:20480',
        ]);

        if ($request->hasFile('thumbnail_file')) {
            $file = $request->file('thumbnail_file');
            $ext = strtolower($file->getClientOriginalExtension() ?: 'png');
            $fileName = 'thumb_' . time() . '_' . Str::random(6) . '.' . $ext;

            $destPath = storage_path('app/public/species/thumbnails');
            $pubPath = public_path('storage/species/thumbnails');

            if (!file_exists($destPath)) mkdir($destPath, 0777, true);
            if (!file_exists($pubPath)) mkdir($pubPath, 0777, true);

            $file->move($destPath, $fileName);
            copy($destPath . '/' . $fileName, $pubPath . '/' . $fileName);

            $validated['thumbnail_url'] = asset('storage/species/thumbnails/' . $fileName);
        }

        if ($request->hasFile('model_3d_file')) {
            $file = $request->file('model_3d_file');
            $ext = strtolower($file->getClientOriginalExtension() ?: 'glb');
            $fileName = 'model_' . time() . '_' . Str::random(6) . '.' . $ext;

            $destPath = storage_path('app/public/species/models');
            $pubPath = public_path('storage/species/models');

            if (!file_exists($destPath)) mkdir($destPath, 0777, true);
            if (!file_exists($pubPath)) mkdir($pubPath, 0777, true);

            $file->move($destPath, $fileName);
            copy($destPath . '/' . $fileName, $pubPath . '/' . $fileName);

            $validated['model_3d_url'] = asset('storage/species/models/' . $fileName);
        }

        Species::create($validated);

        return redirect()->route('admin.species.index')->with('success', 'Spesies baru berhasil ditambahkan!');
    }

    public function show(Species $species)
    {
        return redirect()->route('admin.species.edit', $species);
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
            'thumbnail_file' => 'nullable|file|max:4096',
            'model_3d_file' => 'nullable|file|max:20480',
        ]);

        if ($request->hasFile('thumbnail_file')) {
            $file = $request->file('thumbnail_file');
            $ext = strtolower($file->getClientOriginalExtension() ?: 'png');
            $fileName = 'thumb_' . time() . '_' . Str::random(6) . '.' . $ext;

            $destPath = storage_path('app/public/species/thumbnails');
            $pubPath = public_path('storage/species/thumbnails');

            if (!file_exists($destPath)) mkdir($destPath, 0777, true);
            if (!file_exists($pubPath)) mkdir($pubPath, 0777, true);

            $file->move($destPath, $fileName);
            copy($destPath . '/' . $fileName, $pubPath . '/' . $fileName);

            $validated['thumbnail_url'] = asset('storage/species/thumbnails/' . $fileName);
        }

        if ($request->hasFile('model_3d_file')) {
            $file = $request->file('model_3d_file');
            $ext = strtolower($file->getClientOriginalExtension() ?: 'glb');
            $fileName = 'model_' . time() . '_' . Str::random(6) . '.' . $ext;

            $destPath = storage_path('app/public/species/models');
            $pubPath = public_path('storage/species/models');

            if (!file_exists($destPath)) mkdir($destPath, 0777, true);
            if (!file_exists($pubPath)) mkdir($pubPath, 0777, true);

            $file->move($destPath, $fileName);
            copy($destPath . '/' . $fileName, $pubPath . '/' . $fileName);

            $validated['model_3d_url'] = asset('storage/species/models/' . $fileName);
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
