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
                  color: bluePrimary.withValues(alpha: 0.35),
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
                          color: blueSecondary.withValues(alpha: 0.2),
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
                                color: bluePrimary.withValues(alpha: 0.3),
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
                border: Border.all(color: purple.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
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
                        activeTrackColor: green.withValues(alpha: 0.3),
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
                            side: BorderSide(color: bluePrimary.withValues(alpha: 0.5)),
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
                                color: purple.withValues(alpha: 0.35),
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
                border: Border.all(color: purple.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
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
                                      ? purple.withValues(alpha: 0.18)
                                      : const Color(0xFF162436),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? purple
                                        : isGoalMet
                                            ? green.withValues(alpha: 0.6)
                                            : Colors.white12,
                                width: isSelected || isToday ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: purple.withValues(alpha: 0.4),
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
                                          ? green.withValues(alpha: isSelected ? 0.9 : 0.25)
                                          : blueSecondary.withValues(alpha: isSelected ? 0.9 : 0.25),
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
                border: Border.all(color: purple.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
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
                            color: purple.withValues(alpha: 0.35),
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
      bottomNavigationBar: _buildBottomNavigation(),
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
                      color: bluePrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: bluePrimary.withValues(alpha: 0.4)),
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
                              ? green.withValues(alpha: 0.5)
                              : cardBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: purple.withValues(alpha: 0.38),
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
                          color: isSelected ? Colors.white : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Glasses badge dot / text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withValues(alpha: 0.3)
                              : isGoalMet
                                  ? green.withValues(alpha: 0.22)
                                  : bluePrimary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$glasses",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isGoalMet
                                    ? green
                                    : bluePrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
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
  // WATER DROPLET SECTION (- DROPLET +)
  // ============================================================
  Widget _buildWaterDropletSection() {
    double fillPercentage = (currentGlasses / totalGlasses).clamp(0.0, 1.0);

    String dateLabel = "Today";
    final now = DateTime.now();
    if (_isSameDay(selectedDate, now)) {
      dateLabel = "Today";
    } else if (_isSameDay(selectedDate, now.subtract(const Duration(days: 1)))) {
      dateLabel = "Yesterday";
    } else {
      dateLabel = "${selectedDate.day} ${_monthAbbr(selectedDate.month)}";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // DECREMENT BUTTON (-)
        _circularControlButton(
          icon: Icons.remove_rounded,
          onTap: _decrementWater,
          enabled: currentGlasses > 0,
        ),

        const SizedBox(width: 16),

        // WATER DROPLET CONTAINER
        AnimatedBuilder(
          animation: _waveAnimationController,
          builder: (context, child) {
            return SizedBox(
              width: 210,
              height: 265,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  // WATER DROPLET PAINT & CLIPPER
                  CustomPaint(
                    painter: WaterDropPainter(
                      fillPercentage: fillPercentage,
                      waveValue: _waveAnimationController.value,
                      primaryColor: blueSecondary,
                      secondaryColor: blueDark,
                    ),
                  ),

                  // TEXT INSIDE DROPLET (High Contrast drop shadow)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 35),
                      // COUNTER WITH ANIMATION
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _countAnimationController,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: Text(
                          "$currentGlasses",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "of $totalGlasses glasses",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          dateLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        // INCREMENT BUTTON (+)
        _circularControlButton(
          icon: Icons.add_rounded,
          onTap: _incrementWater,
          enabled: true,
        ),
      ],
    );
  }

  String _monthAbbr(int month) {
    const m = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return m[month - 1];
  }

  // ============================================================
  // CIRCULAR CONTROL BUTTON (- / +)
  // ============================================================
  Widget _circularControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cardColor,
        border: Border.all(
          color: enabled ? bluePrimary.withValues(alpha: 0.35) : Colors.white12,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: enabled ? bluePrimary.withValues(alpha: 0.16) : Colors.transparent,
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white24,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTERACTIVE WATER REMINDER CARD WITH LIVE COUNTDOWN
  // ============================================================
  Widget _buildNextReminderCard() {
    return GestureDetector(
      onTap: _openReminderSettingsDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isReminderEnabled
                ? bluePrimary.withValues(alpha: 0.3)
                : Colors.white12,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isReminderEnabled
                  ? bluePrimary.withValues(alpha: 0.12)
                  : Colors.transparent,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReminderEnabled ? green : Colors.white30,
                        boxShadow: isReminderEnabled
                            ? [BoxShadow(color: green, blurRadius: 6)]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isReminderEnabled ? "WATER REMINDER (ACTIVE)" : "REMINDER DISABLED",
                      style: TextStyle(
                        color: isReminderEnabled ? green : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.settings_suggest_rounded,
                  color: isReminderEnabled ? purple : Colors.white38,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Live Countdown Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Next reminder in",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCountdownTime(reminderSecondsRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bluePrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bluePrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "Every ${reminderIntervalMinutes}m",
                    style: TextStyle(
                      color: bluePrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 6),

            // Action Row (Set Reminder & Test Notification)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _openReminderSettingsDialog,
                  child: Text(
                    "Configure Reminder ⏰",
                    style: TextStyle(
                      color: purple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showHydrationNotificationBanner,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.notifications_active_rounded, color: Color(0xFF00C6FF), size: 14),
                        SizedBox(width: 5),
                        Text(
                          "Test Notification 🔔",
                          style: TextStyle(
                            color: Color(0xFF00C6FF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GLASS ROW INDICATOR (8 glasses)
  // ============================================================
  Widget _buildGlassRowIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalGlasses, (index) {
            final bool isFilled = index < currentGlasses;
            return GestureDetector(
              onTap: () {
                _setGlassesForSelectedDate(index + 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isFilled ? bluePrimary.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFilled ? bluePrimary.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
                child: CustomPaint(
                  size: const Size(22, 32),
                  painter: GlassIconPainter(
                    isFilled: isFilled,
                    fillColor: blueSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // DAILY GOAL CARD (Matching HomePage's gradient card style)
  // ============================================================
  Widget _buildDailyGoalCard() {
    final double litersDrunk = (currentGlasses * 0.3125);
    final double litersTotal = (totalGlasses * 0.3125);

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
          color: purple.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daily Goal",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$currentGlasses / $totalGlasses glasses (${litersDrunk.toStringAsFixed(1)} / ${litersTotal.toStringAsFixed(1)} L)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _editGoalDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  "Edit Goal",
                  style: TextStyle(
                    color: purple,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY HISTORY CARD (Bar Chart & Day Breakdown)
  // ============================================================
  Widget _buildWeeklyHistoryCard() {
    final now = DateTime.now();
    final mondayOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final fullDayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    int totalWeekGlasses = 0;
    int daysGoalMet = 0;
    for (int i = 0; i < 7; i++) {
      final d = mondayOfThisWeek.add(Duration(days: i));
      final g = dailyWaterHistory[_formatDateKey(d)] ?? 0;
      totalWeekGlasses += g;
      if (g >= totalGlasses) daysGoalMet++;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Progress Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$daysGoalMet of 7 Days Completed 🏆",
                    style: TextStyle(
                      color: green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bluePrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bluePrimary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "Avg: ${(totalWeekGlasses / 7).toStringAsFixed(1)} glasses/day",
                  style: TextStyle(
                    color: bluePrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // BAR CHART WITH PERCENTAGE AND GLASSES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final date = mondayOfThisWeek.add(Duration(days: index));
              final glasses = dailyWaterHistory[_formatDateKey(date)] ?? 0;
              final double progressRatio = (glasses / totalGlasses).clamp(0.0, 1.0);
              final int percentage = (progressRatio * 100).round();
              final isSelected = _isSameDay(date, selectedDate);
              final isGoalMet = glasses >= totalGlasses;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  _countAnimationController.forward(from: 0);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Percentage / Glass label on top of bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isGoalMet
                            ? green.withValues(alpha: 0.2)
                            : isSelected
                                ? bluePrimary.withValues(alpha: 0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$percentage%",
                        style: TextStyle(
                          color: isGoalMet
                              ? green
                              : isSelected
                                  ? Colors.white
                                  : Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Bar height container
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Background track
                        Container(
                          width: 22,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Animated progress fill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 22,
                          height: (90 * progressRatio).clamp(6.0, 90.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isGoalMet
                                  ? [green, const Color(0xFF5DFFC6)]
                                  : isSelected
                                      ? [blueDark, blueSecondary]
                                      : [bluePrimary.withValues(alpha: 0.35), bluePrimary.withValues(alpha: 0.75)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected || isGoalMet
                                ? [
                                    BoxShadow(
                                      color: (isGoalMet ? green : bluePrimary).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fullDayNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$glasses/$totalGlasses",
                      style: TextStyle(
                        color: isSelected ? bluePrimary : Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          const Text(
            "Day-by-Day Progress Breakdown",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // LIST OF DAYS WITH PROGRESS BARS
          Column(
            children: List.generate(7, (index) {
              final date = mondayOfThisWeek.add(Duration(days: index));
              final dateKey = _formatDateKey(date);
              final glasses = dailyWaterHistory[dateKey] ?? 0;
              final double progressRatio = (glasses / totalGlasses).clamp(0.0, 1.0);
              final int percentage = (progressRatio * 100).round();
              final isSelected = _isSameDay(date, selectedDate);
              final isGoalMet = glasses >= totalGlasses;
              final dayFullNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  _countAnimationController.forward(from: 0);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? bluePrimary.withValues(alpha: 0.14)
                        : const Color(0xFF142030),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? bluePrimary.withValues(alpha: 0.45)
                          : isGoalMet
                              ? green.withValues(alpha: 0.35)
                              : Colors.white12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isGoalMet
                                    ? Icons.check_circle_rounded
                                    : Icons.water_drop_rounded,
                                color: isGoalMet ? green : bluePrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dayFullNames[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "(${date.day} ${_monthAbbr(date.month)})",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "$glasses / $totalGlasses glasses ($percentage%)",
                            style: TextStyle(
                              color: isGoalMet
                                  ? green
                                  : isSelected
                                      ? bluePrimary
                                      : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Indicator Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isGoalMet ? green : bluePrimary,
                          ),
                        ),
                      ),
                    ],
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
  // BOTTOM NAVIGATION BAR (Exact HomePage Bottom Nav)
  // ============================================================
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.only(top: 9, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF08131F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 25,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = (index == 0); // Home tab selected conceptually

    return GestureDetector(
      onTap: () {
        if (index == 0) {
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
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? purple : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 9,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              purple,
              const Color(0xFF8D4CFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: purple.withValues(alpha: 0.38),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _incrementWater,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WATER DROP PAINTER (Wave liquid fill & Droplet outline)
// ============================================================
class WaterDropPainter extends CustomPainter {
  final double fillPercentage;
  final double waveValue;
  final Color primaryColor;
  final Color secondaryColor;

  WaterDropPainter({
    required this.fillPercentage,
    required this.waveValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Build Water Drop Path
    Path dropPath = Path();
    dropPath.moveTo(width * 0.5, 5); // Tip top of drop
    dropPath.cubicTo(
      width * 0.85, height * 0.42,
      width, height * 0.68,
      width * 0.5, height - 5,
    ); // Right curve to bottom
    dropPath.cubicTo(
      0, height * 0.68,
      width * 0.15, height * 0.42,
      width * 0.5, 5,
    ); // Left curve to top
    dropPath.close();

    // Draw background drop container (glass dark outline fill)
    final bgPaint = Paint()
      ..color = const Color(0xFF0C1726)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropPath, bgPaint);

    // 2. Draw Liquid level inside clipped drop
    canvas.save();
    canvas.clipPath(dropPath);

    if (fillPercentage > 0.0) {
      double liquidTopY = height - (height * fillPercentage);

      Path wavePath = Path();
      wavePath.moveTo(0, liquidTopY);

      double waveFrequency = 2 * math.pi;
      double waveAmplitude = 6.0;

      for (double x = 0; x <= width; x += 2) {
        double y = liquidTopY +
            math.sin((x / width * waveFrequency) + (waveValue * 2 * math.pi)) *
                waveAmplitude;
        wavePath.lineTo(x, y);
      }

      wavePath.lineTo(width, height);
      wavePath.lineTo(0, height);
      wavePath.close();

      // Liquid Gradient
      final liquidGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor,
          secondaryColor,
        ],
      );

      final liquidPaint = Paint()
        ..shader = liquidGradient.createShader(Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(wavePath, liquidPaint);

      // Liquid Top Highlight Ripple
      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(wavePath, ripplePaint);

      // Draw subtle floating bubbles inside liquid
      final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.25);
      final random = math.Random(42);
      for (int i = 0; i < 5; i++) {
        double bx = (random.nextDouble() * 0.6 + 0.2) * width;
        double by = height - (random.nextDouble() * (height * fillPercentage * 0.8));
        double br = (random.nextDouble() * 3 + 2);
        canvas.drawCircle(Offset(bx, by), br, bubblePaint);
      }
    }

    canvas.restore();

    // 3. Drop Rim & Glow Border
    final borderPaint = Paint()
      ..color = const Color(0xFF4B9CFF).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(dropPath, borderPaint);

    // Highlights on drop edge for 3D glossy look
    Path highlightPath = Path();
    highlightPath.moveTo(width * 0.5, 12);
    highlightPath.cubicTo(
      width * 0.78, height * 0.4,
      width * 0.85, height * 0.55,
      width * 0.75, height * 0.75,
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant WaterDropPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.waveValue != waveValue;
  }
}

// ============================================================
// GLASS ICON PAINTER (Used in 8-glass row indicator)
// ============================================================
class GlassIconPainter extends CustomPainter {
  final bool isFilled;
  final Color fillColor;

  GlassIconPainter({
    required this.isFilled,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    Path glassPath = Path();
    glassPath.moveTo(2, 2);
    glassPath.lineTo(width - 2, 2);
    glassPath.lineTo(width - 4, height - 2);
    glassPath.lineTo(4, height - 2);
    glassPath.close();

    if (isFilled) {
      // Liquid inside glass
      Path liquidPath = Path();
      liquidPath.moveTo(3, height * 0.25);
      liquidPath.lineTo(width - 3, height * 0.25);
      liquidPath.lineTo(width - 4, height - 2);
      liquidPath.lineTo(4, height - 2);
      liquidPath.close();

      final liquidPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(liquidPath, liquidPaint);
    }

    final strokePaint = Paint()
      ..color = isFilled ? Colors.white : Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(glassPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant GlassIconPainter oldDelegate) {
    return oldDelegate.isFilled != isFilled;
  }
}
