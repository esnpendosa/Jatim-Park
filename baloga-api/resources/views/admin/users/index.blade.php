@extends('admin.layouts.app')

@section('title', 'Daftar Ranger (Users)')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">Ranger Terdaftar di Baloga AR Rescue</h3>
    </div>

    <div class="bg-[#122018] border border-emerald-900/40 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-[#1A2D1F] text-slate-400 uppercase font-bold border-b border-emerald-900/30">
                    <tr>
                        <th class="p-4">Ranger Name</th>
                        <th class="p-4">Email</th>
                        <th class="p-4">Level</th>
                        <th class="p-4">XP</th>
                        <th class="p-4">Poin</th>
                        <th class="p-4">Spesies Ditemukan</th>
                        <th class="p-4">Terdaftar</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-emerald-900/20 text-slate-300">
                    @forelse($users as $u)
                        <tr class="hover:bg-emerald-900/10 transition">
                            <td class="p-4 font-bold text-slate-100 flex items-center gap-3">
                                <div class="w-8 h-8 rounded-full bg-emerald-500/20 border border-emerald-400 flex items-center justify-center font-bold text-xs text-emerald-400">
                                    {{ strtoupper(substr($u->name, 0, 1)) }}
                                </div>
                                <span>{{ $u->name }}</span>
                            </td>
                            <td class="p-4 text-slate-400">{{ $u->email }}</td>
                            <td class="p-4 font-black text-emerald-400">Lv.{{ $u->level }}</td>
                            <td class="p-4 font-semibold text-amber-400">{{ $u->xp }} XP</td>
                            <td class="p-4 font-semibold text-cyan-400">{{ $u->points }} Pts</td>
                            <td class="p-4 font-semibold text-purple-400">{{ $u->species_found }} Spesies</td>
                            <td class="p-4 text-slate-500">{{ $u->created_at->format('d M Y, H:i') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="p-6 text-center text-slate-500 font-semibold">Belum ada Ranger terdaftar.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($users->hasPages())
            <div class="p-4 border-t border-emerald-900/30">
                {{ $users->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
