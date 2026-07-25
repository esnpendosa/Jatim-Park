<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;

class AppConfigController extends Controller
{
    public function getConfig(): JsonResponse
    {
        return response()->json([
            'app_name' => AppSetting::get('app_name', 'Baloga AR Rescue'),
            'app_tagline' => AppSetting::get('app_tagline', 'Penjaga Ekosistem Baloga'),
            'app_logo_url' => AppSetting::get('app_logo_url', 'https://api.dicebear.com/7.x/bottts/svg?seed=BalogaLogo'),
            'api_domain' => AppSetting::get('api_domain', 'https://balago.rozitech.co.id'),
        ]);
    }
}
