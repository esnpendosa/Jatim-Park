<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AdminItemController extends Controller
{
    public function index()
    {
        $items = Item::all();
        return view('admin.items.index', compact('items'));
    }

    public function show(Item $item)
    {
        return redirect()->route('admin.items.index');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'type' => 'required|in:capture_ball,scanner,radar,booster',
            'icon_file' => 'nullable|file|max:2048',
        ]);

        if ($request->hasFile('icon_file')) {
            $file = $request->file('icon_file');
            $ext = strtolower($file->getClientOriginalExtension() ?: 'png');
            $fileName = 'item_' . time() . '_' . Str::random(6) . '.' . $ext;
            $mime = $file->getClientMimeType() ?: 'image/png';

            $path = $file->storeAs('items/icons', $fileName, [
                'disk' => 'public',
                'mimetype' => $mime,
            ]);
            $validated['icon_url'] = asset('storage/' . $path);
        }

        Item::create($validated);

        return back()->with('success', 'Item baru berhasil ditambahkan!');
    }

    public function destroy(Item $item)
    {
        $item->delete();
        return back()->with('success', 'Item berhasil dihapus!');
    }
}
