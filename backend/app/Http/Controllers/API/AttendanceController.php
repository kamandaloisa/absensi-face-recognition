<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\OfficeLocation;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    /**
     * Check-in with face recognition and GPS validation
     */
    public function checkIn(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'photo' => 'nullable|string', // Base64 encoded image
            'face_encoding' => 'nullable|array', // Face embeddings from mobile
        ]);

        $user = $request->user();
        $today = Carbon::today();

        // Check if already checked in today
        $existingAttendance = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        if ($existingAttendance && $existingAttendance->hasCheckedIn()) {
            return response()->json([
                'message' => 'You have already checked in today',
                'attendance' => $existingAttendance,
            ], 422);
        }

        // Validate GPS location
        $isValidLocation = $this->validateLocation(
            $request->latitude,
            $request->longitude
        );

        if (!$isValidLocation) {
            return response()->json([
                'message' => 'You are not within office location radius',
            ], 422);
        }

        // TODO: Validate face recognition
        // This will be implemented when face recognition service is ready

        // Save photo if provided
        $photoPath = null;
        if ($request->photo) {
            $photoPath = $this->savePhoto($request->photo, 'checkin');
        }

        // Create or update attendance
        if ($existingAttendance) {
            $existingAttendance->update([
                'check_in_time' => now(),
                'check_in_latitude' => $request->latitude,
                'check_in_longitude' => $request->longitude,
                'check_in_photo' => $photoPath,
                'status' => 'hadir',
            ]);
            $attendance = $existingAttendance;
        } else {
            $attendance = Attendance::create([
                'user_id' => $user->id,
                'date' => $today,
                'check_in_time' => now(),
                'check_in_latitude' => $request->latitude,
                'check_in_longitude' => $request->longitude,
                'check_in_photo' => $photoPath,
                'status' => 'hadir',
            ]);
        }

        return response()->json([
            'message' => 'Check-in successful',
            'attendance' => $attendance,
        ]);
    }

    /**
     * Check-out with face recognition and GPS validation
     */
    public function checkOut(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'photo' => 'nullable|string',
        ]);

        $user = $request->user();
        $today = Carbon::today();

        $attendance = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        if (!$attendance) {
            return response()->json([
                'message' => 'You must check in first',
            ], 422);
        }

        if (!$attendance->hasCheckedIn()) {
            return response()->json([
                'message' => 'You must check in first',
            ], 422);
        }

        if ($attendance->hasCheckedOut()) {
            return response()->json([
                'message' => 'You have already checked out today',
            ], 422);
        }

        // Validate GPS location
        $isValidLocation = $this->validateLocation(
            $request->latitude,
            $request->longitude
        );

        if (!$isValidLocation) {
            return response()->json([
                'message' => 'You are not within office location radius',
            ], 422);
        }

        // Save photo if provided
        $photoPath = null;
        if ($request->photo) {
            $photoPath = $this->savePhoto($request->photo, 'checkout');
        }

        $attendance->update([
            'check_out_time' => now(),
            'check_out_latitude' => $request->latitude,
            'check_out_longitude' => $request->longitude,
            'check_out_photo' => $photoPath,
        ]);

        return response()->json([
            'message' => 'Check-out successful',
            'attendance' => $attendance,
        ]);
    }

    /**
     * Get today's attendance
     */
    public function today(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today();

        $attendance = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        return response()->json([
            'attendance' => $attendance,
        ]);
    }

    /**
     * Get attendance history
     */
    public function history(Request $request)
    {
        $user = $request->user();

        $attendances = Attendance::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->paginate(30);

        return response()->json($attendances);
    }

    /**
     * Validate if coordinates are within office radius
     */
    private function validateLocation($latitude, $longitude)
    {
        $officeLocations = OfficeLocation::where('is_active', true)->get();

        foreach ($officeLocations as $office) {
            $distance = $this->calculateDistance(
                $latitude,
                $longitude,
                $office->latitude,
                $office->longitude
            );

            if ($distance <= $office->radius) {
                return true;
            }
        }

        return false;
    }

    /**
     * Calculate distance between two coordinates using Haversine formula
     * Returns distance in meters
     */
    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // Earth radius in meters

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distance = $earthRadius * $c;

        return $distance;
    }

    /**
     * Save base64 photo to storage
     */
    private function savePhoto($base64Photo, $type)
    {
        // Remove data URL prefix if exists
        if (strpos($base64Photo, 'data:image') !== false) {
            $base64Photo = substr($base64Photo, strpos($base64Photo, ',') + 1);
        }

        $image = base64_decode($base64Photo);
        $fileName = $type . '_' . time() . '_' . uniqid() . '.jpg';
        $path = 'attendance/' . $fileName;

        \Storage::disk('public')->put($path, $image);

        return $path;
    }
}
