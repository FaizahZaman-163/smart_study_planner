import 'package:flutter/material.dart';
import 'dart:async';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  static const int focusTime = 25 * 60;
  static const int breakTime = 5 * 60;

  int remainingSeconds = focusTime;
  bool isRunning = false;
  bool isFocusMode = true;
  Timer? timer;

  String get timerText {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();
        _switchMode();
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isFocusMode = true;
      remainingSeconds = focusTime;
    });
  }

  void takeBreak() {
    if (!isFocusMode) return;
    timer?.cancel();
    setState(() {
      isRunning = false;
      isFocusMode = false;
      remainingSeconds = breakTime;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Break time!"), backgroundColor: Colors.green),
    );
  }

  void _switchMode() {
    setState(() {
      isFocusMode = !isFocusMode;
      remainingSeconds = isFocusMode ? focusTime : breakTime;
      isRunning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFocusMode ? "Back to focus!" : "Time for a break!"),
        backgroundColor: isFocusMode ? Colors.blue : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isFocusMode ? "Focus Session" : "Break Time"),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isFocusMode
                ? [Colors.red.shade700, Colors.red.shade900]
                : [Colors.green.shade700, Colors.green.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isFocusMode ? "Focus Mode" : "Break Mode",
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              Text(
                timerText,
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? pauseTimer : startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: const CircleBorder(),
                    ),
                    child: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: isFocusMode ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: resetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.refresh, size: 35, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (isFocusMode)
                OutlinedButton(
                  onPressed: takeBreak,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Take a Break Now",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}