import 'package:flutter/material.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/presenatation/pages/hasta/hasta_detail.dart';
import 'package:life_line/features/widgets/common/colors.dart';

class HastaCard extends StatelessWidget {
  final HastaModel hasta;
  final Function(HastaModel)? onDelete;

  const HastaCard({super.key, required this.hasta, this.onDelete});

  String _initials() {
    final n = hasta.name.isNotEmpty ? hasta.name[0].toUpperCase() : '?';
    final s = hasta.surName.isNotEmpty ? hasta.surName[0].toUpperCase() : '';
    return '$n$s';
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => HastaDetailPage(hasta: hasta)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: hasta.cinsiyet
                                ? AppColors.femaleAccent.withOpacity(0.12)
                                : AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _initials(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: hasta.cinsiyet
                                    ? AppColors.femaleAccent
                                    : AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Bilgiler
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${hasta.name} ${hasta.surName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _Badge(
                                      label: '${hasta.age} yaş',
                                      color: AppColors.surfaceVariant,
                                      textColor: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  _Badge(
                                    label: hasta.cinsiyet ? 'Kadın' : 'Erkek',
                                    color: hasta.cinsiyet
                                        ? AppColors.femaleAccent
                                            .withOpacity(0.12)
                                        : AppColors.primarySurface,
                                    textColor: hasta.cinsiyet
                                        ? AppColors.femaleAccent
                                        : AppColors.accent,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Sil butonu
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error, size: 22),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hasta Sil'),
                                  content: Text(
                                      '${hasta.name} kaydını silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('İptal')),
                                    TextButton(
                                      onPressed: () {
                                        onDelete!(hasta);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Sil',
                                          style: TextStyle(
                                              color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Badge(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: textColor)),
    );
  }
}
