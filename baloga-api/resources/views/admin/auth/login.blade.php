<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Admin - Baloga AR Rescue</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;800;900&display=swap');
        body { font-family: 'Outfit', sans-serif; }
    </style>
</head>
<body class="bg-[#0A1A0E] text-slate-100 min-h-screen flex items-center justify-center p-4">

    <div class="w-full max-w-md bg-[#122018] border border-emerald-900/40 rounded-2xl p-8 shadow-2xl shadow-emerald-950/50">
        <!-- Logo -->
        <div class="text-center mb-8">
            <div class="w-16 h-16 rounded-full bg-emerald-500/20 border border-emerald-400 mx-auto flex items-center justify-center text-emerald-400 text-3xl mb-3 shadow-lg shadow-emerald-500/30">
                🌿
            </div>
            <h1 class="text-2xl font-black text-emerald-400 tracking-wider">BALOGA AR RESCUE</h1>
            <p class="text-xs text-emerald-600 font-semibold tracking-widest uppercase mt-1">Admin Portal Management</p>
        </div>

        @if($errors->any())
            <div class="mb-6 p-3.5 rounded-xl bg-red-500/15 border border-red-500/40 text-red-400 text-xs font-semibold">
                {{ $errors->first() }}
            </div>
        @endif

        <form action="{{ route('admin.login.submit') }}" method="POST" class="space-y-5">
            @csrf
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase tracking-wider">Email Administrator</label>
                <div class="relative">
                    <i class="fa-solid fa-envelope absolute left-4 top-3.5 text-slate-500 text-sm"></i>
                    <input type="email" name="email" value="{{ old('email') }}" required placeholder="admin@baloga.com" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl py-3 pl-11 pr-4 text-sm text-slate-100 placeholder-slate-600 focus:outline-none focus:border-emerald-400 transition">
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-400 mb-2 uppercase tracking-wider">Password</label>
                <div class="relative">
                    <i class="fa-solid fa-lock absolute left-4 top-3.5 text-slate-500 text-sm"></i>
                    <input type="password" name="password" required placeholder="••••••••" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl py-3 pl-11 pr-4 text-sm text-slate-100 placeholder-slate-600 focus:outline-none focus:border-emerald-400 transition">
                </div>
            </div>

            <button type="submit" class="w-full py-3.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-sm uppercase tracking-wider shadow-lg shadow-emerald-500/25 transition transform active:scale-95">
                Masuk ke Admin Panel
            </button>
        </form>
    </div>

</body>
</html>
