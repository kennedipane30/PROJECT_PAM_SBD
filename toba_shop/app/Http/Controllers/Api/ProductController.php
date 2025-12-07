<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\UmkmProfile; // Jangan lupa import Model ini
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage; // TAMBAHAN: Untuk hapus gambar lama

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

    // =========================================================================
    // [BARU] UPDATE PRODUK (Edit)
    // =========================================================================
    public function update(Request $request, $id)
    {
        $user = Auth::user();

        // 1. Cek Apakah Produk Ini Milik User yang Login
        // Caranya: Cari produk ID X, yang UMKM-nya dimiliki oleh User ID Y
        $product = Product::where('id', $id)
            ->whereHas('umkm', function($query) use ($user) {
                $query->where('user_id', $user->id);
            })->first();

        if (!$product) {
            return response()->json(['message' => 'Produk tidak ditemukan atau Anda bukan pemiliknya'], 403);
        }

        // 2. Validasi (Gambar nullable karena user mungkin tidak ganti gambar)
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'required|string',
            'harga'       => 'required|numeric',
            'stok'        => 'required|integer',
            'deskripsi'   => 'required|string',
            'gambar'      => 'nullable|image|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // 3. Handle Gambar Baru
        if ($request->hasFile('gambar')) {
            // Hapus gambar lama dari storage jika ada
            if ($product->gambar) {
                Storage::disk('public')->delete($product->gambar);
            }
            // Simpan gambar baru
            $product->gambar = $request->file('gambar')->store('products', 'public');
        }

        // 4. Update Database
        $product->update([
            'nama_produk' => $request->nama_produk,
            'harga'       => $request->harga,
            'stok'        => $request->stok,
            'deskripsi'   => $request->deskripsi,
            // Kolom 'gambar' otomatis terupdate karena kita set $product->gambar di atas
            // Kolom 'kategori' opsional jika ingin diupdate juga
        ]);

        return response()->json(['message' => 'Produk berhasil diperbarui', 'data' => $product]);
    }

    // =========================================================================
    // [BARU] DELETE PRODUK (Hapus)
    // =========================================================================
    public function destroy($id)
    {
        $user = Auth::user();

        // 1. Cek Kepemilikan (Sama seperti update)
        $product = Product::where('id', $id)
            ->whereHas('umkm', function($query) use ($user) {
                $query->where('user_id', $user->id);
            })->first();

        if (!$product) {
            return response()->json(['message' => 'Produk tidak ditemukan atau Anda bukan pemiliknya'], 403);
        }

        // 2. Hapus Produk
        // Karena Anda sudah pakai SoftDeletes di Model, ini tidak akan error FK.
        $product->delete();

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}
