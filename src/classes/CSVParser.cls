//
// (c) 2017 Appirio, Inc.
//
// Apex Class Name: CSVParser
// For Apex Class: CSVReader
// Description: This apex class is a utility class that contains constants used in the parsing CSV data rows.
//
//
public with sharing class CSVParser {
  // Public Constants.
  public static final String COMMA = String.fromCharArray(new List<Integer> { 44 });
  public static final String CR = '\r';
  public static final String DQUOTE = '\"';
  public static final String LF = '\n';
  public static final String CRLF = CR + LF;
  public static final String LFCR = LF + CR;
  public static final String DQUOTEDQUOTE = DQUOTE + DQUOTE;
}