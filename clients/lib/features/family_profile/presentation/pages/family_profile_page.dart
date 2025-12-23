import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../core/router/route_names.dart';
import 'add_family_member_page.dart';

/// Family Profile Page
/// Displays family information and members
/// Theme-aware with Material 3 design
class FamilyProfilePage extends StatefulWidget {
  const FamilyProfilePage({super.key});

  @override
  State<FamilyProfilePage> createState() => _FamilyProfilePageState();
}

class _FamilyProfilePageState extends State<FamilyProfilePage> {
  List<Map<String, dynamic>> _familyMembers = [];
  bool _isLoading = true;
  String? _error;
  String? _familyName;
  String? _headOfFamilyName;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationService = const ApplicationService();
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'Please log in to view family members';
        _isLoading = false;
      });
      return;
    }

    try {
      final members = await applicationService.getFamilyMembers(token: token);
      setState(() {
        _familyMembers = members;
        // Set family name from first member or use default
        if (members.isNotEmpty) {
          _familyName = '${members[0]['lastName']} Family';
          // Find head of family (could be first member or marked as head)
          final headMember = members.firstWhere(
            (m) => m['maritalStatus'] == 'married' || m['status'] == 'alive',
            orElse: () => members[0],
          );
          _headOfFamilyName = headMember['fullName'] as String? ?? 'N/A';
        } else {
          _familyName = 'Your Family';
          _headOfFamilyName = 'Not set';
        }
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = e.toString();
      // Check if error is about missing family
      if (errorMessage.contains('does not have an active family') ||
          errorMessage.contains('no active family')) {
        setState(() {
          _error = 'Please create your family record first';
          _isLoading = false;
        });
        // Redirect to create family after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.goNamed(Routes.createFamily);
          }
        });
      } else {
        setState(() {
          _error = 'Failed to load family members: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAddMember(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFamilyMemberPage(),
      ),
    );

    // Refresh list if member was added successfully
    if (result == true) {
      _loadFamilyMembers();
    }
  }

  void _handleMemberTap(BuildContext context, Map<String, dynamic> member) {
    final dateOfBirth = member['dateOfBirth'] != null
        ? DateTime.tryParse(member['dateOfBirth'].toString())
        : null;
    final age = dateOfBirth != null
        ? DateTime.now().difference(dateOfBirth).inDays ~/ 365
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member['fullName'] as String? ?? 'Unknown'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member['gender'] != null)
              Text('Gender: ${member['gender']}'),
            if (dateOfBirth != null)
              Text('Date of Birth: ${DateFormat('yyyy-MM-dd').format(dateOfBirth)}'),
            if (age != null) Text('Age: $age years'),
            if (member['placeOfBirth'] != null)
              Text('Place of Birth: ${member['placeOfBirth']}'),
            if (member['maritalStatus'] != null)
              Text('Marital Status: ${member['maritalStatus']}'),
            if (member['nationalIdNumber'] != null)
              Text('National ID: ${member['nationalIdNumber']}'),
            if (member['status'] != null) Text('Status: ${member['status']}'),
          ],
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Column(
        children: [
          // Family Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _familyName ?? 'Your Family',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Head of Family: ${_headOfFamilyName ?? 'Not set'}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Members Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Family Members',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_familyMembers.length} members',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Family Members List
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
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (_error!.contains('create your family'))
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.goNamed(Routes.createFamily);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Family'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: _loadFamilyMembers,
                                child: const Text('Retry'),
                              ),
                          ],
                        ),
                      )
                    : _familyMembers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No family members yet',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the button below to add your first family member',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _familyMembers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final member = _familyMembers[index];
                              final dateOfBirth = member['dateOfBirth'] != null
                                  ? DateTime.tryParse(
                                      member['dateOfBirth'].toString())
                                  : null;
                              final age = dateOfBirth != null
                                  ? DateTime.now()
                                          .difference(dateOfBirth)
                                          .inDays ~/
                                      365
                                  : null;

                              // Determine relationship based on marital status
                              String relationship = 'Member';
                              if (member['maritalStatus'] == 'married') {
                                relationship = 'Spouse';
                              } else if (member['maritalStatus'] == 'divorced') {
                                relationship = 'Divorced';
                              }

                              return _FamilyMemberCard(
                                name: member['fullName'] as String? ??
                                    '${member['firstName']} ${member['lastName']}',
                                relationship: relationship,
                                age: age,
                                onTap: () => _handleMemberTap(context, member),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          onPressed: () => _handleAddMember(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Add Family Member'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Compact Family Member Card
/// Theme-aware compact card for displaying family member info
class _FamilyMemberCard extends StatelessWidget {
  final String name;
  final String relationship;
  final int? age;
  final VoidCallback? onTap;

  const _FamilyMemberCard({
    required this.name,
    required this.relationship,
    this.age,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Member details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relationship,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
