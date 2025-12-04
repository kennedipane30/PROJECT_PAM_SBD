<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('orders', function (Blueprint $table) {
            // Menambahkan kolom metode_pembayaran
            if (!Schema::hasColumn('orders', 'metode_pembayaran')) {
                $table->string('metode_pembayaran')->default('transfer')->after('total_harga');
            }

            // Menambahkan kolom alamat_pengiriman (karena di Flutter kita kirim alamat juga)
            if (!Schema::hasColumn('orders', 'alamat_pengiriman')) {
                $table->text('alamat_pengiriman')->nullable()->after('metode_pembayaran');
            }
        });
    }

    public function down()
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['metode_pembayaran', 'alamat_pengiriman']);
        });
    }
};
