import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/presentation/providers/auth_provider.dart';

import '../routes/app_router.gr.dart';

@RoutePage()
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(authProvider);
    final controller = ref.read(authProvider.notifier);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text('Create account',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: "Email", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )),
                  obscureText: _obscure),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: status == AuthStatus.loading
                      ? null
                      : () async {
                          await controller.signup(
                              emailController.text, passwordController.text);
                          final statusAfter = ref.read(authProvider);
                          if (statusAfter == AuthStatus.authenticated) {
                            if (context.mounted) {
                              context.router.replace(const DashboardRoute());
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Signup failed')),
                              );
                            }
                          }
                        },
                  child: status == AuthStatus.loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Sign Up"),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.router.replace(const LoginRoute()),
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
