//
// (c) 2017 Appirio, Inc.
//
// Apex Class Name: CSVReader
// Description: This apex class is used for reading CSV files.
//
//
public with sharing class CSVReader {
  /*
  @method      : readCSVFile
  @description : This method is used to read CSV file.
  @params      : String fileString
  @returns     : List<List<String>> fileValues
  */
  public static List<List<String>> readCSVFile(String fileString) {
    if(!fileString.endsWith(CSVParser.CRLF)) {
      fileString = fileString + CSVParser.CRLF;
    }

    List<List<String>> fileValues = new List<List<String>>();
    List<String> rowValues = new List<String>();
    CSVValue csvValue = new CSVValue();

    Boolean eod = false;
    while(!eod) {
      csvValue = readCSVValue(fileString);
      rowValues.add(csvValue.value);

      if(csvValue.delimiter == CSVParser.CRLF) {
        fileValues.add(rowValues);
        rowValues = new List<String>();
      }

      if(csvValue.biteSize() == fileString.length()) {
        eod = true;
      }
      else {
        fileString = fileString.substring(csvValue.biteSize());
      }
    }
    return fileValues;
  }
    
  /*
  @method      : readCSVValue
  @description : This method is used to read CSV values.
  @params      : String data
  @returns     : CSVValue csvValue
  */
  public static CSVValue readCSVValue(String data) {
    System.assert(data.endsWith(CSVParser.CRLF));

    CSVValue csvValue = new CSVValue();
    if(data.startsWith(CSVParser.DQUOTE)) {
      csvValue.enclosed = true;

      Integer searchIndex = 1;
      Integer dquoteIndex = -1;
      Integer dquotesIndex = -1;
      Boolean closerFound = false;

      while(!closerFound) {
        dquoteIndex = data.indexOf(CSVParser.DQUOTE, searchIndex);
        dquotesIndex = data.indexOf(CSVParser.DQUOTEDQUOTE, searchIndex);
        System.assert(dquoteIndex != -1);

        if(dquoteIndex == dquotesIndex) {
          searchIndex = dquotesIndex + CSVParser.DQUOTEDQUOTE.length();
        }
        else {
          closerFound = true;
        }
      }

      csvValue.value = data.substring(CSVParser.DQUOTE.length(), dquoteIndex).replaceAll(CSVParser.DQUOTEDQUOTE, CSVParser.DQUOTE);

      Integer commaIndex = data.indexOf(CSVParser.COMMA, dquoteIndex);
      Integer crlfIndex = data.indexOf(CSVParser.CRLF, dquoteIndex);
      if(commaIndex != -1 && commaIndex < crlfIndex) {
        csvValue.delimiter = CSVParser.COMMA;
      }
      else {
        csvValue.delimiter = CSVParser.CRLF;
      }
    }
    else {
      csvValue.enclosed = false;

      Integer commaIndex = data.indexOf(CSVParser.COMMA);
      Integer crlfIndex = data.indexOf(CSVParser.CRLF);

      if(commaIndex != -1 && commaIndex < crlfIndex) {
        csvValue.value = data.substring(0, commaIndex);
        csvValue.delimiter = CSVParser.COMMA;
      }
      else {
        csvValue.value = data.substring(0, crlfIndex);
        csvValue.delimiter = CSVParser.CRLF;
      }
    }
    return csvValue;
  }
    
  // Inner Class.
  private class CSVValue {
    // Public Data Members.
    public String value;
    public Boolean enclosed;
    public String delimiter;

    // Default Constructor.
    public CSVValue() {
      this(null, null, null);
    }
        
    // Parameterized Constructor.
    public CSVValue(String value, Boolean enclosed, String delimiter) {
      this.value = value;
      this.enclosed = enclosed;
      this.delimiter = delimiter;
    }
        
    /*
    @method      : biteSize
    @description : Returns the number of characters to remove from the data string which produced the CSVValue
                   in order to reach the next value in the data String.
    @params      : void
    @returns     : Integer biteSize
    */
    public Integer biteSize() {
      Integer biteSize = value.replaceAll(CSVParser.DQUOTE, CSVParser.DQUOTEDQUOTE).length() + delimiter.length();
      if(enclosed) {
        biteSize += CSVParser.DQUOTE.length() * 2;
      }
      return biteSize;
    }

    /*
    @method      : equals
    @description : Returns whether a CSVValue has the same <code>value</code> and <code>enclosed</code> as another CSVValue.
    @params      : CSVValue compCSVValue
    @returns     : Boolean
    */
    public Boolean equals(CSVValue compCSVValue) {
      return this.value.equals(compCSVValue.value) && this.enclosed == compCSVValue.enclosed && this.delimiter == compCSVValue.delimiter;
    }

    /*
    @method      : assertEquals
    @description : Asserts that two <code>CSVValue</code> instances have the same <code>value</code> and <code>enclosed</code>.
    @params      : CSVValue compCSVValue
    @returns     : void
    */
    public void assertEquals(CSVValue compCSVValue) {
      System.assertEquals(value, compCSVValue.value);
      System.assertEquals(enclosed, compCSVValue.enclosed);
      System.assertEquals(delimiter, compCSVValue.delimiter);
    }
  }
}