public class YTD_Status {

public Object  YTDdt{set;get;}  
public Object  YTDdtAus{set;get;}  

public Object  YTDdt_ASIA{set;get;}  
public Object  YTDdt_Aus{set;get;}  
public Object  YTDdt_NZ{set;get;}  
Public Object YTDdt_UK{set;get;} 
public Object  YTDdt_EUR{set;get;} 
public Object  YTDdt_SA{set;get;} 

public Object  YTDdt_USA{set;get;}  
public Object  YTDdt_CAN{set;get;} 
public Object  YTDdt_UW{set;get;} 



public YTD_Status(){




AggregateResult[] groupedResults = [select MAX(sa.lastmodifieddate)lmd from Summary_Analysis_2__c sa where Type__c = 'Business Unit - YTD - By Owner'  ];

AggregateResult[] groupedResults_ASIA = [select MAX(saASIA.lastmodifieddate)lmd_ASIA from Summary_Analysis_2__c saASIA where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='Asia' AND Brand__c='Contiki' AND  Active__c=true ];
AggregateResult[] groupedResults_Aus = [select MAX(saAus.lastmodifieddate)lmd_Aus from Summary_Analysis_2__c saAus where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='Australia' AND Brand__c='Contiki' AND  Active__c=true ];
AggregateResult[] groupedResults_NZ = [select MAX(saNZ.lastmodifieddate)lmd_NZ from Summary_Analysis_2__c saNZ where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='New Zealand' AND Brand__c='Contiki' AND  Active__c=true ];

AggregateResult[] groupedResults_SA = [select MAX(saSA.lastmodifieddate)lmd_SA from Summary_Analysis_2__c saSA where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='South Africa' AND Brand__c='Contiki' AND  Active__c=true];
AggregateResult[] groupedResults_UK = [select MAX(saUK.lastmodifieddate)lmd_UK from Summary_Analysis_2__c saUK where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='United Kingdom' AND Brand__c='Contiki' AND  Active__c=true];
AggregateResult[] groupedResults_EUR = [select MAX(saEUR.lastmodifieddate)lmd_EUR from Summary_Analysis_2__c saEUR where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='Euro Wholesalers' AND Brand__c='Contiki' AND  Active__c=true];

AggregateResult[] groupedResults_USA = [select MAX(saUSA.lastmodifieddate)lmd_USA from Summary_Analysis_2__c saUSA where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='USA' AND Brand__c='Contiki' AND  Active__c=true];
AggregateResult[] groupedResults_CAN = [select MAX(saCAN.lastmodifieddate)lmd_CAN from Summary_Analysis_2__c saCAN where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='Canada' AND Brand__c='Contiki' AND  Active__c=true];

AggregateResult[] groupedResults_UW = [select MAX(saUW.lastmodifieddate)lmd_UW from Summary_Analysis_2__c saUW where Type__c = 'Business Unit - YTD - By Owner' AND   Region__c ='USA' AND Brand__c='Uniworld' AND  Active__c=true];




Datetime dt= (Datetime) groupedResults[0].get('lmd');
Datetime dtAus= dt.addDays(-2);


Datetime dt_Asia= (Datetime) groupedResults_Asia[0].get('lmd_Asia');
Datetime dt_Asia2= dt_Asia.addDays(-1);

Datetime dt_Aus= (Datetime) groupedResults_Aus[0].get('lmd_Aus');
Datetime dt_Aus2= dt_Aus.addDays(-1);

Datetime dt_NZ= (Datetime) groupedResults_NZ[0].get('lmd_NZ');
Datetime dt_NZ2= dt_NZ.addDays(-1);

Datetime dt_SA= (Datetime) groupedResults_SA[0].get('lmd_SA');
Datetime dt_SA2= dt_SA.addDays(-1);

Datetime dt_UK= (Datetime) groupedResults_UK[0].get('lmd_UK');
Datetime dt_UK2= dt_UK.addDays(-1);

Datetime dt_EUR= (Datetime) groupedResults_EUR[0].get('lmd_EUR');
Datetime dt_EUR2= dt_EUR.addDays(-1);

Datetime dt_USA= (Datetime) groupedResults_USA[0].get('lmd_USA');
Datetime dt_USA2= dt_USA.addDays(-1);

Datetime dt_CAN= (Datetime) groupedResults_CAN[0].get('lmd_CAN');
Datetime dt_CAN2= dt_CAN.addDays(-1);




   Datetime dt_UW= (Datetime) groupedResults_UW[0].get('lmd_UW');
   Datetime dt_UW2= dt_UW.addDays(-1);








YTDdt = dt.date();
YTDdtAus = dtAus.date();

YTDdt_Asia = dt_Asia2.date();
YTDdt_Aus = dt_Aus2.date();
YTDdt_NZ = dt_NZ2.date();
YTDdt_SA= dt_SA2.date();
YTDdt_UK= dt_UK2.date();
YTDdt_EUR = dt_EUR2.date();
YTDdt_USA = dt_USA2.date();
YTDdt_CAN = dt_CAN2.date();
YTDdt_UW =  dt_UW2.date();





}

}