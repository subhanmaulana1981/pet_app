
import 'dart:typed_data';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pet_app/models/pet.dart';

class PetPdfService {
  // generates a pdf catalog grouped by pet species
  static Future<Uint8List> generatePetReport(List<Pet> pets) async {
    // 1. create a new pdf document
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 36;
    document.pageSettings.size = PdfPageSize.a4;

    // 2. add header and footer templates (repeat on every pages)
    _addHeaderAndFooter(document);

    // 3. add first page
    PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    final Size pageSize = page.getClientSize();

    // 4. document fonts and brushes
    // title
    final PdfStandardFont titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      20,
      style: PdfFontStyle.bold
    );
    // sub title
    final PdfStandardFont subTitleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
    );
    // category
    final PdfStandardFont categoryFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      14,
      style: PdfFontStyle.bold
    );

    final PdfBrush primaryBrush = PdfSolidBrush(PdfColor(41, 128, 185));
    final PdfBrush textBrush = PdfSolidBrush(PdfColor(51, 51, 51));

    // 5. draw document header
    double yOffset = 0;
    graphics.drawString(
      'PET CATALOG REPORT',
      titleFont,
      brush: primaryBrush,
      bounds: Rect.fromLTWH(0, yOffset, pageSize.width, 30),
    );

    yOffset += 26;
    final String generatedDate = 'generated on: '
        '${DateTime.now().toLocal().toString().split('.')[0]}';
    final String summaryText = 'total registered pets: ${pets.length} | '
        '$generatedDate';
    graphics.drawString(
      summaryText,
      subTitleFont,
      brush: textBrush,
      bounds: Rect.fromLTWH(0, yOffset, pageSize.width, 20),
    );

    yOffset += 24;
    // draw a divider line
    graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200), width: 1),
        Offset(0, yOffset),
        Offset(pageSize.width, yOffset),
    );

    yOffset += 16;
    // 6. group pets by species
    final Map<String, List<Pet>> groupedPets = {};
    for (final pet in pets) {
      final speciesKey = pet.species.trim().isEmpty
          ? 'uncategorized'
          : pet.species.trim();

      groupedPets.putIfAbsent(speciesKey, () {
        return [];
      }).add(pet);
    }

    // 7. render each category and its table
    for (final entry in groupedPets.entries) {
      // define the border pen
      final PdfBorders borders = PdfBorders();
      borders.all = PdfPen(PdfColor(220, 220, 220), width: 0.5);

      // categories and its children
      final String categoryName = entry.key;
      final List<Pet> categoryList = entry.value;

      // check if we need to add a page
      // before starting a new category
      if (yOffset > pageSize.height - 120) {
        page = document.pages.add();
        yOffset = 10;
      }

      // draw category title
      final PdfTextElement categoryElement = PdfTextElement(
        text: '${_sanitizeText(categoryName)} (${categoryList.length})',
        font: categoryFont,
        brush: primaryBrush,
      );
      final PdfLayoutResult catResult = categoryElement.draw(
        page: page,
        bounds: Rect.fromLTWH(0, yOffset, pageSize.width, 30),
      )!;
      yOffset = catResult.bounds.bottom + 8;
      page = catResult.page;

      // build (table)
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 4);

      // define column widths
      grid.columns[0].width = 40; // no.
      grid.columns[1].width = 180; // pet name
      grid.columns[2].width = 160; // pet id
      grid.columns[3].width = 100; // isFavorite

      // table header row
      final PdfGridRow headerRow = grid.headers.add(1)[0];
      headerRow.cells[0].value = 'no.';
      headerRow.cells[1].value = 'pet name';
      headerRow.cells[2].value = 'id';
      headerRow.cells[3].value = 'favorite?';

      // style header row
      headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(240, 243, 244));
      headerRow.style.textBrush = PdfSolidBrush(PdfColor(44, 62, 80));
      headerRow.style.font = PdfStandardFont(
        PdfFontFamily.helvetica,
        10,
        style: PdfFontStyle.bold,
      );
      for (int i = 0; i < headerRow.cells.count; i++) {
        headerRow.cells[i].style.borders = borders;
      }

      // add table rows
      for (int i = 0; i < categoryList.length; i++) {
        final pet = categoryList[i];
        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = '${i + 1}';
        row.cells[1].value = _sanitizeText(pet.name);
        row.cells[2].value = _sanitizeText(pet.id);
        row.cells[3].value = pet.isFavorite ? 'Yes' : 'No';

        // alternate row colors for readability
        if (i % 2 == 1) {
          row.style.backgroundBrush = PdfSolidBrush(PdfColor(220, 220, 220));
        }
      }

      // format grid padding and borders
      // grid padding
      grid.style.cellPadding = PdfPaddings(
          left: 6,
          right: 6,
          top: 6,
          bottom: 5
      );
      // grid border
      grid.rows.applyStyle(PdfGridCellStyle(borders: borders));

      // draw grid to the page
      // syncfusion handles multi-page split automatically
      final PdfLayoutResult gridResult = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, yOffset, pageSize.width, 0),
      )!;

      // update yOffset and current page for the next category
      yOffset = gridResult.bounds.bottom + 20;
      page = gridResult.page;
    }

    // 8. save and dispose
    final List<int> bytes = document.saveSync();
    document.dispose();

    return Uint8List.fromList(bytes);
  }

  // filters out characters not supported by standard PDF fonts
  // (e.g. symbols, emojis)
  static String _sanitizeText(String text) {
    return text.replaceAll(RegExp(r'[^\x20-\x7E\xA0-\xFF]'), '');
  }

  // adds a subtle footer with page numbers to all pages
  static void _addHeaderAndFooter(PdfDocument document) {
    // 1. create the template bounds
    final PdfPageTemplateElement footer = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, 500, 30)
    );

    // 2. build dynamic page numbering
    final PdfCompositeField pageNumber = PdfCompositeField(
      font: PdfStandardFont(PdfFontFamily.helvetica, 8),
      brush: PdfSolidBrush(PdfColor(130, 130, 130)),
      text: 'page {0} of {1}',
      fields: <PdfAutomaticField>[
        PdfPageNumberField(),
        PdfPageCountField(),
      ],
    );
    pageNumber.draw(footer.graphics, Offset(0, 10));

    // 3. assigning it here automatically marks it as a document template!
    document.template.bottom = footer;
  }
}
