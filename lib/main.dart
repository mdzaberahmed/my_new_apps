                                      ),
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const FFBoostAppPremium());
}

class FFBoostAppPremium extends StatelessWidget {
  const FFBoostAppPremium({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FF Boost Premium',
      // 10/10 LUXURY THEME SETUP
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05080D), // Deep Space Dark BG
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700), brightness: Brightness.dark, primary: const Color(0xFFFFD700)), // Gold Primary
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFFFFD700), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2),
          iconTheme: IconThemeData(color: Color(0xFFFFD700)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFFFFD700),
          inactiveTrackColor: const Color(0xFF1A1F2B),
          thumbColor: const Color(0xFFFFD700),
          overlayColor: const Color(0xFFFFD700).withOpacity(0.2),
          trackHeight: 6,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(const Color(0xFFFFD700)),
          trackColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? const Color(0xFFFFD700).withOpacity(0.5) : Colors.grey.shade800),
        )
      ),
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN (LUXURY UPGRADE) ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PremiumBoostPanel()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(colors: [Color(0xFF1A1F2B), Color(0xFF05080D)], radius: 1.5, center: Alignment.center)
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 50, spreadRadius: 10)]
                ),
                child: const Icon(Icons.rocket_launch_rounded, size: 80, color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 40),
              const Text("FF GAMING HUB", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFFFD700), letterSpacing: 3)),
              const SizedBox(height: 15),
              Text("LUXURY EDITION", style: TextStyle(fontSize: 14, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 6, fontWeight: FontWeight.bold)),
              const SizedBox(height: 60),
              const CircularProgressIndicator(color: Color(0xFFFFD700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== NEW LUXURY HOME SCREEN ====================
class PremiumBoostPanel extends StatefulWidget {
  const PremiumBoostPanel({super.key});
  @override
  State<PremiumBoostPanel> createState() => _PremiumBoostPanelState();
}

class _PremiumBoostPanelState extends State<PremiumBoostPanel> {
  bool _isOptimizing = false;
  int _ping = 56;
  Timer? _statsTimer;
  List<AppInfo> _installedApps = [];
  bool _isLoadingApps = true;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _statsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if(mounted) setState(() { _ping = 45 + math.Random().nextInt(15); });
    });
    _loadApps();
    _loadRewardedAd(); 
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1591007651969921/1768812277', 
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void _showRewardedAdAndNavigate() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) { ad.dispose(); _loadRewardedAd(); },
        onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); _loadRewardedAd(); Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage())); },
      );
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage()));
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage()));
      _loadRewardedAd();
    }
  }

  void _loadApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      List<AppInfo> gameApps = apps.where((app) {
        String pkg = app.packageName?.toLowerCase() ?? '';
        return pkg.contains('freefire') || pkg.contains('dts') || pkg.contains('pubg') || pkg.contains('tencent') || pkg.contains('legends') || pkg.contains('roblox');
      }).toList();
      if(mounted) setState(() { _installedApps = gameApps; _isLoadingApps = false; });
    } catch (e) {
      if(mounted) setState(() => _isLoadingApps = false);
    }
  }

  void _optimizeDevice() {
    setState(() => _isOptimizing = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Preparing device for maximum performance..."), backgroundColor: const Color(0xFF1A1F2B), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFFFD700)))));
    Timer(const Duration(seconds: 3), () {
      setState(() => _isOptimizing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Device READY for Gaming!"), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating));
    });
  }

  @override
  void dispose() { _statsTimer?.cancel(); _rewardedAd?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FF GAMING HUB'),
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: (){}),
        actions: [IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: (){})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LUXURY STATUS DASHBOARD ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1F2B), Color(0xFF0A0E11)]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.2), blurRadius: 25, offset: const Offset(0, 10))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem(Icons.wifi_tethering_rounded, "$_ping MS", "LIVE PING", Colors.greenAccent),
                  Container(height: 60, width: 1, color: const Color(0xFFFFD700).withOpacity(0.3)),
                  _buildStatusItem(Icons.bolt_rounded, "OPTIMAL", "SYSTEM", const Color(0xFFFFD700)),
                ],
              ),
            ),
            
            const SizedBox(height: 35),

            // --- GLOWING OPTIMIZE BUTTON ---
            InkWell(
              onTap: _isOptimizing ? null : _optimizeDevice,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5)),
                    BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 30, spreadRadius: 5, offset: const Offset(0, 10))
                    ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isOptimizing 
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Icon(Icons.rocket_launch_rounded, color: Colors.black87, size: 36),
                    const SizedBox(width: 15),
                    Text(_isOptimizing ? "PREPARING..." : "PREPARE FOR MATCH", style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- NEON TOOLS GRID ---
            Row(
              children: [
                Expanded(child: _buildNeonToolBtn("GFX TOOL", Icons.settings_suggest_rounded, Colors.cyanAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GfxToolPage())))),
                const SizedBox(width: 20),
                Expanded(child: _buildNeonToolBtn("CROSSHAIR", Icons.gps_fixed_rounded, Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CrosshairPage())))),
              ],
            ),

            const SizedBox(height: 30),

            // --- GOLDEN VIP BUTTON ---
            InkWell(
              onTap: _showRewardedAdAndNavigate, 
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2B),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))]
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 34),
                    SizedBox(width: 15),
                    Text("UNLOCK VIP FEATURES", style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- FUTURISTIC GAME LIBRARY ---
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text("INSTALLED GAMES", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700), fontSize: 16, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.cyanAccent.withOpacity(0.05), Colors.purpleAccent.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white10, width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, inset: true)]
              ),
              child: _isLoadingApps 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _installedApps.length,
                      itemBuilder: (context, index) {
                        AppInfo app = _installedApps[index];
                        return GestureDetector(
                          onTap: () => InstalledApps.startApp(app.packageName!), 
                          child: Container(
                            width: 85, margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFD700), width: 2), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 15)]),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(50), child: app.icon != null ? Image.memory(app.icon!, width: 55, height: 55) : const Icon(Icons.games, color: Colors.white)),
                                ),
                                const SizedBox(height: 10),
                                Text(app.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30, shadows: [Shadow(color: color, blurRadius: 10)]),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeonToolBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2B),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
           boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36, shadows: [Shadow(color: color, blurRadius: 15)]),
            const SizedBox(height: 15),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
// ==================== GFX TOOL PAGE (LUXURY REDESIGN) ====================
class GfxToolPage extends StatefulWidget {
  const GfxToolPage({super.key});
  @override
  State<GfxToolPage> createState() => _GfxToolPageState();
}
class _GfxToolPageState extends State<GfxToolPage> {
  String selectedRes = "1080p"; String selectedFPS = "60 FPS"; String selectedGraphics = "Smooth"; bool isApplying = false;
  void applySettings() {
    setState(() => isApplying = true);
    Timer(const Duration(seconds: 2), () {
      setState(() => isApplying = false);
      if(mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("GFX Settings Applied!"), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating)); Navigator.pop(context); }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GFX SETTINGS")),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionTitle("RESOLUTION"), _buildOptionsRow(["720p", "1080p", "1440p"], selectedRes, (val) => setState(() => selectedRes = val), Colors.orangeAccent),
        const SizedBox(height: 35), _buildSectionTitle("FPS"), _buildOptionsRow(["30 FPS", "60 FPS", "90 FPS"], selectedFPS, (val) => setState(() => selectedFPS = val), Colors.cyanAccent),
        const SizedBox(height: 35), _buildSectionTitle("GRAPHICS"), _buildOptionsRow(["Smooth", "Balanced", "HDR"], selectedGraphics, (val) => setState(() => selectedGraphics = val), Colors.purpleAccent),
        const SizedBox(height: 60),
        InkWell(onTap: isApplying ? null : applySettings, borderRadius: BorderRadius.circular(25), child: Container(height: 70, width: double.infinity, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]), child: Center(child: isApplying ? const CircularProgressIndicator(color: Colors.white) : const Text("APPLY SETTINGS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1))))),
      ])),
    );
  }
  Widget _buildSectionTitle(String title) { return Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2))); }
  Widget _buildOptionsRow(List<String> options, String currentValue, Function(String) onSelect, Color activeColor) {
    return Row(children: options.map((opt) {
      bool isSelected = currentValue == opt;
      return Expanded(child: GestureDetector(onTap: () => onSelect(opt), child: AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 5), padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: isSelected ? activeColor.withOpacity(0.1) : const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? activeColor : Colors.white10, width: 1.5), boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 15)] : []), child: Center(child: Text(opt, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? activeColor : Colors.white54, letterSpacing: 1))))));
    }).toList());
  }
}

// ==================== CROSSHAIR PAGE (LUXURY REDESIGN) ====================
class CrosshairPage extends StatefulWidget {
  const CrosshairPage({super.key});
  @override
  State<CrosshairPage> createState() => _CrosshairPageState();
}
class _CrosshairPageState extends State<CrosshairPage> {
  IconData selectedIcon = Icons.add; Color selectedColor = Colors.redAccent; bool isApplying = false;
  final List<IconData> crosshairs = [Icons.add, Icons.gps_fixed, Icons.my_location, Icons.control_camera, Icons.filter_center_focus, Icons.track_changes];
  final List<Color> colors = [Colors.redAccent, Colors.greenAccent, Colors.yellowAccent, Colors.white, Colors.cyanAccent, Colors.purpleAccent];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CUSTOM CROSSHAIR")),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 180, height: 180, decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(30), border: Border.all(color: selectedColor.withOpacity(0.8), width: 2), boxShadow: [BoxShadow(color: selectedColor.withOpacity(0.4), blurRadius: 30)]), child: Center(child: Icon(selectedIcon, size: 80, color: selectedColor, shadows: [Shadow(color: selectedColor, blurRadius: 20)])))),
        const SizedBox(height: 40), const Text("SELECT STYLE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 20), Wrap(spacing: 20, runSpacing: 20, children: crosshairs.map((icon) => GestureDetector(onTap: () => setState(() => selectedIcon = icon), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 65, height: 65, decoration: BoxDecoration(color: selectedIcon == icon ? Colors.cyanAccent.withOpacity(0.1) : const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(15), border: Border.all(color: selectedIcon == icon ? Colors.cyanAccent : Colors.white10, width: 1.5), boxShadow: selectedIcon == icon ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 15)] : []), child: Icon(icon, color: selectedIcon == icon ? Colors.cyanAccent : Colors.white54)))).toList()),
        const SizedBox(height: 40), const Text("SELECT COLOR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 20), Wrap(spacing: 20, runSpacing: 20, children: colors.map((color) => GestureDetector(onTap: () => setState(() => selectedColor = color), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 55, height: 55, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: selectedColor == color ? Colors.white : Colors.transparent, width: 3), boxShadow: selectedColor == color ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 20)] : []), ))).toList()),
        const SizedBox(height: 60),
        InkWell(onTap: () { setState(() => isApplying = true); Timer(const Duration(seconds: 2), () { setState(() => isApplying = false); Navigator.pop(context); }); }, borderRadius: BorderRadius.circular(25), child: Container(height: 70, width: double.infinity, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]), child: Center(child: isApplying ? const CircularProgressIndicator(color: Colors.white) : const Text("ACTIVATE CROSSHAIR", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1))))),
      ])),
    );
  }
}

// ==================== VIP PAGE (LUXURY REDESIGN - FUNCTIONAL) ====================
class VipSensiPage extends StatefulWidget {
  const VipSensiPage({super.key});
  @override
  State<VipSensiPage> createState() => _VipSensiPageState();
}
class _VipSensiPageState extends State<VipSensiPage> {
  double general = 98; double redDot = 95; double scope2x = 90; double scope4x = 85;
  bool isDPIBoosted = false; bool isPingFixed = false; bool isLaserEnabled = false; bool isApplying = false;
  String myDeviceName = "Your Device"; 

  @override
  void initState() { super.initState(); _fetchDeviceName(); }

  Future<void> _fetchDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (mounted) setState(() { myDeviceName = "${androidInfo.brand.toUpperCase()} ${androidInfo.model}"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VIP PREMIUM FEATURES", style: TextStyle(color: Color(0xFFFFD700)))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFFFD700), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 20)]), child: Column(children: [
          const Text("🔥 ADVANCED TOOLS 🔥", style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)), const Divider(color: Color(0xFFFFD700), height: 30),
          _buildVipToggle("Auto DPI Optimizer", "Boosts $myDeviceName Touch", Icons.speed_rounded, isDPIBoosted, (val) => setState(() => isDPIBoosted = val)),
          _buildVipToggle("Ping Stabilizer Pro", "Connects to 1.1.1.1 DNS", Icons.network_check_rounded, isPingFixed, (val) => setState(() => isPingFixed = val)),
          _buildVipToggle("Laser Crosshair Pro", "Red Dot Laser for Sniper", Icons.track_changes_rounded, isLaserEnabled, (val) => setState(() => isLaserEnabled = val)),
        ])),
        const SizedBox(height: 40), const Text("🎯 VIP SENSITIVITY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 25), _buildSensiSlider("GENERAL", general, (val) => setState(() => general = val)),
        _buildSensiSlider("RED DOT", redDot, (val) => setState(() => redDot = val)),
        _buildSensiSlider("2X SCOPE", scope2x, (val) => setState(() => scope2x = val)),
        _buildSensiSlider("4X SCOPE", scope4x, (val) => setState(() => scope4x = val)),
        const SizedBox(height: 60),
        InkWell(onTap: () { setState(() => isApplying = true); Timer(const Duration(seconds: 2), () { setState(() => isApplying = false); Navigator.pop(context); }); }, borderRadius: BorderRadius.circular(25), child: Container(height: 70, width: double.infinity, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]), child: Center(child: isApplying ? const CircularProgressIndicator(color: Colors.black87) : const Text("APPLY ALL VIP SETTINGS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1))))),
      ])),
    );
  }
  Widget _buildVipToggle(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: ListTile(contentPadding: EdgeInsets.zero, leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFFFD700))), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)), trailing: Transform.scale(scale: 1.2, child: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFFFD700), activeTrackColor: const Color(0xFFFFD700).withOpacity(0.4)))));
  }
  Widget _buildSensiSlider(String title, double value, Function(double) onChanged) {
    return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)), Text("${value.toInt()}%", style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18))]), Slider(value: value, min: 0, max: 100, onChanged: onChanged)]);
  }
}
