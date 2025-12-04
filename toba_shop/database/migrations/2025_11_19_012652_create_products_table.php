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
    Schema::create('products', function (Blueprint $table) {
        $table->id();
        $table->foreignId('umkm_profile_id')->constrained('umkm_profiles')->onDelete('cascade');
        $table->string('nama_produk');
        $table->text('deskripsi')->nullable();
        $table->decimal('harga', 12, 2);
        $table->integer('stok');
        $table->string('kategori'); // Makanan, Minuman
        $table->string('gambar')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
