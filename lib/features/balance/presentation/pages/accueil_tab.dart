import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await sl.getCurrentUserUseCase();
    final listSorties = await sl.getSortiesUseCase();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _sorties = listSorties;
      });
    }
  }

  int get _totalDepenses {
    return _sorties.fold<int>(0, (sum, item) => sum + item.montant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                _buildTopHeader(),

                const SizedBox(height: 20),

                // 2. Offline Sync Callout Banner if Guest
                if (_currentUser.isGuest) _buildGuestBanner(),

                // 3. Main Emerald Card ("Dépenses ce mois-ci")
                _buildMainExpenseCard(),

                const SizedBox(height: 24),

                // 4. Period Filter Selector Pills
                _buildPeriodSelector(),

                const SizedBox(height: 20),

                // 5. Line Chart Card
                _buildLineChartCard(),

                const SizedBox(height: 24),

                // 6. Category Breakdown ("Répartition par catégorie")
                _buildCategoryBreakdownSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Voici un aperçu de vos dépenses",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildGuestBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.yellowEnergy.withOpacity(0.15),
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
              children: const [
                Text(
                  "Mode Hors-ligne (Invité)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "Créer un compte pour sauvegarder et synchroniser vos données.",
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
            color: AppColors.primaryGreen.withOpacity(0.35),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
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
            "$total FCFA",
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
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
              color: isSelected ? AppColors.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : AppColors.border,
              ),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Évolution des dépenses",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Icon(Icons.show_chart, color: AppColors.primaryGreen),
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

  Widget _buildCategoryBreakdownSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Répartition par catégorie",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          if (_sorties.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  "Aucune dépense à afficher.\nAppuyez sur '+' pour ajouter une dépense.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _DonutChartPainter(),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildLegendItem("Alimentation", AppColors.catAlimentation),
                      _buildLegendItem("Transport", AppColors.catTransport),
                      _buildLegendItem("Loisirs", AppColors.catLoisirs),
                      _buildLegendItem("Santé", AppColors.catSante),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    paint.color = AppColors.catAlimentation;
    canvas.drawArc(rect, -1.57, 2.2, false, paint);

    paint.color = AppColors.catTransport;
    canvas.drawArc(rect, 0.7, 1.75, false, paint);

    paint.color = AppColors.catLoisirs;
    canvas.drawArc(rect, 2.5, 1.25, false, paint);

    paint.color = AppColors.catSante;
    canvas.drawArc(rect, 3.8, 1.0, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
