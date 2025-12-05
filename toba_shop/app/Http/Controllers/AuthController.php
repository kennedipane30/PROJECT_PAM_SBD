<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // 1. Menampilkan Halaman Login
    public function showLoginForm()
    {
        return view('auth.login');
    }

    // 2. Proses Login
    public function login(Request $request)
    {
        // Validasi input
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Coba login
        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            // Cek apakah dia ADMIN?
            if (Auth::user()->role === 'admin') {
                return redirect()->intended('/admin/products'); // Redirect ke dashboard admin
            }

            // Jika bukan admin, tendang keluar
            Auth::logout();
            return back()->withErrors(['email' => 'Anda tidak memiliki akses admin.']);
        }

        // Login Gagal
        return back()->withErrors([
            'email' => 'Email atau password salah.',
        ]);
    }

    // 3. Logout
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/login');
    }
}
