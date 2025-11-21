/*********************************************************************************
 * Name: ManagePolicyChangeCRTL
 *
 * Version History
 * Version           Author                 Date                      Description
 * ---------------  --------------------    -----------------------  ---------------------------------------------------------
 * V1.0             Kevani Chow            2016-11-03                Control Policy Change flow and trigger save function of forms
*********************************************************************************/
public without sharing class ManagePolicyChangeCRTL{

    /*User language for validation*/
    public String userLanguage{get;set;}
    public String userFullName{get;set;}
    public String userEmail{get;set;}

    /*for login id/hold SSN to get policy information*/
    public String PolicyHolderLoginIn{get;set;}
    public String PolicyHolderId{get;set;}
    public String Policyholder{get;set;}
    public Boolean policyHolderSelected{get;set;}
    public String PolicyHolderEmail{get;set;}
    public String fromPolicyChangelist{get;set;}
    public String fromTab{get;set;}

    public Policy_Change_Request__c Request{get;set;}
    public Policy_Change_Request_Detail__c RequestDetail{get;set;}
    public List<RecordType> requestRT{get;set;}
    public List<Policy_Change_Request_Detail__c> ListRequestDetail{get;set;}
    public List<Policy_Change_Request_Detail__c> ListAppFundDetail{get;set;}
    public List<Policy_Change_Request_Detail__c> ListBenefitSumInsured{get;set;}
    public List<Policy_Change_Request_Detail__c> ListBenefitRider{get;set;}
    public List<Policy_Change_Request_Detail__c> ListBenefitSingle{get;set;}
    public List<Policy_Change_Request_Detail__c> ListBenefitRegular{get;set;}

    public String deleteBenefitDetailId{get;set;}
    public Integer rowIndex{get;set;}
    public String deleteReqDetailId{get;set;}
    public List<Policy> ListPolicy{get;set;}
    public Boolean hasNoPolicy{get;set;}

    /*for displaying policy holder and policy Insured*/
    public Map<string,Policy> mapPolicyHolder{get;set;}
    public Map<string,PolicyInsured> mapPolicyInsured{get;set;}
    public List<PolicyInsured> ListPolicyInsured{get;set;}


    public String changeType{get;set;}
    public Boolean hasChangeType{get;set;}
    public Boolean hasPolicy{get;set;}
    public Boolean hasAvailablePolicy{get;set;}

    public Boolean multiPolicy{get;set;}
    public set<string> setMultiPolicyChoice{get;set;}
    public String PolicyChoice{get;set;}

    public Boolean hasPolicyMember{get;set;}
    public String policyMemberName{get;set;}
    public String policyMemberId{get;set;}
    public Boolean hasPolicyMemberName{get;set;}

    public Decimal currentStep{get;set;}
    public String sitePrefix{get;set;}

    /*for update policy change*/
    public String policyChangeId{get;set;}

    /*For upload attachment*/
    public String removeAttId{get;set;}
    public Boolean hasAtt{get;set;}

    /*Boolean Flag to control Attachement display*/
    public Boolean currentPhAddProof{get;set;}
    public Boolean currentPhIdCopy{get;set;}
    public Boolean currentPiAddProof{get;set;}
    public Boolean currentPiIdCopy{get;set;}
    public Boolean PhPiAddProof{get;set;}
    public Boolean PhPiIdCopy{get;set;}
    public Boolean newPHIdCopy{get;set;}
    public Boolean newPHAddProof{get;set;}
    public Boolean FNA{get;set;}
    public Boolean thirdPartyAddProof{get;set;}
    public Boolean thirdPartyIdCopy{get;set;}
    public Boolean deedPoll{get;set;}
    public Boolean riskProfileQuestion{get;set;}
    public Boolean IsPersonalParti{get;set;}
    public Boolean IsAddress{get;set;}
    public Boolean IsThirdParty{get;set;}
    public Boolean requireAtt{get;set;}

    /*Boolean Flag for Download Docuement*/
    public Boolean isGoldMedal{get;set;}
    public Boolean isGoldMedalPlus{get;set;}
    public Boolean isJuniorCare{get;set;}
    public Boolean isPlatinumMedal{get;set;}
    public Boolean isCignaInvestPlusLife{get;set;}
    public Boolean isDownload{get;set;}

    /*Document link*/
    public String DocGoldMedalPlan{get;set;}
    public String DocJuniorCare{get;set;}
    public String DocGoldMedalPlanPlus{get;set;}
    public String DocPlatinumMedalPlan{get;set;}
    public String DocCignaInvestPlusLife{get;set;}

    /*For Selected Policy Change Type*/
    public Boolean IsPersonal{get;set;}
    public Boolean IsBeneficiary{get;set;}
    public Boolean IsOwner{get;set;}
    public Boolean IsDD{get;set;}
    public Boolean IsCopyDoc{get;set;}
    public Boolean IsRenew{get;set;}
    public Boolean IsBenefit{get;set;}
    public Boolean IsApp{get;set;}

    /*For Payment Information (DD)*/
    public Boolean IsAlertThirdParty{get;set;}

    /*For Date of Birth Value*/
    public String ddDOB{get;set;}
    public String mmDOB{get;set;}
    public String yyyyDOB{get;set;}

    /*For Credit Card No Value*/
    public String creditCardNo1{get;set;}
    public String creditCardNo2{get;set;}
    public String creditCardNo3{get;set;}
    public String creditCardNo4{get;set;}
    public String savedCreditCardWithMask{get;set;}

    /* APP Fund List */
    public List<SelectOption> fundSequence{get;set;}
    public String PriceType_BasicPlan{get{return 'B';} set;}
    public List<HttpCalloutVO.PolicyAvailFund> policyAvailFundList{get;set;}
    public Map<String,HttpCalloutVO.PolicyAvailFund> availFundMap{get;set;}
    public String policyPaymentPaidToDate{get;set;}
    public Map<String,ILAS_Plan_Code_Mapping__c> planCodeMap{get;set;}

    /* Benefit Sum Insured List */
    public List<SelectOption> availBenefitSumInsuredOptions{get;set;}
    public Map<String,HttpCalloutVO.PolicyPersonCoverage> availBenefitMap{get;set;}
    public List<HttpCalloutVO.PolicyPersonCoverage> policyAvailBenefitList{get;set;}
    public Boolean hasBenefit{get;set;}

    /* Benefit Addtional Contribution */
    public List<SelectOption> availFundOptions{get;set;}

    /*e-signature*/
    public Transient String eSignature{get;set;}
    public Transient String eSignature2{get;set;}
    public String esignatureEmail{get;set;}

    /*Flags to indicate the hidden and display policy or fields*/
    public Boolean isAllowChangePaymentDate{get;set;}
    public Boolean isHasBroker{get;set;}
    public Boolean isLife{get;set;}
    public Boolean isGeneral{get;set;}
    public Boolean isIlas{get;set;}

    /*map ad string of policy list by criteria*/
    public List<Policy> ListAvaliblePolicy{get;set;}
    public map<String,Policy> mapAllowChangePaymentdatePolicy{get;set;}
    public map<String,Policy> mapHasBrokerPolicy{get;set;}
    public map<String,Policy> mapIsLifePolicy{get;set;}
    public map<String,Policy> mapIsGeneralPolicy{get;set;}
    public map<String,Policy> mapIsIlasPolicy{get;set;}
    public set<String> setIsNotIPMIPolicy{get;set;}
    public String strAllowChangePolicy{get;set;}
    public String strHasBrokerPolicy{get;set;}
    public String strIsLifePolicy{get;set;}
    public String strIsGeneralPolicy{get;set;}

    /* Datepicker variables */
    public Long medReportExamDateTimestamp{get;set;}
    public Long phyStatementDateTimestamp{get;set;}
    public Long incorporationDateTimestamp{get;set;}

    /*Email Flag*/
    public Boolean FromEmail{get;set;}

    /* Broker Info */
    public String BrokerName{get;set;}
    public String ConsultantName{get;set;}
    public String ConsultantCode{get;set;}
    public String ConsultantContact{get;set;}
    public List<User> ListUserInfo{get;set;}

    //chris_SPS-421_2020_05_20
    public String brokerEsignEmail{get;set;}

    //add Bob ThirdParty-PayerRelationship List
    public List<SelectOption> ThirdPartyRelationshipList{get{
        Map<String,Map<String,String>> transFieldEsales=new Map<String,Map<String,String>>();
        for(Translate__mdt t : [select DeveloperName,zh_TW__c,en_US__c from Translate__mdt where Category__c='Esales']){
            // system.debug(t.DeveloperName);
            transFieldEsales.put(t.DeveloperName,new Map<String,String>{'zh_TW'=> t.zh_TW__c,'en_US'=> t.en_US__c });
        }
        String langStr=UserInfo.getLanguage();
        thirdPartyRelationshipList=new List<SelectOption>();
        thirdPartyRelationshipList.add(new SelectOption('',Label.eSales_None));
        thirdPartyRelationshipList.add(new SelectOption(transFieldEsales.get('Child').get('en_US'),transFieldEsales.get('Child').get(langStr)));
        thirdPartyRelationshipList.add(new SelectOption(transFieldEsales.get('Parent').get('en_US'),transFieldEsales.get('Parent').get(langStr)));
        thirdPartyRelationshipList.add(new SelectOption('Spouse',Label.eSales_Spouse));
        return thirdPartyRelationshipList;
    } set;}

    /*PDF*/
    public Transient Blob policychangePDF{get;set;}

    // 20200306 - minghua - ILAS 20200610 - minghua - levyII
    public String policyHolderSSN{get;set;}
    public String customerUserId{get;set;}

    // Rancho_IA_AML_Inspection_20211005
    public List<SelectOption> countryList{get;set;}
    public Map<String,String> countryEnMap{get;set;}
    public Map<String,String> countryZhMap{get;set;}
    public List<SelectOption> nationalityList{get;set;}
    public Map<String,String> nationalityEnMap{get;set;}
    public Map<String,String> nationalityZhMap{get;set;}
    public static final String CHINA= '86';
    public static final String HONGKONG= '852';
    public static final String MACAU= '853';
    //Link_IA_AML_Inspection_20211229 start
    public List<String> isSanctionCodeListNa{get;set;}
    public List<String> isSanctionCodeListCou{get;set;}
    //Link_IA_AML_Inspection_20211229 end

    public Map<String,Map<String,String>> transField{
        get{
            if(transField==null){
                transField=new Map<String,Map<String,String>>();
                for(Translate__mdt t : [select DeveloperName,zh_TW__c,en_US__c from Translate__mdt where Category__c='RPQResult' OR Category__c='LevyII' or Category__c='WhatApp' or Category__c='Esales']){//GL31 jack add
                    transField.put(t.DeveloperName,new Map<String,String>{'zh_TW'=> t.zh_TW__c,'en_US'=> t.en_US__c });
                }
            }
            return transField ;
        }
        set;
    }

    // 20210820 - Kirk - Epic 113178-Invesco fund merger
    public Map<String, ILAS_fund_risk_level__c> iLASPlanCodesRiskSellMap{ 
        get{
            if(iLASPlanCodesRiskSellMap == null){
                iLASPlanCodesRiskSellMap = new Map<String, ILAS_fund_risk_level__c>();
                List<ILAS_fund_risk_level__c> ilasPlanCodeList =ILAS_fund_risk_level__c.getAll().values();
                if(ilasPlanCodeList != null && !ilasPlanCodeList.isEmpty()){
                    for(ILAS_fund_risk_level__c ilasPlanCode: ilasPlanCodeList){
                        if(ilasPlanCode.Sell_Expired_Date__c==null || ilasPlanCode.Sell_Expired_Date__c>Date.today()){
                            iLASPlanCodesRiskSellMap.put(ilasPlanCode.Reference_Code__c,ilasPlanCode);
                        }
                    }
                }
            }
            return iLASPlanCodesRiskSellMap;
        }
        set; 
    }

    // 20210830 - Kirk - additional contribution
    public Map<String, ILAS_fund_risk_level__c> iLASPlanCodesRiskDiscMap{ 
        get{
            if(iLASPlanCodesRiskDiscMap == null){
                iLASPlanCodesRiskDiscMap = new Map<String, ILAS_fund_risk_level__c>();
                List<ILAS_fund_risk_level__c> ilasPlanCodeList =ILAS_fund_risk_level__c.getAll().values();
                if(ilasPlanCodeList != null && !ilasPlanCodeList.isEmpty()){
                    for(ILAS_fund_risk_level__c ilasPlanCode: ilasPlanCodeList){
                        if(ilasPlanCode.Discontinued_Date__c==null || ilasPlanCode.Discontinued_Date__c>Date.today()){
                            iLASPlanCodesRiskDiscMap.put(ilasPlanCode.Reference_Code__c,ilasPlanCode);
                        }
                    }
                }
            }
            return iLASPlanCodesRiskDiscMap;
        }
        set; 
    }

    //JR1840 jack add
    public String encryptedSearchCriteria{get;private set;}
    public final String URLParamName{get;private set;}{URLParamName='FLTR';}
    
    //GL31 jack add
    public Map<String,String> assessAllRiderMap=new Map<String,String>();
    public Map<String,String> assessRiderMap{get;set;}
    public List<ESaleQuestion> assessmentQuestionList{get;set;}
    public static String selectedProductCode='';
    public String basicProductCode='';
    Map<String,Set<String>> assessMap;
    public List<SelectOption> riderOption{get;set;}
    public List<SelectOption> existRiderOption{get;set;}
    public final String riderSperator{get; private set;}{riderSperator=' / ';}
    
    // FileScanning_Link_20220530
    public Boolean scanPopup{get;set;}
    
    public String entityName { get; set; } //JOBR-184: JOBR-199 added by Kermit
    public String entityNameForNote { get; set; } // JOBR-184;
    
    public ManagePolicyChangeCRTL(ApexPages.StandardController controller){
        policyHolderSSN=''; //20200306 - minghua - ILAS
        customerUserId='';
        if(CignaUtil.isCustomerPortal()){
            sitePrefix='/customer';
            //20200306 - minghua - ILAS
            Id holderContactId = [Select Id,ContactId From User Where Id = :Userinfo.getUserId()].ContactId;
            Id holderAccountId = [Select Id,AccountId From Contact Where Id = :holderContactId].AccountId;
            policyHolderSSN = [Select Id,SSN__c From Account Where Id = :holderAccountId].SSN__c;
            customerUserId = Userinfo.getUserId();
        }else{
            sitePrefix='/broker';
        }

        this.userLanguage=UserInfo.getLanguage();
        this.userFullName=UserInfo.getName();

        if(ApexPages.currentPage().getParameters().get('pcid')!=null&&ApexPages.currentPage().getParameters().get('pcid')!=''){
            policyChangeId=ApexPages.currentPage().getParameters().get('pcid');
        }
        
        /*For Broker use*/
        if(ApexPages.currentPage().getParameters().get('phid')!=null&&ApexPages.currentPage().getParameters().get('phid')!=''){
            PolicyHolderId=ApexPages.currentPage().getParameters().get('phid');
            system.debug('policyHolderId: '+policyHolderId);
            //20200306 - minghua - ILAS
            policyHolderSSN=PolicyHolderId;
            if(String.isNotBlank(policyHolderSSN)){
                List<User> u=[select id,Name,Username,Account.SSN__c From User where Account.SSN__c=: policyHolderSSN];
                if(u.size()>0){
                    customerUserId=u[0].id;
                }
            }
        }else{
            PolicyHolderId='';
        }
        policyHolderSSN=RPQFormController.encryptRPQSSN(policyHolderSSN);//add by jack ILAS
        system.debug('policyHolderSSN:'+policyHolderSSN);
        if(ApexPages.currentPage().getParameters().get('phname')!=null&&ApexPages.currentPage().getParameters().get('phname')!=''){
            Policyholder=ApexPages.currentPage().getParameters().get('phname').replace('%20',' ');
        }
        if(ApexPages.currentPage().getParameters().get('phemail')!=null&&ApexPages.currentPage().getParameters().get('phemail')!=''){
            String PolicyHolderEmailEncode=ApexPages.currentPage().getParameters().get('phemail');
            PolicyHolderEmail=PolicyHolderEmailEncode;
        }

        if(CignaUtil.isCustomerPortal()){
            this.userEmail=UserInfo.getUserName();
        }else{
            this.userEmail=PolicyHolderEmail;
        }
        if(ApexPages.currentPage().getParameters().get('pclist')!=null&&ApexPages.currentPage().getParameters().get('pclist')!=''){
            fromPolicyChangelist=ApexPages.currentPage().getParameters().get('pclist');
        }
        if(ApexPages.currentPage().getParameters().get('tab')!=null&&ApexPages.currentPage().getParameters().get('tab')!=''){
            fromTab=ApexPages.currentPage().getParameters().get('tab');
        }

        currentStep=0;
        setMultiPolicyChoice=new set<string>();
        PolicyChoice='';
        hasPolicy=false;
        policyMemberName='';
        hasPolicyMemberName=false;
        hasPolicyMember=false;
        isLife=false;
        isIlas=false;
        hasBenefit=false;

        ListPolicy=new List<Policy>();
        hasNoPolicy=false;
        policyPaymentPaidToDate='';
        BrokerName='';
        ConsultantName='';
        ConsultantCode='';
        ConsultantContact='';
        ListUserInfo=new List<User>();

        //JR1840 jack add
        String encryptedFilter=ApexPages.currentpage().getparameters().get(URLParamName);
        System.debug('encryptedFilter'+encryptedFilter);
        if(!String.isEmpty(encryptedFilter)){
            encryptedSearchCriteria=EncodingUtil.urlEncode(encryptedFilter,'UTF-8');
        }
        //JR1840 jack add

        // Rancho_IA_AML_Inspection_20211005: init country list
        setNationalityListInfo();
        setCountryListInfo();
    }

    public Id getRecordType(String objName,String rtName){
        String recordType='';
        if(String.isNotEmpty(objName)&&String.isNotEmpty(rtName)){
            requestRT=[Select Id,Name From RecordType Where SobjectType=: objName and Name=: rtName Limit 1];
        }

        if(requestRT!=null){
            if(requestRT.size()>0){
                recordType=requestRT[0].id;
            }
        }
        return recordType;
    }

    public void init(){
    system.debug('init run');
        if(CignaUtil.isBrokerPortal()){
            ListAvaliblePolicy=getPolicyList(policyHolderId);
            String UserId=userinfo.getUserId();
            ListUserInfo=[SELECT Id,Name,Contact_No_Country_Code__c,Contact_No__c,Company_Name__c,Agent_Code__c,Notification_Channel__c,Notification_Email_Address__c FROM User WHERE Id=:UserId];
            if(ListUserInfo!=null){
                if(ListUserInfo.size()>0){
                    BrokerName=ListUserInfo[0].Company_Name__c;
                    ConsultantName=ListUserInfo[0].Name;
                    ConsultantCode=ListUserInfo[0].Agent_Code__c;
                    ConsultantContact=ListUserInfo[0].Contact_No_Country_Code__c+' '+ListUserInfo[0].Contact_No__c;
                    //chris_SPS-421_2020_05_20
                    brokerEsignEmail=ListUserInfo[0].Notification_Channel__c=='SMS' ? UserInfo.getUserEmail() : ListUserInfo[0].Notification_Email_Address__c;
                }
            }
        }else{
            ListAvaliblePolicy=getPolicyList('');
        }
        /*map of policy*/
        mapAllowChangePaymentdatePolicy=new map<String,Policy>();
        List<Policy> tempListAllowChangePaymentdatePolicy=getListPolicyByCriteria('allowChangePaymentdate');
        if(tempListAllowChangePaymentdatePolicy!=null){
            if(tempListAllowChangePaymentdatePolicy.size()>0){
                for(Policy paymentPolicy: tempListAllowChangePaymentdatePolicy){
                    mapAllowChangePaymentdatePolicy.put(paymentPolicy.policyNo,paymentPolicy);
                }
            }
        }

        mapHasBrokerPolicy=new map<String,Policy>();
        List<Policy> tempListHasBrokerPolicy=getListPolicyByCriteria('hasBroker');
        if(tempListHasBrokerPolicy!=null){
            if(tempListHasBrokerPolicy.size()>0){
                for(Policy brokerPolicy: tempListAllowChangePaymentdatePolicy){
                    mapHasBrokerPolicy.put(brokerPolicy.policyNo,brokerPolicy);
                }
            }
        }

        mapIsLifePolicy=new map<String,Policy>();
        List<Policy> tempListIsLifePolicy=getListPolicyByCriteria('life');
        if(tempListIsLifePolicy!=null){
            if(tempListIsLifePolicy.size()>0){
                for(Policy lifePolicy: tempListIsLifePolicy){
                    mapIsLifePolicy.put(lifePolicy.policyNo,lifePolicy);
                }
            }
        }

        mapIsGeneralPolicy=new map<String,Policy>();
        List<Policy> tempListIsGeneralPolicy=getListPolicyByCriteria('general');
        if(tempListIsGeneralPolicy!=null){
            if(tempListIsGeneralPolicy.size()>0){
                for(Policy generalPolicy: tempListIsGeneralPolicy){
                    mapIsGeneralPolicy.put(generalPolicy.policyNo,generalPolicy);
                }
            }
        }

        mapIsIlasPolicy=new map<String,Policy>();
        List<Policy> tempListIsIlasPolicy=getListPolicyByCriteria('ilas');
        if(tempListIsIlasPolicy!=null){
            if(tempListIsIlasPolicy.size()>0){
                for(Policy ilasPolicy: tempListIsIlasPolicy){
                    mapIsIlasPolicy.put(ilasPolicy.policyNo,ilasPolicy);
                }
            }
        }
        
        setIsNotIPMIPolicy=new set<String>();
        for(Policy p: ListAvaliblePolicy){
            if(p.isIPMIPolicy==false){
                setIsNotIPMIPolicy.add(p.policyNo);
            }
        }

        /**************************************/
        PolicyHolderLoginIn='';
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //junda update for plus profile
        String profile=Portal_Settings__c.getInstance().Customer_User_Profile__c;
        if(profileName==profile||profileName=='Cigna Customer User'){
            PolicyHolderLoginIn=userinfo.getUserName();
        }
        //junda update end

        ListRequestDetail=new List<Policy_Change_Request_Detail__c>();
        ListAppFundDetail=new List<Policy_Change_Request_Detail__c>();
        ListBenefitSumInsured=new List<Policy_Change_Request_Detail__c>();
        ListBenefitRider=new List<Policy_Change_Request_Detail__c>();
        ListBenefitSingle=new List<Policy_Change_Request_Detail__c>();
        ListBenefitRegular=new List<Policy_Change_Request_Detail__c>();

        planCodeMap=new Map<String,ILAS_Plan_Code_Mapping__c>();
        List<ILAS_Plan_Code_Mapping__c> tempListPlanCode=new List<ILAS_Plan_Code_Mapping__c>();
        tempListPlanCode=[Select Id,Name,ILAS_Plan_code_with_IFS__c,Plan_Code__c,Product_Name__c From ILAS_Plan_Code_Mapping__c];
        for(ILAS_Plan_Code_Mapping__c pcm: tempListPlanCode){
            planCodeMap.put(pcm.Plan_Code__c,pcm);
        }

        /*retrieve Policy Change Record*/
        if(policyChangeId !=null && policyChangeId !=''){
            // Rancho_IA_AML_Inspection_20211005: add Place_of_Residence__c, Place_of_Residence_En__c, Place_of_Residence_Zh__c, Nationality_En__c, Nationality_Zh__c, Place_of_Birth_En__c, Place_of_Birth_Zh__c
            // Rancho_JOBR144_20220811 - add field
            Request = [SELECT id, recordTypeId,RecordType.Name, Current_Step__c, Status__c, Policy_No__c, Policy_Holder_Insured_ID__c, Policy_Holder_Insured_Name__c, Policy_Holder_Name__c, Policy_Holder_ID__c, Policy_Holder_Insured_Name_in_English__c, Policy_Holder_Insured_Name_in_Chinese__c, Is_Third_Party_Payer__c, Gender__c, Place_of_Birth__c, Date_of_Birth__c, Nationality__c, HKID_Passport_No__c, Residential_Address__c, Permanent_Address__c, Correspondence_Address__c, Mobile_Number_Country_Code__c, Mobile_Number__c, Residential_Number_Country_Code__c, Residential_Number__c, Office_Number_Country_Code__c, Office_Number__c, Occupation_Job_Title__c, Nature_of_Business__c, Occupation_Class__c, Exact_Job_Duties__c, Name_of_Employer__c, Monthly_Income__c, Business_Address__c, PAddress_same_as_RAddress__c, CAddress_same_as_RAddress__c, Change_of_Premium_Paying_Frequency__c, Direct_Debit_Method__c, Bank_Name__c, Branch_Name__c, Bank_No__c, Branch_No__c, Bank_Account_No__c, Name_of_Card_Issuing_Bank__c, Country_of_Card_Issuing_Bank__c, VisaMaster_Card_Credit_Card_Account__c, Card_Expiry_Date_Month__c, Card_Expiry_Date_Year__c, I_D_Number_of_Account_Holder_s__c, ID_Type__c, Name_of_Account_Holder_s_IN_English__c, Choice_of_Payment_Date__c, Source_of_Fund__c, Source_of_Fund_Ownership__c, Funds_by_Others__c, X3rd_Party_Payer__c, Full_Name_of_3rd_party_payer__c, Relationship_with_Policyholder_Applica__c, Contact_No_Country_Code__c, Name_of_Company_Institution__c, Contact_No_of_Company_Country_Code__c, Contact_No_of_Company_Institution__c, BR_Number__c, Date_of_Incorporation__c, Place_of_Incorporation__c, Registered_Office_Address__c, Name_of_person_acting_on_behalf_of_the_c__c, Designation__c, Contact_No__c, Contact_No_Acting__c, Contact_No_Acting_Country_Code__c, Reason_for_3rd_party_payment__c, Duplicate_Policy__c, Copy_for_the_Policy_Medical_Documents__c, Medical_report__c, Medical_Report_Date_of_Examination__c, Attending_Physician_Statement__c, Attending_Physician_Date_of_Examination__c, Others_Document__c, Others__c, Delivery_Instruction__c, Industry__c, Reinstatement_1_Job_Duties__c, Reinstatement_2_Construction__c, Reinstatement_Monthly_Income_Range__c, Reinstatement_existing_insurance__c, Reinstatement_life__c, Reinstatement_critical_illness__c, Reinstatement_accident__c, Reinstatement_accidental_hospital_income__c, Reinstatement_hospital_income__c, Reinstatement_disability_income__c, Height__c, Height_Unit__c, Weight__c, Weight_Unit__c, Reinstatement_breath_problem__c, Reinstatement_breath_problem_details__c, Reinstatement_heart_problem__c, Reinstatement_heart_problem_details__c, Reinstatement_digestive_sys_prob__c, Reinstatement_digestive_sys_prob_details__c, Reinstatement_brain_problem__c, Reinstatement_brain_problem_details__c, Reinstatement_cancer__c, Reinstatement_cancer_details__c, Reinstatement_back_problem__c, Reinstatement_back_problem_details__c, Reinstatement_apart_from_con__c, Reinstatement_apart_from_con_details__c, Reinstatement_members_disease__c, Reinstatement_members_disease_details__c, Reinstatement_additional_declaration__c, Occupation__c, Currency__c, Additional_Contribution__c, New_Policyholder_Name_in_English__c, New_Policyholder_Name_in_Chinese__c, Relationship_with_Person_Insured__c, Email_Address__c, ChangePersonalParticular__c, ChangeAddress__c, ChangeContactInfo__c, ChangeOccupation__c, I_D_Number_of_Account_Holder_1__c, I_D_Number_of_Account_Holder_2__c, I_D_Number_of_Account_Holder_3__c, I_D_Type_of_Account_Holder_1__c, I_D_Type_of_Account_Holder_2__c, I_D_Type_of_Account_Holder_3__c, Name_of_Account_Holder_1_in_English__c, Name_of_Account_Holder_2_in_English__c, Name_of_Account_Holder_3_in_English__c, hasAccountHolder2__c, hasAccountHolder3__c, feet__c, inch__c, IsLifePolicy__c, Reason_for_change_of_ownership__c, eSignature_Status__c, Site_Prefix__c, HKID_Passport_No_Company__c, Automatic_Premium_Payment_Action__c, Effective_Start_Date_Month__c, Effective_Start_Date_Year__c, Effective_End_Date_Month__c, Effective_End_Date_Year__c, Effective_Year__c, Effective_Month__c, Effective_Month_Cancel__c, Effective_Year_Cancel__c, Single_Currency__c, Regular_Currency__c, IsIlasPolicy__c,Current_Contribution_Amount_From__c,New_Contribution_Amount_To__c, Place_of_Residence__c, Place_of_Residence_En__c, Place_of_Residence_Zh__c, Nationality_En__c, Nationality_Zh__c, Place_of_Birth_En__c, Place_of_Birth_Zh__c, Nationality_Code__c, IsGerneralPolicy__c
            FROM Policy_Change_Request__c WHERE id=:policyChangeId LIMIT 1];
            if(Request!=null){
                /*assign record type - changeType*/
                List<RecordType> requestRT=[Select Id,Name From RecordType Where SobjectType='Policy_Change_Request__c' and id=: Request.recordTypeId Limit 1];
                if(requestRT!=null){
                    if(requestRT.size()>0){
                        if(requestRT[0].Name.contains('Basic')){
                            changeType='personal';
                        }

                        if(requestRT[0].Name.contains('Beneficiary')){
                            changeType='beneficiary';
                        }

                        if(requestRT[0].Name.contains('Ownership')){
                            changeType='owner';
                        }
                        if(requestRT[0].Name.contains('Payment')&&requestRT[0].Name.contains('Information')){
                            changeType='dd';
                        }
                        if(requestRT[0].Name.contains('copy')){
                            changeType='copyDoc';
                            //PolicyChoice=Request.Policy_No__c;
                        }
                        if(requestRT[0].Name.contains('reinstatement')){
                            changeType='renew';
                            //PolicyChoice=Request.Policy_No__c;
                        }
                        if(requestRT[0].Name.contains('Benefit')){
                            changeType='benefit';
                            //PolicyChoice=Request.Policy_No__c;
                        }
                        if(requestRT[0].Name.contains('Automatic')){
                            changeType='app';
                            //PolicyChoice=Request.Policy_No__c;
                        }
                        selectChangeType();
                        showListPolicy();// get avaliable policy of the policy holder
                        PolicyChoice=Request.Policy_No__c;
                    }
                }
                /*check if attachment is uploaded*/
                checkAtt();
                /*Assign Policy Selected*/
                if(String.IsNotEmpty(Request.Policy_No__c)){
                    String policyNoTrim=Request.Policy_No__c.trim();
                    String[] tmpString=policyNoTrim.split(',');
                    for(String s : tmpString){
                        if(String.isNotBlank(s)){
                            setMultiPolicyChoice.add(s.trim());
                        }
                    }
                    hasPolicy=true;
                }

                /*update policy list record for those chosen policy*/
                for(Policy policies: ListPolicy){
                    if(setMultiPolicyChoice.contains(policies.policyNo)){
                        policies.policySelected=true;
                    }
                }

                // Rancho_PI84_20221111 - change the order to align policy type with WS
                isLife=Request.IsLifePolicy__c;
                isGeneral=Request.IsGerneralPolicy__c;// Rancho_JOBR144_20220811 - get value from record
                assignPolicyList();

                /*Assign Policy Holder/Insured Selected*/
                showPolicyMember();//get policy holder/insured selected
                policyMemberId=Request.Policy_Holder_Insured_ID__c;
                /*check if the policy holder.insured is selected*/
                /*map policy holder*/
                mapPolicyHolder=new Map<String,Policy>();
                if(ListPolicy!=null){
                    if(ListPolicy.size()>0){
                        for(Policy ph: ListPolicy){
                            mapPolicyHolder.put(ph.policyHolderId,ph);
                        }
                    }
                }
                /*map policy insured*/
                mapPolicyInsured=new Map<String,PolicyInsured>();
                if(ListPolicyInsured!=null){
                    if(ListPolicyInsured.size()>0){
                        for(PolicyInsured mpi: ListPolicyInsured){
                            mapPolicyInsured.put(mpi.policyInsuredId,mpi);
                        }
                    }
                }

                /*update policy insured/holder list record for those chosen*/
                if(mapPolicyInsured!=null){
                    if(mapPolicyInsured.containsKey(policyMemberId)){
                        for(PolicyInsured pi: ListPolicyInsured){
                            pi.policyInsuredSelected=true;
                        }
                        hasPolicyMemberName=true;
                    }
                }

                if(mapPolicyHolder!=null&&mapPolicyHolder.get(policyMemberId)!=null){
                    for(Policy ph: ListPolicy){
                        ph.policyHolderSelected=true;
                    }
                    hasPolicyMemberName=true;
                }

                /*Assign Current Step for redirecting*/
                currentStep=Request.Current_Step__c;
                isIlas=Request.IsIlasPolicy__c;
                IsThirdParty=Request.Is_Third_Party_Payer__c;
                PolicyHolder=Request.Policy_Holder_Name__c;
                if(String.isBlank(Request.Policy_Holder_Insured_Name__c)){
                    policyMemberName=PolicyHolder;
                }else{
                    policyMemberName=Request.Policy_Holder_Insured_Name__c;
                }
                PolicyHolderId=Request.Policy_Holder_ID__c;
                IsPersonalParti=Request.ChangePersonalParticular__c;
                IsAddress=Request.ChangeAddress__c;

                if(Request.Date_of_Birth__c!=null){
                    yyyyDOB=String.valueOf(Request.Date_of_Birth__c.Year());
                    mmDOB=String.valueOf(Request.Date_of_Birth__c.Month());
                    ddDOB=String.valueOf(Request.Date_of_Birth__c.Day());
                }

                if(Request.VisaMaster_Card_Credit_Card_Account__c!=null&&Request.VisaMaster_Card_Credit_Card_Account__c!=''){
                    if(CignaValidationUtil.isValidCreditCard(Request.VisaMaster_Card_Credit_Card_Account__c)){
                        creditCardNo1='****';
                        creditCardNo2='****';
                        creditCardNo3='****';
                        creditCardNo4=Request.VisaMaster_Card_Credit_Card_Account__c.substring(12,16);
                        savedCreditCardWithMask=creditCardNo1+creditCardNo2+creditCardNo3+creditCardNo4;
                    }
                }

                /*creditCardNo1=Request.VisaMaster_Card_Credit_Card_Account__c.substring(0,3);
                creditCardNo2=Request.VisaMaster_Card_Credit_Card_Account__c.substring(4,7);
                creditCardNo3=Request.VisaMaster_Card_Credit_Card_Account__c.substring(8,11);
                creditCardNo4=Request.VisaMaster_Card_Credit_Card_Account__c.substring(12,15);*/

                checkAttDisplay();

                if(changeType=='beneficiary'||changeType=='owner'){
                    ListRequestDetail=[SELECT Id,Name,Policy_Change_Request__c,English_Name__c,HKID_Birth_Cert_Passport_No__c,Relationship_with_Person_Insured__c,Share__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId];
                }else if(changeType=='app'){
                    List<Policy_Change_Request_Detail__c> ListTempAppFundDetail=new List<Policy_Change_Request_Detail__c>();
                    ListTempAppFundDetail=[SELECT Id,Name,Fund_Code__c,Fund_Name__c,Fund_Name_Chinese__c,Sequence__c,Total__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId];
                    if(ListTempAppFundDetail.size()>0){
                        ListAppFundDetail=ListTempAppFundDetail;
                    }
                }else if(changeType=='benefit'){
                    //for sum insured
                    Id BenefitSumInsuredRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Benefit Change Sum Insured');
                    //for add delete rider
                    Id BenefitRiderRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Benefit Rider');
                    //for Additional Contribution
                    Id BenefitAdditionalConRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Benefit Additional Contribution');

                    ListBenefitSumInsured=[SELECT Id,Name,Benefit_Name_Code__c,Benefit_Name_Code_Chinese__c,Sum_Insured_From_Currency__c,Sum_Insured_To__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: BenefitSumInsuredRecordTypeId];
                    ListBenefitRider=[SELECT Id,Name,Add_Delete_Rider__c,Rider_Benefit_Name_Code__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: BenefitRiderRecordTypeId];

                    if(Request.Additional_Contribution__c=='Single'){
                        ListBenefitSingle=[SELECT Id,Name,Single_Name_of_Investment_Choice__c,Amount__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: BenefitAdditionalConRecordTypeId];
                    }else if(Request.Additional_Contribution__c=='Regular'){
                        ListBenefitRegular=[SELECT Id,Name,Name_of_Investment_Choice_Regular__c,Allocation__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: BenefitAdditionalConRecordTypeId];
                    }
                }
            }
        }else{
            Request=new Policy_Change_Request__c();           
        }
        hasAvailablePolicy=true;
        /*get download Document Id*/
        DocGoldMedalPlan=getDocFileId('Important_Facts_Statement_Gold_Medal_Plan');
        DocCignaInvestPlusLife=getDocFileId('Important_Facts_Statement_Cigna_Invest_Plus_Life');
        DocGoldMedalPlanPlus=getDocFileId('Important_Facts_Statement_Gold_Medal_Plan_Plus');
        DocJuniorCare=getDocFileId('Important_Facts_Statement_Junior_Care');
        DocPlatinumMedalPlan=getDocFileId('Important_Facts_Statement_Platinum_Medal_Plan');
        system.debug('Kevani init policyMemberName:' + policyMemberName);
    }

    public String getDocFileId(String fileName){
        List <Document> tempDocList=[SELECT Id FROM Document WHERE DeveloperName=: fileName LIMIT 1];
        String DocId='';
        if(tempDocList!=null){
            if(tempDocList.size()>0){
                DocId=tempDocList[0].Id;
            }
        }
        return DocId;
    }

    /*get Current Step*/
    Public void InputCurrentStep(){
        Request.Current_Step__c=currentStep;
        system.debug('currentStep: '+currentStep);
        if(IsApp||IsBenefit){
            SavePolicyChange();
        }
    }
    /*Select Policy Change Type*/
    
    Public void selectChangeType(){
        hasPolicy=false;
        PolicyChoice='';
        setMultiPolicyChoice.clear();
        hasChangeType=false;
        IsPersonal=false;
        IsBeneficiary=false;
        IsOwner=false;
        IsDD=false;
        IsCopyDoc=false;
        IsRenew=false;
        IsBenefit=false;
        IsApp=false;
        IsThirdParty=false;

        currentPhAddProof=false;
        currentPhIdCopy=false;
        currentPiAddProof=false;
        currentPiIdCopy=false;
        PhPiIdCopy=false;
        PhPiAddProof=false;
        newPHIdCopy=false;
        newPHAddProof=false;
        FNA=false;
        thirdPartyAddProof=false;
        thirdPartyIdCopy=false;
        deedPoll=false;
        riskProfileQuestion=false;
        IsPersonalParti=false;
        IsAddress=false;
        isLife=false;
        requireAtt=false;

        if(changeType!=''||changeType!=null){
            hasChangeType=true;
        }

        if(changeType=='personal'){

            multiPolicy=true;
            IsPersonal=true;
        }

        if(changeType=='beneficiary'){
            multiPolicy=true;
            IsBeneficiary=true;
            addRowBeneficiary();
        }else{
            clearBeneficiary();
        }

        if(changeType=='owner'){
            multiPolicy=true;
            IsOwner=true;
        }

        if(changeType=='dd'){
            multiPolicy=true;
            IsDD=true;
        }

        if(changeType=='copyDoc'){
            multiPolicy=false;
            IsCopyDoc=true;
        }

        if(changeType=='renew'){
            multiPolicy=false;
            IsRenew=true;
        }

        if(changeType=='benefit'){
            multiPolicy=false;
            IsBenefit=true;
            FNA=true;
            addRowBenefitSingle();
            addRowBenefitRegular();
        }

        if(changeType=='app'){
            multiPolicy=false;
            IsApp=true;

        }else{
            clearAppFund();
        }
    }
    /*Get Policy Choice */
    
    public void showListPolicy(){
        if(IsOwner){
            ListPolicy=getListAllowChangeOwnerPolicy();
        }else if(IsRenew){
            ListPolicy=getListLapsedPolicy();
        }else if(IsApp){
            ListPolicy=getListIsILASPolicy();
        }else{
            ListPolicy=getListinforcePolicy();
        }

        ListPolicy = filterPolicyByChangeType(ListPolicy); // 20251019 - HKITSFDC-412
        
        if(ListPolicy!=null){
            if(ListPolicy.size()>0){
                policyholder=ListPolicy[0].policyHolder;// get the policy holder name
                policyholderId=ListPolicy[0].policyHolderId; // get the policy holder id
                policyHolderSelected=ListPolicy[0].policyHolderSelected;
                if(policyMemberName==''|| policyMemberName==null){
                    policyMemberName=ListPolicy[0].policyHolder; // get the policy holder name for display on attachment step
                }
                hasNoPolicy=false;
            }else{
                hasNoPolicy=true;
            }
            system.debug('Kevani showListPolicy policyMemberName:' + policyMemberName);
        }
    }

    /**
    * @description hide policy based on selected change type
    * @param List<Policy> lstPolicy 
    * @return List<Policy> 
    **/
    public List<Policy> filterPolicyByChangeType(List<Policy> lstPolicy){
        List<Policy> lstVisiblePolicies = new List<Policy>();
        Map<String, Boolean> activeTypeMap = new Map<String, Boolean>{
            'personal'    => IsPersonal,
            'beneficiary' => IsBeneficiary,
            'owner'       => IsOwner,
            'dd'          => IsDD,
            'copyDoc'     => IsCopyDoc,
            'renew'       => IsRenew,
            'benefit'     => IsBenefit,
            'app'         => IsApp
        };
        Map<String, Policy_Change_Hide_Setting__c> hideSettingMap = Policy_Change_Hide_Setting__c.getAll();
        for (Policy pol : lstPolicy) {
            Boolean toHide = false;
            Policy_Change_Hide_Setting__c polHideSetting = hideSettingMap.get(pol.productCode);
            if (polHideSetting != null && polHideSetting.Hide_Change_Type__c != null && polHideSetting.Active__c) {
                
                Set<String> hiddenTypes = new Set<String>();
                for (String type : polHideSetting.Hide_Change_Type__c.split(';')) {
                    
                    if (String.isNotBlank(type.trim()) && !hiddenTypes.contains(type.trim())) {
                        hiddenTypes.add(type);
                    }
                }

                
                for (String hideKey : hiddenTypes) {
                    Boolean isActive = activeTypeMap.get(hideKey);
                    if (isActive == true) {
                        toHide = true;
                        break;
                    }
                }
            }

            if (!toHide) {
                lstVisiblePolicies.add(pol);
            }
        }
        return lstVisiblePolicies;
    }

    /*Policy List By different Criteria*/
    public List<Policy> getListinforcePolicy(){
        return getListPolicyByCriteria('inforce');
    }

    public List<Policy> getListLapsedPolicy(){
        return getListPolicyByCriteria('lapsed');
    }

    public List<Policy> getListHasBrokerPolicy(){
        return getListPolicyByCriteria('hasBroker');
    }

    public List<Policy> getListAllowChangeOwnerPolicy(){
        return getListPolicyByCriteria('allowChangeOwner');
    }

    public List<Policy> getListAllowChangePaymentdatePolicy(){
        return getListPolicyByCriteria('allowChangePaymentdate');
    }

    public List<Policy> getListIsLifePolicy(){
        return getListPolicyByCriteria('life');
    }

    public List<Policy> getListIsGeneralPolicy(){
        return getListPolicyByCriteria('general');
    }

    public List<Policy> getListIsILASPolicy(){
        return getListPolicyByCriteria('ilas');
    }

    public List<Policy> getListPolicyByCriteria(String criteria){
        List<Policy> ListinforcePolicy=new List<Policy>();
        List<Policy> ListLapsedPolicy=new List<Policy>();
        List<Policy> ListHasBrokerPolicy=new List<Policy>();
        List<Policy> ListAllowChangeOwnerPolicy=new List<Policy>();
        List<Policy> ListAllowChangePaymentdatePolicy=new List<Policy>();
        List<Policy> ListIsILAS=new List<Policy>();
        List<Policy> ListIsLifePolicy=new List<Policy>();
        List<Policy> ListIsGeneralPolicy=new List<Policy>();
        System.debug('getListPolicyByCriteria ListAvaliblePolicy:'+ListAvaliblePolicy);
        if(ListAvaliblePolicy!=null){
            if(ListAvaliblePolicy.size()>0){
                for(Policy p: ListAvaliblePolicy){
                    Policy policy=new Policy();
                    policy.policyName=p.policyName;
                    policy.policyNo=p.policyNo;
                    policy.policyHolderId=p.policyHolderId;
                    policy.policyStatus=p.policyStatus;
                    policy.policyHolder=p.policyHolder;
                    policy.agentCode=p.agentCode;
                    policy.brokerName=p.brokerName;
                    policy.allowChangeOwner=p.allowChangeOwner;
                    policy.allowChangePaymentDate=p.allowChangePaymentDate;
                    policy.isLifePolicy=p.isLifePolicy;
                    policy.isILAS=p.isILAS;
                    policy.isIPMIPolicy=p.isIPMIPolicy;
                    policy.policySelected=p.policySelected;
                    policy.policyHolderSelected=p.policyHolderSelected;
                    policy.productCode=p.productCode;//GL31 jack add
                    system.debug('inforce p.policyStatus: '+p.policyStatus);
                    if(String.valueOf(policy.policyStatus).Equals(system.label.inforce)){
                        ListinforcePolicy.add(policy);

                        if(p.agentCode!=''){
                            ListHasBrokerPolicy.add(policy);
                        }

                        if(p.allowChangeOwner==true){
                            ListAllowChangeOwnerPolicy.add(policy);
                        }

                        if(p.allowChangePaymentDate==true){
                            ListAllowChangePaymentdatePolicy.add(policy);
                        }
                    }

                    if(String.valueOf(policy.policyStatus).Equals(system.label.lapsed)){
                        ListLapsedPolicy.add(policy);
                    }

                    if(p.isLifePolicy==true){
                        ListIsLifePolicy.add(policy);
                    }

                    if(p.isLifePolicy==false){
                        ListIsGeneralPolicy.add(policy);
                    }

                    if(p.isILAS==true){
                        ListIsILAS.add(policy);
                    }
                }
            }
        }

        if(criteria=='inforce'){
            return ListinforcePolicy;
        }else if(criteria=='lapsed'){
            return ListLapsedPolicy;
        }else if(criteria=='hasBroker'){
            return ListHasBrokerPolicy;
        }else if(criteria=='allowChangeOwner'){
            return ListAllowChangeOwnerPolicy;
        }else if(criteria=='allowChangePaymentdate'){
            return ListAllowChangePaymentdatePolicy;
        }else if(criteria=='life'){
            return ListIsLifePolicy;
        }else if(criteria=='general'){
            return ListIsGeneralPolicy;
        }else if(criteria=='ilas'){
            return ListIsILAS;
        }else{
            return null;
        }
    }

    public void showPolicyMember(){
        /*get policy Insured*/
        ListPolicyInsured=new List<PolicyInsured>();
        /*check duplicate Policy Insured Id*/
        set<string> SetPolicyInsuredCheck=new set<string>();
        if(policyholderId!=null&&policyholderId!=''){
            SetPolicyInsuredCheck.add(policyholderId);
        }
        List<PolicyInsured> ListPolicyInsuredCheck=new List<PolicyInsured>();
        if(setMultiPolicyChoice.size()>0){
            for(String policyno: setMultiPolicyChoice){
                ListPolicyInsuredCheck.addall(getInsuredList(policyno)) ;
            }
            for(PolicyInsured pi: ListPolicyInsuredCheck){
                /*check duplicate Policy Insured Id*/
                if(!SetPolicyInsuredCheck.contains(pi.policyInsuredId)||!SetPolicyInsuredCheck.contains(policyholderId)){
                    ListPolicyInsured.add(pi);
                    SetPolicyInsuredCheck.add(pi.policyInsuredId);
                }
            }
        }
        hasPolicyMember=true;
    }

    /*Select Policy Choice*/
    public void selectPolicy(){
        system.debug('selectPolicy()');
        if(multiPolicy){
            if(setMultiPolicyChoice.contains(PolicyChoice)){
                setMultiPolicyChoice.remove(PolicyChoice);
            }else if(String.isNotBlank(PolicyChoice)){
                setMultiPolicyChoice.add(PolicyChoice);
            }
        }else{
            if(setMultiPolicyChoice.size()>0){
                setMultiPolicyChoice.clear();
            }
            if(String.isNotBlank(PolicyChoice)){
                setMultiPolicyChoice.add(PolicyChoice);
            }
        }
        assignPolicyList();
        system.debug('Kevani selectPolicy policyMemberName: ' + policyMemberName);
    }

    public void assignPolicyList(){
        isDownload=false;
        isGoldMedal=false;
        isGoldMedalPlus=false;
        isJuniorCare=false;
        isPlatinumMedal=false;
        isCignaInvestPlusLife=false;

        isAllowChangePaymentDate=false;
        isHasBroker=false;
        isLife=false;
        isGeneral=false;
        isIlas=false;

        /*For Benefit Plan Type*/
        if(IsBenefit){
            policyAvailBenefitList=new List<HttpCalloutVO.PolicyPersonCoverage>();
            availBenefitSumInsuredOptions=new List<SelectOption>();
            availBenefitMap=new map< String ,HttpCalloutVO.PolicyPersonCoverage>();
            availBenefitSumInsuredOptions.add(new SelectOption('',system.label.Please_select));

            if(setMultiPolicyChoice.size()>0){
                for(String policyChoice :setMultiPolicyChoice){
                    policyAvailBenefitList.addAll(getPolicyPlanCode(policyChoice));
                }
                system.debug('kevani policyAvailBenefitList: '+policyAvailBenefitList);
                if(policyAvailBenefitList.size()>0){
                    Set<String> benefitCodeSet=new Set<String>();//GL31 jack add
                    for(HttpCalloutVO.PolicyPersonCoverage coverage: policyAvailBenefitList){
                        //only add basic plan benefit into the benefit picklist
                        if((coverage.productCode==coverage.benefitCode)&&setIsNotIPMIPolicy.contains(policyChoice)){
                            String benefitOption=coverage.benefitName.trim()+'/'+coverage.benefitCode.trim();
                            availBenefitSumInsuredOptions.add(new SelectOption(benefitOption ,benefitOption));
                            hasBenefit=true;
                            availBenefitMap.put(benefitOption,coverage);
                        }
                        if(planCodeMap!=null){
                            if(planCodeMap.get(coverage.BenefitCode.trim())!=null){
                                if(planCodeMap.get(coverage.BenefitCode.trim()).ILAS_Plan_code_with_IFS__c.EqualsIgnoreCase('GMP')){
                                    isGoldMedal=true;
                                    isDownload=true;
                                }else if(planCodeMap.get(coverage.BenefitCode.trim()).ILAS_Plan_code_with_IFS__c.EqualsIgnoreCase('GMPJ')){
                                    isJuniorCare=true;
                                    isDownload=true;
                                }else if(planCodeMap.get(coverage.BenefitCode.trim()).ILAS_Plan_code_with_IFS__c.EqualsIgnoreCase('GMPP')){
                                    isGoldMedalPlus=true;
                                    isDownload=true;
                                }else if(planCodeMap.get(coverage.BenefitCode.trim()).ILAS_Plan_code_with_IFS__c.EqualsIgnoreCase('PMP')){
                                    isPlatinumMedal=true;
                                    isDownload=true;
                                }else if(planCodeMap.get(coverage.BenefitCode.trim()).ILAS_Plan_code_with_IFS__c.EqualsIgnoreCase('CIPL')){
                                    isCignaInvestPlusLife=true;
                                    isDownload=true;
                                }
                            }
                        }
                        benefitCodeSet.add(coverage.benefitCode);//GL31 jack add
                    }
                    //GL31 jack add
                    // String selectedProductCode='';
                    // System.debug('setMultiPolicyChoice:'+setMultiPolicyChoice+' ListPolicy:'+ListPolicy);
                    // for(policy temPolicy : ListPolicy){
                    //     if(setMultiPolicyChoice.contains(temPolicy.policyNo)){
                    //         selectedProductCode=temPolicy.productCode;
                    //         break;
                    //     }
                    // }
                    System.debug('selectedProductCode'+selectedProductCode);
                    List<Product__c> proList=[select product__r.product_code__c from Product__c where Product_code__c=:selectedProductCode];
                    System.debug('proList'+proList);
                    if(proList.size()>0){
                        basicProductCode=proList[0].product__r.product_code__c;
                        assessAllRiderMap=ESalesUtility.getAvailRiderMap(basicProductCode);
                        assessRiderMap=new Map<String,String>();
                        riderOption=new List<SelectOption>();
                        existRiderOption=new List<SelectOption>();
                        for(String benefitCode : benefitCodeSet){
                            for(String riderCode : assessAllRiderMap.keySet()){
                                if(benefitCode.startsWithIgnoreCase(riderCode)){
                                    existRiderOption.add(new SelectOption(assessAllRiderMap.get(riderCode)+riderSperator+riderCode,assessAllRiderMap.get(riderCode)+riderSperator+riderCode));
                                }
                            }
                        }
                    }
                    assessmentQuestionList=ESalesUtility.getQuestionData('');
                    system.debug('assessRiderMap:'+assessRiderMap);
                    if(availBenefitSumInsuredOptions.size()>1){
                    }
                }else{
                    hasBenefit=false;
                }
            }
        }

        strAllowChangePolicy='';
        strHasBrokerPolicy='';
        strIsLifePolicy='';
        strIsGeneralPolicy='';

        if(setMultiPolicyChoice.size()>0){
            hasPolicy=true;
            for(String policyChoice :setMultiPolicyChoice){
                if(mapAllowChangePaymentdatePolicy.containsKey(policyChoice)){
                    strAllowChangePolicy=strAllowChangePolicy+policyChoice+','+' ';
                }

                if(mapHasBrokerPolicy.containsKey(policyChoice)){
                    strHasBrokerPolicy=strHasBrokerPolicy+policyChoice+','+' ';
                }

                if(mapIsLifePolicy.containsKey(policyChoice)){
                    strIsLifePolicy=strIsLifePolicy+policyChoice+','+' ';
                }

                if(mapIsGeneralPolicy.containsKey(policyChoice)){
                    strIsGeneralPolicy=strIsGeneralPolicy+policyChoice+','+' ';
                }

                if(mapIsIlasPolicy.containsKey(policyChoice)){
                    isIlas=true;
                }
            }
            if(strAllowChangePolicy.length()>0){
                strAllowChangePolicy=strAllowChangePolicy.substring(0,strAllowChangePolicy.length()-2);
                isAllowChangePaymentDate=true;
            }
            if(strHasBrokerPolicy.length()>0){
                strHasBrokerPolicy=strHasBrokerPolicy.substring(0,strHasBrokerPolicy.length()-2);
                isHasBroker=true;
            }
            if(strIsLifePolicy.length()>0){
                strIsLifePolicy=strIsLifePolicy.substring(0,strIsLifePolicy.length()-2);
                isLife=true;
            }
            if(strIsGeneralPolicy.length()>0){
                strIsGeneralPolicy=strIsGeneralPolicy.substring(0,strIsGeneralPolicy.length()-2);
                isGeneral=true;
            }
        }else{
            hasPolicy=false;
        }

        if(IsApp||IsBenefit){
            getAllAvailFundOptions();
        }

        if(IsBeneficiary){
            listRequestDetail=new List<Policy_Change_Request_Detail__c>();
            addRowBeneficiary();
        }

        if(IsOwner){
            listRequestDetail=new List<Policy_Change_Request_Detail__c>();
        }

        checkAttDisplay();
        
        //JOBR-184: JOBR-199 added by Kermit
        if(isLife && !isGeneral){
            entityName = Label.Chubb_Life_Entity_Name;
            entityNameForNote = Label.Life_Entity_Name;
        }else if(!isLife && isGeneral){
            entityName = Label.Cigna_Entity_Name;
            entityNameForNote = Label.Cigna_Entity_Name;
        }else{
			entityName = Label.Both_Life_And_GI_Entity_Name;
            entityNameForNote = Label.Both_Life_And_GI_Entity_Name;
        }
        //JOBR-184: JOBR-199 added by Kermit
    }

    /*Selected Policy Member*/
    public void selectedPolicyMember(){
        if(policyMemberName!=''&& policyMemberName!=null){
            hasPolicyMemberName=true;
        }
        system.debug('Kevani selectedPolicyMember policyMemberName: ' + policyMemberName);
    }

    public void SavePolicyChange(){
        if((policyMemberName==''|| policyMemberName==null)&&ListPolicy.size()>0){
            policyMemberName=ListPolicy[0].policyHolder; // get the policy holder name for display on attachment step
        }
        system.debug('Kevani SavePolicyChange policyMemberName: ' + policyMemberName);
        /*handle selected policy and find the policy holder*/
        String policynostr='';
        if(setMultiPolicyChoice!=null&&setMultiPolicyChoice.size()>0){
            for(String policyno :setMultiPolicyChoice){
                if(String.isNotBlank(policyno)){
                    policynostr+=policyno+','+' ';
                }
            }
            policynostr=policynostr.substring(0,policynostr.length()-2);
            policynostr=policynostr.trim();
            Integer commaIndex=policynostr.lastIndexOf(',');
            if(commaIndex==(policynostr.length()-1)){
                policynostr=policynostr.substring(0,policynostr.length()-1);
            }
        }
        /*Common Saving Policy Change fields*/
        Request.Site_Prefix__c=sitePrefix;
        Request.Policy_No__c=policynostr;
        Request.Policy_Holder_Name__c=policyholder;
        Request.Policy_Holder_ID__c=policyHolderId;
        Request.Status__c='Not Submitted';
        /* Broker */
        Request.Financial_Consultant_Code__c=ConsultantCode;
        Request.Financial_Consultant_Contact_No__c=ConsultantContact;
        Request.Financial_Consultant_Name__c=ConsultantName;
        Request.Broker_Name__c=BrokerName;
        //add bob name sc 20201201
        if (Request.X3rd_Party_Payer__c=='Company / Institution'){
            Request.Relationship_with_Policyholder_Applica__c='Employer';
        }

        /**********/

        if(Request.eSignature_Status__c=='Email Sent'&&FromEmail!=true){
            Request.eSignature_Status__c='Edited after email sent';
        }
        if(isLife){
            Request.IsLifePolicy__c=true;
        }else{
            Request.IsLifePolicy__c=false;
        }

        // Rancho_JOBR144_20220811 - set value for general policy
        if(isGeneral){
            Request.IsGerneralPolicy__c=true;
        }else{
            Request.IsGerneralPolicy__c=false;
        }

        if(isIlas){
            Request.IsIlasPolicy__c=true;
        }else{
            Request.IsIlasPolicy__c=false;
        }

        if(yyyyDOB!=null&&yyyyDOB!=''&&mmDOB!=null&&mmDOB!=''&&ddDOB!=null&&ddDOB!=''){
            Request.Date_of_Birth__c=Date.newInstance(Integer.ValueOf(yyyyDOB),Integer.ValueOf(mmDOB),Integer.ValueOf(ddDOB));
        }

        if(Request.Mobile_Number_Country_Code__c==null||Request.Mobile_Number_Country_Code__c==''){
            Request.Mobile_Number_Country_Code__c='+852';
        }

        if(Request.Residential_Number_Country_Code__c==null||Request.Residential_Number_Country_Code__c==''){
            Request.Residential_Number_Country_Code__c='+852';
        }

        if(Request.Office_Number_Country_Code__c==null||Request.Office_Number_Country_Code__c==''){
            Request.Office_Number_Country_Code__c='+852';
        }

        /*For Saving Change personal information*/
        if(IsPersonal){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Basic Information');
            Request.Policy_Holder_Insured_Name__c=policyMemberName;
            Request.Policy_Holder_Insured_ID__c=policyMemberId;
            // Rancho_IA_AML_Inspection_20211005: update nationality field to use ws list
            if(String.isNotBlank(Request.Nationality_Code__c)){
                if(UserInfo.getLanguage() == 'en_US'){
                    Request.Nationality__c=nationalityEnMap.get(Request.Nationality_Code__c);
                }else{
                    Request.Nationality__c=nationalityZhMap.get(Request.Nationality_Code__c);
                }
            }
        }else if(IsDD){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Payment Information');
            Request.Is_Third_Party_Payer__c=IsThirdParty;
            String tempCreditCard=creditCardNo1+creditCardNo2+creditCardNo3+creditCardNo4;
            if(tempCreditCard!=savedCreditCardWithMask){
                Request.VisaMaster_Card_Credit_Card_Account__c=tempCreditCard;
            }
            if(Request.Contact_No_Country_Code__c==null||Request.Contact_No_Country_Code__c==''){
                Request.Contact_No_Country_Code__c='+852';
            }

            if(Request.Contact_No_of_Company_Country_Code__c==null||Request.Contact_No_of_Company_Country_Code__c==''){
                Request.Contact_No_of_Company_Country_Code__c='+852';
            }

            if(Request.Contact_No_Acting_Country_Code__c==null||Request.Contact_No_Acting_Country_Code__c==''){
                Request.Contact_No_Acting_Country_Code__c='+852';
            }
            if(incorporationDateTimestamp!=null&&incorporationDateTimestamp!=0){
                Request.Date_of_Incorporation__c=DateTime.newInstance(incorporationDateTimestamp).date();
            }
            // Rancho_IA_AML_Inspection_20211005: update nationality field to use ws list
            if(String.isNotBlank(Request.Nationality_Code__c)){
                if(UserInfo.getLanguage() == 'en_US'){
                    Request.Nationality__c=nationalityEnMap.get(Request.Nationality_Code__c);
                }else{
                    Request.Nationality__c=nationalityZhMap.get(Request.Nationality_Code__c);
                }
            }
        }else if(IsCopyDoc){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Request for Policy copy or / and Medical Report copy');

            if(medReportExamDateTimestamp!=null&&medReportExamDateTimestamp!=0){
                Request.Medical_Report_Date_of_Examination__c=DateTime.newInstance(medReportExamDateTimestamp).date();
            }
            if(phyStatementDateTimestamp!=null&&phyStatementDateTimestamp!=0){
                Request.Attending_Physician_Date_of_Examination__c=DateTime.newInstance(phyStatementDateTimestamp).date();
            }
        }else if(IsRenew){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Application for policy reinstatement');
        }else if(IsBenefit){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Benefit');
            if(Request.Additional_Contribution__c=='Single'){
                Request.Regular_Currency__c='';
                Request.Current_Contribution_Amount_From__c=null;
                Request.New_Contribution_Amount_To__c=null;
            }else if(Request.Additional_Contribution__c=='Regular'){
                Request.Single_Currency__c='';
            }
        }else if(IsOwner){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Ownership');

            // Rancho_IA_AML_Inspection_20211005: get country name by country code
            if(String.isNotBlank(Request.Nationality__c)){
                Request.Nationality_En__c=nationalityEnMap.get(Request.Nationality__c);
                Request.Nationality_Zh__c=nationalityZhMap.get(Request.Nationality__c);
            }
            if(String.isNotBlank(Request.Place_of_Residence__c)){
                Request.Place_of_Residence_En__c=countryEnMap.get(Request.Place_of_Residence__c);
                Request.Place_of_Residence_Zh__c=countryZhMap.get(Request.Place_of_Residence__c);
            }
            if(String.isNotBlank(Request.Place_of_Birth__c)){
                Request.Place_of_Birth_En__c=countryEnMap.get(Request.Place_of_Birth__c);
                Request.Place_of_Birth_Zh__c=countryZhMap.get(Request.Place_of_Birth__c);
            }
        }else if(IsBeneficiary){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Beneficiary');
        }else if(IsApp){
            Request.RecordTypeId=getRecordType('Policy_Change_Request__c','Automatic Premium Payment');
        }

        Request.id=policyChangeId;
        upsert Request;

        policyChangeId=Request.id;
        if(IsOwner||IsBeneficiary){
            Id RequestDetailRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Beneficiary');
            List<Policy_Change_Request_Detail__c> listPolicyChangeReqDetailToInsert=new List<Policy_Change_Request_Detail__c>();

            if(policyChangeId!=null&&policyChangeId!=''){
                system.debug('beneficiary: '+policyChangeId);
                system.debug('ListRequestDetail: '+ListRequestDetail.size());
                if(ListRequestDetail.size()>0){
                    for(Policy_Change_Request_Detail__c reqDetail : ListRequestDetail){
                        Policy_Change_Request_Detail__c  objreqDetail=new Policy_Change_Request_Detail__c();
                        objreqDetail.RecordTypeId=RequestDetailRecordTypeId;
                        objreqDetail.Policy_Change_Request__c=policyChangeId;
                        objreqDetail.id=reqDetail.id;
                        objreqDetail.English_Name__c=reqDetail.English_Name__c;
                        objreqDetail.HKID_Birth_Cert_Passport_No__c=reqDetail.HKID_Birth_Cert_Passport_No__c;
                        objreqDetail.Relationship_with_Person_Insured__c=reqDetail.Relationship_with_Person_Insured__c;
                        objreqDetail.Share__c=reqDetail.Share__c;
                        if(objreqDetail.English_Name__c!=''&&objreqDetail.HKID_Birth_Cert_Passport_No__c!=''&&objreqDetail.Relationship_with_Person_Insured__c!=''&&objreqDetail.Share__c>0){
                            listPolicyChangeReqDetailToInsert.add(objreqDetail);
                        }
                    }

                    if(listPolicyChangeReqDetailToInsert.size()>0){
                        upsert listPolicyChangeReqDetailToInsert;
                        ListRequestDetail=[SELECT Id,Name,Policy_Change_Request__c,English_Name__c,HKID_Birth_Cert_Passport_No__c,Relationship_with_Person_Insured__c,Share__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId];
                    }
                }
            }
        }else if(IsApp){
            Id RequestDetailRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','APP Deduction Sequence');
            List<Policy_Change_Request_Detail__c> listAppFundDetailToInsert=new List<Policy_Change_Request_Detail__c>();

            if(policyChangeId!=null&&policyChangeId!=''){
                if(ListAppFundDetail.size()>0){
                    for(Policy_Change_Request_Detail__c reqDetail : ListAppFundDetail){
                        Policy_Change_Request_Detail__c  objreqDetail=new Policy_Change_Request_Detail__c();
                        objreqDetail.RecordTypeId=RequestDetailRecordTypeId;
                        objreqDetail.Policy_Change_Request__c=policyChangeId;
                        objreqDetail.id=reqDetail.id;
                        objreqDetail.Fund_Code__c=reqDetail.Fund_Code__c;
                        objreqDetail.Fund_Name__c=reqDetail.Fund_Name__c;
                        objreqDetail.Fund_Name_Chinese__c=reqDetail.Fund_Name_Chinese__c;
                        objreqDetail.Total__c=reqDetail.Total__c;
                        objreqDetail.Sequence__c=reqDetail.Sequence__c;
                        if(objreqDetail.Sequence__c>0){
                            listAppFundDetailToInsert.add(objreqDetail);
                        }
                    }

                    if(listAppFundDetailToInsert.size()>0){
                        upsert listAppFundDetailToInsert;
                        /*ListAppFundDetail=[SELECT Id,
                                                    Name,
                                                    Policy_Change_Request__c,
                                                    Fund_Code__c,
                                                    Fund_Name__c,
                                                    Fund_Name_Chinese__c,
                                                    Total__c,
                                                    Sequence__c
                                                    FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId];*/

                    }
                }
            }
        }else if(IsBenefit){
            //for sum insured
            Id RequestDetailSumInsuredRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Benefit Change Sum Insured');
            List<Policy_Change_Request_Detail__c> listBenefitSumInsuredToInsert=new List<Policy_Change_Request_Detail__c>();

            //for add delete rider
            Id RequestDetailRiderRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Benefit Rider');
            List<Policy_Change_Request_Detail__c> listBenefitRiderToInsert=new List<Policy_Change_Request_Detail__c>();

            //for Additional Contribution
            Id RequestDetailAdditionalConRecordTypeId=getRecordType('Policy_Change_Request_Detail__c','Benefit Additional Contribution');
            List<Policy_Change_Request_Detail__c> listBenefitAdditionalConToInsert=new List<Policy_Change_Request_Detail__c>();

            //for sum insured
            if(policyChangeId!=null&&policyChangeId!=''){
                if(ListBenefitSumInsured.size()>0){
                    for(Policy_Change_Request_Detail__c reqDetail : ListBenefitSumInsured){
                        Policy_Change_Request_Detail__c  objreqDetail=new Policy_Change_Request_Detail__c();
                        objreqDetail.RecordTypeId=RequestDetailSumInsuredRecordTypeId;
                        objreqDetail.Policy_Change_Request__c=policyChangeId;
                        objreqDetail.id=reqDetail.id;
                        objreqDetail.Benefit_Name_Code__c=reqDetail.Benefit_Name_Code__c;
                        objreqDetail.Benefit_Name_Code_Chinese__c=reqDetail.Benefit_Name_Code_Chinese__c;
                        objreqDetail.Sum_Insured_From_Currency__c=reqDetail.Sum_Insured_From_Currency__c;
                        objreqDetail.Sum_Insured_To__c=reqDetail.Sum_Insured_To__c;
                        listBenefitSumInsuredToInsert.add(objreqDetail);
                    }

                    if(listBenefitSumInsuredToInsert.size()>0){
                        upsert listBenefitSumInsuredToInsert;
                        request.Change_of_Sum_Insured_Information__c=true;
                        request.id=policyChangeId;
                        update Request;

                        ListBenefitSumInsured=[SELECT Id,Name,Policy_Change_Request__c,Benefit_Name_Code__c,Benefit_Name_Code_Chinese__c,Sum_Insured_From_Currency__c,Sum_Insured_To__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: RequestDetailSumInsuredRecordTypeId];
                    }
                }

                //for add delete rider
                if(ListBenefitRider.size()>0){
                    for(Policy_Change_Request_Detail__c reqDetail : ListBenefitRider){
                        Policy_Change_Request_Detail__c  objreqDetail=new Policy_Change_Request_Detail__c();
                        objreqDetail.RecordTypeId=RequestDetailRiderRecordTypeId;
                        objreqDetail.Policy_Change_Request__c=policyChangeId;
                        objreqDetail.id=reqDetail.id;
                        objreqDetail.Add_Delete_Rider__c=reqDetail.Add_Delete_Rider__c;
                        objreqDetail.Rider_Benefit_Name_Code__c=reqDetail.Rider_Benefit_Name_Code__c;
                        listBenefitRiderToInsert.add(objreqDetail);
                    }

                    if(listBenefitRiderToInsert.size()>0){
                        upsert listBenefitRiderToInsert;
                        Request.Add_Delete_Rider__c=true;
                        update Request;

                        ListBenefitRider=[SELECT Id,Name,Policy_Change_Request__c,Add_Delete_Rider__c,Rider_Benefit_Name_Code__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: RequestDetailRiderRecordTypeId];
                    }
                }

                // for Additional Contribution
                if(Request.Additional_Contribution__c=='Single'){
                    if(ListBenefitSingle.size()>0){
                        for(Policy_Change_Request_Detail__c reqDetail : ListBenefitSingle){
                            Policy_Change_Request_Detail__c  objreqDetail=new Policy_Change_Request_Detail__c();
                            objreqDetail.RecordTypeId=RequestDetailAdditionalConRecordTypeId;
                            objreqDetail.Policy_Change_Request__c=policyChangeId;
                            objreqDetail.id=reqDetail.id;
                            objreqDetail.Single_Name_of_Investment_Choice__c=reqDetail.Single_Name_of_Investment_Choice__c;
                            objreqDetail.Amount__c=reqDetail.Amount__c;
                            listBenefitAdditionalConToInsert.add(objreqDetail);
                        }

                        if(listBenefitAdditionalConToInsert.size()>0){
                            upsert listBenefitAdditionalConToInsert;
                            ListBenefitSingle=[SELECT Id,Name,Policy_Change_Request__c,Single_Name_of_Investment_Choice__c,Amount__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: RequestDetailAdditionalConRecordTypeId AND Policy_Change_Request__r.Additional_Contribution__c='Single'];
                        }
                    }
                }else if(Request.Additional_Contribution__c=='Regular'){
                    if(ListBenefitRegular.size()>0){
                        for(Policy_Change_Request_Detail__c reqDetail : ListBenefitRegular){
                            Policy_Change_Request_Detail__c  objreqDetail=new Policy_Change_Request_Detail__c();
                            objreqDetail.RecordTypeId=RequestDetailAdditionalConRecordTypeId;
                            objreqDetail.Policy_Change_Request__c=policyChangeId;
                            objreqDetail.id=reqDetail.id;
                            objreqDetail.Name_of_Investment_Choice_Regular__c=reqDetail.Name_of_Investment_Choice_Regular__c;
                            objreqDetail.Allocation__c=reqDetail.Allocation__c;
                            listBenefitAdditionalConToInsert.add(objreqDetail);
                        }

                        if(listBenefitAdditionalConToInsert.size()>0){
                            upsert listBenefitAdditionalConToInsert;
                            ListBenefitRegular=[SELECT Id,Name,Policy_Change_Request__c,Name_of_Investment_Choice_Regular__c,Allocation__c FROM Policy_Change_Request_Detail__c WHERE Policy_Change_Request__c=: policyChangeId AND RecordTypeId=: RequestDetailAdditionalConRecordTypeId AND Policy_Change_Request__r.Additional_Contribution__c='Regular'];
                        }
                    }
                }
            }
        }
    }

    /*Save e-signature*/
    public void submitEsignature(){
        if(policyChangeId!=null&&policyChangeId!=''){
            /*e-signature For Customer single signature*/
            if(String.isNotBlank(eSignature)){
                eSignature=eSignature.substring(eSignature.indexOf(',')+1,eSignature.length());
                Transient Blob fileContent=EncodingUtil.base64Decode(eSignature);
                Attachment a=new Attachment(parentId=policyChangeId);
                a.body=fileContent;
                a.ContentType='image/png';
                if(IsOwner){
                    if(CignaUtil.isCustomerPortal()){
                        a.name='newph_esignature';
                    }else{
                        a.name='ph_esignature';
                    }
                }

                if(IsThirdParty){
                    if(CignaUtil.isCustomerPortal()){
                        a.name='3p_esignature';
                    }else{
                        a.name='ph_esignature';
                    }
                }

                if(!IsThirdParty&&!IsOwner){
                    a.name='ph_esignature';
                }
                insert a;
            }

            if(String.isNotBlank(eSignature2)){
                eSignature2=eSignature2.substring(eSignature2.indexOf(',')+1,eSignature2.length());
                Transient Blob fileContent=EncodingUtil.base64Decode(eSignature2);
                Attachment a=new Attachment(parentId=policyChangeId);
                a.body=fileContent;
                a.ContentType='image/png';
                if(IsOwner){
                    a.name='newph_esignature';
                }

                if(IsThirdParty){
                    a.name='3p_esignature';
                }

                if(!IsThirdParty&&!IsOwner){
                    a.name='ph_esignature';
                }
                insert a;
            }
        }
    }

    /*submit change and update the status to In Progress*/
    public PageReference submitPolicyChange(){
        //add Bob 20201218 CM User
        //Rancho_IA_AML_Inspection_20211005: for test class
        if(!Test.isRunningTest() && CignaUtil.isCMLoginAsUser()){
            CignaUtil.stopSubmittionforCMUser();
            return null;
        }
        if(policyChangeId!=null&&policyChangeId!=''){
            /*depends on different record type to generate different PDF*/
            String requestURL='';

            if(IsPersonal){
                requestURL='/CustomerFormBasicInfoPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsBeneficiary){
                requestURL='/CustomerFormBeneficiaryPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsOwner){
                requestURL='/CustomerFormOwnershipPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsDD){
                requestURL='/CustomerFormPaymentInfoPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsCopyDoc){
                requestURL='/CustomerFormRequestCopyPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsRenew){
                requestURL='/CustomerFormReinstatementPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsAPP){
                requestURL='/PolicyChangeAPPFormPDFExportVFP?policyChangeRequestId='+policyChangeId;
            }else if(IsBenefit){
                requestURL='/PolicyChangeBenefitFormPDFExportVFP?policyChangeRequestId='+policyChangeId;
            }

            String attPdfId='';
            // Rancho_PI80_20221011 - update file name to avoid file type mismatch issue
            List<Attachment> listAttPdf=[SELECT Id FROM Attachment Where parentId=:policyChangeId AND Name='0policychange.pdf' LIMIT 1];
            if(listAttPdf!=null&&listAttPdf.size()>0){
                attPdfId=listAttPdf[0].id;
            }
            /*Web service to send out the PDF and attachment*/

            // FileScanning_Link_20220530
            scanPopup=false;
            if(OpswatWebService.checkScanStatus(policyChangeId)){
                if(!OpswatWebService.checkScanResult(policyChangeId)){
                    System.debug('Policy change file have virus');
                    scanPopup=true;
                }
            }else{
                System.debug('Policy change file scanning not done');
                scanPopup=true;
            }

            Attachment att=new Attachment();
            att.name='0policychange.pdf';
            if(attPdfId!=''){
                att.id=attPdfId;
            }
            att.contentType='application/pdf';
            att.parentId=policyChangeId;
            if(!test.isrunningtest()){
                /*Web service to send out the PDF and attachment*/
                policychangePDF=new PageReference(requestURL).getContentAsPDF();
                att.body=policychangePDF;
                upsert att;
            }

            List<Attachment> attachmentList=[SELECT Id FROM Attachment Where parentId=:policyChangeId AND (NOT Name LIKE '%esignature%') ORDER BY Name];
            Integer attSize=attachmentList.size();
            Boolean isNoAtt=false;
            if(attSize==1){
                isNoAtt=true;
            }
            // FileScanning_Link_20220530
            if(scanPopup){
                System.enqueueJob(new GetScandeatils(policyChangeId,'PolicyChange',CignaUtil.isCustomerPortal(),new SubmitWorkRequestQueue(policyChangeId,attachmentList,sitePrefix,isNoAtt,attSize,'','','','')));
            }else{
                System.enqueueJob(new SubmitWorkRequestQueue(policyChangeId,attachmentList,sitePrefix,isNoAtt,attSize,'','','',''));
            }
            // System.enqueueJob(new SubmitWorkRequestQueue(policyChangeId,attachmentList,sitePrefix,isNoAtt,attSize,'','','',''));
            attachmentList=null;
            //submitRequestToAppian(policyChangeId,policychangePDF,sitePrefix,isNoAtt,attSize);

            Policy_Change_Request__c Request=new Policy_Change_Request__c ();
            Request.id=policyChangeId;
            Request.Status__c='In Progress';
            // Rancho_PI84_20221111 - align old data policy type with WS
            Request.IsLifePolicy__c = isLife;
            Request.IsGerneralPolicy__c = isGeneral;
            update Request;

            //20191224 - Terry - Signature Require
            List<E_Signature_Request__c> signatureReq=[SELECT id,name,E_Signature_URL__c,Request_Type__c,Policy_Change_Request__c FROM E_Signature_Request__c
            WHERE Policy_Change_Request__c=:policyChangeId AND Completed__c=False];

            if(signatureReq!=null&&signatureReq.size()>0){
                for(E_Signature_Request__c signReq : signatureReq){
                    signReq.Completed__c=True;
                }
                update signatureReq;
            }
        }
        return null;
    }

    public static PageReference submitPolicyChangeFromEmail(Id policyChangeId,String sitePrefix,String RecordType, Boolean scanResult){
        //add Bob 20201218 CM User
        //Rancho_IA_AML_Inspection_20211005: for test class
        if(!Test.isRunningTest() && CignaUtil.isCMLoginAsUser()){
            CignaUtil.stopSubmittionforCMUser();
            return null;
        }
        /*depends on different record type to generate different PDF*/
        Transient Blob policychangePDF;
        String requestURL='';

        if(RecordType.contains('Basic')){
            requestURL='/CustomerFormBasicInfoPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Beneficiary')){
            requestURL='/CustomerFormBeneficiaryPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Ownership')){
            requestURL='/CustomerFormOwnershipPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Payment')&&RecordType.contains('Information')){
            requestURL='/CustomerFormPaymentInfoPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('copy')){
            requestURL='/CustomerFormRequestCopyPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('reinstatement')){
            requestURL='/CustomerFormReinstatementPDFDownloadVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Benefit')){
            requestURL='/PolicyChangeBenefitFormPDFExportVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Automatic')){
            requestURL='/PolicyChangeAPPFormPDFExportVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Switch')){
            requestURL='/PolicyChangeFundSwitchingPDFVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Reallocation')){
            requestURL='/PolicyChangeFundReallocationPDFVFP?policyChangeRequestId='+policyChangeId;
        }else if(RecordType.contains('Withdrawal')){
            requestURL='/PolicyChangeFundWithdrawalPDFVFP?policyChangeRequestId='+policyChangeId;
        }

        System.debug('requestURL:'+requestURL);
        String attPdfId='';
        // Rancho_PI80_20221011 - update file name to avoid file type mismatch issue
        List<Attachment> listAttPdf=[SELECT Id FROM Attachment Where parentId=:policyChangeId AND Name='0policychange.pdf' LIMIT 1];
        if(listAttPdf!=null&&listAttPdf.size()>0){
            attPdfId=listAttPdf[0].id;
        }

        Attachment att=new Attachment();
        att.name='0policychange.pdf';
        if(attPdfId!=''){
            att.id=attPdfId;
        }
        att.contentType='application/pdf';
        att.parentId=policyChangeId;
        if(!test.isrunningtest()){
            // 20240104 - minghua MR-724 In-App Message - There is no response when we click the Broker - Related message
            requestURL='/apex'+requestURL;
            /*Web service to send out the PDF and attachment*/
            policychangePDF=new PageReference(requestURL).getContentAsPDF();
            att.body=policychangePDF;
            upsert att;
        }

        List<Attachment> attachmentList=[SELECT Id FROM Attachment Where parentId=:policyChangeId AND (NOT Name LIKE '%esignature%') ORDER BY Name];
        Integer attSize=attachmentList.size();
        Boolean isNoAtt=false;
        if(attSize==1){
            isNoAtt=true;
        }

        // JOBR-126 File Scaning Security: not submit to other system if found virus file. 2022-06-28 Zane
        if(scanResult){
            System.enqueueJob(new GetScandeatils(policyChangeId,'PolicyChange',CignaUtil.isCustomerPortal(),new SubmitWorkRequestQueue(policyChangeId,attachmentList,sitePrefix,isNoAtt,attSize,'','','','')));
        }else{
            System.enqueueJob(new SubmitWorkRequestQueue(policyChangeId,attachmentList,sitePrefix,isNoAtt,attSize,'','','',''));
        }
        attachmentList=null;
        //submitRequestToAppian(policyChangeId,policychangePDF,sitePrefix,isNoAtt,attSize);

        Policy_Change_Request__c Request=new Policy_Change_Request__c ();
        Request.id=policyChangeId;
        Request.Status__c='In Progress';
        Request.eSignature_Status__c='eSignature signed by email';
        update Request;

        //20191224 - Terry - Signature Require
        List<E_Signature_Request__c> signatureReq=[SELECT id,name,E_Signature_URL__c,Request_Type__c,Policy_Change_Request__c FROM E_Signature_Request__c
        WHERE Policy_Change_Request__c=:policyChangeId AND Completed__c=False];

        if(signatureReq!=null&&signatureReq.size()>0){
            for(E_Signature_Request__c signReq : signatureReq){
                signReq.Completed__c=True;
            }
            update signatureReq;
        }
        return null;
    }

    public void sendEmailSignature(){
        if(UserInfo.getLanguage()=='en_US'){
            if(!test.isrunningtest()){
                //ESignatureUtil.sendEmail(policyChangeId,'Email_to_send_signature_link_PC_English' ,esignatureEmail ,true,'Policy_Change_T_and_C','Cigna Hong Kong') ;
                ESignatureUtil.sendEmailWebService(policyChangeId,'Email to send signature link PC English',esignatureEmail,true,'Policy_Change_T_and_C','Cigna Hong Kong');                

                //Chris_JR1830_20200512
                List<EmailTemplate> emailTempList=[SELECT Id FROM EmailTemplate WHERE Name='Email to send to broker English'];
                if (emailTempList.size()>0&&String.isNotBlank(brokerEsignEmail)){
                    // system.debug('send to broker'+UserInfo.getUserEmail());
                    ESignatureUtil.sendOutEmailWebserive(emailTempList[0].Id,UserInfo.getUserId(),policyChangeId,brokerEsignEmail);
                }
            }
        }else{
            if(!test.isrunningtest()){
                //ESignatureUtil.sendEmail(policyChangeId,'Email_to_send_signature_link_PC_Chinese' ,esignatureEmail ,true,'Policy_Change_T_and_C','Cigna Hong Kong') ;
                ESignatureUtil.sendEmailWebService(policyChangeId,'Email to send signature link PC Chinese',esignatureEmail,true,'Policy_Change_T_and_C','Cigna Hong Kong');

                //Chris_JR1830_20200512
                List<EmailTemplate> emailTempList=[SELECT Id FROM EmailTemplate WHERE Name='Email to send to broker Chinese'];
                if (emailTempList.size()>0&&String.isNotBlank(brokerEsignEmail)){
                    // system.debug('send to broker');
                    ESignatureUtil.sendOutEmailWebserive(emailTempList[0].Id,UserInfo.getUserId(),policyChangeId,brokerEsignEmail);
                }
            }
        }

        Policy_Change_Request__c Request=new Policy_Change_Request__c ();
        Request.id=policyChangeId;
        Request.eSignature_Status__c='Email Sent';
        if(CignaUtil.isCustomerPortal()){
            Request.current_step__c=6;           
        }else{
            Request.current_step__c=7;
        }
        FromEmail=true;
        update Request;

        //20191224 - Terry - Signature Require
        List<E_Signature_Request__c> signatureReq=[SELECT id,name,E_Signature_URL__c,Request_Type__c,Policy_Number__c,Policy_Change_Request__c FROM E_Signature_Request__c
        WHERE Policy_Change_Request__c=:policyChangeId AND Completed__c=False];
        String eSignLink='';
        String policyNo='';
        String phId='';
        for(Policy_Change_Request__c polChangeReq : [SELECT E_Signature_Link__c,Policy_No__c,Policy_Holder_ID__c FROM Policy_Change_Request__c WHERE id=:policyChangeId]){
            eSignLink=polChangeReq.E_Signature_Link__c;
            policyNo=polChangeReq.Policy_No__c;
            phId=polChangeReq.Policy_Holder_ID__c;
        }

        if(signatureReq!=null&&signatureReq.size()>0){
            for(E_Signature_Request__c signReq : signatureReq){
                signReq.E_Signature_URL__c=eSignLink;
            }
            update signatureReq;
        }else{
            Id phUserId=UserInfo.getUserId();
            if(phId!=null&&phId!=''){
                List<User> phUsers=[SELECT id FROM User WHERE AccountId IN (SELECT id FROM Account WHERE SSN__c=:phId)];
                if(phUsers.size()>0){
                    phUserId=phUsers[0].Id;
                }
            }

            E_Signature_Request__c signReq=new E_Signature_Request__c(E_Signature_URL__c=eSignLink,Policy_Change_Request__c=policyChangeId,Policy_Number__c=policyNo,Request_Type__c='Policy Change',OwnerId=phUserId);
            insert signReq;
        }
    }

    /*control attachment display*/
    public void checkAttDisplay(){
        if(IsPersonal){
            //if(IsPersonalParti){
            PhPiIdCopy=true;
            deedPoll=true;
            //requireAtt=true;
            // }
            // if(IsAddress){
            //20190726 - David Zhang - No attachment for address change
            //PhPiAddProof=true;
            requireAtt=true;
            //}
        }

        if(IsBeneficiary){
            requireAtt=false;
        }

        if(IsOwner){
            //20190726 - David Zhang - No attachment for address change
            //currentPhAddProof=true;
            currentPhIdCopy=true;
            //newPHAddProof=true;
            newPHIdCopy=true;
            requireAtt=true;
        }

        if(IsBenefit){
            requireAtt=false;
            if(isLife||isIlas||isDownload){
                if(isLife){
                    FNA=true;
                }

                if(isIlas){
                    riskProfileQuestion=true;
                }

                requireAtt=true;

            }else{
                FNA=false;
                riskProfileQuestion=false;
                requireAtt=false;
            }
        }

        if(IsApp){
            requireAtt=false;
        }

        if(IsCopyDoc){
            requireAtt=false;
        }

        if(IsDD){
            currentPhIdCopy=true;
            if(IsThirdParty){
                thirdPartyAddProof=true;
                thirdPartyIdCopy=true;
            }else{
                thirdPartyAddProof=false;
                thirdPartyIdCopy=false;
            }
            requireAtt=true;
        }

        if(IsRenew){
            currentPhIdCopy=true;
            currentPiIdCopy=true;
            //20190726 - David Zhang - No attachment for address change
            /*
            if(isLife){
                currentPhAddProof=true;
            }else{
                currentPhAddProof=false;
            }
            */
            requireAtt=true;
        }
    }

    public void addRowBeneficiary(){
        Policy_Change_Request_Detail__c newBeneficiary=new Policy_Change_Request_Detail__c();
        if(ListRequestDetail.size()<4){
            ListRequestDetail.add(newBeneficiary);
        }
    }

    public void removeRowBeneficiary(){
        if(ListRequestDetail.size()>0){
            if(rowIndex!=null){
                deleteReqDetailId=ListRequestDetail[rowIndex].Id;
                ListRequestDetail.remove(rowIndex);
            }

            if(deleteReqDetailId!=null&&deleteReqDetailId!=''){
                List<Policy_Change_Request_Detail__c> checkReqDetailExit=[SELECT id FROM Policy_Change_Request_Detail__c WHERE id=:deleteReqDetailId];
                Policy_Change_Request_Detail__c delReqDetail=new Policy_Change_Request_Detail__c();
                delReqDetail.id=deleteReqDetailId;

                if(checkReqDetailExit!=null){
                    if(checkReqDetailExit.size()>0){
                        delete(delReqDetail);
                    }
                }
            }
        }
    }

    public void clearBeneficiary(){
        if(ListRequestDetail!=null){
            ListRequestDetail.clear();
        }
    }

    /*Get All Available Fund List*/
    public void getAllAvailFundOptions(){
        availFundMap=new Map<String,HttpCalloutVO.PolicyAvailFund>();
        availFundOptions=new List<SelectOption>();
        availFundOptions.add(new SelectOption('',system.label.Please_select));
        List<Policy_Change_Request_Detail__c> tempListAppFundDetail=new List<Policy_Change_Request_Detail__c>();
        PolicyCalloutHelper helper=new PolicyCalloutHelper();
        policyAvailFundList=new List <HttpCalloutVO.PolicyAvailFund>();
        policyAvailFundList=helper.getPolicyAvailFundListBasic(PolicyChoice,PriceType_BasicPlan);
        policyPaymentPaidToDate=getPolicyPaymentBasicPaidToDate();

        if(policyAvailFundList!=null&&!policyAvailFundList.isEmpty()){
            for(HttpCalloutVO.PolicyAvailFund fund : policyAvailFundList){
                Policy_Change_Request_Detail__c newFund=new Policy_Change_Request_Detail__c();
                newFund.Fund_Code__c=fund.productCode.trim();
                newFund.Fund_Name__c=fund.productFullName.trim();
                newFund.Total__c=fund.totValue;

                if(fund.totValue>0){
                    tempListAppFundDetail.add(newFund);
                }
                // 20210830 - Kirk - additional contribution---Only if statement is added
                if(iLASPlanCodesRiskDiscMap.containsKey(newFund.Fund_Code__c)){
                    availFundOptions.add(new SelectOption(newFund.Fund_Name__c, newFund.Fund_Name__c));
                }
            }

            if(ListAppFundDetail.size()==0){
                ListAppFundDetail.addAll(tempListAppFundDetail);
            }
            // 20210820 - Kirk - Epic 113178-Invesco fund merger
            for(Integer i=0;i<ListAppFundDetail.size();i++){
                if(!iLASPlanCodesRiskSellMap.containsKey(ListAppFundDetail[i].Fund_Code__c)){
                    ListAppFundDetail.remove(i);
                }       
            }

            fundSequence=new List<SelectOption>();
            fundSequence.add(new SelectOption(system.label.Please_select_deduction_sequence,system.label.Please_select_deduction_sequence));

            for(Integer i=0; i<ListAppFundDetail.size(); i++){
                fundSequence.add(new SelectOption(String.ValueOf(i+1),String.ValueOf(i+1)));
            }
        }
    }

    /*get paid to date*/
    public string getPolicyPaymentBasicPaidToDate(){
        List<HttpCalloutVO.PolicyPayment> paymentList=new List<HttpCalloutVO.PolicyPayment>();
        HttpCalloutVO.PolicyPayment payment=new HttpCalloutVO.PolicyPayment();
        PolicyCalloutHelper helper=new PolicyCalloutHelper();

        if(PolicyChoice!=null&&PolicyChoice!=''){
            paymentList=helper.getPolicyPaymentBasic(PolicyChoice);
            if(!paymentList.isEmpty()&&paymentList.size()>0){
                payment=paymentList.get(0);
            }
        }
        return payment.paidToDate;
    }

    public void clearAppFund(){
        if(ListAppFundDetail!=null){
            ListAppFundDetail.clear();
        }
    }

    /*Get All Available Benefit List*/
    public void getBenefitSumInsuredFrom(){
        /*if(rowIndex!=null){
            if(ListBenefitSumInsured[rowIndex].Benefit_Name_Code__c!=null){
                if(availBenefitMap.get(ListBenefitSumInsured[rowIndex].Benefit_Name_Code__c)!=null){
                    ListBenefitSumInsured[rowIndex].Sum_Insured_From_Currency__c=availBenefitMap.get(ListBenefitSumInsured[rowIndex].Benefit_Name_Code__c).currencySymbol;//+' '+String.Valueof(availBenefitMap.get(ListBenefitSumInsured[rowIndex].Benefit_Name_Code__c).benefitAmountInNumber);
                }
            }
        }*/
    }

    public void addRowBenefitSumInsured(){
        Policy_Change_Request_Detail__c newBenefitSumInsured=new Policy_Change_Request_Detail__c();
        newBenefitSumInsured.Sum_Insured_From_Currency__c='USD';

        if(ListBenefitSumInsured.size()<(availBenefitSumInsuredOptions.size()-1)){
            ListBenefitSumInsured.add(newBenefitSumInsured);
        }

    }

    public void removeRowBenefitSumInsured(){
        if(ListBenefitSumInsured.size()>0){
            if(rowIndex!=null){
                deleteBenefitDetailId=ListBenefitSumInsured[rowIndex].Id;
                ListBenefitSumInsured.remove(rowIndex);
            }

            if(deleteBenefitDetailId!=null&&deleteBenefitDetailId!=''){
                List<Policy_Change_Request_Detail__c> checkReqDetailExit=[SELECT id FROM Policy_Change_Request_Detail__c WHERE id=: deleteBenefitDetailId];
                Policy_Change_Request_Detail__c delReqDetail=new Policy_Change_Request_Detail__c();
                delReqDetail.id=deleteBenefitDetailId;

                if(checkReqDetailExit!=null){
                    if(checkReqDetailExit.size()>0){
                        delete(delReqDetail);
                    }
                }
            }
        }
    }

    public void clearBenefitSumInsured(){
        if(ListBenefitSumInsured!=null){
            ListBenefitSumInsured.clear();
        }
    }

    /** Add / Delete Row Benefit Rider **/
    public void addRowBenefitRider(){
        Policy_Change_Request_Detail__c newBenefitRider=new Policy_Change_Request_Detail__c();
        ListBenefitRider.add(newBenefitRider);

    }

    public void removeRowBenefitRider(){
        if(ListBenefitRider.size()>0){
            if(rowIndex!=null){
                deleteBenefitDetailId=ListBenefitRider[rowIndex].Id;
                ListBenefitRider.remove(rowIndex);
            }

            if(deleteBenefitDetailId!=null&&deleteBenefitDetailId!=''){
                List<Policy_Change_Request_Detail__c> checkReqDetailExit=[SELECT id FROM Policy_Change_Request_Detail__c WHERE id=: deleteBenefitDetailId];
                Policy_Change_Request_Detail__c delReqDetail=new Policy_Change_Request_Detail__c();
                delReqDetail.id=deleteBenefitDetailId;

                if(checkReqDetailExit!=null){
                    if(checkReqDetailExit.size()>0){
                        delete(delReqDetail);
                    }
                }
            }
        }
    }

    public void clearBenefitRider(){
        if(ListBenefitRider!=null){
            ListBenefitRider.clear();
        }
    }

    /**Single Additional Contribution**/

    public void addRowBenefitSingle(){
        Policy_Change_Request_Detail__c newBenefitSingle=new Policy_Change_Request_Detail__c();
        if(ListBenefitSingle.size()<8){
            ListBenefitSingle.add(newBenefitSingle);
        }
    }

    public void removeRowBenefitSingle(){
        if(ListBenefitSingle.size()>0){
            if(rowIndex!=null){
                deleteBenefitDetailId=ListBenefitSingle[rowIndex].Id;
                ListBenefitSingle.remove(rowIndex);
            }

            if(deleteBenefitDetailId!=null&&deleteBenefitDetailId!=''){
                List<Policy_Change_Request_Detail__c> checkReqDetailExit=[SELECT id FROM Policy_Change_Request_Detail__c WHERE id=: deleteBenefitDetailId];
                Policy_Change_Request_Detail__c delReqDetail=new Policy_Change_Request_Detail__c();
                delReqDetail.id=deleteBenefitDetailId;

                if(checkReqDetailExit!=null){
                    if(checkReqDetailExit.size()>0){
                        delete(delReqDetail);
                    }
                }
            }
        }
    }

    public void clearBenefitSingle(){
        if(ListBenefitSingle!=null){
            ListBenefitSingle.clear();
        }
    }

    /**Regular Additional Contribution**/
    public void addRowBenefitRegular(){
        Policy_Change_Request_Detail__c newBenefitRegular=new Policy_Change_Request_Detail__c();
        if(ListBenefitRegular.size()<8){
            ListBenefitRegular.add(newBenefitRegular);
        }
    }

    public void removeRowBenefitRegular(){
        if(ListBenefitRegular.size()>0){
            if(rowIndex!=null){
                ListBenefitRegular.remove(rowIndex);
            }

            if(deleteBenefitDetailId!=null&&deleteBenefitDetailId!=''){
                List<Policy_Change_Request_Detail__c> checkReqDetailExit=[SELECT id FROM Policy_Change_Request_Detail__c WHERE id=: deleteBenefitDetailId];
                Policy_Change_Request_Detail__c delReqDetail=new Policy_Change_Request_Detail__c();
                delReqDetail.id=deleteBenefitDetailId;

                if(checkReqDetailExit!=null){
                    if(checkReqDetailExit.size()>0){
                        delete(delReqDetail);
                    }
                }
            }
        }
    }

    public void clearBenefitRegular(){
        if(ListBenefitRegular!=null){
            ListBenefitRegular.clear();
        }
    }

    /*get attachment list*/
    public List<Attachment> getListHkidAtt(){
        return getListAtt('HKIDAtt');
    }

    public List<Attachment> getListAddressAtt(){
        return getListAtt('AddressAtt');
    }

    public List<Attachment> getListDeedPollAtt(){
        return getListAtt('DeedPollAtt');
    }

    public List<Attachment> getListPiHkidAtt(){
        return getListAtt('PIHKIDAtt');
    }

    public List<Attachment> getListNewPhHkidAtt(){
        return getListAtt('NewPHHKIDAtt');
    }

    public List<Attachment> getListNewPhAddressAtt(){
        return getListAtt('NewPHAddressAtt');
    }

    public List<Attachment> getListPhHkidAtt(){
        return getListAtt('PHHKIDAtt');
    }

    public List<Attachment> getListTpHkidAtt(){
        return getListAtt('TPHKIDAtt');
    }

    public List<Attachment> getListTpAddressAtt(){
        return getListAtt('TPAddressAtt');
    }

    public List<Attachment> getListDDAAtt(){
        return getListAtt('DDAAtt');
    }

    public List<Attachment> getListBenefitFNA(){
        return getListAtt('BenefitFNA');
    }

    public List<Attachment> getListRPQAtt(){
        return getListAtt('RPQAtt');
    }

    public List<Attachment> getListGMAtt(){
        return getListAtt('GMAtt');
    }

    public List<Attachment> getListJCAtt(){
        return getListAtt('JCAtt');
    }

    public List<Attachment> getListGMPAtt(){
        return getListAtt('GMPAtt');
    }

    public List<Attachment> getListPMAtt(){
        return getListAtt('PMAtt');
    }

    public List<Attachment> getListCIPLAtt(){
        return getListAtt('CIPLAtt');
    }


    /*get general attachment list*/
    public List<Attachment> getListAtt(String attType){
        List<Attachment> lstAttrename=new List<Attachment>();
        List<Attachment> lstAtt=new List<Attachment>();
        if(policyChangeId!=''&&policyChangeId!=null){
            lstAtt=[SELECT Name FROM Attachment Where parentId=:policyChangeId and Name LIKE: attType+'%'];
            for(Attachment att :lstAtt){
                Attachment tempAtt=new Attachment();
                tempAtt.Name=att.name.removeStart(attType+'_');
                tempAtt.Id=att.id;
                lstAttrename.add(tempAtt);
            }
        }
        return lstAttrename;
    }

    /*check attachment list*/
    public void checkAtt(){
        hasAtt=false;
        if(IsPersonal){
            if(CignaUtil.isCustomerPortal()){
                if(getListHkidAtt().size()>0||getListAddressAtt().size()>0||getListDeedPollAtt().size()>0){
                    hasAtt=true;
                }
            }else{
                hasAtt=true;
            }
        }

        if(IsDD){
            if(IsThirdParty){
                if(getListTpHkidAtt().size()>0||getListTpAddressAtt().size()>0||getListPhHkidAtt().size()>0||getListHkidAtt().size()>0){
                    hasAtt=true;
                }
            }else{
                if(getListPhHkidAtt().size()>0||getListHkidAtt().size()>0){
                    hasAtt=true;
                }
            }
        }

        if(IsBenefit){
            //if(getListBenefitFNA().size()>0||getListRPQAtt().size()>0){
            hasAtt=true;
            //}
        }

        if(IsOwner){
            if(getListHkidAtt().size()>0||getListAddressAtt().size()>0||getListNewPhHkidAtt().size()>0||getListNewPhAddressAtt().size()>0){
                hasAtt=true;
            }
        }

        if(IsRenew){
            if(getListHkidAtt().size()>0||getListAddressAtt().size()>0 ||getListPiHkidAtt().size()>0){
                hasAtt=true;
            }
        }
    }

    /*remove attachment*/
    public void removeAtt(){
        if(removeAttId!=null&&removeAttId!=''){
            List<Attachment> checkExit=[SELECT id FROM Attachment WHERE id=:removeAttId];
            Attachment att=new Attachment();
            att.id=removeAttId;

            if(checkExit!=null&&checkExit.size()>0){
                delete(att);
            }
            checkAtt();
        }
    }

    /*Dummy Wrapper Object*/
    public class Policy{
        public String policyName{get;set;}
        public String policyNo{get;set;}
        public String policyHolderId{get;set;}
        public String policyStatus{get;set;}
        public String policyStatusChecking{get;set;}
        public String policyHolder{get;set;}
        public String agentCode{get;set;}
        public String brokerName{get;set;}
        public Boolean allowChangeOwner{get;set;}
        public Boolean allowChangePaymentDate{get;set;}
        public Boolean isLifePolicy{get;set;}
        public Boolean isILAS{get;set;}
        public Boolean isIPMIPolicy{get;set;}

        /*for reteriving the selected policy*/
        public Boolean policySelected{get;set;}
        /*for reteriving the selected policy holder*/
        public Boolean policyHolderSelected{get;set;}
        public String productCode{get;set;}//GL31 jack add
    }

    public class PolicyInsured{
        public String policyNo{get;set;}
        public String policyInsured{get;set;}
        public String policyInsuredId{get;set;}
        /*for reteriving the selected policy Insured*/
        public Boolean policyInsuredselected{get;set;}
    }

    /*Nicole Modify Start*/
    public static List<HttpCalloutVO.Policy> getPolicyListbyAPI(String PolicyHolderId){
        List<HttpCalloutVO.Policy> policyListbyHolder=new List<HttpCalloutVO.Policy>();
        PolicyCalloutHelper policyHelper=new PolicyCalloutHelper();

        List<String> ListStatus=new List<String>();
        List<Policy_Status_Mapping__c> tempListStatus=[SELECT Description__c FROM Policy_Status_Mapping__c WHERE PolicyStatus__c='Inforce' OR PolicyStatus__c='Lapsed'];

        if(tempListStatus.size()>0){
            for(Policy_Status_Mapping__c status: tempListStatus){
                ListStatus.add(status.Description__c);
            }
        }

        //get SSN Number
        String holderSsnNumber='';
        if(CignaUtil.isBrokerPortal()){
            holderSsnNumber=PolicyHolderId;
            // system.debug('>>>>>>>holderSsnNumber>>>: '+ holderSsnNumber);
        }else{
            Id holderContactId=[Select Id,ContactId From User Where Id=:Userinfo.getUserId()].ContactId;
            Id holderAccountId=[Select Id,AccountId From Contact Where Id=:holderContactId].AccountId;
            holderSsnNumber=[Select Id,SSN__c From Account Where Id=:holderAccountId].SSN__c;          
        }

        // system.debug('****holderSsnNumber****: '+ holderSsnNumber);
        //String holderSsnNumber='G689080';//for testing only
        /*Get policy List*/

        policyListbyHolder=policyHelper.getIndividualPolicyListBasicByCriteria('','',holderSsnNumber,'','','','','');        
        return policyListbyHolder ;
    }

    /*Kevani added a function to get the policy by policy no*/
    public static List<HttpCalloutVO.Policy> getPolicyListbyPolicyNoAPI(String policyno){

        List<HttpCalloutVO.Policy> policyListbyPolicyNo=new List<HttpCalloutVO.Policy>();
        PolicyCalloutHelper policyHelper=new PolicyCalloutHelper();

        List<String> ListStatus=new List<String>();
        List<Policy_Status_Mapping__c> tempListStatus=[SELECT Description__c FROM Policy_Status_Mapping__c WHERE PolicyStatus__c='Inforce' OR PolicyStatus__c='Lapsed'];

        if(tempListStatus.size()>0){
            for(Policy_Status_Mapping__c status: tempListStatus){
                ListStatus.add(status.Description__c);
            }
        }
        /*Get policy List*/
        if(string.IsNotBlank(policyno)){
            policyListbyPolicyNo=policyHelper.getIndividualPolicyListBasicByCriteria(policyno,'','','','','',ListStatus,'');
        }
        return policyListbyPolicyNo;
    }

    /*get policy plan type code (benefit code)*/
    public static List<HttpCalloutVO.PolicyPersonCoverage> getPolicyPlanCode(String policyno){
        List<HttpCalloutVO.PolicyPersonCoverage> tempPolicyListPlanCode=new List<HttpCalloutVO.PolicyPersonCoverage>();
        List<HttpCalloutVO.PolicyPersonCoverage> policyListPlanCode=new List<HttpCalloutVO.PolicyPersonCoverage>();
        Set<String> setBenefitCode=new Set<String>();
        PolicyCalloutHelper policyHelper=new PolicyCalloutHelper();
        List<PolicyInsured> policyInsuredList=new List<PolicyInsured>();
        policyInsuredList=getInsuredList(policyno);
        for(PolicyInsured pi: policyInsuredList){
            tempPolicyListPlanCode.addAll(policyHelper.getPolicyPersonCoverageBasic(policyno,pi.policyInsuredId));
        }
        for(HttpCalloutVO.PolicyPersonCoverage ppc: tempPolicyListPlanCode){
            if(!setBenefitCode.Contains(ppc.benefitCode)&&ppc.termDateInDate>=Date.today()){
                policyListPlanCode.add(ppc);
                setBenefitCode.add(ppc.benefitCode);
            }
        }
        return policyListPlanCode; //policyListPlanCode.benefitCode
    }


    public static list<Policy> getPolicyList(String policyHolderId){
        List<HttpCalloutVO.Policy> policyListbyHolder=getPolicyListbyAPI(policyHolderId);
        system.debug('>>>>policyListbyHolder>>>>: '+policyListbyHolder);
        list<Policy> policyList=new list<Policy>();
        // system.debug('getPolicyList policyListbyHolder: '+policyListbyHolder);
        if(policyListbyHolder.size()>0){
            for(HttpCalloutVO.Policy policy : policyListbyHolder){
                Policy tempolicy=new Policy();
                tempolicy.policyNo=policy.policyNumber ;
                tempolicy.policyName=policy.marketingName;
                tempolicy.policyHolderId=policy.holderSSN ;
                tempolicy.policyHolder=policy.holderName;
                tempolicy.policyStatus=policy.policyStatusDisplayName;
                tempolicy.agentCode=policy.agentCode ;
                tempolicy.brokerName=policy.brokerName ;
                tempolicy.allowChangeOwner=policy.allowChangeOwner ;
                tempolicy.allowChangePaymentDate=policy.allowChangePaymentDate ;
                tempolicy.isLifePolicy=policy.isLifePolicy;
                tempolicy.isILAS=policy.isILAS ;
                tempolicy.isIPMIPolicy=policy.isIPMIPolicy;
                tempolicy.productCode=policy.productCode;//GL31 jack add
                policyList.add(tempolicy);
            }
        }
        return policyList;
    }
    public static list<PolicyInsured> getInsuredList(String policyno){
        List<HttpCalloutVO.Policy> policyListbyHolder=getPolicyListbyPolicyNoAPI(policyno);
        List<PolicyInsured> insuredList=new List<PolicyInsured>();
        if(policyListbyHolder.size()>0){
            for(HttpCalloutVO.Policy policy : policyListbyHolder){
                List<HttpCalloutVO.Person> personList=policy.insuredList;
                selectedProductCode = policy.productCode;
                if(personList.size()>0){
                    for(HttpCalloutVO.Person person : personList){
                        PolicyInsured insured=new PolicyInsured();
                        insured.policyNo=policy.policyNumber;
                        insured.policyInsured=person.fullName;
                        insured.policyInsuredId=person.ssnNumber;
                        insuredList.add(insured);
                    }
                }
            }
        }
        return insuredList ;
    }
    /*Nicole Modify End*/

    //GL31 jack add()
    public void setAvailableRiderMap(){
        String Q1Answer='';
        String Q2Answer='';
        assessRiderMap=new Map<String,String>();
        for (ESaleQuestion question : assessmentQuestionList) {
            System.debug('question:'+question);
            for(ESaleQuestion.ESaleOption option : question.esaleOptions){
                if(option.getAnswer()==option.getValue()){
                    System.debug('selcted option:'+option.getAnswer());
                    if(question.getQuestionId()=='Assessment_Q_1'){
                        Q1Answer=Q1Answer+option.getAnswer()+';';
                    }
                    if(question.getQuestionId()=='Assessment_Q_2'){
                        Q2Answer=Q2Answer+option.getAnswer()+';';
                    }
                }
            }
        }
        System.debug('Q1Answer:'+Q1Answer+' Q2Answer:'+Q2Answer);
        List<Assessment_Questions_Product_Mapping__c> setting=Assessment_Questions_Product_Mapping__c.getAll().values();
        assessMap=CignaUtil.getAvailableProductScope(setting,Q1Answer,Q2Answer);
        System.debug('basicProductCode:'+basicProductCode);
        Set<String> riderSet=assessMap.get(basicProductCode);
        System.debug('riderSet:'+riderSet);
        if(riderSet!=null && assessAllRiderMap!=null && assessAllRiderMap.size()>0){
            if(riderSet.contains(CignaUtil.ALL_RIDER)){
                assessRiderMap=assessAllRiderMap;
            }else{
                for(String rider : riderSet){
                    if(assessAllRiderMap.containsKey(rider)){
                        assessRiderMap.put(rider,assessAllRiderMap.get(rider));
                    }
                }
            }
        }
        if(riderOption != null){
            riderOption.clear();
        }
        if(assessRiderMap!=null && assessRiderMap.size()>0){
            for(String key : assessRiderMap.keySet()){
                riderOption.add(new SelectOption(assessRiderMap.get(key)+riderSperator+key,assessRiderMap.get(key)+riderSperator+key));
            }
        }
    }

    /**
    * setNationalityListInfo
    * @description Rancho_IA_AML_Inspection_20211005: call WS GetMasterList to get the nationality list
    * @return null
    * @author ranzhao@deloitte.com.cn
    **/
    public void setNationalityListInfo(){
        nationalityList=new List<SelectOption>();
        nationalityEnMap=new Map<String,String>();
        nationalityZhMap=new Map<String,String>();
        nationalityList.add(new SelectOption('',Label.Please_Select));
        MasterListCalloutHelper enNationalityCalloutHelper=new MasterListCalloutHelper(15,'en');
        MasterListCalloutHelper zhNationalityCalloutHelper=new MasterListCalloutHelper(15,'zh');
        //Link_IA_AML_Inspection_20211229 start
        List<HttpCalloutVO.MasterList> enNationalityMasterList = (List<HttpCalloutVO.MasterList>)enNationalityCalloutHelper.RequestMasterList();
        List<HttpCalloutVO.MasterList> zhNationalityMasterList = (List<HttpCalloutVO.MasterList>)zhNationalityCalloutHelper.RequestMasterList();
        nationalityEnMap=covertMasterListtoMapwithSort(enNationalityMasterList);
        nationalityZhMap=covertMasterListtoMapwithSort(zhNationalityMasterList);
        //Link_IA_AML_Inspection_20211229 end            
        if('zh_HK'.equalsIgnoreCase(userLanguage)||'zh_CN'.equalsIgnoreCase(userLanguage)||'zh_TW'.equalsIgnoreCase(userLanguage)){
            for(String code : nationalityZhMap.keySet()){
                nationalityList.add(new SelectOption(code,nationalityZhMap.get(code)));
            }
        }else{
            for(String code : nationalityEnMap.keySet()){
                nationalityList.add(new SelectOption(code,nationalityEnMap.get(code)));
            }
        }
        //Link_IA_AML_Inspection_20211229 start:get the code list of isSanction == true
        isSanctionCodeListNa = new List<String>();
        for(HttpCalloutVO.MasterList master : enNationalityMasterList){
            if(master.isSanction){
                isSanctionCodeListNa.add(master.code);
            }
        }
        //Link_IA_AML_Inspection_20211229 end
    }

    /**
    * setCountryListInfo
    * @description Rancho_IA_AML_Inspection_20211005: call WS GetMasterList to get the country list for residence and place of birth
    * @return null
    * @author ranzhao@deloitte.com.cn
    **/
    public void setCountryListInfo(){
        countryList=new List<SelectOption>();
        countryEnMap=new Map<String,String>();
        countryZhMap=new Map<String,String>();
        countryList.add(new SelectOption('',Label.Please_Select));
        MasterListCalloutHelper enCountryCalloutHelper=new MasterListCalloutHelper(14,'en');
        MasterListCalloutHelper zhCountryCalloutHelper=new MasterListCalloutHelper(14,'zh');
        //Link_IA_AML_Inspection_20211229 start
        List<HttpCalloutVO.MasterList> enCountryMasterList = (List<HttpCalloutVO.MasterList>)enCountryCalloutHelper.RequestMasterList();
        List<HttpCalloutVO.MasterList> zhCountryMasterList = (List<HttpCalloutVO.MasterList>)zhCountryCalloutHelper.RequestMasterList();
        countryEnMap=covertMasterListtoMapwithSort(enCountryMasterList);
        countryZhMap=covertMasterListtoMapwithSort(zhCountryMasterList);
        //Link_IA_AML_Inspection_20211229 end         
        if('zh_HK'.equalsIgnoreCase(userLanguage)||'zh_CN'.equalsIgnoreCase(userLanguage)||'zh_TW'.equalsIgnoreCase(userLanguage)){
            for(String code : countryZhMap.keySet()){
                countryList.add(new SelectOption(code,countryZhMap.get(code)));
            }
        }else{
            for(String code : countryEnMap.keySet()){
                countryList.add(new SelectOption(code,countryEnMap.get(code)));
            }
        }
        //Link_IA_AML_Inspection_20211229 start:get the code list of isSanction == true
        isSanctionCodeListCou = new List<String>();
        for(HttpCalloutVO.MasterList master : enCountryMasterList){
            if(master.isSanction){
                isSanctionCodeListCou.add(master.code);
            }
        }
        //Link_IA_AML_Inspection_20211229 end
    }

    /**
    * covertMasterListtoMapwithSort
    * @description Rancho_IA_AML_Inspection_20211005: sort the list returned from WS GetMasterList
    * @param List<HttpCalloutVO.MasterList> masterList: result of WS GetMasterList
    * @return Map<String,String>
    * @author ranzhao@deloitte.com.cn
    **/
    private Map<String,String> covertMasterListtoMapwithSort(List<HttpCalloutVO.MasterList> masterList){
        Map<String,String> masterMap=new Map<String,String>();
        List<HttpCalloutVO.MasterList> otherList=new List<HttpCalloutVO.MasterList>();
        HttpCalloutVO.MasterList chinaMaster=new HttpCalloutVO.MasterList();
        HttpCalloutVO.MasterList hongkongMaster=new HttpCalloutVO.MasterList();
        HttpCalloutVO.MasterList macauMaster=new HttpCalloutVO.MasterList();
        // China, HongKong and Macau should be at the top of the select list
        if(masterList.size()>0){
            for(HttpCalloutVO.MasterList m: masterList){
                if(m.code!=null){
                    if(m.code==CHINA){
                        chinaMaster=m;
                    }else if(m.code==HONGKONG){
                        hongkongMaster=m;
                    }else if(m.code==MACAU){
                        macauMaster=m;
                    }else{
                        otherList.add(m);
                    }
                }
            }
        }
        otherList.sort();
        System.debug('otherList: '+otherList);
        otherList.add(0,chinaMaster);
        otherList.add(1,hongkongMaster);
        otherList.add(2,macauMaster);
        System.debug('otherList: '+otherList);
        for(HttpCalloutVO.MasterList other : otherList){
            // Rancho_IA_AML_Inspection_20211005: avoid error for nationality, as hongkong and macau have been removed
            if(String.isBlank(other.code)){
                continue;
            }
            masterMap.put(other.code,other.name);
        }
        System.debug('masterMap: '+masterMap);
        return masterMap;
    }
}