<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\UmkmApiController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReviewController;

// =================================================================
// ROUTE PUBLIC (Bisa diakses siapa saja tanpa Login)
// =================================================================

// Autentikasi
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Produk
Route::get('/products', [ProductController::class, 'index']);


// =================================================================
// ROUTE PROTECTED (Harus Login & Punya Token 'Bearer')
// =================================================================
Route::middleware(['auth:sanctum'])->group(function () {

    // --- User & Profile ---
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // --- UMKM (Pendaftaran & Status) ---
    Route::get('/umkm/status', [UmkmApiController::class, 'checkStatus']);
    Route::post('/umkm/register', [UmkmApiController::class, 'register']);

    // --- Produk (Khusus Seller) ---
    Route::post('/products', [ProductController::class, 'store']);

    // =============================================================
    // --- TRANSAKSI (ORDER FLOW) ---
    // =============================================================

    // [BARU] DETAIL PESANAN
    // Digunakan saat notifikasi diklik untuk melihat rincian sebelum dikirim
    Route::get('/orders/{id}', [OrderController::class, 'show']);

    // 1. PEMBELI (Buyer)
    Route::post('/checkout', [OrderController::class, 'checkout']);             // Checkout
    Route::get('/my-orders', [OrderController::class, 'myOrders']);             // Riwayat Pesanan Pembeli
    Route::post('/orders/{id}/complete', [OrderController::class, 'completeOrder']); // Pembeli Klik "Pesanan Diterima"

    // 2. PENJUAL (UMKM)
    Route::get('/umkm/orders', [OrderController::class, 'getUmkmIncomingOrders']); // Dashboard UMKM: Lihat Pesanan Masuk
    Route::post('/umkm/orders/{id}/ship', [OrderController::class, 'shipOrder']);  // UMKM Klik "Kirim Barang" (Status -> dikirim)


    // --- Review / Ulasan ---
    Route::post('/reviews', [ReviewController::class, 'store']); // Pembeli beri rating setelah status 'selesai'

    // --- Notifikasi ---
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);

});
