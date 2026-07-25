<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Capture;
use App\Models\User;

class AdminUserController extends Controller
{
    public function index()
    {
        $users = User::where('is_admin', false)->orderBy('id', 'desc')->paginate(15);
        return view('admin.users.index', compact('users'));
    }

    public function captures()
    {
        $captures = Capture::with(['user', 'species'])->orderBy('id', 'desc')->paginate(20);
        return view('admin.users.captures', compact('captures'));
    }
}
