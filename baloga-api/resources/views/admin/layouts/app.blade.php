<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Panel') - Baloga AR Rescue</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap');
        body { font-family: 'Outfit', sans-serif; }
    </style>
</head>
<body class="bg-[#0A1A0E] text-slate-100 min-h-screen flex">

    <!-- Sidebar -->
    <aside class="w-64 bg-[#122018] border-r border-emerald-900/40 flex flex-col justify-between hidden md:flex">
        <div>
            <!-- Brand -->
            <div class="p-6 border-b border-emerald-900/30 flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-emerald-500/20 border border-emerald-400 flex items-center justify-center text-emerald-400 font-black text-xl shadow-lg shadow-emerald-500/20">
                    🌿
                </div>
                <div>
                    <h1 class="font-extrabold text-lg text-emerald-400 tracking-wider">BALOGA AR</h1>
                    <p class="text-xs text-emerald-600 font-semibold tracking-widest uppercase">Admin Portal</p>
                </div>
            </div>

            <!-- Navigation -->
            <nav class="p-4 space-y-1.5">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.dashboard') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-chart-line w-5 text-center"></i>
                    <span>Dashboard</span>
                </a>
                <a href="{{ route('admin.species.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.species.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-paw w-5 text-center"></i>
                    <span>Master Spesies</span>
                </a>
                <a href="{{ route('admin.locations.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.locations.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-map-location-dot w-5 text-center"></i>
                    <span>Lokasi & Spawn</span>
                </a>
                <a href="{{ route('admin.items.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.items.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-vial w-5 text-center"></i>
                    <span>Item & Eko-Sphere</span>
                </a>
                <a href="{{ route('admin.missions.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.missions.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-trophy w-5 text-center"></i>
                    <span>Misi & Reward</span>
                </a>
                <a href="{{ route('admin.users.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.users.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-users w-5 text-center"></i>
                    <span>Ranger (Users)</span>
                </a>
                <a href="{{ route('admin.captures.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.captures.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-clock-rotate-left w-5 text-center"></i>
                    <span>History Capture</span>
                </a>
                <a href="{{ route('admin.settings.index') }}" class="flex items-center gap-3 px-4 py-3 rounded-xl transition {{ request()->routeIs('admin.settings.*') ? 'bg-emerald-500/15 text-emerald-400 font-bold border border-emerald-500/30' : 'text-slate-400 hover:bg-emerald-900/20 hover:text-slate-200' }}">
                    <i class="fa-solid fa-gear w-5 text-center"></i>
                    <span>Branding & Settings</span>
                </a>
            </nav>
        </div>

        <!-- Footer User -->
        <div class="p-4 border-t border-emerald-900/30">
            <div class="flex items-center justify-between bg-[#1A2D1F] p-3 rounded-xl border border-emerald-900/40">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-emerald-600 text-white font-bold flex items-center justify-center text-xs">
                        A
                    </div>
                    <div class="text-xs">
                        <p class="font-bold text-slate-200">{{ auth()->user()->name ?? 'Admin' }}</p>
                        <p class="text-emerald-500">Administrator</p>
                    </div>
                </div>
                <form action="{{ route('admin.logout') }}" method="POST">
                    @csrf
                    <button type="submit" title="Logout" class="text-slate-400 hover:text-red-400 transition p-1">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </button>
                </form>
            </div>
        </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
        <!-- Topbar -->
        <header class="h-16 bg-[#122018] border-b border-emerald-900/30 flex items-center justify-between px-6">
            <h2 class="text-lg font-bold text-slate-100">@yield('title', 'Dashboard')</h2>
            <div class="flex items-center gap-4">
                <span class="text-xs px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 font-semibold">
                    🟢 REST API Sync: ONLINE
                </span>
            </div>
        </header>

        <!-- Content -->
        <main class="flex-1 p-6 overflow-y-auto">
            @if(session('success'))
                <div class="mb-6 p-4 rounded-xl bg-emerald-500/20 border border-emerald-500/50 text-emerald-300 flex items-center gap-3">
                    <i class="fa-solid fa-circle-check text-emerald-400 text-lg"></i>
                    <p class="font-semibold text-sm">{{ session('success') }}</p>
                </div>
            @endif

            @if($errors->any())
                <div class="mb-6 p-4 rounded-xl bg-red-500/20 border border-red-500/50 text-red-300">
                    <div class="flex items-center gap-2 font-bold mb-1">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span>Terjadi Kesalahan:</span>
                    </div>
                    <ul class="list-disc list-inside text-xs space-y-1">
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            @yield('content')
        </main>
    </div>

</body>
</html>
