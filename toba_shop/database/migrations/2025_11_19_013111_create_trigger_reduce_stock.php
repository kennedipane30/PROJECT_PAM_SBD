<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB; // <--- WAJIB DITAMBAHKAN AGAR TIDAK ERROR

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Fungsi: Kurangi stok otomatis saat order dibuat
        DB::unprepared('
            CREATE OR REPLACE FUNCTION reduce_stock()
            RETURNS TRIGGER AS $$
            BEGIN
                UPDATE products
                SET stok = stok - NEW.jumlah
                WHERE id = NEW.product_id;
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
        ');

        // Trigger: Jalankan fungsi saat ada insert di order_items
        DB::unprepared('
            CREATE TRIGGER trigger_reduce_stock
            AFTER INSERT ON order_items
            FOR EACH ROW
            EXECUTE PROCEDURE reduce_stock();
        ');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Hapus Trigger dan Function jika rollback
        DB::unprepared('DROP TRIGGER IF EXISTS trigger_reduce_stock ON order_items');
        DB::unprepared('DROP FUNCTION IF EXISTS reduce_stock');
    }
};
