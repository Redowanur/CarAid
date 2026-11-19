import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/ui.dart';
import '../../models/vehicle_type.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import 'customer/customer_shell.dart';
import 'mechanic/mechanic_shell.dart';
import 'signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CarAidLogo(size: 46, light: true),
                  const SizedBox(height: 36),
                  Text(
                    'Help is always\nnearby.',
                    style: AppText.display(36, color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Find a trusted mechanic, track them live, and pay your way — all in one app.',
                    style: AppText.body(
                      color: AppColors.white.withOpacity(0.7),
                      size: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _HeroChip(icon: Icons.near_me_rounded, label: 'Nearest mechanic'),
                      _HeroChip(icon: Icons.my_location_rounded, label: 'Live tracking'),
                      _HeroChip(icon: Icons.account_balance_wallet_outlined,
                          label: 'bKash · Nagad'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.liftShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back', style: AppText.h2()),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to continue where you left off.',
                            style: AppText.body(
                                size: 12.5, color: AppColors.muted),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  !value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: 'Sign in',
                            icon: Icons.arrow_forward_rounded,
                            loading: _loading,
                            onPressed: _signIn,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to CarAid? ',
                                style: AppText.body(
                                    size: 12.5, color: AppColors.muted),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .push(riseRoute(const SignUpScreen())),
                                child: Text(
                                  'Create account',
                                  style: AppText.body(
                                    size: 12.5,
                                    weight: FontWeight.w800,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.white.withOpacity(0.25)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR TRY THE DEMO',
                          style: AppText.label(
                            size: 10.5,
                            color: AppColors.white.withOpacity(0.6),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.white.withOpacity(0.25)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _demoButton(
                    icon: Icons.person_search_rounded,
                    title: 'Explore as Customer',
                    subtitle: 'Book, track and pay for a service',
                    color: AppColors.teal,
                    onTap: () => _startDemo(UserRole.customer),
                  ),
                  const SizedBox(height: 10),
                  _demoButton(
                    icon: Icons.build_circle_outlined,
                    title: 'Explore as Mechanic',
                    subtitle: 'Accept jobs and manage your garage',
                    color: AppColors.amber,
                    onTap: () => _startDemo(UserRole.mechanic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        ),
        Positioned(
          top: -90,
          right: -110,
          child: Container(
            width: 330,
            height: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withOpacity(0.13),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -130,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amber.withOpacity(0.07),
            ),
          ),
        ),
      ],
    );
  }

  Widget _demoButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.white.withOpacity(0.16)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body(
                          size: 13.5,
                          weight: FontWeight.w700,
                          color: AppColors.white),
                    ),
                    Text(
                      subtitle,
                      style: AppText.body(
                          size: 11,
                          color: AppColors.white.withOpacity(0.58)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: AppColors.white.withOpacity(0.7), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await appState.signInWithEmail(_email.text, _password.text);
      if (!mounted) return;
      _goToShell();
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startDemo(UserRole role) {
    appState.signInDemo(role);
    _goToShell();
  }

  void _goToShell() {
    Navigator.of(context).pushReplacement(riseRoute(
      appState.isMechanic ? const MechanicShell() : const CustomerShell(),
    ));
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.body(
                size: 11, color: AppColors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}
