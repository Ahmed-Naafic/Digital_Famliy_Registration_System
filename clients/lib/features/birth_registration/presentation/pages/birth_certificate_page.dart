import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../features/applications/providers/application_provider.dart';
import '../../../../features/application_status/data/application_model.dart';
import '../../../../features/applications/data/application_service.dart'
    as api_service;

/// Birth Certificate Generation Page
/// Shows approved birth applications and allows certificate generation
class BirthCertificatePage extends StatefulWidget {
  const BirthCertificatePage({super.key});

  @override
  State<BirthCertificatePage> createState() => _BirthCertificatePageState();
}

class _BirthCertificatePageState extends State<BirthCertificatePage> {
  bool _isLoading = false;
  bool _isGenerating = false;
  List<Application> _approvedBirthApplications = [];
  Map<String, String> _generatedCertificates =
      {}; // applicationId -> certificateId
  Map<String, String> _certificateDownloadUrls =
      {}; // certificateId -> downloadUrl

  @override
  void initState() {
    super.initState();
    _loadApprovedApplications();
  }

  Future<void> _loadApprovedApplications() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token != null && token.isNotEmpty) {
        await provider.fetchMyApplications(token: token);

        // Filter approved birth applications
        final allApps = provider.applications;
        final approvedApps = allApps
            .where(
              (app) =>
                  app.serviceType == ApplicationType.birth &&
                  app.status == ApplicationStatus.approved,
            )
            .toList();

        // Check for certificates for each application individually
        final applicationService = const api_service.ApplicationService();
        final newGeneratedCertificates = <String, String>{};
        final newCertificateDownloadUrls = <String, String>{};

        for (final app in approvedApps) {
          try {
            final certificate = await applicationService
                .getCertificateByApplicationId(
                  applicationId: app.id,
                  token: token,
                );

            if (certificate != null) {
              final certId = certificate['certificateId'] as String?;
              final downloadUrl = certificate['downloadUrl'] as String?;
              if (certId != null) {
                newGeneratedCertificates[app.id] = certId;
                if (downloadUrl != null) {
                  newCertificateDownloadUrls[certId] = downloadUrl;
                } else {
                  newCertificateDownloadUrls[certId] =
                      '/api/certificates/$certId/download';
                }
              }
            }
          } catch (e) {
            // If certificate check fails for an application, continue
            debugPrint(
              'Error checking certificate for application ${app.id}: $e',
            );
          }
        }

        setState(() {
          _approvedBirthApplications = approvedApps;
          _generatedCertificates = newGeneratedCertificates;
          _certificateDownloadUrls = newCertificateDownloadUrls;
        });
      } else {
        // No token - just filter applications
        final allApps = provider.applications;
        setState(() {
          _approvedBirthApplications = allApps
              .where(
                (app) =>
                    app.serviceType == ApplicationType.birth &&
                    app.status == ApplicationStatus.approved,
              )
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading applications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateCertificate(String applicationId) async {
    setState(() => _isGenerating = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required');
      }

      // Call API to generate certificate
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/certificates/birth');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'applicationId': applicationId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        final downloadUrl = data['downloadUrl'] as String;
        final certificateId = data['certificateId'] as String;

        if (mounted) {
          // Store generated certificate info
          setState(() {
            _generatedCertificates[applicationId] = certificateId;
            _certificateDownloadUrls[certificateId] = downloadUrl;
          });

          // Reload applications to refresh certificate status
          await _loadApprovedApplications();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            body['message'] as String? ?? 'Failed to generate certificate';
        throw Exception(message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showAllCertificatesDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? kDarkCardColor : Colors.white,
        title: Text(
          'Generated Certificates',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _generatedCertificates.isEmpty
              ? Text(
                  'No certificates generated yet.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _generatedCertificates.length,
                  itemBuilder: (context, index) {
                    final entry = _generatedCertificates.entries.elementAt(
                      index,
                    );
                    final appId = entry.key;
                    final certId = entry.value;
                    final downloadUrl = _certificateDownloadUrls[certId];

                    // Find the application to get child name
                    final app = _approvedBirthApplications.firstWhere(
                      (a) => a.id == appId,
                      orElse: () => _approvedBirthApplications.first,
                    );
                    final childName =
                        app.formData['birth']?['child']?['name'] ?? 'Unknown';

                    return ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: kPrimaryColor,
                      ),
                      title: Text(
                        childName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Certificate ID: ${certId.substring(0, 8)}...',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      trailing: downloadUrl != null
                          ? IconButton(
                              icon: const Icon(
                                Icons.open_in_new,
                                color: kPrimaryColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _viewAndShareCertificate(
                                  certId,
                                  downloadUrl,
                                  childName,
                                );
                              },
                            )
                          : null,
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

  Future<void> _viewAndShareCertificate(
    String certificateId,
    String downloadUrl,
    String childName,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final isDark = themeProvider.isDarkMode;
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required');
      }

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Download PDF
      final uri = Uri.parse('${ApiConstants.baseUrl}$downloadUrl');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Save to temporary directory
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/birth_certificate_$certificateId.pdf',
        );
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          // Show options: View or Share
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              decoration: BoxDecoration(
                color: isDark ? kDarkCardColor : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                left: kDefaultPadding,
                right: kDefaultPadding,
                top: kDefaultPadding,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + kDefaultPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: kDefaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Certificate: $childName',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  ListTile(
                    leading: const Icon(Icons.share, color: kPrimaryColor),
                    title: Text(
                      'Share Certificate',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.shareXFiles([
                        XFile(file.path),
                      ], text: 'Birth Certificate: $childName');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download, color: kPrimaryColor),
                    title: Text(
                      'Download Certificate',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await _saveToDownloads(file, childName, certificateId);
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to download certificate');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveToDownloads(
    File tempFile,
    String childName,
    String certificateId,
  ) async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Verify temp file exists
      if (!await tempFile.exists()) {
        throw Exception('Temporary file not found');
      }

      // Try to get Downloads directory
      Directory? downloadsDir;
      String? downloadsPath;

      // For Android, try to get external storage Downloads directory
      if (Platform.isAndroid) {
        try {
          // Method 1: Direct path to Downloads (most reliable)
          downloadsPath = '/storage/emulated/0/Download';
          downloadsDir = Directory(downloadsPath);

          if (!await downloadsDir.exists()) {
            try {
              await downloadsDir.create(recursive: true);
            } catch (e) {
              debugPrint('Cannot create Downloads directory: $e');
              downloadsDir = null;
            }
          }
        } catch (e) {
          debugPrint('Error accessing Downloads directory: $e');
          downloadsDir = null;
        }

        // Method 2: Try via external storage
        if (downloadsDir == null || !await downloadsDir.exists()) {
          try {
            final externalStorage = await getExternalStorageDirectory();
            if (externalStorage != null) {
              // Navigate to Downloads folder
              downloadsPath =
                  '${externalStorage.path.split('/Android')[0]}/Download';
              downloadsDir = Directory(downloadsPath);

              if (!await downloadsDir.exists()) {
                await downloadsDir.create(recursive: true);
              }
            }
          } catch (e) {
            debugPrint('Error accessing external storage: $e');
          }
        }
      }

      // Fallback to external storage directory if Downloads not available
      if (downloadsDir == null || !await downloadsDir.exists()) {
        try {
          final externalStorage = await getExternalStorageDirectory();
          if (externalStorage != null) {
            downloadsPath = '${externalStorage.path}/Downloads';
            downloadsDir = Directory(downloadsPath);
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
          }
        } catch (e) {
          debugPrint('Error creating Downloads subfolder: $e');
        }
      }

      // Final fallback: use external storage root
      if (downloadsDir == null || !await downloadsDir.exists()) {
        try {
          final externalStorage = await getExternalStorageDirectory();
          if (externalStorage != null) {
            downloadsPath = externalStorage.path;
            downloadsDir = externalStorage;
          }
        } catch (e) {
          debugPrint('Error accessing external storage root: $e');
        }
      }

      // If still no directory, use app documents directory
      if (downloadsDir == null) {
        final appDocDir = await getApplicationDocumentsDirectory();
        downloadsPath = appDocDir.path;
        downloadsDir = appDocDir;
      }

      // Create safe filename
      final safeChildName = childName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .trim();
      final fileName =
          'Birth_Certificate_${safeChildName}_${certificateId.substring(0, 8)}.pdf';
      final destinationFile = File('${downloadsDir.path}/$fileName');

      // Copy file from temp to Downloads
      try {
        await tempFile.copy(destinationFile.path);
      } catch (e) {
        debugPrint('Error copying file: $e');
        // Try to write directly instead
        final bytes = await tempFile.readAsBytes();
        await destinationFile.writeAsBytes(bytes, flush: true);
      }

      // Verify file was copied successfully
      if (!await destinationFile.exists()) {
        throw Exception(
          'File was not saved successfully. Check storage permissions.',
        );
      }

      final fileSize = await destinationFile.length();
      if (fileSize == 0) {
        throw Exception('File was saved but is empty');
      }

      debugPrint('✅ File saved successfully: ${destinationFile.path}');
      debugPrint('✅ File size: $fileSize bytes');
      debugPrint('✅ File exists: ${await destinationFile.exists()}');

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Certificate downloaded successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Text(
                //   'Location: ${downloadsPath ?? downloadsDir.path}',
                //   style: const TextStyle(fontSize: 12),
                // ),
                // Text('File: $fileName', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  // Use platform channel to open file on Android
                  if (Platform.isAndroid) {
                    const platform = MethodChannel(
                      'com.example.digital_family_system/open_file',
                    );
                    try {
                      await platform.invokeMethod('openFile', {
                        'filePath': destinationFile.path,
                        'mimeType': 'application/pdf',
                      });
                      // Success - file should open
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening PDF...'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Platform channel error: $e');
                      // Show file location if opening fails
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cannot open file automatically.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'File saved at:\n${destinationFile.path}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Please use a file manager to open it.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 6),
                          ),
                        );
                      }
                    }
                  } else {
                    // For iOS/other platforms, show file location
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'File saved at: ${destinationFile.path}\n'
                            'Please use a file manager to open it.',
                          ),
                          backgroundColor: Colors.blue,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('Error opening file: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: $e\n'
                          'File location: ${destinationFile.path}',
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving certificate: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('Error in _saveToDownloads: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? kDarkCardColor : kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed(Routes.dashboard),
        ),
        title: const Text(
          'Birth Certificate',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: _generatedCertificates.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  tooltip: 'View All Certificates',
                  onPressed: () => _showAllCertificatesDialog(context),
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _approvedBirthApplications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Approved Birth Records',
                    style: TextStyle(
                      fontSize: kSubheadingFontSize,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You need an approved birth registration to generate a certificate.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: kBodyFontSize,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(kDefaultPadding),
              itemCount: _approvedBirthApplications.length,
              itemBuilder: (context, index) {
                final app = _approvedBirthApplications[index];
                final childName =
                    app.formData['birth']?['child']?['name'] ?? 'Unknown';
                final dateOfBirth =
                    app.formData['birth']?['child']?['dateOfBirth'];

                final hasCertificate = _generatedCertificates.containsKey(
                  app.id,
                );
                final certificateId = _generatedCertificates[app.id];
                final downloadUrl = certificateId != null
                    ? _certificateDownloadUrls[certificateId]
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(kDefaultPadding),
                    leading: const Icon(
                      Icons.child_care,
                      color: kPrimaryColor,
                      size: 32,
                    ),
                    title: Text(
                      childName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dateOfBirth != null
                            ? Text(
                                'Date of Birth: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(dateOfBirth))}',
                              )
                            : const Text('Date of Birth: N/A'),
                        if (hasCertificate)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Certificate Generated',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    trailing: hasCertificate && downloadUrl != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: kPrimaryColor,
                                ),
                                tooltip: 'View Certificate',
                                onPressed: () => _viewAndShareCertificate(
                                  certificateId!,
                                  downloadUrl,
                                  childName,
                                ),
                              ),
                            ],
                          )
                        : _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ElevatedButton(
                            onPressed: () => _generateCertificate(app.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            child: const Text('Generate'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
