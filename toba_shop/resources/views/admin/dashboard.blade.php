@extends('layouts.admin')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>DASHBOARD</h2>
</div>

<!-- Statistik Cards -->
<div class="row g-3 mb-4">
    <!-- Card 1: Total Pendapatan -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm bg-primary text-white h-100">
            <div class="card-body">
                <h6 class="card-title">Total Pendapatan</h6>
                <h3 class="fw-bold">Rp {{ number_format($totalPendapatan, 0, ',', '.') }}</h3>
                <small><i class="fas fa-arrow-up"></i> Transaksi Selesai</small>
            </div>
        </div>
    </div>

    <!-- Card 2: UMKM Pending -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100 border-start border-4 border-warning">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h6 class="text-muted">Verifikasi UMKM</h6>
                        <h3 class="fw-bold text-warning">{{ $pendingUmkm }}</h3>
                        <small class="text-muted">Menunggu persetujuan</small>
                    </div>
                    <i class="fas fa-user-clock fa-2x text-warning opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Card 3: Total Users -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h6 class="text-muted">Total Pembeli</h6>
                        <h3 class="fw-bold">{{ $totalUsers }}</h3>
                        <small class="text-success">User Aktif</small>
                    </div>
                    <i class="fas fa-users fa-2x text-primary opacity-50"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Table Preview (Contoh Statis) -->
<div class="card border-0 shadow-sm">
    <div class="card-header bg-white py-3">
        <h5 class="mb-0">Statistik Sistem</h5>
    </div>
    <div class="card-body">
        <div class="row text-center">
            <div class="col-md-3">
                <h4 class="fw-bold">{{ $totalUmkm }}</h4>
                <p class="text-muted">Total Mitra UMKM</p>
            </div>
            <div class="col-md-3">
                <h4 class="fw-bold">{{ $totalProducts }}</h4>
                <p class="text-muted">Produk Terdaftar</p>
            </div>
            <div class="col-md-3">
                <h4 class="fw-bold">{{ $totalOrders }}</h4>
                <p class="text-muted">Total Order Masuk</p>
            </div>
        </div>
    </div>
</div>
@endsection
