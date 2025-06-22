import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Speech to Text App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize speech recognition
  void _initSpeech() async {
    // Request microphone permission
    await Permission.microphone.request();
    
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _isListening = false;
        });
      },
      onStatus: (status) {
        print('Speech recognition status: $status');
        setState(() {
          _isListening = status == 'listening';
        });
      },
    );
    setState(() {});
  }

  /// Start listening for speech
  void _startListening() async {
    if (!_speechEnabled) return;
    
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US', // English - United States
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {
      _isListening = true;
    });
  }

  /// Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Handle speech recognition results
  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.green.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isListening ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_off,
                      color: _isListening ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening 
                          ? 'Listening...' 
                          : (_speechEnabled 
                              ? 'Tap the microphone to speak' 
                              : 'Speech recognition not available'),
                      style: TextStyle(
                        color: _isListening ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Recognized text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recognized text:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_confidenceLevel > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _confidenceLevel > 0.8 
                                  ? Colors.green 
                                  : _confidenceLevel > 0.5 
                                      ? Colors.orange 
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(_confidenceLevel * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _lastWords.isEmpty ? 'No text recognized yet' : _lastWords,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Main microphone button
              GestureDetector(
                onTap: _speechEnabled
                    ? (_isListening ? _stopListening : _startListening)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.red : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : Colors.blue).withOpacity(0.3),
                        spreadRadius: _isListening ? 8 : 4,
                        blurRadius: _isListening ? 15 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Help text
              Text(
                _isListening 
                    ? 'Tap to stop' 
                    : 'Tap to start speaking',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Button to clear text
                  ElevatedButton.icon(
                    onPressed: _lastWords.isNotEmpty ? () {
                      setState(() {
                        _lastWords = '';
                        _confidenceLevel = 0;
                      });
                    } : null,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                  // Button to restart speech
                  ElevatedButton.icon(
                    onPressed: () {
                      _initSpeech();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Additional information
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(height: 8),
                    Text(
                      'Speak clearly and wait for the text to appear.\nAccuracy is shown with the confidence percentage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
