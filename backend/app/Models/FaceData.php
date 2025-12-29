<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FaceData extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'face_encoding',
        'face_image_path',
        'enrolled_at',
    ];

    protected $casts = [
        'face_encoding' => 'array',
        'enrolled_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
