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
    final theme = Theme.of(context);
    final jobsProv = context.watch<JobsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Offerta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Crea Nuovo Annuncio di Lavoro',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Compila i campi per pubblicare la posizione lavorativa aperta sulla bacheca pubblica.',
                        style: TextStyle(fontSize: 13.5, color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 24),

                      // Titolo Annuncio
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titolo Posizione *',
                          hintText: 'es. Flutter Mobile Developer',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
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
                          labelText: 'Sede / Modalità',
                          hintText: 'es. Remoto, Salerno, Milano (Ibrido)',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Descrizione
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          labelText: 'Descrizione del Ruolo e Requisiti *',
                          hintText:
                              'Descrivi attività principali, competenze richieste, benefit e dettagli contrattuali...',
                          alignLabelWithHint: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'La descrizione è obbligatoria';
                          }
                          if (val.trim().length < 10) {
                            return 'Inserisci una descrizione di almeno 10 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Bottone di Pubblicazione (R4)
                      FilledButton.icon(
                        onPressed: jobsProv.isActionLoading ? null : _handleSubmit,
                        icon: jobsProv.isActionLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                          jobsProv.isActionLoading
                              ? 'Pubblicazione in corso...'
                              : 'Pubblica Annuncio sulla Bacheca',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
