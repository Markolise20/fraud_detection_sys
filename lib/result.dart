import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPage extends StatefulWidget {
  final String domain;
  final String status;
  final String message;
  final String customerCare;

  const ResultPage({
    super.key,
    required this.domain,
    required this.status,
    required this.message,
    required this.customerCare,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    final isSafe = widget.status == 'safe';
    final borderColor = isSafe
        ? const Color(0xFF22C55E)
        : const Color(0xFFF87171);
    final backgroundColor = isSafe
        ? const Color(0xFF0B2F1B)
        : const Color(0xFF2C1A1A);
    final iconColor = isSafe
        ? const Color(0xFF6EE7B7)
        : const Color(0xFFFECACA);
    final title = isSafe ? 'Looks Safe!' : 'Potential Threat!';
    final icon = isSafe ? Icons.shield : Icons.warning;

    return Column(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(alignment: Alignment.centerLeft),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, size: 60, color: borderColor),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Analysis for: "${widget.domain}"',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                /// Initial Assessment
                _buildCard(
                  icon: Icons.warning_amber_outlined,
                  title: 'Initial Assessment',
                  description: widget.message.isEmpty
                      ? 'No detailed assessment available.'
                      : widget.message,
                ),
                const SizedBox(height: 20),

                /// Detailed Explanation
                _buildCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Detailed Explanation',
                  description:
                      'Our AI analyzed the URL based on domain age, SSL status, and phishing patterns. ${widget.message}',
                ),
                const SizedBox(height: 20),

                /// Recommendation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.assignment_outlined, color: iconColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommendation',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSafe
                                  ? 'You can proceed to interact with this site. Always verify URLs and avoid unknown links.'
                                  : 'Avoid interacting with this site. It may be a phishing attempt. Contact support if needed.',
                              style: GoogleFonts.inter(
                                color: iconColor,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.customerCare.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Contact: ${widget.customerCare}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade300,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
