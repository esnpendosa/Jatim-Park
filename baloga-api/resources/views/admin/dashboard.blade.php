@extends('admin.layouts.app')

@section('title', 'Dashboard Overview')

@section('content')
<div class="space-y-6">

    <!-- Stat Cards Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <div class="p-5 rounded-2xl bg-[#122018] border border-emerald-900/40">
            <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-400 uppercase">Ranger User</span>
                <i class="fa-solid fa-users text-emerald-400"></i>
            </div>
            <p class="text-2xl font-black text-emerald-400 mt-2">{{ $stats['total_users'] }}</p>
        </div>
        <div class="p-5 rounded-2xl bg-[#122018] border border-emerald-900/40">
            <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-400 uppercase">Total Spesies</span>
                <i class="fa-solid fa-paw text-amber-400"></i>
            </div>
            <p class="text-2xl font-black text-amber-400 mt-2">{{ $stats['total_species'] }}</p>
        </div>
        <div class="p-5 rounded-2xl bg-[#122018] border border-emerald-900/40">
            <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-400 uppercase">Total Capture</span>
                <i class="fa-solid fa-hand-holding-heart text-cyan-400"></i>
            </div>
            <p class="text-2xl font-black text-cyan-400 mt-2">{{ $stats['total_captures'] }}</p>
        </div>
        <div class="p-5 rounded-2xl bg-[#122018] border border-emerald-900/40">
            <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-400 uppercase">Spawn Points</span>
                <i class="fa-solid fa-location-dot text-rose-400"></i>
            </div>
            <p class="text-2xl font-black text-rose-400 mt-2">{{ $stats['total_spawn_points'] }}</p>
        </div>
        <div class="p-5 rounded-2xl bg-[#122018] border border-emerald-900/40">
            <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-400 uppercase">Total Item</span>
                <i class="fa-solid fa-vial text-purple-400"></i>
            </div>
            <p class="text-2xl font-black text-purple-400 mt-2">{{ $stats['total_items'] }}</p>
        </div>
        <div class="p-5 rounded-2xl bg-[#122018] border border-emerald-900/40">
            <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-400 uppercase">Aktif Misi</span>
                <i class="fa-solid fa-trophy text-emerald-400"></i>
            </div>
            <p class="text-2xl font-black text-emerald-400 mt-2">{{ $stats['total_missions'] }}</p>
        </div>
    </div>

    <!-- Activity Section Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        <!-- Latest Captures Log -->
        <div class="lg:col-span-2 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="font-bold text-slate-200 text-sm uppercase tracking-wider">Aktivitas Penyelamatan Terkini</h3>
                <a href="{{ route('admin.captures.index') }}" class="text-xs text-emerald-400 font-semibold hover:underline">Lihat Semua Log →</a>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-xs">
                    <thead class="bg-[#1A2D1F] text-slate-400 uppercase font-bold">
                        <tr>
                            <th class="p-3">Ranger</th>
                            <th class="p-3">Spesies Diselamatkan</th>
                            <th class="p-3">CP Result</th>
                            <th class="p-3">Waktu</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-emerald-900/20 text-slate-300">
                        @forelse($latestCaptures as $c)
                            <tr>
                                <td class="p-3 font-semibold text-emerald-400">{{ $c->user->name ?? 'User' }}</td>
                                <td class="p-3 font-medium">{{ $c->species->name ?? 'Spesies' }}</td>
                                <td class="p-3"><span class="px-2 py-1 rounded bg-emerald-500/10 text-emerald-400 font-bold">{{ $c->cp_result }} CP</span></td>
                                <td class="p-3 text-slate-500">{{ $c->created_at->diffForHumans() }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="p-4 text-center text-slate-500">Belum ada aktivitas capture.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Recent Rangers -->
        <div class="bg-[#122018] border border-emerald-900/40 rounded-2xl p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="font-bold text-slate-200 text-sm uppercase tracking-wider">Ranger Terdaftar</h3>
                <a href="{{ route('admin.users.index') }}" class="text-xs text-emerald-400 font-semibold hover:underline">Lihat Semua →</a>
            </div>
            <div class="space-y-3">
                @forelse($recentUsers as $u)
                    <div class="p-3 rounded-xl bg-[#1A2D1F] border border-emerald-900/30 flex items-center justify-between">
                        <div>
                            <p class="font-bold text-sm text-slate-200">{{ $u->name }}</p>
                            <p class="text-xs text-slate-500">{{ $u->email }}</p>
                        </div>
                        <span class="text-xs font-black text-amber-400 px-2 py-1 rounded bg-amber-400/10">Lv.{{ $u->level }}</span>
                    </div>
                @empty
                    <p class="text-xs text-slate-500">Belum ada Ranger terdaftar.</p>
                @endforelse
            </div>
        </div>

    </div>

</div>
@endsection
