<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    // [PENTING] Kita pakai $fillable agar lebih spesifik dan aman.
    // Pastikan 'metode_pembayaran' ada disini agar data dari Controller tersimpan.
protected $fillable = [
        'user_id',
        'umkm_profile_id',
        'total_harga',
        'status',
        'bukti_bayar',
        'metode_pembayaran', // <--- Pastikan ini ada
        'alamat_pengiriman', // <--- TAMBAHKAN INI JUGA
        'nomor_resi'
    ];

    // ==========================================
    // RELASI DATABASE
    // ==========================================

    // 1. Relasi ke User (Pembeli)
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    // 2. Relasi ke Barang-barang yang dibeli
    // Nama fungsi 'items' ini PENTING karena di Controller dipanggil: with(['items.product'])
    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class, 'order_id');
    }

    // 3. Relasi ke Toko (UMKM)
    // Ini dipakai Admin untuk menampilkan nama toko & notifikasi
    public function umkmProfile(): BelongsTo
    {
        return $this->belongsTo(UmkmProfile::class, 'umkm_profile_id');
    }
}
