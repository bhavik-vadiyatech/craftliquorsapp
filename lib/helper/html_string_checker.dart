import 'package:html/parser.dart' as html_parser;

bool isHtmlContentEmpty(String? htmlText) {
  if (htmlText == null) return true;

  final document = html_parser.parse(htmlText);

  // Extract visible text only
  final String parsedText = document.body?.text ?? '';

  // Remove spaces, new lines, non-breaking spaces
  final cleanedText = parsedText
      .replaceAll('\u00A0', '') // &nbsp;
      .replaceAll('\n', '')
      .trim();

  return cleanedText.isEmpty;
}