import 'dart:async';
import 'package:flutter/foundation.dart';

/// This service simulates the Alibaba Cloud Tingwu (Tongyi Tingwu) SDK integration.
/// 
/// ⚠️ PUBLISHING NOTICE ⚠️
/// This is a MOCK implementation. For a production app, you must:
/// 1. Download the real Alibaba Cloud NUI SDK (Android/iOS).
/// 2. Implement MethodChannels in android/ and ios/ folders.
/// 3. Replace this mock logic with actual calls to the native SDK.
class TingwuService {
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  final StreamController<String> _translationController = StreamController<String>.broadcast();
  Timer? _mockTimer;
  bool _isListening = false;

  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get translationStream => _translationController.stream;
  bool get isListening => _isListening;

  // Mock data for demonstration
  final List<String> _englishPhrases = [
    "Hello, how are you today?",
    "I am looking for a good restaurant.",
    "The weather is very nice.",
    "Can you help me with this project?",
    "I need to go to the airport.",
    "This is a real-time translation demo.",
    "Flutter is an amazing framework.",
    "Alibaba Cloud provides powerful AI services."
  ];

  final List<String> _chinesePhrases = [
    "你好，今天过得怎么样？",
    "我正在找一家好餐馆。",
    "天气非常好。",
    "你能帮我做这个项目吗？",
    "我需要去机场。",
    "这是一个实时翻译演示。",
    "Flutter 是一个很棒的框架。",
    "阿里云提供强大的 AI 服务。"
  ];

  Future<void> startRecording() async {
    if (_isListening) return;
    _isListening = true;
    
    // TODO: INTEGRATION POINT
    // In the real app, call the native method channel here:
    // await MethodChannel('com.example.tingwu').invokeMethod('startRecording');

    debugPrint("Tingwu Service: Started Recording (Mock Mode)");

    // Simulate receiving data
    int index = 0;
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (index < _englishPhrases.length) {
        _transcriptionController.add(_englishPhrases[index]);
        // Simulate a slight delay for translation
        Future.delayed(const Duration(milliseconds: 500), () {
          _translationController.add(_chinesePhrases[index]);
        });
        index++;
      } else {
        index = 0; // Loop
      }
    });
  }

  Future<void> stopRecording() async {
    if (!_isListening) return;
    _isListening = false;
    _mockTimer?.cancel();
    
    // TODO: INTEGRATION POINT
    // await MethodChannel('com.example.tingwu').invokeMethod('stopRecording');
    
    debugPrint("Tingwu Service: Stopped Recording");
  }

  void dispose() {
    _transcriptionController.close();
    _translationController.close();
    _mockTimer?.cancel();
  }
}
