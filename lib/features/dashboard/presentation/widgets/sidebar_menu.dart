import 'package:flutter/material.dart';

/// Sidebar menu widget
class SidebarMenu extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const SidebarMenu({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo section
          Container(
            height: 64,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.point_of_sale,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'POS 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white24, height: 1),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  'dashboard',
                  'Dashboard',
                  Icons.dashboard,
                ),
                _buildMenuItem(
                  context,
                  'sales',
                  'Bán hàng',
                  Icons.point_of_sale,
                ),
                _buildMenuItem(
                  context,
                  'inventory',
                  'Quản lý kho',
                  Icons.inventory,
                ),
                _buildMenuItem(
                  context,
                  'reports',
                  'Báo cáo',
                  Icons.assessment,
                ),
                const Divider(color: Colors.white24, height: 32),
                _buildMenuItem(
                  context,
                  'settings',
                  'Cài đặt',
                  Icons.settings,
                ),
                _buildMenuItem(
                  context,
                  'sync',
                  'Đồng bộ',
                  Icons.sync,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String id,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedMenu == id;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onTap: () => onMenuSelected(id),
      ),
    );
  }
}
