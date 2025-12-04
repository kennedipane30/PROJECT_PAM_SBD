<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'product_id' => 'required|exists:products,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string'
        ]);

        // Cek apakah user adalah pembeli asli dari order ini
        $order = Order::find($request->order_id);
        if ($order->user_id != Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        Review::create([
            'user_id' => Auth::id(),
            'order_id' => $request->order_id,
            'product_id' => $request->product_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        return response()->json(['message' => 'Ulasan berhasil dikirim'], 201);
    }
}
