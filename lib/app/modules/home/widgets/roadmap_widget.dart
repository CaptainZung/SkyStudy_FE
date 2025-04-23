import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skystudy/app/modules/home/widgets/chest_controller.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/utils/sound_manager.dart';

class RoadmapWidget extends StatefulWidget {
  final Function(int) onTopicChanged;

  const RoadmapWidget({super.key, required this.onTopicChanged});

  @override
  _RoadmapWidgetState createState() => _RoadmapWidgetState();
}

class _RoadmapWidgetState extends State<RoadmapWidget> {
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
  final Logger logger = Logger();
  late ChestController chestController;

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

    final controller = Get.find<HomeController>();
    await controller.loadProgressFromAPI();

    final currentTopic = controller.currentTopic.value;
    final currentNode = controller.currentNode.value;
    final topicList = topics.toList();

    int topicIndex = topicList.indexOf(currentTopic);

    setState(() {
      if (topicIndex == -1) {
        nodeStatus = List.generate(40, (_) => 0);
      } else {
        nodeStatus = List.generate(40, (index) {
          int topicIdx = index ~/ 5;
          int nodeInTopic = index % 5 + 1;

          if (topicIdx < topicIndex) {
            return 2;
          } else if (topicIdx == topicIndex) {
            if (nodeInTopic < currentNode) return 2;
            if (nodeInTopic == currentNode) return 1;
            return 0;
          } else {
            return 0;
          }
        });
        controller.saveProgressToLocal(currentTopic, currentNode);
        currentTopicIndex = topicIndex == -1 ? 0 : topicIndex;
        loadedTopics = topics.sublist(0, currentTopicIndex + 1);
      }
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

  Future<void> _loadNextTopic(int nextIndex) async {
    if (nextIndex < topics.length && !loadedTopics.contains(topics[nextIndex])) {
      setState(() {
        isLoadingNext = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        loadedTopics.add(topics[nextIndex]);
        isLoadingNext = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            reverse: true,
            onPageChanged: (index) async {
              setState(() {
                currentTopicIndex = index;
              });

              widget.onTopicChanged(currentTopicIndex);

              if (index == loadedTopics.length - 1 && index < topics.length - 1) {
                await _loadNextTopic(index + 1);
              }
            },
            itemCount: loadedTopics.length + (isLoadingNext ? 1 : 0),
            itemBuilder: (context, index) {
              if (isLoadingNext && index == loadedTopics.length) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

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
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Align(
                                  alignment: isEven ? Alignment.centerLeft : Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: isEven ? 70 : 0,
                                      right: isEven ? 0 : 70,
                                    ),
                                    child: nodeInTopic == 4
                                        ? GestureDetector(
                                            onTapDown: (_) {
                                              setState(() {
                                                nodeScales[actualNodeIndex] = 0.9;
                                              });
                                            },
                                            onTapUp: (_) async {
                                              setState(() {
                                                nodeScales[actualNodeIndex] = 1.0;
                                              });

                                              await chestController.openMysteryChest(
                                                topic: currentTopic,
                                                nodeIndex: actualNodeIndex,
                                                nodeStatus: nodeStatus,
                                                baseNodeIndex: baseNodeIndex,
                                                updateNodeStatus: (int nodeIndex) {
                                                  setState(() {
                                                    nodeStatus[nodeIndex] = 2;
                                                  });
                                                  _saveNodeStatus();
                                                },
                                              );
                                            },
                                            child: AnimatedScale(
                                              scale: nodeScales[actualNodeIndex],
                                              duration: const Duration(milliseconds: 200),
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
                                                onTapDown: isLocked
                                                    ? null
                                                    : (_) {
                                                        setState(() {
                                                          nodeScales[actualNodeIndex] = 0.9;
                                                        });
                                                      },
                                                onTapUp: isLocked
                                                    ? null
                                                    : (_) {
                                                        setState(() {
                                                          nodeScales[actualNodeIndex] = 1.0;
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
                                                            'Result from exercise1 (Node $actualNodeIndex, Topic $currentTopic): $result',
                                                          );
                                                          if (result == true) {
                                                            completeNode(actualNodeIndex);
                                                          }
                                                        });
                                                      },
                                                child: AnimatedScale(
                                                  scale: nodeScales[actualNodeIndex],
                                                  duration: const Duration(milliseconds: 200),
                                                  child: Image.asset(
                                                    getNodeIcon(nodeStatus[actualNodeIndex]),
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