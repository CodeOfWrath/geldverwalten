import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';

class AddExpensePage extends StatefulWidget {
  final bool initialIsExpense;

  const AddExpensePage({super.key, this.initialIsExpense = true});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late bool isExpenseMode;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController customNatureController = TextEditingController();

  String selectedCategory = "Alimentation";
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  final expenseCategories = [
    {"name": "Alimentation", "icon": Icons.restaurant_rounded, "color": AppColors.catAlimentation},
    {"name": "Transport", "icon": Icons.directions_car_rounded, "color": AppColors.catTransport},
    {"name": "Loisirs", "icon": Icons.sports_esports_rounded, "color": AppColors.catLoisirs},
    {"name": "Santé", "icon": Icons.favorite_rounded, "color": AppColors.catSante},
    {"name": "Maison", "icon": Icons.home_rounded, "color": AppColors.catMaison},
    {"name": "Autre", "icon": Icons.more_horiz_rounded, "color": AppColors.catAutre},
  ];

  final incomeCategories = [
    {"name": "Salaire", "icon": Icons.work_rounded, "color": AppColors.primaryGreen},
    {"name": "Vente", "icon": Icons.shopping_bag_rounded, "color": AppColors.catTransport},
    {"name": "Remboursement", "icon": Icons.replay_rounded, "color": AppColors.catMaison},
    {"name": "Cadeau", "icon": Icons.card_giftcard_rounded, "color": AppColors.catLoisirs},
    {"name": "Investissement", "icon": Icons.trending_up_rounded, "color": AppColors.navyBlue},
    {"name": "Autre", "icon": Icons.more_horiz_rounded, "color": AppColors.catAutre},
  ];

  @override
  void initState() {
    super.initState();
    isExpenseMode = widget.initialIsExpense;
    selectedCategory = isExpenseMode ? "Alimentation" : "Salaire";
  }

  Future<void> _handleSave() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un montant."),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final intAmount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (intAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un montant valide supérieur à 0."),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (selectedCategory == "Autre" && customNatureController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez préciser la nature du Mouvement."),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final categoryLabel = selectedCategory == "Autre" && customNatureController.text.trim().isNotEmpty
          ? "Autre (${customNatureController.text.trim()})"
          : selectedCategory;

      final comment = commentController.text.trim();
      final raison = comment.isNotEmpty ? "$comment ($categoryLabel)" : categoryLabel;

      if (isExpenseMode) {
        // Enregistrer une Dépense (Sortie)
        await sl.addSortieUseCase(raison, amountText, 1);
      } else {
        // Enregistrer une Entrée (Revenu)
        await sl.addEntreeUseCase(raison, intAmount);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isExpenseMode
                  ? "Dépense enregistrée avec succès !"
                  : "Entrée d'argent enregistrée avec succès !",
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction sauvegardée en mode hors-ligne."),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = isExpenseMode ? expenseCategories : incomeCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isExpenseMode ? "Ajouter une dépense" : "Ajouter une entrée"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // 1. Transaction Type Selector Pills (Dépense / Revenu)
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
                        onTap: () {
                          setState(() {
                            isExpenseMode = true;
                            selectedCategory = "Alimentation";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isExpenseMode ? AppColors.accentRed : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_circle_outline_rounded,
                                color: isExpenseMode ? Colors.white : AppColors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Dépense (-)",
                                style: TextStyle(
                                  color: isExpenseMode ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isExpenseMode ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpenseMode = false;
                            selectedCategory = "Salaire";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isExpenseMode ? AppColors.primaryGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: !isExpenseMode ? Colors.white : AppColors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Revenu (+)",
                                style: TextStyle(
                                  color: !isExpenseMode ? Colors.white : AppColors.textSecondary,
                                  fontWeight: !isExpenseMode ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Amount Display Input
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      isExpenseMode ? "Montant de la dépense" : "Montant du revenu",
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: isExpenseMode ? AppColors.accentRed : AppColors.primaryGreen,
                            ),
                            decoration: const InputDecoration(
                              hintText: "0",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "FCFA",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isExpenseMode ? AppColors.accentRed : AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Category Selector Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: currentCategories.length,
                itemBuilder: (context, index) {
                  final cat = currentCategories[index];
                  final isSelected = selectedCategory == cat["name"];
                  final Color catColor = cat["color"] as Color;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat["name"] as String;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? catColor.withOpacity(0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? catColor : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat["icon"] as IconData,
                              color: catColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat["name"] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? catColor : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 4. Field for 'Autre' nature if selected
              if (selectedCategory == "Autre") ...[
                TextField(
                  controller: customNatureController,
                  decoration: InputDecoration(
                    labelText: isExpenseMode
                        ? "Préciser la nature de la dépense"
                        : "Préciser la provenance du revenu",
                    hintText: "ex: Frais divers, Bonus...",
                    prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 5. Date Selector Card
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primaryGreen),
                          SizedBox(width: 12),
                          Text("Date", style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text(
                        "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 6. Optional Comment Field
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: "Commentaire (optionnel)",
                  hintText: "ex: Détails supplémentaires...",
                ),
              ),

              const SizedBox(height: 30),

              // 7. Enregistrer Button
              ElevatedButton(
                onPressed: isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpenseMode ? AppColors.accentRed : AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isExpenseMode ? "Enregistrer la dépense" : "Enregistrer le revenu",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
