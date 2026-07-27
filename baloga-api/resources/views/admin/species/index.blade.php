@extends('admin.layouts.app')

@section('title', 'Manajemen Master Spesies')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">Daftar Hewan & Tumbuhan Baloga</h3>
        <a href="{{ route('admin.species.create') }}" class="px-4 py-2.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/20 transition">
            + Tambah Spesies Baru
        </a>
    </div>

    <div class="bg-[#122018] border border-emerald-900/40 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <blockquote class="bg-[#1A2D1F] text-slate-400 font-bold uppercase border-b border-emerald-900/30">
                    <tr class="bg-[#1A2D1F] text-slate-400 font-bold uppercase border-b border-emerald-900/30">
                        <th class="p-4">Thumbnail</th>
                        <th class="p-4">Nama & Nama Latin</th>
                        <th class="p-4">Kategori</th>
                        <th class="p-4">Rarity</th>
                        <th class="p-4">Base CP</th>
                        <th class="p-4">Status Konservasi</th>
                        <th class="p-4 text-center">Aksi</th>
                    </tr>
                </blockquote>
                <tbody class="divide-y divide-emerald-900/20 text-slate-300">
                    @forelse($species as $s)
                        <tr class="hover:bg-emerald-900/10 transition">
                            <td class="p-4">
                                @if($s->thumbnail_url)
                                    <img src="{{ $s->thumbnail_url }}" alt="{{ $s->name }}" class="w-12 h-12 rounded-xl object-cover border border-emerald-900/50" onerror="this.onerror=null; this.src='https://api.dicebear.com/7.x/bottts/svg?seed={{ urlencode($s->name) }}';">
                                @else
                                    <div class="w-12 h-12 rounded-xl bg-[#1A2D1F] flex items-center justify-center text-slate-600 font-bold text-lg">🌱</div>
                                @endif
                            </td>
                            <td class="p-4">
                                <p class="font-bold text-slate-100 text-sm">{{ $s->name }}</p>
                                <p class="text-emerald-500 italic text-xs">{{ $s->latin_name }}</p>
                            </td>
                            <td class="p-4">
                                <span class="px-2.5 py-1 rounded-full text-[11px] font-bold uppercase {{ $s->category == 'hewan' ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/30' : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30' }}">
                                    {{ $s->category }}
                                </span>
                            </td>
                            <td class="p-4">
                                <span class="px-2.5 py-1 rounded-full text-[11px] font-extrabold uppercase 
                                    {{ $s->rarity == 'legendary' ? 'bg-amber-400/20 text-amber-300 border border-amber-400/50' : 
                                       ($s->rarity == 'epic' ? 'bg-purple-500/20 text-purple-300 border border-purple-500/50' : 
                                       ($s->rarity == 'rare' ? 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/50' : 'bg-slate-500/20 text-slate-400')) }}">
                                    {{ $s->rarity }}
                                </span>
                            </td>
                            <td class="p-4 font-extrabold text-amber-400">{{ $s->base_cp }} CP</td>
                            <td class="p-4 text-slate-400">{{ $s->conservation_status }}</td>
                            <td class="p-4 text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <a href="{{ route('admin.species.edit', $s->id) }}" class="p-2 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 transition" title="Edit">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <form action="{{ route('admin.species.destroy', $s->id) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin menghapus spesies ini?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-2 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 transition" title="Hapus">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="p-6 text-center text-slate-500 font-semibold">Belum ada data spesies. Silakan tambah spesies baru.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($species->hasPages())
            <div class="p-4 border-t border-emerald-900/30">
                {{ $species->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
