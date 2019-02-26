//Update lead currency based on Selling Company Code, needs trigger as workflow does not work with SF standard Lead currency field
// Brands covered IV, CH, TT, Uniworld, IV Gold, TT CostSaver
// Currencies covered GBP, USD, AUD, NZD, EUR, ZAR, SGD, CAD is a default lead currency for Lead object
// Created  - Shaz 26/01/16 Last update 30/06/16

trigger UpdateLeadCurrency on Lead (before insert,before update) {

                 for(lead ll:trigger.new){
                            if (ll.Selling_Company_Code__c=='IVSYDS' || ll.Selling_Company_Code__c=='CHSYDS' ||  ll.Selling_Company_Code__c=='TTSYDS' ||  ll.Selling_Company_Code__c=='UNSYDS'||  ll.Selling_Company_Code__c=='IVSYDS Gold'|| ll.Selling_Company_Code__c=='TTSYDS CostSaver' || ll.Selling_Company_Code__c=='AW#AUS' || ll.Selling_Company_Code__c=='AASYDS' ||  ll.Selling_Company_Code__c=='AAASAS' ||  ll.Selling_Company_Code__c=='AAGAUS'||  ll.Selling_Company_Code__c=='AABAUS'|| ll.Selling_Company_Code__c=='AASYDS CostSaver' || ll.Selling_Company_Code__c=='AAGAUS CostSaver' || ll.Selling_Company_Code__c=='AABAUS CostSaver') 
                            {
                            ll.CurrencyIsoCode='AUD'; // Australian Dollar
                            }
                            
                            else if (ll.Selling_Company_Code__c=='IVCANS' || ll.Selling_Company_Code__c=='CHCANS'||  ll.Selling_Company_Code__c=='TTCANS'||  ll.Selling_Company_Code__c=='UNCANS' || ll.Selling_Company_Code__c=='IVCANS Gold'|| ll.Selling_Company_Code__c=='TTCANS CostSaver' || ll.Selling_Company_Code__c=='AACANS'|| ll.Selling_Company_Code__c=='AACANS CostSaver') 
                            {
                            ll.CurrencyIsoCode='CAD'; // Canadian Dollar
                            }
                            
                            else if (ll.Selling_Company_Code__c=='IVUSAS' || ll.Selling_Company_Code__c=='CHUSAS'||  ll.Selling_Company_Code__c=='TTUSAS'||  ll.Selling_Company_Code__c=='UNUSAS'||  ll.Selling_Company_Code__c=='IVUSAS Gold' || ll.Selling_Company_Code__c=='TTUSAS CostSaver'|| ll.Selling_Company_Code__c=='Grand European' || ll.Selling_Company_Code__c=='AAUSAS'|| ll.Selling_Company_Code__c=='AAUSAS Costsaver') 
                            {
                            ll.CurrencyIsoCode='USD'; // U.S. Dollar
                            }
                            
                            else if (ll.Selling_Company_Code__c=='IVEUOS' || ll.Selling_Company_Code__c=='CHEUOS'||  ll.Selling_Company_Code__c=='TTEUOS'||  ll.Selling_Company_Code__c=='UNEUOS'||  ll.Selling_Company_Code__c=='IVEUOS Gold'|| ll.Selling_Company_Code__c=='TTEUOS CostSaver' || ll.Selling_Company_Code__c=='AAEUOS'||  ll.Selling_Company_Code__c=='AABEUS'||  ll.Selling_Company_Code__c=='AAEUOS Costsaver'||  ll.Selling_Company_Code__c=='AABEUS Costsaver') 
                            {
                            ll.CurrencyIsoCode='EUR'; // Euro
                            
                            }
                            else if (ll.Selling_Company_Code__c=='IVAKLS' || ll.Selling_Company_Code__c=='CHAKLS'||  ll.Selling_Company_Code__c=='TTAKLS'||  ll.Selling_Company_Code__c=='UNAKLS'||  ll.Selling_Company_Code__c=='IVAKLS Gold'|| ll.Selling_Company_Code__c=='TTAKLS CostSaver'|| ll.Selling_Company_Code__c=='AW#NZL' || ll.Selling_Company_Code__c=='AAAKLS'||  ll.Selling_Company_Code__c=='AAGNZS'|| ll.Selling_Company_Code__c=='AAAKLS CostSaver'|| ll.Selling_Company_Code__c=='AAGNZS Costsaver') 
                            {
                            ll.CurrencyIsoCode='NZD'; // New Zealand Dollar
                            
                            }
                            else if (ll.Selling_Company_Code__c=='IVJBGS' || ll.Selling_Company_Code__c=='CHJBGS'||  ll.Selling_Company_Code__c=='TTJBGS'||  ll.Selling_Company_Code__c=='UNJBGS'||  ll.Selling_Company_Code__c=='IVJBGS Gold'|| ll.Selling_Company_Code__c=='TTJBGS CostSaver') 
                            {
                            ll.CurrencyIsoCode='ZAR'; // South Africa Rand
                            
                            }
                            else if (ll.Selling_Company_Code__c=='IVSINS' || ll.Selling_Company_Code__c=='CHSINS'||  ll.Selling_Company_Code__c=='TTSINS'||  ll.Selling_Company_Code__c=='UNSINS'||  ll.Selling_Company_Code__c=='IVSINS Gold'|| ll.Selling_Company_Code__c=='TTSINS CostSaver'|| ll.Selling_Company_Code__c=='BVUSAS'|| ll.Selling_Company_Code__c=='BVUSAS CostSaver') 
                            {
                            ll.CurrencyIsoCode='USD'; // U.S. Dollar
                            
                            }
                          else if (ll.Selling_Company_Code__c=='IVUKLS' || ll.Selling_Company_Code__c=='CHUKLS'||  ll.Selling_Company_Code__c=='TTUKLS'||  ll.Selling_Company_Code__c=='UNUKLS' ||  ll.Selling_Company_Code__c=='IVUKLS Gold' || ll.Selling_Company_Code__c=='TTUKLS CostSaver' || ll.Selling_Company_Code__c=='AAUKLS' || ll.Selling_Company_Code__c=='AAUKLS CostSaver') 
                            {
                            ll.CurrencyIsoCode='GBP'; // British Pound
                           
                            }
                }
}