import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();

  String gender = "Male";
  String goal = "Muscle Gain";
  String activity = "Moderately Active";

  bool buttonHover = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isSubmitting = false;

  late AnimationController animationController;

  final Color orange = const Color(0xFFFF6B00);
  final Color darkBackground = const Color(0xFF0B1120);
  final Color fieldColor = const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    animationController.dispose();

    super.dispose();
  }

  Future<void> createAccount() async {
    final fullName = name.text.trim();
    final emailAddress = email.text.trim();

    if (fullName.isEmpty || emailAddress.isEmpty || password.text.isEmpty) {
      showMessage('Please fill in your name, email, and password.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailAddress)) {
      showMessage('Please enter a valid email address.');
      return;
    }
    if (password.text.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }
    if (password.text != confirmPassword.text) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() => isSubmitting = true);

    User? createdUser;
    var profileSaved = false;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password.text,
      );
      createdUser = credential.user;
      await createdUser!.updateDisplayName(fullName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(createdUser.uid)
          .set({
        'fullName': fullName,
        'email': emailAddress,
        'phone': phone.text.trim(),
        'gender': gender,
        'age': int.tryParse(age.text.trim()),
        'heightCm': double.tryParse(height.text.trim()),
        'weightKg': double.tryParse(weight.text.trim()),
        'fitnessGoal': goal,
        'activityLevel': activity,
        'createdAt': FieldValue.serverTimestamp(),
      });
      profileSaved = true;
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pop(context, emailAddress);
    } on FirebaseAuthException catch (error) {
      if (!profileSaved) {
        await _removeIncompleteAccount(createdUser);
      }
      debugPrint('Firebase Auth sign-up error: ${error.code}: ${error.message}');
      showMessage(_signupErrorMessage(error));
    } on FirebaseException catch (error) {
      if (!profileSaved) {
        await _removeIncompleteAccount(createdUser);
      }
      debugPrint('Firestore sign-up error: ${error.code}: ${error.message}');
      showMessage(_databaseErrorMessage(error));
    } catch (error) {
      if (!profileSaved) {
        await _removeIncompleteAccount(createdUser);
      }
      debugPrint('🔥 Unknown Signup Error: $error');
      showMessage('Signup Error: $error');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _removeIncompleteAccount(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (_) {
      // The original error is more useful to the user.
    }
  }

  void showMessage(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        content: Text(message),
      ),
    );
  }

  String _signupErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Enable Email/Password sign-in in Firebase first.';
      case 'network-request-failed':
        return 'Cannot reach Firebase. Check your internet connection.';
      default:
        return 'Account creation failed (${error.code}). ${error.message ?? ''}';
    }
  }

  String _databaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Database access is blocked. Add the Firestore rules first.';
      case 'unavailable':
        return 'Cannot reach the database. Check your internet connection.';
      case 'not-found':
        return 'Create the Firestore database in Firebase Console first.';
      default:
        return 'Could not save your profile: ${error.message ?? error.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: orange.withValues(alpha: 0.12),
                          boxShadow: [
                            BoxShadow(
                              color: orange.withValues(alpha: 0.25),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: orange,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Start Your Fitness Journey",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        "Create your profile and reach your goals",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // PERSONAL INFORMATION
                sectionTitle(
                  "Personal Information",
                  Icons.person_outline,
                ),

                const SizedBox(height: 15),

                buildField(
                  name,
                  "Full Name",
                  Icons.person_outline,
                ),

                const SizedBox(height: 14),

                buildField(
                  email,
                  "Email Address",
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                buildField(
                  phone,
                  "Phone Number",
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                buildPasswordField(
                  password,
                  "Password",
                  showPassword,
                  () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),

                const SizedBox(height: 14),

                buildPasswordField(
                  confirmPassword,
                  "Confirm Password",
                  showConfirmPassword,
                  () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // BODY INFORMATION
                sectionTitle(
                  "Body Information",
                  Icons.monitor_weight_outlined,
                ),

                const SizedBox(height: 15),

                buildDropdown(
                  label: "Gender",
                  icon: Icons.people_outline,
                  value: gender,
                  items: const [
                    "Male",
                    "Female",
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        gender = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: buildField(
                        age,
                        "Age",
                        Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: buildField(
                        height,
                        "Height (cm)",
                        Icons.height,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                buildField(
                  weight,
                  "Weight (kg)",
                  Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 30),

                // FITNESS INFORMATION
                sectionTitle(
                  "Fitness Preferences",
                  Icons.fitness_center_outlined,
                ),

                const SizedBox(height: 15),

                buildDropdown(
                  label: "Fitness Goal",
                  icon: Icons.fitness_center_outlined,
                  value: goal,
                  items: const [
                    "Weight Loss",
                    "Muscle Gain",
                    "Maintain Fitness",
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        goal = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 14),

                buildDropdown(
                  label: "Activity Level",
                  icon: Icons.directions_run_outlined,
                  value: activity,
                  items: const [
                    "Sedentary",
                    "Lightly Active",
                    "Moderately Active",
                    "Very Active",
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        activity = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 32),

                // CREATE ACCOUNT BUTTON
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      buttonHover = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      buttonHover = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    transform: Matrix4.translationValues(
                      0,
                      buttonHover ? -3 : 0,
                      0,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: orange.withValues(
                              alpha: buttonHover ? 0.45 : 0.20,
                            ),
                            blurRadius: buttonHover ? 25 : 12,
                            spreadRadius: buttonHover ? 2 : 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSubmitting)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else ...[
                              const Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: Text(
                    "By creating an account, you agree to our Terms & Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
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

  // SECTION TITLE
  Widget sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: orange,
            size: 19,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // TEXT FIELD
  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      cursorColor: orange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        floatingLabelStyle: TextStyle(
          color: orange,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: orange,
        ),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: orange.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // PASSWORD FIELD
  Widget buildPasswordField(
    TextEditingController controller,
    String label,
    bool visible,
    VoidCallback onPressed,
  ) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      cursorColor: orange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        floatingLabelStyle: TextStyle(
          color: orange,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: orange,
        ),
        suffixIcon: IconButton(
          onPressed: onPressed,
          icon: Icon(
            visible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white54,
          ),
        ),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: orange.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // DROPDOWN
  Widget buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      style: TextStyle(
        color: orange,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      dropdownColor: const Color(0xFF1F2937),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: orange,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        floatingLabelStyle: TextStyle(
          color: orange,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: orange,
        ),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: orange.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
      ),
      items: items.map(
        (item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
