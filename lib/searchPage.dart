import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:google_place/google_place.dart';
import 'package:geocoding/geocoding.dart';

// 場所の検索ページ
class SerachPage extends StatefulWidget {
  const SerachPage({super.key});

  @override
  State<SerachPage> createState() => _SerachPage();
}

class _SerachPage extends State<SerachPage> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  final apiKey = Api.apiKey;
  List LatLng = [];

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(apiKey);
    // initState()はFutureできないのでメソッドを格納。
    // initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            // offset: Offset(10, 10)
                          )
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              autoCompleteSearch(value);
                            } else {
                              if (predictions.length > 0 && mounted) {
                                setState(() {
                                  predictions = [];
                                });
                              }
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              color: Colors.grey[500],
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            hintText: "検索したい場所を入力",
                            hintStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w100),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(predictions[index].description.toString()),
                        onTap: () async {
                          List? locations = await locationFromAddress
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 検索処理
  void autoCompleteSearch(value) async {
    final result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}

// initState()はFutureできないのでメソッドを格納。
Future initState() async {}
