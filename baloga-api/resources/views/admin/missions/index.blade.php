@extends('admin.layouts.app')

@section('title', 'Manajemen Misi & Reward')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    <!-- Form Add Mission -->
    <div class="lg:col-span-1 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-4">
        <h3 class="text-sm font-bold text-emerald-400 uppercase tracking-wider">+ Tambah Misi Baru</h3>
        <form action="{{ route('admin.missions.store') }}" method="POST" class="space-y-4">
            @csrf
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Judul Misi</label>
                <input type="text" name="title" required placeholder="Penyelamat Flora" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Tipe Misi</label>
                <select name="type" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    <option value="daily">Harian (Daily)</option>
                    <option value="weekly">Mingguan (Weekly)</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Deskripsi Misi</label>
                <textarea name="description" rows="2" required placeholder="Temukan 3 tumbuhan langka..." class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400"></textarea>
            </div>
            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Target</label>
                    <input type="number" name="target_count" value="3" min="1" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Reward XP</label>
                    <input type="number" name="xp_reward" value="250" min="10" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                </div>
            </div>
            <button type="submit" class="w-full py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs uppercase tracking-wider transition">
                Simpan Misi Baru
            </button>
        </form>
    </div>

    <!-- Mission List -->
    <div class="lg:col-span-2 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6">
        <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider mb-4">Daftar Misi Aktif</h3>
        <div class="space-y-3">
            @forelse($missions as $m)
                <div class="p-4 rounded-xl bg-[#1A2D1F] border border-emerald-900/40 flex items-center justify-between">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="px-2 py-0.5 rounded text-[10px] font-extrabold uppercase {{ $m->type == 'daily' ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/30' : 'bg-purple-500/10 text-purple-400 border border-purple-500/30' }}">{{ $m->type }}</span>
                            <p class="font-bold text-slate-100 text-sm">{{ $m->title }}</p>
                        </div>
                        <p class="text-xs text-slate-400 mt-1">{{ $m->description }}</p>
                    </div>
                    <div class="flex items-center gap-4">
                        <div class="text-right">
                            <p class="text-xs font-black text-amber-400">+{{ $m->xp_reward }} XP</p>
                            <p class="text-[11px] text-slate-500">Target: {{ $m->target_count }}x</p>
                        </div>
                        <form action="{{ route('admin.missions.destroy', $m->id) }}" method="POST" onsubmit="return confirm('Hapus misi ini?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="text-red-400 hover:text-red-300 p-1">
                                <i class="fa-solid fa-trash text-xs"></i>
                            </button>
                        </form>
                    </div>
                </div>
            @empty
                <p class="text-xs text-slate-500">Belum ada misi terdaftar.</p>
            @endforelse
        </div>
    </div>

</div>
@endsection
