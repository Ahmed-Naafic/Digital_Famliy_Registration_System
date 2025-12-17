// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/utils/constants.dart';
// import '../../../../core/theme_provider.dart';

// /// Family Member Card Widget
// /// Theme-aware card displaying family member information
// /// Adapts to light and dark modes
// class FamilyMemberCard extends StatelessWidget {
//   /// Family member's name
//   final String name;

//   /// Relationship to the user
//   final String relationship;

//   /// Age of the family member
//   final int? age;

//   /// Callback when card is tapped
//   final VoidCallback? onTap;

//   /// Constructor for FamilyMemberCard
//   const FamilyMemberCard({
//     super.key,
//     required this.name,
//     required this.relationship,
//     this.age,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = themeProvider.isDarkMode;

//     return Card(
//       elevation: 0,
//       color: isDark ? kDarkCardColor : Colors.white,
//       margin: const EdgeInsets.only(bottom: kDefaultPadding * 0.75),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(kDefaultPadding),
//           child: Row(
//             children: [
//               // Avatar/Icon
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       kPrimaryColor.withOpacity(0.3),
//                       kSecondaryColor.withOpacity(0.3),
//                     ],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(width: kDefaultPadding),
//               // Member details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontSize: kSubheadingFontSize,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.people,
//                           size: 16,
//                           color: isDark ? Colors.grey[400] : Colors.grey[600],
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           relationship,
//                           style: TextStyle(
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                             fontSize: kBodyFontSize,
//                           ),
//                         ),
//                         if (age != null) ...[
//                           const SizedBox(width: kDefaultPadding),
//                           Icon(
//                             Icons.cake,
//                             size: 16,
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             '$age years',
//                             style: TextStyle(
//                               color: isDark ? Colors.grey[400] : Colors.grey[600],
//                               fontSize: kBodyFontSize,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // Arrow icon
//               Icon(
//                 Icons.chevron_right,
//                 color: isDark ? Colors.grey[500] : Colors.grey[400],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
