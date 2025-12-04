<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UmkmProfile;
use Illuminate\Support\Facades\Validator;

class UmkmApiController extends Controller
{
    // Cek Status
    public function checkStatus(Request $request)
    {
        $user = $request->user();
        // Cari profil berdasarkan user_id
        $umkm = UmkmProfile::where('user_id', $user->id)->first();

        if (!$umkm) {
            return response()->json([
                'status' => 'not_registered',
                'message' => 'Belum mendaftar UMKM'
            ]);
        }

        return response()->json([
            'status' => $umkm->status_verifikasi, // pending, approved, rejected
            'data' => $umkm
        ]);
    }

    // Register
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_usaha' => 'required|string',
            'alamat_usaha' => 'required|string',
            'foto_ktp' => 'required|image|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Upload Foto
        if ($request->hasFile('foto_ktp')) {
            $path = $request->file('foto_ktp')->store('ktp_umkm', 'public');
        } else {
            return response()->json(['message' => 'Foto wajib diisi'], 400);
        }

        $umkm = UmkmProfile::create([
            'user_id' => $request->user()->id,
            'nama_usaha' => $request->nama_usaha,
            'alamat_usaha' => $request->alamat_usaha,
            'foto_ktp' => $path,
            'status_verifikasi' => 'pending',
        ]);

        return response()->json([
            'message' => 'Berhasil mendaftar',
            'data' => $umkm
        ], 201);
    }
}
