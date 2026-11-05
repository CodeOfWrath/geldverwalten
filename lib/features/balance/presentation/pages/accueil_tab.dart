import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/budget_manager.dart';
import '../../../../core/util/currency_manager.dart';
import '../../../../core/util/data_change_notifier.dart';
import '../../../../core/util/notification_manager.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../entree/domain/entities/entree_entity.dart';
import '../../../sortie/domain/entities/sortie_entity.dart';

class AccueilTab extends StatefulWidget {
  const AccueilTab({super.key});

  @override
  State<AccueilTab> createState() => _AccueilTabState();
}

class _AccueilTabState extends State<AccueilTab> {
  String _selectedPeriod = "Mois";
  UserEntity _currentUser = UserEntity.guest;
  List<SortieEntity> _allSorties = [];
  List<EntreeEntity> _allEntrees = [];
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
    final listEntrees = await sl.getEntreesUseCase();
    final limits = await BudgetManager.getAllLimits();
    final currency = await CurrencyManager.getCurrency();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _allSorties = listSorties;
        _allEntrees = listEntrees;
        _categoryLimits = limits;
        _currencySymbol = currency;
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } else if (dateStr.contains('-')) {
        return DateTime.tryParse(dateStr);
      }
    } catch (_) {}
    return null;
  }

  List<SortieEntity> get _filteredSorties {
    final now = DateTime.now();
    return _allSorties.where((s) {
      final dt = _parseDate(s.date);
      if (dt == null) return true; // Include if date format unparsed

      if (_selectedPeriod == "Jour") {
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      } else if (_selectedPeriod == "Semaine") {
        final diff = now.difference(dt).inDays;
        return diff >= 0 && diff <= 7;
      } else {
        // Mois
        return dt.year == now.year && dt.month == now.month;
      }
    }).toList();
  }

  List<EntreeEntity> get _filteredEntrees {
    final now = DateTime.now();
    return _allEntrees.where((e) {
      final dt = _parseDate(e.date);
      if (dt == null) return true;

      if (_selectedPeriod == "Jour") {
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      } else if (_selectedPeriod == "Semaine") {
        final diff = now.difference(dt).inDays;
        return diff >= 0 && diff <= 7;
      } else {
        // Mois
        return dt.year == now.year && dt.month == now.month;
      }
    }).toList();
  }

  int get _totalDepensesPeriod {
    return _filteredSorties.fold<int>(0, (sum, item) => sum + item.montant);
  }

  int get _totalRevenusPeriod {
    return _filteredEntrees.fold<int>(0, (sum, item) => sum + item.montant);
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

    for (var s in _filteredSorties) {
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

                // 3. Main Emerald Card
                _buildMainExpenseCard(),

                const SizedBox(height: 24),

                // 4. Period Filter Selector Pills (Jour, Semaine, Mois)
                _buildPeriodSelector(context),

                const SizedBox(height: 20),

                // 5. Dual Line Chart Card with Dynamic Values Callouts
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
                  "Aperçu du solde & dépenses",
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
    final total = _totalDepensesPeriod;
    final titlePeriod = _selectedPeriod == "Jour"
        ? "Dépenses aujourd'hui"
        : _selectedPeriod == "Semaine"
            ? "Dépenses cette semaine"
            : "Dépenses ce mois-ci";

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
              Text(
                titlePeriod,
                style: const TextStyle(
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
                child: Text(
                  _selectedPeriod,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                _filteredSorties.isEmpty
                    ? "Aucune dépense sur cette période."
                    : "${_filteredSorties.length} transaction(s) ($titlePeriod)",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final periods = ["Jour", "Semaine", "Mois"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                period,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChartCard(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

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
                "Graphique des flux ($_selectedPeriod)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
              const Icon(Icons.show_chart_rounded, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 12),

          // Chart Legend Row
          const Row(
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: AppColors.primaryGreen, size: 10),
                  SizedBox(width: 6),
                  Text("Revenus (+)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ],
              ),
              SizedBox(width: 18),
              Row(
                children: [
                  Icon(Icons.circle, color: AppColors.accentRed, size: 10),
                  SizedBox(width: 6),
                  Text("Dépenses (-)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _DualLineChartPainter(
                totalIncome: _totalRevenusPeriod,
                totalExpense: _totalDepensesPeriod,
                currency: _currencySymbol,
                textColor: textColor,
              ),
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
            "Répartition & Limites ($_selectedPeriod)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (_filteredSorties.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  "Aucune dépense enregistrée pour cette période.\nAppuyez sur '+' pour ajouter une dépense.",
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

class _DualLineChartPainter extends CustomPainter {
  final int totalIncome;
  final int totalExpense;
  final String currency;
  final Color textColor;

  _DualLineChartPainter({
    required this.totalIncome,
    required this.totalExpense,
    required this.currency,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final incomePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final expensePaint = Paint()
      ..color = AppColors.accentRed
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final pointPaintIncome = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    final pointPaintExpense = Paint()
      ..color = AppColors.accentRed
      ..style = PaintingStyle.fill;

    final maxVal = (totalIncome > totalExpense ? totalIncome : totalExpense).clamp(1, 1000000000);
    final incomeRatio = (totalIncome / maxVal).clamp(0.08, 1.0);
    final expenseRatio = (totalExpense / maxVal).clamp(0.08, 1.0);

    // Dynamic Y positions following curve height
    final rawYIncome = size.height * (0.85 - 0.65 * incomeRatio);
    final rawYExpense = size.height * (0.85 - 0.65 * expenseRatio);

    // Anti-overlap spacing calculation
    double badgeYIncome = rawYIncome - 12;
    double badgeYExpense = rawYExpense - 12;

    const double minSpacing = 28.0;
    if ((badgeYIncome - badgeYExpense).abs() < minSpacing) {
      if (totalIncome >= totalExpense) {
        badgeYIncome = (rawYIncome - 14).clamp(0.0, size.height - 24.0);
        badgeYExpense = badgeYIncome + minSpacing;
      } else {
        badgeYExpense = (rawYExpense - 14).clamp(0.0, size.height - 24.0);
        badgeYIncome = badgeYExpense + minSpacing;
      }
    }

    badgeYIncome = badgeYIncome.clamp(0.0, size.height - 24.0);
    badgeYExpense = badgeYExpense.clamp(0.0, size.height - 24.0);

    // Format text
    final textIncome = "+$totalIncome $currency";
    final textExpense = "-$totalExpense $currency";

    // Measure text width
    final tpIncome = _layoutText(textIncome, AppColors.primaryGreen);
    final tpExpense = _layoutText(textExpense, AppColors.accentRed);

    final badgeWidthIncome = tpIncome.width + 16;
    final badgeWidthExpense = tpExpense.width + 16;

    final badgeXIncome = (size.width - badgeWidthIncome).clamp(0.0, size.width - badgeWidthIncome);
    final badgeXExpense = (size.width - badgeWidthExpense).clamp(0.0, size.width - badgeWidthExpense);

    final curveMaxXIncome = badgeXIncome - 6;
    final curveMaxXExpense = badgeXExpense - 6;

    // 1. Curve Points
    final p1Income = Offset(0, size.height * 0.85);
    final p2Income = Offset(curveMaxXIncome * 0.5, (size.height * 0.85 + rawYIncome) / 2);
    final p3Income = Offset(curveMaxXIncome, rawYIncome);

    final p1Expense = Offset(0, size.height * 0.85);
    final p2Expense = Offset(curveMaxXExpense * 0.5, (size.height * 0.85 + rawYExpense) / 2);
    final p3Expense = Offset(curveMaxXExpense, rawYExpense);

    // 2. Draw Income Curve up to the badge edge
    final incomePath = Path()
      ..moveTo(p1Income.dx, p1Income.dy)
      ..cubicTo(curveMaxXIncome * 0.25, p1Income.dy, curveMaxXIncome * 0.35, p2Income.dy, p2Income.dx, p2Income.dy)
      ..cubicTo(curveMaxXIncome * 0.65, p2Income.dy, curveMaxXIncome * 0.85, p3Income.dy, p3Income.dx, p3Income.dy);

    canvas.drawPath(incomePath, incomePaint);

    // 3. Draw Expense Curve up to the badge edge
    final expensePath = Path()
      ..moveTo(p1Expense.dx, p1Expense.dy)
      ..cubicTo(curveMaxXExpense * 0.25, p1Expense.dy, curveMaxXExpense * 0.35, p2Expense.dy, p2Expense.dx, p2Expense.dy)
      ..cubicTo(curveMaxXExpense * 0.65, p2Expense.dy, curveMaxXExpense * 0.85, p3Expense.dy, p3Expense.dx, p3Expense.dy);

    canvas.drawPath(expensePath, expensePaint);

    // 4. Draw End Points
    canvas.drawCircle(p3Income, 4, pointPaintIncome);
    canvas.drawCircle(p3Expense, 4, pointPaintExpense);

    // 5. Draw Non-Overlapping Dynamic Badge Callouts
    _drawBadgeAt(
      canvas: canvas,
      tp: tpIncome,
      badgeX: badgeXIncome,
      badgeY: badgeYIncome,
      badgeWidth: badgeWidthIncome,
      badgeHeight: tpIncome.height + 8,
      color: AppColors.primaryGreen,
    );

    _drawBadgeAt(
      canvas: canvas,
      tp: tpExpense,
      badgeX: badgeXExpense,
      badgeY: badgeYExpense,
      badgeWidth: badgeWidthExpense,
      badgeHeight: tpExpense.height + 8,
      color: AppColors.accentRed,
    );
  }

  TextPainter _layoutText(String text, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  void _drawBadgeAt({
    required Canvas canvas,
    required TextPainter tp,
    required double badgeX,
    required double badgeY,
    required double badgeWidth,
    required double badgeHeight,
    required Color color,
  }) {
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight),
      const Radius.circular(10),
    );

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(badgeRect, bgPaint);
    canvas.drawRRect(badgeRect, borderPaint);

    tp.paint(canvas, Offset(badgeX + 8, badgeY + 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
