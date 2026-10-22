import 'package:flutter/material.dart';
import 'add_crop_screen.dart';

/// EditCropScreen provides the direct screen presentation for editing existing crop details.
class EditCropScreen extends StatelessWidget {
  const EditCropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddCropScreen(isEdit: true);
  }
}
