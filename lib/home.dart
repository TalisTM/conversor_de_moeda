import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  Future dados;

  @override
  void initState() {
    dados = getData();
  }

  void _changedReal(text){
    _clearAll(realController);
    dolarController.text = (double.parse(realController.text) / dolar).toStringAsFixed(2);
    euroController.text = (double.parse(realController.text) / euro).toStringAsFixed(2);
  }

  void _changedDolar(text){
    _clearAll(dolarController);
    realController.text = (double.parse(dolarController.text) * dolar).toStringAsFixed(2);
    euroController.text = ((double.parse(dolarController.text) * dolar) / euro).toStringAsFixed(2);
  }

  void _changedEuro(text){
    _clearAll(euroController);
    realController.text = (double.parse(euroController.text) * euro).toStringAsFixed(2);
    dolarController.text = ((double.parse(euroController.text) * euro) / dolar).toStringAsFixed(2);
  }

  void _clearAll(TextEditingController t){
    if(t.text.isEmpty || double.parse(t.text) == 0){
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.4,
        centerTitle: true,
        title: Text("Conversor de Moeda",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder(
        future: dados,
        builder: (context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 35
                  ),
                ),
              );
            break;
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 35
                    ),
                  ),
                );
              } else {
                dolar = snapshot.data["USD"]["buy"];
                euro = snapshot.data["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 150,
                      ),
                      Divider(),
                      TextFieldBuilder("Real", "R\$", realController, _changedReal),
                      Divider(),
                      TextFieldBuilder("Dolar", "US\$", dolarController, _changedDolar),
                      Divider(),
                      TextFieldBuilder("Euro", "€", euroController, _changedEuro),
                    ],
                  ),
                );
              }
          }
        }
      )
    );
  }
}

TextFieldBuilder(String text, String moeda, TextEditingController c, Function f){
  return TextField (
    keyboardType: TextInputType.number,
    controller: c,
    style: TextStyle(
      fontSize: 25,
      color: Colors.amber,
    ),
    decoration: InputDecoration(
      prefixText: moeda,
      labelText: text,
      border: OutlineInputBorder(),
      disabledBorder: OutlineInputBorder(),
      hintStyle: TextStyle(
        color: Colors.amber,
        fontSize: 25,
      ),
      labelStyle: TextStyle(
        color: Colors.amber,
        fontSize: 25,
      ),
    ),
    onChanged: f,
  );
}

Future<Map> getData() async {
  const request = 'https://api.hgbrasil.com/finance?format=json&key=3993e7d3';
  var response = await http.get(request);

  Map data = json.decode(response.body)["results"]["currencies"];

  return data;
}