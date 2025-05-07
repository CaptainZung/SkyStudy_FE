import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/modules/home/widgets/chest_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/utils/sound_manager.dart';

class RoadmapWidget extends StatefulWidget {
  final Function(int) onTopicChanged;

  const RoadmapWidget({super.key, required this.onTopicChanged});

  @override
  RoadmapWidgetState createState() => RoadmapWidgetState();
}

class RoadmapWidgetState extends State<RoadmapWidget> {
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

  List<String> loadedTopics = [];
  List<double> nodeScales = List.generate(40, (_) => 1.0);
  List<int> nodeStatus = List.generate(40, (_) => 0);
  bool isLoading = true;
  bool isLoadingNext = false;
  int currentTopicIndex = 0;
  late PageController _pageController;
  late ChestController chestController;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    chestController = Get.put(ChestController());
    _pageController = PageController(initialPage: 0);
    _loadNodeStatus();
    SoundManager.init().then((_) {
      SoundManager.playMusic();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    SoundManager.stopMusic();
    super.dispose();
  }

  Future<void> _loadNodeStatus() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final controller = Get.find<HomeController>();

    // Load trạng thái từ SharedPreferences
    currentTopicIndex = prefs.getInt('currentTopicIndex') ?? 0;
    final savedNodeStatus = prefs.getStringList('nodeStatus');
    if (savedNodeStatus != null) {
      nodeStatus = savedNodeStatus.map((e) => int.parse(e)).toList();
    } else {
      // Nếu không có trạng thái lưu trữ, tải từ API
      await controller.loadProgressFromAPI();
      final currentTopic = controller.currentTopic.value;
      final currentNode = controller.currentNode.value;

      // Cập nhật trạng thái node
      nodeStatus = List.generate(40, (index) {
        int topicIdx = index ~/ 5;
        int nodeInTopic = index % 5 + 1;

        if (topicIdx < currentTopicIndex) {
          return 2; // Hoàn thành
        } else if (topicIdx == currentTopicIndex) {
          if (nodeInTopic < currentNode) return 2; // Hoàn thành
          if (nodeInTopic == currentNode) return 1; // Đang hoạt động
          return 0; // Chưa mở khóa
        } else {
          return 0; // Chưa mở khóa
        }
      });
    }

    setState(() {
      loadedTopics = topics;
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(currentTopicIndex);
      }
    });

    widget.onTopicChanged(currentTopicIndex);
  }

  Future<void> _saveNodeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentTopicIndex', currentTopicIndex);
    await prefs.setStringList(
      'nodeStatus',
      nodeStatus.map((e) => e.toString()).toList(),
    );
  }

  String getNodeIcon(int status) {
    switch (status) {
      case 0:
        return 'assets/icons/star0.png';
      case 1:
        return 'assets/icons/star1.png';
      case 2:
        return 'assets/icons/star2.png';
      default:
        return 'assets/icons/star0.png';
    }
  }

  void completeNode(int nodeIndex) {
    setState(() {
      nodeStatus[nodeIndex] = 2;
    });
    _saveNodeStatus();
  }

  void _navigateToExercise(
    String currentTopic,
    int nodeInTopic,
    int actualNodeIndex,
  ) {
    SoundManager.stopMusic(); // Tạm dừng nhạc khi vào bài tập
    Get.toNamed(
      Routes.exercise1,
      arguments: {'topic': currentTopic, 'node': nodeInTopic + 1},
    )?.then((result) async {
      logger.i(
        'Result from exercise1 (Node $actualNodeIndex, Topic $currentTopic): $result',
      );
      if (result == true) {
        completeNode(actualNodeIndex);
      }
      await _saveNodeStatus(); // Lưu trạng thái sau khi hoàn thành bài tập
      SoundManager.playMusic(); // Phát lại nhạc khi quay lại
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          reverse: true,
          onPageChanged: (index) async {
            setState(() {
              currentTopicIndex = index;
            });
            await _saveNodeStatus(); // Lưu trạng thái khi thay đổi topic
            widget.onTopicChanged(currentTopicIndex);
          },
          itemCount: loadedTopics.length,
          itemBuilder: (context, index) {
            String currentTopic = loadedTopics[index];
            int topicIndex = topics.indexOf(currentTopic);
            int baseNodeIndex = topicIndex * 5;

            return Container(
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          currentTopic,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 80,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(5, (nodeIndex) {
                            int nodeInTopic = 4 - nodeIndex;
                            int actualNodeIndex = baseNodeIndex + nodeInTopic;
                            bool isLocked = nodeStatus[actualNodeIndex] == 0;
                            bool isEven = nodeInTopic % 2 == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ), // Giảm padding để tiết kiệm không gian
                              child: Align(
                                alignment:
                                    isEven
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: isEven ? 70 : 0,
                                    right: isEven ? 0 : 70,
                                  ),
                                  child:
                                      nodeInTopic == 4
                                          ? GestureDetector(
                                            onTapDown: (_) {
                                              setState(() {
                                                nodeScales[actualNodeIndex] =
                                                    0.9;
                                              });
                                            },
                                            onTapUp: (_) async {
                                              setState(() {
                                                nodeScales[actualNodeIndex] =
                                                    1.0;
                                              });

                                              await chestController
                                                  .openMysteryChest(
                                                    topic: currentTopic,
                                                    nodeIndex: actualNodeIndex,
                                                    nodeStatus: nodeStatus,
                                                    baseNodeIndex:
                                                        baseNodeIndex,
                                                    updateNodeStatus: (
                                                      int nodeIndex,
                                                    ) {
                                                      setState(() {
                                                        nodeStatus[nodeIndex] =
                                                            2;
                                                      });
                                                      _saveNodeStatus();
                                                    },
                                                  );
                                            },
                                            child: AnimatedScale(
                                              scale:
                                                  nodeScales[actualNodeIndex],
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              child: Image.asset(
                                                nodeStatus[actualNodeIndex] == 2
                                                    ? 'assets/icons/chest_open.png'
                                                    : 'assets/icons/chest.png',
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                          )
                                          : Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              GestureDetector(
                                                onTapDown:
                                                    isLocked
                                                        ? null
                                                        : (_) {
                                                          setState(() {
                                                            nodeScales[actualNodeIndex] =
                                                                0.9;
                                                          });
                                                        },
                                                onTapUp:
                                                    isLocked
                                                        ? null
                                                        : (_) {
                                                          setState(() {
                                                            nodeScales[actualNodeIndex] =
                                                                1.0;
                                                          });
                                                          SoundManager.playButtonSound();
                                                          _navigateToExercise(
                                                            currentTopic,
                                                            nodeInTopic,
                                                            actualNodeIndex,
                                                          );
                                                        },
                                                child: AnimatedScale(
                                                  scale:
                                                      nodeScales[actualNodeIndex],
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  child: Image.asset(
                                                    getNodeIcon(
                                                      nodeStatus[actualNodeIndex],
                                                    ),
                                                    width: 60,
                                                    height: 60,
                                                    color:
                                                        isLocked
                                                            ? Colors.grey
                                                                .withOpacity(
                                                                  0.5,
                                                                )
                                                            : null,
                                                    colorBlendMode:
                                                        isLocked
                                                            ? BlendMode.modulate
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                              if (isLocked)
                                                Icon(
                                                  Icons.lock,
                                                  size: 30,
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                ),
                                            ],
                                          ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}