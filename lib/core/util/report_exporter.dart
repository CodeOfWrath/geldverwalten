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
    buffer.writeln("TOTAL REVENUS;${totalEntrees} FCFA");
    buffer.writeln("TOTAL DÉPENSES;${totalSorties} FCFA");
    buffer.writeln("SOLDE NET;${solde} FCFA");

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
          height: MediaQuery.of(context).size.height * 0.75,
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
                      ),
                      _buildReportPreview(
                        context: context,
                        content: generateCsvReport(month: month, entrees: entrees, sorties: sorties),
                        formatName: "Excel / CSV",
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
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Rapport au format $formatName copié dans le presse-papiers !"),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          },
          icon: const Icon(Icons.copy_rounded),
          label: Text("Copier le rapport ($formatName)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ],
    );
  }
}
