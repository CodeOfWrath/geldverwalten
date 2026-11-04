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
  bool _showArchived = false;

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

  Future<void> _confirmDeleteProjet(ProjetEntity projet) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.delete_forever_rounded, color: AppColors.accentRed, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text("Supprimer le projet", style: TextStyle(fontSize: 18, color: AppColors.accentRed)),
              ),
            ],
          ),
          content: Text("Voulez-vous vraiment supprimer définitivement le projet '${projet.nomProjet}' ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                minimumSize: const Size(100, 42),
              ),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await sl.projetLocalDataSource.deleteLocalProjet(projet.id);
      dataChangeNotifier.notifyDataChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Projet '${projet.nomProjet}' supprimé !"),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _toggleArchiveProjet(ProjetEntity projet) async {
    await sl.projetLocalDataSource.toggleArchiveProjet(projet.id);
    dataChangeNotifier.notifyDataChanged();
    if (mounted) {
      final isArchivedNow = projet.statut == 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArchivedNow
                ? "Projet '${projet.nomProjet}' archivé avec succès !"
                : "Projet '${projet.nomProjet}' restauré parmi les objectifs actifs !",
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  Future<void> _showCreateDialog() async {
    bool isSaving = false;
    bool hasNameError = false;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nomProjetController,
                    enabled: !isSaving,
                    onChanged: (val) {
                      if (hasNameError && val.trim().isNotEmpty) {
                        setDialogState(() {
                          hasNameError = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Nom du projet *",
                      hintText: "ex: Achat Équipement, Epargne...",
                      labelStyle: TextStyle(color: hasNameError ? AppColors.accentRed : null),
                      errorText: hasNameError ? "Veuillez entrer le nom du projet" : null,
                      focusedBorder: hasNameError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                            )
                          : null,
                      enabledBorder: hasNameError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
                            )
                          : null,
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
                    onPressed: () {
                      _nomProjetController.clear();
                      _montantCibleController.clear();
                      Navigator.pop(dialogContext);
                    },
                    child: const Text("Annuler"),
                  ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final nom = _nomProjetController.text.trim();
                          if (nom.isEmpty) {
                            setDialogState(() {
                              hasNameError = true;
                            });
                            return;
                          }

                          final targetAmount = int.tryParse(_montantCibleController.text.trim()) ?? 100000;

                          setDialogState(() {
                            isSaving = true;
                          });

                          await sl.createProjetUseCase(nom, montantCible: targetAmount);

                          _nomProjetController.clear();
                          _montantCibleController.clear();

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          if (mounted) {
                            await DbDialogs.showSuccess(
                              this.context,
                              title: "Projet créé avec succès !",
                              message: "Le projet '$nom' ($targetAmount FCFA) a été correctement enregistré dans la base de données locale.",
                            );
                            _loadProjets();
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
    final cardBg = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = textColor.withValues(alpha: 0.7);

    return Scaffold(
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

                  final allProjets = snapshot.data ?? [];
                  final activeProjets = allProjets.where((p) => p.statut == 1).toList();
                  final archivedProjets = allProjets.where((p) => p.statut == 0).toList();

                  final totalCible = activeProjets.fold<int>(0, (sum, item) => sum + item.montantCible);
                  final totalActuel = activeProjets.fold<int>(0, (sum, item) => sum + item.montantActuel);
                  final double overallProgress = totalCible > 0 ? (totalActuel / totalCible).clamp(0.0, 1.0) : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Overall Goal Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
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
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Progression globale des objectifs",
                              style: TextStyle(fontSize: 13, color: subtextColor),
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
                          Text(
                            "Mes objectifs actifs (${activeProjets.length})",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
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

                      if (activeProjets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            "Aucun objectif actif. Cliquez sur '+ Nouveau' pour créer votre premier projet d'épargne !",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subtextColor),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeProjets.length,
                          itemBuilder: (context, index) {
                            final p = activeProjets[index];
                            return _buildProjectCard(p, isArchived: false);
                          },
                        ),

                      const SizedBox(height: 24),

                      // Archived Projects Section Toggle
                      if (archivedProjets.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showArchived = !_showArchived;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.archive_outlined, color: subtextColor, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Projets archivés (${archivedProjets.length})",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                                    ),
                                  ],
                                ),
                                Icon(
                                  _showArchived ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: subtextColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showArchived) ...[
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: archivedProjets.length,
                            itemBuilder: (context, index) {
                              final p = archivedProjets[index];
                              return _buildProjectCard(p, isArchived: true);
                            },
                          ),
                        ],
                      ],
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

  Widget _buildProjectCard(ProjetEntity p, {required bool isArchived}) {
    final progress = p.progressPercentage;
    final cardBg = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = textColor.withValues(alpha: 0.7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isArchived ? subtextColor : AppColors.primaryGreen).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isArchived ? Icons.archive_rounded : Icons.flag_rounded,
                  color: isArchived ? subtextColor : AppColors.primaryGreen,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isArchived ? subtextColor : textColor,
                        decoration: isArchived ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${p.montantActuel} / ${p.montantCible} FCFA",
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isArchived ? subtextColor : AppColors.primaryGreen,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: subtextColor),
                onSelected: (value) {
                  if (value == "archive") {
                    _toggleArchiveProjet(p);
                  } else if (value == "delete") {
                    _confirmDeleteProjet(p);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "archive",
                    child: Row(
                      children: [
                        Icon(isArchived ? Icons.unarchive_rounded : Icons.archive_outlined, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 10),
                        Text(isArchived ? "Restaurer le projet" : "Archiver le projet", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 20),
                        SizedBox(width: 10),
                        Text("Supprimer le projet", style: TextStyle(color: AppColors.accentRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: (isArchived ? subtextColor : AppColors.primaryGreen).withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(isArchived ? subtextColor : AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}
