import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/budget_manager.dart';
import '../../../../core/util/currency_manager.dart';
import '../../../../core/util/data_change_notifier.dart';
import '../../../../core/util/notification_manager.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../sortie/domain/entities/sortie_entity.dart';

class AccueilTab extends StatefulWidget {
  const AccueilTab({super.key});

  @override
  State<AccueilTab> createState() => _AccueilTabState();
}

class _AccueilTabState extends State<AccueilTab> {
  String _selectedPeriod = "Mois";
  UserEntity _currentUser = UserEntity.guest;
  List<SortieEntity> _sorties = [];
  Map<String, int> _categoryLimits = {};
  String _currencySymbol = "FCFA";

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPendingNotification();
    dataChangeNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    dataChangeNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _checkPendingNotification() async {
    final pending = await NotificationManager.hasPendingPopup();
    if (pending && mounted) {
      await NotificationManager.setPendingPopup(false);
      if (!mounted) return;
      NotificationManager.showNotificationPopup(context);
    }
  }

  Future<void> _loadData() async {
    final user = await sl.getCurrentUserUseCase();
    final listSorties = await sl.getSortiesUseCase();
    final limits = await BudgetManager.getAllLimits();
    final currency = await CurrencyManager.getCurrency();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _sorties = listSorties;
        _categoryLimits = limits;
        _currencySymbol = currency;
      });
    }
  }

  int get _totalDepenses {
    return _sorties.fold<int>(0, (sum, item) => sum + item.montant);
  }

  Map<String, int> get _categoryTotals {
    final Map<String, int> totals = {
      "Alimentation": 0,
      "Transport": 0,
      "Loisirs": 0,
      "Santé": 0,
      "Maison": 0,
      "Autre": 0,
    };

    for (var s in _sorties) {
      if (s.message.contains("Alimentation")) {
        totals["Alimentation"] = (totals["Alimentation"] ?? 0) + s.montant;
      } else if (s.message.contains("Transport")) {
        totals["Transport"] = (totals["Transport"] ?? 0) + s.montant;
      } else if (s.message.contains("Loisirs")) {
        totals["Loisirs"] = (totals["Loisirs"] ?? 0) + s.montant;
      } else if (s.message.contains("Santé")) {
        totals["Santé"] = (totals["Santé"] ?? 0) + s.montant;
      } else if (s.message.contains("Maison")) {
        totals["Maison"] = (totals["Maison"] ?? 0) + s.montant;
      } else {
        totals["Autre"] = (totals["Autre"] ?? 0) + s.montant;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // 1. Header (Avatar, Greeting & Notification Bell)
                _buildTopHeader(context),

                const SizedBox(height: 20),

                // 2. Offline Sync Callout Banner if Guest
                if (_currentUser.isGuest) _buildGuestBanner(context),

                // 3. Main Emerald Card ("Dépenses ce mois-ci")
                _buildMainExpenseCard(),

                const SizedBox(height: 24),

                // 4. Period Filter Selector Pills
                _buildPeriodSelector(context),

                const SizedBox(height: 20),

                // 5. Line Chart Card
                _buildLineChartCard(context),

                const SizedBox(height: 24),

                // 6. Category Breakdown & Budget Limits
                _buildCategoryBreakdownSection(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = textColor.withValues(alpha: 0.7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
              child: const Text(
                "👩🏽‍💼",
                style: TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bonjour ${_currentUser.pseudo} 👋",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Voici un aperçu de vos dépenses",
                  style: TextStyle(
                    fontSize: 12,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppColors.primaryGreen),
            tooltip: "Notifications & Rappel",
            onPressed: () {
              NotificationManager.showNotificationPopup(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuestBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.yellowEnergy.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellowEnergy),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mode Hors-ligne (Invité)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  "Créer un compte pour sauvegarder et synchroniser vos données.",
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              "Connexion",
              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainExpenseCard() {
    final total = _totalDepenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dépenses ce mois-ci",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      "Actif",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$total $_currencySymbol",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.yellowEnergy, size: 20),
              const SizedBox(width: 6),
              Text(
                _sorties.isEmpty
                    ? "Aucune dépense enregistrée pour le moment."
                    : "${_sorties.length} transaction(s) enregistrée(s)",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final periods = ["Jour", "Semaine", "Mois", "Événement"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGreen : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChartCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Évolution des dépenses",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Icon(Icons.show_chart, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _LineChartPainter(hasData: _sorties.isNotEmpty),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection(BuildContext context) {
    final totals = _categoryTotals;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Limites de budget & Catégories",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (_sorties.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  "Aucune dépense enregistrée.\nAppuyez sur '+' pour ajouter votre première dépense.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBudgetProgressRow(context, "Alimentation", totals["Alimentation"] ?? 0, AppColors.catAlimentation),
                _buildBudgetProgressRow(context, "Transport", totals["Transport"] ?? 0, AppColors.catTransport),
                _buildBudgetProgressRow(context, "Loisirs", totals["Loisirs"] ?? 0, AppColors.catLoisirs),
                _buildBudgetProgressRow(context, "Santé", totals["Santé"] ?? 0, AppColors.catSante),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgressRow(BuildContext context, String category, int spent, Color color) {
    final limit = _categoryLimits[category] ?? 50000;
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    Color barColor = AppColors.primaryGreen;
    if (spent >= limit) {
      barColor = AppColors.accentRed;
    } else if (ratio >= 0.8) {
      barColor = Colors.orange;
    }

    final textColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
              Text("$spent / $limit $_currencySymbol", style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: barColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final bool hasData;

  _LineChartPainter({required this.hasData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (hasData) {
      path.moveTo(0, size.height * 0.75);
      path.cubicTo(
        size.width * 0.3,
        size.height * 0.85,
        size.width * 0.6,
        size.height * 0.3,
        size.width,
        size.height * 0.2,
      );
    } else {
      path.moveTo(0, size.height * 0.9);
      path.lineTo(size.width, size.height * 0.9);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
