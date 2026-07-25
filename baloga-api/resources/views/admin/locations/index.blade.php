@extends('admin.layouts.app')

@section('title', 'Manajemen Lokasi & Spawn Points')

@section('content')
<div class="space-y-8">

    <!-- Game Location Section -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-1 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-4">
            <h3 class="text-sm font-bold text-emerald-400 uppercase tracking-wider">+ Tambah Area Game Baloga</h3>
            <form action="{{ route('admin.locations.store') }}" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Nama Area</label>
                    <input type="text" name="name" required placeholder="Batu Love Garden (Baloga)" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Latitude</label>
                        <input type="text" name="latitude" required placeholder="-7.892543" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Longitude</label>
                        <input type="text" name="longitude" required placeholder="112.548972" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Radius Area (Meter)</label>
                    <input type="number" name="radius_meters" value="1000" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                </div>
                <button type="submit" class="w-full py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs uppercase tracking-wider transition">
                    Simpan Area Game
                </button>
            </form>
        </div>

        <div class="lg:col-span-2 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6">
            <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider mb-4">Area Game Terdaftar</h3>
            <div class="space-y-3">
                @forelse($locations as $loc)
                    <div class="p-4 rounded-xl bg-[#1A2D1F] border border-emerald-900/30 flex items-center justify-between">
                        <div>
                            <p class="font-bold text-slate-100">{{ $loc->name }}</p>
                            <p class="text-xs text-slate-400">Lat: {{ $loc->latitude }}, Lng: {{ $loc->longitude }}</p>
                        </div>
                        <span class="px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-xs font-bold">
                            Radius: {{ $loc->radius_meters }}m
                        </span>
                    </div>
                @empty
                    <p class="text-xs text-slate-500">Belum ada area game terdaftar.</p>
                @endforelse
            </div>
        </div>
    </div>

    <!-- Spawn Points Section -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 pt-4 border-t border-emerald-900/30">
        <div class="lg:col-span-1 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-4">
            <h3 class="text-sm font-bold text-cyan-400 uppercase tracking-wider">+ Tambah Monster Spawn Point</h3>
            <form action="{{ route('admin.spawn_points.store') }}" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Pilih Spesies Monster</label>
                    <select name="species_id" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                        @foreach($species as $sp)
                            <option value="{{ $sp->id }}">{{ $sp->name }} ({{ strtoupper($sp->rarity) }})</option>
                        @endforeach
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Latitude</label>
                        <input type="text" name="latitude" required placeholder="-7.892600" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Longitude</label>
                        <input type="text" name="longitude" required placeholder="112.549000" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Respawn (Menit)</label>
                    <input type="number" name="respawn_minutes" value="15" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                </div>
                <button type="submit" class="w-full py-3 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-black text-xs uppercase tracking-wider transition">
                    Simpan Spawn Point
                </button>
            </form>
        </div>

        <div class="lg:col-span-2 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6">
            <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider mb-4">Spawn Points Aktif di Map</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-xs">
                    <thead class="bg-[#1A2D1F] text-slate-400 uppercase font-bold">
                        <tr>
                            <th class="p-3">Spesies</th>
                            <th class="p-3">Koordinat GPS</th>
                            <th class="p-3">Respawn</th>
                            <th class="p-3 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-emerald-900/20 text-slate-300">
                        @forelse($spawnPoints as $pt)
                            <tr>
                                <td class="p-3 font-bold text-slate-100">{{ $pt->species->name ?? 'Unmapped' }}</td>
                                <td class="p-3 text-slate-400">{{ $pt->latitude }}, {{ $pt->longitude }}</td>
                                <td class="p-3 text-amber-400 font-semibold">{{ $pt->respawn_minutes }} mnt</td>
                                <td class="p-3 text-center">
                                    <form action="{{ route('admin.spawn_points.destroy', $pt->id) }}" method="POST" onsubmit="return confirm('Hapus spawn point ini?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="p-4 text-center text-slate-500">Belum ada spawn point aktif.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
            @if($spawnPoints->hasPages())
                <div class="p-3 border-t border-emerald-900/30">
                    {{ $spawnPoints->links() }}
                </div>
            @endif
        </div>
    </div>

</div>
@endsection
