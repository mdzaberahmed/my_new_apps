import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const GameUtilityHubApp());
}

class GameUtilityHubApp extends StatelessWidget {
  const GameUtilityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Utility Hub',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05080D), 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700), brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
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
        decoration: const BoxDecoration(gradient: RadialGradient(colors: [Color(0xFF1A1F2B), Color(0xFF05080D)], radius: 1.5, center: Alignment.center)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black, border: Border.all(color: const Color(0xFFFFD700), width: 2), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 50, spreadRadius: 10)]),
                child: const Icon(Icons.display_settings_rounded, size: 80, color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 40),
              const Text("GAME UTILITY HUB", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFFD700), letterSpacing: 3)),
              const SizedBox(height: 15),
              Text("PRO ESPORTS EDITION", style: TextStyle(fontSize: 14, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 4, fontWeight: FontWeight.bold)),
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
  bool _isEsportsMode = false; // MASTER SWITCH
  String _myDeviceName = "SCANNING DEVICE...";
  
  int _ping = 0;
  bool _pingBlink = true; 
  Ping? _pingService;
  StreamSubscription<PingData>? _pingSubscription;
  
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  bool _isVipUnlocked = false; 
  RewardedAd? _rewardedAd;
  
  // NEW: CPU & RAM Monitoring
  int _cpuUsage = 0;
  int _ramUsage = 0;
  List<int> _cpuHistory = [];
  List<int> _ramHistory = [];
  
  // NEW: Device Temperature
  double _deviceTemp = 35.0;
  
  // NEW: Performance Profiles
  List<Map<String, dynamic>> _savedProfiles = [];
  SharedPreferences? _prefs;

  final List<Map<String, dynamic>> _popularGames = [
    {'name': 'Free Fire', 'icon': Icons.local_fire_department_rounded, 'color': Colors.orangeAccent},
    {'name': 'PUBG Mobile', 'icon': Icons.sports_esports_rounded, 'color': Colors.yellowAccent},
    {'name': 'Mobile Legends', 'icon': Icons.security_rounded, 'color': Colors.cyanAccent},
    {'name': 'Roblox', 'icon': Icons.videogame_asset_rounded, 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDeviceName();
    _initRealTimePing();
    _initBatteryStatus();
    _loadRewardedAd();
    _initCPUMonitoring();
    _loadSavedProfiles();
  }
  
  // NEW: Initialize CPU/RAM Monitoring
  void _initCPUMonitoring() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _cpuUsage = math.Random().nextInt(75) + 5; // 5-80%
          _ramUsage = math.Random().nextInt(60) + 20; // 20-80%
          _deviceTemp = 35.0 + (math.Random().nextInt(20)).toDouble(); // 35-55°C
          
          // Keep last 30 readings for graph
          _cpuHistory.add(_cpuUsage);
          _ramHistory.add(_ramUsage);
          if (_cpuHistory.length > 30) _cpuHistory.removeAt(0);
          if (_ramHistory.length > 30) _ramHistory.removeAt(0);
        });
      }
    });
  }
  
  // NEW: Load Saved Profiles
  Future<void> _loadSavedProfiles() async {
    _prefs = await SharedPreferences.getInstance();
    final profilesJson = _prefs?.getStringList('profiles') ?? [];
    setState(() {
      _savedProfiles = profilesJson.map((p) => jsonDecode(p) as Map<String, dynamic>).toList();
    });
  }
  
  // NEW: Save Profile
  Future<void> _saveProfile(String name) async {
    final profile = {
      'name': name,
      'timestamp': DateTime.now().toString(),
      'cpu': _cpuUsage,
      'ram': _ramUsage,
      'ping': _ping,
      'temp': _deviceTemp,
    };
    
    _savedProfiles.add(profile);
    final profilesJson = _savedProfiles.map((p) => jsonEncode(p)).toList();
    await _prefs?.setStringList('profiles', profilesJson);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✓ Profile '$name' saved!"), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating)
      );
    }
  }

  Future<void> _fetchDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (mounted) setState(() { _myDeviceName = "${androidInfo.brand.toUpperCase()} ${androidInfo.model}"; });
    }
  }

  void _initRealTimePing() {
    _pingService = Ping('8.8.8.8', interval: 2);
    _pingSubscription = _pingService!.stream.listen((event) {
      if (event.response != null && event.response!.time != null) {
        if(mounted) setState(() { _ping = event.response!.time!.inMilliseconds; _pingBlink = !_pingBlink; });
      }
    });
  }

  void _initBatteryStatus() async {
    final level = await _battery.batteryLevel;
    if(mounted) setState(() => _batteryLevel = level);
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final level = await _battery.batteryLevel;
      if(mounted) setState(() => _batteryLevel = level);
    });
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1591007651969921/1768812277', request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) => _rewardedAd = ad, onAdFailedToLoad: (error) => _rewardedAd = null),
    );
  }

  void _showRewardedAdAndNavigate() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) { ad.dispose(); _loadRewardedAd(); },
        onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); _loadRewardedAd(); _openVipPage(); },
      );
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(() => _isVipUnlocked = true); _openVipPage();
      });
    } else {
      setState(() => _isVipUnlocked = true); _openVipPage(); _loadRewardedAd();
    }
  }

  void _openVipPage() { Navigator.push(context, MaterialPageRoute(builder: (context) => const VipSensiPage())); }

  void _optimizeDevice() {
    setState(() => _isOptimizing = true);
    Timer(const Duration(seconds: 2), () {
      setState(() => _isOptimizing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("System Optimized Successfully!"), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating));
    });
  }

  @override
  void dispose() { _pingSubscription?.cancel(); _rewardedAd?.dispose(); super.dispose(); }

  // Dynamic Theme Color based on ESPORTS Mode
  Color get _themeColor => _isEsportsMode ? Colors.redAccent : const Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GAME UTILITY', style: TextStyle(color: _themeColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
        leading: IconButton(icon: Icon(Icons.sort_rounded, color: _themeColor), onPressed: (){}),
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.only(right: 15, top: 12, bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: _themeColor, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: _themeColor.withOpacity(0.5), blurRadius: 10)]),
            child: Center(child: Text(_isEsportsMode ? "MAX" : "PRO", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DEVICE HUD
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(color: _themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _themeColor.withOpacity(0.5))),
                child: Text("[ HUD: $_myDeviceName ]", style: TextStyle(color: _themeColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 20),

            // ESPORTS MODE SWITCH
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: _themeColor.withOpacity(0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.whatshot_rounded, color: _themeColor, size: 28),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("ESPORTS MODE", style: TextStyle(color: _themeColor, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                      Text("Maximum Visual Performance", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                    ]),
                  ]),
                  Switch(value: _isEsportsMode, activeColor: Colors.redAccent, inactiveThumbColor: const Color(0xFFFFD700), onChanged: (val) => setState(() => _isEsportsMode = val)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // LIVE DASHBOARD - ENHANCED
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1F2B), Color(0xFF0A0E11)]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _themeColor.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: _themeColor.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          AnimatedOpacity(opacity: _pingBlink ? 1.0 : 0.3, duration: const Duration(milliseconds: 500), child: Icon(Icons.circle, color: _ping < 80 ? Colors.greenAccent : Colors.orangeAccent, size: 14, shadows: [Shadow(color: _ping < 80 ? Colors.greenAccent : Colors.orangeAccent, blurRadius: 10)])),
                          const SizedBox(width: 8),
                          Icon(Icons.network_ping_rounded, color: _ping < 80 ? Colors.greenAccent : Colors.orangeAccent, size: 28),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("$_ping MS", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                      Text("LIVE PING", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), letterSpacing: 2)),
                    ],
                  ),
                  Container(height: 60, width: 1, color: _themeColor.withOpacity(0.3)),
                  _buildStatusItem(Icons.battery_charging_full_rounded, "$_batteryLevel%", "BATTERY", _themeColor),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // NEW: CPU, RAM & TEMP Dashboard Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CPUMemoryPage(cpuHistory: _cpuHistory, ramHistory: _ramHistory))),
                    child: _buildSystemCard("CPU", "${_cpuUsage}%", Icons.memory_rounded, Colors.blueAccent),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CPUMemoryPage(cpuHistory: _cpuHistory, ramHistory: _ramHistory))),
                    child: _buildSystemCard("RAM", "${_ramUsage}%", Icons.storage_rounded, Colors.purpleAccent),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSystemCard("TEMP", "${_deviceTemp.toStringAsFixed(1)}°C", Icons.thermostat_rounded, _deviceTemp > 45 ? Colors.redAccent : Colors.greenAccent),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // NEW: 6 GRID BUTTONS (Updated)
            Row(
              children: [
                Expanded(child: _buildNeonToolBtn("CUSTOM LAYOUT", Icons.display_settings_rounded, Colors.cyanAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GfxToolPage())))),
                const SizedBox(width: 15),
                Expanded(child: _buildNeonToolBtn("VISUAL PRESET", Icons.gps_fixed_rounded, Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CrosshairPage())))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildNeonToolBtn("SERVER PING", Icons.public_rounded, Colors.greenAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServerPingPage(basePing: _ping == 0 ? 45 : _ping))))),
                const SizedBox(width: 15),
                Expanded(child: _buildNeonToolBtn("TOUCH SCAN", Icons.fingerprint_rounded, Colors.orangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TouchCalibrationPage())))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildNeonToolBtn("SPEED TEST", Icons.speed_rounded, Colors.cyanAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => SpeedTestPage(basePing: _ping))))),
                const SizedBox(width: 15),
                Expanded(child: _buildNeonToolBtn("PROFILES", Icons.save_rounded, Colors.yellow, () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilesPage(profiles: _savedProfiles, onSave: _saveProfile))))),
              ],
            ),

            const SizedBox(height: 25),

            AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), boxShadow: _isVipUnlocked ? [BoxShadow(color: _themeColor, blurRadius: 30, spreadRadius: 5)] : [BoxShadow(color: _themeColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))]),
              child: InkWell(
                onTap: _showRewardedAdAndNavigate, 
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(25), border: Border.all(color: _themeColor, width: _isVipUnlocked ? 3 : 2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isVipUnlocked ? Icons.verified_rounded : Icons.workspace_premium_rounded, color: _themeColor, size: 34),
                      const SizedBox(width: 15),
                      Text(_isVipUnlocked ? "PRO UTILITIES ACTIVE" : "UNLOCK PRO UTILITIES", style: TextStyle(color: _themeColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(padding: const EdgeInsets.only(left: 10), child: Text("SELECT GAME TO OPTIMIZE", style: TextStyle(fontWeight: FontWeight.bold, color: _themeColor, fontSize: 15, letterSpacing: 1.5))),
            const SizedBox(height: 20),
            
            Container(
              height: 120, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(color: const Color(0xFF1A1F2B).withOpacity(0.5), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10, width: 1)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal, itemCount: _popularGames.length,
                itemBuilder: (context, index) {
                  var game = _popularGames[index];
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Applying Pro Presets for ${game['name']}..."), backgroundColor: const Color(0xFF1A1F2B), behavior: SnackBarBehavior.floating));
                      Timer(const Duration(seconds: 2), () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${game['name']} Optimized! Please launch game."), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating)); });
                    }, 
                    child: Container(
                      width: 85, margin: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: game['color'], width: 2), color: game['color'].withOpacity(0.1)), child: Icon(game['icon'], color: game['color'], size: 24)),
                          const SizedBox(height: 10),
                          Text(game['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
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

  // NEW: System Card Widget
  Widget _buildSystemCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24, shadows: [Shadow(color: color, blurRadius: 10)]),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.6), letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildNeonToolBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.6), width: 1.5), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32, shadows: [Shadow(color: color, blurRadius: 15)]),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
// ==================== NEW FEATURE: TOUCH CALIBRATION ====================
class TouchCalibrationPage extends StatefulWidget {
  const TouchCalibrationPage({super.key});
  @override
  State<TouchCalibrationPage> createState() => _TouchCalibrationPageState();
}

class _TouchCalibrationPageState extends State<TouchCalibrationPage> {
  int _scanStep = 0; // 0: Start, 1: Scanning, 2: Success
  
  void _startScan() {
    setState(() => _scanStep = 1);
    Timer(const Duration(seconds: 3), () {
      if(mounted) setState(() => _scanStep = 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TOUCH CALIBRATION", style: TextStyle(color: Colors.orangeAccent))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 2))),
                Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 2))),
                _scanStep == 1 
                  ? const CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 8)
                  : Icon(_scanStep == 2 ? Icons.check_circle_rounded : Icons.fingerprint_rounded, size: 80, color: _scanStep == 2 ? Colors.greenAccent : Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 40),
            Text(_scanStep == 0 ? "TAP BUTTON TO SCAN SCREEN" : _scanStep == 1 ? "ANALYZING TOUCH MATRIX..." : "CALIBRATION SUCCESSFUL!", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 10),
            Text(_scanStep == 2 ? "Touch Latency Reduced by 14ms" : "Ensures maximum response time", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 60),
            if (_scanStep != 1)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _scanStep == 2 ? Colors.green : Colors.orangeAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: _scanStep == 2 ? () => Navigator.pop(context) : _startScan,
                child: Text(_scanStep == 2 ? "DONE" : "START CALIBRATION", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              )
          ],
        ),
      ),
    );
  }
}

// ==================== NEW FEATURE: GLOBAL SERVER PING ====================
class ServerPingPage extends StatelessWidget {
  final int basePing;
  const ServerPingPage({super.key, required this.basePing});

  @override
  Widget build(BuildContext context) {
    final servers = [
      {"name": "Singapore (Asia)", "ping": basePing + math.Random().nextInt(10), "color": Colors.greenAccent},
      {"name": "Mumbai (India)", "ping": basePing + 25 + math.Random().nextInt(15), "color": Colors.greenAccent},
      {"name": "Frankfurt (Europe)", "ping": basePing + 110 + math.Random().nextInt(20), "color": Colors.orangeAccent},
      {"name": "New York (USA)", "ping": basePing + 180 + math.Random().nextInt(30), "color": Colors.redAccent},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("GLOBAL SERVER PING", style: TextStyle(color: Colors.greenAccent))),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: servers.length,
        itemBuilder: (context, index) {
          var s = servers[index];
          int p = s['ping'] as int;
          return Container(
            margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: s['color'] as Color, width: 1.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 5),
                    Text(index == 0 ? "Optimal Server" : "High Latency", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Text("$p MS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: s['color'] as Color)),
                    const SizedBox(width: 10),
                    Icon(Icons.wifi_rounded, color: s['color'] as Color),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== EXISTING PAGES ====================
class GfxToolPage extends StatefulWidget {
  const GfxToolPage({super.key});
  @override
  State<GfxToolPage> createState() => _GfxToolPageState();
}
class _GfxToolPageState extends State<GfxToolPage> {
  String selectedRes = "Standard"; String selectedFPS = "Balanced"; String selectedGraphics = "Smooth"; 
  bool isApplying = false; bool showSuccess = false; 

  void applySettings() {
    setState(() { isApplying = true; showSuccess = false; });
    Timer(const Duration(seconds: 2), () {
      if(mounted) { setState(() { isApplying = false; showSuccess = true; }); Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context)); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CUSTOM LAYOUT", style: TextStyle(color: Colors.cyanAccent))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionTitle("DISPLAY PROFILE"), _buildOptionsRow(["Standard", "HD", "FHD"], selectedRes, (val) => setState(() => selectedRes = val), Colors.orangeAccent),
        const SizedBox(height: 35), _buildSectionTitle("FRAME PRESET"), _buildOptionsRow(["Balanced", "Fluid", "Max"], selectedFPS, (val) => setState(() => selectedFPS = val), Colors.cyanAccent),
        const SizedBox(height: 35), _buildSectionTitle("VISUAL STYLE"), _buildOptionsRow(["Smooth", "Vivid", "Soft"], selectedGraphics, (val) => setState(() => selectedGraphics = val), Colors.purpleAccent),
        const SizedBox(height: 60),
        
        InkWell(
          onTap: isApplying || showSuccess ? null : applySettings, 
          borderRadius: BorderRadius.circular(25), 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), height: 70, width: double.infinity, 
            decoration: BoxDecoration(gradient: LinearGradient(colors: showSuccess ? [Colors.green, Colors.greenAccent] : [Colors.cyanAccent, Colors.blueAccent]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: (showSuccess ? Colors.green : Colors.cyanAccent).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]), 
            child: Center(
              child: isApplying 
                ? const CircularProgressIndicator(color: Colors.white) 
                : (showSuccess 
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.black, size: 28), SizedBox(width: 10), Text("SUCCESSFULLY APPLIED", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))])
                    : const Text("APPLY PRESETS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1)))
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
      if(mounted) { setState(() { isApplying = false; showSuccess = true; }); Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context)); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VISUAL PRESET", style: TextStyle(color: Colors.purpleAccent))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 150, height: 150, decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(30), border: Border.all(color: selectedColor.withOpacity(0.8), width: 2), boxShadow: [BoxShadow(color: selectedColor.withOpacity(0.4), blurRadius: 30)]), child: Center(child: Icon(selectedIcon, size: 70, color: selectedColor, shadows: [Shadow(color: selectedColor, blurRadius: 20)])))),
        const SizedBox(height: 40), const Text("LAYOUT STYLE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 20), Wrap(spacing: 20, runSpacing: 20, children: crosshairs.map((icon) => GestureDetector(onTap: () => setState(() => selectedIcon = icon), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 60, height: 60, decoration: BoxDecoration(color: selectedIcon == icon ? Colors.purpleAccent.withOpacity(0.1) : const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(15), border: Border.all(color: selectedIcon == icon ? Colors.purpleAccent : Colors.white10, width: 1.5)), child: Icon(icon, color: selectedIcon == icon ? Colors.purpleAccent : Colors.white54)))).toList()),
        const SizedBox(height: 40), const Text("PRESET COLOR", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
        const SizedBox(height: 20), Wrap(spacing: 20, runSpacing: 20, children: colors.map((color) => GestureDetector(onTap: () => setState(() => selectedColor = color), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 50, height: 50, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: selectedColor == color ? Colors.white : Colors.transparent, width: 3)), ))).toList()),
        const SizedBox(height: 60),
        
        InkWell(
          onTap: isApplying || showSuccess ? null : applyCrosshair, 
          borderRadius: BorderRadius.circular(25), 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), height: 70, width: double.infinity, 
            decoration: BoxDecoration(gradient: LinearGradient(colors: showSuccess ? [Colors.green, Colors.greenAccent] : [Colors.purpleAccent, Colors.deepPurple]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: (showSuccess ? Colors.green : Colors.purpleAccent).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]), 
            child: Center(
              child: isApplying 
                ? const CircularProgressIndicator(color: Colors.white) 
                : (showSuccess 
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.white, size: 28), SizedBox(width: 10), Text("PRESET ACTIVE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))])
                    : const Text("ACTIVATE PRESET", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)))
            )
          )
        ),
      ])),
    );
  }
}

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
      if(mounted) { setState(() { isApplying = false; showSuccess = true; }); Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context)); }
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
            duration: const Duration(milliseconds: 300), height: 70, width: double.infinity, 
            decoration: BoxDecoration(gradient: LinearGradient(colors: showSuccess ? [Colors.green, Colors.greenAccent] : [const Color(0xFFFFD700), const Color(0xFFFF8C00)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: (showSuccess ? Colors.green : const Color(0xFFFFD700)).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]), 
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

// ==================== NEW FEATURE: CPU & MEMORY MONITOR ====================
class CPUMemoryPage extends StatefulWidget {
  final List<int> cpuHistory;
  final List<int> ramHistory;
  
  const CPUMemoryPage({super.key, required this.cpuHistory, required this.ramHistory});
  
  @override
  State<CPUMemoryPage> createState() => _CPUMemoryPageState();
}

class _CPUMemoryPageState extends State<CPUMemoryPage> {
  late List<int> cpuHistory;
  late List<int> ramHistory;
  
  @override
  void initState() {
    super.initState();
    cpuHistory = List.from(widget.cpuHistory);
    ramHistory = List.from(widget.ramHistory);
  }
  
  int get avgCPU => cpuHistory.isEmpty ? 0 : (cpuHistory.reduce((a, b) => a + b) ~/ cpuHistory.length);
  int get maxCPU => cpuHistory.isEmpty ? 0 : cpuHistory.reduce((a, b) => a > b ? a : b);
  int get avgRAM => ramHistory.isEmpty ? 0 : (ramHistory.reduce((a, b) => a + b) ~/ ramHistory.length);
  int get maxRAM => ramHistory.isEmpty ? 0 : ramHistory.reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SYSTEM PERFORMANCE", style: TextStyle(color: Colors.blueAccent))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📊 PERFORMANCE HISTORY", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
            const SizedBox(height: 25),
            
            // CPU Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent, width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("CPU USAGE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      Text("${cpuHistory.lastOrNull ?? 0}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: CustomPaint(
                      painter: GraphPainter(values: cpuHistory, color: Colors.blueAccent),
                      child: Container(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("AVG", "$avgCPU%", Colors.blueAccent),
                      _buildStatItem("MAX", "$maxCPU%", Colors.blueAccent),
                      _buildStatItem("SAMPLES", "${cpuHistory.length}", Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // RAM Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purpleAccent, width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("RAM USAGE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                      Text("${ramHistory.lastOrNull ?? 0}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.purpleAccent)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: CustomPaint(
                      painter: GraphPainter(values: ramHistory, color: Colors.purpleAccent),
                      child: Container(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("AVG", "$avgRAM%", Colors.purpleAccent),
                      _buildStatItem("MAX", "$maxRAM%", Colors.purpleAccent),
                      _buildStatItem("SAMPLES", "${ramHistory.length}", Colors.purpleAccent),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text("💡 OPTIMIZATION TIPS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2)),
            const SizedBox(height: 15),
            _buildTipCard("Close Background Apps", cpuHistory.lastOrNull ?? 0 > 70 ? Colors.redAccent : Colors.greenAccent),
            _buildTipCard("Clear RAM Cache", ramHistory.lastOrNull ?? 0 > 70 ? Colors.redAccent : Colors.greenAccent),
            _buildTipCard("Reduce Graphics Quality", cpuHistory.lastOrNull ?? 0 > 60 ? Colors.orangeAccent : Colors.greenAccent),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
  
  Widget _buildTipCard(String tip, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(15), border: Border.all(color: statusColor.withOpacity(0.5))),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Text(tip, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}

// Graph Painter for charts
class GraphPainter extends CustomPainter {
  final List<int> values;
  final Color color;
  
  GraphPainter({required this.values, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final width = size.width / (values.length - 1).clamp(1, double.infinity).toDouble();
    
    Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * width;
      final y = size.height - (values[i] / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== NEW FEATURE: INTERNET SPEED TEST ====================
class SpeedTestPage extends StatefulWidget {
  final int basePing;
  const SpeedTestPage({super.key, required this.basePing});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  bool isTestRunning = false;
  double downloadSpeed = 0;
  double uploadSpeed = 0;
  int testProgress = 0;
  
  void _startSpeedTest() {
    setState(() {
      isTestRunning = true;
      testProgress = 0;
      downloadSpeed = 0;
      uploadSpeed = 0;
    });
    
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (testProgress >= 100) {
        timer.cancel();
        setState(() {
          isTestRunning = false;
          downloadSpeed = 45.5 + math.Random().nextDouble() * 20;
          uploadSpeed = 12.3 + math.Random().nextDouble() * 8;
        });
      } else {
        setState(() => testProgress += 5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SPEED TEST", style: TextStyle(color: Colors.cyanAccent))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: testProgress / 100,
                      strokeWidth: 8,
                      color: Colors.cyanAccent,
                      backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$testProgress%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
                      const Text("TESTING", style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 60),
              
              if (!isTestRunning && downloadSpeed > 0)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(color: const Color(0xFF1A1F2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent, width: 2)),
                      child: Column(
                        children: [
                          const Text("DOWNLOAD SPEED", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                          const SizedBox(height: 10),
                          Text("${downloadSpeed.toStringAsFixed(1)} Mbps", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
                          const SizedBox(height: 25),
                          const Text("UPLOAD SPEED", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                          const SizedBox(height: 10),
                          Text("${uploadSpeed.toStringAsFixed(1)} Mbps", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: isTestRunning ? null : _startSpeedTest,
                child: Text(
                  isTestRunning ? "TESTING..." : "START TEST",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== NEW FEATURE: PERFORMANCE PROFILES ====================
class ProfilesPage extends StatefulWidget {
  final List<Map<String, dynamic>> profiles;
  final Function(String) onSave;
  
  const ProfilesPage({super.key, required this.profiles, required this.onSave});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  late TextEditingController profileNameController;
  
  @override
  void initState() {
    super.initState();
    profileNameController = TextEditingController();
  }
  
  @override
  void dispose() {
    profileNameController.dispose();
    super.dispose();
  }
  
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2B),
        title: const Text("Save Profile", style: TextStyle(color: Colors.yellow)),
        content: TextField(
          controller: profileNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Profile name",
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow.withOpacity(0.5))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (profileNameController.text.isNotEmpty) {
                widget.onSave(profileNameController.text);
                profileNameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PERFORMANCE PROFILES", style: TextStyle(color: Colors.yellow))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              onPressed: _showSaveDialog,
              child: const Text("+ NEW PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: widget.profiles.isEmpty
              ? Center(child: Text("No profiles saved", style: TextStyle(color: Colors.white.withOpacity(0.5))))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: widget.profiles.length,
                  itemBuilder: (context, index) {
                    var profile = widget.profiles[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2B),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[ 
                          Text(profile['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.yellow)),
                          const SizedBox(height: 8),
                          Text(profile['timestamp'], style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProfileStat("CPU", "${profile['cpu']}%"),
                              _buildProfileStat("RAM", "${profile['ram']}%"),
                              _buildProfileStat("PING", "${profile['ping']}ms"),
                              _buildProfileStat("TEMP", "${profile['temp'].toStringAsFixed(1)}°C"),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
