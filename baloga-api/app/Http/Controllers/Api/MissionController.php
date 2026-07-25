<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mission;
use App\Models\UserMission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MissionController extends Controller
{
    public function getMissions(Request $request): JsonResponse
    {
        $user = $request->user();
        $allMissions = Mission::all();

        $missionsData = $allMissions->map(function ($mission) use ($user) {
            $userMission = UserMission::firstOrCreate(
                ['user_id' => $user->id, 'mission_id' => $mission->id],
                ['current_progress' => 0, 'is_completed' => false]
            );

            return [
                'id' => $mission->id,
                'title' => $mission->title,
                'description' => $mission->description,
                'type' => $mission->type,
                'target_count' => $mission->target_count,
                'xp_reward' => $mission->xp_reward,
                'icon_url' => $mission->icon_url,
                'current_progress' => min($userMission->current_progress, $mission->target_count),
                'is_completed' => $userMission->is_completed,
                'can_claim' => ($userMission->current_progress >= $mission->target_count && !$userMission->is_completed),
            ];
        });

        return response()->json([
            'data' => $missionsData,
        ]);
    }

    public function claimMission(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $mission = Mission::find($id);

        if (!$mission) {
            return response()->json(['message' => 'Misi tidak ditemukan'], 404);
        }

        $userMission = UserMission::where('user_id', $user->id)
            ->where('mission_id', $id)
            ->first();

        if (!$userMission || $userMission->current_progress < $mission->target_count) {
            return response()->json(['message' => 'Progress misi belum memenuhi syarat'], 400);
        }

        if ($userMission->is_completed) {
            return response()->json(['message' => 'Reward misi sudah diklaim sebelumnya'], 400);
        }

        $userMission->update(['is_completed' => true]);
        $user->increment('xp', $mission->xp_reward);
        $user->increment('points', $mission->xp_reward * 2);

        return response()->json([
            'success' => true,
            'message' => 'Reward misi berhasil diklaim!',
            'earned_xp' => $mission->xp_reward,
        ]);
    }
}
