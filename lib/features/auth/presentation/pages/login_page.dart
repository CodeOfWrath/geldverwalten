import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/logo_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/pages/main_navigation_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _handleLogin() async {
    if (loginController.text.trim().isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Veuillez remplir tous les champs";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await sl.loginUseCase(loginController.text.trim(), passwordController.text);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion. Vérifiez vos identifiants.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Connexion"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const DepensiaLogoWidget(size: 90, showTagline: false),
              const SizedBox(height: 30),

              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentRed),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.accentRed),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: loginController,
                decoration: const InputDecoration(
                  labelText: "Email ou Pseudo",
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Se connecter",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pas encore de compte ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await sl.authRepository.setGuestMode(true);
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationShell()),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  "Continuer sans compte (Mode Hors-ligne)",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
