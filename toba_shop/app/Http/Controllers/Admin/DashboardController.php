<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UmkmProfile;
use App\Models\Product;
use App\Models\Order;

class DashboardController extends Controller
{
    public function index()
    {
        // Menggunakan Aggregate Function (COUNT & SUM) sesuai syarat SBD
        $totalUsers = User::where('role', 'buyer')->count();
        $totalUmkm = UmkmProfile::count(); // Semua UMKM
        $pendingUmkm = UmkmProfile::where('status_verifikasi', 'pending')->count();
        $totalProducts = Product::count();
        $totalOrders = Order::count();
        $totalPendapatan = Order::where('status', 'completed')->sum('total_harga'); // Asumsi status 'completed'

        return view('admin.dashboard', compact(
            'totalUsers',
            'totalUmkm',
            'pendingUmkm',
            'totalProducts',
            'totalOrders',
            'totalPendapatan'
        ));
    }
}
