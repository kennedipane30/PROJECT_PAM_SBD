<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
// [PENTING] Jangan lupa import ini supaya tidak Error 500
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderItem extends Model
{
    // Agar bisa diisi massal oleh OrderItem::create([...]) di Controller
    protected $guarded = ['id'];

    // Relasi ke tabel 'orders'
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    // Relasi ke tabel 'products'
    // Ini PENTING agar di Controller bisa pakai: with('items.product')
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
