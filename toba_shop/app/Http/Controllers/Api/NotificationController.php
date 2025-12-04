<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    public function index()
    {
        // CARA BENAR (Custom): Cari berdasarkan user_id
        $notifications = Notification::where('user_id', Auth::id())
                                     ->orderBy('created_at', 'desc')
                                     ->get();

        // JANGAN PAKAI INI: $user->notifications (Ini fitur bawaan Laravel yang bikin error)

        return response()->json($notifications);
    }

    public function markAsRead($id)
    {
        $notification = Notification::where('id', $id)
                                    ->where('user_id', Auth::id())
                                    ->first();

        if ($notification) {
            $notification->update(['is_read' => true]);
            return response()->json(['message' => 'Ditandai sudah dibaca']);
        }

        return response()->json(['message' => 'Notifikasi tidak ditemukan'], 404);
    }

    public function markAllRead()
    {
        Notification::where('user_id', Auth::id())
                    ->update(['is_read' => true]);

        return response()->json(['message' => 'Semua ditandai sudah dibaca']);
    }
}
