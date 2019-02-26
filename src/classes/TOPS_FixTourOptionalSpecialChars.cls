global class TOPS_FixTourOptionalSpecialChars implements Schedulable{

    
  global void execute (SchedulableContext sc)
  {
     fixTheOptionals();
  }       
 
  public void fixTheOptionals() {
  
   List<tour_optional__c> todsToUpdate = new List<tour_optional__c>();

    for(tour_optional__c to: [SELECT id, Description__c FROM tour_optional__c where tour_optional_date__C > 2018-02-01 and (name ='Gossip Girl Sites Tour' or name ='Souvenirs & Apparel' or name ='Trip T-shirts' or name='Jungfrau Mountain & Adventure Park' or name = 'Snowmobiles Single Rider' or name = 'Big Apple Helicopter Ride' or name = 'New York Helicopter Ride' or name = 'Lake Cruise') LIMIT 9000]){
        if(to.Description__c != null){
            if(to.Description__c.contains('\u2028') || to.Description__c.contains('\u2026') || to.Description__c.contains('\u003F')){
                to.Description__c = to.Description__c.replaceAll('\u2028', '\n');
                to.Description__c = to.Description__c.replaceAll('\u2026', '...');
                to.Description__c = to.Description__c.replaceAll('\\'+ '?', '.');
                todsToUpdate.add(to);
            }
        }
    }
    if(todsToUpdate.size()>0){
        update todsToUpdate;
    }
    }
}