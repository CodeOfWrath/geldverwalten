import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/data_change_notifier.dart';
import '../../../../core/util/db_loading_dialog.dart';
import '../../domain/entities/projet_entity.dart';

class ObjectifsPage extends StatefulWidget {
  const ObjectifsPage({super.key});

  @override
  State<ObjectifsPage> createState() => _ObjectifsPageState();
}

class _ObjectifsPageState extends State<ObjectifsPage> {
  late Future<List<ProjetEntity>> _projetsFuture;
  final TextEditingController _nomProjetController = TextEditingController();
  final TextEditingController _montantCibleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjets();
    dataChangeNotifier.addListener(_loadProjets);
  }

  @override
  void dispose() {
    dataChangeNotifier.removeListener(_loadProjets);
    super.dispose();
  }

  void _loadProjets() {
    setState(() {
      _projetsFuture = sl.getProjetsUseCase();
    });
  }

  Future<void> _showCreateDialog() async {
    bool isSaving = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Créer un projet / objectif"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nomProjetController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: "Nom du projet",
                      hintText: "ex: Achat Équipement, Epargne...",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _montantCibleController,
                    keyboardType: TextInputType.number,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: "Montant cible (FCFA)",
                      hintText: "ex: 100000",
                    ),
                  ),
                ],
              ),
              actions: [
                if (!isSaving)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Annuler"),
                  ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final nom = _nomProjetController.text.trim();
                          if (nom.isNotEmpty) {
                            setDialogState(() {
                              isSaving = true;
                            });

                            await sl.createProjetUseCase(nom);

                            _nomProjetController.clear();
                            _montantCibleController.clear();

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (mounted) {
                              await DbDialogs.showSuccess(
                                this.context,
                                title: "Projet créé avec succès !",
                                message: "Le projet '$nom' a été correctement enregistré dans la base de données locale.",
                              );
                              _loadProjets();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(100, 44),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Créer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mes objectifs"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 28),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dynamic Projets Builder
              FutureBuilder<List<ProjetEntity>>(
                future: _projetsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final projets = snapshot.data ?? [];
                  final totalCible = projets.fold<int>(0, (sum, item) => sum + item.montantCible);
                  final totalActuel = projets.fold<int>(0, (sum, item) => sum + item.montantActuel);
                  final double overallProgress = totalCible > 0 ? (totalActuel / totalCible).clamp(0.0, 1.0) : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Overall Goal Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: CircularProgressIndicator(
                                    value: overallProgress,
                                    strokeWidth: 12,
                                    backgroundColor: AppColors.yellowEnergy.withValues(alpha: 0.25),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellowEnergy),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${(overallProgress * 100).toInt()}%",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Progression globale des objectifs",
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$totalActuel / $totalCible FCFA",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Mes Objectifs Actifs Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Mes objectifs actifs",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: _showCreateDialog,
                            child: const Text(
                              "+ Nouveau",
                              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (projets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            "Aucun objectif actif pour le moment. Cliquez sur '+ Nouveau' pour créer votre premier projet d'épargne !",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: projets.length,
                          itemBuilder: (context, index) {
                            final p = projets[index];
                            final progress = p.progressPercentage;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.flag_rounded,
                                          color: AppColors.primaryGreen,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.nomProjet,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${p.montantActuel} / ${p.montantCible} FCFA",
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "${(progress * 100).toInt()}%",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
