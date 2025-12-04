<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\UmkmProfile;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    // ==========================================
    // 1. CHECKOUT (Pembeli Beli -> Notif ke UMKM)
    // ==========================================
    public function checkout(Request $request) {
        // [MODIFIKASI] Validasi data dari Flutter
        $request->validate([
            'umkm_id' => 'required|exists:umkm_profiles,id',
            'items'   => 'required|array',
            'metode_pembayaran' => 'required|in:cod,transfer',
            // Tambahkan validasi alamat (boleh null jika user malas isi, tapi sebaiknya ada)
            'alamat_pengiriman' => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            // [MODIFIKASI] Buat Header Order dengan Alamat & Metode Bayar
            $order = Order::create([
                'user_id' => Auth::id(),
                'umkm_profile_id' => $request->umkm_id,
                'total_harga' => 0,
                'status' => 'pending',
                'bukti_bayar' => null,

                // Simpan data yang dikirim dari Flutter
                'metode_pembayaran' => $request->metode_pembayaran,
                'alamat_pengiriman' => $request->alamat_pengiriman ?? '-',
            ]);

            $totalHargaOrder = 0;

            // Loop Barang
            foreach ($request->items as $item) {
                // Gunakan lockForUpdate untuk mencegah race condition stok (rebutan stok)
                $product = Product::lockForUpdate()->find($item['product_id']);

                if (!$product) {
                    throw new \Exception("Produk dengan ID {$item['product_id']} tidak ditemukan.");
                }

                if ($product->stok < $item['jumlah']) {
                    throw new \Exception("Stok {$product->nama_produk} kurang. Sisa: {$product->stok}");
                }

                $subtotal = $product->harga * $item['jumlah'];
                $totalHargaOrder += $subtotal;

                // Simpan Item (Trigger DB akan otomatis kurangi stok jika sudah disetting)
                // Jika tidak ada trigger DB, kurangi manual: $product->decrement('stok', $item['jumlah']);
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'jumlah' => $item['jumlah'],
                    'harga_satuan' => $product->harga,
                    'subtotal' => $subtotal
                ]);
            }

            // Update Total Harga di Header Order
            $order->update(['total_harga' => $totalHargaOrder]);

            // Notifikasi ke UMKM
            try {
                $umkm = UmkmProfile::find($request->umkm_id);
                if ($umkm && $umkm->user_id) {
                    Notification::create([
                        'user_id' => $umkm->user_id,
                        'order_id' => $order->id,
                        'title' => 'Pesanan Baru',
                        'message' => 'Pesanan masuk (' . strtoupper($request->metode_pembayaran) . ') senilai Rp ' . number_format($totalHargaOrder),
                        'is_read' => false
                    ]);
                }
            } catch (\Exception $notifError) {
                // Error notifikasi jangan sampai menggagalkan transaksi
                Log::error("Gagal buat notifikasi: " . $notifError->getMessage());
            }

            DB::commit();

            return response()->json(['message' => 'Order berhasil', 'data' => $order], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Checkout Error: " . $e->getMessage());
            // Kembalikan pesan error yang jelas ke Flutter
            return response()->json(['message' => 'Gagal memproses pesanan: ' . $e->getMessage()], 400);
        }
    }

    // ==========================================
    // DETAIL ORDER (Untuk Halaman Detail di Flutter)
    // ==========================================
    public function show($id)
    {
        $order = Order::with(['user', 'items.product', 'umkmProfile'])->find($id);

        if (!$order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        return response()->json(['data' => $order]);
    }

    // ==========================================
    // 2. LIST PESANAN MASUK (Dashboard UMKM)
    // ==========================================
    public function getUmkmIncomingOrders()
    {
        $user = Auth::user();
        $umkm = UmkmProfile::where('user_id', $user->id)->first();

        if (!$umkm) {
            return response()->json(['message' => 'Anda bukan mitra UMKM'], 400);
        }

        // Ambil order pending/paid/processing
        $orders = Order::where('umkm_profile_id', $umkm->id)
                       ->whereIn('status', ['pending', 'paid', 'processing'])
                       ->with(['user', 'items.product'])
                       ->orderBy('created_at', 'desc')
                       ->get();

        return response()->json(['data' => $orders]);
    }

    // ==========================================
    // 3. KIRIM BARANG (UMKM -> Pembeli)
    // ==========================================
    public function shipOrder($id)
    {
        $order = Order::find($id);
        if (!$order) return response()->json(['message' => 'Order tidak ditemukan'], 404);

        $user = Auth::user();
        $umkm = UmkmProfile::where('user_id', $user->id)->first();

        // Validasi Pemilik
        if (!$umkm || $order->umkm_profile_id != $umkm->id) {
            return response()->json(['message' => 'Akses ditolak. Ini bukan pesanan toko Anda.'], 403);
        }

        // Update Status jadi 'shipped'
        $order->update(['status' => 'shipped']);

        // Notifikasi ke Pembeli
        try {
            Notification::create([
                'user_id' => $order->user_id,
                'order_id' => $order->id,
                'title' => 'Pesanan Dikirim',
                'message' => 'Pesanan #' . $order->id . ' sedang dalam perjalanan.',
                'is_read' => false
            ]);
        } catch (\Exception $e) { Log::error($e->getMessage()); }

        return response()->json(['message' => 'Status diperbarui menjadi dikirim', 'data' => $order]);
    }

    // ==========================================
    // 4. TERIMA BARANG (Pembeli -> Selesai)
    // ==========================================
    public function completeOrder($id)
    {
        $order = Order::where('id', $id)->where('user_id', Auth::id())->first();
        if (!$order) return response()->json(['message' => 'Order tidak ditemukan'], 404);

        // Cek status harus shipped
        if ($order->status !== 'shipped') {
            return response()->json(['message' => 'Pesanan belum dikirim atau sudah selesai'], 400);
        }

        // Update status jadi 'completed'
        $order->update(['status' => 'completed']);

        // Notifikasi ke Penjual
        try {
            $umkm = $order->umkmProfile;
            if($umkm) {
                Notification::create([
                    'user_id' => $umkm->user_id,
                    'order_id' => $order->id,
                    'title' => 'Transaksi Selesai',
                    'message' => 'Pembeli telah menerima pesanan #' . $order->id,
                    'is_read' => false
                ]);
            }
        } catch (\Exception $e) { Log::error($e->getMessage()); }

        return response()->json(['message' => 'Pesanan selesai', 'data' => $order]);
    }

    // ==========================================
    // 5. RIWAYAT PESANAN PEMBELI
    // ==========================================
    public function myOrders()
    {
        $orders = Order::where('user_id', Auth::id())
            ->with(['items.product', 'umkmProfile'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['data' => $orders]);
    }
}
