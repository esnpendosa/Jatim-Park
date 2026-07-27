<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    use HasFactory;

    protected $fillable = ['key', 'value'];

    public static function get(string $key, ?string $default = null): ?string
    {
        $setting = static::where('key', $key)->first();
        $value = $setting ? $setting->value : $default;

        if ($key === 'app_logo_url' && !empty($value)) {
            if (str_contains($value, 'localhost') || str_contains($value, '127.0.0.1') || str_contains($value, '10.0.2.2')) {
                $path = parse_url($value, PHP_URL_PATH);
                return asset(ltrim($path, '/'));
            }
        }

        return $value;
    }

    public static function set(string $key, ?string $value): void
    {
        static::updateOrCreate(['key' => $key], ['value' => $value]);
    }
}
