@extends('admin.layouts.app')

@section('title', 'Tambah Spesies Baru')

@section('content')
<div class="max-w-4xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
        <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">Form Tambah Spesies Baru</h3>
        <a href="{{ route('admin.species.index') }}" class="text-xs text-slate-400 hover:text-slate-200">← Kembali</a>
    </div>

    <form action="{{ route('admin.species.store') }}" method="POST" enctype="multipart/form-data" class="bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-6">
        @csrf

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Nama Spesies (Lokal)</label>
                <input type="text" name="name" value="{{ old('name') }}" required placeholder="Contoh: Harimau Sumatra" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Nama Latin</label>
                <input type="text" name="latin_name" value="{{ old('latin_name') }}" required placeholder="Contoh: Panthera tigris sumatrae" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Kategori</label>
                <select name="category" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    <option value="hewan" {{ old('category') == 'hewan' ? 'selected' : '' }}>Hewan</option>
                    <option value="tumbuhan" {{ old('category') == 'tumbuhan' ? 'selected' : '' }}>Tumbuhan</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Rarity</label>
                <select name="rarity" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    <option value="common" {{ old('rarity') == 'common' ? 'selected' : '' }}>Common (Abu-abu)</option>
                    <option value="rare" {{ old('rarity') == 'rare' ? 'selected' : '' }}>Rare (Biru)</option>
                    <option value="epic" {{ old('rarity') == 'epic' ? 'selected' : '' }}>Epic (Ungu)</option>
                    <option value="legendary" {{ old('rarity') == 'legendary' ? 'selected' : '' }}>Legendary (Kuning Gold)</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Base CP</label>
                <input type="number" name="base_cp" value="{{ old('base_cp', 500) }}" required min="10" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Habitat</label>
                <input type="text" name="habitat" value="{{ old('habitat') }}" required placeholder="Hutan Tropis Lembab" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Makanan (Opsional)</label>
                <input type="text" name="food" value="{{ old('food') }}" placeholder="Karnivora / Buah-buahan" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Status Konservasi (IUCN)</label>
            <input type="text" name="conservation_status" value="{{ old('conservation_status') }}" required placeholder="Contoh: Kritis (Critically Endangered)" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Peran Ekologi</label>
            <textarea name="ecological_role" rows="2" required placeholder="Jelaskan peran spesies ini di ekosistem..." class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">{{ old('ecological_role') }}</textarea>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Fakta Menarik</label>
            <textarea name="fun_fact" rows="2" required placeholder="Fakta unik dan edukatif spesies..." class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">{{ old('fun_fact') }}</textarea>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-emerald-900/30">
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Upload Thumbnail Gambar</label>
                <input type="file" name="thumbnail_file" accept="image/*" class="block w-full text-xs text-slate-400 file:mr-4 file:py-2.5 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-emerald-500/20 file:text-emerald-400 hover:file:bg-emerald-500/30 cursor-pointer">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Upload Asset 3D Model (Opsional)</label>
                <input type="file" name="model_3d_file" class="block w-full text-xs text-slate-400 file:mr-4 file:py-2.5 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-cyan-500/20 file:text-cyan-400 hover:file:bg-cyan-500/30 cursor-pointer">
            </div>
        </div>

        <div class="flex justify-end gap-4 pt-4">
            <a href="{{ route('admin.species.index') }}" class="px-6 py-3 rounded-xl bg-slate-800 text-slate-400 font-bold text-xs uppercase">Batal</a>
            <button type="submit" class="px-6 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/25">
                Simpan Spesies Baru
            </button>
        </div>
    </form>
</div>
@endsection
