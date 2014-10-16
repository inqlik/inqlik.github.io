import 'dart:html';
import 'package:qv_exp/src/parser.dart';
import 'package:petitparser/petitparser.dart' as p;
bool dirty = true;
void main() {
  querySelector("#parse_expression")
      ..onClick.listen(parseExpression);
  querySelector("#formula_text")..onInput.listen(invalidateResult);
}

void parseExpression(MouseEvent event) {
  var expressionText = (querySelector("#formula_text") as TextAreaElement).value;
  var qvs = new QvExpParser();
  var parser = qvs['start'].end();
  p.Result parseResult = new QvExpParser().guarded_parse(expressionText);
  String  resultText = 'Expression parsed successfully';
  String textWithErrorMark = '';
  if (parseResult.isFailure) {
    textWithErrorMark = expressionText.substring(0,parseResult.position) + '▼' + expressionText.substring(parseResult.position);
    resultText = '''Error while parsing expression: ${parseResult.message} at position ${parseResult.position}''';
  }
  querySelector("#expression_with_mark").text = textWithErrorMark;
  querySelector("#result").text = resultText;
  dirty = false;
}
void invalidateResult(_) {
  if (!dirty) {
    querySelector("#result").text = '';
    querySelector("#expression_with_mark").text = '';
    dirty = true;
  }  
}