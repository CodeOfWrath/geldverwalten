import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../../../balance/domain/entities/solde_entity.dart';
import '../../../balance/presentation/pages/accueil_page.dart';
import '../../domain/entities/entree_entity.dart';

class AddEntreePage extends StatefulWidget {
  const AddEntreePage({super.key, required this.title});

  final String title;

  @override
  State<AddEntreePage> createState() => _AddEntreePageState();
}

class _AddEntreePageState extends State<AddEntreePage> {
  final TextEditingController origine = TextEditingController();
  final TextEditingController montant = TextEditingController();

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
            body: SingleChildScrollView(
              child: Center(
                  child: Stack(
                alignment: AlignmentDirectional.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const Text("Les 3 dernières entrées"),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 6,
                    child: FutureBuilder<List<EntreeEntity>>(
                      future: listeEntree,
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length < 3
                                  ? snapshot.data!.length
                                  : 3,
                              itemBuilder: (context, index) {
                                int taille = snapshot.data!.length - 1;
                                EntreeEntity item = snapshot.data![taille - index];
                                return InkWell(
                                    onTap: () {},
                                    child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 40, left: 5, right: 5, bottom: 5),
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
                                        width: MediaQuery.of(context).size.width / 3.3,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(item.origine),
                                            Text("${item.montant}"),
                                          ],
                                        )));
                              });
                        }
                        return const CircularProgressIndicator();
                      }),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 5),
                    child: const Text("Nouvelle Entrée"),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 3),
                    decoration: const BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            topRight: Radius.circular(100))),
                    height: MediaQuery.of(context).size.height / 1.81,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              SizedBox(width: 20),
                              Text("Raison", textAlign: TextAlign.start),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.eco_outlined, size: 24),
                              SizedBox(
                                height: 20,
                                width: MediaQuery.of(context).size.width / 1.4,
                                child: Center(
                                  child: TextField(
                                    controller: origine,
                                    decoration: const InputDecoration.collapsed(
                                        border: UnderlineInputBorder(), hintText: ""),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              SizedBox(width: 20),
                              Text("Montant", textAlign: TextAlign.start),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.eco_outlined, size: 24),
                              SizedBox(
                                height: 20,
                                width: MediaQuery.of(context).size.width / 1.4,
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
                          const SizedBox(height: 120),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildButton("Valider l'entrée", Colors.green, () async {
                                if (origine.text.isNotEmpty && montant.text.isNotEmpty) {
                                  await sl.addEntreeUseCase(
                                      origine.text, int.parse(montant.text));
                                }
                                if (mounted) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return const AddEntreePage(title: "title");
                                  }));
                                }
                              }),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
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
