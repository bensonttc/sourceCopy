//Modified by Sajal for C-00226000 : Replaced 'Decimal' with 'String' for roomNumber
global class TOPS_WrapperUtility{

    public class paxWrapper{
        public Passenger__c pax;
        //START- Modified by Sajal for C-00226000 
        //public Decimal roomNumber;
        public String roomNumber;
        //END for C-00226000 
        public String roomType;
        //START- Modified by Sajal for C-00226000
        //public paxWrapper(Passenger__c pax, Decimal roomNumber, String roomType){
        public paxWrapper(Passenger__c pax, String roomNumber, String roomType){
        //END for C-00226000 
            this.pax = pax;
            this.roomNumber = roomNumber;
            this.roomType = roomType;
        }
        
        //START- Modified by Sajal for C-00226000
        //public paxWrapper(Passenger__c pax, Decimal roomNumber){
        public paxWrapper(Passenger__c pax, String roomNumber){
        //END for C-00226000 
            this.pax = pax;
            this.roomNumber = roomNumber;
            this.roomType = '';
        }
        public paxWrapper(){
            this.pax = new Passenger__c();
            //START- Modified by Sajal for C-00226000
            //this.roomNumber = -1;
            this.roomNumber = '-1';
            //END for C-00226000 
            this.roomType = '';
        }
    }

    /*public static String sortBy;
    global class paxWrapper implements Comparable{
        public Passenger__c pax;
        //Constructor
        public paxWrapper(Passenger__c pax){
            this.pax = pax;
        }
        global Integer compareTo(Object compareTo) {
            paxWrapper compareToPax = (paxWrapper)compareTo;
                String thisBagNum = (this.pax.Bag_Number__c == null || String.isEmpty(this.pax.Bag_Number__c) ? '' : this.pax.Bag_Number__c);
                String compareToBagNum = (compareToPax == null || compareToPax.pax == null || 
                                          String.isEmpty(compareToPax.pax.Bag_Number__c) ? '' : compareToPax.pax.Bag_Number__c);
                return thisBagNum.compareTo(compareToBagNum);
        }
    }*/
    
    public class TIIData{
        public List<Modules> modules;
    }
    public class Modules {
        public String name;
    }
    public static TIIData parseTIIData(String json){
        return (TIIData) System.JSON.deserialize(json, TIIData.class);
    }
    
    public class PAXTimeline{
        public List<Days> days;
    }
    public class Days {
        public Integer day;
        public String RoomingList_ID;
        public Boolean PAX_On_Tour;
        public Integer Actual_Room_ID;
        public String Actual_Room_Type;
        public String Temp_Change_of_Class;
        public String In_Change_Class_Mode;
    }

    public static PAXTimeline parsePAXTimeline(String json) {
        return (PAXTimeline) System.JSON.deserialize(json, PAXTimeline.class);
    }
}