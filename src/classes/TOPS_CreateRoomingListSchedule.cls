/*** Class Created by Ravi Jain ***/
//April 10, 2018    Ravi Jain     T-678781    Class to schedule the batch

// Code changes done by Ravi Jain for story S-548465
// Start - Ravi Jain - S-548465 - 10th April, 2018 - to schedule the batch
global class TOPS_CreateRoomingListSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      TOPS_CreateRoomingList roomingListBatch = new TOPS_CreateRoomingList(); 
      database.executebatch(roomingListBatch);
   }
}
// End - Ravi Jain - S-548465 - 10th April, 2018