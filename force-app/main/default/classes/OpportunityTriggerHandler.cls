/********************************************************************************
 * Apex Class Name - OpportunityTriggerHandler
 * Version - 1.0
 * Created Date - Nov 14, 2017
 *  
 * @description Trigger Handler for Opportunityt
 * 
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Daft            14/11/2017              Original Version
 * 2.0       Franco          13/12/2017              Add logics, Reconsitution
 * 3.0       Jinni Liang     26/02/2020              JR1817 - Add auto-assignment logic
 * 4.0       Jinni Liang     15/06/2020              JR1828 - Add initial team leader name for reporting
 * 5.0     Jinni Liang     30/09/2020         JR1861 - Calculate actual occupied percentage in current day of each DTC team leader by transaction status
 ********************************************************************************/
public without sharing class OpportunityTriggerHandler{
    
    public final static String RECORD_TYPE_TM_OPP = 'TM_Opportunity';
    //public final static String RECORD_TYPE_INBOUND = 'Inbound';
    //public final static String RECORD_TYPE_OUTBOUND = 'Outbound';
    
    public static Boolean isBDUser = false;
    public static Map<String, String> SHORT_TYPE_MAP = new Map<String, String>{
        'New Business' => 'NB',
        'Renewal' => 'RN',
        '' => '',
        null => ''
    };
    
    public static Map<String, String> recordTypeMap = new Map<String, String>();
    
    static{
        for(RecordType rt : [select Id, Name, developerName from RecordType where sobjectType = 'Opportunity']){
            recordTypeMap.put(rt.Id, rt.developerName);
            recordTypeMap.put(rt.developerName, rt.Id);
        }
        isBDUser = CignaUtil.isBDUser();
    }

    //JR1817 - Auto assignment - Start
    public final static String DTC_TMR_PROFILE_ID;
    static{
        List<profile> profileList = ([SELECT id FROM Profile WHERE Name = 'TM DTC TMR' Limit 1]);
        DTC_TMR_PROFILE_ID = profileList[0].Id;
    }
    Public static String DTC_LEADER_PROFILE_ID;
    static{
        List<profile> profileList = ([SELECT id FROM Profile WHERE Name = 'TM DTC Leader' Limit 1]);
        DTC_LEADER_PROFILE_ID = profileList[0].Id;
    }
    
    Public static List<String> TM_BACKOFFICE_PROFIEL_ID_LIST = new List<String>();
    static{
        List<profile> tmBackOfficeProfileList = ([SELECT id FROM Profile WHERE Name IN ('TM Management','TM Back office')]);
        for(Profile pro : tmBackOfficeProfileList){
            TM_BACKOFFICE_PROFIEL_ID_LIST.add(pro.id);
        }
    }  
    //JR1817 - End
    public final static String NO_SUCH_PRODUCT = 'N/A';//GL31 jack add
    
    private static string traceStr = '';
    public static Integer updateTriggerCount=0;/* add by Jack on 2021-11-12 for project: allow Opportunity Change account */
       
    public static void onBeforeInsert(List<Opportunity> newList){
        if(isBDUser){
            OpportunityTriggerHandler.autoPopulateClientManager(newList);
        }
        
        List<Opportunity> tmOppList = new List<Opportunity>();
        for(Opportunity o : newList){
            if(recordTypeMap.get(o.recordTypeId) == RECORD_TYPE_TM_OPP){
                
                tmOppList.add(O);
            }
        }
        if(!tmOppList.isEmpty()){
            try{
                OpportunityTriggerHandler.autoPopulateOpptyName(tmOppList);
                OpportunityTriggerHandler.updateDNISinfo(tmOppList);
                OpportunityTriggerHandler.checkReferralOpptyRelation(tmOppList);
                OpportunityTriggerHandler.updateIsUnSuccessField(tmOppList);
                OpportunityTriggerHandler.autoPopulateOpptyAssignDate(null, tmOppList);
                OpportunityTriggerHandler.autoPopulateProspectId(tmOppList);
                OpportunityTriggerHandler.autoPopulateIQIDrunningNo(tmOppList);
                OpportunityTriggerHandler.transferPrimaryCampaign(tmOppList);
                //JR1801
                OpportunityTriggerHandler.populateCampaignTypeFieldForOppty(tmOppList);
                //JR1801
                OpportunityTriggerHandler.autoUpdateIsGAInd(tmOppList);//Wellness CI GA sys approach
                //JR1817 - Start
                OpportunityTriggerHandler.dtcOpptyAssignment(tmOppList);
                //JR1817 - End
                OpportunityTriggerHandler.autoPopulateAvailableProduct(null, tmOppList);//GL31 jack add
            }catch(Exception e){
                Checking_Log__c clog = new Checking_Log__c();
                clog.Function_Name__c = 'OpportunityTriggerHandler.onBeforeInsert';
                //clog.ErrorMessage__c = e.getMessage();
                clog.ErrorMessage_Long__c = e.getMessage();
                clog.TmpString1__c = String.valueOf(e.getLineNumber());
                clog.TmpString2__c = e.getStackTraceString();
                clog.TmpString3__c = traceStr;
                clog.UserInfo_String__c = userInfo.getUserId();
                insert clog;
            }
        }
    }
    
    public static void onAfterInsert(List<Opportunity> newList){
        List<Opportunity> tmOppList = new List<Opportunity>();
        List<Id> tmOppIdList = new List<Id>();
        for(Opportunity o : newList){
            if(recordTypeMap.get(o.recordTypeId) == RECORD_TYPE_TM_OPP){
                tmOppList.add(O);
                tmOppIdList.add(o.id);
            }
        }
        if(!tmOppList.isEmpty()){
            List<Opportunity> toUpdateOppList = [select Id, Name, AccountId, Opportunity_ID__c, Batch_No__c, Account.PersonMobilePhone, Account.PersonHomePhone,Mobile_Phone_2__c, Home_Phone_2__c, Office_Phone_2__c, Account.Office_Phone__c, Prospect_Id__c
                from Opportunity where id in :newList];
            
            try{
                OpportunityTriggerHandler.autoUpdateBatchNo(toUpdateOppList);
                OpportunityTriggerHandler.patchProspectId(toUpdateOppList);
                //JL20200226 OpportunityTriggerHandler.autoUpdatePhoneNo(toUpdateOppList);
                update toUpdateOppList;
                //OpportunityTriggerHandler.manualSharingAccount(null, tmOppList);
                if(!Test.isRunningTest()){
                    //String jobId = System.enqueueJob(new TMManualShareAccountQueue(tmOppIdList));
                    OpportunityTriggerHandler.manualShareAccountAfterCreate(tmOppIdList);
                }
            }catch(Exception e){
                Checking_Log__c clog = new Checking_Log__c();
                clog.Function_Name__c = 'OpportunityTriggerHandler.onAfterInsert';
                //clog.ErrorMessage__c = e.getMessage();
                clog.ErrorMessage_Long__c = e.getMessage();
                clog.TmpString1__c = String.valueOf(e.getLineNumber());
                clog.TmpString2__c = e.getStackTraceString();
                clog.UserInfo_String__c = userInfo.getUserId();
                insert clog;
            }
        }
    }
    
    /*
     * Handle the logic for before update
     */
    public static void onBeforeUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap, List<Opportunity> newList){
        system.debug('onBeforeUpdate');
        updateTriggerCount++;/* add by Jack on 2021-11-12 for project: allow Opportunity Change account */
        if(isBDUser){
            for(Opportunity newOpp : newList){
                // If Commission Type is Fee, will be the same as the fee inputted;
                // if Commission Type is Percentage, will be Amount in USD * Broker Commission (%)
                if(newOpp.Commission_Type__c == 'Percentage' && newOpp.Broker_Commission__c != null && newOpp.Amount_in_USD__c != null){
                   newOpp.Broker_Commission_Fee__c = (newOpp.Broker_Commission__c * newOpp.Amount_in_USD__c) / 100;
                }
                // This field will be auto-populated as 'Cigna' if the stage is changed to Closed Won
                if(newOpp.StageName == 'Closed Won'){
                    newOpp.Winning_Carrier__c = 'Cigna';
                }
            }
        }
        
        // TM
        List<Opportunity> tmOppList = new List<Opportunity>();
        Map<String,DNIS__c> numDnisMap = new Map<String,DNIS__c>();
        for(Opportunity o : newList){
            if(recordTypeMap.get(o.recordTypeId) == RECORD_TYPE_TM_OPP){
                tmOppList.add(O);
                
            }
        }
        if(!tmOppList.isEmpty()){
            try{
                if(updateTriggerCount==1){/* add by Jack on 2021-11-12 for project: allow Opportunity Change account */
                    OpportunityTriggerHandler.blockChangeOpptyName(oldMap, tmOppList);
                }
                OpportunityTriggerHandler.checkReferralOpptyRelation(tmOppList);
                OpportunityTriggerHandler.updateIsUnSuccessField(tmOppList);
                OpportunityTriggerHandler.autoPopulateOpptyName(tmOppList);
                OpportunityTriggerHandler.autoUpdateBatchNo(tmOppList);
                OpportunityTriggerHandler.updateOwner(tmOppList);
                OpportunityTriggerHandler.autoPopulateOpptyAssignDate(oldMap, tmOppList);
                OpportunityTriggerHandler.updateDNISinfo(tmOppList);
                OpportunityTriggerHandler.checkIsSideOrderOppty(tmOppList);
                OpportunityTriggerHandler.updateOpptyCloseDate(tmOppList);
                OpportunityTriggerHandler.transferPrimaryCampaign(tmOppList);
                //JR1801
                OpportunityTriggerHandler.populateCampaignTypeFieldForOppty(tmOppList);
                //JR1801
                OpportunityTriggerHandler.UpdateTermCodeHistory(tmOppList,newList);//jack add for JR1821
                OpportunityTriggerHandler.autoPopulateAvailableProduct(oldMap, tmOppList);//GL31 jack add
            }catch(Exception e){
                Checking_Log__c clog = new Checking_Log__c();
                clog.Function_Name__c = 'OpportunityTriggerHandler.onBeforeUpdate';
                //clog.ErrorMessage__c = e.getMessage();
                clog.ErrorMessage_Long__c = e.getMessage();
                clog.TmpString1__c = String.valueOf(e.getLineNumber());
                clog.TmpString2__c = e.getStackTraceString();
                clog.TmpString3__c = traceStr;
                clog.UserInfo_String__c = userInfo.getUserId();
                insert clog;
            }
        }
    }
    
    public static void onAfterUpdate(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        if(isBDUser){
            OpportunityTriggerHandler.autoCreateRenewalOpportunity(oldMap, newList);
        }
        
        List<Opportunity> tmOppList = new List<Opportunity>();
        //Prepare data for manualShareAccountAfterUpdate future method
        List<Id> tmOppIdList = new List<Id>();
        Map<Id,Id> oppIdOldOwnerIdMap = new Map<Id,Id>();
        Map<Id,Id> oppIdOldAccIdMap = new Map<Id,Id>();
        
        for(Opportunity o : newList){
            if(recordTypeMap.get(o.recordTypeId) == RECORD_TYPE_TM_OPP){
                tmOppList.add(O);
                
                //Prepare data for manualShareAccountAfterUpdate future method
                tmOppIdList.add(o.id);
                oppIdOldOwnerIdMap.put(o.id, oldMap.get(o.id).ownerId);
                oppIdOldAccIdMap.put(o.id, oldMap.get(o.id).accountId);
            }
        }
        
        if(!tmOppList.isEmpty()){
            try{
                OpportunityTriggerHandler.transferPolicyOwnerWithOppty(oldMap, newList);
                
                //String jobId = System.enqueueJob(new TMManualShareAccountQueue(oppIdOldOwnerIdMap, oppIdOldAccIdMap, tmOppIdList));
                OpportunityTriggerHandler.manualShareAccountAfterUpdate(oppIdOldOwnerIdMap, oppIdOldAccIdMap, tmOppIdList,oldMap);
                //OpportunityTriggerHandler.manualSharingAccount(oldMap, newList);
                OpportunityTriggerHandler.autoCompletePortableReferPolicy(oldMap, newList);
                OpportunityTriggerHandler.newSARecd(tmOppIdList);// Rancho_SpeechAnalytics_20210607
            }catch(Exception e){
                Checking_Log__c clog = new Checking_Log__c();
                clog.Function_Name__c = 'OpportunityTriggerHandler.onAfterUpdate';
                //clog.ErrorMessage__c = e.getMessage();
                clog.ErrorMessage_Long__c = e.getMessage();
                clog.TmpString1__c = String.valueOf(e.getLineNumber());
                clog.TmpString2__c = e.getStackTraceString();
                clog.UserInfo_String__c = userInfo.getUserId();
                insert clog;
            }
        }
    }
    
    /*
     * Client Manager field will be auto-populated with the Opportunity Account's Account Manager upon creation
     */
    public static void autoPopulateClientManager(List<Opportunity> newList){    
        List<Id> accountId = new List<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Opportunity opp : newList){
            accountId.add(opp.accountId);
        }
        accountMap = new Map<Id,Account>([select id, Name, Account_Manager__c from account where id in :accountId ]);
        for(Opportunity opp : newlist){
            // Opportunity name format: [ACCOUNT NAME]-NB-[YEAR] (NB: new business) or [ACCOUNT NAME]-R-[YEAR] (R: renewal)
            // NB/R is determined by value in the Type field. Year is determined by Effective Date in YYYY format
            //if(accountMap.get(opp.accountId) != null && opp.Effective_Date__c != null && opp.Name == '*DO NOT MODIFY*'){
            if(accountMap.get(opp.accountId) != null && opp.Effective_Date__c != null){
                opp.Name = accountMap.get(opp.accountId).Name + '-' + SHORT_TYPE_MAP.get(opp.Type) + '-' + opp.Effective_Date__c.year();
            }
            // Client Manager field will be auto-populated with the Opportunity Account's Account Manager upon creation
            if(accountMap.get(opp.accountId) != null && accountMap.get(opp.accountId).Account_Manager__c != null){
                opp.Client_Manager__c = accountMap.get(opp.accountId).Account_Manager__c;
            }
            // This field will be auto-populated as 'Cigna' if the stage is changed to Closed Won
            if(opp.StageName == 'Closed Won'){
                opp.Winning_Carrier__c = 'Cigna';
            }
        }
    }
    
    /*
     * For group opportunities, if 'Automatically create a Renewal?' is checked,
     * then when the opportunity is Closed Won, a Renewal Opportunity will be created automatically
     */
    public static void autoCreateRenewalOpportunity(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        System.debug('[autoCreateRenewalOpportunity] oldMap=' + oldMap);
        System.debug('[autoCreateRenewalOpportunity] newList=' + newList);
        List<Id> accountId = new List<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Opportunity opp : newList){
            accountId.add(opp.accountId);
        }
        accountMap = new Map<Id,Account>([select id, Name, Account_Manager__c from account where id in :accountId ]);
        Map<Id, Opportunity> renewalOppMap = new Map<Id, Opportunity>();
        for(Opportunity newOpp: newList){
            System.debug('[autoCreateRenewalOpportunity] newOpportunity='+newOpp);
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if(recordTypeMap.get(newOpp.recordtypeid) == 'Group_Opportunity'){
                boolean oldAutoCreateRenewal = oldOpp.Auto_Create_Renewal__c;
                boolean newAutoCreateRenewal = newOpp.Auto_Create_Renewal__c;
                String oldStageName = oldOpp.StageName;
                String newStageName = newOpp.StageName;
                if((!oldAutoCreateRenewal && newAutoCreateRenewal && newStageName == 'Closed Won') 
                        || (oldStageName != 'Closed Won' && newStageName == 'Closed Won' && newAutoCreateRenewal )){
                    Opportunity cloneOpp = newOpp.clone();
                    Date nCloseDate = newOpp.CloseDate;
                    Date nEffectiveDate = newOpp.Effective_Date__c;
                    Date nRenewalDate = newOpp.Renewal_Date__c;
                    cloneOpp.Type = 'Renewal';
                    cloneOpp.StageName = 'Renewal';
                    cloneOpp.CloseDate = nCloseDate != null ? nCloseDate.addYears(1) : null;
                    cloneOpp.Effective_Date__c = nEffectiveDate != null ? nEffectiveDate.addYears(1) : null;
                    cloneOpp.Renewal_Date__c = nRenewalDate != null ? nRenewalDate.addYears(1) : null;
                    cloneOpp.ownerid = newOpp.Client_Manager__c;                    
                    cloneOpp.Prior_year_opportnity__c = newOpp.Id;
                    cloneOpp.Campaign__c = newOpp.Campaign__c;
                    //cloneOpp.Campaign = newOpp.Campaign;
                    cloneOpp.Name = accountMap.get(cloneOpp.accountId).Name + '-' + SHORT_TYPE_MAP.get(cloneOpp.Type) + '-' + cloneOpp.Effective_Date__c.year();
                    system.debug('[autoCreateRenewalOpportunity] cloneOpportunity=' + cloneOpp);
                    renewalOppMap.put(newOpp.Id, cloneOpp);
                }
            }
        }
        
        //List<Opportunity.campaign> oppCamList = new List<Opportunity.campaign>();
        
        // insert the renewwal opportunity and their related list
        if(!renewalOppMap.isEmpty()){
            insert renewalOppMap.values();
            Set<Id> newOppIdSet = renewalOppMap.keySet();
            // 1. Task
            String taskSOQL = getSOQL('Task') + ' where whatid in :newOppIdSet';
            List<Task> cloneTaskList = new List<Task>();
            for(Task t : DataBase.query(taskSOQL)){
                Task cloneTask = t.clone();
                cloneTask.whatId = renewalOppMap.get(t.whatId).Id;
                cloneTaskList.add(cloneTask);
            }
            insert cloneTaskList;
            // Contact Roles
            String contactRoleSOQL = getSOQL('OpportunityContactRole') + ' where OpportunityId in :newOppIdSet';
            List<OpportunityContactRole> cloneContactRoleList = new List<OpportunityContactRole>();
            for(OpportunityContactRole cr : DataBase.query(contactRoleSOQL)){
                OpportunityContactRole cloneCR = cr.clone();
                cloneCR.OpportunityId = renewalOppMap.get(cr.OpportunityId).Id;
                cloneContactRoleList.add(cloneCR);
            }
            insert cloneContactRoleList;
            
            // Campaign Influence
            //  Error: Compile Error: Invalid type: CampaignInfluence at line 118 column 13 
            /*String campaignInfluenceSOQL = getSOQL('CampaignInfluence') + ' where OpportunityId in :newOppIdSet';
            List<CampaignInfluence> campaignInfluenceList = new List<CampaignInfluence>();
            for(CampaignInfluence cif : DataBase.query(campaignInfluenceSOQL)){
                CampaignInfluence cloneCIF = cif.clone();
                cloneCIF.OpportunityId = renewalOppMap.get(cif.OpportunityId).Id;
                campaignInfluenceList.add(cloneCIF);
            }
            insert campaignInfluenceList;*/
            
            //partners
            /*
            String partnerSOQL = getSOQL('Partner') + ' where OpportunityId in :newOppIdSet';
            List<Partner> clonePartnerList = new List<Partner>();
            for(Partner p : DataBase.query(partnerSOQL)){
                if(p.AccountToId != renewalOppMap.get(p.OpportunityId).AccountId){
                    Partner clonePartner = p.clone();
                    clonePartner.OpportunityId = renewalOppMap.get(p.OpportunityId).Id;
                    clonePartner.AccountFromId = null;
                    //clonePartner.AccountToId = null;
                    clonePartnerList.add(clonePartner);
                }
            }
            insert clonePartnerList;
            */
            
            //Notes & Attachments
            String noteSOQL = getSOQL('Note') + ' where ParentId in :newOppIdSet';
            List<Note> cloneNoteList = new List<Note>();
            for(Note n : DataBase.query(noteSOQL)){
                Note cloneNote = n.clone();
                cloneNote.ParentId = renewalOppMap.get(n.ParentId).Id;
                cloneNoteList.add(cloneNote);
            }
            insert cloneNoteList;
            
            String attachmentSOQL = getSOQL('Attachment') + ' where ParentId in :newOppIdSet';
            List<Attachment> cloneAttachmentList = new List<Attachment>();
            for(Attachment att : DataBase.query(attachmentSOQL)){
                Attachment cloneAtt = att.clone();
                cloneAtt.ParentId = renewalOppMap.get(att.ParentId).Id;
                cloneAttachmentList.add(cloneAtt);
            }
            insert cloneAttachmentList;
        }
    }
    
    public static String getSOQL(String objectName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<String> fieldList = new List<String>();
        for(String key : fieldMap.keySet()){
            Schema.DescribeFieldResult dfr = fieldMap.get(key).getDescribe();
            if(dfr.isCreateable()){
                fieldList.add(dfr.getName());
            }
        }
        String soql = 'select ' + String.join(fieldList, ',') + ' from ' + objectName + ' ';
        system.debug('>>> ' + soql);
        return soql;
    }
    
            
    public static void autoUpdateBatchNo(List<Opportunity> newList){
        for(Opportunity o : newList){
            o.Batch_No_for_global_search__c = o.Batch_No__c;
        }
    }
    
    public static void autoUpdatePhoneNo(List<Opportunity> newList){
        for(Opportunity o : newList){
            if(String.isNotBlank(o.Account.PersonMobilePhone) && String.isBlank(o.Mobile_Phone_2__c)){
                o.Mobile_Phone_2__c = o.Account.PersonMobilePhone;
            }
            if(String.isNotBlank(o.Account.PersonHomePhone) && String.isBlank(o.Home_Phone_2__c)){
                o.Home_Phone_2__c = o.Account.PersonHomePhone;
            }
            if(String.isNotBlank(o.Account.Office_Phone__c) && String.isBlank(o.Office_Phone_2__c)){
                o.Office_Phone_2__c = o.Account.Office_Phone__c;
            }
        }
    }
            
    public static void autoPopulateOpptyName(List<Opportunity> newList){
        List<Id> accountId = new List<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Opportunity o : newList){
            accountId.add(o.accountId);
        } 
        if(!accountId.isEmpty()){
            
            //JR1817 - Update the phone num to the opportunity accordingly
            //JR1817 accountMap = new Map<Id,Account>([select id, lastname,firstname,salutation,Gender__c  from account where id in :accountId ]);
            //JR1817 - Start
            accountMap = new Map<Id,Account>([select id, lastname,firstname,salutation,Gender__c, PersonMobilePhone, PersonHomePhone, Office_Phone__c  
                from account where id in :accountId ]);//JR1817
            //JR1817 - End
        }
        for(Opportunity o : newList){
            String Salutation = '';
            if(accountMap.get(o.accountId) != null){
                if(accountMap.get(o.accountId).Gender__c != null){
                    if(accountMap.get(o.accountId).Gender__c == 'Male'){
                        Salutation = 'Mr';
                    }else if(accountMap.get(o.accountId).Gender__c == 'Female'){
                        Salutation = 'Ms';
                    }
                }
                String acctLastName =  accountMap.get(o.accountId).lastname;
                String acctFirstName =  accountMap.get(o.accountId).firstname;
                if(acctFirstName == null){
                    acctFirstName = '';
                }
                if(!o.Name.startsWith('XXXXXX-')){ //for dummy oppty name, not to change the oppty name.
                    o.Name = Salutation + acctLastName + acctFirstName;
                    o.Name = o.Name.replace(' ','');
                }
                
                //JR1817 - Start
                if(String.isNotBlank(accountMap.get(o.AccountId).PersonMobilePhone) && String.isBlank(o.Mobile_Phone_2__c)){
                    o.Mobile_Phone_2__c = accountMap.get(o.AccountId).PersonMobilePhone;
                }
                if(String.isNotBlank(accountMap.get(o.AccountId).PersonHomePhone) && String.isBlank(o.Home_Phone_2__c)){
                    o.Home_Phone_2__c = accountMap.get(o.AccountId).PersonHomePhone;
                }
                if(String.isNotBlank(accountMap.get(o.AccountId).Office_Phone__c) && String.isBlank(o.Office_Phone_2__c)){
                    o.Office_Phone_2__c = accountMap.get(o.AccountId).Office_Phone__c;
                }
                system.debug('o.Mobile_Phone_2__c'+o.Mobile_Phone_2__c);
                //JR1817 - End
            }
        }
    }
    
    public static void updateOwner(List<Opportunity> newList){
        for(Opportunity o: newList){
            if(o.New_Owner__c != null && o.New_Owner__c != ''){
                o.ownerid = o.New_Owner__c;
                o.New_Owner__c = null;
                o.To_Be_Approved__c = null;
            }
        }
    }
    
    public static void autoPopulateProspectId(List<Opportunity> newList){
        TM_Campaign_Setting__c  campaignSetting = [select id, Prospect_Id_Running_No__c from TM_Campaign_Setting__c where Name = 'Default' for update];
        String prospectIdRunningNo = campaignSetting.Prospect_Id_Running_No__c;
        String yy = String.valueOf(Date.today().year()).right(2);
        for(Opportunity newOpp : newList){
            if(String.isBlank(newOpp.Prospect_Id__c)){
                String runningNo = generateProspectId(prospectIdRunningNo);
                newOpp.Prospect_Id__c = yy + runningNo;
                prospectIdRunningNo = runningNo;
            }
        }
        //release the locking TM_Campaign_Setting__c
        campaignSetting.Prospect_Id_Running_No__c = prospectIdRunningNo;
        update campaignSetting;
    }
    
    //get next running no
    public static String generateProspectId(String currentRunningNo){
        Integer nextRunningNo = Integer.valueOf(currentRunningNo) + 1;
        String runningNo = (String.valueOf(nextRunningNo)).leftPad(8, '0');
        return runningNo;
    }
    
    public static void autoPopulateOpptyAssignDate(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        Date today = Date.today();
        if(oldMap == null){
            // before insert
            for(Opportunity o : newList){
                o.assign_date__c = today;
                o.Last_Assigned_Date__c = today;
            }
        }else{
            // before update
            for(Opportunity o : newList){
                if(o.ownerId != oldMap.get(o.id).ownerId){
                    o.assign_date__c = today;
                    o.Last_Assigned_Date__c = oldMap.get(o.id).assign_date__c;
                }
            }
        }
    }

    public static void updateSPVID(Map<Id, Opportunity> oldMap,List<Opportunity> newList){
        Map<Id,User> ownerMap = new Map<Id,User>();
        List<Opportunity> updateList = new List<Opportunity>();
        Map<Id,Id> leaderMap = new Map<Id,Id>();
        for(Opportunity o : newList){
            if(oldMap == null || (oldMap.containsKey(o.Id) && oldMap.get(o.Id).OwnerId <> o.OwnerId)){
                ownerMap.put(o.OwnerId,null);
                updateList.add(o);
            }
        }
        if(ownerMap<>null && ownerMap.size()>0){
            ownerMap = new Map<Id,User>([select id, UserRoleId, UserRole.name, UserRole.ParentRoleId from User where id in: ownerMap.keySet()]);
        }
        for(User u : ownerMap.values()){
            if(u.UserRoleId <> null && u.UserRole.ParentRoleId<>null && !u.UserRole.Name.toLowerCase().contains('leader') && !u.UserRole.Name.toLowerCase().contains('manage')){
                leaderMap.put(u.UserRole.ParentRoleId,null);
            }
        }
        if(leaderMap<>null && leaderMap.size()>0){
            for(User leaderU : [select id, UserRoleId from User where IsActive =true and UserRoleId in:leaderMap.keySet()]){
                if(!leaderMap.containsKey(leaderU.UserRoleId)){
                    leaderMap.put(leaderU.UserRoleId, leaderU.Id);
                }
            }
        }
        for(Opportunity o1 : updateList){
            Boolean SPVisNotNull = (ownerMap.containsKey(o1.ownerId) && ownerMap.get(o1.OwnerId).UserRoleId<>null && ownerMap.get(o1.OwnerId).UserRole.ParentRoleId<>null && leaderMap.containsKey(ownerMap.get(o1.OwnerId).UserRole.ParentRoleId) && leaderMap.get(ownerMap.get(o1.OwnerId).UserRole.ParentRoleId) <> null);
            o1.TM_SPV_ID__c = (SPVisNotNull)?leaderMap.get(ownerMap.get(o1.OwnerId).UserRole.ParentRoleId):null;
        }
    }
    
    /**
     * unSuccess = true when term codes in ‘Unsuccess’ category 
     * Due to the error 'Compiled formula is too big to execute (5,627 characters). ' when use the formual
    */
    public static void updateIsUnSuccessField(List<Opportunity> newList){
        List<String> unSucessCodeList = new List<String>{'201','202','204','205','206','207', '209', '497', '499'};
        for(Opportunity opp : newList){
            if(String.isNotBlank(opp.Term_Code__c) && unSucessCodeList.contains(opp.Term_Code__c)){
                opp.Is_UnSuccess__c = true;
            }else{
                opp.Is_UnSuccess__c = false;
            }
        }
    }
    
    /**
     * For TM Opportunity, block the oppty creation/update if the Referral_Relationship__c is not empty but Referee_Opportunity__c is empty
    **/
    public static void checkReferralOpptyRelation(List<Opportunity> newList){
        for(Opportunity o : newList){
            if(o.Referee_Opportunity__c == null && o.Referral_Relationship__c != null){
                o.addError('Can not edit referral relationship if not referee opportunity case.');
                continue;
            }
        }
    }
    
    public static void updateDNISinfo(List<Opportunity> newList){
        List<String> hotlineNumberList = new List<String>();
        Map<String,DNIS__c> numDnisMap = new Map<String,DNIS__c>();
        for(Opportunity o : newList){
            if(o.Hotline_Number__c != null && o.Hotline_Number__c != ''){
                hotlineNumberList.add(o.Hotline_Number__c);
            }
        }
        if(hotlineNumberList != null && hotlineNumberList.size() > 0){
            List<DNIS__c> dnisInfo = [SELECT Avaya_VDN__c,Campaign_Code__c,Channel__c,Hotline_Type__c,TVC_version__c, Lead_Source__c,One_Call_Number__c,Product__c,Spot_Number__c, TD_hotline__c
                FROM DNIS__c WHERE Spot_Number__c in :hotlineNumberList];
                          
            for(DNIS__c dnis : dnisInfo){
                numDnisMap.put(dnis.Spot_Number__c,dnis);
            }
        }
        for(Opportunity o : newList){
            if(String.isNotBlank(o.Hotline_Number__c)){
                DNIS__c temp = numDnisMap.get(o.Hotline_Number__c);
                if(temp != null){
                    o.Hotline_Type__c = temp.Hotline_Type__c;//Hotline Type
                    o.TVC_version__c = temp.TVC_version__c;//TVC version
                    o.Avaya_VDN__c = temp.Avaya_VDN__c;//Avaya VDN
                    o.Spot_Number__c = temp.Spot_Number__c;//Spot Number
                    o.TD_hotline__c = temp.TD_hotline__c;//TD hotline
                    o.Lead_Source__c = temp.Lead_Source__c;//Lead Source
                    o.Hotline_Product__c = temp.Product__c;//Hotline Product
                    o.Hotline_Channel__c = temp.Channel__c;//Hotline Channel
                }else{
                    o.addError('Invalid Hotline Number');
                    continue;
                }
            }else{
                o.Hotline_Type__c = '';//Hotline Type
                o.TVC_version__c = '';//TVC version
                o.Avaya_VDN__c = '';//Avaya VDN
                o.Spot_Number__c = '';//Spot Number
                o.TD_hotline__c = '';//TD hotline
                o.Lead_Source__c = '';//Lead Source
                o.Hotline_Product__c = '';//Hotline Product
                o.Hotline_Channel__c = '';//Hotline Channel
            }
        }
    }
    
    public static void transferPrimaryCampaign(List<Opportunity> newList){
        for(Opportunity o : newList){
            if(o.Campaign__c != null){
                o.CampaignId = o.Campaign__c;
            }
        }
    }
    
    public static void blockChangeOpptyName(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        for(Opportunity o : newList){
            system.debug('OpportunityTriggerHandler blockChangeOpptyName o.name: '+o.name+' oldMap.get(o.id).name: '+oldMap.get(o.id).name);
            if(o.name != oldMap.get(o.id).name){
                System.debug('You have no permission to change Opportunity Name==========');
                o.addError('You have no permission to change Opportunity Name');
                continue;
            }
        }
    }
    
    public static void transferPolicyOwnerWithOppty(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        List<Id> oppIdList = new List<Id>();
        Map<Id,Id> oppOwnerIdMap = new Map<Id,Id>();
        for(Opportunity o : newList){
            if(o.ownerId != oldMap.get(o.id).ownerid){
                oppIdList.add(o.id);
                oppOwnerIdMap.put(o.id,o.ownerId);
            }
        }
        if(!oppIdList.isEmpty()){
            List<Policy_Transaction__c> policyList = [Select id,name,ownerid,owner.name,Opportunity__r.id from Policy_Transaction__c where Opportunity__r.id in :oppIdList];
            if(!policyList.isEmpty()){
                for(Policy_Transaction__c ptc : policyList){
                    ptc.ownerId = oppOwnerIdMap.get(ptc.Opportunity__r.id);
                }
                update policyList;
            }
        }
    }
    
    /*check if is side order case
    * the logic of side order for oppty -- Oppty is marked with side order only when:
    * 1.respective campaign type = BUL; and
    * 2.oppty is a referral case
    */
    public static void checkIsSideOrderOppty(List<Opportunity> newList){
        Map<Id,String> opptyIdCampaignTypeMap = new Map<Id,String>();
        List<Id> referralOpptyIdList = new List<Id>();
        for(Opportunity o : newList){
            if(o.Referee_Opportunity__c != null){
                referralOpptyIdList.add(o.id);
            }
        }
        if(!referralOpptyIdList.isEmpty()){
            List<Opportunity> referralOpptyList = [Select id,name,campaign__r.Campaign_Type__r.Name from Opportunity where id in :referralOpptyIdList];
            for(Opportunity o : referralOpptyList){
                opptyIdCampaignTypeMap.put(o.id,o.campaign__r.Campaign_Type__r.Name);
            }
            
            for(Opportunity o : newList){
                if(opptyIdCampaignTypeMap.get(o.id) == 'BUL'){
                    o.Is_Side_Order__c = true;
                }
            }
        }
    }
    
    //Block update oppty close date
    public static void updateOpptyCloseDate(List<Opportunity> newList){
        List<Id> opptyIdList = new List<Id>();
        Map<Id,Date> oppIdCampaignEndDateMap = new Map<Id,Date>();
        
        for(Opportunity o : newList){
            opptyIdList.add(o.id);
        }
        
        if(!opptyIdList.isEmpty()){
            List<Opportunity> oppList = [Select id,name,CloseDate,Campaign__r.Expiry_Date__c from Opportunity where id in :opptyIdList];
            for(Opportunity o : oppList){
                oppIdCampaignEndDateMap.put(o.id,o.Campaign__r.Expiry_Date__c);
            }
        }
        
        for(Opportunity o : newList){
            o.CloseDate = oppIdCampaignEndDateMap.get(o.id);
        }
    }
    
    
    //after insert
    //@future
    public static void manualShareAccountAfterCreate(List<Id> newIdList){
        system.debug('manualShareAccountAfterCreate');
        List<Opportunity> newList = [Select id,name,accountId,ownerId from Opportunity where id in :newIdList];
        
        List<AccountShare> asList = new List<AccountShare>();
        for(Opportunity o : newList){
            //if(!o.Is_Dummy_TM_opportunity__c){
                AccountShare newAs = new AccountShare(AccountId = o.accountId,
                                                          UserOrGroupId = o.ownerId,
                                                          AccountAccessLevel = 'Edit',
                                                          OpportunityAccessLevel = 'None',
                                                          RowCause = 'Manual'
                                                          );
                asList.add(newAs);
            //}
        }
        
        try{
            Database.SaveResult[] srList = Database.insert(asList, false);
        }catch(Exception e){
        }
    }
    
    /*
    * DPSP-553
    */
    
    //@future
    public static void manualShareAccountAfterUpdate(Map<Id,Id> oppIdOldOwnerIdMap, Map<Id,Id> oppIdOldAccIdMap, List<Id> newIdList, Map<Id,Opportunity> oldMap){
        system.debug('manualShareAccountAfterUpdate');
        List<Opportunity> changeOwnerOppList = new List<Opportunity>();
        List<Id> oldOwnerIdList = new List<Id>();  //
        List<Id> newOwnerIdList = new List<Id>();
        List<Id> oldAccountIdList = new List<Id>();
        
        List<AccountShare> oldOwnerAsList = new List<AccountShare>();
        List<AccountShare> oldOwnerAsAfterDeleteList = new List<AccountShare>();
        List<AccountShare> newOwnerAsList = new List<AccountShare>();
        
        List<Opportunity> newList = [Select id,name,accountId,ownerId from Opportunity where id in :newIdList];
        
        for(Opportunity o : newList){
            if((o.ownerId != oppIdOldOwnerIdMap.get(o.id)) || (o.accountId != oldMap.get(o.id).accountId )){
                changeOwnerOppList.add(o);
                oldOwnerIdList.add(oppIdOldOwnerIdMap.get(o.id));
                newOwnerIdList.add(o.ownerId);
                oldAccountIdList.add(oldMap.get(o.id).accountId);
            }
        }
        
        if(!changeOwnerOppList.isEmpty()){
            system.debug('point A');
            oldOwnerAsList = [Select id from AccountShare where UserOrGroupId in :oldOwnerIdList and accountId in :oldAccountIdList and RowCause = 'Manual'];
            try{
                //Database.DeleteResult[] drList = Database.delete(oldOwnerAsList, false);
                delete oldOwnerAsList;
            }catch(Exception e){
            }
            system.debug('point B');
            
            List<Opportunity> oldOwnerOppList = [Select id,name,accountid,ownerId from Opportunity 
                                            where Is_Dummy_TM_opportunity__c = false and ownerid in :oldOwnerIdList and accountId in :oldAccountIdList];
            if(!oldOwnerOppList.isEmpty()){
                system.debug('point C');
                for(Opportunity o : oldOwnerOppList){
                    AccountShare newAs = new AccountShare(AccountId = o.accountId,
                                                          UserOrGroupId = o.ownerId,
                                                          AccountAccessLevel = 'Edit',
                                                          OpportunityAccessLevel = 'None',
                                                          RowCause = 'Manual'
                                                          );
                    
                    oldOwnerAsAfterDeleteList.add(newAs);
                }
                try{
                    Database.SaveResult[] srList = Database.insert(oldOwnerAsAfterDeleteList, false);
                }catch(Exception e){
                }
                system.debug('point D');
            }
            
            system.debug('point E');
            for(Opportunity o : changeOwnerOppList){
                AccountShare newAs = new AccountShare(AccountId = o.accountId,
                                                          UserOrGroupId = o.ownerId,
                                                          AccountAccessLevel = 'Edit',
                                                          OpportunityAccessLevel = 'None',
                                                          RowCause = 'Manual'
                                                          );
                newOwnerAsList.add(newAs);
            }
            try{
                Database.SaveResult[] srList = Database.insert(newOwnerAsList, false);
            }catch(Exception e){
            }
            system.debug('point F');
        }
    }
    
    /*
    * term code should only be added and 
    * (2) policy status should only be marked as "completed" when created opportunity is assigned to agent.
    */
    public static void autoCompletePortableReferPolicy(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        Map<Id,Opportunity> ownerIdOpptyMap = new Map<Id,Opportunity>();
        Map<String,Opportunity> ownerIdRunningNoOpptyMap = new Map<String,Opportunity>();
        Map<String,String> userIdAgentIdMap = new Map<String,String>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Id> opptyIdList = new List<Id>();
        for(Opportunity opp : newList){
            if((opp.Source_of_Activity__c == 'CPRefer' || opp.Source_of_Activity__c == 'STPRefer') && String.isBlank(opp.Result__c) && opp.ownerId != oldMap.get(opp.Id).ownerId ){
                ownerIdOpptyMap.put(opp.ownerId,opp);
                ownerIdRunningNoOpptyMap.put(opp.ownerId+opp.Running_No__c, opp);
            }
        }
        if(!ownerIdOpptyMap.isEmpty()){
            List<String> teamList = new List<String>();
            teamList.add('TM_Build_Team_TMR');
            teamList.add('TM_DTC_Sub_Team_1_TMR');
            teamList.add('TM_DTC_Sub_Team_2_TMR');
            
            List<User> tmrList = [Select id, name, TM_Agent_ID__c from User where userRole.developerName in :teamList and id in :ownerIdOpptyMap.keySet()];
            if(!tmrList.isEmpty()){
                //for(User u : tmrList){
                    //opptyList.add(ownerIdOpptyMap.get(u.Id));
                    //opptyIdList.add(ownerIdOpptyMap.get(u.Id).Id);
                //}

                for(User u: tmrList){
                    for(String key : ownerIdRunningNoOpptyMap.keySet()){
                        if(key.contains(u.Id)){
                            opptyList.add(ownerIdRunningNoOpptyMap.get(key));
                            opptyIdList.add(ownerIdRunningNoOpptyMap.get(key).Id);
                        }
                    }
                    userIdAgentIdMap.put(u.id,u.TM_Agent_Id__c);
                }
                
                List<Policy_Transaction__c> ptList = [Select id, name, Status__c, Opportunity__r.Source_of_Activity__c from Policy_Transaction__c where Opportunity__c in :opptyIdList];
                if(!ptList.isEmpty()){
                    for(Policy_Transaction__c pt : ptList){
                        if(String.isNotBlank(pt.Opportunity__r.Source_of_Activity__c) && !pt.Opportunity__r.Source_of_Activity__c.contains('STP')){
                            pt.Status__c = 'Completed';
                        }
                    }
                    update ptList;
                }
                
                List<new_policy__c> npList = [Select id, name, policy_status__c, Opportunity__r.Source_of_Activity__c from new_policy__c where Opportunity__c in :opptyIdList];
                if(!npList.isEmpty()){
                    for(new_policy__c np : npList){
                        if(String.isNotBlank(np.Opportunity__r.Source_of_Activity__c) && !np.Opportunity__r.Source_of_Activity__c.contains('STP')){
                            np.policy_status__c = 'Completed';
                        }
                    }
                    update npList;
                }
                
                //Comment by jack to avoid auto create 380 call for drop-off
                /* List<Task> callList = new List<Task>();
                RecordType rt = [select Id, Name, developerName from RecordType where sobjectType = 'Task' and developerName = 'TM_Call'];
                for(Opportunity o : opptyList){
                    Task successCall = new Task();
                    successCall.recordTypeId = rt.id;
                    successCall.calldurationinseconds  = 0;
                    successCall.Result__c = '380 - Incomplete sales';
                    successCall.Overall_Opt_in_Opt_out__c = 'Opt-In';
                    successCall.whatId = o.Id;
                    successCall.Subject = 'Call';
                    successCall.Status = 'Completed';
                    successCall.ownerId = o.ownerId;
                    successCall.TMR_Agent_ID__c = String.isBlank(userIdAgentIdMap.get(o.ownerId))? '' : userIdAgentIdMap.get(o.ownerId);
                   
                    callList.add(successCall);
                }
                insert callList; */
            }
        }
    }
    
    public static void autoPopulateIQIDrunningNo(List<Opportunity> newList){
        
        String prefixDateStr = String.ValueOf(Date.today().year()) 
                                + String.valueOf(Date.today().month()).leftPad(2, '0') 
                                + String.valueOf(Date.today().day()).leftPad(2, '0');
        
        List<Sequence_Number__c> sequenceNumbers = [select id, name_space__c, current_number__c from Sequence_Number__c where name_space__c = :prefixDateStr for update];
        Sequence_Number__c sequenceNumber;
        Decimal currentNumber = 0;
        if(sequenceNumbers.size() == 0){
            // Race condition may happen if there are multiple thread concurrently executing this line and may lead to multiple name space record created
            sequenceNumber = new Sequence_Number__c(name_space__c = prefixDateStr, current_number__c = 0);
            insert sequenceNumber;
            currentNumber = 0;
        }else if(sequenceNumbers.size() == 1){
            sequenceNumber = sequenceNumbers.get(0);
            currentNumber = sequenceNumber.current_number__c;
        }else{
            // There should be not multiple sequence number record for the same namespace
            system.debug('[OpportunityTriggerHandler] autoPopulateIQIDrunningNo Exception >>>> Multiple namespace record found');
        }
        
        for(Opportunity o : newList){
            currentNumber++;
            if(String.isBlank(o.Running_No__c)){
                o.IQ_ID__c = '11154662';
                o.Running_No__c = 'HK' + prefixDateStr + 'J' + String.valueOf(currentNumber).leftpad(4, '0');
            }
        }
        sequenceNumber.current_number__c = currentNumber;
        update sequenceNumber;
        
    }
    
    public static void populateCampaignTypeFieldForOppty(List<Opportunity> newList){
        Map<Id,String> CamIdCampaignTypeMap = new Map<Id,String>();
        Set<Id> camIdSet = new Set<Id>();
        for(Opportunity opp : newList){
            camIdSet.add(opp.Campaign__c);
        }
        for(Campaign cam : [SELECT Id, Campaign_Type__r.Name FROM Campaign WHERE Id in :camIdSet]){
            CamIdCampaignTypeMap.put(cam.Id,cam.Campaign_Type__r.Name);
        }
        for(Opportunity opp : newList){
            opp.Campaign_Type_Name__c = CamIdCampaignTypeMap.get(opp.Campaign__c);
        }
    }
    
    //JR1817 - Start - Add for auto-assignment
    public static void dtcOpptyAssignment(List<Opportunity> newList){
        
        List<String> mobileList = new List<String>();
        List<Id> ownerIdLIst = new List<String>();
        
        List<Opportunity> duplicateOpptyList = new List<Opportunity>();
        List<Opportunity> unAssignOpptyList = new List<Opportunity>();
        List<String> repeatOpptyList = new List<String>();
        
        List<String> initialUserIdList = new List<String>();   //JL20200615
        List<User> initialUserList = new List<User>();         //JL20200615
        
        Map<String, Opportunity> mobileOpptyMap = new Map<String, Opportunity>();
        Map<Id, User> ownerMap = new Map<Id, User>();
        Map<Id, String> initialUserMap = new Map<Id, String>();  //JL20200615
            
        Set<String> dtcCampTypeSet = new Set<String>();
        
        //Get DTC campaign type list
        for(Campaign_Type__c ct :[SELECT Id,NAME FROM Campaign_Type__c WHERE is_auto_assignment__c = true]){
            dtcCampTypeSet.add(ct.Name);
        }
        
        for(Opportunity opp : newList){
            if(opp.OwnerId != null){
                ownerIdList.add(opp.ownerId);
            }
        }
        
        ownerMap = new Map<id, User>([SELECT Id, ProfileId FROM USER where Id = :ownerIdList]);

        //Get DTC lead only
        for(Opportunity opp : newList){     
            System.debug('Opp owner profile' + ownerMap.get(opp.OwnerId).ProfileId + opp.ownerId);
            
            if((dtcCampTypeSet.contains(opp.Campaign_Type__c) && ownerMap.get(opp.OwnerId).ProfileId != DTC_TMR_PROFILE_ID)||Test.isRunningTest()){
                if(String.isNotBlank(opp.Mobile_Phone_2__c)){
                    mobileList.add(opp.Mobile_Phone_2__c);
                }   
            }
        }
        System.debug('Duplicate moblie list size:' + String.valueof(mobileList.size()));
            
        if(!mobileList.isEmpty()){
            System.debug('Enter duplicate check');
           
            duplicateOpptyList = [SELECT Id, Mobile_phone_2__c, CreatedDate, Last_Called_Date__c,Result__c, OwnerId, Opportunity_Id__c, Owner.ProfileId, Owner.Name, Owner.ManagerId
                FROM Opportunity 
                WHERE Mobile_phone_2__c IN :mobileList 
                AND Owner.ProfileId != :TM_BACKOFFICE_PROFIEL_ID_LIST
                AND Campaign_Type__c = :dtcCampTypeSet
                // AND auto_assignment_flag__c > 0 /* add by Jack on 2021-10-11 for including empty auto_assignment_flag__c*/
                AND (auto_assignment_flag__c > 0 OR auto_assignment_flag__c = null) /* add by Jack on 2021-10-11 for including empty auto_assignment_flag__c*/
                //2023/10/19 ,Add by Owen for active user checking
                AND Owner.IsActive = true
                AND CreatedDate = LAST_N_DAYS:100];
            
            traceStr += 'duplicateOpptyList:' + duplicateOpptyList.toString() + ';';
            
            for(Opportunity opp : duplicateOpptyList){
                if(!mobileOpptyMap.containsKey(opp.mobile_phone_2__c)){
                    mobileOpptyMap.put(opp.Mobile_Phone_2__c, opp);
                }else{
                    Opportunity oldOppty = mobileOpptyMap.get(opp.Mobile_Phone_2__c);
                    
                    if(opp.CreatedDate > oldOppty.CreatedDate){
                        mobileOpptyMap.put(opp.Mobile_Phone_2__c, opp);
                    }                  
                }                
            }                              
        }
        System.debug('Mobile map size:' + String.valueof(mobileOpptyMap.size()));
        traceStr += 'mobileOpptyMap:' + mobileOpptyMap.toString() + ';';

        for(Opportunity opp : newList){
            traceStr = 'MobilePhone2:' + opp.Mobile_Phone_2__c + ';';
            if(dtcCampTypeSet.contains(opp.Campaign_Type__c) && ownerMap.get(opp.OwnerId).ProfileId != DTC_TMR_PROFILE_ID){   //If it is DTC campaign & not created by TMR
                
                if(mobileOpptyMap.size() > 0){  
                    
                    Opportunity oldOppty = mobileOpptyMap.get(opp.Mobile_Phone_2__c);
                    traceStr = 'oldOppty:' + oldOppty + ';';
                    
                    if(oldOppty != null){
                        if(oldOppty.CreatedDate.day() == System.Date.today().day()){
                           System.debug('Oppty created at the current day.' + oldOppty.Mobile_Phone_2__c);
                            
                            if(oldOppty.Owner.ProfileId != DTC_LEADER_PROFILE_ID){    //If the oppty has been assigned to TMR
                                if(oldOppty.Owner.ManagerId != null){
                                    opp.Ownerid = oldOppty.Owner.ManagerId;
                                    opp.initial_team_leader__c = oldOppty.Owner.ManagerId;
                                   
                                }else{
                                    opp.OwnerId = oldOppty.OwnerId;
                                    opp.initial_team_leader__c = oldOppty.OwnerId;
                                    opp.initial_team_leader_name__c = oldOppty.Owner.Name; //JL20200615
                                }
                            }else{                                                   // The oppty is owner by DTC leader
                                opp.OwnerId = oldOppty.OwnerId;
                                opp.initial_team_leader__c = oldOppty.OwnerId;
                            }
                            opp.duplicate_opp_owner__c = oldOppty.Owner.Name;
                            opp.duplicate_last_calldt__c = oldOppty.Last_Called_Date__c;
                            opp.duplicate_last_result__c = oldOppty.Result__c;
                            opp.duplicate_opp_created_dt__c = oldOppty.CreatedDate;
                            opp.duplicate_opp_id__c = oldOppty.Opportunity_ID__c;
                            opp.auto_assignment_flag__c = 0;
                        }else{                                                                  //The found oppty was not created at the current date
                            //cigna-jinni remove the oldOppty.Result__c.Left(3) != '105'
                            if((oldOppty.Result__c != null) || oldOppty.Result__c == null){
                                if(oldOppty.Owner.ManagerId != null){
                                    opp.Ownerid = oldOppty.Owner.ManagerId;
                                    opp.initial_team_leader__c = oldOppty.Owner.ManagerId;
                                }else{
                                    opp.OwnerId = oldOppty.OwnerId;
                                    opp.initial_team_leader__c = oldOppty.OwnerId;
                                }
                                opp.duplicate_last_calldt__c = oldOppty.Last_Called_Date__c;
                                opp.duplicate_last_result__c = oldOppty.Result__c;
                                opp.duplicate_opp_created_dt__c = oldOppty.CreatedDate;
                                opp.duplicate_opp_id__c = oldOppty.Opportunity_ID__c;
                                opp.duplicate_opp_owner__c = oldOppty.Owner.Name;
                                opp.auto_assignment_flag__c = 0;
                            }else{
                                unAssignOpptyList.add(opp);
                            }
                        }         
                    }else{
                        unassignOpptyList.add(opp);
                    }               
                }else{
                    unassignOpptyList.add(opp);
                }
            }    
        } 


        //JL20200615 - Added for JR1828 - Update initial team leader name field
        for(Opportunity opp : newList){
            if(opp.initial_team_leader__c != null){
                initialUserIdList.Add(opp.initial_team_leader__c);
            }            
        }
        
        initialUserList = [SELECT Id, Name FROM User WHERE Id IN : initialUserIdList];
        
        for(User initialUser : initialUserList){
            initialUserMap.put(initialUser.Id, initialUser.Name);
        }
        
        for(Opportunity opp : newList){
            if(opp.initial_team_leader__c != null){
                opp.initial_team_leader_name__c = initialUserMap.get(opp.initial_team_leader__c);
            }            
        }      
      //JL20200615 - End         

        if(unAssignOpptyList != null){
            OpportunityTriggerHandler.autoAssignmentForOppty(unAssignOpptyList);
        }   
    }
      
    //Add for JR1817
    public static void autoAssignmentForOppty(List<Opportunity> newList){
        
        decimal dtcTMRCount = 0;
        //JL20200930 decimal totalAssignCount = 0;
                
        Map<id, decimal> teamRateMap = new Map<id, decimal>();                           //For target calculation, team target rate
        Map<String, Map<Id, integer>> batchTeamOccupCountMap = new Map<String, Map<Id, integer>>();       //For actual rate calculation; actual assigned count by batch/team
        Map<String, Map<Id, decimal>> batchTeamOccupRateMap = new Map<String, Map<id, decimal>>();        //actual occupation rate by batch/team
        //JL20200930 Map<Id, integer> totalTeamOccupCountMap = new Map<id, integer>();              //actual overall assigned count by team
        //JL20200930 Map<Id, decimal> totalTeamOccupRateMap = new Map<id, decimal>();                 //actual overall occupation by team
        Map<String, decimal> batchAssignCountMap = new Map<String, decimal>();                   //actual assigned count by batch
        Map<String, Opportunity> assignedMap = new Map<String, Opportunity>();
        Map<Id, String> dtcLeaderNameMap = new Map<Id, String>(); //JL20200615
        
        Map<String, Map<String, decimal>> batchStatusAssignMap = new Map<String, Map<String, decimal>>();           //JL20200930 - JR1861; actual assigned count by batch/status
        Map<String, Map<String, Map<id, integer>>> batchStatusCountMap = new Map<String, Map<String, Map<id, integer>>>(); //JL20200930 - JR1861; actual assigned count by batch/status/team
        Map<String, Map<String, Map<id, decimal>>> batchStatusRateMap = new Map<String, Map<String, Map<id, decimal>>>();  //JL20200930 - JR1861; actual occupation rate by batch/status/team
        
        Date lastDate;  //JL20200930
    
        List<String> batchNoLiST = new List<String>();       
        List<id> dtcLeaderIdList = new List<id>();  
        //JL20200930 List<User> dtcLeaderList = [SELECT Id, Name FROM User WHERE ProfileId = :DTC_LEADER_PROFILE_ID and auto_assignment__c = true and IsActive = true];
        List<User> dtcLeaderList = [SELECT Id, Name, dtc_target_rate_update_date__c, dtc_target_occup_rate__c FROM User WHERE ProfileId = :DTC_LEADER_PROFILE_ID and auto_assignment__c = true and IsActive = true]; //JL20200930
        List<String> tranStatusList = new List<String>();     //JL20200930
        
        for(Opportunity opp : newList){
            if(!batchNoList.contains(opp.Batch_No__c)){
                batchNoList.add(opp.Batch_No__c);
            }
            
            if(!tranStatusList.contains(opp.Tx_Status__c)){     //JL20200930
                tranStatusList.add(opp.Tx_Status__c);      //JL20200930  
            }                          //JL20200930
        }
                    
        for(User dtcleader: dtcLeaderList){               
            dtcLeaderIdList.add(dtcleader.Id);
            teamRateMap.put(dtcleader.Id,0);
            //JL20200930 totalTeamOccupCountMap.put(dtcleader.Id, 0);
            //JL20200930 totalTeamOccupRateMap.put(dtcleader.Id, 0);
            dtcLeaderNameMap.put(dtcleader.Id,dtcleader.Name); //JL20200615         
        }
            
        dtcTMRCount = [SELECT COUNT() FROM User WHERE ManagerId = :dtcLeaderIdList And IsActive = true];
        //JL20200930 totalAssignCount = [SELECT COUNT() 
        //JL20200930                     FROM Opportunity 
        //JL20200930                     WHERE auto_assignment_flag__c > 0
        //JL20200930                     AND CALENDAR_YEAR(CreatedDate) = :System.Date.today().year() 
        //JL20200930                     AND CALENDAR_MONTH(CreatedDate) = :System.Date.today().Month()
        //JL20200930                     AND initial_team_leader__c = :dtcLeaderIdList];
        
        //Get target rate by team        
        //JL20200930 for(Id leaderId : dtcLeaderIdList){
        for(User leaderUser : dtcLeaderList){  //JL20200930
                       
            integer teamCount = 0;                    
            decimal teamRate = 0;
            
            //JL20200930 integer teamOccupCount = 0;
            //JL20200930 decimal teamOccupRate = 0;  
          
            
            //JL20200930 teamCount = [SELECT COUNT() FROM User WHERE ManagerId = :leaderId And IsActive = true];
            teamCount = [SELECT COUNT() FROM User WHERE ManagerId = :leaderUser.Id And IsActive = true];    //JL20200930
            
            //JL20200930 teamOccupCount = [SELECT COUNT() 
            //JL20200930                   FROM Opportunity 
            //JL20200930                   WHERE auto_assignment_flag__c > 0
            //JL20200930                   AND CALENDAR_YEAR(CreatedDate) = :System.Date.today().year() 
            //JL20200930                   AND CALENDAR_MONTH(CreatedDate) = :System.Date.today().Month()
            //JL20200930                   AND initial_team_leader__c = :leaderId];
                
            if(teamCount > 0){
                teamRate = teamCount / dtcTMRCount;                 
            }
            
            //JL20200930 - Start - Check if the target rate is changed
            if(teamRate > 0){
                System.debug('Calculated team target rate > 0.');
                if(teamRate.setScale(4) != (leaderUser.dtc_target_occup_rate__c == null ? 0 : leaderUser.dtc_target_occup_rate__c.setScale(4))){
                    //System.debug('Class.OpportunityDeDuplicationHelper.deDuplicatedInsert: line 411, column 1Class.OpportunityDeDuplicationHelper.deDuplicatedInsert: line 422, column 1Class.TMWebsitCallListGenerateQueue.createOpportunity: line 579, column 1Class.TMWebsitCallListGenerateQueue.createProspectAndCallList: line 325, column 1Class.TMWebsitCallListGenerateQueue.execute: line 122, column 1 ' + leaderUser.Id + ' : ' + String.valueOf(leaderUser.dtc_target_occup_rate__c.setScale(4)) + ' : ' + String.valueOf(teamRate.setScale(4)));
                
                    leaderUser.dtc_target_occup_rate__c = teamRate.setScale(4);
                    lastDate = Date.today();
                    leaderUser.dtc_target_rate_update_date__c = lastDate;
                }else{
                    //System.debug('Calculated rate = orignal rate. ' + leaderUser.Id);
                
                    if(lastDate == null){
                        lastDate = leaderUser.dtc_target_rate_update_date__c;
                    }else{
                        if(lastDate < leaderUser.dtc_target_rate_update_date__c){
                            lastDate = leaderUser.dtc_target_rate_update_date__c;
                        }
                    }             
                }
            }else{
                System.debug('Calculated team target rate = 0.');
                
                if((leaderUser.dtc_target_occup_rate__c == null ? 0 : leaderUser.dtc_target_occup_rate__c.setScale(4)) != 0){
                    leaderUser.dtc_target_occup_rate__c = 0;
                    leaderUser.dtc_target_rate_update_date__c = Date.today();
                    lastDate = Date.today();   
                    System.debug('Target rate and update date is change.');
                }else{
                    lastDate = (leaderUser.dtc_target_rate_update_date__c == null ? Date.today() : leaderUser.dtc_target_rate_update_date__c);
                    System.debug('Get the last update date.');
                }
            }
            //JL20200930 - End
            
            //JL20200930 if(teamOccupCount > 0){ 
            //JL20200930     teamOccupRate = teamOccupCount / totalAssignCount;
            //JL20200930 }
            
            //JL20200930 teamRateMap.put(leaderId, teamRate.setScale(4));    //JL20200420
            teamRateMap.put(leaderUser.Id, teamRate.setScale(4));        //JL20200930
            //JL20200930 totalTeamOccupCountMap.put(leaderId, teamOccupCount);
            //JL20200420 totalTeamOccupRateMap.put(leaderId, teamOccupRate.setScale(2));
            //JL20200930 totalTeamOccupRateMap.put(leaderId, teamOccupRate.setScale(4)); //JL20200420
        } 
        
        update dtcLeaderList;  //JL20200930 
        System.debug('Team target occupation rate calcuation completed');
        
        System.debug('Last Date is :' + String.valueOf(lastDate));
        
        //Get current occupation rate by batch
        //Start of occupation rate calculation
        Datetime lastDt  = Datetime.newInstanceGmt(lastDate, Time.newInstance(0, 0, 0, 0));
        for(String batchno : batchNoList){
            System.debug('Start to calculate the acutal batch occupation rate before assignment. ' + batchno);
            
            decimal assignCount = 0;
            Map<Id, integer> occupCountMap = new Map<Id, integer>();
            Map<Id, decimal> occupRateMap = new Map<Id,decimal>();
            Map<String, Map<Id, Integer>> initTeamStatusCountMap = new Map<String,Map<Id,Integer>>();    //JL20200930
            Map<String, Map<Id, decimal>> initTeamStatusRateMap = new Map<String, Map<Id,decimal>>();    //JL20200930
            Map<String, decimal> initStatusAssignMap = new Map<String, decimal>();              //JL20200930
            
            assignCount = [SELECT COUNT() 
                FROM Opportunity 
                WHERE batch_no__c = :batchno
                AND  auto_assignment_flag__c > 0
                //AND  CALENDAR_YEAR(CreatedDate) = :System.Date.today().year() 
                //AND  CALENDAR_MONTH(CreatedDate) = :System.Date.today().Month()
                AND initial_team_leader__c = :dtcLeaderIdList //JL20200420
	            AND DAY_ONLY(ConvertTimeZone(CreatedDate)) >= :lastDate  //JL20200930
	            AND CreatedDate >= :lastDT //add in 2021/1/6
                ];
            System.debug('Actual assign count by batch: ' + batchno + ' : ' + String.valueof(assignCount));    
            batchAssignCountMap.put(batchno, assignCount);  
            
            //Get current occupation rate by team
          
            for(Id leaderId : dtcLeaderIdList){
                integer teamOccupCount = 0; 
                decimal teamOccupRate = 0;
                
                teamOccupCount = [SELECT COUNT() 
                    FROM Opportunity 
                    WHERE initial_team_leader__c = :leaderId 
                    AND batch_no__c = :batchno
                    AND auto_assignment_flag__c > 0
                    AND DAY_ONLY(ConvertTimeZone(CreatedDate)) >= :lastDate  //JL20200930
                    AND CreatedDate >= :lastDT
                    ];
                
                if(assignCount > 0){
                    teamOccupRate = teamOccupCount / assignCount;
                }
                                    
                occupCountMap.put(leaderId, teamOccupCount);
                //JL20200420 occupRateMap.put(leaderId, teamOccupRate.setScale(2)); 
                occupRateMap.put(leaderId, teamOccupRate.setScale(4)); //JL20200420               
                System.debug('Team occupation rate:' + leaderId + '; ' + String.valueOf(teamOccupRate.setScale(4)));
            }
            
            batchTeamOccupCountMap.put(batchno, occupCountMap);
            batchTeamOccupRateMap.put(batchno, occupRateMap);
            
             //JL20200930 - Start - Add for JR1861; Calculate the actual rate by batch/transaction status/team leader
            for(String tranStatus : tranStatusList){
                System.debug('Start to calculate the actual occupation rate before assignment by batch/transaction status. ' + tranStatus);
                
                decimal  statusAssignCount = 0; 
                Map<Id, Integer> initTeamCountMap = new Map<Id, Integer>();
                Map<Id, decimal> initTeamRateMap = new Map<Id, decimal>();
               
                    
                statusAssignCount = [SELECT COUNT() 
                    FROM Opportunity 
                    WHERE initial_team_leader__c = :dtcLeaderIdList
                    AND batch_no__c = :batchno
                    AND auto_assignment_flag__c > 0
                    AND Tx_Status__c = :tranStatus
                    AND DAY_ONLY(ConvertTimeZone(CreatedDate)) >= :lastDate
                    AND CreatedDate >= :lastDT
                    ];
                
                for(Id leaderId : dtcLeaderIdList){
                    integer initCount = 0;
                    decimal initRate = 0;
                                                        
                    initCount = [SELECT COUNT() 
                        FROM Opportunity 
                        WHERE initial_team_leader__c = :leaderId 
                        AND batch_no__c = :batchno
                        AND auto_assignment_flag__c > 0
                        AND Tx_Status__c = :tranStatus
                        AND DAY_ONLY(ConvertTimeZone(CreatedDate)) >= :lastDate
                        AND CreatedDate >= :lastDT
                        ];

                    if(statusAssignCount > 0){
                        initRate = initCount / statusAssignCount;
                    }
                    
                    initTeamCountMap.put(leaderId, initCount);
                    initTeamRateMap.put(leaderId, initRate.setScale(4));
                }
                
                initTeamStatusCountMap.put(tranStatus, initTeamCountMap);
                initTeamStatusRateMap.put(tranStatus, initTeamRateMap);
                initStatusAssignMap.put(tranStatus, statusAssignCount);
            }
            
            batchStatusAssignMap.put(batchno, initStatusAssignMap);      //team-status assign count
            batchStatusCountMap.put(batchno, initTeamStatusCountMap);    //team-status rate
            batchStatusRateMap.put(batchno, initTeamStatusRateMap);      //status assign count
            //JL20200930 - End - Add
            
        } //End of occupation rate calculation
        
        System.debug('status assign map;' + batchStatusAssignMap);
        System.debug('status occu count map:' + batchStatusCountMap);
        System.debug('status occup rate map:' +batchStatusRateMap);

        //Start to assign the oppty
        for(Opportunity opp : newList){
            
            System.debug('phone = ' + opp.Mobile_Phone_2__c + ' : ' + opp.Batch_No__c);    
            if(opp.Batch_No__c == '195498'){
                System.debug('Assign Map:' + batchAssignCountMap.get(opp.Batch_No__c));
                System.debug('Actual map:' + (batchStatusAssignMap.get(opp.Batch_No__c)).get(opp.Tx_Status__c));
            }
            
            decimal compare_occup_rate = 0;
            Id initial_dtc_leader_id;
            
            Map<Id, integer> occupCountMap = new Map<Id, integer>();
            Map<Id, decimal> occupRateMap = new Map<Id, decimal>();
           
            decimal batchAssignCount = 0;
            decimal batchStatusAssignCount = 0; //JL20200930
            
            List<id> pendingList = new List<id>();

            batchAssignCount = batchAssignCountMap.get(opp.Batch_No__c);
            //JL20200930 occupRateMap = batchTeamOccupRateMap.get(opp.Batch_No__c);
            //JL20200930 occupCountMap = batchTeamOccupCountMap.get(opp.Batch_No__c);
                        
            
            occupCountMap = (batchStatusCountMap.get(opp.Batch_No__c)).get(opp.Tx_Status__c);   //JL20200930
            occupRateMap = (batchStatusRateMap.get(opp.Batch_No__c)).get(opp.Tx_Status__c);     //JL20200930
            //statusAssignMap = batchStatusAssignMap.get(opp.Batch_No__c);                 //JL20200930
            batchStatusAssignCount = (batchStatusAssignMap.get(opp.Batch_No__c)).get(opp.Tx_Status__c); //JL20200930
            //batchStatusAssignCount = statusAssignMap.get(opp.Tx_Status__c);                 //JL20200930
            
            if(assignedMap.containsKey(opp.Mobile_phone_2__c)){
                opp.ownerId = assignedMap.get(opp.Mobile_Phone__c).OwnerId;
                opp.initial_team_leader__c = assignedMap.get(opp.Mobile_Phone__c).OwnerId;
                opp.duplicate_opp_id__c = assignedMap.get(opp.Mobile_Phone__c).opportunity_id__c;                
                opp.duplicate_opp_created_dt__c = System.Datetime.now();
                opp.auto_assignment_flag__c = 0;
                
                for(User leader : dtcLeaderList){
                    if(leader.id == assignedMap.get(opp.Mobile_Phone__c).OwnerId){
                        opp.duplicate_opp_owner__c = leader.Name;
                    }
                }               
            }else{
                for(Id dtcLeaderId : dtcLeaderIdList){ 
                    System.debug(dtcleaderid + ':' + String.valueOf(teamRateMap.get(dtcLeaderId)) + ':' + String.valueof(occupRateMap.get(dtcleaderId)));
                    if(teamRateMap.get(dtcLeaderId) - occupRateMap.get(dtcleaderId) >= compare_occup_rate){
                        compare_occup_rate = teamRateMap.get(dtcLeaderId) - occupRateMap.get(dtcleaderId);                       
                    }               
                }
                
                System.debug('compare rate:' + String.valueof(compare_occup_rate));
            
                for(Id dtcLeaderId : dtcLeaderIdList){
                    if(teamRateMap.get(dtcLeaderId) - occupRateMap.get(dtcleaderId) == compare_occup_rate){
                        pendingList.add(dtcLeaderId);
                    }                
                }
            
                System.debug('pending list is' + String.valueof(pendingList.size()));
                
                if(pendingList.size() == 0){
                    decimal compare_occup_rate_2 = 0;
                    for(Id dtcLeaderId : dtcLeaderIdList){
                        if(occupRateMap.get(dtcleaderId) > compare_occup_rate_2){
                          initial_dtc_leader_id = dtcLeaderId;
                        }                                                                                                    
                    }
                }else{
                    if(pendingList.size() == 1){
                        initial_dtc_leader_id = pendingList[0];
                    }else{
                        for(Id pendingId1 : pendingList){
                            for(Id pendingId2 : pendingList){
                                if(pendingId1 != pendingId2){
                                    /* JL20200930 - Start - Disable
                                    if(totalTeamOccupRateMap.get(pendingId1) >= totalTeamOccupRateMap.get(pendingId2)){
                                        initial_dtc_leader_id = pendingId2;
                                    }else{
                                        initial_dtc_leader_id = pendingId1;
                                    }
                                    JL20200930 - End = Disable */
                                
                                    //JL20200930 - Start - Add for JR1861
                                    if(batchTeamOccupRateMap.get(opp.Batch_No__c).get(pendingId1) >= batchTeamOccupRateMap.get(opp.Batch_No__c).get(pendingId2)){
                                        initial_dtc_leader_id = pendingId2;
                                    }else{
                                        initial_dtc_leader_id = pendingId1;
                                    }
                                    //JL20200930 - End
                                }
                            } 
                        }
                    }                   
                }

                batchAssignCount+=1;
                //JL20200930 totalAssignCount+=1;
                batchStatusAssignCount+=1;   //JL20200930
            
                batchAssignCountMap.put(opp.Batch_No__c, batchAssignCount);
                //(batchStatusAssignMap.get(opp.Batch_No__c)).put(opp.Tx_Status__c, batchStatusAssignCount); //JL20200930
                System.debug('new batch-status assign count:' + String.valueof(batchStatusAssignCount) + ':' + opp.Tx_Status__c);
                
                opp.initial_team_leader__c = initial_dtc_leader_id;
                opp.initial_team_leader_name__c = dtcLeaderNameMap.get(initial_dtc_leader_id); //JL20200615
                opp.OwnerId = initial_dtc_leader_id;
                opp.auto_assignment_flag__c = 1;
            
                //Recalculate the occpuation rate
                for(id dtcLeaderId : dtcLeaderIdList){        
                    integer newopptyCount = 0;
                    decimal newopptyOccupRate = 0;
                
                    integer newTotalCount = 0;
                    decimal newTotalRate = 0;
                    
                    if(dtcLeaderId == initial_dtc_leader_id){
                        
                        newopptyCount = occupCountMap.get(dtcLeaderId) + 1; 
                        //JL20200930 newTotalCount = totalTeamOccupCountMap.get(dtcLeaderId) + 1;
                        newTotalCount = batchTeamOccupCountMap.get(opp.Batch_No__c).get(dtcLeaderId) + 1;   //JL20200930b
                                            
                        occupCountMap.put(dtcLeaderId, newopptyCount); 
                        //JL20200930 totalTeamOccupCountMap.put(dtcLeaderId, newTotalCount);
                        batchTeamOccupRateMap.get(opp.Batch_No__c).put(dtcLeaderId, newTotalCount);      //JL20200930
                        
                         
                    }else{
                        newopptyCount = occupCountMap.get(dtcLeaderId);
                        //JL20200930 newTotalCount = totalTeamOccupCountMap.get(dtcLeaderId);
                        newTotalCount = batchTeamOccupCountMap.get(opp.Batch_No__c).get(dtcLeaderId);      //JL20200930
                    }
                      
                    //JL20200930 newopptyOccupRate = newopptyCount / batchAssignCount;
                    //JL20200930 newTotalRate = newTotalCount / totalAssignCount;
                   
                    newopptyOccupRate = newopptyCount / batchStatusAssignCount;                //JL20200930
                    newTotalRate = newTotalCount / batchAssignCount ;                     //JL20200930
                    
                    System.debug('new occup count:' + opp.Tx_status__c + ' : ' + String.valueof(newopptyCount));
                    System.debug('new assign count:' + opp.Tx_status__c + ' : ' + String.valueof(batchStatusAssignCount));
                    System.debug('new occup rate: ' + String.valueof(newopptyOccupRate.setScale(4)));
                    
                    //JL20200930 occupRateMap.put(dtcLeaderId, newopptyOccupRate.setScale(2));
                    //JL20200930 totalTeamOccupRateMap.put(dtcLeaderId, newTotalRate.setScale(2));
                    occupRateMap.put(dtcLeaderId, newopptyOccupRate.setScale(4));              //JL20200930
                    batchTeamOccupRateMap.get(opp.Batch_No__c).put(dtcLeaderId, newTotalRate.setScale(4));  //JL20200930
                    
                    System.debug('new occupation rate:' + dtcLeaderId + ' : ' + String.valueof (newopptyOccupRate.setScale(4)));
                }
                //JL20200930 batchTeamOccupCountMap.put(opp.Batch_No__c, occupCountMap);
                //JL20200930 batchTeamOccupRateMap.put(opp.Batch_No__c, occupRateMap);
                batchStatusCountMap.get(opp.Batch_No__c).put(opp.Tx_Status__c,occupCountMap);        //JL20200930
                batchStatusRateMap.get(opp.Batch_No__c).put(opp.Tx_Status__c, occupRateMap);
                batchStatusAssignMap.get(opp.Batch_No__c).put(opp.Tx_Status__c, batchStatusAssignCount);  //JL20200930
                //batchStatusAssignMap.put(opp.Batch_No__c, statusAssignMap);
                assignedMap.put(opp.Mobile_Phone_2__c,opp);
                
                System.debug('occup count : ' + String.valueOf(occupCountMap));
                System.debug('occup rate : ' + String.valueOf(occupRateMap));
            }                 
        } //End of assignment for loop          
    }  
    
    //SPS-402
    public static void patchProspectId(List<Opportunity> newList){
        for(Opportunity opp : newList){
            system.debug('[OpportunityTriggerHandler] opp.Opportunity_Id__c = '+opp.Opportunity_Id__c);
            system.debug('[OpportunityTriggerHandler] opp.Prospect_Id__c = '+opp.Prospect_Id__c);
            if(String.isBlank(opp.Prospect_Id__c)){
                opp.Prospect_Id__c = opp.Opportunity_ID__c;
            }
        }
    }
    //SPS-402

    //jack add for JR1821
    public static void UpdateTermCodeHistory(List<Opportunity> tmOppList,List<Opportunity> newList){
        //List<Opportunity> tmOppList = [select id,result__c from opportunity where result__c != null];
        Set<String> oppIdSet = new Set<string>();
        for(Opportunity opp : tmOppList){
            if(String.isNotBlank(opp.result__c))
                oppIdSet.add(opp.Id);
        }
        // Rancho_20240604 - do not update opp result when it is 500
        List<Task> taskList = [Select term_code__c,whatId from Task where term_code__c != null and term_code__c != '500' and whatId in :oppIdSet order by createdDate asc];
        Map<Id,List<String>> oppMap = new Map<Id,List<String>>();
        for(Task task : taskList){
            if(oppMap.containsKey(task.whatId)){
                oppMap.get(task.whatId).add(task.term_code__c);
            }else{
                List<String> termCodelist = new List<String>();
                termCodelist.add(task.term_code__c);
                oppMap.put(task.whatId,termCodelist);
            }
        }
        system.debug('[OpportunityTriggerHanler] oppMap'+oppMap);

        for(Opportunity opp : newList){
            if(oppMap.containsKey(opp.Id)){
                String termCodeHistory = String.join(oppMap.get(opp.Id), ',');
                system.debug('[OpportunityTriggerHanler] termCodeHistory'+termCodeHistory);
                opp.Term_code_History__c = termCodeHistory;
            }
        }
    }
    
    public static void autoUpdateIsGAInd(List<Opportunity> tmOppList){
        Set<ID> AccIdSet = new Set<ID>();
        for(Opportunity opp : tmOppList){
            AccIdSet.add(opp.AccountId);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([select id, Is_GA__c from account where id in :AccIdSet ]);
        for(Opportunity opp : tmOppList){
            opp.Is_GA__c = accountMap.get(opp.AccountId).Is_GA__c;
        }
    }

    //GL31 jack add
    public static void autoPopulateAvailableProduct(Map<Id, Opportunity> oldMap,List<Opportunity> tmOppList){
        List<Assessment_Questions_Product_Mapping__c> mappingList = Assessment_Questions_Product_Mapping__c.getAll().values();
        for(Opportunity opp : tmOppList){
            //system.debug('autoPopulateAvailableProduct(): oldMap.get(opp.id).Objectives_Question__c'+oldMap.get(opp.id).Objectives_Question__c+' opp.Objectives_Question__c:'+opp.Objectives_Question__c+' oldMap.get(opp.id).Which_type_s_of_medical_insurance__c:'+oldMap.get(opp.id).Which_type_s_of_medical_insurance__c+' opp.Which_type_s_of_medical_insurance__c:'+opp.Which_type_s_of_medical_insurance__c);
            if(oldMap != null && (oldMap.get(opp.id).Objectives_Question__c != opp.Objectives_Question__c || oldMap.get(opp.id).Which_type_s_of_medical_insurance__c != opp.Which_type_s_of_medical_insurance__c)){
                if(String.isNotBlank(opp.Objectives_Question__c) && String.isNotBlank(opp.Which_type_s_of_medical_insurance__c)){
                    Map<String,Set<String>> prodRiderMap = CignaUtil.getAvailableProductScope(mappingList,opp.Objectives_Question__c,opp.Which_type_s_of_medical_insurance__c);
                    opp.Prod_Rider_Map__c = JSON.serialize(prodRiderMap);
                    // List<TM_Product_Category__c> tmProList = TM_Product_Category__c.getAll().values();//jack add for friend and family discount in SFDC
                    List<TM_Product_Category__c> tmProList = [Select Product_Code__c,Parent_Product__c,Name from TM_Product_Category__c where Module__c='Assessment Question'];//jack add for friend and family discount in SFDC
                    opp.Available_Product_Code_For_Assessment__c =  CignaUtil.getTMProductCode(tmProList, prodRiderMap);
                    List<String> productCodeList = opp.Available_Product_Code_For_Assessment__c.split(',');
                    List<Product__c> pList = [Select Name from Product__c where product_code__c in :productCodeList and recordType.DeveloperName ='TM_Product'];
                    String availProdName = '';
                    for(Product__c pro : pList){
                        System.debug('pro.name'+pro.name);
                        availProdName = availProdName + pro.Name + '\n';
                    }
                    Set<String> riderNameSet= TMPolicyUtil.getRiderNameForAssessment(prodRiderMap);
                    if(riderNameSet.size()>0){
                        availProdName = availProdName + '\n' + 'Rider part:' + '\n';
                        for(String rider : riderNameSet){
                            availProdName = availProdName + rider + '\n';
                        }
                    }
                    if(availProdName.endsWith('\n')){
                        availProdName = availProdName.substringBeforeLast('\n');
                    }
                    if(String.isEmpty(availProdName)){
                        availProdName = NO_SUCH_PRODUCT;
                    }
                    opp.Available_Product_Name_For_Assessment__c = availProdName;
                }else{
                    opp.Available_Product_Name_For_Assessment__c = '';
                    opp.Available_Product_Code_For_Assessment__c = '';
                    opp.Prod_Rider_Map__c = '';
                }
            }
        }
    }
        
    /**
     *  Rancho_SpeechAnalytics_20210607 new Speech Analytics Log record when log a call and opportunity updated
     **/
    public static void newSARecd(List<String> oppIdList){
        System.debug('OpportunityTriggerHandler.newSARecd');
        if(!oppIdList.isEmpty()){
            CreateNewSpeechAnalyticsLogCtrl newSA = new CreateNewSpeechAnalyticsLogCtrl();
            newSA.newRecord(oppIdList);
        }
    }
}