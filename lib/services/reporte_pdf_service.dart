import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ReportePdfService {
  static Future<Uint8List> _generarPdf({
    required String periodoTexto,
    required String clienteTexto,
    required int totalPedidos,
    required double totalIngresos,
    required int totalBidones,
    required Map<String, int> desglose,
    required List<Map<String, dynamic>> pedidos,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generado: ${_fechaHora()}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'PEYDAR - RUC: 20614957965 - Página ${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ),
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
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                  pw.Text('RUC: 20614957965',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text('Hidratación directo a tu puerta.',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('REPORTE DE VENTAS',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(periodoTexto,
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(thickness: 2, color: PdfColors.blue900),
          pw.SizedBox(height: 14),

          // ── Filters applied ──
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              children: [
                pw.Text('Cliente: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(clienteTexto,
                    style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 24),
                pw.Text('Período: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(periodoTexto,
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Summary section ──
          pw.Header(level: 0, text: 'Resumen'),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBox('Pedidos', totalPedidos.toString(), PdfColors.blue800),
              _buildStatBox('Ingresos', 'S/. ${totalIngresos.toStringAsFixed(2)}', PdfColors.green800),
              _buildStatBox('Bidones', totalBidones.toString(), PdfColors.teal800),
            ],
          ),
          pw.SizedBox(height: 24),

          // ── Bottle breakdown ──
          pw.Header(level: 0, text: 'Desglose de Bidones'),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: pw.TextStyle(fontSize: 10),
            headers: ['Tipo', 'Color', 'Cantidad'],
            data: [
              ['Recarga', 'Azul', desglose['Recarga Azul']?.toString() ?? '0'],
              ['Recarga', 'Celeste', desglose['Recarga Celeste']?.toString() ?? '0'],
              ['Compra', 'Azul', desglose['Compra Azul']?.toString() ?? '0'],
              ['Compra', 'Celeste', desglose['Compra Celeste']?.toString() ?? '0'],
              ['', 'Total', totalBidones.toString()],
            ],
          ),
          pw.SizedBox(height: 24),

          // ── Orders table ──
          pw.Header(level: 0, text: 'Pedidos del período'),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: pw.TextStyle(fontSize: 8),
            headers: ['N°', 'Cliente', 'Fecha', 'Estado', 'Total'],
            data: pedidos.map((p) {
              final nombre = (p['usuario']?['nombre'] ?? '').toString();
              final apellido = (p['usuario']?['apellido'] ?? '').toString();
              final cliente = [nombre, apellido].where((s) => s.isNotEmpty).join(' ');
              final id = (p['id'] ?? '').toString();
              String fecha = (p['created_at'] ?? '').toString();
              try {
                final dt = DateTime.parse(fecha).toLocal();
                fecha = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
              } catch (_) {}
              final estado = (p['estado'] ?? 'PENDIENTE').toString().toLowerCase();
              double monto = 0;
              final rawMonto = p['monto_final'];
              if (rawMonto != null) {
                monto = rawMonto is double ? rawMonto : double.tryParse(rawMonto.toString()) ?? 0;
              }
              return [
                '#$id',
                cliente.isNotEmpty ? cliente : 'Cliente',
                fecha,
                estado,
                monto > 0 ? 'S/. ${monto.toStringAsFixed(2)}' : '-',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),

          // ── Footer text ──
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          pw.Text(
            'Reporte generado automáticamente por el sistema PEYDAR.',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(label,
              style: pw.TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  static Future<void> exportarPdf({
    required String periodoTexto,
    required String clienteTexto,
    required int totalPedidos,
    required double totalIngresos,
    required int totalBidones,
    required Map<String, int> desglose,
    required List<Map<String, dynamic>> pedidos,
  }) async {
    final pdf = await _generarPdf(
      periodoTexto: periodoTexto,
      clienteTexto: clienteTexto,
      totalPedidos: totalPedidos,
      totalIngresos: totalIngresos,
      totalBidones: totalBidones,
      desglose: desglose,
      pedidos: pedidos,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/reporte_peydar.pdf');
    await file.writeAsBytes(pdf);
    await OpenFilex.open(file.path);
  }

  static String _fechaHora() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$d/$m/${now.year} $h:$min';
  }
}
