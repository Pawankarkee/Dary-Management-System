import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/backup_controller.dart';
import '../../../config/theme/app_theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBackups();
    });
  }

  Future<void> _loadBackups() async {
    final controller = Provider.of<BackupController>(context, listen: false);
    await controller.loadBackupList();
    await controller.loadBackupStats();
  }

  Future<void> _createBackup() async {
    final controller = Provider.of<BackupController>(context, listen: false);
    final success = await controller.createBackup();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✅ Backup created successfully!' : '❌ Failed to create backup'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _restoreBackup(String backupPath, String fileName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Text('Are you sure you want to restore from "$fileName"?\n\nThis will replace all current data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final controller = Provider.of<BackupController>(context, listen: false);
    final success = await controller.restoreBackup(backupPath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✅ Backup restored successfully!' : '❌ Failed to restore backup'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _deleteBackup(String backupPath, String fileName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final controller = Provider.of<BackupController>(context, listen: false);
    final success = await controller.deleteBackup(backupPath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '🗑️ Backup deleted' : '❌ Failed to delete backup'),
        backgroundColor: success ? Colors.orange : Colors.red,
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Backup'),
        elevation: 0,
      ),
      body: Consumer<BackupController>(
        builder: (context, controller, child) {
          return RefreshIndicator(
            onRefresh: _loadBackups,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backup Stats Card
                  _buildStatsCard(controller, isDark),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.status == BackupStatus.creating
                              ? null
                              : _createBackup,
                          icon: const Icon(Icons.backup),
                          label: const Text('Create Backup'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.backupList.isEmpty
                              ? null
                              : () => _deleteOldBackups(),
                          icon: const Icon(Icons.cleaning_services),
                          label: const Text('Clean Old'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Backup List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Backup History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${controller.backupList.length} backups',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Backup List
                  if (controller.backupList.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.backupList.length,
                      itemBuilder: (context, index) {
                        final backup = controller.backupList[index];
                        return _buildBackupCard(backup, isDark);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(BackupController controller, bool isDark) {
    final stats = controller.backupStats;
    final totalBackups = stats['total_backups'] ?? 0;
    final totalSizeMB = stats['total_size_mb'] ?? '0.00';
    final backupDir = stats['backup_directory'] ?? '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup Statistics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalBackups backups • $totalSizeMB MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Backup Location:'),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              backupDir,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontFamily: 'monospace',
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(Map<String, dynamic> backup, bool isDark) {
    final fileName = backup['file_name'];
    final sizeKB = backup['size_kb'];
    final created = backup['created'];
    final backupInfo = backup['backup_info'];
    final totalRecords = backupInfo?['total_records'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.folder_zip,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Created: ${_formatDate(created)}'),
            Text('Size: $sizeKB KB • Records: $totalRecords'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'restore':
                _restoreBackup(backup['file_path'], fileName);
                break;
              case 'delete':
                _deleteBackup(backup['file_path'], fileName);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 12),
                  Text('Restore'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.backup,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No backups found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first backup to save all your data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteOldBackups() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Old Backups'),
        content: const Text('Keep only the latest 10 backups and delete older ones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clean'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final controller = Provider.of<BackupController>(context, listen: false);
    final count = await controller.deleteOldBackups(keepLast: 10);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ Deleted $count old backup(s)'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
