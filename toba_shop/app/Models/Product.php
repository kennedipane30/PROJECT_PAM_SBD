<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes; // 1. Library sudah ada (Bagus)

class Product extends Model
{
    // 2. DISINI YANG KURANG: Tambahkan 'SoftDeletes' agar fitur aktif
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'umkm_profile_id',
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'kategori',
        'gambar'
    ];

    // Relasi: Produk milik 1 UMKM
    public function umkm() {
        return $this->belongsTo(UmkmProfile::class, 'umkm_profile_id');
    }

    // Relasi: Produk bisa ada di banyak detail order
    public function orderItems() {
        return $this->hasMany(OrderItem::class);
    }
}
