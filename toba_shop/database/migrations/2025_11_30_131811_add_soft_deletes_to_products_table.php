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
    Schema::table('products', function (Blueprint $table) {
        // Cek dulu: Jika kolom 'deleted_at' BELUM ada, baru buat.
        if (!Schema::hasColumn('products', 'deleted_at')) {
            $table->softDeletes();
        }
    });
}

    public function down()
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }
};
