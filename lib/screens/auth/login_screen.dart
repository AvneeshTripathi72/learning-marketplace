import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _loginAsPublication() {
    final mockUser = UserModel(
      id: 'pub_001',
      name: 'Oxford Publication User',
      email: 'user@oxford.com',
      role: UserRole.publication,
      publicationId: 'oxford_pub',
    );
    ref.read(authProvider.notifier).login(mockUser, 'mock_pub_token');
    context.go('/dashboard');
  }

  void _loginAsPublic() {
    final mockUser = UserModel(
      id: 'public_001',
      name: 'General Public User',
      email: 'public@user.com',
      role: UserRole.public,
    );
    ref.read(authProvider.notifier).login(mockUser, 'mock_public_token');
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Education Platform',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loginAsPublication,
                  child: const Text('Login as Publication User'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _loginAsPublic,
                  child: const Text('Login as Public User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
