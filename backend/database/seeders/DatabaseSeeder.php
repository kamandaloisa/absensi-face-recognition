<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create admin user
        User::create([
            'username' => 'admin',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'full_name' => 'Administrator',
            'email' => 'admin@attendance.com',
            'employee_code' => 'ADM001',
            'status' => 'active',
        ]);

        // Create sample employee
        User::create([
            'username' => 'employee1',
            'password' => Hash::make('password123'),
            'role' => 'employee',
            'full_name' => 'Karyawan Demo',
            'email' => 'employee1@attendance.com',
            'phone' => '081234567890',
            'employee_code' => 'EMP001',
            'department' => 'IT Department',
            'position' => 'Staff',
            'join_date' => now()->subYears(1),
            'status' => 'active',
        ]);

        // Create sample office location
        \App\Models\OfficeLocation::create([
            'location_name' => 'Kantor Pusat',
            'latitude' => -6.200000, // Example: Jakarta coordinates
            'longitude' => 106.816666,
            'radius' => 100, // 100 meters
            'is_active' => true,
        ]);

        echo "✅ Admin user created:\n";
        echo "   Username: admin\n";
        echo "   Password: admin123\n\n";
        echo "✅ Sample employee created:\n";
        echo "   Username: employee1\n";
        echo "   Password: password123\n\n";
        echo "✅ Office location created: Kantor Pusat\n";
    }
}
