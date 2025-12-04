<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DASHBOARD</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .sidebar {
            min-height: 100vh;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .nav-link { color: #333; font-weight: 500; }
        /* Style saat menu aktif atau di-hover */
        .nav-link:hover, .nav-link.active {
            background-color: #0d6efd;
            color: white !important;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 bg-white sidebar p-3">
                <h4 class="text-primary fw-bold mb-4"><i class="fas fa-shopping-basket"></i> Toba Food</h4>

                <ul class="nav flex-column gap-2">
                    <!-- 1. DASHBOARD -->
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"
                           href="{{ route('admin.dashboard') }}">
                            <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                        </a>
                    </li>

                    <!-- 2. VERIFIKASI UMKM -->
                    <li class="nav-item">
                        <!-- Active jika route mengandung kata 'admin.umkm' -->
                        <a class="nav-link {{ request()->routeIs('admin.umkm.*') ? 'active' : '' }}"
                           href="{{ route('admin.umkm.index') }}">
                            <i class="fas fa-store me-2"></i> Verifikasi UMKM
                        </a>
                    </li>

                    <!-- 3. DATA PRODUK -->
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('admin.products.*') ? 'active' : '' }}"
                           href="{{ route('admin.products.index') }}">
                            <i class="fas fa-box me-2"></i> Data Produk
                        </a>
                    </li>

                    <!-- 4. MONITORING TRANSAKSI (Menggantikan Data User) -->
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('admin.transactions.*') ? 'active' : '' }}"
                           href="{{ route('admin.transactions.index') }}">
                            <i class="fas fa-receipt me-2"></i> Transaksi
                        </a>
                    </li>

                    <!-- 5. LOGOUT (Sementara redirect ke home) -->
                    <li class="nav-item mt-4">
                        <a class="nav-link text-danger" href="#">
                            <i class="fas fa-sign-out-alt me-2"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 p-4">
                @yield('content')
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
