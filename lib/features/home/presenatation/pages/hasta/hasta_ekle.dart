import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/domain/entities/analizSonuclari.dart';
import 'package:life_line/features/home/domain/entities/hastaModel.dart';
import 'package:life_line/features/home/domain/entities/yapayZeka_bulgulari.dart';
import 'package:life_line/features/home/presenatation/cubits/hasta_cubit.dart';
import 'package:life_line/features/home/presenatation/cubits/hasta_state.dart';
import 'package:life_line/features/home/presenatation/pages/ilaclar/ilac_cubit.dart';
import 'package:life_line/features/home/presenatation/pages/randevu/cihaz_takilacak_tarih.dart';
import 'package:life_line/features/home/presenatation/pages/randevu/cihaz_cikarilacak_tarih.dart';
import 'package:life_line/features/widgets/bottomSheet/analiz_ekleme_bottomSheet.dart';
import 'package:life_line/features/widgets/bottomSheet/yapayzeka_sonuclari_ekleme_bottomSheet.dart';
import 'package:life_line/features/widgets/common/colors.dart';
import 'package:life_line/features/widgets/common/custom_app_bar.dart';
import 'package:life_line/features/widgets/forms/hasta_ekleme_textField.dart';

class HastaEklePage extends StatefulWidget {
  final HastaModel? existingHasta;
  const HastaEklePage({super.key, this.existingHasta});

  @override
  State<HastaEklePage> createState() => _HastaEklePageState();
}

class _HastaEklePageState extends State<HastaEklePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController hastaSikayetiController = TextEditingController();
  TextEditingController hastalikController = TextEditingController();
  TextEditingController isFemaleController = TextEditingController();
  TextEditingController doctorIdController = TextEditingController();
  TextEditingController idController = TextEditingController();

  AnalizSonuclari analizSonucu = AnalizSonuclari(
    PR_araligi: 0,
    QRS_suresi: 0,
    kalp_hizi: 0,
    QT_araligi: 0,
  );

  YapayzekaBulgulari yapayzekaBulgulari = YapayzekaBulgulari(
    aritmi: '',
    kalp_krizi_riski: '',
  );
  bool? cinsiyet;
  List<String> ilaclar = [];
  DateTime? cihazTarihi;
  DateTime? cihazCikarmaTarihi;

  @override
  void initState() {
    super.initState();
    if (widget.existingHasta != null) {
      final h = widget.existingHasta!;
      idController.text = h.id ?? '';
      nameController.text = h.name;
      surNameController.text = h.surName;
      ageController.text = h.age.toString();
      hastaSikayetiController.text = h.hastaSikayeti ?? '';
      hastalikController.text = h.hastalik ?? '';
      cinsiyet = h.cinsiyet;
      ilaclar = List.from(h.kullandigiIlaclar ?? []);
      cihazTarihi = h.cihazTakmaGunu;
      cihazCikarmaTarihi = h.cihazCikarmaGunu;
      if (h.analizSonuclari != null) {
        analizSonucu = h.analizSonuclari!;
      }
      if (h.yapayzekaBulgulari != null) {
        yapayzekaBulgulari = h.yapayzekaBulgulari!;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surNameController.dispose();
    ageController.dispose();
    hastaSikayetiController.dispose();
    hastalikController.dispose();
    isFemaleController.dispose();
    doctorIdController.dispose();
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    context.read<IlacCubit>().sonIlaclar; // Clear previous medications
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: widget.existingHasta != null ? 'Hasta Düzenle' : 'Hasta Ekle'),
      body: BlocBuilder<HastaCubit, HastaState>(builder: (context, state) {
        if (state is HastaLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HastaAdded) {
          return Center(child: Text('Hasta başarıyla eklendi: ${state.hasta.name}'));
        } else if (state is HastaUpdated) {
          return Center(child: Text('Hasta başarıyla güncellendi: ${state.hasta.name}'));
        } else if (state is HastaError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return 
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Hasta Kodu (İsteğe Bağlı, Hasta Uygulamasından Alınır)',
                      controller: idController,
                    ),
                    CustomTextField(
                      label: 'Hasta Adı',
                      controller: nameController,
                    ),
                    CustomTextField(
                      label: 'Hasta Soyadı',
                      controller: surNameController,
                    ),
                    CustomTextField(
                      label: 'Yaş',
                      controller: ageController,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      label: 'Hasta Şikayeti',
                      controller: hastaSikayetiController,
                    ),
                    CustomTextField(
                      label: 'Hastalık',
                      controller: hastalikController,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: DropdownButtonFormField<bool>(
                        isExpanded: true,
                        dropdownColor: AppColors.borderLight,
                        decoration: InputDecoration(
                          labelText: 'Cinsiyet',
                          border: OutlineInputBorder(),
                        ),
                        value: cinsiyet,
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text("Kadın", style: TextStyle(color: Colors.black)),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text("Erkek", style: TextStyle(color: Colors.black)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            cinsiyet = value;
                          });
                        },
                      ),
                    ),
                    buildElevatedButton('Kullandığı İlaçlar Ekle', () async {
                      _showIlacBottomSheet();
                    }),
                    buildElevatedButton('Analiz Sonuçları Ekle', () {
                      showAnalizBottomSheet(context, (analiz) {
                        analizSonucu = analiz;
                      });
                    }),
                    CihazTakilacakTarih(
                      initialDate: cihazTarihi,
                      onTarihSecildi: (tarih) {
                      setState(() {
                        cihazTarihi = tarih;
                      });
                    },
                    ),
                    const SizedBox(height: 8),
                    CihazCikarilacakTarih(
                      initialDate: cihazCikarmaTarihi,
                      onTarihSecildi: (tarih) {
                      setState(() {
                        cihazCikarmaTarihi = tarih;
                      });
                    },
                    ),
                    Text(ilaclar.isEmpty ? 'İlaç eklenmedi' : 'Eklenen İlaçlar: ${ilaclar.join(', ')}', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
      }
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: (){
          final isEditing = widget.existingHasta != null;
          final updatedHasta = HastaModel(
            id: isEditing ? widget.existingHasta!.id : (idController.text.trim().isNotEmpty ? idController.text.trim() : null),
            name: nameController.text,
            surName: surNameController.text,
            age: int.tryParse(ageController.text) ?? 0,
            hastaSikayeti: hastaSikayetiController.text,
            hastalik: hastalikController.text,
            cinsiyet: cinsiyet ?? false,
            analizSonuclari: analizSonucu,
            yapayzekaBulgulari: yapayzekaBulgulari,
            kullandigiIlaclar: ilaclar, 
            cihazTakmaGunu: cihazTarihi,
            cihazCikarmaGunu: cihazCikarmaTarihi,
            doctorId: context.read<HastaCubit>().doctorId,
          );

          if (isEditing) {
            context.read<HastaCubit>().updateHasta(updatedHasta);
          } else {
            context.read<HastaCubit>().addHasta(updatedHasta);
          }
          Navigator.pop(context);
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16.0))  ,
          backgroundColor: MaterialStateProperty.all(AppColors.buttonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        child: Text(widget.existingHasta != null ? 'Güncelle' : 'Hasta Ekle')),
      ),
    );
  }

    Future<void> _showIlacBottomSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<String> tempIlaclar = List.from(ilaclar);
        TextEditingController controller = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: tempIlaclar
                          .map((e) => Chip(
                                label: Text(e),
                                onDeleted: () {
                                  setModalState(() {
                                    tempIlaclar.remove(e);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'İlaç adı'),
                    ),
                    SizedBox(height: 2.0),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      onPressed: () {
                        if (controller.text.trim().isEmpty) return;
                        setModalState(() {
                          tempIlaclar.add(controller.text.trim());
                          controller.clear();
                        });
                      },
                      child: Text('Ekle', style: TextStyle(color: AppColors.buttonColor)),
                    ),
                    ElevatedButton(
                       style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, tempIlaclar);
                      },
                      child: Text('Tamam', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        ilaclar = result;
      });
    }
  }

  Widget buildElevatedButton(String text, VoidCallback onPressed) {
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
          onPressed: onPressed,
          child: Text(text, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}


  Widget buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

 


