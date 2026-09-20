import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/home/presenatation/pages/ilaclar/ilac_cubit.dart';

class IlacEtiketleriWidget extends StatefulWidget {
  const IlacEtiketleriWidget({super.key});

  @override
  State<IlacEtiketleriWidget> createState() => _IlacEtiketleriWidgetState();
}

class _IlacEtiketleriWidgetState extends State<IlacEtiketleriWidget> {
  final TextEditingController _controller = TextEditingController();

  void _ilacEkle(String ilac) {
    if (ilac.isNotEmpty) {
      context.read<IlacCubit>().ilacEkle(ilac);
      _controller.clear();
    }
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("İlaçlar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: "İlaç adı", border: OutlineInputBorder()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _ilacEkle(_controller.text.trim()),
            )
          ],
        ),
        const SizedBox(height: 10),
        BlocBuilder<IlacCubit, List<String>>(
          builder: (context, ilaclar) {
            return Wrap(
              spacing: 8,
              children: ilaclar.map((ilac) {
                return Chip(
                  label: Text(ilac),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    context.read<IlacCubit>().ilacSil(ilac);
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final ilaclar = context.read<IlacCubit>().state;
            Navigator.pop(context, ilaclar); 
          },
          child: Text("Kaydet"),
        ),

      ],
    );
  }
}
