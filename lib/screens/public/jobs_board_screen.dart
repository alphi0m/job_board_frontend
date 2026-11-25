import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jobs_provider.dart';
import '../../providers/theme_provider.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final jobsProv = context.watch<JobsProvider>();
    final themeProv = context.watch<ThemeProvider>();

    final filteredJobs = jobsProv.publicJobs.where((job) {
      final q = _searchQuery.toLowerCase();
      return job.title.toLowerCase().contains(q) ||
          job.companyName.toLowerCase().contains(q) ||
          job.location.toLowerCase().contains(q) ||
          job.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bacheca Annunci',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Switcher Tema Light/Dark
          IconButton(
            tooltip: 'Cambia Tema',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeProv.toggleTheme(context),
          ),
          // Configurazione IP Server
          IconButton(
            tooltip: 'Impostazioni Rete',
            icon: const Icon(Icons.settings_ethernet),
            onPressed: () => ServerConfigDialog.show(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 4.0),
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
                : FilledButton.icon(
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
          // Banner Informativo Candidato
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Trova la tua opportunità lavorativa. Candidati liberamente senza registrazione!',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Campo di Ricerca Moderno
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca annunci per posizione, azienda o città...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Elenco Annunci Pubblici (R5)
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
                                const Icon(Icons.cloud_off_rounded, size: 54, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  jobsProv.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: theme.colorScheme.error),
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
                                  Icon(Icons.work_outline, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'Nessun annuncio presente al momento.'
                                        : 'Nessun risultato corrispondente.',
                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredJobs.length,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemBuilder: (ctx, index) {
                                final job = filteredJobs[index];
                                final formattedDate = DateFormat('dd/MM/yyyy').format(job.createdAt);

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => JobDetailScreen(job: job),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Avatar Iniziale Azienda
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primaryContainer,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  (job.companyName.isNotEmpty ? job.companyName[0] : 'A').toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      job.title,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      job.companyName,
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.w500,
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            job.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              height: 1.4,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Badge info
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.location_on_outlined, size: 13, color: theme.colorScheme.secondary),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      job.location,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: theme.colorScheme.onSecondaryContainer,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
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
          ),
        ],
      ),
    );
  }
}
