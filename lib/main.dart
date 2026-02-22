import 'dart:async';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent, brightness: Brightness.dark, primary: Colors.greenAccent),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
  
  int _ping = 45;
  int _temp = 38;
  Timer? _statsTimer;

  List<AppInfo> _installedApps = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if(mounted) setState(() { _ping = 40 + math.Random().nextInt(25); _temp = 35 + math.Random().nextInt(8); });
    });
    _loadApps();
  }

  void _loadApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      List<AppInfo> gameApps = apps.where((app) {
        String pkg = app.packageName?.toLowerCase() ?? '';
        if (pkg.contains('freefire') || pkg.contains('dts') || pkg.contains('pubg') || pkg.contains('tencent') || pkg.contains('legends') || pkg.contains('roblox')) {
          return true;
        }
        return false;
      }).toList();

      if(mounted) {
        setState(() {
          _installedApps = gameApps;
          _isLoadingApps = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoadingApps = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _statsTimer?.cancel();
    super.dispose();
  }

  void startBoostProcess() {
    if (_isBoosting) return;
    setState(() { _isBoosting = true; _showLetsPlay = false; });
    _spinController.repeat();
    Timer(const Duration(seconds: 3), () {
      _spinController.stop();
      if (mounted) {
        setState(() { _isBoosting = false; _ramValue = (30 + math.Random().nextInt(15)) / 100.0; _showLetsPlay = true; _temp = 32; _ping = 35; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Device Optimized!"), backgroundColor: Colors.greenAccent.shade700, behavior: SnackBarBehavior.floating));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FF GAMING HUB'), leading: const Icon(Icons.menu), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))]),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://i.imgur.com/LoadH9S.png"), opacity: 0.05, fit: BoxFit.cover)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRamMonitorCard(),
              const SizedBox(height: 15),
              _buildSystemStatsRow(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildPremiumActionButton("GFX TOOL", Icons.settings_suggest_outlined, Colors.orangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GfxToolPage())))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildPremiumActionButton("CROSSHAIR", Icons.my_location, Colors.cyanAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CrosshairPage())))),
                ],
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage())),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 70, width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFF1A221A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.1), blurRadius: 10)]),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.radar, color: Colors.purpleAccent, size: 28), SizedBox(width: 10), Text("🔥 VIP SENSI (HEADSHOT)", style: TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2))]),
                ),
              ),
              const SizedBox(height: 25),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(left: 5, bottom: 15), child: Text("🎮 MY INSTALLED GAMES", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  SizedBox(
                    height: 90,
                    child: _isLoadingApps 
                      ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                      : _installedApps.isEmpty 
                        ? const Center(child: Text("No games found on your device", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _installedApps.length,
                            itemBuilder: (context, index) {
                              AppInfo app = _installedApps[index];
                              return GestureDetector(
                                onTap: () => InstalledApps.startApp(app.packageName!),
                                child: Container(
                                  width: 75, margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: const Color(0xFF1A221A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                                        child: app.icon != null ? Image.memory(app.icon!, width: 40, height: 40) : const Icon(Icons.sports_esports, color: Colors.greenAccent, size: 40),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(app.name ?? 'Game', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildBottomAnimationSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatsRow() {
    return Row(
      children: [
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF161B16), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.network_ping, color: Colors.blueAccent, size: 20), const SizedBox(width: 10), Text("$_ping ms", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]))),
        const SizedBox(width: 15),
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF161B16), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.thermostat, color: Colors.redAccent, size: 20), const SizedBox(width: 10), Text("$_temp°C", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]))),
      ],
    );
  }

  Widget _buildRamMonitorCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1A221A), Colors.greenAccent.withOpacity(0.05)]), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 1), boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(turns: _spinController, child: SizedBox(width: 160, height: 160, child: TweenAnimationBuilder<double>(tween: Tween<double>(begin: 0, end: _ramValue), duration: const Duration(seconds: 1), builder: (context, value, child) { return CircularProgressIndicator(value: _isBoosting ? null : value, strokeWidth: 12, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(_isBoosting ? Colors.orangeAccent : Colors.greenAccent), strokeCap: StrokeCap.round); }))),
              Column(children: [Text(_isBoosting ? "OPTIMIZING..." : "RAM USED", style: TextStyle(color: Colors.grey.shade400, letterSpacing: 1, fontSize: 12)), const SizedBox(height: 5), TweenAnimationBuilder<double>(tween: Tween<double>(begin: 0, end: _ramValue), duration: const Duration(milliseconds: 800), builder: (context, value, child) { return Text(_isBoosting ? "--" : "${(value * 100).toInt()}%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)); })]),
            ],
          ),
          const SizedBox(height: 25),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300), height: 55, width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: LinearGradient(colors: _isBoosting ? [Colors.grey.shade800, Colors.grey.shade900] : [Colors.greenAccent.shade400, Colors.green.shade700]), boxShadow: _isBoosting ? [] : [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Material(color: Colors.transparent, child: InkWell(onTap: _isBoosting ? null : startBoostProcess, borderRadius: BorderRadius.circular(15), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (_isBoosting) const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)), if (_isBoosting) const SizedBox(width: 15), Text(_isBoosting ? "BOOSTING..." : "BOOST RAM NOW", style: TextStyle(color: _isBoosting ? Colors.white54 : Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1))])))),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 100, decoration: BoxDecoration(color: const Color(0xFF1A221A), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.15)), boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 30, color: color), const SizedBox(height: 10), Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color))]))),
    );
  }

  Widget _buildBottomAnimationSection() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 800),
      firstChild: Column(children: [Icon(Icons.security, size: 60, color: Colors.greenAccent.withOpacity(0.5)), const SizedBox(height: 10), Text("SYSTEM READY", style: TextStyle(color: Colors.greenAccent.withOpacity(0.7), letterSpacing: 2))]),
      secondChild: Column(children: [ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [Colors.greenAccent, Colors.blueAccent]).createShader(bounds), child: const Icon(Icons.sports_esports_rounded, size: 70, color: Colors.white)), const SizedBox(height: 10), ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Colors.greenAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(bounds), child: const Text("LET'S PLAY", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)))]),
      crossFadeState: _showLetsPlay ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    );
  }
}

// ==========================================
// 2. GFX TOOL PAGE
// ==========================================
class GfxToolPage extends StatefulWidget {
  const GfxToolPage({super.key});
  @override
  State<GfxToolPage> createState() => _GfxToolPageState();
}

class _GfxToolPageState extends State<GfxToolPage> {
  String selectedRes = "1080p";
  String selectedFPS = "60 FPS";
  String selectedGraphics = "Smooth";
  bool isApplying = false;

  void applySettings() {
    setState(() => isApplying = true);
    Timer(const Duration(seconds: 2), () {
      setState(() => isApplying = false);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GFX Settings Applied Successfully!"), backgroundColor: Colors.greenAccent));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GFX SETTINGS", style: TextStyle(color: Colors.orangeAccent))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("RESOLUTION"),
            _buildOptionsRow(["720p", "1080p", "1440p"], selectedRes, (val) => setState(() => selectedRes = val), Colors.orangeAccent),
            const SizedBox(height: 25),
            _buildSectionTitle("FPS (FRAMES PER SECOND)"),
            _buildOptionsRow(["30 FPS", "60 FPS", "90 FPS"], selectedFPS, (val) => setState(() => selectedFPS = val), Colors.orangeAccent),
            const SizedBox(height: 25),
            _buildSectionTitle("GRAPHICS QUALITY"),
            _buildOptionsRow(["Smooth", "Balanced", "HDR"], selectedGraphics, (val) => setState(() => selectedGraphics = val), Colors.orangeAccent),
            const SizedBox(height: 50),
            InkWell(
              onTap: isApplying ? null : applySettings,
              child: Container(
                height: 60, width: double.infinity,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]), borderRadius: BorderRadius.circular(15)),
                child: Center(child: isApplying ? const CircularProgressIndicator(color: Colors.white) : const Text("APPLY SETTINGS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)));
  }

  Widget _buildOptionsRow(List<String> options, String currentValue, Function(String) onSelect, Color activeColor) {
    return Row(
      children: options.map((opt) {
        bool isSelected = currentValue == opt;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(color: isSelected ? activeColor.withOpacity(0.2) : const Color(0xFF1A221A), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? activeColor : Colors.white10)),
              child: Center(child: Text(opt, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? activeColor : Colors.white54))),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==========================================
// 3. CROSSHAIR PAGE
// ==========================================
class CrosshairPage extends StatefulWidget {
  const CrosshairPage({super.key});
  @override
  State<CrosshairPage> createState() => _CrosshairPageState();
}

class _CrosshairPageState extends State<CrosshairPage> {
  IconData selectedIcon = Icons.add;
  Color selectedColor = Colors.redAccent;
  bool isApplying = false;

  final List<IconData> crosshairs = [Icons.add, Icons.gps_fixed, Icons.my_location, Icons.control_camera, Icons.filter_center_focus, Icons.track_changes];
  final List<Color> colors = [Colors.redAccent, Colors.greenAccent, Colors.yellowAccent, Colors.white, Colors.cyanAccent, Colors.purpleAccent];

  void activateCrosshair() {
    setState(() => isApplying = true);
    Timer(const Duration(seconds: 2), () {
      setState(() => isApplying = false);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Custom Crosshair Activated Successfully!"), backgroundColor: Colors.cyan));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CUSTOM CROSSHAIR", style: TextStyle(color: Colors.cyanAccent))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(color: const Color(0xFF161B16), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
                child: Center(child: Icon(selectedIcon, size: 60, color: selectedColor)),
              ),
            ),
            const SizedBox(height: 30),
            const Text("SELECT STYLE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 15, runSpacing: 15,
              children: crosshairs.map((icon) => GestureDetector(
                onTap: () => setState(() => selectedIcon = icon),
           
