import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/presentation/providers/auth_provider.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.gr.dart';

@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // if already authenticated (token persisted), redirect to dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(authProvider) == AuthStatus.authenticated) {
        context.router.replace(const DashboardRoute());
      }
    });
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
                height: 120,
                child: Column(
                  children: [
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
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
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
                  ),
                ),
                obscureText: _obscure,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: status == AuthStatus.loading
                      ? null
                      : () async {
                          await controller.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          final statusAfter = ref.read(authProvider);
                          if (statusAfter == AuthStatus.authenticated) {
                            if (context.mounted) {
                              context.router.replace(const DashboardRoute());
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Login failed: invalid credentials'),
                                ),
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
                      : const Text("Login"),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.router.push(const SignupRoute()),
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
