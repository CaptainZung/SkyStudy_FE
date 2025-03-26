import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Dữ liệu cho các trang onboarding
  final List<Map<String, dynamic>> onboardingData = [
    {
      'background': 'assets/images/onboarding.png',
      'text': 'Chào mừng đến với SkyStudy!\n Hãy lướt qua phải để biết thêm ',
    },
    {
      'background': 'assets/images/onboarding_1.png',
      'text': 'Nhìn, nghe, chạm tay - học hay, nhớ lâu, giỏi ngay mỗi ngày!',
    },
    {
      'background': 'assets/images/onboarding_2.png',
      'text': 'Nhún, nhảy, chạm tay – học hay, nhớ lâu, giỏi ngay mỗi ngày!',
    },
    {
      'background': 'assets/images/onboarding_3.png',
      'text': 'XIN CHÀO!\nHọc cùng AI, nhanh tay, nhanh trí, tương lai rộng mở!\n\nVà còn nhiều điều thú vị đang chờ bạn phía sau nhé!',
    },
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView cho background
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(onboardingData[index]['background']),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          // Lớp phủ cho text, dots, và nút
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Text
                if (onboardingData[_currentPage]['text'].isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      onboardingData[_currentPage]['text'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentPage == index ? 20 : 10,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(onboardingData[index]['background']),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Nút Skip hoặc Đăng nhập ngay
                _currentPage == onboardingData.length - 1
                    ? ElevatedButton(
                        onPressed: () {
                          Get.offNamed(Routes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          Get.offNamed(Routes.login);
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}