<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SpawnPoint extends Model
{
    use HasFactory;

    protected $fillable = [
        'species_id',
        'latitude',
        'longitude',
        'active',
        'respawn_minutes',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'active' => 'boolean',
        'respawn_minutes' => 'integer',
    ];

    public function species()
    {
        return $this->belongsTo(Species::class);
    }
}
