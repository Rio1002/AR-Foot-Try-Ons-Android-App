import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'model_viewer_page.dart';
import 'onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2D to 3D Viewer',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImagePickerApp extends StatefulWidget {
  const ImagePickerApp({super.key});
  @override
  State<ImagePickerApp> createState() => _ImagePickerAppState();
}

class _ImagePickerAppState extends State<ImagePickerApp> {
  File? _image;
  bool _loading = false;
  int _progress = 0;
  Timer? _timer;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _loading = true;
        _startProgressAnimation();
      });

      await uploadImage(_image!);
    }
  }

  void _startProgressAnimation() {
    _progress = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_progress < 98) {
        setState(() => _progress += 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _stopProgressAnimation() {
    _timer?.cancel();
    setState(() {
      _progress = 100;
      _loading = false;
    });
  }

  Future<void> uploadImage(File imageFile) async {
    final uri = Uri.parse('https://7d8b-34-143-203-246.ngrok-free.app/convert');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);

        if (data['glb_url'] != null) {
          final glbUrl = data['glb_url'];
          _stopProgressAnimation();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModelViewerPage(glbUrl: glbUrl),
            ),
          );
        } else {
          _showError("Unexpected response format: $responseBody");
        }
      } else {
        _showError("Conversion failed [${response.statusCode}]: $responseBody");
      }
    } catch (e) {
      _showError("Upload failed: $e");
    } finally {
      _stopProgressAnimation();
    }
  }

  void _showError(String message) {
    _stopProgressAnimation();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '2D to 3D Viewer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_image != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Icon(Icons.image, size: 100, color: Colors.white70),
                  ),
                const SizedBox(height: 30),
                _loading
                    ? Column(
                  children: [
                    const Text(
                      "Converting...",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$_progress%",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.upload_file,
                      color: Color(0xFF6E48AA)),
                  label: const Text(
                    "Pick Image & Convert",
                    style: TextStyle(
                      color: Color(0xFF6E48AA),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
