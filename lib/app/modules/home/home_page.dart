import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../global_widgets/bottom_navbar.dart';
import '../../controllers/lottie_controller.dart';
import 'home_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import '../menu/setting_popup.dart';
import '../menu/setting_controller.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../leaderboard/leaderboard_page.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final LottieController lottieController = Get.find<LottieController>();
    return _HomePageView(controller: lottieController);
  }
}

class _HomePageView extends StatefulWidget {
  final LottieController controller;
  const _HomePageView({required this.controller});

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView>
    with TickerProviderStateMixin {
  LottieComposition? _ufoComposition;
  LottieComposition? _dinoComposition;

  // Biến để điều khiển hiệu ứng scale cho các nút hiện có
  double settingScale = 1.0;
  double dailyCheckScale = 1.0;
  double leaderboardScale = 1.0;

  // Danh sách scale cho các node (40 node: 8 topic, mỗi topic 5 node)
  List<double> nodeScales = List.generate(40, (_) => 1.0);

  // Danh sách trạng thái cho các node (0: chưa làm, 1: đang làm, 2: đã hoàn thành)
  List<int> nodeStatus = List.generate(40, (_) => 0); // Khởi tạo mặc định

  // Biến để theo dõi trạng thái tải dữ liệu
  bool isLoading = true;

  final int _points = 1000; // Điểm ảo (tạm thời)
  final Logger logger = Logger();

  // Danh sách các topic
  final List<String> topics = [
    'Family',
    'Animal',
    'Fruits',
    'School',
    'Foods',
    'Sport',
    'Body Part',
    'Career',
  ].toList(); // Đảo ngược danh sách để bắt đầu từ dưới lên

  // ScrollController để điều khiển vị trí cuộn
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(this);
    Get.find<HomeController>().fetchProfile();

    // Khởi tạo SoundManager và phát nhạc nền
    SoundManager.init().then((_) {
      SoundManager.playMusic();
    });

    // Tải trạng thái từ SharedPreferences
    _loadNodeStatus();

    // Khởi tạo ScrollController
    _scrollController = ScrollController();

    // Tự động cuộn lên trên cùng sau khi màn hình được tải (vì list đã đảo ngược)
    _scrollToTop();
  }

  // Tải trạng thái từ SharedPreferences
  Future<void> _loadNodeStatus() async {
    setState(() {
      isLoading = true;
    });

    final controller = Get.find<HomeController>();
    await controller.loadProgressFromAPI();

    final currentTopic = controller.currentTopic.value;
    final currentNode = controller.currentNode.value;
    final topicList = topics.toList(); // Đảo ngược lại để khớp với logic

    int currentTopicIndex = topicList.indexOf(currentTopic);

    setState(() {
      if (currentTopicIndex == -1) {
        // Nếu currentTopic không hợp lệ, mặc định tất cả node đều bị khóa
        nodeStatus = List.generate(40, (_) => 0);
      } else {
        nodeStatus = List.generate(40, (index) {
          int topicIndex = index ~/ 5;
          int nodeInTopic = index % 5 + 1;

          if (topicIndex < currentTopicIndex) {
            return 2; // Đã học toàn bộ topic
          } else if (topicIndex == currentTopicIndex) {
            if (nodeInTopic < currentNode) return 2;
            if (nodeInTopic == currentNode) return 1;
            return 0;
          } else {
            return 0; // Chưa học
          }
        });
      }
      isLoading = false;
    });
  }

  // Lưu trạng thái vào SharedPreferences
  Future<void> _saveNodeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nodeStatus',
      nodeStatus.map((e) => e.toString()).toList(),
    );
  }

  // Hàm để cuộn lên trên cùng, thử lại nếu ScrollController chưa sẵn sàng
  void _scrollToTop() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      } else {
        // Thử lại sau 100ms nếu ScrollController chưa sẵn sàng
        _scrollToTop();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.stopAnimations();
    widget.controller.onClose();
    _scrollController.dispose(); // Giải phóng ScrollController
    SoundManager.stopMusic(); // Dừng nhạc nền khi thoát
    super.dispose();
  }

  // Hàm để lấy icon dựa trên trạng thái node
  String getNodeIcon(int status) {
    switch (status) {
      case 0:
        return 'assets/icons/star0.png'; // Chưa làm (màu xám)
      case 1:
        return 'assets/icons/star1.png'; // Đang làm (màu vàng)
      case 2:
        return 'assets/icons/star2.png'; // Đã hoàn thành (màu xanh)
      default:
        return 'assets/icons/star0.png';
    }
  }

  // Hàm để cập nhật trạng thái khi hoàn thành node
  void completeNode(int nodeIndex) {
    setState(() {
      nodeStatus[nodeIndex] = 2; // Đánh dấu node là đã hoàn thành
    });
    _saveNodeStatus();
  }

  @override
  Widget build(BuildContext context) {
    final SettingController settingController = Get.put(SettingController());

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Hình nền
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home1.png'),
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeatY, // Lặp lại hình nền khi cuộn
                ),
              ),
              height: double.infinity,
              width: double.infinity,
            ),
            // Thông tin người dùng (Avatar, Tên, Điểm)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Obx(
                () => Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: settingController.avatarPath.value.isNotEmpty
                            ? Image.file(
                                File(settingController.avatarPath.value),
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/icons/default_avatar.png',
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/icons/default_avatar.png',
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            settingController.userName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$_points p',
                                  style: const TextStyle(
                                    color: Color(0xFF4A90E2),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF4A90E2),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.60,
              left: MediaQuery.of(context).size.width * 0.45,
              child: Lottie.asset(
                'assets/lottie/ufo1.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                controller: widget.controller.ufoController,
                onLoaded: (composition) {
                  _ufoComposition = composition;
                  if (_dinoComposition != null) {
                    widget.controller.startAnimations(
                      _ufoComposition!,
                      _dinoComposition!,
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.55,
              left: MediaQuery.of(context).size.width * 0.55,
              child: Lottie.asset(
                'assets/lottie/khunglongdance.json',
                width: 170,
                height: 170,
                fit: BoxFit.contain,
                controller: widget.controller.dinoController,
                onLoaded: (composition) {
                  _dinoComposition = composition;
                  if (_ufoComposition != null) {
                    widget.controller.startAnimations(
                      _ufoComposition!,
                      _dinoComposition!,
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          settingScale = 0.9;
                        });
                        logger.i('Setting button pressed down');
                      },
                      onTapUp: (_) {
                        setState(() {
                          settingScale = 1.0;
                        });
                        logger.i('Setting button pressed up');
                        SoundManager.playButtonSound();
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            logger.i('Showing SettingPopup');
                            return const SettingPopup();
                          },
                        );
                      },
                      child: AnimatedScale(
                        scale: settingScale,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/icons/setting.png',
                          width: 52,
                          height: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          dailyCheckScale = 0.9;
                        });
                        logger.i('Daily Check button pressed down');
                      },
                      onTapUp: (_) {
                        setState(() {
                          dailyCheckScale = 1.0;
                        });
                        logger.i('Daily Check button pressed up');
                        SoundManager.playButtonSound();
                      },
                      child: AnimatedScale(
                        scale: dailyCheckScale,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/icons/dailycheck.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          leaderboardScale = 0.9;
                        });
                        logger.i('Leaderboard button pressed down');
                      },
                      onTapUp: (_) {
                        setState(() {
                          leaderboardScale = 1.0;
                        });
                        logger.i('Leaderboard button pressed up');
                        SoundManager.playButtonSound();
                        Get.to(
                          const LeaderboardPage(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: AnimatedScale(
                        scale: leaderboardScale,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/icons/leadboard.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Phần Roadmap cuộn được với ListView.builder
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.only(left: 70), // Dịch toàn bộ roadmap sang phải
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: topics.length,
                          itemBuilder: (context, topicIndex) {
                            String currentTopic = topics[topicIndex];
                            int baseNodeIndex = topicIndex * 5;

                            return Column(
                              children: [
                                Column(
                                  children: List.generate(5, (index) {
                                    // Đảo ngược thứ tự node: index 0 sẽ là nodeInTopic 4, index 4 sẽ là nodeInTopic 0
                                    int nodeInTopic = 4 - index;
                                    int nodeIndex = baseNodeIndex + nodeInTopic;
                                    bool isLocked = nodeStatus[nodeIndex] == 0;
                                    bool isEven = nodeInTopic % 2 == 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Align(
                                        alignment: isEven
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: isEven ? 50 : 0,
                                            right: isEven ? 0 : 50,
                                          ),
                                          child: nodeInTopic == 4
                                              ? GestureDetector(
                                                  onTap: null, // Tạm vô hiệu hóa
                                                  child: Image.asset(
                                                    'assets/icons/chest.png',
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                                )
                                              : Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTapDown: isLocked
                                                          ? null
                                                          : (_) {
                                                              setState(() {
                                                                nodeScales[nodeIndex] = 0.9;
                                                              });
                                                            },
                                                      onTapUp: isLocked
                                                          ? null
                                                          : (_) {
                                                              setState(() {
                                                                nodeScales[nodeIndex] = 1.0;
                                                              });
                                                              SoundManager.playButtonSound();
                                                              Get.toNamed(
                                                                Routes.exercise1,
                                                                arguments: {
                                                                  'topic': currentTopic,
                                                                  'node': nodeInTopic + 1,
                                                                },
                                                              )?.then((result) {
                                                                logger.i(
                                                                  'Result from exercise1 (Node $nodeIndex, Topic $currentTopic): $result',
                                                                );
                                                                if (result == true) {
                                                                  completeNode(nodeIndex);
                                                                }
                                                              });
                                                            },
                                                      child: AnimatedScale(
                                                        scale: nodeScales[nodeIndex],
                                                        duration: const Duration(milliseconds: 200),
                                                        child: Image.asset(
                                                          getNodeIcon(nodeStatus[nodeIndex]),
                                                          width: 60,
                                                          height: 60,
                                                          color: isLocked ? Colors.grey.withOpacity(0.5) : null,
                                                          colorBlendMode: isLocked ? BlendMode.modulate : null,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isLocked)
                                                      Icon(
                                                        Icons.lock,
                                                        size: 30,
                                                        color: Colors.black.withOpacity(0.7),
                                                      ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                 Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    currentTopic,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}