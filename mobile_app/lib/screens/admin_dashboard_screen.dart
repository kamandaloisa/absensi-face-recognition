import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'dart:ui'; 

// Removed AdminBackground import as we are moving to White theme

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Console'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppTheme.title1.copyWith(fontSize: 22),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textDark),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: AppTheme.caption),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            Text("Management", style: AppTheme.caption),
            const SizedBox(height: 16),
            _buildMenuGrid(),
            const SizedBox(height: 32),
            Text("Recent Activity", style: AppTheme.caption),
            const SizedBox(height: 16),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Present', '45', AppTheme.primaryBlue), 
        _buildStatCard('Late', '3', AppTheme.warningAmber),
        _buildStatCard('Absent', '2', AppTheme.errorRed),
        _buildStatCard('Leave', '5', AppTheme.textGrey), 
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(Icons.bar_chart, color: color.withOpacity(0.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {'title': 'Employees', 'icon': Icons.people_outline},
      {'title': 'Face Data', 'icon': Icons.face_retouching_natural},
      {'title': 'Schedule', 'icon': Icons.calendar_month_outlined},
      {'title': 'Reports', 'icon': Icons.bar_chart_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
             decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
             ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(height: 8),
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityList() {
    return Container(
      decoration: AppTheme.cleanCardDecoration,
      child: Column(
        children: [
          _buildActivityItem('John Doe', 'Checked In', '08:00 AM'),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
          _buildActivityItem('Sarah Smith', 'Late Check In', '09:15 AM'),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
          _buildActivityItem('Michael', 'Leave Approved', 'Yesterday'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String name, String action, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.accentBlue,
        child: Text(name[0], style: const TextStyle(color: AppTheme.primaryBlue)),
      ),
      title: Text(name, style: AppTheme.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(action, style: AppTheme.caption),
      trailing: Text(time, style: AppTheme.caption),
    );
  }
}
