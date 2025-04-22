// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:skystudy/app/modules/pronunciation_check/BasePronunciationController.dart';

// class PronunciationCheckWidget extends StatelessWidget {
//   final BasePronunciationController controller;

//   const PronunciationCheckWidget({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Hiển thị từ và nút phát âm thanh mẫu
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               controller.sampleSentence,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(width: 8),
//             Obx(() {
//               return IconButton(
//                 icon: Icon(
//                   controller.isPlayingSampleSentence.value ? Icons.pause : Icons.volume_up,
//                   color: Colors.blue,
//                 ),
//                 onPressed: controller.isPlayingSampleSentence.value
//                     ? null
//                     : () => controller.playSampleSentenceAudio(),
//               );
//             }),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // Kết quả nhận diện
//         Obx(() {
//           if (controller.recognizedText.value.isNotEmpty) {
//             return Column(
//               children: [
//                 Text(
//                   controller.accuracy.value >= 0.8 ? 'Phát Âm Đúng' : 'Sai Mất Rồi',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: controller.accuracy.value >= 0.8 ? Colors.green : Colors.red,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Độ chính xác: ${(controller.accuracy.value * 100).toStringAsFixed(1)}%',
//                   style: const TextStyle(fontSize: 16, color: Colors.black54),
//                 ),
//               ],
//             );
//           }
//           return const Text('Hãy nói rõ ràng để kiểm tra phát âm nhé!');
//         }),
//       ],
//     );
//   }
// }