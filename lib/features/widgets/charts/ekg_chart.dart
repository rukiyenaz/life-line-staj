import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:life_line/features/widgets/common/colors.dart';

Widget EKGChartPage({List<double>? ecgSamplePoints}) {
  List<FlSpot> generateEkgData() {
    List<FlSpot> spots = [];
    
    // Eğer gerçek veriler varsa onları çiz
    if (ecgSamplePoints != null && ecgSamplePoints.isNotEmpty) {
      double x = 0;
      for (int i = 0; i < ecgSamplePoints.length; i++) {
        // Gerçek veriyi çiz, değerleri küçültebiliriz veya doğrudan verebiliriz.
        // Genelde EKG verileri grafiğe sığması için ölçeklendirilir.
        // Önceki mock veriler -3 ile 3 arasındaydı.
        // Gerçek veriler -1000 ile 2000 civarında (örn: 1738.12)
        // Dolayısıyla Y eksenini sonradan ayarlayacağız (LineChart kısmında).
        spots.add(FlSpot(x, ecgSamplePoints[i]));
        x += 1; // Her bir örnek noktası için X ekseninde 1 birim ilerle
      }
      return spots;
    }

    // Gerçek veri yoksa varsayılan (mock) EKG verisini oluştur
    double x = 0;
    for (int beat = 0; beat < 4; beat++) {
      // P-dalgası (küçük tepe)
      for (int i = 0; i < 10; i++) {
        double y = 0.1 * sin(pi * i / 10);
        spots.add(FlSpot(x, y));
        x += 0.05;
      }

      // Düz çizgi
      for (int i = 0; i < 10; i++) {
        spots.add(FlSpot(x, 0));
        x += 0.05;
      }

      // Q-dalgası (küçük negatif)
      spots.add(FlSpot(x, -0.2));
      x += 0.05;

      // R-dalgası (yüksek pozitif sivri uç)
      spots.add(FlSpot(x, 1.5));
      x += 0.05;

      // S-dalgası (negatif kısa düşüş)
      spots.add(FlSpot(x, -0.5));
      x += 0.05;

      // ST segmenti
      for (int i = 0; i < 10; i++) {
        spots.add(FlSpot(x, 0));
        x += 0.05;
      }

      // T-dalgası (geniş tepe)
      for (int i = 0; i < 20; i++) {
        double y = 0.3 * sin(pi * i / 20);
        spots.add(FlSpot(x, y));
        x += 0.05;
      }

      // Düz çizgi (diyastol)
      for (int i = 0; i < 20; i++) {
        spots.add(FlSpot(x, 0));
        x += 0.05;
      }
    }

    return spots;
  }
 
    return Container(
        padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FFFE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LineChart(
        LineChartData(
          gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: ecgSamplePoints != null && ecgSamplePoints.isNotEmpty
              ? ((ecgSamplePoints.reduce(max) - ecgSamplePoints.reduce(min) + 400) / 5).clamp(1.0, double.infinity)
              : 1.0,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0xFFE2E8F0),
              strokeWidth: 0.8,
            );
          },
        ),
          titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  // X ekseninde yaklaşık 5-6 etiket göstermek için aralığı hesaplıyoruz
                  interval: ecgSamplePoints != null && ecgSamplePoints.isNotEmpty 
                      ? (ecgSamplePoints.length / 5).clamp(1.0, double.infinity)
                      : 2.0,
                  reservedSize: 25,
                  getTitlesWidget: (value, meta) {
                    // Sadece tam sayı olan aralıklarda yazıyı göster
                    if (value % 1 != 0) return const SizedBox();
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          maxY: ecgSamplePoints != null && ecgSamplePoints.isNotEmpty 
              ? ecgSamplePoints.reduce(max) + 200 
              : 3,
          minY: ecgSamplePoints != null && ecgSamplePoints.isNotEmpty 
              ? ecgSamplePoints.reduce(min) - 200 
              : -3,
          maxX: ecgSamplePoints != null && ecgSamplePoints.isNotEmpty 
              ? ecgSamplePoints.length.toDouble() 
              : 15, 
          minX: 0,
      
          backgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
            spots: generateEkgData(),
            isCurved: false,
            color: const Color(0xFF10B981), // Medikal Nane Yeşili
            barWidth: 1.5,
            isStrokeCapRound: false,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          ],
      ),
      
        ),  
            );

  }

  