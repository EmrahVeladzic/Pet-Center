import 'package:pdf/widgets.dart' as pw;
import 'package:pet_center_app/utils/helpers.dart';
import 'package:printing/printing.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/account_service.dart';

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
