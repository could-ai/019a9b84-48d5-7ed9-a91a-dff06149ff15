import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/tingwu_service.dart';
import '../services/purchase_service.dart';
import '../services/database_service.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TingwuService _tingwuService = TingwuService();
  final PurchaseService _purchaseService = PurchaseService();
  final DatabaseService _dbService = DatabaseService();

  String _currentTranscription = "Press mic to start...";
  String _currentTranslation = "";
  int _remainingSeconds = 3600;
  bool _isPremium = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _purchaseService.init();
    
    // Listen to timer updates
    _purchaseService.remainingTimeStream.listen((seconds) {
      if (mounted) {
        setState(() {
          _remainingSeconds = seconds;
          _isPremium = _purchaseService.isPremium;
        });
        
        // Auto-stop if time runs out
        if (seconds <= 0 && !_isPremium && _isListening) {
          _stopRecording();
          _showPaywall();
        }
      }
    });

    // Listen to transcription updates
    _tingwuService.transcriptionStream.listen((text) {
      if (mounted) {
        setState(() {
          _currentTranscription = text;
        });
      }
    });

    // Listen to translation updates
    _tingwuService.translationStream.listen((text) {
      if (mounted) {
        setState(() {
          _currentTranslation = text;
        });
        // Save to Supabase when a full sentence is translated
        _dbService.saveTranslation(
          sourceText: _currentTranscription,
          translatedText: text,
        );
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_isListening) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    // Check access first
    if (!_purchaseService.hasAccess()) {
      _showPaywall();
      return;
    }

    // Request permissions (Mocked for web/simulator safety, but good practice)
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      // On some platforms request() might be needed. 
      // For this demo we proceed assuming permission or mock.
      // await Permission.microphone.request();
    }

    await _tingwuService.startRecording();
    _purchaseService.startTracking();
    
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopRecording() async {
    await _tingwuService.stopRecording();
    _purchaseService.stopTracking();
    
    setState(() {
      _isListening = false;
    });
  }

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              "Free Trial Ended",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You have used your 1 hour of free translation. Please upgrade to continue.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                bool success = await _purchaseService.buyPremium();
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Premium Activated!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Unlock Unlimited Access (\$9.99)"),
            ),
            TextButton(
              onPressed: () async {
                // Dev backdoor to reset
                await _purchaseService.resetUsage();
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Reset Trial (Dev Only)"),
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (_isPremium) return "Unlimited";
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _tingwuService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Translator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Timer / Status Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: _isListening ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer, color: _remainingSeconds < 300 ? Colors.red : Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      "Remaining: ${_formatTime(_remainingSeconds)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_isPremium)
                  const Chip(label: Text("Premium"), backgroundColor: Colors.amber)
              ],
            ),
          ),
          
          // Translation Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "English (Source)",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentTranscription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const Divider(height: 48),
                  Text(
                    "Chinese (Target)",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentTranslation.isEmpty ? "..." : _currentTranslation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.only(bottom: 48, top: 24),
            child: FloatingActionButton.large(
              onPressed: _toggleRecording,
              backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
              child: Icon(_isListening ? Icons.stop : Icons.mic, size: 48, color: Colors.white),
            ),
          ),
          if (_isListening)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text("Listening...", style: TextStyle(color: Colors.red)),
            )
        ],
      ),
    );
  }
}
