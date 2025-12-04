<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\AdminController;

// Halaman Utama
Route::get('/', [DashboardController::class, 'index'])->name('admin.dashboard');

// Group Route Admin
Route::prefix('admin')->name('admin.')->group(function () {
    // Manajemen UMKM
    Route::get('/umkm', [AdminController::class, 'umkmIndex'])->name('umkm.index');
    Route::put('/umkm/{id}/verify', [AdminController::class, 'verifyUmkm'])->name('umkm.verify');

    // Manajemen Produk
    Route::get('/products', [AdminController::class, 'productIndex'])->name('products.index');
    Route::delete('/products/{id}', [AdminController::class, 'deleteProduct'])->name('products.delete');

    // Monitoring Transaksi
    Route::get('/transactions', [AdminController::class, 'transactionIndex'])->name('transactions.index');
});
