import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../balance/domain/entities/solde_entity.dart';
import '../../../balance/presentation/pages/accueil_page.dart';
import '../../domain/entities/entree_entity.dart';
import '../widgets/entree_presentation.dart';

class ListEntreePage extends StatefulWidget {
  const ListEntreePage({super.key, required this.title});

  final String title;

  @override
  State<ListEntreePage> createState() => _ListEntreePageState();
}

class _ListEntreePageState extends State<ListEntreePage> {
  late Future<List<EntreeEntity>> listeEntree;
  late Future<List<SoldeEntity>> lesolde;

  @override
  void initState() {
    super.initState();
    listeEntree = sl.getEntreesUseCase();
    lesolde = sl.getSoldeUseCase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(
              centerTitle: true,
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
              child: FutureBuilder<List<EntreeEntity>>(
                future: listeEntree,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text("Toutes les entrées"),
                              Container(
                                margin: const EdgeInsets.only(top: 50, left: 5, right: 5),
                                height: MediaQuery.of(context).size.height / 1.3,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      EntreeEntity item = snapshot.data![index];
                                      return InkWell(
                                        onTap: () {},
                                        child: EntreePresentation(
                                          message: item.origine,
                                          montant: item.montant,
                                          date: item.date,
                                        ),
                                      );
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
