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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    final jobsProv = context.watch<JobsProvider>();
    final applications = jobsProv.currentApplications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidature Ricevute'),
      ),
      body: Column(
        children: [
          // Riepilogo annuncio selezionato
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.work_outline, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${applications.length} candidature pervenute (R7)',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Elenco Candidature (S3)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  jobsProv.fetchApplications(widget.job.id),
              child: jobsProv.isLoading && applications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_off_outlined,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text(
                                'Nessuna candidatura ricevuta per questa offerta.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: applications.length,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          itemBuilder: (ctx, index) {
                            final app = applications[index];
                            final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                                .format(app.createdAt);

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(
                                    app.firstName.isNotEmpty
                                        ? app.firstName[0].toUpperCase()
                                        : 'C',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  app.fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.email,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            app.email,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ricevuto: $formattedDate',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
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
    final app = widget.application;
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(app.createdAt);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Dettaglio Candidato (R7)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Dati Anagrafici
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person, color: Colors.blueAccent),
            title: const Text('Nome e Cognome'),
            subtitle: Text(
              app.fullName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email, color: Colors.blueAccent),
            title: const Text('Email del Candidato'),
            subtitle: Text(
              app.email,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time, color: Colors.blueAccent),
            title: const Text('Data Candidatura'),
            subtitle: Text(
              formattedDate,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const Divider(height: 24),

          // Sezione Curriculum Vitae
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Curriculum Allegato',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        app.cvOriginalName,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                  ? 'Download in corso...'
                  : 'Apri Curriculum Vitae (PDF)',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
