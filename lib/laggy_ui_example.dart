import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Required for compute() function
import 'package:flutter/material.dart';
import 'package:isolate_learning/functions.dart'; // Contains our heavy computation function

/// A widget that demonstrates the importance of using Isolates for heavy computations
/// by showing the difference between running tasks on the main thread vs background thread
class LaggyUIExample extends StatefulWidget {
  const LaggyUIExample({super.key});

  @override
  State<LaggyUIExample> createState() => _LaggyUIExampleState();
}

class _LaggyUIExampleState extends State<LaggyUIExample>
    with SingleTickerProviderStateMixin {
  // State variables
  Color _bgColor = Colors.blue; // Background color
  int _result = 0; // Result of heavy computation
  double _rotation = 0.0; // Rotation angle for animation
  bool _isComputing = false; // Flag to track computation status

  @override
  void initState() {
    super.initState();
    // Create a timer for continuous rotation animation
    // Updates every 50ms for smooth animation
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        _rotation += 0.1; // Increment rotation angle
      });
    });

    // Create a timer for background color changes
    // Updates every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _changeColor();
      });
    });
  }

  /// Generates a random background color
  void _changeColor() {
    setState(() {
      _bgColor = Color.fromRGBO(
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
        1,
      );
    });
  }

  /// Runs heavy computation on the main thread
  /// WARNING: This will block the UI and freeze animations
  int _runHeavyTask() {
    setState(() {
      // This runs synchronously on the main thread
      // It will block all UI updates until completion
      _result = findLargePrime(20000);
    });
    return _result;
  }

  /// Runs heavy computation in a separate isolate
  /// RECOMMENDED: This keeps the UI responsive
  void _runHeavyTaskWithIsolate() async {
    // Show loading indicator
    setState(() => _isComputing = true);

    // compute() is a Flutter helper that:
    // 1. Creates a new isolate
    // 2. Runs the specified function (findLargePrime) in that isolate
    // 3. Passes the argument (20000) to the function
    // 4. Returns the result back to the main isolate
    // 5. Automatically disposes the isolate when done
    final result = await compute(findLargePrime, 20000);

    // Update UI with result
    setState(() {
      _result = result;
      _isComputing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: _bgColor,
        child: Column(
          children: [
            // Spinning rectangle demonstration
            SizedBox(height: 100),
            Center(
              child: Transform.rotate(
                angle: _rotation,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Color.fromRGBO(
                      Random().nextInt(256),
                      Random().nextInt(256),
                      Random().nextInt(256),
                      1,
                    ),
                  ),
                ),
              ),
            ),
            // UI Controls
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Button to run computation on main thread
                    ElevatedButton(
                      onPressed: _runHeavyTask,
                      child: Text("Run Heavy Computation"),
                    ),
                    SizedBox(height: 20),
                    // Button to run computation in isolate
                    ElevatedButton(
                      onPressed: _runHeavyTaskWithIsolate,
                      child: _isComputing
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : Text("Run Heavy Computation With Isolate"),
                    ),
                    SizedBox(height: 20),
                    // Display computation result
                    Text(
                      "Result: $_result",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
