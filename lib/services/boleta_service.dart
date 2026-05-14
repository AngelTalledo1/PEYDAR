import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class BoletaService {
  static Future<Uint8List> _generarPdf({
    required int pedidoId,
    required String clienteNombre,
    required String direccion,
    required String telefono,
    required List<Map<String, dynamic>> detalles,
    required double montoFinal,
    required String fecha,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── Header ──
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PEYDAR',
                      style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                  pw.Text('RUC: 20614957965',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('Hidratación directo a tu puerta.',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('BOLETA DE VENTA',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('N° ${pedidoId.toString().padLeft(4, '0')}',
                      style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 2, color: PdfColors.blue900),
          pw.SizedBox(height: 16),

          // ── Date ──
          pw.Text('Fecha: $fecha',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.SizedBox(height: 20),

          // ── Customer info ──
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('DATOS DEL CLIENTE',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 8),
                pw.Text('Nombre: $clienteNombre',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Dirección: $direccion',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Teléfono: $telefono',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // ── Products table ──
          pw.Text('DETALLE DEL PEDIDO',
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: ['Producto', 'Cantidad', 'Precio'],
            data: detalles.map((d) {
              final prod = (d['producto'] ?? d['name'] ?? '').toString();
              final cant = (d['cantidad'] ?? d['cant'] ?? d['qty'] ?? 1).toString();
              return [prod, cant, '-'];
            }).toList(),
          ),
          pw.SizedBox(height: 24),

          // ── Total ──
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700)),
                  pw.Text('S/. ${montoFinal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Text(
            '¡Gracias por tu preferencia!',
            style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'PEYDAR - Agua de calidad para tu hogar',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> verBoleta({
    required int pedidoId,
    required String clienteNombre,
    required String direccion,
    required String telefono,
    required List<Map<String, dynamic>> detalles,
    required double montoFinal,
    required String fecha,
  }) async {
    final pdf = await _generarPdf(
      pedidoId: pedidoId,
      clienteNombre: clienteNombre,
      direccion: direccion,
      telefono: telefono,
      detalles: detalles,
      montoFinal: montoFinal,
      fecha: fecha,
    );

    final filename = 'boleta_${pedidoId.toString().padLeft(4, '0')}.pdf';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdf);
    await OpenFilex.open(file.path);
  }
}
