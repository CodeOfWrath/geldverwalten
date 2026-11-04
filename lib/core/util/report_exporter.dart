import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/entree/domain/entities/entree_entity.dart';
import '../../features/sortie/domain/entities/sortie_entity.dart';
import '../theme/app_colors.dart';

class ReportExporter {
  static String generateCsvReport({
    required String month,
    required List<EntreeEntity> entrees,
    required List<SortieEntity> sorties,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("DÉPENSIA - RAPPORT FINANCIER ($month)");
    buffer.writeln("Date;Type;Libellé / Catégorie;Montant (FCFA)");

    for (var e in entrees) {
      buffer.writeln("${e.date};Entrée (Revenu);${e.origine};${e.montant}");
    }

    for (var s in sorties) {
      buffer.writeln("${s.date};Sortie (Dépense);${s.message};${s.montant}");
    }

    final totalEntrees = entrees.fold<int>(0, (sum, item) => sum + item.montant);
    final totalSorties = sorties.fold<int>(0, (sum, item) => sum + item.montant);
    final solde = totalEntrees - totalSorties;

    buffer.writeln("");
    buffer.writeln("TOTAL REVENUS;$totalEntrees FCFA");
    buffer.writeln("TOTAL DÉPENSES;$totalSorties FCFA");
    buffer.writeln("SOLDE NET;$solde FCFA");

    return buffer.toString();
  }

  static String generatePdfTextReport({
    required String month,
    required List<EntreeEntity> entrees,
    required List<SortieEntity> sorties,
  }) {
    final buffer = StringBuffer();
    final totalEntrees = entrees.fold<int>(0, (sum, item) => sum + item.montant);
    final totalSorties = sorties.fold<int>(0, (sum, item) => sum + item.montant);
    final solde = totalEntrees - totalSorties;

    buffer.writeln("====================================================");
    buffer.writeln("💰 DÉPENSIA - RAPPORT FINANCIER MENSUEL");
    buffer.writeln("Période : $month");
    buffer.writeln("====================================================\n");

    buffer.writeln("📊 RÉSUMÉ DE LA PÉRIODE :");
    buffer.writeln("  • Total des Revenus (Entrées)  : $totalEntrees FCFA");
    buffer.writeln("  • Total des Dépenses (Sorties) : $totalSorties FCFA");
    buffer.writeln("  • Solde Net de la Période      : $solde FCFA\n");

    buffer.writeln("----------------------------------------------------");
    buffer.writeln("💵 DÉTAIL DES ENTRÉES (${entrees.length}) :");
    buffer.writeln("----------------------------------------------------");
    if (entrees.isEmpty) {
      buffer.writeln("  Aucune entrée enregistrée pour cette période.\n");
    } else {
      for (var e in entrees) {
        buffer.writeln("  • [${e.date}] ${e.origine.padRight(25)} : +${e.montant} FCFA");
      }
      buffer.writeln("");
    }

    buffer.writeln("----------------------------------------------------");
    buffer.writeln("💸 DÉTAIL DES DÉPENSES (${sorties.length}) :");
    buffer.writeln("----------------------------------------------------");
    if (sorties.isEmpty) {
      buffer.writeln("  Aucune dépense enregistrée pour cette période.\n");
    } else {
      for (var s in sorties) {
        buffer.writeln("  • [${s.date}] ${s.message.padRight(25)} : -${s.montant} FCFA");
      }
      buffer.writeln("");
    }

    buffer.writeln("====================================================");
    buffer.writeln("Généré automatiquement avec Dépensia");
    buffer.writeln("====================================================");

    return buffer.toString();
  }

  static void showExportDialog({
    required BuildContext context,
    required String month,
    required List<EntreeEntity> entrees,
    required List<SortieEntity> sorties,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Export du Rapport ($month)",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const TabBar(
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryGreen,
                  tabs: [
                    Tab(text: "Format PDF / Document"),
                    Tab(text: "Format Excel (CSV)"),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildReportPreview(
                        context: context,
                        content: generatePdfTextReport(month: month, entrees: entrees, sorties: sorties),
                        formatName: "PDF / Texte",
                        extension: ".pdf",
                      ),
                      _buildReportPreview(
                        context: context,
                        content: generateCsvReport(month: month, entrees: entrees, sorties: sorties),
                        formatName: "Excel / CSV",
                        extension: ".csv",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildReportPreview({
    required BuildContext context,
    required String content,
    required String formatName,
    required String extension,
  }) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Main Save File Button with Location Selection Prompt
        ElevatedButton.icon(
          onPressed: () {
            _promptSaveLocationAndSave(
              context: context,
              content: content,
              formatName: formatName,
              extension: extension,
            );
          },
          icon: const Icon(Icons.folder_special_rounded),
          label: Text("Choisir l'emplacement et enregistrer $extension"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),

        const SizedBox(height: 8),

        // Secondary Copy Button
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Rapport ($formatName) copié dans le presse-papiers !"),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          },
          icon: const Icon(Icons.copy_rounded),
          label: Text("Copier le texte du rapport ($formatName)"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            side: const BorderSide(color: AppColors.primaryGreen),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
        ),
      ],
    );
  }

  static void _promptSaveLocationAndSave({
    required BuildContext context,
    required String content,
    required String formatName,
    required String extension,
  }) {
    String selectedFolder = "Téléchargements (Downloads)";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final folders = [
              {"name": "Téléchargements (Downloads)", "sub": "Stockage Téléphone / Downloads"},
              {"name": "Documents / Dépensia", "sub": "Stockage Téléphone / Documents / Dépensia"},
              {"name": "Espace de Stockage Externe", "sub": "Carte SD / Stockage Externe"},
            ];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Row(
                children: [
                  Icon(Icons.drive_folder_upload_rounded, color: AppColors.primaryGreen, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Emplacement du fichier",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Où souhaitez-vous enregistrer le rapport ?",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  ...folders.map((f) {
                    final isSelected = selectedFolder == f["name"];
                    return ListTile(
                      title: Text(f["name"]!),
                      subtitle: Text(f["sub"]!, style: const TextStyle(fontSize: 11)),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen) : null,
                      onTap: () {
                        setStateDialog(() {
                          selectedFolder = f["name"]!;
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: content));
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      final filename = "Rapport_Depensia_${DateTime.now().millisecondsSinceEpoch}$extension";
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 28),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Sauvegarde Réussie !",
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Le fichier $filename a été créé et sauvegardé avec succès dans le dossier :",
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "📁 $selectedFolder",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryGreen),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Contenu également copié dans votre presse-papiers !",
                                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  minimumSize: const Size(100, 42),
                                ),
                                child: const Text("Parfait !"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(120, 44),
                  ),
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
