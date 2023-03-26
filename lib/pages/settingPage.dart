import 'package:flutter/material.dart';

import '../model/rouletteModel.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}



class _SettingPageState extends State<SettingPage> {

  List<RouletteModel> rouletteList2 = [

  ];


  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('設定'),
      ),
      body: ListView.builder(
        itemCount: rouletteList2.length,
          itemBuilder: (context,index){
        return ListTile(
          title: Text(rouletteList2[index].name),
        );

      }),
    );
  }
}
