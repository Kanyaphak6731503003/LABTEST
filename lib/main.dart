import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your project's config values.
  // Replace the dummy strings below with real values from your Firebase console:
  // Firebase Console → Project Settings → Your apps → SDK setup and configuration
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Class',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Class App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login, size: 28),
                  label: const Text('Check-in (Before Class)'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckInScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 28),
                  label: const Text('Finish Class (After Class)'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FinishClassScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Part 2: Check-in Screen ───────────────────────────────────────────────

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // 1. Form key for validation
  final _formKey = GlobalKey<FormState>();

  // 1. TextEditingControllers for the reflection form fields
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  // 1. State variables
  String _gpsLocation = 'Fetching location...'; // stores "lat, lng" string
  bool _isGpsLoading = true;                     // shows GPS loading indicator
  String _qrStatus = 'Not Scanned';             // QR scan status
  bool _qrScanned = false;                       // whether QR mock scan is done
  double _moodScore = 3;                         // default mood score
  bool _isLoading = false;                       // submit loading indicator

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // 2. Auto-fetch GPS as soon as the screen opens
    _fetchGpsLocation();
  }

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  // ── GPS Logic ─────────────────────────────────────────────────────────────

  /// 2. Requests location permission and fetches current GPS coordinates.
  Future<void> _fetchGpsLocation() async {
    setState(() => _isGpsLoading = true);

    try {
      // Check if location services are enabled on the device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _gpsLocation = 'Location services disabled';
          _isGpsLoading = false;
        });
        return;
      }

      // Request permission if not already granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _gpsLocation = 'Location permission denied';
            _isGpsLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsLocation = 'Location permission permanently denied';
          _isGpsLoading = false;
        });
        return;
      }

      // Fetch the actual position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        // Format coordinates to 6 decimal places
        _gpsLocation =
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}';
        _isGpsLoading = false;
      });
    } catch (e) {
      setState(() {
        _gpsLocation = 'Error fetching location: $e';
        _isGpsLoading = false;
      });
    }
  }

  // ── QR Mock Scan ──────────────────────────────────────────────────────────

  /// 3. Simulates a QR scan without a real camera (safe for lab web PCs).
  Future<void> _mockScanQrCode() async {
    // Show scanning state
    setState(() => _qrStatus = 'Scanning...');

    // Simulate a 1-second camera scan delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _qrStatus = 'CLASS-CS101'; // mocked QR result
      _qrScanned = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ QR Scanned: CLASS-CS101'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ── Submit Logic ──────────────────────────────────────────────────────────

  /// 5. Validates form, checks QR, saves to Firestore, then pops back home.
  Future<void> _submitCheckIn() async {
    // 5a. Validate all form fields
    if (!_formKey.currentState!.validate()) return;

    // 5b. Ensure QR has been scanned before submitting
    if (!_qrScanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please scan the QR code first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 5c. Show loading indicator
    setState(() => _isLoading = true);

    try {
      // 5d. Save check-in data to Firestore collection 'checkins'
      await FirebaseFirestore.instance.collection('checkins').add({
        'timestamp': FieldValue.serverTimestamp(), // server-side timestamp
        'gps_location': _gpsLocation,
        'qr_code': _qrStatus,
        'previous_topic': _previousTopicController.text.trim(),
        'expected_topic': _expectedTopicController.text.trim(),
        'mood_score': _moodScore,
      });

      // 5f. Success — show SnackBar and go back to HomeScreen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Check-in submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // 5e. Show error SnackBar if Firestore write fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error submitting check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Always hide loading indicator
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Form fields and slider are disabled until QR is scanned
    final bool formEnabled = _qrScanned;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in (Before Class)',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── GPS Card ─────────────────────────────────────────────────
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('GPS Location',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 2. Show spinner while GPS is loading
                      _isGpsLoading
                          ? const Row(
                              children: [
                                SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                SizedBox(width: 10),
                                Text('Fetching GPS...'),
                              ],
                            )
                          : Text(_gpsLocation,
                              style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      // Allow manual refresh of GPS
                      TextButton.icon(
                        onPressed: _fetchGpsLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Location'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── QR Code Card ─────────────────────────────────────────────
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_scanner,
                              color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('QR Code',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 3. Display current QR scan status
                      Row(
                        children: [
                          Icon(
                            _qrScanned ? Icons.check_circle : Icons.cancel,
                            color: _qrScanned ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text('Status: $_qrStatus',
                              style: TextStyle(
                                  color: _qrScanned
                                      ? Colors.green
                                      : Colors.grey[700])),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 3. Mock scan button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Scan QR Code'),
                          onPressed:
                              _qrScanned ? null : _mockScanQrCode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Reflection Form Card ──────────────────────────────────────
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Reflection',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (!formEnabled)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '🔒 Scan QR code to unlock this section',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // 4. Input 1: Previous topic
                      TextFormField(
                        controller: _previousTopicController,
                        enabled: formEnabled, // locked until QR scanned
                        decoration: const InputDecoration(
                          labelText:
                              'What topic was covered in the previous class?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.history_edu),
                        ),
                        maxLines: 2,
                        // 4. Validation: cannot be empty
                        validator: (value) {
                          if (!formEnabled) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // 4. Input 2: Expected topic
                      TextFormField(
                        controller: _expectedTopicController,
                        enabled: formEnabled,
                        decoration: const InputDecoration(
                          labelText:
                              'What topic do you expect to learn today?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lightbulb_outline),
                        ),
                        maxLines: 2,
                        // 4. Validation: cannot be empty
                        validator: (value) {
                          if (!formEnabled) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 4. Input 3: Mood Slider (1–5)
                      Text(
                        'Mood before class: ${_moodScore.toInt()} / 5',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Slider(
                        value: _moodScore,
                        min: 1,
                        max: 5,
                        divisions: 4, // steps: 1, 2, 3, 4, 5
                        label: _moodScore.toInt().toString(),
                        onChanged: formEnabled
                            ? (value) => setState(() => _moodScore = value)
                            : null, // disabled until QR scanned
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('😞 1', style: TextStyle(fontSize: 12)),
                          Text('😐 3', style: TextStyle(fontSize: 12)),
                          Text('😄 5', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Submit Button ─────────────────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  // 5c. Show spinner inside button while submitting
                  onPressed: _isLoading ? null : _submitCheckIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Submit Check-in'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Part 3: Finish Class Screen ───────────────────────────────────────────

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for reflection fields
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  // State variables
  String _qrStatus = 'Not Scanned';   // QR scan result
  bool _qrScanned = false;             // whether mock QR scan completed
  String _gpsLocation = '';            // stores "lat, lng" string
  bool _isGpsLoading = false;          // shows GPS loading indicator after QR scan
  bool _gpsReady = false;              // GPS fetched and ready
  String _timestamp = '';              // human-readable timestamp shown on UI
  bool _isLoading = false;             // submit loading indicator

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  // ── Action 1: Mock QR Scan ────────────────────────────────────────────────

  /// Simulates a QR scan (no real camera needed — safe for lab web PCs).
  /// After scan succeeds, automatically triggers GPS fetch (Action 2).
  Future<void> _mockScanQrCode() async {
    setState(() => _qrStatus = 'Scanning...');

    // Simulate 1-second camera scan delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _qrStatus = 'CLASS-CS101';
      _qrScanned = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ QR Scanned: CLASS-CS101'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Action 2: Auto-fetch GPS immediately after QR scan
    await _fetchGpsAndTimestamp();
  }

  // ── Action 2: Auto-fetch GPS after QR Scan ────────────────────────────────

  /// Fetches GPS location and records a timestamp after QR scan is complete.
  Future<void> _fetchGpsAndTimestamp() async {
    setState(() {
      _isGpsLoading = true;
      _gpsReady = false;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _gpsLocation = 'Location services disabled';
          _isGpsLoading = false;
        });
        return;
      }

      // Request permission if not already granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _gpsLocation = 'Location permission denied';
            _isGpsLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsLocation = 'Location permission permanently denied';
          _isGpsLoading = false;
        });
        return;
      }

      // Fetch current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Record the current timestamp for display and storage
      final now = DateTime.now();
      final formattedTime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';

      setState(() {
        _gpsLocation =
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}';
        _timestamp = formattedTime;
        _isGpsLoading = false;
        _gpsReady = true; // unlocks the form (Action 3)
      });
    } catch (e) {
      setState(() {
        _gpsLocation = 'Error: $e';
        _isGpsLoading = false;
      });
    }
  }

  // ── Action 4: Submit to Firestore ─────────────────────────────────────────

  /// Validates form and saves checkout data to Firestore collection 'checkouts'.
  Future<void> _submitFinishClass() async {
    // Validate all TextFormFields
    if (!_formKey.currentState!.validate()) return;

    // Show loading spinner on button
    setState(() => _isLoading = true);

    try {
      // Save to Firestore 'checkouts' collection
      await FirebaseFirestore.instance.collection('checkouts').add({
        'timestamp': FieldValue.serverTimestamp(), // server-side timestamp
        'gps_location': _gpsLocation,
        'qr_code': _qrStatus,
        'learned_today': _learnedTodayController.text.trim(),
        'feedback': _feedbackController.text.trim(),
      });

      // Success: show SnackBar and return to HomeScreen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Class finished! Data saved successfully.'),
            backgroundColor: Colors.teal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Error: show error SnackBar but stay on screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Form is only enabled after QR scanned AND GPS is ready
    final bool formEnabled = _qrScanned && _gpsReady;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Class (After Class)',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Action 1: QR Code Card ────────────────────────────────────
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_scanner, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Step 1: Scan QR Code',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _qrScanned ? Icons.check_circle : Icons.cancel,
                            color: _qrScanned ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text('Status: $_qrStatus',
                              style: TextStyle(
                                  color: _qrScanned ? Colors.green : Colors.grey[700])),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Scan QR Code'),
                          // Disabled once already scanned
                          onPressed: _qrScanned ? null : _mockScanQrCode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Action 2: GPS & Timestamp Card (auto-shown after QR) ──────
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Step 2: GPS Location & Time',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!_qrScanned)
                        // Show placeholder before QR scan
                        const Text('⏳ Waiting for QR scan...',
                            style: TextStyle(color: Colors.grey))
                      else if (_isGpsLoading)
                        // Show spinner while fetching GPS
                        const Row(
                          children: [
                            SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 10),
                            Text('Fetching GPS & timestamp...'),
                          ],
                        )
                      else ...[
                        // Display GPS and timestamp once ready
                        Row(
                          children: [
                            const Icon(Icons.my_location,
                                size: 16, color: Colors.teal),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(_gpsLocation,
                                    style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.teal),
                            const SizedBox(width: 6),
                            Text(_timestamp,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Action 3: Reflection Form Card ────────────────────────────
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Step 3: Class Reflection',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (!formEnabled)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '🔒 Complete QR scan & GPS to unlock',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // Input 1: What you learned today
                      TextFormField(
                        controller: _learnedTodayController,
                        enabled: formEnabled,
                        decoration: const InputDecoration(
                          labelText: 'What did you learn today?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (!formEnabled) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Input 2: Feedback about class or instructor
                      TextFormField(
                        controller: _feedbackController,
                        enabled: formEnabled,
                        decoration: const InputDecoration(
                          labelText: 'Feedback about the class or instructor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.feedback_outlined),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (!formEnabled) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Action 4: Submit Button ───────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitFinishClass,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Submit & Finish Class'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
