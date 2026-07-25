<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Capture extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'species_id',
        'captured_at',
        'latitude',
        'longitude',
        'cp_result',
    ];

    protected $casts = [
        'captured_at' => 'datetime',
        'latitude' => 'float',
        'longitude' => 'float',
        'cp_result' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function species()
    {
        return $this->belongsTo(Species::class);
    }
}
