import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_line/features/widgets/common/colors.dart'; 

class CihazCikarilacakTarih extends StatefulWidget {
  final ValueChanged<DateTime> onTarihSecildi;
  final DateTime? initialDate;

  const CihazCikarilacakTarih({Key? key, required this.onTarihSecildi, this.initialDate}) : super(key: key);

  @override
  _CihazCikarilacakTarihState createState() => _CihazCikarilacakTarihState();
}

class _CihazCikarilacakTarihState extends State<CihazCikarilacakTarih> {
  DateTime? secilenTarih;

  @override
  void initState() {
    super.initState();
    secilenTarih = widget.initialDate;
  }

  void _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: secilenTarih ?? DateTime.now(), 
      firstDate: DateTime(2023), 
      lastDate: DateTime(2030), 
      locale: const Locale("tr", "TR"), 
    );

    if (secilen != null) {
      setState(() {
        secilenTarih = secilen;
      });
      widget.onTarihSecildi(secilen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.textFieldBackground),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            onPressed: () => _tarihSec(context),
            child: Text(secilenTarih == null
                ? 'Cihaz Çıkarılacak Tarih Seç'
                : 'Cihaz Çıkarılacak Tarih: ${DateFormat('dd/MM/yyyy').format(secilenTarih!)}', style: TextStyle(color: Colors.white),),
          )
        ),
    );
  }
}
