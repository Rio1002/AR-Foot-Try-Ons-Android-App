import 'package:flutter/material.dart';
import 'main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardPageData> pages = [
    _OnboardPageData(
      title: "Welcome to AR Shoe Fitter",
      description: "Easily convert 2D images into 3D models.",
      image: "assets/images/onboard1.png", // add your asset images here
    ),
    _OnboardPageData(
      title: "Upload Your Shoes",
      description: "Choose any image and we’ll handle the rest!",
      image: "assets/images/onboard2.jpg",
    ),
    _OnboardPageData(
      title: "Try in AR!",
      description: "Preview your shoes in AR using the model viewer.",
      image: "assets/images/onboard3.jpg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return _buildPage(
                      context,
                      title: page.title,
                      description: page.description,
                      imageAsset: page.image,
                      isLast: index == pages.length - 1,
                    );
                  },
                ),
              ),
              _buildPageIndicator(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context,
      {required String title,
        required String description,
        required String imageAsset,
        required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imageAsset,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
            ),
            onPressed: () {
              if (isLast) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ImagePickerApp()),
                );
              } else {
                if (_pageController.hasClients) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              }
            },
            child: Text(
              isLast ? "Get Started" : "Next",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 10,
          width: _currentPage == index ? 24 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _OnboardPageData {
  final String title;
  final String description;
  final String image;

  _OnboardPageData({
    required this.title,
    required this.description,
    required this.image,
  });
}
