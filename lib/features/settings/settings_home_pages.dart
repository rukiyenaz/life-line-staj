import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_line/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:life_line/features/widgets/common/colors.dart';
import 'package:life_line/features/widgets/common/custom_app_bar.dart';
import 'package:life_line/features/settings/pages/profile_page.dart';
import 'package:life_line/features/settings/pages/security_page.dart';

class SettingsHomePages extends StatefulWidget {
  const SettingsHomePages({super.key});

  @override
  State<SettingsHomePages> createState() => _SettingsHomePagesState();
}

class _SettingsHomePagesState extends State<SettingsHomePages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Ayarlar'),
      body: Padding(padding: const EdgeInsets.all(16.0), child: Column(
        children: [
          Card(
            color: AppColors.cardBackground,
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.white,),
              title: const Text('Profil',style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
            ),
          ),
          Card(
            color: AppColors.cardBackground,
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.white,),
              title: const Text('Güvenlik',style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage()));
              },
            ),
          ),
          Card(
            color: AppColors.cardBackground,
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.white,),
              title: const Text('Bildirimler',style: TextStyle(color: Colors.white),),
              onTap: () {
              },
            ),
          ),
          Card(
            color: AppColors.cardBackground,
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.white,),
              title: const Text('Hakkında',style: TextStyle(color: Colors.white),),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationIcon: const FlutterLogo(),
                  applicationName: 'Life Line',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('Bu uygulama, sağlık verilerinizi yönetmenize yardımcı olmak için tasarlanmıştır.'),
                  ],
                );
              },
            ),
          ),
          Card(
            color: AppColors.cardBackground,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white,),
              title: const Text('Çıkış Yap',style: TextStyle(color: Colors.white),),
              onTap: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Çıkış Yap"),
                    content: const Text("Çıkış yapmak istediğinize emin misiniz?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Hayır", style: TextStyle(color: AppColors.cardBackground)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Evet", style: TextStyle(color: AppColors.cardBackground)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  context.read<AuthCubit>().signOut();
                }
              },
            ),
          )
        ],
      ),),
    );
  }
}