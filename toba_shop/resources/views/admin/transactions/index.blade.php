@extends('layouts.admin')

@section('content')
<div class="container-fluid">
    <h3 class="mb-4 fw-bold">Monitoring Transaksi (Selesai)</h3>

    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>ID Order</th>
                            <th>Tanggal</th>
                            <th>Pembeli</th>
                            <!-- Kolom Toko (UMKM) Dihapus -->
                            <th>Total</th>
                            <th>Status</th>
                            <th>Metode Bayar</th>
                            <th>Bukti Bayar / Info</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($orders as $order)
                        <tr>
                            <td>#{{ $order->id }}</td>
                            <td>{{ $order->created_at->format('d M Y H:i') }}</td>

                            <!-- Menampilkan Nama Pembeli -->
                            <td>
                                {{ $order->user->name ?? 'User Hapus' }} <br>
                                <small class="text-muted">{{ $order->user->email ?? '-' }}</small>
                            </td>

                            <!-- Kolom Data Toko (UMKM) Dihapus -->

                            <td class="fw-bold">Rp {{ number_format($order->total_harga, 0, ',', '.') }}</td>

                            <!-- Badge Status -->
                            <td>
                                @if($order->status == 'pending')
                                    <span class="badge bg-secondary">Menunggu</span>
                                @elseif($order->status == 'processing' || $order->status == 'diproses')
                                    <span class="badge bg-info text-dark">Diproses</span>
                                @elseif($order->status == 'selesai' || $order->status == 'completed')
                                    <span class="badge bg-success">Selesai</span>
                                @elseif($order->status == 'batal' || $order->status == 'cancelled')
                                    <span class="badge bg-danger">Batal</span>
                                @else
                                    <span class="badge bg-light text-dark">{{ $order->status }}</span>
                                @endif
                            </td>

                            <!-- Metode Pembayaran -->
                            <td>
                                @php
                                    $metode = strtolower($order->metode_pembayaran ?? '');
                                @endphp

                                @if($metode == 'cod')
                                    <span class="badge bg-warning text-dark">COD (Tunai)</span>
                                @else
                                    <span class="badge bg-primary">Transfer</span>
                                @endif
                            </td>

                            <!-- LOGIKA BUKTI BAYAR -->
                            <td>
                                @php
                                    $metode = strtolower($order->metode_pembayaran ?? '');
                                @endphp

                                @if($metode == 'cod')
                                    {{-- Jika COD, kosongkan atau beri strip --}}
                                    <span class="text-muted">-</span>
                                @else
                                    {{-- Jika Transfer, tampilkan isi kolom bukti_bayar --}}
                                    @if($order->bukti_bayar)
                                        <div class="text-break" style="max-width: 150px;">
                                            {{-- Jika isinya link gambar (storage), buat tombol lihat --}}
                                            @if(Str::contains($order->bukti_bayar, ['jpg', 'jpeg', 'png', 'storage']))
                                                 <a href="{{ asset('storage/'.$order->bukti_bayar) }}" target="_blank" class="btn btn-sm btn-outline-primary">
                                                    Lihat Foto
                                                </a>
                                            @else
                                                {{-- Jika isinya teks/nomor transfer --}}
                                                <span class="fw-bold text-dark">{{ $order->bukti_bayar }}</span>
                                            @endif
                                        </div>
                                    @else
                                        <span class="text-danger small">Belum ada data</span>
                                    @endif
                                @endif
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <!-- Colspan diubah dari 8 menjadi 7 karena 1 kolom dihapus -->
                            <td colspan="7" class="text-center py-4">
                                <h5>Belum ada transaksi yang Selesai.</h5>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Menampilkan Pagination -->
            <div class="mt-3">
                {{ $orders->links() }}
            </div>
        </div>
    </div>
</div>
@endsection
