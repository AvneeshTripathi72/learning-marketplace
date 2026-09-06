import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/core/premium_textfield.dart';
import '../../widgets/core/premium_button.dart';
import '../../widgets/core/feedback_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final PageController _pageController;
  int _currentStep = 0;
  bool _isLoading = false;

  // Selected Onboarding Options
  String? _selectedGoal;
  String? _selectedRole;
  String? _selectedRoutine;

  // Direct Login / Sign Up Form State
  bool _isSignUpMode = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String _selectedRegisterRole = 'PUBLIC'; // 'PUBLIC' or 'PUBLICATION'
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextStep() {
    if (_currentStep < 7) {
      _goToStep(_currentStep + 1);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  bool _isValidEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return false;
    if (clean.endsWith('@gmail.co') || clean.endsWith('@yahoo.co') || clean.endsWith('@outlook.co')) {
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$',
    );
    return emailRegex.hasMatch(clean);
  }

  bool _isValidPassword(String password) {
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\+=/\\]').hasMatch(password);
    return password.length >= 6 && hasUppercase && hasSpecialChar;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Header Bar with Back Button, Progress Bar, Theme Switcher & Close
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Back Arrow Button
                    SizedBox(
                      width: 40,
                      child: _currentStep > 0
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                              onPressed: _prevStep,
                              tooltip: 'Back',
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Animated Progress Bar (Steps 1 to 7)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _currentStep == 0 ? 0.05 : (_currentStep / 7.0),
                            minHeight: 6,
                            backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Close / Skip to Login Hub
                    if (_currentStep < 7)
                      IconButton(
                        icon: const Icon(Icons.close, size: 22),
                        tooltip: 'Skip Onboarding',
                        onPressed: () => _goToStep(7),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // PageView carrying Onboarding Steps 0 through 7
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Managed via Continue / Back buttons
                  onPageChanged: (page) => setState(() => _currentStep = page),
                  children: [
                    _buildStep0Hero(theme),
                    _buildStep1Goals(theme),
                    _buildStep2Reach(theme),
                    _buildStep3Role(theme),
                    _buildStep4Routine(theme),
                    _buildStep5Notifications(theme),
                    _buildStep6Testimonial(theme),
                    _buildStep7LoginHub(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SPEECH BUBBLE MASCOT COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildSpeechBubble(BuildContext context, {required String text}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mascot Icon Avatar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),

          // Speech Bubble Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 0: HERO SCREEN (Brilliant Image 1)
  // ---------------------------------------------------------------------------
  Widget _buildStep0Hero(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stylized Brand Typography Banner
              Text(
                'Master your\nstudies.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 38,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Interactive educational eBooks, compiled question papers, YouTube video hub, and custom test paper generators. Learn effectively in 15 minutes a day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Feature Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadgeChip(theme, Icons.book, 'eBooks'),
                  const SizedBox(width: 8),
                  _buildBadgeChip(theme, Icons.play_circle_fill, 'Videos'),
                  const SizedBox(width: 8),
                  _buildBadgeChip(theme, Icons.assignment, 'Papers'),
                ],
              ),
              const SizedBox(height: 48),

              // Primary Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => _goToStep(1),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Existing User Sign In Link
              TextButton(
                onPressed: () => _goToStep(7),
                child: Text.rich(
                  TextSpan(
                    text: 'Existing user? ',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    children: [
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: TOP GOAL SELECTION (Brilliant Images 3 & 4)
  // ---------------------------------------------------------------------------
  Widget _buildStep1Goals(ThemeData theme) {
    final speechText = _selectedGoal == null
        ? "What's your top goal?"
        : "Smart move! Future you approves.";

    final goals = [
      {'id': 'exam', 'icon': Icons.track_changes, 'title': 'Excelling in Board Exams (CBSE/ICSE)'},
      {'id': 'ebook', 'icon': Icons.menu_book, 'title': 'Reading eBooks & Study Material'},
      {'id': 'paper', 'icon': Icons.edit_note, 'title': 'Generating Practice Question Papers'},
      {'id': 'video', 'icon': Icons.play_circle_filled, 'title': 'Watching Educational Video Tutorials'},
      {'id': 'publish', 'icon': Icons.business, 'title': 'Managing Publication & Ad Injections'},
      {'id': 'other', 'icon': Icons.auto_awesome, 'title': 'General Knowledge & Learning'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpeechBubble(context, text: speechText),
              ...goals.map((g) {
                final isSelected = _selectedGoal == g['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AnimatedCard(
                    onTap: () => setState(() => _selectedGoal = g['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            g['icon'] as IconData,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              g['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedGoal != null ? _nextStep : null,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  // STEP 2: PLATFORM REACH (Brilliant Image 5)
  // ---------------------------------------------------------------------------
  Widget _buildStep2Reach(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Graphic Stack Container
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 54, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Icon(Icons.ondemand_video, size: 64, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Icon(Icons.quiz, size: 54, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Text(
                "You'll fit right in",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Thousands of students, educators, and publishers use our platform daily to master subjects and publish educational assets.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _nextStep,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  // STEP 3: EDUCATIONAL LEVEL / ROLE GRID (Brilliant Images 6 & 7)
  // ---------------------------------------------------------------------------
  Widget _buildStep3Role(ThemeData theme) {
    final speechText = _selectedRole == null
        ? "What's your educational / platform role?"
        : "Great! Tailoring content specifically for your role.";

    final roles = [
      {
        'id': 'student',
        'title': 'School Student',
        'sub': 'Class 9 - 12 CBSE/ICSE curriculum & eBooks',
        'icon': Icons.school,
        'role': UserRole.public,
      },
      {
        'id': 'aspirant',
        'title': 'Competitive Aspirant',
        'sub': 'Advanced papers, mock tests & video hub',
        'icon': Icons.psychology,
        'role': UserRole.public,
      },
      {
        'id': 'publisher',
        'title': 'Publication Admin',
        'sub': 'Manage series, eBooks & ad campaigns',
        'icon': Icons.business,
        'role': UserRole.publication,
      },
      {
        'id': 'educator',
        'title': 'Teacher / Educator',
        'sub': 'Generate & compile custom test papers',
        'icon': Icons.history_edu,
        'role': UserRole.public,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpeechBubble(context, text: speechText),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final r = roles[index];
                  final isSelected = _selectedRole == r['id'];

                  return AnimatedCard(
                    onTap: () => setState(() => _selectedRole = r['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            r['icon'] as IconData,
                            size: 32,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            r['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r['sub'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedRole != null ? _nextStep : null,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  // STEP 4: PREFERRED STUDY ROUTINE (Brilliant Images 9 & 10)
  // ---------------------------------------------------------------------------
  Widget _buildStep4Routine(ThemeData theme) {
    final speechText = _selectedRoutine == null
        ? "How will learning fit into your day?"
        : "Nightly study sessions by starlight! Sounds dreamy.";

    final routines = [
      {'id': 'morning', 'icon': Icons.wb_sunny, 'title': 'Morning routine', 'sub': 'During breakfast or commute'},
      {'id': 'break', 'icon': Icons.local_pizza, 'title': 'Quick break', 'sub': 'Between classes or lunch time'},
      {'id': 'night', 'icon': Icons.nights_stay, 'title': 'Nightly ritual', 'sub': 'After dinner or before bed'},
      {'id': 'flexible', 'icon': Icons.schedule, 'title': 'Another time', 'sub': 'Flexible daily routine'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpeechBubble(context, text: speechText),
              ...routines.map((r) {
                final isSelected = _selectedRoutine == r['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AnimatedCard(
                    onTap: () => setState(() => _selectedRoutine = r['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            r['icon'] as IconData,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  r['sub'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedRoutine != null ? _nextStep : null,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  // STEP 5: NOTIFICATIONS PROMPT (Brilliant Image 11)
  // ---------------------------------------------------------------------------
  Widget _buildStep5Notifications(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpeechBubble(
                context,
                text: "I'll send reminders so studying becomes a daily long-term habit.",
              ),
              const SizedBox(height: 20),

              // iOS Style Alert Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_active, size: 40, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text(
                      '“Platform” Would Like to Send You Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Notifications may include paper compile alerts, new eBook releases, and study reminders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _nextStep();
                            },
                            child: const Text("Don't Allow"),
                          ),
                        ),
                        Container(height: 30, width: 1, color: theme.dividerColor),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await NotificationService().requestPermission();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.notifications_active, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text('Notifications allowed! 🔔', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                              _nextStep();
                            },
                            child: const Text(
                              "Allow",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _nextStep,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  // STEP 6: TESTIMONIAL & RATING (Brilliant Image 12)
  // ---------------------------------------------------------------------------
  Widget _buildStep6Testimonial(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium, size: 54, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),

              Text(
                "You're on your way!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 12),

              // 5 Stars
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                "“This platform is an absolute game-changer for reading eBooks and preparing board exam papers! The question generator saved me countless hours of compilation.”",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '— Student & Educator Review',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _nextStep,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  // STEP 7: FINAL SIGN UP & LOGIN HUB (Brilliant Image 13)
  // ---------------------------------------------------------------------------

  Widget _buildStep7LoginHub(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    InputDecoration buildInputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E8EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      );
    }

    return Stack(
      children: [
        // Top Soft Ambient Gradient Backdrop Overlay (Matching Screenshots)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 240,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark
                      ? primaryColor.withValues(alpha: 0.28)
                      : const Color(0xFFCBE2FF).withValues(alpha: 0.75),
                  isDark
                      ? primaryColor.withValues(alpha: 0.06)
                      : const Color(0xFFE8F2FF).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Main Form Content Scrollable View
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Top Header & App Logo Icon (Matching Reference Screenshots)
                  if (_isSignUpMode) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 22),
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = false;
                            _errorMessage = null;
                          });
                        },
                        tooltip: 'Back to Sign In',
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_stories, color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Large Clean Bold Heading
                  Text(
                    _isSignUpMode ? 'Register' : 'Sign in to your\nAccount',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: _isSignUpMode ? 32 : 30,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUpMode
                        ? 'Create an account to continue!'
                        : 'Enter your email and password to log in',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Role Selector Tabs (Only in Sign Up Mode)
                  if (_isSignUpMode) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F3F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRegisterRole = 'PUBLIC'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _selectedRegisterRole == 'PUBLIC'
                                      ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: _selectedRegisterRole == 'PUBLIC'
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 18,
                                      color: _selectedRegisterRole == 'PUBLIC'
                                          ? primaryColor
                                          : theme.iconTheme.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Student / Reader',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _selectedRegisterRole == 'PUBLIC'
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _selectedRegisterRole == 'PUBLIC'
                                            ? primaryColor
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRegisterRole = 'PUBLICATION'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _selectedRegisterRole == 'PUBLICATION'
                                      ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: _selectedRegisterRole == 'PUBLICATION'
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 18,
                                      color: _selectedRegisterRole == 'PUBLICATION'
                                          ? primaryColor
                                          : theme.iconTheme.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Publisher Vendor',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _selectedRegisterRole == 'PUBLICATION'
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _selectedRegisterRole == 'PUBLICATION'
                                            ? primaryColor
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Full Name Input (Sign Up)
                    PremiumTextField(
                      controller: _nameController,
                      label: _selectedRegisterRole == 'PUBLICATION' ? 'Publication / Vendor Name' : 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Email Address Input
                  PremiumTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Password Input
                  PremiumTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                  ),

                  // Confirm Password Field (Sign Up Mode)
                  if (_isSignUpMode) ...[
                    const SizedBox(height: 14),
                    PremiumTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      isPassword: true,
                      prefixIcon: Icons.lock_reset_outlined,
                    ),
                  ],

                  // Remember Me & Forgot Password Row (Matching Reference Screenshots)
                  if (!_isSignUpMode) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {},
                          child: Text(
                            'Forgot Password ?',
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Inline Error Alert Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 18, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Main Primary Button (Log In / Register)
                  PremiumButton(
                    text: _isSignUpMode ? 'Create Account' : 'Log In',
                    isLoading: _isLoading,
                    onPressed: () async {
                        setState(() => _errorMessage = null);
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final confirmPassword = _confirmPasswordController.text.trim();
                        final name = _nameController.text.trim();

                        if (_isSignUpMode) {
                          if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please fill all required fields.';
                            });
                            return;
                          }
                          if (!_isValidEmail(email)) {
                            setState(() {
                              _errorMessage = 'Invalid email address. Enter a valid email (e.g. user@gmail.com).';
                            });
                            return;
                          }
                          if (!_isValidPassword(password)) {
                            setState(() {
                              _errorMessage = 'Password must be at least 6 characters, with at least 1 Uppercase letter (A-Z) and 1 Special character (e.g. @, #, \$, !).';
                            });
                            return;
                          }
                          if (password != confirmPassword) {
                            setState(() {
                              _errorMessage = 'Passwords do not match. Please re-enter matching passwords.';
                            });
                            return;
                          }
                        } else {
                          if (email.isEmpty || password.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please fill all required fields.';
                            });
                            return;
                          }
                          if (!_isValidEmail(email)) {
                            setState(() {
                              _errorMessage = 'Please enter a valid email address.';
                            });
                            return;
                          }
                        }

                        setState(() => _isLoading = true);
                        final auth = ref.read(authProvider.notifier);
                        UserModel? user;

                        if (_isSignUpMode) {
                          final regResult = await auth.registerAccountOnly(
                            name: name,
                            email: email,
                            password: password,
                            roleStr: _selectedRegisterRole,
                          );
                          if (mounted) {
                            if (regResult['success'] == true) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                                      SizedBox(width: 10),
                                      Text('Account Created! 🎉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                  ),
                                  content: Text(
                                    'Your account ($email) has been created & synced successfully!\n\nPlease click "Sign In Now" to log into your account.',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _isSignUpMode = false;
                                          _errorMessage = null;
                                          _passwordController.clear();
                                          _confirmPasswordController.clear();
                                        });
                                      },
                                      child: const Text('Sign In Now'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              setState(() {
                                _errorMessage = regResult['message'] ?? 'Registration failed. Please try again.';
                              });
                            }
                          }
                        } else {
                          user = await auth.loginWithCredentials(email, password);
                          if (mounted) {
                            if (user != null) {
                              setState(() => _errorMessage = null);
                              if (user.role == UserRole.admin) {
                                context.go('/admin/dashboard');
                              } else if (user.role == UserRole.publication) {
                                context.go('/dashboard');
                              } else {
                                context.go('/public/dashboard');
                              }
                            } else {
                              setState(() {
                                _errorMessage = 'Invalid email or password. Please check your credentials.';
                              });
                            }
                          }
                        }
                        }

                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      },
                    );
                  const SizedBox(height: 28),

                  // Footer Toggle Navigation Text Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUpMode = !_isSignUpMode;
                          _errorMessage = null;
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          children: [
                            TextSpan(
                              text: _isSignUpMode
                                  ? 'Already have an account? '
                                  : "Don't have an account? ",
                            ),
                            TextSpan(
                              text: _isSignUpMode ? 'Log in' : 'Sign Up',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // -----------------------------------------------------------
                  // DEV TESTING BYPASS SECTION
                  // -----------------------------------------------------------
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '🛠️ QUICK ACCESS BYPASS (TESTING)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                          foregroundColor: Colors.redAccent,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          _emailController.text = 'admin@system.com';
                          _passwordController.text = 'Admin@12345';
                          final user = await ref.read(authProvider.notifier).loginWithCredentials('admin@system.com', 'Admin@12345');
                          if (user != null && mounted) context.go('/admin/dashboard');
                        },
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Admin'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                          foregroundColor: Colors.blueAccent,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          _emailController.text = 'student@gmail.com';
                          _passwordController.text = 'Student@12345';
                          final user = await ref.read(authProvider.notifier).loginWithCredentials('student@gmail.com', 'Student@12345');
                          if (user != null && mounted) context.go('/public/dashboard');
                        },
                        icon: const Icon(Icons.school, size: 16),
                        label: const Text('Public'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
                          foregroundColor: Colors.orangeAccent,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          _emailController.text = 'vendor@oxford.com';
                          _passwordController.text = 'Vendor@12345';
                          final user = await ref.read(authProvider.notifier).loginWithCredentials('vendor@oxford.com', 'Vendor@12345');
                          if (user != null && mounted) context.go('/dashboard');
                        },
                        icon: const Icon(Icons.business, size: 16),
                        label: const Text('Vendor'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
