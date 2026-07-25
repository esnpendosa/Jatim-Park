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
