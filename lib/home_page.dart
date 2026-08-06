import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'food_scanner_page.dart';
import 'water_tracker_page.dart';

// ============================================================
// FOOD SCANNER PAGE
// ============================================================
// Make sure food_scanner_page.dart is inside the same lib folder.
//
// If it is inside another folder, for example:
// lib/pages/food_scanner_page.dart
//
// then change this to:
// import 'pages/food_scanner_page.dart';
// ============================================================

import 'food_scanner_page.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({
    super.key,
    required this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  final Color background = const Color(0xFF050D17);
  final Color cardColor = const Color(0xFF101B29);

  final Color purple = const Color(0xFFB05CFF);
  final Color pink = const Color(0xFFFF5F91);
  final Color green = const Color(0xFF25E6A0);
  final Color blue = const Color(0xFF4B9CFF);

  // ============================================================
  // VARIABLES
  // ============================================================

  int selectedIndex = 0;
  int currentSlide = 0;

  late AnimationController pageController;
  late AnimationController ringController;
  late AnimationController pulseController;

  late PageController sliderController;

  Timer? sliderTimer;

  // ============================================================
  // SLIDER DATA
  // ============================================================

  final List<Map<String, String>> sliderData = [
    {
      "image":
          "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80",
      "title": "Push Your Limits",
      "subtitle": "Every workout brings you closer to your best.",
      "button": "Keep Going",
    },
    {
      "image":
          "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80",
      "title": "Train Like A Pro",
      "subtitle": "Stay consistent. Stay strong. Stay focused.",
      "button": "Start Workout",
    },
    {
      "image":
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=1200&q=80",
      "title": "Build Your Strength",
      "subtitle": "Small progress every day creates big results.",
      "button": "View Plan",
    },
    {
      "image":
          "https://images.unsplash.com/photo-1517832207067-4db24a2ae47c?auto=format&fit=crop&w=1200&q=80",
      "title": "Stay Consistent",
      "subtitle": "Your future self will thank you for today's effort.",
      "button": "Let's Go",
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    sliderController = PageController(
      viewportFraction: 0.94,
    );

    pageController.forward();
    ringController.forward();

    // ==========================================================
    // AUTO SLIDER
    // ==========================================================

    sliderTimer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        if (!mounted) return;

        int nextPage = currentSlide + 1;

        if (nextPage >= sliderData.length) {
          nextPage = 0;
        }

        sliderController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    sliderTimer?.cancel();

    sliderController.dispose();

    pageController.dispose();
    ringController.dispose();
    pulseController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: pageController,
            curve: Curves.easeOut,
          ),

          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: pageController,
                curve: Curves.easeOutCubic,
              ),
            ),

            child: _buildBody(),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        25,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _buildTopBar(),

          const SizedBox(height: 25),

          _buildGreeting(),

          const SizedBox(height: 22),

          // ====================================================
          // IMAGE SLIDER
          // ====================================================

          _buildImageSlider(),

          const SizedBox(height: 25),

          // ====================================================
          // PROGRESS CARD
          // ====================================================

          _buildProgressCard(),

          const SizedBox(height: 25),

          // ====================================================
          // DAILY GOALS
          // ====================================================

          _buildSectionTitle("Daily Goals"),

          const SizedBox(height: 14),

          _buildDailyGoals(),

          const SizedBox(height: 25),

          // ====================================================
          // CALORIES
          // ====================================================

          _buildCaloriesCard(),

          const SizedBox(height: 25),

          // ====================================================
          // NEW FOOD SCANNER
          // ====================================================

          _buildFoodScannerCard(),

          const SizedBox(height: 25),

          // ====================================================
          // QUICK ACTIONS
          // ====================================================

          _buildQuickActions(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        _iconButton(
          Icons.menu_rounded,
          () {},
        ),

        _iconButton(
          Icons.notifications_none_rounded,
          () {},
        ),
      ],
    );
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(8),

          child: Icon(
            icon,
            color: Colors.white,
            size: 27,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  String getGreeting() {
    int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning 👋";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon 👋";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening 👋";
    } else {
      return "Good Night 🌙";
    }
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          getGreeting(),

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          widget.userName.isEmpty
              ? 'Guest'
              : widget.userName,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          "Let's crush your goals today!",

          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PREMIUM IMAGE SLIDER
  // ============================================================

  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 205,

          child: PageView.builder(
            controller: sliderController,

            itemCount: sliderData.length,

            onPageChanged: (index) {
              setState(() {
                currentSlide = index;
              });
            },

            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: sliderController,

                builder: (context, child) {
                  double scale = 1.0;

                  if (sliderController
                      .position
                      .haveDimensions) {
                    double page =
                        sliderController.page ??
                            currentSlide.toDouble();

                    double difference =
                        (page - index).abs();

                    scale = (1 -
                            (difference * 0.06))
                        .clamp(0.94, 1.0);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },

                child: _sliderCard(
                  sliderData[index],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // DOTS
        // ======================================================

        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: List.generate(
            sliderData.length,
            (index) {
              final bool active =
                  currentSlide == index;

              return AnimatedContainer(
                duration:
                    const Duration(milliseconds: 300),

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                ),

                width: active ? 24 : 7,
                height: 7,

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),

                  gradient: active
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFB05CFF),
                            Color(0xFFFF5F91),
                          ],
                        )
                      : null,

                  color: active
                      ? null
                      : Colors.white24,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SLIDER CARD
  // ============================================================

  Widget _sliderCard(
    Map<String, String> data,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 3,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),

        child: Stack(
          fit: StackFit.expand,

          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            Image.network(
              data["image"]!,

              fit: BoxFit.cover,

              loadingBuilder:
                  (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: cardColor,

                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB05CFF),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },

              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  color: cardColor,

                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white24,
                    size: 50,
                  ),
                );
              },
            ),

            // ==================================================
            // DARK GRADIENT
            // ==================================================

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,

                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.20),
                    const Color(0xFF050817)
                        .withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BOTTOM GRADIENT
            // ==================================================

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,

                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFFB8DDFF),
                          Color(0xFFFF75B4),
                        ],
                      ).createShader(bounds);
                    },

                    child: Text(
                      data["title"]!,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  SizedBox(
                    width: 210,

                    child: Text(
                      data["subtitle"]!,

                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // BUTTON
                  // =================================================

                  Material(
                    color: Colors.transparent,

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(30),

                      onTap: () {},

                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30),

                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFF8B4DFF),
                              Color(0xFFFF4F9A),
                            ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: purple
                                  .withValues(alpha: 0.30),

                              blurRadius: 15,
                            ),
                          ],
                        ),

                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Text(
                              data["button"]!,

                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 7),

                            const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SLIDE NUMBER
            // ==================================================

            Positioned(
              top: 14,
              right: 14,

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.black
                      .withValues(alpha: 0.35),

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.15),
                  ),
                ),

                child: Text(
                  "${currentSlide + 1} / ${sliderData.length}",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFF292442),
            Color(0xFF15192E),
          ],
        ),

        border: Border.all(
          color: purple.withValues(alpha: 0.08),
        ),

        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Today's Progress",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 15,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              AnimatedBuilder(
                animation: ringController,

                builder: (context, child) {
                  return SizedBox(
                    width: 112,
                    height: 112,

                    child: CustomPaint(
                      painter:
                          ProgressRingPainter(
                        progress:
                            0.78 *
                                ringController.value,

                        backgroundColor:
                            Colors.white
                                .withValues(alpha: 0.08),

                        purple: purple,
                        pink: pink,
                      ),

                      child: Center(
                        child: Text(
                          "${(78 * ringController.value).round()}%",

                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 25),

              Expanded(
                child: Column(
                  children: [
                    _progressRow(
                      "Calories",
                      "1286 / 1800 kcal",
                    ),

                    const SizedBox(height: 15),

                    _progressRow(
                      "Protein",
                      "86 / 120 g",
                    ),

                    const SizedBox(height: 15),

                    _progressRow(
                      "Workouts",
                      "45 / 60 min",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,

          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          "View All",

          style: TextStyle(
            color: purple,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DAILY GOALS
  // ============================================================

  Widget _buildDailyGoals() {
    return Row(
      children: [
        Expanded(
          child: _goalCard(
            Icons.directions_walk_rounded,
            "Steps",
            "8,246",
            "10,000",
            green,
            onTap: () {},
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _goalCard(
            Icons.fitness_center_rounded,
            "Workout",
            "45",
            "60 min",
            pink,
            onTap: () {},
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _goalCard(
            Icons.water_drop_rounded,
            "Water",
            "6",
            "8 glasses",
            blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WaterTrackerPage(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _goalCard(
            Icons.nightlight_round,
            "Sleep",
            "7.2",
            "8 hrs",
            purple,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _goalCard(
    IconData icon,
    String title,
    String value,
    String target,
    Color color, {
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),

      duration:
          const Duration(milliseconds: 700),

      curve: Curves.easeOutBack,

      builder:
          (context, animation, child) {
        return Transform.scale(
          scale: animation,

          child: Material(
            color: cardColor,

            borderRadius:
                BorderRadius.circular(17),

            child: InkWell(
              borderRadius:
                  BorderRadius.circular(17),

              onTap: onTap,

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 5,
                ),

                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      title,

                      style:
                          const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      value,

                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      target,

                      style:
                          const TextStyle(
                        color: Colors.white38,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CALORIES
  // ============================================================

  Widget _buildCaloriesCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(19),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white
              .withValues(alpha: 0.03),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Calories Summary",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
                size: 13,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,

                children: [
                  const Text(
                    "1286",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Text(
                    "kcal",

                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),

              const Text(
                "514 left",

                style: TextStyle(
                  color: Color(0xFF25E6A0),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: 1286 / 1800,

              minHeight: 6,

              backgroundColor:
                  Colors.white
                      .withValues(alpha: 0.07),

              valueColor:
                  AlwaysStoppedAnimation<Color>(
                green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOD SCANNER CARD
  // ============================================================

  Widget _buildFoodScannerCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
                const FoodScannerPage(),
          ),
        );
      },

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(23),

          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              Color(0xFF211C38),
              Color(0xFF111D2B),
            ],
          ),

          border: Border.all(
            color: Color(0xFFB05CFF),
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Color(0xFFB05CFF)
                      .withValues(alpha: 0.10),

              blurRadius: 25,

              spreadRadius: 1,
            ),
          ],
        ),

        child: Row(
          children: [
            // ==================================================
            // CAMERA ICON
            // ==================================================

            Container(
              height: 58,
              width: 58,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(17),

                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFFB05CFF),
                    Color(0xFFFF5F91),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Color(0xFFB05CFF)
                            .withValues(alpha: 0.30),

                    blurRadius: 15,
                  ),
                ],
              ),

              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            // ==================================================
            // TEXT
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Food Scanner",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Scan your food & discover nutrition",

                    style: TextStyle(
                      color:
                          Colors.white
                              .withValues(alpha: 0.55),

                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: const [
                      Icon(
                        Icons
                            .local_fire_department_rounded,

                        color:
                            Color(0xFFFFB52E),

                        size: 14,
                      ),

                      SizedBox(width: 4),

                      Text(
                        "Calories",

                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),

                      SizedBox(width: 12),

                      Icon(
                        Icons
                            .fitness_center_rounded,

                        color:
                            Color(0xFF25E6A0),

                        size: 14,
                      ),

                      SizedBox(width: 4),

                      Text(
                        "Protein",

                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // ARROW
            // ==================================================

            Container(
              height: 38,
              width: 38,

              decoration: BoxDecoration(
                color:
                    Colors.white
                        .withValues(alpha: 0.07),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .arrow_forward_ios_rounded,

                color: Colors.white70,

                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          "Quick Actions",

          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _quickAction(
                Icons.add_circle_outline,
                "Add Meal",
                purple,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _quickAction(
                Icons.fitness_center,
                "Workout",
                pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    Color color,
  ) {
    return Material(
      color: cardColor,

      borderRadius:
          BorderRadius.circular(18),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),

        onTap: () {},

        child: Padding(
          padding:
              const EdgeInsets.all(15),

          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color:
                      color.withValues(alpha: 0.13),

                  borderRadius:
                      BorderRadius.circular(11),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.only(
        top: 9,
        bottom: 8,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF08131F),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.40),

            blurRadius: 25,
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [
            _navItem(
              Icons.home_rounded,
              "Home",
              0,
            ),

            _navItem(
              Icons.receipt_long_outlined,
              "Plan",
              1,
            ),

            _addButton(),

            _navItem(
              Icons.bar_chart_rounded,
              "Progress",
              3,
            ),

            _navItem(
              Icons.person_outline_rounded,
              "Profile",
              4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int index,
  ) {
    final bool selected =
        selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1.0,

              duration:
                  const Duration(milliseconds: 200),

              child: Icon(
                icon,

                color: selected
                    ? purple
                    : Colors.white38,

                size: 24,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white38,

                fontSize: 9,

                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CENTER ADD BUTTON
  // ============================================================

  Widget _addButton() {
    return GestureDetector(
      onTap: () {
        // ------------------------------------------------------
        // For now this opens Food Scanner.
        // Later we can change this into a proper Quick Add menu.
        // ------------------------------------------------------

        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
                const FoodScannerPage(),
          ),
        );
      },

      child: AnimatedBuilder(
        animation: pulseController,

        builder: (context, child) {
          final double scale =
              1 +
              (pulseController.value * 0.04);

          return Transform.scale(
            scale: scale,

            child: Container(
              height: 52,
              width: 52,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFFB05CFF),
                    Color(0xFF8D4CFF),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        purple.withValues(alpha: 0.38),

                    blurRadius: 22,

                    spreadRadius: 2,
                  ),
                ],
              ),

              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PROGRESS RING PAINTER
// ============================================================

class ProgressRingPainter
    extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color purple;
  final Color pink;

  ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.purple,
    required this.pink,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2 - 9;

    final backgroundPaint =
        Paint()
          ..color =
              backgroundColor
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 9;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    final rect =
        Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final gradient =
        SweepGradient(
      startAngle:
          -math.pi / 2,

      endAngle:
          (math.pi * 2) -
              math.pi / 2,

      colors: [
        purple,
        pink,
      ],
    );

    final progressPaint =
        Paint()
          ..shader =
              gradient.createShader(rect)
          ..style =
              PaintingStyle.stroke
          ..strokeCap =
              StrokeCap.round
          ..strokeWidth = 9;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant ProgressRingPainter
        oldDelegate,
  ) {
    return oldDelegate.progress !=
            progress ||
        oldDelegate.purple != purple ||
        oldDelegate.pink != pink;
  }
}