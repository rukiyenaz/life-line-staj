import 'package:flutter/material.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';
import 'package:life_line/features/widgets/common/colors.dart';
import 'package:life_line/features/widgets/forms/hasta_ekleme_textField.dart';

void showYapayZekaBottomSheet(BuildContext context, Function(YapayzekaBulgulari) onYapayZekaEkle) {
  final TextEditingController aritmiController = TextEditingController();
  final TextEditingController kalpKriziRiskiController = TextEditingController();


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
                Text("Yeni Yapay Zeka Bulguları Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                CustomTextField(label: "Aritmi", controller: aritmiController, keyboardType: TextInputType.text),
                SizedBox(height: 8),
                CustomTextField(label: "Kalp Krizi Riski", controller: kalpKriziRiskiController, keyboardType: TextInputType.text),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColors.primary),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                  ),
                  onPressed: () {
                    if (aritmiController.text.isNotEmpty && kalpKriziRiskiController.text.isNotEmpty) {
                      onYapayZekaEkle(YapayzekaBulgulari(
                        aritmi: aritmiController.text,
                        kalp_krizi_riski: kalpKriziRiskiController.text,
                      ));
                    }
                    Navigator.pop(context); // modalı kapat
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

    