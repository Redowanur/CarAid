import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/ui.dart';
import '../../models/vehicle_type.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import 'customer/customer_shell.dart';
import 'mechanic/mechanic_shell.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.customer;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CarAidLogo(size: 44),
                const SizedBox(height: 26),
                Text('Create your account', style: AppText.h1()),
                const SizedBox(height: 6),
                Text(
                  'Join thousands getting help on the road.',
                  style: AppText.body(color: AppColors.muted, size: 13),
                ),
                const SizedBox(height: 24),
                Text('I am a', style: AppText.label()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _roleCard(
                        role: UserRole.customer,
                        icon: Icons.person_outline_rounded,
                        title: 'Customer',
                        subtitle: 'Need a service',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _roleCard(
                        role: UserRole.mechanic,
                        icon: Icons.build_outlined,
                        title: 'Mechanic',
                        subtitle: 'Offer services',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().length < 2
                      ? 'Enter your full name'
                      : null,
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Enter a valid phone number'
                      : null,
                  decoration: const InputDecoration(
                    hintText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null ||
                          !v.contains('@') ||
                          !v.contains('.')
                      ? 'Enter a valid email address'
                      : null,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  validator: (v) => v == null || v.length < 6
                      ? 'Use at least 6 characters'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Create account',
                  icon: Icons.arrow_forward_rounded,
                  loading: _loading,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your price chart is free — no card required.',
                    style: AppText.body(size: 12, color: AppColors.faint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = role == _role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: selected ? AppColors.teal : AppColors.faint, size: 22),
            const SizedBox(height: 8),
            Text(title,
                style: AppText.body(
                    size: 13.5,
                    weight: FontWeight.w700,
                    color:
                        selected ? AppColors.tealDark : AppColors.ink)),
            Text(subtitle,
                style: AppText.body(size: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await appState.register(
        fullName: _name.text,
        userPhone: _phone.text,
        userEmail: _email.text,
        password: _password.text,
        userRole: _role,
      );
      if (!mounted) return;
      showAppSnack(context, 'Welcome to CarAid, ${appState.firstName}!');
      Navigator.of(context).pushReplacement(riseRoute(_role == UserRole.mechanic
          ? const MechanicShell()
          : const CustomerShell()));
    } catch (error) {
      if (mounted) showAppSnack(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
