import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
import '../../../balance/domain/entities/solde_entity.dart';
import '../../../balance/presentation/pages/accueil_page.dart';
import '../../../sortie/domain/entities/sortie_entity.dart';
import '../../domain/entities/projet_entity.dart';

class ProjetInfoPage extends StatefulWidget {
  const ProjetInfoPage({super.key, required this.title});

  final String title;

  @override
  State<ProjetInfoPage> createState() => _ProjetInfoPageState();
}

class _ProjetInfoPageState extends State<ProjetInfoPage> {
  final TextEditingController raison = TextEditingController();
  final TextEditingController montant = TextEditingController();

  late ProjetEntity selectedP = const ProjetEntity(
      id: 0, idUser: 0, statut: 0, nomProjet: "aucun projet selectionné");

  late Future<List<SoldeEntity>> lesolde;
  late Future<List<ProjetEntity>> listProjets;
  late Future<List<SortieEntity>> listSorties;

  @override
  void initState() {
    super.initState();
    lesolde = sl.getSoldeUseCase();
    listProjets = sl.getProjetsUseCase();
    listSorties = sl.getSortiesByProjetUseCase(0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                FutureBuilder<List<SoldeEntity>>(
                  future: lesolde,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Text(
                        snapshot.data![0].montant.toString(),
                        style: const TextStyle(fontSize: 50),
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
                ),
              ],
              elevation: 0,
            ),
            body: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<List<ProjetEntity>>(
                  future: listProjets,
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 7,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              ProjetEntity projet = snapshot.data![index];
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedP = projet;
                                      listSorties =
                                          sl.getSortiesByProjetUseCase(selectedP.id);
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        top: 5, left: 10, bottom: 5),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                            color: Colors.grey)
                                      ],
                                    ),
                                    width: 100,
                                    child: Text(projet.nomProjet),
                                  ));
                            }),
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(selectedP.nomProjet),
                      FutureBuilder<List<SortieEntity>>(
                        future: listSorties,
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              margin: const EdgeInsets.only(
                                  top: 20, left: 15, right: 15),
                              height: MediaQuery.of(context).size.height / 1.8,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    SortieEntity item = snapshot.data![index];
                                    return InkWell(
                                        onTap: () {},
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 5, left: 0, bottom: 5),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: const [
                                              BoxShadow(
                                                  offset: Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.grey)
                                            ],
                                          ),
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(item.message),
                                              Text("${item.montant}")
                                            ],
                                          ),
                                        ));
                                  }),
                            );
                          }
                          return Container(
                            height: 20 + MediaQuery.of(context).size.height / 1.8,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                buildButton("Nouvelle sortie", Colors.green, () {
                  newSortie();
                }),
              ],
            ))),
        onWillPop: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const AccueilPage(title: "title");
          }));
          return Future.value(false);
        });
  }

  Future<void> newSortie() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              "Informations sur la sortie",
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 11,
            contentPadding: const EdgeInsets.all(10.0),
            children: [
              const SizedBox(height: 10),
              const Text("Raison", textAlign: TextAlign.start),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.eco_outlined, size: 18),
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Center(
                      child: TextField(
                        controller: raison,
                        decoration: const InputDecoration.collapsed(
                            border: UnderlineInputBorder(), hintText: ""),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Montant", textAlign: TextAlign.start),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.eco_outlined, size: 18),
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Center(
                      child: TextField(
                        controller: montant,
                        keyboardType: TextInputType.number,
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
                    if (raison.text.isNotEmpty && montant.text.isNotEmpty) {
                      await sl.addSortieUseCase(
                          raison.text, montant.text, selectedP.id);
                    }
                    if (mounted) {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                        return const ProjetInfoPage(title: "title");
                      }));
                    }
                  }),
                ],
              )
            ],
          );
        });
  }
}
