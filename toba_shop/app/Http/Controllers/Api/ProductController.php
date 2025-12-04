<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\UmkmProfile; // Jangan lupa import Model ini
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    public function index(Request $request) {
        $query = Product::with('umkm');
        if($request->search) {
            $query->where('nama_produk', 'like', '%' . $request->search . '%');
        }
        return response()->json($query->get());
    }

    public function store(Request $request) {
        $user = Auth::user();

        // 1. Cek Role
        if ($user->role !== 'seller') {
            return response()->json(['message' => 'Hanya penjual yang bisa upload'], 403);
        }

        // 2. FIX FINAL: Ambil UMKM ID yang BENAR
        // Cari profil UMKM milik user yang sedang login
        $umkm = UmkmProfile::where('user_id', $user->id)->first();

        // JIKA TIDAK ADA PROFIL, TOLAK! (Jangan pakai user_id, itu bikin error)
        if (!$umkm) {
            return response()->json([
                'message' => 'Profil UMKM tidak ditemukan. Silakan daftar UMKM terlebih dahulu.'
            ], 403);
        }

        // Opsional: Cek apakah sudah diapprove
        if($umkm->status_verifikasi !== 'approved') {
             return response()->json([
                'message' => 'Akun UMKM Anda belum disetujui admin.'
            ], 403);
        }

        // 3. Validasi
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'required|string',
            'harga'       => 'required|numeric', // Laravel terima angka bersih dari Flutter
            'stok'        => 'required|integer',
            'kategori'    => 'required|string',
            'deskripsi'   => 'required|string',
            'gambar'      => 'nullable|image|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi Gagal', 'errors' => $validator->errors()], 422);
        }

        // 4. Upload Gambar
        $path = null;
        if ($request->hasFile('gambar')) {
            $path = $request->file('gambar')->store('products', 'public');
        }

        // 5. Create Product
        try {
            $product = Product::create([
                'umkm_profile_id' => $umkm->id, // PASTI BENAR karena diambil dari database
                'nama_produk' => $request->nama_produk,
                'deskripsi'   => $request->deskripsi,
                'harga'       => $request->harga,
                'stok'        => $request->stok,
                'kategori'    => $request->kategori,
                'gambar'      => $path
            ]);

            return response()->json(['message' => 'Produk berhasil dibuat', 'data' => $product], 201);

        } catch (\Exception $e) {
            // Ini akan menangkap error database dan menampilkannya
            return response()->json(['message' => 'Gagal menyimpan ke database', 'error' => $e->getMessage()], 500);
        }
    }
}
