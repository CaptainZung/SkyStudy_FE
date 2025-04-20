import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  // Mock data for leaderboard
  final List<Map<String, dynamic>> leaderboardData = const [
    {
      'name': 'Bé Mai',
      'score': 1250,
      'avatar': '👧',
      'badge': '🏆',
      'progress': 0.95,
    },
    {
      'name': 'Bé Nam',
      'score': 1100,
      'avatar': '👦',
      'badge': '🥈',
      'progress': 0.85,
    },
    {
      'name': 'Bé Lan',
      'score': 980,
      'avatar': '👧',
      'badge': '🥉',
      'progress': 0.75,
    },
    {
      'name': 'Bé Tuấn',
      'score': 850,
      'avatar': '👦',
      'badge': '🌟',
      'progress': 0.65,
    },
    {
      'name': 'Bé Hà',
      'score': 720,
      'avatar': '👧',
      'badge': '⭐',
      'progress': 0.55,
    },
    {
      'name': 'Bé An',
      'score': 600,
      'avatar': '👦',
      'badge': '✨',
      'progress': 0.45,
    },
    {
      'name': 'Bé My',
      'score': 450,
      'avatar': '👧',
      'badge': '',
      'progress': 0.35,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8E5EB), // Background color #C8E5EB
      appBar: AppBar(
        title: const Text(
          'Bảng Xếp Hạng',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white, // White text
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(
          0xFF2277B4,
        ), // Updated AppBar color #2277B4
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White icon
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding to save space
        child: Column(
          children: [
            // Top 3 podium - Reduced height further
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.25, // Reduced height
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Second place
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '2',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Text(
                            leaderboardData[1]['avatar'],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          leaderboardData[1]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${leaderboardData[1]['score']} điểm',
                          style: const TextStyle(
                            color: Color(0xFF0077B6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              leaderboardData[1]['badge'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // First place
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                leaderboardData[0]['avatar'],
                                style: const TextStyle(fontSize: 32),
                              ),
                              Positioned(
                                top: -18,
                                child: Text(
                                  '👑',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          leaderboardData[0]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${leaderboardData[0]['score']} điểm',
                          style: const TextStyle(
                            color: Color(0xFF0077B6),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              leaderboardData[0]['badge'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Third place
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '3',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Text(
                            leaderboardData[2]['avatar'],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          leaderboardData[2]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${leaderboardData[2]['score']} điểm',
                          style: const TextStyle(
                            color: Color(0xFF0077B6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.brown[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              leaderboardData[2]['badge'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12), // Reduced spacing
            // Leaderboard list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    itemCount: leaderboardData.length,
                    itemBuilder: (context, index) {
                      final player = leaderboardData[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ), // Reduced margin
                          decoration: BoxDecoration(
                            color: const Color(0xFF8FEFFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ), // Reduced padding
                            leading: CircleAvatar(
                              backgroundColor: const Color(
                                0xFF8FEFFF,
                              ).withOpacity(0.3),
                              radius: 22,
                              child: Text(
                                player['avatar'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              player['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: LinearProgressIndicator(
                                value: player['progress'],
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(index),
                                ),
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${player['score']} điểm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0077B6),
                                    fontSize: 13,
                                  ),
                                ),
                                if (player['badge'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      player['badge'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12), // Reduced spacing
            // Your position
            Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ), // Reduced bottom margin
              padding: const EdgeInsets.all(12), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF8FEFFF).withOpacity(0.3),
                    radius: 22,
                    child: const Text('👧', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vị trí của bạn',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Tiếp tục cố gắng nhé!',
                          style: TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FEFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '#8',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return const Color(0xFF0077B6);
    }
  }
}
