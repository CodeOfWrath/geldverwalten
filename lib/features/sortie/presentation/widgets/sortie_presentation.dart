import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/sortie_entity.dart';

class SortiePresentation extends StatefulWidget {
  final int idProjet;
  final String nomProjet;

  const SortiePresentation({super.key, required this.idProjet, required this.nomProjet});

  @override
  State<SortiePresentation> createState() => _SortiePresentationState();
}

class _SortiePresentationState extends State<SortiePresentation> {
  late Future<List<SortieEntity>> listeSortie;
  int somProjet = 0;

  @override
  void initState() {
    super.initState();
    listeSortie = sl.getSortiesByProjetUseCase(widget.idProjet);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                widget.nomProjet,
                style: const TextStyle(fontSize: 19, color: Colors.green),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
                textAlign: TextAlign.start,
              )),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<SortieEntity>>(
          future: listeSortie,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 50,
                        color: Colors.black12)
                  ],
                ),
                height: MediaQuery.of(context).size.width / 1.5,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      SortieEntity item = snapshot.data![index];
                      return InkWell(
                          onTap: () {},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      item.date,
                                      style: const TextStyle(
                                          fontSize: 19, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      textAlign: TextAlign.start,
                                    )),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 5, right: 5),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 50,
                                        color: Colors.black12)
                                  ],
                                ),
                                height: MediaQuery.of(context).size.width / 5.5,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: 1,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {},
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Icon(
                                                  Icons.eco_outlined,
                                                  size: 24,
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.4,
                                                  child: Center(
                                                      child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                        "Raison: ${item.message}    Montant: ${item.montant}"),
                                                  )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      "   Total : ${item.montant}",
                                      style: const TextStyle(
                                          fontSize: 19, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      textAlign: TextAlign.start,
                                    )),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                height: 1,
                                color: Colors.black38,
                              )
                            ],
                          ));
                    }),
              );
            }
            return const CircularProgressIndicator();
          }),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                "   Total Projet : $somProjet",
                style: const TextStyle(fontSize: 19, color: Colors.green),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
                textAlign: TextAlign.start,
              )),
        ),
        const SizedBox(height: 20),
        Container(
          height: 1,
          color: Colors.black38,
        )
      ],
    );
  }
}
