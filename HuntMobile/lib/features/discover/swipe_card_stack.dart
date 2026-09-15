import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared_widgets/job_card.dart';

/// Centerpiece 3-card stack widget with custom gesture pan rotation physics:
/// - Rotation formula: dx / 18 radians
/// - Threshold: dx.abs() > 90 px fling
/// - Optimistic UI: Card disappears immediately when threshold crossed
class SwipeCardStack extends ConsumerStatefulWidget {
  final List<Job> jobs;
  final Function(Job job, bool isRightSwipe) onSwipe;

  const SwipeCardStack({
    super.key,
    required this.jobs,
    required this.onSwipe,
  });

  @override
  ConsumerState<SwipeCardStack> createState() => SwipeCardStackState();
}

class SwipeCardStackState extends ConsumerState<SwipeCardStack>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dx = _dragOffset.dx;
    if (dx.abs() > 90) {
      // Threshold crossed: trigger swipe decision
      final isRight = dx > 0;
      final swipedJob = widget.jobs.first;

      // Reset drag offset and call callback (Optimistic UI removes top card)
      setState(() {
        _dragOffset = Offset.zero;
      });
      widget.onSwipe(swipedJob, isRight);
    } else {
      // Snap back if threshold not reached
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_outline, size: 64, color: AppColors.forestGreen),
              SizedBox(height: 16),
              Text(
                'You\'re all caught up!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for new matching job postings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Render 3 cards simultaneously: top card is interactive, bottom 2 decorative
            if (widget.jobs.length > 2)
              _buildBackgroundCard(widget.jobs[2], scale: 0.90, translateY: 30),
            if (widget.jobs.length > 1)
              _buildBackgroundCard(widget.jobs[1], scale: 0.95, translateY: 15),
            _buildTopCard(widget.jobs.first),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundCard(Job job,
      {required double scale, required double translateY}) {
    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          height: 480,
          child: JobCard(
            title: job.title,
            companyName: job.companyName,
            oneLinePitch: job.oneLinePitch,
            requiredSkills: job.requiredSkills,
            salaryMin: job.salaryMin,
            salaryMax: job.salaryMax,
            workStyle: job.workStyle,
            experienceLevel: job.experienceLevel,
            compatibilityScore: job.compatibilityScore,
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(Job job) {
    final rotationAngle = (_dragOffset.dx / 18) * (math.pi / 180);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotationAngle,
          child: SizedBox(
            height: 480,
            child: Stack(
              children: [
                JobCard(
                  title: job.title,
                  companyName: job.companyName,
                  oneLinePitch: job.oneLinePitch,
                  requiredSkills: job.requiredSkills,
                  salaryMin: job.salaryMin,
                  salaryMax: job.salaryMax,
                  workStyle: job.workStyle,
                  experienceLevel: job.experienceLevel,
                  compatibilityScore: job.compatibilityScore,
                ),
                // Stamp overlay indicator during drag
                if (_dragOffset.dx > 20)
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.forestGreen, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'APPLY',
                          style: TextStyle(
                            color: AppColors.forestGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_dragOffset.dx < -20)
                  Positioned(
                    top: 24,
                    right: 24,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.clayRed, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PASS',
                          style: TextStyle(
                            color: AppColors.clayRed,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Programmatic method exposed for widget tests
  void simulateDrag(double dx) {
    setState(() {
      _dragOffset = Offset(dx, 0);
    });
    _onPanEnd(DragEndDetails());
  }
}
