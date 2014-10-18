library csv;

import 'dart:convert';
import 'dart:async';

import 'src/csv_parser.dart';
import 'csv_settings_autodetection.dart';

part 'csv_to_list_converter.dart';
part 'list_to_csv_converter.dart';


/// This is the RFC conform default value for field delimiter.
const String defaultFieldDelimiter = ',';

/// This is the RFC conform default value for the text delimiter.
const String defaultTextDelimiter = '"';

/// This is the RFC conform default value for eol.
const String defaultEol = '\r\n';


/// A codec which converts a csv string ↔ List of rows.
///
/// See [CsvToListConverter] and [ListToCsvConverter].
class CsvCodec extends Codec<List<List>, String> {

  final CsvToListConverter decoder;

  final ListToCsvConverter encoder;


  CsvCodec({String fieldDelimiter: defaultFieldDelimiter,
            String textDelimiter: defaultTextDelimiter,
            String textEndDelimiter,
            String eol: defaultEol,
            bool parseNumbers: true,
            bool allowInvalid: true})
      : decoder = new CsvToListConverter(fieldDelimiter: fieldDelimiter,
                                         textDelimiter: textDelimiter,
                                         textEndDelimiter: textEndDelimiter,
                                         eol: eol,
                                         parseNumbers: parseNumbers,
                                         allowInvalid: allowInvalid),
        encoder = new ListToCsvConverter(fieldDelimiter: fieldDelimiter,
                                         textDelimiter: textDelimiter,
                                         textEndDelimiter: textEndDelimiter,
                                         eol: eol);

}


