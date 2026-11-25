import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jobs_provider.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Remoto');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final jobsProv = context.read<JobsProvider>();
    final success = await jobsProv.createJob(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annuncio pubblicato con successo sulla bacheca!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jobsProv.errorMessage ?? 'Errore pubblicazione annuncio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsProv = context.watch<JobsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Nuovo Annuncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dettagli Offerta di Lavoro (R4)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Compila i campi sottostanti per pubblicare la posizione lavorativa aperta sulla bacheca pubblica.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Titolo Annuncio
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo Posizione *',
                  hintText: 'es. Flutter Mobile Developer Junior',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Il titolo dell\'annuncio è obbligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sede / Modalità
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Sede / Modalità di lavoro',
                  hintText: 'es. Remoto, Salerno, Milano (Ibrido)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Descrizione
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Descrizione Completa dell\'Offerta *',
                  hintText:
                      'Descrivi mansioni, requisiti richiesti, benefit e informazioni utili per i candidati...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'La descrizione dell\'annuncio è obbligatoria';
                  }
                  if (val.trim().length < 10) {
                    return 'La descrizione deve essere più dettagliata (almeno 10 caratteri)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bottone di Pubblicazione (R4)
              FilledButton.icon(
                onPressed: jobsProv.isActionLoading ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: jobsProv.isActionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  jobsProv.isActionLoading
                      ? 'Pubblicazione in corso...'
                      : 'Pubblica Annuncio sulla Bacheca',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
