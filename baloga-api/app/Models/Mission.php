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

    public function userMissions()
    {
        return $this->hasMany(UserMission::class);
    }
}
