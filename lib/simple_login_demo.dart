import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'form_page.dart';

class SimpleLoginPage extends StatefulWidget {
  const SimpleLoginPage({super.key});

  @override
  State<SimpleLoginPage> createState() => _SimpleLoginPageState();
}

class _SimpleLoginPageState extends State<SimpleLoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF050D17);
  static const Color cardColor = Color(0xFF101B29);

  static const Color blue = Color(0xFF4B8DFF);
  static const Color lightBlue = Color(0xFF63B3FF);

  static const Color purple = Color(0xFF7548D8);
  static const Color darkPurple = Color(0xFF4C317F);

  static const Color darkPink = Color(0xFFB94772);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ).timeout(const Duration(seconds: 15));
      final userName = credential.user!.displayName ??
          credential.user!.email?.split('@').first ??
          'User';

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),

          pageBuilder: (context, animation, secondaryAnimation) {
            return HomePage(userName: userName);
          },

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,

              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),

                child: child,
              ),
            );
          },
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login took too long. Check your internet and try again.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardColor,
          content: Text(_loginErrorMessage(error)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log in. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _loginErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ?? 'Could not log in. Please try again.';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Stack(
          children: [

            // ==================================================
            // BLUE GLOW
            // ==================================================

            Positioned(
              top: -150,
              right: -120,

              child: Container(
                width: 330,
                height: 330,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color:
                      blue.withValues(alpha: 0.10),
                ),
              ),
            ),

            // ==================================================
            // PURPLE GLOW
            // ==================================================

            Positioned(
              top: 180,
              left: -180,

              child: Container(
                width: 330,
                height: 330,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color:
                      purple.withValues(alpha: 0.07),
                ),
              ),
            ),

            // ==================================================
            // SUBTLE PINK GLOW
            // ==================================================

            Positioned(
              bottom: -180,
              right: -100,

              child: Container(
                width: 320,
                height: 320,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color:
                      darkPink.withValues(alpha: 0.045),
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Center(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 25,
                ),

                child: FadeTransition(
                  opacity: _fadeAnimation,

                  child: SlideTransition(
                    position: _slideAnimation,

                    child: Form(
                      key: _formKey,

                      child: Column(
                        children: [

                          // ====================================
                          // LOGO
                          // ====================================

                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0.75,
                              end: 1.0,
                            ),

                            duration:
                                const Duration(
                              milliseconds: 900,
                            ),

                            curve:
                                Curves.easeOutBack,

                            builder:
                                (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },

                            child: Container(
                              width: 88,
                              height: 88,

                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                  26,
                                ),

                                gradient:
                                    const LinearGradient(
                                  colors: [
                                    blue,
                                    purple,
                                  ],

                                  begin:
                                      Alignment.topLeft,

                                  end: Alignment
                                      .bottomRight,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: blue
                                        .withValues(
                                      alpha: 0.22,
                                    ),

                                    blurRadius: 30,

                                    spreadRadius: 2,
                                  ),
                                ],
                              ),

                              child: const Icon(
                                Icons
                                    .fitness_center_rounded,

                                color:
                                    Colors.white,

                                size: 44,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ====================================
                          // APP NAME
                          // ====================================

                          const Text(
                            'FitLife',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Your Fitness, Your Journey',

                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.48),

                              fontSize: 14,

                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(
                            height: 42,
                          ),

                          // ====================================
                          // WELCOME
                          // ====================================

                          const Align(
                            alignment:
                                Alignment.centerLeft,

                            child: Text(
                              'Welcome Back 👋',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          Align(
                            alignment:
                                Alignment.centerLeft,

                            child: Text(
                              'Login to continue your fitness journey',

                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.42),

                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 27,
                          ),

                          // ====================================
                          // EMAIL
                          // ====================================

                          _buildTextField(
                            controller:
                                _emailController,

                            label: 'Email',

                            hint:
                                'Enter your email',

                            icon:
                                Icons.email_outlined,

                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter email';
                              }

                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 17,
                          ),

                          // ====================================
                          // PASSWORD
                          // ====================================

                          _buildTextField(
                            controller:
                                _passwordController,

                            label: 'Password',

                            hint:
                                'Enter your password',

                            icon:
                                Icons.lock_outline_rounded,

                            obscureText:
                                _obscurePassword,

                            suffixIcon:
                                IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },

                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,

                                color:
                                    Colors.white38,
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please enter password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),

                          // ====================================
                          // FORGOT PASSWORD
                          // ====================================

                          Align(
                            alignment:
                                Alignment.centerRight,

                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        cardColor,

                                    content:
                                        const Text(
                                      'Forgot password feature coming soon',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },

                              child: const Text(
                                'Forgot Password?',

                                style: TextStyle(
                                  color: lightBlue,

                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 13,
                          ),

                          // ====================================
                          // LOGIN BUTTON
                          // ====================================

                          Container(
                            width:
                                double.infinity,

                            height: 55,

                            decoration:
                                BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                17,
                              ),

                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(0xFF3E79E8),
                                  Color(0xFF6546B8),
                                ],

                                begin:
                                    Alignment.centerLeft,

                                end: Alignment
                                    .centerRight,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: blue
                                      .withValues(
                                    alpha: 0.20,
                                  ),

                                  blurRadius: 22,

                                  offset:
                                      const Offset(
                                    0,
                                    8,
                                  ),
                                ),
                              ],
                            ),

                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : login,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.transparent,

                                disabledBackgroundColor:
                                    Colors.transparent,

                                shadowColor:
                                    Colors.transparent,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    17,
                                  ),
                                ),
                              ),

                              child:
                                  AnimatedSwitcher(
                                duration:
                                    const Duration(
                                  milliseconds: 250,
                                ),

                                child: _isLoading
                                    ? const SizedBox(
                                        width: 23,
                                        height: 23,

                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2.5,

                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,

                                        children: [
                                          Text(
                                            'Login',

                                            style:
                                                TextStyle(
                                              color:
                                                  Colors.white,

                                              fontSize:
                                                  17,

                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),

                                          SizedBox(
                                            width: 8,
                                          ),

                                          Icon(
                                            Icons
                                                .arrow_forward_rounded,

                                            color:
                                                Colors.white,

                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ====================================
                          // OR
                          // ====================================

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                ),

                                child: Text(
                                  'OR',

                                  style: TextStyle(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha: 0.25,
                                    ),

                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ====================================
                          // SIGN UP
                          // ====================================

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Text(
                                "Don't have an account?",

                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.42,
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: () async {
                                  final email = await Navigator.push<String>(
                                    context,

                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(
                                        milliseconds:
                                            500,
                                      ),

                                      pageBuilder:
                                          (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) {
                                        return const SignupPage();
                                      },

                                      transitionsBuilder:
                                          (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity:
                                              animation,

                                          child:
                                              child,
                                        );
                                      },
                                    ),
                                  );
                                  if (email != null && mounted) {
                                    setState(() => _emailController.text = email);
                                  }
                                },

                                child: const Text(
                                  'Sign Up',

                                  style: TextStyle(
                                    color: lightBlue,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            '© 2026 FitLife',

                            style: TextStyle(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.18,
                              ),

                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
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
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,

    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,

      obscureText: obscureText,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),

      cursorColor: lightBlue,

      validator: validator,

      decoration: InputDecoration(
        labelText: label,

        hintText: hint,

        labelStyle: TextStyle(
          color: Colors.white.withValues(
            alpha: 0.48,
          ),
        ),

        hintStyle: TextStyle(
          color: Colors.white.withValues(
            alpha: 0.22,
          ),
        ),

        prefixIcon: Icon(
          icon,

          color: blue,
        ),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: cardColor,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),

          borderSide: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.06,
            ),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),

          borderSide: const BorderSide(
            color: blue,
            width: 1.4,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),

          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),

          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}
