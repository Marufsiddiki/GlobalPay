import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../models/worker.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class DocumentsCenterScreen extends StatefulWidget {
  const DocumentsCenterScreen({super.key});

  @override
  State<DocumentsCenterScreen> createState() => _DocumentsCenterScreenState();
}

class _DocumentsCenterScreenState extends State<DocumentsCenterScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isAdmin) {
      return const AppScaffold(
        title: 'Access restricted',
        child: Center(child: Text('Only a company admin can view all documents.')),
      );
    }

    final query = _query.trim().toLowerCase();
    final documents = [
      for (final worker in state.workers)
        for (final document in worker.uploadedDocuments)
          if (query.isEmpty ||
              document.name.toLowerCase().contains(query) ||
              document.type.toLowerCase().contains(query) ||
              worker.name.toLowerCase().contains(query) ||
              worker.country.toLowerCase().contains(query))
            (worker: worker, document: document),
    ];
    const groups = [
      ('Identity documents', 'National ID'),
      ('Tax documents', 'Tax Form'),
      ('Contracts', 'Contract'),
    ];

    return AppScaffold(
      title: 'Documents',
      currentTab: 2,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search workers or documents',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 18),
          if (documents.isEmpty)
            SurfaceCard(
              child: Column(
                children: [
                  const Icon(Icons.folder_open_outlined, color: green, size: 32),
                  const SizedBox(height: 10),
                  Text(
                    query.isEmpty ? 'No documents uploaded yet' : 'No matches',
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    query.isEmpty
                        ? 'Documents uploaded while adding a worker will appear here.'
                        : 'Try a different worker or document name.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted, height: 1.4),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              '${documents.length} document${documents.length == 1 ? '' : 's'}',
              style: const TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            for (final group in groups)
              if (documents.any((item) => item.document.type == group.$2)) ...[
                Text(
                  group.$1,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final item in documents.where(
                  (item) => item.document.type == group.$2,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _documentCard(item.worker, item.document),
                  ),
              ],
          ],
        ],
      ),
    );
  }

  Widget _documentCard(Worker worker, PayrollDocument document) {
    return SurfaceCard(
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${worker.name} · ${worker.country}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                const StatusBadge(text: 'Uploaded'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
