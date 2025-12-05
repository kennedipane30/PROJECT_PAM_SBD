<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController; // Pastikan Import ini ada
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\AdminController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// 1. Saat user akses root '/', langsung arahkan ke halaman Login
Route::get('/', function () {
    return redirect()->route('login');
});

// 2. Route Authentication (Login & Logout)
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// 3. Group Route Admin (Hanya bisa diakses jika sudah Login)
Route::middleware(['auth'])->group(function () {

    // Dashboard (Halaman pertama setelah login)
    // Saya ubah URL-nya jadi '/dashboard' agar lebih rapi
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');

    // Group Prefix 'admin'
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

});
