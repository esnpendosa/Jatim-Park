<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Species extends Model
{
    use HasFactory;

    protected $table = 'species';

    protected $fillable = [
        'name',
        'latin_name',
        'category',
        'rarity',
        'habitat',
        'food',
        'ecological_role',
        'conservation_status',
        'fun_fact',
        'model_3d_url',
        'thumbnail_url',
        'base_cp',
    ];

    protected $casts = [
        'base_cp' => 'integer',
    ];

    public function getThumbnailUrlAttribute($value)
    {
        if (empty($value)) {
            return 'https://api.dicebear.com/7.x/bottts/svg?seed=' . urlencode($this->name);
        }

        // If thumbnail points to known broken local test file name from early testing
        if (str_contains($value, 'thumb_1785117408_0b3wel')) {
            return 'https://images.unsplash.com/photo-1534188753412-3e26d0d618d6?w=500';
        }

        // Fix local host IP in stored URLs when running on live domain
        if (str_contains($value, 'localhost') || str_contains($value, '127.0.0.1') || str_contains($value, '10.0.2.2')) {
            $path = parse_url($value, PHP_URL_PATH);
            return asset(ltrim($path, '/'));
        }

        // Relative path
        if (!str_starts_with($value, 'http://') && !str_starts_with($value, 'https://')) {
            return asset('storage/' . ltrim($value, '/'));
        }

        return $value;
    }

    public function getModel3dUrlAttribute($value)
    {
        if (empty($value)) return null;

        if (str_contains($value, 'localhost') || str_contains($value, '127.0.0.1') || str_contains($value, '10.0.2.2')) {
            $path = parse_url($value, PHP_URL_PATH);
            return asset(ltrim($path, '/'));
        }

        if (!str_starts_with($value, 'http://') && !str_starts_with($value, 'https://')) {
            return asset('storage/' . ltrim($value, '/'));
        }

        return $value;
    }

    public function spawnPoints()
    {
        return $this->hasMany(SpawnPoint::class);
    }

    public function captures()
    {
        return $this->hasMany(Capture::class);
    }

    public function inventories()
    {
        return $this->hasMany(Inventory::class);
    }
}
