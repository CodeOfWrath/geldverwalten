import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/logo_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/currency_manager.dart';
import '../../../../core/util/db_loading_dialog.dart';
import '../../../shell/presentation/pages/main_navigation_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _askVisitorInfoAndContinue() async {
    final TextEditingController visitorPseudoController = TextEditingController();
    String selectedCurrency = "FCFA";

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              title: const Text(
                "Mode Visiteur 👋",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personnalisez votre espace hors-ligne :",
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: visitorPseudoController,
                      autofocus: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Votre pseudo",
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: "ex: Micaelle, Alex...",
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Choisissez votre devise :",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCurrency,
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          items: CurrencyManager.availableCurrencies.map((c) {
                            return DropdownMenuItem<String>(
                              value: c["symbol"],
                              child: Text(
                                "${c["name"]} (${c["symbol"]})",
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setStateDialog(() {
                                selectedCurrency = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(110, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                  ),
                  child: const Text("Continuer"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final inputPseudo = visitorPseudoController.text.trim();
    final finalPseudo = inputPseudo.isNotEmpty ? inputPseudo : "Visiteur";

    if (!mounted) return;

    DbDialogs.showLoading(
      context,
      message: "Enregistrement du profil dans la base de données locale...",
    );

    await sl.authRepository.setGuestMode(true, pseudo: finalPseudo);
    await CurrencyManager.setCurrency(selectedCurrency);
    await sl.authRepository.setHasSeenOnboarding(true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    DbDialogs.hideLoading(context);

    await DbDialogs.showSuccess(
      context,
      title: "Profil Visiteur prêt !",
      message: "Bienvenue $finalPseudo ! Votre espace hors-ligne en $selectedCurrency est configuré.",
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationShell()),
      (route) => false,
    );
  }

  Future<void> _handleRegister() async {
    if (nomController.text.isEmpty ||
        pseudoController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Veuillez remplir tous les champs obligatoires";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await sl.registerUseCase(
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        pseudo: pseudoController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur d'inscription. Veuillez réessayer.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Création de compte"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const DepensiaLogoWidget(size: 80, showTagline: false),
              const SizedBox(height: 20),

              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentRed),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: "Prénom"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pseudoController,
                decoration: const InputDecoration(labelText: "Pseudo"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe"),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
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
                        "Créer mon compte",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _askVisitorInfoAndContinue,
                child: const Text(
                  "Continuer sans compte (Mode Visiteur)",
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
