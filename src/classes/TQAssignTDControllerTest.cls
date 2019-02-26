/**
 *  Test Class for the TD Assignment functionality 
 *  required by the myTrafalgar app
 */
@isTest
private class TQAssignTDControllerTest {
    

    @isTest(SeeAllData=true) 
    static void testAssign() {
        // User needs to be fetched from real data - otherwise the filter on the 
        // Tour Instance creation keeps firing an error
        List<User> tds = [SELECT firstName, lastname, Name 
            FROM User Where isActive=true AND Is_Travel_Director__c = true LIMIT 1];
        System.assert(tds != null && tds.size() > 0);

        if(tds != null && tds.size() > 0) {
            User td = tds.get(0);

            String name = td.Name;
            String operatingProductCode = 'TYCGG435B01SSS', departureCode = '04G15aXXX';
            String startDateStr = '04/07/2015', endDateStr = '25/07/2015';
            Date startDate = Date.newInstance(2015, 7, 4);
            Date endDate = Date.newInstance(2015, 7, 25);

            String[] data = new String[3];
            data[0] = 'Operating Product Code,Departure Code,Start Date,End Date,TD Name';
            data[1] = +operatingProductCode+','+departureCode+','+startDateStr+','+endDateStr+','+name;

            TQAssignTDController ctrl = new TQAssignTDController();
            ctrl.saveTDAssignments(data);

            // Check if the Tour Instance is there
            List<Tour_Instance__c> tourInstances = [SELECT Id
                FROM Tour_Instance__c WHERE Operating_Product_Code__c = :operatingProductCode 
                AND Departure_Code__c = :departureCode AND Start_Date__c = :startDate AND End_Date__c = :endDate
                AND Travel_Director__r.Name = :name];
            System.assertEquals(tourInstances.size(), 1);
        }

    }
    
}