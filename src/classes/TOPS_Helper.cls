//
// (c) 2016 Appirio, Inc.
//
// Helper class for TOPS code
//
public with sharing class TOPS_Helper
{
    // set the From Address of the email to be sent to send grid - this was previously done using the email processors, but due to a change in Google's DMARC policy, gmail cannot be used anymore
    public static void setFromAddresses(List<TOPS_EmailWrapper> emailWrappersToProcess)
    {
        TourInstanceDataWrapper tourInstanceWrapper = new TourInstanceDataWrapper(emailWrappersToProcess);
        for (TOPS_EmailWrapper emailWrapper : emailWrappersToProcess)
        {
            setFromAddress(emailWrapper, tourInstanceWrapper);
        }
    }
    // set from address on individual wrapper
    private static void setFromAddress(TOPS_EmailWrapper emailWrapper, TourInstanceDataWrapper tourInstanceWrapper)
    {
        Account tdAccount = tourInstanceWrapper.tdMap.get(emailWrapper.tdId);
        Passenger__c tdPassenger = tdAccount.Passengers__r.size() == 1 ? tdAccount.Passengers__r[0] : null;
        Region_Code_Brand_Mapping__mdt mapRec = tourInstanceWrapper.regionMap.get(emailWrapper.regionCode);
        // use either Preferred_Name__c from the passenger record or last name of the account record
        String firstNameToUse = tdPassenger != null && tdPassenger.Preferred_Name__c != null ? tdPassenger.Preferred_Name__c : tdAccount.FirstName;
        
        String regex = '[^a-zA-Z ]';
        String firstNameStripped = firstNameToUse.replace(regex, '');
        String lastNameStripped = tdAccount.LastName.replace(regex, '');
        //Code changes done by Ravi Jain for Case - 00176858
        //Code Changes start here
        //Code to replace all the spaces with blank
        //Code Modified by Aditya Tiwari for case#00196300 05/15/2017 Start
        //Code to replace all the spaces with blank
        firstNameStripped = firstNameToUse.replaceAll( '\\s+', '');
        //Code Modified by Aditya Tiwari for case#00196300 05/15/2017 End
        lastNameStripped = tdAccount.LastName.replaceAll( '\\s+', '');
        //Code Changes end here
   
        emailWrapper.fromEmail = mapRec.Abbreviated_Role__c + '.' +  firstNameStripped + '.' + lastNameStripped + '@' + mapRec.Domain__c;
    }

    // wrapper class that contains two relevant pieces of setting the correct data
    class TourInstanceDataWrapper
    {
        private Set<String> regionCodes;

        protected Map<Id, Account> tdMap;
        protected Map<String, Region_Code_Brand_Mapping__mdt> regionMap;

        public TourInstanceDataWrapper(List<TOPS_EmailWrapper> emailWrappersToProcess)
        {
            this.regionCodes = new Set<String>();
            Set<Id> tdIds = new Set<Id>();
            for (TOPS_EmailWrapper emailWrapper : emailWrappersToProcess)
            {   
                regionCodes.add(emailWrapper.regionCode);
                tdIds.add(emailWrapper.tdId);
            }
            initTdMap(tdIds);
            initRegionMap();
        }

        // initastes td map by querying relevant fields
        private void initTdMap(Set<Id> tdIds)
        {   
            //Code Modified by Aditya Tiwari for case#00196300 05/15/2017 Start
            // Modified Asc to DESC to use the most recent preferred name rather than the oldest
            this.tdMap = new Map<Id, Account>([SELECT FirstName, LastName,
                                              (SELECT Preferred_Name__c FROM Passengers__r WHERE Preferred_Name__c != null order by LastModifiedDate DESC Limit 1)
                                              FROM Account WHERE ID IN: tdIds]);
            //Code Modified by Aditya Tiwari for case#00196300 05/15/2017 End                                      
        }

        // query region mappings and put them in a map that contains the codes of the email wrappers
        private void initRegionMap()
        {
            regionMap = new Map<String, Region_Code_Brand_Mapping__mdt>();
            for (Region_Code_Brand_Mapping__mdt rec : [SELECT DeveloperName, Abbreviated_Role__c, Domain__c FROM Region_Code_Brand_Mapping__mdt WHERE DeveloperName IN: regionCodes])
            {
                regionMap.put(rec.DeveloperName, rec);
            }
        }

    }
}