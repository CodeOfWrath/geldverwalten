import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../projet/presentation/pages/projet_info_page.dart';
import '../../domain/entities/solde_entity.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key, required this.title});

  final String title;

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final TextEditingController nomprojet = TextEditingController();
  late Future<List<SoldeEntity>> lesolde;

  @override
  void initState() {
    super.initState();
    lesolde = sl.getSoldeUseCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text("GELDVERWALTEN"),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size(50, 150),
          child: Container(),
        ),
      ),
      body: Center(
        child: FutureBuilder<List<SoldeEntity>>(
          future: lesolde,
          builder: ((context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return SingleChildScrollView(
                child: Center(
                    child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 2 - 300),
                        decoration: const BoxDecoration(
                            color: Colors.yellow,
                            borderRadius:
                                BorderRadius.all(Radius.circular(360))),
                        height: 220,
                        width: 220),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2 - 270),
                      decoration: BoxDecoration(
                          color: snapshot.data![0].montant < 0
                              ? Colors.red
                              : Colors.green,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(360))),
                      height: 160,
                      width: 160,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 60, left: 10, right: 10),
                          child: Text(
                            snapshot.data![0].montant.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 35),
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 1.9,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildButton("Nouveau Projet", Colors.green, () {
                              newProjet();
                            }),
                            buildButton("Projet en Cours", Colors.green, () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return const ProjetInfoPage(title: "title");
                              }));
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                )),
              );
            } else if (snapshot.hasError) {
              return Text("Erreur: ${snapshot.error}");
            }
            return const CircularProgressIndicator();
          }),
        ),
      ),
    );
  }

  Future<void> newProjet() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 11,
            contentPadding: const EdgeInsets.all(10.0),
            children: [
              const Text(
                "Quel est le nom de votre projet ??",
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.eco_outlined, size: 18),
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Center(
                      child: TextField(
                        controller: nomprojet,
                        decoration: const InputDecoration.collapsed(
                            border: UnderlineInputBorder(), hintText: ""),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildButton("Annuler", Colors.green, () {
                    Navigator.pop(context);
                  }),
                  buildButton("Creer", Colors.green, () async {
                    if (nomprojet.text.isNotEmpty) {
                      await sl.createProjetUseCase(nomprojet.text);
                    }
                    if (mounted) Navigator.pop(context);
                  }),
                ],
              )
            ],
          );
        });
  }
}
