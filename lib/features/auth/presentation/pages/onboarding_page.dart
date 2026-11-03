import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/logo_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/currency_manager.dart';
import '../../../../core/util/db_loading_dialog.dart';
import '../../../shell/presentation/pages/main_navigation_shell.dart';
import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _askVisitorInfoAndContinue(BuildContext context) async {
    final TextEditingController pseudoController = TextEditingController();
    String selectedCurrency = "FCFA";

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                "Bienvenue sur Dépensia 👋",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personnalisez votre espace de gestion :",
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pseudoController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Votre pseudo",
                        hintText: "ex: Micaelle, Alex...",
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryGreen),
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
                          isExpanded: true,
                          items: CurrencyManager.availableCurrencies.map((c) {
                            return DropdownMenuItem<String>(
                              value: c["symbol"],
                              child: Text("${c["name"]} (${c["symbol"]})"),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(120, 46),
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

    final inputPseudo = pseudoController.text.trim();
    final finalPseudo = inputPseudo.isNotEmpty ? inputPseudo : "Visiteur";

    if (!context.mounted) return;

    // 1. Show blocking DB loading popup
    DbDialogs.showLoading(
      context,
      message: "Enregistrement de la configuration dans la base de données locale...",
    );

    await sl.authRepository.setGuestMode(true, pseudo: finalPseudo);
    await CurrencyManager.setCurrency(selectedCurrency);
    await sl.authRepository.setHasSeenOnboarding(true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      // 2. Hide DB loading popup
      DbDialogs.hideLoading(context);

      // 3. Show success popup
      await DbDialogs.showSuccess(
        context,
        title: "Configuration enregistrée !",
        message: "Bienvenue $finalPseudo ! Votre espace avec la devise $selectedCurrency est prêt dans la base de données locale.",
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationShell(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo & Branding
              const DepensiaLogoWidget(
                size: 140,
                showText: true,
                showTagline: true,
              ),

              const Spacer(flex: 2),

              // Subtitle Card / Pitch
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: const [
                    Text(
                      "Maîtrisez vos dépenses, réalisez vos projets !",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Utilisez l'application immédiatement sans compte, ou connectez-vous pour sauvegarder vos données en ligne.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Action Buttons
              ElevatedButton(
                onPressed: () => _askVisitorInfoAndContinue(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Commencer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 14),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Se connecter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
