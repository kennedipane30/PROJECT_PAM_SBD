@extends('layouts.admin')

@section('content')
<div class="container-fluid">
    <h3 class="mb-4 fw-bold">Manajemen Produk</h3>

    <!-- Statistik Produk Populer (Aggregate Function) -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm bg-primary text-white">
                <div class="card-body">
                    <h5 class="card-title mb-3"><i class="fas fa-chart-line"></i> 5 Produk Terpopuler</h5>
                    <ul class="list-group list-group-flush rounded">
                        @foreach($popularProducts as $pp)
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            {{ $pp->product->nama_produk ?? 'Produk Dihapus' }}
                            <span class="badge bg-primary rounded-pill">{{ $pp->total_terjual }} Terjual</span>
                        </li>
                        @endforeach
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabel Semua Produk -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3">
            <h5 class="mb-0">Daftar Semua Produk UMKM</h5>
        </div>
        <div class="card-body">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>Produk</th>
                        <th>Harga</th>
                        <th>Stok</th>
                        <th>Toko (UMKM)</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($products as $product)
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                @if($product->gambar)
                                    <img src="{{ asset('storage/'.$product->gambar) }}" class="rounded me-2" width="40" height="40" style="object-fit:cover">
                                @else
                                    <div class="bg-secondary rounded me-2" style="width:40px;height:40px;"></div>
                                @endif
                                <div>
                                    <div class="fw-bold">{{ $product->nama_produk }}</div>
                                    <small class="text-muted">{{ $product->kategori }}</small>
                                </div>
                            </div>
                        </td>
                        <td>Rp {{ number_format($product->harga, 0, ',', '.') }}</td>
                        <td>{{ $product->stok }}</td>
                        <td>{{ $product->umkm->nama_usaha ?? '-' }}</td>
                        <td>
                            <form action="{{ route('admin.products.delete', $product->id) }}" method="POST" onsubmit="return confirm('Yakin hapus produk ini? (Melanggar Aturan)')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                    <i class="fas fa-trash"></i> Hapus
                                </button>
                            </form>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>

            <!-- Pagination -->
            <div class="mt-3">
                {{ $products->links('pagination::bootstrap-5') }}
            </div>
        </div>
    </div>
</div>
@endsection
