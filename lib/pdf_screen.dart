import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key, required this.pdfDoc}) : super(key: key);

  final PDFDocument pdfDoc;

  @override
  State<PDFScreen> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFScreen> {

  late PDFDocument pdfDocument;
  bool _isLoading = true;

  @override
  void initState() {
    setPdfDoc();
  }

  void setPdfDoc() {
    pdfDocument = widget.pdfDoc;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View PDF'),
        backgroundColor: Colors.green,
      ),
      body: Center(
          child: _isLoading ? const Center(child: CircularProgressIndicator()) :
          PDFViewer(document: pdfDocument))
    );
  }

}