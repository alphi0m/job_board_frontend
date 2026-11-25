import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/job.dart';
import '../../providers/jobs_provider.dart';

class ApplyJobScreen extends StatefulWidget {
  final Job job;

  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  PlatformFile? _pickedFile;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickCvFile() async {
    setState(() => _isPickingFile = true);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        setState(() {
          _pickedFile = files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore selezione file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attenzione: Devi allegare il tuo Curriculum (PDF).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final fileBytes = await _pickedFile!.xFile.readAsBytes();
    if (!mounted) return;

    final jobsProv = context.read<JobsProvider>();
    final success = await jobsProv.applyToJob(
      jobId: widget.job.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      fileBytes: fileBytes,
      originalFilename: _pickedFile!.name,
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline,
              size: 56, color: Colors.green),
          title: const Text('Candidatura Inviata!'),
          content: Text(
            'Grazie ${_firstNameController.text.trim()}, la tua candidatura per "${widget.job.title}" presso ${widget.job.companyName} è stata registrata con successo con il tuo curriculum allegato.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Chiude dialog
                Navigator.of(context).pop(); // Torna indietro
              },
              child: const Text('Torna all\'annuncio'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jobsProv.errorMessage ?? 'Errore durante l\'invio'),
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
        title: const Text('Invia Candidatura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      const Icon(Icons.work, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              widget.job.companyName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'I tuoi dati personali (R6)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Nome
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Inserisci il tuo nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Cognome
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Cognome *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Inserisci il tuo cognome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Inserisci la tua email';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Inserisci un indirizzo email valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Allegato Curriculum (PDF)
              const Text(
                'Curriculum Vitae (PDF) *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _pickedFile != null ? Colors.green : Colors.grey.shade400,
                    width: _pickedFile != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _pickedFile != null
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.transparent,
                ),
                child: Column(
                  children: [
                    if (_pickedFile == null) ...[
                      const Icon(Icons.picture_as_pdf,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 8),
                      const Text(
                        'Nessun file selezionato',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Formati supportati: .pdf',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isPickingFile ? null : _pickCvFile,
                        icon: _isPickingFile
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: const Text('Seleziona File PDF'),
                      ),
                    ] else ...[
                      const Icon(Icons.check_circle,
                          size: 44, color: Colors.green),
                      const SizedBox(height: 6),
                      Text(
                        _pickedFile!.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${((_pickedFile!.lengthSync() ?? 0) / 1024).toStringAsFixed(1)} KB',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _pickCvFile,
                        icon: const Icon(Icons.sync, size: 18),
                        label: const Text('Cambia file PDF'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bottone di invio candidatura
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: jobsProv.isActionLoading
                      ? null
                      : _submitApplication,
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
                      : const Icon(Icons.send),
                  label: Text(
                    jobsProv.isActionLoading
                        ? 'Invio in corso...'
                        : 'Conferma e Invia Candidatura',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
