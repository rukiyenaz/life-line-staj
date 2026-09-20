class TodayMedsState {
  final List<Map<String, dynamic>> hastalar;
  final bool isLoading;
  final String? error;

  const TodayMedsState({
    this.hastalar = const [],
    this.isLoading = false,
    this.error,
  });

  TodayMedsState copyWith({
    List<Map<String, dynamic>>? hastalar,
    bool? isLoading,
    String? error,
  }) {
    return TodayMedsState(
      hastalar: hastalar ?? this.hastalar,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}