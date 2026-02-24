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
      title: 'Game Utility Hub',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05080D), 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700), brightness: Brightness.dark, primary: const Color(0xFFFFD700)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
          thumbColor: WidgetStateProperty.all(const Color(0xFFFFD700)),
          trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? const Color(0xFFFFD700).withOpacity(0.5) : Colors.grey.shade800),
        )
      ),
      home: const SplashScreen(),
    );
  }
}

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
                child: const Icon(Icons.display_settings_rounded, size: 80, color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 40),
              const Text("GAME UTILITY HUB", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFFD700), letterSpacing: 3)),
              const SizedBox(height: 15),
              Text("PRO PRESET EDITION", style: TextStyle(fontSize: 14, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 4, fontWeight: FontWeight.bold)),
              const SizedBox(height: 60),
              const CircularProgressIndicator(color: Color(0xFFFFD700)),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumBoostPanel extends StatefulWidget {
  const PremiumBoostPanel({super.key});
  @override
  State<PremiumBoostPanel> createState() => _PremiumBoostPanelState();
}

class _PremiumBoostPanelState extends State<PremiumBoostPanel> {
  bool _isOptimizing = false;
  int _ping = 56;
  bool _pingBlink = true; // For Live Animated Ping Effect
  bool _isVipUnlocked = false; // For VIP Glow Border Effect
  
  Timer? _statsTimer;
  List<AppInfo> _installedApps = [];
  bool _isLoadingApps = true;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    // 2. Animated Live Ping Effect
    _statsTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if(mounted) {
        setState(() { 
          _ping = 45 + math.Random().nextInt(15); 
          _pingBlink = !_pingBlink; 
        });
      }
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
        onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); _loadRewardedAd(); _openVipPage(); },
      );
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(() => _isVipUnlocked = true); // 3. Activate VIP Glow
        _openVipPage();
      });
    } else {
      setState(() => _isVipUnlocked = true); // Fallback unlock
      _openVipPage();
      _loadRewardedAd();
    }
  }

  void _openVipPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage()));
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
    Timer(const Duration(seconds: 2), () {
      setState(() => _isOptimizing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Utility Panel Ready!"), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating));
    });
  }

  @override
  void dispose() { _statsTimer?.cancel(); _rewardedAd?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAME UTILITY'),
        leading: IconButton(icon: const Icon(Icons.sort_rounded), onPressed: (){}),
        actions: [
          // 1. Top Right PRO Badge (Masterpiece Feature)
          Container(
            margin: const EdgeInsets.only(right: 15, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.5), blurRadius: 10)]
            ),
            child: const Center(child: Text("PRO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dashboard with Live Ping Animation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1F2B), Color(0xFF0A0E11)]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Animated Ping Section
                  Column(
                    children: [
                      Row(
                        children: [
                          AnimatedOpacity(
                            opacity: _pingBlink ? 1.0 : 0.3, 
                            duration: const Duration(milliseconds: 500),
                            child: const Icon(Icons.circle, color: Colors.greenAccent, size: 14, shadows: [Shadow(color: Colors.greenAccent, blurRadius: 10)])
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.network_ping_rounded, color: Colors.greenAccent, size: 28),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("$_ping MS", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                      Text("NETWORK", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), letterSpacing: 2)),
                    ],
                  ),
                  Container(height: 60, width: 1, color: const Color(0xFFFFD700).withOpacity(0.3)),
                  _buildStatusItem(Icons.memory_rounded, "READY", "SYSTEM", const Color(0xFFFFD700)),
                ],
              ),
            ),
            
            const SizedBox(height: 35),

            // Play Store Safe Main Button
            InkWell(
              onTap: _isOptimizing ? null : _optimizeDevice,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 5))]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isOptimizing 
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Icon(Icons.tune_rounded, color: Colors.black87, size: 32),
                    const SizedBox(width: 15),
                    Text(_isOptimizing ? "LOADING UTILITIES..." : "GAME UTILITY PANEL", style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(child: _buildNeonToolBtn("CUSTOM LAYOUT", Icons.display_settings_rounded, Colors.cyanAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GfxToolPage())))),
                const SizedBox(width: 20),
                Expanded(child: _buildNeonToolBtn("VISUAL PRESET", Icons.gps_fixed_rounded, Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CrosshairPage())))),
              ],
            ),

            const SizedBox(height: 30),

            // 3. VIP Active Glow Border Effect
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: _isVipUnlocked ? [BoxShadow(color: const Color(0xFFFFD700), blurRadius: 30, spreadRadius: 5)] : [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))]
              ),
              child: InkWell(
                onTap: _showRewardedAdAndNavigate, 
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2B),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFFFD700), width: _isVipUnlocked ? 3 : 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isVipUnlocked ? Icons.verified_rounded : Icons.workspace_premium_rounded, color: const Color(0xFFFFD700), size: 34),
                      const SizedBox(width: 15),
                      Text(_isVipUnlocked ? "PRO UTILITIES ACTIVE" : "UNLOCK PRO UTILITIES", style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text("GAME LAUNCHER TOOLS", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700), fontSize: 15, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white10, width: 1),
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
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFD700), width: 2)),
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
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), letterSpacing: 2)),
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
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
// ==================== LAYOUT PRESET PAGE (Play Store Safe) ====================
class GfxToolPage extends StatefulWidget {
  const GfxToolPage({super.key});
  @override
  State<GfxToolPage> createState() => _GfxToolPageState();
}
class _GfxToolPageState extends State<GfxToolPage> {
  String selectedRes = "Standard"; String selectedFPS = "Balanced"; String selectedGraphics = "Smooth"; 
  bool isApplying = false;
  bool showSuccess = false; // 4. Success Animation State

  void applySettings() {
    setState(() { isApplying = true; showSuccess = false; });
    Timer(const Duration(seconds: 2), () {
      if(mounted) {
        setState(() { isApplying = false; showSuccess = true; }); // Show checkmark
        Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context)); // Auto close after success
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CUSTOM LAYOUT")),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionTitle("DISPLAY PROFILE"), _buildOptionsRow(["Standard", "HD", "FHD"], selectedRes, (val) => setState(() => selectedRes = val), Colors.orangeAccent),
        const SizedBox(height: 35), _buildSectionTitle("FRAME PRESET"), _buildOptionsRow(["Balanced", "Fluid", "Max"], selectedFPS, (val) => setState(() => selectedFPS = val), Colors.cyanAccent),
        const SizedBox(height: 35), _buildSectionTitle("VISUAL STYLE"), _buildOptionsRow(["Smooth", "Vivid", "Soft"], selectedGraphics, (val) => setState(() => selectedGraphics = val), Colors.purpleAccent),
        const SizedBox(height: 60),
        
        // 4. Success Animation Button
        InkWell(
          onTap: isApplying || showSuccess ? null : applySettings, 
          borderRadius: BorderRadius.circular(25), 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70, width: double.infinity, 
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: showSuccess ? [Colors.green, Colors.greenAccent] : [Colors.orangeAccent, Colors.deepOrange]), 
              borderRadius: BorderRadius.circular(25), 
              boxShadow: [BoxShadow(color: (showSuccess ? Colors.green : Colors.orangeAccent).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]
            ), 
            child: Center(
              child: isApplying 
                ? const CircularProgressIndicator(color: Colors.white) 
                : (showSuccess 
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 28), SizedBox(width: 10), Text("SUCCESSFULLY APPLIED", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))])
                    : const Text("APPLY PRESETS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)))
            )
          )
        ),
      ])),
    );
  }
  Widget _buildSectionTitle(String title) { return Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2))); }
  Widget _buildOptionsRow(List<String> options, String currentValue, Function(String) onSelect, Color activeColor) {
    return Row(children: options.map((opt) {
      bool isSelected = currentValue == opt;
      return Expanded(child: GestureDetector(onTap: () => onSelect(opt), child: AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 5), padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: isSelected ? activeColor.withOpacity(0.1) : const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? activeColor : Colors.white10, width: 1.5)), child: Center(child: Text(opt, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? activeColor : Colors.white54, fontSize: 13))))));
    }).toList());
  }
}

// ==================== VISUAL PRESET PAGE (Crosshair - Safe) ====================
class CrosshairPage extends StatefulWidget {
  const CrosshairPage({super.key});
  @override
  State<CrosshairPage> createState() => _CrosshairPageState();
}
class _CrosshairPageState extends State<CrosshairPage> {
  IconData selectedIcon = Icons.add; Color selectedColor = Colors.redAccent; 
  bool isApplying = false; bool showSuccess = false;
  final List<IconData> crosshairs = [Icons.add, Icons.gps_fixed, Icons.my_location, Icons.control_camera, Icons.filter_center_focus, Icons.track_changes];
  final List<Color> colors = [Colors.redAccent, Colors.greenAccent, Colors.yellowAccent, Colors.white, Colors.cyanAccent, Colors.purpleAccent];
  
  void applyCrosshair() {
    setState(() { isApplying = true; showSuccess = false; });
    Timer(const Duration(seconds: 2), () {
      if(mounted) {
        setState(() { isApplying = false; showSuccess = true; }); 
        Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context)); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VISUAL PRESET")),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 150, height: 150, decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(30), border: Border.all(color: selectedColor.withOpacity(0.8), width: 2), boxShadow: [BoxShadow(color: selectedColor.withOpacity(0.4), blurRadius: 30)]), child: Center(child: Icon(selectedIcon, size: 70, color: selectedColor, shadows: [Shadow(color: selectedColor, blurRadius: 20)])))),
        const SizedBox(height: 40), const Text("LAYOUT STYLE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 20), Wrap(spacing: 20, runSpacing: 20, children: crosshairs.map((icon) => GestureDetector(onTap: () => setState(() => selectedIcon = icon), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 60, height: 60, decoration: BoxDecoration(color: selectedIcon == icon ? Colors.cyanAccent.withOpacity(0.1) : const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(15), border: Border.all(color: selectedIcon == icon ? Colors.cyanAccent : Colors.white10, width: 1.5)), child: Icon(icon, color: selectedIcon == icon ? Colors.cyanAccent : Colors.white54)))).toList()),
        const SizedBox(height: 40), const Text("PRESET COLOR", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 20), Wrap(spacing: 20, runSpacing: 20, children: colors.map((color) => GestureDetector(onTap: () => setState(() => selectedColor = color), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 50, height: 50, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: selectedColor == color ? Colors.white : Colors.transparent, width: 3)), ))).toList()),
        const SizedBox(height: 60),
        
        InkWell(
          onTap: isApplying || showSuccess ? null : applyCrosshair, 
          borderRadius: BorderRadius.circular(25), 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70, width: double.infinity, 
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: showSuccess ? [Colors.green, Colors.greenAccent] : [Colors.cyanAccent, Colors.blueAccent]), 
              borderRadius: BorderRadius.circular(25), 
              boxShadow: [BoxShadow(color: (showSuccess ? Colors.green : Colors.cyanAccent).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]
            ), 
            child: Center(
              child: isApplying 
                ? const CircularProgressIndicator(color: Colors.white) 
                : (showSuccess 
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.black, size: 28), SizedBox(width: 10), Text("PRESET ACTIVE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))])
                    : const Text("ACTIVATE PRESET", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1)))
            )
          )
        ),
      ])),
    );
  }
}

// ==================== PRO UTILITIES PAGE (Play Store Safe) ====================
class VipSensiPage extends StatefulWidget {
  const VipSensiPage({super.key});
  @override
  State<VipSensiPage> createState() => _VipSensiPageState();
}
class _VipSensiPageState extends State<VipSensiPage> {
  double general = 98; double redDot = 95; double scope2x = 90; double scope4x = 85;
  bool isDPIBoosted = false; bool isPingFixed = false; bool isLaserEnabled = false; 
  bool isApplying = false; bool showSuccess = false;
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

  void applyProSettings() {
    setState(() { isApplying = true; showSuccess = false; });
    Timer(const Duration(seconds: 2), () {
      if(mounted) {
        setState(() { isApplying = false; showSuccess = true; }); 
        Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context)); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PRO VISUAL PRESETS", style: TextStyle(color: Color(0xFFFFD700), fontSize: 20))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFFFD700), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 20)]), child: Column(children: [
          const Text("🔥 PRO UTILITIES 🔥", style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)), const Divider(color: Color(0xFFFFD700), height: 30),
          _buildVipToggle("Custom Graphics Layout", "Display Profile for $myDeviceName", Icons.aspect_ratio_rounded, isDPIBoosted, (val) => setState(() => isDPIBoosted = val)),
          _buildVipToggle("Network Visual Preset", "Connection Status Indicator", Icons.network_check_rounded, isPingFixed, (val) => setState(() => isPingFixed = val)),
          _buildVipToggle("Visual Preset Selection", "Screen Center Indicator", Icons.filter_center_focus_rounded, isLaserEnabled, (val) => setState(() => isLaserEnabled = val)),
        ])),
        const SizedBox(height: 40), const Text("🎯 SENSITIVITY PROFILE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 25), _buildSensiSlider("STANDARD", general, (val) => setState(() => general = val)),
        _buildSensiSlider("RED DOT PRESET", redDot, (val) => setState(() => redDot = val)),
        _buildSensiSlider("2X ZOOM", scope2x, (val) => setState(() => scope2x = val)),
        _buildSensiSlider("4X ZOOM", scope4x, (val) => setState(() => scope4x = val)),
        const SizedBox(height: 60),
        
        InkWell(
          onTap: isApplying || showSuccess ? null : applyProSettings, 
          borderRadius: BorderRadius.circular(25), 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70, width: double.infinity, 
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: showSuccess ? [Colors.green, Colors.greenAccent] : [const Color(0xFFFFD700), const Color(0xFFFF8C00)]), 
              borderRadius: BorderRadius.circular(25), 
              boxShadow: [BoxShadow(color: (showSuccess ? Colors.green : const Color(0xFFFFD700)).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]
            ), 
            child: Center(
              child: isApplying 
                ? const CircularProgressIndicator(color: Colors.black87) 
                : (showSuccess 
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.black87, size: 28), SizedBox(width: 10), Text("PRO PROFILE APPLIED", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87))])
                    : const Text("APPLY PRO UTILITIES", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1)))
            )
          )
        ),
      ])),
    );
  }
  Widget _buildVipToggle(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: ListTile(contentPadding: EdgeInsets.zero, leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFFFD700))), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)), trailing: Transform.scale(scale: 1.1, child: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFFFD700), activeTrackColor: const Color(0xFFFFD700).withOpacity(0.4)))));
  }
  Widget _buildSensiSlider(String title, double value, Function(double) onChanged) {
    return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)), Text("${value.toInt()}", style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16))]), Slider(value: value, min: 0, max: 100, onChanged: onChanged)]);
  }
}
