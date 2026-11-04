import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/data_change_notifier.dart';
import '../../../../core/util/report_exporter.dart';
import '../../../entree/domain/entities/entree_entity.dart';
import '../../domain/entities/sortie_entity.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool isExpenseMode = true;
  String selectedMonth = "Ce mois-ci";
  List<EntreeEntity> _entrees = [];
  List<SortieEntity> _sorties = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    dataChangeNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    dataChangeNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final entreesList = await sl.getEntreesUseCase();
    final sortiesList = await sl.getSortiesUseCase();

    if (mounted) {
      setState(() {
        _entrees = entreesList;
        _sorties = sortiesList;
      });
    }
  }

  int get _totalSorties => _sorties.fold<int>(0, (sum, item) => sum + item.montant);
  int get _totalEntrees => _entrees.fold<int>(0, (sum, item) => sum + item.montant);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Rapports"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primaryGreen),
            tooltip: "Exporter le rapport",
            onPressed: () {
              ReportExporter.showExportDialog(
                context: context,
                month: selectedMonth,
                entrees: _entrees,
                sorties: _sorties,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Toggle Pills (Dépenses / Revenus)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isExpenseMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isExpenseMode ? AppColors.accentRed : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Dépenses (-)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isExpenseMode ? Colors.white : AppColors.textSecondary,
                                fontWeight: isExpenseMode ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isExpenseMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isExpenseMode ? AppColors.primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Revenus (+)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isExpenseMode ? Colors.white : AppColors.textSecondary,
                                fontWeight: !isExpenseMode ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Month Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Période du rapport", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMonth,
                          items: ["Ce mois-ci", "Mois dernier", "Année en cours"]
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedMonth = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Total Expenses Card Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isExpenseMode ? "Total des dépenses (Sorties)" : "Total des revenus (Entrées)",
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isExpenseMode ? "$_totalSorties FCFA" : "$_totalEntrees FCFA",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isExpenseMode ? AppColors.accentRed : AppColors.primaryGreen,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isExpenseMode ? AppColors.accentRed : AppColors.primaryGreen).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isExpenseMode ? "${_sorties.length} opérations" : "${_entrees.length} opérations",
                              style: TextStyle(
                                color: isExpenseMode ? AppColors.accentRed : AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Export Button Callout
                ElevatedButton.icon(
                  onPressed: () {
                    ReportExporter.showExportDialog(
                      context: context,
                      month: selectedMonth,
                      entrees: _entrees,
                      sorties: _sorties,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text("Exporter le rapport (PDF / Excel / CSV)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Category Details List
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isExpenseMode ? "Historique des dépenses" : "Historique des revenus",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (isExpenseMode && _sorties.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "Aucune dépense enregistrée.",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else if (!isExpenseMode && _entrees.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "Aucun revenu enregistré.",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else if (isExpenseMode)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _sorties.length,
                          separatorBuilder: (context, index) => const Divider(height: 20),
                          itemBuilder: (context, index) {
                            final item = _sorties[index];
                            return _buildTransactionRow(
                              title: item.message,
                              date: item.date,
                              amount: "-${item.montant} FCFA",
                              color: AppColors.accentRed,
                              icon: Icons.remove_circle_outline_rounded,
                            );
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _entrees.length,
                          separatorBuilder: (context, index) => const Divider(height: 20),
                          itemBuilder: (context, index) {
                            final item = _entrees[index];
                            return _buildTransactionRow(
                              title: item.origine,
                              date: item.date,
                              amount: "+${item.montant} FCFA",
                              color: AppColors.primaryGreen,
                              icon: Icons.add_circle_outline_rounded,
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow({
    required String title,
    required String date,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
      ],
    );
  }
}
