import 'package:pdf/widgets.dart' as pw;
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/image_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:printing/printing.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'dart:typed_data';

Future<void> accountsToPdf(Access role, String contact) async {
  final accounts = await AccountService.getAll(role, contact);

  if (accounts == null) {
    return;
  }

  final doc = pw.Document();

  final font = await PdfGoogleFonts.nunitoRegular();
  final fontBold = await PdfGoogleFonts.nunitoBold();

  doc.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            'Accounts — ${role.displayName}${contact.isEmpty ? "" : " \"$contact\""} - Evaluated at: ${formatDate(DateTime.now().toUtc())}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Contact', 'Role', 'Verified'],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: accounts
              .map(
                (a) => [
                  a.contact,
                  a.accessLevel.displayName,
                  a.verified ? 'Yes' : 'No',
                ],
              )
              .toList(),
        ),
      ],
    ),
  );

  final bytes = await doc.save();

  final safeContact = contact.length > 20 ? contact.substring(0, 20) : contact;
  await Printing.sharePdf(
    bytes: bytes,
    filename:
        'Accounts_${role.displayName}${safeContact.isEmpty ? "" : "_$safeContact"}.pdf',
  );
}

Future<void> formToPdf(String id) async {
  if (templates.isEmpty) {
    return;
  }
  final frm = await FormService.getById(id);
  if (frm == null) return;

  Uint8List? img;
  if (frm.media.isNotEmpty && frm.media[0].token != null) {
    img = await ImageService.get(frm.media[0].token);
    if (img == null) return;
  }

  final doc = pw.Document();
  final font = await PdfGoogleFonts.nunitoRegular();
  final fontBold = await PdfGoogleFonts.nunitoBold();

  doc.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            '${frm.franchiseName} — ${frm.defaultContact} - Evaluated at: ${formatDate(DateTime.now().toUtc())}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        if (img != null) ...[
          pw.Center(
            child: pw.Image(pw.MemoryImage(img), height: 400, width: 400),
          ),
          pw.SizedBox(height: 8),
        ],
        pw.TableHelper.fromTextArray(
          headers: ['Question', 'Answer'],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          data: frm.entries.map((e) {
            final templateField = templates
                .expand((t) => t.fields)
                .where((f) => f.id == e.formTemplateFieldId)
                .firstOrNull;

            return [
              templateField?.description ?? 'QUESTION',
              e.serialized.isEmpty ? 'NO-ANSWER' : e.serialized,
            ];
          }).toList(),
        ),
      ],
    ),
  );

  final bytes = await doc.save();
  await Printing.sharePdf(
    bytes: bytes,
    filename: 'Form_${frm.franchiseName}.pdf',
  );
}
