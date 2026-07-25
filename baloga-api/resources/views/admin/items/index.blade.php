@extends('admin.layouts.app')

@section('title', 'Manajemen Item & Eko-Sphere')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    <!-- Form Add Item -->
    <div class="lg:col-span-1 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6 space-y-4">
        <h3 class="text-sm font-bold text-emerald-400 uppercase tracking-wider">+ Tambah Item Baru</h3>
        <form action="{{ route('admin.items.store') }}" method="POST" enctype="multipart/form-data" class="space-y-4">
            @csrf
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Nama Item</label>
                <input type="text" name="name" required placeholder="Eko-Sphere Ultra" class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Tipe Item</label>
                <select name="type" required class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400">
                    <option value="capture_ball">Bola Penangkap (Capture Ball)</option>
                    <option value="scanner">Pemindai (Eco Scanner)</option>
                    <option value="radar">Radar (Nature Radar)</option>
                    <option value="booster">Booster XP (Lucky Leaf)</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Deskripsi Item</label>
                <textarea name="description" rows="3" required placeholder="Fungsi & keunggulan item ini..." class="w-full bg-[#1A2D1F] border border-emerald-900/50 rounded-xl p-3 text-sm text-slate-100 focus:outline-none focus:border-emerald-400"></textarea>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-400 mb-1.5 uppercase">Upload Icon Asset</label>
                <input type="file" name="icon_file" accept="image/*" class="block w-full text-xs text-slate-400 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-emerald-500/20 file:text-emerald-400">
            </div>
            <button type="submit" class="w-full py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs uppercase tracking-wider transition">
                Simpan Item Baru
            </button>
        </form>
    </div>

    <!-- Item List -->
    <div class="lg:col-span-2 bg-[#122018] border border-emerald-900/40 rounded-2xl p-6">
        <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider mb-4">Daftar Item Game Active</h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            @forelse($items as $it)
                <div class="p-4 rounded-xl bg-[#1A2D1F] border border-emerald-900/40 flex items-start justify-between">
                    <div class="flex items-start gap-3">
                        @if($it->icon_url)
                            <img src="{{ $it->icon_url }}" alt="{{ $it->name }}" class="w-10 h-10 rounded-lg object-cover">
                        @else
                            <div class="w-10 h-10 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center font-bold">🧪</div>
                        @endif
                        <div>
                            <p class="font-bold text-sm text-slate-100">{{ $it->name }}</p>
                            <span class="text-[10px] uppercase font-bold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded">{{ $it->type }}</span>
                            <p class="text-xs text-slate-400 mt-1">{{ $it->description }}</p>
                        </div>
                    </div>
                    <form action="{{ route('admin.items.destroy', $it->id) }}" method="POST" onsubmit="return confirm('Hapus item ini?')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="text-red-400 hover:text-red-300 p-1">
                            <i class="fa-solid fa-trash text-xs"></i>
                        </button>
                    </form>
                </div>
            @empty
                <p class="text-xs text-slate-500 col-span-2">Belum ada item terdaftar.</p>
            @endforelse
        </div>
    </div>

</div>
@endsection
