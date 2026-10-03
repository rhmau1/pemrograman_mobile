import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/mahasiswa.dart';
import '../data/paged_mahasiswa.dart';
import '../data/providers.dart';
import 'form_page.dart';

class MahasiswaListPage extends ConsumerStatefulWidget {
  const MahasiswaListPage({super.key});

  @override
  ConsumerState<MahasiswaListPage> createState() => _MahasiswaListPageState();
}

class _MahasiswaListPageState extends ConsumerState<MahasiswaListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pixels = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (pixels >= maxExtent - 200) {
      debugPrint('[Scroll] threshold reached: pixels=$pixels, max=$maxExtent');
      ref.read(pagedMahasiswaProvider.notifier).loadNextPage();
    }
  }

  /// Check after each frame if the content doesn't fill the viewport.
  /// If so, automatically load the next page.
  void _checkIfNeedMoreData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      final state = ref.read(pagedMahasiswaProvider);
      if (!state.hasMore || state.isLoadingMore || state.error != null) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // If content doesn't fill the viewport (maxScroll is small),
      // or we're already near the bottom, load more data.
      if (currentScroll >= maxScroll - 200) {
        debugPrint('[AutoLoad] content does not fill viewport '
            '(maxScroll=$maxScroll), loading next page...');
        ref.read(pagedMahasiswaProvider.notifier).loadNextPage();
      }
    });
  }

  Future<void> _bukaForm([Mahasiswa? m]) async {
    final berhasil = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPage(mahasiswa: m)),
    );
    if (berhasil == true) {
      ref.read(pagedMahasiswaProvider.notifier).refresh();
      ref.read(mahasiswaListProvider.notifier).refresh();
    }
  }

  Future<void> _hapus(Mahasiswa m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Yakin menghapus ${m.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(mahasiswaListProvider.notifier).deleteMahasiswa(m.id);
      ref.read(pagedMahasiswaProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Widget _buildItem(Mahasiswa m) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(m.nama.isNotEmpty ? m.nama[0].toUpperCase() : '?'),
      ),
      title: Text(m.nama),
      subtitle: Text('${m.nim} • ${m.prodi}'),
      onTap: () => _bukaForm(m),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _hapus(m),
      ),
    );
  }

  Widget _buildFooter(PagedMahasiswaState state) {
    // Show error with retry button
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gagal memuat data: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(pagedMahasiswaProvider.notifier).retryLoadNextPage();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Show loading spinner when loading more
    if (state.isLoadingMore || state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // All data loaded
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Semua data termuat.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedMahasiswaProvider);

    debugPrint('[Build] state: $state');

    // After this frame renders, check if we need to auto-load more data
    // because the content might not fill the viewport yet.
    if (state.items.isNotEmpty &&
        state.hasMore &&
        !state.isLoadingMore &&
        state.error == null) {
      _checkIfNeedMoreData();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(pagedMahasiswaProvider.notifier).refresh(),
        child: state.items.isEmpty && state.isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty && state.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Gagal memuat data:\n${state.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(pagedMahasiswaProvider.notifier)
                                .retryLoadNextPage();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.items.length + 1, // +1 untuk footer
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return _buildFooter(state);
                      }
                      final mahasiswa = state.items[index];
                      return _buildItem(mahasiswa);
                    },
                  ),
      ),
    );
  }
}
