/********************************************************************************
 * Apex Class Name - TMWebsitCallListGenerateQueue
 * Created Date - Apr 23, 2018
 * @description Internet Lead call lists, fetch prospect details from website
 * 
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Ken, Franco     23/04/2018              Original Version
 ********************************************************************************/
public class TMWebsitCallListGenerateQueue implements Queueable, Database.AllowsCallouts{
    
    public List<String> activityIdList;
    public List<String> activityTypeList;
    public Integer batchSize;
    public List<Id> optOutAccIdList;
    public static String log = '';
    private Set<String> VHISProductCode = new Set<String>{'VSTDG','VSMMG','VSUPG'};
    private Set<String> eliteProductCode = new Set<String> {'NELG','NESG'};
    private Set<String> cignaPlusProductCode = new Set<String> {'TUPG','TUSG','TUWG'};
    private Set<String> choiceProductCode = new Set<String> {'PMGH'};
    //Combo: reset policy transaction step = PHPI Information
    private Set<String> hasDefaultUWResultSet = new Set<String> {'@CBOG'};
        
    public Boolean thorwException1;
    public Boolean thorwException2;
    
    public Map<string,string> dropoffExclusion{
        get{
            Map<string,string> tmp = new Map<string,string>();
            tmp.put('MGMSTPDO18','1');
            return tmp;
        }
        set;
    }
    
    public static Map<String, String> uwResultMap = new Map<String, String>{
        //added by Connor for issue vu2-140
        'Accept' => 'Accepted','Refer' => 'Referred','Decline' => 'Declined','N/A' => '','' => '',null => ''
    };    
    
    //Add by Manuel
    public Map<String,Country_List_Settings__c> mapCtryListSet{
        get{
            Map<String,Country_List_Settings__c> tmp= new Map<String,Country_List_Settings__c>();
            for(Country_List_Settings__c cls : Country_List_Settings__c.getAll().values()){
                tmp.put(cls.Country_Id__c,cls);
            }
            return tmp;
        }
        set;
    }
    
    //Add by Manuel
    public Map<String,Discount_Code__c> mapDiscountCode{
        get{
            Map<String,Discount_Code__c> tmp= new Map<String,Discount_Code__c>();
            for(Discount_Code__c dc : Discount_Code__c.getAll().values()){
                tmp.put(dc.Code__c,dc);
            }
            return tmp;
        }
        set;
    }
    
    //Add by Manuel
    public Map<String,Policy_Validation_Checking__c> mapPolicyValidationChecking{
        get{
            Map<String,Policy_Validation_Checking__c> tmp = new Map<String,Policy_Validation_Checking__c>();
            for(Policy_Validation_Checking__c pvc : Policy_Validation_Checking__c.getAll().values()){
                tmp.put(pvc.Product_Code__c,pvc);
            }
            return tmp;
        }
        set;
    }
    
    Map<String, Drop_Off_Criteria__mdt> dropOffCriteriaMap;//SPS-693 jack add

    public Map<String,String> runningNoChangingMap;
    
    public Map<String,Map<String,Id>> CampaginCodeProductListMap = new Map<String, Map<String,Id>>();
    
    public Map<String,Map<String,String>> CampaignCodeProductNameListMap = new Map<String,Map<String,String>>();
    /* add by Jack on 2022-08-12 for project: fix for wrong Selected_Campaign__c */
    public Map<String,Map<String,Id>> CampaginCodeProductCamMap = new Map<String, Map<String,Id>>();
    /* add by Jack on 2022-09-23 for project: fix for empty Relationship_Of_Policy__c of policy */
    public static Map<String,String> relationshipMap{get{
        if(relationshipMap == null){
            relationshipMap = new Map<String, String>{'Policy Holder' => 'MI','Spouse' => 'SP','Son' => 'CH','Daughter' => 'CH','Dependent' => 'DP'};
        }
        return relationshipMap;
    } set;}
    /*
     * TMWebsitCallListGenerateQueue
     * @ activityIdList represent the waiting to process prospect activity ids
     * @ activityTypeList represent the waiting to process prospect activity types
     * @ batchSize represent how many prospects will process in this queue
     */
    public TMWebsitCallListGenerateQueue(List<String> activityIdList, List<String> activityTypeList, Integer batchSize){
        this(activityIdList,activityTypeList,batchSize,new List<Id>());
    } 
     
    public TMWebsitCallListGenerateQueue(List<String> activityIdList, List<String> activityTypeList, Integer batchSize, List<Id> optOutAccIdList){
        this.activityIdList = activityIdList;
        this.activityTypeList = activityTypeList;
        this.batchSize = batchSize;
        this.optOutAccIdList = optOutAccIdList;
        //SPS-693 jack add
        dropOffCriteriaMap = new Map<String, Drop_Off_Criteria__mdt>();
        for(Drop_Off_Criteria__mdt doc : [SELECT Id, Campaign_Code__c, Transaction_Status__c, Type__c FROM Drop_Off_Criteria__mdt]){
            dropOffCriteriaMap.put(doc.Campaign_Code__c, doc);
        }
    }
    /*
     * pick out the 10(batchSize) records to process, the rest records will pass to next queue
     *
     */
    public void execute(QueueableContext context){
        //system.debug('>>> current queue, activityIdList size: ' + activityIdList.size());
        List<String> subActivityIdList = new List<String>();
        List<String> subActivityTypeList = new List<String>();
        while(!activityIdList.isEmpty()){
            subActivityIdList.add(activityIdList.remove(0));
            subActivityTypeList.add(activityTypeList.remove(0));
            if(subActivityIdList.size()==batchSize||activityIdList.isEmpty()){
                createProspectAndCallList(subActivityIdList, subActivityTypeList);
                break;
            }
        }
        if(!activityIdList.isEmpty()){
            if(!Test.isRunningTest()){
                //system.debug('>>> next queue, activityIdList size: ' + activityIdList.size());
                Id jobID = System.enqueueJob(new TMWebsitCallListGenerateQueue(activityIdList, activityTypeList, batchSize, optOutAccIdList));
                //System.debug('jobID in queue: '+ jobID);
            }
        }else{
            //After executing all queue. Will update the Opt out TM customer's opt out flag to opt-out
            if(!optOutAccIdList.isEmpty()){
                List<Account> optOutAcc = [Select id, Overall_Opt_Out__pc, Opt_out_Exclusion__pc from Account where id in :optOutAccIdList and RecordType.developerName = 'TM_Customer'];
                for(Account acc : optOutAcc){
                    acc.Overall_Opt_Out__pc = true;
                    acc.Opt_out_Exclusion__pc = true;
                }
                update optOutAcc;
            }
        }
    }
    
    /*
     * Create account and opportunity
     */
    public void createProspectAndCallList(List<String> activityIdList, List<String> activityTypeList){
        
        List<String> personMobilePhone = new List<String>();
        Map<String,List<HttpCalloutVO.ProspectDetail>> accPhoneProsDetail = new Map<String,List<HttpCalloutVO.ProspectDetail>>();
        Set<String> activityTypesPara = new Set<String>();
        Set<String> productCodesPara = new Set<String>();
        //system.debug('>>>GetProspectListSchedulable.saveObject prospects size: ' + activityIdList.size());
        
        Map<String, HttpCalloutVO.ProspectDetail> prospectDetailsMap = new Map<String, HttpCalloutVO.ProspectDetail>();
        Map<String, Account> activityAccountMap = new Map<String, Account>();
        //add for covid19
        List<Covid19_Product_Info__c> covid19List = new List<Covid19_Product_Info__c>();
        ProspectCalloutHelper helper = new ProspectCalloutHelper('TM');

        //add for Combo drop-off
        List<Drop_Off_Sync_Up_Obj__c> dropOffObjList = new List<Drop_Off_Sync_Up_Obj__c>();

        //comment by jack for SPS-693
        //Rancho_Combo_20201118
        // Map<String, Drop_Off_Criteria__mdt> dropOffCriteriaMap = new Map<String, Drop_Off_Criteria__mdt>();
        // for(Drop_Off_Criteria__mdt doc : [SELECT Id, Campaign_Code__c, Transaction_Status__c, Type__c FROM Drop_Off_Criteria__mdt]){
        //     dropOffCriteriaMap.put(doc.Campaign_Code__c, doc);
        // }
        for(Integer i = 0; i < activityIdList.size(); i++){
            String activityId = activityIdList[i];
            String activityType = activityTypeList[i];
            List<HttpCalloutVO.ProspectDetail> pdList = helper.getProspectBasic(activityId, activityType);
            if(pdList.size() > 0){
                HttpCalloutVO.ProspectDetail pd = pdList[0];
                HttpCalloutVO.Person ps = pd.holderDetail.person;

                /*CR-44 create account -- 2021-01-18 Zane*/
                Boolean createAcc = true;
                /********************Covid19 enhancement logic start*********************************/ 
                //Add by Andy Li from Deloitte
                //if the activity type = esales campaign, means this is an covid product
                System.debug('acType: '+pd.activityType+' campaignCode: '+pd.CampaignCode+' tranStatus: '+pd.transactionStatus);
                if(pd.activityType=='EsalesCampaign'){
                    HttpCalloutVO.Policy pl = pd.policy;
                    Covid19_Product_Info__c covid19Tmp = new Covid19_Product_Info__c();
                    //For covid19, the PH = PI and only have one PI
                    covid19Tmp.Covid19_Activity_Id__c = pd.ActivityId;
                    covid19Tmp.Covid19_Activity_Type__c = pd.activityType;
                    covid19Tmp.Covid19_Campaign_Code__c = pd.CampaignCode;
                    covid19Tmp.Covid19_Running_Number__c = pd.RunningNumber;
                    covid19Tmp.Covid19_Submission_Date__c = Date.valueOf(pd.SubmissionDate);
                    covid19Tmp.Covid19_Plan_Level__c = pd.planLevel;
                    covid19Tmp.Covid19_Policy_Status__c = pd.PolicyStatus;
                    covid19Tmp.Covid19_QuestionAns1__c = pd.QuestionAns1;
                    covid19Tmp.Covid19_QuestionAns2__c = pd.QuestionAns2;

                    covid19Tmp.Covid19_DOB__c = Date.valueOf(ps.birthDate);
                    covid19Tmp.Covid19_Email_Address__c = String.isBlank(ps.emailAddress) ? '' : ps.emailAddress;
                    covid19Tmp.Covid19_First_Name__c = ps.firstName;
                    covid19Tmp.Covid19_Last_Name__c = String.isBlank(ps.lastName) ? 'Unnamed' : ps.lastName;
                    covid19Tmp.Covid19_Gender__c = ps.gender;
                    covid19Tmp.Covid19_Phone__c = ps.mobilePhoneNo;
                    covid19Tmp.Covid19_SSN__c = ps.ssnNumber;
                    covid19Tmp.Covid19_ResidenceaddressLine1__c = ps.ResidenceaddressLine1;
                    covid19Tmp.Covid19_ResidenceaddressLine2__c = ps.ResidenceaddressLine2;
                    covid19Tmp.Covid19_ResidenceaddressLine3__c = ps.ResidenceaddressLine3;
                    covid19Tmp.Covid19_ResidenceaddressLine4__c = ps.ResidenceaddressLine4;

                    covid19Tmp.Covid19_Plan_Name__c = pl.planName;
                    covid19Tmp.Covid19_Policy_Number__c = pl.policyNumber;
                    covid19Tmp.Covid19_Product_Code__c = pl.productCode;
                    
                    //Nicole_CR-36 Covid_20200709
                    if(pd.OptOutInd!=null){
                        covid19Tmp.Opt_Out_Indicator__c = pd.OptOutInd;
                    }

                    covid19List.add(covid19Tmp);

                    /*CR-44 create account -- 2021-01-18 Zane*/
                    createAcc = false;
                    /********************Covid19 enhancement logic end*********************************/
                //Add by Rancho_20201022 Combo drop-off logic Start
                }else if(dropOffCriteriaMap.containsKey(pd.CampaignCode)
                    && String.isNotBlank(dropOffCriteriaMap.get(pd.CampaignCode).Transaction_Status__c)
                    && String.isNotBlank(pd.transactionStatus)
                    && dropOffCriteriaMap.get(pd.CampaignCode).Transaction_Status__c.contains(pd.transactionStatus)){
                    /*CR-44 create opportunity when CampaignCode = 'COMBOEAP01' and Transaction Status = 'PHINFO'. It just only creates Drop_Off_Sync_Up_Obj__c before.
                            -- 2021-01-18 Zane*/
                    if('Combo' == dropOffCriteriaMap.get(pd.CampaignCode).Type__c && 'PHINFO' == pd.transactionStatus){
                        createAcc = true;
                        // CR-44 manually add product information
                        if(String.isBlank(pd.ProductCode)){
                            pd.ProductCode = 'CBOG';
                            pd.planLevel = '1';
                            pd.policy.productCode = 'CBOG';
                            pd.policy.planName = 'Cigna DIY Health Plan';
                        }
                    }else if('Combo' == dropOffCriteriaMap.get(pd.CampaignCode).Type__c && String.isBlank(pd.ProductCode)){//detecting if it is a Combo campaign drop off and without product code sps-681 jack add
                        createAcc = true;//create policy for this drop off case
                    }else{
                        createAcc = false;
                    }

                    HttpCalloutVO.Policy pl=pd.policy;
                    Drop_Off_Sync_Up_Obj__c dropOffObj=new Drop_Off_Sync_Up_Obj__c();
                    dropOffObj.Activity_Id__c=pd.ActivityId;
                    dropOffObj.Activity_Type__c=pd.activityType;
                    dropOffObj.Campaign_Code__c=pd.CampaignCode;
                    dropOffObj.Running_Number__c=pd.RunningNumber;
                    dropOffObj.Submission_Date__c=Date.valueOf(pd.SubmissionDate);
                    dropOffObj.Plan_Level__c=pd.planLevel;
                    dropOffObj.Policy_Status__c=pd.PolicyStatus;
                    dropOffObj.Smoke_Habit__c=pd.smokeInd;
                    dropOffObj.Plan_Declaration__c=pd.planDeclaration;
                    dropOffObj.QuestionAns1__c=pd.QuestionAns1;
                    dropOffObj.QuestionAns2__c=pd.QuestionAns2;
                    dropOffObj.QuestionAns3__c=pd.QuestionAns3;
                    dropOffObj.QuestionAns4__c=pd.QuestionAns4;
                    dropOffObj.QuestionAns5__c=pd.QuestionAns5;
                    dropOffObj.HK_Mobile_Phone__c=String.isBlank(ps.mobilePhoneNo) ?'':'852'+ps.mobilePhoneNo;
                    if(String.isNotBlank(ps.birthDate)){
                        dropOffObj.DOB__c=Date.valueOf(ps.birthDate);
                    }
                    dropOffObj.Email__c=String.isBlank(ps.emailAddress)?'':ps.emailAddress;
                    dropOffObj.First_Name__c=ps.firstName;
                    dropOffObj.Last_Name__c=String.isBlank(ps.lastName)?'':ps.lastName;
                    dropOffObj.Gender__c=String.isBlank(ps.gender)?'':ps.gender;
                    dropOffObj.Mobile__c=String.isBlank(ps.mobilePhoneNo) ?'':ps.mobilePhoneNo;
                    dropOffObj.SSN__c=ps.ssnNumber;
                    dropOffObj.Plan_Name__c=pl.planName;
                    dropOffObj.Policy_Number__c=pl.policyNumber;
                    dropOffObj.Product_Code__c=pl.productCode;
                    dropOffObj.Type__c=dropOffCriteriaMap.get(pd.CampaignCode).Type__c;
                    dropOffObj.Transaction_Status__c=pd.transactionStatus;// Rancho_JR1920_20210712

                    dropOffObjList.add(dropOffObj); 
                    //Add by Rancho_20201022 Combo drop-off logic End
                }
                /*CR-44 create account -- 2021-01-18 Zane*/
                system.debug('createAcc:'+createAcc);
                if(createAcc){
                    Account a = new Account();
                    a.RecordTypeId = AccountTriggerHandler.recordTypeMap.get(AccountTriggerHandler.RECORD_TYPE_TM_CUSTOMER);
                    a.FirstName = ps.firstName;
                    a.LastName = String.isBlank(ps.lastName) ? 'Unnamed' : ps.lastName;
                    a.SSN__c = ps.ssnNumber;
                    a.PersonTitle = ps.title;
                    a.Gender__c = ps.gender;
                    if(String.isBlank(ps.gender) && AccountTriggerHandler.titleGenderMap.containsKey(ps.title)){
                        a.Gender__c = AccountTriggerHandler.titleGenderMap.get(ps.title);
                    }
                    if(pd.language == 'en_US'){
                        a.Language_Preference__c = 'English';
                    }else if(pd.language == 'zh_HK'){
                        a.Language_Preference__c = 'Chinese';
                    }
                    a.PersonBirthdate = ps.birthDateInDate;
                    a.PersonBirthdate__c = ps.birthDateInDate;
                    a.Home_Address_Line_1__c = ps.addressLine1;
                    a.Home_Address_Line_2__c = ps.addressLine2;
                    a.Home_Address_Line_3__c = ps.addressLine3;
                    a.Home_Address_Line_4__c = ps.addressLine4;
                    a.PersonMailingCity = ps.city;
                    a.PersonMailingState = ps.addressState;
                    a.PersonMailingCountry = ps.addressCountry;
                    a.Email__c = ps.emailAddress;
                    if(String.isNotBlank(ps.mobilePhoneNo)){ //only match mobilePhone
                        a.PersonMobilePhone = ps.mobilePhoneNo;
                    }else if(String.isNotBlank(ps.mobileTelephoneNo)){
                        a.PersonMobilePhone = ps.mobileTelephoneNo;
                    }else if(String.isNotBlank(ps.businessPhoneNo)){
                        a.PersonMobilePhone = ps.businessPhoneNo;
                    }else if(String.isNotBlank(ps.homePhoneNo)){
                        a.PersonMobilePhone = ps.homePhoneNo;
                    }
                    //System.debug('>>> PersonMobilePhone: ' + a.PersonMobilePhone);
                    // will create account regardless the opt out indicator
                    if(String.isNotBlank(a.PersonMobilePhone)){ //pd.OptOutInd != true && 
                        activityAccountMap.put(activityId + '_' + activityType, a);
                        prospectDetailsMap.put(activityId + '_' + activityType, pd);
                    } else {
                        //log = log + '\nOptOutInd flag is true, will not create acc and opp, activityId:' + activityId + ',activityType:' + activityType;
                    }
                }
            }
        }
        // Create Account with pre-processing rules
        PreProcessingHelper processingHelper = new PreProcessingHelper();
        List<Account> newAccList = processingHelper.process(activityAccountMap.values());

        //add for dropOffObj
        if(!dropOffObjList.isEmpty()){
            insert dropOffObjList;

            List<String> errMessage = new List<String>();
            List<String> runningNoList = new List<String>();
            List<String> tempString = new List<String>();
            for(Drop_Off_Sync_Up_Obj__c  dropOffObj : dropOffObjList){
                errMessage.add( 'convert to combo dropoff sync up obj, id = ' + dropOffObj.Id + '\nActivityId = ' + dropOffObj.Activity_Id__c + ' ActivityType = ' + dropOffObj.Activity_Type__c + ' SSN = ' + dropOffObj.SSN__c + ' Campaign Code = ' + dropOffObj.Campaign_Code__c);
                runningNoList.add(dropOffObj.Running_Number__c);
                tempString.add('convert to combo dropoff sync up obj');
            }
            if(errMessage.size() > 0){
                insertCheckinglog('TMWebsitCallListGenerateQueue.createProspectAndCallList',errMessage,runningNoList,tempString);
            }
        }

        // Create Opportunity with De-duplication
        try {
            //system.debug('>>> newAccList.size() ' + newAccList.size());
            //system.debug('>>> activityAccountMap.size() ' + activityAccountMap.size());
            system.debug('>>> prospectDetailsMap.size() ' + prospectDetailsMap.size());
            createOpportunity(newAccList, activityAccountMap, prospectDetailsMap);
            //add for covid19 by andy li from deloitte---start
            insert covid19List;
            //add for covid19 by andy li from deloitte---end
            if(Test.isRunningTest()&& thorwException1){
                throw new CignaException('Exception');
            }
        } catch(Exception e){
            //system.debug('>>> exception when create opportunity: ' + e.getMessage());
            //system.debug('>>> exception when create opportunity: ' + e.getStackTraceString());
            log = log + '\nException when create opportunity: ' + e.getStackTraceString();
            //add by kermit
            createCheckingLog('TMWebsitCallListGenerateQueue.createOpportunity',prospectDetailsMap.values(),String.valueOf(e.getLineNumber()),e.getStackTraceString(),e.getMessage());
            //end add
        }


        
    }
    
    /*
     * Create Opportunity with De-duplication
     */
    public void createOpportunity(List<Account> newAccList, Map<String, Account> activityAccountMap, Map<String, HttpCalloutVO.ProspectDetail> prospectDetailsMap){
        PreProcessingHelper processingHelper = new PreProcessingHelper();
        Set<String> campaignCodeSet = new Set<String>();
        for(HttpCalloutVO.ProspectDetail pd : prospectDetailsMap.values()){
            campaignCodeSet.add(pd.campaignCode);
        }
        system.debug('>>> campaignCodeSet: ' + campaignCodeSet);
        
        //exclude the duplicate prospect, determine by runningNo
        Map<String,List<String>> runningNoActIdMap = new Map<String,List<String>>();
        Set<String> runningNoSet = new Set<String>();
        for(String key : prospectDetailsMap.keySet()){
            if(!runningNoActIdMap.containsKey(prospectDetailsMap.get(key).RunningNumber)){
                runningNoActIdMap.put(prospectDetailsMap.get(key).RunningNumber, new List<String>{key});
            }else{
                runningNoActIdMap.get(prospectDetailsMap.get(key).RunningNumber).add(key);
            }
        }
        DateTime timerange = DateTime.newInstance(Date.today(), Time.newInstance(DateTime.now().hour(), 0, 0, 0));
        for(Opportunity opp : [SELECT Id,Running_No__c FROM Opportunity WHERE Running_No__c in :runningNoSet and createddate < :timerange]){
            List<String> actIdList = runningNoActIdMap.get(opp.Running_No__c);
            if(actIdList!=null){
                for(String reKey : actIdList)
                    prospectDetailsMap.remove(reKey);
            }
        }
        //exclude end here
        
        List<Campaign> campaignList = [select id,name,Core_Product_Code__c, ownerid, Core_Product__c, Core_Product__r.Name, Expiry_Date__c, IPAS_Campaign_Code__c from Campaign where IPAS_Campaign_Code__c in :campaignCodeSet And status = : CampaignTriggerHandler.STATUS_IN_PROGRESS Order by Createddate desc];//,Business_Partner__r.Sponsor_Code__c AM project coupon jack add
        system.debug('>>> campaignList.size() ' + campaignList.size());
        
        Map<String, Campaign> actTypeProCodeCamMap = new Map<String, Campaign>();
        for(Campaign c : campaignList){
            actTypeProCodeCamMap.put(c.IPAS_Campaign_Code__c, c);
        }
        
        //20190415 change start
        List<Campaign> prospectCampaignList = [SELECT Id,IPAS_Campaign_Code__c,Core_Product__c,Core_Product_Code__c,Status,Core_Product__r.Name,(select Id,Alt_Campaign__c,Alt_Campaign__r.Core_Product__c,Alt_Campaign__r.Core_Product_Code__c,Alt_Campaign__r.Core_Product__r.Name from Core_Campaign_Alter_Campaign__r)
            From Campaign Where IPAS_Campaign_Code__c in :campaignCodeSet And status = : CampaignTriggerHandler.STATUS_IN_PROGRESS Order by Createddate desc];
        system.debug('[TMWebsitCallListGenerateQueue] prospectCampaignList: '+prospectCampaignList);
        
        // generate CampaignCodeProductListMap: Map<IPAS_Campaign_Code__c, Map<Product_Code__c,ProductId>>
        for(Campaign cam:prospectCampaignList){
            /* add by Jack on 2022-08-12 for project: fix for wrong Selected_Campaign__c */
            if(CampaginCodeProductCamMap.get(cam.IPAS_Campaign_Code__c)==null){
                Map<String,Id> tempMap1 = new Map<String,Id>();
                tempMap1.put(cam.Core_Product__c,cam.id);
                for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_Alter_Campaign__r){
                    tempMap1.put(ccac.Alt_Campaign__r.Core_Product__c,ccac.Alt_Campaign__c);
                }
                CampaginCodeProductCamMap.put(cam.IPAS_Campaign_Code__c,tempMap1);
            }else{
                Map<String,Id> tempMap2 = CampaginCodeProductCamMap.get(cam.IPAS_Campaign_Code__c);
                tempMap2.put(cam.Core_Product__c,cam.id);
                for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_Alter_Campaign__r){
                    tempMap2.put(ccac.Alt_Campaign__r.Core_Product__c,ccac.Alt_Campaign__c);
                }
                CampaginCodeProductCamMap.put(cam.IPAS_Campaign_Code__c,tempMap2);                
            }

            if(CampaginCodeProductListMap.get(cam.IPAS_Campaign_Code__c)==null){
                Map<String,Id> tempMap1 = new Map<String,Id>();
                tempMap1.put(cam.Core_Product_Code__c,cam.Core_Product__c);
                for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_Alter_Campaign__r){
                    tempMap1.put(ccac.Alt_Campaign__r.Core_Product_Code__c,ccac.Alt_Campaign__r.Core_Product__c);
                }
                CampaginCodeProductListMap.put(cam.IPAS_Campaign_Code__c,tempMap1);
            }else{
                Map<String,Id> tempMap2 = CampaginCodeProductListMap.get(cam.IPAS_Campaign_Code__c);
                tempMap2.put(cam.Core_Product_Code__c,cam.Core_Product__c);
                for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_Alter_Campaign__r){
                    tempMap2.put(ccac.Alt_Campaign__r.Core_Product_Code__c,ccac.Alt_Campaign__r.Core_Product__c);
                }
                CampaginCodeProductListMap.put(cam.IPAS_Campaign_Code__c,tempMap2);                
            }
            // end generate CampaignCodeProductListMap
             
            // generate CampaignCodeProductNameListMap: Map<IPAS_Campaign_Code__c, Map<Product_Code__c,ProductName>>
            if(CampaignCodeProductNameListMap.get(cam.IPAS_Campaign_Code__c)==null){
                Map<String,Id> tempMap1 = new Map<String,String>();
                tempMap1.put(cam.Core_Product_Code__c,cam.Core_Product__r.Name);
                for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_Alter_Campaign__r){
                    tempMap1.put(ccac.Alt_Campaign__r.Core_Product_Code__c,ccac.Alt_Campaign__r.Core_Product__r.Name);
                }
                CampaignCodeProductNameListMap.put(cam.IPAS_Campaign_Code__c, tempMap1);
            }else{
                Map<String,String> tempMap2 = CampaignCodeProductNameListMap.get(cam.IPAS_Campaign_Code__c);
                tempMap2.put(cam.Core_Product_Code__c,cam.Core_Product__r.Name);
                for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_ALter_Campaign__r){
                    tempMap2.put(ccac.Alt_Campaign__r.Core_Product_Code__c, ccac.Alt_Campaign__r.Core_Product__r.Name);
                }
                CampaignCodeProductNameListMap.put(cam.IPAS_Campaign_Code__c,tempMap2);
            }
            // end generate CampaignCodeProductNameListMap
            
            
        }
        //system.debug('[TMWebsitCallListGenerateQueue] CampaginCodeProductListMap: '+CampaginCodeProductListMap);
        //20190415 change end
        
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> AccIdSet = new Set<Id>();
        Set<Id> campaignIdSet = new Set<Id>();

        List<String> errMessage = new List<String>();
        List<String> runningNoList = new List<String>();
        List<String> tempString = new List<String>();
        // Rancho_HKITSFDC187_20250304 - add opt-out mobile list to block opportunity creation
        List<TM_Opt_out_Mobile_List__c> optOutList = TM_Opt_out_Mobile_List__c.getAll().values();
        Set<String> optOutNumbers = new Set<String>();
        for(TM_Opt_out_Mobile_List__c optOut : optOutList) {
            if(String.isNotBlank(optOut.Mobile_Number__c) && optOut.Active__c) {
                optOutNumbers.add(optOut.Mobile_Number__c);
            }
        }

        for(String key : prospectDetailsMap.keySet()){
            
            HttpCalloutVO.ProspectDetail pd;
            pd = prospectDetailsMap.get(key);

            // Rancho_HKITSFDC187_20250304 - add opt-out mobile list to block opportunity creation
            System.debug('Prospect Detail: ' + pd.holderDetail);
            if(null != pd.holderDetail.person && null != pd.holderDetail.person.mobilePhoneNo && optOutNumbers.contains(pd.holderDetail.person.mobilePhoneNo)) {
                System.debug('opt-out mobile number, could not create opp');
                continue;
            }

            String accId;
            for(Account acc : newAccList){
                AccIdSet.add(acc.id);
                Account a = activityAccountMap.get(key);
                if(String.isNotBlank(a.ssn__c) && a.ssn__c == acc.ssn__c){
                    accId = acc.id;
                    break;
                }else if(processingHelper.processContactNumber(a.PersonMobilePhone) == acc.PersonMobilePhone){
                    accId = acc.id;
                    break;
                }
            }
            //system.debug('[TMWebsitCallListGenerateQueue] accId= '+accId);
            
            Campaign cam = actTypeProCodeCamMap.get(pd.campaignCode);
            //system.debug('>>> cam: ' + cam);
            if(cam != null){
                campaignIdSet.add(cam.id);
                HttpCalloutVO.Person person = pd.holderDetail.person;
                Opportunity o = new Opportunity();
                o.RecordTypeId = OpportunityTriggerHandler.recordTypeMap.get(OpportunityTriggerHandler.RECORD_TYPE_TM_OPP);
                o.Name = '*DO NOT MODIFY*';
                o.StageName = 'Cigna';
                o.CloseDate = cam.Expiry_Date__c;
                o.Activity__c = pd.ActivityId;
                o.Running_No__c = pd.RunningNumber;
                o.IQ_ID__c = pd.IQId;
                o.Submission_Date_Time__c = DateTime.valueOf(pd.SubmissionDate + ' ' + pd.SubmissionTime);
                o.Submission_Date__c = o.Submission_Date_Time__c.date();
                //o.Quote_Product1__c = cam.Core_Product__r.Name;
                Map<String,String> ProductCodeProductNameMap = CampaignCodeProductNameListMap.get(pd.campaignCode);
                if(ProductCodeProductNameMap.get(pd.policy.productCode)!=null || ProductCodeProductNameMap.get(TMCallListGenerator.productCodeMap.get(pd.policy.productCode))!=null){
                    o.Quote_Product1__c = ProductCodeProductNameMap.get(pd.policy.productCode)!=null ? 
                        ProductCodeProductNameMap.get(pd.policy.productCode) : ProductCodeProductNameMap.get(TMCallListGenerator.productCodeMap.get(pd.policy.productCode));
                }else{
                    o.Quote_Product1__c = cam.Core_Product__r.Name;
                }
                Map<String,Id> ProductCodeProductIdMap = CampaginCodeProductListMap.get(pd.campaignCode);
                if(ProductCodeProductIdMap.get(pd.policy.productCode)!=null || ProductCodeProductIdMap.get(TMCallListGenerator.productCodeMap.get(pd.policy.productCode))!=null){
                    o.Product_1__c = ProductCodeProductIdMap.get(pd.policy.productCode)!=null ? 
                        ProductCodeProductIdMap.get(pd.policy.productCode) : ProductCodeProductIdMap.get(TMCallLIstGenerator.productCodeMap.get(pd.policy.productCode));
                }else{
                    o.Product_1__c = cam.Core_Product__c;
                }
                o.Campaign__c = cam.Id;
                o.AccountId = accId;
                o.OwnerId = cam.OwnerId;
                o.StageName = 'Cigna';
                //o.Plan_Level_Rate_Scale_for_Product1__c = pd.PlanLevel + (String.isNotBlank(pd.rateScale) ? (';' + pd.rateScale) : '');
                if(!'Contact'.equals(pd.ActivityType)){
                    o.Plan_Level_Rate_Scale_for_Product1__c = pd.PlanLevel + (String.isNotBlank(pd.rateScale) ? (';' + pd.rateScale) : '');
                }
                o.Date_of_Birth__c = person.birthDateInDate;                       
                o.Preferred_Contact_Time__c = pd.preferContactTime;
                o.Remark3__c = pd.preferContactTime;
                o.Remark7__c = pd.Enquiry;
                o.Smoke_Indicator__c = pd.smokeInd != null && pd.smokeInd;
                o.How_Do_You_Know__c = pd.howToKnow;
                o.Tx_Status__c = pd.transactionStatus;
                o.Source_of_Activity__c = pd.ActivityType;
                //Add by Manuel to include new Activity Type NewEsales 
                if( (pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && pd.FinalUWResult == 'Refer'){
                    o.Source_of_Activity__c = 'STPRefer';
                }else if((pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && pd.FinalUWResult == 'N/A'){
                    o.Source_of_Activity__c = 'STPDropOff';
                    //added by Charles, excluding opportunity creation for CHOICE MGM campaign 
                    if(dropoffExclusion.get(pd.CampaignCode) != null){
                        continue;
                    }
                }else if((pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && pd.FinalUWResult == 'Accept'){
                    o.Source_of_Activity__c = 'STPDropOff';
                }else if((pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && pd.FinalUWResult == 'Decline'){
                    o.Source_of_Activity__c = '';
                }
                
                //add for JR-GA by kermit
                o.GACLIENTID__c = pd.GAClientID;
                o.GATRACKID__c = pd.GATrackID;
                o.GAUSERID__c = pd.GAUserId;
                o.GASource__c = pd.GASource;
                o.GAMedium__c = pd.GAMedium;
                o.GACampaign__c = pd.GACampaign;
                //add for JR-GA by kermit
                
                //JR-1846
                o.GAKeyword__c = pd.GAKeyword;
                //JR-1846
                
                //SPS-319
                HttpCalloutVO.Person ps = pd.holderDetail.person;
                if(ps!=null){
                    //system.debug('[TMWebsitCallListGenerateQueue] o.Mobile_Phone_2__c='+ps.mobilePhoneNo);
                    o.Mobile_Phone_2__c = ps.mobilePhoneNo;
                }
                //SPS-319
                
                //JR-1801
                o.Attempt_Count__c = 1;
                //JR-1801
                
                //Combo product: answer three question in questionnaire page for providing the rider suggestion to customer
                o.QuestionAns1__c = String.isNotBlank(pd.QuestionAns1) ? pd.QuestionAns1 : '';
                o.QuestionAns2__c = String.isNotBlank(pd.QuestionAns2) ? pd.QuestionAns2 : '';
                o.QuestionAns3__c = String.isNotBlank(pd.QuestionAns3) ? pd.QuestionAns3 : '';

                //system.debug('[TMWebSitCallListGenerateQueue] createPolicy pd.planDeclaration='+pd.planDeclaration);
                if(String.isNotBlank(pd.planDeclaration)){
                    for(String planAns : pd.planDeclaration.split(';')){
                        if(String.isNotBlank(planAns) && planAns.contains(':')){
                            String[] planCodeAns = planAns.split(':');
                            String planCode = planCodeAns[0];
                            String Ans = planCodeAns[1];
                            if(planCode == 'CCAG' && Ans == 'Y'){
                                o.Cancer_Declaration__c = 'Yes';
                            }else if(planCode == 'CCAG' && Ans == 'N'){
                                o.Cancer_Declaration__c = 'No';
                            }

                            /* add by Jack on 2022-04-11 for project: Separation project - TM remove CADG in COMBO */
                            // if(planCode == 'CADG' && Ans == 'Y'){
                            //     o.Accident_Declaration__c = 'Yes';
                            // }else if(planCode == 'CADG' && Ans == 'N'){
                            //     o.Accident_Declaration__c = 'No';
                            // }
                        }
                    }
                }
                // Combo end
                //AM project jack add for opptunity AM field
                System.debug('pd.insuredDetailList:'+pd.insuredDetailList);
                // for(HttpCalloutVO.PersonRelation pr : pd.insuredDetailList){
                //     HttpCalloutVO.Person person1 = pr.person;
                //     system.debug('pr.relation.RelationRoleCode:'+pr.relation.RelationRoleCode);
                //     if(pr.relation.InsurableInterestReason=='Policy Holder'){
                //     // if(pr.relation.RelationRoleCode=='8'){
                //         if(person1.membership.channel=='M'){
                //             o.Asia_Miles_Membership_First_Name__c = person1.membership.membershipFirstName;
                //             o.Asia_Miles_Membership_Last_Name__c = person1.membership.membershipLastName;
                //             o.Asia_Miles_Membership_Num__c = person1.membership.membershipId;
                //         }
                //         break;
                //     }
                // }
                system.debug('pd.activityType:'+pd.activityType+' pd.holderDetail:'+pd.holderDetail);
                if(pd.holderDetail!=null && (pd.activityType=='Quote' || pd.activityType=='Contact' || pd.activityType=='ContactMe' || pd.holderDetail.relation.RelationRoleCode=='8')){
                    HttpCalloutVO.Person holder = pd.holderDetail.person;
                    if(holder.membership.channel=='M'){
                        o.Asia_Miles_Membership_First_Name__c = holder.membership.membershipFirstName;
                        o.Asia_Miles_Membership_Last_Name__c = holder.membership.membershipLastName;
                        o.Asia_Miles_Membership_Num__c = holder.membership.membershipId;
                    }
                }
                // Add by Owen,20230523, For JOBR-312 to get promote code
                System.debug('================promocode is'+ pd.PromoCode);
                o.Promote_Code__c = String.isNotBlank(pd.PromoCode) ? pd.PromoCode : '';
                oppList.add(o);
                //system.debug('[TMWebsitCallListGenerateQueue] o.accountId= '+o.AccountId);
                /*
                // will not create opportunity if it's opt out
                if(pd.OptOutInd != true){
                    oppList.add(o);
                }else{
                    system.debug('Opportunity Opt-out flag is true, will not create oppty.');
                    log = log + '\nOpportunity Opt-out flag is true, will not create oppty. activity code:' + pd.ActivityId + ', activity type:' + pd.ActivityType;
                }
                */
                if(pd.OptOutInd == true){
                    optOutAccIdList.add(o.AccountId);
                }
                
            } else {
                //system.debug('>>> can not find the campaign for account:' + accId + ', campaign code:' + pd.campaignCode + ', activity code:' + pd.ActivityId + ', activity type:' + pd.ActivityType);
                log = log + '\ncan not find the campaign for account:' + accId + ', campaign code:' + pd.campaignCode + ', activity code:' + pd.ActivityId + ', activity type:' + pd.ActivityType;
                //insert campaign not found log : The status of corresponding campaign in SFDC is not in progress

                errMessage.add('can not find the campaign for account:' + accId + ', campaign code:' + pd.campaignCode + ', activity code:' + pd.ActivityId + ', activity type:' + pd.ActivityType);
                runningNoList.add(pd.RunningNumber);
                tempString.add('campaign is not in progress' + pd.campaignCode);
            }
        }

        if(errMessage.size() > 0){
            insertCheckinglog('TMWebsitCallListGenerateQueue.createOpportunity-campaign_not_found',errMessage,runningNoList,tempString);
        }
        //system.debug('>>> oppList.size(): ' + oppList.size());
        //system.debug('>>> oppList: ' + oppList);
        if(oppList.size() > 0){
            List<Opportunity> toSaveOppList = new List<Opportunity>();
            OpportunityDeDuplicationHelper oppHelper = new OpportunityDeDuplicationHelper(campaignIdSet, AccIdSet);
            List<Opportunity> newOppList = oppHelper.deDuplicatedInsert(oppList);
            runningNoChangingMap = oppHelper.runningNoChangingMap;
            Map<String, HttpCalloutVO.ProspectDetail> applyPDMap = new Map<String, HttpCalloutVO.ProspectDetail>();
            for(HttpCalloutVO.ProspectDetail pd : prospectDetailsMap.values()){
                //Add by Manuel to include new ActivityType NewEsales
                //if((pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && (pd.FinalUWResult == 'Refer' || pd.FinalUWResult == 'N/A')){
                //if((pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && (pd.FinalUWResult == 'Refer' || pd.FinalUWResult == 'N/A' || pd.FinalUWResult == 'Accept')){
                if((pd.ActivityType == 'Apply' || pd.ActivityType == 'NewEsales') && 
                   (pd.FinalUWResult == 'Refer' || pd.FinalUWResult == 'N/A' || pd.FinalUWResult == 'Accept' ||  
                    ( pd.FinalUWResult == 'Decline' && (VHISProductCode.contains(pd.productCode)||eliteProductCode.contains(pd.productCode)||cignaPlusProductCode.contains(pd.productCode)||choiceProductCode.contains(pd.productCode)) ) )){//Decline condition added by Connor for issue vu2-140
                    applyPDMap.put(pd.activityId + '_' + pd.activityType, pd);
                }
            }
            //system.debug('>>> applyPDMap.size(): ' + applyPDMap.size());
            // create policy for referred case and drop-off case
            if(applyPDMap.size() > 0){
                try {
                    createPolicy(applyPDMap, newOppList, actTypeProCodeCamMap); //Add by Manuel
                    //createPolicy(applyPDMap, oppList, actTypeProCodeCamMap);
                    if(Test.isRunningTest()&& thorwException2){
                        throw new CignaException('Exception');
                    }
                } catch(Exception e){
                    //system.debug('>>> exception when create policy: ' + e.getMessage());
                    log = log + '\nexception when create policy: ' + e.getStackTraceString();
                    
                    //add by kermit
                    createCheckingLog('TMWebsitCallListGenerateQueue.createPolicy',applyPDMap.values(),String.valueOf(e.getLineNumber()),e.getStackTraceString(),e.getMessage());
                    //end add
                }
            }
        }
        if(String.isNotBlank(log)){
            //System.debug('William ' + log);
            //WSCalloutSettingHelper.insertSFDCLog('TMWebsitCallListGenerateQueue Error Log', log);
        }
    }
    
    /*
     * Create policy for referred case and drop-off case
     */ 
    public void createPolicy(Map<String, HttpCalloutVO.ProspectDetail> applyPDMap, List<Opportunity> oppList, Map<String, Campaign> actTypeProCodeCamMap){
    
        //system.debug('>>> create policy for refer case or drop-off case:');
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        List<Policy_Transaction__c> referCaseList = new List<Policy_Transaction__c>();  //to record the refer case
        List<String> referCaseRunningNumList = new List<String>();
        for(Opportunity opp : oppList){
            oppMap.put(opp.Running_No__c, opp);
        }
        
        //de-dup policies
        Map<String,String> polNoAppIDMap = new Map<String,String>();
        //de-dup applyPDMap 
        for(String key : applyPDMap.keySet()){
            String polNo = applyPDMap.get(key).policy.policyNumber;
            if(!polNoAppIDMap.containsKey(polNo)){
                polNoAppIDMap.put(polNo,key);
            }else{
                HttpCalloutVO.prospectDetail oriPD = applyPDMap.get(polNoAppIDMap.get(polNo));
                HttpCalloutVO.ProspectDetail distPD = applyPDMap.get(key);
                if(distPD.SubmissionDateInTime > oriPD.SubmissionDateInTime){
                    applyPDMap.remove(polNoAppIDMap.get(polNo));
                    polNoAppIDMap.put(polNo,key);
                }
            }
        }
        
        //de-dup with existing sfdc record
        Set<String> polNoSet = new Set<String>();
        for(New_Policy__c np : [SELECT Id, Policy_No__c FROM New_Policy__c WHERE Policy_No__c IN :polNoAppIDMap.keySet()]){
            polNoSet.add(np.Policy_No__c);
        }
        if(!polNoSet.isEmpty()){
            for(String s : polNoSet){
                applyPDMap.remove(polNoAppIDMap.get(s));
            }
        }
        
        //de-dup policies end here
        
        // Create Policy Transaction
        //Map<String, Policy_Transaction__c> ptMap = new Map<String, Policy_Transaction__c>();
        List<Policy_Transaction__c> ptList = new List<Policy_Transaction__c>(); //Add by Manuel
        for(String key : applyPDMap.keySet()){
            HttpCalloutVO.ProspectDetail pd = applyPDMap.get(key);
            //Opportunity opp = oppMap.get(pd.RunningNumber);
            //system.debug('[TMWebSitCallListGenerateQueue] runningNoChanging= '+runningNoChangingMap);
            Opportunity opp = oppMap.get(pd.RunningNumber);
            //if(opp == null){
                //opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
            //}
            if(opp!=null){
                system.debug('[createpolicytransaction] current runningNo:'+opp.Running_No__c);
            }
            while(opp == null && !runningNoChangingMap.isEmpty() && runningNoChangingMap.containsKey(pd.RunningNumber)){
                opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
                pd.RunningNumber = runningNoChangingMap.get(pd.RunningNumber);
            }
            if(opp == null){
                continue;
            }
            //Comment by Manuel that create a new policy transaction for each one prospect policy (start)
            //if(!ptMap.containsKey(pd.RunningNumber)){
                Policy_Transaction__c pt = new Policy_Transaction__c();
                pt.Account__c = opp.AccountId;
                pt.Opportunity__c = opp.Id;
                pt.Core_Campaign__c = opp.Campaign__c;
                // pt.Selected_Campaign__c = opp.Campaign__c;
                pt.OwnerId = opp.OwnerId==null?null:opp.OwnerId;
                if(TMCallListGenerator.productCodeMap.containsKey(pd.productCode)){
                    pt.Product_Code__c = TMCallListGenerator.productCodeMap.get(pd.productCode);
                }else{
                    pt.Product_Code__c = pd.productCode;
                }
                
                /* add by Jack on 2022-08-12 for project: fix for wrong Selected_Campaign__c */
                Map<String,Id> IPAScodeProductIdMap = CampaginCodeProductListMap.get(pd.campaignCode);
                String productId;
                if(IPAScodeProductIdMap.get(pt.Product_Code__c)!=null){
                    productId = IPAScodeProductIdMap.get(pt.Product_Code__c);
                }else{
                    productId = actTypeProCodeCamMap.get(pd.campaignCode).Core_Product__c;
                }
                Map<String,id> productCamMap = CampaginCodeProductCamMap.get(pd.campaignCode);
                pt.Selected_Campaign__c = productCamMap.get(productId)==null?opp.Campaign__c:productCamMap.get(productId);

                pt.Product_Name__c = pd.policy.planName;
                if(pd.FinalUWResult == 'Refer'){
                    // Refer case
                    pt.Status__c = 'Pending Payment';
                    pt.Step__c = String.valueOf(TMCreatePolicyCtrl.STEP_CONFIRMATION_PAYMENT);
                }
                //Add by Manuel
                else if(pd.FinalUWResult == 'Accept'){
                    // supplement accept case
                    pt.Status__c = 'Pending Payment';
                    pt.Step__c = String.valueOf(TMCreatePolicyCtrl.STEP_CONFIRMATION_PAYMENT);
                }
                else if(pd.FinalUWResult == 'Decline'){    //Added by Nicole for VU2-140
                    // supplement decline case
                    pt.Status__c = 'Pending Payment';
                    pt.Step__c = String.valueOf(TMCreatePolicyCtrl.STEP_CONFIRMATION_PAYMENT);
                }
                else {
                    // Drop-off case
                    pt.Status__c = 'Pending Basic Information';
                    pt.Step__c = String.valueOf(TMCreatePolicyCtrl.STEP_PHPI_INFORMATION );
                }
                System.debug('TMWebsitCallListGenerateQueue pt.Product_Code__c:'+pt.Product_Code__c+' pt.Step__c：'+pt.Step__c);
                //Combo: Combo drop-off case need be in PHPI INFORMATION step although FinalUWResult is accept. Combo FinalUWResult always has a default value because it dosn't need AUW step
                //Combo pd.FinalUWResult == 'Accept', will reset status to below -20201209
                if(String.isNotBlank(pt.Product_Code__c) && hasDefaultUWResultSet.contains(pt.Product_Code__c)){
                    pt.Status__c = 'Pending Basic Information';
                    pt.Step__c = String.valueOf(TMCreatePolicyCtrl.STEP_PHPI_INFORMATION );
                }

                System.debug('TMWebsitCallListGenerateQueue pt.Product_Code__c:'+pt.Product_Code__c+' pt.Step__c：'+pt.Step__c);
                //SPS-681 jack add
                if(String.isBlank(pt.Product_Code__c)){
                    pt.Status__c = 'Pending Basic Information';
                    pt.Step__c = String.valueOf(TMCreatePolicyCtrl.STEP_POLICY_INFORMATION );
                }

                pt.Number_of_Person_Insured__c = 1;
                pt.Web_Site_Running_Number__c = pd.RunningNumber;
                //ptMap.put(pt.Web_Site_Running_Number__c, pt);
                ptList.add(pt);//Add by Manuel
                Set<String> transactionStatusSet = new Set<String>{'UWQ','Confirm','Payment'};
                //Add by Owen,set status 'completed' only when UW Overall result not equals'Referred'
                if(pt.Status__c == 'Pending Payment' && !((uwResultMap.get(pd.finalResult) == 'Referred') || (uwResultMap.get(pd.PolicyStatus) == 'Declined' && transactionStatusSet.contains(pd.transactionStatus)))){
                    pt.Status__c = 'Completed';
                    referCaseList.add(pt);
                    referCaseRunningNumList.add(pd.RunningNumber);
                }
                System.debug('TMWebsitCallListGenerateQueue pt.Product_Code__c:'+pt.Product_Code__c+' pt.Step__c：'+pt.Step__c);
            //Comment by Manuel that create a new policy transaction for each one prospect policy (stop)
            /*
            } else {
                Policy_Transaction__c pt = ptMap.get(pd.RunningNumber);
                pt.Number_of_Person_Insured__c = pt.Number_of_Person_Insured__c + 1;
            }
            */
            
        }
        //Comment by Manuel
        /*
        system.debug('ptMap: ' + ptMap);
        if(!ptMap.isEmpty()){
            upsert ptMap.values();
            
        }
        */
        
        //Add by Manuel 
        //system.debug('>>> ptList: '+ptList);
        if(ptList.size()>0){
            upsert ptList;
            for(Policy_Transaction__c pt : ptList){
                System.debug('TMWebsitCallListGenerateQueue pt.Product_Code__c:'+pt.Product_Code__c+' pt.Step__c：'+pt.Step__c);
            }
        }
        
        // Create Policy
        Map<String, New_Policy__c> policyMap = new Map<String, New_Policy__c>();
        Integer ptListIndex = 0; //Add by Manuel
        
        //WEI-323: wrong master policy no
        Map<String, String> HolderSSNPolicyNoMap = new Map<String,String>();
        for(HttpCalloutVO.ProspectDetail pd : applyPDMap.values()){
            if('Policy Holder'.equals(pd.insuredDetailList[0].relation.InsurableInterestReason) && String.isNotBlank(pd.holderDetail.person.ssnNumber))//fast fixing for AM extra issue jack add
                HolderSSNPolicyNoMap.put(pd.holderDetail.person.ssnNumber,pd.policy.policyNumber);
        }
        //WEI-323 END HERE
        
        for(String key : applyPDMap.keySet()){
            HttpCalloutVO.ProspectDetail pd = applyPDMap.get(key);
            Opportunity opp = oppMap.get(pd.RunningNumber);
            //if(opp == null){
                //opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
            //}
            
            while(opp == null && !runningNoChangingMap.isEmpty() && runningNoChangingMap.containsKey(pd.RunningNumber)){
                opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
                pd.RunningNumber = runningNoChangingMap.get(pd.RunningNumber);
            }
            if(opp == null){
                continue;
            }
            
            New_Policy__c np = new New_Policy__c();
            
            //np.Policy_Transaction__c = ptMap.get(pd.RunningNumber).Id;
            //np.Policy_Status__c = ptMap.get(pd.RunningNumber).Status__c;
            
            //Add by Manuel
            np.Policy_Transaction__c = ptList[ptListIndex].Id;
            np.Policy_Status__c = ptList[ptListIndex].Status__c;
            ptListIndex++;
            
            np.Account__c = opp.AccountId;
            np.Opportunity__c = opp.Id;
            np.Core_Campaign__c = opp.Campaign__c;
            // np.Selected_Campaign__c = opp.Campaign__c;
            np.IQ_ID__c = opp.IQ_ID__c; //add by Andy pre pop IQID if opp's IQID not empty
            np.Running_No__c = opp.Running_No__c; //add by Andy pre pop running no. if opp's running no. not empty
            np.Policy_No__c = pd.policy.policyNumber;
                        
            np.Submission_Date_Time__c = DateTime.valueOf(pd.SubmissionDate + ' ' + pd.SubmissionTime);
            
            np.Discount_Code_1_to_IPAS__c = String.isBlank(pd.DiscountCode1)? '':pd.DiscountCode1;
            np.Discount_Code_2_to_IPAS__c = String.isBlank(pd.DiscountCode2)? '':pd.DiscountCode2;
            
            // WEI-315: The following change would be required in SFDC TM:
            // Map the <DiscountCode1> & <DiscountCode2> to CITAS loading factor code for Choice product in SFDC TM:
            // DiscountCode in GetProspectBasic              DiscountCode in SFDC TM SetNBComplete
            //             06                                                 95
            //           06 + 18                                              97
            if(pd.productCode.contains('PMGH')){
                if(('06'.equals(np.Discount_Code_1_to_IPAS__c)&&'18'.equals(np.Discount_Code_2_to_IPAS__c)) // 06 + 18 = 97
                    ||('18'.equals(np.Discount_Code_1_to_IPAS__c)&&'06'.equals(np.Discount_Code_2_to_IPAS__c))){
                        np.Discount_Code_1_to_IPAS__c = '97';
                        np.Discount_Code_2_to_IPAS__c = '';
                    }else{
                        np.Discount_Code_1_to_IPAS__c = '06'.equals(np.Discount_Code_1_to_IPAS__c) ? '95' : np.Discount_Code_1_to_IPAS__c;
                        np.Discount_Code_2_to_IPAS__c = '06'.equals(np.Discount_Code_2_to_IPAS__c) ? '95' : np.Discount_Code_2_to_IPAS__c;
                    }
            }
                
            if(TMCallListGenerator.productCodeMap.containsKey(pd.policy.productCode)){
                np.Product_Code__c = TMCallListGenerator.productCodeMap.get(pd.policy.productCode);
            }else{
                np.Product_Code__c = pd.policy.productCode;
            }
            
            //np.Product__c = actTypeProCodeCamMap.get(pd.campaignCode).Core_Product__c;
            Map<String,Id> IPAScodeProductIdMap = CampaginCodeProductListMap.get(pd.campaignCode);
            if(IPAScodeProductIdMap.get(np.Product_Code__c)!=null){
                np.Product__c = IPAScodeProductIdMap.get(np.Product_Code__c);
            }else{
                np.Product__c = actTypeProCodeCamMap.get(pd.campaignCode).Core_Product__c;
            }
            /* add by Jack on 2022-08-12 for project: fix for wrong Selected_Campaign__c */
            Map<String,id> productCamMap = CampaginCodeProductCamMap.get(pd.campaignCode);
            np.Selected_Campaign__c = productCamMap.get(np.Product__c)==null?opp.Campaign__c:productCamMap.get(np.Product__c);
            
            np.plan_code__c = pd.policy.productCode;
            np.Product_Name__c = pd.policy.planName;
            np.Sum_Insured__c = String.isNotBlank(pd.policy.policyValue) ? Decimal.valueOf(pd.policy.policyValue) : null;
            if(pd.policy.paymentAmt != null && pd.policy.paymentAmt != 0){
                np.Payment_Frequency__c = 'Annual'; 
                np.Actual_Premium__c = pd.policy.paymentAmt;
                np.Annual_Premium__c = pd.policy.paymentAmt;
            }else if(String.isNotBlank(pd.policy.monthlyPaymentAmt) && Decimal.valueOf(pd.policy.monthlyPaymentAmt) != 0){
                np.Payment_Frequency__c = 'Monthly'; 
                np.Actual_Premium__c = pd.policy.paymentAmt;
                np.Annual_Premium__c = pd.policy.paymentAmt;
            }
            np.Pre_Sales_Result__c = uwResultMap.get(pd.PresalesResult);
            // np.Pre_Sales_Result_From_Website__c = uwResultMap.get(pd.PresalesResult);//SPS-699 jack add
            np.UW_Result__c = uwResultMap.get(pd.FinalUWResult);
            if(!pd.exclusionDetails.isEmpty() && 'Accepted'.equals(np.UW_Result__c)){
                np.UW_Result__c = 'Accepted with Exclusion';
            }
            np.UW_Overrall_Result__c = uwResultMap.get(pd.finalResult);
            np.Personal_ID__c = pd.holderDetail.person.ssnNumber;
            np.Policy_Holder_Name__c = pd.holderDetail.person.fullName;
            np.Policy_Holder_First_Name__c = pd.holderDetail.person.firstName;
            np.Policy_Holder_Last_Name__c = pd.holderDetail.person.lastName;
            np.Gender__c = pd.holderDetail.person.gender;
            np.Residential_Address_1__c = pd.holderDetail.person.ResidenceaddressLine1;
            np.Residential_Address_2__c = pd.holderDetail.person.ResidenceaddressLine2;
            np.Residential_Address_3__c = pd.holderDetail.person.ResidenceaddressLine3;
            np.Residential_Address_4__c = pd.holderDetail.person.ResidenceaddressLine4;
            np.Mobile_Phone__c = pd.holderDetail.person.mobilePhoneNo;
            np.Home_Phone__c = pd.holderDetail.person.homePhoneNo;
            np.Office_Phone__c = pd.holderDetail.person.businessPhoneNo;
            np.Policy_Holder_Email_Address__c = pd.holderDetail.person.emailAddress;
            np.Corresponding_Address_1__c = pd.holderDetail.person.addressLine1;
            np.Corresponding_Address_2__c = pd.holderDetail.person.addressLine2;
            np.Corresponding_Address_3__c = pd.holderDetail.person.addressLine3;
            np.Corresponding_Address_4__c = pd.holderDetail.person.addressLine4;
            np.Corresponding_Address_Country__c = pd.holderDetail.person.addressCountry;
            /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
            if(pd.holderDetail.person.PlaceOfBirthCode!=null&&mapCtryListSet.containsKey(pd.holderDetail.person.PlaceOfBirthCode)){
                np.Place_of_Birth__c=mapCtryListSet.get(pd.holderDetail.person.PlaceOfBirthCode).name;
            }
            if(pd.holderDetail.person.ResidenceaddressConutryCode!=null&&mapCtryListSet.containsKey(pd.holderDetail.person.ResidenceaddressConutryCode)){
                np.Residential_Address_Country__c=mapCtryListSet.get(pd.holderDetail.person.ResidenceaddressConutryCode).name;
            }
            if(pd.holderDetail.person.nationalityCode!=null&&mapCtryListSet.containsKey(pd.holderDetail.person.nationalityCode)){
                np.Nationality__c=mapCtryListSet.get(pd.holderDetail.person.nationalityCode).Nationality__c;
            }
            /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */

            np.Date_of_Birth__c = pd.holderDetail.person.birthDateInDate; //add by Andy
            np.ID_Type__c = 'HK PERM RESIDENT';
            
            np.Policy_Effective_Date__c = Date.today();
            
            //for AUW URL
            np.Application_Id__c = pd.UWApplicationId;
            
            //Add by Manuel for VHIS products
            if(np.Product_Code__c!=null&&mapPolicyValidationChecking.containsKey(np.Product_Code__c)){
                np.UW_Requirement__c = mapPolicyValidationChecking.get(np.Product_Code__c).UW_Requirement__c;
            }
            /* comment by Jack on 2022-01-14 for project: IA AML */
            // if(pd.holderDetail.person.placeOfResCode!=null&&mapCtryListSet.containsKey(pd.holderDetail.person.placeOfResCode)){
            //     np.Place_of_Residence_picklist__c = mapCtryListSet.get(pd.holderDetail.person.placeOfResCode).name; 
            // }
            if(pd.DiscountCode1!=null&&mapDiscountCode.containsKey(pd.DiscountCode1)){
                np.Discount_1__c = mapDiscountCode.get(pd.DiscountCode1).Description__c;
            }
            if(pd.DiscountCode2!=null&&mapDiscountCode.containsKey(pd.DiscountCode2)){
                np.Discount_2__c = mapDiscountCode.get(pd.DiscountCode2).Description__c;
            }
            
            //WEI-315
            if(pd.productCode.contains('PMGH')){
                if(String.isNotBlank(np.Discount_Code_1_to_IPAS__c) && mapDiscountCode.get(np.Discount_Code_1_to_IPAS__c)!=null){
                    np.Discount_1__c = mapDiscountCode.get(np.Discount_Code_1_to_IPAS__c).Description__c;
                }else if(String.isBlank(np.Discount_Code_1_to_IPAS__c)){
                    np.Discount_1__c = '';
                }
                
                if(String.isNotBlank(np.Discount_Code_2_to_IPAS__c) && mapDiscountCode.get(np.Discount_Code_2_to_IPAS__c)!=null){
                    np.Discount_2__c = mapDiscountCode.get(np.Discount_Code_2_to_IPAS__c).Description__c;
                }else if(String.isBlank(np.Discount_Code_2_to_IPAS__c)){
                    np.Discount_2__c = '';
                }
            }
            
            np.Master_Policy_No__c = pd.policy.policyNumber;
            
            if(referCaseRunningNumList.contains(pd.RunningNumber)){//refer policy
                np.Payment_Type__c = 'Direct Billing'; 
                np.Payment_Frequency__c = 'Annual'; 
                /*
                try{
                    if(String.isNotBlank(np.Personal_ID__c)){
                        system.debug('[TMWebsitCallListGenerateQueue].createPolicy() Get Bank Account Number from WS >> Personal Id : ' + np.Personal_ID__c );    
                        PersonCalloutHelper personCalloutHelper = new PersonCalloutHelper();
                        List<HttpCalloutVO.PersonPayment> personPaymentList = personCalloutHelper.getPersonPaymentBasic(np.Personal_ID__c);
                        if(!personPaymentList.isEmpty()){
                            HttpCalloutVO.PersonPayment pp = personPaymentList[0];
                            np.Bank_Account_No__c = pp.accountNumber;
                            np.Bank_Account_No_Mask__c = TMPolicyUtil.maskBankAccountNumber(pp.accountNumber);
                            np.Credit_Card_Number__c = pp.accountNumber;
                            np.Credit_Card_Number_Mask__c = TMPolicyUtil.maskBankAccountNumber(pp.accountNumber);
                            system.debug('[TMWebsitCallListGenerateQueue].createPolicy() Get Bank Account Number from WS Success>> Bank Acc No. : ' + pp.accountNumber);  
                        }
                    }
                }catch(Exception e){
                    system.debug('[TMWebsitCallListGenerateQueue].createPolicy() Get Bank Account Number from WS Error >> ' + e.getMessage());  
                }*/
            }
            
            //Add by Manuel 
            np.Appeal__c = 'Accept';
            np.Payment_Type__c = 'Cheque'; 
            np.Payment_Frequency__c = 'Annual'; 
            
            if(np.Date_of_Birth__c != null){
                Integer nowYear = Date.today().year();
                Integer nowMonth = Date.today().month();
                Integer nowDay = Date.today().day();

                Integer birthYear = np.Date_of_Birth__c.year();
                Integer birthMonth = np.Date_of_Birth__c.month();
                Integer birthDay = np.Date_of_Birth__c.day();

                Integer age = nowYear - birthYear;
                if(nowMonth <= birthMonth){
                    if(nowMonth == birthMonth){
                        if(nowDay < birthDay){
                            age--;
                        }
                    }else{
                        age--;
                    }
                }
                np.Age__c = age;
            }
            
            // for SPS-97 missing exclusion message
            np.Referral_Exclusion_Reason__c = pd.remarkDetails;
            /* add by Jack on 2021-10-28 for project: SUQ loading for drop-off */
            system.debug('pd.LoadingPremiumRate:'+pd.LoadingPremiumRate);
            if(String.isNotBlank(pd.LoadingPremiumRate)){
                np.Loading__c=Decimal.valueOf(pd.LoadingPremiumRate);
                system.debug('np.Loading__c:'+np.Loading__c);
            }
            
            //system.debug('[TMWebSitCallListGenerateQueue] create policy np.Referral_Exclusion_Reason_Long__c= '+np.Referral_Exclusion_Reason_Long__c);
            // for SPS-97 end
            
            //system.debug('[TMWebsitCallListGenerateQueue] HolderSSNPolicyNoMap= '+ HolderSSNPolicyNoMap);
            //system.debug('[TMWebsitCallListGenerateQueue] pd.holderDetail.person.ssnNumber= '+ pd.holderDetail.person.ssnNumber);
            np.Master_Policy_No__c = (String.isNotBlank(pd.holderDetail.person.ssnNumber) && String.isNotBlank(HolderSSNPolicyNoMap.get(pd.holderDetail.person.ssnNumber))) ? HolderSSNPolicyNoMap.get(pd.holderDetail.person.ssnNumber) : pd.policy.policyNumber;//fast fixing for AM extra issue jack add
            np.Master_Policy_No_Saved__c = np.Master_Policy_No__c;
            policyMap.put(key, np);
        
            //AM project jack add for opptunity AM field
            // for(HttpCalloutVO.PersonRelation pr : pd.insuredDetailList){
            //     HttpCalloutVO.Person person1 = pr.person;
            //     if(pr.relation.InsurableInterestReason=='Policy Holder'){
            //     // if(pr.relation.RelationRoleCode=='8'){
            //         if(person1.membership.channel=='M'){
            //             np.Asia_Miles_Membership_First_Name__c = person1.membership.membershipFirstName;
            //             np.Asia_Miles_Membership_Last_Name__c = person1.membership.membershipLastName;
            //             np.Asia_Miles_Membership_Num__c = person1.membership.membershipId;
            //         }
            //         break;
            //     }
            // }
            if(pd.holderDetail!=null && (pd.activityType=='Quote' || pd.activityType=='Contact' || pd.activityType=='ContactMe' || pd.holderDetail.relation.RelationRoleCode=='8')){
                HttpCalloutVO.Person holder = pd.holderDetail.person;
                if(holder.membership.channel=='M'){
                    np.Asia_Miles_Membership_First_Name__c = holder.membership.membershipFirstName;
                    np.Asia_Miles_Membership_Last_Name__c = holder.membership.membershipLastName;
                    np.Asia_Miles_Membership_Num__c = holder.membership.membershipId;
                }
            }
        }
        //system.debug('>>> policyMap: ' + policyMap);
        if(!policyMap.isEmpty()){
            insert policyMap.values();
        }
        
        //AM project coupon jack add insert coupon data for policy
        /* for(String key : applyPDMap.keySet()){
            HttpCalloutVO.ProspectDetail pd = applyPDMap.get(key);
            if(pd.policy.couponList.size()>0){
                New_policy__c newPolicy=policyMap.get(key);
                //check campaign sponsor code to set coupon status
                Campaign cam=actTypeProCodeCamMap.get(pd.campaignCode);
                String sponsorCode=cam.business_partner__r.Sponsor_Code__c;
                Boolean isCorrectCam=CouponUtil.checkcampaignScope(sponsorCode);
                for(Coupon coupon:pd.policy.couponList){
                    coupon.setPolicyId(newPolicy.Id);
                    if(!isCorrectCam){
                        coupon.setStatus('Invalid');
                    }
                }
                CouponUtil.saveCouponList(pd.policy.couponList);
            }
        } */
        //AM project coupon jack add

        // Create Person Insured / Plan Quote
        Map<String, Person_Insured__c> insuredMap = new Map<String, Person_Insured__c>();
        List<Plan_Quote__c> planQuoteList = new List<Plan_Quote__c>();
        
        List<New_Policy__c> toUpdateUrlPolicyList = new List<New_Policy__c>();
        
        for(String key : applyPDMap.keySet()){
            HttpCalloutVO.ProspectDetail pd = applyPDMap.get(key);
            Opportunity opp = oppMap.get(pd.RunningNumber);
            //if(opp == null){
                //opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
            //}
            
            while(opp == null && !runningNoChangingMap.isEmpty() && runningNoChangingMap.containsKey(pd.RunningNumber)){
                opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
                pd.RunningNumber = runningNoChangingMap.get(pd.RunningNumber);
            }
            if(opp == null){
                continue;
            }
            
            //Add by Manuel
            String idOfPhAsPi;
            for(HttpCalloutVO.PersonRelation pr : pd.insuredDetailList){
                if(pr.relation.InsurableInterestReason=='Policy Holder'){
                    idOfPhAsPi = pr.person.ssnNumber;
                }
            }
            
            for(HttpCalloutVO.PersonRelation pr : pd.insuredDetailList){
                HttpCalloutVO.Person person = pr.person;
                Person_Insured__c pi = new Person_Insured__c();
                pi.New_Policy__c = policyMap.get(key).id;
                pi.Insured_First_Name__c = person.firstName;
                pi.Insured_Last_Name__c = person.lastName;
                pi.Person_Insured_Name__c = person.fullName;
                pi.Date_of_Birth__c = person.birthDateInDate;
                pi.Personal_ID__c = person.ssnNumber;
                pi.Email__c = person.emailAddress;
                pi.gender__c = person.gender;
                pi.Position__c = person.title;
                pi.Corresponding_Address_1__c = person.addressLine1;
                pi.Corresponding_Address_2__c = person.addressLine2;
                pi.Corresponding_Address_3__c = person.addressLine3;
                pi.Corresponding_Address_4__c = person.addressLine4;
                /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
                if(person.PlaceOfBirthCode!=null&&mapCtryListSet.containsKey(person.PlaceOfBirthCode)){
                    pi.Place_of_Birth__c=mapCtryListSet.get(person.PlaceOfBirthCode).name;
                }
                if(person.ResidenceaddressConutryCode!=null&&mapCtryListSet.containsKey(person.ResidenceaddressConutryCode)){
                    pi.Residential_Address_Country__c=mapCtryListSet.get(person.ResidenceaddressConutryCode).name;
                }
                if(person.nationalityCode!=null&&mapCtryListSet.containsKey(person.nationalityCode)){
                    pi.Nationality__c=mapCtryListSet.get(person.nationalityCode).Nationality__c;
                }
                /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
                pi.Mobile_Phone__c = person.mobilePhoneNo;
                pi.Home_Phone__c = person.homePhoneNo;
                pi.Office_Phone__c = person.businessPhoneNo;
                pi.Benefit_Level__c = pd.planLevel ;
                /*if(!pi.Benefit_Level__c.isNumeric() && !'Completed'.equals(policyMap.get(key).Policy_Status__c)){
                    pi.Benefit_Level__c = hex2DecMap.get(pi.Benefit_Level__c);
                }*/
                pi.Smoker__c = pd.smokeInd?'yes':'no';
                pi.Basic_Plan__c = pd.policy.productCode; //Added by Andy
                
                pi.Height__c = Decimal.valueOf(String.isBlank(person.height) ? '0' : person.height);
                //pi.Height__c = 170;
                pi.Height_Unit__c = 'cm'; //default cm when return from WS
                pi.Weight__c = Decimal.valueOf(String.isBlank(person.weight) ? '0' : person.weight);
                //pi.Weight__c = 55;
                pi.Weight_Unit__c = 'kg'; //default kg when return from WS
                
                //Add by Manuel
                if(person.height!=null&&String.isNotBlank(person.height)){
                    pi.Height__c = Decimal.valueOf(person.height);
                }
                pi.Height_Unit__c = 'cm';
                if(person.weight!=null&&String.isNotBlank(person.weight)){
                    pi.Weight__c = Decimal.valueOf(person.weight);
                }
                pi.Weight_Unit__c = 'kg';
                /* comment by Jack on 2022-01-14 for project: IA AML */
                // if(person.placeOfResCode!=null&&mapCtryListSet.containsKey(person.placeOfResCode)){
                //     pi.Place_of_Residence_picklist__c = mapCtryListSet.get(person.placeOfResCode).name;
                // }
                
                //basic plan quote
                Plan_Quote__c planQuote = new Plan_Quote__c();
                planQuote.Policy__c = policyMap.get(key).id;
                planQuote.Product_Code__c = policyMap.get(key).Product_Code__c;
                planQuote.Product_Name__c = policyMap.get(key).Product_Name__c;
                planQuote.Is_Rider__c = false;
                planQuote.Plan_Level__c = pi.Benefit_Level__c;
                planQuoteList.add(planQuote);
                
                
                if(pi.Date_of_Birth__c != null){
                    Integer nowYear = Date.today().year();
                    Integer nowMonth = Date.today().month();
                    Integer nowDay = Date.today().day();

                    Integer birthYear = pi.Date_of_Birth__c.year();
                    Integer birthMonth = pi.Date_of_Birth__c.month();
                    Integer birthDay = pi.Date_of_Birth__c.day();

                    Integer age = nowYear - birthYear;
                    if(nowMonth <= birthMonth){
                        if(nowMonth == birthMonth){
                            if(nowDay < birthDay){
                                age--;
                            }
                        }else{
                            age--;
                        }
                    }
                    pi.PI_Age__c = age;
                }
                
                pi.ID_Type__c = 'HK PERM RESIDENT';
                
                //Comment by Manuel
                /*
                pi.Insured_Type__c = 'Dependent';
                pi.Relationship__c = 'Dependent';
                if(pi.Personal_ID__c == policyMap.get(key).Personal_ID__c){
                    pi.Insured_Type__c = 'PH = PI';
                    pi.Relationship__c = 'Policy Holder';
                }
                */
                
                //Add by Manuel
                pi.Relationship__c = pr.relation.InsurableInterestReason;
                if(pi.Relationship__c=='Policy Holder'){
                    pi.Insured_Type__c = 'PH = PI';
                }else if(pi.Relationship__c=='Spouse'){
                    pi.Insured_Type__c = 'Spouse';
                    //if(idOfPhAsPi!=null){
                        //pi.Spouse_PI_ID__c = idOfPhAsPi;
                        pi.Spouse_PI_ID__c = pd.holderDetail.person.ssnNumber;
                    //}
                }else if(pi.Relationship__c=='Son'||pi.Relationship__c=='Daughter'){
                    pi.Insured_Type__c = 'Dependent';
                    //if(idOfPhAsPi!=null){
                        //pi.Parent_PI_ID__c = idOfPhAsPi;
                        pi.Parent_PI_ID__c = pd.holderDetail.person.ssnNumber;
                    //}
                }else{
                    pi.Insured_Type__c = 'Dependent';
                }
                
                //AM project jack add for person insured AM fields
                if(person.membership.channel=='M'){
                    pi.Asia_Miles_Membership_First_Name__c = person.membership.membershipFirstName;
                    pi.Asia_Miles_Membership_Last_Name__c = person.membership.membershipLastName;
                    pi.Asia_Miles_Membership_Num__c = person.membership.membershipId;
                }
                
                List<String> riderList = new List<String>();
                if(String.isNotBlank(pd.rider1)){
                    riderList.add(pd.RiderPlanLevel1 + ':' + pd.rider1);
                    //rider 1 plan quote
                    Plan_Quote__c planQuote_rider1 = new Plan_Quote__c();
                    planQuote_rider1.Policy__c = policyMap.get(key).id;
                    planQuote_rider1.Product_Code__c = pd.rider1;
                    planQuote_rider1.Is_Rider__c = true;
                    planQuote_rider1.Plan_Level__c = pd.RiderPlanLevel1;
                    planQuote_rider1.Rate_Scale__c = pd.RiderPlanLevel1; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider1);
                }
                if(String.isNotBlank(pd.rider2)){
                    riderList.add(pd.RiderPlanLevel2 + ':' + pd.rider2);
                    //rider 1 plan quote
                    Plan_Quote__c planQuote_rider2 = new Plan_Quote__c();
                    planQuote_rider2.Policy__c = policyMap.get(key).id;
                    planQuote_rider2.Product_Code__c = pd.rider2;
                    planQuote_rider2.Is_Rider__c = true;
                    planQuote_rider2.Plan_Level__c = pd.RiderPlanLevel2;
                    planQuote_rider2.Rate_Scale__c = pd.RiderPlanLevel2; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider2);
                }
                if(String.isNotBlank(pd.rider3)){
                    riderList.add(pd.RiderPlanLevel3 + ':' + pd.rider3);
                    //rider 1 plan quote
                    Plan_Quote__c planQuote_rider3 = new Plan_Quote__c();
                    planQuote_rider3.Policy__c = policyMap.get(key).id;
                    planQuote_rider3.Product_Code__c = pd.rider3;
                    planQuote_rider3.Is_Rider__c = true;
                    planQuote_rider3.Plan_Level__c = pd.RiderPlanLevel3;
                    planQuote_rider3.Rate_Scale__c = pd.RiderPlanLevel3; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider3);
                }
                if(String.isNotBlank(pd.rider4)){
                    riderList.add(pd.RiderPlanLevel4 + ':' + pd.rider4);
                    //rider 1 plan quote
                    Plan_Quote__c planQuote_rider4 = new Plan_Quote__c();
                    planQuote_rider4.Policy__c = policyMap.get(key).id;
                    planQuote_rider4.Product_Code__c = pd.rider4;
                    planQuote_rider4.Is_Rider__c = true;
                    planQuote_rider4.Plan_Level__c = pd.RiderPlanLevel4;
                    planQuote_rider4.Rate_Scale__c = pd.RiderPlanLevel4; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider4);
                }
                if(String.isNotBlank(pd.rider5)){
                    riderList.add(pd.RiderPlanLevel5 + ':' + pd.rider5);
                    //rider 1 plan quote
                    Plan_Quote__c planQuote_rider5 = new Plan_Quote__c();
                    planQuote_rider5.Policy__c = policyMap.get(key).id;
                    planQuote_rider5.Product_Code__c = pd.rider5;
                    planQuote_rider5.Is_Rider__c = true;
                    planQuote_rider5.Plan_Level__c = pd.RiderPlanLevel5;
                    planQuote_rider5.Rate_Scale__c = pd.RiderPlanLevel5; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider5);
                }if(String.isNotBlank(pd.rider6)){
                    riderList.add(pd.RiderPlanLevel6 + ':' + pd.rider6);
                    //rider 1 plan quote
                    Plan_Quote__c planQuote_rider6 = new Plan_Quote__c();
                    planQuote_rider6.Policy__c = policyMap.get(key).id;
                    planQuote_rider6.Product_Code__c = pd.rider6;
                    planQuote_rider6.Is_Rider__c = true;
                    planQuote_rider6.Plan_Level__c = pd.RiderPlanLevel6;
                    planQuote_rider6.Rate_Scale__c = pd.RiderPlanLevel6; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider6);
                }if(String.isNotBlank(pd.rider7)){ //Combo: maybe 7 riders -20201209
                    riderList.add(pd.RiderPlanLevel7 + ':' + pd.rider7);
                    Plan_Quote__c planQuote_rider7 = new Plan_Quote__c();
                    planQuote_rider7.Policy__c = policyMap.get(key).id;
                    planQuote_rider7.Product_Code__c = pd.rider7;
                    planQuote_rider7.Is_Rider__c = true;
                    planQuote_rider7.Plan_Level__c = pd.RiderPlanLevel7;
                    planQuote_rider7.Rate_Scale__c = pd.RiderPlanLevel7; // <RateScale> in setNBComplete is using Plan_Quote__c.Rate_Scale__c as the value (for rider)
                    planQuoteList.add(planQuote_rider7);
                }


                pi.Rider__c = String.join(riderList, ';');
                //system.debug('[TMWebisitCallListGenerateQueue] pi.Rider__c= '+pi.Rider__c);
                
                //Combo Product Declaration
                //Combo change Declaration field type
                //system.debug('[TMWebSitCallListGenerateQueue] createPolicy pd.planDeclaration='+pd.planDeclaration);
                if(String.isNotBlank(pd.planDeclaration)){
                    for(String planAns : pd.planDeclaration.split(';')){
                        if(String.isNotBlank(planAns) && planAns.contains(':')){
                            String[] planCodeAns = planAns.split(':');
                            String planCode = planCodeAns[0];
                            String Ans = planCodeAns[1];
                            if(planCode == 'CCAG' && Ans == 'Y'){
                                pi.Cancer_Declaration__c = 'Yes';
                            }else if(planCode == 'CCAG' && Ans == 'N'){
                                pi.Cancer_Declaration__c = 'No';
                            }

                            /* add by Jack on 2022-04-11 for project: Separation project - TM remove CADG in COMBO */
                            // if(planCode == 'CADG' && Ans == 'Y'){
                            //     pi.Accident_Declaration__c = 'Yes';
                            // }else if(planCode == 'CADG' && Ans == 'N'){
                            //     pi.Accident_Declaration__c = 'No';
                            // }
                        }
                    }
                }
                //system.debug('[TMWebSitCallListGenerateQueue] createPolicy pi.Cancer_Health_Declaration__c='+pi.Cancer_Declaration__c);
                //system.debug('[TMWebSitCallListGenerateQueue] createPolicy pi.Accident_Declaration__c='+pi.Accident_Declaration__c);
                //Combo Product Declaration
                
                insuredMap.put(key, pi);
                
                New_Policy__c toUpdatePolicy = policyMap.get(key);
                /*String att = '';
                att += 'Person_Insured_Name__c' + ':' + pi.Insured_Last_Name__c + ' ' + pi.Insured_First_Name__c +';';
                att += 'Date_of_Birth__c' + ':' + pi.Date_of_Birth__c + ';';
                att += 'Personal_ID__c' + ':' + pi.Personal_ID__c + ';';
                att += 'Height__c' + ':' + pi.height__c + ';';
                att += 'Weight__c' + ':' + pi.weight__c + ';';
                att += 'Gender__c' + ':' + pi.Gender__c + ';';
                att += 'Smoker__c' + ':' + pi.Smoker__c + ';';
                att += 'Product_Code__c' + ':' + policyMap.get(key).Product_Code__c;
                
                toUpdatePolicy.Presales_Result_Attribute__c  = att;
                
                toUpdateUrlPolicyList.add(toUpdatePolicy);*/
                
                if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED.equals(toUpdatePolicy.Pre_Sales_Result__c) || TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED.equals(toUpdatePolicy.Pre_Sales_Result__c)){
                    String att = '';
                    att += 'Person_Insured_Name__c' + ':' + pi.Insured_Last_Name__c + ' ' + pi.Insured_First_Name__c +';';
                    att += 'Date_of_Birth__c' + ':' + pi.Date_of_Birth__c + ';';
                    att += 'Personal_ID__c' + ':' + pi.Personal_ID__c + ';';
                    att += 'Height__c' + ':' + pi.height__c + ';';
                    att += 'Weight__c' + ':' + pi.weight__c + ';';
                    att += 'Gender__c' + ':' + pi.Gender__c + ';';
                    att += 'Smoker__c' + ':' + pi.Smoker__c + ';';
                    att += 'Product_Code__c' + ':' + policyMap.get(key).Product_Code__c + ';';
                    att += 'Sum_Insured__c' + ':' + policyMap.get(key).Sum_Insured__c;// Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
                    
                    toUpdatePolicy.Presales_Result_Attribute__c  = att;
                }
                /* add by Jack on 2022-09-23 for project: fix for empty Relationship_Of_Policy__c of policy */
                toUpdatePolicy.Relationship_Of_Policy__c = relationshipMap.get(pi.Relationship__c);
                toUpdateUrlPolicyList.add(toUpdatePolicy);
            }
        }
        //system.debug('>>> insuredMap: ' + insuredMap);
        if(!insuredMap.isEmpty()){
            insert insuredMap.values();
            insert planQuoteList;
        }
        
        if(!toUpdateUrlPolicyList.isEmpty()){
            update toUpdateUrlPolicyList;
        }
        
        // Create Beneficiary
        Map<String, Beneficiary__c> beneficiaryMap = new Map<String, Beneficiary__c>();
        for(String key : applyPDMap.keySet()){
            HttpCalloutVO.ProspectDetail pd = applyPDMap.get(key);
            Opportunity opp = oppMap.get(pd.RunningNumber);
            //if(opp == null){
                //opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
            //}
            
            while(opp == null && !runningNoChangingMap.isEmpty() && runningNoChangingMap.containsKey(pd.RunningNumber)){
                opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
                pd.RunningNumber = runningNoChangingMap.get(pd.RunningNumber);
            }
            if(opp == null){
                continue;
            }
            for(HttpCalloutVO.PersonRelation pr : pd.beneficiaryDetailList){
                HttpCalloutVO.Person person = pr.person;
                Beneficiary__c bene = new Beneficiary__c();
                bene.Policy__c = policyMap.get(key).id;
                bene.Person_Insured__c = insuredMap.get(key).Id;
                bene.First_Name__c = person.firstName;
                bene.Last_Name__c = person.lastName;
                bene.Gender__c = person.gender;
                bene.Person_ID__c = person.ssnNumber;
                
                beneficiaryMap.put(key, bene);
            }
        }
        //system.debug('>>> beneficiaryMap: ' + beneficiaryMap);
        if(!beneficiaryMap.isEmpty()){
            insert beneficiaryMap.values();
        }
        
        
        // Create UW Result
        Map<String, UW_Result__c> uwMap = new Map<String, UW_Result__c>();
        List<UW_Result__c> riderUWList = new List<UW_Result__c>(); //add at 20190430
        for(String key : applyPDMap.keySet()){
            HttpCalloutVO.ProspectDetail pd = applyPDMap.get(key);
            Opportunity opp = oppMap.get(pd.RunningNumber);
            //if(opp == null){
                //opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
            //}
            
            while(opp == null && !runningNoChangingMap.isEmpty() && runningNoChangingMap.containsKey(pd.RunningNumber)){
                opp = oppMap.get(runningNoChangingMap.get(pd.RunningNumber));
                pd.RunningNumber = runningNoChangingMap.get(pd.RunningNumber);
            }
            if(opp == null){
                continue;
            }
            for(HttpCalloutVO.PersonRelation pr : pd.insuredDetailList){
                UW_Result__c uw = new UW_Result__c();
                uw.Application_Id__c = policyMap.get(key).id + '_' + DateTime.now().formatGmt('yyyyMMddHHmmss');
                uw.Full_Result__c = uwResultMap.get(pd.FinalUWResult);
                uw.Presales_Result__c = uwResultMap.get(pd.PresalesResult);
                uw.Overrall_Result__c = uwResultMap.get(pd.finalResult);
                uw.Policy__c = policyMap.get(key).id;
                uw.Person_Insured__c = insuredMap.get(key).Id;
                //add by Andy, init Is_Basic_Plan__c to true;
                uw.Is_Basic_Plan__c = true; 
                if(String.isNotBlank(pd.LoadingPremiumRate)){
                    uw.Loading__c=Decimal.valueOf(pd.LoadingPremiumRate);/* add by Jack on 2021-10-28 for project: SUQ loading for drop-off */
                }
                uwMap.put(key, uw);
                
                // for SPS-97 missing exclusion message
                for(HttpCalloutVO.UWExclusionDetail exclusion : pd.exclusionDetails){
                    if(String.isBlank(uw.UW_Excl_1__c)){
                        uw.UW_Excl_1__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_2__c)){
                        uw.UW_Excl_2__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_3__c)){
                        uw.UW_Excl_3__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_4__c)){
                        uw.UW_Excl_4__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_5__c)){
                        uw.UW_Excl_5__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_6__c)){
                        uw.UW_Excl_6__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_7__c)){
                        uw.UW_Excl_7__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_8__c)){
                        uw.UW_Excl_8__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_9__c)){
                        uw.UW_Excl_9__c = exclusion.detail;
                    }else if(String.isBlank(uw.UW_Excl_10__c)){
                        uw.UW_Excl_10__c = exclusion.detail;
                    }
                }
                
                for(HttpCalloutVO.UWExclusionDetail remark : pd.remarkDetailsList){
                    if(String.isBlank(uw.UW_Remark_1__c)){
                        uw.UW_Remark_1__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_2__c)){
                        uw.UW_Remark_2__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_3__c)){
                        uw.UW_Remark_3__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_4__c)){
                        uw.UW_Remark_4__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_5__c)){
                        uw.UW_Remark_5__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_6__c)){
                        uw.UW_Remark_6__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_7__c)){
                        uw.UW_Remark_7__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_8__c)){
                        uw.UW_Remark_8__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_9__c)){
                        uw.UW_Remark_9__c = remark.detail;
                    }else if(String.isBlank(uw.UW_Remark_10__c)){
                        uw.UW_Remark_10__c = remark.detail;
                    }
                }
                // for SPS-97 end
                
                //add by kermit at 20190430
                Person_Insured__c pi = insuredMap.get(key);
                for(String reader : pi.Rider__c.split(';')){
                    if(String.isNotBlank(reader)){
                        String ridercode = reader.split(':')[1];
                        UW_Result__c ruw = new UW_Result__c();
                        ruw.Application_Id__c = policyMap.get(key).id + '_' + DateTime.now().formatGmt('yyyyMMddHHmmss');
                        ruw.Full_Result__c = uwResultMap.get(pd.FinalUWResult);
                        ruw.Presales_Result__c = uwResultMap.get(pd.PresalesResult);
                        ruw.Overrall_Result__c = uwResultMap.get(pd.finalResult);
                        ruw.Policy__c = policyMap.get(key).id;
                        ruw.Person_Insured__c = pi.Id;
                        ruw.Is_Basic_Plan__c = false;
                        ruw.Product_Code__c = ridercode;
                        ruw.Submission_Date_Time__c = DateTime.valueOf(pd.SubmissionDate + ' ' + pd.SubmissionTime);
                        //system.debug('[TMWebSitCallListGenerateQueue] ruw='+ruw);
                        riderUWList.add(ruw);
                    }
                }
                //end add
            }
        }
        //system.debug('>>> uwMap: ' + uwMap);
        if(!uwMap.isEmpty()){
            insert uwMap.values();
        }
        //system.debug('[TMWebSitCallListGenerateQueue] riderUWList='+riderUWList);
        if(!riderUWList.isEmpty()){
            insert riderUWList;
        }
        
        
        //Auto log a 400 term code call record for refer case oppty
        //comment by kermit at 20190321, shouldn't auto log a call util manager assign the oppty to agent.(this part is not completed at 0321)
        /*if(!referCaseList.isEmpty()){
            List<String> relatedOpptyIdList = new List<String>();
            for(policy_transaction__c pt : referCaseList){
                relatedOpptyIdList.add(pt.Opportunity__c);
            }
            
            List<Task> callList = new List<Task>();
            RecordType rt = [select Id, Name, developerName from RecordType where sobjectType = 'Task' and developerName = 'TM_Call'];
            for(String i : relatedOpptyIdList){
                Task successCall = new Task();
                successCall.recordTypeId = rt.id;
                successCall.calldurationinseconds  = 0;
                successCall.Result__c = '400 - Success';
                successCall.Overall_Opt_in_Opt_out__c = 'Opt-In';
                successCall.whatId = i;
                successCall.Subject = 'Call';
                successCall.Status = 'Completed';
                callList.add(successCall);
            }
            insert callList;
            
            
        }*/
    }
    
    public void createCheckingLog(String functionName, List<HttpCalloutVO.ProspectDetail> details, String LineNumber, String StackTrace, String ErrorMessage){
        Checking_Log__c clog = new Checking_Log__c();
            //clog.Function_Name__c = 'TMWebsitCallListGenerateQueue.createOpportunity';
            clog.Function_Name__c = functionName;
            List<String> runningNos = new List<String>();
            List<String> ssns = new List<String>();
            List<String> phoneNos = new List<String>();
            List<String> policyNos = new List<String>();
            for(HttpCalloutVO.ProspectDetail pd : details){
                runningNos.add(pd.RunningNumber);
                policyNos.add(pd.policy.policyNumber);
                if(!pd.insuredDetailList.isEmpty() && pd.insuredDetailList.get(0).person!=null){
                    ssns.add(pd.insuredDetailList.get(0).person.ssnNumber);
                    phoneNos.add(pd.insuredDetailList.get(0).person.mobilePhoneNo);
                }
            }
            clog.Policy_No_in_the_Batch__c = String.join(policyNos, ';');
            clog.Running_No_in_the_Batch__c = String.join(runningNos, ';');
            clog.SSN_in_the_Batch__c = String.join(ssns, ';');
            clog.Phone_No_in_the_Batch__c = String.join(phoneNos, ';');
            clog.ErrorMessage_Long__c = ErrorMessage;
            clog.TmpString1__c = LineNumber;
            clog.TmpString2__c = StackTrace;
            clog.TmpString3__c = String.join(activityIdList, ',') + String.join(activityTypeList, ',');
            clog.UserInfo_String__c = userInfo.getUserId();
            insert clog;
    }

    @future
    public static void insertCheckinglog(String functionName,List<String> errMessage,List<String> runningNoList,List<String> tmpString){
        List<Checking_Log__c> checkingLogList = new List<Checking_Log__c>();
        for(Integer i=0; i<errMessage.size(); i++){
            Checking_Log__c clog = new Checking_Log__c();
            clog.Function_Name__c = functionName;   
            clog.ErrorMessage_Long__c = errMessage[i];
            cLog.Running_No_in_the_Batch__c = runningNoList[i];
            cLog.TmpString1__c = tmpString[i];
            clog.UserInfo_String__c = userInfo.getUserId();
            checkingLogList.add(cLog);
        }
        if(checkingLogList.size() > 0){
            insert checkingLogList;
        }
    }
}