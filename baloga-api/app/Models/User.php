<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar_url',
        'level',
        'xp',
        'points',
        'species_found',
        'badges_count',
        'is_admin',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'level' => 'integer',
            'xp' => 'integer',
            'points' => 'integer',
            'species_found' => 'integer',
            'badges_count' => 'integer',
            'is_admin' => 'boolean',
        ];
    }

    public function captures()
    {
        return $this->hasMany(Capture::class);
    }

    public function inventories()
    {
        return $this->hasMany(Inventory::class);
    }

    public function userItems()
    {
        return $this->hasMany(UserItem::class);
    }

    public function userMissions()
    {
        return $this->hasMany(UserMission::class);
    }

    public function userBadges()
    {
        return $this->hasMany(UserBadge::class);
    }
}
