import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/application_service.dart';
import '../../../../features/application_status/data/application_model.dart';

/// Applications Page
/// Displays all applications with filtering and status management
class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  String _selectedFilter = 'All';

  List<Application> get _filteredApplications {
    final applicationService = Provider.of<ApplicationService>(
      context,
      listen: false,
    );
    final allApplications = applicationService.applications;

    if (_selectedFilter == 'All') {
      return allApplications
        ..sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
    }

    final status = _selectedFilter == 'Pending'
        ? ApplicationStatus.pending
        : _selectedFilter == 'Approved'
        ? ApplicationStatus.approved
        : ApplicationStatus.rejected;

    return allApplications.where((app) => app.status == status).toList()
      ..sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
  }

  void _showRejectionDialog(BuildContext context, Application application) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for rejecting this application:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a rejection reason'),
                  ),
                );
                return;
              }

              _rejectApplication(
                context,
                application,
                reasonController.text.trim(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _approveApplication(
    BuildContext context,
    Application application,
  ) async {
    final applicationService = Provider.of<ApplicationService>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await applicationService.approveApplication(application.id);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application approved. Certificate created.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving application: $e')),
        );
      }
    }
  }

  void _rejectApplication(
    BuildContext context,
    Application application,
    String reason,
  ) async {
    final applicationService = Provider.of<ApplicationService>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await applicationService.rejectApplication(
        application.id,
        reason: reason,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application rejected.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting application: $e')),
        );
      }
    }
  }

  void _viewApplicationDetails(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(application.type.displayName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Citizen', application.citizenName),
              _buildDetailRow('Status', application.status.displayName),
              _buildDetailRow(
                'Submitted',
                DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(application.submittedDate),
              ),
              if (application.rejectionReason != null)
                _buildDetailRow(
                  'Rejection Reason',
                  application.rejectionReason!,
                ),
              const SizedBox(height: 16),
              const Text(
                'Form Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...application.formData.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: Consumer<ApplicationService>(
        builder: (context, applicationService, child) {
          final applications = _filteredApplications;

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Pending', 'Approved', 'Rejected'].map((
                      filter,
                    ) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(filter),
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          selectedColor: colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Applications List
              Expanded(
                child: applications.isEmpty
                    ? Center(
                        child: Text(
                          'No applications found',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          final statusColor = app.status.color;
                          final dateFormat = DateFormat('yyyy-MM-dd');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(app.type.icon, color: statusColor),
                              ),
                              title: Text(
                                app.citizenName,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(app.type.displayName),
                                  Text(
                                    dateFormat.format(app.submittedDate),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          app.status.icon,
                                          color: statusColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          app.status.displayName,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      if (app.status ==
                                          ApplicationStatus.pending)
                                        const PopupMenuItem(
                                          value: 'approve',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Approve'),
                                            ],
                                          ),
                                        ),
                                      if (app.status ==
                                          ApplicationStatus.pending)
                                        const PopupMenuItem(
                                          value: 'reject',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Reject'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility),
                                            SizedBox(width: 8),
                                            Text('View Details'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'approve') {
                                        _approveApplication(context, app);
                                      } else if (value == 'reject') {
                                        _showRejectionDialog(context, app);
                                      } else if (value == 'view') {
                                        _viewApplicationDetails(context, app);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
