global without sharing class TMCallCenterUtility{
    public static final string TM_DFT_CALL_RC = 'TM_Call';

    webService static String getAspectTMRecordType(){
        List< RecordType> rcList = [select id from RecordType where developerName = :TM_DFT_CALL_RC];
        if(rcList.size()>0){
            return rcList[0].id;
        }else{
            return null;
        }        
    }

    webService static String updateOpportunityOwner(string OpportunityID){
        String oppid = OpportunityID;
        string uid = UserInfo.getUserId();
        string ret = 'OK';
        List<Opportunity> oppList = [select id,ownerid from Opportunity where id = :oppid];
        try{
            if(oppList.size()>0){
                Opportunity opp = oppList[0];
                opp.ownerid = uid;
                update opp;
            }else{
                ret = 'Opportunity not found';
            }
        }catch(Exception e){
            ret = e.getMessage();
        }
        return ret;     
    }

    webService static String UpdatePaymentInformation(String opportunityId,String paymentType, String paymentAccountNo){

        String ret = 'Success';
        String oppid = opportunityId;
        try{
            Set<String> types = new Set<String>();
            Schema.DescribeFieldResult paymentTypeDesc = Bank_Account__c.Payment_Type__c.getDescribe();
            List<Schema.PicklistEntry> picklistOfPaymentType = paymentTypeDesc.getPicklistValues();
            for(Schema.PicklistEntry entry : picklistOfPaymentType){
                types.add(entry.getValue());
            }

            if(String.isBlank(oppid)){
                ret = 'opportunityId is empty';
                return ret;
            }

            List<Opportunity> Opp = [SELECT Id,Ownerid FROM Opportunity WHERE Id=:opportunityId];
            if(Opp.size() > 0){
            
            }else{
                ret = 'OpportunityId is Invalid ' + opportunityId;
                return ret;
            }

            if(String.isBlank(paymentType)){
                ret = 'paymentType is empty';
                return ret;
            }else{
                if(!types.contains(paymentType)){
                    ret = 'Invalid PaymentType ' + paymentType;
                    return ret;
                }
            }

            if(String.isBlank(paymentAccountNo)){
                ret = 'paymentAccountNo is empty';
                return ret;
            }

            Bank_Account__c bankAcc = new Bank_Account__c();
            bankAcc.OwnerId = Opp[0].OwnerId;
            bankAcc.Payment_Type__c = paymentType;
            if(paymentType == 'Bank'){
                bankAcc.Bank_Account_No__c = paymentAccountNo;
            }

            if(paymentType == 'Credit_Card'){
                bankAcc.Credit_Card_No__c = paymentAccountNo;
            }
            bankAcc.Opportunity__c = oppid;

            insert bankAcc;

        }catch(Exception e){
            ret = e.getMessage();
        }
        return ret;
    }
    // Rancho_CallCenterUCID_20210618
    // webService static String getCallResultTermCode(string OpportunityID, string callStartTime, string callEndTime, string Duration, string ANI, string DNIS, String ServiceID, String RecordSeq, String UCID){
    webService static String getCallResultTermCode(string OpportunityID, string callStartTime, string callEndTime, string Duration, string ANI, string DNIS, String ServiceID, String RecordSeq){
        System.debug('getCallResultTermCode start');
        System.debug('OpportunityID:'+OpportunityID);
        System.debug('callStartTime:'+callStartTime);
        System.debug('callEndTime:'+callEndTime);
        System.debug('Duration:'+Duration);
        System.debug('ANI:'+ANI);
        System.debug('DNIS:'+DNIS);
        System.debug('ServiceID:'+ServiceID);
        System.debug('RecordSeq:'+RecordSeq);
        CignaUtil.createCheckingLog('getCallResultTermCode','currentUser:'+UserInfo.getUserId()+' OpportunityID:'+OpportunityID+' callStartTime:'+callStartTime+' callEndTime:'+callEndTime+' Duration:'+Duration+' ANI:'+ANI+' DNIS:'+DNIS+' ServiceID:'+ServiceID+' RecordSeq:'+RecordSeq,'','','');
        string ret = '';
        String oppid = OpportunityID;
        string starttime = EncodingUtil.urlDecode(callStartTime.trim(), 'UTF-8');
        string endtime = EncodingUtil.urlDecode(callEndTime.trim(), 'UTF-8');        
        try{
            Datetime dt_start =null;
            Datetime dt_end = null;
            if(starttime.length()<10){
                return ret;
            }else{
                dt_start =getDatetimeYYYYMMDDHHMISS(starttime);
                if(endtime.length()<10){
                    if(integer.valueof(Duration)>0){
                        dt_end =dt_start.addSeconds(integer.valueof(Duration));
                    }else{
                        dt_end = dt_start;
                    } 
                }else{
                    dt_end = getDatetimeYYYYMMDDHHMISS(endtime);
                }
            }
            System.debug('dt_start:'+dt_start);
            System.debug('dt_end:'+dt_end);
            CignaUtil.createCheckingLog('getCallResultTermCode','dt_start:'+dt_start+' dt_end:'+dt_end,'','','');
	        // Rancho_CallCenterUCID_20210618
            List<Task> tList = [select id,result__c ,call_start_time__c, call_end_time__c, callDurationInseconds, ani__c, dnis__c, service_id__c, record_seq__c, UCID__c
                 from Task where whatid = :oppid and createddate>=:dt_start and recordType.developerName = :TM_DFT_CALL_RC order by createddate desc]; //Nicole_Speech_20210527
            // Rancho_CallCenter_20210602 regard OpportunityID as task id if tList is empty
            if(tList.isEmpty()){
                tList = [select id,result__c ,call_start_time__c, call_end_time__c, callDurationInseconds, ani__c, dnis__c, service_id__c, record_seq__c, UCID__c
                 from Task where Id = :oppid and createddate>=:dt_start and recordType.developerName = :TM_DFT_CALL_RC order by createddate desc];
            }
            CignaUtil.createCheckingLog('getCallResultTermCode','tList:'+tList.size(),'','','');
            if(tList.size()>0){
                Task call = tList[0];
                call.call_start_time__c=dt_start;
                call.call_end_time__c = dt_end;
                call.service_id__c  = serviceID;
                System.debug('integer.valueof(Duration):'+integer.valueof(Duration));
                call.callDurationInseconds = integer.valueof(Duration);
                if(String.isNotBlank(ANI)){
                    call.ANI__c = ANI;
                }
                if(String.isNotBlank(DNIS)){
                    call.dnis__c = DNIS;
                }
                call.record_seq__c = RecordSeq;
                // Rancho_ClickToDial_20210923: do not overwrite UCID if it is not blank
                // call.UCID__c = UCID;// Rancho_CallCenterUCID_20210618
                if(String.isBlank(call.UCID__c)){/* add by Jack on 2021-09-20 for project: SA Auto Click POC */
                    call.UCID__c = RecordSeq;
                }
                System.debug('call:'+call);
                CignaUtil.createCheckingLog('getCallResultTermCode','call:'+String.valueOf(call),'','','');
                update call;
                System.debug('all.Id:'+call.Id);
                System.debug('all.result__c:'+call.result__c);
                CignaUtil.createCheckingLog('getCallResultTermCode','all.result__c:'+call.result__c,'','','');
                if(string.isNotBlank(call.result__c)){
                    string r = call.result__c;
                    r = r.split('-')[0].trim();
                    ret = r;
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage()); 
            ret = e.getMessage() + ' ' +e.getStackTraceString();
            System.debug('e.getStackTraceString()'+e.getStackTraceString());
            CignaUtil.createCheckingLog('getCallResultTermCode','',e.getStackTraceString(),e.getMessage(),'');
        }
        return ret;       
    }

    public static Datetime getDatetimeYYYYMMDDHHMISS(STRING input){
        if(input.contains('-')){
            return Datetime.newInstance(
            integer.valueof (input.substring(0, 4)),
            integer.valueof (input.substring(5, 7)),
            integer.valueof (input.substring(8, 10)),
            integer.valueof (input.substring(11, 13)),
            integer.valueof (input.substring(14, 16)),
            integer.valueof (input.substring(17, 19)) );

        }else{
            return Datetime.newInstance(
                integer.valueof (input.substring(0, 4)),
                integer.valueof (input.substring(4, 6)),
                integer.valueof (input.substring(6, 8)),
                integer.valueof (input.substring(8, 10)),
                integer.valueof (input.substring(10, 12)),
                integer.valueof (input.substring(12, 14)) );
        }
    }
}