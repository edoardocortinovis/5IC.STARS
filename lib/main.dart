import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E17EB),
          brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE4EDF5)],
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),

                    // Sezione 1 - Gioco 1
                    _buildFeatureCard(
                      title: 'GIOCO 1',
                      icon: FontAwesomeIcons.gamepad,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    // Sezione 2 - Gioco 2
                    _buildFeatureCard(
                      title: 'GIOCO 2',
                      icon: FontAwesomeIcons.dice,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    // Sezione 3 - Ricordi
                    _buildFeatureCard(
                      title: 'RICORDI',
                      icon: FontAwesomeIcons.photoFilm,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      height: 180,
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    // Sezione 4 - Due card quadrate
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
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSquareCard(
                            title: 'NEWS',
                            icon: FontAwesomeIcons.newspaper,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF834D9B), Color(0xFFD04ED6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ]),
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern decorativo
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                icon,
                size: 150,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Contenuto principale
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Pattern decorativo
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              // Contenuto principale
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
