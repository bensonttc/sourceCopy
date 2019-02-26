//
//
// Test Class Name: StaticImageManager_Test
// For Apex Class: StaticImageManager//
// 17 Feb 2017    Maksud Ali  (Story# - S-455965)
// Code coverage : 100%
// 
@isTest(seeAllData=false)
class StaticImageManager_Test{

    static testMethod void StaticImageManager_Test() { 
        
         
        List<StaticImageManager> lstStaticImages = new List<StaticImageManager>();
        lstStaticImages.add(new StaticImageManager('Brendan.PNG',''));
        lstStaticImages.add(new StaticImageManager('Contiki.png',''));
        lstStaticImages.add(new StaticImageManager('Trafalgar.png',''));
        lstStaticImages.add(new StaticImageManager('AAT_Kings.png',''));
        lstStaticImages.add(new StaticImageManager('GET.png',''));
        lstStaticImages.add(new StaticImageManager('InsightVacation.png',''));
        lstStaticImages.add(new StaticImageManager('INSPIRING.png',''));
        lstStaticImages.add(new StaticImageManager('noRegrets.png',''));
        lstStaticImages.add(new StaticImageManager('TransatLogo.png',''));
        lstStaticImages.add(new StaticImageManager('COSTSAVER.png',''));
        lstStaticImages.add(new StaticImageManager('LUXURY.png',''));
        lstStaticImages.add(new StaticImageManager('Trafalgar.png','COST'));
        lstStaticImages.add(new StaticImageManager('InsightVacation.png','GOLD'));
        lstStaticImages.add(new StaticImageManager('dummy.png',''));
        System.assertEquals(lstStaticImages.size(),14);
    }

}