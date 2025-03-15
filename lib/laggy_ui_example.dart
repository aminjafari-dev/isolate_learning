import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolate_learning/functions.dart';

class LaggyUIExample extends StatefulWidget {
  const LaggyUIExample({super.key});

  @override
  State<LaggyUIExample> createState() => _LaggyUIExampleState();
}

class _LaggyUIExampleState extends State<LaggyUIExample>
    with SingleTickerProviderStateMixin {
  Color _bgColor = Colors.blue;
  int _result = 0;
  double _rotation = 0.0;

  bool _isComputing = false;

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget initializes
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        _rotation += 0.1; // Increment rotation angle
      });
    });

    // Start the timer when the widget initializes
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _changeColor();
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    super.dispose();
  }

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

  int _runHeavyTask() {
    setState(() {
      _result = findLargePrime(20000); // This will block the UI
    });
    return _result;
  }

  void _runHeavyTaskWithIsolate() async {
    setState(() => _isComputing = true);

    final result =
        await compute(findLargePrime, 20000); // Runs in a background isolate

    setState(() {
      _result = result;
      _isComputing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500), // Update duration to match timer
        color: _bgColor,
        child: Column(
          children: [
            SizedBox(height: 100), // Add some padding from top
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
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _runHeavyTask,
                      child: Text("Run Heavy Computation"),
                    ),
                    SizedBox(height: 20),
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
