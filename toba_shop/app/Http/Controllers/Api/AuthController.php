<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register User Baru (Pembeli / Calon Penjual)
     */
    public function register(Request $request) {
        // 1. Validasi Input
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users', // Email harus unik
            'password' => 'required|string|min:6', // Minimal 6 karakter
            'role' => 'required|in:buyer,seller', // Hanya boleh buyer atau seller
            'phone_number' => 'nullable|string|max:15', // Opsional
        ]);

        // 2. Buat User di Database
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'phone_number' => $validated['phone_number'] ?? null,
        ]);

        // 3. Buat Token langsung agar user tidak perlu login ulang setelah register
        $token = $user->createToken('auth_token')->plainTextToken;

        // 4. Return Response JSON (Status 201 Created)
        return response()->json([
            'message' => 'Registrasi berhasil',
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer'
        ], 201);
    }

    /**
     * Login User
     */
    public function login(Request $request) {
        // 1. Validasi Input
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // 2. Cek Kredensial
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Email atau password salah'
            ], 401); // 401 Unauthorized
        }

        // 3. Ambil Data User
        $user = User::where('email', $request->email)->firstOrFail();

        // 4. Buat Token Baru
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer'
        ], 200);
    }

    /**
     * Logout User
     */
    public function logout(Request $request) {
        // Hapus token yang sedang digunakan (agar tidak bisa dipakai lagi)
        // Pastikan route logout menggunakan middleware 'auth:sanctum'
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }

    /**
     * Cek Profile User (User Me)
     * Berguna untuk Mobile App memastikan token masih valid dan mengambil data user terbaru
     */
    public function me(Request $request) {
        return response()->json([
            'message' => 'Data profile user',
            'data' => $request->user() // Mengembalikan data user yang sedang login
        ]);
    }
}
