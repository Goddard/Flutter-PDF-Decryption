import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:decryption_demo/pdf_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:encrypt/encrypt.dart' as Enc;
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:convert';

class HomeRoute extends StatefulWidget {
  const HomeRoute({Key? key}) : super(key: key);

  @override
  State<HomeRoute> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeRoute> {

  String encryptedPdfContents = "";
  bool _isLoading = true;

  final KEY = "12345678901234561234567890123456";
  final IV = "1234567890123456";

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    loadEncryptedFile();
  }

  void loadEncryptedFile() async {
    encryptedPdfContents = await rootBundle.loadString("assets/encryptedPdf.txt");
    print("encrypted pdf contents loaded");
    setState(() => _isLoading = false);
  }

  void decryptPdfContents() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), decryptString);
  }

  void decryptString() async {
    print("decryption started");

    final key = Enc.Key.fromUtf8(KEY);
    final iv = Enc.IV.fromUtf8(IV);

    final encrypter = Enc.Encrypter(Enc.AES(key, mode: Enc.AESMode.cbc, padding: null));
    print("algorithm");
    print(encrypter.algo);

    final bytes = base64Decode(encryptedPdfContents);
    print(bytes);

    final decrypted = encrypter.decryptBytes(Enc.Encrypted(bytes), iv: iv);
    print("decrypted");
    print(decrypted);

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/decrypted.pdf");

    await file.writeAsBytes(decrypted);

    final pdfDoc = await PDFDocument.fromFile(file);
    print("pdf created");
    print(pdfDoc.filePath);

    setState(() => _isLoading = false);

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PDFScreen(pdfDoc: pdfDoc)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: SingleChildScrollView(child: Center(
          child: _isLoading ? const Center(heightFactor: 20, child: CircularProgressIndicator()) :
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
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  strutStyle: const StrutStyle(fontSize: 12.0),
                  text: TextSpan(
                    text: encryptedPdfContents.length > 10000 ? encryptedPdfContents.substring(0, 9999) : encryptedPdfContents,
                    style: const TextStyle(color: Colors.black),
                  ),
                  maxLines: 500,
                  textAlign: TextAlign.center,
                )
              )
            ],
          )
      )),
      bottomNavigationBar: (
          _isLoading ? const SizedBox() : MaterialButton(
            onPressed: () {
              decryptPdfContents();
            },
            elevation: 5,
            color: Colors.red,
            child: const Text("Decrypt PDF"),
          )
      ),
    );
  }
}
