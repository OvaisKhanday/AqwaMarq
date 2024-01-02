import 'dart:io';

import 'package:aqwamarq/view/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:open_file/open_file.dart';

import '../../control/subject/image_subject.dart';
import '../../control/subject/pdf_subject.dart';
import '../../control/subject/subject.dart';
import '../../control/watermark/documents_created.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Subject subject;
  bool docLoaded = false;
  DocumentsCreated documents = DocumentsCreated();

  @override
  void initState() {
    super.initState();
    _getDocuments();
  }

  void _getDocuments() async {
    setState(() {
      docLoaded = false;
    });
    await documents.getPathsOfCreatedDocuments();
    setState(() {
      docLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: const Text('Select Subject'), actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  _getDocuments();
                },
              )
            ]),
            floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
              FloatingActionButton(
                key: UniqueKey(),
                onPressed: () async {
                  subject = PdfSubject();
                  await _loadAndPushNewScreen(subject, context);
                },
                tooltip: 'select PDF',
                child: const Icon(Icons.picture_as_pdf_rounded),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                key: UniqueKey(),
                onPressed: () async {
                  subject = ImageSubject();
                  await _loadAndPushNewScreen(subject, context);
                },
                tooltip: 'select Image',
                child: const Icon(Icons.photo),
              )
            ]),
            body: !docLoaded
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: ListView.builder(
                        itemCount: documents.count,
                        itemBuilder: (context, index) {
                          Widget leading;
                          if (documents.docFilenames[index].split('.')[1] != 'pdf') {
                            leading = CircleAvatar(child: Image.file(File(documents.docPaths[index])));
                          } else {
                            leading = const CircleAvatar(child: Icon(Icons.picture_as_pdf));
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                            child: GestureDetector(
                              // onTap: OpenFile.open(),
                              child: Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: leading,
                                  title: Text(documents.docFilenames[index]),
                                  trailing: IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        Share.shareXFiles([XFile(documents.docPaths[index])]);
                                      }),
                                ),
                              ),
                            ),
                          );
                        }),
                  )));
  }

  Future<void> _loadAndPushNewScreen(Subject subject, BuildContext context) async {
    if (await subject.load() == true && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectWatermarkScreen(subject: subject)));
    }
  }
}
