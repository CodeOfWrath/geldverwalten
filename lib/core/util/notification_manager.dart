import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class NotificationManager {
  static const String notifEnabledKey = "NOTIF_ENABLED_KEY";
  static const String notifPendingPopupKey = "NOTIF_PENDING_POPUP_KEY";

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notifEnabledKey) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notifEnabledKey, enabled);
  }

  static Future<void> setPendingPopup(bool pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notifPendingPopupKey, pending);
  }

  static Future<bool> hasPendingPopup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notifPendingPopupKey) ?? false;
  }

  /// Affiche le popup de notification sur l'écran
  static void showNotificationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Rappel Dépensia 🔔",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rappel quotidien (20:00) :",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              SizedBox(height: 8),
              Text(
                "N'oubliez pas d'enregistrer vos dépenses et revenus d'aujourd'hui pour garder le contrôle de votre budget !",
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Plus tard", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(130, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
