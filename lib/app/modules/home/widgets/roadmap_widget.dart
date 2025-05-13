import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/modules/home/widgets/chest_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:skystudy/app/modules/exercises/exercise_1/exercise_1_page.dart';

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
  PageController? _pageController;
  late ChestController chestController;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    chestController = Get.put(ChestController());
    _loadNodeStatus();
    SoundManager.init().then((_) {
      SoundManager.playMusic();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    SoundManager.stopMusic();
    super.dispose();
  }

  Future<void> _loadNodeStatus() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = await AuthManager.getToken() ?? '';
    final controller = Get.find<HomeController>();

    // 1. Ưu tiên load local để hiển thị ngay lập tức
    int? localTopicIndex = prefs.getInt('currentTopicIndex_${token}');
    final savedNodeStatus = prefs.getStringList('nodeStatus_${token}');
    bool loadedFromLocal = false;

    if (savedNodeStatus != null && localTopicIndex != null) {
      nodeStatus = savedNodeStatus.map((e) => int.parse(e)).toList();
      currentTopicIndex = localTopicIndex;
      loadedFromLocal = true;
    } else {
      // Nếu không có local thì mới lấy từ API/local controller
      await controller.loadProgressFromAPI();
      final currentTopic = controller.currentTopic.value;
      final currentNode = controller.currentNode.value;

      currentTopicIndex = topics.indexOf(currentTopic);
      if (currentTopicIndex == -1) currentTopicIndex = 0;

      nodeStatus = List.generate(40, (index) {
        int topicIdx = index ~/ 5;
        int nodeInTopic = index % 5 + 1;
        if (topicIdx < currentTopicIndex) {
          return 2;
        } else if (topicIdx == currentTopicIndex) {
          if (nodeInTopic < currentNode) return 2;
          if (nodeInTopic == currentNode) return 1;
          return 0;
        } else {
          return 0;
        }
      });
    }

    // Khởi tạo _pageController với đúng initialPage
    _pageController?.dispose();
    _pageController = PageController(initialPage: currentTopicIndex);

    setState(() {
      loadedTopics = topics;
      isLoading = false;
    });

    // Không cần jumpToPage nữa vì đã khởi tạo đúng trang
    widget.onTopicChanged(currentTopicIndex);

    // 2. Sau khi đã hiển thị local, đồng bộ lại với server (nếu muốn)
    // Nếu không muốn đồng bộ lại thì bỏ đoạn dưới đây
    if (loadedFromLocal) {
      await controller.loadProgressFromAPI();
      final currentTopic = controller.currentTopic.value;
      final currentNode = controller.currentNode.value;
      int apiTopicIndex = topics.indexOf(currentTopic);
      if (apiTopicIndex == -1) apiTopicIndex = 0;

      // Nếu dữ liệu server khác local thì mới update lại UI
      if (apiTopicIndex != currentTopicIndex ||
          !_isNodeStatusSame(apiTopicIndex, currentNode, nodeStatus)) {
        setState(() {
          currentTopicIndex = apiTopicIndex;
          nodeStatus = List.generate(40, (index) {
            int topicIdx = index ~/ 5;
            int nodeInTopic = index % 5 + 1;
            if (topicIdx < apiTopicIndex) {
              return 2;
            } else if (topicIdx == apiTopicIndex) {
              if (nodeInTopic < currentNode) return 2;
              if (nodeInTopic == currentNode) return 1;
              return 0;
            } else {
              return 0;
            }
          });
          // Cập nhật lại pageController nếu cần
          _pageController?.jumpToPage(currentTopicIndex);
        });
        widget.onTopicChanged(currentTopicIndex);
      }
    }
  }

  // Helper để so sánh nodeStatus local và server
  bool _isNodeStatusSame(int topicIndex, int node, List<int> localStatus) {
    for (int i = 0; i < 40; i++) {
      int topicIdx = i ~/ 5;
      int nodeInTopic = i % 5 + 1;
      int expected;
      if (topicIdx < topicIndex) {
        expected = 2;
      } else if (topicIdx == topicIndex) {
        if (nodeInTopic < node) expected = 2;
        else if (nodeInTopic == node) expected = 1;
        else expected = 0;
      } else {
        expected = 0;
      }
      if (localStatus[i] != expected) return false;
    }
    return true;
  }

  Future<void> _saveNodeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await AuthManager.getToken() ?? '';
    await prefs.setInt('currentTopicIndex_${token}', currentTopicIndex);
    await prefs.setStringList(
      'nodeStatus_${token}',
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
    SoundManager.stopMusic();
    Get.to(
      () => Exercise1Page(),
      arguments: {'topic': currentTopic, 'node': nodeInTopic + 1},
      transition: Transition.rightToLeft, // hoặc Transition.leftToRight nếu muốn
    )?.then((result) async {
      logger.i(
        'Result from exercise1 (Node $actualNodeIndex, Topic $currentTopic): $result',
      );
      if (result == true) {
        completeNode(actualNodeIndex);
      }
      await _saveNodeStatus();
      SoundManager.playMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : PageView.builder(
          controller: _pageController!,
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