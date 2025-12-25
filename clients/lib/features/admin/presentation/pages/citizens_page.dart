import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/admin_scaffold.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';

/// Citizens Management Page
/// Displays all citizens with search and management options
class CitizensPage extends StatefulWidget {
  const CitizensPage({super.key});

  @override
  State<CitizensPage> createState() => _CitizensPageState();
}

class _CitizensPageState extends State<CitizensPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _citizens = [];
  int _totalCitizens = 0;
  int _currentPage = 1;
  final int _limit = 50;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCitizens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCitizens({bool resetPage = false}) async {
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

      final result = await applicationService.getAllCitizens(
        token: token,
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      if (mounted) {
        setState(() {
          _citizens =
              (result['citizens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _totalCitizens = result['total'] as int? ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load citizens: $e';
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
        _loadCitizens(resetPage: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdminScaffold(
      title: 'Citizens',
      body: Column(
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
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadCitizens(resetPage: true);
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

          // Citizens List
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
                          onPressed: () => _loadCitizens(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _citizens.isEmpty
                ? Center(
                    child: Text(
                      'No citizens found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadCitizens(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _citizens.length,
                      itemBuilder: (context, index) {
                        final citizen = _citizens[index];
                        final isActive = citizen['status'] == 'active';
                        final hasFamily =
                            citizen['hasFamily'] as bool? ?? false;
                        final familyMembersCount =
                            citizen['familyMembersCount'] as int? ?? 0;

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
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary.withOpacity(
                                0.2,
                              ),
                              child: Icon(
                                Icons.person,
                                color: colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              citizen['fullName'] as String? ?? 'Unknown',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  citizen['email'] as String? ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (hasFamily) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.family_restroom,
                                        size: 14,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${citizen['familyName'] ?? 'Family'} • $familyMembersCount members',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'No family registered',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.5),
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Suspended',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton(
                                  iconSize: 20,
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility, size: 18),
                                          SizedBox(width: 8),
                                          Text('View Details'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: isActive ? 'suspend' : 'activate',
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isActive
                                                ? Icons.block
                                                : Icons.check_circle,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isActive
                                                ? 'Suspend User'
                                                : 'Activate User',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'view') {
                                      _showCitizenDetails(context, citizen);
                                    } else if (value == 'suspend' ||
                                        value == 'activate') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${value == 'suspend' ? 'Suspend' : 'Activate'} action coming soon',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: false,
                          ),
                        );
                      },
                    ),
                  ),
          ),

          // Pagination Info
          if (!_isLoading && _error == null && _citizens.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_citizens.length} of $_totalCitizens citizens',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_totalCitizens > _limit)
                    TextButton(
                      onPressed: () {
                        // Load more functionality can be added here
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
    );
  }

  void _showCitizenDetails(BuildContext context, Map<String, dynamic> citizen) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        title: Text(
          'Citizen Details',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Name',
                citizen['fullName']?.toString() ?? 'Unknown',
              ),
              _buildDetailRow(
                'Email',
                citizen['email']?.toString() ?? 'Unknown',
              ),
              if (citizen['phoneNumber'] != null)
                _buildDetailRow(
                  'Phone',
                  citizen['phoneNumber']?.toString() ?? 'N/A',
                ),
              _buildDetailRow(
                'Status',
                (citizen['status'] as String? ?? 'active').toUpperCase(),
              ),
              _buildDetailRow(
                'Verified',
                (citizen['isVerified'] as bool? ?? false) ? 'Yes' : 'No',
              ),
              if (citizen['hasFamily'] == true) ...[
                const Divider(),
                _buildDetailRow(
                  'Family Name',
                  citizen['familyName']?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  'Family Members',
                  '${citizen['familyMembersCount'] ?? 0}',
                ),
              ],
              if (citizen['createdAt'] != null)
                _buildDetailRow(
                  'Registered',
                  DateTime.parse(
                    citizen['createdAt'] as String,
                  ).toString().substring(0, 10),
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
}
