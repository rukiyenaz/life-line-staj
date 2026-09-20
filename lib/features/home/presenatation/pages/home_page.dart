
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:life_line/features/auth/presentation/cubits/auth_state.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/presenatation/pages/hasta/hasta_detail.dart';
import 'package:life_line/features/home/presenatation/search_cubits/search_cubit.dart';
import 'package:life_line/features/home/presenatation/search_cubits/search_state.dart';
import 'package:life_line/features/home/presenatation/today_meds_cubits/today_meds_cubit.dart';
import 'package:life_line/features/home/presenatation/today_meds_cubits/today_meds_state.dart';
import 'package:life_line/features/widgets/card/hasta_card.dart';
import 'package:life_line/features/widgets/common/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late final HastaSearchCubit _searchCubit;
  late final TodayMedsCubit _todayCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = HastaSearchCubit();
    _searchCubit.loadOnce();
    _todayCubit = TodayMedsCubit()..loadToday();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchCubit.close();
    _todayCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              //arama cubugu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: BlocBuilder<HastaSearchCubit, HastaSearchState>(
                  buildWhen: (p, c) => p.query != c.query,
                  builder: (context, state) {
                    if (_searchController.text != state.query) {
                      _searchController.value = TextEditingValue(
                        text: state.query,
                        selection: TextSelection.collapsed(
                            offset: state.query.length),
                      );
                    }
                    return Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Hasta veya tanı ara...',
                          hintStyle: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textSecondary, size: 20),
                          suffixIcon: state.query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18, color: AppColors.textSecondary),
                                  onPressed: () => context
                                      .read<HastaSearchCubit>()
                                      .onQueryChanged(''),
                                )
                              : null,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (v) =>
                            context.read<HastaSearchCubit>().onQueryChanged(v),
                      ),
                    );
                  },
                ),
              ),

              // içerik
              Expanded(
                child: BlocBuilder<HastaSearchCubit, HastaSearchState>(
                  builder: (context, state) {
                    return state.query.isNotEmpty
                        ? const _SearchResults()
                        : _HomeContent(todayCubit: _todayCubit);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//arama sonuçları
class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HastaSearchCubit, HastaSearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (state.error != null) {
          return Center(
              child: Text(state.error!,
                  style: const TextStyle(color: AppColors.textSecondary)));
        }
        if (state.hastalar.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 56, color: AppColors.textDisabled),
                SizedBox(height: 12),
                Text('Hasta bulunamadı',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 15)),
              ],
            ),
          );
        }
        return ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: state.hastalar.length,
          itemBuilder: (context, index) {
            final hasta = state.hastalar[index];
            final hastaModel = HastaModel.fromJson(hasta, hasta['_id']);
            return HastaCard(
              hasta: hastaModel,
              onDelete: (_) {},
            );
          },
        );
      },
    );
  }
}

//ana içerik
class _HomeContent extends StatelessWidget {
  final TodayMedsCubit todayCubit;
  const _HomeContent({required this.todayCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: Text('Lütfen giriş yapın'));
        }

        final userData = state.user;
        final now = DateTime.now();
        final gun = now.day.toString();
        final ay = _ayAdi(now.month);
        final haftaGunu = _gunAdi(now.weekday);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //karşılama kartı
              BlocBuilder<TodayMedsCubit, TodayMedsState>(
                bloc: todayCubit,
                builder: (context, s) {
                  final count = s.hastalar.length;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İyi günler,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'DR. ${userData?.ad?.toUpperCase() ?? ''}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  count == 0
                                      ? 'Bugün cihaz takacak hasta yok'
                                      : 'Bugün $count hasta cihaz takacak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: count == 0
                                        ? Colors.white.withOpacity(0.7)
                                        : const Color(0xFF6EE7B7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              gun,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            Text(
                              ay,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              haftaGunu,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              //bugün cihaz takacak hastalar
              BlocBuilder<TodayMedsCubit, TodayMedsState>(
                bloc: todayCubit,
                builder: (context, s) {
                  if (s.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent)),
                    );
                  }
                  if (s.error != null) {
                    return _SectionError(
                        message: s.hastalar.isEmpty ? s.error! : '',
                        onRetry: () => todayCubit.loadToday());
                  }
                  if (s.hastalar.isEmpty) {
                    return _EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.accentGreen,
                      label: 'Bugün cihaz takacak hasta yok',
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Bugün Cihaz Takacak Hastalar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${s.hastalar.length}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: s.hastalar.length,
                        itemBuilder: (context, i) {
                          final h = s.hastalar[i];
                          final hasta = HastaModel.fromJson(h, h['_id']);
                          return HastaCard(
                            hasta: hasta,
                            onDelete: (_) {},
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static String _ayAdi(int m) {
    const aylar = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return aylar[m - 1];
  }

  static String _gunAdi(int w) {
    const gunler = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
    ];
    return gunler[w - 1];
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _EmptyState(
      {required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _SectionError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 13)),
          ),
          TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene',
                  style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
  }
}