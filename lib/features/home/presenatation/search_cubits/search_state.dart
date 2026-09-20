class HastaSearchState {
  final List<Map<String, dynamic>> hastalar;
  final bool isLoading;
  final String? error;
  final String query;

  const HastaSearchState({
    this.hastalar = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  HastaSearchState copyWith({
    List<Map<String, dynamic>>? hastalar,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return HastaSearchState(
      hastalar: hastalar ?? this.hastalar,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}
