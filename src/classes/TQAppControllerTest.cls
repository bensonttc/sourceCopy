/**
 *  Test the generic controller
 */
@isTest
private class TQAppControllerTest {
	
	static testMethod void testLoginRedirect() {
		Brand_Settings__c customBrandSettings = new Brand_Settings__c();
		customBrandSettings.Name = 'TT';
		customBrandSettings.Custom_Site_Url__c = 'http://google.com';
		customBrandSettings.Should_Not_Use_Site_Prefix__c = true;
		upsert customBrandSettings;
		
		App_Settings__c appSettings = new App_Settings__c(
			Name = 'mtsApp',
			ClientApp_Id__c = 'mtsApp',
			SSO_JS_Library_URL__c = 'test.js'
		);
		upsert appSettings;
		
		TQAppController appCtrl = new TQAppController();
		appCtrl.loginRedirect();
		System.assertEquals('http://google.com', appCtrl.siteUrl);
		System.assertEquals(null, appCtrl.getNetworkId());
		System.assertEquals('test.js', appCtrl.getSSOLibraryURL());
	}
	
	
	static testMethod void testLogoutFunctionality(){
		App_Settings__c appSettings = new App_Settings__c(
			Name = 'mtsApp',
			ClientApp_Id__c = 'mtsApp',
			TT_Logout_URL__c = 'http://uat.trafalgar.com'
		);
		upsert appSettings;
		
		Test.startTest();
		TQAppController appCtrl = new TQAppController();
		PageReference logoutRedirectPage = appCtrl.logoutRedirect();	
		Test.stopTest();
		
		System.assertEquals('http://uat.trafalgar.com', logoutRedirectPage.getUrl());
	}
	
	static testMethod void testUrlPublicity(){
		PageReference pageReferenceToTest = Page.TQLogout;
		String urlToTest = 'http://cs17.salesforce.com/234f23d23d23/profilephoto';
		
		System.assert(TQAppController.isPublicURL(pageReferenceToTest));
		System.assert(TQAppController.isPublicURL(urlToTest));
	}
}