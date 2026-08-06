import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_page.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage>
    with TickerProviderStateMixin {
  // ============================================================
  // DESIGN SYSTEM & COLORS (Strictly matched to home_page.dart)
  // ============================================================
  final Color background = const Color(0xFF050D17);
  final Color cardColor = const Color(0xFF101B29);
  final Color cardBorder = const Color(0xFF1A293D);

  final Color purple = const Color(0xFFB05CFF);
  final Color pink = const Color(0xFFFF5F91);
  final Color green = const Color(0xFF25E6A0);
  final Color bluePrimary = const Color(0xFF4B9CFF);
  final Color blueSecondary = const Color(0xFF00C6FF);
  final Color blueDark = const Color(0xFF0072FF);

  // ============================================================
  // STATE VARIABLES
  // ============================================================
  DateTime selectedDate = DateTime.now();
  int totalGlasses = 8;

  // REMINDER STATE VARIABLES
  bool isReminderEnabled = true;
  int reminderIntervalMinutes = 45;
  late int reminderSecondsRemaining;
  TimeOfDay reminderStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay reminderEndTime = const TimeOfDay(hour: 22, minute: 0);
  Timer? _reminderCountdownTimer;

  // Daily water history map: "YYYY-MM-DD" -> glasses drunk
  late Map<String, int> dailyWaterHistory;

  late AnimationController _pageAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _countAnimationController;

  @override
  void initState() {
    super.initState();

    reminderSecondsRemaining = reminderIntervalMinutes * 60;

    // Pre-populate realistic historical water data
    final now = DateTime.now();
    dailyWaterHistory = {
      _formatDateKey(now): 6,
      _formatDateKey(now.subtract(const Duration(days: 1))): 8,
      _formatDateKey(now.subtract(const Duration(days: 2))): 7,
      _formatDateKey(now.subtract(const Duration(days: 3))): 8,
      _formatDateKey(now.subtract(const Duration(days: 4))): 5,
      _formatDateKey(now.subtract(const Duration(days: 5))): 8,
      _formatDateKey(now.subtract(const Duration(days: 6))): 6,
      _formatDateKey(now.subtract(const Duration(days: 7))): 4,
      _formatDateKey(now.subtract(const Duration(days: 8))): 8,
      _formatDateKey(now.subtract(const Duration(days: 9))): 7,
    };

    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _countAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pageAnimationController.forward();
    _startReminderCountdown();
  }

  @override
  void dispose() {
    _reminderCountdownTimer?.cancel();
    _pageAnimationController.dispose();
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();
    _countAnimationController.dispose();
    super.dispose();
  }

  // ============================================================
  // REMINDER & NOTIFICATION CONTROLLER
  // ============================================================
  void _startReminderCountdown() {
    _reminderCountdownTimer?.cancel();
    if (!isReminderEnabled) return;

    _reminderCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (reminderSecondsRemaining > 0) {
          reminderSecondsRemaining--;
        } else {
          reminderSecondsRemaining = reminderIntervalMinutes * 60;
          _showHydrationNotificationBanner();
        }
      });
    });
  }

  String _formatCountdownTime(int totalSeconds) {
    if (!isReminderEnabled) return "Disabled";
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} min";
  }

  // Live Notification Banner Popup
  void _showHydrationNotificationBanner() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Hydration Notification",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF101B29),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: bluePrimary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: bluePrimary.withAlpha(90),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: blueSecondary.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.water_drop_rounded,
                          color: blueSecondary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Time to Drink Water! 🥤",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Stay hydrated! Take a glass to reach your daily goal of $totalGlasses glasses.",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: [blueSecondary, blueDark]),
                            boxShadow: [
                              BoxShadow(
                                color: bluePrimary.withAlpha(70),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _incrementWater();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  content: const Text(
                                    "Glass logged! Great job staying hydrated! 🥤✨",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              "Drink (+1 Glass)",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            reminderSecondsRemaining = 10 * 60; // Snooze 10m
                          });
                        },
                        child: const Text(
                          "Snooze 10m",
                          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
          child: child,
        );
      },
    );
  }

  // ============================================================
  // REMINDER SETTINGS DIALOG (Interval, Times & Switch)
  // ============================================================
  void _openReminderSettingsDialog() {
    bool tempEnabled = isReminderEnabled;
    int tempInterval = reminderIntervalMinutes;
    TimeOfDay tempStart = reminderStartTime;
    TimeOfDay tempEnd = reminderEndTime;

    final intervals = [15, 30, 45, 60, 90, 120];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF101B29),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: purple.withAlpha(60)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(200),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Title & Switch Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active_rounded, color: purple, size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "Water Reminder",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: tempEnabled,
                        activeColor: green,
                        activeTrackColor: green.withAlpha(70),
                        inactiveThumbColor: Colors.white38,
                        inactiveTrackColor: Colors.white10,
                        onChanged: (val) {
                          setModalState(() {
                            tempEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // Reminder Interval Chips
                  const Text(
                    "Reminder Frequency",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: intervals.map((min) {
                      final isSel = (tempInterval == min);
                      return ChoiceChip(
                        label: Text(
                          min >= 60 ? "${min ~/ 60} hour${min > 60 ? 's' : ''}" : "$min min",
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: purple,
                        backgroundColor: const Color(0xFF162436),
                        side: BorderSide(
                          color: isSel ? Colors.white : Colors.white12,
                        ),
                        onSelected: tempEnabled
                            ? (sel) {
                                if (sel) {
                                  setModalState(() {
                                    tempInterval = min;
                                  });
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  // Schedule Start/End Time Row
                  const Text(
                    "Reminder Schedule Window",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _timeTile(
                          context,
                          label: "Start Time",
                          time: tempStart,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: tempStart,
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempStart = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeTile(
                          context,
                          label: "End Time",
                          time: tempEnd,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: tempEnd,
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempEnd = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Action Buttons (Test Notification & Save)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: bluePrimary.withAlpha(128)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showHydrationNotificationBanner();
                          },
                          icon: Icon(Icons.notifications_active_rounded, color: bluePrimary, size: 20),
                          label: Text(
                            "Test Notification",
                            style: TextStyle(color: bluePrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: [purple, bluePrimary]),
                            boxShadow: [
                              BoxShadow(
                                color: purple.withAlpha(90),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isReminderEnabled = tempEnabled;
                                reminderIntervalMinutes = tempInterval;
                                reminderStartTime = tempStart;
                                reminderEndTime = tempEnd;
                                reminderSecondsRemaining = tempInterval * 60;
                              });
                              _startReminderCountdown();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: bluePrimary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  content: Text(
                                    "Reminder set for every $reminderIntervalMinutes minutes! ⏰",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Save Reminder",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _timeTile(BuildContext context, {required String label, required TimeOfDay time, required VoidCallback onTap}) {
    final formattedTime = time.format(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF162436),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Icon(Icons.access_time_rounded, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }

  // Helper to get YYYY-MM-DD string
  String _formatDateKey(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  // Get glasses drunk for current selected date
  int get currentGlasses {
    return dailyWaterHistory[_formatDateKey(selectedDate)] ?? 0;
  }

  // Update glasses drunk for current selected date
  void _setGlassesForSelectedDate(int count) {
    setState(() {
      dailyWaterHistory[_formatDateKey(selectedDate)] = count.clamp(0, 30);
    });
    _countAnimationController.forward(from: 0);
  }

  void _incrementWater() {
    _setGlassesForSelectedDate(currentGlasses + 1);
  }

  void _decrementWater() {
    if (currentGlasses > 0) {
      _setGlassesForSelectedDate(currentGlasses - 1);
    }
  }

  // Check if same date
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ============================================================
  // MONTHLY CALENDAR DIALOG (High Contrast Glass Sheet)
  // ============================================================
  void _openMonthlyCalendarDialog() {
    DateTime displayedMonth = DateTime(selectedDate.year, selectedDate.month, 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
            final firstWeekday = DateTime(displayedMonth.year, displayedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
            final monthNames = [
              "January", "February", "March", "April", "May", "June",
              "July", "August", "September", "October", "November", "December"
            ];

            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.74,
              decoration: BoxDecoration(
                color: const Color(0xFF101B29),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: purple.withAlpha(60)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(200),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Month Navigation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
                          });
                        },
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                      ),
                      Text(
                        "${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
                          });
                        },
                        icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Days of Week Row (High Contrast Labels)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                    ].map((d) => SizedBox(
                          width: 38,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )).toList(),
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 10),

                  // Calendar Grid
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: (firstWeekday - 1) + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday - 1) {
                          return const SizedBox();
                        }

                        final dayNum = index - (firstWeekday - 1) + 1;
                        final cellDate = DateTime(displayedMonth.year, displayedMonth.month, dayNum);
                        final dateKey = _formatDateKey(cellDate);
                        final glasses = dailyWaterHistory[dateKey] ?? 0;
                        final isSelected = _isSameDay(cellDate, selectedDate);
                        final isToday = _isSameDay(cellDate, DateTime.now());
                        final isGoalMet = glasses >= totalGlasses;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = cellDate;
                            });
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [purple, bluePrimary],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : isToday
                                      ? purple.withAlpha(50)
                                      : const Color(0xFF162436),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? purple
                                        : isGoalMet
                                            ? green.withAlpha(150)
                                            : Colors.white12,
                                width: isSelected || isToday ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: purple.withAlpha(100),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$dayNum",
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (glasses > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isGoalMet
                                          ? green.withAlpha(isSelected ? 230 : 64)
                                          : blueSecondary.withAlpha(isSelected ? 230 : 64),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "$glasses 🥤",
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EDIT GOAL DIALOG
  // ============================================================
  void _editGoalDialog() {
    int tempGoal = totalGlasses;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF101B29),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: purple.withAlpha(64)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(180),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Set Daily Goal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$tempGoal glasses (${(tempGoal * 0.3125).toStringAsFixed(1)} Liters)",
                    style: TextStyle(
                      color: bluePrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (tempGoal > 1) {
                            setModalState(() {
                              tempGoal--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 38),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        "$tempGoal",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {
                          if (tempGoal < 20) {
                            setModalState(() {
                              tempGoal++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [purple, bluePrimary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: purple.withAlpha(90),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            totalGlasses = tempGoal;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save Goal",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _pageAnimationController,
            curve: Curves.easeOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _pageAnimationController,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN BODY
  // ============================================================
  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTopBar(),
          const SizedBox(height: 20),
          _buildCalendarStripSection(),
          const SizedBox(height: 24),
          _buildWaterDropletSection(),
          const SizedBox(height: 24),
          _buildNextReminderCard(),
          const SizedBox(height: 24),
          _buildGlassRowIndicator(),
          const SizedBox(height: 24),
          _buildDailyGoalCard(),
          const SizedBox(height: 24),
          _buildWeeklyHistoryCard(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR (High Contrast Icons & Title)
  // ============================================================
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconButton(
          Icons.arrow_back_rounded,
          () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(userName: 'Alex'),
                ),
              );
            }
          },
        ),
        const Text(
          "Water Tracker",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            _iconButton(
              Icons.notifications_active_rounded,
              _openReminderSettingsDialog,
            ),
            _iconButton(
              Icons.calendar_month_rounded,
              _openMonthlyCalendarDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
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
            size: 26,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CALENDAR STRIP SECTION (Horizontal High Contrast Picker)
  // ============================================================
  Widget _buildCalendarStripSection() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final mondayOfThisWeek = now.subtract(Duration(days: currentWeekday - 1));

    final weekDates = List.generate(7, (index) => mondayOfThisWeek.add(Duration(days: index)));

    final monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    final dayAbbreviations = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
        // Month Header & Full Calendar Link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: purple, size: 17),
                const SizedBox(width: 8),
                Text(
                  "${monthNames[selectedDate.month - 1]} ${selectedDate.year}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_isSameDay(selectedDate, now)) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bluePrimary.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: bluePrimary.withAlpha(100)),
                    ),
                    child: const Text(
                      "TODAY",
                      style: TextStyle(
                        color: Color(0xFF4B9CFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            GestureDetector(
              onTap: _openMonthlyCalendarDialog,
              child: Text(
                "Full Calendar",
                style: TextStyle(
                  color: purple,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Horizontal Date Strip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDates.map((date) {
            final isSelected = _isSameDay(date, selectedDate);
            final dateKey = _formatDateKey(date);
            final glasses = dailyWaterHistory[dateKey] ?? 0;
            final isGoalMet = glasses >= totalGlasses;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  _countAnimationController.forward(from: 0);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [purple, bluePrimary],
                          )
                        : null,
                    color: isSelected ? null : cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : isGoalMet
                              ? green.withAlpha(128)
                              : cardBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: purple.withAlpha(97),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayAbbreviations[date.weekday - 1],
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${date.day}",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (glasses > 0)
                        Icon(
                          Icons.water_drop_rounded,
                          color: isSelected
                              ? Colors.white
                              : isGoalMet
                                  ? green
                                  : blueSecondary,
                          size: 13,
                        )
                      else
                        const Icon(Icons.circle_outlined, color: Colors.white12, size: 10),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // WATER DROPLET INTERACTIVE BUBBLE
  // ============================================================
  Widget _buildWaterDropletSection() {
    double progress = (currentGlasses / totalGlasses).clamp(0.0, 1.0);
    int percentage = (progress * 100).round();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outermost pulsing aura
            AnimatedBuilder(
              animation: _pulseAnimationController,
              builder: (context, child) {
                return Container(
                  width: 250 + (_pulseAnimationController.value * 22),
                  height: 250 + (_pulseAnimationController.value * 22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bluePrimary.withAlpha((20 - (_pulseAnimationController.value * 15)).round()),
                  ),
                );
              },
            ),

            // Middle glow ring
            Container(
              width: 234,
              height: 234,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: bluePrimary.withAlpha(40),
                  width: 3,
                ),
              ),
            ),

            // The main interactive droplet container
            ClipPath(
              clipper: _CircleClipper(),
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E31),
                  shape: BoxShape.circle,
                  border: Border.all(color: cardBorder, width: 2),
                ),
                child: Stack(
                  children: [
                    // Wave simulation layer
                    AnimatedBuilder(
                      animation: _waveAnimationController,
                      builder: (context, child) {
                        return Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: (210 - (progress * 210)), // controls fill height
                          child: CustomPaint(
                            size: const Size(210, 210),
                            painter: _WavePainter(
                              animationValue: _waveAnimationController.value,
                              waveColor: progress >= 1.0 ? green : blueSecondary,
                              waveDarkColor: progress >= 1.0 
                                  ? const Color(0xFF159960) 
                                  : blueDark,
                            ),
                          ),
                        );
                      },
                    ),

                    // Centered progress display text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_rounded,
                            color: progress > 0.45 ? Colors.white : blueSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 5),
                          AnimatedBuilder(
                            animation: _countAnimationController,
                            builder: (context, child) {
                              // Mini scale bounce on increment
                              final scale = 1.0 + (math.sin(_countAnimationController.value * math.pi) * 0.15);
                              return Transform.scale(
                                scale: scale,
                                child: Text(
                                  "$percentage%",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withAlpha(128),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            "$currentGlasses / $totalGlasses glasses",
                            style: TextStyle(
                              color: progress > 0.45 ? Colors.white.withAlpha(204) : Colors.white.withAlpha(138),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${(currentGlasses * 0.3125).toStringAsFixed(2)}L / ${(totalGlasses * 0.3125).toStringAsFixed(1)}L",
                            style: TextStyle(
                              color: progress > 0.45 ? Colors.white.withAlpha(153) : Colors.white.withAlpha(97),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Floating Control Buttons (Minus & Plus)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus Button
            _circleControlBtn(
              icon: Icons.remove_rounded,
              color: pink,
              onTap: _decrementWater,
            ),
            const SizedBox(width: 32),

            // Quick Add 1 Glass Big Button
            GestureDetector(
              onTap: () {
                _incrementWater();
                // Play subtle feedback snackbar at goal
                if (currentGlasses + 1 == totalGlasses) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      content: const Text(
                        "Congratulations! Daily Water Goal Achieved! 🏆💧✨",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: currentGlasses >= totalGlasses ? [green, const Color(0xFF159960)] : [blueSecondary, blueDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (currentGlasses >= totalGlasses ? green : blueSecondary).withAlpha(100),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      "Add 1 Glass",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 32),

            // Plus Custom Set Button
            _circleControlBtn(
              icon: Icons.add_rounded,
              color: green,
              onTap: _incrementWater,
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleControlBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cardColor,
          border: Border.all(color: color.withAlpha(100), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(25),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  // ============================================================
  // REMINDER CARD
  // ============================================================
  Widget _buildNextReminderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: purple.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: purple,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Next Reminder In",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatCountdownTime(reminderSecondsRemaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: purple.withAlpha(128)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: _openReminderSettingsDialog,
            child: Text(
              "Set Alert",
              style: TextStyle(
                color: purple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INDIVIDUAL GLASS ROW INDICATOR
  // ============================================================
  Widget _buildGlassRowIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Drink Progress Map",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Goal: $totalGlasses",
                style: TextStyle(
                  color: bluePrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid-like layout representing glasses
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: List.generate(totalGlasses.clamp(1, 20), (index) {
              final isDrunk = index < currentGlasses;
              return GestureDetector(
                onTap: () {
                  _setGlassesForSelectedDate(index + 1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDrunk 
                        ? (currentGlasses >= totalGlasses ? green.withAlpha(50) : blueSecondary.withAlpha(50)) 
                        : const Color(0xFF162436),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDrunk 
                          ? (currentGlasses >= totalGlasses ? green : blueSecondary) 
                          : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: isDrunk 
                          ? (currentGlasses >= totalGlasses ? green : blueSecondary) 
                          : Colors.white24,
                      size: 18,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GOAL ADJUST CARD
  // ============================================================
  Widget _buildDailyGoalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: green.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.track_changes_rounded, color: green, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Intake Target",
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "$totalGlasses Glasses / ${(totalGlasses * 0.3125).toStringAsFixed(1)}L",
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: _editGoalDialog,
            icon: const Icon(Icons.edit_rounded, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY PROGRESS BAR GRAPH
  // ============================================================
  Widget _buildWeeklyHistoryCard() {
    final now = DateTime.now();
    final List<DateTime> weekDays = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    final weekLabels = ["M", "T", "W", "T", "F", "S", "S"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Analytics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final day = weekDays[index];
              final key = _formatDateKey(day);
              final count = dailyWaterHistory[key] ?? 0;
              final maxGoal = totalGlasses;
              final double percent = (count / maxGoal).clamp(0.0, 1.2);
              final isToday = _isSameDay(day, now);

              return Column(
                children: [
                  // Numeric Indicator above bar
                  Text(
                    "$count",
                    style: TextStyle(
                      color: isToday ? purple : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // The graph bar
                  Container(
                    width: 14,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF162436),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Filled part
                        Container(
                          width: 14,
                          height: 110 * percent,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: percent >= 1.0 
                                  ? [green, const Color(0xFF159960)] 
                                  : [blueSecondary, blueDark],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Weekday Label
                  Text(
                    weekLabels[day.weekday - 1],
                    style: TextStyle(
                      color: isToday ? purple : Colors.white54,
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CUSTOM WAVE SIMULATION PAINTER
// ============================================================
class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final Color waveDarkColor;

  _WavePainter({
    required this.animationValue,
    required this.waveColor,
    required this.waveDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final darkWavePaint = Paint()
      ..color = waveDarkColor.withAlpha(160)
      ..style = PaintingStyle.fill;

    final path = Path();
    final backPath = Path();

    // Amplitude & Frequency of Wave
    double amplitude = 8.0;
    double frequency = 2 * math.pi / size.width;

    path.moveTo(0, size.height);
    backPath.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      // Front Wave
      double yFront = amplitude * math.sin((x * frequency) + (animationValue * 2 * math.pi));
      path.lineTo(x, yFront);

      // Back Wave (Phase shifted)
      double yBack = amplitude * math.cos((x * frequency) - (animationValue * 2 * math.pi) + (math.pi / 4));
      backPath.lineTo(x, yBack);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    backPath.lineTo(size.width, size.height);
    backPath.lineTo(0, size.height);

    // Draw background/dark wave first
    canvas.drawPath(backPath, darkWavePaint);
    // Draw foreground wave second
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Circle clipping helper
class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
