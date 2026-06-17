import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class AccountSetupScreen extends ConsumerStatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  ConsumerState<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends ConsumerState<AccountSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();

    if (email == null && phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide at least an email or phone number')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).setupAccount(
          email: email,
          phone: phone,
          newPassword: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.lock_open_outlined, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Set Up Your Account',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'This is your first login. Please set up a recovery contact and a new password.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                Text('Recovery Contact', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Provide at least one for account recovery',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _emailController,
                  label: 'Email (optional)',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone (optional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Text('New Password', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _passwordController,
                  label: 'New Password',
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  isPassword: true,
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(authState.error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 32),
                AppButton(
                  label: 'Complete Setup',
                  onPressed: authState.isLoading ? null : _submit,
                  isLoading: authState.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
