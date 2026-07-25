<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\UserItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    public function getInventory(Request $request): JsonResponse
    {
        $user = $request->user();
        $capturedSpecies = $user->inventories()->with('species')->get();

        return response()->json([
            'data' => $capturedSpecies,
        ]);
    }

    public function getItems(Request $request): JsonResponse
    {
        $user = $request->user();
        $allItems = Item::all();

        $itemsWithQuantity = $allItems->map(function ($item) use ($user) {
            $userItem = UserItem::where('user_id', $user->id)
                ->where('item_id', $item->id)
                ->first();

            $item->quantity = $userItem ? $userItem->quantity : 0;
            return $item;
        });

        return response()->json([
            'data' => $itemsWithQuantity,
        ]);
    }
}
