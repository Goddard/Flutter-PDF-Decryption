import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:decryption_demo/pdf_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as Enc;
import 'package:path_provider/path_provider.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({Key? key}) : super(key: key);

  @override
  State<HomeRoute> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeRoute> {

  String pdfPath = "";
  String encryptedPdf = "";
  bool _isLoading = true;
  PDFDocument document = PDFDocument();

  final KEY = "12345678901234561234567890123456";
  final IV = "1234567890123456";

  @override
  void initState() {
    setState(() => _isLoading = true);
    loadDocument();
  }

  void loadDocument() async {
    document = await PDFDocument.fromAsset('assets/sample.pdf');

    print("doc loaded");
    print(document.filePath);
    pdfPath = document.filePath!;

    getPdfBytes();
  }

  ///Get the PDF document as bytes.
  void getPdfBytes() async {
    Uint8List _documentBytes = File(pdfPath).readAsBytesSync();
    encryptString(_documentBytes);
  }

  void encryptString(bytes) async {
    print("encryption started");

    // final key = Enc.Key.fromLength(16);
    final key = Enc.Key.fromUtf8(KEY);
    // final key = "1234567890123456" as Enc.Key;
    final iv = Enc.IV.fromUtf8(IV);

    final encrypter = Enc.Encrypter(Enc.AES(key, mode: Enc.AESMode.cbc));
    print("algorithm");
    print(encrypter.algo);

    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    encryptedPdf = encrypted.base64;
    print("encrypted");
    print(encryptedPdf);

    setState(() => _isLoading = false);
  }

  void decryptString() async {
    setState(() => _isLoading = true);
    print("decryption started");

    // final key = Enc.Key.fromLength(16);
    final key = Enc.Key.fromUtf8(KEY);
    // final key = "1234567890123456" as Enc.Key;
    final iv = Enc.IV.fromUtf8(IV);

    final encrypter = Enc.Encrypter(Enc.AES(key, mode: Enc.AESMode.cbc));
    print("algorithm");
    print(encrypter.algo);

    final decrypted = encrypter.decrypt64(encryptedPdf, iv: iv);
    print("decrypted");
    print(decrypted);

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(decrypted.codeUnits);

    final pdfDoc = await PDFDocument.fromFile(file);
    print("pdf created");
    print(pdfDoc.filePath);

    setState(() => _isLoading = false);

    Navigator.push(context, MaterialPageRoute(builder: (context) => PDFScreen(pdfDoc: pdfDoc)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: SingleChildScrollView(child: Center(
          child: _isLoading ? const Center(child: CircularProgressIndicator()) :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Encrypted PDF contents:-',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              // Expanded(child: Container(), flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  encryptedPdf,
                  textAlign: TextAlign.center,
              )),
            ],
          )
      )),
      bottomNavigationBar: (
          MaterialButton(
            onPressed: () {
              decryptString();
            },
            elevation: 5,
            color: Colors.red,
            child: const Text("Decrypt PDF"),
          )
      ),
    );
  }
}
