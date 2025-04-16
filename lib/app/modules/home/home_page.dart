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
  List<int> nodeStatus = [];

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
  ];

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

    // Tự động cuộn xuống dưới cùng sau khi màn hình được tải
    _scrollToBottom();
  }

  // Tải trạng thái từ SharedPreferences
  Future<void> _loadNodeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedStatus = prefs.getStringList('nodeStatus');
    if (savedStatus != null && savedStatus.length == 40) {
      setState(() {
        nodeStatus = savedStatus.map((e) => int.parse(e)).toList();
      });
    } else {
      // Nếu không có trạng thái đã lưu, khởi tạo mặc định
      setState(() {
        nodeStatus = List.generate(40, (index) {
          if (index == 0) return 1; // Topic 1, Node 1: đang làm
          return 0; // Các node khác: chưa làm
        });
      });
      await _saveNodeStatus();
    }
  }

  // Lưu trạng thái vào SharedPreferences
  Future<void> _saveNodeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nodeStatus',
      nodeStatus.map((e) => e.toString()).toList(),
    );
  }

  // Hàm để cuộn xuống dưới cùng, thử lại nếu ScrollController chưa sẵn sàng
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        // Thử lại sau 100ms nếu ScrollController chưa sẵn sàng
        _scrollToBottom();
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
      nodeStatus[nodeIndex] =
          2; // Đánh dấu node hiện tại là đã hoàn thành (màu xanh)
    });
    // Lưu trạng thái sau khi cập nhật
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
                  image: AssetImage('assets/images/home.png'),
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
                    // Avatar
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
                    // Tên và Điểm
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
            // Lottie Animations (UFO và Dinosaur)
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
            // Nút Setting, Daily Check, Leaderboard
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
                      color: const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút 1: Setting
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
                    // Nút 2: Daily Check
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
                    // Nút 3: Leaderboard
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
            // Phần Roadmap cuộn được
            Positioned(
              top: MediaQuery.of(context).padding.top, // Cách đỉnh để không che avatar/nút
              left: 45,
              right: 0,
              bottom: 0, // Cách đáy để không che bottom navbar
              child: ClipRect(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse: false,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 8,
                    child: Stack(
                      children: [
                        // Tạo 8 topic, mỗi topic 5 node
                        ...List.generate(8, (topicIndex) {
                          int displayIndex = topicIndex;
                          double topicOffset =
                              displayIndex * MediaQuery.of(context).size.height;
                          String currentTopic = topics[topicIndex];
                          int baseNodeIndex =
                              topicIndex * 5; // Mỗi topic có 5 node

                          return [
                            // Node 1
                            Positioned(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.15 +
                                  topicOffset,
                              left: MediaQuery.of(context).size.width * 0.1,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex] = 0.9;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex] = 1.0;
                                  });
                                  SoundManager.playButtonSound();
                                  Get.toNamed(
                                    Routes.exercise1,
                                    arguments: {
                                      'topic': currentTopic,
                                      'node': 1,
                                    },
                                  )?.then((result) {
                                    logger.i(
                                      'Result from exercise1 (Node ${baseNodeIndex}, Topic $currentTopic): $result',
                                    ); // Debug log
                                    if (result == true) {
                                      completeNode(baseNodeIndex);
                                    }
                                  });
                                },
                                child: AnimatedScale(
                                  scale: nodeScales[baseNodeIndex],
                                  duration: const Duration(milliseconds: 200),
                                  child: Image.asset(
                                    getNodeIcon(nodeStatus[baseNodeIndex]),
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                            // Node 2
                            Positioned(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.35 +
                                  topicOffset,
                              left: MediaQuery.of(context).size.width * 0.30,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 1] = 0.9;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 1] = 1.0;
                                  });
                                  SoundManager.playButtonSound();
                                  Get.toNamed(
                                    Routes.exercise1,
                                    arguments: {
                                      'topic': currentTopic,
                                      'node': 2,
                                    },
                                  )?.then((result) {
                                    logger.i(
                                      'Result from exercise1 (Node ${baseNodeIndex + 1}, Topic $currentTopic): $result',
                                    ); // Debug log
                                    if (result == true) {
                                      completeNode(baseNodeIndex + 1);
                                    }
                                  });
                                },
                                child: AnimatedScale(
                                  scale: nodeScales[baseNodeIndex + 1],
                                  duration: const Duration(milliseconds: 200),
                                  child: Image.asset(
                                    getNodeIcon(nodeStatus[baseNodeIndex + 1]),
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                            // Node 3
                            Positioned(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.45 +
                                  topicOffset,
                              right: MediaQuery.of(context).size.width * 0.15,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 2] = 0.9;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 2] = 1.0;
                                  });
                                  SoundManager.playButtonSound();
                                  Get.toNamed(
                                    Routes.exercise1,
                                    arguments: {
                                      'topic': currentTopic,
                                      'node': 3,
                                    },
                                  )?.then((result) {
                                    logger.i(
                                      'Result from exercise1 (Node ${baseNodeIndex + 2}, Topic $currentTopic): $result',
                                    ); // Debug log
                                    if (result == true) {
                                      completeNode(baseNodeIndex + 2);
                                    }
                                  });
                                },
                                child: AnimatedScale(
                                  scale: nodeScales[baseNodeIndex + 2],
                                  duration: const Duration(milliseconds: 200),
                                  child: Image.asset(
                                    getNodeIcon(nodeStatus[baseNodeIndex + 2]),
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                            // Node 4
                            Positioned(
                              top:
                                  MediaQuery.of(context).size.height * 0.25 +
                                  topicOffset,
                              left: MediaQuery.of(context).size.width * 0.2,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 3] = 0.9;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 3] = 1.0;
                                  });
                                  SoundManager.playButtonSound();
                                  Get.toNamed(
                                    Routes.exercise1,
                                    arguments: {
                                      'topic': currentTopic,
                                      'node': 4,
                                    },
                                  )?.then((result) {
                                    logger.i(
                                      'Result from exercise1 (Node ${baseNodeIndex + 3}, Topic $currentTopic): $result',
                                    ); // Debug log
                                    if (result == true) {
                                      completeNode(baseNodeIndex + 3);
                                    }
                                  });
                                },
                                child: AnimatedScale(
                                  scale: nodeScales[baseNodeIndex + 3],
                                  duration: const Duration(milliseconds: 200),
                                  child: Image.asset(
                                    getNodeIcon(nodeStatus[baseNodeIndex + 3]),
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                            // Node 5 (Chest)
                            Positioned(
                              top:
                                  MediaQuery.of(context).size.height * 0.12 +
                                  topicOffset,
                              right: MediaQuery.of(context).size.width * 0.1,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 4] = 0.9;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    nodeScales[baseNodeIndex + 4] = 1.0;
                                  });
                                  SoundManager.playButtonSound();
                                  // Không điều hướng cho chest, nhưng vẫn cập nhật trạng thái
                                  completeNode(baseNodeIndex + 4);
                                },
                                child: AnimatedScale(
                                  scale: nodeScales[baseNodeIndex + 4],
                                  duration: const Duration(milliseconds: 200),
                                  child: Image.asset(
                                    'assets/icons/chest.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            ),
                          ];
                        }).expand((element) => element).toList(),
                      ],
                    ),
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