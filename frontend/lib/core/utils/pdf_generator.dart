import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateAndPrintMedicalRecord(String title, String date, String patientName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Rukhsana Gynae Clinic', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
                        pw.SizedBox(height: 4),
                        pw.Text('Women\'s Health & Maternity Center', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                        pw.Text('123 Health Avenue, City, 54000', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Container(
                      height: 60,
                      width: 60,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.purple100,
                      ),
                      child: pw.Center(
                        child: pw.Text('RGC', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
                      ),
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.purple800),
                pw.SizedBox(height: 24),
                
                // Patient Info
                pw.Text('Patient Name: $patientName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: $date', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 24),

                // Report Title
                pw.Center(
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                  ),
                ),
                pw.SizedBox(height: 32),

                // Mock Content
                pw.Text('Record Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
                pw.SizedBox(height: 12),
                pw.Text(
                  'This document serves as an official medical record. The clinical findings are recorded below. All vitals are within normal ranges. Please continue the prescribed medication and ensure adequate rest and hydration.',
                  style: pw.TextStyle(fontSize: 14, lineSpacing: 1.5),
                ),
                pw.SizedBox(height: 16),
                _buildMockTable(),
                
                pw.Spacer(),

                // Footer / Signature
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('_________________________'),
                        pw.SizedBox(height: 4),
                        pw.Text('Dr. Rukhsana', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Consultant Gynecologist', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      ],
                    )
                  ]
                ),
                pw.SizedBox(height: 24),
                pw.Center(
                  child: pw.Text('For queries, contact support@rukhsanaclinic.com', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                )
              ],
            ),
          );
        },
      ),
    );

    // Share / Save the PDF instead of directly printing to avoid printer spooler errors on Windows
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${title.replaceAll(' ', '_')}_$date.pdf',
    );
  }

  static pw.Widget _buildMockTable() {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerDecoration: pw.BoxDecoration(color: PdfColors.purple50),
      headerHeight: 30,
      cellHeight: 30,
      headerStyle: pw.TextStyle(color: PdfColors.purple800, fontWeight: pw.FontWeight.bold),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
      },
      headers: ['Test / Parameter', 'Result', 'Normal Range'],
      data: [
        ['Hemoglobin', '12.5 g/dL', '12.0 - 15.5'],
        ['Blood Sugar (Fasting)', '92 mg/dL', '70 - 100'],
        ['Blood Pressure', '118/78 mmHg', '< 120/80'],
        ['Heart Rate', '72 bpm', '60 - 100'],
      ],
    );
  }

  static Future<void> generateAndPrintDailyReport() async {
    final pdf = pw.Document();
    final date = DateTime.now().toString().split(' ')[0];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Rukhsana Gynae Clinic', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
                pw.Divider(thickness: 2, color: PdfColors.purple800),
                pw.SizedBox(height: 24),
                pw.Center(
                  child: pw.Text(
                    'Daily Analytics Report',
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(child: pw.Text('Date: $date')),
                pw.SizedBox(height: 32),
                pw.Text('Summary Statistics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  context: null,
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.purple50),
                  headers: ['Metric', 'Value'],
                  data: [
                    ['Total Patients Seen', '42'],
                    ['Average Wait Time', '14 mins'],
                    ['Pending Patients', '6'],
                    ['Completion Rate', '85%'],
                  ]
                ),
                pw.Spacer(),
                pw.Text('Generated automatically by Clinic Management System.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ]
            )
          );
        }
      )
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Daily_Report_$date.pdf',
    );
  }
}
