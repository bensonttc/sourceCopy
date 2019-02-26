// **** Built By Ricky Lowe (Cloud Perspective) 08/09/2014
// **** Controller for the logo page. The controller searches through the BrandLogo custom setting
// **** and checks if the user role has the Brand in the role name. If it does then it sets the
// **** logo as the static resource defined in the custom setting.

// **** a BrandLogo custom setting record called 'Default' must exist! This should be the Travel Corp Logo

// **** To Deploy:
// * Brand_logo_Controller
// * Brand Logo Page
// * BrandLogos Custom Setting + all fields


public class Brand_logo_Controller {
    public boolean Renderlogo {get; set;}
    public BrandLogos__c Brand {get; set;}
    
    //Initialise the Controller
    public Brand_logo_Controller(){
        Renderlogo = false;
        CalcBrand();
    }
    
    //Calculate the Brand logo from the Custom settings
    public void CalcBrand(){
        try{
        
            String uRoleId = UserInfo.getUserRoleId();
            BrandLogos__c DefaultBrand;
            try{
                DefaultBrand = BrandLogos__c.getvalues('Default');
            }
            catch(exception e){
                system.debug(loggingLevel.Warn, '*** No Default Custom Setting found');
            }
            
    
            if(uRoleId != null){
                UserRole UR = [select name from UserRole where id = :uRoleId];
                string RoleName = UR.name;
    
                for(BrandLogos__c  Brands : BrandLogos__c.getall().values()){
                    if(Brands.name != 'Default' && RoleName.Contains(Brands.name)){
                        Brand = Brands;
                        continue;
                    }
                }
                if(Brand == null){
                    if(DefaultBrand != null){
                        Brand = DefaultBrand;
                    }
                    else{
                        //No Custom setting exists for default - leave blank 
                        return;
                    }
                }
    
                //Check the static resource exists - if it doesn't then show white screen
                list<StaticResource> SR = [select id from StaticResource where name = :Brand.Static_Resource_Name__c];
                if(SR.size() == 1){
                    Renderlogo = true;
                }
    
            }
            else{
                if(DefaultBrand != null){
                    Brand = DefaultBrand;
                    Renderlogo = true;
                }
                else{
                    //No Custom setting exists for default - leave blank 
                    return;
                }
            }
        }
        catch(exception e){
            system.debug(loggingLevel.Warn, '*** Untrapped error = ' + e.getMessage());
            Renderlogo = false;
        }
        
    }
    
}