import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const GameBoosterApp());
}

class GameBoosterApp extends StatelessWidget {
  const GameBoosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Booster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF0A0A0A),
          surface: Color(0xFF1A1A1A),
          primary: Color(0xFF00FF88),
          secondary: Color(0xFFFF0080),
          tertiary: Color(0xFF0080FF),
        ),
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const BoosterScreen(),
    );
  }
}

class BoosterScreen extends StatefulWidget {
  const BoosterScreen({super.key});

  @override
  State<BoosterScreen> createState() => _BoosterScreenState();
}

class _BoosterScreenState extends State<BoosterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _boostAnimation;
  bool _isBoosting = false;
  double _ramUsage = 65.0;
  double _cpuTemp = 45.0;
  double _batteryLevel = 85.0;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _boostAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize device info
    _initDeviceInfo();

    // Mock sensor updates
    _startMockUpdates();
  }

  Future<void> _initDeviceInfo() async {
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel.toDouble();
    });
  }

  void _startMockUpdates() {
    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isBoosting) {
        setState(() {
          _ramUsage = 50.0 + Random().nextDouble() * 30.0;
          _cpuTemp = 35.0 + Random().nextDouble() * 20.0;
        });
      }
    });
  }

  Future<void> _boost() async {
    if (_isBoosting) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _isBoosting = true;
    });

    _controller.forward().then((_) {
      // Simulate boost effect
      setState(() {
        _ramUsage = 25.0;
        _cpuTemp = 30.0;
      });

      Timer(const Duration(seconds: 1), () {
        setState(() {
          _isBoosting = false;
        });
        _controller.reverse();
        HapticFeedback.mediumImpact();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A0A2E),
              Color(0xFF0A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF88).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Icon(
                        Icons.speed,
                        color: Color(0xFF00FF88),
                        size: 32.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GAME BOOSTER',
                          style: GoogleFonts.orbitron(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FF88),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4.0,
                                color: const Color(0xFF00FF88).withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Ultimate Performance',
                          style: GoogleFonts.orbitron(
                            fontSize: 14.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(
                        'RAM',
                        '${_ramUsage.toStringAsFixed(0)}%',
                        Icons.memory,
                        const Color(0xFF0080FF),
                        _ramUsage,
                      ),
                      const SizedBox(height: 16.0),
                      _buildStatCard(
                        'CPU TEMP',
                        '${_cpuTemp.toStringAsFixed(0)}°C',
                        Icons.thermostat,
                        const Color(0xFFFF0080),
                        100.0,
                      ),
                      const SizedBox(height: 16.0),
                      _buildStatCard(
                        'BATTERY',
                        '${_batteryLevel.toStringAsFixed(0)}%',
                        Icons.battery_full,
                        const Color(0xFF00FF88),
                        _batteryLevel,
                      ),
                    ],
                  ),
                ),
              ),

              // BOOST Button
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: GestureDetector(
                  onTap: _isBoosting ? null : _boost,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_boostAnimation.value * 0.1),
                        child: Container(
                          height: 120.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isBoosting
                                  ? [
                                      const Color(0xFF00FF88),
                                      const Color(0xFF00CC6A),
                                    ]
                                  : [
                                      const Color(0xFF00FF88).withOpacity(0.3),
                                      const Color(0xFF0080FF).withOpacity(0.3),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(60.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF88).withOpacity(0.4),
                                blurRadius: 30.0,
                                spreadRadius: _boostAnimation.value * 5.0,
                              ),
                            ],
                          ),
                          child: _isBoosting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Lottie.asset(
                                        'assets/animations/boost.json',
                                        repeat: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'BOOSTING...',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${(_boostAnimation.value * 100).toInt()}%',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 16.0,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text(
                                    'BOOST',
                                    style: TextStyle(
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 4.0,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Watermark
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Developed by Bintang',
                  style: GoogleFonts.orbitron(
                    fontSize: 12.0,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: color, size: 28.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 14.0,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: 60.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              Container(
                width: (progress / 100) * 60.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
