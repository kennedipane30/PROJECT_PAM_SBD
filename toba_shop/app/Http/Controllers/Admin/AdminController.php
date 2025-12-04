<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UmkmProfile;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    // ... (Fungsi UMKM Index & Verify tetap sama) ...
    public function umkmIndex()
    {
        $umkms = UmkmProfile::with('user')
            ->orderByRaw("CASE WHEN status_verifikasi = 'pending' THEN 1 ELSE 2 END")
            ->orderBy('created_at', 'desc')
            ->get();
        return view('admin.umkm.index', compact('umkms'));
    }

    public function verifyUmkm(Request $request, $id)
    {
        $umkm = UmkmProfile::findOrFail($id);
        $request->validate(['status' => 'required|in:approved,rejected']);
        $umkm->update([
            'status_verifikasi' => $request->status,
            'alasan_penolakan' => $request->alasan ?? null
        ]);
        return redirect()->back()->with('success', 'Status UMKM diperbarui.');
    }

    // ... (Fungsi Product Index & Delete tetap sama) ...
    public function productIndex()
    {
        // Karena sudah pakai SoftDeletes, produk yang dihapus
        // otomatis TIDAK akan muncul disini (difilter otomatis oleh Laravel).
        $products = Product::with('umkm')->latest()->paginate(10);

        $popularProducts = OrderItem::select('product_id', DB::raw('SUM(jumlah) as total_terjual'))
            ->groupBy('product_id')
            ->orderByDesc('total_terjual')
            ->limit(5)
            ->with('product')
            ->get();

        return view('admin.products.index', compact('products', 'popularProducts'));
    }

    public function deleteProduct($id)
    {
        // KODE INI SEKARANG AMAN.
        // Karena Model Product sudah pakai SoftDeletes, perintah ini
        // tidak akan menghapus data fisik, melainkan mengisi kolom 'deleted_at'.
        // Jadi error foreign key violation TIDAK AKAN MUNCUL lagi.
        Product::findOrFail($id)->delete();

        return redirect()->back()->with('success', 'Produk dihapus.');
    }

    // ==================================================
    // MONITORING TRANSAKSI
    // ==================================================
// ==================================================
    // MONITORING TRANSAKSI (MODIFIED - FINAL & AMAN)
    // ==================================================
public function transactionIndex()
    {
        // KITA HAPUS FILTER 'WHERE' SEMENTARA
        // Tujuannya: Melihat apa sebenarnya isi data di database Anda.

        $orders = Order::with(['user', 'umkmProfile.user'])
            ->latest() // Urutkan dari yang terbaru
            ->paginate(15);

        // Debugging: Mari kita lihat datanya langsung di layar jika view bermasalah
        // dd($orders->items()); // <- Uncomment baris ini jika tabel masih kosong nanti

        return view('admin.transactions.index', compact('orders'));
    }
}
