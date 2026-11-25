import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/job.dart';
import '../../models/application.dart';
import '../../providers/jobs_provider.dart';

class JobApplicationsScreen extends StatefulWidget {
  final Job job;

  const JobApplicationsScreen({super.key, required this.job});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().fetchApplications(widget.job.id);
    });
  }

  void _showCandidateDetail(CandidateApplication application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _CandidateDetailBottomSheet(
          application: application,
          jobTitle: widget.job.title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobsProv = context.watch<JobsProvider>();
    final applications = jobsProv.currentApplications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidature Ricevute'),
      ),
      body: Column(
        children: [
          // Riepilogo annuncio selezionato
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.work_outline, color: theme.colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${applications.length} candidature pervenute (R7)',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Elenco Candidature (S3)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => jobsProv.fetchApplications(widget.job.id),
              child: jobsProv.isLoading && applications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off_outlined, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'Nessuna candidatura ricevuta per questa offerta.',
                                style: TextStyle(fontSize: 15, color: theme.colorScheme.outline),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: applications.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (ctx, index) {
                            final app = applications[index];
                            final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(app.createdAt);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(
                                    app.firstName.isNotEmpty ? app.firstName[0].toUpperCase() : 'C',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  app.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Text(
                                      app.email,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ricevuta il $formattedDate',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
                                onTap: () => _showCandidateDetail(app),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateDetailBottomSheet extends StatefulWidget {
  final CandidateApplication application;
  final String jobTitle;

  const _CandidateDetailBottomSheet({
    required this.application,
    required this.jobTitle,
  });

  @override
  State<_CandidateDetailBottomSheet> createState() =>
      _CandidateDetailBottomSheetState();
}

class _CandidateDetailBottomSheetState
    extends State<_CandidateDetailBottomSheet> {
  bool _isOpeningPdf = false;

  Future<void> _openCv() async {
    setState(() => _isOpeningPdf = true);
    final jobsProv = context.read<JobsProvider>();
    final success = await jobsProv.openCandidateCv(widget.application);
    if (mounted) {
      setState(() => _isOpeningPdf = false);
      if (!success && jobsProv.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jobsProv.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = widget.application;
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(app.createdAt);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Dettaglio Candidatura (R7)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Dati Anagrafici
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
            title: const Text('Candidato'),
            subtitle: Text(
              app.fullName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
            title: const Text('Email'),
            subtitle: Text(
              app.email,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
            title: const Text('Data di invio'),
            subtitle: Text(
              formattedDate,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Divider(height: 24),

          // Sezione Curriculum Vitae Allegato
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Curriculum Vitae',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        app.cvOriginalName,
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tasto per visualizzare il CV PDF (Scenario S3)
          FilledButton.icon(
            onPressed: _isOpeningPdf ? null : _openCv,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.redAccent.shade700,
            ),
            icon: _isOpeningPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.file_open_rounded),
            label: Text(
              _isOpeningPdf
                  ? 'Apertura in corso...'
                  : 'Apri Curriculum Vitae (PDF)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
