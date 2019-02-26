/**
 *  Generic Controller for all the TQ Applications
 */
public without sharing class TQAppController {

    public String region {get; set;}
    public String locale {get; set;}
    public Id sellingCompanyId {get; set;}
    public Id ttcCompanyId {get; set;}
    public String privacyPolicyLink {get; set;}
    public String sitePrefix {get; set;}
    public String siteUrl {get; set;}
    public Boolean isFirstLogin {get; set;}
    
    public final static String defaultBrand = 'TT';
    public final String appSettingsName = 'mtsApp';

    /**
     *  Default Controller
     */
    public TQAppController() {}
    
    
    public static String getBrandByPageName(String pageName){
        String brand = defaultBrand;
        Brand_Settings__c[] brandList = Brand_Settings__c.getAll().values();
        for (Brand_Settings__c brandSettings : brandList){
            if (pageName.containsIgnoreCase('_'+brandSettings.Name)){
                return brandSettings.Name.toUpperCase();
            }
        }
        return brand;
    }

    /**
     *  Login redirect: if the user is null or guest, go to the login page
     */
    public PageReference loginRedirect() {
        String MTS = 'MTS';
        String currentURL = Site.getBaseSecureUrl() + ApexPages.currentPage().getUrl();
        String pathPrefix = Site.getPathPrefix();
        String communityURL = currentURL.substringBefore(pathPrefix);
        String pageName = currentURL.substringAfter(pathPrefix);
        String brand = TQAppController.getBrandByPageName(pageName);
        String sellingCompanyStr = ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().get('sc') != null
            ? ((String) ApexPages.currentPage().getParameters().get('sc')).toUpperCase()
            : '';
                
        specifySiteSettings(brand);

        // If the user is a Guest user, he needs to login via SSO
        if(UserInfo.getUserType() == 'Guest') {
            if(!isPublicURL(ApexPages.currentPage().getUrl())) {
                // Redirect to the login
                return new PageReference(Auth.AuthConfiguration.getAuthProviderSsoUrl(communityURL, 
                    pathPrefix + '/' + MTS + '_' + sellingCompanyStr, 'TTC_Connect_' + brand));
            } else {
                System.debug('Public page via Guest');
                return null;
            }
        }
        // Grant access to the VF page if logged in
        else {
            Id runningUserId = UserInfo.getUserId();
            User runningUser = [SELECT ContactId FROM User WHERE Id = :runningUserId];
            if(runningUser != null) {
                // Check, according to the brand, if 
                Id personContactId = runningUser.ContactId;
                System.debug('PersonContactId is ' + personContactId);
                
                // ttcCompanyId
                List<Account> ttcGlobal = [Select Id From Account Where Name = 'The Travel Corporation (Global)'];
                if(ttcGlobal.size() > 0){
                    ttcCompanyId = ttcGlobal.get(0).Id;
                }

                String sellingCompanyField = brand + '_Selling_Company__c';
                String sellingCompanyRelation = brand + '_Selling_Company__r';
                String sellingCompanyQuery = 'SELECT Id,' + sellingCompanyField + ', ' +
                     sellingCompanyRelation + '.Region__c, ' +  sellingCompanyRelation + '.Locale__c, ' +
                     sellingCompanyRelation + '.Privacy_Policy_Link__c ' +
                     ' from Account WHERE PersonContactId = :personContactId LIMIT 1';
                List<Account> personAccounts = Database.query(sellingCompanyQuery);

                if(personAccounts != null && personAccounts.size() > 0) {
                    Account personAccount = personAccounts.get(0);

                    if(personAccount.get(sellingCompanyField) != null) {
                        try {
                            isFirstLogin = False;
                            sellingCompanyId = (String)personAccount.get(sellingCompanyField);
                            Account sellingCompanyAccount = (Account)(personAccount.getSObject(sellingCompanyRelation));
                            
                            if (sellingCompanyAccount != null) {
                              region = sellingCompanyAccount.Region__c;
                              locale = sellingCompanyAccount.Locale__c;
                              privacyPolicyLink = sellingCompanyAccount.Privacy_Policy_Link__c;
                            }
                        } finally{
                            return null;  
                        }
                        return null;  
                    } else {
                        System.debug('Person Account NOT populated yet');
                        if (sellingCompanyStr == '' || sellingCompanyStr == null){
                            return null;
                        }
                        List<Account> sellingCompanies = [SELECT Id, Region__c, Locale__c, Privacy_Policy_Link__c FROM Account WHERE Selling_Company_Short_Name__c = :sellingCompanyStr];
                        System.debug('Selling: ' + sellingCompanies);
                        if(sellingCompanies != null && sellingCompanies.size() > 0) {
                            Account sellingCompany = sellingCompanies.get(0);
                            region = sellingCompany.Region__c != null && sellingCompany.Region__c.length() > 0 ? sellingCompany.Region__c : 'uk';
                            locale = sellingCompany.Locale__c != null && sellingCompany.Locale__c.length() > 0 ? sellingCompany.Locale__c : 'en-gb';
                            sellingCompanyId = sellingCompany.Id;
                            privacyPolicyLink = sellingCompany.Privacy_Policy_Link__c;
                            isFirstLogin = True;
                            personAccount.put(sellingCompanyField, sellingCompany.Id);
                            update personAccount;
                        } else {
                            System.debug('Selling Company \'' + sellingCompanyStr + '\' not found!');
                        }
                        return null;    
                    }
                } else {
                    System.debug('Person Account not found');
                    return null;
                }
            } else {
                System.debug('Logged User not found');
                return null;
            }

            return null;
        }
    }
    
        
    private void specifySiteSettings(String brand){
        sitePrefix = Site.getPathPrefix();
        if (Site.getBaseCustomUrl() != null && Site.getBaseCustomUrl() != ''){
            siteUrl = Site.getBaseCustomUrl();
        } else {
            siteUrl = Site.getBaseUrl();
        }
        
        Brand_Settings__c brandSettings = Brand_Settings__c.getInstance(brand);
        if (brandSettings != null){
            if (brandSettings.Custom_Site_Prefix__c != null && brandSettings.Custom_Site_Prefix__c != ''){
                sitePrefix = brandSettings.Custom_Site_Prefix__c;
            } else if (brandSettings.Should_Not_Use_Site_Prefix__c == true){
                sitePrefix = '';
            }
            
            if (brandSettings.Custom_Site_Url__c != null && brandSettings.Custom_Site_Url__c != ''){
                siteUrl = brandSettings.Custom_Site_Url__c;
            }
        }
    }
    

    /**
     *  Logout redirect: redirect the user to the appropriate branded website
     */
    public PageReference logoutRedirect() {
        //Get the brand from the URL
        App_Settings__c appSettings = App_Settings__c.getValues(appSettingsName);
        String redirectToUrl = null, brand = null;
        if (appSettings != null){
            try {
                brand = ApexPages.currentPage().getParameters().get('b');
                if (brand != null && brand != ''){
                    String fieldName = brand.toUpperCase() + '_Logout_URL__c';
                    redirectToUrl = (String)(appSettings.get(fieldName));
                }
            } catch(Exception e) {
                System.debug('Exception in reading the Brand code, assuming TT' + e.getMessage());
            }
            
            if (redirectToUrl == null) {
                String fieldName = defaultBrand.toUpperCase() + '_Logout_URL__c';
                redirectToUrl = (String)(appSettings.get(fieldName));
            }
        }
        
        //Query the custom setting to get the right URL
        if (redirectToUrl != null){
            return new PageReference(redirectToUrl);    
        } else {
            return null;
        }

    }
    
    /**
     *  Method used in the VF page to retrieve the current network ID
     */
    public Id getNetworkId() {
        return Network.getNetworkId();
    }

    /**
     *  Get the URL for the SSO library, 
     *  fetching the value defined in the custom setting
     */
    public String getSSOLibraryURL() {
        App_Settings__c settings = App_Settings__c.getValues('mtsApp');
        return settings != null ? settings.SSO_JS_Library_URL__c : null;
    }

    /**
     *  Given a URL, return if it is publicly accessible or not
     */
    public static Boolean isPublicURL(PageReference pageReference) {
        return pageReference != null && isPublicURL(pageReference.getUrl());
    }

    /**
     *  Given a URL, return if it is publicly accessible or not
     */
    public static Boolean isPublicURL(String url) {
        return url != null && (
            url.containsIgnoreCase('TQAttachment') ||
            url.containsIgnoreCase('TQLogout') ||
            url.containsIgnoreCase('servlet.FileDownload') || 
            url.containsIgnoreCase('login') ||
            url.containsIgnoreCase('/_ui/networks/management') ||
            url.containsIgnoreCase('/_nc_external/identity/sso/') ||
            url.containsIgnoreCase('/_ui/identity/oauth') ||
            url.containsIgnoreCase('/_ui/system') ||
            url.containsIgnoreCase('TQShare') ||
            url.containsIgnoreCase('profilephoto')
            //url.containsIgnoreCase('/_ui/')
            //TODO Check if 'url.containsIgnoreCase('/_ui/')' could be added
        );
    }

}