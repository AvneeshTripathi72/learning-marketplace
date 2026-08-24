import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _selectedCountry = 'India (+91)';
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(text: 'user@oxford.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _showEmailLogin = false;
  bool _obscurePassword = true;

  final List<String> _countries = [
    'India (+91)',
    'United States (+1)',
    'United Kingdom (+44)',
    'Canada (+1)',
    'Australia (+61)',
    'United Arab Emirates (+971)',
  ];

  void _loginAsPublication() {
    final mockUser = UserModel(
      id: 'pub_001',
      name: 'Oxford Publication User',
      email: 'user@oxford.com',
      role: UserRole.publication,
      publicationId: 'oxford_pub',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    );
    ref.read(authProvider.notifier).login(mockUser, 'mock_pub_token');
    context.go('/dashboard');
  }

  void _loginAsPublic() {
    final mockUser = UserModel(
      id: 'public_001',
      name: 'Rahul Sharma (Student)',
      email: 'public@user.com',
      role: UserRole.public,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    );
    ref.read(authProvider.notifier).login(mockUser, 'mock_public_token');
    context.go('/public/dashboard');
  }

  void _loginWithGoogle() {
    final mockUser = UserModel(
      id: 'google_101',
      name: 'Google User',
      email: 'google@user.com',
      role: UserRole.public,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    );
    ref.read(authProvider.notifier).login(mockUser, 'mock_google_token');
    context.go('/public/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar matching reference layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () {
                      if (_showEmailLogin) {
                        setState(() => _showEmailLogin = false);
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Log in or sign up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                      size: 22,
                    ),
                    tooltip: 'Toggle Theme Mode',
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content Form Body
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child: Column(
                        key: ValueKey(_showEmailLogin),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_showEmailLogin) ...[
                          // Country/Region & Phone Number Segmented Box
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Country/Region Selector
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCountry,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down),
                                      hint: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Country/Region',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                          Text(
                                            _selectedCountry,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: _countries.map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedCountry = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                // Phone Number Input
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      hintText: 'Phone number',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "We'll call or text to confirm your number. Standard message and data rates apply.",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Primary Continue Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _loginAsPublic,
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Email Login Form Mode
                          Text(
                            'Sign in with Email',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _loginAsPublication,
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // OR Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.dividerColor)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.dividerColor)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Outlined Option Buttons matching reference design
                        if (!_showEmailLogin)
                          _buildOutlinedButton(
                            context,
                            icon: Icons.email_outlined,
                            iconColor: theme.colorScheme.primary,
                            label: 'Continue with email',
                            onTap: () => setState(() => _showEmailLogin = true),
                          )
                        else
                          _buildOutlinedButton(
                            context,
                            icon: Icons.phone_android,
                            iconColor: theme.colorScheme.primary,
                            label: 'Continue with phone',
                            onTap: () =>
                                setState(() => _showEmailLogin = false),
                          ),
                        const SizedBox(height: 12),

                        _buildOutlinedButton(
                          context,
                          icon: Icons.apple,
                          iconColor: theme.colorScheme.onSurface,
                          label: 'Continue with Apple',
                          onTap: _loginAsPublic,
                        ),
                        const SizedBox(height: 12),

                        _buildOutlinedButton(
                          context,
                          icon: Icons.g_mobiledata,
                          iconColor: Colors.redAccent,
                          label: 'Continue with Google',
                          onTap: _loginWithGoogle,
                        ),
                        const SizedBox(height: 12),

                        _buildOutlinedButton(
                          context,
                          icon: Icons.facebook,
                          iconColor: Colors.blue,
                          label: 'Continue with Facebook',
                          onTap: _loginAsPublic,
                        ),
                        const SizedBox(height: 16),

                        const Divider(),
                        const SizedBox(height: 12),

                        // Quick Role Login Buttons
                        _buildOutlinedButton(
                          context,
                          icon: Icons.business,
                          iconColor: Colors.amber,
                          label: 'Continue as Publication Admin',
                          onTap: _loginAsPublication,
                        ),
                        const SizedBox(height: 12),

                        _buildOutlinedButton(
                          context,
                          icon: Icons.school,
                          iconColor: Colors.teal,
                          label: 'Continue as Public Student',
                          onTap: _loginAsPublic,
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.dividerColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}
