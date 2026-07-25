<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Http\Request;

class AdminItemController extends Controller
{
    public function index()
    {
        $items = Item::all();
        return view('admin.items.index', compact('items'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'type' => 'required|in:capture_ball,scanner,radar,booster',
            'icon_file' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
        ]);

        if ($request->hasFile('icon_file')) {
            $path = $request->file('icon_file')->store('items/icons', 'public');
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
