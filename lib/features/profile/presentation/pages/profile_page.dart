import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/budget_manager.dart';
import '../../../../core/util/currency_manager.dart';
import '../../../../core/util/notification_manager.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/onboarding_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserEntity _user = UserEntity.guest;
  bool notificationsEnabled = true;
  String _currentCurrency = "FCFA";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await sl.getCurrentUserUseCase();
    final notifState = await NotificationManager.isEnabled();
    final currency = await CurrencyManager.getCurrency();

    if (mounted) {
      setState(() {
        _user = user;
        notificationsEnabled = notifState;
        _currentCurrency = currency;
      });
    }
  }

  Future<void> _showCurrencySelectorDialog() async {
    String selected = _currentCurrency;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Devise de l'application"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: CurrencyManager.availableCurrencies.map((c) {
                    return RadioListTile<String>(
                      title: Text("${c["name"]} (${c["symbol"]})"),
                      value: c["symbol"]!,
                      groupValue: selected,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selected = val;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CurrencyManager.setCurrency(selected);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {
                        _currentCurrency = selected;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Devise modifiée en $selected !"),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(100, 44),
                  ),
                  child: const Text("Changer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showBudgetLimitsDialog() async {
    final limits = await BudgetManager.getAllLimits();
    final controllers = <String, TextEditingController>{};

    for (var entry in limits.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value.toString());
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Limites de dépenses par catégorie"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "${entry.key} ($_currentCurrency)",
                      suffixText: _currentCurrency,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                for (var entry in controllers.entries) {
                  final val = int.tryParse(entry.value.text.trim()) ?? 30000;
                  await BudgetManager.setLimit(entry.key, val);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Limites de budget mises à jour !"),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(100, 44),
              ),
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Paramètres"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // 1. User Info Header Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                      child: const Text("👩🏽‍💼", style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user.pseudo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _user.email,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _user.isGuest
                                  ? AppColors.yellowEnergy.withOpacity(0.2)
                                  : AppColors.primaryGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _user.isGuest ? "Mode Hors-ligne (Invité)" : "Compte Synchronisé",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _user.isGuest ? Colors.amber[900] : AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Settings Menu List
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active_rounded, color: AppColors.textPrimary),
                        title: const Text("Rappel quotidien (20:00)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        subtitle: const Text("Rappel pour renseigner vos dépenses", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: Switch(
                          value: notificationsEnabled,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (val) async {
                            setState(() => notificationsEnabled = val);
                            await NotificationManager.setEnabled(val);
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      _buildSettingsTile(
                        icon: Icons.monetization_on_outlined,
                        title: "Devise de l'application",
                        trailingText: _currentCurrency,
                        onTap: _showCurrencySelectorDialog,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      _buildSettingsTile(
                        icon: Icons.tune_rounded,
                        title: "Limites de dépenses par catégorie",
                        onTap: _showBudgetLimitsDialog,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      _buildSettingsTile(
                        icon: Icons.contrast_rounded,
                        title: "Thème",
                        trailingText: "Système",
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      _buildSettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: "À propos de Dépensia",
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: "Dépensia",
                            applicationVersion: "1.0.0",
                            applicationIcon: const Text("💰", style: TextStyle(fontSize: 32)),
                            children: const [
                              Text("Dépensia est votre allié financier au quotidien. Gérez vos dépenses, vos revenus et vos objectifs d'épargne en toute sécurité et hors-ligne."),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Login / Logout Action Button
              if (_user.isGuest)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text("Créer un compte / Se connecter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () async {
                    await sl.logoutUseCase();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingPage()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
                  label: const Text("Se déconnecter", style: TextStyle(color: AppColors.accentRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentRed),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
