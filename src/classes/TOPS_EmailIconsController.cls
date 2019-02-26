//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_EmailIconsController
// Description: to get email icon from custom meta data according to brand
//
// 2nd Feb 2016   kamal sharma  Original (Task # T-466992)
// 05th June 2018   Ravi Jain   Modified (Story# S-485984)
//
public without sharing class TOPS_EmailIconsController {
    public List<Social_Media_Sharing__mdt> socialList {get; set;}
    public String brand {get; set;}
    
     // Code changes done by Ravi Jain for story S-485984
    // Start - Ravi Jain - S-485984 - June 06,2018 - define the setter and getter
    public List<Social_Media_Sharing__mdt> tdSocialMediaList {get; set;}
    public List<TDSocialMediaIcon> TDSocialIcon {get; set;}
    public String tdID {get; set;}
    public String emailTemplate {get; set;}
    public Boolean emailFlag {get; set;}
    // End - Ravi Jain - S-485984 - June 06,2018
    
    public TOPS_EmailIconsController(){
        brand = ApexPages.currentPage().getParameters().get('Brand');
        
        // Code commented and changes done by Ravi Jain for story S-485984
        /*if (brand != null){
             socialList = new List<Social_Media_Sharing__mdt>();
            socialList =  [SELECT Brand__c,Social_Media_del__c,Icon_URL__c,Share_Link__c FROM Social_Media_Sharing__mdt WHERE Brand__c =: Brand];
        }*/
        // Start - Ravi Jain - S-485984 - June 05,2018 - Show the TD social media Icon if tourDirectorAccount.Facebook__c != null || tourDirectorAccount.Twitter__c != null || tourDirectorAccount.Instagram__c != null
        // else show the brand social media icon
        tdID = ApexPages.currentPage().getParameters().get('TourDirectorId');
        emailTemplate =  ApexPages.currentPage().getParameters().get('emailTemplate');
        socialList = new List<Social_Media_Sharing__mdt>(); 
        if(tdID != null && emailTemplate != null)
        {
        tdSocialMediaList = new List<Social_Media_Sharing__mdt>();    
        String iconUrl = ''; 
        String shareLink = ''; 
        Account tourDirectorAccount = [Select Id,Facebook__c,Twitter__c,Instagram__c from Account where id = :tdID limit 1];
        TDSocialIcon = new List<TDSocialMediaIcon>();
            
        tdSocialMediaList =  [SELECT MasterLabel, Icon_URL__c,Share_Link__c FROM Social_Media_Sharing__mdt where MasterLabel IN ('TD Facebook Icon', 'TD Twitter Icon', 'TD Instagram Icon')];    
        if (tourDirectorAccount != null && (tourDirectorAccount.Facebook__c != null || tourDirectorAccount.Twitter__c != null || tourDirectorAccount.Instagram__c != null)) {
            if(tdSocialMediaList.size() >0)  
            {
            for(Social_Media_Sharing__mdt socialIcon: tdSocialMediaList)
            {
            if (tourDirectorAccount.Facebook__c != null && socialIcon.MasterLabel.equalsIgnoreCase('TD Facebook Icon')) {
                  iconUrl = socialIcon.Icon_URL__c; 
                  shareLink = socialIcon.Share_Link__c;
                  TDSocialIcon.add(new TDSocialMediaIcon(shareLink+tourDirectorAccount.Facebook__c,iconUrl));
                  }
                 if (tourDirectorAccount.Twitter__c != null && socialIcon.MasterLabel.equalsIgnoreCase('TD Twitter Icon')) {
                    iconUrl = socialIcon.Icon_URL__c; 
                    shareLink = socialIcon.Share_Link__c;
                    TDSocialIcon.add(new TDSocialMediaIcon(shareLink+tourDirectorAccount.Twitter__c,iconUrl));
                   }
                if (tourDirectorAccount.Instagram__c != null && socialIcon.MasterLabel.equalsIgnoreCase('TD Instagram Icon')) {
                     iconUrl = socialIcon.Icon_URL__c; 
                     shareLink = socialIcon.Share_Link__c;
                     TDSocialIcon.add(new TDSocialMediaIcon(shareLink+tourDirectorAccount.Instagram__c,iconUrl));
                   }
              if(emailTemplate.equalsIgnoreCase('Farewell Email') || emailTemplate.equalsIgnoreCase('Farewell Email - Opt Out'))
              { 
                  emailFlag = true;
                socialList = [SELECT Brand__c,Social_Media_del__c,Icon_URL__c,Share_Link__c FROM Social_Media_Sharing__mdt WHERE Brand__c =: Brand AND MasterLabel NOT IN ('TD Facebook Icon', 'TD Twitter Icon', 'TD Instagram Icon')];
              }
            }
         }
        }
         else if (brand != null){
            socialList = [SELECT Brand__c,Social_Media_del__c,Icon_URL__c,Share_Link__c FROM Social_Media_Sharing__mdt WHERE Brand__c =: Brand AND MasterLabel NOT IN ('TD Facebook Icon', 'TD Twitter Icon', 'TD Instagram Icon')];
        }       
     }
        else 
     {
            if (brand != null){
             socialList = [SELECT Brand__c,Social_Media_del__c,Icon_URL__c,Share_Link__c FROM Social_Media_Sharing__mdt WHERE Brand__c =: Brand AND MasterLabel NOT IN ('TD Facebook Icon', 'TD Twitter Icon', 'TD Instagram Icon')];
        }
            }
    }
    
    public class TDSocialMediaIcon {
        public String shareLink {get; set;} 
        public String iconUrl {get; set;} 
        
        public TDSocialMediaIcon(String shareLink, String iconUrl) {
            this.shareLink = shareLink;
            this.iconUrl = iconUrl;
        }
    } 
    // End - Ravi Jain - S-485984 - June 05,2018
    
}