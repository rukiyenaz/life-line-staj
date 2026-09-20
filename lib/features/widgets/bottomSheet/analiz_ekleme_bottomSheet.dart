import 'package:flutter/material.dart';
import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/widgets/common/colors.dart';
import 'package:life_line/features/widgets/forms/hasta_ekleme_textField.dart';

void showAnalizBottomSheet(BuildContext context, Function(AnalizSonuclari) onAnalizEkle) {
  final TextEditingController analizControllerPR = TextEditingController();
  final TextEditingController analizControllerQRS = TextEditingController();
  final TextEditingController analizControllerQT = TextEditingController();
  final TextEditingController analizControllerKalp = TextEditingController();



  showModalBottomSheet(
    backgroundColor: AppColors.background,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets, // klavye uyumu
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Yarım ekran
              children: [
                SizedBox(height: 8),
                Text("Yeni Analiz Sonucu Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                CustomTextField(label: "PR Aralığı", controller: analizControllerPR, keyboardType: TextInputType.number),
                SizedBox(height: 8),
                CustomTextField(label: "QRS Süresi", controller: analizControllerQRS, keyboardType: TextInputType.number),
                SizedBox(height: 8),
                CustomTextField(label: "QT Aralığı", controller: analizControllerQT, keyboardType: TextInputType.number),
                SizedBox(height: 8),
                CustomTextField(label: "Kalp Hızı", controller: analizControllerKalp, keyboardType: TextInputType.number),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColors.primary),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                  ),
                  onPressed: () {
                    if (analizControllerPR.text.isNotEmpty && analizControllerQRS.text.isNotEmpty && analizControllerQT.text.isNotEmpty && analizControllerKalp.text.isNotEmpty) {
                      onAnalizEkle(AnalizSonuclari(
                        PR_araligi: int.tryParse(analizControllerPR.text) ?? 0,
                        QRS_suresi: int.tryParse(analizControllerQRS.text) ?? 0,
                        kalp_hizi: int.tryParse(analizControllerKalp.text) ?? 0,
                        QT_araligi: int.tryParse(analizControllerQT.text) ?? 0,
                      ));
                      Navigator.pop(context); // modalı kapat
                    }
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Ekle", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
