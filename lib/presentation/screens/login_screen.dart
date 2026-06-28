import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/presentation/providers/auth_provider.dart';
import 'package:agriyouthconnect/presentation/screens/registration_screen.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_button.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_text_field.dart';

/// LoginScreen presents a sunlight-readable login form with interactive language options.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginFarmer(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.activeProfile?.role == 'ADMIN'
                  ? 'Welcome Admin!'
                  : 'Welcome back!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localeNotifier = LocaleProvider.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Contextual localization helpers
    final isEn = localeNotifier.locale.languageCode == 'en';
    final welcomeTitle = isEn ? 'Sign In' : 'Injira';
    final welcomeSubtitle = isEn 
        ? 'AgriYouthConnectAI farmer portal' 
        : 'AgriYouthConnectAI umuryango w\'abahinzi';
    final phoneLabel = isEn ? 'Phone Number' : 'Numero ya Telefoni';
    final passwordLabel = isEn ? 'Password' : 'Ijambo ry\'Ibanga';
    final registerPrompt = isEn ? 'Don\'t have an account?' : 'Ntabwo ufite konti?';
    final registerAction = isEn ? 'Register here' : 'Iyandikishe hano';
    final phoneHint = '+250788000000';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text(
          welcomeTitle,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // Prominent Language Toggle Switch
          Row(
            children: [
              Text(
                'EN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEn ? theme.colorScheme.primary : Colors.grey,
                ),
              ),
              Switch(
                value: !isEn,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: (value) {
                  localeNotifier.setLocale(Locale(value ? 'rw' : 'en'));
                },
              ),
              Text(
                'RW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !isEn ? theme.colorScheme.primary : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Header Details
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error Banner
                  if (authProvider.errorMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authProvider.errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Input Fields
                  CustomTextField(
                    controller: _phoneController,
                    labelText: phoneLabel,
                    hintText: phoneHint,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isEn ? 'Phone number is required.' : 'Telefoni irakenewe.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: passwordLabel,
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isEn ? 'Password is required.' : 'Ijambo ry\'ibanga rirakenewe.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Primary Action Button
                  if (authProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(strokeWidth: 4.0),
                      ),
                    )
                  else
                    CustomButton(
                      label: welcomeTitle.toUpperCase(),
                      onPressed: _handleLogin,
                    ),

                  const SizedBox(height: 28),

                  // Navigation Link Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$registerPrompt ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                        child: Text(
                          registerAction,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
