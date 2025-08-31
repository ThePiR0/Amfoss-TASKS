import 'package:flutter/material.dart';
import '../utils/leaderboard_manager.dart';

// Leaderboard Screen with smooth animations & shimmer effect on #1 spot
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late List<LeaderboardEntry> leaderboard;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();

    // Load leaderboard entries (assuming synchronous getter)
    leaderboard = LeaderboardManager().entries;

    // Animation controller for staggered list animations
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animation after first frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  // Clear leaderboard with confirmation dialog
  void _clearLeaderboard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Leaderboard?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              LeaderboardManager().clear();
              setState(() {
                leaderboard = [];
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Build each animated leaderboard item with staggered slide, fade, scale animations
  Widget _buildAnimatedListItem(int index, LeaderboardEntry entry) {
    // Define animation intervals to stagger items (0.1 seconds apart)
    final animationIntervalStart = index * 0.1;
    final animationIntervalEnd = animationIntervalStart + 0.5;

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Interval(animationIntervalStart, animationIntervalEnd, curve: Curves.easeOut),
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Interval(animationIntervalStart, animationIntervalEnd, curve: Curves.easeIn),
      ),
    );

    final isTop3 = index < 3;

    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Interval(animationIntervalStart, animationIntervalEnd, curve: Curves.elasticOut),
      ),
    );

    // Set colors for top 3 ranks
    Color bgColor;
    switch (index) {
      case 0:
        bgColor = const Color(0xFFFFD700); // Gold
        break;
      case 1:
        bgColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 2:
        bgColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        bgColor = Colors.deepPurple;
    }

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: isTop3 ? scaleAnimation : const AlwaysStoppedAnimation(1),
          child: ListTile(
            leading: index == 0
                ? _ShimmerCircleAvatar(
                    text: '1',
                    backgroundColor: bgColor,
                  )
                : CircleAvatar(
                    backgroundColor: bgColor,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
            title: Text(
              entry.playerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isTop3 ? Colors.deepPurple.shade700 : Colors.black87,
              ),
            ),
            trailing: _AnimatedScore(score: entry.score, isTop3: isTop3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Leaderboard',
            onPressed: _clearLeaderboard,
          ),
        ],
      ),
      body: leaderboard.isEmpty
          ? Center(
              child: Text(
                'No scores yet.\nPlay some games to get on the board!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return _buildAnimatedListItem(index, leaderboard[index]);
              },
            ),
    );
  }
}

// Animated score widget that counts up from 0 to final score
class _AnimatedScore extends StatefulWidget {
  final int score;
  final bool isTop3;
  const _AnimatedScore({required this.score, this.isTop3 = false, Key? key})
      : super(key: key);

  @override
  State<_AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<_AnimatedScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Text(
          '${_scoreAnimation.value}',
          style: TextStyle(
            fontSize: 18,
            color:
                widget.isTop3 ? Colors.deepPurple.shade700 : Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

// Custom GradientTransform for shimmer sliding effect
class SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// Shimmering CircleAvatar widget used on top leaderboard rank
class _ShimmerCircleAvatar extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  const _ShimmerCircleAvatar({required this.text, required this.backgroundColor, Key? key}) : super(key: key);

  @override
  State<_ShimmerCircleAvatar> createState() => _ShimmerCircleAvatarState();
}

class _ShimmerCircleAvatarState extends State<_ShimmerCircleAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (rect) {
                  final shimmerWidth = rect.width / 2;
                  final dx = (_controller.value * (rect.width + shimmerWidth)) - shimmerWidth;
                  return LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white,
                      Colors.white.withOpacity(0.3)
                    ],
                    stops: const [0.25, 0.5, 0.75],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    transform: SlidingGradientTransform(dx / rect.width),
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: CircleAvatar(
                  backgroundColor: widget.backgroundColor,
                ),
              );
            },
          ),
          Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
