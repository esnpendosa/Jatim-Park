<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\Request;

class AdminSettingController extends Controller
{
    public function index()
    {
        $settings = [
            'app_name' => AppSetting::get('app_name', 'Baloga AR Rescue'),
            'app_tagline' => AppSetting::get('app_tagline', 'Penjaga Ekosistem Baloga'),
            'app_logo_url' => AppSetting::get('app_logo_url'),
            'api_domain' => AppSetting::get('api_domain', 'https://balago.rozitech.co.id'),
        ];

        return view('admin.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'app_name' => 'required|string|max:255',
            'app_tagline' => 'required|string|max:255',
            'api_domain' => 'required|string|max:255',
            'logo_file' => 'nullable|image|mimes:jpeg,png,jpg,svg,webp|max:4096',
        ]);

        AppSetting::set('app_name', $request->app_name);
        AppSetting::set('app_tagline', $request->app_tagline);
        AppSetting::set('api_domain', $request->api_domain);

        if ($request->hasFile('logo_file')) {
            $path = $request->file('logo_file')->store('app/logo', 'public');
            AppSetting::set('app_logo_url', asset('storage/' . $path));
        }

        return back()->with('success', 'Pengaturan & Branding Aplikasi berhasil diperbarui secara dinamis!');
    }
}
