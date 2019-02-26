/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
  /*  public PageReference forwardToStartPage() {        
       return Network.communitiesLanding();        
    }  */
    
    public CommunitiesLandingController() {       
    }
    
    
    //Added by Shruti for MTSII-602
    
     public PageReference forwardToStartPage() {
         // Query the profile ids
         List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
          String MyProflieName = PROFILE[0].Name;
        
       //  Return the appropriate landing page
         if(MyProflieName  == 'MTS Guest User') {
            return new PageReference('/apex/TTCHomePage');
        } else {
           return Network.communitiesLanding();
        }          
    } 
}