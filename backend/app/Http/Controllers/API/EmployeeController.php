<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class EmployeeController extends Controller
{
    /**
     * Get all employees
     */
    public function index(Request $request)
    {
        $employees = User::where('role', 'employee')
            ->when($request->search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('full_name', 'like', "%{$search}%")
                      ->orWhere('employee_code', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%");
                });
            })
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            ->orderBy('full_name')
            ->paginate(20);

        return response()->json($employees);
    }

    /**
     * Create new employee
     */
    public function store(Request $request)
    {
        $request->validate([
            'username' => 'required|string|unique:users',
            'password' => 'required|string|min:6',
            'full_name' => 'required|string',
            'employee_code' => 'required|string|unique:users',
            'email' => 'nullable|email|unique:users',
            'phone' => 'nullable|string',
            'department' => 'nullable|string',
            'position' => 'nullable|string',
            'join_date' => 'nullable|date',
        ]);

        $employee = User::create([
            'username' => $request->username,
            'password' => Hash::make($request->password),
            'role' => 'employee',
            'full_name' => $request->full_name,
            'employee_code' => $request->employee_code,
            'email' => $request->email,
            'phone' => $request->phone,
            'department' => $request->department,
            'position' => $request->position,
            'join_date' => $request->join_date,
            'status' => 'active',
        ]);

        return response()->json([
            'message' => 'Employee created successfully',
            'employee' => $employee,
        ], 201);
    }

    /**
     * Get employee details
     */
    public function show($id)
    {
        $employee = User::where('role', 'employee')->findOrFail($id);

        return response()->json([
            'employee' => $employee,
        ]);
    }

    /**
     * Update employee
     */
    public function update(Request $request, $id)
    {
        $employee = User::where('role', 'employee')->findOrFail($id);

        $request->validate([
            'username' => 'sometimes|string|unique:users,username,' . $id,
            'password' => 'sometimes|string|min:6',
            'full_name' => 'sometimes|string',
            'employee_code' => 'sometimes|string|unique:users,employee_code,' . $id,
            'email' => 'nullable|email|unique:users,email,' . $id,
            'phone' => 'nullable|string',
            'department' => 'nullable|string',
            'position' => 'nullable|string',
            'join_date' => 'nullable|date',
            'status' => 'sometimes|in:active,inactive',
        ]);

        $data = $request->only([
            'username', 'full_name', 'employee_code', 'email',
            'phone', 'department', 'position', 'join_date', 'status'
        ]);

        if ($request->password) {
            $data['password'] = Hash::make($request->password);
        }

        $employee->update($data);

        return response()->json([
            'message' => 'Employee updated successfully',
            'employee' => $employee,
        ]);
    }

    /**
     * Delete employee
     */
    public function destroy($id)
    {
        $employee = User::where('role', 'employee')->findOrFail($id);
        $employee->delete();

        return response()->json([
            'message' => 'Employee deleted successfully',
        ]);
    }
}
