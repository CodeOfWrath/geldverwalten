import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class SecurityManager {
  static const String PIN_ENABLED_KEY = "PIN_ENABLED_KEY";
  static const String SAVED_PIN_KEY = "SAVED_PIN_KEY";

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PIN_ENABLED_KEY) ?? false;
  }

  static Future<String?> getSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SAVED_PIN_KEY);
  }

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SAVED_PIN_KEY, pin);
    await prefs.setBool(PIN_ENABLED_KEY, true);
  }

  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PIN_ENABLED_KEY, false);
  }

  static Future<bool> showPinDialog({
    required BuildContext context,
    required String title,
    bool isSetup = false,
  }) async {
    final controller = TextEditingController();
    bool isSuccess = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.lock_rounded, color: AppColors.primaryGreen),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Entrez votre code PIN à 4 chiffres :",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "••••",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = controller.text.trim();
                if (pin.length == 4) {
                  if (isSetup) {
                    await setPin(pin);
                    isSuccess = true;
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    final saved = await getSavedPin();
                    if (saved == pin) {
                      isSuccess = true;
                      if (context.mounted) Navigator.pop(context);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Code PIN incorrect !"),
                            backgroundColor: AppColors.accentRed,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(100, 44),
              ),
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );

    return isSuccess;
  }
}
