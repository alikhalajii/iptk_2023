// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  const ImageInput({Key? key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: source, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  void _takePicture() async {
    _pickImage(ImageSource.camera);
  }

  void _selectFromGallery() async {
    _pickImage(ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(
        Icons.camera,
        color: Colors.pink,
      ),
      label: const Text(
        'Take Picture',
        style: TextStyle(color: Colors.pink),
      ),
      onPressed: _takePicture,
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(
              Icons.camera,
              color: Colors.white,
            ),
            label: const Text(
              'Take Picture',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _takePicture,
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
            label: const Text(
              'Choose from Gallery',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _selectFromGallery,
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.pink),
      ),
      height: 200,
      width: double.infinity,
      child: content,
    );
  }
}
