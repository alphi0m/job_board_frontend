import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/job.dart';
import 'apply_job_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(job.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Annuncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Azienda e Sede
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.business, size: 16),
                  label: Text(job.companyName),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.location_on, size: 16),
                  label: Text(job.location),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Data di pubblicazione: $formattedDate',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const Divider(height: 32),

            // Descrizione
            const Text(
              'Descrizione dell\'offerta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              job.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 80), // Spazio per il pulsante fisso in basso
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ApplyJobScreen(job: job),
              ),
            );
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.send_rounded),
          label: const Text(
            'Candidati a questo annuncio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
