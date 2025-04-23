import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/home/home_service.dart';
import 'package:skystudy/app/utils/sound_manager.dart';

class ChestController extends GetxController {
  final ProgressService apiService = ProgressService();

  Future<void> openMysteryChest({
    required String topic,
    required int nodeIndex,
    required List<int> nodeStatus,
    required int baseNodeIndex,
    required Function(int) updateNodeStatus,
  }) async {
    bool canOpenChest = true;
    for (int i = baseNodeIndex; i < baseNodeIndex + 4; i++) {
      if (nodeStatus[i] != 2) {
        canOpenChest = false;
        break;
      }
    }

    if (!canOpenChest) {
      Get.snackbar(
        'Locked',
        'Complete all previous nodes to open the mystery chest!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (nodeStatus[nodeIndex] == 2) {
      Get.snackbar(
        'Already Opened',
        'You have already opened this mystery chest!',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
      return;
    }

    SoundManager.playButtonSound();
    final message = await apiService.openMysteryChest(topic);
    if (message != null) {
      Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      updateNodeStatus(nodeIndex);
    } else {
      Get.snackbar(
        'Error',
        'Failed to open the mystery chest.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}