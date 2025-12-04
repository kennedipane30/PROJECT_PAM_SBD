<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $table = 'notifications';

    protected $fillable = [
        'user_id',
        'order_id',
        'title',
        'message',
        'is_read'
    ];

    // Relasi ke Order (Opsional, untuk kemudahan)
    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
