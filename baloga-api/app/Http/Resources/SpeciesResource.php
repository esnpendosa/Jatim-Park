<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SpeciesResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $user = $request->user();
        $isDiscovered = false;

        if ($user) {
            $isDiscovered = $user->inventories()->where('species_id', $this->id)->exists();
        }

        return [
            'id' => $this->id,
            'name' => $this->name,
            'latin_name' => $this->latin_name,
            'category' => $this->category,
            'rarity' => $this->rarity,
            'habitat' => $this->habitat,
            'food' => $this->food,
            'ecological_role' => $this->ecological_role,
            'conservation_status' => $this->conservation_status,
            'fun_fact' => $this->fun_fact,
            'model_3d_url' => $this->model_3d_url,
            'thumbnail_url' => $this->thumbnail_url,
            'base_cp' => $this->base_cp,
            'is_discovered' => $isDiscovered,
        ];
    }
}
