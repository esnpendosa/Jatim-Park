<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserMission extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'mission_id',
        'current_progress',
        'is_completed',
        'reset_at',
    ];

    protected $casts = [
        'current_progress' => 'integer',
        'is_completed' => 'boolean',
        'reset_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mission()
    {
        return $this->belongsTo(Mission::class);
    }
}
