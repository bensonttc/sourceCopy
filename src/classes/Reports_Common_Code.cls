public with sharing class Reports_Common_Code {
    public Reports_Common_Code() {
        
    }

    //Format decimal into string
    public static string formatTheCurrency(decimal value, boolean positive){
        string format1;
        if(positive){
            format1 = (value + 0.001).format();
        }
        else{
            format1 = (value - 0.001).format();
        }
        
        string format2 = format1.substring(0,format1.length()-1);
        return format2;
    }

    public static decimal ConvertThis(decimal ConversionRate, decimal input){
        decimal result;
        if(input != null){
            system.debug('Conversion rate used = '+ConversionRate);
            try{
                result = (input*conversionRate).setScale(2);
            }
            catch(exception e){
                result = 0.00;
            }
        }
        else{
            result = 0.00;
        }
        
        return result;
    }

    public static decimal SetNullToZero(decimal input){
        decimal result;
        if(input != null){
            result = input;
        }
        else{
            result = 0.00;
        }
        return result;
    }

    public static Integer ConvertToInteger(decimal input){
        Integer result;
        if(input != null){
            result = input.intValue();
        }
        else{
            result = 0;
        }
        return result;
    }
}