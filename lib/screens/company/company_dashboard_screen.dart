import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jobs_provider.dart';
import '../public/jobs_board_screen.dart';
import 'create_job_screen.dart';
import 'job_applications_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().fetchCompanyJobs();
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma Logout'),
        content: const Text(
            'Sei sicuro di voler uscire dall\'area riservata aziendale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Esegue il logout (R3)
      await context.read<AuthProvider>().logout();
      if (mounted) {
        // Torna alla schermata pubblica eliminando la cronologia di navigazione (S3)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const JobsBoardScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobsProv = context.watch<JobsProvider>();
    final company = auth.currentCompany;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Riservata Azienda'),
        actions: [
          IconButton(
            tooltip: 'Logout (R3)',
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => jobsProv.fetchCompanyJobs(),
        child: Column(
          children: [
            // Scheda Profilo Aziendale
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (company?.name.isNotEmpty == true
                              ? company!.name[0]
                              : 'A')
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company?.name ?? 'Azienda Autenticata',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          company?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Intestazione Sezione "I miei annunci"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'I tuoi Annunci Pubblicati',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${jobsProv.companyJobs.length} annunci',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Lista Annunci Pubblicati dall'azienda (R7)
            Expanded(
              child: jobsProv.isLoading && jobsProv.companyJobs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : jobsProv.companyJobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.post_add,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text(
                                  'Non hai ancora pubblicato nessun annuncio.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateJobScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Pubblica il tuo primo annuncio'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: jobsProv.companyJobs.length,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          itemBuilder: (ctx, index) {
                            final job = jobsProv.companyJobs[index];
                            final formattedDate = DateFormat('dd/MM/yyyy')
                                .format(job.createdAt);

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Apre la schermata delle candidature per questo annuncio (S3)
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JobApplicationsScreen(job: job),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              job.title,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios,
                                              size: 16, color: Colors.grey),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        job.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[800]),
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Badge conteggio candidature (R7)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: job.applicationsCount > 0
                                                  ? Colors.green.shade50
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: job.applicationsCount > 0
                                                    ? Colors.green
                                                    : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.people_alt_outlined,
                                                  size: 16,
                                                  color: job.applicationsCount > 0
                                                      ? Colors.green.shade800
                                                      : Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${job.applicationsCount} candidature',
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: job.applicationsCount >
                                                            0
                                                        ? Colors.green.shade800
                                                        : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Creato: $formattedDate',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateJobScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Annuncio'),
      ),
    );
  }
}
