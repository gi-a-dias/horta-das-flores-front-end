import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'services/mqtt_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MqttService.instance.connect(); // não bloqueia a abertura do app
  runApp(const HortaDasFloresApp());
}

abstract final class AppColors {
  static const forest = Color(0xFF1E3B2B);
  static const forestLight = Color(0xFF224231);
  static const sage = Color(0xFFEAF5EE);
  static const mint = Color(0xFFD8EFE2);
  static const emerald = Color(0xFF2ECC71);
  static const emeraldDark = Color(0xFF15965A);
  static const gold = Color(0xFFF5A623);
  static const cyan = Color(0xFF00BCD4);
  static const teal = Color(0xFF2CA58D);
  static const muted = Color(0xFF6D8276);
  static const white = Color(0xFFFFFFFF);
}

enum AppPage { login, garden, irrigation }

List<int> get moistureByBed => MqttService.instance.moisture.value;

class HortaDasFloresApp extends StatelessWidget {
  const HortaDasFloresApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
      primary: AppColors.forest,
      secondary: AppColors.emerald,
      surface: AppColors.white,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horta das Flores',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.sage,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.forest,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
          ),
          titleLarge: TextStyle(
            color: AppColors.forest,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          bodyMedium: TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white.withOpacity(0.96),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0x0F1E3B2B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.emerald,
              width: 1.5,
            ),
          ),
          prefixIconColor: AppColors.emeraldDark,
          hintStyle: const TextStyle(
            color: Color(0xFF83978B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const HortaNavigator(),
    );
  }
}

class HortaNavigator extends StatefulWidget {
  const HortaNavigator({super.key});

  @override
  State<HortaNavigator> createState() => _HortaNavigatorState();
}

class _HortaNavigatorState extends State<HortaNavigator> {
  AppPage _page = AppPage.login;
  int _selectedBed = 1;

  void _navigate(AppPage page) => setState(() => _page = page);

  void _openIrrigation(int bed) => setState(() {
        _selectedBed = bed;
        _page = AppPage.irrigation;
      });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: MqttService.instance.moisture,
      builder: (context, _, __) => _buildPage(),
    );
  }

  Widget _buildPage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: switch (_page) {
        AppPage.login => LoginScreen(
            key: const ValueKey('login'),
            onEnter: () => _navigate(AppPage.garden),
          ),
        AppPage.garden => GardenScreen(
            key: const ValueKey('garden'),
            selectedBed: _selectedBed,
            onNavigate: _navigate,
            onSelectBed: (bed) => setState(() => _selectedBed = bed),
            onOpenIrrigation: _openIrrigation,
          ),
        AppPage.irrigation => IrrigationScreen(
            key: const ValueKey('irrigation'),
            initialBed: _selectedBed,
            onNavigate: _navigate,
            onBedChanged: (bed) => _selectedBed = bed,
          ),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onEnter, super.key});

  final VoidCallback onEnter;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) widget.onEnter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: LoginBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 46,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const BrandMark(),
                        const SizedBox(height: 10),
                        const Text(
                          'CULTIVE  •  CONECTE  •  TRANSFORME',
                          style: TextStyle(
                            color: AppColors.emeraldDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Horta das Flores',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Monitoramento IoT & Cultivo Comunitário',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                controller: _emailController,
                                hint: 'E-mail ou Usuário',
                                icon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value == null ||
                                        value.trim().isEmpty
                                    ? 'Informe seu e-mail ou usuário'
                                    : null,
                              ),
                              const SizedBox(height: 13),
                              AppTextField(
                                controller: _passwordController,
                                hint: 'Senha',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Informe sua senha'
                                        : null,
                                suffix: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () => setState(
                                    () => _obscurePassword =
                                        !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.forest,
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Esqueceu a senha?'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FilledButton(
                                onPressed: _submit,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(58),
                                  backgroundColor: AppColors.forest,
                                  foregroundColor: AppColors.white,
                                  shape: const StadiumBorder(),
                                  elevation: 8,
                                  shadowColor:
                                      AppColors.forest.withOpacity(0.35),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Entrar no Jardim',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 9),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 13),
                              OutlinedButton.icon(
                                onPressed: widget.onEnter,
                                icon: const Icon(
                                  Icons.eco_outlined,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Continuar como Voluntário Convidado',
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(58),
                                  foregroundColor: AppColors.forest,
                                  side: const BorderSide(
                                    color: AppColors.forest,
                                    width: 1.3,
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Novo na horta? ',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  color: AppColors.forest,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sage, AppColors.mint],
        ),
      ),
      child: CustomPaint(painter: BotanicalPatternPainter()),
    );
  }
}

class BotanicalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forest.withOpacity(0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    void leaf(Offset center, double scale, double rotation) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(65 * scale, -70 * scale, 92 * scale, 10 * scale, 0, 95 * scale)
        ..cubicTo(-35 * scale, 53 * scale, -28 * scale, 20 * scale, 0, 0);
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset.zero, Offset(0, 92 * scale), paint);
      canvas.restore();
    }

    leaf(Offset(-12, 90), 1.2, -0.35);
    leaf(Offset(size.width + 8, size.height * .3), 1.05, 2.6);
    leaf(Offset(-16, size.height * .77), .8, -.6);
    leaf(Offset(size.width + 18, size.height - 30), 1.2, 2.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandMark extends StatelessWidget {
  const BrandMark({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 112.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: compact ? 42 : 92,
            height: compact ? 42 : 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald.withOpacity(compact ? .20 : .16),
              boxShadow: compact
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.emerald.withOpacity(.08),
                        spreadRadius: 14,
                      ),
                    ],
            ),
          ),
          Icon(
            Icons.cottage_outlined,
            size: compact ? 38 : 76,
            color: compact ? AppColors.white : AppColors.forest,
          ),
          Positioned(
            bottom: compact ? 4 : 13,
            child: Icon(
              Icons.eco_rounded,
              size: compact ? 21 : 38,
              color: compact
                  ? const Color(0xFF72E59B)
                  : AppColors.emeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}

class GardenScreen extends StatefulWidget {
  const GardenScreen({
    required this.selectedBed,
    required this.onNavigate,
    required this.onSelectBed,
    required this.onOpenIrrigation,
    super.key,
  });

  final int selectedBed;
  final ValueChanged<AppPage> onNavigate;
  final ValueChanged<int> onSelectBed;
  final ValueChanged<int> onOpenIrrigation;

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  String _period = 'Mês';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const GardenHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
                child: Column(
                  children: [
                    PeriodSelector(
                      selected: _period,
                      onSelected: (value) => setState(() => _period = value),
                    ),
                    const SizedBox(height: 14),
                    GardenMap(
                      selectedBed: widget.selectedBed,
                      onTap: () =>
                          widget.onOpenIrrigation(widget.selectedBed),
                    ),
                    const SizedBox(height: 14),
                    GardenBedSelector(
                      selectedBed: widget.selectedBed,
                      onSelected: widget.onSelectBed,
                      onOpenIrrigation: widget.onOpenIrrigation,
                    ),
                    const SizedBox(height: 14),
                    AnalyticsCard(
                      onOpenSensor: () =>
                          widget.onOpenIrrigation(widget.selectedBed),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNavigation(
        selected: AppPage.garden,
        onNavigate: widget.onNavigate,
      ),
    );
  }
}

class GardenHeader extends StatelessWidget {
  const GardenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const BrandMark(compact: true),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HORTA DAS FLORES',
                      style: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Visão Geral',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const CurrencyBadge(
                icon: Icons.monetization_on_rounded,
                value: '1.569',
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              const CurrencyBadge(
                icon: Icons.diamond_rounded,
                value: '137',
                color: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            width: 184,
            height: 49,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.white.withOpacity(.13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MonthButton(
                  icon: Icons.chevron_left_rounded,
                  label: 'Mês anterior',
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PERÍODO ATUAL',
                      style: TextStyle(
                        color: Color(0x8FFFFFFF),
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Set 2026',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                _MonthButton(
                  icon: Icons.chevron_right_rounded,
                  label: 'Próximo mês',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: () {},
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.white.withOpacity(.09),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({
    required this.icon,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.fromLTRB(4, 3, 8, 3),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.white.withOpacity(.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.white, size: 15),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const periods = ['Dia', 'Semana', 'Mês', 'Ano'];
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0ECE4)),
      ),
      child: Row(
        children: periods
            .map(
              (period) => Expanded(
                child: Semantics(
                  selected: selected == period,
                  button: true,
                  child: InkWell(
                    onTap: () => onSelected(period),
                    borderRadius: BorderRadius.circular(11),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected == period
                            ? AppColors.forest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        period,
                        style: TextStyle(
                          color: selected == period
                              ? AppColors.white
                              : const Color(0xFF829488),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class GardenBedSelector extends StatelessWidget {
  const GardenBedSelector({
    required this.selectedBed,
    required this.onSelected,
    required this.onOpenIrrigation,
    super.key,
  });

  final int selectedBed;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onOpenIrrigation;

  String get _status {
    final moisture = moistureByBed[selectedBed - 1];
    if (moisture < 60) return 'Rega recomendada';
    if (moisture > 80) return 'Muito úmido';
    return 'Solo ideal';
  }

  @override
  Widget build(BuildContext context) {
    final moisture = moistureByBed[selectedBed - 1];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EEE7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: AppColors.emeraldDark,
                size: 17,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'SELECIONE UM CANTEIRO',
                  style: TextStyle(
                    color: AppColors.emeraldDark,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Text(
                '10 CONECTADOS',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: moistureByBed.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final bed = index + 1;
                final selected = bed == selectedBed;
                return Semantics(
                  button: true,
                  selected: selected,
                  label:
                      'Selecionar canteiro $bed, ${moistureByBed[index]}% de umidade',
                  child: InkWell(
                    onTap: () => onSelected(bed),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.forest
                            : AppColors.sage,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.forest
                              : const Color(0xFFDCEAE1),
                        ),
                      ),
                      child: Text(
                        'C$bed',
                        style: TextStyle(
                          color: selected
                              ? AppColors.white
                              : AppColors.forest,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(11, 9, 8, 9),
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: moisture < 60
                        ? AppColors.gold
                        : AppColors.emerald,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: AppColors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CANTEIRO $selectedBed  •  $_status',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                        ),
                      ),
                      Text(
                        '$moisture% de umidade',
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => onOpenIrrigation(selectedBed),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Abrir rega',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.chevron_right_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GardenMap extends StatelessWidget {
  const GardenMap({
    required this.selectedBed,
    required this.onTap,
    super.key,
  });

  final int selectedBed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 280,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD5F2DF), Color(0xFFA9DFC0)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.forest.withOpacity(.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: CustomPaint(
                    painter: GardenPainter(
                      selectedBed: selectedBed,
                      moisture: moistureByBed[selectedBed - 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 11,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(.72),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withOpacity(.7),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        color: AppColors.emeraldDark,
                        size: 17,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '10 canteiros conectados',
                          style: TextStyle(
                            color: AppColors.forest,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Toque para explorar',
                        style: TextStyle(
                          color: AppColors.emeraldDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GardenPainter extends CustomPainter {
  const GardenPainter({required this.selectedBed, required this.moisture});

  final int selectedBed;
  final int moisture;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .42);

    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.white.withOpacity(.75),
          AppColors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 150));
    canvas.drawCircle(center, 150, halo);

    final side = Path()
      ..moveTo(center.dx - 128, center.dy + 17)
      ..lineTo(center.dx + 128, center.dy + 17)
      ..lineTo(center.dx + 60, center.dy + 105)
      ..lineTo(center.dx, center.dy + 135)
      ..lineTo(center.dx - 62, center.dy + 98)
      ..close();
    canvas.drawPath(
      side,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF825C38), Color(0xFF392D22)],
        ).createShader(side.getBounds()),
    );

    final island = Rect.fromCenter(
      center: center,
      width: 276,
      height: 118,
    );
    canvas.drawOval(
      island,
      Paint()
        ..color = const Color(0xFF57B96B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      island.deflate(8),
      Paint()..color = const Color(0xFF6AC879),
    );

    final pathPaint = Paint()
      ..color = const Color(0xFFD5BD89)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(-5, -47),
      center.translate(8, 50),
      pathPaint,
    );
    canvas.drawLine(
      center.translate(-105, 10),
      center.translate(108, -7),
      pathPaint,
    );

    void bed(Rect rect, int plants, String identifier) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = const Color(0xFF784730),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(3)),
        Paint()..color = const Color(0xFF653827),
      );
      for (var i = 0; i < plants; i++) {
        final x = rect.left + 11 + (i * (rect.width - 22) / (plants - 1));
        canvas.drawCircle(
          Offset(x, rect.center.dy),
          7,
          Paint()..color = i.isEven
              ? const Color(0xFF2B9D50)
              : const Color(0xFF45BD67),
        );
      }

      final labelRect = Rect.fromLTWH(
        rect.left - 3,
        rect.top - 12,
        28,
        18,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(7)),
        Paint()..color = AppColors.forest,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(7)),
        Paint()
          ..color = AppColors.white.withOpacity(.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final labelPainter = TextPainter(
        text: TextSpan(
          text: identifier,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: labelRect.width, maxWidth: labelRect.width);
      labelPainter.paint(
        canvas,
        Offset(
          labelRect.left,
          labelRect.center.dy - labelPainter.height / 2,
        ),
      );
    }

    bed(Rect.fromLTWH(center.dx - 104, center.dy - 38, 77, 30), 4, 'C1');
    bed(Rect.fromLTWH(center.dx + 35, center.dy - 37, 67, 29), 3, 'C2');
    bed(Rect.fromLTWH(center.dx - 70, center.dy + 19, 76, 29), 4, 'C3');

    final pond = Rect.fromCenter(
      center: center.translate(74, 30),
      width: 56,
      height: 31,
    );
    canvas.drawOval(pond, Paint()..color = const Color(0xFF429C67));
    canvas.drawOval(pond.deflate(4), Paint()..color = const Color(0xFF56D6D0));

    void tree(Offset offset, double scale) {
      canvas.drawRect(
        Rect.fromCenter(
          center: offset.translate(0, 12 * scale),
          width: 6 * scale,
          height: 25 * scale,
        ),
        Paint()..color = const Color(0xFF73442D),
      );
      canvas.drawCircle(
        offset,
        18 * scale,
        Paint()..color = const Color(0xFF1E924B),
      );
      canvas.drawCircle(
        offset.translate(-5 * scale, -5 * scale),
        11 * scale,
        Paint()..color = const Color(0xFF3CBD67),
      );
    }

    tree(center.translate(-124, -8), 1);
    tree(center.translate(112, -28), .78);
    tree(center.translate(118, 32), .7);

    final pinCenter = center.translate(8, -80);
    canvas.drawCircle(
      pinCenter,
      30,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pinCenter.translate(-8, 0),
      12,
      Paint()..color = AppColors.cyan,
    );
    final drop = Path()
      ..moveTo(pinCenter.dx - 8, pinCenter.dy - 7)
      ..quadraticBezierTo(
        pinCenter.dx - 17,
        pinCenter.dy + 3,
        pinCenter.dx - 8,
        pinCenter.dy + 7,
      )
      ..quadraticBezierTo(
        pinCenter.dx + 1,
        pinCenter.dy + 3,
        pinCenter.dx - 8,
        pinCenter.dy - 7,
      );
    canvas.drawPath(drop, Paint()..color = AppColors.white);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'C$selectedBed  $moisture%',
        style: const TextStyle(
          color: AppColors.forest,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      pinCenter.translate(2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant GardenPainter oldDelegate) =>
      selectedBed != oldDelegate.selectedBed ||
      moisture != oldDelegate.moisture;
}

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({required this.onOpenSensor, super.key});

  final VoidCallback onOpenSensor;
  static const values = [54, 69, 61, 78, 64, 72, 58, 67, 75, 63];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8F0EB)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANÁLISE DOS SENSORES',
                      style: TextStyle(
                        color: AppColors.emeraldDark,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Umidade do Solo',
                      style: TextStyle(
                        color: AppColors.forest,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '●  Canteiros Ativos: 10',
                  style: TextStyle(
                    color: AppColors.emeraldDark,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('100', style: _axisStyle),
                      Text('50', style: _axisStyle),
                      Text('0', style: _axisStyle),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomPaint(
                    painter: ChartGridPainter(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        values.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: index == 3 ? onOpenSensor : null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (index == 3)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 3),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.forest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${values[index]}%',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    height: values[index] * .9,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: index == 3
                                            ? const [
                                                Color(0xFF008BA1),
                                                AppColors.cyan,
                                              ]
                                            : const [
                                                Color(0xFF1FAC61),
                                                Color(0xFF50DC88),
                                              ],
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${index + 1}',
                                    style: _axisStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: const Color(0xFFE9F8F8),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: onOpenSensor,
              borderRadius: BorderRadius.circular(13),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cyan,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CANTEIRO MAIS ÚMIDO',
                            style: TextStyle(
                              color: Color(0xFF348A8B),
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .8,
                            ),
                          ),
                          Text(
                            'Canteiro 4 • Sensor ESP32',
                            style: TextStyle(
                              color: AppColors.forest,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.forest,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _axisStyle = TextStyle(
    color: Color(0xFFA0B0A6),
    fontSize: 7,
  );
}

class ChartGridPainter extends CustomPainter {
  const ChartGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8EFEA)
      ..strokeWidth = 1;
    for (final ratio in [0.0, .45, .9]) {
      final y = (size.height - 18) * ratio;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({
    required this.initialBed,
    required this.onNavigate,
    required this.onBedChanged,
    super.key,
  });

  final int initialBed;
  final ValueChanged<AppPage> onNavigate;
  final ValueChanged<int> onBedChanged;

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _selectedBed;
  bool _watering = false;

  int get _moisture => moistureByBed[_selectedBed - 1];

  String get _soilStatus {
    if (_moisture < 60) return 'Rega Recomendada';
    if (_moisture > 80) return 'Solo Muito Úmido';
    return 'Solo Ideal';
  }

  @override
  void initState() {
    super.initState();
    _selectedBed = widget.initialBed;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF197E70),
              AppColors.teal,
              Color(0xFFA9DDC5),
            ],
            stops: [0, .42, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SensorHeader(
                selectedBed: _selectedBed,
                onBack: () => widget.onNavigate(AppPage.garden),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 4, 25, 106),
                  child: Column(
                    children: [
                      IrrigationBedSelector(
                        selectedBed: _selectedBed,
                        moistureByBed: moistureByBed,
                        onSelected: (bed) {
                          widget.onBedChanged(bed);
                          setState(() {
                            _selectedBed = bed;
                            _watering = false;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      const ConnectionBadge(),
                      const SizedBox(height: 15),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            0,
                            -4 * math.sin(_controller.value * math.pi),
                          ),
                          child: child,
                        ),
                        child: const PlantOrb(),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'UMIDADE DO SOLO',
                        style: TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_moisture',
                            style: const TextStyle(
                              color: AppColors.white,
                              height: .98,
                              fontSize: 66,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -4,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 7, left: 5),
                            child: Text(
                              '%',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      IdealStatus(status: _soilStatus),
                      const SizedBox(height: 22),
                      const SensorMeta(),
                      const SizedBox(height: 22),
                      WateringButton(
                        watering: _watering,
                        onPressed: () =>
                            setState(() => _watering = !_watering),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selected: AppPage.irrigation,
        onNavigate: widget.onNavigate,
      ),
    );
  }
}

class SensorHeader extends StatelessWidget {
  const SensorHeader({
    required this.selectedBed,
    required this.onBack,
    super.key,
  });

  final int selectedBed;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 8, 17, 13),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar para o jardim',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.white.withOpacity(.1),
              side: BorderSide(
                color: AppColors.white.withOpacity(.25),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HORTA',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                Text(
                  'Canteiro $selectedBed  •  Sensor ESP32',
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const CurrencyBadge(
            icon: Icons.monetization_on_rounded,
            value: '1.569',
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class IrrigationBedSelector extends StatelessWidget {
  const IrrigationBedSelector({
    required this.selectedBed,
    required this.moistureByBed,
    required this.onSelected,
    super.key,
  });

  final int selectedBed;
  final List<int> moistureByBed;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              color: Color(0xCCFFFFFF),
              size: 15,
            ),
            SizedBox(width: 7),
            Text(
              'SELECIONE O CANTEIRO',
              style: TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 57,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: moistureByBed.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final bed = index + 1;
              final selected = bed == selectedBed;
              return Semantics(
                button: true,
                selected: selected,
                label:
                    'Canteiro $bed, ${moistureByBed[index]}% de umidade',
                child: InkWell(
                  onTap: () => onSelected(bed),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 64,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.white
                          : AppColors.white.withOpacity(.09),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.white
                            : AppColors.white.withOpacity(.22),
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.forest.withOpacity(.18),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'C$bed',
                          style: TextStyle(
                            color: selected
                                ? AppColors.forest
                                : AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${moistureByBed[index]}%',
                          style: TextStyle(
                            color: selected
                                ? AppColors.emeraldDark
                                : AppColors.white.withOpacity(.65),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MqttStatus>(
      valueListenable: MqttService.instance.status,
      builder: (context, status, _) {
        final (label, color) = switch (status) {
          MqttStatus.connected => ('SENSOR CONECTADO', const Color(0xFF7AF1A8)),
          MqttStatus.connecting => ('CONECTANDO...', AppColors.gold),
          MqttStatus.reconnecting => ('RECONECTANDO...', AppColors.gold),
          MqttStatus.disconnected => ('SEM CONEXÃO', const Color(0xFFFF8A80)),
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x40104D3D),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.white.withOpacity(.17)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox(width: 7, height: 7),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xD9FFFFFF),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PlantOrb extends StatelessWidget {
  const PlantOrb({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 252,
      height: 252,
      child: CustomPaint(
        painter: OrbRingsPainter(),
        child: Center(
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white.withOpacity(.38),
                  AppColors.white.withOpacity(.08),
                ],
              ),
              border: Border.all(
                color: AppColors.white.withOpacity(.52),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C5B47).withOpacity(.24),
                  blurRadius: 55,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: const CustomPaint(painter: PlantPainter()),
          ),
        ),
      ),
    );
  }
}

class OrbRingsPainter extends CustomPainter {
  const OrbRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.white.withOpacity(.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 124, paint);
    canvas.drawCircle(center, 105, paint);
    canvas.drawCircle(
      center.translate(-94, -76),
      4,
      Paint()..color = AppColors.white.withOpacity(.65),
    );
    canvas.drawCircle(
      center.translate(112, 45),
      2.5,
      Paint()..color = AppColors.white.withOpacity(.55),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlantPainter extends CustomPainter {
  const PlantPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, 63),
        width: 110,
        height: 22,
      ),
      Paint()..color = const Color(0x40164D3A),
    );

    final trunk = Paint()
      ..color = const Color(0xFF75452E)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final trunkPath = Path()
      ..moveTo(center.dx, center.dy + 57)
      ..quadraticBezierTo(
        center.dx + 8,
        center.dy + 16,
        center.dx - 7,
        center.dy - 38,
      );
    canvas.drawPath(trunkPath, trunk);
    canvas.drawLine(
      center.translate(3, 22),
      center.translate(36, -26),
      trunk,
    );
    canvas.drawLine(
      center.translate(-2, 10),
      center.translate(-36, -23),
      trunk,
    );

    final canopy = Paint()..color = const Color(0xFF1B9C59);
    final light = Paint()..color = const Color(0xFF64D98E);
    for (final data in [
      (Offset(-30, -42), 30.0),
      (Offset(4, -57), 33.0),
      (Offset(38, -35), 29.0),
      (Offset(-7, -20), 35.0),
      (Offset(-51, -20), 24.0),
      (Offset(52, -8), 23.0),
    ]) {
      canvas.drawCircle(center + data.$1, data.$2, canopy);
      canvas.drawCircle(
        center + data.$1.translate(-8, -8),
        data.$2 * .48,
        light,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, 66),
        width: 100,
        height: 22,
      ),
      Paint()..color = const Color(0xFF704A32),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, 62),
        width: 78,
        height: 13,
      ),
      Paint()..color = const Color(0xFF3D2C22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IdealStatus extends StatelessWidget {
  const IdealStatus({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final needsWater = status == 'Rega Recomendada';
    final tooWet = status == 'Solo Muito Úmido';
    final statusColor = needsWater
        ? AppColors.gold
        : tooWet
            ? const Color(0xFF75E5F3)
            : const Color(0xFF90EFB5);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            needsWater
                ? Icons.water_drop_outlined
                : tooWet
                    ? Icons.water_rounded
                    : Icons.eco_rounded,
            color: AppColors.forest,
            size: 16,
          ),
        ),
        const SizedBox(width: 7),
        const Text(
          'Status: ',
          style: TextStyle(color: AppColors.white, fontSize: 12),
        ),
        Text(
          status,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class SensorMeta extends StatelessWidget {
  const SensorMeta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0x24FFFFFF)),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _MetaItem(label: 'ÚLTIMA LEITURA', value: 'Agora mesmo'),
          ),
          SizedBox(
            height: 28,
            child: VerticalDivider(color: Color(0x2BFFFFFF)),
          ),
          Expanded(
            child: _MetaItem(label: 'PRÓXIMA LEITURA', value: 'em 4 min'),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x8FFFFFFF),
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class WateringButton extends StatelessWidget {
  const WateringButton({
    required this.watering,
    required this.onPressed,
    super.key,
  });

  final bool watering;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = watering ? AppColors.white : AppColors.forest;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(69),
        padding: const EdgeInsets.fromLTRB(9, 8, 14, 8),
        backgroundColor:
            watering ? AppColors.forest : AppColors.white,
        foregroundColor: foreground,
        shape: const StadiumBorder(),
        elevation: 10,
        shadowColor: AppColors.forest.withOpacity(.3),
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: watering
                  ? const Color(0xFF8DE7AE)
                  : AppColors.forest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_outlined,
              color: watering ? AppColors.forest : AppColors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  watering ? 'REGA EM ANDAMENTO' : 'AÇÃO MANUAL',
                  style: TextStyle(
                    color: watering
                        ? const Color(0xFF8DE7AE)
                        : AppColors.emeraldDark,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  watering
                      ? 'Finalizar Rega'
                      : 'Iniciar Rega Presencial',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: foreground),
        ],
      ),
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selected,
    required this.onNavigate,
    super.key,
  });

  final AppPage selected;
  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(28, 0, 28, 14),
      child: Container(
        height: 64,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(.94),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: AppColors.white.withOpacity(.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.forest.withOpacity(.2),
              blurRadius: 34,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              label: 'Jardim',
              icon: Icons.home_outlined,
              selected: selected == AppPage.garden,
              onTap: () => onNavigate(AppPage.garden),
            ),
            _NavItem(
              label: 'Rega',
              icon: Icons.water_drop_outlined,
              selected: selected == AppPage.irrigation,
              onTap: () => onNavigate(AppPage.irrigation),
            ),
            _NavItem(
              label: 'Sair',
              icon: Icons.logout_rounded,
              selected: false,
              onTap: () => onNavigate(AppPage.login),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? AppColors.forest : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? AppColors.white
                      : const Color(0xFF829388),
                  size: 21,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.white
                        : const Color(0xFF829388),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
