import 'dart:io';

import 'package:aqwamarq/control/watermark/used_image_watermark.dart';
import 'package:flutter/material.dart';

import '../../control/subject/subject.dart';
import '../../control/watermark/image_watermark.dart';
import '../../control/watermark/text_watermark.dart';
import '../../control/watermark/watermark.dart';
import 'screens.dart';

// ignore: must_be_immutable
class SelectWatermarkScreen extends StatefulWidget {
  SelectWatermarkScreen({super.key, required this.subject});

  Subject subject;

  @override
  State<SelectWatermarkScreen> createState() => _SelectWatermarkScreenState();
}

class _SelectWatermarkScreenState extends State<SelectWatermarkScreen> {
  late Watermark watermark;

  final TextEditingController _textWatermarkController = TextEditingController();

  UsedImageWatermark usedImages = UsedImageWatermark();

  @override
  void initState() {
    getCacheImages();
    super.initState();
  }

  void getCacheImages() async {
    await usedImages.getPathsOfCacheImageWatermarks();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _textWatermarkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Select Watermark'),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                  key: UniqueKey(),
                  onPressed: () async {
                    watermark = ImageWatermark();

                    if (await watermark.load() == true && context.mounted) {
                      _navigateToPreviewScreen(context);
                    }
                  },
                  tooltip: 'add image',
                  child: const Icon(Icons.add_photo_alternate_rounded)),
              const SizedBox(height: 12),
              FloatingActionButton(
                  key: UniqueKey(),
                  onPressed: () {
                    watermark = TextWatermark();
                    _showDialogForTextWatermark(context);
                  },
                  tooltip: 'add text',
                  child: const Icon(Icons.text_format_rounded))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              shrinkWrap: true,
              crossAxisCount: 3,
              children: usedImages.imagePaths
                  .map((path) => GestureDetector(
                      onTap: () async {
                        watermark = ImageWatermark();
                        if (await watermark.load(value: path) == true && context.mounted) {
                          _navigateToPreviewScreen(context);
                        }
                      },
                      child: Image.file(File(path))))
                  .toList(),
            ),
          )
          // body: ListView.builder(
          //     itemCount: usedImages.imagePaths.length,
          //     itemBuilder: (context, index) {
          //       // return ListTile(
          //       //   leading: Image.file(File(usedImages.imagePaths[index])),
          //       //   title: Text(usedImages.imageFilenames[index]),
          //       // );
          //     }),
          ),
    );
  }

  void _navigateToPreviewScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PreviewScreen(subject: widget.subject, watermark: watermark)));
  }

  void _showDialogForTextWatermark(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Enter watermark text'),
            contentPadding: const EdgeInsets.all(12.0),
            children: [
              TextField(
                controller: _textWatermarkController,
                maxLength: 32,
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  print('222222222222222222222222222222222222222222222');
                  print(_textWatermarkController.text);
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    watermark.load(value: _textWatermarkController.text);
                    _navigateToPreviewScreen(context);
                    print('222222222222222222222222222222222222222222222');
                    print(_textWatermarkController.text);
                  },
                  child: const Text('submit'))
            ],
          );
        });
  }
}
