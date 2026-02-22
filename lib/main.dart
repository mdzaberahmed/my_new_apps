            import 'dart:async';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  double _ramValue = 0.36;
  bool _isBoosting = false;
  late AnimationController _spinController;
  int _ping = 56;
  int _temp = 39;
  Timer? _statsTimer;

  List<AppInfo> _installedApps = [];
  bool _isLoadingApps = true;

  // শুধুমাত্র ভিআইপি বাটনের জন্য Rewarded Ad
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if(mounted) setState(() { _ping = 50 + math.Random().nextInt(10); _temp = 38 + math.Random().nextInt(4); });
    });
    _loadApps();
    _loadRewardedAd(); // অ্যাপ ওপেন হলেই ভিডিও অ্যাড লোড হয়ে থাকবে
  }

  // আপনার আসল Rewarded ID দিয়ে অ্যাড লোড করা হচ্ছে
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1591007651969921/1768812277', // Your Real Rewarded ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  // ভিআইপি বাটনে ক্লিক করলে এই ফাংশনটি কাজ করবে
  void _showRewardedAdAndNavigate() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // পরের বারের জন্য আবার অ্যাড লোড করবে
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage()));
        },
      );

      // ভিডিও অ্যাড দেখা শেষ হলে ইউজারের পুরস্কার (VIP পেজে যাওয়া)
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage()));
      });
    } else {
      // যদি নেট প্রবলেমের কারণে অ্যাড লোড না হয়, তবে এমনিতেই পেজে ঢুকতে দেবে
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

  @override
  void dispose() {
    _spinController.dispose();
    _statsTimer?.cancel();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FF GAMING HUB'), leading: const Icon(Icons.menu)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildRamMonitorCard(),
            const SizedBox(height: 15),
            _buildStatsRow(),
            const SizedBox(height: 15),
            _buildToolsRow(),
            const SizedBox(height: 15),
            _buildVipSensiButton(),
            const SizedBox(height: 25),
            _buildGameLauncher(),
          ],
        ),
      ),
    );
  }

  Widget _buildRamMonitorCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF1A221A), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.greenAccent.withOpacity(0.3))),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(turns: _spinController, child: SizedBox(width: 160, height: 160, child: CircularProgressIndicator(value: _isBoosting ? null : _ramValue, strokeWidth: 12, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(_isBoosting ? Colors.orangeAccent : Colors.greenAccent)))),
              Text("${(_ramValue * 100).toInt()}%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              setState(() => _isBoosting = true);
              _spinController.repeat();
              Timer(const Duration(seconds: 3), () {
                _spinController.stop();
                setState(() { _isBoosting = false; _ramValue = 0.30; });
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, minimumSize: const Size(double.infinity, 50)),
            child: const Text("BOOST RAM NOW", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatItem(Icons.network_ping, "$_ping ms", Colors.blueAccent)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatItem(Icons.thermostat, "$_temp°C", Colors.redAccent)),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF161B16), borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10), Text(value)]));
  }

  Widget _buildToolsRow() {
    return Row(
      children: [
        Expanded(child: _buildToolBtn("GFX TOOL", Icons.settings_suggest, Colors.orangeAccent)),
        const SizedBox(width: 15),
        Expanded(child: _buildToolBtn("CROSSHAIR", Icons.my_location, Colors.cyanAccent)),
      ],
    );
  }

  Widget _buildToolBtn(String title, IconData icon, Color color) {
    return Container(
      height: 100, decoration: BoxDecoration(color: const Color(0xFF1A221A), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: InkWell(
        onTap: () {
          if (title == "GFX TOOL") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const GfxToolPage()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CrosshairPage()));
          }
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 30), Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildVipSensiButton() {
    return InkWell(
      onTap: _showRewardedAdAndNavigate, // <--- ভিডিও অ্যাড ফাংশন
      child: Container(
        height: 70, width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFF1A221A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purpleAccent.withOpacity(0.3))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.radar, color: Colors.purpleAccent), SizedBox(width: 10), Text("🔥 VIP SENSI (HEADSHOT)", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildGameLauncher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🎮 MY INSTALLED GAMES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 15),
        SizedBox(
          height: 90,
          child: _isLoadingApps 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _installedApps.length,
                  itemBuilder: (context, index) {
                    AppInfo app = _installedApps[index];
                    return GestureDetector(
                      onTap: () => InstalledApps.startApp(app.packageName!), // <--- গেম সরাসরি ওপেন হবে, কোনো অ্যাড নেই
                      child: Container(
                        width: 75, margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            if (app.icon != null) Image.memory(app.icon!, width: 50, height: 50),
                            const SizedBox(height: 5),
                            Text(app.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                          ],
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
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: selectedIcon == icon ? Colors.cyanAccent.withOpacity(0.2) : const Color(0xFF1A221A), borderRadius: BorderRadius.circular(15), border: Border.all(color: selectedIcon == icon ? Colors.cyanAccent : Colors.white10)),
                  child: Icon(icon, color: selectedIcon == icon ? Colors.cyanAccent : Colors.white54),
                ),
              )).toList(),
            ),
            const SizedBox(height: 30),
            const Text("SELECT COLOR", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 15, runSpacing: 15,
              children: colors.map((color) => GestureDetector(
                onTap: () => setState(() => selectedColor = color),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: selectedColor == color ? Colors.white : Colors.transparent, width: 3)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 50),
            InkWell(
              onTap: isApplying ? null : activateCrosshair,
              child: Container(
                height: 60, width: double.infinity,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]), borderRadius: BorderRadius.circular(15)),
                child: Center(child: isApplying ? const CircularProgressIndicator(color: Colors.white) : const Text("ACTIVATE CROSSHAIR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. VIP SENSI PAGE
// ==========================================
class VipSensiPage extends StatefulWidget {
  const VipSensiPage({super.key});
  @override
  State<VipSensiPage> createState() => _VipSensiPageState();
}

class _VipSensiPageState extends State<VipSensiPage> {
  double general = 98;
  double redDot = 95;
  double scope2x = 90;
  double scope4x = 85;
  bool isApplying = false;

  void applySensi() {
    setState(() => isApplying = true);
    Timer(const Duration(seconds: 2), () {
      setState(() => isApplying = false);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("VIP Headshot Sensi Applied Successfully!"), backgroundColor: Colors.purpleAccent));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VIP HEADSHOT SENSI", style: TextStyle(color: Colors.purpleAccent))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.purpleAccent.withOpacity(0.3))),
              child: Row(children: const [Icon(Icons.warning_amber_rounded, color: Colors.purpleAccent), SizedBox(width: 10), Expanded(child: Text("These sensitivity settings are optimized for maximum headshot accuracy.", style: TextStyle(color: Colors.white70, fontSize: 13)))]),
            ),
            const SizedBox(height: 30),
            _buildSensiSlider("GENERAL", general, (val) => setState(() => general = val)),
            const SizedBox(height: 20),
            _buildSensiSlider("RED DOT", redDot, (val) => setState(() => redDot = val)),
            const SizedBox(height: 20),
            _buildSensiSlider("2X SCOPE", scope2x, (val) => setState(() => scope2x = val)),
            const SizedBox(height: 20),
            _buildSensiSlider("4X SCOPE", scope4x, (val) => setState(() => scope4x = val)),
            const SizedBox(height: 50),
            InkWell(
              onTap: isApplying ? null : applySensi,
              child: Container(
                height: 60, width: double.infinity,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurpleAccent]), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 10)]),
                child: Center(child: isApplying ? const CircularProgressIndicator(color: Colors.white) : const Text("APPLY VIP SENSI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSensiSlider(String title, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)), Text("${value.toInt()}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent))]),
        Slider(value: value, min: 0, max: 100, activeColor: Colors.purpleAccent, inactiveColor: Colors.white10, onChanged: onChanged),
      ],
    );
  }
}
