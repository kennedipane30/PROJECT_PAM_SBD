@extends('layouts.admin')

@section('content')
<div class="container-fluid">
    <h3 class="mb-4 fw-bold">Manajemen Pendaftaran UMKM</h3>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Nama Usaha</th>
                        <th>Pemilik</th>
                        <th>Alamat</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($umkms as $umkm)
                    <tr>
                        <td>{{ $umkm->nama_usaha }}</td>
                        <td>{{ $umkm->user->name }} <br> <small class="text-muted">{{ $umkm->user->email }}</small></td>
                        <td>{{ Str::limit($umkm->alamat_usaha, 30) }}</td>
                        <td>
                            @if($umkm->status_verifikasi == 'pending')
                                <span class="badge bg-warning text-dark">Pending</span>
                            @elseif($umkm->status_verifikasi == 'approved')
                                <span class="badge bg-success">Aktif</span>
                            @else
                                <span class="badge bg-danger">Ditolak</span>
                            @endif
                        </td>
                        <td>
                            @if($umkm->status_verifikasi == 'pending')
                                <form action="{{ route('admin.umkm.verify', $umkm->id) }}" method="POST" class="d-inline">
                                    @csrf
                                    @method('PUT')
                                    <input type="hidden" name="status" value="approved">
                                    <button type="submit" class="btn btn-sm btn-success" onclick="return confirm('Terima UMKM ini?')"><i class="fas fa-check"></i> Terima</button>
                                </form>

                                <!-- Tombol Trigger Modal Tolak -->
                                <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#rejectModal{{ $umkm->id }}">
                                    <i class="fas fa-times"></i> Tolak
                                </button>

                                <!-- Modal Tolak -->
                                <div class="modal fade" id="rejectModal{{ $umkm->id }}" tabindex="-1">
                                    <div class="modal-dialog">
                                        <form action="{{ route('admin.umkm.verify', $umkm->id) }}" method="POST">
                                            @csrf
                                            @method('PUT')
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Alasan Penolakan</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <input type="hidden" name="status" value="rejected">
                                                    <textarea name="alasan" class="form-control" placeholder="Tulis alasan penolakan..." required></textarea>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="submit" class="btn btn-danger">Kirim Penolakan</button>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            @else
                                <span class="text-muted small">Selesai</span>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="5" class="text-center">Belum ada data UMKM.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
