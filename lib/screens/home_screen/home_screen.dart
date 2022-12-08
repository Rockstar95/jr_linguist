import 'package:flutter/material.dart';

import '../../utils/SizeConfig.dart';
import '../../utils/styles.dart';
import '../common/components/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: Column(
        children: [
          MyAppBar(title: "Home", color: Colors.white, backbtnVisible: false,),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MySize.size20!),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Center(
                    child: Text("Home"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
