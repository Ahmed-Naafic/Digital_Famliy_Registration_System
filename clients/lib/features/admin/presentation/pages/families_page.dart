import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/admin_scaffold.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';

/// Families Management Page
/// Displays all families with search and management options
class FamiliesPage extends StatefulWidget {
  const FamiliesPage({super.key});

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _families = [];
  int _totalFamilies = 0;
  int _currentPage = 1;
  final int _limit = 50;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilies({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Authentication token missing';
          _isLoading = false;
        });
        return;
      }

      final result = await applicationService.getAllFamilies(
        token: token,
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      if (mounted) {
        setState(() {
          _families =
              (result['families'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _totalFamilies = result['total'] as int? ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load families: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // Debounce search - reload after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value && mounted) {
        _loadFamilies(resetPage: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdminScaffold(
      title: 'Families Management',
      body: RefreshIndicator(
        onRefresh: () => _loadFamilies(),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by family name or number...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadFamilies(resetPage: true);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Families List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: TextStyle(color: colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadFamilies(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _families.isEmpty
                          ? Center(
                              child: Text(
                                'No families found',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _families.length,
                              itemBuilder: (context, index) {
                                final family = _families[index];
                                final memberCount =
                                    family['memberCount'] as int? ?? 0;
                                final linkedUsersCount =
                                    family['linkedUsersCount'] as int? ?? 0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.family_restroom,
                                        color: colorScheme.primary,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      family['familyName'] as String? ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 4),
                                        if (family['familyNumber'] != null)
                                          Text(
                                            'Number: ${family['familyNumber']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people,
                                              size: 14,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '$memberCount members',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.primary,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.person,
                                              size: 14,
                                              color: colorScheme.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '$linkedUsersCount users',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.secondary,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (family['address'] != null &&
                                            (family['address'] as String)
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  family['address'] as String,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
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
                                        const PopupMenuItem(
                                          value: 'members',
                                          child: Row(
                                            children: [
                                              Icon(Icons.people),
                                              SizedBox(width: 8),
                                              Text('View Members'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'view') {
                                          _showFamilyDetails(context, family);
                                        } else if (value == 'members') {
                                          _showFamilyMembers(context, family);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            // Pagination Info
            if (!_isLoading && _error == null && _families.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_families.length} of $_totalFamilies families',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_totalFamilies > _limit)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pagination coming soon'),
                            ),
                          );
                        },
                        child: const Text('Load More'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFamilyDetails(
    BuildContext context,
    Map<String, dynamic> family,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkedUsers = family['linkedUsers'] as List<dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        title: Row(
          children: [
            Icon(Icons.family_restroom, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                family['familyName'] as String? ?? 'Family Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Family Name',
                family['familyName']?.toString() ?? 'N/A',
              ),
              if (family['familyNumber'] != null)
                _buildDetailRow(
                  'Family Number',
                  family['familyNumber']?.toString() ?? 'N/A',
                ),
              _buildDetailRow(
                'Status',
                (family['status'] as String? ?? 'active').toUpperCase(),
              ),
              _buildDetailRow(
                'Members',
                '${family['memberCount'] ?? 0}',
              ),
              _buildDetailRow(
                'Linked Users',
                '${family['linkedUsersCount'] ?? 0}',
              ),
              if (family['address'] != null &&
                  (family['address'] as String).isNotEmpty)
                _buildDetailRow(
                  'Address',
                  family['address']?.toString() ?? 'N/A',
                ),
              if (family['headOfFamily'] != null) ...[
                const Divider(),
                Text(
                  'Head of Family:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(family['headOfFamily']['name']?.toString() ?? 'N/A'),
              ],
              if (linkedUsers != null && linkedUsers.isNotEmpty) ...[
                const Divider(),
                Text(
                  'Linked Users:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...linkedUsers.map((user) {
                  final userMap = user as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${userMap['name']} (${userMap['email']})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ],
              if (family['createdAt'] != null)
                _buildDetailRow(
                  'Created',
                  DateTime.parse(family['createdAt'] as String)
                      .toString()
                      .substring(0, 10),
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
            width: 120,
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

  void _showFamilyMembers(
    BuildContext context,
    Map<String, dynamic> family,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final familyId = family['_id'] as String?;

    if (familyId == null || familyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family ID is missing')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication token missing')),
          );
        }
        return;
      }

      final members = await applicationService.getFamilyMembersByFamilyId(
        familyId: familyId,
        token: token,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show members dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? colorScheme.surface : Colors.white,
            title: Row(
              children: [
                Icon(Icons.people, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Family Members - ${family['familyName']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: members.isEmpty
                  ? const Text('No members found in this family')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary.withOpacity(0.2),
                              child: Icon(
                                (member['gender'] as String?) == 'male'
                                    ? Icons.male
                                    : Icons.female,
                                color: colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              member['fullName'] as String? ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (member['dateOfBirth'] != null)
                                  Text(
                                    'DOB: ${DateTime.parse(member['dateOfBirth'] as String).toString().substring(0, 10)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                if (member['nationalIdNumber'] != null)
                                  Text(
                                    'NID: ${member['nationalIdNumber']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                if (member['maritalStatus'] != null)
                                  Text(
                                    'Status: ${member['maritalStatus']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            trailing: member['status'] == 'alive'
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : Icon(Icons.cancel, color: Colors.red),
                            onTap: () {
                              _showMemberDetails(context, member);
                            },
                          ),
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
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMemberDetails(
    BuildContext context,
    Map<String, dynamic> member,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        title: Text(member['fullName'] as String? ?? 'Member Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('First Name', member['firstName']?.toString() ?? 'N/A'),
              _buildDetailRow('Last Name', member['lastName']?.toString() ?? 'N/A'),
              _buildDetailRow('Gender', (member['gender'] as String? ?? 'N/A').toUpperCase()),
              if (member['dateOfBirth'] != null)
                _buildDetailRow(
                  'Date of Birth',
                  DateTime.parse(member['dateOfBirth'] as String).toString().substring(0, 10),
                ),
              if (member['placeOfBirth'] != null)
                _buildDetailRow('Place of Birth', member['placeOfBirth']?.toString() ?? 'N/A'),
              if (member['nationalIdNumber'] != null)
                _buildDetailRow('National ID', member['nationalIdNumber']?.toString() ?? 'N/A'),
              _buildDetailRow('Marital Status', (member['maritalStatus'] as String? ?? 'N/A').toUpperCase()),
              _buildDetailRow('Life Status', (member['status'] as String? ?? 'alive').toUpperCase()),
              if (member['fatherName'] != null) ...[
                const Divider(),
                _buildDetailRow('Father', member['fatherName']?.toString() ?? 'N/A'),
              ],
              if (member['motherName'] != null)
                _buildDetailRow('Mother', member['motherName']?.toString() ?? 'N/A'),
              if (member['spouseName'] != null)
                _buildDetailRow('Spouse', member['spouseName']?.toString() ?? 'N/A'),
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
}

