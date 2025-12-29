<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\LeaveRequest;
use Illuminate\Http\Request;

class LeaveController extends Controller
{
    /**
     * Get all leave requests (admin) or user's own requests (employee)
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $query = LeaveRequest::with(['user', 'approver']);

        // If employee, only show their own requests
        if ($user->isEmployee()) {
            $query->where('user_id', $user->id);
        }

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        $leaveRequests = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json($leaveRequests);
    }

    /**
     * Submit leave request
     */
    public function store(Request $request)
    {
        $request->validate([
            'leave_type' => 'required|in:izin,cuti',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'reason' => 'required|string',
            'attachment' => 'nullable|string', // Base64 encoded file
        ]);

        $user = $request->user();

        // Save attachment if provided
        $attachmentPath = null;
        if ($request->attachment) {
            $attachmentPath = $this->saveAttachment($request->attachment);
        }

        $leaveRequest = LeaveRequest::create([
            'user_id' => $user->id,
            'leave_type' => $request->leave_type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'reason' => $request->reason,
            'attachment' => $attachmentPath,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Leave request submitted successfully',
            'leave_request' => $leaveRequest,
        ], 201);
    }

    /**
     * Approve leave request (admin only)
     */
    public function approve(Request $request, $id)
    {
        $user = $request->user();

        if (!$user->isAdmin()) {
            return response()->json([
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $leaveRequest = LeaveRequest::findOrFail($id);

        if (!$leaveRequest->isPending()) {
            return response()->json([
                'message' => 'Leave request is already ' . $leaveRequest->status,
            ], 422);
        }

        $leaveRequest->update([
            'status' => 'approved',
            'approved_by' => $user->id,
            'approved_at' => now(),
        ]);

        return response()->json([
            'message' => 'Leave request approved successfully',
            'leave_request' => $leaveRequest,
        ]);
    }

    /**
     * Reject leave request (admin only)
     */
    public function reject(Request $request, $id)
    {
        $user = $request->user();

        if (!$user->isAdmin()) {
            return response()->json([
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $request->validate([
            'rejection_reason' => 'required|string',
        ]);

        $leaveRequest = LeaveRequest::findOrFail($id);

        if (!$leaveRequest->isPending()) {
            return response()->json([
                'message' => 'Leave request is already ' . $leaveRequest->status,
            ], 422);
        }

        $leaveRequest->update([
            'status' => 'rejected',
            'approved_by' => $user->id,
            'approved_at' => now(),
            'rejection_reason' => $request->rejection_reason,
        ]);

        return response()->json([
            'message' => 'Leave request rejected',
            'leave_request' => $leaveRequest,
        ]);
    }

    /**
     * Save attachment file
     */
    private function saveAttachment($base64File)
    {
        if (strpos($base64File, 'data:') !== false) {
            $base64File = substr($base64File, strpos($base64File, ',') + 1);
        }

        $file = base64_decode($base64File);
        $fileName = 'leave_' . time() . '_' . uniqid() . '.pdf';
        $path = 'leave_attachments/' . $fileName;

        \Storage::disk('public')->put($path, $file);

        return $path;
    }
}
