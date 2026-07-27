<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'icon_url',
        'type',
    ];

    public function getIconUrlAttribute($value)
    {
        if (empty($value)) {
            return 'https://api.dicebear.com/7.x/bottts/svg?seed=' . urlencode($this->name);
        }

        if (str_contains($value, 'localhost') || str_contains($value, '127.0.0.1') || str_contains($value, '10.0.2.2')) {
            $path = parse_url($value, PHP_URL_PATH);
            return asset(ltrim($path, '/'));
        }

        if (!str_starts_with($value, 'http://') && !str_starts_with($value, 'https://')) {
            // Check if local public asset exists, else return reliable SVG icon
            $localPath = public_path(ltrim($value, '/'));
            if (file_exists($localPath)) {
                return asset(ltrim($value, '/'));
            }
            return 'https://api.dicebear.com/7.x/bottts/svg?seed=' . urlencode($this->name);
        }

        return $value;
    }

    public function userItems()
    {
        return $this->hasMany(UserItem::class);
    }
}
