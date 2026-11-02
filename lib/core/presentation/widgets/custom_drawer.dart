import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../features/balance/presentation/pages/accueil_page.dart';
import '../../../features/entree/presentation/pages/add_entree_page.dart';
import '../../../features/entree/presentation/pages/list_entree_page.dart';
import '../../../features/sortie/presentation/pages/list_sortie_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryGreen,
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: const <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Text("👩🏽‍💼", style: TextStyle(fontSize: 40)),
                ),
                SizedBox(height: 8),
                Text(
                  "Dépensia",
                  style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          CustomListTile(
              Icons.home_outlined,
              'Accueil',
              () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccueilPage(title: "Dépensia")))
                  }),
          CustomListTile(
              Icons.input_outlined,
              'Ajouter une entrée',
              () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddEntreePage(title: "Ajouter une entrée")))
                  }),
          CustomListTile(
              Icons.inbox_outlined,
              'Liste des entrées',
              () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ListEntreePage(title: "Liste des entrées")))
                  }),
          CustomListTile(
              Icons.outbox_outlined,
              'Liste des sorties',
              () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ListSortiePage(title: "Liste des sorties")))
                  }),
          CustomListTile(Icons.logout, 'Se déconnecter', () async {
            await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    contentPadding: const EdgeInsets.all(10.0),
                    children: [
                      const Text("VOULEZ VOUS VRAIMENT VOUS DECONNECTER ??",
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Annuler",
                                  style: TextStyle(fontSize: 12))),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Me déconnecter",
                                  style: TextStyle(fontSize: 12)))
                        ],
                      )
                    ],
                  );
                });
          }),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onTap;

  const CustomListTile(this.icon, this.text, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0, 8.0, 0),
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white54))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              splashColor: Colors.white24,
              onTap: onTap,
              child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            icon,
                            color: Colors.white70,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          Text(
                            text,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }
}
