<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SpeciesResource;
use App\Models\Species;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SpeciesController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $category = $request->query('category');
        $rarity = $request->query('rarity');

        $query = Species::query();

        if ($category) {
            $query->where('category', $category);
        }

        if ($rarity) {
            $query->where('rarity', $rarity);
        }

        $species = $query->get();

        return response()->json([
            'data' => SpeciesResource::collection($species),
        ]);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $species = Species::find($id);

        if (!$species) {
            return response()->json(['message' => 'Spesies tidak ditemukan'], 404);
        }

        return response()->json([
            'data' => new SpeciesResource($species),
        ]);
    }
}
