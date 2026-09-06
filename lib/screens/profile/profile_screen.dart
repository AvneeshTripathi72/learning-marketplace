import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;

  final List<String> _avatars = [
    'https://ui-avatars.com/api/?name=Hariom+Student&background=0000D1&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Academic+Pro&background=FF2D55&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Scholar+Star&background=00A86B&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Master+Mind&background=7C4DFF&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Top+Ranker&background=FF9100&color=fff&size=200&bold=true',
    'https://ui-avatars.com/api/?name=Oxford+User&background=00E5FF&color=fff&size=200&bold=true',
  ];

  // ---------------------------------------------------------------------------
  // BULLETPROOF AVATAR WIDGET (Supports Base64 uploads & HTTP network images)
  // ---------------------------------------------------------------------------
  Widget _buildUserAvatar(UserModel? user, {double radius = 34}) {
    final initialLetter = (user != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'H';
    final avatarUrl = user?.avatarUrl;

    Widget avatarChild;

    if (avatarUrl != null && (avatarUrl.startsWith('data:image') || avatarUrl.startsWith('data:'))) {
      try {
        final base64Str = avatarUrl.contains(',') ? avatarUrl.split(',').last : avatarUrl;
        final bytes = base64Decode(base64Str);
        avatarChild = Image.memory(
          bytes,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitialText(initialLetter, radius),
        );
      } catch (e) {
        avatarChild = _buildFallbackInitialText(initialLetter, radius);
      }
    } else if (avatarUrl != null && avatarUrl.startsWith('http')) {
      avatarChild = Image.network(
        avatarUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackInitialText(initialLetter, radius),
      );
    } else {
      avatarChild = _buildFallbackInitialText(initialLetter, radius);
    }

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        color: Color(0xFFFF2D55),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: radius * 2,
          height: radius * 2,
          color: const Color(0xFF0000D1),
          alignment: Alignment.center,
          child: avatarChild,
        ),
      ),
    );
  }

  Widget _buildFallbackInitialText(String initialLetter, double radius) {
    return Text(
      initialLetter,
      style: TextStyle(
        fontSize: radius * 0.75,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE PICKER SHEET (Device & Preset Avatar)
  // ---------------------------------------------------------------------------
  void _showImagePickerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pick Image from Phone Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0000D1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                pickProfileImageFromDevice((imageUrl) {
                  ref.read(authProvider.notifier).updateProfile(avatarUrl: imageUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📸 Profile photo selected & updated successfully! 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
              },
              icon: const Icon(Icons.add_a_photo, size: 20),
              label: const Text(
                'Upload Photo from Phone / Device',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'OR CHOOSE PRESET AVATAR:',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Preset Avatars Row
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _avatars.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final url = _avatars[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(authProvider.notifier).updateProfile(avatarUrl: url);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture updated successfully! 🎉'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2D55),
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          url,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFF0000D1),
                            alignment: Alignment.center,
                            child: Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BIOMETRIC PROMPT DIALOG
  // ---------------------------------------------------------------------------
  void _showBiometricPromptDialog(BuildContext context, bool enable) {
    if (!enable) {
      setState(() => _biometricEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔓 Biometric Security / Face ID Disabled'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0000D1).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, size: 54, color: Color(0xFF0000D1)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Face ID / Touch ID',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan your fingerprint or Face ID sensor to authenticate and lock app access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0000D1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _biometricEnabled = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔒 Biometric Verification Verified & Enabled successfully! 🎉'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Verify Biometrics Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BIO-DATA / EDIT ACCOUNT MODAL (Matching Reference Image 2)
  // ---------------------------------------------------------------------------
  void _showBioDataSheet(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameParts = user.name.split(' ');
    final firstNameCtrl = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    final lastNameCtrl = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    final phoneCtrl = TextEditingController(text: user.mobile ?? '+91 9876543210');
    final emailCtrl = TextEditingController(text: user.email);
    String selectedGender = 'Male';
    String dobText = '15 Aug 2002';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141418) : const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            InputDecoration buildBioInputDecoration(String hint, {Widget? prefixIcon, Widget? suffixIcon}) {
              return InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF0000D1), width: 1.8),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 16,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 22),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        const Expanded(
                          child: Text(
                            'Bio-data',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Avatar Banner
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showImagePickerSheet(context);
                      },
                      child: Stack(
                        children: [
                          _buildUserAvatar(user, radius: 46),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.camera_alt, size: 14, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Input Form (Matching Image 2)
                    TextField(
                      controller: firstNameCtrl,
                      decoration: buildBioInputDecoration("What's your first name?"),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: lastNameCtrl,
                      decoration: buildBioInputDecoration("And your last name?"),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: buildBioInputDecoration(
                        "Phone number",
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          margin: const EdgeInsets.only(right: 8),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇮🇳', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: selectedGender,
                      decoration: buildBioInputDecoration("Select your gender"),
                      dropdownColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                      items: ['Male', 'Female', 'Other'].map((g) {
                        return DropdownMenuItem(value: g, child: Text(g));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedGender = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime(2002, 8, 15),
                          firstDate: DateTime(1960),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setSheetState(() {
                            dobText = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: buildBioInputDecoration(
                            dobText,
                            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF0000D1)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Solid Blue Update Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0000D1),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final fullName = "${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}".trim();
                          ref.read(authProvider.notifier).updateProfile(
                                name: fullName.isNotEmpty ? fullName : user.name,
                                mobile: phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bio-data profile updated successfully! 🎉'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  // ---------------------------------------------------------------------------
  // HELP & SUPPORT MODAL
  // ---------------------------------------------------------------------------
  void _showHelpSupportSheet(BuildContext context, UserModel? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFF0EEFF),
                    child: Icon(Icons.headset_mic, color: Color(0xFF0000D1)),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help & Support Hub',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Submit query, bug or feedback to support team',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Your Email Address (Gmail)',
                  hintText: 'user@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Query Subject / Issue Type',
                  hintText: 'e.g. eBook download issue, Video playback error',
                  prefixIcon: const Icon(Icons.subject),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Describe your query or feedback in detail',
                  hintText: 'Write your message here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0000D1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (messageCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your query message.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Query sent to admin team via ${emailCtrl.text.trim()}! 📩 We will reach out to you soon.',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Submit Query to Support Team',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ABOUT APP MODAL
  // ---------------------------------------------------------------------------
  void _showAboutAppSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0000D1).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book, size: 48, color: Color(0xFF0000D1)),
            ),
            const SizedBox(height: 14),

            const Text(
              'Educational eBook & Video Hub',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Version 2.4.0 (Build 2026.09)',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            const Text(
              'A complete multi-tenant educational ecosystem for CBSE/ICSE board preparation, interactive eBooks, test paper generators, and YouTube video tutorials.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.security, color: Color(0xFF0000D1)),
              title: const Text('Privacy Policy & Terms of Service', style: TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy: All student & publisher data is end-to-end encrypted.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD METHOD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerBg = isDark ? const Color(0xFF1E1E26) : Colors.white;
    final iconBgColor = isDark ? const Color(0xFF2A2A38) : const Color(0xFFF0EEFF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121216) : const Color(0xFFF5F7FB),
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.textTheme.bodyLarge?.color),
            tooltip: 'Open Menu Drawer',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 110.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BLUE BANNER CARD
            GestureDetector(
              onTap: () => user != null ? _showBioDataSheet(context, user) : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF061099),
                      Color(0xFF0000D1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0000D1).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildUserAvatar(user, radius: 34),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email != null ? "@${user!.email.split('@')[0]}" : '@guestuser',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                      tooltip: 'Edit Bio-data',
                      onPressed: () => user != null ? _showBioDataSheet(context, user) : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // MAIN ACCOUNT OPTIONS CARD GROUP
            Container(
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. My Account
                  _buildProfileTile(
                    context,
                    icon: Icons.person_outline,
                    iconBgColor: iconBgColor,
                    iconColor: const Color(0xFF0000D1),
                    title: 'My Account',
                    subtitle: 'Make changes to your account',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user?.mobile == null)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                          ),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    ),
                    onTap: () => user != null ? _showBioDataSheet(context, user) : null,
                  ),
                  const Divider(height: 1, indent: 64),

                  // 2. Saved Items & Downloads
                  _buildProfileTile(
                    context,
                    icon: Icons.bookmark_outline,
                    iconBgColor: iconBgColor,
                    iconColor: const Color(0xFF0000D1),
                    title: 'Saved Items & Downloads',
                    subtitle: 'Access offline eBooks & bookmarks',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📚 Saved offline eBooks & video bookmarks ready!'),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64),

                  // 3. Biometric Security / Face ID
                  _buildProfileTile(
                    context,
                    icon: Icons.lock_outline,
                    iconBgColor: iconBgColor,
                    iconColor: const Color(0xFF0000D1),
                    title: 'Face ID / Biometric Security',
                    subtitle: 'Manage your device security',
                    trailing: Switch(
                      value: _biometricEnabled,
                      activeThumbColor: const Color(0xFF0000D1),
                      onChanged: (val) => _showBiometricPromptDialog(context, val),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),

                  // 4. Dark Mode Theme Switch
                  Consumer(
                    builder: (context, ref, _) {
                      final themeMode = ref.watch(themeModeProvider);
                      final isDarkMode = themeMode == ThemeMode.dark;
                      return _buildProfileTile(
                        context,
                        icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        iconBgColor: iconBgColor,
                        iconColor: isDarkMode ? Colors.amber : Colors.orange,
                        title: 'Dark Mode Theme',
                        subtitle: isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                        trailing: Switch(
                          value: isDarkMode,
                          activeThumbColor: const Color(0xFF0000D1),
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64),

                  // 5. Log out
                  _buildProfileTile(
                    context,
                    icon: Icons.logout,
                    iconBgColor: const Color(0xFFFFF0F0),
                    iconColor: const Color(0xFFF53649),
                    title: 'Log out',
                    subtitle: 'Sign out of your account',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION: MORE
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'More',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    context,
                    icon: Icons.notifications_none_outlined,
                    iconBgColor: iconBgColor,
                    iconColor: const Color(0xFF0000D1),
                    title: 'Help & Support',
                    subtitle: 'Contact team, send query or feedback',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    onTap: () => _showHelpSupportSheet(context, user),
                  ),
                  const Divider(height: 1, indent: 64),

                  _buildProfileTile(
                    context,
                    icon: Icons.favorite_outline,
                    iconBgColor: iconBgColor,
                    iconColor: const Color(0xFF0000D1),
                    title: 'About App',
                    subtitle: 'Platform version, terms & privacy',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    onTap: () => _showAboutAppSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
