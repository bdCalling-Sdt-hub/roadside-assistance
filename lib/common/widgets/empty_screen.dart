import 'package:flutter/material.dart';
import 'package:roadside_assistance/common/app_images/app_images.dart';
import 'package:lottie/lottie.dart';


class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(AppImage.emptyImg,),
    );
  }
}
