<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CaptureAttemptRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'spawn_point_id' => 'required|exists:spawn_points,id',
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'item_id' => 'required|exists:items,id',
        ];
    }
}
