import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/note.dart';
import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  Future<void> _editNote(BuildContext context, WidgetRef ref, Note note) async {
    final result = await showDialog<NoteFormResult>(
      context: context,
      builder: (_) => NoteFormDialog(initial: note),
    );
    if (result == null) return;
    await ref.read(noteActionsProvider).update(
          note.copyWith(
            title: result.title,
            body: result.body,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          noteAsync.maybeWhen(
            data: (note) => note != null
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                    onPressed: () => _editNote(context, ref, note),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          noteAsync.maybeWhen(
            data: (note) => note != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus',
                    onPressed: () async {
                      await ref.read(noteActionsProvider).delete(id);
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat catatan: $err')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (note.dirty)
                      Chip(
                        label: const Text('belum tersinkron'),
                        labelStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.deepOrange,
                        ),
                        backgroundColor: Colors.orange.shade50,
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Terakhir diperbarui: ${note.updatedAt.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const Divider(height: 24),
                Text(
                  note.body.isEmpty ? '(Tanpa isi)' : note.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
