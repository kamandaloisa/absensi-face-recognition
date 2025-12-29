<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('holidays', function (Blueprint $table) {
            $table->id();
            $table->date('holiday_date');
            $table->string('holiday_name');
            $table->enum('holiday_type', ['national', 'company'])->default('national');
            $table->enum('source', ['manual', 'google_calendar'])->default('manual');
            $table->foreignId('created_by')->nullable()->constrained('users');
            $table->timestamps();
            $table->index('holiday_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('holidays');
    }
};
