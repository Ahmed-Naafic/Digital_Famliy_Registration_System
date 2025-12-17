import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/application_service.dart';
import '../../../../features/application_status/data/application_model.dart';
import '../../auth/auth_provider.dart';
import 'widgets/sidebar_widget.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/certificate_card.dart';
import 'widgets/service_list_item.dart';

/// Dashboard Screen
/// Modern dark-themed dashboard with BottomNavigationBar
/// Features dark blue background matching the modern design aesthetic
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _showCertificates = false;

  final List<Map<String, dynamic>> _certificates = [
    {
      'name': 'Birth Certificate',
      'dateIssued': '2020-05-15',
      'status': 'Active',
    },
    {
      'name': 'Marriage Certificate',
      'dateIssued': '2018-08-20',
      'status': 'Active',
    },
    {'name': 'National ID', 'dateIssued': '2015-03-10', 'status': 'Active'},
  ];

  // _familyMembers list removed - now handled by FamilyProfilePage

  Widget _buildHomeTab(BuildContext context, AuthProvider authProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [kDarkBackgroundColor, kDarkBackgroundColor]
              : [kBackgroundColor, kBackgroundColor],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimaryColor, kSecondaryColor],
                ),
              ),
              padding: const EdgeInsets.all(kDefaultPadding * 1.5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${authProvider.user?.name ?? 'User'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: kHeadingFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your family records and certificates',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: kBodyFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kDefaultPadding * 1.5),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: kSubheadingFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: kDefaultPadding,
              mainAxisSpacing: kDefaultPadding,
              childAspectRatio: 1.1,
              children: [
                QuickActionCard(
                  icon: Icons.child_care,
                  title: 'Birth Registration',
                  backgroundColor: kPrimaryColor,
                  onTap: () => context.goNamed(Routes.birthRegistration),
                ),
                QuickActionCard(
                  icon: Icons.favorite,
                  title: 'Marriage Registration',
                  backgroundColor: Colors.pink,
                  onTap: () => context.goNamed(Routes.marriageRegistration),
                ),
                QuickActionCard(
                  icon: Icons.heart_broken,
                  title: 'Divorce Registration',
                  backgroundColor: Colors.purple,
                  onTap: () => context.goNamed(Routes.divorceRegistration),
                ),
                QuickActionCard(
                  icon: Icons.celebration,
                  title: 'Death Registration',
                  backgroundColor: Colors.grey[700]!,
                  onTap: () => context.goNamed(Routes.deathRegistration),
                ),
                QuickActionCard(
                  icon: Icons.description,
                  title: 'View Certificates',
                  backgroundColor: kAccentColor,
                  onTap: () => context.goNamed(Routes.certificates),
                ),
                QuickActionCard(
                  icon: Icons.people,
                  title: 'Family Profile',
                  backgroundColor: Colors.teal,
                  onTap: () => context.goNamed(Routes.familyProfile),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding * 2),

            // Recent Applications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Applications',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: kSubheadingFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => context.goNamed(Routes.applicationStatus),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Consumer<ApplicationService>(
              builder: (context, applicationService, child) {
                final user = authProvider.user;
                if (user == null) {
                  return const SizedBox.shrink();
                }

                final recentApps = applicationService
                    .getRecentApplicationsForCitizen(user.id, limit: 5);

                if (recentApps.isEmpty) {
                  return Card(
                    color: isDark ? kDarkCardColor : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding * 2),
                      child: Center(
                        child: Text(
                          'No recent applications',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: recentApps
                      .map(
                        (app) => _buildApplicationCard(
                          context,
                          app,
                          isDark,
                          applicationService,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_showCertificates) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? kDarkBackgroundColor : kBackgroundColor,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: isDark ? kDarkCardColor : Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => setState(() => _showCertificates = false),
                  ),
                  Text(
                    'My Certificates',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: kSubheadingFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(kDefaultPadding),
                children: _certificates
                    .map(
                      (cert) => CertificateCard(
                        name: cert['name'] as String,
                        dateIssued: cert['dateIssued'] as String,
                        status: cert['status'] as String,
                        onView: () =>
                            _showSnackBar(context, 'Viewing ${cert['name']}'),
                        onDownload: () => _showSnackBar(
                          context,
                          'Downloading ${cert['name']}',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }

    // Services data with descriptions
    final services = [
      {
        'icon': Icons.child_care,
        'title': 'Birth Registration',
        'description': 'Register a new birth and obtain birth certificate',
        'color': kPrimaryColor,
        'onTap': () => context.goNamed(Routes.birthRegistration),
      },
      {
        'icon': Icons.favorite,
        'title': 'Marriage Registration',
        'description': 'Register your marriage and get marriage certificate',
        'color': Colors.pink,
        'onTap': () => context.goNamed(Routes.marriageRegistration),
      },
      {
        'icon': Icons.heart_broken,
        'title': 'Divorce Registration',
        'description': 'Register divorce and obtain divorce certificate',
        'color': Colors.purple,
        'onTap': () => context.goNamed(Routes.divorceRegistration),
      },
      {
        'icon': Icons.celebration,
        'title': 'Death Registration',
        'description': 'Register a death and obtain death certificate',
        'color': Colors.grey[700]!,
        'onTap': () => context.goNamed(Routes.deathRegistration),
      },
      {
        'icon': Icons.description,
        'title': 'View Certificates',
        'description': 'Access and download all your certificates',
        'color': kAccentColor,
        'onTap': () => context.goNamed(Routes.certificates),
      },
      {
        'icon': Icons.assignment,
        'title': 'Application Status',
        'description': 'Track the status of your submitted applications',
        'color': Colors.orange,
        'onTap': () => context.goNamed(Routes.applicationStatus),
      },
      {
        'icon': Icons.people,
        'title': 'Family Profile',
        'description': 'Manage your family members and relationships',
        'color': Colors.teal,
        'onTap': () => context.goNamed(Routes.familyProfile),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kDarkBackgroundColor : kBackgroundColor,
      ),
      child: Column(
        children: [
          // Search bar header
          Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            decoration: BoxDecoration(
              color: isDark ? kDarkCardColor : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: isDark ? kDarkBackgroundColor : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: kDefaultPadding * 0.75,
                ),
              ),
            ),
          ),

          // Services list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: Row(
                    children: [
                      Icon(Icons.apps, color: kPrimaryColor, size: 24),
                      const SizedBox(width: kDefaultPadding * 0.5),
                      Text(
                        'Available Services',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: kSubheadingFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Services list items
                ...services.map(
                  (service) => ServiceListItem(
                    icon: service['icon'] as IconData,
                    title: service['title'] as String,
                    description: service['description'] as String,
                    iconColor: service['color'] as Color,
                    onTap: service['onTap'] as VoidCallback,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildFamilyTab removed - Family tab now navigates to FamilyProfilePage route

  Widget _buildProfileTab(BuildContext context, AuthProvider authProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kDarkBackgroundColor : kBackgroundColor,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Card(
              color: isDark ? kDarkCardColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding * 1.5),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor.withOpacity(0.3),
                            kSecondaryColor.withOpacity(0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    Text(
                      authProvider.user?.name ?? 'User',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: kSubheadingFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user?.email ?? '',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: kBodyFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding * 1.5),

            Card(
              color: isDark ? kDarkCardColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: kPrimaryColor),
                    title: Text(
                      'Personal Information',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () => _showSnackBar(context, 'Personal Information'),
                  ),
                  Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications,
                      color: kPrimaryColor,
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () => _showSnackBar(context, 'Notifications'),
                  ),
                  Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: kPrimaryColor),
                    title: Text(
                      'Privacy & Security',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () => _showSnackBar(context, 'Privacy & Security'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kDefaultPadding * 1.5),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  authProvider.logout();
                  context.goNamed(Routes.login);
                  _showSnackBar(
                    context,
                    'Logged out successfully',
                    isSuccess: true,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: kDefaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    Application app,
    bool isDark,
    ApplicationService applicationService,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final statusColor = _getStatusColor(app.status);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isDark ? kDarkCardColor : Colors.white,
      margin: const EdgeInsets.only(bottom: kDefaultPadding * 0.75),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                app.serviceType.icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              app.serviceType.displayName,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Submitted: ${dateFormat.format(app.submittedAt)}',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                app.status.displayName,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Action buttons based on status
          if (app.status == ApplicationStatus.pending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _handleRejectApplication(
                      context,
                      app.id,
                      applicationService,
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kErrorColor,
                      side: const BorderSide(color: kErrorColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _handleApproveApplication(
                      context,
                      app.id,
                      applicationService,
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSuccessColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else if (app.status == ApplicationStatus.approved &&
              app.certificateUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleDownloadCertificate(
                    context,
                    app.certificateUrl!,
                    app.serviceType.displayName,
                  ),
                  icon: const Icon(Icons.download),
                  label: const Text('Download Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return kSuccessColor;
      case ApplicationStatus.rejected:
        return kErrorColor;
      case ApplicationStatus.pending:
        return Colors.orange;
    }
  }

  Future<void> _handleApproveApplication(
    BuildContext context,
    String applicationId,
    ApplicationService applicationService,
  ) async {
    try {
      await applicationService.approveApplication(applicationId);
      if (context.mounted) {
        _showSnackBar(
          context,
          'Application approved successfully',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error approving application: $e');
      }
    }
  }

  Future<void> _handleRejectApplication(
    BuildContext context,
    String applicationId,
    ApplicationService applicationService,
  ) async {
    try {
      await applicationService.rejectApplication(applicationId);
      if (context.mounted) {
        _showSnackBar(context, 'Application rejected');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error rejecting application: $e');
      }
    }
  }

  Future<void> _handleDownloadCertificate(
    BuildContext context,
    String certificateUrl,
    String certificateType,
  ) async {
    // In a real app, this would download the actual certificate
    // For now, we'll show a success message
    _showSnackBar(
      context,
      'Downloading $certificateType certificate...',
      isSuccess: true,
    );

    // Simulate download
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      _showSnackBar(
        context,
        'Certificate downloaded successfully',
        isSuccess: true,
      );
    }
  }

  void _showNotificationsDialog(
    BuildContext context,
    ApplicationService applicationService,
    user,
  ) {
    final notifications = applicationService.getNotificationsForUser(user.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
              ? const Text('No notifications')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return ListTile(
                      leading: Icon(
                        notif.isRead
                            ? Icons.notifications_none
                            : Icons.notifications,
                        color: notif.isRead
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(notif.title),
                      subtitle: Text(notif.message),
                      trailing: notif.isRead
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                applicationService.markNotificationAsRead(
                                  notif.id,
                                );
                              },
                            ),
                      onTap: () {
                        applicationService.markNotificationAsRead(notif.id);
                        if (notif.actionRoute != null) {
                          Navigator.pop(context);
                          context.go(notif.actionRoute!);
                        }
                      },
                    );
                  },
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

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? kSuccessColor : null,
      ),
    );
  }

  // _showMemberDialog removed - now handled by FamilyProfilePage

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? kDarkCardColor : kPrimaryColor,
        elevation: 0,
        title: Text(
          _showCertificates
              ? 'Certificates'
              : ['Home', 'Services', 'Family', 'Profile'][_currentIndex],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Notification indicator
          Consumer<ApplicationService>(
            builder: (context, applicationService, child) {
              final user = authProvider.user;
              if (user == null) return const SizedBox.shrink();

              final unreadCount = applicationService
                  .getUnreadNotifications(user.id)
                  .length;

              if (unreadCount == 0) return const SizedBox.shrink();

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Navigate to notifications or show dialog
                      _showNotificationsDialog(
                        context,
                        applicationService,
                        user,
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        // The drawer icon (hamburger menu) will appear automatically
      ),
      drawer: const SidebarWidget(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(context, authProvider),
          _buildServicesTab(context),
          // Family tab navigates to Family Profile route instead
          const SizedBox.shrink(),
          _buildProfileTab(context, authProvider),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? kDarkCardColor : Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Family tab (index 2) navigates to the new Family Profile screen
            if (index == 2) {
              // Reset to Home tab before navigating (so when user returns, they see Home)
              setState(() {
                _currentIndex = 0;
              });
              context.goNamed(Routes.familyProfile);
            } else {
              setState(() {
                _currentIndex = index;
                _showCertificates = false;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Family'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      // FloatingActionButton removed - Family Profile screen has its own FAB
    );
  }
}
