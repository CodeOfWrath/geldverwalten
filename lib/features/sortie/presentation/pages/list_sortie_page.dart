import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../balance/domain/entities/solde_entity.dart';
import '../../../balance/presentation/pages/accueil_page.dart';
import '../../../projet/domain/entities/projet_entity.dart';
import '../widgets/sortie_presentation.dart';

class ListSortiePage extends StatefulWidget {
  const ListSortiePage({super.key, required this.title});

  final String title;

  @override
  State<ListSortiePage> createState() => _ListSortiePageState();
}

class _ListSortiePageState extends State<ListSortiePage> {
  late Future<List<ProjetEntity>> listProjets;
  late Future<List<SoldeEntity>> lesolde;

  @override
  void initState() {
    super.initState();
    listProjets = sl.getProjetsUseCase();
    lesolde = sl.getSoldeUseCase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(
              elevation: 0,
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
            ),
            body: Center(
              child: FutureBuilder<List<ProjetEntity>>(
                future: listProjets,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text("Toutes les sorties"),
                              Container(
                                margin: const EdgeInsets.only(top: 50, left: 5, right: 5),
                                height: MediaQuery.of(context).size.height / 1.3,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      ProjetEntity projet = snapshot.data![index];
                                      return InkWell(
                                          onTap: () {},
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, left: 0, bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                    color: Colors.white)
                                              ],
                                            ),
                                            width: 100,
                                            child: SortiePresentation(
                                              idProjet: projet.id,
                                              nomProjet: projet.nomProjet,
                                            ),
                                          ));
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                }),
              ),
            )),
        onWillPop: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const AccueilPage(title: "title");
          }));
          return Future.value(false);
        });
  }
}
