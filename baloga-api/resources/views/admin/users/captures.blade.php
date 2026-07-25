@extends('admin.layouts.app')

@section('title', 'History Log Penyelamatan Spesies')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">Log Penyelamatan Spesies oleh Ranger</h3>
    </div>

    <div class="bg-[#122018] border border-emerald-900/40 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-[#1A2D1F] text-slate-400 uppercase font-bold border-b border-emerald-900/30">
                    <tr>
                        <th class="p-4">ID</th>
                        <th class="p-4">Ranger</th>
                        <th class="p-4">Spesies Diselamatkan</th>
                        <th class="p-4">CP Result</th>
                        <th class="p-4">Koordinat Penyelamatan</th>
                        <th class="p-4">Waktu</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-emerald-900/20 text-slate-300">
                    @forelse($captures as $c)
                        <tr class="hover:bg-emerald-900/10 transition">
                            <td class="p-4 font-mono text-slate-500">#{{ $c->id }}</td>
                            <td class="p-4 font-bold text-emerald-400">{{ $c->user->name ?? 'User' }}</td>
                            <td class="p-4 font-bold text-slate-100">{{ $c->species->name ?? 'Spesies' }}</td>
                            <td class="p-4 font-black text-amber-400">{{ $c->cp_result }} CP</td>
                            <td class="p-4 text-slate-400 font-mono">{{ $c->latitude }}, {{ $c->longitude }}</td>
                            <td class="p-4 text-slate-500">{{ $c->captured_at ? $c->captured_at->format('d M Y, H:i') : $c->created_at->format('d M Y, H:i') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="p-6 text-center text-slate-500 font-semibold">Belum ada log penyelamatan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($captures->hasPages())
            <div class="p-4 border-t border-emerald-900/30">
                {{ $captures->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
