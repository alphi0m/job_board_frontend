import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jobs_provider.dart';
import '../../widgets/server_config_dialog.dart';
import '../auth/login_screen.dart';
import '../company/company_dashboard_screen.dart';
import 'job_detail_screen.dart';

class JobsBoardScreen extends StatefulWidget {
  const JobsBoardScreen({super.key});

  @override
  State<JobsBoardScreen> createState() => _JobsBoardScreenState();
}

class _JobsBoardScreenState extends State<JobsBoardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().fetchPublicJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobsProv = context.watch<JobsProvider>();

    final filteredJobs = jobsProv.publicJobs.where((job) {
      final q = _searchQuery.toLowerCase();
      return job.title.toLowerCase().contains(q) ||
          job.companyName.toLowerCase().contains(q) ||
          job.location.toLowerCase().contains(q) ||
          job.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca Annunci'),
        actions: [
          IconButton(
            tooltip: 'Configura Server',
            icon: const Icon(Icons.settings_ethernet),
            onPressed: () => ServerConfigDialog.show(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: auth.isAuthenticated
                ? FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CompanyDashboardScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.business_center, size: 18),
                    label: Text(auth.currentCompany?.name ?? 'Area Azienda'),
                  )
                : OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.business, size: 18),
                    label: const Text('Area Aziende'),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo Candidato
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Trova il tuo lavoro ideale. Candidati liberamente senza registrazione!',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Campo di Ricerca
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca per titolo, azienda o città...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Lista Annunci Pubblici (R5)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => jobsProv.fetchPublicJobs(),
              child: jobsProv.isLoading && jobsProv.publicJobs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : jobsProv.errorMessage != null && jobsProv.publicJobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_off,
                                    size: 56, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  jobsProv.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () => jobsProv.fetchPublicJobs(),
                                  child: const Text('Riprova'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredJobs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.work_outline,
                                      size: 56, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'Nessun annuncio pubblicato al momento.'
                                        : 'Nessun annuncio corrisponde alla ricerca.',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredJobs.length,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              itemBuilder: (ctx, index) {
                                final job = filteredJobs[index];
                                final formattedDate =
                                    DateFormat('dd/MM/yyyy')
                                        .format(job.createdAt);

                                return Card(
                                  elevation: 1,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              JobDetailScreen(job: job),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  job.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                  Icons.chevron_right,
                                                  color: Colors.grey),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.business,
                                                  size: 16,
                                                  color: Colors.blueGrey),
                                              const SizedBox(width: 4),
                                              Text(
                                                job.companyName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Colors.blueGrey),
                                              const SizedBox(width: 4),
                                              Text(
                                                job.location,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            job.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87),
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              'Pubblicato il $formattedDate',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
