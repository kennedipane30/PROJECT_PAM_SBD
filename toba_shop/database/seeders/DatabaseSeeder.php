<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Memanggil Class Seeder Lain
        $this->call([
            UserSeeder::class,
            // Jika nanti ada ProductSeeder atau OrderSeeder, tambahkan di bawah ini:
            // ProductSeeder::class,
        ]);
    }
}
