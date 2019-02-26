//
// Class Name  : StaticImageManager
// Created By  : Maksud Ali
// Description : It will contain the infromation of all static images(Brands) (for Story - S-455965)
// Date        : 17 Feb 2017

public class StaticImageManager {

    public String imageName { get; set; }
    public String imageWidth { get; set; }
    public String imageHeight { get; set; }
    
    //Constructor will take a param of string type (image name)
    public StaticImageManager(String imgName,String tourBrand){
    
        if(tourBrand != null && tourBrand != ''){
            if(imgName == 'Trafalgar.png' && tourBrand == 'COST'){
                imgName = 'COSTSAVER.png';
            } else if(imgName == 'InsightVacation.png' && tourBrand == 'GOLD'){
                imgName = 'LUXURY.png';
            }
        }
        
        //In case of large image it will set the old image size which we had earlier.
        imageHeight = 'auto';
        imageName = imgName;
        if(imgName == 'Brendan.PNG') {
            imageWidth = '107px';
        } else if(imgname == 'Contiki.png'){
            imageWidth = '150px';
        } else if(imgname == 'Trafalgar.png'){
            imageWidth = '200px';
        } else if(imgname == 'AAT_Kings.png'){
            imageWidth = '113px';
        } else if(imgname == 'GET.png'){
            imageWidth = '70px';
        } else if(imgname == 'InsightVacation.png'){
            imageWidth = '155px';
        } else if(imgname == 'INSPIRING.png'){
            imageWidth = '200px';
        } else if(imgname == 'noRegrets.png'){
            imageWidth = '452px';
        } else if(imgname == 'TransatLogo.png'){
            imageWidth = '596px';
        } else if(imgname == 'COSTSAVER.png'){
            imageWidth = '180px';
        } else if(imgname == 'LUXURY.png'){
            imageWidth = '200px';
        } else {
            imageWidth = 'auto';
        }
    }
}