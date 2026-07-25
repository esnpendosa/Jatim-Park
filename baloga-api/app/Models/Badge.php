<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Badge extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'icon_url',
        'requirement_type',
        'requirement_value',
    ];

    protected $casts = [
        'requirement_value' => 'integer',
    ];

    public function userBadges()
    {
        return $this->hasMany(UserBadge::class);
    }
}
