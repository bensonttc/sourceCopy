/**
 *  URL Rewriter
 */
global class TQAppUrlRewriter implements Site.UrlRewriter {
    
    
 //Maps a user-friendly URL to a Salesforce URL
   
  global PageReference mapRequestUrl(PageReference friendlyUrl) {
    System.debug('TQAppUrlRewriter.mapRequestUrl: ' + friendlyUrl);
     
    if(TQAppController.isPublicURL(friendlyUrl)) {
      return null;
        
    } else {

      String url = friendlyUrl != null ? friendlyUrl.getUrl() : null;
      String brandID ='';
      String MTS = 'MTS_';
      Boolean topsUser = TRUE;
      //Added by Shruti for MTSII-602
      String CUSTOMER_PROFILE_NAME = 'MTS Guest User' ;      
      Id profileId=userinfo.getProfileId();
      String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);  
        
      // Get the relevant brand and determine if the user is a TOPS or MTS user.
        
    if (url.containsIgnoreCase('MTS_IV')){
        brandID = 'IV';
        topsUser = FALSE; 
            System.debug('Insight User');
    }
    else if (url.containsIgnoreCase('MTS_TT')){
        brandID = 'TT';
        topsUser = FALSE; 
            System.debug('Trafalgar User');
    }
    else if (url.containsIgnoreCase('MTS_CH')){
        brandID = 'CH';
        topsUser = FALSE; 
            System.debug('Contiki User');
    }
    else if (url.containsIgnoreCase('MTS_UU')){
        brandID = 'UU';
        topsUser = FALSE; 
            System.debug('U by Uniworld User');
    }
    else if (url.containsIgnoreCase('MTS_UN')){
        brandID = 'UN';
        topsUser = FALSE; 
            System.debug('Uniworld User');
    }
    else if (url.containsIgnoreCase('MTS_AA')){
        brandID = 'AA';
        topsUser = FALSE; 
            System.debug('AAT Kings User');
    }
    else if (url.containsIgnoreCase('MTS_GE')){
        brandID = 'GE';
        topsUser = FALSE; 
            System.debug('Grand European Travel User');
    } 
    
      
// If the user is NOT a topUser, get the selling company, and inject it as a GET parameter

        if (topsUser == FALSE) {
        
          String sellingCompany = '';
          String region = url.toLowerCase().substringAfter(MTS.toLowerCase());
          
          if(region != null && region.length() > 0) {
              sellingCompany = '?sc=' + region;
          }
          
          return new PageReference('/apex/ACNONE_mts_' + brandID + sellingCompany);
          
        } else {
         //Added by Shruti for MTSII-602
          System.debug('Go to TOPS IF PROFILE IS MTS');
          if (profileName == CUSTOMER_PROFILE_NAME) {         
         return new PageReference('/apexpage/TTCHomePage');
        } else {
        
          System.debug('Go to TOPS');
          return new PageReference('https://travcorp.force.com/TTC/');
        } 
        
        }
    }
  }
  

//Maps a list of Salesforce URLs to a list of user-friendly URLs.
  
  global PageReference[] generateUrlFor(PageReference[] yourSalesforceUrls) {
    System.debug('TQAppUrlRewriter.generateUrlFor: ' + yourSalesforceUrls);
    List<PageReference> pageReferenceFormatted = new List<PageReference>();

    for(integer i = 0; i < yourSalesforceUrls.size(); i++) {
      PageReference pageReference = yourSalesforceUrls[i];

      if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_tt')) {
        pageReferenceFormatted.add(new PageReference('/MTS_TT'));
      } else if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_IV')) {
        pageReferenceFormatted.add(new PageReference('/MTS_IV'));
      } else if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_CH')) {
        pageReferenceFormatted.add(new PageReference('/MTS_CH'));
      } else if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_UU')) {
        pageReferenceFormatted.add(new PageReference('/MTS_UU'));
      } else if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_UN')) {
        pageReferenceFormatted.add(new PageReference('/MTS_UN'));
      } else if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_AA')) {
        pageReferenceFormatted.add(new PageReference('/MTS_AA'));
      } else if(pageReference.getUrl().containsIgnoreCase('ACNONE_mts_GE')) {
        pageReferenceFormatted.add(new PageReference('/MTS_GE'));
      } 
    }
    return pageReferenceFormatted;
  }
}