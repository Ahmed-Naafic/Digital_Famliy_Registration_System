// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';

// /// Birth Registration Page
// /// Form for registering a new birth
// /// Theme-aware with Material 3 design
// class BirthRegistrationPage extends StatefulWidget {
//   const BirthRegistrationPage({super.key});

//   @override
//   State<BirthRegistrationPage> createState() => _BirthRegistrationPageState();
// }

// class _BirthRegistrationPageState extends State<BirthRegistrationPage> {
//   final _formKey = GlobalKey<FormBuilderState>();
//   bool _isLoading = false;

//   void _handleSubmit() async {
//     if (_formKey.currentState?.saveAndValidate() ?? false) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 1));

//       setState(() {
//         _isLoading = false;
//       });

//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Registration Submitted'),
//             content: const Text(
//               'Your birth registration has been submitted successfully. You will be notified once it is processed.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Birth Registration')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: FormBuilder(
//           // key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header Card
//               Card(
//                 elevation: isDark ? 0 : 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: colorScheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.child_care,
//                           color: colorScheme.primary,
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Register New Birth',
//                               style: Theme.of(context).textTheme.titleLarge
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Please fill in all required information',
//                               style: Theme.of(context).textTheme.bodySmall
//                                   ?.copyWith(
//                                     color: colorScheme.onSurface.withOpacity(
//                                       0.6,
//                                     ),
//                                   ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Child Information Section
//               Text(
//                 'Child Information',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderTextField(
//                 name: 'childName',
//                 decoration: InputDecoration(
//                   labelText: 'Child Full Name *',
//                   hintText: 'Enter child\'s full name',
//                   prefixIcon: const Icon(Icons.person),
//                 ),
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                   FormBuilderValidators.minLength(2),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderDateTimePicker(
//                 name: 'dateOfBirth',
//                 decoration: InputDecoration(
//                   labelText: 'Date of Birth *',
//                   hintText: 'Select date of birth',
//                   prefixIcon: const Icon(Icons.calendar_today),
//                 ),
//                 validator: FormBuilderValidators.required(),
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime(1900),
//                 lastDate: DateTime.now(),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderTextField(
//                 name: 'placeOfBirth',
//                 decoration: InputDecoration(
//                   labelText: 'Place of Birth *',
//                   hintText: 'Enter place of birth',
//                   prefixIcon: const Icon(Icons.location_on),
//                 ),
//                 validator: FormBuilderValidators.required(),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderDropdown<String>(
//                 name: 'gender',
//                 decoration: InputDecoration(
//                   labelText: 'Gender *',
//                   prefixIcon: const Icon(Icons.people),
//                 ),
//                 items: ['Male', 'Female', 'Other']
//                     .map(
//                       (gender) =>
//                           DropdownMenuItem(value: gender, child: Text(gender)),
//                     )
//                     .toList(),
//                 validator: FormBuilderValidators.required(),
//               ),
//               const SizedBox(height: 24),

//               // Parent Information Section
//               Text(
//                 'Parent Information',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderTextField(
//                 name: 'fatherName',
//                 decoration: InputDecoration(
//                   labelText: 'Father\'s Full Name *',
//                   hintText: 'Enter father\'s full name',
//                   prefixIcon: const Icon(Icons.person_outline),
//                 ),
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                   FormBuilderValidators.minLength(2),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderTextField(
//                 name: 'motherName',
//                 decoration: InputDecoration(
//                   labelText: 'Mother\'s Full Name *',
//                   hintText: 'Enter mother\'s full name',
//                   prefixIcon: const Icon(Icons.person_outline),
//                 ),
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                   FormBuilderValidators.minLength(2),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               FormBuilderTextField(
//                 name: 'nationalId',
//                 decoration: InputDecoration(
//                   labelText: 'National ID (Optional)',
//                   hintText: 'Enter national ID if available',
//                   prefixIcon: const Icon(Icons.badge),
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Submit Button
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _handleSubmit,
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Submit Registration'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

