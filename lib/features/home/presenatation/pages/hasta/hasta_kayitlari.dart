import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/presenatation/cubits/hasta_cubit.dart';
import 'package:life_line/features/home/presenatation/cubits/hasta_state.dart';
import 'package:life_line/features/home/presenatation/pages/hasta/hasta_ekle.dart';
import 'package:life_line/features/home/presenatation/pages/ilaclar/ilac_cubit.dart';
import 'package:life_line/features/widgets/card/hasta_card.dart';
import 'package:life_line/features/widgets/common/colors.dart';

class HastaKayitlariPage extends StatefulWidget {
  const HastaKayitlariPage({super.key});

  @override
  State<HastaKayitlariPage> createState() => _HastaKayitlariPageState();
}

class _HastaKayitlariPageState extends State<HastaKayitlariPage> {
  User auth = FirebaseAuth.instance.currentUser!;

  void fetcHastaList() {
    context.read<HastaCubit>().loadHastaList();
  }

  @override
  void initState() {
    super.initState();
    fetcHastaList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: const Text(
            'Hasta Kayıtları',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<IlacCubit>(
                      create: (_) => IlacCubit(),
                      child: HastaEklePage(),
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Hasta Ekle',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ],
        ),

        body: BlocBuilder<HastaCubit, HastaState>(
          builder: (context, state) {
            if (state is HastaLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent));
            }

            if (state is HastaLoaded) {
              final hastaList = state.hastaList;

              if (hastaList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people_alt_outlined,
                            size: 36, color: AppColors.accent),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz hasta kaydı yok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sağ üstteki butona tıklayarak hasta ekleyin',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                itemCount: hastaList.length,
                itemBuilder: (context, index) {
                  final hasta = hastaList[index];
                  return HastaCard(
                    hasta: hasta,
                    onDelete: (h) =>
                        context.read<HastaCubit>().deleteHasta(h.id ?? ''),
                  );
                },
              );
            }

            if (state is HastaError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('Hata: ${state.message}',
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetcHastaList,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent),
                      child: const Text('Tekrar Dene',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (state is HastaAdded || state is HastaDeleted) {
              fetcHastaList();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
