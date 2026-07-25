@extends('admin.layouts.app')

@section('title', 'Edit Spesies')

@section('content')
<div class="max-w-4xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
        <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">Form Edit Spesies: {{ $species->name }}</h3>
        <a href="{{ route('admin.species.index') }}" class="text-xs text-slate-400 hover:text-slate-200">← Kembali</a>
    </div>

    <form action="{{ route('admin.species.update', $species->id) }}" method="POST" enctype="multipart/form-data" class="bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-6">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Nama Spesies (Lokal)</label>
                <input type="text" name="name" value="{{ old('name', $species->name) }}" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Nama Latin</label>
                <input type="text" name="latin_name" value="{{ old('latin_name', $species->latin_name) }}" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Kategori</label>
                <select name="category" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    <option value="hewan" {{ old('category', $species->category) == 'hewan' ? 'selected' : '' }}>Hewan</option>
                    <option value="tumbuhan" {{ old('category', $species->category) == 'tumbuhan' ? 'selected' : '' }}>Tumbuhan</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Rarity</label>
                <select name="rarity" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    <option value="common" {{ old('rarity', $species->rarity) == 'common' ? 'selected' : '' }}>Common</option>
                    <option value="rare" {{ old('rarity', $species->rarity) == 'rare' ? 'selected' : '' }}>Rare</option>
                    <option value="epic" {{ old('rarity', $species->rarity) == 'epic' ? 'selected' : '' }}>Epic</option>
                    <option value="legendary" {{ old('rarity', $species->rarity) == 'legendary' ? 'selected' : '' }}>Legendary</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Base CP</label>
                <input type="number" name="base_cp" value="{{ old('base_cp', $species->base_cp) }}" required min="10" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Habitat</label>
                <input type="text" name="habitat" value="{{ old('habitat', $species->habitat) }}" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Makanan</label>
                <input type="text" name="food" value="{{ old('food', $species->food) }}" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Status Konservasi</label>
            <input type="text" name="conservation_status" value="{{ old('conservation_status', $species->conservation_status) }}" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Peran Ekologi</label>
            <textarea name="ecological_role" rows="2" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">{{ old('ecological_role', $species->ecological_role) }}</textarea>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Fakta Menarik</label>
            <textarea name="fun_fact" rows="2" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">{{ old('fun_fact', $species->fun_fact) }}</textarea>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-emerald-900/30">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Ganti Thumbnail Gambar</label>
                @if($species->thumbnail_url)
                    <div class="mb-2 flex items-center gap-3">
                        <img src="{{ $species->thumbnail_url }}" alt="Thumbnail" class="w-12 h-12 rounded-lg object-cover">
                        <span class="text-xs text-slate-500">Gambar saat ini</span>
                    </div>
                @endif
                <input type="file" name="thumbnail_file" accept="image/*" class="block w-full text-xs text-slate-400 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-emerald-500/20 file:text-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Ganti Asset 3D Model</label>
                <input type="file" name="model_3d_file" class="block w-full text-xs text-slate-400 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-cyan-500/20 file:text-cyan-400">
            </div>
        </div>

        <div class="flex justify-end gap-4 pt-4">
            <a href="{{ route('admin.species.index') }}" class="px-6 py-3 rounded-xl bg-slate-800 text-slate-400 font-bold text-xs uppercase">Batal</a>
            <button type="submit" class="px-6 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/25">
                Update Spesies
            </button>
        </div>
    </form>
</div>
@endsection
