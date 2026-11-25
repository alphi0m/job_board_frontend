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
            'Vuoi disconnetterti dall\'area aziendale e tornare alla schermata pubblica?'),
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
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const JobsBoardScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final jobsProv = context.watch<JobsProvider>();
    final company = auth.currentCompany;

    final totalApplications = jobsProv.companyJobs.fold<int>(
      0,
      (sum, item) => sum + item.applicationsCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Area Riservata Azienda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout (R3)',
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => jobsProv.fetchCompanyJobs(),
        child: Column(
          children: [
            // Scheda Profilo Aziendale con Statistiche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (company?.name.isNotEmpty == true ? company!.name[0] : 'A')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
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
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Badge statistici (Annunci pubblicati + Candidature ricevute)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${jobsProv.companyJobs.length}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Annunci attivi',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$totalApplications',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: totalApplications > 0 ? Colors.green.shade600 : null,
                                    ),
                                  ),
                                  Text(
                                    'Candidature totali',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Intestazione Sezione "I tuoi annunci"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'I tuoi Annunci di Lavoro',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${jobsProv.companyJobs.length} pubblicati',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
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
                                Icon(Icons.post_add_rounded, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 14),
                                const Text(
                                  'Nessun annuncio pubblicato finora.',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Crea la tua prima offerta per ricevere candidature.',
                                  style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                                ),
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const CreateJobScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Pubblica Nuovo Annuncio'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: jobsProv.companyJobs.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (ctx, index) {
                            final job = jobsProv.companyJobs[index];
                            final formattedDate = DateFormat('dd/MM/yyyy').format(job.createdAt);
                            final hasApplications = job.applicationsCount > 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => JobApplicationsScreen(job: job),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        job.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          height: 1.4,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                        ),
                                      ),
                                      const Divider(height: 22),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Badge conteggio candidature (R7)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: hasApplications
                                                  ? Colors.green.withValues(alpha: 0.12)
                                                  : theme.colorScheme.surfaceContainerHighest,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: hasApplications
                                                    ? Colors.green.shade400
                                                    : theme.colorScheme.outlineVariant,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.people_outline,
                                                  size: 15,
                                                  color: hasApplications
                                                      ? Colors.green.shade700
                                                      : theme.colorScheme.outline,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${job.applicationsCount} candidature',
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: hasApplications
                                                        ? Colors.green.shade700
                                                        : theme.colorScheme.outline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.outline,
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
