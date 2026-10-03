import 'package:app_mahasiswa/data/models/mahasiswa.dart';
import 'package:app_mahasiswa/data/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PagedMahasiswaState {
  const PagedMahasiswaState({
    this.items = const [],
    this.page = 0,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Mahasiswa> items;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  @override
  String toString() =>
      'PagedMahasiswaState(items: ${items.length}, page: $page, '
      'isLoadingMore: $isLoadingMore, hasMore: $hasMore, error: $error)';
}

class PagedMahasiswaNotifier extends Notifier<PagedMahasiswaState> {
  @override
  PagedMahasiswaState build() {
    Future.microtask(() => loadNextPage());
    return const PagedMahasiswaState();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) {
      debugPrint('[Paged] loadNextPage SKIPPED: '
          'isLoadingMore=${state.isLoadingMore}, hasMore=${state.hasMore}');
      return;
    }

    final repo = ref.read(mahasiswaRepositoryProvider);
    final currentItems = state.items;
    final currentPage = state.page;
    final next = currentPage + 1;

    debugPrint('[Paged] loadNextPage START: fetching page $next ...');

    state = PagedMahasiswaState(
      items: currentItems,
      page: currentPage,
      isLoadingMore: true,
      hasMore: true,
    );

    try {
      final items = await repo.fetchMahasiswaPage(page: next, limit: 10);
      debugPrint('[Paged] loadNextPage SUCCESS: got ${items.length} items');

      state = PagedMahasiswaState(
        items: [...currentItems, ...items],
        page: next,
        hasMore: items.length == 10,
      );
    } catch (e, st) {
      debugPrint('[Paged] loadNextPage ERROR: $e');
      debugPrint('[Paged] stack: $st');

      state = PagedMahasiswaState(
        items: currentItems,
        page: currentPage,
        isLoadingMore: false,
        hasMore: false, // stop retrying on error
        error: e,
      );
    }
  }

  Future<void> retryLoadNextPage() async {
    // Reset error state and allow retrying
    state = PagedMahasiswaState(
      items: state.items,
      page: state.page,
      isLoadingMore: false,
      hasMore: true,
      error: null,
    );
    await loadNextPage();
  }

  Future<void> refresh() async {
    state = const PagedMahasiswaState();
    await loadNextPage();
  }
}

final pagedMahasiswaProvider =
    NotifierProvider<PagedMahasiswaNotifier, PagedMahasiswaState>(
  PagedMahasiswaNotifier.new,
);
