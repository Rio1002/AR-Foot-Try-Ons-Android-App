import 'dart:async';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerPage extends StatefulWidget {
  final String glbUrl;

  const ModelViewerPage({super.key, required this.glbUrl});

  @override
  State<ModelViewerPage> createState() => _ModelViewerPageState();
}

class _ModelViewerPageState extends State<ModelViewerPage> {
  double verticalAngle = 0;
  Timer? _timer;

  String get cameraOrbit => '0deg ${verticalAngle.toStringAsFixed(1)}deg 2.5m';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        verticalAngle = (verticalAngle + 1) % 360;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B2FF7), Color(0xFF9F44D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Augmented Reality Viewer",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/preview.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                " Click to view your 3D model in AR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            backgroundColor: Colors.deepPurple,
                            title: const Text("AR Model"),
                          ),
                          body: Center(
                            child: ModelViewer(
                              src: widget.glbUrl,
                              alt: "3D Model",
                              disableZoom: false,
                              cameraControls: true,
                              ar: true,
                              autoRotate: false,
                              cameraOrbit: cameraOrbit,
                              interactionPrompt: InteractionPrompt.none,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Augment in AR",
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
