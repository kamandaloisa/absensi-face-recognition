<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Holiday;
use Illuminate\Http\Request;

class HolidayController extends Controller
{
    /**
     * Get all holidays
     */
    public function index(Request $request)
    {
        $holidays = Holiday::when($request->year, function ($query, $year) {
                $query->whereYear('holiday_date', $year);
            })
            ->when($request->month, function ($query, $month) {
                $query->whereMonth('holiday_date', $month);
            })
            ->orderBy('holiday_date')
            ->get();

        return response()->json([
            'holidays' => $holidays,
        ]);
    }

    /**
     * Create holiday (admin only)
     */
    public function store(Request $request)
    {
        $request->validate([
            'holiday_date' => 'required|date',
            'holiday_name' => 'required|string',
            'holiday_type' => 'required|in:national,company',
        ]);

        $user = $request->user();

        $holiday = Holiday::create([
            'holiday_date' => $request->holiday_date,
            'holiday_name' => $request->holiday_name,
            'holiday_type' => $request->holiday_type,
            'source' => 'manual',
            'created_by' => $user->id,
        ]);

        return response()->json([
            'message' => 'Holiday created successfully',
            'holiday' => $holiday,
        ], 201);
    }

    /**
     * Update holiday (admin only)
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'holiday_date' => 'sometimes|date',
            'holiday_name' => 'sometimes|string',
            'holiday_type' => 'sometimes|in:national,company',
        ]);

        $holiday = Holiday::findOrFail($id);
        $holiday->update($request->only(['holiday_date', 'holiday_name', 'holiday_type']));

        return response()->json([
            'message' => 'Holiday updated successfully',
            'holiday' => $holiday,
        ]);
    }

    /**
     * Delete holiday (admin only)
     */
    public function destroy($id)
    {
        $holiday = Holiday::findOrFail($id);
        $holiday->delete();

        return response()->json([
            'message' => 'Holiday deleted successfully',
        ]);
    }
}
