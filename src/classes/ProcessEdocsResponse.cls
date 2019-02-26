public class ProcessEdocsResponse implements Queueable, Database.AllowsCallouts {
    String response;
    
    public ProcessEdocsResponse(String response){
        this.response = response;
    }

    
    public void execute(QueueableContext context) {
        External_Rest_Integration_Setting__mdt edocsIntegrationSetting = 
                           [SELECT DeveloperName, Endpoint__c, Method__c, x_api_key__c 
                            FROM External_Rest_Integration_Setting__mdt
                            Where DeveloperName = 'Edocs' limit 1];
        Http altHttp = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(edocsIntegrationSetting.Endpoint__c);
        req.setMethod(edocsIntegrationSetting.Method__c);
        req.setHeader('x-api-key', edocsIntegrationSetting.x_api_key__c);
        req.setBody(response);
        system.debug('This is the request x-api-key: '+req.getHeader('x-api-key'));
        HttpResponse res = altHttp.send(req);
    }
    
}