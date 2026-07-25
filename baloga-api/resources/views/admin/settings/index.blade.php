@extends('admin.layouts.app')

@section('title', 'Pengaturan & Branding Aplikasi')

@section('content')
<div class="max-w-3xl mx-auto space-y-6">
    <div class="flex items-center justify-between">
        <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider">Kelola Nama, Logo, & Configuration Aplikasi secara Dinamis</h3>
    </div>

    <form action="{{ route('admin.settings.update') }}" method="POST" enctype="multipart/form-data" class="bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-6">
        @csrf

        <!-- Preview Current Logo -->
        <div class="p-4 rounded-xl bg-[#1A2D1F] border border-emerald-900/30 flex items-center gap-4">
            @if($settings['app_logo_url'])
                <img src="{{ $settings['app_logo_url'] }}" alt="Logo App" class="w-16 h-16 rounded-full object-cover border border-emerald-400 p-1 bg-black">
            @else
                <div class="w-16 h-16 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center text-2xl font-bold border border-emerald-400">
                    🌿
                </div>
            @endif
            <div>
                <h4 class="font-extrabold text-slate-100 text-base">{{ $settings['app_name'] }}</h4>
                <p class="text-xs text-emerald-400">{{ $settings['app_tagline'] }}</p>
                <p class="text-[11px] text-slate-500 mt-1">Domain: {{ $settings['api_domain'] }}</p>
            </div>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Nama Aplikasi (Dynamic App Title)</label>
            <input type="text" name="app_name" value="{{ old('app_name', $settings['app_name']) }}" required placeholder="Baloga AR Rescue" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            <p class="text-[11px] text-slate-500 mt-1">Nama ini akan langsung tampil secara dinamis di seluruh header dan halaman Flutter app.</p>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Slogan / Tagline Aplikasi</label>
            <input type="text" name="app_tagline" value="{{ old('app_tagline', $settings['app_tagline']) }}" required placeholder="Penjaga Ekosistem Baloga" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Domain API Production</label>
            <input type="text" name="api_domain" value="{{ old('api_domain', $settings['api_domain']) }}" required placeholder="https://balago.rozitech.co.id" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            <p class="text-[11px] text-slate-500 mt-1">Mendukung protokol HTTP & HTTPS secara otomatis.</p>
        </div>

        <div>
            <label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Upload Logo / Icon Baru Aplikasi</label>
            <input type="file" name="logo_file" accept="image/*" class="block w-full text-xs text-slate-400 file:mr-4 file:py-2.5 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-emerald-500/20 file:text-emerald-400 hover:file:bg-emerald-500/30 cursor-pointer">
            <p class="text-[11px] text-slate-500 mt-1">Format gambar: PNG, JPG, SVG, WEBP (Max 4MB).</p>
        </div>

        <div class="flex justify-end pt-4">
            <button type="submit" class="px-6 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/25 transition">
                Simpan Perubahan Branding
            </button>
        </div>
    </form>
</div>
@endsection
