/********************************************************************************
 * Apex Class Name - UpdateCustomerBatch
 * Version - 1.0
 * Created Date - Jan 29, 2018
 * @description: Batch Apex class created to transfer data from Customer_Update_Message__c to Account.
 * 
 * Modification Log : 
 * -------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       David Zhang     29/01/2018              Original Version
 * 2.0       Linus Ho        25/02/2026              HKITSFDC-706 Add Marketing Opt Out in mapping
 * 3.0       Linus Ho        08/05/2026              HKITSFDC-563 Update Overall Opt Out instead of Marketing Opt Out
 ********************************************************************************/
global class UpdateCustomerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
   global final String recordTypeId;
   global final Map<String,Account> splitMap = new Map<String,Account>();
   global final Map<String,Account> mergeMap = new Map<String,Account>();
   public Boolean sendEmailFlag = false;
   public String errorMsg;
   public String informationMsg;
   Public Map<String,Boolean> dmlresultMap = new Map<String,Boolean>();
   public Integer batchNo=1;
   public Integer totalbatchNo=0;
   global List<TransactionTO> TransactonTOList;
   global final String DeletedrecordTypeId;
   global final Map<String,String> oldNewAccountMap = new Map<String,String>();
   public final static String EMAIL_REGEX = '(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
   public static Pattern emailPattern = Pattern.compile(EMAIL_REGEX);
   public static final String SEX_JOINT = 'JOINT';
   public static final String SEX_COMPANY = 'COMPANY';
   
   //Nicole_SPS-536_20200728
   public final static String RECORD_TYPE_TM_TASK = 'TM_Task';
   public final static String RECORD_TYPE_TM_CALL = 'TM_Call';

   /********************************************************************************
    * Batch apex class standard start method.
    ********************************************************************************/
   /*
   global Iterable<TransactionTO> start(Database.BatchableContext BC){
      return new TransactionTO();
   }*/
   global Database.QueryLocator start(Database.BatchableContext BC){

        
       List<Customer_Update_Message__c> earliestDate = [SELECT createdDate FROM Customer_Update_Message__c  WHERE Is_Loaded__c = false and Has_Error__c = false and Is_Executed__c = false order by createdDate asc limit 1];
        if(earliestDate!=null && earliestDate.size()>0){
        
            String startDT = DateTime.newInstance(earliestDate[0].createdDate.yearGMT(),earliestDate[0].createdDate.monthGMT(),earliestDate[0].createdDate.dayGMT()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            String endDT = DateTime.newInstance(earliestDate[0].createdDate.yearGMT(),earliestDate[0].createdDate.monthGMT(),earliestDate[0].createdDate.dayGMT()).addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');            
            // CR-60_Link_20220329, add SSN__c
            // String query = 'SELECT Transaction_ID__c FROM Customer_Update_Message__c WHERE Is_Loaded__c = false and Has_Error__c = false and Is_Executed__c = false and createdDate >='+ startDT +' and createdDate < '+ endDT +' order by Transaction_ID__c limit 10000';
            
            String query = 'SELECT SSN__c,Transaction_ID__c FROM Customer_Update_Message__c WHERE Is_Loaded__c = false and Has_Error__c = false and Is_Executed__c = false and createdDate >='+ startDT +' and createdDate < '+ endDT +' order by Transaction_ID__c limit 10000';
            // System.debug('query:'+query);
            //David - suspend Delete message when needed
            /*String query = '';
            if(test.isRunningTest()){
                query = 'SELECT SSN__c,Transaction_ID__c FROM Customer_Update_Message__c WHERE Is_Loaded__c = false and Has_Error__c = false and Is_Executed__c = false and createdDate >='+ startDT +' and createdDate < '+ endDT +' order by Transaction_ID__c limit 10000';
            } else {
                query = 'SELECT SSN__c,Transaction_ID__c FROM Customer_Update_Message__c WHERE Action__c != \'Delete\' and Is_Loaded__c = false and Has_Error__c = false and Is_Executed__c = false and createdDate >='+ startDT +' and createdDate < '+ endDT +' order by Transaction_ID__c limit 10000';
            }*/
            //David end
            
            
            return Database.getQueryLocator(query);
        } else {
            return Database.getQueryLocator('SELECT createdDate FROM Customer_Update_Message__c  WHERE Is_Loaded__c = false and Has_Error__c = false and Is_Executed__c = false order by createdDate asc limit 1');
        }
       
  }

   /********************************************************************************
    * Constructor, use to initialize
    ********************************************************************************/
   global UpdateCustomerBatch(){
       recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       DeletedrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Deleted Customer').getRecordTypeId();
   }

   global class TransactionTO {
     global String transactionId{get;set;}
     global Integer countOfTransaction{get;set;}
     global List<Customer_Update_Message__c> detailList {get;set;} 

  }
   
   /********************************************************************************
    * Batch apex class standard execute method.
    ********************************************************************************/
   global void execute(Database.BatchableContext BC, List<sObject> scope){
   //global void execute(Database.BatchableContext BC, List<TransactionTO> scope){
    
     List<String> transactionIdList = new List<String>();
        //CR-60_Link_20220329
        Map<String,String> tranAndSsnMap = new Map<String,String>();
        for(sObject msg:scope){
            Customer_Update_Message__c c = (Customer_Update_Message__c)msg;
            if (!tranAndSsnMap.containskey(c.SSN__c)) {
                tranAndSsnMap.put(c.SSN__c,c.Transaction_ID__c);
            }
            //transactionIdList.add(c.Transaction_ID__c);
        }
        //CR-60_Link_20220329
        for(String transID : tranAndSsnMap.values()){
            transactionIdList.add(transID);
        }
     // system.debug('###transactionIdList: ' + transactionIdList + ' ' + transactionIdList.size());
     // 20200717 - minghua - SF Modeling
     /*CR-54: Update account ssn and customer id: add Old_SSN__c, Old_Customer_ID__c  Zane 2021-10-21*/
     List<Customer_Update_Message__c> msgList = [SELECT Action__c,AML_Black_List_Exclusion__c,Broker_Customer__c, Customer_ID__c,DOB__c,Email__c,First_Name__c,Gender__c,Has_Error__c,Home_Phone__c,Is_Loaded__c,Is_Staff__c,Is_Suppressed__c,Last_Name__c,MM_Exclusion_Flag__c,Mobile__c,Nationality__c,OFCA_exclusion_applied__c,Opt_out_email_exclusion_applied__c,Partner_Exclusion_applied__c,Permanent_Address_1__c,Permanent_Address_2__c,Permanent_Address_3__c,Permanent_Address_4__c,Phone_opt_out_exclusion_applied__c,Record_In_Transaction__c,Resident_Address_1__c,Resident_Address_2__c,Resident_Address_3__c,Resident_Address_4__c,Sensitivity_Code__c,SSN__c,Transaction_ID__c,Work_Phone__c,Is_Executed__c,Sensitivity_Code_Desc__c,Credit_Card_No__c,Bank_Account_No__c, Old_Customer_ID__c, Old_SSN__c, Marketing_Opt_Out__c FROM Customer_Update_Message__c  WHERE Is_Loaded__c = false AND Has_Error__c = false  AND Is_Executed__c = false  AND Transaction_ID__c IN :transactionIdList ORDER BY Transaction_ID__c ASC];  // HKITSFDC-706 Adding a field Marketing_Opt_out__c

     String currentId ='';
     TransactionTO temp = new TransactionTO(); 
     TransactonTOList = new List<TransactionTO>();

     totalbatchNo = totalbatchNo + msgList.size();
     system.debug('###totalbatchNo: ' + totalbatchNo);


     for(Customer_Update_Message__c msg : msgList){
        msg.Is_Executed__c = true;
        if(String.isBlank(currentId) ||  msg.Transaction_ID__c != currentId){
            currentId = msg.Transaction_ID__c; 
            temp = new TransactionTO();
            temp.transactionId = msg.Transaction_ID__c;
            temp.countOfTransaction = Integer.valueof(msg.Record_In_Transaction__c);
            temp.detailList = new List<Customer_Update_Message__c>();
            temp.detailList.add(msg);
            TransactonTOList.add(temp);
        } else {
            temp.detailList.add(msg);
        }   
        
     }  

       List<Account> updateList = new List<Account>();
       Map<String,Account> upsertMap = new Map<String,Account>();
       List<String> updateSSNList = new List<String>();
       Map<String,Account> updateMap = new Map<String,Account>();
       List<String> deleteList = new List<String>();

       List<Customer_Update_Message__c> allMsg = new List<Customer_Update_Message__c>();
       for(TransactionTO s: TransactonTOList){
           //allMsg.addAll(s.detailList);
           // system.debug(s.transactionId + '  s.detailList.size() >>> ' + s.detailList.size() + ' <<<  s.countOfTransaction >>> ' + s.countOfTransaction);
           if(s.detailList.size() == s.countOfTransaction){
               allocateToList(s,upsertMap,deleteList, updateMap, updateSSNList);
           } else {
               //Error
               for(Customer_Update_Message__c msg : s.detailList){
                   msg.Has_Error__c = true;
                   dmlresultMap.put(msg.Customer_ID__c, false);
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ msg.Customer_ID__c+' : ' + Label.Update_Customer_Transaction_Record_Not_Correct;
                   }else{
                        errorMsg = msg.Customer_ID__c+' : ' + Label.Update_Customer_Transaction_Record_Not_Correct;
                   }
               }
           }
       }
       

       /*CR-54: Update account ssn and customer id. Zane 2021-10-21*/
       //process data for action type: SSN update
       Map<String, Account> updateSSNAccMap = swapAccountSSN(msgList);
       System.debug(LoggingLevel.INFO, '***updateSSNAccMap : ' + updateSSNAccMap);
       if(updateSSNAccMap.size() >0){
            Database.SaveResult[] ssnAccUpdtResults = Database.update(updateSSNAccMap.values(), false);
            Integer index = 0; 
            for (Database.SaveResult result : ssnAccUpdtResults) {
                Account ssnAccount = updateSSNAccMap.values()[index];
                System.debug('[ssnAccUpdtResults] ssnAccount='+ssnAccount);
                System.debug('[ssnAccUpdtResults] result='+result); 
                if (result.isSuccess()) {
                    // Operation was successful, update the is_load__c field in update customer message object       

                    dmlresultMap.put(ssnAccount.Customer_ID__c, true);
      
                } else {                   
                    dmlresultMap.put(ssnAccount.Customer_ID__c, false);
                     System.debug('[Failed]');
                    // Operation failed, so get all errors
                    for(Database.Error err : result.getErrors()) {   
                        System.debug('The following error has occurred.');
                        String resultErrorMsg =ssnAccount.SSN__c+' : ' + err.getStatusCode() + ' - ' + err.getMessage();
                        if(String.isNotBlank(errorMsg)){
                            errorMsg = errorMsg +'<br/>'+resultErrorMsg;
                        }else{
                            errorMsg = resultErrorMsg;
                        }
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                      }
                }
                index++;
            }

       }


       //Delete Account
       system.debug('Delete Size:'+deleteList.size());

       if(deleteList.size()>0){
          List<Account> deleteAccount = [select id, customer_id__c from Account where customer_id__c in :deleteList];
          //delete deleteAccount;
          Integer status = transferCaseBeforeDelete(deleteAccount);
          if(status >= 0){
            Database.DeleteResult[] delResults = Database.delete(deleteAccount, false);
            system.debug('delResults:' + delResults);
            Integer cnt = 0; 
            for (Database.DeleteResult result : delResults) {
               Account delAccount = deleteAccount[cnt];
               // System.debug('[UpsertResult] delAccount='+delAccount);
               // System.debug('[UpsertResult] DeleteResult='+result); 
               if (result.isSuccess()) {
                    // Operation was successful, update the is_load__c field in update customer message object       
                    dmlresultMap.put(delAccount.Customer_ID__c, true);
                    // System.debug('[Success]');

                    if(String.isNotBlank(informationMsg)){
                        informationMsg = informationMsg +'<br/>'+'Customer: ' + delAccount.Customer_ID__c + ' has been deleted.';
                    }else{
                        informationMsg = 'Customer: ' + delAccount.Customer_ID__c + ' has been deleted.';
                    }

                }else{ 
                    dmlresultMap.put(delAccount.Customer_ID__c, false);
                    for(Database.Error err : result.getErrors()) {   
                      // System.debug('The following error has occurred for delete.');
                      String delErrorMsg =delAccount.Customer_ID__c+' : ' + err.getStatusCode() + ' - ' + err.getMessage();
                      if(String.isNotBlank(errorMsg)){
                          errorMsg = errorMsg +'<br/>'+delErrorMsg;
                      }else{
                          errorMsg = delErrorMsg;
                      }
                      // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                      // System.debug('Account fields that affected this error: ' + err.getFields());
                    }

                }
                cnt ++;
            }
          }else{
            for(Account a : deleteAccount){
              dmlresultMap.put(a.customer_id__c, false);
              if(String.isNotBlank(errorMsg)){
                  errorMsg = errorMsg +'<br/>'+'Delete failed: ' + a.Customer_ID__c ;
              }else{
                  errorMsg = 'Delete failed: ' + a.Customer_ID__c ;
              }
            }
          }
        }

       //update Account
       system.debug('Update Size:'+updateMap.size());
       /*
       if(updateMap.size()>0){ 

           Map<String,String> accountSSNMap = new Map<String,String>();
           For(Account a : [Select id, SSN__c from Account Where SSN__c IN: updateSSNList]){
            accountSSNMap.put(a.SSN__c, a.id);
           }

           For(Account a : updateMap.values()){
            if(accountSSNMap != null && accountSSNMap.containsKey(a.SSN__c)){
              a.id = accountSSNMap.get(a.SSN__c);
            }
           }

           Schema.SObjectField f1 = Account.Fields.ID;
           Database.UpsertResult[] updateResults = Database.upsert(updateMap.values(), f1, false);
           system.debug('updateResults:' + updateResults);
           
           Integer index1 = 0; 
           for (Database.UpsertResult result : updateResults) {
               Account updateAccount = updateMap.values()[index1];
               System.debug('[UpsertResult] updateAccount='+updateAccount);
               System.debug('[UpsertResult] updateAccountResult='+result); 
               if (result.isSuccess()) {
                    // Operation was successful, update the is_load__c field in update customer message object       

                    dmlresultMap.put(updateAccount.Customer_ID__c, true);
                    System.debug('[Success]');
                } else {                   
                    dmlresultMap.put(updateAccount.Customer_ID__c, false);
                     System.debug('[Failed]');
                    // Operation failed, so get all errors
                    for(Database.Error err : result.getErrors()) {   
                        System.debug('The following error has occurred.');
                        String resultErrorMsg =updateAccount.Customer_ID__c+' : ' + err.getStatusCode() + ' - ' + err.getMessage();
                        if(String.isNotBlank(errorMsg)){
                            errorMsg = errorMsg +'<br/>'+resultErrorMsg;
                        }else{
                            errorMsg = resultErrorMsg;
                        }
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                      }
                }
               index1++;
            }
      
       }
        */
       //for insert
       // system.debug('Update Size:'+upsertMap.size());
       if(upsertMap.size()>0){ 
           
           // @@@ start add to updateMap
           List<String> tempSSNList = new List<String>();
           Map<String,String> ssnCustomerIdMap = new Map<String,String>();
           for(Account a : upsertMap.values()){
               tempSSNList.add(a.SSN__c);
               ssnCustomerIdMap.put(a.SSN__c, a.Customer_Id__c);
           }
           for(Account a : [Select id, SSN__c, Customer_ID__c from Account Where SSN__c IN: tempSSNList]){
           
           // system.debug('>>> a.SSN__c ' + a.SSN__c);
           // system.debug('>>> a.Customer_ID__c' + a.Customer_ID__c);
           
               if(String.isNotBlank(a.SSN__c) && String.isBlank(a.Customer_ID__c)){
                   String tempCustomerId = ssnCustomerIdMap.get(a.SSN__c);
                   Account upsertAcc = upsertMap.remove(tempCustomerId);
                   updateMap.put(tempCustomerId, upsertAcc);
                   updateSSNList.add(a.SSN__c);
               }
           }
           
           // @@@ End

           //upsert upsertMap.values() customer_id__c;
           // CR-60_Link_20220329
           // Schema.SObjectField f = Account.Fields.Customer_ID__c;
           Schema.SObjectField f = Account.Fields.SSN__c;
           Database.UpsertResult[] upsResults = Database.upsert(upsertMap.values(),f,false);
           system.debug('upsResults:' + upsResults);
           
           Integer index = 0; 
           for (Database.UpsertResult result : upsResults) {
               Account upsertAccount = upsertMap.values()[index];
               // System.debug('[UpsertResult] upsertAccount='+upsertAccount);
               // System.debug('[UpsertResult] upsertAccountResult='+result); 
               if (result.isSuccess()) {
                    // Operation was successful, update the is_load__c field in update customer message object       

                    dmlresultMap.put(upsertAccount.Customer_ID__c, true);
                    // System.debug('[Success]');
                    if(upsertAccount.description != null && upsertAccount.description.contains('Deleted')){
                        if(String.isNotBlank(informationMsg)){
                            informationMsg = informationMsg +'<br/>'+' Merge Case: soft-delete account: ' + upsertAccount.Customer_ID__c;
                        }else{
                            informationMsg = ' Merge Case: soft-delete account: ' + upsertAccount.Customer_ID__c;
                        }
                    }
                } else {                   
                    dmlresultMap.put(upsertAccount.Customer_ID__c, false);
                     // System.debug('[Failed]');
                    // Operation failed, so get all errors
                    for(Database.Error err : result.getErrors()) {   
                        // System.debug('The following error has occurred.');
                        String resultErrorMsg =upsertAccount.Customer_ID__c+' : ' + err.getStatusCode() + ' - ' + err.getMessage();
                        if(String.isNotBlank(errorMsg)){
                            errorMsg = errorMsg +'<br/>'+resultErrorMsg;
                        }else{
                            errorMsg = resultErrorMsg;
                        }
                        // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        // System.debug('Account fields that affected this error: ' + err.getFields());
                      }
                }
               index++;
            }
      
       }
       
       system.debug('Update Size:'+updateMap.size());
       if(updateMap.size()>0){ 
           Map<String,String> accountSSNMap = new Map<String,String>();
           For(Account a : [Select id, SSN__c from Account Where SSN__c IN: updateSSNList]){
            accountSSNMap.put(a.SSN__c, a.id);
           }

           For(Account a : updateMap.values()){
            if(accountSSNMap != null && accountSSNMap.containsKey(a.SSN__c)){
              a.id = accountSSNMap.get(a.SSN__c);
            }
           }

           Schema.SObjectField f1 = Account.Fields.ID;
           Database.UpsertResult[] updateResults = Database.upsert(updateMap.values(), f1, false);
           system.debug('updateResults:' + updateResults);
           
           Integer index1 = 0; 
           for (Database.UpsertResult result : updateResults) {
               Account updateAccount = updateMap.values()[index1];
               // System.debug('[UpsertResult] updateAccount='+updateAccount);
               // System.debug('[UpsertResult] updateAccountResult='+result); 
               if (result.isSuccess()) {
                    // Operation was successful, update the is_load__c field in update customer message object       

                    dmlresultMap.put(updateAccount.Customer_ID__c, true);
                    // System.debug('[Success]');
                } else {                   
                    dmlresultMap.put(updateAccount.Customer_ID__c, false);
                     // System.debug('[Failed]');
                    // Operation failed, so get all errors
                    for(Database.Error err : result.getErrors()) {   
                        // System.debug('The following error has occurred.');
                        String resultErrorMsg =updateAccount.Customer_ID__c+' : ' + err.getStatusCode() + ' - ' + err.getMessage();
                        if(String.isNotBlank(errorMsg)){
                            errorMsg = errorMsg +'<br/>'+resultErrorMsg;
                        }else{
                            errorMsg = resultErrorMsg;
                        }
                        // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        // System.debug('Account fields that affected this error: ' + err.getFields());
                      }
                }
               index1++;
            }
      
       }

        // System.debug('dmlresultMap: ' + dmlresultMap);
        if(oldNewAccountMap != null && oldNewAccountMap.size()>0){
            //transfer related list inforation to new account
            transferRelatedListToNewAccount(oldNewAccountMap);
        }

        //HKITSFDC-318 BEGIN ,nonOTP email update
        Map<Id, String> accountIdToNonOtpEmail = new Map<Id, String>();
        Set<String> customerIdsForNonOtp = new Set<String>();
        for (Customer_Update_Message__c cum : msgList) {
            if (cum.Action__c != null && cum.Action__c.equalsIgnoreCase('Update')
                && dmlresultMap.containsKey(cum.Customer_ID__c)
                && dmlresultMap.get(cum.Customer_ID__c) == true) {
                customerIdsForNonOtp.add(cum.Customer_ID__c);
            }
        }
        if (!customerIdsForNonOtp.isEmpty()) {
            Map<String, Id> customerIdToAccountId = new Map<String, Id>();
            for (Account acc : [
                SELECT Id, Customer_ID__c
                FROM Account
                WHERE Customer_ID__c IN :customerIdsForNonOtp
            ]) {
                customerIdToAccountId.put(acc.Customer_ID__c, acc.Id);
            }
            for (Customer_Update_Message__c cum : msgList) {
                if (cum.Action__c != null && cum.Action__c.equalsIgnoreCase('Update')
                    && customerIdToAccountId.containsKey(cum.Customer_ID__c)
                    && dmlresultMap.containsKey(cum.Customer_ID__c)
                    && dmlresultMap.get(cum.Customer_ID__c) == true) {
                    accountIdToNonOtpEmail.put(
                        customerIdToAccountId.get(cum.Customer_ID__c),
                        cum.Email__c
                    );
                }
            }
            updateNonOtpUserEmailForBatch(accountIdToNonOtpEmail);
        }
        //HKTISFDC-318 ENDED

       for(Customer_Update_Message__c c : msgList){
           if(dmlresultMap.containsKey(c.Customer_ID__c)){
            if(dmlresultMap.get(c.Customer_ID__c) == true){
              c.Is_Loaded__c = True;
              c.Has_Error__c = False;
            }else{
              c.Is_Loaded__c = False;
              c.Has_Error__c = True;
            }
          }
          c.Is_Executed__c = true;
          // System.debug('dmlresultMap c: ' + c);
          allMsg.add(c);
       }

       //update TX
       update allMsg;
   }
   
   /********************************************************************************
    *  Custom class, used to statistic database excute information for one record.
    ********************************************************************************/    
   private class TXFeature {
       Integer deleteCount = 0;
       Integer insertCount = 0;
       Integer updateCount = 0;
       String deleteId = '';
       String upsertId = '';
   }
   
   /********************************************************************************
    * Method to transfer data type from iterator to account.
    ********************************************************************************/
   private void allocateToList(TransactionTO tx, Map<String,Account> upsertMap, List<String> deleteList, Map<String,Account> updateMap, List<String> updateSSNList){
       //System.debug('Transaction:'+tx);
       if(tx.countOfTransaction > 1){
           TXFeature feature = new TXFeature();
           List<Account> updateTempList = new List<Account>();
           List<Account> deleteTempList = new List<Account>();
           system.debug('Detail List size >>> ' + tx.detailList.size());
           String newAccountId;
           for(Customer_Update_Message__c msg : tx.detailList){
               
               if(String.isBlank(msg.Last_Name__c)){
                  msg.Last_Name__c = '[BLANK]';    
               }

               if(msg.Action__c.equalsIgnoreCase('Delete')){
                   feature.deleteCount++;
                   feature.deleteId += msg.Customer_ID__c + ', ';
                   deleteTempList.add(transformToAccount(msg));
               }
               
               if(msg.Action__c.equalsIgnoreCase('Update')){
                   feature.updateCount++;
                   feature.upsertId += msg.Customer_ID__c + ', ';
                   updateTempList.add(transformToAccount(msg));
               }
               
               if(msg.Action__c.equalsIgnoreCase('Insert')){
                   feature.updateCount++;
                   feature.upsertId += msg.Customer_ID__c + ', ';
                   updateTempList.add(transformToAccount(msg));
               }
           }
           
           if(feature.insertCount + feature.updateCount == 2 && feature.deleteCount == 0){
               //split Case
               // System.debug('Split Case:'+ feature.upsertId );
               for(Account temp : updateTempList){
                  upsertMap.put(temp.Customer_ID__c, temp);
                  splitMap.put(temp.Customer_ID__c, temp);                  
               }

               for(Account temp : deleteTempList){
                  temp.SSN__c = 'Deleted' + temp.SSN__c;
                  temp.Description = 'Deleted (Split Case)';
                  //soft-delete the account
                  temp.RecordTypeId = DeletedrecordTypeId;
                  upsertMap.put(temp.Customer_ID__c, temp);
               }
               
           } else if(feature.insertCount + feature.updateCount == 1 && feature.deleteCount >= 1) {
               // Merge Case
               // System.debug('Merge Case from '+feature.deleteId + ' to ' + feature.upsertId);
               for(Account temp : updateTempList){
                  upsertMap.put(temp.Customer_ID__c, temp);
                  mergeMap.put(temp.Customer_ID__c, temp);
                  newAccountId = temp.Customer_ID__c;
               }
               for(Account temp : deleteTempList){
                  temp.SSN__c = 'Deleted' + temp.SSN__c;
                  temp.Description = 'Deleted (Merge Case)';
                  temp.RecordTypeId = DeletedrecordTypeId;
                  upsertMap.put(temp.Customer_ID__c, temp);
                  oldNewAccountMap.put(temp.Customer_ID__c, newAccountId);
               }
           } else {
               //Error
               for(Customer_Update_Message__c msg : tx.detailList){
                   //msg.Has_Error__c = true;
                  dmlresultMap.put(msg.Customer_ID__c, false);
               }
           }
           
       } else {
           Customer_Update_Message__c temp = tx.detailList[0];
           if(String.isBlank(temp.Last_Name__c)){
              temp.Last_Name__c = '[BLANK]';    
           }
               
           if(temp.Action__c.equalsIgnoreCase('Delete')){
              deleteList.add(temp.customer_Id__c);
           //} else if(temp.Action__c.equalsIgnoreCase('Update')){
             // updateMap.put(temp.Customer_ID__c, transformToAccount(temp));
             // updateSSNList.add(temp.SSN__c);

           //CR-54 Update broker account SSN Zane 2021-10-21
           }else if(temp.Action__c.equalsIgnoreCase('SSN Update')){


           }else{
              upsertMap.put(temp.Customer_ID__c, transformToAccount(temp));
           }
       }       
   }
  


   /**
    * CR-54: update account SSN and customer id.  
    * 1. swap ssn and custoemr id if tow asscounts are existed with old ssn and new ssn; 2. replase old ssn with new ssn if only one account with old ssn is exsisted. 3. report customer registed customer portal with new ssn not old ssn
    * @param    List<Customer_Update_Message__c> updateSSNCustomerList: use those data to update account SSN 
    * @return   Map<String, Account> : update this account map
    * @version  V1.0   create this method,  Zane 2021-10-21
    * @author Zane
    * 
    * 
    * ****/
    private Map<String, Account> swapAccountSSN(List<Customer_Update_Message__c> updateSSNCustomerList){
        Map<String, Account> resultedAccMap =new Map<String, Account>();

        Map<String, Customer_Update_Message__c> customerUpdateMap = new Map<String, Customer_Update_Message__c>();
        Set<String> customerIdSet = new Set<String>();
        Map<String, Account> customerIdAccMap = new Map<String, Account>();

        // System.debug(LoggingLevel.INFO, '*** updateSSNCustomerList: ' + updateSSNCustomerList);
        /*1. collect old and new customer id*/
        for(Customer_Update_Message__c tempCUM: updateSSNCustomerList){
            // oldCustomerMap.put(tempCUM.Old_Customer_ID__c, tempCUM);
            // newCustomerMap.put(tempCUM.Customer_ID__c, tempCUM);
            if(tempCUM.Action__c.equalsIgnoreCase('SSN Update')){
                customerUpdateMap.put(tempCUM.SSN__c, tempCUM);
                customerIdSet.add(tempCUM.SSN__c);
                customerIdSet.add(tempCUM.Old_SSN__c);
            }
        }
        // System.debug(LoggingLevel.INFO, '***customerIdSet : ' + customerIdSet);
        /*2. search corresponding account datas*/
        for(Account tempAcc: [SELECT Id, Customer_ID__c,SSN__c FROM Account WHERE SSN__c IN :customerIdSet]){
            customerIdAccMap.put(tempAcc.SSN__c,tempAcc);
        }
        System.debug(LoggingLevel.INFO, '***customerIdAccMap : ' + customerIdAccMap);
        /*3. process data: */
        for(Customer_Update_Message__c tempCUMSSN: customerUpdateMap.values()){
            //a. swap the SSN and Customer ID between the 2 accounts:
            if(customerIdAccMap.containskey(tempCUMSSN.SSN__c) && customerIdAccMap.containskey(tempCUMSSN.Old_SSN__c)){
                Account oldAcc = customerIdAccMap.get(tempCUMSSN.Old_SSN__c);
                Account newAcc = customerIdAccMap.get(tempCUMSSN.SSN__c);

                oldAcc.SSN__c = tempCUMSSN.SSN__c;
                oldAcc.Customer_ID__c = tempCUMSSN.Customer_ID__c;

                newAcc.SSN__c = tempCUMSSN.Old_SSN__c;
                newAcc.Customer_ID__c = tempCUMSSN.Old_Customer_ID__c;


                resultedAccMap.put(tempCUMSSN.SSN__c, oldAcc);
                resultedAccMap.put(tempCUMSSN.Old_SSN__c, newAcc);
                // System.debug(LoggingLevel.INFO, '**111resultedAccMap : ' + resultedAccMap);
                //b. not exist new account
            } else if(!customerIdAccMap.containskey(tempCUMSSN.SSN__c) && customerIdAccMap.containskey(tempCUMSSN.Old_SSN__c)){
                Account oldAcc = customerIdAccMap.get(tempCUMSSN.Old_SSN__c);

                oldAcc.SSN__c = tempCUMSSN.SSN__c;
                oldAcc.Customer_ID__c = tempCUMSSN.Customer_ID__c;


                resultedAccMap.put(tempCUMSSN.SSN__c, oldAcc);
                // System.debug(LoggingLevel.INFO, '***222resultedAccMap : ' + resultedAccMap);
                //c. registed account using new ssn not old ssn?? information in email
            } else if(customerIdAccMap.containskey(tempCUMSSN.SSN__c) && !customerIdAccMap.containskey(tempCUMSSN.Old_SSN__c)){
               // System.debug(LoggingLevel.INFO, '***333resultedAccMap : ' + resultedAccMap);
               if(String.isNotBlank(informationMsg)){
                    informationMsg += '<br/>' + 'New SSN: ' + tempCUMSSN.SSN__c +' already registered a portal account, no further action needed.';
               } else{
                    informationMsg = 'New SSN: ' + tempCUMSSN.SSN__c +' already registered a portal account, no further action needed.';
               }


            }

        }   

        return resultedAccMap;
    }
  
   /********************************************************************************
    * Method to get Account pending handle data from Customer_Update_Message__c.
    ********************************************************************************/
   private Account transformToAccount(Customer_Update_Message__c cum){
       Account acc = new Account();
       // System.debug('recordTypeId:'+recordTypeId);
       acc.Customer_ID__c = cum.Customer_ID__c;
       acc.Email__c = cum.Email__c;
       //check email format and put email address to personEmail if correct
       Matcher emailMatcher;
       if(String.isNotBlank(cum.Email__c)){
          emailMatcher = emailPattern.matcher(cum.Email__c);
          if(emailMatcher.matches()){
              acc.PersonEmail = cum.Email__c;
          }
       }
       //=====SPS-165 (AH16721) Add sensitivity code desc START====
       acc.Sensitivity_Code_Desc__c = cum.Sensitivity_Code_Desc__c;
       //=====SPS-165 (AH16721) Add sensitivity code desc END====
       
       // 20200717 - minghua - SF Modeling
       acc.Credit_Card_No__c = cum.Credit_Card_No__c;
       acc.Bank_Account_No__c = cum.Bank_Account_No__c;

       acc.firstName = cum.First_Name__c;
       acc.PersonHomePhone = cum.Home_Phone__c;
       acc.lastName = cum.Last_Name__c;
       acc.PersonMobilePhone = cum.Mobile__c;
       acc.Phone = cum.Mobile__c;
       acc.SSN__c = cum.SSN__c;
       acc.Work_Phone__c = cum.Work_Phone__c;
       acc.Insert_from_Cigna_Backend__c = true;
       acc.recordTypeId = recordTypeId;
   
       // TM fields start
       // David Zhang - handle company/joint gender - 20190315
       if(String.isNotBlank(cum.Gender__c)){
           System.debug('Gender:'+cum.Gender__c.trim());
           if(cum.Gender__c.trim() == 'F'){
              acc.Gender__c = 'Female';
           } else if(cum.Gender__c.trim() == 'M'){
              acc.Gender__c = 'Male';
           } else if(cum.Gender__c.trim() == SEX_JOINT || cum.Gender__c.trim() == SEX_COMPANY){
               acc.Gender__c = '';
           } else {
               acc.Gender__c = cum.Gender__c.trim();
           }
       }
       
       acc.PersonBirthdate__c = cum.DOB__c;
       if(acc.PersonBirthdate__c != null){
           acc.age__c = calculateAge(acc.PersonBirthdate__c);
       }
       
       /* TS-726 updatecustomerinformation API should cover "Residential Address" only (i.e. NO permanent address)
       acc.Office_Address_Line_1__c = cum.Permanent_Address_1__c;
       acc.Office_Address_Line_2__c = cum.Permanent_Address_2__c;
       acc.Office_Address_Line_3__c = cum.Permanent_Address_3__c;
       acc.Office_Address_Line_4__c = cum.Permanent_Address_4__c;
       */
       acc.Home_Address_Line_1__c = cum.Resident_Address_1__c;
       acc.Home_Address_Line_2__c = cum.Resident_Address_2__c;
       acc.Home_Address_Line_3__c = cum.Resident_Address_3__c;
       acc.Home_Address_Line_4__c = cum.Resident_Address_4__c;
       acc.Sensitivity_Code__c = cum.Sensitivity_Code__c;
       acc.Nationality__c = cum.Nationality__c;
       
       acc.Is_Staff__pc = (cum.Is_Staff__c == 'Y');
       acc.Suppressed__pc = (cum.Is_Suppressed__c == 'Y');
       acc.MM_Exclusion__pc = (cum.MM_Exclusion_Flag__c == 'Y');
       acc.Partner_Exclusion__pc = (cum.Partner_Exclusion_applied__c == 'Y');
       acc.Broker_customer__pc = (cum.Broker_Customer__c == 'Y');
       acc.AML_Black_List__pc = (cum.AML_Black_List_Exclusion__c == 'Y');
       acc.Phone_opt_out__pc = (cum.Phone_opt_out_exclusion_applied__c == 'Y');      
       acc.Opt_out_email__pc = (cum.Opt_out_email_exclusion_applied__c == 'Y');      
       acc.OFCA_opt_out__pc = (cum.OFCA_exclusion_applied__c == 'Y'); 
       //acc.Marketing_opt_out__pc = (cum.Marketing_Opt_Out__c == 'Y');  // HKITSFDC-706
       acc.Overall_Opt_Out__pc  = (cum.Marketing_Opt_Out__c == 'Y');  // HKITSFDC-563
       
       // system.debug('[UpdateCustomerBatch] transformToAccount before updateWithSenvCode >> ' + acc);
       SensitivityCodeUtil.updateWithSenvCode(acc);
       // system.debug('[UpdateCustomerBatch] transformToAccount after updateWithSenvCode >> ' + acc);
       //TM fields end
       return acc;
   }
   /********************************************************************************
    * Method to transfer those related list to new account
    ********************************************************************************/
   private Void transferRelatedListToNewAccount(Map<String,String> oldNewAccountMap){

        //related list for CS start
        List<Case> caseList = new List<Case>();
        List<Task> taskList = new List<Task>();
        List<Event> eventList = new List<Event>();
        List<LiveChatTranscript> liveChatTranscriptList = new List<LiveChatTranscript>();
        List<Tracking_History__c> trackingHistoryList = new List<Tracking_History__c>();
        List<Opportunity> oppList = new List<Opportunity>();                    // add by TM
        List<Policy_Transaction__c> ptList = new List<Policy_Transaction__c>(); // add by TM
        List<Opt_out_History__c> optOutList = new List<Opt_out_History__c>();   // add by TM
        Database.SaveResult[] updateResults;
        // system.debug('transferRelatedListToNewAccount oldNewAccountMap: ' + oldNewAccountMap);

        Map<String,String> accountidCustomeridMap = new Map<String,String>();
        Map<String,String> contactidCustomeridMap = new Map<String,String>();

        for(Account a : [Select id, Customer_id__c from Account where Customer_id__c IN: oldNewAccountMap.keySet() Or Customer_id__c IN: oldNewAccountMap.values()]){

            accountidCustomeridMap.put(a.Customer_id__c, a.id);

        }

        for(Contact c : [Select id, Account.Customer_id__c from Contact where Account.Customer_id__c IN: oldNewAccountMap.keySet() Or Account.Customer_id__c IN: oldNewAccountMap.values()]){

            contactidCustomeridMap.put(c.Account.Customer_id__c, c.id);

        }

        //get related case information
        For(Case c : [Select id, Accountid, Account.Customer_id__c from Case Where Accountid != null and Account.Customer_id__c IN: oldNewAccountMap.keySet()]){
            c.AccountId = accountidCustomeridMap.get(oldNewAccountMap.get(c.Account.Customer_id__c));
            c.ContactId = contactidCustomeridMap.get(oldNewAccountMap.get(c.Account.Customer_id__c));
            // Rancho_PI110_20230705 - set current datetime, will bypass validation rule if this field > (now - 5 seconds)
            c.Bypass_Validation_Datetime__c = System.now();
            caseList.add(c);
        }
        // system.debug('transferRelatedListToNewAccount CaseList: ' + caseList);

        if(caseList != null && caseList.size()>0){

            updateResults = Database.update(caseList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the case related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the case related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }

        //get related Task Information
        //Niocle_SPS-536_20200728
        List<String> TMTaskRecordIdList = new List<String>();
        for(RecordType tmTaskR : [Select Id From RecordType Where DeveloperName = :RECORD_TYPE_TM_TASK or DeveloperName = :RECORD_TYPE_TM_CALL]){
            TMTaskRecordIdList.add(tmTaskR.Id);
        }
        
        For(Task t : [Select id, Accountid, whatid, whoid, Account.Customer_id__c, RecordTypeId from Task Where Accountid != null and Account.Customer_id__c IN: oldNewAccountMap.keySet()]){
            if(!TMTaskRecordIdList.contains(t.RecordTypeId)){
                t.whatid = accountidCustomeridMap.get(oldNewAccountMap.get(t.Account.Customer_id__c));
                t.whoid = contactidCustomeridMap.get(oldNewAccountMap.get(t.Account.Customer_id__c));
                TaskList.add(t);
            }
        }
        // system.debug('transferRelatedListToNewAccount TaskList: ' + TaskList);
        if(TaskList != null && TaskList.size()>0){

            updateResults = Database.update(TaskList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the Task related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the Task related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }
        //get related Event Information
        For(Event e : [Select id, Accountid, whatid, whoid, Account.Customer_id__c from Event Where Accountid != null and Account.Customer_id__c IN: oldNewAccountMap.keySet()]){
            e.whatid = accountidCustomeridMap.get(oldNewAccountMap.get(e.Account.Customer_id__c));
            e.whoid = contactidCustomeridMap.get(oldNewAccountMap.get(e.Account.Customer_id__c));
            eventList.add(e);
        }
        system.debug('transferRelatedListToNewAccount eventList: ' + eventList);
        if(eventList != null && eventList.size()>0){

            updateResults = Database.update(eventList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the Event related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the Event related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }

        //get related live chat transcript information
        For(LiveChatTranscript live : [Select id, Accountid, Account.Customer_id__c from LiveChatTranscript Where Accountid != null and Account.Customer_id__c IN: oldNewAccountMap.keySet()]){
            live.AccountId = accountidCustomeridMap.get(oldNewAccountMap.get(live.Account.Customer_id__c));
            live.ContactId = contactidCustomeridMap.get(oldNewAccountMap.get(live.Account.Customer_id__c));
            liveChatTranscriptList.add(live);
        }
        system.debug('transferRelatedListToNewAccount liveChatTranscriptList: ' + liveChatTranscriptList);
        if(liveChatTranscriptList != null && liveChatTranscriptList.size()>0){

            updateResults = Database.update(liveChatTranscriptList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the liveChatTranscriptList related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the liveChatTranscriptList related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }
        //get tracking history information
        For(Tracking_History__c th : [Select id, Account__c, Account__r.Customer_id__c from Tracking_History__c Where Account__c != null and Account__r.Customer_id__c IN: oldNewAccountMap.keySet()]){
            th.Account__c = accountidCustomeridMap.get(oldNewAccountMap.get(th.Account__r.Customer_id__c));
            trackingHistoryList.add(th);
        }
        system.debug('transferRelatedListToNewAccount trackingHistoryList: ' + trackingHistoryList);
        if(trackingHistoryList != null && trackingHistoryList.size()>0){

            updateResults = Database.update(trackingHistoryList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the Tracking History related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the Tracking History related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }
        //related list for CS end
        
        //get Opportunity information
        For(Opportunity opp : [Select id, AccountId, Account.Customer_id__c from Opportunity Where AccountId != null and Account.Customer_id__c IN: oldNewAccountMap.keySet()]){
            opp.AccountId = accountidCustomeridMap.get(oldNewAccountMap.get(opp.Account.Customer_id__c));
            oppList.add(opp);
        }
        system.debug('transferRelatedListToNewAccount oppList: ' + oppList);
        if(oppList != null && oppList.size()>0){

            updateResults = Database.update(oppList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the Opportunity related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the Opportunity related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }
        
        //get Policy Transaction information
        For(Policy_Transaction__c pt : [Select id, Account__c, Account__r.Customer_id__c from Policy_Transaction__c Where Account__c != null and Account__r.Customer_id__c IN: oldNewAccountMap.keySet()]){
            pt.Account__c = accountidCustomeridMap.get(oldNewAccountMap.get(pt.Account__r.Customer_id__c));
            ptList.add(pt);
        }
        system.debug('transferRelatedListToNewAccount ptList : ' + ptList);
        if(ptList != null && ptList.size()>0){

            updateResults = Database.update(ptList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the Policy Transaction related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the Policy Transaction related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }
        
        //get Opt-out History information
        For(Opt_out_History__c optOut : [Select id, Account__c, Account__r.Customer_id__c from Opt_out_History__c Where Account__c != null and Account__r.Customer_id__c IN: oldNewAccountMap.keySet()]){
            optOut.Account__c = accountidCustomeridMap.get(oldNewAccountMap.get(optOut.Account__r.Customer_id__c));
            optOutList.add(optOut);
        }
        system.debug('transferRelatedListToNewAccount optOutList : ' + optOutList);
        if(optOutList != null && optOutList.size()>0){

            updateResults = Database.update(optOutList, true);
            for (Database.SaveResult result : updateResults) {
               if (!result.isSuccess()) {
                   if(String.isNotBlank(errorMsg)){
                        errorMsg = errorMsg +'<br/>'+ 'Some of the Opt-out History related list failed to transfer to new merge Account' ;
                   }else{
                        errorMsg = 'Some of the Opt-out History related list failed to transfer to new merge Account' ;
                   }
                   break;
                } 
            }
        }

   }

   /********************************************************************************
    * HKITSFDC-213 Sync NonOTP notification email to portal User (Account Id -> new email only).
    * Uses dmlresultMap and errorMsg like transferRelatedListToNewAccount.
    ********************************************************************************/
   private void updateNonOtpUserEmailForBatch(Map<Id, String> accountIdToNewEmail) {
        if (accountIdToNewEmail == null || accountIdToNewEmail.isEmpty()) {
            return;
        }
        List<User> updateUserList = new List<User>();
        for (User u : [
            SELECT Id, NonOTP_Notification_EmailAddress__c, AccountId, Username
            FROM User
            WHERE AccountId IN :accountIdToNewEmail.keySet()
        ]) {
            String newEmail = accountIdToNewEmail.get(u.AccountId);
            if (u.NonOTP_Notification_EmailAddress__c != newEmail) {
                u.NonOTP_Notification_EmailAddress__c = newEmail;
                System.debug(
                    'user ' + u.Username + ' update nonOPT email to ' + newEmail
                );
                updateUserList.add(u);
            }
        }
        if (updateUserList.isEmpty()) {
            return;
        }
        Database.SaveResult[] results = Database.update(updateUserList, false);
        Set<Id> failedAccountIds = new Set<Id>();
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                failedAccountIds.add(updateUserList[i].AccountId);
            }
        }
        Map<Id, Account> failedAccountById = new Map<Id, Account>();
        if (!failedAccountIds.isEmpty()) {
            failedAccountById.putAll([
                SELECT Id, Customer_ID__c
                FROM Account
                WHERE Id IN :failedAccountIds
            ]);
        }
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                User usr = updateUserList[i];
                Account acct = failedAccountById.get(usr.AccountId);
                String customerId = acct != null ? acct.Customer_ID__c : null;
                if (customerId != null && dmlresultMap.containsKey(customerId)) {
                    dmlresultMap.put(customerId, false);
                }
                for (Database.Error err : results[i].getErrors()) {
                    String resultErrorMsg =
                        (String.isNotBlank(customerId) ? customerId : String.valueOf(usr.AccountId))
                        + ' : '
                        + err.getStatusCode()
                        + ' - '
                        + err.getMessage();
                    if (String.isNotBlank(errorMsg)) {
                        errorMsg = errorMsg + '<br/>' + resultErrorMsg;
                    } else {
                        errorMsg = resultErrorMsg;
                    }
                }
            }
        }
   }

   /********************************************************************************
    * Method to transfer related case list to non-existing account and mark soft-delete before delete account
    ********************************************************************************/
   private Integer transferCaseBeforeDelete(List<Account> deleteAccount){

      if(deleteAccount == null || deleteAccount.size() == 0){
         return 0;
      }
      
      Boolean hasError = false;
      List<String> accountIdList = new List<String>();
      List<Case> caseList = new List<Case>();
      List<Policy_Transaction__c> ptList = new List<Policy_Transaction__c>(); // add by TM
      List<User> userList;

      Database.SaveResult[] updateResults;
      // system.debug('transferCaseBeforeDelete deleteAccount: ' + deleteAccount);
      
      for(Account a: deleteAccount){
           accountIdList.add(a.id);
      }

      //get the non-existing customer information
      //Account nonExistingAccount = [Select id, (select id from contacts) from Account where RecordTypeId = :recordTypeId And lastName = 'Non-existing customer' limit 1];
      
      //Nicole_SPS-536_20200803
      Portal_Settings__c portalSetting = Portal_Settings__c.getInstance();  
      Account nonExistingAccount = [Select id, (select id from contacts) from Account where RecordTypeId = :recordTypeId And Id = :portalSetting.Archive_Account_Id__c limit 1];

      
      Contact nonExistingContact;
      if(nonExistingAccount.Contacts !=null && nonExistingAccount.Contacts.size()>0){
        nonExistingContact = nonExistingAccount.Contacts[0];
      }
      
      // system.debug('transferCaseBeforeDelete nonExistingContact: ' + nonExistingContact);
      
      try {

          //get related case information
          for(Case c : [Select id, Accountid, Account.Customer_id__c, ContactId from Case Where Accountid != null and Accountid IN:accountIdList]){
              c.AccountId = nonExistingAccount.id;
              if(!String.isBlank(c.ContactId)){
                c.ContactId = nonExistingContact.id;
              }
              c.Mark_Deleted__c = true;
              c.Mark_Deleted_Date__c = Date.valueof(System.Today());
              // Rancho_PI110_20230705 - set current datetime, will bypass validation rule if this field > (now - 5 seconds)
              c.Bypass_Validation_Datetime__c = System.now();
              caseList.add(c);
          }

          // system.debug('transferCaseBeforeDelete CaseList: ' + caseList);
    
          if(caseList != null && caseList.size()>0){
              update caseList;
          }
          
          //get related policy transaction information
          For(Policy_Transaction__c pt : [Select id, Account__c from Policy_Transaction__c Where Account__c != null and Account__c IN:accountIdList]){
              pt.Account__c = nonExistingAccount.id;
              ptList.add(pt);
          }
          // system.debug('transferCaseBeforeDelete ptList: ' + ptList);
    
          if(ptList != null && ptList.size()>0){
              update ptList;
          }
           
       } catch(Exception e) {
           if(String.isNotBlank(errorMsg)){
                errorMsg = errorMsg +'<br/>'+ 'Fail to transfer related data when trying to delete accounts:'+e.getMessage();
            }else{
                errorMsg = 'Fail to transfer related data when trying to delete accounts:'+e.getMessage();
            }
            return -1;
       } 

       return 1;
       
   }

    /********************************************************************************
     * Batch apex class standard finish method.
     ********************************************************************************/
    global void finish(Database.BatchableContext BC){
       //send email
       // System.debug('Job Complete, sendEmailFlag='+sendEmailFlag);
       //if (sendEmailFlag) {
           //send email to account for split case
           /*
           system.debug('splitMap.size()='+splitMap.size());
           if(splitMap.size()>0){
               for(Account acc : splitMap.values()){
                   system.debug('[send email for split] acc.SSN__c='+acc.SSN__c+',acc.Email__c='+acc.Email__c);
                   if(String.isNotBlank(acc.Email__c)){
                       Boolean isSuccess =  this.sendEmail('Split Case Email',acc.Email__c,null,acc.Id);                                      
                   }
               }
           }
           //send email to account for merge case
           system.debug('mergeMap.size()='+mergeMap.size());
           if(mergeMap.size()>0){
               for(Account acc : mergeMap.values()){
                   system.debug('[send email for merge] acc.SSN__c='+acc.SSN__c+',acc.Email__c='+acc.Email__c);
                   if(String.isNotBlank(acc.Email__c)){                 
                       Boolean isSuccess =  this.sendEmail('Merge Case Email',acc.Email__c, null,acc.Id);                                           
                   }
               }
           }
           */
           //send email to Cigna IT for Job Completed         
           Update_Customer_Setting__c defaultSetting =  Update_Customer_Setting__c.getValues('Default');
           String emailTemplateName = 'Update Customer Information Email';
           String emailAddress = defaultSetting != null ? defaultSetting.Email_Address__c : null;           
           Boolean isSuccess =  this.sendEmail(emailTemplateName,emailAddress,null,null);
           // System.debug('isSuccess: ' + isSuccess);      
        //}
   }
   
   /********************************************************************************
    * Method to send email after batch job completed and when sendEmailFlag is true.
    ********************************************************************************/
   private Boolean sendEmail(String emailTemplateName,String emailAddr, String emailTitle,String objectId) {
        // System.debug('[sendEmail] emailAddr: ' + emailAddr);
        EmailTemplate emailTemplate = [Select id, subject, HtmlValue, Body FROM EmailTemplate WHERE name = :emailTemplateName limit 1];      
        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.id,UserInfo.getUserId(),null);
        String body = email.getHTMLBody();        
        DateTime currentTime = Datetime.now();
        String currentTimeStr = currentTime.format('yyyy-MM-dd HH:mm:ss');
        String detailLink = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ objectId;
        
        String toEmailAddr  = '';
        String ccEmailAddr = '';
        if(emailAddr != null && emailAddr.contains(';')){
            String[] emailAddresses = emailAddr.split(';');
            toEmailAddr = emailAddresses[0];
            ccEmailAddr = emailAddresses[1];
        }else{
            toEmailAddr = emailAddr;
        }
       
        //body = body.replace('###URL###', '');
        body = body.replace('###sendDate###', currentTimeStr);
        body = body.replace('###batchNo###', String.valueof(batchNo));
        body = body.replace('###totalbatchNo###', String.valueOf(totalbatchNo));
        if(String.isNotBlank(informationMsg)){
          body = body.replace('###informationMsg###', 'Merge/Delete account information as below: ' + '<br/>' + informationMsg);
        }else{
          body = body.replace('###informationMsg###', '');
        }
        
        if(String.isNotBlank(errorMsg)){
            body = body.replace('###errorMsg###', Label.Update_Customer_Job_has_Error + '<br/>' + errorMsg);
        }else{
            body = body.replace('###errorMsg###', Label.Update_Customer_Job_successfully);
        }

        HttpCalloutVO.EmailRequest param = new HttpCalloutVO.EmailRequest();
        param.MailTo = toEmailAddr;
        param.MailCC = ccEmailAddr;
        param.MailTitle = String.isBlank(emailTitle) ? emailTemplate.subject : emailTitle ;
        param.MailBody = '<![CDATA[' + body + ']]>';
        param.SecureMailInd = true;
        EmailCalloutHelper helper = new EmailCalloutHelper();
        if(!test.isrunningtest()){
            return helper.sendEmail(param);
        }else{
            return false;
        }
    }    
    
    
    //for calcaulate account age
    public static Integer calculateAge(Date d){
        
        // Leap Year handling
        Date d1 = Date.newInstance(2000, d.month(), d.day());
        Date d2 = Date.newInstance(2000, Date.today().month(), Date.today().day());
        if(d1 <= d2){
          return Date.today().year() - d.year();
        }else{
          return Math.max(Date.today().year() - d.year() - 1, 0);
        }
    }
    
}