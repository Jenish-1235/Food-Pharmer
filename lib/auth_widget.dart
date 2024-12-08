import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> with TickerProviderStateMixin {
  late TabController _tabBarController;

  // Controllers for Sign In
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Controllers for Sign Up
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  bool _signInPasswordVisible = false;
  bool _signUpPasswordVisible = false;
  bool _signUpConfirmPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please enter your email and password.');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _navigateToHome();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _signUpWithEmail() async {
    final email = _signUpEmailController.text.trim();
    final password = _signUpPasswordController.text.trim();
    final confirmPassword = _signUpConfirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('Please fill out all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Passwords do not match.');
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _navigateToHome();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _navigateToHome() {
    // Replace HomePageWidget() with your own home screen widget
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePageWidget()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildEmailTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        contentPadding: const EdgeInsets.all(24),
      ),
    );
  }

  Widget _buildPasswordTextField(
      TextEditingController controller,
      String label,
      bool visible,
      VoidCallback toggleVisibility,
      ) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        contentPadding: const EdgeInsets.all(24),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 44),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 602),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Food Pharmer',
                        style: theme.textTheme.headline6?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 700,
                      constraints: const BoxConstraints(maxWidth: 602),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TabBar(
                              controller: _tabBarController,
                              isScrollable: true,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              labelPadding: const EdgeInsets.all(16),
                              indicatorColor: theme.primaryColor,
                              tabs: const [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabBarController,
                              children: [
                                // Sign In Tab
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        "Let's get started by filling out the form below.",
                                        style: theme.textTheme.bodyText2?.copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildEmailTextField(
                                          _signInEmailController, 'Email'),
                                      const SizedBox(height: 16),
                                      _buildPasswordTextField(
                                        _signInPasswordController,
                                        'Password',
                                        _signInPasswordVisible,
                                            () => setState(() {
                                          _signInPasswordVisible =
                                          !_signInPasswordVisible;
                                        }),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: _signInWithEmail,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(40),
                                            ),
                                            minimumSize: const Size(230, 52),
                                          ),
                                          child: const Text('Sign In'),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            // Implement Forgot Password logic if needed
                                          },
                                          child: const Text('Forgot Password'),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: Text(
                                          'Or sign in with',
                                          style: theme.textTheme.bodyText2?.copyWith(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: _signInWithGoogle,
                                          icon: const FaIcon(FontAwesomeIcons.google),
                                          label: const Text('Continue with Google'),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            onPrimary: Colors.black,
                                            side: const BorderSide(
                                                color: Color(0xFFE0E3E7), width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(40),
                                            ),
                                            minimumSize: const Size(230, 44),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Sign Up Tab
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        "Let's get started by filling out the form below.",
                                        style: theme.textTheme.bodyText2?.copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildEmailTextField(
                                          _signUpEmailController, 'Email'),
                                      const SizedBox(height: 16),
                                      _buildPasswordTextField(
                                        _signUpPasswordController,
                                        'Password',
                                        _signUpPasswordVisible,
                                            () => setState(() {
                                          _signUpPasswordVisible =
                                          !_signUpPasswordVisible;
                                        }),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPasswordTextField(
                                        _signUpConfirmPasswordController,
                                        'Confirm Password',
                                        _signUpConfirmPasswordVisible,
                                            () => setState(() {
                                          _signUpConfirmPasswordVisible =
                                          !_signUpConfirmPasswordVisible;
                                        }),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: _signUpWithEmail,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(40),
                                            ),
                                            minimumSize: const Size(230, 52),
                                          ),
                                          child: const Text('Create Account'),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: Text(
                                          'Or sign up with',
                                          style: theme.textTheme.bodyText2?.copyWith(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: _signInWithGoogle,
                                          icon: const FaIcon(FontAwesomeIcons.google),
                                          label:
                                          const Text('Continue with Google'),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            onPrimary: Colors.black,
                                            side: const BorderSide(
                                                color: Color(0xFFE0E3E7), width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(40),
                                            ),
                                            minimumSize: const Size(230, 44),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // If you don't need a side image for larger screens, remove this.
            // Otherwise, add a second Expanded widget with a background image here if desired.
          ],
        ),
      ),
    );
  }
}

// Placeholder for your home page, replace with your actual home widget.
class HomePageWidget extends StatelessWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Home Page')),
    );
  }
}
