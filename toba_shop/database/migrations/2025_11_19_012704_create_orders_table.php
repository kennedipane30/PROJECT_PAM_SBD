<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users'); // Pembeli
            $table->foreignId('umkm_profile_id')->constrained('umkm_profiles'); // Penjual (UMKM)
            $table->decimal('total_harga', 12, 2);

            // TAMBAHKAN 'shipped' DI SINI
            $table->enum('status', ['pending', 'paid', 'processing', 'shipped', 'completed', 'cancelled'])->default('pending');

            $table->string('bukti_bayar')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
