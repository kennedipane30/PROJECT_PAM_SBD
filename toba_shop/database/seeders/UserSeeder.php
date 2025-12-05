<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Hapus user lama (opsional, biar bersih)
        // User::truncate();

        User::create([
            'name' => 'Super Admin',
            'email' => 'admin@gmail.com',         // Email Login
            'password' => Hash::make('password123'), // Password Login
            'phone_number' => '081234567890',
            'role' => 'admin',
        ]);
    }
}
