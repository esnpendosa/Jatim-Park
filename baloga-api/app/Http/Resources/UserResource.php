<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'avatar_url' => $this->avatar_url,
            'level' => $this->level,
            'xp' => $this->xp,
            'points' => $this->points,
            'species_found' => $this->species_found,
            'badges_count' => $this->badges_count,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
