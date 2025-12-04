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
        Schema::create('umkm_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('nama_usaha');
            $table->text('alamat_usaha');
            $table->string('foto_ktp')->nullable(); // Path file
            // pending, approved, rejected
            $table->enum('status_verifikasi', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('alasan_penolakan')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('umkm_profiles');
    }
};
