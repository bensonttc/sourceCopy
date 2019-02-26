//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_MenuSignUpPDFController
// Description: Used to get list of passenger and menu for pdf
//
// 1th Feb 2016   vinod kumar  Original (Task # T-466992)
//
// 16 Feb 2017   Maksud Ali  Modified (Story# S-428451) - Please see the story description for more details.
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
// Mar 10, 2017        Abhishek Saxena     T-568302
//
public without sharing class TOPS_MenuSignUpPDFController {

    public String colourCodeVal{get; set;}
    public String fontSize{get; set;}
    public String languageParam{get; set;}
    public Tour_Instance__c tourRecord{get; set;}
    public String blankPassangerCSS {get; set;}
    public String passangerCSS {get; set;}
    public List<Passenger__c> blankPassanger {get; set;}
    public List<Passenger__c> passengerList {get; set;}
    public List<Passenger__c> secondPagePassengerList {get; set;}
    public List<Passenger__c> secondPageBlankPassanger {get; set;}
    //Changes Start,Done by Maksud Ali for Story : S-455965
    public List<StaticImageManager> footerlogoList {get; set;}
    //End code.
    String tourOptionalId, regionCode,tourInstance;
    public Tour_Optional__c tourOptional{get;set;}
    public List<Tour_Optional__c> tourOptionalList {get; set;}
    public boolean isKidsMenuAvailable{get;set;}
    public static final integer MAXRECORD = 30;

    public integer totalSoups {get; set;}
    public integer totalStarters {get;set;}
    public integer totalmainCourse {get;set;}
    public integer totalDesserts {get;set;}

    //Changes start, Done by Maksud Ali for story : S-428451
    public boolean isSoup1Available{get;set;}
    public boolean isSoup2Available{get;set;}
    public boolean isSoup3Available{get;set;}
    public boolean isSoup4Available{get;set;}
    public String theLastSoupText {get; private set;}
    public List<Integer> theLastSoupCounter { get; private set; }

    public boolean isStarte1Available{get;set;}
    public boolean isStarte2Available{get;set;}
    public boolean isStarte3Available{get;set;}
    public boolean isStarte4Available{get;set;}
    public boolean isStarte5Available{get;set;}
    public boolean isStarte6Available{get;set;}
    public boolean isStarte7Available{get;set;}
    public boolean isStarte8Available{get;set;}
    public String theLastStarterText { get; private set; }
    public List<Integer> theLastStarterCounter { get; private set; }

    public boolean isMainCourse1Available{get;set;}
    public boolean isMainCourse2Available{get;set;}
    public boolean isMainCourse3Available{get;set;}
    public boolean isMainCourse4Available{get;set;}
    public boolean isMainCourse5Available{get;set;}
    public boolean isMainCourse6Available{get;set;}
    public boolean isMainCourse7Available{get;set;}
    public boolean isMainCourse8Available{get;set;}
    public String theLastMainCourseText { get; private set; }
    public List<Integer> theLastMainCourseCounter { get; private set; }

    public boolean isDesserts1Available{get;set;}
    public boolean isDesserts2Available{get;set;}
    public boolean isDesserts3Available{get;set;}
    public boolean isDesserts4Available{get;set;}
    public boolean isDesserts5Available{get;set;}
    public boolean isDesserts6Available{get;set;}
    public boolean isDesserts7Available{get;set;}
    public boolean isDesserts8Available{get;set;}
    //End Changes.
    public String theLastDessertText { get; private set; }
    public List<Integer> theLastDessertCounter { get; private set; }
    public static Boolean isV2Status {get; set;}

    public integer width{get;set;}

    public TOPS_MenuSignUpPDFController() {
        totalStarters = 0;
        totalmainCourse = 0;
        totalDesserts = 0;
        totalSoups = 0;

        //Changes start, Done by Maksud Ali for story : S-428451
        isSoup1Available = false;
        isSoup2Available = false;
        isSoup3Available = false;
        isSoup4Available = false;
        theLastSoupText = '';
        theLastSoupCounter = new List<Integer>();

        isStarte1Available = false;
        isStarte2Available = false;
        isStarte3Available = false;
        isStarte4Available = false;
        isStarte5Available = false;
        isStarte6Available = false;
        isStarte7Available = false;
        isStarte8Available = false;
        theLastStarterText = '';
        theLastStarterCounter = new List<Integer>();

        isMainCourse1Available = false;
        isMainCourse2Available = false;
        isMainCourse3Available = false;
        isMainCourse4Available = false;
        isMainCourse5Available = false;
        isMainCourse6Available = false;
        isMainCourse7Available = false;
        isMainCourse8Available = false;
        theLastMainCourseText = '';
        theLastMainCourseCounter = new List<Integer>();

        isDesserts1Available = false;
        isDesserts2Available = false;
        isDesserts3Available = false;
        isDesserts4Available = false;
        isDesserts5Available = false;
        isDesserts6Available = false;
        isDesserts7Available = false;
        isDesserts8Available = false;
        //End changes
        theLastDessertText = '';
        theLastDessertCounter = new List<Integer>();

        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        tourOptionalId = parameters.get('relatedObjectId');
        // Mar 10, 2017        Abhishek Saxena     T-568302
        isV2Status = false;
        if(parameters.get('Parameters') != null){
            String parametersValue = parameters.get('Parameters');
            List < String > columnValues = parametersValue.split(',');
            if (parametersValue != null && parametersValue != '') {
                for (String str: columnValues) {
                    if (str.containsIgnoreCase('V2')) {
                        isV2Status = true;
                    }
                }
            }
        }
        fontSize = '14px';
        //used to get passengers list
        getTourOptionalAndPassengers();
        //used to get color code
        getColourCode();
        //used to get language
        getlanguage();
        //
        checkTotalSoups();
        checkTotalStarters();
        checkTotalMainCourse();
        checkTotalDesserts();
        integer totalMenu = totalStarters + totalmainCourse + totalDesserts;

        width = 7;
        if(isKidsMenuAvailable){
            totalMenu+= 2;
        }

        if(totalMenu > 0){
            width = 90 / totalMenu;
        }
    }

    /**
     * @description  This method is used to get list of passengers
     * @created By : Vinod Kumar
     * @created Date : 1th Fef 2016
     * @return       : void
     */
    public void getTourOptionalAndPassengers(){
        passengerList = new List<Passenger__c>();
        tourOptionalList = new List<Tour_Optional__c>();
        secondPagePassengerList = new list<Passenger__c>();
        //Changes start, Done by Maksud Ali for story : S-428451
        for(Tour_Optional__c tOP:[Select Tour_Instance__c, Brand_Name__c, Supplier_Menu__r.Soup_Text_1__c, Supplier_Menu__r.Soup_Text_2__c,Supplier_Menu__r.Soup_Text_3__c,Supplier_Menu__r.Soup_Text_4__c, Supplier_Menu__r.Starter_Text_1__c,  Supplier_Menu__r.Starter_Text_2__c,  Supplier_Menu__r.Starter_Text_3__c,
            Supplier_Menu__r.Starter_Text_4__c,  Supplier_Menu__r.Starter_Text_5__c,Supplier_Menu__r.Starter_Text_6__c,Supplier_Menu__r.Starter_Text_7__c,Supplier_Menu__r.Starter_Text_8__c,  Supplier_Menu__r.Main_Text_1__c,   Supplier_Menu__r.Main_Text_2__c,
            Supplier_Menu__r.Main_Text_3__c,  Supplier_Menu__r.Main_Text_4__c,  Supplier_Menu__r.Main_Text_5__c,Supplier_Menu__r.Main_Text_6__c,Supplier_Menu__r.Main_Text_7__c,Supplier_Menu__r.Main_Text_8__c,  Supplier_Menu__r.Dessert_Text_1__c,
            Supplier_Menu__r.Dessert_Text_2__c,  Supplier_Menu__r.Dessert_Text_3__c,  Supplier_Menu__r.Dessert_Text_4__c,  Supplier_Menu__r.Dessert_Text_5__c,Supplier_Menu__r.Dessert_Text_6__c,Supplier_Menu__r.Dessert_Text_7__c,Supplier_Menu__r.Dessert_Text_8__c,Name,
            Supplier_Menu__r.Kids_Menu_Available__c,Supplier_Menu__r.Kids_menu_content__c,Supplier_Menu__c, Day__c 
            From Tour_Optional__c
            where ID =: tourOptionalId
            AND Duplicate__c = false]){
            tourOptional = tOP;
        }
        //end changes.
        
        isKidsMenuAvailable = tourOptional.Supplier_Menu__r.Kids_Menu_Available__c;
        tourOptionalList.add(tourOptional);
        tourInstance = tourOptional.Tour_Instance__c;
        Integer dayNum = Integer.valueOf(tourOptional.Day__c);
        String query = 'SELECT Family_Name__c,Name,PAX_Timeline__c, First_Name__c, Gender__c, Nationality__c, Passport_Issue_Date__c, Passport_Expiry_Date__c,';
        query += 'Passport_Number__c,Country_of_Issue__c, Date_of_Birth__c,Passenger_Class__c, Id FROM Passenger__c Where Status__c != \'CX\' and Tour_Instance__c =: tourInstance order by Family_Name__c';
        integer recordCount = 0;
        for(Passenger__c pass : Database.query(query)) {
            // Mar 10, 2017        Abhishek Saxena     T-568302    
            if(isV2Status && !TOPS_MealSelectionsProcessor.checkPaxPresent(pass.PAX_Timeline__c, dayNum)){
                continue;
            }
            if(recordCount < MAXRECORD){
                passengerList.add(pass);
            }else{
                secondPagePassengerList.add(pass);
            }
            recordCount++;
        }
        getBlankPassengerList();
        getCSS();
        getFontSizeBasedOnRecords(Integer.valueOf(passengerList.size()));
    }
    /**
    * @description  This method is used to calucate Total Soup menu
    * @created By : Leo Alves
    * @created Date : 24th May 2016
    * @return       : void
    */
    private void checkTotalSoups(){
        if(tourOptional.Supplier_Menu__r.Soup_Text_1__c != null){
            totalSoups++;
            isSoup1Available = true;
            theLastSoupText = tourOptional.Supplier_Menu__r.Soup_Text_1__c;
            theLastSoupCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Soup_Text_2__c != null){
            totalSoups++;
            isSoup2Available = true;
            theLastSoupText = tourOptional.Supplier_Menu__r.Soup_Text_2__c;
            theLastSoupCounter.add(1);
        }
        //Changes start, Done by Maksud Ali for story : S-428451
        if(tourOptional.Supplier_Menu__r.Soup_Text_3__c != null){
            totalSoups++;
            isSoup3Available = true;
            theLastSoupText = tourOptional.Supplier_Menu__r.Soup_Text_3__c;
            theLastSoupCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Soup_Text_4__c != null){
            totalSoups++;
            isSoup4Available = true;
            theLastSoupText = tourOptional.Supplier_Menu__r.Soup_Text_4__c;
            theLastSoupCounter.add(1);
        }
        //End changes
    }

     /**
     * @description  This method is used to calucate Total Starters menu
     * @created By : Vinod Kumar
     * @created Date : 9th Fef 2016
     * @return       : void
     */
    private void checkTotalStarters(){
        if(tourOptional.Supplier_Menu__r.Starter_Text_1__c != null){
            totalStarters++;
            isStarte1Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_1__c;
            theLastStarterCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Starter_Text_2__c != null){
            totalStarters++;
            isStarte2Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_2__c;
            theLastStarterCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Starter_Text_3__c != null){
            totalStarters++;
            isStarte3Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_3__c;
            theLastStarterCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Starter_Text_4__c != null){
            totalStarters++;
            isStarte4Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_4__c;
            theLastStarterCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Starter_Text_5__c != null){
            totalStarters++;
            isStarte5Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_5__c;
            theLastStarterCounter.add(1);
        }
        //Changes start, Done by Maksud Ali for story : S-428451
        if(tourOptional.Supplier_Menu__r.Starter_Text_6__c != null){
            totalStarters++;
            isStarte6Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_6__c;
            theLastStarterCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Starter_Text_7__c != null){
            totalStarters++;
            isStarte7Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_7__c;
            theLastStarterCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Starter_Text_8__c != null){
            totalStarters++;
            isStarte8Available = true;
            theLastStarterText = tourOptional.Supplier_Menu__r.Starter_Text_8__c;
            theLastStarterCounter.add(1);
        }
        //End changes
    }
     /**
     * @description  This method is used to calucate Total Main Course menu
     * @created By : Vinod Kumar
     * @created Date : 9th Fef 2016
     * @return       : void
     */
    private void checkTotalMainCourse(){
        if(tourOptional.Supplier_Menu__r.Main_Text_1__c != null){
            totalmainCourse++;
            isMainCourse1Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_1__c;
            theLastMainCourseCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Main_Text_2__c != null){
            totalmainCourse++;
            isMainCourse2Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_2__c;
            theLastMainCourseCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Main_Text_3__c != null){
            totalmainCourse++;
            isMainCourse3Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_3__c;
            theLastMainCourseCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Main_Text_4__c != null){
            totalmainCourse++;
            isMainCourse4Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_4__c;
            theLastMainCourseCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Main_Text_5__c != null){
            totalmainCourse++;
            isMainCourse5Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_5__c;
            theLastMainCourseCounter.add(1);
        }
        //Changes start, Done by Maksud Ali for story : S-428451
        if(tourOptional.Supplier_Menu__r.Main_Text_6__c != null){
            totalmainCourse++;
            isMainCourse6Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_6__c;
            theLastMainCourseCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Main_Text_7__c != null){
            totalmainCourse++;
            isMainCourse7Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_7__c;
            theLastMainCourseCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Main_Text_8__c != null){
            totalmainCourse++;
            isMainCourse8Available = true;
            theLastMainCourseText = tourOptional.Supplier_Menu__r.Main_Text_8__c;
            theLastMainCourseCounter.add(1);
        }
        //End changes
    }
    /**
     * @description  This method is used to calucate Total Desserts menu
     * @created By : Vinod Kumar
     * @created Date : 9th Fef 2016
     * @return       : void
     */
    private void checkTotalDesserts(){
        if(tourOptional.Supplier_Menu__r.Dessert_Text_1__c != null){
            totalDesserts++;
            isDesserts1Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_1__c;
            theLastDessertCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Dessert_Text_2__c != null){
            totalDesserts++;
            isDesserts2Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_2__c;
            theLastDessertCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Dessert_Text_3__c != null){
            totalDesserts++;
            isDesserts3Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_3__c;
            theLastDessertCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Dessert_Text_4__c != null){
            totalDesserts++;
            isDesserts4Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_4__c;
            theLastDessertCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Dessert_Text_5__c != null){
            totalDesserts++;
            isDesserts5Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_5__c;
            theLastDessertCounter.add(1);
        }
        //Changes start, Done by Maksud Ali for story : S-428451
        if(tourOptional.Supplier_Menu__r.Dessert_Text_6__c != null){
            totalDesserts++;
            isDesserts6Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_6__c;
            theLastDessertCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Dessert_Text_7__c != null){
            totalDesserts++;
            isDesserts7Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_7__c;
            theLastDessertCounter.add(1);
        }
        if(tourOptional.Supplier_Menu__r.Dessert_Text_8__c != null){
            totalDesserts++;
            isDesserts8Available = true;
            theLastDessertText = tourOptional.Supplier_Menu__r.Dessert_Text_8__c;
            theLastDessertCounter.add(1);
        }
        //End changes
    }
     /**
     * @description  This method is used to get blank passenger list
     * @created By : Vinod Kumar
     * @created Date : 1th Fef 2016
     * @return       : void
     */
    private void getBlankPassengerList() {
       blankPassanger = new List<Passenger__c >();
       secondPageBlankPassanger = new List<Passenger__c >();
       if(passengerList.size() < MAXRECORD) {
          blankPassanger =  new List<Passenger__c>();
          for(integer i = passengerList.size(); i<= MAXRECORD; i++) {
            blankPassanger.add(new Passenger__c (Name='test'));
          }
        }
        if(secondPagePassengerList.size() < MAXRECORD) {
          blankPassanger =  new List<Passenger__c>();
          for(integer i = secondPagePassengerList.size(); i<= MAXRECORD; i++) {
            secondPageBlankPassanger.add(new Passenger__c (Name='test'));
          }
        }
    }

     /**
     * @description  This method is used to get blank passenger list
     * @created By : Vinod Kumar
     * @created Date : 1th Fef 2016
     * @return       : void
     */
    private void getCSS() {
        if(passengerList.size() > 0 && blankPassanger.size() > 0) {
          if(Math.mod(passengerList.size(), 2) == 0) {
            passangerCSS = 'pRowOdd,pRowEven';
            blankPassangerCSS = 'pRowOdd,pRowEven';
          }
          else{
            passangerCSS = 'pRowOdd,pRowEven';

            blankPassangerCSS = 'pRowEven,pRowOdd';
          }
        }

    }

    /**
     * @description  This method is used to get font size of passengers pdf
     * @created By : Vinod Kumar
     * @created Date : 1th Fef 2016
     * @return       : void
     */
    private void getFontSizeBasedOnRecords(Integer listSize) {
        if(listSize <= 40 && listSize >= 0) {
            fontSize = '14px';
        }else if(listSize <= 45 && listSize > 40) {
            fontSize = '13px';
        }else if(listSize <= 50 && listSize > 45) {
            fontSize = '12px';
        }else if(listSize <= 55 && listSize > 50) {
            fontSize = '11px';
        }else if(listSize <= 60 && listSize > 55) {
            fontSize = '10px';
        }else{
           fontSize = '9px';
        }
         fontSize = '12px';
    }

    /**
     * @description  This method is used to get colour code of passengers pdf
     * @created By : Vinod Kumar
     * @created Date : 1th Fef 2016
     * @return       : void
     */
     //Changes Start,Done by Maksud Ali for Story : S-455965
    public void getColourCode() {
        String productCode = '';
        footerlogoList = new List<StaticImageManager>();

        for(Tour_Instance__c  tour : [SELECT id,Name, Product_Name__c,Special_Brand__c, Operating_Product_Code__c,Travel_Director__c,Instance_Code__c
                                      FROM Tour_Instance__c
                                      WHERE id=: tourInstance]) {
          productCode = tour.Operating_Product_Code__c;
          tourRecord = tour;
        }
        if(productCode != '' && productCode.length() >= 2) {
          regionCode = productCode.subString(0,2);
        }
        for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, Brand__c, Colour__c,Logos__c
                                                     FROM Region_Code_Brand_Mapping__mdt
                                                     WHERE DeveloperName =: regionCode]) {
          colourCodeVal= mapRec.Colour__c;
          if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
            List<String> tmpSplitedLogoName = mapRec.Logos__c.split(',');
            for(String logoName : tmpSplitedLogoName) {
                footerlogoList.add(new StaticImageManager(logoName,tourRecord.Special_Brand__c));
            }
          }else {
            footerlogoList.add(new StaticImageManager(mapRec.Logos__c,tourRecord.Special_Brand__c));
          }
        }
        //End code.
    }

    /**
     * @description  This method is used to get language of passengers pdf
     * @created By : Vinod Kumar
     * @created Date : 1th Fef 2016
     * @return       : void
     */
    private void getlanguage() {
      languageParam = '';
      if(regionCode == 'VB' || regionCode == 'VE' ) {
        languageParam = 'fr';
      }
    }

}