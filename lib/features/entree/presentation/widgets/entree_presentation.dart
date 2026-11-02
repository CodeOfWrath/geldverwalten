import 'package:flutter/material.dart';

class EntreePresentation extends StatelessWidget {
  final int montant;
  final String message;
  final String date;

  const EntreePresentation({
    super.key,
    required this.montant,
    required this.message,
    required this.date,
  });

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
                date,
                style: const TextStyle(fontSize: 19, color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
                textAlign: TextAlign.start,
              )),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1), blurRadius: 50, color: Colors.black12)
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
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.eco_outlined,
                            size: 24,
                          ),
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width / 1.4,
                            child: Center(
                                child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                  "Origine: $message    Montant: $montant"),
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
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                "   Total : $montant",
                style: const TextStyle(fontSize: 19, color: Colors.black),
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
