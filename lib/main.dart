import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Titolo centrato in alto
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: const Center(
                    child: Text(
                      '5IC STARS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sezione 1 - Card singola
                _buildSectionCard(
                  height: 150,
                  color: Colors.blue[100],
                  text: 'gioco 1',
                ),

                const SizedBox(height: 20),

                // Sezione 3 - Card singola
                _buildSectionCard(
                  height: 150,
                  color: const Color.fromARGB(255, 255, 0, 25),
                   icon: FaIcon(FontAwesomeIcons.gamepad, size: 40, color: Colors.white),
                ),

                const SizedBox(height: 20),

                // Sezione 2 - Card singola
                _buildSectionCard(
                  height: 200,
                  color: Colors.green[100],
                  text: 'RICORDI',
                ),

                const SizedBox(height: 20),

                // Sezione 3 - Due card quadrate
                Row(
                  children: [
                    Expanded(
                      child: _buildSquareCard(
                        color: Colors.orange[100],
                        text: 'CLASSIFICA',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSquareCard(
                        color: Colors.purple[100],
                        text: 'INTERVIEW',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Metodi _buildSectionCard e _buildSquareCard rimangono identici alla versione precedente
  Widget _buildSectionCard({
    required double height,
    required Color? color,
    required String text,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCard({required Color? color, required String text}) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
