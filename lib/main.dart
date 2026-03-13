import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAwDRc9VgW2LBosG7xGLOY0Vxu9ceFwfDo',
      appId: '1:338424489993:android:54b219db385b2059deb0d8',
      messagingSenderId: '338424489993',
      projectId: 'smartclass-app-5d17f',
    ),
  );
  runApp(const MyApp());
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Class',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // deep indigo
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _sectionCard({required Widget child, Color? color}) {
  return Container(
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEF8)),
      boxShadow: [
        BoxShadow(
          color: Colors.indigo.withAlpha(18),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: child,
  );
}

Widget _sectionTitle(String title, IconData icon, Color color) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

void _showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            color == Colors.green ? Icons.check_circle : color == Colors.red ? Icons.error : Icons.warning,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}

// ─── Part 1: Home Screen ──────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Smart Class',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Attendance & Reflection System',
                      style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Check-in button
              _HomeActionCard(
                icon: Icons.login_rounded,
                title: 'Check-in',
                subtitle: 'Before class · GPS + QR + Mood',
                gradient: [const Color(0xFF4F46E5), const Color(0xFF818CF8)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckInScreen()),
                ),
              ),
              const SizedBox(height: 16),
              // Finish class button
              _HomeActionCard(
                icon: Icons.logout_rounded,
                title: 'Finish Class',
                subtitle: 'After class · QR + GPS + Reflection',
                gradient: [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FinishClassScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withAlpha(180), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Part 2: Check-in Screen ──────────────────────────────────────────────────

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  String _gpsLocation = 'Fetching location...';
  bool _isGpsLoading = true;
  String _qrStatus = 'Not Scanned';
  bool _qrScanned = false;
  double _moodScore = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGpsLocation();
  }

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() => _isGpsLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _gpsLocation = 'Location services disabled'; _isGpsLoading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _gpsLocation = 'Location permission denied'; _isGpsLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _gpsLocation = 'Location permission permanently denied'; _isGpsLoading = false; });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _gpsLocation = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        _isGpsLoading = false;
      });
    } catch (e) {
      setState(() { _gpsLocation = 'Error fetching location: $e'; _isGpsLoading = false; });
    }
  }

  Future<void> _openQrScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const QRScannerPage()),
    );
    if (!mounted) return;
    setState(() {
      _qrStatus = (result != null && result.isNotEmpty) ? result : 'CLASS-CS101';
      _qrScanned = true;
    });
    _showSnackBar(context, '✅ QR Scanned: $_qrStatus', Colors.green);
  }

  Future<void> _submitCheckIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_qrScanned) {
      _showSnackBar(context, '⚠️ Please scan the QR code first', Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('checkins').add({
        'timestamp': FieldValue.serverTimestamp(),
        'gps_location': _gpsLocation,
        'qr_code': _qrStatus,
        'previous_topic': _previousTopicController.text.trim(),
        'expected_topic': _expectedTopicController.text.trim(),
        'mood_score': _moodScore,
      });
      if (mounted) {
        _showSnackBar(context, '🎉 Check-in submitted successfully!', Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, '❌ Error submitting check-in: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool formEnabled = _qrScanned;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FF),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.primary.withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: cs.primary, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Check-in', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Before Class', style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Step indicator ──────────────────────────────────────────
              _StepIndicator(steps: const ['GPS', 'QR', 'Form'], currentStep: _qrScanned ? 2 : 0),
              const SizedBox(height: 24),

              // ── GPS Card ────────────────────────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('GPS Location', Icons.my_location_rounded, cs.primary),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isGpsLoading ? Colors.grey.shade100 : cs.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isGpsLoading
                          ? const Row(children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('Fetching GPS...', style: TextStyle(color: Colors.grey)),
                            ])
                          : Row(children: [
                              Icon(Icons.location_pin, color: cs.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_gpsLocation, style: const TextStyle(fontSize: 13))),
                            ]),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _fetchGpsLocation,
                      icon: Icon(Icons.refresh_rounded, size: 18, color: cs.primary),
                      label: Text('Refresh Location', style: TextStyle(color: cs.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── QR Card ─────────────────────────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('QR Code', Icons.qr_code_scanner_rounded, const Color(0xFF7C3AED)),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _qrScanned ? Colors.green.withAlpha(20) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _qrScanned ? Colors.green.withAlpha(80) : Colors.transparent,
                        ),
                      ),
                      child: Row(children: [
                        Icon(
                          _qrScanned ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: _qrScanned ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _qrScanned ? _qrStatus : 'Not scanned yet',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _qrScanned ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _qrScanned ? Colors.grey.shade200 : const Color(0xFF7C3AED),
                          foregroundColor: _qrScanned ? Colors.grey : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Icon(_qrScanned ? Icons.check_rounded : Icons.qr_code_scanner_rounded),
                        label: Text(_qrScanned ? 'Scanned ✓' : 'Open Camera & Scan'),
                        onPressed: _qrScanned ? null : _openQrScanner,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Reflection Form Card ─────────────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Reflection', Icons.edit_note_rounded, const Color(0xFF059669)),
                    if (!formEnabled) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withAlpha(80)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('Scan QR code to unlock this section', style: TextStyle(color: Colors.orange, fontSize: 13)),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _previousTopicController,
                      enabled: formEnabled,
                      decoration: const InputDecoration(
                        labelText: 'What topic was covered in the previous class?',
                        prefixIcon: Icon(Icons.history_edu_rounded),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (!formEnabled) return null;
                        if (value == null || value.trim().isEmpty) return 'This field cannot be empty';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _expectedTopicController,
                      enabled: formEnabled,
                      decoration: const InputDecoration(
                        labelText: 'What topic do you expect to learn today?',
                        prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (!formEnabled) return null;
                        if (value == null || value.trim().isEmpty) return 'This field cannot be empty';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mood slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mood before class', style: TextStyle(fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ['', '😡 Very negative', '🙁 Negative', '😐 Neutral', '🙂 Positive', '😄 Very positive'][_moodScore.toInt()],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF4F46E5),
                        inactiveTrackColor: const Color(0xFF4F46E5).withAlpha(40),
                        thumbColor: const Color(0xFF4F46E5),
                        overlayColor: const Color(0xFF4F46E5).withAlpha(30),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _moodScore,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _moodScore.toInt().toString(),
                        onChanged: formEnabled ? (value) => setState(() => _moodScore = value) : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('😡\n1', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        Text('🙁\n2', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        Text('😐\n3', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        Text('🙂\n4', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        Text('😄\n5', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit Button ─────────────────────────────────────────────
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: const Color(0xFF4F46E5).withAlpha(100),
                  ),
                  onPressed: _isLoading ? null : _submitCheckIn,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(_isLoading ? 'Submitting...' : 'Submit Check-in',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Part 3: Finish Class Screen ──────────────────────────────────────────────

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  String _qrStatus = 'Not Scanned';
  bool _qrScanned = false;
  String _gpsLocation = '';
  bool _isGpsLoading = false;
  bool _gpsReady = false;
  String _timestamp = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _openQrScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const QRScannerPage()),
    );
    if (!mounted) return;
    setState(() {
      _qrStatus = (result != null && result.isNotEmpty) ? result : 'CLASS-CS101';
      _qrScanned = true;
    });
    _showSnackBar(context, '✅ QR Scanned: $_qrStatus', Colors.green);
    await _fetchGpsAndTimestamp();
  }

  Future<void> _fetchGpsAndTimestamp() async {
    setState(() { _isGpsLoading = true; _gpsReady = false; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _gpsLocation = 'Location services disabled'; _isGpsLoading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _gpsLocation = 'Location permission denied'; _isGpsLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _gpsLocation = 'Location permission permanently denied'; _isGpsLoading = false; });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final now = DateTime.now();
      final formattedTime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      setState(() {
        _gpsLocation = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        _timestamp = formattedTime;
        _isGpsLoading = false;
        _gpsReady = true;
      });
    } catch (e) {
      setState(() { _gpsLocation = 'Error: $e'; _isGpsLoading = false; });
    }
  }

  Future<void> _submitFinishClass() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('checkouts').add({
        'timestamp': FieldValue.serverTimestamp(),
        'gps_location': _gpsLocation,
        'qr_code': _qrStatus,
        'learned_today': _learnedTodayController.text.trim(),
        'feedback': _feedbackController.text.trim(),
      });
      if (mounted) {
        _showSnackBar(context, '🎉 Class finished! Data saved successfully.', Colors.teal);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, '❌ Error saving data: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool formEnabled = _qrScanned && _gpsReady;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FF),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.primary.withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: cs.primary, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Finish Class', style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF0D9488))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('After Class', style: TextStyle(color: Color(0xFF0D9488), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Step indicator ───────────────────────────────────────────
              _StepIndicator(
                steps: const ['QR', 'GPS', 'Form'],
                currentStep: formEnabled ? 2 : (_qrScanned ? 1 : 0),
              ),
              const SizedBox(height: 24),

              // ── Step 1: QR Card ──────────────────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Step 1: Scan QR Code', Icons.qr_code_scanner_rounded, const Color(0xFF7C3AED)),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _qrScanned ? Colors.green.withAlpha(20) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _qrScanned ? Colors.green.withAlpha(80) : Colors.transparent),
                      ),
                      child: Row(children: [
                        Icon(
                          _qrScanned ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: _qrScanned ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _qrScanned ? _qrStatus : 'Not scanned yet',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _qrScanned ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _qrScanned ? Colors.grey.shade200 : const Color(0xFF7C3AED),
                          foregroundColor: _qrScanned ? Colors.grey : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Icon(_qrScanned ? Icons.check_rounded : Icons.qr_code_scanner_rounded),
                        label: Text(_qrScanned ? 'Scanned ✓' : 'Open Camera & Scan'),
                        onPressed: _qrScanned ? null : _openQrScanner,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Step 2: GPS & Timestamp Card ─────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Step 2: GPS Location & Time', Icons.location_on_rounded, const Color(0xFF059669)),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: !_qrScanned
                            ? Colors.grey.shade100
                            : _isGpsLoading
                                ? Colors.blue.shade50
                                : Colors.green.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: !_qrScanned
                          ? const Row(children: [
                              Icon(Icons.hourglass_empty_rounded, color: Colors.grey, size: 18),
                              SizedBox(width: 10),
                              Text('Waiting for QR scan...', style: TextStyle(color: Colors.grey)),
                            ])
                          : _isGpsLoading
                              ? const Row(children: [
                                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                  SizedBox(width: 12),
                                  Text('Fetching GPS & timestamp...'),
                                ])
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF059669)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(_gpsLocation, style: const TextStyle(fontSize: 13))),
                                    ]),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF059669)),
                                      const SizedBox(width: 8),
                                      Text(_timestamp, style: const TextStyle(fontSize: 13)),
                                    ]),
                                  ],
                                ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Step 3: Reflection Form Card ──────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Step 3: Class Reflection', Icons.edit_note_rounded, const Color(0xFF059669)),
                    if (!formEnabled) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withAlpha(80)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('Complete QR scan & GPS to unlock', style: TextStyle(color: Colors.orange, fontSize: 13)),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _learnedTodayController,
                      enabled: formEnabled,
                      decoration: const InputDecoration(
                        labelText: 'What did you learn today?',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (!formEnabled) return null;
                        if (value == null || value.trim().isEmpty) return 'This field cannot be empty';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _feedbackController,
                      enabled: formEnabled,
                      decoration: const InputDecoration(
                        labelText: 'Feedback about the class or instructor',
                        prefixIcon: Icon(Icons.feedback_outlined),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (!formEnabled) return null;
                        if (value == null || value.trim().isEmpty) return 'This field cannot be empty';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit Button ─────────────────────────────────────────────
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: const Color(0xFF0D9488).withAlpha(100),
                  ),
                  onPressed: _isLoading ? null : _submitFinishClass,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_isLoading ? 'Submitting...' : 'Submit & Finish Class',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step Indicator Widget ────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const _StepIndicator({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIdx < currentStep ? cs.primary : Colors.grey.shade300,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone = stepIdx < currentStep;
        final isActive = stepIdx == currentStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? cs.primary : isActive ? cs.primary.withAlpha(20) : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isActive ? cs.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text(
                        '${stepIdx + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive ? cs.primary : Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIdx],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isDone || isActive ? cs.primary : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── QR Scanner Page ──────────────────────────────────────────────────────────

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  late AnimationController _animController;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _hasScanned = true;
      Navigator.pop(context, barcode!.rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double scanSize = 260;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          CustomPaint(
            painter: _ScanOverlayPainter(scanSize: scanSize),
            child: const SizedBox.expand(),
          ),

          AnimatedBuilder(
            animation: _scanLineAnim,
            builder: (_, __) {
              final screenH = MediaQuery.of(context).size.height;
              final frameTop = screenH / 2 - scanSize / 2 - 40;
              final lineY = frameTop + _scanLineAnim.value * scanSize;
              return Positioned(
                left: (MediaQuery.of(context).size.width - scanSize) / 2 + 8,
                top: lineY,
                child: Container(
                  width: scanSize - 16,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.tealAccent.withAlpha(0),
                      Colors.tealAccent,
                      Colors.tealAccent.withAlpha(0),
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, null),
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.white60, size: 28),
                    const SizedBox(height: 10),
                    const Text('Point your camera at the QR code',
                        style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.3)),
                    const SizedBox(height: 6),
                    const Text('or close to proceed',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay Painter ───────────────────────────────────────────────────────────

class _ScanOverlayPainter extends CustomPainter {
  final double scanSize;
  const _ScanOverlayPainter({required this.scanSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: scanSize,
      height: scanSize,
    );
    final Paint overlayPaint = Paint()..color = Colors.black.withAlpha(160);
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, overlayPaint);

    final Paint bracketPaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double c = 28.0;
    final l = scanRect.left, r = scanRect.right;
    final t = scanRect.top, b = scanRect.bottom;

    canvas.drawLine(Offset(l, t + c), Offset(l, t), bracketPaint);
    canvas.drawLine(Offset(l, t), Offset(l + c, t), bracketPaint);
    canvas.drawLine(Offset(r - c, t), Offset(r, t), bracketPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + c), bracketPaint);
    canvas.drawLine(Offset(l, b - c), Offset(l, b), bracketPaint);
    canvas.drawLine(Offset(l, b), Offset(l + c, b), bracketPaint);
    canvas.drawLine(Offset(r - c, b), Offset(r, b), bracketPaint);
    canvas.drawLine(Offset(r, b - c), Offset(r, b), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
