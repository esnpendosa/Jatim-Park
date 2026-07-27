<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mission extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'type',
        'target_count',
        'xp_reward',
        'icon_url',
    ];

    protected $casts = [
        'target_count' => 'integer',
        'xp_reward' => 'integer',
    ];

    public function getIconUrlAttribute($value)
    {
        if (empty($value)) {
            return 'https://api.dicebear.com/7.x/bottts/svg?seed=' . urlencode($this->title);
        }

        if (str_contains($value, 'localhost') || str_contains($value, '127.0.0.1') || str_contains($value, '10.0.2.2')) {
            $path = parse_url($value, PHP_URL_PATH);
            return asset(ltrim($path, '/'));
        }

        if (!str_starts_with($value, 'http://') && !str_starts_with($value, 'https://')) {
            $localPath = public_path(ltrim($value, '/'));
            if (file_exists($localPath)) {
                return asset(ltrim($value, '/'));
            }
            return 'https://api.dicebear.com/7.x/bottts/svg?seed=' . urlencode($this->title);
        }

        return $value;
    }

    public function userMissions()
    {
        return $this->hasMany(UserMission::class);
    }
}
