<?php

namespace App\Models;

// Import ini wajib
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class User extends Authenticatable
{
    // Masukkan HasApiTokens di sini
    use HasApiTokens, HasFactory;

protected $fillable = [
    'name',
    'email',
    'password',
    'phone_number', // <--- Tambahkan ini (SESUAI ERROR GAMBAR)
    'role',         // <--- Tambahkan ini juga
];
}
