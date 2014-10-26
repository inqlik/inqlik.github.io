import 'dart:html';
import 'package:qvs/src/qvs_reader.dart';
//import 'package:petitparser/petitparser.dart' as p;
import 'dart:js' show context;

void main() {
  querySelector("#parse")
      ..onClick.listen(parseExpression);
  querySelector("#edit")
      ..onClick.listen(editCode)
      ..style.display = 'none';
  querySelector("#code_area_id").style.display = 'none';
  querySelector("#errors_area_id").style.display = 'none';
  querySelector("#edit").style.display = 'none';
  querySelector("#app").style.removeProperty('display');
}
void editCode(MouseEvent event) {
  querySelector("#edit").style.display = 'none';
  querySelector("#code_area_id").style.display = 'none';
  querySelector("#parse").style.display = 'inline';
  querySelector("#source_code").style.display = 'inline';
  querySelector("#errors_area_id").style.display = 'none';
  querySelector("#result_summary").text = '';
}
void parseExpression(MouseEvent event) {
  var sourceInput = (querySelector("#source_code") as TextAreaElement);
  var sourceText = sourceInput.value;
  sourceInput.style.display = 'none';
  querySelector("#edit").style.display = 'inline';
  querySelector("#parse").style.display = 'none';
  var lines = sourceText.split("\n");
  var codeContainer = querySelector("#code_area_id") as DivElement;
  codeContainer.children.clear();
  int lineNum = 0;
  for (var line in lines) {
    lineNum++;
    var preTag = new PreElement();
    preTag.text = line;
    preTag.className = 'qvs';
    preTag.id = 'code_linenum_$lineNum';
    context["hljs"].callMethod('highlightBlock',[preTag]);
    codeContainer.append(preTag);
  }
  codeContainer.style.removeProperty('display');
  QvsReader reader = readQvs('web_test.qvs',sourceText);
  var resultSummary = 'Script parsed sucessfully';
  if (reader.errors.isNotEmpty) {
    TableSectionElement table = querySelector("#errors") as TableSectionElement;
    int errorId = 0;
    table.children.clear();
    for (ErrorDescriptor ed in reader.errors) {
      errorId++;
      var row = table.addRow();
      row.onClick.listen(clickOnError);
      row.addCell().text = errorId.toString();
      row.addCell().text = ed.lineNum.toString();
      row.addCell().appendText(ed.errorMessage);
      var preTag = new PreElement();
      preTag.text = ed.commandWithError;
      preTag.className = 'qvs';
      preTag.id = 'code_linenum_$lineNum';
      preTag.style.display = 'inline';
      context["hljs"].callMethod('highlightBlock',[preTag]);
      row.addCell().append(preTag);
    }
    resultSummary = '${reader.errors.length} errors found';
    querySelector("#errors_area_id").style.removeProperty('display');
  }
  querySelector("#result_summary").text = resultSummary;
}

void clickOnError(MouseEvent event) {
  TableRowElement row = event.currentTarget;
  for (TableRowElement each in row.parent.children) {
    each.classes.remove('selected');
  }
  row.classes.add('selected');
  var lineNum = row.children[1].text;
  var id = '#code_linenum_$lineNum';
  for (var each in querySelector("#code_area_id").children) {
    each.classes.remove('selected');
  }
  querySelector(id)
      ..scrollIntoView(ScrollAlignment.TOP)
      ..classes.add('selected');
}
