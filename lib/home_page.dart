import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// Rimuovi: import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart'; // Importa AuthService

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'Utente'; // Valore di default
  final AuthService _authService = AuthService(); // Usa AuthService

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Recupera l'username dal servizio di autenticazione (che usa SharedPreferences)
    final currentUsername = await _authService.getCurrentUsername();
    if (currentUsername != null && mounted) {
      setState(() {
        username = currentUsername;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logoutUser(); // Usa il metodo di logout del servizio
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // ... il resto del widget build, _buildFeatureCard, e _buildSquareCard rimane invariato ...
  // Assicurati che il widget build e i metodi _buildFeatureCard, _buildSquareCard siano presenti
  // come nella versione precedente della home page.
  // Li ometto qui per brevità, ma sono necessari.
  @override
  Widget build(BuildContext context) {
    // Use the proper Material Design context from parent
    final theme = Theme.of(context);

    return Scaffold(
      // Add key background color for fallback
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        // Use a more contrasting gradient for better visibility
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDCE4F0), Color(0xFFB8C7DB)], // Darker gradient
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  // Logout button
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFF5E17EB)),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '5IC STARS',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5E17EB),
                      letterSpacing: 1.5,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome user
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.2,
                              ), // Increased opacity
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF4776E6),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Benvenuto,',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Section 1 - Game 1
                      _buildFeatureCard(
                        title: 'GIOCO 1',
                        icon: FontAwesomeIcons.gamepad,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          // Navigate to game 1
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon!')),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Section 2 - Game 2
                      _buildFeatureCard(
                        title: 'GIOCO 2',
                        icon: FontAwesomeIcons.dice,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          // Navigate to game 2
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon!')),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Section 3 - Memories
                      _buildFeatureCard(
                        title: 'RICORDI',
                        icon: FontAwesomeIcons.photoFilm,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        height: 180,
                        onTap: () {
                          // Navigate to memories section
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon!')),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Section 4 - Two square cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSquareCard(
                              title: 'CLASSIFICA',
                              icon: FontAwesomeIcons.trophy,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () {
                                // Navigate to ranking
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSquareCard(
                              title: 'INTERVIEW',
                              icon: FontAwesomeIcons.microphone,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF834D9B), Color(0xFFD04ED6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () {
                                // Navigate to interviews
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    double height = 150,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Increased shadow opacity
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative pattern
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                icon,
                size: 150,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(icon, size: 40, color: Colors.white),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
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

  Widget _buildSquareCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.2,
                ), // Increased shadow opacity
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: 32, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
