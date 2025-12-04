<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UmkmProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'nama_usaha',
        'alamat_usaha',
        'foto_ktp',
        'status_verifikasi', // pending, approved, rejected
        'alasan_penolakan'
    ];

    // Relasi: Profil ini milik 1 User
    public function user() {
        return $this->belongsTo(User::class);
    }

    // Relasi: UMKM punya banyak Produk
    public function products() {
        return $this->hasMany(Product::class);
    }

    // Relasi: UMKM menerima banyak Order
    public function orders() {
        return $this->hasMany(Order::class);
    }
}
