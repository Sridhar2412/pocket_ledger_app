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
  // password obscure flag moved to Riverpod provider
  static final signupObscureProvider = StateProvider<bool>((ref) => true);

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
    final notifier = ref.read(authProvider.notifier);
    final obscure = ref.watch(signupObscureProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 130,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                          width: 80,
                          height: 80,
                          child: Image(
                            image: AssetImage('assets/icon/logo.png'),
                            fit: BoxFit.contain,
                          )),
                    ),
                    const SizedBox(height: 8),
                    Text('Welcome Back',
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
                            obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => ref
                            .read(signupObscureProvider.notifier)
                            .state = !obscure,
                      )),
                  obscureText: obscure),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: status == AuthStatus.loading
                      ? null
                      : () async {
                          await notifier.signup(
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
