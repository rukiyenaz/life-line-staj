import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';
import 'package:life_line/features/widgets/charts/ekg_chart.dart';
import 'package:life_line/features/widgets/common/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/presenatation/pages/ilaclar/ilac_cubit.dart';
import 'package:life_line/features/home/presenatation/pages/hasta/hasta_ekle.dart';

class HastaDetailPage extends StatefulWidget {
  final HastaModel hasta;
  const HastaDetailPage({super.key, required this.hasta});

  @override
  State<HastaDetailPage> createState() => _HastaDetailPageState();
}

class _HastaDetailPageState extends State<HastaDetailPage> {
  bool showAnalysis = false;
  bool showYapayZekaAnalysis = false;
  bool showKullandigiIlaclar = false;

  @override
  Widget build(BuildContext context) {
    final AnalizSonuclari? analizSonuclari = widget.hasta.analizSonuclari;
    final YapayzekaBulgulari? yapayZekaBulgulari = widget.hasta.yapayzekaBulgulari;

    final List<int> analizSonuclariValues = [
      analizSonuclari?.PR_araligi ?? 0,
      analizSonuclari?.QRS_suresi ?? 0,
      analizSonuclari?.QT_araligi ?? 0,
      analizSonuclari?.kalp_hizi ?? 0,
    ];
    String riskLabel = 'N/A';
    if (yapayZekaBulgulari != null && yapayZekaBulgulari.kalp_krizi_riski.isNotEmpty) {
      final int riskVal = int.tryParse(yapayZekaBulgulari.kalp_krizi_riski) ?? 0;
      if (riskVal < 30) {
        riskLabel = 'Düşük';
      } else if (riskVal < 60) {
        riskLabel = 'Orta';
      } else {
        riskLabel = 'Yüksek';
      }
    }

    final List<String> yapayZekaBulgulariValues = [
      yapayZekaBulgulari?.aritmi ?? 'N/A',
      riskLabel,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.hasta.name} ${widget.hasta.surName}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded,
                color: AppColors.accent, size: 22),
            onPressed: () {
              TextEditingController codeController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Uygulama Bağlantısı'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Hastanın uygulamasından aldığı kodu giriniz:'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          hintText: 'Örn: abc123xyz',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
                      onPressed: () async {
                        if (codeController.text.trim().isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('patients')
                              .doc(widget.hasta.id)
                              .update({'authUid': codeController.text.trim()});
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hasta başarıyla uygulamaya bağlandı!')),
                            );
                          }
                        }
                      },
                      child: const Text('Bağla', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.textSecondary, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<IlacCubit>(
                    create: (_) => IlacCubit(),
                    child: HastaEklePage(existingHasta: widget.hasta),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCard(hasta: widget.hasta),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _DateStatCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Cihaz Takma',
                    date: widget.hasta.cihazTakmaGunu,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateStatCard(
                    icon: Icons.event_available_rounded,
                    label: 'Cihaz Çıkarma',
                    date: widget.hasta.cihazCikarmaGunu,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            WeeklyCalendar(
                cihazTakmaGunu: widget.hasta.cihazTakmaGunu ?? DateTime.now(),
                cihazCikarmaGunu: widget.hasta.cihazCikarmaGunu,
            ),
            const SizedBox(height: 16),

            buildIlacSuresi(
                widget.hasta.cihazCikarmaGunu ??
                    DateTime.now().add(const Duration(days: 3))),
            const SizedBox(height: 20),
            const _SectionLabel(icon: Icons.record_voice_over_outlined, label: 'Hasta Şikayeti'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.textSecondary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (widget.hasta.hastaSikayeti == null || widget.hasta.hastaSikayeti!.isEmpty) 
                          ? 'Şikayet belirtilmemiş' 
                          : widget.hasta.hastaSikayeti!,
                      style: TextStyle(
                        fontSize: 14,
                        color: (widget.hasta.hastaSikayeti == null || widget.hasta.hastaSikayeti!.isEmpty)
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //Tanı
            const _SectionLabel(icon: Icons.assignment_outlined, label: 'Tanı'),
            const SizedBox(height: 8),
            _TaniCard(tani: widget.hasta.tani),
            const SizedBox(height: 20),

            //EKG Grafiği
            const _SectionLabel(icon: Icons.monitor_heart_outlined, label: 'EKG Dalgası'),
            const SizedBox(height: 8),
            EKGChartPage(ecgSamplePoints: widget.hasta.ecgSamplePoints),
            const SizedBox(height: 20),

            //analiz Sonuçları
            _ExpandableCard(
              icon: Icons.analytics_outlined,
              title: 'Analiz Sonuçları',
              accentColor: AppColors.accent,
              initiallyExpanded: showAnalysis,
              onExpansionChanged: (v) => setState(() => showAnalysis = v),
              child: _AnalysisGrid(values: analizSonuclariValues),
            ),
            const SizedBox(height: 12),

            //Yapay Zeka Bulguları 
            _ExpandableCard(
              icon: Icons.psychology_outlined,
              title: 'Yapay Zeka Bulguları',
              accentColor: const Color(0xFF8B5CF6),
              initiallyExpanded: showYapayZekaAnalysis,
              onExpansionChanged: (v) =>
                  setState(() => showYapayZekaAnalysis = v),
              child: _AIResultsContent(values: yapayZekaBulgulariValues),
            ),
            const SizedBox(height: 12),

            //Kullanılan İlaçlar
            _ExpandableCard(
              icon: Icons.medication_outlined,
              title: 'Kullanılan İlaçlar',
              accentColor: AppColors.accentGreen,
              initiallyExpanded: showKullandigiIlaclar,
              onExpansionChanged: (v) =>
                  setState(() => showKullandigiIlaclar = v),
              child:
                  _MedicationsContent(ilaclar: widget.hasta.kullandigiIlaclar ?? []),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  //Haftalık Takvim
  Widget WeeklyCalendar({required DateTime cihazTakmaGunu, DateTime? cihazCikarmaGunu}) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final gunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = monday.add(Duration(days: index));
              final isTakmaGunu = index == cihazTakmaGunu.weekday - 1;
              final isCikarmaGunu = cihazCikarmaGunu != null && index == cihazCikarmaGunu.weekday - 1;
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              
              // İkisi çakışırsa
              final isBothTakmaToday = isTakmaGunu && isToday;
              final isBothCikarmaToday = isCikarmaGunu && isToday;
              final isTakmaVeCikarma = isTakmaGunu && isCikarmaGunu;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gunler[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday || isTakmaGunu || isCikarmaGunu
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isToday
                          ? AppColors.accent
                          : isTakmaGunu
                              ? AppColors.accentGreen
                              : isCikarmaGunu
                                  ? AppColors.error
                                  : AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // dış halka -> takma günü yeşil, bugün mavi
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isTakmaVeCikarma
                              ? AppColors.warning // eğer aynı günse turuncu
                              : isBothTakmaToday
                                  ? AppColors.accentGreen
                                  : isBothCikarmaToday
                                      ? AppColors.error
                                      : isTakmaGunu
                                          ? AppColors.accentGreen.withOpacity(0.12)
                                          : isCikarmaGunu
                                              ? AppColors.error.withOpacity(0.12)
                                              : isToday
                                                  ? AppColors.accent
                                                  : Colors.transparent,
                          border: Border.all(
                            color: isTakmaVeCikarma
                                ? AppColors.warning
                                : isBothTakmaToday || isBothCikarmaToday
                                    ? AppColors.accent 
                                    : isTakmaGunu
                                        ? AppColors.accentGreen
                                        : isCikarmaGunu
                                            ? AppColors.error
                                            : isToday
                                                ? AppColors.accent
                                                : AppColors.border,
                            width: isTakmaGunu || isCikarmaGunu || isToday ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isBothTakmaToday || isBothCikarmaToday || isTakmaVeCikarma
                                  ? Colors.white
                                  : isToday
                                      ? Colors.white
                                      : isTakmaGunu
                                          ? AppColors.accentGreen
                                          : isCikarmaGunu
                                              ? AppColors.error
                                              : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      //çakışma -> küçük mavi nokta (alt sağ)
                      if (isBothTakmaToday || isBothCikarmaToday)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.surface, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),

          //lejant
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.accent, label: 'Bugün'),
              const SizedBox(width: 20),
              _LegendDot(color: AppColors.accentGreen, label: 'Cihaz Takma'),
              const SizedBox(width: 20),
              _LegendDot(color: AppColors.error, label: 'Cihaz Çıkarma'),
            ],
          ),
        ],
      ),
    );
  }

  //cihaz sayacı
  Widget buildIlacSuresi(DateTime hedefTarih) {
    final simdi = DateTime.now();
    final fark = hedefTarih.difference(simdi);

    Widget content;
    Color bg;
    Color iconColor;
    IconData icon;

    if (fark == Duration.zero) {
      content = const Text('Cihaz çıkarma zamanı geldi!',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.accentGreen,
              fontSize: 14));
      bg = AppColors.accentSurface;
      iconColor = AppColors.accentGreen;
      icon = Icons.check_circle_rounded;
    } else if (fark.isNegative) {
      content = const Text('Cihaz çıkarma zamanı geçti!',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
              fontSize: 14));
      bg = AppColors.errorSurface;
      iconColor = AppColors.error;
      icon = Icons.error_rounded;
    } else {
      final gun = fark.inDays;
      final saat = fark.inHours % 24;
      content = RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: 'Cihaz çıkarmaya kalan: '),
            TextSpan(
              text: '$gun gün $saat saat',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  fontSize: 13),
            ),
          ],
        ),
      );
      bg = AppColors.primarySurface;
      iconColor = AppColors.accent;
      icon = Icons.timer_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget buildKullanilanIlaclar(List kullanilanIlaclar) {
    List<String> ilacWidgets =
        kullanilanIlaclar.map((e) => e.toString()).toList();
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Visibility(
          visible: showKullandigiIlaclar,
          child: _MedicationsContent(ilaclar: ilacWidgets),
        ),
      ),
    );
  }
}

//profil kartı
class _ProfileCard extends StatelessWidget {
  final HastaModel hasta;
  const _ProfileCard({required this.hasta});

  String _initials() {
    final n = hasta.name.isNotEmpty ? hasta.name[0].toUpperCase() : '?';
    final s = hasta.surName.isNotEmpty ? hasta.surName[0].toUpperCase() : '';
    return '$n$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                  fontSize: 22,
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
              children: [
                Text(
                  '${hasta.name} ${hasta.surName}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(label: '${hasta.age} yaş', color: AppColors.surfaceVariant, textColor: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      _Chip(
                        label: hasta.cinsiyet ? 'Kadın' : 'Erkek',
                        color: hasta.cinsiyet
                            ? AppColors.femaleAccent.withOpacity(0.12)
                            : AppColors.primarySurface,
                        textColor: hasta.cinsiyet
                            ? AppColors.femaleAccent
                            : AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//tarih stat kartı
class _DateStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final Color color;
  const _DateStatCard(
      {required this.icon,
      required this.label,
      required this.date,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final dateStr = date != null
        ? '${date!.day.toString().padLeft(2, '0')}.${date!.month.toString().padLeft(2, '0')}.${date!.year}'
        : 'Belirtilmemiş';

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: date != null ? AppColors.textPrimary : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

//açılabilir kart
class _ExpandableCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final Widget child;

  const _ExpandableCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          children: [child],
        ),
      ),
    );
  }
}

//analiz grid
class _AnalysisGrid extends StatelessWidget {
  final List<int> values;
  const _AnalysisGrid({required this.values});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {'label': 'PR Aralığı', 'value': values[0], 'unit': 'ms'},
      {'label': 'QRS Süresi', 'value': values[1], 'unit': 'ms'},
      {'label': 'QT Aralığı', 'value': values[2], 'unit': 'ms'},
      {'label': 'Kalp Hızı', 'value': values[3], 'unit': 'bpm'},
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricTile(label: metrics[0]['label'] as String, value: metrics[0]['value'] as int, unit: metrics[0]['unit'] as String)),
            const SizedBox(width: 10),
            Expanded(child: _MetricTile(label: metrics[1]['label'] as String, value: metrics[1]['value'] as int, unit: metrics[1]['unit'] as String)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _MetricTile(label: metrics[2]['label'] as String, value: metrics[2]['value'] as int, unit: metrics[2]['unit'] as String)),
            const SizedBox(width: 10),
            Expanded(child: _MetricTile(label: metrics[3]['label'] as String, value: metrics[3]['value'] as int, unit: metrics[3]['unit'] as String)),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  const _MetricTile({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$value',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 3),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

//yapay zeka sonuçları
class _AIResultsContent extends StatelessWidget {
  final List<String> values;
  const _AIResultsContent({required this.values});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Aritmi Durumu', 'value': values[0], 'icon': Icons.favorite_border_rounded},
      {'label': 'Kalp Krizi Riski', 'value': values[1], 'icon': Icons.monitor_heart_outlined},
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(item['icon'] as IconData,
                  color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['label'] as String,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(item['value'] as String,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
//İlaçlar
class _MedicationsContent extends StatelessWidget {
  final List ilaclar;
  const _MedicationsContent({required this.ilaclar});

  @override
  Widget build(BuildContext context) {
    if (ilaclar.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('İlaç kaydı bulunmuyor',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
      );
    }
    return Column(
      children: ilaclar.map((ilac) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accentGreen.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.medication_rounded,
                  color: AppColors.accentGreen, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(ilac.toString(),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

//section label
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

//chip
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Chip(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
    );
  }
}

//lejant dot
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// tanı kartı
class _TaniCard extends StatelessWidget {
  final String? tani;
  const _TaniCard({super.key, required this.tani});

  @override
  Widget build(BuildContext context) {
    final String currentTani = tani ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentTani.isEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.accentGreen, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Henüz tanı girilmemiş',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      currentTani,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}