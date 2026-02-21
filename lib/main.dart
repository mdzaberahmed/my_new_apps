kimport 'dart:async';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:math' as math;

void main() {
  runApp(const FFBoostAppPremium());
}

class FFBoostAppPremium extends StatelessWidget {
  const FFBoostAppPremium({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FF Boost Premium',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050805),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
          primary: Colors.greenAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      home: const PremiumBoostPanel(),
    );
  }
}

class PremiumBoostPanel extends StatefulWidget {
  const PremiumBoostPanel({super.key});

  @override
  State<PremiumBoostPanel> createState() => _PremiumBoostPanelState();
}

class _PremiumBoostPanelState extends State<PremiumBoostPanel> with TickerProviderStateMixin {
  double _ramValue = 0.78; 
  bool _isBoosting = false;
  bool _showLetsPlay = false;

  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  // --- NEW LAUNCH LOGIC ---
  Future<void> launchFreeFire() async {
    try {
      const intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: 'com.dts.freefireth', // Free Fire Package
      );
      await intent.launch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Free Fire is not installed on this device!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void startBoostProcess() {
    if (_isBoosting) return;

    setState(() {
      _isBoosting = true;
      _showLetsPlay = false; 
    });
    _spinController.repeat(); 

    Timer(const Duration(seconds: 3), () {
      _spinController.stop(); 
      setState(() {
        _isBoosting = false;
        _ramValue = (30 + math.Random().nextInt(15)) / 100.0;
        _showLetsPlay = true; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Device Optimized for Maximum Performance!"),
          backgroundColor: Colors.greenAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FF GAMING HUB'),
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: NetworkImage("https://i.imgur.com/LoadH9S.png"), 
                opacity: 0.05,
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildRamMonitorCard(),
              const SizedBox(height: 30),
              _buildActionGrid(),
              const SizedBox(height: 40),
              _buildBottomAnimationSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRamMonitorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1A221A), Colors.greenAccent.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _spinController,
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _ramValue),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: _isBoosting ? null : value, 
                        strokeWidth: 14,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                           _isBoosting ? Colors.orangeAccent : Colors.greenAccent
                        ),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
              ),
              Column(
                children: [
                  Text(_isBoosting ? "OPTIMIZING..." : "RAM USED",
                      style: TextStyle(color: Colors.grey.shade400, letterSpacing: 1)),
                  const SizedBox(height: 5),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _ramValue),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Text(
                        _isBoosting ? "--" : "${(value * 100).toInt()}%",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
               gradient: LinearGradient(
                  colors: _isBoosting
                      ? [Colors.grey.shade800, Colors.grey.shade900]
                      : [Colors.greenAccent.shade400, Colors.green.shade700]),
              boxShadow: _isBoosting ? [] : [
                BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
              ]
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isBoosting ? null : startBoostProcess,
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isBoosting)
                        const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                      if (_isBoosting) const SizedBox(width: 15),
                      Text(
                        _isBoosting ? "BOOSTING..." : "BOOST RAM NOW",
                        style: TextStyle(color: _isBoosting ? Colors.white54 : Colors.black, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildPremiumActionButton("GFX TOOL", Icons.settings_suggest_outlined, Colors.orangeAccent, () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GFX Settings Coming Soon!")));
          }),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildPremiumActionButton("LAUNCH FF", Icons.rocket_launch, Colors.white, launchFreeFire),
        ),
      ],
    );
  }

  Widget _buildPremiumActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A221A),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAnimationSection() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 800),
      firstChild: Column(
        children: [
          Icon(Icons.security, size: 70, color: Colors.greenAccent.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text("SYSTEM READY", style: TextStyle(color: Colors.greenAccent.withOpacity(0.7), letterSpacing: 2)),
        ],
      ),
      secondChild: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [Colors.greenAccent, Colors.blueAccent]).createShader(bounds),
            child: const Icon(Icons.sports_esports_rounded, size: 80, color: Colors.white),
          ),
           const SizedBox(height: 10),
           ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Colors.greenAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(bounds),
             child: const Text("LET'S PLAY GAME", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
           ),
        ],
      ),
      crossFadeState: _showLetsPlay ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    );
  }
}
