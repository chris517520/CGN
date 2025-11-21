/********************************************************************************
Apex Class Name - MyClaimSubmitController
Version - 1.0
Created Date - Oct 26, 2016
@description: This program is to submit claim record
WS:
flow:
Step 1 load PI
GetPolicyListBasicByCriteria - Ind and group
GetPolicyPersonListBasic - for group only
Step 2 - add PI ssn to salesforce
GetPolicyPersonCoverageBasic 
GetClinicVisitCount - group
Step 3 - add policy number to salesforce
GetPolicyPaymentBasic 
GetPolicyBasic
GetPersonBasic 
Remarks:
GetPolicyListBasicByCriteria - all policy under that user - individual with PI / group 
GetPolicyBasic - get policy currency
GetPersonBasic - get email address / gender / sensitivity code / birth date / mobile phone no /  pAccIdInfoMap contains information
GetPolicyPersonCoverageBasic - get product code / benefit amt / benefit code / rate scale 
GetPolicyPersonListBasic - get list of group PI
SubmitClaimRequest - submit claim form in pdf -> base64
======================================================
pAccIdInfoMap   -getIndividualPolicyListBasicByCriteria / getPersonBasic(ssn)
key:    ssn
value:  Map< String, String>
getIndividualPolicyListBasicByCriteria  - PI
('fullName', fullName); 
('ssnNumber', ssnNumber); 
getPersonBasic - LoadPIToGetPlanType (PI) / AddPolicyIntoClaim(PH)
('ssnNum', wPersonItem.ssnNum);     //should duplicate - ssnNumber
('memberName', wPersonItem.memberName);     //should duplicate - fullName
('emailAddr', wPersonItem.emailAddr); 
('senMapList', String.valueOf(wPersonItem.senMapList)); 
('certNum', wPersonItem.certNum ); 
('certEffectiveDate', wPersonItem.certEffectiveDate ); 
('memberStatusDescription', wPersonItem.memberStatusDescription ); 
('gender', wPersonItem.gender ); 
('birthDate', wPersonItem.birthDate ); 
('mobilePhoneNo', wPersonItem.mobilePhoneNo );     // all mobile phone info in list
('mobileCountryCode', wPersonItem.mobileCountryCode ); 
('mobileAreaCode', wPersonItem.mobileAreaCode ); 
('mobileTelephoneNo', wPersonItem.mobileTelephoneNo ); 
======================================================
pNumSsnValueListMap  - GetPolicyPersonCoverageBasic (policyNumber, PIssn)
Key: Map <String,String> policyNumber, PIssn
Value: List<Map <String,String>>      //as each pi may have more than 1 coverage
getPolicyPersonCoverageBasic - LoadPIToGetPlanType
( 'productCode', policyPersonCoverageItem.productCode );
( 'benefitAmount', policyPersonCoverageItem.benefitAmount );    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
( 'benefitCode', policyPersonCoverageItem.benefitCode );
( 'rateScale', policyPersonCoverageItem.rateScale );
======================================================
Modification Log : 
--------------------------------------------------------------------------------
*Version    Developer             Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       Wincy             26/10/2016               New created
********************************************************************************/
public without sharing class MyClaimSubmitController{
    // 20211216 - minghua - JOBR-67, Performance Tuning - Claim submission, back up GetPolicyPersonListBasicByCriteria result
    public List<HttpCalloutVO.Person> basePPBBList{get;set;}
    // 20210803 - minghua - CR48
    public Boolean allowGovernmentHospitalVisit{get;set;} // Rancho_CR48_20210706
    public Boolean isEntitledBenefit{get;set;}
    public Boolean isEconomistPolicy{get;set;}
    public Boolean onlySelectedOP{get;set;}
    public Integer hKCode{get;set;}
    public List<ClaimSD> claimSDList {get;set;}
    public Map<String,List<ClaimSD>> claimSDBenefit {get;set;}
    public Map<String,Boolean> claimDesignated {get;set;}

    public Map<String,List<HttpCalloutVO.Person>> personBasicList{get;set;} //20200817 - minghua - Performance issue in claim flow Step 2
    public Boolean isLoadPIFromWS{get;set;}
    public Boolean isHideWSForTesting{get;set;}
    public Boolean isLoadOldClaim{get;set;}
    public Boolean isLoadSearchComp{get;set;}    // broker only -- if load search component
    public Boolean isPassQuestionPart{get;set;}
    //system judgment for question logic
    public Boolean sj_HIF_d{get;set;}
    public Boolean sj_OP_a{get;set;}    
    public Boolean sj_OP_d{get;set;}    
    public Boolean isContainPI{get;set;}
    
    /** flag **/
    public Boolean needDownloadPDF{get;set;}    /** flag for allow display download pdf link **/
    public Boolean hasNoPolicyPI{get;set;} //check if wPolicyList_PI.size()>0
    /** select bank account **/
    public Boolean isBrkCustomerHasDDA{get;set;}    /** true if bank account info is available from WS or SF **/
    public Boolean isCustomer{get;set;}    /** true of current user is using customer profile  **/
    //SPS-421_chris_2020_05_20
    public String brokerEmailAddress{get;set;} //send e-sign to broker by this email address
    
    //check if limit excess for WS
    public Boolean isExcessMaxLimit{get;set;}    //error msg will pop up if excess limit
    //public Integer max_record_allowed{get;set;}    //flag to show error msg will pop up if excess limit    
    public String errorMsgExcessMaxLimit{get;set;}    //msg to display error Msg Excess Max Limit   
    public Integer noOfFormNeedToDownload{get;set;}   
    public Decimal totalSumInsured{get;set;}    //for calculation for total Sum Insured at question logic * number of days
    public Date EarliestPaidToDate{get;set;}   
    public String picLink{get;set;} 
    public Boolean localIsFastTrack{get;set;} // Zoe update 0329
    public Boolean localIsPIForTC{get;set;} // Zoe update 0329
    
    public String loginId{get;set;}    /** login Id e.g. email address **/
    public String userSsn{get;set;}    /** login Id e.g. email address **/    
    public Integer steps{get;set;}    /** user current steps **/    
    public String idx_bankAccountInfoHK{get;set;}
    public String idx_bankAccountInfoOversea{get;set;}    
    public String idx_visitDate{get;set;}   
    public String currentSelectedQuestionId{get;set;}
    public String removeSelectedQuestionId{get;set;}    
    public String removeAttId{get;set;}    /** attachment id to delete **/   
    public String cId{get;set;}    /** Id of claim - new or old claim record **/
    public String phid{get;set;} 
    public String phname{get;set;}  
    public String bankName{get;set;}    /** String - for hard code only **/
    /** E-Signature **/
    public String paramDMConsent{get;set;}
    public String picString{get;set;}
    public String eSignature{get;set;}
    public String esignatureEmail{get;set;}
    public String userLanguage{get;set;}
    /** end E-Signature **/
    
    public String previousSelectedSsn{get;set;}   
    public String benefitTypeStr{get;set;}    /** string of select benefit type get from VF page **/
    public String allowTypeOfDoctorToClaimStr{get;set;}    /** string of select benefit type get from VF page **/
    public Boolean onlyOneBenefitType{get;set;}
    private Boolean skipOneBenefitForTesting{get;set;} /** for testing purpose */   
    public String errorMsg{get;set;}    /** error message for database **/    
    /* Datepicker variables */
    public Long firstConsultationDateTimestamp{get;set;}    //claimRequest.Admission_Date__c = DateTime.newInstance(admissionDateTimestamp).date();
    public Long dateToStopWorkDateTimestamp{get;set;}    //claimRequest.Admission_Date__c = DateTime.newInstance(admissionDateTimestamp).date();
    
    public List<User> uList{get;set;}    /** current user list **/
    public List<Policy__c> pList{get;set;}    /** list of policy record get from SF - replace by WS later **/
    public List<Claim_Type_Document__c> claimTypeDocumentList{get;set;}    /** list of claim type document **/
    public List<Plan_Code_Claim_Type__c> planCodeClaimTypeList{get;set;}    /** list of plan code claim type **/
    public List<String> selectBenefitTypeList{get;set;}    /** list of string save select benefit type e.g. HI / CI **/
    public List<Claim__c> cList{get;set;}    /** list of claim - size must one for claim record currently use **/
    public List<ClaimHelper.WrapperPolicy> wPolicyList_unchanged{get;set;}    /** broker use use search policy under that broker from WS **/
    public List<ClaimHelper.WrapperPolicy> wPolicyList_PI{get;set;}    /** customer and broker find policies which search by PH from WS **/
    public List<Attachment> attList{get;set;}    /** attachment list for attachment from claim type document **/
    public List<ClaimHelper.WrapperClaimTypeRelatedDocument> wClaimTypeRelatedDocList{get;set;}    /** list of wrapper class of claim type document **/
    public List<ClaimHelper.WrapperClaimUploadAttachment> claimUploadAttList{get;set;}    /** attachment upload doc list **/
    
    /** temp save data **/
    public List<ClaimHelper.WrapperVisit> wVisitDateStrList{get;set;}    //for single date list field
    public List<ClaimHelper.WrapperInfoFromOtherCompany> wInfoFromOtherCompanyList{get;set;}
    public List<ClaimHelper.WrapperInfoFromOtherCompany> wInfoInsuredFromOtherCompanyList{get;set;} //20251008 - HKITSFDC-412
    public List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital> wAdmittedAndDischargedFromHospitalList{get;set;}
    /** end temp save data **/   
    /* WS or Salesforce */   
    public List<Map<String,String>> bankAccInfoList{get;set;}    /** bank account list **/   
    public List<ClaimHelper.WrapperPerson> wPersonList{get;set;}    //GetPersonBasic  
    public List<ClaimHelper.WrapperClinicVisitCount> wClinicVisitCountList{get;set;}    //GetClinicVisitCount
    public List<ClaimHelper.WrapperPolicyPaymentBasic> wPolicyPaymentBasicList{get;set;}    //GetPolicyPaymentBasic   
    /* WS or Salesforce end*/
    
    public List<HttpCalloutVO.Policy> policyIndividualList{get;set;}
    public List<HttpCalloutVO.Policy> policyGroupList{get;set;}    
    public Map<String,Map<String,String>> pAccIdInfoMap{get;set;}    /** Mapping to save policy Account Relationship info at too many level **/
    public Map<Id,List<Attachment>> claimTypeDocIdAttachmentMap{get;set;}    /** Mapping to save related attachment document for claim type document record **/
    public Map<String,Map<String,String>> allSsnNamePIMap{get;set;}
    public Integer PICount{get;set;}    
    public Map<Map<String,String>,List<Map<String,String>>> pNumSsnValueListMap{get;set;}    //GetPolicyPersonCoverageBasic 
    public Map<Map<String,String>,Map<String,String>> policyNumSsnGetCertNumMap{get;set;}    //policyNum: ssn -> policyNum / ssn / certNum   for clinic visit count
    
    /** get value from ClaimHelper **/
    public static String groupPolicyRelationship = ClaimHelper.GROUP_POLICY_RELATIONSHIP ;
    public static String individualPolicyRelationship = ClaimHelper.INDIVIDUAL_POLICY_RELATIONSHIP;
    public static String policyInsuredPersion = ClaimHelper.RELATIONSHIP_POLICY_INSURED_PERSON;
    public static String policyHolder = ClaimHelper.RELATIONSHIP_POLICY_HOLDER;
    /** end get value from ClaimHelper **/
    //performance turning
    public List<ClaimHelper.WrapperPolicy> wPolicyList_selected{get;set;}    /** selected policy list**/
    public String selectedPolicy{get;set;}
    public Set<String> selectedPolicyList{get;set;}
    public String selectedPolicyClaimTypeStr{get;set;}
    public String selectedPolicyBenefitTypeStr{get;set;}
    
    //20190624 - David Zhang - Align Claim Payment flow with CP
    public String brkSelectedAccountNo{get;set;}
    public String failFileName{get;set;}//PI20 jack add
    //20191024 - Raistlin - GS claim
    public List<SelectOption> bankNameList{get;set;}
    public List<SelectOption> bankCountryList{get;set;}
    public List<SelectOption> incurredCountryList{get;set;}
    public List<SelectOption> currencyList{get;set;} 
         
    //Nicole_20200220_GS Claim
    private MemberManagementHelper gsMemberHelper = new MemberManagementHelper();
    public Boolean includeGSClaim{get;set;}
    public ESalesMember employeeMember{get;set;}
    public HttpCalloutVO.BankAccount bankAccInfoForGS{get;set;}
    public String bankAccInfoForGSJSon{get;set;}
    public Boolean isMultiplePolicy{get;set;}
    public List<Bank_Account__c> bankAccountList{get;set;}
    public List<SelectOption> policyOptions{get;set;}
    public Boolean isLoginUserEmployee{get;set;}
    public String belongCha{get{return '\'s';} set;}
    public Boolean isSME{get;set;}//Rancho_ReviseDescription_20210319 in MyCigna for Infectious Disease Hospital Cash
    public String claimFlowTerms{get;set;}//Rancho_JOBR133_20220530 - generate T&C according to selected policy
    public Boolean isCovid19{get;set;}//Rancho_Covid19_20221019 - display a text in upload document step if equals true
    //Rancho_HKITSFDC83_20240829 - not allow submit claim for pending policy
    public Map<String, String> psmMap{
        get{
            if(null == psmMap){
                psmMap = new Map<String, String>();
                for(Policy_Status_Mapping__c psm : Policy_Status_Mapping__c.getAll().values()){
                    psmMap.put(psm.PolicyCode__c, psm.PolicyStatus__c);
                }
            }
            return psmMap;
        }
        set;
    }
    /*translate fields*/
    public Map<String,Map<String,String>> transField{
        get{
            if(transField == null){
            transField = new Map<String,Map<String,String>>();
                for(Translate__mdt t : [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c = 'uploadFile' or Category__c = 'GS claim' or Category__c = 'newClaimFlow']){
                    // system.debug(t.DeveloperName);
                    transField.put(t.DeveloperName, new Map<String,String>{'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c });
                    
                }
            }
            return transField ;
        }
        set;
    }

    public String transKey{
        get{
            if(transKey == null){
                transKey ='';
                for(String s : transField.keySet()){
                    transKey += '~' + s + '~';
                }
            }
            return transKey ;
        }set;
    }
    // minghua - 20220523 - file virus scan
    public Boolean scanPopup{get;set;}{scanPopup=false;}
    public Boolean isInsuredForSimilarBenefitsFlag{get;set;} 

    public MyClaimSubmitController(){
        isInsuredForSimilarBenefitsFlag = false;
        // 20210803 - minghua - CR48
        allowGovernmentHospitalVisit=false; // Rancho_CR48_20210706
        isEntitledBenefit=false;
        isEconomistPolicy=false;
        onlySelectedOP=false;
        hKCode=Integer.valueOf(Claim_Setting__c.getInstance('Cigna').Claim_HKCode__c);
        claimSDList=new List<ClaimSD>();
        claimSDBenefit=new Map<String,List<ClaimSD>>();
        claimDesignated=new Map<String,Boolean>();
        loadClaimSymptomsAndDiagnosis();

        personBasicList = new Map<String,List<HttpCalloutVO.Person>>(); //20200817 - minghua - Performance issue in claim flow Step 2
        isLoadPIFromWS = false;
        isLoadOldClaim = false;
        isLoadSearchComp = false;
        isPassQuestionPart = false;
        isContainPI = false;    //to see if PI exist
        isHideWSForTesting = false;    //true: hide WS, false: normal flow
        skipOneBenefitForTesting = true;
        hasNoPolicyPI = false; //check if wPolicyList_PI.size()>0
        localIsFastTrack = false;
        localIsPIForTC = false;
        claimFlowTerms = ''; //Rancho_JOBR133_20220530
        isCovid19 = false; //Rancho_Covid19_20221019 - init
        
        // system.debug('to see MyClaimSubmitController init start');
        sj_HIF_d = false;            
        sj_OP_a = false;
        sj_OP_d = false;               
        isBrkCustomerHasDDA = false;
        needDownloadPDF = false;
        isCustomer = false;        
        noOfFormNeedToDownload = 0;        
        totalSumInsured = 0;
        
        //check if record excess limit
        isExcessMaxLimit = false;
        //max_record_allowed = ClaimHelper.MAX_COUNT_RECORD;
        errorMsgExcessMaxLimit = '';
        currentSelectedQuestionId= '';
        removeSelectedQuestionId ='';
        steps = 0;
        
        claimUploadAttList = new List<ClaimHelper.WrapperClaimUploadAttachment>{};
        selectBenefitTypeList = new List<String>{};       
        claimTypeDocumentList = new List<Claim_Type_Document__c>{};
        attList = new List<Attachment>{};
        wClaimTypeRelatedDocList = new List<ClaimHelper.WrapperClaimTypeRelatedDocument>{};
        pList = new List<Policy__c>{};       
        wPolicyList_unchanged = new List<ClaimHelper.WrapperPolicy>{};
        wPolicyList_PI = new List<ClaimHelper.WrapperPolicy>{};
        cList = new List<Claim__c>{};
        bankAccInfoList = new List<Map<String,String>>{};
        
        /** tmp data for question answer **/
        wVisitDateStrList = new List<ClaimHelper.WrapperVisit>{};    //for mulitiple consultation date in list
        wInfoFromOtherCompanyList = new List<ClaimHelper.WrapperInfoFromOtherCompany>{};
        wInfoInsuredFromOtherCompanyList = new List<ClaimHelper.WrapperInfoFromOtherCompany>{}; //20251008 - HKITSFDC-412
        wAdmittedAndDischargedFromHospitalList = new List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>{};        
        ClaimHelper.WrapperVisit wVisitItem = new ClaimHelper.WrapperVisit();
        wVisitDateStrList.add(wVisitItem);
        ClaimHelper.WrapperInfoFromOtherCompany wInfoFromOtherCompanyItem = new ClaimHelper.WrapperInfoFromOtherCompany();
        ClaimHelper.WrapperInfoFromOtherCompany wInfoInsuredFromOtherCompanyItem = new ClaimHelper.WrapperInfoFromOtherCompany(); //20251008 - HKITSFDC-412
        wInfoFromOtherCompanyList.add(wInfoFromOtherCompanyItem);    //add 1 new item
        wInfoInsuredFromOtherCompanyList.add(wInfoInsuredFromOtherCompanyItem);    //add 1 new item        
        ClaimHelper.WrapperAdmittedAndDischargedFromHospital wAdmittedAndDischargedFromHospitalItem = new ClaimHelper.WrapperAdmittedAndDischargedFromHospital();
        wAdmittedAndDischargedFromHospitalList.add(wAdmittedAndDischargedFromHospitalItem);    //add 1 new item
        /** end tmp data **/
        
        pAccIdInfoMap = new Map<String,Map<String,String>>{};
        claimTypeDocIdAttachmentMap = new Map<Id,List<Attachment>>{};
        allSsnNamePIMap = new Map<String,Map<String,String>>{};        
        pNumSsnValueListMap = new Map<Map<String,String>,List<Map<String,String>>>{};    //GetPolicyPersonCoverageBasic 
        policyNumSsnGetCertNumMap = new Map<Map<String,String>,Map<String,String>>{};    //get cert number from GetPolicyPersonCoverageBasic use for getclinicvisitcount
        /** WS **/
        wPersonList = new List<ClaimHelper.WrapperPerson>{};    //GetPersonBasic  
        wClinicVisitCountList = new List<ClaimHelper.WrapperClinicVisitCount>{};    //GetClinicVisitCount
        wPolicyPaymentBasicList = new List<ClaimHelper.WrapperPolicyPaymentBasic>{};    //GetPolicyPaymentBasic           
        //performance turning
        wPolicyList_selected = new List<ClaimHelper.WrapperPolicy>{};        
        /** get cId mean continue claim step **/
        cId = Apexpages.currentPage().getParameters().get('cId');        
        /** get param from comp **/
        phid = Apexpages.currentPage().getParameters().get('phid');
        phname = Apexpages.currentPage().getParameters().get('phname');
        //20190624 - David Zhang - Align Claim Payment flow with CP
        brkSelectedAccountNo = '';
            
        //get current user info
        uList = [select Id, UserName, name, ContactId, LanguageLocaleKey, AccountId, Account.SSN__c, Profile.Name ,Notification_Channel__c,Notification_Email_Address__c from User where Id = :UserInfo.getUserId() limit 1];                                                                                                                        
        // system.debug('to see uList: '+uList);        
        for(User u: uList){
            this.userLanguage = u.LanguageLocaleKey;            
            if(u.UserName != null){loginId = u.UserName;}//email address
            if(u.Account.SSN__c != null){userSsn= u.Account.SSN__c;}//user ssn            
            //check if user are using customer profile
            if(u.Profile.Name.contains('Customer') || u.Profile.Name.contains('System Administrator')){isCustomer = true;}
        }        
        //SPS-421_chris_2020_05_20
        if(!isCustomer){
            brokerEmailAddress = uList[0].Notification_Channel__c == 'SMS' ? UserInfo.getUserEmail() : uList[0].Notification_Email_Address__c;
        }
        //prevent create new claim record / override other record
        if(!String.isBlank(cId) && cList.size()>0){
            // system.debug('******prevent create new claim record / override other record ');
            //force create new claim record if passing param is different from current record
            if(!(cId.substring(15).equals(String.valueOf(cList[0].id).substring(15)) && !cId.contains('#') && (cId.length() == 15 || cId.length() != 18))){
                // system.debug('****** force create new claim record if passing param is different from current record');
                cList.clear();
                cId = '';
            }
        }        
        
        if(!String.isBlank(cId) && (cId.length() == 15 || cId.length() == 18)){
            // system.debug('to see load old claim record');
            //claim record created before, get record from salesforce
            loadClaimRecordByPassingId(cId);            
            if(cList.size()==1 && Integer.valueOf(cList[0].steps__c)>1){
                steps = Integer.valueOf(cList[0].steps__c);
                isLoadOldClaim = true;
                // 20210803 - minghua - CR48 
                loadClaimSymptoms(cList[0].What_would_you_like_to_claim_for__c);         
            }else{steps = 1;}
            
            /* get PI record from component works */
            //String phid= Apexpages.currentPage().getParameters().get('phid');
            //String phname = Apexpages.currentPage().getParameters().get('phname');
            if(!String.isBlank(phid) || !String.isBlank(phname)){
                // // system.debug('to see cList when pass param from component: '+cList);
                if(cList.size()>0){
                    cList[0].Person_s_Insured__c = phid;
                    cList[0].Person_Insured_Name__c = phname ;
                    steps = 2;
                }
            }            
            if(steps == 1){isLoadSearchComp = true;}            
            /* end get PI record from component works */
        }else{
            //new claim record
            /* broker - get PI record from component works */
            Claim__c cItem = new Claim__c();
            cList.add(cItem);                        
            //String phid= Apexpages.currentPage().getParameters().get('phid');
            //String phname = Apexpages.currentPage().getParameters().get('phname');
            if(!String.isBlank(phid) || !String.isBlank(phname)){
                /** new claim record when init **/
                if(cList.size()>0){
                    cList[0].Person_s_Insured__c = phid;
                    cList[0].Person_Insured_Name__c = phname ;
                    // // system.debug('to see cList when pass param from component: '+cList);
                }
                steps = 2;
            }else{
                // all param null, new claim at step 1
                isLoadSearchComp = true;
            }
        }
        
        for(User u: uList){
            if(u.LanguageLocaleKey == 'zh_TW' || u.LanguageLocaleKey == 'zh_HK' && cList.size()>0){cList[0].Is_Using_Chinese_Version__c = true;}
            else if(cList.size()>0){cList[0].Is_Using_Chinese_Version__c = false;}
        }
                
        /** e-signature T&C **/
        //String picsDocName = '';
        // Portal_Settings__c portalDocumentURL = Portal_Settings__c.getInstance();
        // String portal;
        if(isCustomer){
            //JOBR-334,2023-09-18 add by Owen, for update PICS.
            if(this.userLanguage == 'zh_TW'){
                picLink = CignaUtil.getPersonalInformationCollectionStatement_chi();
            }else{
                picLink = CignaUtil.getPersonalInformationCollectionStatement_eng();
            }
            //JOBR-184: JOBR-232 addde by Kermit
            // portal = portalDocumentURL.Customer_Portal_Url__c;
            // if(cList[0].Is_Contain_Life_Policy__c && !cList[0].Is_Contain_GI_Policy__c){
            //     picsDocName = Label.Life_PIC_Doc_Customer;
            // }else if(!cList[0].Is_Contain_Life_Policy__c && cList[0].Is_Contain_GI_Policy__c){
            //     picsDocName = Label.GI_PIC_Doc_Customer;
            // }else{
            //     picsDocName = Label.Both_Life_And_GI_PIC_Doc_Customer;
            // }
            //JOBR-184: JOBR-232 addde by Kermit
        }else{
            if(this.userLanguage == 'zh_TW'){
                //picLink = portalDocumentURL.File_Download_URL__c + CignaUtil.getBrokerPersonalInformationCollectionStatement_chi();
                picLink = CignaUtil.getPersonalInformationCollectionStatement_chi();                
            }else{
                //picLink = portalDocumentURL.File_Download_URL__c + CignaUtil.getBrokerPersonalInformationCollectionStatement_eng();
                picLink = CignaUtil.getPersonalInformationCollectionStatement_eng();
            } 
            //JOBR-184: JOBR-232 addde by Kermit
            // portal = portalDocumentURL.Broker_Portal_Url__c;
            // if(cList[0].Is_Contain_Life_Policy__c && !cList[0].Is_Contain_GI_Policy__c){
            //     picsDocName = Label.Life_PIC_Doc_Broker;
            // }else if(!cList[0].Is_Contain_Life_Policy__c && cList[0].Is_Contain_GI_Policy__c){
            //     picsDocName = Label.GI_PIC_Doc_Broker;
            // }else{
            //     picsDocName = Label.Both_Life_And_GI_PIC_Doc_Broker;
            // }
            //JOBR-184: JOBR-232 addde by Kermit
        }
        // List<Document> picsDoc = [SELECT Id FROM Document WHERE DeveloperName = :picsDocName LIMIT 1];
        // if(picsDoc.size() == 1){
        //     picLink = portal + '/servlet/servlet.FileDownload?file='+picsDoc.get(0).Id;
        //     system.debug('[MyClaimSubmitController] picLink='+picLink);
        // }
        
        picString = '';
        String docName;
        if(this.userLanguage == 'zh_TW' || this.userLanguage == 'zh_HK'){docName = 'PIC_Statement_Text_Chinese';}
        else{docName = 'PIC_Statement_Text';}
        List<Document> dList = [SELECT Id, body FROM Document WHERE DeveloperName =:docName LIMIT 1];
        if(dList.size() == 1){picString = dList[0].body.toString();}
        /** end e-signature T&C **/
        
        // // system.debug('to see 1');
        /**
        if(steps == null || steps <1){
            // system.debug('to see 2');
            loadData(1);
        }else{
            //old claim record
            // system.debug('to see 3');
            initData();
        }
        **/       
        //Nicole_20200220_GS Claim
        includeGSClaim = false;
        isLoginUserEmployee = false;
    }
    
    public void loadDataFromWS(){        
        if(steps == null || steps <1){
            // // system.debug('to see 2,steps='+steps);
            loadData(1);
        }else{
            //old claim record
            // // system.debug('to see 3,steps='+steps);
            initData();
        }   
    }    
    
    public PageReference selectTransferHKBank(){
        // // system.debug('to see selectTransferHKBank start');
        if(cList.size()>0){
            cList[0].Is_Selected_Transfer_to_Oversea_Bank__c = false; 
            cList[0].Is_Selected_Transfer_to_HK_Bank__c = true;
        }
        return null;
    }
    
    public PageReference selectTransferOverseaBank(){
        // // system.debug('to see selectTransferOverseaBank start');
        if(cList.size()>0){
            cList[0].Is_Selected_Transfer_to_Oversea_Bank__c = true; 
            cList[0].Is_Selected_Transfer_to_HK_Bank__c = false;
        }
        return null;
    }
    
    public PageReference SelectBrokerPAC(){
        // // system.debug('to see SelectBrokerPAC start');
        if(cList.size()>0){
            cList[0].is_Selected_Broker_PAC_plan__c = true; 
        }
        return null;
    }
    
    public PageReference ResetBrokerPAC(){
        // // system.debug('to see ResetBrokerPAC start');
        if(cList.size()>0){
            cList[0].is_Selected_Broker_PAC_plan__c = false; 
        }
        return null;
    }
    
    public PageReference SelectHSBrokerPAC(){
        // // system.debug('to see SelectHSBrokerPAC start');
        if(cList.size()>0){
            cList[0].HS_Less_Than_3_Yrs_or_Broker_PAC__c= true; 
        }
        return null;
    }
    
    public PageReference ResetHSBrokerPAC(){
        // // system.debug('to see ResetHSBrokerPAC start');
        if(cList.size()>0){
            cList[0].HS_Less_Than_3_Yrs_or_Broker_PAC__c= false; 
        }
        return null;
    }
    public PageReference SelectHPABrokerPAC(){
        // // system.debug('to see SelectHPABrokerPAC start');
        if(cList.size()>0){
            cList[0].HPA_Less_Than_2_Yrs__c= true; 
        }
        return null;
    }    
    public PageReference ResetHPABrokerPAC(){
        // // system.debug('to see ResetHPABrokerPAC start');
        if(cList.size()>0){
            cList[0].HPA_Less_Than_2_Yrs__c= false; 
        }
        return null;
    }    
    public PageReference removeSelectedQuestion(){
        /** useless **/
        // // system.debug('to see removeSelectedQuestion start');
        return null;
    }        
    public PageReference saveSelectedQuestion(){
        // Deserialize the list of invoices from the JSON string.
        // // system.debug('to see currentSelectedQuestionId: '+currentSelectedQuestionId);
        if(!String.isBlank(currentSelectedQuestionId) && cList.size()>0){
            //steps = 7;
            //cList[0].steps__c = 7;
            // // system.debug('to see currentSelectedQuestionId: '+currentSelectedQuestionId);
            cList[0].Selected_Question_s__c = currentSelectedQuestionId;
        }
        SaveRecord();  
        return null;
    }
    
    public PageReference saveSelectedQuestionBrk(){
        // // system.debug('to see currentSelectedQuestionId: '+currentSelectedQuestionId);
        if(!String.isBlank(currentSelectedQuestionId) && cList.size()>0){
            String result = cList[0].Selected_Question_s__c;
            for(Integer i = 1; i<= 3; i++){
                result = result.remove('"c' + String.ValueOf(i) + '"');
            }
            result = result.remove('"nextIn7"');
            cList[0].Selected_Question_s__c = result + currentSelectedQuestionId;
        }
        SaveRecord();  
        return null;
    }
    
    public PageReference saveSelectedExtraQuestionBrk(){
        system.debug('to see currentSelectedQuestionId: '+currentSelectedQuestionId);
        if(!String.isBlank(currentSelectedQuestionId) && cList.size()>0){
            String result = cList[0].Selected_Question_s__c;
            for(Integer i = 1; i<= 5; i++){
                result = result.remove('"cx' + String.ValueOf(i) + '"');
            }
            cList[0].Selected_Question_s__c = result + currentSelectedQuestionId;
        }
        SaveRecord();  
        return null;
    }
    
    public void clearwAdmittedAndDischargedFromHospitalList(){
        // // system.debug('to see pass clearwAdmittedAndDischargedFromHospitalList');
        cList[0].Admitted_and_discharged_from_hospital__c = '';
        wAdmittedAndDischargedFromHospitalList.clear();        
        List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital> tmpWrapperList = new List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>{};
        ClaimHelper.WrapperAdmittedAndDischargedFromHospital wAdmittedAndDischargedFromHospitalItem = new ClaimHelper.WrapperAdmittedAndDischargedFromHospital();
        tmpWrapperList.add(wAdmittedAndDischargedFromHospitalItem); 
        wAdmittedAndDischargedFromHospitalList = tmpWrapperList;
        
        cList[0].Admitted_and_discharged_from_hospital__c = JSON.Serialize(wAdmittedAndDischargedFromHospitalList);            
        if(cList[0].id != null){
            // // system.debug('to see cList[0] Admitted_and_discharged_from_hospital__c  before update: '+cList[0].Admitted_and_discharged_from_hospital__c);
            //170306
            update cList;
            // // system.debug('to see wAdmittedAndDischargedFromHospitalList: '+wAdmittedAndDischargedFromHospitalList);
        }        
    }
    
    public PageReference calculationForAddmissionAndDischargedDate(){
        sj_HIF_d = false; //init
        // // system.debug('to see calculationForAddmissionAndDischargedDate start');
        // // system.debug('to see wAdmittedAndDischargedFromHospitalList: '+wAdmittedAndDischargedFromHospitalList);
        if(cList.size()>0){
            Integer actualDaysToInsured = 0;
            Decimal actualAmtToInsured = 0;
            Boolean tmpDischargeDateEarilerOrEqualToPaidToDateFlag = false;        
            Boolean isPassToQueryPreviousRecord = false;
            Boolean isViolateDateRule = false;
            for(ClaimHelper.WrapperAdmittedAndDischargedFromHospital tmpDatesItem:wAdmittedAndDischargedFromHospitalList){
                // // system.debug('to see admissionDateTimestamp : '+tmpDatesItem.admissionDateTimestamp);
                // // system.debug('to see dischargeDateTimestamp : '+tmpDatesItem.dischargeDateTimestamp);
                if(tmpDatesItem.admissionDateTimestamp != null && tmpDatesItem.admissionDateTimestamp != 0){tmpDatesItem.admissionDate = DateTime.newInstance(tmpDatesItem.admissionDateTimestamp).date();}
                if(tmpDatesItem.dischargeDateTimestamp != null && tmpDatesItem.dischargeDateTimestamp != 0){tmpDatesItem.dischargeDate = DateTime.newInstance(tmpDatesItem.dischargeDateTimestamp).date();}
                
                Date tmpAdmissionDate = tmpDatesItem.admissionDate; 
                Date tmpDischargeDate = tmpDatesItem.dischargeDate;
                // // system.debug('to see tmpAdmissionDate: '+tmpAdmissionDate);
                // // system.debug('to see tmpDischargeDate : '+tmpDischargeDate);
                Integer dayDiff = -1;
                if(tmpAdmissionDate != null && tmpDischargeDate !=null){dayDiff = tmpAdmissionDate.daysBetween(tmpDischargeDate);}
                // // system.debug('to see dayDiff: '+dayDiff);
                if(dayDiff>= 0){
                    dayDiff+=1;    //start-end +1 day
                    actualDaysToInsured += dayDiff;                     
                }else{
                    // // system.debug('to see isViolateDateRule: '+isViolateDateRule);
                    isViolateDateRule = true;
                }
                // // system.debug('to see EarliestPaidToDate: '+EarliestPaidToDate);
                if(EarliestPaidToDate != null && tmpDischargeDate != null){
                    Integer dayDiff_paidToDate = tmpDischargeDate.daysBetween(EarliestPaidToDate);
                    // // system.debug('to see dayDiff_paidToDate: '+dayDiff_paidToDate);
                    if(dayDiff_paidToDate>= 0){
                        tmpDischargeDateEarilerOrEqualToPaidToDateFlag = true;
                    }
                }                                
            }
            
            // // system.debug('to see tmpDischargeDateEarilerOrEqualToPaidToDateFlag: '+tmpDischargeDateEarilerOrEqualToPaidToDateFlag);
            actualAmtToInsured = totalSumInsured * actualDaysToInsured;             
            // // system.debug('to see actualAmtToInsured: '+actualAmtToInsured);
            cList[0].Amount_Of_Sum_Insured__c = actualAmtToInsured;            
            // // system.debug('to see cList[0].Is_All_Selected_Policy_EffDate_6_month__c : '+cList[0].Is_All_Selected_Policy_EffDate_6_month__c);
            // // system.debug('to see actualAmtToInsured : '+actualAmtToInsured);
            // // system.debug('to see tmpDischargeDateEarilerOrEqualToPaidToDateFlag : '+tmpDischargeDateEarilerOrEqualToPaidToDateFlag);
            // // system.debug('to see actualDaysToInsured: '+actualDaysToInsured);
            if(!isViolateDateRule  && !cList[0].Is_All_Selected_Policy_EffDate_6_month__c && actualAmtToInsured <= 2000 && tmpDischargeDateEarilerOrEqualToPaidToDateFlag && ((actualDaysToInsured+1)<=5)){                
                isPassToQueryPreviousRecord =true;
            }
            // // system.debug('to see isPassToQueryPreviousRecord: '+isPassToQueryPreviousRecord);
            if(isPassToQueryPreviousRecord){
                Boolean isExistInPreviousRecordBeforeInFastTrack = false;
                //query claim record with history fast track claim record same admission and discharge date
                String soql_historyWithSamePI = ClaimHelper.CLAIM_ALL_FIELD;
                soql_historyWithSamePI += ' where Person_s_Insured__c=\''+cList[0].Person_s_Insured__c+'\' and id !=\''+cList[0].id+'\'  and Submission_Date__c != null and HIF__c = true and Is_Fast_Track__c = true ';
                // system.debug('to see soql_historyWithSamePI: '+soql_historyWithSamePI);
                List<Claim__c> cList_historyWithSamePI = Database.query(soql_historyWithSamePI);
                // system.debug('to see cList_historyWithSamePI: '+cList_historyWithSamePI);
                // system.debug('to see cList_historyWithSamePI.size: '+cList_historyWithSamePI.size());
                for(Claim__c cItem: cList_historyWithSamePI){                    
                    List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital> wTmpDateList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c,List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
                    for(ClaimHelper.WrapperAdmittedAndDischargedFromHospital wItem: wTmpDateList){                    
                        Date tmpAdmissionDate_history = wItem.admissionDate; 
                        Date tmpDischargeDate_history = wItem.dischargeDate;
                        // system.debug('to see tmpAdmissionDate_history: '+tmpAdmissionDate_history);
                        // system.debug('to see tmpDischargeDate_history: '+tmpDischargeDate_history);
                        //loop current claim admission date and discharge date to do comparsion
                        for(ClaimHelper.WrapperAdmittedAndDischargedFromHospital tmpDatesItem: wAdmittedAndDischargedFromHospitalList){
                            if(tmpDatesItem.admissionDateTimestamp!=null && tmpDatesItem.admissionDateTimestamp!=0){tmpDatesItem.admissionDate = DateTime.newInstance(tmpDatesItem.admissionDateTimestamp).date();}
                            if(tmpDatesItem.dischargeDateTimestamp!=null && tmpDatesItem.dischargeDateTimestamp!=0){tmpDatesItem.dischargeDate = DateTime.newInstance(tmpDatesItem.dischargeDateTimestamp).date();}
                            
                            Date tmpAdmissionDate = null;
                            if(tmpDatesItem.admissionDate!=null){tmpAdmissionDate = tmpDatesItem.admissionDate;}
                            Date tmpDischargeDate = null;
                            if(tmpDatesItem.dischargeDate!=null){tmpDischargeDate = tmpDatesItem.dischargeDate;}
                            // system.debug('to see tmpAdmissionDate: '+tmpAdmissionDate);
                            // system.debug('to see tmpDischargeDate: '+tmpDischargeDate);
                            Integer dayDiff_admission = -1;
                            if(tmpAdmissionDate != null && tmpAdmissionDate_history!=null){dayDiff_admission = tmpAdmissionDate.daysBetween(tmpAdmissionDate_history);}
                            Integer dayDiff_discharge = -1;
                            if(tmpDischargeDate != null && tmpDischargeDate_history!=null){dayDiff_discharge = tmpDischargeDate.daysBetween(tmpDischargeDate_history);}
                            if(dayDiff_admission == 0 && dayDiff_discharge == 0){
                                isExistInPreviousRecordBeforeInFastTrack = true;
                                // system.debug('to see isExistInPreviousRecordBeforeInFastTrack true: '+isExistInPreviousRecordBeforeInFastTrack);
                            }                                            
                        }
                    }
                }
                // system.debug('to see isExistInPreviousRecordBeforeInFastTrack: '+isExistInPreviousRecordBeforeInFastTrack);
                sj_HIF_d = !isExistInPreviousRecordBeforeInFastTrack; 
            }
            cList[0].Admitted_and_discharged_from_hospital__c = JSON.Serialize(wAdmittedAndDischargedFromHospitalList);
            cList[0].sj_HIF_d__c = sj_HIF_d;                                    
        }       
        // system.debug('to see sj_HIF_d: '+sj_HIF_d);
        return null;
    }
    
    public void clearwVisitDateStrList(){
        // system.debug('to see pass clearwVisitDateStrList');
        wVisitDateStrList.clear();        
        List<ClaimHelper.WrapperVisit> tmpWrapperList = new List<ClaimHelper.WrapperVisit>{};       
        ClaimHelper.WrapperVisit wVisitItem = new ClaimHelper.WrapperVisit();
        tmpWrapperList.add(wVisitItem);        
        wVisitDateStrList = tmpWrapperList;
        cList[0].Visit_Date__c = JSON.serialize(wVisitDateStrList);
    }
    
    public pageReference calculationForVisitDate(){
        sj_OP_d = false; //init
        Boolean isExistInPreviousRecordBeforeInNonFastTrack_OP = false;
        // system.debug('to see calculationForVisitDatestart');
        for(ClaimHelper.WrapperVisit tmpDatesItem:wVisitDateStrList){
            if(tmpDatesItem.visitDateTimestamp != null && tmpDatesItem.visitDateTimestamp != 0){tmpDatesItem.visitDate = DateTime.newInstance(tmpDatesItem.visitDateTimeStamp).date();}
        }
        // system.debug('to see wVisitDateStrList: '+wVisitDateStrList);    
        
        if(cList.size()>0){
            // 20210803 - minghua - CR48
            loadClaimSymptoms(cList[0].What_would_you_like_to_claim_for__c);

            cList[0].Visit_Date__c= JSON.Serialize(wVisitDateStrList);
            // system.debug('to see cList[0].Visit_Date__c: '+cList[0].Visit_Date__c);                
            List<ClaimHelper.WrapperVisit> tmpWrapperVisitDateList = (List<ClaimHelper.WrapperVisit>)JSON.deserialize(cList[0].Visit_Date__c,List<ClaimHelper.WrapperVisit>.class);            
            // system.debug('kevani to see tmpWrapperVisitDateList: '+tmpWrapperVisitDateList);            
            //query claim record with history non fast track claim record visit date
            String soql_historyWithSamePI = ClaimHelper.CLAIM_ALL_FIELD;
            soql_historyWithSamePI += ' where Person_s_Insured__c=\''+cList[0].Person_s_Insured__c+'\' and id !=\''+cList[0].id+'\' and Is_Fast_Track__c = true and Submission_Date__c = today and (OP__c = true or OPF__c = true) ';
            // system.debug('to see soql_historyWithSamePI: '+soql_historyWithSamePI);
            List<Claim__c> cList_historyWithSamePI = Database.query(soql_historyWithSamePI);
            if(cList_historyWithSamePI.size()==0){
                sj_OP_d = true;    
            }else{
                for(Claim__c cItem:cList_historyWithSamePI){
                    List<ClaimHelper.WrapperVisit> wTmpVisitDateList = (List<ClaimHelper.WrapperVisit>)JSON.deserialize(cItem.Visit_Date__c,List<ClaimHelper.WrapperVisit>.class);
                    // system.debug('to see wTmpVisitDateList: '+wTmpVisitDateList);
                    for(ClaimHelper.WrapperVisit wItem:wTmpVisitDateList){
                        // system.debug('to see wItem: '+wItem);
                        if(wItem.visitDateTimeStamp != null && wItem.visitDateTimeStamp !=0){wItem.visitDate = DateTime.newInstance(wItem.visitDateTimeStamp).date();}
                    
                        Date tmpVisitDate_history = wItem.visitDate; 
                        // system.debug('to see tmpVisitDate_history : '+tmpVisitDate_history);
                        //loop current claim admission date and discharge date to do comparsion
                        for(ClaimHelper.WrapperVisit tmpDatesItem:tmpWrapperVisitDateList){
                            if(tmpDatesItem.visitDateTimestamp != null && tmpDatesItem.visitDateTimestamp != 0){tmpDatesItem.visitDate = DateTime.newInstance(tmpDatesItem.visitDateTimestamp).date();}                            
                            Date tmpVisitDate = tmpDatesItem.visitDate; 
                            // system.debug('to see tmpVisitDate: '+tmpVisitDate);
                            Integer dayDiff_visit = -1;
                            if(tmpVisitDate_history != null && tmpVisitDate != null){dayDiff_visit = tmpVisitDate.daysBetween(tmpVisitDate_history);}
                            if(dayDiff_visit == 0){
                                isExistInPreviousRecordBeforeInNonFastTrack_OP = true;
                                // system.debug('to see found same date');
                            }
                        }                       
                    }
                }
                sj_OP_d = !isExistInPreviousRecordBeforeInNonFastTrack_OP; 
            }
            cList[0].sj_OP_d__c = sj_OP_d;                        
        }
        return null;
    }
    
    public void loadClaimRecordByPassingId(String claimId){        
        system.debug('to see loadClaimRecordByPassingId claimId start: '+claimId);
        if(!String.isBlank(claimId)){
            String soql_cId = ClaimHelper.CLAIM_ALL_FIELD;
            soql_cId += ' where id= :claimId';/* add by Jack on 2022-06-22 for project: Checkmarx SOQL injection */
            // soql_cId += ' where id=\''+claimId+'\'';
            cList = Database.query(soql_cId);
            system.debug('to see loadClaimRecordByPassingId cList: ' + cList);
            //load all json data to custom list
            if(cList.size()>0 && !String.isBlank(cList[0].Visit_Date__c)){wVisitDateStrList = (List<ClaimHelper.WrapperVisit>)JSON.deserialize(cList[0].Visit_Date__c,List<ClaimHelper.WrapperVisit>.class);}
            if(cList.size()>0 && !String.isBlank(cList[0].Information_from_other_companies__c)){
                wInfoFromOtherCompanyList = (List<ClaimHelper.WrapperInfoFromOtherCompany>)JSON.deserialize(cList[0].Information_from_other_companies__c,List<ClaimHelper.WrapperInfoFromOtherCompany>.class);
            }
            if (cList.size()>0 && !String.isBlank(cList[0].Information_of_benifit_from_other_comp__c)) {
                wInfoInsuredFromOtherCompanyList = (List<ClaimHelper.WrapperInfoFromOtherCompany>)JSON.deserialize(cList[0].Information_of_benifit_from_other_comp__c,List<ClaimHelper.WrapperInfoFromOtherCompany>.class);
            }
            if(cList.size()>0 && !String.isBlank(cList[0].Admitted_and_discharged_from_hospital__c)){wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cList[0].Admitted_and_discharged_from_hospital__c,List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);}            
            if(cList.size()>0){localIsFastTrack = cList[0].Is_Fast_Track__c;}           
            //if(cList.size()>0)    localIsPIForTC = cList[0].Is_PI_Greater_Then_18__c;  //Comment by Nicole for Encryption CR
            //Added by Nicole for Encrytion CR start
            if(cList.size()>0){
                localIsPIForTC = false;
                if(cList[0].Person_Insured_Date_Of_Birth__c!=null){
                    localIsPIForTC = CignaUtil.isPIGreaterThan18(cList[0].Is_Person_Insured_Claim__c, cList[0].Person_Insured_Date_Of_Birth__c);
                }

                // Rancho_JOBR133_20220530 - generate claim flow T&C When PI is PH
                generateSignatureTC();
                
                //20190624 - David Zhang - Align Claim Payment flow with CP
                if(cList[0].Is_Selected_Transfer_to_HK_Bank__c){
                    brkSelectedAccountNo = cList[0].Bank_Code__c  + '-' + cList[0].Bank_Branch_Code__c + '-' + cList[0].Bank_Account_Name__c;
                }else if(cList[0].Is_Selected_Transfer_to_Oversea_Bank__c){
                    brkSelectedAccountNo = cList[0].Bank_Account_Number__c;
                }else if(!String.isBlank(cList[0].Bank_Account_Information__c)){
                    Map<String,String> bankAccInfoMap = (Map<String,String>)JSON.deserialize(cList[0].Bank_Account_Information__c ,Map<String,String>.class); 
                    if(bankAccInfoMap.containsKey('accountNumber')){
                        brkSelectedAccountNo = bankAccInfoMap.get('accountNumber');
                    }
                }                                   
            }
            //Added by Nicole for Encrytion CR end           
            if(cList.size()>0 && !String.isBlank(cList[0].Person_s_Insured__c)){previousSelectedSsn = cList[0].Person_s_Insured__c;}   
            //load doc from record
            loadClaimTypeFromStr();
        }
    }
    
    public PageReference reloadClaimRecord(){
        // system.debug('to see reloadClaimRecord start');
        loadClaimRecordByPassingId(cId);
        return null;
    }        
    
    /*Save e-signature*/
    public void submitEsignature(){
        // system.debug('to see submitEsignature start');
        if(!String.isBlank(cId)){
        /*e-signature For Customer single signature*/
            if(eSignature!='' && eSignature!=null){
                eSignature = eSignature.substring(eSignature.indexOf(',') + 1, eSignature.length());
                // system.debug('eSignature : '+eSignature);
                Blob fileContent = EncodingUtil.base64Decode(eSignature);
                Attachment a = new Attachment(parentId = cId);
                a.body = fileContent;
                a.ContentType = 'image/png';                    
                a.name = 'newph_ esignature'+String.valueOf(DateTime.now());
                // system.debug('a.name: '+a.name);
                insert a;
            }
            if(cList.size()>0){
                cList[0].steps__c= 10;
                SaveRecord();
            }
        }
    }
    
    public PageReference submitClaim(){
        // system.debug('to see submitClaim start');
        if(cList.size()>0){
            for(Claim__c cItem: cList){
                cList[0].steps__c= 11;
                cList[0].Status__c = 'Processing';
            }
            saveRecord();
        }
        return null;
    }
    
    public void loadClaimTypeDocument(String benefitTypeStr){
        // system.debug('to see loadClaimTypeDocument benefitTypeStr start: '+benefitTypeStr);        
        /** reset **/
        noOfFormNeedToDownload = 0;
        needDownloadPDF = false;
        attList.clear();
        claimTypeDocIdAttachmentMap.clear();
        /** end reset **/       
        searchAllDocumentsByClaimType(benefitTypeStr);        
        Set<Id> claimTypeDocIdSet = new Set<Id>{};
        // system.debug('to see claimTypeDocumentList at loadClaimTypeDocument: '+claimTypeDocumentList);
        for(Claim_Type_Document__c cTypeDocItem: claimTypeDocumentList){
            claimTypeDocIdSet.add(cTypeDocItem.id);
        }
        
        String soql_attDoc = ClaimHelper.ATTACHMENT_URL_FIELD;         
        soql_attDoc += ' where ParentId =: claimTypeDocIdSet';       
        attList = Database.query(soql_attDoc);        
        for(Attachment att: attList){
            List<Attachment> tmp_attList = new List<Attachment>{};
            if(claimTypeDocIdAttachmentMap.get(att.ParentId) != null){tmp_attList = claimTypeDocIdAttachmentMap.get(att.ParentId);}
            tmp_attList.add(att);
            claimTypeDocIdAttachmentMap.put(att.ParentId, tmp_attList);
        }
        
        //system.debug('to see claimTypeDocIdAttachmentMap: '+claimTypeDocIdAttachmentMap);
        system.debug('[MyClaimSubmitController] soql_attDoc : ' + soql_attDoc);      //HKITSFDC-413 debug only  
        //clear list to load related doc need to download / upload
        wClaimTypeRelatedDocList.clear();        
        //add all result to wrapper class for claim type document
        for(Claim_Type_Document__c cTypeDocItem: claimTypeDocumentList){
            ClaimHelper.WrapperClaimTypeRelatedDocument tmp_wClaimTypeRelatedDocItem = new ClaimHelper.WrapperClaimTypeRelatedDocument();
            tmp_wClaimTypeRelatedDocItem.docId = cTypeDocItem.id;    
            /** testing to add rules **/
            tmp_wClaimTypeRelatedDocItem.rules = cTypeDocItem.Other_Rule_s__c;            
            tmp_wClaimTypeRelatedDocItem.docTypeName_eng = cTypeDocItem.Document_Name__c;    //e.g. sick leave cert.
            tmp_wClaimTypeRelatedDocItem.docTypeName_chi = cTypeDocItem.Document_Name_Chinese__c;    
            tmp_wClaimTypeRelatedDocItem.isPdf = false;    
            if(cTypeDocItem.Downloadable_as_PDF__c){
                noOfFormNeedToDownload += 1;
                //force to have download section
                needDownloadPDF = true;
                tmp_wClaimTypeRelatedDocItem.isPdf = true;    
            }
            List<Attachment> attList_tmp = new List<Attachment>{};
            if(claimTypeDocIdAttachmentMap.get(cTypeDocItem.id)!=null){attList_tmp =  claimTypeDocIdAttachmentMap.get(cTypeDocItem.id);}
            //too large
            tmp_wClaimTypeRelatedDocItem.attList = attList_tmp;
            List<String> attUrlList_tmp = new List<String>{};
            for(Attachment att: attList_tmp){
                String url = '';
                if(isCustomer){url = ClaimHelper.ATT_CUS_PREFIX + att.id;}
                else{url = ClaimHelper.ATT_BRK_PREFIX + att.id;}
                attUrlList_tmp.add(url);
            }
            tmp_wClaimTypeRelatedDocItem.attUrlList = attUrlList_tmp;
            List<Claim_Type_Document__c> cTypeDocList_tmp = new List<Claim_Type_Document__c>{};
            cTypeDocList_tmp.add(cTypeDocItem); 
            tmp_wClaimTypeRelatedDocItem.cTypeDocList = cTypeDocList_tmp;
            wClaimTypeRelatedDocList.add(tmp_wClaimTypeRelatedDocItem);
        }         
    }
    
    public void  initData(){
        // system.debug('to see 4');
        if(cList.size()>0){
            isContainPI = false;
            // system.debug('to see cList[0].Person_s_Insured__c: '+cList[0].Person_s_Insured__c);           
            if(!String.isBlank(cList[0].Policy__c)){
                selectedPolicy = cList[0].Policy__c;
                // 20210803 - minghua - CR48
                checkEconomistPolicy(selectedPolicy);
            }
            if(!isHideWSForTesting && !isCustomer){getIndividualPolicyListBasicByCriteria('','', '' ,'','', cList[0].Person_s_Insured__c);}
            // Zoe working in progress
            //if(!isCustomer)    createSamplePolicy();            
            if(!isHideWSForTesting && isCustomer){getIndividualPolicyListBasicByCriteria('','', userSsn ,'','','');}           
            if(!isHideWSForTesting && isCustomer){getGroupPolicyListBasicByCriteria('','');}            
            if(this.allSsnNamePIMap != null){
                this.PICount = this.allSsnNamePIMap.keySet().size();
            }                       
            LoadPIToGetPlanType();
            
            //for performance turning
            //loadSelectedWrapperPolicyList(wPolicyList_PI, wPolicyList_unchanged, cList[0].Person_s_Insured__c);
            // system.debug('to see wPolicyList_selected: '+wPolicyList_selected);
            if(cList.size()>0){loadSelectedWrapperPolicyList(wPolicyList_PI, wPolicyList_selected, cList[0].Person_s_Insured__c);}
            // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);            
            AddPolicyIntoClaim();    
        }
    }
    
    public void loadData(Integer seq){
        // system.debug('to see loadData seq start: '+seq);        
        if(seq== null || seq<1){
            //no step -> init
            steps = 1;
        }else{steps = seq;}
        
        // for customer
        if(isCustomer){    
            if(steps == 1){
                isContainPI = false;
                //call WS
                if(!isHideWSForTesting){getIndividualPolicyListBasicByCriteria('','', UserSsn,'','','');} //CTA9005525
                if(!isHideWSForTesting){getGroupPolicyListBasicByCriteria('','');}
                if(isHideWSForTesting){createSamplePolicy();} // testing data - fake data
                
                // get PI count
                if(this.allSsnNamePIMap != null){
                    this.PICount = this.allSsnNamePIMap.keySet().size();                    
                    if(PICount == 1){
                        // if only one PI, assign the PI automatically
                        for(Claim__c cItem: cList){
                            if(cItem.Person_s_Insured__c == null){
                                for(String tmpphid : allSsnNamePIMap.keySet()){
                                    cItem.Person_s_Insured__c = tmpphid;
                                    break;
                                }
                            }
                        }
                        getPolicyListForPI(wPolicyList_PI, wPolicyList_unchanged, cList[0].Person_s_Insured__c);
                    }
                }                
            }            
            if(steps>=2){SearchPolicyBySelectedPH();}
            
            //Nicole_20200311_GS Claim
            if(includeGSClaim && steps == 6){
                /* Nicole_GS Claim UAT_20210430_isAddBCEnable = false;*/                          
                //if(policyOptions.size()>1){
                //    policyOptions.add(0,new SelectOption(ClaimHelper.CLAIM_OPTION_ALL,Label.Pol_Claim_All));                
                //}                
                loadBankAccountRecordByPassingId(cId);
                if(bankAccountList.isEmpty() && policyOptions.size()>0){
                    Bank_Account__c bank = new Bank_Account__c(Claim__c = cId,Policy_Number__c = policyOptions[0].getValue());
                    if(employeeMember!=null && employeeMember.Region==ClaimHelper.MEMBER_REGION_HK){
                        bank.Is_Selected_Transfer_to_HK_Bank__c = true;
                        isNextEnable_Bank = true;
                    }
                    bankAccountList.add(bank);
                }
            }  
        }
        
        // for broker
        if(!isCustomer){    
            if(steps == 1){}            
            if(steps == 2){SearchPolicyBySelectedPH();}          
            //20190624 - David Zhang - Align Claim Payment flow with CP
            if(steps>= 5){
                if(cList[0].Is_Selected_Transfer_to_HK_Bank__c){
                    brkSelectedAccountNo = cList[0].Bank_Code__c  + '-' + cList[0].Bank_Branch_Code__c + '-' + cList[0].Bank_Account_Name__c;
                }else if(cList[0].Is_Selected_Transfer_to_Oversea_Bank__c){
                    brkSelectedAccountNo = cList[0].Bank_Account_Number__c;
                }else if(!String.isBlank(cList[0].Bank_Account_Information__c)){
                    Map<String,String> bankAccInfoMap = (Map<String,String>)JSON.deserialize(cList[0].Bank_Account_Information__c ,Map<String,String>.class); 
                    if(bankAccInfoMap.containsKey('accountNumber')){
                        brkSelectedAccountNo = bankAccInfoMap.get('accountNumber');
                    }
                }        
            }
        }        
    }
       
    //check year diff - load document logic
    public Boolean checkIfLessThanNumOfYears(Date startDate, Date currentDate, Integer numOfYears){
        // system.debug('to see checkIfLessThanNumOfYears start');
        Boolean isLessThanFlag = false;
        if(currentDate.year() - startDate.year() < numOfYears){
            isLessThanFlag = true;
        }else if(currentDate.year() - startDate.year() == numOfYears && currentDate.month() - startDate.month() < 0){
            isLessThanFlag = true;
        }else if(currentDate.year() - startDate.year() == numOfYears && currentDate.month() - startDate.month() ==0 && currentDate.day() - startDate.day() < 0){
            isLessThanFlag = true;
        }
        return isLessThanFlag;
    }
    
    public Boolean checkIfLessThanNumOfMonths(Date startDate, Date currentDate, Integer numOfMonths){
        // system.debug('to see checkIfLessThanNumOfMonths start');
        Boolean isLessThanFlag = false;
        if(currentDate.year() - startDate.year() == 1){    // different year
            if(currentDate.month() < startDate.month() && (currentDate.month() + 12 - startDate.month()) < numOfMonths){
                isLessThanFlag = true;
            }else if(currentDate.month() < startDate.month() && (currentDate.month() + 12 - startDate.month()) == numOfMonths && currentDate.day() - startDate.day() < 0){
                isLessThanFlag = true;
            }
        }else if(currentDate.year() - startDate.year() == 0){    // same year
            if(currentDate.month() - startDate.month() < numOfMonths){
                isLessThanFlag = true;
            }else if(currentDate.month() - startDate.month() == numOfMonths && currentDate.day() - startDate.day() < 0){
                isLessThanFlag = true;
            }
        }        
        return isLessThanFlag;
    }
    
    /** Webservice **/
    public void getGroupPolicyListBasicByCriteria(String policyNumberG,String policyHolderNameG){
        isLoadPIFromWS = true;
        policyGroupList = new List<HttpCalloutVO.Policy>();
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        
        //error from WS handling
        policyGroupList = helper.getGroupPolicyListBasicByCriteria(policyNumberG, policyHolderNameG); //policyNumberG, policyHolderNameG
        /**
        use  helper.getResultInfo().isSuccess    to see if the calling is success
        if helper.getResultInfo().isSuccess == false,   then can use helper.getResultInfo().resultInfoDesc  
        to view the error message
        **/
        if(!helper.getResultInfo().isSuccess){        
            errorMsg = 'Error at getGroupPolicyListBasicByCriteria: '+helper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        System.debug('to see policyGroupList.size(): '+policyGroupList.size());
        System.debug('to see wPolicyList_unchanged.size: '+wPolicyList_unchanged.size());  
        
        if(policyGroupList.size()>0){
            Integer tmpCount = 0;            
            for(HttpCalloutVO.Policy p: policyGroupList){
                // Rancho_JOBR376_20240612 - could not submit claim if policy expired more than 90 days
                if(null != p.memberTermDateInDate && p.memberTermDateInDate.addDays(90) <= Date.today()){
                    continue;
                }
                ClaimHelper.WrapperPolicy wPolicy = new ClaimHelper.WrapperPolicy();
                //IBM KOU 20180531 ticket productType start
                wPolicy.productType = p.productType;
                //IBM KOU 20180531 ticket productType end
                wPolicy.isLifePolicy = p.isLifePolicy;
                wPolicy.isIndividualPolicy = false;    //grp policy
                wPolicy.name = p.planName;
                wPolicy.policyNum = p.policyNumber;
                wPolicy.status = p.policyStatusDisplayName;
                //wPolicy.status = p.policyStatus;
                wPolicy.pItem = null;
                wPolicy.pItem_in = null;
                wPolicy.pItem_grp = p;                
                //data used at claim form but no use for claim process
                wPolicy.policyHolderName = p.holderName ;
                // add & update by minghua - 20190812 - SPS-232
                if(String.isNotBlank(p.holderSSN)){
                    wPolicy.policyHolderId = p.holderSSN;
                }else{
                    List<HttpCalloutVO.Person> insuredList = p.insuredList;
                    if(!insuredList.isEmpty()){
                        wPolicy.policyHolderId = insuredList[0].ssnNumber;
                    }
                }
                wPolicy.policyHolderPhoneNum= p.holderContactNumber;
                wPolicy.policyHolderEmailAddr = p.mailingAddress;
                wPolicy.paidToDate = p.paidToDate;    //paid to date
                
                Date tmpEffDate = null;
                if(String.isNotBlank(p.effDate)){
                    tmpEffDate = Date.valueOf(p.effDate);
                    Date today = System.today();
                    wPolicy.effectiveDate = p.effDate;    //effective date
                    if(checkIfLessThanNumOfMonths(tmpEffDate, today, 6)){wPolicy.isLessThan6Months = true;}
                    else{wPolicy.isLessThan6Months = false;}
                    if(checkIfLessThanNumOfYears(tmpEffDate, today, 2)){wPolicy.isLessThan2Yrs = true;}
                    else{wPolicy.isLessThan2Yrs = false;}
                    if(checkIfLessThanNumOfYears(tmpEffDate, today, 3)){wPolicy.isLessThan3Yrs = true;}
                    else{wPolicy.isLessThan3Yrs = false;}
                    //IBM KOU Wonder Woman CR 20180430 Start
                    if(checkIfLessThanNumOfYears(tmpEffDate, today, 1)){wPolicy.isLessThan1Yr = true;}
                    else{wPolicy.isLessThan1Yr = false;}
                    //IBM KOU Wonder Woman CR 20180430 End                    
                }else{
                    wPolicy.isLessThan6Months = false;
                    wPolicy.isLessThan2Yrs = false;
                    wPolicy.isLessThan3Yrs = false;
                    wPolicy.isLessThan1Yr = false;  //IBM KOU Wonder Woman CR 20180430                  
                }
                /**
                * remarks: 
                * not use plan code here, get plan code at PolicyPersonCoverageBasic
                * load currency code and isUSPolicy at getPolicyBasic after selected policy - AddPolicyIntoClaim  
                * load bank information at getPolicyPaymentBasic after selected policy - AddPolicyIntoClaim  
                *
                **/
                //WS get PI list from getPolicyPersonListBasic 
                if(!String.isBlank(p.policyNumber)){
                    //input value into allSsnNamePIMap - as login id always the same, no need to clear allSsnNamePIMap as always the same result
                    if(!isHideWSForTesting){wPolicy.PIMapList = getPolicyPersonListBasic(p.policyNumber);}
                }
                
                /** Zoe updated on 0915 PPCP-160
                if(tmpCount < max_record_allowed){  
                    wPolicyList_unchanged.add(wPolicy);
                }else{
                    // record > max_record_allowed = 20
                    isExcessMaxLimit = true;
                    errorMsgExcessMaxLimit = 'Too many group policy to display, please contact our representative for more detail.';
                }
                */               
                //Nicole_20200405_GS Claim
                if(gsMemberHelper.isGSUser(userSsn,wPolicy.policyNum)){
                    employeeMember = gsMemberHelper.getEmployeeByFamilySSN(userSsn,wPolicy.policyNum);   
                    if(employeeMember!=null && employeeMember.SSN!=null && employeeMember.SSN==userSSN){
                        isLoginUserEmployee = true;
                    }                    
                    getPolicyPaymentForGS(wPolicy.policyNum);                    
                    if(!isLoginUserEmployee && ((bankAccInfoForGS !=null && String.IsBlank(bankAccInfoForGS.accountNumber)) || bankAccInfoForGS==null)){
                        wPolicy.isDisable = true;
                    }
                }                
                wPolicyList_unchanged.add(wPolicy);                
                tmpCount++;
            }
        }
        // system.debug('to see wPolicyList_unchanged: '+wPolicyList_unchanged);
        // system.debug('to see wPolicyList_unchanged.size: '+wPolicyList_unchanged.size());               
    }        
    
    public void getIndividualPolicyListBasicByCriteria(String policyNumber ,String holderFullName ,String holderSSN ,String holderDialNumber ,String insuredFullName ,String insuredSSN){
        //it works
        // system.debug('to see getIndividualPolicyListBasicByCriteria start');
        isLoadPIFromWS = true;
        policyIndividualList = new List<HttpCalloutVO.Policy>();
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        // Zoe updated on 0810
        //PolicyCalloutHelperFranco helper = new PolicyCalloutHelperFranco();        
        //policyIndividualList = helper.getIndividualPolicyListBasicByCriteria(policyNumber , holderFullName, holderSSN, holderDialNumber, insuredFullName, insuredSSN);        
        policyIndividualList = helper.getIndividualPolicyListBasicByCriteria(policyNumber , holderFullName, holderSSN, holderDialNumber, insuredFullName, insuredSSN);
        //policyIndividualList = helper.getIndividualPolicyListBasicByCriteria();
        // system.debug('Zoe testing: policyIndividualList ' + policyIndividualList); 
        // Zoe updated on 0810        
        /**
        try {
            policyIndividualList = helper.getIndividualPolicyListBasicByCriteria(policyNumber , holderFullName, holderSSN, holderDialNumber, insuredFullName, insuredSSN);
        
        } catch(CignaWSResultTooLargeException e1){
            // system.debug('to see error: '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } catch(CignaWSTimeoutException e2){
            // system.debug('to see error: '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        } catch(CignaWSException e3){
            // system.debug('to see error: '+e3);
            // Handle the exception
        } catch(Exception e4){
            // Handle the exception
            // system.debug('to see error: '+e4);
        }
        if(!helper.getResultInfo().isSuccess){
            errorMsg = 'Error at getIndividualPolicyListBasicByCriteria: '+helper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        **/
        // system.debug('to see policyIndividualList: '+policyIndividualList);
               
        /************* Zoe Dummy Data for Broker ************/       
        if(!isCustomer && insuredSSN == 'test'){
            //policyIndividualList = new List<HttpCalloutVO.Policy>();
            //HttpCalloutVO.Policy p1 = new HttpCalloutVO.Policy();
        }       
        /************* End of Zoe Dummy Data for Broker ************/  
             
        // system.debug('Zoe testing policyIndividualList.size(): ' + policyIndividualList.size());
        if(policyIndividualList.size()>0){
            Integer tmpCount = 0;
            for(HttpCalloutVO.Policy p: policyIndividualList){
                /** get value from mapping **/                
                // if(tmpCount < max_record_allowed){
                // Zoe updated on 0915 PPCP-160
                
                //JR1809 see if policy been inactive more than 90 days
                //if yes then bypass the policy
                if(p.inactiveDays != null && p.inactiveDays>= 90){
                    continue;
                }
                //Rancho_HKITSFDC83_20240829 - not allow submit claim for pending policy
                if(String.isNotBlank(p.policyStatusCode) && psmMap.containsKey(p.policyStatusCode) && psmMap.get(p.policyStatusCode).contains('Pending')){
                    continue;
                }
                Map<String,String> tmpStrMap = new Map<String,String>{};                
                ClaimHelper.WrapperPolicy wPolicy = new ClaimHelper.WrapperPolicy();
                //IBM KOU 20180531 ticket productType start
                wPolicy.productType = p.productType;
                //IBM KOU 20180531 ticket productType end 
                wPolicy.isLifePolicy = p.isLifePolicy;
                wPolicy.isIndividualPolicy = true;    //ind. policy
                wPolicy.name = p.planName;
                // system.debug('to see p.planName: '+p.planName);
                // system.debug('to see p.policyNumber: '+p.policyNumber);
                wPolicy.policyNum = p.policyNumber;
                wPolicy.status = p.policyStatusDisplayName;            
                wPolicy.policyHolderName = p.holderName ;
                wPolicy.policyHolderId = p.holderSSN;
                wPolicy.policyHolderPhoneNum= p.holderContactNumber;
                wPolicy.policyHolderEmailAddr = p.mailingAddress;
                wPolicy.pItem = null;
                wPolicy.pItem_in = p;
                wPolicy.pItem_grp = null;
                wPolicy.currenyCode = p.currencyCode;                
                //data used at claim form but no use for claim process
                wPolicy.policyHolderName = p.holderName ;
                wPolicy.policyHolderId = p.holderSSN;
                wPolicy.policyHolderPhoneNum= p.holderContactNumber;
                wPolicy.policyHolderEmailAddr = p.mailingAddress;
                wPolicy.paidToDate = p.paidToDate;    //paid to date
                
                Date tmpEffDate = null;
                if(String.isNotBlank(p.effDate)){//change for judge error Heather 20190725
                    tmpEffDate = Date.valueOf(p.effDate);
                    Date today = System.today();
                    wPolicy.effectiveDate = p.effDate;    //effective date
                    if(checkIfLessThanNumOfMonths(tmpEffDate, today, 6)){wPolicy.isLessThan6Months = true;}
                    else{wPolicy.isLessThan6Months = false;}
                    if(checkIfLessThanNumOfYears(tmpEffDate, today, 2)){wPolicy.isLessThan2Yrs = true;}
                    else{wPolicy.isLessThan2Yrs = false;}
                    if(checkIfLessThanNumOfYears(tmpEffDate, today, 3)){wPolicy.isLessThan3Yrs = true;}
                    else{wPolicy.isLessThan3Yrs = false;}
                    //IBM KOU Wonder Woman CR 20180430 Start
                    if(checkIfLessThanNumOfYears(tmpEffDate, today, 1)){wPolicy.isLessThan1Yr = true;}
                    else{wPolicy.isLessThan1Yr = false;}
                    //IBM KOU Wonder Woman CR 20180430 End                    
                }else{
                    wPolicy.isLessThan6Months = false;
                    wPolicy.isLessThan2Yrs = false;
                    wPolicy.isLessThan3Yrs = false;
                    wPolicy.isLessThan1Yr = false;   //IBM KOU Wonder Woman CR 20180430                 
                }
                // system.debug('to see each p.insuredList: '+p.insuredList);                
                //remarks: get plan code from PolicyPersonCoverageBasic
                
                //new fields
                // system.debug('to see p.insuredList: '+p.insuredList);
                List<Map<String,String>> tmpStringMapList = new List<Map<String,String>>{};                
                for(HttpCalloutVO.Person wPIInfo: p.insuredList){
                    //get PI from WS and save at map
                    Map<String,String> pAccInfoMap_tmp = new Map<String,String>{};                    
                    String fullName = wPIInfo.fullName ;
                    String ssnNumber = wPIInfo.ssnNumber ;                   
                    fullName = fullName.trim();
                    ssnNumber = ssnNumber.trim();                                       
                    //create tmp mapping where ssn as key - with pi info map as value
                    if(!String.isBlank(fullName) && !String.isBlank(ssnNumber)){
                        pAccInfoMap_tmp.put('fullName', fullName); 
                        pAccInfoMap_tmp.put('ssnNumber', ssnNumber);                     
                        allSsnNamePIMap.put(ssnNumber, pAccInfoMap_tmp);    //assume ssn unique                        
                        pAccIdInfoMap.put(ssnNumber, pAccInfoMap_tmp); 
                        tmpStringMapList.add(pAccInfoMap_tmp);
                        isContainPI = true;
                    }
                }
                // system.debug('to see allSsnNamePIMap: '+allSsnNamePIMap);   
                // system.debug('SK0713 WPOLICY NAME2=' + wPolicy.name);
                wPolicy.PIMapList = tmpStringMapList;         
                // if(wPolicy.name!='Employee Health Value+ Portable Plan - Top Up Plan' && wPolicy.name!='EMPLOYEE HEALTH VALUE+ PORTABLE PLAN – CONVERSION')
                wPolicyList_unchanged.add(wPolicy);
                /**
                }else{
                    // record > max_record_allowed = 20
                    isExcessMaxLimit = true;
                    errorMsgExcessMaxLimit = 'Too many individual policy to display, please contact our representative for more detail.';
                }
                Zoe updated on 0915 PPCP-160 */                
                tmpCount++;                  
            }
        }       
        // system.debug('to see wPolicyList_unchanged: '+wPolicyList_unchanged);
    }
    
    //sample record if WS is not ready
    public void createSamplePolicy(){
        // system.debug('to see createSamplePolicy start');
        isLoadPIFromWS = true;
        
        ClaimHelper.WrapperPolicy wPolicy = new ClaimHelper.WrapperPolicy();
        wPolicy.name = 'Policy For Testing';
        wPolicy.policyNum = 'HMKHK0001203159';
        wPolicy.status = 'Cancel';
        wPolicy.policyHolderName = 'Wincy Chan';
        wPolicy.policyHolderId = 'H779900';
        wPolicy.policyHolderPhoneNum= '21234567';
        wPolicy.policyHolderEmailAddr = 'wincychan1997@yahoo.com.hk';
        wPolicy.effectiveDate = String.valueOf(date.newinstance(2016, 12, 17));
        wPolicy.paidToDate = String.valueOf(date.newinstance(2017, 12, 16));
        EarliestPaidToDate = date.newinstance(2017, 2, 16);
        wPolicy.isLessThan6Months = true;
        wPolicy.isLessThan2Yrs = true;
        wPolicy.isLessThan3Yrs = true;
        wPolicy.isIndividualPolicy = true;
        wPolicy.pItem = null;
        wPolicy.pItem_in = null;
        wPolicy.pItem_grp = null;
        //not sure as HttpCalloutVO.Policy Decimal - paymentAmt - related to Modal premium means paid 3/6/12 months amount currency USD/HKD -split ourselves
        wPolicy.currenyCode = 'USD';
        wPolicy.isUSDPolicy = true;
        
        //get PI from WS and save at map
        Map<String,String> pAccInfoMap_tmp = new Map<String,String>{};        
        //new fields
        List<Map<String,String>> tmpStringMapList = new List<Map<String,String>>{};
        Map<String,String> tmpStrMap = new Map<String,String>{};
        tmpStrMap.put('fullName', 'Wincy Chan'); 
        tmpStrMap.put('ssnNumber', 'A932622'); 
        tmpStringMapList.add(tmpStrMap);        
        //testing data - fake one
        Map<String,String> tmpAllSsnNamePIMap = new Map<String,String>{};
        tmpAllSsnNamePIMap.put('A932622', 'Wincy Chan');    //assume ssn unique
        allSsnNamePIMap.put('A932622', tmpStrMap);
        pAccIdInfoMap.put('A932622', tmpAllSsnNamePIMap); 
        wPolicy.PIMapList = tmpStringMapList;                 
        List<Map<String,String>> tmpValueMapList = new List<Map<String,String>>{};
        Map<String,String> tmpKeyMap = new Map<String,String>{};
        tmpKeyMap.put(wPolicy.policyNum , 'A932622');
            
        Map<String,String> tmpValueMap = new Map<String,String>{};
        tmpValueMap.put('benefitAmount', '100');    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
        tmpValueMap.put('benefitCode', 'TEST');
        tmpValueMap.put('rateScale', '1');        
        tmpValueMapList.add(tmpValueMap);       
        pNumSsnValueListMap.put(tmpKeyMap, tmpValueMapList);        
        wPolicyList_unchanged.add(wPolicy);       
    }    
    /** Webservice end **/
    
    // for customer and broker search policy by select PH - step3
    public PageReference SearchPolicyBySelectedPH(){        
        // system.debug('to see pass SearchPolicyBySelectedPH start');        
        //reload claim data
        loadClaimRecordByPassingId(cId);
        //for performance turning
        //loadSelectedWrapperPolicyList(wPolicyList_PI, wPolicyList_unchanged, cList[0].Person_s_Insured__c);
        
        System.debug('SearchPolicyBySelectedPH wPolicyList_PI:'+wPolicyList_PI);
        System.debug('SearchPolicyBySelectedPH wPolicyList_selected:'+wPolicyList_selected);
        System.debug('SearchPolicyBySelectedPH Person_s_Insured__c:'+cList[0].Person_s_Insured__c);
        
        // 20211216 - minghua - JOBR-67, Performance Tuning, only steps equal 2 call this function
        if(steps==2){
            if(cList.size()>0){loadSelectedWrapperPolicyList(wPolicyList_PI, wPolicyList_selected, cList[0].Person_s_Insured__c);}
        }
        // system.debug('to see wPolicyList_PI.size(): '+wPolicyList_PI.size());
        return null;
    }
    
    public void loadClaimTypeFromStr(){
        // system.debug('to see loadClaimTypeFromStr');
        String benefitTypeStr = '';
        String tmpBenefitTypeStr = '';       
        if(cList.size()>0 && cList[0].HIF__c){tmpBenefitTypeStr +='HIF;';}
        if(cList.size()>0 && cList[0].HI__c){tmpBenefitTypeStr +='HI;';}
        if(cList.size()>0 && cList[0].HPA__c){tmpBenefitTypeStr +='HPA;';}
        if(cList.size()>0 && cList[0].HS__c){tmpBenefitTypeStr +='HS;';}
        if(cList.size()>0 && cList[0].DIS__c){tmpBenefitTypeStr +='DIS;';}
        if(cList.size()>0 && cList[0].MAT__c){tmpBenefitTypeStr +='MAT;';}
        if(cList.size()>0 && cList[0].CI__c){tmpBenefitTypeStr +='CI;';}
        if(cList.size()>0 && cList[0].OP__c){tmpBenefitTypeStr +='OP;';}
        if(cList.size()>0 && cList[0].OPF__c){tmpBenefitTypeStr +='OPF;';}
        //Added by minglei 2018.05.15 [add Wellness type to claim] start
        if(cList.size()>0 && cList[0].WL__c){tmpBenefitTypeStr +='WL;';}
        //Added by minglei 2018.05.15 [add Wellness type to claim] end          
        if(cList.size()>0 && cList[0].Is_Selected_Temporary_or_Permanent_Dis__c){tmpBenefitTypeStr +='TTD;';}  
        if(cList.size()>0 && cList[0].Is_Selected_Waiver_of_Premium__c){tmpBenefitTypeStr +='WD;';}
        
        // system.debug('to see tmpBenefitTypeStr: '+tmpBenefitTypeStr);
        //// system.debug('to see cList[0].Type_of_benefit_to_claim__c: '+cList[0].Type_of_benefit_to_claim__c);        
        if(cList.size()>0 && !String.isBlank(tmpBenefitTypeStr) && String.isBlank(cList[0].Type_of_benefit_to_claim__c)){
            cList[0].Type_of_benefit_to_claim__c = tmpBenefitTypeStr;
        }       
        if(cList.size()>0 && !String.isBlank(cList[0].Type_of_benefit_to_claim__c)){
            benefitTypeStr = cList[0].Type_of_benefit_to_claim__c;
            loadClaimTypeDocument(benefitTypeStr);
            selectBenefitTypeList.clear();
            if(!String.isBlank(benefitTypeStr)){
                // 20210803 - minghua - CR48, check only op
                checkOnlySelectedOP(benefitTypeStr);

                selectBenefitTypeList = benefitTypeStr.split(';');
            }
            if(cList.size()==1){
                cList[0].Type_of_benefit_to_claim__c = benefitTypeStr;
                for(String tmpType: selectBenefitTypeList){
                    if(tmpType == 'HIF'){cList[0].HIF__c = true;}
                    if(tmpType == 'HI'){cList[0].HI__c = true;}
                    if(tmpType == 'HPA'){cList[0].HPA__c = true;}
                    if(tmpType == 'HS'){cList[0].HS__c = true;}
                    if(tmpType == 'CI'){cList[0].CI__c = true;}
                    if(tmpType == 'DIS'){cList[0].DIS__c = true;}
                    if(tmpType == 'OP'){cList[0].OP__c = true;}
                    if(tmpType == 'OPF'){cList[0].OPF__c = true;}
                    if(tmpType == 'MAT'){cList[0].MAT__c = true;}
                    //Added by minglei 2018.05.15 [add Wellness type to claim] start
                    if(tmpType == 'WL'){cList[0].WL__c = true;}
                    //Added by minglei 2018.05.15 [add Wellness type to claim] end                    
                    if(tmpType == 'TTD'){cList[0].Is_Selected_Temporary_or_Permanent_Dis__c = true;}
                    if(tmpType == 'WP'){cList[0].Is_Selected_Waiver_of_Premium__c = true;}
                    /**
                    if(tmpType == 'IPMI')    cList[0].All_Non_IPMI_policy__c= false;
                    else    cList[0].All_Non_IPMI_policy__c= true;
                    **/
                    //if(tmpType == 'BrokerPAC')    cList[0].is_Selected_Broker_PAC_plan__c= false;
                    //else    cList[0].is_Selected_Broker_PAC_plan__c= true;                   
                }
            }
        }
    }
    
    public void passOneBenefitTypeFlag(){
        // system.debug('******* only one benefit type? ' + onlyOneBenefitType);
    }
    
    /** options selection **/
    //select benefit type
    public PageReference SelectBenefitType(){
        // system.debug('to see SelectBenefitType start');
        // system.debug('benefitTypeStr:'+benefitTypeStr);        
        //pass benefitTypeStr from js
        if(cList.size()>0){
            //reset flag
            cList[0].HIF__c = false;
            cList[0].HI__c = false;
            cList[0].HPA__c = false;
            cList[0].HS__c = false;
            cList[0].CI__c = false;
            cList[0].DIS__c = false;
            cList[0].OP__c = false;
            cList[0].OPF__c = false;
            cList[0].MAT__c = false;
            //Added by minglei 2018.05.15 [add Wellness type to claim] start
            cList[0].WL__c = false;
            //Added by minglei 2018.05.15 [add Wellness type to claim] end            
            cList[0].Is_Selected_Temporary_or_Permanent_Dis__c = false;
            cList[0].Is_Selected_Waiver_of_Premium__c = false;                   
            //cList[0].is_Selected_Broker_PAC_plan__c = false;
            cList[0].Type_of_benefit_to_claim__c = benefitTypeStr;
            cList[0].steps__c = 4;     //hard code current steps is 4
            // 20210803 - minghua - CR48, check only op
            checkOnlySelectedOP(benefitTypeStr);
        }
        loadClaimTypeFromStr();       
        
        //next steps
        steps = 5;        
        SaveRecord();        
        loadData(steps);       
        return null;
    }
    
    public PageReference AllowTypeOfDoctorToClaim(){
        // system.debug('to see allowTypeOfDoctorToClaimStr start');
        system.debug('to see allowTypeOfDoctorToClaimStr: '+allowTypeOfDoctorToClaimStr);        
        // system.debug('to see cList[0].sj_OP_a__c before: '+cList[0].sj_OP_a__c);
        //get allowTypeOfDoctorToClaimStr  from js
        if(cList.size()>0){cList[0].Allow_Types_Of_Doctor_To_Claim__c = allowTypeOfDoctorToClaimStr ;}       
        SaveRecord();
        system.debug('to see cList[0].sj_OP_a__c after: '+cList[0].sj_OP_a__c);
        return null;
    }
    
    public void clearClericalManualValue(){
        // system.debug('to see clearClericalManualValue start');
        cList[0].What_is_of_work_allocation_Clerical__c = null;
        cList[0].What_is_of_work_allocation_Manual__c = null;
    }
    
    public void changeManualValue(){
        // system.debug('to see changeManualValue start');
        String tmpClericalStr = cList[0].What_is_of_work_allocation_Clerical__c;        
        if(!String.isBlank(tmpClericalStr) && tmpClericalStr.isNumeric() && Integer.valueOf(tmpClericalStr)<=100){
            cList[0].What_is_of_work_allocation_Manual__c = String.valueOf(Integer.valueOf(100 - Integer.valueOf(cList[0].What_is_of_work_allocation_Clerical__c)));
        }else{
            cList[0].What_is_of_work_allocation_Manual__c = null;
        }
    }
    
    public void getPHPersonBasic(){
        // system.debug('to see getPHPersonBasic');       
        if(cList.size()>0){
            // Zoe updated on 0406 for performance tuning
            //get phone number and email addr from other WS
            if(!isHideWSForTesting){getPersonBasic(cList[0].Policy_Holder_ID__c, false);}    //pAccIdInfoMap full more data after getPersonBasic call have value
            
            // Rancho_PI101_20230428 - avoid null pi dob
            if(String.isNotBlank(cList[0].Person_s_Insured__c) && null == cList[0].Person_Insured_Date_Of_Birth__c && cList[0].Steps__c>7){
                getPersonBasic(cList[0].Person_s_Insured__c, true);
            }

            Map<String,String> pAccIdInfoMap_getByPassSsn = new Map<String,String>{};
            if(pAccIdInfoMap.get(cList[0].Policy_Holder_ID__c)!= null){pAccIdInfoMap_getByPassSsn = pAccIdInfoMap.get(cList[0].Policy_Holder_ID__c);}
            if(pAccIdInfoMap_getByPassSsn !=null && pAccIdInfoMap_getByPassSsn.size()>0){
                String mobilePhoneNo = pAccIdInfoMap_getByPassSsn.get('mobilePhoneNo');    //list of mobile number info
                String mobileCountryCode = pAccIdInfoMap_getByPassSsn.get('mobileCountryCode');
                String mobileAreaCode = pAccIdInfoMap_getByPassSsn.get('mobileAreaCode');
                String mobileTelephoneNo = pAccIdInfoMap_getByPassSsn.get('mobileTelephoneNo');
                String mobileNum = '';
                if(!String.isBlank(mobilePhoneNo)){
                    mobileNum = mobilePhoneNo;
                }else{
                    mobileNum = '+'+mobileCountryCode +' ('+mobileAreaCode+') '+mobileTelephoneNo;
                }
                cList[0].Policy_Holder_Contact_No__c = mobileNum ;
                if(pAccIdInfoMap_getByPassSsn.get('emailAddr') != null){
                    cList[0].Policy_Holder_Email_Address__c = pAccIdInfoMap_getByPassSsn.get('emailAddr');
                }
            }
            SaveRecord();
        }
    }
    
    public PageReference sendESignatureEmail(){    //send link to PH for signature
        // system.debug('to see sendESignatureEmail');
        //add Bob 20201218 CM User
        if(CignaUtil.isCMLoginAsUser()){
            CignaUtil.stopSubmittionforCMUser();
            return null;
        }
        if(cList.size()>0){
            String tmpEmailAddr = cList[0].Email_Address_to_send__c;
            // system.debug('to see tmpEmailAddr : '+tmpEmailAddr);
            if(!String.isBlank(tmpEmailAddr)){
                // Zoe updated on 0406 for performance tuning
                //get phone number and email addr from other WS
                if(!isHideWSForTesting){getPersonBasic(cList[0].Policy_Holder_ID__c, false);}//pAccIdInfoMap full more data after getPersonBasic call have value
                
                // Rancho_PI101_20230428 - avoid null pi dob
                if(String.isNotBlank(cList[0].Person_s_Insured__c) && null == cList[0].Person_Insured_Date_Of_Birth__c && cList[0].Steps__c>7){
                    getPersonBasic(cList[0].Person_s_Insured__c, true);
                }

                Map<String,String> pAccIdInfoMap_getByPassSsn = new Map<String,String>{};
                if(pAccIdInfoMap.get(cList[0].Policy_Holder_ID__c)!= null){pAccIdInfoMap_getByPassSsn = pAccIdInfoMap.get(cList[0].Policy_Holder_ID__c);}
                if(pAccIdInfoMap_getByPassSsn !=null && pAccIdInfoMap_getByPassSsn.size()>0){
                    String mobilePhoneNo  = pAccIdInfoMap_getByPassSsn.get('mobilePhoneNo');    //list of mobile number info
                    String mobileCountryCode = pAccIdInfoMap_getByPassSsn.get('mobileCountryCode');
                    String mobileAreaCode = pAccIdInfoMap_getByPassSsn.get('mobileAreaCode');
                    String mobileTelephoneNo = pAccIdInfoMap_getByPassSsn.get('mobileTelephoneNo');
                    String mobileNum = '';
                    if(!String.isBlank(mobilePhoneNo)){
                        mobileNum = mobilePhoneNo;
                    }else{
                        mobileNum = '+'+mobileCountryCode +' ('+mobileAreaCode+') '+mobileTelephoneNo ;
                    }
                    cList[0].Policy_Holder_Contact_No__c = mobileNum ;
                    if(pAccIdInfoMap_getByPassSsn.get('emailAddr') != null){
                        cList[0].Policy_Holder_Email_Address__c = pAccIdInfoMap_getByPassSsn.get('emailAddr');
                    }
                }
                
                //Zoe updated on 0406 for performance tuning, the current one is identical with broker part
                /**
                if(isCustomer){
                    if(!cList[0].Is_Using_Chinese_Version__c)    ESignatureUtil.sendEmail(cList[0].id, 'Email_to_send_signature_link_English', tmpEmailAddr, true, 'Claims_T_and_C_Customer','Cigna Hong Kong');
                    else    ESignatureUtil.sendEmail(cList[0].id, 'Email_to_send_signature_link_Chinese', tmpEmailAddr, true, 'Claims_T_and_C_Customer','Cigna Hong Kong');
                    //working
                    cList[0].Is_Chosen_Sign_On_Screen__c = false;
                    cList[0].Is_Chosen_Send_Esignature__c = true;
                    SaveRecord();
                }
                else{
                    // system.debug('******** before send email for signature broker');
                    steps = 8;
                    cList[0].Is_Chosen_Sign_On_Screen__c = false;
                    cList[0].Is_Chosen_Send_Esignature__c = true;
                    // system.debug('******** before send email saving record steps: ' + cList[0].Steps__c);
                    SaveRecord();
                    if(!cList[0].Is_Using_Chinese_Version__c)    ESignatureUtil.sendEmail(cList[0].id, 'Email_to_send_signature_link_English', tmpEmailAddr, true, 'Claims_T_and_C_Customer','Cigna Hong Kong');
                    else    ESignatureUtil.sendEmail(cList[0].id, 'Email_to_send_signature_link_Chinese', tmpEmailAddr, true, 'Claims_T_and_C_Customer','Cigna Hong Kong');
                }
                */
                if(!isCustomer){steps = 8;}
                cList[0].Is_Chosen_Sign_On_Screen__c = false;
                cList[0].Is_Chosen_Send_Esignature__c = true;
                SaveRecord();
                
                //if(!cList[0].Is_Using_Chinese_Version__c)    toSendESignatureEmail(cList[0].id, 'Email_to_send_signature_link_English', tmpEmailAddr);
                //else    toSendESignatureEmail(cList[0].id, 'Email_to_send_signature_link_Chinese', tmpEmailAddr);
                // Zoe updated on 0428, changed email template name because change to send email by ws
                if(!cList[0].Is_Using_Chinese_Version__c){
                    toSendESignatureEmail(cList[0].id, 'Email to send signature link English', tmpEmailAddr);
                    // SPS-421_chris_2020_05_14
                    if(cList[0].Is_Created_By_Broker__c && String.isNotBlank(brokerEmailAddress)){
                        //JOBR-184: JOBR-232 added by Kermit
                        List<emailTemplate> tempList;
                        if(!cList[0].Is_Contain_GI_Policy__c && cList[0].Is_Contain_Life_Policy__c){
                            tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send Claim to brk PDF ENG Life'];
                        }else if(cList[0].Is_Contain_GI_Policy__c && !cList[0].Is_Contain_Life_Policy__c){
                            tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send Claim to brk PDF ENG GI'];
                        }else{
                            tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send Claim to brk PDF English'];
                        }
                        //JOBR-184: JOBR-232 added by Kermit
                        if(tempList.size()> 0){
                            ESignatureUtil.sendOutEmailWebserive(tempList[0].Id, UserInfo.getUserId(), cList[0].Id, brokerEmailAddress);   
                        }
                    }
                }else{
                    toSendESignatureEmail(cList[0].id, 'Email to send signature link Chinese', tmpEmailAddr);
                    // SPS-421_chris_2020_05_14
                    if(cList[0].Is_Created_By_Broker__c && String.isNotBlank(brokerEmailAddress)){
                        //JOBR-184: JOBR-232 added by Kermit
                        List<emailTemplate> tempList;
                        if(!cList[0].Is_Contain_GI_Policy__c && cList[0].Is_Contain_Life_Policy__c){
                            tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send Claim to brk PDF CHI Life'];
                        }else if(cList[0].Is_Contain_GI_Policy__c && !cList[0].Is_Contain_Life_Policy__c){
                            tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send Claim to brk PDF CHI GI'];
                        }else{
                            tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send Claim to brk PDF Chinese'];
                        }
                        //JOBR-184: JOBR-232 added by Kermit
                        if(tempList.size()> 0){
                            ESignatureUtil.sendOutEmailWebserive(tempList[0].Id, UserInfo.getUserId(), cList[0].Id, brokerEmailAddress);   
                        }
                    }
                }                   
            }
            
            //20191224 - Terry - Signature Require  
            List<E_Signature_Request__c> signatureReq = [SELECT id, name, E_Signature_URL__c, Request_Type__c, Policy_Number__c, Claim__c FROM E_Signature_Request__c WHERE Claim__c=:cId AND Completed__c=False];                                                                                                                    
            String eSignLink = '';  
            String policyNo = '';   
            String phId = '';   
            for(Claim__c claim : [SELECT E_Signature_Link__c, Policy__c, Policy_Holder_ID__c FROM Claim__c WHERE id=:cId]){ 
                eSignLink = claim.E_Signature_Link__c;  
                policyNo = claim.Policy__c; 
                phId = claim.Policy_Holder_ID__c;   
            }   
                
            if(signatureReq != null && signatureReq.size()> 0){    
                for(E_Signature_Request__c signReq : signatureReq){ 
                    signReq.E_Signature_URL__c=eSignLink;   
                }   
                update signatureReq;    
            }else{  
                Id phUserId = UserInfo.getUserId(); 
                if(phId != null && phId != ''){ 
                    List<User> phUsers = [SELECT id FROM User WHERE AccountId IN (SELECT id FROM Account WHERE SSN__c=:phId)];  
                    if(phUsers.size()> 0){ 
                        phUserId = phUsers[0].Id;   
                    }   
                }   
                E_Signature_Request__c signReq = new E_Signature_Request__c(E_Signature_URL__c=eSignLink, Claim__c=cId, Policy_Number__c=policyNo, Request_Type__c='Claim', OwnerId=phUserId);  
                insert signReq; 
            }
        }
        return null;
    }
    
    // @Future(callout=true) 
    // Zoe updated on 0426, otherwise, the e-signature link will be incorrect
    public static void toSendESignatureEmail(String cId,String emailTemplate,String tmpEmailAddr){
        //ESignatureUtil.sendEmail(cId, emailTemplate, tmpEmailAddr, true, 'Claims_T_and_C_Customer', 'Cigna Hong Kong');
        // Zoe updated on 0428, change to send email by ws
        ESignatureUtil.sendEmailWebService(cId, emailTemplate, tmpEmailAddr, true, 'Claims_T_and_C_Customer', 'Cigna Hong Kong');
    }
    
    public PageReference sendAttachmentEmail(){    //send attachment link to PH
        // system.debug('to see sendAttachmentEmail');
        // system.debug('to see cList.size: '+cList.size());
        system.debug('to see clist[0].id: '+cList[0].id);
        //add Bob 20201218 CM User
        if(CignaUtil.isCMLoginAsUser()){
            CignaUtil.stopSubmittionforCMUser();
            return null;
        }
        if(cList.size()==1 && cList[0].id!= null){
            String tmpEmailAddr = cList[0].Email_Address_to_send__c;
            system.debug('to see tmpEmailAddr : '+tmpEmailAddr);            
            if(!String.isBlank(tmpEmailAddr)){
                // system.debug('to see before pass toSendAttachmentEmail');
                String emailBody = getEmailContentBody(cList[0]);
                String emailTitle = getClaimTypeStrForEmailTitle(cList[0]);
                for(User u: uList){
                    toSendAttachmentEmail(cList[0].id, tmpEmailAddr, 'Cigna Hong Kong', emailBody, emailTitle, u.LanguageLocaleKey);
                }                
                //toSendAttachmentEmail(cList[0].id, tmpEmailAddr, 'Cigna Hong Kong', emailBody, emailTitle, u.LanguageLocaleKey);
            }
        }
        return null;
    }
    
    @Future(callout=true) 
    public static void toSendAttachmentEmail(String cId,String tmpEmailAddr,String oEmailAddrName,String emailBody,String emailTitle,String lang){
        system.debug('to see pass cId: '+cId);
        system.debug('to see pass tmpEmailAddr: '+tmpEmailAddr);
        // system.debug('to see pass oEmailAddrName: '+oEmailAddrName);
        if(!String.isBlank(cId) && !String.isBlank(tmpEmailAddr) && !String.isBlank(oEmailAddrName)){        
            // system.debug('to see toSendAttachmentEmail pass cId: '+cId);
            //OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName =: oEmailAddrName];
            List<OrgWideEmailAddress> owaList = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName =: oEmailAddrName];
            OrgWideEmailAddress owa = new OrgWideEmailAddress();
            if(owaList.size()>0){owa = owaList[0];}
            
            String soql = ClaimHelper.CLAIM_ALL_FIELD;
            soql += ' where id=\''+cId+'\' ';
            List<Claim__c> cList = Database.query(soql);
            if(cList.size()>0){
                HttpCalloutVO.EmailRequest EmailRequest = new HttpCalloutVO.EmailRequest();
                EmailRequest.MailTo = tmpEmailAddr;
                // if(cList[0].Is_Using_Chinese_Version__c){
                if(lang == 'zh_TW' || lang == 'zh_HK'){
                    //EmailRequest.MailTitle = '信諾香港: 申請- 保單# '+cList[0].Policy__c;
                    EmailRequest.MailTitle = '信諾香港: '+emailTitle+' 表格- 保單# '+cList[0].Policy__c;                    
                }else{
                    //EmailRequest.MailTitle = 'Cigna HK: Claim Form - Policy # '+cList[0].Policy__c;
                    EmailRequest.MailTitle = 'Cigna HK: '+emailTitle+' Claim Form - Policy # '+cList[0].Policy__c;
                }
                EmailRequest.MailBody = emailBody;
                EmailRequest.SecureMailInd = true;
                EmailCalloutHelper helper = new EmailCalloutHelper();
                helper.sendEmail(EmailRequest);
            }
        }else{
            // system.debug('to see fail to see toSendAttachmentEmail: cId'+ cId +'    tmpEmailAddr: '+tmpEmailAddr+'    oEmailAddrName: '+oEmailAddrName);
        } 
    }
       
    @future(callout=true)
    public static void toSendClaimFormEmail(String cId,String tmpEmailAddr,String oEmailAddrName){
        // system.debug('to see toSendClaimFormEmail start');
        if(!String.isBlank(cId) && !String.isBlank(tmpEmailAddr) && !String.isBlank(oEmailAddrName)){
            //send claim form in pdf to send to QHMS server for IPMI policy only
            // system.debug('to see toSendClaimFormEmail pass cId: '+cId);
            //OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName =: oEmailAddrName];
            List<OrgWideEmailAddress> owaList = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName =: oEmailAddrName];
            OrgWideEmailAddress owa = new OrgWideEmailAddress();
            if(owaList.size()>0){owa = owaList[0];}
            String soql = ClaimHelper.CLAIM_ALL_FIELD;
            soql += ' where id=\''+cId+'\' ';
            List<Claim__c> cList = Database.query(soql);
            if(cList.size()>0){
                String firstPolicyNo = '';
                if(cList[0].Policy__c != null && cList[0].Policy__c != ''){
                    String[] pNoList = cList[0].Policy__c.split(',');
                    pNoList.sort();
                    firstPolicyNo = pNoList[0];
                }
                //generate PDF first
                PageReference thePage = Page.ExportSubmitClaimPDFVFP;
                thePage.getParameters().put('id', cId);
                //blob body = thePage.getContent();
                //for test class
                blob tmpBody;
                if(!test.isRunningTest()){tmpBody = thePage.getContent();
                }else{tmpBody = blob.valueof('TEST');}
                blob body = tmpBody;
                
                List<Attachment> attachmentList = new List<Attachment>();
                attachment att= new attachment();
                // att.name= cId+'_'+system.now()+'.pdf';
                att.name = firstPolicyNo + '-CF.pdf';
                att.body = body;
                //add content type to avoid judge content type is null validation
                att.contentType = 'application/pdf';
                att.ParentId = cId;
                att.isPrivate = false;
                attachmentList.add(att);
                //claim form is created
                // system.debug('to see attachmentList: '+attachmentList);
                // List<EmailTemplate> templateList = [Select id, Subject, HtmlValue, Body from EmailTemplate where developername = 'Email_to_QHMS_for_Claim_by_WS_New'];
                List<EmailTemplate> templateList = [Select id, Subject, HtmlValue, Body from EmailTemplate where developername = 'Email_to_QHMS_for_Claim_by_WS'];
                if(templateList.size()>0){
                    // system.debug('to send email by WS');
                    EmailTemplate template = templateList.get(0);
                    // Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, '', '');
                    HttpCalloutVO.EmailRequest EmailRequest = new HttpCalloutVO.EmailRequest();
                    EmailRequest.MailTo = tmpEmailAddr;
                    String policyNo = '';
                    if(cList[0].Policy__c!=null){
                        policyNo = ' - Policy # '+cList[0].Policy__c;
                    } 
                    EmailRequest.MailTitle = template.Subject + policyNo ;
                    // Zoe updated in 03/24 for email template, but rollbacked
                    
                    // EmailRequest.MailTitle = email.getSubject()+cList[0].Policy__c;
                    EmailRequest.MailBody = template.Body;
                    // EmailRequest.MailBody = '<![CDATA['+email.getHTMLBody()+']]>';
                    EmailRequest.SecureMailInd = true;
                    EmailRequest.AttachmentList = new List<HttpCalloutVO.Attachment>();
                    for(Attachment a: attachmentList){
                        HttpCalloutVO.Attachment attachment_tmp = new HttpCalloutVO.Attachment();
                        attachment_tmp.AttachmentType = 'Document';
                        attachment_tmp.fileName = a.Name;
                        attachment_tmp.fileBody = a.Body;
                        EmailRequest.AttachmentList.add(attachment_tmp);
                    }
                    
                    //get uploaded attachments
                    Integer attCount = 1;
                    for(Attachment a : [select Name, Body, BodyLength From Attachment Where ParentId = :cId And (Not Name Like :cId + '%') And (Not Name Like '%esignature%')]){
                        // ---- confirmed format for attachment
                        String tmpExtension = '';
                        String tmpName = '';
                        system.debug('original file name: ' + a.Name);
                        if(a.Name != null && a.Name != ''){
                            String[] tmpNameArray = a.Name.split('\\.');
                            // system.debug('*************tmpNameArray : ' + tmpNameArray);
                            tmpExtension = '.' + tmpNameArray[tmpNameArray.size() - 1];
                        }
                        // system.debug('*************tmpExtension : ' + tmpExtension);
                        if(attCount < 10){tmpName = firstPolicyNo + '-0' + String.valueOf(attCount);
                        }else{tmpName = firstPolicyNo + '-' + String.valueOf(attCount);}
                                         
                        HttpCalloutVO.Attachment attachment_tmp = new HttpCalloutVO.Attachment();
                        attachment_tmp.AttachmentType = 'Document';
                        attachment_tmp.fileName = tmpName + tmpExtension;
                        // system.debug('*************attachment filename: ' + attachment_tmp.fileName);
                        attachment_tmp.fileBody = a.Body;
                        EmailRequest.AttachmentList.add(attachment_tmp);
                        attCount++;
                    }
                    EmailCalloutHelper helper = new EmailCalloutHelper();
                    helper.sendEmailOnebyOne(EmailRequest);
                    if(helper.getResultInfo() != null && helper.getResultInfo().isSuccess){
                        //clearClaimDetailsAfterSubmit(cId);
                    }
                }
            }
        }else{
            // system.debug('to see fail to see toSendClaimFormEmail: cId'+ cId +'    tmpEmailAddr: '+tmpEmailAddr+'    oEmailAddrName: '+oEmailAddrName);
        }    
    }
    
    @future(callout=true)
    // isBrokerSubmit -> indicator for group claim, not broker submit...
    // True - All Group policies; False - contains individual policies
    public static void toSendClaimFormToServer(Id cId,List<String> policyList, Boolean isBrokerSubmit){
        // system.debug('to see pass toSendClaimFormToServer cId: '+cId);
        system.debug('to see pass toSendClaimFormToServer policyList: '+policyList);
        if(!String.isBlank(cId) && policyList.size()>0){
            //generate claim form PDF first
            String soql_cId = ClaimHelper.CLAIM_ALL_FIELD;
            soql_cId += ' where id=\''+cId+'\'';
            List<Claim__c> cList_submit = Database.query(soql_cId);
            if(cList_submit.size()>0){
                PageReference thePage = Page.ExportSubmitClaimPDFVFP;
                thePage.getParameters().put('id', cId);
                //blob body = thePage.getContent();
                //for test class
                blob tmpBody;
                if(!test.isRunningTest()){tmpBody = thePage.getContent();}
                else{tmpBody = blob.valueof('TEST');}
                blob body = tmpBody;
                
                List<HttpCalloutVO.Attachment> paraList = new List<HttpCalloutVO.Attachment>();
                HttpCalloutVO.Attachment a = new HttpCalloutVO.Attachment();
                String firstPolicyNo = '';
                if(cList_submit[0].Policy__c != null && cList_submit[0].Policy__c != ''){
                    String[] pNoList = cList_submit[0].Policy__c.split(',');
                    pNoList.sort();
                    firstPolicyNo = pNoList[0];
                }
                
                //a.attachmentData64Binary = EncodingUtil.base64Encode(body);
                a.fileBody = body;
                a.mimeType = 'application/pdf';
                a.mimeTypeTC = '17';    //unknown not sure
                //a.fileName = 'Claim_Form_'+cList_submit[0].Person_s_Insured__c+'_'+system.now();
                //a.fileName = firstPolicyNo + '-CF'; //Ray's Updates
                a.fileName = firstPolicyNo + '-CF.pdf';    // ---- confirmed filename format
                //a.attachmentHashValue = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256',body));
                //a.fileExtension = 'pdf';                 // ---- confirmed to remove extension tag
                paraList.add(a);
                
                String soql_attUpload = ClaimHelper.ATTACHMENT_ALL_FIELD +' where parentId= :cId ';
                // system.debug('to see soql_attUpload: '+soql_attUpload);
                List<Attachment> attUploadList = Database.query(soql_attUpload);
                Integer idx_att = 1;
                for(Attachment att: attUploadList){
                    if(att.Name.contains('esignature')){continue;}
                    HttpCalloutVO.Attachment a_tmp = new HttpCalloutVO.Attachment();
                    // Zoe testing attachment ws
                    //a_tmp.attachmentData64Binary = EncodingUtil.base64Encode(att.body);
                    a_tmp.AttachmentType = 'Document';
                    a_tmp.mimeType = att.contentType;
                    a_tmp.fileBody = att.Body;
                    a_tmp.mimeTypeTC = '17';    //unknown not sure
                    // a_tmp.fileName = 'Attachment'+idx_att+'_'+cList_submit[0].Person_s_Insured__c+'_'+system.now();
                    
                    // ---- confirmed format for attachment
                    String tmpExtension = '';
                    String tmpName = '';
                    if(att.Name != null && att.Name != ''){
                        String[] tmpNameArray = att.Name.split('\\.');
                        tmpExtension = '.' + tmpNameArray[tmpNameArray.size() - 1];
                    }
                    if(idx_att < 10){
                        tmpName = firstPolicyNo + '-0' + String.valueOf(idx_att);
                    }else{
                        tmpName = firstPolicyNo + '-' + String.valueOf(idx_att);
                    }
                    a_tmp.fileName = tmpName + tmpExtension;
                    //a_tmp.fileName = tmpName;            //  Ray's Updates
                    
                    // a_tmp.attachmentHashValue = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256',body));
                    // a_tmp.fileExtension = 'pdf';
                    if(!String.isBlank(att.contentType)){
                        List<String> ext_strList = att.contentType.split('/');
                        if(ext_strList.size()==2){a_tmp.fileExtension = ext_strList[1];}
                    }
                    paraList.add(a_tmp);
                    idx_att += 1;
                }
                ClaimCalloutHelper helper = new ClaimCalloutHelper();
                List<String> firstPolicyList = new List<String>();
                firstPolicyList.add(firstPolicyNo);
                //helper.SubmitClaimRequest(paraList, firstPolicyList);
                // system.debug('to see paraList size: '+paraList.size());
                
                //loop list of item
                Integer successCount = 0;
                for(HttpCalloutVO.Attachment tmpAttItem: paraList){
                    List<HttpCalloutVO.Attachment> tmpWSAttList = new List<HttpCalloutVO.Attachment>{};
                    tmpWSAttList.add(tmpAttItem);
                    helper.SubmitClaimRequest(tmpWSAttList, firstPolicyList, isBrokerSubmit);
                    system.debug('**********send to ws result: ' + helper.resultCode);
                    if(helper.getResultInfo() != null && helper.getResultInfo().isSuccess){
                        successCount++;
                    }
                }
                if(paraList.size() == successCount){
                    //clearClaimDetailsAfterSubmit(cId);
                }
                
                /**    
                try {
                    // helper.SubmitClaimRequest(paraList ,policyList);
                    List<String> firstPolicyList = new List<String>();
                    firstPolicyList.add(firstPolicyNo);
                    helper.SubmitClaimRequest(paraList, firstPolicyList);
                } catch(CignaWSResultTooLargeException e1){
                    // system.debug('to see error: '+e1);
                    // Handle the exception
                    // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
                } catch(CignaWSTimeoutException e2){
                    // system.debug('to see error: '+e2);
                    // Handle the exception
                    // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
                } catch(CignaWSException e3){
                    // system.debug('to see error: '+e3);
                    // Handle the exception
                } catch(Exception e4){
                    // Handle the exception
                    // system.debug('to see error: '+e4);
                }
                **/
            }else{
                // system.debug('to see fail to see toSendClaimFormToServer invalid cId: '+cId);
            }
        }else{
            // system.debug('to see fail to see toSendClaimFormToServer');
        }    
    }
    
    public static void clearClaimDetailsAfterSubmit(Id cId){
        // system.debug('to see clearClaimDetailsAfterSubmit start');
        /***************  1. Attachments ********************************/
        List<Attachment> listAttToDel = new List<Attachment>();
        listAttToDel = [SELECT Id FROM Attachment WHERE parentId =: cId];
        if(listAttToDel.size()>0){
            Delete listAttToDel;
        }
        
        /***************  2. External Data ******************************/
        List<External_Data__c> listExtToDel = new List<External_Data__c>();
        listExtToDel = [SELECT Id FROM External_Data__c WHERE Claim__c =: cId];
        if(listExtToDel.size()>0){
            Delete listExtToDel;
        }
        
        /***************  3. Details ************************************/
        //Fields to keep:  status, agent name, agent code, broker company code, policy holder name, policy change type, policy numbers, last modified datetime, create datetime, created by, last modified by - TNB-818
        //                 Status__c, Broker_Financial_Consultant_Name__c, Broker_Financial_Consultant_Code__c, Broker_Company__c, Submission_Date__c, 
        //                 Person_s_Insured__c, Person_Insured_Name__c, Policy__c, Policy_Holder_ID__c, Policy_Holder_Name__c, Display_Selected_Benefit_Type_s__c, Display_Selected_Benefit_Type_s_In_Chi__c
        
        //                 Id, Person_s_Insured__c, Visit_Date__c, Submission_Date__c, OP__c, OPF__c, Is_Fast_Track__c - for OP Fast Track checking
        //                 Id, Person_s_Insured__c, Admitted_and_discharged_from_hospital__c, Submission_Date__c, HIF__c, Is_Fast_Track__c - for HIF fast track checking
        
        //                 Is_Created_By_Broker__c, Is_Created_By_Customer__c, Selected_Question_s__c, sj_HIF_d__c, sj_OP_d__c
        //                 HIF__c, OP__c, HI__c, HPA__c, CI__c, HS__c, DIS__c, MAT__c - for Is_Fast_Track__c formula
        //                 Is_Selected_Temporary_or_Permanent_Dis__c, Is_Selected_Waiver_of_Premium__c - for Display_Selected_Benefit_Type_s__c formula
        /****************************************************************/
        Claim__c Request = new Claim__c ();
        Request.id = cId;
        Request.Status__c = 'Processing';
        // to keep:
        /*******************
        All FC related
        
        Request.HIF__c = '';
        Request.HI__c = '';
        Request.HPA__c = '';
        Request.HS__c = '';
        Request.DIS__c = '';
        Request.OP__c = '';
        Request.CI__c = '';
        Request.MAT__c = '';
        Request.OPF__c = '';
        Request.Selected_Question_s__c = '';
        Request.Display_Selected_Benefit_Type_s_In_Chi__c = '';
        Request.Display_Selected_Benefit_Type_s__c = '';
        Request.Is_Selected_Waiver_of_Premium__c = '';
        Request.Is_Selected_Temporary_or_Permanent_Dis__c = '';
        Request.Submission_Date__c = '';
        Request.Policy__c = '';
        Request.Is_Fast_Track__c = '';
        
        Request.sj_OP_d__c = '';
        Request.Visit_Date__c = null;
        Request.sj_HIF_d__c = '';
        Request.Admitted_and_discharged_from_hospital__c = '';
        
        Request.Is_Created_By_Broker__c = '';
        Request.Is_Created_By_Customer__c = '';
        
        Request.Policy_Holder_ID__c = '';
        Request.Policy_Holder_Name__c = '';
        Request.Person_Insured_Name__c = '';
        Request.Person_s_Insured__c = '';
        *******************/
        Request.Is_Contain_Individual_Life_Policy__c = false;
        Request.HS_Less_Than_3_Yrs_or_Broker_PAC__c = false;
        Request.HPA_Less_Than_2_Yrs__c = false;
        Request.Is_Chosen_Send_Esignature__c = false;
        Request.Is_Chosen_Sign_On_Screen__c = false;
        Request.Is_Contain_Life_Policy__c = false;
        Request.All_Policy_IPMI__c = false;
        Request.Ask_If_More_Than_One_Claim__c = false;
        Request.All_Claims_Related_To_Same_Event__c = false;
        Request.Cannot_Enter_Bank_Account_Information__c = false;
        Request.Is_Displayed_For_Customer__c = false;
        Request.Amount_Of_Sum_Insured__c = null;
        Request.Allow_Types_Of_Doctor_To_Claim__c = '';
        Request.Is_Contain_Group_Policy__c = false;
        Request.Is_Contain_Individual_Policy__c = false;
        Request.Is_Selected_Transfer_to_HK_Bank__c = false;
        Request.Is_Selected_Transfer_to_Oversea_Bank__c = false;
        Request.Is_Contain_US_Policy__c = false;
        Request.sj_OP_a__c = false;
        Request.Is_All_Selected_Policy_EffDate_6_month__c = false;
        Request.All_Non_IPMI_policy__c = false;
        Request.is_Selected_Broker_PAC_plan__c = false;
        Request.PI_without_any_Sen_Code_N6__c = false;
        Request.E_Signature_Link__c = '';
        Request.Policy_Holder_Email_Address__c = '';
        Request.Policy_Holder_Contact_No__c = '';
        Request.Person_Insured_Gender__c = '';
        Request.Person_Insured_Date_Of_Birth__c = null;
        Request.Is_Using_Chinese_Version__c = false;
        Request.Policy_Holder__c = null;
        Request.Email_Address_to_send__c = '';
        Request.What_is_the_phone_of_hospital_doctor__c = '';
        Request.Do_you_have_the_admission_details__c = false;
        Request.Bank_Account_Holder__c = '';
        Request.Bank_Account_Name__c = '';
        Request.Bank_Account_Number__c = '';
        Request.Bank_Branch_Address__c = '';
        Request.Bank_Branch_Code__c = '';
        Request.Bank_Code__c = '';
        Request.Bank_Name__c = '';
        Request.Bank_Routing_Code_ABA__c = '';
        Request.Bank_SWIFT__c = '';
        Request.What_would_you_like_to_claim_for__c = '';
        Request.What_is_of_work_allocation_Clerical__c = '';
        Request.What_is_of_work_allocation_Manual__c = '';
        Request.Bank_Account_Information__c = '';
        Request.Steps__c = null;
        Request.Account__c = null;
        Request.Claim_Type__c = '';
        Request.Date_of_stop_working_due_to_disability__c = null;
        Request.Do_you_stay_in_hospital__c = false;
        Request.Information_from_other_companies__c = '';
        Request.Is_there_any_room_charge__c = false;
        Request.Payment_Currency__c = '';
        Request.Please_input_the_amount_of_charge_HKD__c = null;
        Request.Receive_reimbursement_from_other_comp__c = false;
        Request.Have_All_Documents_To_Upload__c = false;
        Request.Still_on_sick_leave__c = false;
        Request.Type_of_benefit_to_claim__c = '';
        Request.What_is_the_hospital_doctor_name__c = '';
        Request.What_is_your_1st_consultation_date__c = null;
        update Request;
    }
    /*Other attachment list...*/
    
    /*get general attachment list*/
    public List<Attachment> getListAtt(String attType){
        // system.debug('to see getListAtt attType start: '+attType);            
        List<Attachment> lstAttrename = new List<Attachment>(); 
        List<Attachment> lstAtt = new List<Attachment>();
        if(cId!='' && cId!=null){
            lstAtt= [SELECT Name FROM Attachment Where parentId=: cId and Name LIKE: attType+'%'];
            for(Attachment att :lstAtt){
                Attachment tempAtt = new Attachment();
                tempAtt.Name = att.name.removeStart(attType+'_');
                tempAtt.Id = att.id;
                
                lstAttrename.add(tempAtt);
            }
        }
        return lstAttrename;                                                                    
    }
    /** options selection end **/
    
    public void LoadPIToGetPlanType(){
        // system.debug('to see LoadPIToGetPlanType start');
        //get selected policy list
        selectedPolicyList = new Set<String>();
        if(!String.isBlank(selectedPolicy)){
            selectedPolicyList.addAll(selectedPolicy.split(','));
            cList[0].Policy__c = selectedPolicy;
        }
        system.debug('to see selectedPolicy: '+selectedPolicy);
        system.debug('to see selectedPolicyList: '+selectedPolicyList);
        /**
        if(!isCustomer && String.isBlank(selectedPolicy)){
            wPolicyList_selected = wPolicyList_unchanged;
        }else{
            for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_unchanged){
                // system.debug('to see loop wPolicyItem: '+wPolicyItem.policyNum);
                if(!String.isBlank(selectedPolicy) && selectedPolicy.contains(wPolicyItem.policyNum)){
                    // system.debug('to see contains wPolicyItem: ');
                    wPolicyList_selected.add(wPolicyItem);
                }
            }
        }
        **/

        // add by minghua 20190807 - SPS-225 Customer Portal UAT - Claim type information no update for changing policy
        wPolicyList_selected.clear();
        if(!isCustomer){
            wPolicyList_selected = wPolicyList_unchanged;
        }else{
            // 2021-07-08 minghua PI-33 Portal cannot display the claim benefit list when customer submitted a claim
            if (wPolicyList_unchanged.isEmpty()) {
                isContainPI = false;
                if(!isHideWSForTesting){getIndividualPolicyListBasicByCriteria('','', userSsn,'','','');}
                if(!isHideWSForTesting){getGroupPolicyListBasicByCriteria('','');}
                // get PI count
                if(this.allSsnNamePIMap != null){
                    this.PICount = this.allSsnNamePIMap.keySet().size();                    
                    if(PICount == 1){
                        // if only one PI, assign the PI automatically
                        for(Claim__c cItem: cList){
                            if(cItem.Person_s_Insured__c == null){
                                for(String tmpphid : allSsnNamePIMap.keySet()){
                                    cItem.Person_s_Insured__c = tmpphid;
                                    break;
                                }
                            }
                        }
                        getPolicyListForPI(wPolicyList_PI, wPolicyList_unchanged, cList[0].Person_s_Insured__c);
                    }
                }
            }
            
            for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_unchanged){
                // system.debug('to see loop wPolicyItem: '+wPolicyItem.policyNum);
                if(!String.isBlank(selectedPolicy) && selectedPolicy.contains(wPolicyItem.policyNum)){
                    // system.debug('to see contains wPolicyItem: ');
                    wPolicyList_selected.add(wPolicyItem);
                }
            }
        }
        
        // system.debug('to see wPolicyList_selected: '+wPolicyList_selected);
        for(Claim__c cItem: cList){
            String PISsn = '';
            if(cItem.Person_s_Insured__c != null){
                PISsn = cItem.Person_s_Insured__c;
                //reset policy data
                if(previousSelectedSsn != PISsn){
                    previousSelectedSsn = PISsn ;
                    cItem.Policy__c = null;
                }
            }
            cItem.Certificate_Number__c = ''; // Rancho_PI81_20221107 - clear old data
            // system.debug('to see PISsn: '+PISsn);
            if(wPolicyList_selected.size()>0 && !String.isBlank(PISsn)){
                // system.debug('to see wPolicyList_selected: '+wPolicyList_selected);
                // system.debug('to see wPolicyList_selected size: '+wPolicyList_selected.size());
                Integer i = 1;
                
                for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_selected){
                    system.debug('current pol no: '+wPolicyItem.policyNum);
                    String pNum_tmp = '';
                    pNum_tmp = wPolicyItem.policyNum;
                    pNum_tmp = pNum_tmp.trim();
                    if(!String.isBlank(pNum_tmp) && wPolicyItem.PIMapList != null && wPolicyItem.PIMapList.size()>0){
                        for(Map<String,String> tmpMap: wPolicyItem.PIMapList){
                            String ssnFromMap = '';
                            if(tmpMap.get('ssnNumber') != null){ssnFromMap = tmpMap.get('ssnNumber');}
                            ssnFromMap = ssnFromMap.trim();
                            String fullName ='';
                            if(tmpMap.get('fullName') != null){fullName = tmpMap.get('fullName');}
                            String certNum = tmpMap.get('certNum'); //Add by Manuel on Sep 28 that supplement parameter for claim request
                            
                            system.debug('tmp map: '+tmpMap);
                            system.debug('to see PISsn: '+PISsn);
                            // system.debug('to see isHideWSForTesting : '+isHideWSForTesting);
                            if(!String.isBlank(ssnFromMap) && ssnFromMap.equals(PISsn)){
                                if(!isHideWSForTesting){
                                    cItem.Person_Insured_Name__c = fullName;
                                    // Rancho_PI81_20221107 - avoid overriding value when select multiple policy
                                    if(String.isBlank(cItem.Certificate_Number__c)){
                                        cItem.Certificate_Number__c = certNum;
                                    }else{
                                        cItem.Certificate_Number__c += ';' + certNum;
                                    }
                                    // cItem.Certificate_Number__c = certNum; //Add by Manuel on Sep 28 that supplement parameter for claim request
                                    // system.debug('to see Person_Insured_Name__c : '+cItem.Person_Insured_Name__c);
                                    //ind. and group
                                    getPolicyPersonCoverageBasic(wPolicyItem.policyNum, PISsn);    //pNumSsnValueListMap get result Map<Map<String,String>, List<Map <String,String>>>
                                    //get value - policyNumSsnGetCertNumMap from getPolicyPersonCoverageBasic - //policyNum, ssn, certNum
                                    //group -> get benefit code by clinic visit call
                                    // Zoe commented on 1017 PPCP-143
                                    /**
                                    Map<String,String> tmpKeyGetCertMap = new Map<String,String>{};
                                    tmpKeyGetCertMap.put(wPolicyItem.policyNum, PISsn);
                                    Map<String,String> tmpResultGetCertMap = new Map<String,String>{};
                                    tmpResultGetCertMap = policyNumSsnGetCertNumMap.get(tmpKeyGetCertMap);
                                    // system.debug('to see tmpResultGetCertMap: '+tmpResultGetCertMap);
                                    if(tmpResultGetCertMap != null && !wPolicyItem.isIndividualPolicy && ssnFromMap.equals(PISsn)){
                                        String tmp_policyNum = '';
                                        if(tmpResultGetCertMap.get('policyNum') != null)    tmp_policyNum = tmpResultGetCertMap.get('policyNum');
                                        String tmp_ssnNumber = '';
                                        if(tmpResultGetCertMap.get('ssnNumber') != null)    tmp_ssnNumber = tmpResultGetCertMap.get('ssnNumber');
                                        String tmp_certNum = '';
                                        if(tmpResultGetCertMap.get('certNum') != null)    tmp_certNum = tmpResultGetCertMap.get('certNum');
                                        
                                        getClinicVisitCount(tmp_policyNum , tmp_ssnNumber , tmp_certNum); 
                                        break;
                                    }
                                    */
                                }
                                // system.debug('to see pNumSsnValueListMap: '+pNumSsnValueListMap);
                                //get DOB and gender from WS - getPersonBasic
                                // 20200817 - minghua - Performance issue in claim flow Step 2
                                // if(!isHideWSForTesting)    getPersonBasic(PISsn, true);    //pAccIdInfoMap full more data after getPersonBasic call have value
                                
                            }
                        }
                    }
                    i++;
                }
            }
        }
    }    
    
    public void AddPolicyIntoClaim(){
        system.debug('to see AddPolicyIntoClaim start');
        system.debug('cList[0].Policy__c: '+cList[0].Policy__c);
        // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
        Boolean tmp_policyMoreThan6Month = false;
        totalSumInsured = 0;    //init
                        
        //load bank account information from WS
        wPolicyPaymentBasicList.clear();
        bankAccInfoList.clear();
        //Raistlin - 20191024 - GS claim
        bankAccInfoForGS = null;
        //Nicole_20200220_GS Claim
        includeGSClaim = false;
        policyOptions = new List<SelectOption>(); 
        
        for(Claim__c cItem: cList){
            // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
            //reset flag
            cItem.Is_Contain_Individual_Policy__c = false;
            cItem.Is_Contain_Group_Policy__c = false;
            
            Boolean atLeastOneNonIPMI = false;
            List<String> policyNumberItemList = new List<String>{};
            if(!String.isBlank(cItem.Policy__c)){
                policyNumberItemList = cItem.Policy__c.split(',');    //selected policy number list
                // 20210803 - minghua - CR48
                checkEconomistPolicy(cItem.Policy__c);
            }else{
                // 20210803 - minghua - CR48
                if(!String.isBlank(selectedPolicy)){
                    policyNumberItemList = selectedPolicy.split(',');
                    checkEconomistPolicy(selectedPolicy);
                }
            }
            
            system.debug('to see cItem.Policy__c: '+cItem.Policy__c);
            system.debug('to see policyNumberItemList: '+policyNumberItemList);
            // system.debug('to see policyNumberItemList.size(): '+policyNumberItemList.size());
            
            String PISsn = '';
            if(cItem.Person_s_Insured__c != null){PISsn = cItem.Person_s_Insured__c;}
            String tmpPolicyListStr = '';     //remove unwanted seperater
            
            Boolean isFail_sj_OP_a = false;    //flag to check if pass sj_OP_a
            Boolean isContainUSPolicy = false;    //flag to check if claim incude US policy
            Boolean isAtLeastOneIPMI = false;
            Boolean isContainLifePolicy = false;    //flag to check if own life policy
            Boolean isContaiGIPolicy = false;       //Rancho_JOBR133_20220530 - flag to check if own GI policy
            Boolean isContainIndividualLifePolicy = false;    
            for(String pNumStr: policyNumberItemList){
                // system.debug('to see pNumStr: '+pNumStr);
                pNumStr = pNumStr.trim();
                // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
                if(!String.isBlank(pNumStr)){
                    //Nicole_20200220_GS Claim
                    if(gsMemberHelper.isGSUser(userSsn,pNumStr)){
                        includeGSClaim = true;
                        policyOptions.add(new SelectOption(pNumStr, pNumStr));           
                    }
                    
                    
                    //pass policy number to get bank account info each time
                    // system.debug('to see pass getPolicyPaymentBasic pNumStr: '+pNumStr);
                    
                    if(!isHideWSForTesting){
                        getPolicyPaymentBasic(pNumStr);
                        // getPolicyBasic(pNumStr);    //get currency code
                        // Zoe updated on 0405 for performance tuning
                        
                        //Raistlin - 20191024 - GS claim
                        if(includeGSClaim){
                            getPolicyPaymentForGS(pNumStr);
                        }
                    }else{
                        //hard code for testing if WS not ready - for testing only
                        if(isHideWSForTesting || bankAccInfoList == null || bankAccInfoList.size()==0){
                            Map<String,String> tmp_nameInfoMap = new Map<String,String>{};
                            tmp_nameInfoMap.put('acctHolderName', 'Cherry Huang');
                            tmp_nameInfoMap.put('accountNumber', '888 8888-****');
                            tmp_nameInfoMap.put('bankName', 'Hang Seng Bank');
                            String tmpJSON = JSON.serialize(tmp_nameInfoMap);
                            tmp_nameInfoMap.put('json', tmpJSON);
                            bankAccInfoList.add(tmp_nameInfoMap);
                        }
                    }
                    //pNumSsnValueListMap get result Map<Map<String,String>,List<Map<String,String>>> from getPolicyPersonCoverageBasic(pNumStr, PISsn);
                    //question logic - check if IPMI / isind. / isUsPolicy
                    // system.debug('to see wPolicyList_PI：    '+wPolicyList_PI);
                    //for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_unchanged){
                    for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_PI){
                        // system.debug('to see pNumStr: '+pNumStr);
                        // system.debug('to see wPolicyItem.policyNum: '+wPolicyItem.policyNum);
                        if(wPolicyItem.policyNum.equals(pNumStr)){
                            if(wPolicyItem.isIndividualPolicy && wPolicyItem.isIPMI){
                                isAtLeastOneIPMI = true;
                            }else{
                                atLeastOneNonIPMI = true;
                            }
                            /**
                            //170317
                            if(wPolicyItem.isIPMI){
                                isAtLeastOneIPMI = true;
                            }else{
                                atLeastOneNonIPMI = true;
                            }
                            **/
                            // system.debug('to see wPolicyItem.isLessThan6Months: '+wPolicyItem.isLessThan6Months);
                            if(!wPolicyItem.isLessThan6Months){tmp_policyMoreThan6Month  = true;}
                            // system.debug('to see tmp_policyMoreThan6Month  : '+tmp_policyMoreThan6Month );
                            if(wPolicyItem.isUSDPolicy != null && wPolicyItem.isUSDPolicy){isContainUSPolicy  = true;}
                            if(wPolicyItem.isLifePolicy != null && wPolicyItem.isLifePolicy){isContainLifePolicy = true;}
                            if(wPolicyItem.isLifePolicy != null && !wPolicyItem.isLifePolicy){isContaiGIPolicy = true;} //Rancho_JOBR133_20220530 - avoid treating null as GI policy
                            if(wPolicyItem.isLifePolicy != null && wPolicyItem.isLifePolicy && wPolicyItem.isIndividualPolicy!= null && wPolicyItem.isIndividualPolicy){isContainIndividualLifePolicy = true;}
                            // system.debug('to see wPolicyItem.isIndividualPolicy: '+wPolicyItem.isIndividualPolicy);
                            // system.debug('to see isFail_sj_OP_a before: '+ isFail_sj_OP_a);
                            if(wPolicyItem.isIndividualPolicy){
                                isFail_sj_OP_a = true;    //not group policy
                                cItem.Is_Contain_Individual_Policy__c = true;
                            }else{
                                cItem.Is_Contain_Group_Policy__c = true;
                            }
                            if(pNumSsnValueListMap != null){
                                Map<String,String> tmpKeyForPolicyNumSsnMap = new Map<String,String>{};
                                tmpKeyForPolicyNumSsnMap.put(wPolicyItem.policyNum, PISsn);
                                List<Map<String,String>> tmpResultGetSumInsuredMapList = new List<Map<String,String>>{};
                                if(pNumSsnValueListMap.get(tmpKeyForPolicyNumSsnMap) != null){tmpResultGetSumInsuredMapList = pNumSsnValueListMap.get(tmpKeyForPolicyNumSsnMap);}
                                
                                //one policy may have more than 1 benefit type list
                                for(Map<String,String> tmpMapItemForList: tmpResultGetSumInsuredMapList){
                                    if(tmpMapItemForList.get('benefitAmount') != null){
                                        Decimal tmpSumInsured = 0;
                                        tmpSumInsured = Decimal.valueOf(tmpMapItemForList.get('benefitAmount'));
                                        totalSumInsured += tmpSumInsured;
                                    }
                                }
                            }
                            
                            Date tmpPaidToDate = null;
                            // system.debug('to see wPolicyItem.paidToDate: '+wPolicyItem.paidToDate);
                            if(!String.isBlank(wPolicyItem.paidToDate)){tmpPaidToDate = Date.valueOf(wPolicyItem.paidToDate);}
                            if(EarliestPaidToDate == null &&  wPolicyItem.paidToDate != null){
                                EarliestPaidToDate =  tmpPaidToDate ;
                            }else if(EarliestPaidToDate> tmpPaidToDate){EarliestPaidToDate = tmpPaidToDate;}
                            
                            //add data that get from WS but no need to use during claim process
                            // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
                            if(wPolicyItem.policyHolderName != null){cItem.Policy_Holder_Name__c= wPolicyItem.policyHolderName;}
                            String PHSsn = '';
                            PHSsn = wPolicyItem.policyHolderId;
                            if(!String.isBlank(PHSsn)){
                                cItem.Policy_Holder_ID__c= PHSsn;
                                
                                // Zoe updated on 0406 for performance tuning, will be called when submitted
                                /**
                                //get phone number and email addr from other WS
                                if(!isHideWSForTesting)    getPersonBasic(PHSsn, false);    //pAccIdInfoMap full more data after getPersonBasic call have value
                                Map<String,String> pAccIdInfoMap_getByPassSsn = new Map<String,String>{};
                                if(pAccIdInfoMap.get(PHSsn)!= null)    pAccIdInfoMap_getByPassSsn = pAccIdInfoMap.get(PHSsn);
                                if(pAccIdInfoMap_getByPassSsn !=null && pAccIdInfoMap_getByPassSsn.size()>0){
                                    String mobilePhoneNo  = pAccIdInfoMap_getByPassSsn.get('mobilePhoneNo');    //list of mobile number info
                                    String mobileCountryCode = pAccIdInfoMap_getByPassSsn.get('mobileCountryCode');
                                    String mobileAreaCode = pAccIdInfoMap_getByPassSsn.get('mobileAreaCode');
                                    String mobileTelephoneNo = pAccIdInfoMap_getByPassSsn.get('mobileTelephoneNo');
                                    String mobileNum = '';
                                    if(!String.isBlank(mobilePhoneNo)){
                                        mobileNum = mobilePhoneNo;
                                    }else{
                                        mobileNum = '+'+mobileCountryCode +' ('+mobileAreaCode+') '+mobileTelephoneNo ;
                                    }
                                    cItem.Policy_Holder_Contact_No__c = mobileNum ;
                                    if(pAccIdInfoMap_getByPassSsn.get('emailAddr') != null){
                                        cItem.Policy_Holder_Email_Address__c = pAccIdInfoMap_getByPassSsn.get('emailAddr');
                                    }
                                }
                                */
                                if(!isCustomer){
                                    // system.debug('***********Policy_Holder_ID__c ' + cItem.Policy_Holder_ID__c);
                                    if(cItem.Policy_Holder_ID__c != null && cItem.Policy_Holder_ID__c != ''){
                                        for(User u : [Select Id, Username From User Where Account.SSn__c = :cItem.Policy_Holder_ID__c]){
                                            cItem.Email_Address_to_send__c = u.Username;
                                        }
                                        // system.debug('***********Email_Address_to_send__c ' + cItem.Email_Address_to_send__c);
                                    }
                                }
                            }
                        }
                    }
                }
                if(String.isBlank(tmpPolicyListStr)){tmpPolicyListStr = pNumStr;}
                else{
                    tmpPolicyListStr += ', '+pNumStr;                
                    //more then 1 or not OP or not grp, non-fast track
                    //isFail_sj_OP_a = true;
                }
            }
            // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
            // system.debug('to see isFail_sj_OP_a final: '+isFail_sj_OP_a);
            if(!isFail_sj_OP_a && policyNumberItemList.size()==1){sj_OP_a = true;}
            else{sj_OP_a = false;}
            
            cItem.sj_OP_a__c = sj_OP_a;
            cItem.steps__c = 2;
            cItem.Policy__c = tmpPolicyListStr;
            cItem.Is_Contain_US_Policy__c = isContainUSPolicy;
            cItem.All_Non_IPMI_policy__c = !isAtLeastOneIPMI;
            cItem.All_Policy_IPMI__c = !atLeastOneNonIPMI;
            cItem.Is_Contain_Life_Policy__c = isContainLifePolicy;
            cItem.Is_Contain_GI_Policy__c = isContaiGIPolicy; //Rancho_JOBR133_20220530 - indicate if own GI policy
            cItem.Is_Contain_Individual_Life_Policy__c = isContainIndividualLifePolicy;
            

            // 20210803 - minghua - CR48, used by all user/ add defualt value hKCode
            if(incurredCountryList==null|| incurredCountryList.isEmpty()){                    
                incurredCountryList = new List<SelectOption>();                    
                incurredCountryList = masterListHandler(ClaimHelper.MASTER_TYPE_INCURRED_COUNTRY,null); 
                incurredCountryList.add(0,new SelectOption('', Label.Please_Select));
                if (!(isLoadOldClaim && String.isNotBlank(cItem.Incurred_Country_Code__c))) {
                    cItem.Incurred_Country_Code__c=String.valueOf(hKCode);
                }
            }
            if(currencyList==null || currencyList.isEmpty()){
                currencyList = new List<SelectOption>();
                currencyList = masterListHandler(ClaimHelper.MASTER_TYPE_CURRENCY,null);
                //20210803 - Kirk - CR48
                if (!(isLoadOldClaim&&String.isNotBlank(cItem.Incurred_Currency_Code__c))) {
                    cItem.Incurred_Currency_Code__c=ClaimHelper.CURRENCY_CODE_HK;
                }
                if (!(isLoadOldClaim&&String.isNotBlank(cItem.Consultation_Currency_Code__c))) {
                    cItem.Consultation_Currency_Code__c=ClaimHelper.CURRENCY_CODE_HK;
                }
            }
            
            //Nicole_20200225_GS Claim
            if(includeGSClaim){
                if(bankNameList==null || bankNameList.isEmpty()){                    
                    bankNameList = new List<SelectOption>();                   
                    bankNameList = masterListHandler(ClaimHelper.MASTER_TYPE_BANK,null);  
                    bankNameList.add(0,new SelectOption('', Label.Please_Select));             
                }

                // 20210803 - minghua - CR48, move currencyList
                // remove Incurred_Currency_Code__c, do not distinguish GS User
                // if (employeeMember!=null) {
                //     if(employeeMember.region == ClaimHelper.MEMBER_REGION_HK){
                //         cList[0].Incurred_Currency_Code__c = ClaimHelper.CURRENCY_CODE_HK;
                //     }
                //     if(employeeMember.region == ClaimHelper.MEMBER_REGION_TW){
                //         cList[0].Incurred_Currency_Code__c = ClaimHelper.CURRENCY_CODE_TW;
                //     }
                // }
                
                if(bankCountryList==null|| bankCountryList.isEmpty()){
                    bankCountryList = new List<SelectOption>();
                    bankCountryList = masterListHandler(ClaimHelper.MASTER_TYPE_COUNTRY,null);
                }
                
                /* Nicole_GS Claim UAT_20210430_isAddBCEnable = false;*/                                 
                if(policyOptions.size()>1){
                    policyOptions.add(0,new SelectOption(ClaimHelper.CLAIM_OPTION_ALL,Label.Pol_Claim_All));                
                }
                
                loadBankAccountRecordByPassingId(cId);
                if(steps==6){
                    if(bankAccountList.isEmpty() && policyOptions.size()>0){
                        Bank_Account__c bank = new Bank_Account__c(Claim__c = cId,Policy_Number__c = policyOptions[0].getValue()); 
                        if(employeeMember!=null && employeeMember.Region==ClaimHelper.MEMBER_REGION_HK){
                            bank.Is_Selected_Transfer_to_HK_Bank__c = true; 
                            isNextEnable_Bank = true;
                        }                               
                        bankAccountList.add(bank);
                    }  
                }                                                       
            }
        }
        system.debug('to see bankAccInfoList: '+bankAccInfoList);
        // system.debug('to see tmp_policyMoreThan6Month: '+tmp_policyMoreThan6Month);
        if(cList.size()>0){cList[0].Is_All_Selected_Policy_EffDate_6_month__c = !tmp_policyMoreThan6Month;}
        // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
        // system.debug('to see cList[0].PI_without_any_Sen_Code_N6__c at the END OF AddPolicyIntoClaim: ' + cList[0].PI_without_any_Sen_Code_N6__c);
    }
    
    //dummy only
    public PageReference DummyAction(){
        // system.debug('to see DummyAction start');
        // system.debug('to see cList: '+cList);
        // system.debug('to see cList[0].Is_Fast_Track__c: '+cList[0].Is_Fast_Track__c);
        // system.debug('to see cList[0].What_is_your_1st_consultation_date__c: '+cList[0].What_is_your_1st_consultation_date__c);
        // system.debug('to see wAdmittedAndDischargedFromHospitalList at saveRecord: '+wAdmittedAndDischargedFromHospitalList);
        // system.debug('to see Admitted_and_discharged_from_hospital__cat saveRecord: '+cList[0].Admitted_and_discharged_from_hospital__c);
        return null;
    }
    
    public PageReference CannotEnterBankAccountInformation(){
        // system.debug('to see CannotEnterBankAccountInformation start');
        if(cList.size()>0){
            cList[0].Cannot_Enter_Bank_Account_Information__c = true;
        }
        return null;
    }
    
    public PageReference CanEnterBankAccountInformation(){
        // system.debug('to see CanEnterBankAccountInformation start');
        if(cList.size()>0){
            cList[0].Cannot_Enter_Bank_Account_Information__c = false;
        }
        return null;
    }
    
    public void CreateClaimRecord(){
        system.debug('to see CreateClaimRecord');
        system.debug('to see cList[0].policy__c: '+cList[0].Policy__c);
        // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
        Savepoint sp = Database.setSavepoint();
        try{
            if(cList.size()==1 && cList[0].id == null){
                //assign record type normal
                Id claimNormalRecordTypeId = Schema.SObjectType.Claim__c.getRecordTypeInfosByName().get('Normal').getRecordTypeId();
                for(Claim__c cItem: cList){    //size should be one
                    cItem.recordTypeId = claimNormalRecordTypeId ;
                    if(uList.size()>0){
                        cItem.Account__c = uList[0].AccountId;    //Created From Account by login user
                    }
                    
                    if(isCustomer){cItem.Is_Created_By_Customer__c = true;}
                    else{cItem.Is_Created_By_Broker__c = true;}
                }
                
                //for test N6 case only
                if(isHideWSForTesting){cList[0].PI_without_any_Sen_Code_N6__c = true;}
                if(isCustomer){
                    cList[0].Email_Address_to_send__c = UserInfo.getUsername();   
                }
                insert cList;
                cId = cList[0].id;
                // system.debug('to see cList[0] after insert: '+cList[0]);
                // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
            }else{
                SaveRecord();
                // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
            }
            // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
        }catch(Exception ex){
            system.debug('to see Error: '+ex);
            Database.rollback(sp);
        }
    }
    
    //for edit and back to change date picker value 170309
    public void loadFirstConsultationDate(){
        // system.debug('to see loadFirstConsultationDate start');
        if(firstConsultationDateTimestamp != null && firstConsultationDateTimestamp != 0){cList[0].What_is_your_1st_consultation_date__c = DateTime.newInstance(firstConsultationDateTimestamp).date();}
    }
    
    public void loadDateToStopWorkDate(){
        // system.debug('to see loadDateToStopWorkDate start');
        if(dateToStopWorkDateTimestamp != null && dateToStopWorkDateTimestamp != 0){cList[0].Date_of_stop_working_due_to_disability__c = DateTime.newInstance(dateToStopWorkDateTimestamp).date();}
    }
    
    public void clearFirstConsultationDateTimestamp(){
        // system.debug('to see clearFirstConsultationDateTimestamp start');
        firstConsultationDateTimestamp = null;
        cList[0].What_is_your_1st_consultation_date__c = null;
        if(cList[0].id != null){
            // system.debug('to see cList[0] before update: '+cList[0]);
            //update cList;
        }
    }
    
    public void clearStopToWorkDateTimestamp(){
        // system.debug('to see clearStopToWorkDateTimestamp start');
        dateToStopWorkDateTimestamp = null;
        cList[0].Date_of_stop_working_due_to_disability__c= null;
        if(cList[0].id != null){
            // system.debug('to see cList[0] before update: '+cList[0]);
            //update cList;
        }
    }
    
    public PageReference refreshAckBrk(){
        //SaveRecord();
        // Zoe updated 0330
        // system.debug('to see refreshAckBrk start');
        if(cList.size()>0){
            for(Claim__c c : [Select Id, Is_Fast_Track__c From Claim__c Where Id = :cList[0].Id]){
                localIsFastTrack = c.Is_Fast_Track__c;
            }
        }        
        return null;
    }
    
    public PageReference refreshTCBrk(){
        // system.debug('to see refreshTCBrk start');
        SaveRecord();
        if(cList.size()>0){
            //for(Claim__c c : [Select Id, Is_PI_Greater_Then_18__c From Claim__c Where Id = :cList[0].Id]){
                //localIsPIForTC = c.Is_PI_Greater_Then_18__c; 
                // Comment by Nicole for Encryption CR
               //Added by Nicole for Encryption start
            for(Claim__c c : [Select Id, Is_Person_Insured_Claim__c,Person_Insured_Date_Of_Birth__c From Claim__c Where Id = :cList[0].Id]){
                localIsPIForTC = false;
                if(c.Person_Insured_Date_Of_Birth__c!=null){
                    localIsPIForTC = CignaUtil.isPIGreaterThan18(c.Is_Person_Insured_Claim__c, c.Person_Insured_Date_Of_Birth__c);
                }
                //Added by Nicole for Encryption end
            }

            // Rancho_JOBR133_20220530 - generate claim flow T&C When PI is PH
            generateSignatureTC();
        }
        return null;
    }
    
    /** save data for each steps **/
    public PageReference SaveRecord(){
        //Nicole_20200319_GS Claim 
        setGSClaimImformation();
        
        // system.debug('to see SaveRecord start');
        // system.debug('to see steps : '+steps);
        Savepoint sp = Database.setSavepoint();
        try{
            
            //create or update claim record
            if(cList.size()>0){
                system.debug('to see wAdmittedAndDischargedFromHospitalList at saveRecord: '+wAdmittedAndDischargedFromHospitalList);
                // system.debug('to see Admitted_and_discharged_from_hospital__cat saveRecord: '+cList[0].Admitted_and_discharged_from_hospital__c);
                system.debug('other insurance: '+cList[0].Making_other_insurance_claim__c);
                loadClaimTypeFromStr(); // Zoe 0317
                if(steps != null){
                    cList[0].steps__c = Integer.valueOf(steps);
                    if(cList[0].steps__c != null && cList[0].steps__c>=4 && !cList[0].Is_Displayed_For_Customer__c){
                        cList[0].Is_Displayed_For_Customer__c = true;
                    }
                    if(cList[0].steps__c != null && cList[0].steps__c>=7){
                        isPassQuestionPart = true;
                    }
                }
                //date
                if(firstConsultationDateTimestamp != null && firstConsultationDateTimestamp != 0){cList[0].What_is_your_1st_consultation_date__c = DateTime.newInstance(firstConsultationDateTimestamp).date();}
                if(dateToStopWorkDateTimestamp != null && dateToStopWorkDateTimestamp != 0){cList[0].Date_of_stop_working_due_to_disability__c = DateTime.newInstance(dateToStopWorkDateTimestamp).date();}
                if(wInfoFromOtherCompanyList.size()>0 || wInfoInsuredFromOtherCompanyList.size()>0){
                    cList[0].Information_from_other_companies__c = JSON.serialize(wInfoFromOtherCompanyList);
                    cList[0].Information_of_benifit_from_other_comp__c = JSON.serialize(wInfoInsuredFromOtherCompanyList);
                }
                if(wAdmittedAndDischargedFromHospitalList.size()>0){cList[0].Admitted_and_discharged_from_hospital__c= JSON.serialize(wAdmittedAndDischargedFromHospitalList);}
                if(wVisitDateStrList.size()>0){cList[0].Visit_Date__c = JSON.serialize(wVisitDateStrList);}
                
                if(String.isBlank(cList[0].Policy__c)){
                    cList[0].Policy__c = selectedPolicy;
                }
                
                if(String.isBlank(cList[0].Bank_Account_Information__c)){
                    cList[0].Cannot_Enter_Bank_Account_Information__c = false;
                }else{
                    cList[0].Cannot_Enter_Bank_Account_Information__c = true;
                }

                // Rancho_HKITSFDC115_20241105 - avoid missing bank type indicator
                if(String.isNotBlank(cList[0].Bank_Account_Number__c)){
                    cList[0].Is_Selected_Transfer_to_Oversea_Bank__c = true;
                    cList[0].Is_Selected_Transfer_to_HK_Bank__c = false;
                }else if(String.isNotBlank(cList[0].Bank_Account_Holder__c)){
                    cList[0].Is_Selected_Transfer_to_Oversea_Bank__c = false;
                    cList[0].Is_Selected_Transfer_to_HK_Bank__c = true;
                }

                // 20200221 - minghua - SPS-388
                String selectedQues = cList[0].Selected_Question_s__c;
                if(String.isNotBlank(selectedQues) && selectedQues.contains('next')){
                    if(!selectedQues.contains('q12')){
                        clearwVisitDateStrList();
                    }
                    if(!selectedQues.contains('q14')){
                        clearwInfoFromOtherCompanyList();
                    }
                    // 20210803 - minghua - CR48
                    if (selectedQues.contains('q19')&&String.isNotBlank(cList[0].What_Are_Your_Symptoms_And_Diagnosis__c)) {
                        List<String> tmpSD = cList[0].What_Are_Your_Symptoms_And_Diagnosis__c.split(',');
                        cList[0].Fast_Track_Claim__c=false;
                        for (String item : tmpSD) {
                            if (claimDesignated.get(item)) {
                                cList[0].Fast_Track_Claim__c=true;
                            }else{
                                cList[0].Fast_Track_Claim__c=false;
                                break;
                            }
                        }
                    }
                }

                if(cList[0].Is_Insured_for_Similar_Benefits__c){
                    isInsuredForSimilarBenefitsFlag = true;
                }
                
                //exist claim record
                if(cList[0].id != null){
                    // system.debug('to see cList[0] before update: '+cList[0]);
                    update cList;
                }else{
                    /**
                    do insertion at CreateClaimRecord(no longer use now) -> do insertion at SaveRecord
                    **/
                }
            }
        }catch(Exception ex){
            errorMsg = String.valueOf(ex);
            system.debug('to see error exist: '+ex);
            Database.rollback(sp);
        }
        return null;
    }
    
    //Nicole_20200319_GS Claim
    private void setGSClaimImformation(){
        Savepoint sp = null;
        try{
            if(includeGSClaim){
                system.debug('To set GS Bank Info start, steps:'+steps);
                if(steps == 7 && bankAccountList!=null && String.isBlank(cList[0].Bank_Account_Information__c)){
                    for(Bank_Account__c bank : bankAccountList){
                        if(bank.Is_Selected_Transfer_to_HK_Bank__c){
                            bank.Bank_Name__c = '';
                            for(SelectOption enOption : masterListHandler(ClaimHelper.MASTER_TYPE_BANK, 'en')){
                                if(String.IsNotBlank(bank.Bank_Code__c) && enOption.getValue().equalsIgnoreCase(bank.Bank_Code__c)){
                                    bank.Bank_Name__c = enOption.getLabel() + ';';
                                    break;
                                }
                            }
                            for(SelectOption zhOption : masterListHandler(ClaimHelper.MASTER_TYPE_BANK, 'zh')){
                                if(String.IsNotBlank(bank.Bank_Code__c) && zhOption.getValue().equalsIgnoreCase(bank.Bank_Code__c)){
                                    bank.Bank_Name__c = bank.Bank_Name__c + zhOption.getLabel();
                                    break;
                                }
                            }
                        }
                        
                        if(bank.Is_Selected_Transfer_to_Oversea_Bank__c){
                            bank.Bank_Account_Country__c = '';
                            for(SelectOption enOption : masterListHandler(ClaimHelper.MASTER_TYPE_COUNTRY, 'en')){
                                if(String.IsNotBlank(bank.Bank_Account_Country_Code__c) && enOption.getValue().equalsIgnoreCase(bank.Bank_Account_Country_Code__c)){
                                    bank.Bank_Account_Country__c = enOption.getLabel() + ';';
                                    break;
                                }
                            }
                            for(SelectOption zhOption : masterListHandler(ClaimHelper.MASTER_TYPE_COUNTRY, 'zh')){
                                if(String.IsNotBlank(bank.Bank_Account_Country_Code__c) && zhOption.getValue().equalsIgnoreCase(bank.Bank_Account_Country_Code__c)){
                                    bank.Bank_Account_Country__c = bank.Bank_Account_Country__c + zhOption.getLabel();
                                    break;
                                }
                            }
                        }
                    }                  
                    
                    sp = Database.setSavepoint();               
                    if(bankAccountList!=null && bankAccountList.size()>0){upsert bankAccountList;}
                }else if(steps == 7 && bankAccountList!=null && String.IsNotBlank(cList[0].Bank_Account_Information__c)){
                    sp = Database.setSavepoint();
                    if(bankAccountList!=null && bankAccountList.size()>0){
                        delete bankAccountList;
                        bankAccountList = new List<Bank_Account__c>();
                    }
                }
            
                if(steps == 8){
                    //Set Incurred Country Name                   
                    if(String.IsNotBlank(cList[0].Incurred_Country_Code__c)){
                        for(SelectOption enOption : masterListHandler(ClaimHelper.MASTER_TYPE_INCURRED_COUNTRY, 'en')){
                            if(enOption.getValue().equalsIgnoreCase(cList[0].Incurred_Country_Code__c)){
                                cList[0].Incurred_Country_Name__c = enOption.getLabel() + ';';
                                break;
                            }
                        }
                        for(SelectOption zhOption : masterListHandler(ClaimHelper.MASTER_TYPE_INCURRED_COUNTRY, 'zh')){
                            if(zhOption.getValue().equalsIgnoreCase(cList[0].Incurred_Country_Code__c)){
                                cList[0].Incurred_Country_Name__c = cList[0].Incurred_Country_Name__c + zhOption.getLabel();
                                break;
                            }
                        }                                                                      
                    }else{
                        cList[0].Incurred_Country_Name__c = '';
                    }
                    system.debug('To set GS Bank Info start, cList[0].Incurred_Country_Code__c:'+cList[0].Incurred_Country_Code__c);
                    system.debug('To set GS Bank Info start, cList[0].Incurred_Country_Name__c :'+cList[0].Incurred_Country_Name__c);
                    
                    //Set Incurred Currency Name                    
                    if(String.IsNotBlank(cList[0].Incurred_Currency_Code__c)){
                        for(SelectOption enOption : masterListHandler(ClaimHelper.MASTER_TYPE_CURRENCY, 'en')){
                            if(enOption.getValue().equalsIgnoreCase(cList[0].Incurred_Currency_Code__c)){
                                cList[0].Incurred_Currency_Name__c = enOption.getLabel() + ';';
                                break;
                            }
                        }
                        for(SelectOption zhOption : masterListHandler(ClaimHelper.MASTER_TYPE_CURRENCY, 'zh')){
                            if(zhOption.getValue().equalsIgnoreCase(cList[0].Incurred_Currency_Code__c)){
                                system.debug('[SetGSClaimInfo] get Chiese Currency');
                                cList[0].Incurred_Currency_Name__c = cList[0].Incurred_Currency_Name__c + zhOption.getLabel();
                                break;
                            }
                        }                                                                       
                    }else{
                        cList[0].Incurred_Currency_Name__c = '';
                    }
                    system.debug('To set GS Bank Info start, cList[0].Incurred_Currency_Code__c:'+cList[0].Incurred_Currency_Code__c);
                    system.debug('To set GS Bank Info start, cList[0].Incurred_Currency_Name__c:'+cList[0].Incurred_Currency_Name__c);
                }
            }else{
                sp = Database.setSavepoint();
                if(bankAccountList!=null && bankAccountList.size()>0){
                    delete bankAccountList;
                    bankAccountList = new List<Bank_Account__c>();
                }
            }        
        }catch(Exception ex){
            errorMsg = String.valueOf(ex);
            system.debug('to see error exist:'+ex);
            Database.rollback(sp);
        }
    }
    
    public PageReference updatePIRecord(){
        //create new claim record
        // system.debug('to see updatePIRecord start');
        CreateClaimRecord();
        getPolicyListForPI(wPolicyList_PI, wPolicyList_unchanged, cList[0].Person_s_Insured__c);
        return null;
    }
    
    public PageReference SavePIRecord(){
        //create new claim record
        // system.debug('to see SavePIRecord start');
        LoadPIToGetPlanType();
        CreateClaimRecord();
        loadData(2);
        return null;
    }
    
    public PageReference SavePolicyRecord(){
        // system.debug('to see SavePolicyRecord wPolicyList_PI: '+wPolicyList_PI);
        AddPolicyIntoClaim();
        SaveRecord();
        return null;
    }
    
    /** Attachment Action **/
    public PageReference FindUploadAttachment(){
        // system.debug('to see cList[0].sj_OP_a__c: '+cList[0].sj_OP_a__c);
        // system.debug('to see FindUploadAttachment start');
        claimUploadAttList.clear();
        // system.debug('ListAtt claimId: ' + cId);
        
        List<Attachment> lstAttrename = new List<Attachment>(); 
        List<Attachment> lstAtt = new List<Attachment>();
        failFileName = null;//PI20 jack add
        List<Attachment> zeroSizeAtt = new List<attachment>();//PI20 jack add
        if(cId!='' && cId!=null){
            String soql_attUpload = ClaimHelper.ATTACHMENT_URL_FIELD +' where parentId= :cId ';
            // system.debug('to see soql_attUpload: '+soql_attUpload);
            List<Attachment> attUploadList= Database.query(soql_attUpload);
            
            for(Attachment att: attUploadList){
                ClaimHelper.WrapperClaimUploadAttachment wItem = new ClaimHelper.WrapperClaimUploadAttachment();
                wItem.attId = att.Id;
                String tmpAttName = att.Name;
                List<String> tmpAttStrList = tmpAttName.split('_', 2);
                wItem.relatedClaimTypeDocumentId = '';
                wItem.attName = 'N/A';
                
                //upload file name in UPLOADCLAIMTYPEDOCUMENTID_FILENAME format
                if(tmpAttStrList.size()==2){
                    wItem.relatedClaimTypeDocumentId = tmpAttStrList[0];
                    wItem.attName = tmpAttStrList[1];
                }
                //PI20 jack add
                if(att.bodyLength <= 0){
                    if(failFileName == null){
                        failFileName = '';
                    }
                    failFileName = failFileName + wItem.attName + ',';
                    zeroSizeAtt.add(att);
                    continue;
                }
                wItem.parentClaimId = cId;
                wItem.attItem = att;
        
                claimUploadAttList.add(wItem);
            }
            //PI20 jack add
            if(failFileName != null && failFileName.endsWith(',')){
                failFileName = failFileName.removeEnd(',');
                delete zeroSizeAtt;
            }
            system.debug('failFileName:'+failFileName);
            //loadClaimRecordByPassingId(cId);
        }
        // system.debug('to see cList[0].sj_OP_a__c end: '+cList[0].sj_OP_a__c);
        return null;
    }
    
    /*remove attachment*/
    public PageReference RemoveUploadAttachment(){
        // system.debug('to see RemoveUploadAttachment start');
        if(removeAttId!=null && removeAttId!=''){
            List<Attachment> deleteAttList = [SELECT id FROM Attachment WHERE id=:removeAttId];
            Attachment att = new Attachment();
            att.id = removeAttId;
            Savepoint sp = Database.setSavepoint();
            if(deleteAttList !=null && deleteAttList.size()>0){
                try{
                    delete att;
                }catch(Exception ex){
                    // system.debug('to see removeAttId: '+removeAttId);
                    // system.debug('to see error: '+ex);
                    Database.rollback(sp);
                }
            }else{
                // system.debug(removeAttId + 'has been removed');
            }
            FindUploadAttachment();
        }
        return null;
    }
    /** end Attachment Action **/
    public PageReference NextStepsToSeven(){
        // system.debug('to see NextSteps steps start: '+steps);
        // system.debug('to see cList[0] at next steps: '+cList[0]);
        steps = 7;
        SaveRecord();
        loadData(steps);
        return null;
    }

    public PageReference NextStepsTo40AtAction(){
        // system.debug('to see NextSteps steps start: '+steps);
        // system.debug('to see cList[0] at next steps: '+cList[0]);
        steps = 40;
        SaveRecord();
        loadData(steps);
        return null;
    }
    
    public PageReference NextSteps(){
        system.debug('to see NextSteps steps start: '+steps);
        // system.debug('to see cList[0] at next steps: '+cList[0]);
        //AddedNicole for Encryption CR start
        if(isCustomer){
            // system.debug('steps： '+steps);
            if(steps == 7){
                // system.debug('cList.size:'+cList.size());
                if(cList.size()>0){
                    localIsPIForTC = false;
                    // system.debug('Person_Insured_Date_Of_Birth__c:'+cList[0].Person_Insured_Date_Of_Birth__c);
                    if(cList[0].Person_Insured_Date_Of_Birth__c!=null){
                        localIsPIForTC = CignaUtil.isPIGreaterThan18(cList[0].Is_Person_Insured_Claim__c, cList[0].Person_Insured_Date_Of_Birth__c);
                    }
                    // system.debug('localIsPIForTC:'+localIsPIForTC);
                }
            }
        }else{
            if(steps == 7){
                if(cList.size()>0){
                    localIsPIForTC = false;
                    if(cList[0].Person_Insured_Date_Of_Birth__c!=null){
                        localIsPIForTC = CignaUtil.isPIGreaterThan18(cList[0].Is_Person_Insured_Claim__c, cList[0].Person_Insured_Date_Of_Birth__c);
                    }
                }
            }

            if(steps == 40){
                steps = 4;
            }
        }

        // Rancho_JOBR133_20220530 - generate claim flow T&C When PI is PH
        generateSignatureTC();

        //AddedNicole for Encryption CR end
        
        if(steps <10){
            steps += 1;
            /**     
            if(steps == 6){
                Map<String,String> bankAccInfoMap = new Map<String,String>{};
                if(!(String.isBlank(cList[0].Bank_Account_Information__c) && cList[0].Is_Contain_Individual_Policy__c)){
                    // system.debug('*******Bank_Account_Information__c is not blank');
                    steps += 1;    //for select bank account info from WS
                    
                    accHolderList.clear();
                    ClaimHelper.WrapperAccountHolder tmp_accHolder = new ClaimHelper.WrapperAccountHolder();
                    accHolderList.add(tmp_accHolder);
                    wBankAccountInfoHKList.clear();
                    wBankAccountInfoOverseaList.clear();
                    
                    ClaimHelper.WrapperBankAccountInfoHK tmp_wBankAccountInfoHK = new ClaimHelper.WrapperBankAccountInfoHK();
                    wBankAccountInfoHKList.add(tmp_wBankAccountInfoHK);
                    
                    ClaimHelper.WrapperBankAccountInfoOversea tmp_wBankAccountInfoOversea = new ClaimHelper.WrapperBankAccountInfoOversea();
                    wBankAccountInfoOverseaList.add(tmp_wBankAccountInfoOversea);
                    
                }
            }
            **/
        }
        SaveRecord();
        loadData(steps);
        return null;
    }
    
    public PageReference PreviousSteps(){
        // system.debug('to see PreviousSteps steps start: '+steps);
        if(steps>1){    
            steps -= 1;
            if(steps == 6 && isCustomer){
                Map<String,String> bankAccInfoMap = new Map<String,String>{};
                /**
                if(!String.isBlank(cList[0].Bank_Account_Information__c)){
                    steps -= 1;    //for select bank account info from WS
                }
                **/
                if(!(String.isBlank(cList[0].Bank_Account_Information__c) && cList[0].Is_Contain_Individual_Policy__c)){
                    steps -= 1;    //for select bank account info from WS
                }
            }
            if(steps == 5 && !isCustomer){
                if(!cList[0].Have_All_Documents_To_Upload__c){
                    cList[0].Have_All_Documents_To_Upload__c = true;
                }
            }
            if(steps == 7 && !isCustomer){
                if(!cList[0].Selected_Question_s__c.contains('c1') || cList[0].Selected_Question_s__c.contains('skipStep7')){
                    steps -= 1;
                }
            }
            //20190624 - David Zhang - Align Claim Payment flow with CP
            if(steps == 39 && !isCustomer){
                steps = 4;
            }

            if(steps == 4 && !isCustomer && !cList[0].Cannot_Enter_Bank_Account_Information__c){
                steps = 40;
            }
            //End
            // system.debug('************steps: ' + steps);
            if(skipOneBenefitForTesting){
                if((isCustomer && steps == 4) || (!isCustomer && steps == 3)){
                    // system.debug('************onlyOneBenefitType: ' + onlyOneBenefitType);
                    if(onlyOneBenefitType != null && onlyOneBenefitType){
                        steps -=1;
                    }
                }
            }
        }
        SaveRecord();
        return null;
    }
    /** next steps action end **/
    
    public void refreshSearch(){
        // system.debug('to see refreshSearch start');
        isLoadSearchComp = true;
    }
    
    /** common method **/  
    public void getPolicyListForPI(List<ClaimHelper.WrapperPolicy> wPolicyList_PI,List<ClaimHelper.WrapperPolicy> wPolicyList_unchanged,String ssn){
        // system.debug('to see getPolicyListForPI start');
        wPolicyList_PI.clear();
        for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_unchanged){
            for(Map<String,String> tmpMap: wPolicyItem.PIMapList){
                String ssnNumber = '';
                ssnNumber = tmpMap.get('ssnNumber');
                ssnNumber = ssnNumber.trim();
                if(ssnNumber.equals(ssn) && !String.isBlank(ssn)){
                    wPolicyList_PI.add(wPolicyItem);
                    break;
                }
            }
        }
    }

    public void loadSelectedWrapperPolicyList(List<ClaimHelper.WrapperPolicy> wPolicyList_PI,List<ClaimHelper.WrapperPolicy> wPolicyList_unchanged,String ssn){
        // system.debug('to see loadSelectedWrapperPolicyList start');
        wPolicyList_PI.clear();
        //wPolicyList_PI - add selected pi to list
        //wPolicyList_unchanged -  original list
        // system.debug('to see pass ssn at loadSelectedWrapperPolicyList start: ' + ssn);
        // system.debug('to see pNumSsnValueListMap at loadSelectedWrapperPolicyList: '+pNumSsnValueListMap);
        //get plan code rate scale for mapping first
        Map<String,String> planCodeRateScaleMap = new Map<String,String>{};
        List<Map<String,String>> productCodePlanCodeRateScaleMapList = new List<Map<String,String>>{};
        selectedPolicyBenefitTypeStr = '';
        selectedPolicyClaimTypeStr = '';
        isSME=false;//Rancho_ReviseDescription_20210319    
        for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_unchanged){
            String pNum_tmp = '';
            pNum_tmp = wPolicyItem.policyNum;
            pNum_tmp = pNum_tmp.trim();
            //Rancho_ReviseDescription_20210319
            // wPolicyItem.pItem_grp.productCode='SME2021';
            if(wPolicyItem.pItem_grp!=null&&wPolicyItem.pItem_grp.productCode!=null&&isSME==false&&wPolicyItem.pItem_grp.productCode=='SME2021'){
                isSME=true;
            }
            System.debug('isSME:'+isSME);
            system.debug('SK0428 policyNum =' + wPolicyItem.policyNum); //IBM KOU TEMP
            // system.debug('SK0428 status =' + wPolicyItem.status); //IBM KOU TEMP
            // system.debug('SK0428 planTypeCode =' + wPolicyItem.planTypeCode); //IBM KOU TEMP            
            system.debug('SK0428 productCode =' + wPolicyItem.productCode); //IBM KOU TEMP
            
            //get plan code rate scale for mapping first
            // system.debug('to see each wPolicyItem: '+wPolicyItem);
            //if(wPolicyItem.planTypeCodeStr !=null && wPolicyItem.PIMapList.size()>0){
            if(wPolicyItem.PIMapList.size()>0 && !String.isBlank(pNum_tmp)){
                for(Map<String,String> tmpMap: wPolicyItem.PIMapList){
                    //fullName / ssnNumber
                    String fullName = '';
                    String ssnNumber = '';
                    fullName = tmpMap.get('fullName');
                    ssnNumber = tmpMap.get('ssnNumber');
                    fullName = fullName.trim();
                    ssnNumber = ssnNumber.trim();
                    
                    if(ssnNumber.equals(ssn) && !String.isBlank(ssn)){
                        // system.debug('to see pNumSsnValueListMap: '+pNumSsnValueListMap);    //getPolicyPersonCoverageBasic(wPolicyItem.policyNum, ssn);   
                        Map<String,String> tmpKeyMap = new Map<String,String>{};
                        tmpKeyMap.put(pNum_tmp, ssn);
                        // system.debug('to see tmpKeyMap: '+tmpKeyMap);
                        List<Map<String,String>> tmpValueMapList = new List<Map<String,String>>{};
                        if(pNumSsnValueListMap.get(tmpKeyMap)!=null){tmpValueMapList = pNumSsnValueListMap.get(tmpKeyMap);}    //result - List< Map<String,String>> - benefit map list
                        
                        // system.debug('to see tmpValueMapList: '+tmpValueMapList);
                        for(Map<String,String> tmpValueMap: tmpValueMapList){
                            planCodeRateScaleMap.put(tmpValueMap.get('benefitCode'), tmpValueMap.get('rateScale'));
                            //create tmp map to save at list, include product code
                            Map<String,String> tmpProductCodePlanCodeRateScaleMap = new Map<String,String>{};
                            tmpProductCodePlanCodeRateScaleMap.put('benefitCode', tmpValueMap.get('benefitCode'));
                            tmpProductCodePlanCodeRateScaleMap.put('rateScale', tmpValueMap.get('rateScale'));
                            tmpProductCodePlanCodeRateScaleMap.put('productCode', tmpValueMap.get('productCode'));
                            productCodePlanCodeRateScaleMapList.add(tmpProductCodePlanCodeRateScaleMap);
                        }
                    }
                }
            }
        }
        // system.debug('to see planCodeRateScaleMap: '+planCodeRateScaleMap);
        // system.debug('to see productCodePlanCodeRateScaleMapList: '+productCodePlanCodeRateScaleMapList);
        
        Map<Map<String,String>,Map<String,String>> tmpResultMap = new Map<Map<String,String>,Map<String,String>>{};
        //get Total And Permanent Disability / Broker PAC / product code / plan code / rate scale / IPMI / Fast Track Allow for mapping first
        if(planCodeRateScaleMap.size()>0){tmpResultMap = searchAllClaimTypesByPlanCode(productCodePlanCodeRateScaleMapList);}
        // system.debug('to see tmpResultMap: '+tmpResultMap);
        // end get plan code rate scale for mapping first
        if(tmpResultMap != null && tmpResultMap.size()>0){
            for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_unchanged){
                if(wPolicyItem.PIMapList.size()>0){
                    Map<String,String> mappingResultStrMap = new Map<String,String>{};
                    //tmp map to save all benefit type list under same policy
                    Map<String,String> tmpBenefitInfoMap = new Map<String,String>{};
                    //init tmpBenefitInfoMap
                    tmpBenefitInfoMap.put('benefitTypeListStr', '[]');
                    tmpBenefitInfoMap.put('claimTypeListStr', '[]');
                    tmpBenefitInfoMap.put('isFastTrackAllow', null);
                    tmpBenefitInfoMap.put('isIPMI', null);
                            
                    //each policy may have multiple benefit with different benefit code / rate scale - e.g. package - get info from getPolicyPersonCoverageBasic
                    for(Map<String,String> tmpMap: wPolicyItem.PIMapList){
                        if(tmpMap.get('ssnNumber') == ssn && !String.isBlank(ssn) && !String.isBlank(wPolicyItem.policyNum)){
                            Map<String,String> tmpKeyMap = new Map<String,String>{};    // policy number / ssn
                            // system.debug('to see pNumSsnValueListMap at line 1058 of loadSelectedWrapperPolicyList: '+pNumSsnValueListMap);
                            tmpKeyMap.put(wPolicyItem.policyNum, ssn);
                            List<Map<String,String>> tmpValueMapList = new List<Map<String,String>>{};
                            if(pNumSsnValueListMap.size()>0 && pNumSsnValueListMap.get(tmpKeyMap) != null){tmpValueMapList = pNumSsnValueListMap.get(tmpKeyMap);}    //result - List< Map<String,String>> - benefit map list
                            
                            // system.debug('to see tmpValueMapList: '+tmpValueMapList);
                            if(tmpValueMapList.size()>0){
                                for(Map<String,String> tmpValueMap: tmpValueMapList){    //({benefitAmount=100, benefitCode=TEST, effectiveDate=5/1/2017, rateScale=1})
                                    
                                    //get result benefitAmount/ benefitCode / rateScale / effectiveDate from tmpValueMap
                                    //tmpResultMap - get data from planCodeRateScaleMap
                                    Map<String,String> tmpKeyValueUseForValueMap = new Map<String,String>{};
                                    String benefitCode = null;
                                    if(!String.isBlank(tmpValueMap.get('benefitCode'))){benefitCode = tmpValueMap.get('benefitCode');}
                                    //String rateScale = ''; 
                                    String rateScale = null;     //e.g.{1900=null}
                                    if(!String.isBlank(tmpValueMap.get('rateScale'))){rateScale = tmpValueMap.get('rateScale');}
                                    
                                    if(!String.isBlank(benefitCode)){tmpKeyValueUseForValueMap.put(benefitCode,rateScale);}
                                    Map<String,String> tmpMappingResultStrMap = new Map<String,String>{};    //for each benefit code under policy mapping result
                                    // system.debug('to see tmpKeyValueUseForValueMap: '+tmpKeyValueUseForValueMap);
                                    tmpMappingResultStrMap = tmpResultMap.get(tmpKeyValueUseForValueMap);    //get mapping result by each benefit code and rate scale - from tmpKeyValueUseForValueMap
                                    // system.debug('to see tmpMappingResultStrMap: '+tmpMappingResultStrMap);
                                    
                                    //add value to tmpBenefitInfoMap for each benefit type code under same policy
                                    String tmpBenefitTypeListStr = '[]';    //e.g. HIF
                                    String tmpClaimTypeListStr = '[]';    //e.g. A, B
                                    String tmpIsFastTrackAllow = null;    //'1' mean true, null means false
                                    String tmpIsIPMI = null;    //'1' mean true, null means false
                    
                                    // system.debug('to see tmpMappingResultStrMap: '+tmpMappingResultStrMap);
                                    if(tmpMappingResultStrMap!=null){
                                        if(tmpMappingResultStrMap.get('benefitTypeListStr') != null){tmpBenefitTypeListStr = tmpMappingResultStrMap.get('benefitTypeListStr');}
                                        if(tmpMappingResultStrMap.get('claimTypeListStr') != null){tmpClaimTypeListStr = tmpMappingResultStrMap.get('claimTypeListStr');}
                                        if(tmpMappingResultStrMap.get('isFastTrackAllow') != null){tmpIsFastTrackAllow = tmpMappingResultStrMap.get('isFastTrackAllow');}
                                        if(tmpMappingResultStrMap.get('isIPMI') != null){tmpIsIPMI = tmpMappingResultStrMap.get('isIPMI');}
                                    }
                                    if(!String.isBlank(tmpBenefitTypeListStr)){    //e.g. '['HIF','CI']'
                                        // original one         
                                        String tmpResultAtTmpBenefitInfoMap_benefitTypeListStr = '[]';
                                        if(tmpBenefitInfoMap.get('benefitTypeListStr') != null){tmpResultAtTmpBenefitInfoMap_benefitTypeListStr = tmpBenefitInfoMap.get('benefitTypeListStr');}
                                        //new one
                                        Set <String> strSet_orginial = new Set <String>{};
                                        strSet_orginial = transformListStrToSet(tmpResultAtTmpBenefitInfoMap_benefitTypeListStr);    //set of original benefit type str
                                        Set <String> strSet_new = new Set <String>{};
                                        strSet_new = transformListStrToSet(tmpBenefitTypeListStr);
                                        strSet_orginial.addAll(strSet_new);    //group all result together
                                        // system.debug('to see strSet_orginial before: '+strSet_orginial);
                                        tmpResultAtTmpBenefitInfoMap_benefitTypeListStr = transformSetToListStr(strSet_orginial);    //set of String to Str
                                        tmpBenefitInfoMap.put('benefitTypeListStr', tmpResultAtTmpBenefitInfoMap_benefitTypeListStr);
                                        // system.debug('to see new tmpBenefitInfoMap for tmpBenefitTypeListStr change: '+tmpBenefitInfoMap);
                                    }
                                    
                                    if(!String.isBlank(tmpClaimTypeListStr)){    //e.g. '['A','B']'
                                        String tmpResultAtTmpBenefitInfoMap_claimTypeListStr = '[]';
                                        if(tmpBenefitInfoMap.get('claimTypeListStr') != null)    tmpResultAtTmpBenefitInfoMap_claimTypeListStr = tmpBenefitInfoMap.get('claimTypeListStr');
                                        Set <String> strSet_orginial = new Set <String>{};
                                        strSet_orginial = transformListStrToSet(tmpResultAtTmpBenefitInfoMap_claimTypeListStr);
                                        Set <String> strSet_new = new Set <String>{};
                                        strSet_new = transformListStrToSet(tmpClaimTypeListStr);
                                        strSet_orginial.addAll(strSet_new);    //group all result together
                                        tmpResultAtTmpBenefitInfoMap_claimTypeListStr = transformSetToListStr(strSet_orginial);    //set of String to Str
                                        tmpBenefitInfoMap.put('claimTypeListStr', tmpResultAtTmpBenefitInfoMap_claimTypeListStr);
                                        // system.debug('to see new tmpBenefitInfoMap for claimTypeListStr change: '+tmpBenefitInfoMap);
                                    }
                                    if(!String.isBlank(tmpIsFastTrackAllow)){    //e.g. '1' / null
                                        String tmpResultAtTmpBenefitInfoMap_isFastTrackAllow = null;
                                        if(tmpBenefitInfoMap.get('isFastTrackAllow') != null)    tmpResultAtTmpBenefitInfoMap_isFastTrackAllow = tmpBenefitInfoMap.get('isFastTrackAllow');
                                        //working
                                        tmpBenefitInfoMap.put('isFastTrackAllow', tmpResultAtTmpBenefitInfoMap_isFastTrackAllow);
                                        // system.debug('to see new tmpBenefitInfoMap for isFastTrackAllow change: '+tmpBenefitInfoMap);
                                    }
                                    if(!String.isBlank(tmpIsIPMI)){    //e.g. '1' / null
                                        tmpBenefitInfoMap.put('isIPMI', '1');
                                        // system.debug('to see new tmpBenefitInfoMap for isIPMI change: '+tmpBenefitInfoMap);
                                    }
                                }
                            }
                        }    
                    }
                    mappingResultStrMap = tmpBenefitInfoMap;
                    // system.debug('to see mappingResultStrMap after: '+mappingResultStrMap);
                    
                    if(mappingResultStrMap != null){
                        wPolicyItem.benefitTypeListStr = mappingResultStrMap.get('benefitTypeListStr');
                        wPolicyItem.claimTypeListStr = mappingResultStrMap.get('claimTypeListStr');
                        if(mappingResultStrMap.get('isFastTrackAllow')!= null){wPolicyItem.isFastTrackAllow = true;}
                        else{wPolicyItem.isFastTrackAllow = false;}
                        if(mappingResultStrMap.get('isIPMI')!= null){wPolicyItem.isIPMI = true;}
                        else{wPolicyItem.isIPMI = false;}
                        
                        //if(wPolicyItem.claimTypeListStr != null && wPolicyItem.claimTypeListStr != ''){
                        if(wPolicyItem.claimTypeListStr != null && wPolicyItem.claimTypeListStr != ''
                           && String.isNotBlank(selectedPolicy) && selectedPolicy.contains(wPolicyItem.policyNum)){ // to filter unselected policy
                            String ss = wPolicyItem.claimTypeListStr;
                            //ss = wPolicyItem.claimTypeListStr.replace(']', '');
                            if(selectedPolicyClaimTypeStr == null || selectedPolicyClaimTypeStr == ''){
                                selectedPolicyClaimTypeStr = wPolicyItem.policyNum + ':' + ss;
                            }else if(selectedPolicyBenefitTypeStr.indexOf(wPolicyItem.policyNum) == -1){ // to filter duplicate selected policy
                                selectedPolicyClaimTypeStr = selectedPolicyClaimTypeStr + ';' + wPolicyItem.policyNum + ':' + ss;
                            }
                        }
                        // system.debug('to see selectedPolicyBenefitTypeStr 00: '+selectedPolicyBenefitTypeStr);

                        //if(wPolicyItem.benefitTypeListStr != null && wPolicyItem.benefitTypeListStr != ''){ 
                        if(wPolicyItem.benefitTypeListStr != null && wPolicyItem.benefitTypeListStr != ''
                          && String.isNotBlank(selectedPolicy) && selectedPolicy.contains(wPolicyItem.policyNum)){ // to filter unselected policy
                            String bss = wPolicyItem.benefitTypeListStr;
                            //bss = wPolicyItem.benefitTypeListStr.replace(']', '');
                            if(selectedPolicyBenefitTypeStr ==  null || selectedPolicyBenefitTypeStr == ''){
                                selectedPolicyBenefitTypeStr = wPolicyItem.policyNum + ':' + bss;
                                // system.debug('to see selectedPolicyBenefitTypeStr 1 : '+selectedPolicyBenefitTypeStr);
                            }else if(selectedPolicyBenefitTypeStr.indexOf(wPolicyItem.policyNum) == -1){ // to filter duplicate selected policy
                                selectedPolicyBenefitTypeStr = selectedPolicyBenefitTypeStr + ';' + wPolicyItem.policyNum + ':' + bss;
                                // system.debug('to see selectedPolicyBenefitTypeStr 2 : '+selectedPolicyBenefitTypeStr);
                            }
                        }
                        system.debug('to see selectedPolicyClaimTypeStr: ' + selectedPolicyClaimTypeStr);
                        system.debug('to see selectedPolicyBenefitTypeStr: ' + selectedPolicyBenefitTypeStr);
                    }
                    // system.debug('to see wPolicyItem.PIMapList: ' + wPolicyItem.PIMapList);
                    for(Map<String,String> tmpMap: wPolicyItem.PIMapList){
                        //fullName / ssnNumber
                        String ssnNumber = '';
                        ssnNumber = tmpMap.get('ssnNumber');
                        ssnNumber = ssnNumber.trim();
                        if(ssnNumber.equals(ssn) && !String.isBlank(ssn)){
                            wPolicyList_PI.add(wPolicyItem);
                            break;
                        }
                    }
                }
            }
        }
        // system.debug('to see wPolicyList_PI: '+wPolicyList_PI);
            if(wPolicyList_PI!=null){
                if(wPolicyList_PI.size()>0){
                    hasNoPolicyPI = false;
                }else{
                    hasNoPolicyPI = true;
                }
            } 
    }

    public Set<String> transformListStrToSet(String resultListStr){    //e.g. '['HIF','CI', 'HIF']' -> {'HIF','CI'}
        // system.debug('to see transformListStrToSet start');
        Set <String> returnStrSet = new Set <String>{}; 
        String tmpUseStr = resultListStr.removeStart('[');
        tmpUseStr = tmpUseStr.removeEnd(']');
        List<String> tmpStrList = new List<String>{};
        if(!String.isBlank(tmpUseStr))    tmpStrList = tmpUseStr.split(',');
        for(String tmpStrItem: tmpStrList){
            if(!String.isBlank(tmpStrItem)){
                // system.debug('to see tmpStrItem:'+tmpStrItem);
                tmpStrItem = tmpStrItem.trim();
                // system.debug('to see tmpStrItem:'+tmpStrItem);
                String tmpStrWithoutApostropheStr = tmpStrItem.substring(1,tmpStrItem.length()-1);
                // system.debug('to see tmpStrWithoutApostropheStr: '+tmpStrWithoutApostropheStr);
                returnStrSet.add(tmpStrWithoutApostropheStr);    
                
            }
        }
        return returnStrSet;
    }
    
    public String transformSetToListStr(Set<String> resultStrSet){    //{'HIF','CI'} ->'['HIF','CI']'
        // system.debug('to see transformSetToListStr start');
        String returnStr = null; 
        if(resultStrSet.size()>0){
            //loop in Set of String
            returnStr = '[';
            Integer i = 0;
            for(String StrItem: resultStrSet){
                if(!String.isBlank(StrItem)){
                    if(i == 0){returnStr += '\''+StrItem+'\'';}
                    else if(i>0){returnStr += ', \''+StrItem+'\'';}
                    i++;
                }
            }
            returnStr += ']';
        }else{
            returnStr = '[]';
        }
        return returnStr;
    }
    
    public PageReference SubmitClaimRequest(){
        // system.debug('to see SubmitClaimRequest start');
        //add Bob 20201218 CM User
        if(CignaUtil.isCMLoginAsUser()){
            CignaUtil.stopSubmittionforCMUser();
            return null;
        }
        if(cList.size()>0 && cList[0].id != null){
            /**
            cList[0].steps__c = 11;
            cList[0].Status__c = 'Processing';
            cList[0].Submission_Date__c = System.today();
            
            Savepoint sp = Database.setSavepoint();
            try{
                update cList;
            }catch(Exception ex){
                // system.debug('to see error at SubmitClaimRequestFromEmail: '+ex);
                Database.rollback(sp);
            }
            */
            // TO DO 0714: fix submission date
            // minghua - 20220523 - file virus scan
            // SubmitClaimRequestFromEmail(cList[0].id);
            scanPopup=false;
            if (OpswatWebService.checkScanStatus(cList[0].id)) {
                System.debug('File virus scan done.');
                // will check the scan result
                if (!OpswatWebService.checkScanResult(cList[0].id)) {
                    // popup message remind the submitter the specific files are removed and ask if they want to proceed 
                    scanPopup=true;
                    System.debug('File virus scan done, has a virus');
                }
            }else{
                scanPopup=true;
                System.debug('File virus scan not done. will display success message');
            }
            SubmitClaimRequestFromEmail(cList[0].id,scanPopup);
        }
        return null;
    }
    
    //submit claim to server
    // minghua - 20220523 - file virus scan
    // public static void SubmitClaimRequestFromEmail(Id cId){
    public static void SubmitClaimRequestFromEmail(Id cId, Boolean scanFlag){
        // system.debug('to see SubmitClaimRequestFromEmail start');
        if(!String.isBlank(cId)){
            String soql_cId = ClaimHelper.CLAIM_ALL_FIELD;
            soql_cId += ' where id=\''+cId+'\'';
            List<Claim__c> cList_submit = Database.query(soql_cId);
                
            if(cList_submit.size()==1){
                //Nicole_20200324_GS Claim
                Boolean includeGSClaim = false;
                MemberManagementHelper gsMemberHelper = new MemberManagementHelper();
                String userSsn = '';
                for(User u: [select Id, UserName, name, ContactId, LanguageLocaleKey, AccountId, Account.SSN__c, Profile.Name from User where Id = :UserInfo.getUserId() limit 1]){                
                    if(u.Account.SSN__c != null){userSsn= u.Account.SSN__c;}    //user ssn
                }
                
                List<String> policyList = new List<String>();
                if(!String.isBlank(cList_submit[0].Policy__c)){
                    List<String> tmpPolicyNumList = cList_submit[0].Policy__c.split(',');
                    for(String tmpPolicyNumItem: tmpPolicyNumList){
                        String tmpPolicyNumItemAfterTrim = tmpPolicyNumItem.trim();
                        policyList.add(tmpPolicyNumItemAfterTrim); 
                        if(gsMemberHelper.isGSUser(userSsn,tmpPolicyNumItemAfterTrim)){includeGSClaim = true;}
                    }
                }
                
                Boolean toShareFolder = true;
                PolicyCalloutHelper pHelper = new PolicyCalloutHelper();
                for(String policyNo : policyList){
                    HttpCalloutVO.Policy p = pHelper.getPolicyBasic(policyNo);
                    if(IPMISettingUtil.isIPMIPolicy(p)){
                        toShareFolder = false;
                    }
                    if(IPMISettingUtil.isIPMITopUpPolicy(p) || IPMISettingUtil.isGAOPPolicy(p) || IPMISettingUtil.isLHBPolicy(p)){
                        toShareFolder = IPMISettingUtil.isClaimsSendToShareFolder(p);
                    }
                    //VHIS - David Zhang - 0319
                    if(p.productCode != null && (p.productCode.trim().equalsIgnoreCase('VSTDG') || p.productCode.trim().equalsIgnoreCase('VSMMG') || p.productCode.trim().equalsIgnoreCase('VSUPG'))){
                        toShareFolder = true;
                    }
                    if(toShareFolder){break;}
                }
                
                cList_submit[0].steps__c = 11;
                cList_submit[0].Status__c = 'Processing';
                cList_submit[0].Submission_Date__c = System.today();
                //working
                cList_submit[0].Is_Chosen_Sign_On_Screen__c = true;    //for sign on screen and no need to sign case
                cList_submit[0].Is_Chosen_Send_Esignature__c = false;
                cList_submit[0].Caller_Platform__c = 'Web'; //JOBR-375 GOP claim in analyst report
                Savepoint sp = Database.setSavepoint();
                try{
                    update cList_submit;
                }catch(Exception ex){
                    // system.debug('to see error at SubmitClaimRequestFromEmail: '+ex);
                    Database.rollback(sp);
                }
                
                // Zoe updated on 0508 for queue
                List<String> attIdList = new List<String>();
                String firstPolicyNo = '';
                if(cList_submit[0].Policy__c != null && cList_submit[0].Policy__c != ''){
                    String[] pNoList = cList_submit[0].Policy__c.split(',');
                    pNoList.sort();
                    firstPolicyNo = pNoList[0];
                }
                //generate PDF and save as attachment
                PageReference thePage = Page.ExportSubmitClaimPDFVFP;
                thePage.getParameters().put('id', cId);
                // system.debug('to see submission date: '+cList_submit[0].Submission_Date__c);
                                
                //for test class
                blob tmpBody;
                if(!test.isRunningTest()){
                    tmpBody = thePage.getContent();
                }else{
                    tmpBody = blob.valueof('TEST');
                }
                blob body = tmpBody;
                
                Attachment att= new attachment();
                // att.name= cId+'_'+system.now()+'.pdf';
                att.name = firstPolicyNo + '-CF.pdf';
                att.body = body;
                //add content type to avoid judge content type is null validation
                att.contentType = 'application/pdf';
                att.ParentId = cId;
                att.isPrivate = false;
                insert att;
                //claim form is created
                attIdList.add(att.Id);
                
                //rename uploaded attachments
                Integer attCount = 1;
                //List<Attachment> attListToRename = [select Id, Name, Body, BodyLength  //Comment by Manuel, remove the Body attribute to avoid files size limitation
                List<Attachment> attListToRename = [select Id, Name, BodyLength From Attachment Where ParentId =:cId And (Not Name Like :cId + '%') And (Not Name Like '%esignature%') And (Not Name Like '%-CF.pdf')];
                                                                     
                for(Attachment a : attListToRename){
                    // ---- confirmed format for attachment
                    String tmpExtension = '';
                    String tmpName = '';
                    // system.debug('*************original file name: ' + a.Name);
                    if(a.Name != null && a.Name != ''){
                        String[] tmpNameArray = a.Name.split('\\.');
                        // system.debug('*************tmpNameArray : ' + tmpNameArray);
                        tmpExtension = '.' + tmpNameArray[tmpNameArray.size() - 1];
                    }
                    // system.debug('*************tmpExtension : ' + tmpExtension);
                    if(attCount < 10){
                        tmpName = firstPolicyNo + '-0' + String.valueOf(attCount);
                    }else{
                        tmpName = firstPolicyNo + '-' + String.valueOf(attCount);
                    }
                    
                    if(tmpName != ''){
                        a.Name = tmpName + tmpExtension;
                    }
                    attCount++;
                    attIdList.add(a.Id);
                }
                if(attListToRename != null && !attListToRename.isEmpty()){
                    update attListToRename;
                }
                //add by minghua for claim submitClaim - 20190718
                // //QHMS
                // if(!String.isBlank(ClaimHelper.EMAIL_ADDRESS_QHMS)){
                //     //if(cList_submit[0].All_Policy_IPMI__c){
                //     if(!toShareFolder){
                //         // system.debug('to see cList_submit[0].All_Non_IPMI_policy__c: '+cList_submit[0].All_Non_IPMI_policy__c);
                //         // system.debug('to see cList_submit[0].All_Policy_IPMI__c : '+cList_submit[0].All_Policy_IPMI__c);
                //         //toSendClaimFormEmail(cList_submit[0].id, ClaimHelper.EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong');
                //         if(!test.isrunningtest()){
                //             //System.enqueueJob(new SubmitClaimQueue(cList_submit[0].id, attIdList, ClaimHelper.EMAIL_ADDRESS_QHMS, 1, attIdList.size(), null, true, false));
                //             System.enqueueJob(new SubmitClaimQueue(cList_submit[0].id, attIdList, ClaimHelper.EMAIL_ADDRESS_QHMS, 1, attIdList.size(), null, true, false, cList_submit[0].Name, cList_submit[0].Certificate_Number__c));
                //             //Add by Manuel on Sep 28 that supplement claim number for submit claim request 
                //         }
                //     }
                // }
                //add by minghua for claim submitClaim - 20190718
                if(!toShareFolder && cList_submit[0].RecordType.developerName == 'Pre_Admission'){
                    //QHMSforGOP
                    if(!test.isrunningtest()){
                        // minghua - 20220523 - file virus scan
                        // System.enqueueJob(new SubmitClaimQueue(cList_submit[0].id, attIdList, ClaimHelper.EMAIL_ADDRESS_QHMS, 1, attIdList.size(), null, true, false, cList_submit[0].Name, cList_submit[0].Certificate_Number__c));
                        SubmitClaimQueue subQueue=new SubmitClaimQueue(cId, attIdList, ClaimHelper.EMAIL_ADDRESS_QHMS, 1, attIdList.size(), null, true, false, cList_submit[0].Name, cList_submit[0].Certificate_Number__c);
                        if (scanFlag) {
                            System.enqueueJob(new GetScandeatils(cId,'',CignaUtil.isCustomerPortal(),subQueue,false));
                        }else{
                            System.enqueueJob(subQueue);
                        }
                    }
                }else{
                    /*Nicole_GS Claim UAT_20210430if(includeGSClaim && !Test.isRunningTest()){
                        System.enqueueJob(new SubmitClaimQueue(cId, attIdList, true, false, true, policyList ));
                    }else if(!includeGSClaim && !Test.isRunningTest()){
                        submitClaimWithAllAttachments(cId);
                    }*/
                    // minghua - 20220523 - file virus scan
                    // submitClaimWithAllAttachments(cId,includeGSClaim); //Nicole_GS Claim UAT_20210430
                    if (scanFlag) {
                        System.enqueueJob(new GetScandeatils(cId,'',CignaUtil.isCustomerPortal(),null,includeGSClaim));
                    }else{
                        submitClaimWithAllAttachments(cId,includeGSClaim);
                    }
                }

                //if(!cList_submit[0].All_Policy_IPMI__c){
                //add by minghua for claim submitClaim - 20190718
                // if(toShareFolder){
                //     // toSendClaimFormToServer(cList_submit[0].id,policyList,cList_submit[0].Is_Created_By_Broker__c);
                //     // update: the indicator is for group policy claim, not broker initiated - 0418 by Zoe
                //     //toSendClaimFormToServer(cList_submit[0].id,policyList,cList_submit[0].Is_Contain_Group_Policy__c);
                //     if(!test.isRunningTest()){
                //         //System.enqueueJob(new SubmitClaimQueue(cList_submit[0].id, attIdList, null, null, null, cList_submit[0].Is_Contain_Group_Policy__c, false, true));
                //         System.enqueueJob(new SubmitClaimQueue(cList_submit[0].id, attIdList, null, 1, attIdList.size(), cList_submit[0].Is_Contain_Group_Policy__c, false, true, cList_submit[0].Name, cList_submit[0].Certificate_Number__c));
                //         //Add by Manuel on Sep 28 that supplement claim number for submit claim request 
                //     }
                // }
            }  
            
            //20191224 - Terry - Signature Require  
            List<E_Signature_Request__c> signatureReq = [SELECT id, name, E_Signature_URL__c, Request_Type__c, Claim__c FROM E_Signature_Request__c WHERE Claim__c=:cId AND Completed__c=False];    
            if(signatureReq != null && signatureReq.size()> 0){    
                for(E_Signature_Request__c signReq : signatureReq){ 
                    signReq.Completed__c=True;  
                }   
                update signatureReq;    
            } 
        }
    }
    
    //add by minghua for claim submitClaim - 20190618
    @future(callout=true)
    public static void submitClaimWithAllAttachments(Id cId, Boolean includeGSClaim){
        if(String.isNotBlank(cId)){
            String soql_cId = ClaimHelper.CLAIM_ALL_FIELD;
            soql_cId += ' where id=\''+cId+'\'';
            List<Claim__c> cList_submit = Database.query(soql_cId);
            // system.debug('cList_submit:'+cList_submit);
            if(cList_submit!=null && cList_submit.size()==1){
                Claim__c claim = cList_submit[0];
                HttpCalloutVO.ClaimApplication claimApp = new HttpCalloutVO.ClaimApplication();
                claimApp.hasReferralLetter = false;
                claimApp.claimNumber = claim.Name;
                if(claim.Submission_Date__c != null){
                    claimApp.submissionDate = formatDate(claim.Submission_Date__c);
                }
                if(claim.Is_Created_By_Customer__c){
                    claimApp.source = 'CUSTOMER_PORTAL';
                }else{
                    claimApp.source = 'BROKER_PORTAL';
                }

                claimApp.policyList = new List<HttpCalloutVO.Policy>();
                PolicyCalloutHelper pHelper = new PolicyCalloutHelper();
                if(String.isNotBlank(claim.Policy__c)){
                    List<String> tmpPolicyNumList = claim.Policy__c.split(',');
                    for(String tmpPolicyNumItem : tmpPolicyNumList){
                        String policyNo = tmpPolicyNumItem.trim();
                        if(String.isNotBlank(policyNo)){
                            HttpCalloutVO.Policy p = pHelper.getPolicyBasic(policyNo);
                            if(p != null){
                                // Rancho_PI81_20221107 - comment to pass all cert no
                                // if(String.isBlank(p.memberCertNo)){
                                //     p.memberCertNo = claim.Certificate_Number__c;
                                // }
                                if(p.isIndividual == null){
                                    p.isIndividual = claim.Is_Contain_Individual_Policy__c;
                                }
                                if(String.isBlank(p.holderName)){
                                    p.holderName = claim.Policy_Holder_Name__c;
                                }
                                
                                // <CompanyCode>    Party3->OrgCode
                                // <BrokerName>     Party2->FullName
                                // <BrokerCode>     Party2->CompanyProducerID
                                // <BrokerContactNum>   Party2->DialNumber
                                HttpCalloutVO.Person party = p.broker;
                                if(party != null){
                                    p.brokerContactPerson = party.fullName; //BrokerName
                                    p.brokerCode = party.brokerAgentCode;   //BrokerCode
                                    //BrokerContactNum
                                    if(String.isNotBlank(party.businessPhoneNo)){
                                        p.brokerContactNo = party.businessPhoneNo;
                                    }else if(String.isNotBlank(party.homePhoneNo)){
                                        p.brokerContactNo = party.homePhoneNo;
                                    }else if(String.isNotBlank(party.businessFaxNo)){
                                        p.brokerContactNo = party.businessFaxNo;
                                    }else if(String.isNotBlank(party.mobilePhoneNo)){
                                        p.brokerContactNo = party.mobilePhoneNo;
                                    }else if(String.isNotBlank(party.homeFaxNo)){
                                        p.brokerContactNo = party.homeFaxNo;
                                    }

                                    if(party.organization != null){
                                        HttpCalloutVO.Person orgParty = party.organization;
                                        p.brokerCompany = orgParty.orgCode;  //CompanyCode
                                    }
                                }

                                // Rancho_PI81_20221107 - pass all cert no in different policy node
                                if(String.isBlank(p.memberCertNo) && !p.isIndividual && String.isNotBlank(claim.Certificate_Number__c)){
                                    List<String> tempAllCertNoList = claim.Certificate_Number__c.split(';');
                                    for(Integer i=0; i<tempAllCertNoList.size(); i++){
                                        if(i==0){
                                            p.memberCertNo = tempAllCertNoList[i];
                                        }else{
                                            System.debug('cert no: '+i+' '+tempAllCertNoList[i]);
                                            HttpCalloutVO.Policy newPol = p.clone();
                                            newPol.memberCertNo = tempAllCertNoList[i];
                                            claimApp.policyList.add(newPol);
                                        }
                                    }
                                }
                                claimApp.policyList.add(p);
                            }
                        }
                    }
                }
                
                if(String.isNotBlank(claim.Type_of_benefit_to_claim__c)){
                    List<String> tmpClaimTypeList = claim.Type_of_benefit_to_claim__c.split(';');
                    if(tmpClaimTypeList != null && tmpClaimTypeList.size()> 0){
                        List<String> tmp_conditionList = new List<String>{};
                        String query_condition_on_portal = '';
                        String query_condition = '';

                        claimApp.claimTypeList = new List<HttpCalloutVO.ClaimType>();
                        Map<String,String> typeCode = new Map<String,String>{};
                        // HI(7, "HI"), HPA(8, "HPA"), HIF(9,"HIF"), HS(10, "HS"), OP(11, "OP"), MAT(12, "MAT"), 
                        // DIS(13, "DIS"), CI(14, "CI"), WL(15,"WL"),MIS(16, "MIS"), SD(17, "SD"), WP(18, "WP"), 
                        // TTD(19,"TTD"), ACC(20,"ACC"), OTH(21, "OTH")
                        typeCode.put('HI', '7');
                        typeCode.put('HPA', '8');
                        typeCode.put('HIF', '9');
                        typeCode.put('HS', '10');
                        typeCode.put('OP', '11');
                        typeCode.put('MAT', '12');
                        typeCode.put('DIS', '13');
                        typeCode.put('CI', '14'); //HKITSFDC-412 Emanuel rollback
                        typeCode.put('WL', '15');
                        typeCode.put('MIS', '16');
                        typeCode.put('SD', '17');
                        typeCode.put('WP', '18');
                        typeCode.put('TTD', '19');
                        typeCode.put('ACC', '20');
                        typeCode.put('OTH', '21');
                        typeCode.put('OPF', '22');
                            
                        for(String typeStr : tmpClaimTypeList){
                            HttpCalloutVO.ClaimType claimTyp = new HttpCalloutVO.ClaimType();
                            claimTyp.claimType = typeStr;
                            claimTyp.claimTypeCode = typeCode.get(typeStr);
                            claimApp.claimTypeList.add(claimTyp);
                            if(typeStr == 'HIF'){tmp_conditionList.add('HIF__c');}  
                            if(typeStr == 'HI'){tmp_conditionList.add('HI__c');}
                            if(typeStr == 'HPA'){tmp_conditionList.add('HPA__c');}
                            if(typeStr == 'HS'){tmp_conditionList.add('HS__c');}
                            if(typeStr == 'DIS'){tmp_conditionList.add('DIS__c');}
                            if(typeStr == 'MAT'){tmp_conditionList.add('MAT__c');}
                            if(typeStr == 'CI'){tmp_conditionList.add('CI__c');}
                            if(typeStr == 'OP'){tmp_conditionList.add('OP__c');}
                            if(typeStr == 'OPF'){tmp_conditionList.add('OPF__c');}
                            if(typeStr == 'WL'){tmp_conditionList.add('WL__c');}
                        }

                        if(tmp_conditionList.size()> 0){
                            for(String condition_str: tmp_conditionList){
                                if(String.isBlank(query_condition)){
                                    query_condition = ' '+condition_str+'=true ';
                                }else{
                                    query_condition += ' or '+condition_str+'=true ';
                                }   
                            }
                            if(claim.Is_Created_By_Customer__c){
                                query_condition_on_portal = 'Is_Customer__c = true';
                            }else{
                                query_condition_on_portal = 'Is_Broker__c = true';
                            }
                            String soql = 'select id, Document_Name__c from Claim_Type_Document__c where Active__c = true '; 
                            if(String.isNotBlank(query_condition_on_portal)){
                                soql += ' and ' + query_condition_on_portal;
                            }
                            if(String.isNotBlank(query_condition)){
                                soql += ' and ('+query_condition+') ';
                            }
                            soql += ' and Document_Name__c like \'%referral letter%\'';
                            List<Claim_Type_Document__c> claimTDList = Database.query(soql);
                            // system.debug('claimTDList:'+claimTDList);
                            if(claimTDList!=null && claimTDList.size()> 0){
                                claimApp.hasReferralLetter = true;
                            }
                        }
                    }
                }
                HttpCalloutVO.Claimant claimant = new HttpCalloutVO.Claimant();
                claimant.fullName = claim.Person_Insured_Name__c;
                claimant.ssnNumber = claim.Person_s_Insured__c;
                if(claim.Person_Insured_Date_Of_Birth__c != null){
                    claimant.birthDate = formatDate(claim.Person_Insured_Date_Of_Birth__c);
                }
                claimApp.claimant = claimant;

                // ----------- Claim Form -------------
                // 20200225-minghua-SPS398 judge selected question is not null
                String selectedQue = claim.Selected_Question_s__c;
                if(String.isNotBlank(selectedQue)){
                    if(selectedQue.contains('q1')){
                        claimApp.hasAdmission = claim.Do_you_stay_in_hospital__c;
                    }
                    if(selectedQue.contains('q2')){
                       claimApp.hasRoomCharge = claim.Is_there_any_room_charge__c;
                    }
                    if(selectedQue.contains('q3') && String.isNotBlank(claim.Admitted_and_discharged_from_hospital__c)){
                        claimApp.hospitalStayList = new List<HttpCalloutVO.HospitalStay>();
                        List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital> visitIP = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(claim.Admitted_and_discharged_from_hospital__c , List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
                        if(visitIP!=null && visitIP.size()>0){
                            for(ClaimHelper.WrapperAdmittedAndDischargedFromHospital  waddfhospital : visitIP){
                                HttpCalloutVO.HospitalStay hospitalStay = new HttpCalloutVO.HospitalStay();
                                if(waddfhospital.admissionDate!= null){
                                    hospitalStay.admissionDateTime = formatDate(waddfhospital.admissionDate);
                                }
                                if(waddfhospital.dischargeDate!=null){
                                    hospitalStay.dischargeDateTime = formatDate(waddfhospital.dischargeDate);
                                }
                                if(waddfhospital.admissionDate!= null || waddfhospital.dischargeDate!=null){
                                    claimApp.hospitalStayList.add(hospitalStay);
                                }
                            }
                        }
                    }
                    
                    if(selectedQue.contains('q4') && claim.What_is_your_1st_consultation_date__c!=null){
                        claimApp.firstConsultationDate = formatDate(claim.What_is_your_1st_consultation_date__c);
                    }
                    if(selectedQue.contains('q5')){
                        claimApp.doctorName = claim.What_is_the_hospital_doctor_name__c;
                        claimApp.hospitalName = claim.What_is_the_hospital_doctor_name__c;
                    }
                    if(selectedQue.contains('q6')){
                        claimApp.doctorContactNo = claim.What_is_the_phone_of_hospital_doctor__c;
                        claimApp.hospitalContactNo = claim.What_is_the_phone_of_hospital_doctor__c;
                    }
                    if(selectedQue.contains('q7')){
                        claimApp.clearicalJobPercentage = claim.What_is_of_work_allocation_Clerical__c;
                        claimApp.manualJobPercentage = claim.What_is_of_work_allocation_Manual__c;
                    }
                    if(selectedQue.contains('q8') && claim.Date_of_stop_working_due_to_disability__c != null){
                        claimApp.sickLeaveStartDate = formatDate(claim.Date_of_stop_working_due_to_disability__c);
                    }
                    if(selectedQue.contains('q9')){
                        claimApp.isOnSickLeave = claim.Still_on_sick_leave__c;
                    }
                    if(selectedQue.contains('q10') && String.isNotBlank(claim.Selected_Type_Of_Doctor__c)){
                        if(claim.Selected_Type_Of_Doctor__c.containsIgnoreCase('specialist')){
                            claimApp.isSpecialist = true;
                        }else{
                            claimApp.isSpecialist = false;
                        }
                        claimApp.benefitTypeList = new List<String>();
                        List<String> tmpBenefitTypeList = claim.Selected_Type_Of_Doctor__c.split(',');
                        if(tmpBenefitTypeList != null && tmpBenefitTypeList.size() > 0){
                            claimApp.benefitTypeList = tmpBenefitTypeList;
                        }
                    }
                    
                    if(selectedQue.contains('q11')){
                        claimApp.totalAmount = String.valueOf(claim.Please_input_the_amount_of_charge_HKD__c);
                        // 20210803 - minghua - CR48, remove GS condition
                        if(String.IsNotBlank(claim.Incurred_Currency_Code__c)){
                            claimApp.incurredCurrency = claim.Incurred_Currency_Code__c;
                        }
                    }
                    if(selectedQue.contains('q12') && String.isNotBlank(claim.Visit_Date__c)){
                        claimApp.opConsultationDateList = new List<String>();
                        List<ClaimHelper.WrapperVisit> visit = (List<ClaimHelper.WrapperVisit>)JSON.deserialize(claim.Visit_Date__c , List<ClaimHelper.WrapperVisit>.class);
                        for(ClaimHelper.WrapperVisit wvisut : visit){
                            if(wvisut.visitDate != null){
                                claimApp.opConsultationDateList.add(formatDate(wvisut.visitDate));
                            }
                        }
                    }

                    // 20210803 - minghua - CR48
                    if (claim.Is_Created_By_Customer__c) {
                        if(selectedQue.contains('q13')){
                            claimApp.hasOtherInsurancePolicy = claim.Receive_reimbursement_from_other_comp__c;
                        }
                        if(selectedQue.contains('q14') && claimApp.hasOtherInsurancePolicy){ // when q13 is true, will display q14
                            if(String.IsNotBlank(claim.Information_from_other_companies__c)){  
                                List<ClaimHelper.WrapperInfoFromOtherCompany> other = (List<ClaimHelper.WrapperInfoFromOtherCompany>)JSON.deserialize(claim.Information_from_other_companies__c ,List<ClaimHelper.WrapperInfoFromOtherCompany>.class);
                                if(other!=null && other.size()>0){
                                    claimApp.otherInsurerPolicy = new List<HttpCalloutVO.OtherInsurer>();
                                    for(ClaimHelper.WrapperInfoFromOtherCompany c : other){
                                        HttpCalloutVO.OtherInsurer o = new HttpCalloutVO.OtherInsurer();
                                        o.name = c.nameOfInsurer;
                                        o.policyNo = c.policyNum;
                                        claimApp.otherInsurerPolicy.add(o);
                                    }
                                }
                            }           
                        }
                        if(selectedQue.contains('q15')){
                            if(String.IsNotBlank(claim.Incurred_Country_Code__c)){                                                  
                                claimApp.incurredCountry=claim.Incurred_Country_Code__c;
                            }           
                        }
                        if(selectedQue.contains('q17')){
                            if(claim.Ask_If_Include_Separate_Medication__c!=null){                                                  
                                claimApp.inSepMedicCharge=claim.Ask_If_Include_Separate_Medication__c;
                            }           
                        }
                        if(selectedQue.contains('q18')){
                            if (claim.Please_input_the_amount_of_charge_Con__c>0&&claim.Please_input_the_amount_of_charge_Med__c>0) {
                                claimApp.consulAmount=String.valueOf(claim.Please_input_the_amount_of_charge_Con__c);
                                claimApp.incurredCurrency = claim.Consultation_Currency_Code__c;
                                claimApp.medicAmount=String.valueOf(claim.Please_input_the_amount_of_charge_Med__c);
                            }
                            if (claim.Please_input_the_amount_of_charge_Oth__c>0) {
                                claimApp.otherAmount=String.valueOf(claim.Please_input_the_amount_of_charge_Oth__c);
                            }
                        }
                        if(selectedQue.contains('q19')&&String.isNotBlank(claim.What_Are_Your_Symptoms_And_Diagnosis__c)){
                            claimApp.diagnosis=claim.What_Are_Your_Symptoms_And_Diagnosis__c.split(',');
                            claimApp.isFastTrackClaim=claim.Fast_Track_Claim__c;
                        }
                        // Rancho_CR48_20210706
                        if(selectedQue.contains('q20')&&claim.Is_Public_Hospital__c!=null){
                            claimApp.isPublicHospital=claim.Is_Public_Hospital__c;
                        }
                    }
                }
                
                // 20210803 - minghua - CR48
                if (!claim.Is_Created_By_Customer__c) {
                    //if(selectedQue.contains('q13')){
                    //Nicole_20200129_Broker Portal UAT-Missed Other Insurence Issue
                        claimApp.hasOtherInsurancePolicy = claim.Receive_reimbursement_from_other_comp__c;
                        if(claimApp.hasOtherInsurancePolicy && !String.isBlank(claim.Information_from_other_companies__c)){
                            List<ClaimHelper.WrapperInfoFromOtherCompany> other = (List<ClaimHelper.WrapperInfoFromOtherCompany>)JSON.deserialize(claim.Information_from_other_companies__c ,List<ClaimHelper.WrapperInfoFromOtherCompany>.class);
                            if(other!=null && other.size()>0){
                                claimApp.otherInsurerPolicy = new List<HttpCalloutVO.OtherInsurer>();
                                for(ClaimHelper.WrapperInfoFromOtherCompany c : other){
                                    HttpCalloutVO.OtherInsurer o = new HttpCalloutVO.OtherInsurer();
                                    o.name = c.nameOfInsurer;
                                    o.policyNo = c.policyNum;
                                    claimApp.otherInsurerPolicy.add(o);
                                }
                            }
                        }
                    //}
                }
                
                claimApp.bankAccount = new HttpCalloutVO.BankAccount();
                
                // 20201214 - minghua - PI-16:Portal submitted a LHB Claim with bank account information
                // 20210430 - Nicole_GS Claim UAT - GS Claim may have only LHB policy, but still need to pass bank account
                //if(claim.Is_Contain_Group_Policy__c && !claim.Is_Contain_Individual_Policy__c){
                 if(claim.Is_Contain_Group_Policy__c && !claim.Is_Contain_Individual_Policy__c&&!includeGSClaim){
                }else{
                    //Nicole_GS Claim UAT_20210430
                    if(includeGSClaim){
                        List<Bank_Account__c> bList = new List<Bank_Account__c>();
                        if(String.IsNotBlank(claim.Id)){
                            String soql = ClaimHelper.BANK_ACCOUNT_ALL_FIELD;
                            soql += ' where Claim__c =\''+claim.Id+'\'';
                            bList = Database.query(soql);
                        }
                        if(bList!=null && bList.size()>0){
                            Bank_Account__c bank = bList[0];
                            if(bank.Is_Selected_Transfer_to_HK_Bank__c && String.IsNotBlank(bank.Bank_Account_No__c)){
                                claimApp.bankAccount.type = 'HkAccount';
                                claimApp.bankAccount.acctHolderName = bank.Account_Holder__c;
                                claimApp.bankAccount.bankCode = bank.Bank_Code__c;
                                claimApp.bankAccount.branchCode = bank.Branch_Code__c;
                                claimApp.bankAccount.accountNumber = bank.Bank_Account_No__c;
                            }
                            if(bank.Is_Selected_Transfer_to_Oversea_Bank__c && String.IsNotBlank(bank.Bank_Account_No__c)){
                                claimApp.bankAccount.type = 'Telegraphic';
                                claimApp.bankAccount.acctHolderName = bank.Account_Holder__c;
                                //claimApp.bankAccount.bankAccountCountry = bank.Bank_Account_Country_Code__c;
                                if(String.IsNotBlank(bank.Bank_Account_Country__c)){                                                  
                                    claimApp.bankAccount.bankAccountCountry = bank.Bank_Account_Country__c.split(';').size()>0?bank.Bank_Account_Country__c.split(';').get(0):'';
                                }
                                claimApp.bankAccount.bankName = bank.Bank_Name__c;
                                claimApp.bankAccount.bankCode = bank.Bank_Code__c;
                                claimApp.bankAccount.accountNumber = bank.Bank_Account_No__c;
                                claimApp.bankAccount.swiftCode = bank.SWIFT_Code__c;
                            }
                        }else if (String.isNotBlank(claim.Bank_Account_Information__c)){
                            claimApp.bankAccount = new HttpCalloutVO.BankAccount();
                            claimApp.bankAccount.type = 'DdaAccount';
                        }
                    }else{
                        if(claim.Is_Selected_Transfer_to_HK_Bank__c){
                            claimApp.bankAccount.type = 'HkAccount';
                            claimApp.bankAccount.acctHolderName = claim.Bank_Account_Holder__c;
                            claimApp.bankAccount.bankName = claim.Bank_Name__c;
                            claimApp.bankAccount.bankCode = claim.Bank_Code__c;
                            claimApp.bankAccount.branchCode = claim.Bank_Branch_Code__c;
                            claimApp.bankAccount.accountNumber = claim.Bank_Account_Name__c;
                        }else if(claim.Is_Selected_Transfer_to_Oversea_Bank__c){
                            claimApp.bankAccount.type = 'Telegraphic';
                            claimApp.bankAccount.accountNumber = claim.Bank_Account_Number__c;
                            //Nicole_20200210_Customer Portal UAT-Swift Code Missing Issue
                            //claimApp.bankAccount.bankCode = claim.Bank_SWIFT__c;
                            claimApp.bankAccount.swiftCode = claim.Bank_SWIFT__c;
                            claimApp.bankAccount.routingCode = claim.Bank_Routing_Code_ABA__c;
                            claimApp.bankAccount.branchAddress = claim.Bank_Branch_Address__c;
                        }else if(String.isNotBlank(claim.Bank_Account_Information__c) && !claim.Is_Selected_Transfer_to_Oversea_Bank__c && !claim.Is_Selected_Transfer_to_HK_Bank__c){
                            claimApp.bankAccount.type = 'DdaAccount';
                        }
                    }
                }
                
                if(String.isNotBlank(claim.Payment_Currency__c)){
                    claimApp.paymentCurrency = claim.Payment_Currency__c;
                }else{
                    claimApp.paymentCurrency = 'HKD';
                }
                claimApp.attachmentList = new List<HttpCalloutVO.Attachment>();
                List<Attachment> attListToSend = [select Id, Name, BodyLength From Attachment Where ParentId =:cId And (Not Name Like :cId + '%') And (Not Name Like '%esignature%') order by Name asc];
                                                                     
                Integer k = 1;
                if(attListToSend != null && attListToSend.size()> 0){
                    claimApp.numOfAttachment =attListToSend.size();
                    for(Attachment attToSend: attListToSend){
                        HttpCalloutVO.Attachment att = new HttpCalloutVO.Attachment();
                        att.fileName = attToSend.Name;
                        att.seqNo = String.valueOf(k);
                        att.salesforceAttachmentId = attToSend.Id;
                        claimApp.attachmentList.add(att);
                        k++;
                    }
                }
                // system.debug('ClaimApplication:'+claimApp);
                if(!Test.isRunningTest()){  //Nicole_GS Claim_20210430
                    ClaimCalloutHelper helper = new ClaimCalloutHelper();
                    helper.submitClaim(claimApp);
                    if(helper.getResultInfo().isSuccess){
                        MyClaimSubmitController.sendNotification(cId);
                    } 
                }
            }
        }
    }

    //add by minghua for claim submitClaim - 20190618
    public Static String formatDate(Date d){
        return String.valueOf(d.year()) + '-' + String.valueOf(d.month()).leftPad(2, '0') + '-' + String.valueOf(d.day()).leftPad(2, '0');
    }

    public void searchAllDocumentsByClaimType(String benefitTypeStr){
        // system.debug('to see searchAllDocumentsByClaimType benefitTypeStr start: '+benefitTypeStr);
        //query all upload and download document from db by condition
        
        List<String> benefitTypeList = new List<String>{};
        if(!String.isBlank(benefitTypeStr)){benefitTypeList = benefitTypeStr.split(';');}
        List<String> tmp_conditionList = new List<String>{};
        String query_condition_on_portal = '';
        String query_condition = '';
        //CLAIM_TYPE_DOCUMENT_ALL_FIELD
        // system.debug('to see benefitTypeStr: '+benefitTypeStr);
        for(String benefitTypeItem : benefitTypeList){
            if(benefitTypeItem == 'HIF'){tmp_conditionList.add('HIF__c');}
            if(benefitTypeItem == 'HI'){tmp_conditionList.add('HI__c');}
            if(benefitTypeItem == 'HPA'){tmp_conditionList.add('HPA__c');}
            if(benefitTypeItem == 'HS'){tmp_conditionList.add('HS__c');}
            if(benefitTypeItem == 'DIS'){tmp_conditionList.add('DIS__c');}
            if(benefitTypeItem == 'MAT'){tmp_conditionList.add('MAT__c');}
            if((benefitTypeItem == 'CI' || benefitTypeItem == 'WP')){tmp_conditionList.add('CI__c');} //HKITSFDC-412 Show CI Doc when WP is selected
            if(benefitTypeItem == 'OP'){tmp_conditionList.add('OP__c');}
            if(benefitTypeItem == 'OPF'){tmp_conditionList.add('OPF__c');}
            //Added by minglei 2018.05.15 [add Wellness type to claim] start
            if(benefitTypeItem == 'WL'){tmp_conditionList.add('WL__c');}
            //Added by minglei 2018.05.15 [add Wellness type to claim] end
        }
        
        claimTypeDocumentList.clear();
        if(tmp_conditionList.size()> 0){
            for(String condition_str: tmp_conditionList){
                if(String.isBlank(query_condition)){query_condition = ' '+condition_str+'=true ';}
                else{query_condition += ' or '+condition_str+'=true ';}
            }
            if(isCustomer){query_condition_on_portal = 'Is_Customer__c = true';}
            else{query_condition_on_portal = 'Is_Broker__c = true';}
            String soql = ClaimHelper.CLAIM_TYPE_DOCUMENT_ALL_FIELD;
            if(!String.isBlank(query_condition)){soql += ' where Active__c = true and ' + query_condition_on_portal + ' and ('+query_condition+') ';}
            claimTypeDocumentList = Database.query(soql);
        }
    }
    
    public Map<Map<String,String>,Map<String,String>> searchAllClaimTypesByPlanCode(List<Map<String,String>> productCodePlanCodeRateScaleMapList){
        // system.debug('to see searchAllClaimTypesByPlanCode productCodePlanCodeRateScaleMapList  start: '+productCodePlanCodeRateScaleMapList);
        /** planCodeplanScaleMap: key is plancode; value is scales **/
        Map<Map<String,String>,Map<String,String>> returnMap = new Map<Map<String,String>,Map<String,String>>{};
        String tmp_soql_condition = '';
        
        for(Map<String,String> tmpProductCodePlanCodeRateScaleMap: productCodePlanCodeRateScaleMapList){
            String tmpProductCode = '';
            String tmpBenefitCode = '';
            String tmpRateScale = '';
            if(tmpProductCodePlanCodeRateScaleMap.get('productCode') != null){tmpProductCode = tmpProductCodePlanCodeRateScaleMap.get('productCode');}
            if(tmpProductCodePlanCodeRateScaleMap.get('benefitCode') != null){tmpBenefitCode = tmpProductCodePlanCodeRateScaleMap.get('benefitCode');}
            if(tmpProductCodePlanCodeRateScaleMap.get('rateScale') != null){tmpRateScale = tmpProductCodePlanCodeRateScaleMap.get('rateScale');}
            // system.debug('SK0430 tmpProductCode=' + tmpProductCode); //IBM KOU TEMP
            // system.debug('SK0430 tmpBenefitCode=' + tmpBenefitCode); //IBM KOU TEMP
            // system.debug('SK0430 tmpRateScale=' + tmpRateScale); //IBM KOU TEMP  
            // 20211216 - minghua - JOBR-67, Performance Tuning, comment invalid condition
            // ((system__c=\'S6\' and Product_Code__c=\''+tmpProductCode +'\' and Plan_code__c =\''+tmpBenefitCode +'\' and Rate_Scale__c =\''+tmpRateScale +'\') or 
            // (( system__c=\'S6\' and Product_Code__c=\''+tmpProductCode +'\' and Plan_code__c =\''+tmpBenefitCode +'\' and Rate_Scale__c =\''+tmpRateScale +'\') or 
            if(String.isBlank(tmp_soql_condition)){tmp_soql_condition += ' (Plan_code__c =\''+tmpBenefitCode +'\' and Rate_Scale__c =\''+tmpRateScale +'\')';}
            else{tmp_soql_condition += ' or (Plan_code__c =\''+tmpBenefitCode +'\' and Rate_Scale__c =\''+tmpRateScale +'\') ';}
        }
        // system.debug('to see tmp_soql_condition: '+tmp_soql_condition);
        planCodeClaimTypeList = new List<Plan_Code_Claim_Type__c>{};
        String soql = ClaimHelper.PLAN_CODE_CLAIM_TYPE_ALL_FIELD;

        isEntitledBenefit=false; // 20210803 - minghua - CR48
        allowGovernmentHospitalVisit=false; // Rancho_CR48_20210706
        if(!String.isBlank(tmp_soql_condition)){
            soql += ' where '+tmp_soql_condition;
            // system.debug('SK0713 soql=' + soql);
            planCodeClaimTypeList = Database.query(soql);
        }

        // system.debug('SK0430 planCodeClaimTypeList=' + planCodeClaimTypeList); //IBM KOU TEMP
        for(Plan_Code_Claim_Type__c pCodeClaimType: planCodeClaimTypeList){
            System.debug('pCodeClaimType:'+pCodeClaimType);
            Map<String,String> tmpKeyMap = new Map<String,String>{};     //key
            Map<String,String> tmpValueMap = new Map<String,String>{};     //value
            String tmpPlanCode = pCodeClaimType.Plan_code__c;
            String tmpRateScale = pCodeClaimType.Rate_Scale__c;
            tmpKeyMap.put(tmpPlanCode, tmpRateScale);
            
            List<String> tmpBenefitTypeStrList = new List<String>{};
            List<String> tmpClaimTypeStrList = new List<String>{};
            String str_benefitType = '';
            String str_claimType = '';
            if(pCodeClaimType.ACC__c){tmpBenefitTypeStrList.add('ACC');}
            if(pCodeClaimType.CI__c){tmpBenefitTypeStrList.add('CI');}
            //Added by minglei 2018.05.15 [add Wellness type to claim] start
            if(pCodeClaimType.WL__c){tmpBenefitTypeStrList.add('WL');}
            //Added by minglei 2018.05.15 [add Wellness type to claim] end
            if(pCodeClaimType.DIS__c){tmpBenefitTypeStrList.add('DIS');}
            if(pCodeClaimType.HI__c){tmpBenefitTypeStrList.add('HI');}
            if(pCodeClaimType.HIF__c){tmpBenefitTypeStrList.add('HIF');}
            if(pCodeClaimType.HPA__c){tmpBenefitTypeStrList.add('HPA');}
            if(pCodeClaimType.HS__c){tmpBenefitTypeStrList.add('HS');}
            if(pCodeClaimType.MAT__c){tmpBenefitTypeStrList.add('MAT');}
            if(pCodeClaimType.MIS__c){tmpBenefitTypeStrList.add('MIS');}
            if(pCodeClaimType.OP__c && !pCodeClaimType.Fast_Track_Allow__c){tmpBenefitTypeStrList.add('OP');}
            if(pCodeClaimType.OTH__c){tmpBenefitTypeStrList.add('OTH');}
            if(pCodeClaimType.SD__c){tmpBenefitTypeStrList.add('SD');}
            if(pCodeClaimType.TTD__c){tmpBenefitTypeStrList.add('TTD');}
            if(pCodeClaimType.WP__c){tmpBenefitTypeStrList.add('WP');}
            if(pCodeClaimType.Broker_PAC__c){tmpBenefitTypeStrList.add('BrokerPAC');}
            if(pCodeClaimType.IPMI__c){tmpBenefitTypeStrList.add('IPMI');}
            if(pCodeClaimType.Wonder_Woman__c){tmpBenefitTypeStrList.add('WonderWoman');}  //IBM KOU Wonder Woman CR 20180430
            //OPF
            if(pCodeClaimType.OP__c && pCodeClaimType.Fast_Track_Allow__c){tmpBenefitTypeStrList.add('OPF');}
            if(pCodeClaimType.A_General_Practitioner__c){tmpClaimTypeStrList.add('A');}
            if(pCodeClaimType.B_Specialist_Practitioner__c){tmpClaimTypeStrList.add('B');}
            if(pCodeClaimType.C_Laboratory_Testing_X_Ray__c){tmpClaimTypeStrList.add('C');}
            if(pCodeClaimType.D_Chinese_Herbalist_Bonesetter_Acupunc__c){tmpClaimTypeStrList.add('D');}
            if(pCodeClaimType.E_Physiotherapy_Chiropractic__c){tmpClaimTypeStrList.add('E');}
            if(pCodeClaimType.F_Long_Term_Prescribed_Medicine__c){tmpClaimTypeStrList.add('F');}
            if(pCodeClaimType.G_Medical_Check_Up_Vaccination__c){tmpClaimTypeStrList.add('G');}
            if(pCodeClaimType.H_Dental__c){tmpClaimTypeStrList.add('H');}
            if(pCodeClaimType.I_Others__c){tmpClaimTypeStrList.add('I');}
            //Added by minglei 2018.05.15 [add Wellness type to claim] start
            if(pCodeClaimType.J_Wellness__c){tmpClaimTypeStrList.add('J');}
            //Added by minglei 2018.05.15 [add Wellness type to claim] end
            //20210803 - Kirk - CR48  [add benefit type to claim] start
            if(pCodeClaimType.K_Physiotherapy__c){tmpClaimTypeStrList.add('K');}
            if(pCodeClaimType.L_Dentist__c){tmpClaimTypeStrList.add('L');}
            if(pCodeClaimType.M_Speech_Therapy__c){tmpClaimTypeStrList.add('M');}
            if(pCodeClaimType.N_Occupational_Therapy__c){tmpClaimTypeStrList.add('N');}
            if(pCodeClaimType.O_Dietetic_Guidance__c){tmpClaimTypeStrList.add('O');}
            if(pCodeClaimType.P_Prescribed_Western_Medicine_pharmacy__c){tmpClaimTypeStrList.add('P');}
            if(pCodeClaimType.Q_Diagnostic_Imaging_Laboratory_Test__c){tmpClaimTypeStrList.add('Q');}
            if(pCodeClaimType.R_Health_Check_Up__c){tmpClaimTypeStrList.add('R');}
            if(pCodeClaimType.S_Vaccination__c){tmpClaimTypeStrList.add('S');}
            //if(pCodeClaimType.T_Tui_Na__c){tmpClaimTypeStrList.add('T');}  //20210803 - Kirk - CR48 - 20210917 - Kirk - T_Tui_Na__c removed
            if(pCodeClaimType.Is_Entitled__c){
                // Rancho_CR48_20210706: if plan code is LMDO, selected policy should be ESF policy, then isEntitledBenefit is true
                if(pCodeClaimType.Plan_Code__c != 'LMDO' || (pCodeClaimType.Plan_Code__c == 'LMDO' && checkESFPolicy(selectedPolicy))){
                    isEntitledBenefit=true;
                }
            }
            System.debug('isEntitledBenefit:'+isEntitledBenefit);
            if(pCodeClaimType.Allow_Government_Hospital_Visit__c){allowGovernmentHospitalVisit=true;} // Rancho_CR48_20210706
            if(pCodeClaimType.Covid_19_Benefit__c){isCovid19=true;} // Rancho_Covid19_20221019 - set value
            //20210803 - Kirk - CR48  [add benefit type to claim] end
            if(tmpBenefitTypeStrList.size()>0){
                if(tmpBenefitTypeStrList.size()==1){str_benefitType = '[\''+tmpBenefitTypeStrList[0]+'\']';}
                else{
                    str_benefitType = '[';
                        for(Integer i = 0; i <tmpBenefitTypeStrList.size()-1; i++){
                            str_benefitType += '\''+tmpBenefitTypeStrList[i]+'\', ';
                        }
                        str_benefitType += '\''+tmpBenefitTypeStrList[tmpBenefitTypeStrList.size()-1]+ '\'';
                        str_benefitType += ']';
                    }
            }else{
                str_benefitType = '[]';
            }
            
            if(tmpClaimTypeStrList.size()>0){
                if(tmpClaimTypeStrList.size()==1){str_claimType = '[\''+tmpClaimTypeStrList[0]+'\']';}
                else{
                    str_claimType = '[';
                        for(Integer i = 0; i <tmpClaimTypeStrList.size()-1; i++){
                            str_claimType += '\''+tmpClaimTypeStrList[i]+'\', ';
                        }
                        str_claimType += '\''+tmpClaimTypeStrList[tmpClaimTypeStrList.size()-1]+ '\'';
                        str_claimType += ']';
                    }
            }else{
                str_claimType = '[]';
            }
            
            tmpValueMap.put('benefitTypeListStr', str_benefitType);
            tmpValueMap.put('claimTypeListStr', str_claimType);
            if(pCodeClaimType.Fast_Track_Allow__c){tmpValueMap.put('isFastTrackAllow', '1');}    //have value mean fast track allow
            if(pCodeClaimType.IPMI__c){tmpValueMap.put('isIPMI', '1');}    //have value mean fast track allow
            returnMap.put(tmpKeyMap, tmpValueMap);
        }
        return returnMap;
    }
    
    /** tmp save data **/
    public PageReference AddInfoFromOtherComp(){
        // system.debug('to see AddInfoFromOtherComp start');
        //add 1 item each time
        ClaimHelper.WrapperInfoFromOtherCompany wItem_tmp = new ClaimHelper.WrapperInfoFromOtherCompany();
        wInfoFromOtherCompanyList.add(wItem_tmp);
        return null;
    }

     public PageReference addInfoInsdFromOtherComp(){
        // system.debug('to see AddInfoFromOtherComp start');
        //add 1 item each time
        ClaimHelper.WrapperInfoFromOtherCompany wItem_tmp = new ClaimHelper.WrapperInfoFromOtherCompany();
        wInfoInsuredFromOtherCompanyList.add(wItem_tmp);
        return null;
    }
    
    public PageReference RemoveInfoFromOtherComp(){
        // system.debug('to see RemoveInfoFromOtherComp start');
        //remove 1 item each time with param
        String idx_infoFromOtherCompany = ApexPages.currentPage().getParameters().get('idx_infoFromOtherCompany'); 
        String idx_tmp = idx_infoFromOtherCompany;
        List<ClaimHelper.WrapperInfoFromOtherCompany> wInfoFromOtherCompanyList_tmp = new List<ClaimHelper.WrapperInfoFromOtherCompany>{};
        Integer i = 0;
        for(ClaimHelper.WrapperInfoFromOtherCompany tmpItem: wInfoFromOtherCompanyList){
            if(idx_tmp != null && i != Integer.valueOf(idx_tmp)){wInfoFromOtherCompanyList_tmp.add(tmpItem);}
            i++;
        }
        wInfoFromOtherCompanyList.clear();
        wInfoFromOtherCompanyList = wInfoFromOtherCompanyList_tmp;
        return null;
    }

    public PageReference RemoveInfoInsdFromOtherComp(){
        // system.debug('to see RemoveInfoFromOtherComp start');
        //remove 1 item each time with param
        String idx_infoInsdFromOtherCompany = ApexPages.currentPage().getParameters().get('idx_infoInsdFromOtherCompany'); 
        String idx_tmp = idx_infoInsdFromOtherCompany;
        List<ClaimHelper.WrapperInfoFromOtherCompany> wInfoInsuredFromOtherCompanyList_tmp = new List<ClaimHelper.WrapperInfoFromOtherCompany>{};
        Integer i = 0;
        for(ClaimHelper.WrapperInfoFromOtherCompany tmpItem: wInfoInsuredFromOtherCompanyList){
            if(idx_tmp != null && i != Integer.valueOf(idx_tmp)){wInfoInsuredFromOtherCompanyList_tmp.add(tmpItem);}
            i++;
        }
        wInfoInsuredFromOtherCompanyList.clear();
        wInfoInsuredFromOtherCompanyList = wInfoInsuredFromOtherCompanyList_tmp;
        return null;
    }
    
    public void clearwInfoFromOtherCompanyList(){
        // system.debug('to see pass clearwInfoFromOtherCompanyList');
        wInfoFromOtherCompanyList.clear();
        List<ClaimHelper.WrapperInfoFromOtherCompany> tmpWrapperList = new List<ClaimHelper.WrapperInfoFromOtherCompany>{};
        ClaimHelper.WrapperInfoFromOtherCompany wInfoFromOtherCompanyItem = new ClaimHelper.WrapperInfoFromOtherCompany();
        tmpWrapperList.add(wInfoFromOtherCompanyItem);
        wInfoFromOtherCompanyList = tmpWrapperList;
        cList[0].Information_from_other_companies__c = JSON.serialize(wInfoFromOtherCompanyList);
    }

    public void clearwInfoInsdFromOtherCompanyList(){
        // clear for question: for borker new question - Information of benifit from other company  HKITSFDC-412
        wInfoInsuredFromOtherCompanyList.clear();
        List<ClaimHelper.WrapperInfoFromOtherCompany> tmpWrapperList2 = new List<ClaimHelper.WrapperInfoFromOtherCompany>{};
        ClaimHelper.WrapperInfoFromOtherCompany wInfoInsuredFromOtherCompanyItem = new ClaimHelper.WrapperInfoFromOtherCompany();
        tmpWrapperList2.add(wInfoInsuredFromOtherCompanyItem);
        wInfoInsuredFromOtherCompanyList = tmpWrapperList2;
        cList[0].Information_of_benifit_from_other_comp__c = JSON.serialize(wInfoInsuredFromOtherCompanyList);
    }
    
    public PageReference AddAdmissionAndDischargeDate(){
        // system.debug('to see AddAdmissionAndDischargeDate start');
        //add 1 item each time
        ClaimHelper.WrapperAdmittedAndDischargedFromHospital wItem_tmp = new ClaimHelper.WrapperAdmittedAndDischargedFromHospital();
        wAdmittedAndDischargedFromHospitalList.add(wItem_tmp);
        return null;
    }
    
    public PageReference RemoveAdmissionAndDischargeDate(){
        // system.debug('to see RemoveAdmissionAndDischargeDate start');
        //remove 1 item each time with param
        String idx_admissionAndDischargeDate = ApexPages.currentPage().getParameters().get('idx_admissionAndDischargeDate'); 
        system.debug('to see idx_admissionAndDischargeDate: '+idx_admissionAndDischargeDate);
        List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital> wAdmittedAndDischargedFromHospitalList_tmp = new List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>{};
        system.debug('to see wAdmittedAndDischargedFromHospitalList: '+wAdmittedAndDischargedFromHospitalList);
        Integer i = 0;
        for(ClaimHelper.WrapperAdmittedAndDischargedFromHospital tmpItem: wAdmittedAndDischargedFromHospitalList){
            if(idx_admissionAndDischargeDate != null && i != Integer.valueOf(idx_admissionAndDischargeDate)){wAdmittedAndDischargedFromHospitalList_tmp.add(tmpItem);}
            i++;
        }
        wAdmittedAndDischargedFromHospitalList.clear();
        wAdmittedAndDischargedFromHospitalList = wAdmittedAndDischargedFromHospitalList_tmp ;
        return null;
    }
    
    public PageReference AddVisitDate(){
        // system.debug('to see AddVisitDate start');
        // system.debug('to see wVisitDateStrList size before: '+wVisitDateStrList.size());
        //add 1 item each time
        ClaimHelper.WrapperVisit tmpDate = new ClaimHelper.WrapperVisit();
        wVisitDateStrList.add(tmpDate);
        // system.debug('to see wVisitDateStrList size after: '+wVisitDateStrList.size());
        return null;
    }
    
    public PageReference RemoveVisitDate(){
        // system.debug('to see RemoveVisitDate start');
        //remove 1 item each time with param
        // system.debug('to see idx_visitDate: '+idx_visitDate);
        List<ClaimHelper.WrapperVisit> wVisitDateStrList_tmp = new List<ClaimHelper.WrapperVisit>{};
        // system.debug('to see wVisitDateStrList_tmp: '+wVisitDateStrList_tmp);
        Integer i = 0;
        for(ClaimHelper.WrapperVisit tmpItem: wVisitDateStrList){
            if(idx_visitDate != null && i != Integer.valueOf(idx_visitDate)){wVisitDateStrList_tmp.add(tmpItem);}
            i++;
        }
        wVisitDateStrList.clear();
        wVisitDateStrList = wVisitDateStrList_tmp ;
        return null;
    }
    
    /**
    public PageReference AddBankAccountInfoHK(){
        // system.debug('to see AddBankAccountInfoHK start');
        //add 1 item each time
        ClaimHelper.WrapperAccountHolder tmpInfo = new ClaimHelper.WrapperAccountHolder();
        accHolderList.add(tmpInfo);
        return null;
    }
    
    public PageReference RemoveBankAccountInfoHK(){
        // system.debug('to see RemoveBankAccountInfoHKstart');
        
        // system.debug('to see idx_bankAccountInfoHK: '+idx_bankAccountInfoHK);
        List<ClaimHelper.WrapperAccountHolder> accHolderList_tmp= new List<ClaimHelper.WrapperAccountHolder>{};
        // system.debug('to see accHolderList_tmp: '+accHolderList_tmp);
        Integer i = 1;
        
        for(ClaimHelper.WrapperAccountHolder tmpItem: accHolderList){
            //idx_bankAccountInfoHK: 1,2,3 -> 0,1,2
            if(i != Integer.valueOf(idx_bankAccountInfoHK)){accHolderList_tmp.add(tmpItem);}
            i++;
        }
        accHolderList.clear();
        accHolderList = accHolderList_tmp;
        
        return null;
    }
    **/
    
    /**
    public PageReference AddBankAccountInfoOversea(){
        // system.debug('to see AddBankAccountInfoOversea start');
        //add 1 item each time
        ClaimHelper.WrapperBankAccountInfoOversea tmpInfo = new ClaimHelper.WrapperBankAccountInfoOversea();
        wBankAccountInfoOverseaList.add(tmpInfo);
        return null;
    }
    
    public PageReference RemoveBankAccountInfoOversea(){
        // system.debug('to see RemoveBankAccountInfoOversea start');
        //remove 1 item each time with param
        //String idx_bankAccountInfoOversea = ApexPages.currentPage().getParameters().get('idx_bankAccountInfoOversea '); 
        // system.debug('to see idx_bankAccountInfoOversea : '+idx_bankAccountInfoOversea);
        List<ClaimHelper.WrapperBankAccountInfoOversea> wBankAccountInfoOverseaList_tmp = new List<ClaimHelper.WrapperBankAccountInfoOversea>{};
        // system.debug('to see wBankAccountInfoOverseaList_tmp : '+wBankAccountInfoOverseaList_tmp);
        Integer i = 0;
        for(ClaimHelper.WrapperBankAccountInfoOversea tmpItem: wBankAccountInfoOverseaList){
            if(i != Integer.valueOf(idx_bankAccountInfoOversea))    wBankAccountInfoOverseaList_tmp.add(tmpItem);
            i++;
        }
        wBankAccountInfoOverseaList.clear();
        wBankAccountInfoOverseaList = wBankAccountInfoOverseaList_tmp ;
        
        return null;
    }
    **/
    
    //WS - GetPersonBasic
    public void getPersonBasic(String ssn, Boolean isPI){    //pass ssn to get sen code for HIF or group PI get cert number at GetClinicVisitCount for OP
        Boolean PI_have_Sen_Code_N6 = false;
        // system.debug('to see getPersonBasic ssn: '+ssn);  
        List<HttpCalloutVO.Person> personList = new List<HttpCalloutVO.Person>();
        //error from ws handling
        //personList = helper.getPersonBasic(ssn);
        //20200817 - minghua - Performance issue in claim flow Step 2
        if(String.isNotBlank(ssn)){
            if(personBasicList != null && personBasicList.containsKey(ssn)){
                personList = personBasicList.get(ssn);
            }else{
                PersonCalloutHelper helper = new PersonCalloutHelper();
                personList = helper.getPersonBasic(ssn);
                if(personList!= null && String.isNotBlank(ssn)){
                    personBasicList.put(ssn, personList);
                }
                if(!helper.getResultInfo().isSuccess){
                    errorMsg = 'Error at getPersonBasic: '+helper.getResultInfo().resultInfoDesc;
                    // system.debug('to see '+errorMsg);
                }
            }
        }
        /**
        try {
            personList = helper.getPersonBasic(ssn);
        } catch(CignaWSResultTooLargeException e1){
            // system.debug('to see error: '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } catch(CignaWSTimeoutException e2){
            // system.debug('to see error: '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        } catch(CignaWSException e3){
            // system.debug('to see error: '+e3);
            // Handle the exception
        } catch(Exception e4){
            // Handle the exception
            // system.debug('to see error: '+e4);
        }
        **/
        // system.debug('to see personList : '+personList);
        for(HttpCalloutVO.Person  personCalloutHelperItem: personList){    //GetPersonBasic  
            ClaimHelper.WrapperPerson wPersonItem = new ClaimHelper.WrapperPerson();
            //ind.
            wPersonItem.ssnNum = personCalloutHelperItem.ssnNumber;
            wPersonItem.memberName = personCalloutHelperItem.fullName;
            wPersonItem.emailAddr = personCalloutHelperItem.emailAddress;
            wPersonItem.gender = personCalloutHelperItem.gender ;
            //wPersonItem.sensitivityCode = null;
            //group
            wPersonItem.certNum = personCalloutHelperItem.certificateNo;
            wPersonItem.certEffectiveDate = personCalloutHelperItem.certificateeffdate;
            wPersonItem.memberStatusDescription = personCalloutHelperItem.memberstatusdesc;
            wPersonItem.birthDate = personCalloutHelperItem.birthDate ;
            
            List<Map<String,String>> tmpSenMapList = new List<Map<String,String>>{};
            // system.debug('to see sensitivityList: '+personCalloutHelperItem.sensitivityList);
            for(HttpCalloutVO.Sensitivity senItem: personCalloutHelperItem.sensitivityList){
                Map<String,String> tmpMap = new Map<String,String>{};
                tmpMap.put('sensitivityCode', senItem.sensitivityCode);
                tmpMap.put('sensitivityDesc', senItem.sensitivityDesc);
                tmpMap.put('action', senItem.action);
                tmpSenMapList.add(tmpMap);
                if(senItem.sensitivityCode == 'UW04'){
                    if(cList[0].Person_s_Insured__c.equals(ssn)){
                        PI_have_Sen_Code_N6 = true;
                        
                    }
                    //sj_HIF_a = false;
                }
            }
            wPersonItem.senMapList = tmpSenMapList;
            wPersonList.add(wPersonItem);
            
            //add to list and display at website    
            Map<String,String> pAccInfoMap_tmp = new Map<String,String>{};
            pAccInfoMap_tmp.put('ssnNum', wPersonItem.ssnNum);     //should duplicate - ssnNumber
            pAccInfoMap_tmp.put('memberName', wPersonItem.memberName);     //should duplicate - fullName
            pAccInfoMap_tmp.put('senMapList',String.valueOf(wPersonItem.senMapList)); 
            pAccInfoMap_tmp.put('certNum', wPersonItem.certNum); 
            pAccInfoMap_tmp.put('certEffectiveDate', wPersonItem.certEffectiveDate); 
            pAccInfoMap_tmp.put('memberStatusDescription', wPersonItem.memberStatusDescription);
            if(isPI){
                pAccInfoMap_tmp.put('gender', wPersonItem.gender); 
                pAccInfoMap_tmp.put('birthDate', wPersonItem.birthDate); 
            }else{
                pAccInfoMap_tmp.put('mobilePhoneNo', wPersonItem.mobilePhoneNo);     // all mobile phone info in list
                pAccInfoMap_tmp.put('mobileCountryCode', wPersonItem.mobileCountryCode); 
                pAccInfoMap_tmp.put('mobileAreaCode', wPersonItem.mobileAreaCode); 
                pAccInfoMap_tmp.put('mobileTelephoneNo', wPersonItem.mobileTelephoneNo); 
                pAccInfoMap_tmp.put('emailAddr', wPersonItem.emailAddr); 
            }
            if(wPersonItem.ssnNum != null){
                // system.debug('to see pAccIdInfoMap before: ' + pAccIdInfoMap);
                //should duplicate from WS GetPolicyListBasicByCriteria PI list
                Map<String,String> pAccIdInfoMap_getByPassSsn = new Map<String,String>{};
                if(pAccIdInfoMap.get(wPersonItem.ssnNum) != null){pAccIdInfoMap_getByPassSsn = pAccIdInfoMap.get(wPersonItem.ssnNum);}
                pAccIdInfoMap_getByPassSsn.putAll(pAccInfoMap_tmp);
                pAccIdInfoMap.put(wPersonItem.ssnNum , pAccIdInfoMap_getByPassSsn);
            }
        }
        // system.debug('to see pAccIdInfoMap: '+pAccIdInfoMap);
        
        /** save all data in pAccIdInfoMap to claim record if necessary **/
        if(!String.isBlank(ssn) && pAccIdInfoMap.get(ssn) != null && cList.size() == 1){
            Map<String,String> tmpToGetPersonDataFromListMap = new Map<String,String>{};
            tmpToGetPersonDataFromListMap = pAccIdInfoMap.get(ssn);
            // system.debug('to see pass tmpToGetPersonDataFromListMap to claim record: '+tmpToGetPersonDataFromListMap);
            for(String itemName: tmpToGetPersonDataFromListMap.keySet()){
                // system.debug('to see tmpToGetPersonDataFromListMap.get(itemName): '+tmpToGetPersonDataFromListMap.get(itemName));
                if(itemName == 'gender'){cList[0].Person_Insured_Gender__c = tmpToGetPersonDataFromListMap.get(itemName);}
                if(itemName == 'birthDate'){
                    if(!String.isBlank(tmpToGetPersonDataFromListMap.get(itemName))){
                        cList[0].Person_Insured_Date_Of_Birth__c = Date.valueOf(tmpToGetPersonDataFromListMap.get(itemName));
                    } 
                }
                
            }
        }
        cList[0].PI_without_any_Sen_Code_N6__c = !PI_have_Sen_Code_N6 ;
        system.debug('to see isPI: ' + isPI);
        system.debug('to see cList[0].PI_without_any_Sen_Code_N6__c: ' + cList[0].PI_without_any_Sen_Code_N6__c);
    }
    
    // WS - GetClinicVisitCount - for OP only group policy get coverage
    public void getClinicVisitCount(String p1,String p2,String p3){    //helper.getClinicVisitCount('3018', 'A123456', '0446-00');
        Map<String,String> tmpKeyMap = new Map<String,String>{};
        List<Map<String,String>> tmpResultMapList = new List<Map<String,String>>{};
        tmpKeyMap.put(p1, p2);
        
        // system.debug('to see getClinicVisitCount start');
        // system.debug('to see p1: '+p1);
        // system.debug('to see p2: '+p2);
        // system.debug('to see p3: '+p3);
        List<HttpCalloutVO.ClinicVisit> clinicVisitList = new List<HttpCalloutVO.ClinicVisit>();
        //error from WS handling
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        //clinicVisitList = helper.getClinicVisitCount(p1, p2, p3);
        clinicVisitList = helper.getClinicVisitCount(p1, p2, p3);
        /**
        try {
            clinicVisitList = helper.getClinicVisitCount(p1, p2, p3);
        } catch(CignaWSResultTooLargeException e1){
            // system.debug('to see error: '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } catch(CignaWSTimeoutException e2){
            // system.debug('to see error: '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        } catch(CignaWSException e3){
            // system.debug('to see error: '+e3);
            // Handle the exception
        } catch(Exception e4){
            // Handle the exception
            // system.debug('to see error: '+e4);
        }
        **/
        if(!helper.getResultInfo().isSuccess){
            errorMsg = 'Error at getClinicVisitCount: '+helper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        // system.debug('to see clinicVisitList: '+clinicVisitList);
        
        for(HttpCalloutVO.ClinicVisit clinicVisitItem: clinicVisitList){    //GetClinicVisitCount
            ClaimHelper.WrapperClinicVisitCount wClinicVisitCountItem = new ClaimHelper.WrapperClinicVisitCount();
            wClinicVisitCountItem.policyNum = clinicVisitItem.policyNumber;
            wClinicVisitCountItem.certNum = clinicVisitItem.certNumber;
            List<String> tmpCodeList = new List<String>{};
            if(clinicVisitItem.planTypeCode!= null){tmpCodeList  = clinicVisitItem.planTypeCode.split(':');}
            if(tmpCodeList.size()>0){wClinicVisitCountItem.planTypeCode = tmpCodeList[0];}
            if(tmpCodeList.size()>1){wClinicVisitCountItem.rateScale = tmpCodeList[1];}
            List<Map<String,String>> tmpMapList_benefit = new List<Map<String,String>>{};
            List<Map<String,String>> tmpMapList_combineBenefit = new List<Map<String,String>>{};
            
            for(HttpCalloutVO.BenefitDetailItem tmpBenefitItem : clinicVisitItem.benefitList){
                Map<String,String> tmpMap = new Map<String,String>{};
                tmpMap.put('benefitDetailItemCode', tmpBenefitItem.benefitDetailItemCode);
                tmpMap.put('benefitDetailItemDescription', tmpBenefitItem.benefitDetailItemDescription);
                tmpMapList_benefit.add(tmpMap);
                /**
                testing to get claim benefit code from WS
                **/
                Map<String,String> tmpValueItemMap = new Map<String,String>{};
                tmpValueItemMap.put('benefitCode', tmpBenefitItem.benefitDetailItemCode);
                tmpValueItemMap.put('rateScale', '');
                tmpResultMapList.add(tmpValueItemMap);
            }
            wClinicVisitCountItem.benefitDetailItemMapList = tmpMapList_benefit;
            for(HttpCalloutVO.CombinedBenefit tmpBenefitItem : clinicVisitItem.combinedBenefitList){
                Map<String,String> tmpMap = new Map<String,String>{};
                tmpMap.put('sequenceNumber', tmpBenefitItem.sequenceNumber);
                //tmpMap.put('overallOutpatientMaximumNo', tmpBenefitItem.overallOutpatientMaximumNo);
                //tmpMap.put('totalVisitedCount', tmpBenefitItem.totalVisitedCount);
                tmpMap.put('benefitItemCodeList', tmpBenefitItem.benefitItemCodeList);
                tmpMapList_combineBenefit.add(tmpMap);
            }
            wClinicVisitCountItem.combinedBenefitDetailItemMapList = tmpMapList_combineBenefit;
            wClinicVisitCountList.add(wClinicVisitCountItem);    
        }
        pNumSsnValueListMap.put(tmpKeyMap, tmpResultMapList);
        // system.debug('to see wClinicVisitCountList: '+wClinicVisitCountList);
    }
    
    // WS - GetPolicyPersonCoverageBasic - pass ssn to get policy detail
    public void getPolicyPersonCoverageBasic(String policyNumber,String ssn){    //pNumSsnValueListMap 
        // system.debug('to see getPolicyPersonCoverageBasic policyNumber start: '+policyNumber+'    ssn: '+ssn);
        policyNumber = policyNumber.trim();
        ssn = ssn.trim();
        
        if(!String.isBlank(policyNumber) && !String.isBlank(ssn)){
            Map<String,String> tmpKeyMap = new Map<String,String>{};
            tmpKeyMap.put(policyNumber, ssn);
            // system.debug('to see getPolicyPersonCoverageBasic start policyNumber: <'+policyNumber+'>');
            // system.debug('to see getPolicyPersonCoverageBasic start ssn: <'+ssn+'>');
            List<HttpCalloutVO.PolicyPersonCoverage> policyPersonCoverageList = new List<HttpCalloutVO.PolicyPersonCoverage>();
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            if(pNumSsnValueListMap.get(tmpKeyMap) == null){    //no call getPolicyPersonCoverageBasic before
                //policyPersonCoverageList = helper.getPolicyPersonCoverageBasic(policyNumber, ssn);    //'HMKHK0001203152', 'Z636352'
                policyPersonCoverageList = helper.getPolicyPersonCoverageBasic(policyNumber, ssn);    //'HMKHK0001203152', 'Z636352'
                /**
                try {
                    policyPersonCoverageList = helper.getPolicyPersonCoverageBasic(policyNumber, ssn);    //'HMKHK0001203152', 'Z636352'
                } catch(CignaWSResultTooLargeException e1){
                    // system.debug('to see error: '+e1);
                    // Handle the exception
                    // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
                } catch(CignaWSTimeoutException e2){
                    // system.debug('to see error: '+e2);
                    // Handle the exception
                    // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
                } catch(CignaWSException e3){
                    // system.debug('to see error: '+e3);
                    // Handle the exception
                } catch(Exception e4){
                    // Handle the exception
                    // system.debug('to see error: '+e4);
                }
                **/
                if(!helper.getResultInfo().isSuccess){
                    errorMsg = 'Error at getPolicyPersonCoverageBasic: '+helper.getResultInfo().resultInfoDesc;
                    // system.debug('to see '+errorMsg);
                }
                // system.debug('to see policyPersonCoverageList: '+policyPersonCoverageList);
            }
            List<Map<String,String>> tmpValueMapList = new List<Map<String,String>>{};
                    
            for(HttpCalloutVO.PolicyPersonCoverage policyPersonCoverageItem: policyPersonCoverageList){
                // system.debug('to see policyPersonCoverageItem: '+policyPersonCoverageItem);
                Map<String,String> tmpValueMap = new Map<String,String>{};
                /** 
                 *  Zoe updated on 1017, PPCP-143
                 *  For individual, HttpCalloutVO.PolicyPersonCoverage.productCode = product code under OLifEExtension; 
                 *                  HttpCalloutVO.PolicyPersonCoverage.benefitCode = product code under Coverage (before :);
                 *                  HttpCalloutVO.PolicyPersonCoverage.rateScale = rate scale under Coverage (after :).
                 *                  -- The plan code mapping will be based on product code(only exists in S6 mapping) + benefitCode + rateScale
                 *  For Group, HttpCalloutVO.PolicyPersonCoverage.productCode = '';
                 *             HttpCalloutVO.PolicyPersonCoverage.benefitCode = product code under Coverage;
                 *             HttpCalloutVO.PolicyPersonCoverage.benefitItemCode = Benefit Item Code under OLifEExtension;
                 *             HttpCalloutVO.PolicyPersonCoverage.rateScale = ''.
                 *             -- The plan code mapping will be based on benefitItemCode only
                 */
                
                //    BACKUP before PPCP-143 's change
                /**
                tmpValueMap.put('productCode', policyPersonCoverageItem.productCode);
                if(policyPersonCoverageItem.benefitAmountInNumber != null)    tmpValueMap.put('benefitAmount',String.valueOf(policyPersonCoverageItem.benefitAmountInNumber));    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                else    tmpValueMap.put('benefitAmount', null);    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                //tmpValueMap.put('benefitAmount', policyPersonCoverageItem.benefitAmount);    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                tmpValueMap.put('benefitCode', policyPersonCoverageItem.benefitCode);
                tmpValueMap.put('rateScale', policyPersonCoverageItem.rateScale);
                */
                
                // individual
                //if(policyPersonCoverageItem.productCode != null && policyPersonCoverageItem.productCode != ''){
                // Zoe updated on 1110, PPCP-143 && CR-7
                if(policyPersonCoverageItem.benefitItemCode == null || policyPersonCoverageItem.benefitItemCode == ''){
                    tmpValueMap.put('productCode', policyPersonCoverageItem.productCode);
                    if(policyPersonCoverageItem.benefitAmountInNumber != null){tmpValueMap.put('benefitAmount',String.valueOf(policyPersonCoverageItem.benefitAmountInNumber));}   //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                    else{tmpValueMap.put('benefitAmount', null);}    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                    //tmpValueMap.put('benefitAmount', policyPersonCoverageItem.benefitAmount);    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                    tmpValueMap.put('benefitCode', policyPersonCoverageItem.benefitCode);
                    tmpValueMap.put('rateScale', policyPersonCoverageItem.rateScale);
                }
                // group
                else{
                    tmpValueMap.put('productCode', '');
                    tmpValueMap.put('benefitCode', policyPersonCoverageItem.benefitItemCode);
                    //tmpValueMap.put('benefitCode', 'DENLAB');
                    //tmpValueMap.put('benefitCode', 'HEX');
                    tmpValueMap.put('rateScale', '');
                }

                tmpValueMapList.add(tmpValueMap);

                Map<String,String> tmpCertMap = new Map<String,String>{};    //policyNum: ssn -> policyNum / ssn / certnum
                tmpCertMap.put('policyNum', policyNumber);    
                tmpCertMap.put('ssnNumber', ssn);
                tmpCertMap.put('certNum', policyPersonCoverageItem.memberCertNo);
                policyNumSsnGetCertNumMap.put(tmpKeyMap,tmpCertMap);
                // for policy currency, updated by Zoe on 0405 for performance tuning
                // system.debug('************ currencyTypeCodeTC :' + policyPersonCoverageItem.currencyTypeCodeTC);
            }
            
            // system.debug('to see tmpValueMapList: '+tmpValueMapList);
            if(tmpValueMapList.size()>0){
                pNumSsnValueListMap.put(tmpKeyMap, tmpValueMapList);
                system.debug('to see pNumSsnValueListMap: '+pNumSsnValueListMap);
            }           
            // for policy currency, updated by Zoe on 0405 for performance tuning
            // system.debug('********** wPolicyList_unchanged: ' + wPolicyList_unchanged);
            // system.debug('********** wPolicyList_unchanged.size: '+ wPolicyList_unchanged.size());  
            // system.debug('********** wPolicyList_PI: ' + wPolicyList_PI);
            // system.debug('********** wPolicyList_PI.size: '+ wPolicyList_PI.size()); 
            
            if(policyPersonCoverageList != null && policyPersonCoverageList.size()> 0){
                for(ClaimHelper.WrapperPolicy wPolicy: wPolicyList_unchanged){
                    if(wPolicy.policyNum == policyNumber){
                        String tmpCurrencyCode = policyPersonCoverageList[0].currencyTypeCodeTC;
                        wPolicy.currenyCode = tmpCurrencyCode;
                        if(tmpCurrencyCode =='840'){wPolicy.isUSDPolicy = true;}
                        else{wPolicy.isUSDPolicy = false;}
                        system.debug('to see wPolicyList_unchanged wPolicy: '+wPolicy);
                    }
                }
                
                for(ClaimHelper.WrapperPolicy wPolicy: wPolicyList_PI){
                    if(wPolicy.policyNum == policyNumber){
                        String tmpCurrencyCode = policyPersonCoverageList[0].currencyTypeCodeTC;
                        wPolicy.currenyCode = tmpCurrencyCode;
                        if(tmpCurrencyCode =='840'){wPolicy.isUSDPolicy = true;}
                        else{wPolicy.isUSDPolicy = false;}
                        system.debug('to see wPolicyList_PI wPolicy: '+wPolicy);
                    }
                }
            } 
        }
        // system.debug('to see pNumSsnValueListMap: '+pNumSsnValueListMap);
    }
    
    //WS - GetPolicyPersonListBasic - pass group policy to get PI under
    public List<Map<String,String>> getPolicyPersonListBasic(String policyNumber){
        List<Map<String,String>> tmpStrMapList = new List<Map<String,String>>{}; 
        // system.debug('to see getPolicyPersonListBasic policyNumber start: '+policyNumber);
        List<HttpCalloutVO.Person> policyPersonList = new List<HttpCalloutVO.Person>();
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        // ***** Start of Quick fix for group policy by Zoe on 0331 
        // policyPersonList = helper.getPolicyInsuredListBasic(policyNumber);    //get insured only from GetPolicyPersonListBasic 
        policyPersonList = helper.getPolicyPersonListBasicByCriteria(policyNumber, '','','',userSsn);
        // permanent fix for group policy by Zoe on 0713
        /**
        PersonCalloutHelper personHelper = new PersonCalloutHelper();
        List<HttpCalloutVO.Person> phPersonBasicList = new List<HttpCalloutVO.Person>();
        
        phPersonBasicList = personHelper.getPersonBasic(userSsn);
        for(HttpCalloutVO.Person p : phPersonBasicList){
            policyPersonList.add(p);
        }
        */
        // ***** End of Quick fix for group policy by Zoe on 0331 
        /**
        try {
            policyPersonList = helper.getPolicyInsuredListBasic(policyNumber);    //get insured only from GetPolicyPersonListBasic 
        } catch(CignaWSResultTooLargeException e1){
            // system.debug('to see error: '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } catch(CignaWSTimeoutException e2){
            // system.debug('to see error: '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        } catch(CignaWSException e3){
            // system.debug('to see error: '+e3);
            // Handle the exception
        } catch(Exception e4){
            // Handle the exception
            // system.debug('to see error: '+e4);
        }
        **/
        // ***** Start of Quick fix for group policy by Zoe on 0331 
        
        if(!helper.getResultInfo().isSuccess){
            errorMsg = 'Error at getPolicyInsuredListBasic: '+helper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        // permanent fix for group policy by Zoe on 0713
        /**
        if(!personHelper.getResultInfo().isSuccess){
            errorMsg = 'Error at getPolicyInsuredListBasic: '+personHelper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        */
        // ***** End of Quick fix for group policy by Zoe on 0331 
        // system.debug('to see policyPersonList : '+policyPersonList);
        if(policyPersonList != null && policyPersonList.size()>0){
            // 20211216 - minghua - JOBR-67, Performance Tuning - Claim submission
            basePPBBList=policyPersonList;
            for(HttpCalloutVO.Person personPersonItem: policyPersonList){    //GetPolicyPersonListBasic 
                Map<String,String> tmpPIValueMap = new Map<String,String>{};
                String fullName = '';
                String ssnNumber = '';
                fullName = personPersonItem.fullName;
                ssnNumber = personPersonItem.ssnNumber;
                String certNum = personPersonItem.certificateNo; //Add by Manuel on Sep 28 that supplement parameter for claim request
                
                if(!String.isBlank(fullName) && !String.isBlank(ssnNumber)){
                    fullName = fullName.trim();
                    ssnNumber = ssnNumber.trim();
                    tmpPIValueMap.put('fullName', fullName);
                    tmpPIValueMap.put('ssnNumber', ssnNumber);
                    tmpPIValueMap.put('certNum', certNum); //Add by Manuel on Sep 28 that supplement parameter for claim request
                    allSsnNamePIMap.put(personPersonItem.ssnNumber, tmpPIValueMap);     
                    tmpStrMapList.add(tmpPIValueMap);
                    isContainPI = true;
                }
            }
            // system.debug('to see allSsnNamePIMap: '+allSsnNamePIMap);
        }
        return tmpStrMapList;
    }
    
    // WS - getPolicyPaymentBasic - pass selected policy to get bank account info
    public void getPolicyPaymentBasic(String policyNumber){    //'3018' or 'HMKHK0000693908'
        //bankAccInfoList.clear();
        // system.debug('to see getPolicyPaymentBasic policyNumber start: '+policyNumber);
        List<HttpCalloutVO.PolicyPayment> policyPaymentList = new List<HttpCalloutVO.PolicyPayment>();
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        //policyPaymentList = helper.getPolicyPaymentBasic(policyNumber);
        policyPaymentList = helper.getPolicyPaymentBasic(policyNumber);
        /**
        try {
            policyPaymentList = helper.getPolicyPaymentBasic(policyNumber);
        } catch(CignaWSResultTooLargeException e1){
            // system.debug('to see error: '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } catch(CignaWSTimeoutException e2){
            // system.debug('to see error: '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        } catch(CignaWSException e3){
            // system.debug('to see error: '+e3);
            // Handle the exception
        } catch(Exception e4){
            // Handle the exception
            // system.debug('to see error: '+e4);
        }
        **/
        if(!helper.getResultInfo().isSuccess){
            errorMsg = 'Error at getPolicyPaymentBasic: '+helper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        // system.debug('to see policyPaymentList: '+policyPaymentList);
        
        if(policyPaymentList!= null && policyPaymentList.size()>0){
            List<Map<String,String>> tmpMapList_nulBankAcc = new List<Map<String,String>>{};
            for(HttpCalloutVO.PolicyPayment  personCalloutHelperItem: policyPaymentList){    //getPolicyPaymentBasic 
                // Zoe updated on 0402 to filter DDA account
                if(personCalloutHelperItem.paymentMethodCode == '1052500002' || personCalloutHelperItem.paymentMethodCode == '1052500006'){
                    ClaimHelper.WrapperPolicyPaymentBasic wPolicyPaymentBasicItem = new ClaimHelper.WrapperPolicyPaymentBasic();
                    wPolicyPaymentBasicItem.policyNum = personCalloutHelperItem.policyNumber;
                    wPolicyPaymentBasicItem.modalPremium = personCalloutHelperItem.paymentAmt;
                    wPolicyPaymentBasicItem.payerSsnNum = personCalloutHelperItem.ssnNumber;
                    wPolicyPaymentBasicItem.payerFullName = personCalloutHelperItem.PayerName;
                    wPolicyPaymentBasicItem.payerAccNumber = personCalloutHelperItem.accountNumber;
                    wPolicyPaymentBasicItem.payAccHolderName = personCalloutHelperItem.acctHolderName;
                    wPolicyPaymentBasicItem.payBankName = personCalloutHelperItem.bankName;
                    /** useless for group **/
                    wPolicyPaymentBasicList.add(wPolicyPaymentBasicItem);
                    
                    Map<String,String> tmp_nameInfoMap = new Map<String,String>{};
                    String tmp_accHolderName = 'N/A';
                    String tmp_accNum = 'N/A';
                    String tmp_bankName = 'N/A';
                    if(!String.isBlank(personCalloutHelperItem.acctHolderName)){tmp_accHolderName = personCalloutHelperItem.acctHolderName;}
                    if(!String.isBlank(personCalloutHelperItem.accountNumber)){tmp_accNum = personCalloutHelperItem.accountNumber;}
                    if(!String.isBlank(personCalloutHelperItem.bankName)){tmp_bankName = personCalloutHelperItem.bankName;}
                    
                    tmp_accHolderName = tmp_accHolderName.trim();
                    tmp_accNum = tmp_accNum.trim();
                    tmp_bankName = tmp_bankName.trim();
                    //should no duplicate for bank account
                    tmp_nameInfoMap.put('acctHolderName', tmp_accHolderName);
                    tmp_nameInfoMap.put('accountNumber', tmp_accNum);
                    tmp_nameInfoMap.put('bankName', tmp_bankName);
                    String tmpJSON = JSON.serialize(tmp_nameInfoMap);
                    tmp_nameInfoMap.put('json', tmpJSON);
                    
                    Boolean isDuplicate = false;
                    for(Map<String,String> bankAccInfoItem: bankAccInfoList){
                        if(bankAccInfoItem.get('acctHolderName') == tmp_accHolderName && bankAccInfoItem.get('accountNumber') == tmp_accNum && bankAccInfoItem.get('bankName') == tmp_bankName){isDuplicate = true;}
                    }
                    if(!isDuplicate){
                        // system.debug('to see tmp_nameInfoMap: '+tmp_nameInfoMap);
                        if(!String.isBlank(personCalloutHelperItem.acctHolderName) || !String.isBlank(personCalloutHelperItem.accountNumber) || !String.isBlank(personCalloutHelperItem.bankName)){
                            bankAccInfoList.add(tmp_nameInfoMap);
                        }else{
                            tmpMapList_nulBankAcc.add(tmp_nameInfoMap);
                        }
                    }
                }
            }
            //for case WS really have null data and null data is the only avaliable
            if(bankAccInfoList.size()==0 && tmpMapList_nulBankAcc.size()>0){bankAccInfoList.add(tmpMapList_nulBankAcc[0]);}
        }
        // system.debug('to see bankAccInfoList: '+bankAccInfoList);
        if(bankAccInfoList.size()> 0){isBrkCustomerHasDDA = true;}
    }
    
    //get currency code to distinguish USD policy or not
    public void getPolicyBasic(String policyNumber){    //'3018' or 'HMKHK0000693908'
        system.debug('to see getPolicyBasic policyNumber start: '+policyNumber);
        HttpCalloutVO.Policy policyItem = new HttpCalloutVO.Policy();
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        //policyItem = helper.getPolicyBasic(policyNumber);
        policyItem = helper.getPolicyBasic(policyNumber);
        /**
        try {
            policyItem = helper.getPolicyBasic(policyNumber);
        } catch(CignaWSResultTooLargeException e1){
            // system.debug('to see error: '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } catch(CignaWSTimeoutException e2){
            // system.debug('to see error: '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        } catch(CignaWSException e3){
            // system.debug('to see error: '+e3);
            // Handle the exception
        } catch(Exception e4){
            // Handle the exception
            // system.debug('to see error: '+e4);
        }
        **/
        if(!helper.getResultInfo().isSuccess){
            errorMsg = 'Error at getPolicyBasic: '+helper.getResultInfo().resultInfoDesc;
            // system.debug('to see '+errorMsg);
        }
        // system.debug('to see policyItem: '+policyItem);
        /**
        344 = OLI_CURRENCY_HKD
        840 = OLI_CURRENCY_USD
        156 = OLI_CURRENCY_CNY
        **/
        
        if(policyItem != null){
            for(ClaimHelper.WrapperPolicy wPolicy: wPolicyList_unchanged){
                if(wPolicy.policyNum == policyItem.policyNumber){
                    String tmpCurrencyCode = policyItem.currencyCode;
                    wPolicy.currenyCode = tmpCurrencyCode;
                    if(tmpCurrencyCode =='840'){wPolicy.isUSDPolicy = true;}
                    else{wPolicy.isUSDPolicy = false;}
                    // system.debug('to see wPolicyList_unchanged wPolicy: '+wPolicy);
                }
            }
            
            for(ClaimHelper.WrapperPolicy wPolicy: wPolicyList_PI){
                if(wPolicy.policyNum == policyItem.policyNumber){
                    String tmpCurrencyCode = policyItem.currencyCode;
                    wPolicy.currenyCode = tmpCurrencyCode;
                    if(tmpCurrencyCode =='840'){wPolicy.isUSDPolicy = true;}
                    else{wPolicy.isUSDPolicy = false;}
                    // system.debug('to see wPolicyList_PI wPolicy: '+wPolicy);
                }
            }
        }
    }
    
    //email title for send claim form part 2
    public String getClaimTypeStrForEmailTitle(Claim__c cItem){
        /**
        String soql_getUpdatedClaim = ClaimHelper.CLAIM_ALL_FIELD;
        soql_getUpdatedClaim += ' where Id=\''+cItem.Id+'\'';
        // system.debug('to see soql_getUpdatedClaim : '+soql_getUpdatedClaim);
        List<Claim__c> updated_cList = Database.query(soql_getUpdatedClaim);
        cItem = updated_cList[0];
        */
        // system.debug('*********' + cItem.HIF__c + cItem.HI__c + cItem.HPA__c + cItem.HS__c + cItem.CI__c + cItem.DIS__c + cItem.OP__c + cItem.OPF__c + cItem.MAT__c);
        // system.debug('to see getClaimTypeStrForEmailTitle start');
        // system.debug('to see cItem: ' + cItem);
        String emailTitle = '';
        String query_condition_on_portal = '';
        Boolean isChi = false;
        for(User u: uList){
            if(u.LanguageLocaleKey == 'zh_TW' || u.LanguageLocaleKey == 'zh_HK'){isChi = true;}
        }
        // if(cItem.Is_Using_Chinese_Version__c)    isChi = true;
        
        String query_condition = ''; 
        //edited by minglei 2018.05.15 [add Wellness type to claim] start
        /* 
        if(!cItem.HIF__c && !cItem.HI__c && !cItem.HPA__c && !cItem.HS__c && !cItem.CI__c && !cItem.DIS__c && !cItem.OP__c && !cItem.OPF__c && !cItem.MAT__c){
            query_condition += ' HIF__c = false and HI__c = false and HPA__c = false and  HS__c = false and  CI__c = false and  DIS__c = false and  OP__c = false and  OPF__c = false and  MAT__c = false  ';  
        }*/
        if(!cItem.HIF__c && !cItem.HI__c && !cItem.HPA__c && !cItem.HS__c && !cItem.CI__c && !cItem.DIS__c && !cItem.OP__c && !cItem.OPF__c && !cItem.MAT__c && !cItem.WL__c){
            query_condition += ' HIF__c = false and HI__c = false and HPA__c = false and  HS__c = false and  CI__c = false and  DIS__c = false and  OP__c = false and  OPF__c = false and  MAT__c = false and  WL__c = false';  
        }        
        if(cItem.WL__c){
            if(String.isBlank(query_condition)){query_condition += ' WL__c = true';}
            else{query_condition += ' or WL__c = true ';}
        }        
        //edited by minglei 2018.05.15 [add Wellness type to claim] end        
        if(cItem.HIF__c){
            if(String.isBlank(query_condition)){query_condition += ' HIF__c = true';}
            else{query_condition += ' or HIF__c = true ';}
        }
        if(cItem.HI__c){
            if(String.isBlank(query_condition)){query_condition += ' HI__c = true';}
            else{query_condition += ' or HI__c = true ';}
        }
        if(cItem.HPA__c && cItem.HPA_Less_Than_2_Yrs__c){
            if(String.isBlank(query_condition)){query_condition += ' (HPA__c = true and  Other_Rule_s__c = \'brokerPAC\')';}    
            else{query_condition += ' or (HPA__c = true and  Other_Rule_s__c = \'brokerPAC\') ';}
        }
        if(cItem.HS__c && cItem.HS_Less_Than_3_Yrs_or_Broker_PAC__c){
            if(String.isBlank(query_condition)){query_condition += ' (HS__c = true and  Other_Rule_s__c = \'brokerPAC\')';}
            else{query_condition += ' or (HS__c = true and  Other_Rule_s__c = \'brokerPAC\') ';}
        }
        // 20190918 - Raistlin - GS user download doctor form
        if(cItem.HS__c && !cItem.HS_Less_Than_3_Yrs_or_Broker_PAC__c){
            if(String.isBlank(query_condition)){query_condition += ' MAT__c = true';}
            else{query_condition += ' or MAT__c = true ';}
        }
        if(cItem.CI__c){
            if(String.isBlank(query_condition)){query_condition += ' CI__c = true';}
            else{query_condition += ' or CI__c = true ';}
        }
        if(cItem.DIS__c){
            if(String.isBlank(query_condition)){query_condition += ' DIS__c = true';}
            else{query_condition += ' or DIS__c = true ';}
        }
        if(cItem.OP__c){
            if(String.isBlank(query_condition)){query_condition += ' OP__c = true';}
            else{query_condition += ' or OP__c = true ';}
        }
        if(cItem.OPF__c){
            if(String.isBlank(query_condition)){query_condition += ' OPF__c = true';}
            else{query_condition += ' or OPF__c = true ';}
        }
        if(cItem.MAT__c){
            if(String.isBlank(query_condition)){query_condition += ' MAT__c = true';}
            else{query_condition += ' or MAT__c = true ';}
        }
        if(isCustomer){query_condition_on_portal = 'Is_Customer__c = true';}
        else{query_condition_on_portal = 'Is_Broker__c = true';}
        // system.debug('to see query_condition: ' + query_condition);
        
        String soql_claimTypeDoc = ClaimHelper.CLAIM_TYPE_DOCUMENT_ALL_FIELD;
        if(!String.isBlank(query_condition)){soql_claimTypeDoc += ' where Active__c = true and ' + query_condition_on_portal + ' and ('+query_condition+') ';}
        // system.debug('to see soql_claimTypeDoc: ' + soql_claimTypeDoc);
        
        List<Claim_Type_Document__c> claimTypeDocumentList = new List<Claim_Type_Document__c>();
        claimTypeDocumentList = Database.query(soql_claimTypeDoc);
        // system.debug('claimTypeDocumentList '+claimTypeDocumentList);
        Set<String> claimTypeDocIdSet = new Set<String>{};
            for(Claim_Type_Document__c cTypeDocItem: claimTypeDocumentList){
                claimTypeDocIdSet.add(cTypeDocItem.id);
            }
        Map<String,List<Attachment>> claimTypeDocIdAttachmentMap = loadClaimTypeDocumentAttachement(claimTypeDocIdSet);    //save data in claimTypeDocIdAttachmentMap
        
        String typeNameEng ='';
        String typeNameChi ='';
        List<Map<String,String>> urlMapList = new List<Map<String,String>>{};
        for(Claim_Type_Document__c cTypeDocItem: claimTypeDocumentList){
            // system.debug('to see cTypeDocItem.Other_Rule_s__c: '+cTypeDocItem.Other_Rule_s__c);
            if(cTypeDocItem.Downloadable_as_PDF__c){
                // system.debug('to see cTypeDocItem: '+cTypeDocItem);
                //need to download
                List<Attachment> attList_tmp = new List<Attachment>{};
                if(claimTypeDocIdAttachmentMap.get(cTypeDocItem.id)!=null){attList_tmp =  claimTypeDocIdAttachmentMap.get(cTypeDocItem.id);}
                List<String> attUrlList_tmp = new List<String>{};
                for(Attachment att: attList_tmp){
                        String url = '';
                        url = ClaimHelper.ATT_EMAIL_PREFIX + att.id;
                        attUrlList_tmp.add(url);
                        
                        //add url / name
                        Map<String,String> tmpMap = new Map<String,String>{};
                        if(isChi){tmpMap.put('name', cTypeDocItem.Document_Name_Chinese__c);}
                        else{tmpMap.put('name', cTypeDocItem.Document_Name__c);}
                        tmpMap.put('attId', att.Id);
                        tmpMap.put('url', url);
                        urlMapList.add(tmpMap);    
                }
        
                if(!String.isBlank(cTypeDocItem.Attachment_Of_Benefit_Type_In_English__c)){
                    String targetTypeName = cTypeDocItem.Attachment_Of_Benefit_Type_In_English__c;
                    String[] typeArr = cTypeDocItem.Attachment_Of_Benefit_Type_In_English__c.split(';');
                    // system.debug('*********Attachment_Of_Benefit_Type_In_English__c List: ' + typeArr);
                    // system.debug('*********Attachment_Of_Benefit_Type_In_English__c size: ' + typeArr.size());
                    if(typeArr.size()> 1){
                        // system.debug('to see typeArr: '+typeArr);
                        // system.debug('to see typeArr[0]: '+typeArr[0]);
                        // system.debug('to see typeArr[1]: '+typeArr[1]);
                        if(cItem.HPA__c && cItem.HS__c && cTypeDocItem.HPA__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[0] + '\',\'' + typeArr[1];
                        }else if(cItem.HPA__c && cTypeDocItem.HPA__c){
                            // system.debug('to see HPA is true');
                            targetTypeName = typeArr[0];
                        }else if(cItem.HS__c && cTypeDocItem.HS__c){
                            // system.debug('to see HS is true');
                            targetTypeName = typeArr[1];
                        }
                        
                        //for DIS / WD
                        if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0] + '”，“' + typeArr[1];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[1];
                        }
                    }
                    // system.debug('to see targetTypeName: '+targetTypeName);
                    if(String.isBlank(typeNameEng)){typeNameEng = '\''+targetTypeName+'\'';}
                    else{typeNameEng += ' ,\''+targetTypeName+'\'';}
                    // system.debug('to see typeNameEng : '+typeNameEng);
                }
                if(!String.isBlank(cTypeDocItem.Attachment_Of_Benefit_Type_In_Chinese__c)){
                    String targetTypeName = cTypeDocItem.Attachment_Of_Benefit_Type_In_Chinese__c;
                    String[] typeArr = cTypeDocItem.Attachment_Of_Benefit_Type_In_Chinese__c.split(';');
                    // system.debug('*********Attachment_Of_Benefit_Type_In_Chinese__c List: ' + typeArr);
                    // system.debug('*********Attachment_Of_Benefit_Type_In_Chinese__c size: ' + typeArr.size());
                    if(typeArr.size()> 1){
                        if(cItem.HPA__c && cItem.HS__c && cTypeDocItem.HPA__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[0] + '”，“' + typeArr[1];
                        }else if(cItem.HPA__c && cTypeDocItem.HPA__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.HS__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[1];
                        }
                        
                        //for DIS / WD
                        if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0] + '”，“' + typeArr[1];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[1];
                        }
                    }
                    // system.debug('to see targetTypeName: '+targetTypeName);
                    
                    if(String.isBlank(typeNameChi)){typeNameChi= '“'+targetTypeName+'”';}
                    else{typeNameChi += '，“'+targetTypeName+'”';}
                    // system.debug('to see typeNameChi : '+typeNameChi);
                }
            }
            // system.debug('to see typeNameChi final: '+typeNameChi);
            // system.debug('to see typeNameEng final: '+typeNameEng);
            //if(cList[0].Is_Using_Chinese_Version__c){
            if(isChi){
                emailTitle = typeNameChi;
            }else{
            //if(!cList[0].Is_Using_Chinese_Version__c){
                emailTitle = typeNameEng;
            }
        }
        return emailTitle;
    }
    
    public String getEmailContentBody(Claim__c cItem){
        // system.debug('to see getEmailContentBody start');
        String emailBody = '';
        Boolean isChi = false;
        //if(cItem.Is_Using_Chinese_Version__c)    isChi = true;
        for(User u: uList){
            if(u.LanguageLocaleKey == 'zh_TW' || u.LanguageLocaleKey == 'zh_HK'){isChi = true;}
        }
        String query_condition_on_portal = '';
        
        String query_condition = ''; 
        //Added by minglei 2018.05.15 [add Wellness type to claim] start 
        /*if(!cItem.HIF__c && !cItem.HI__c && !cItem.HPA__c && !cItem.HS__c && !cItem.CI__c && !cItem.DIS__c && !cItem.OP__c && !cItem.OPF__c && !cItem.MAT__c){
            query_condition += ' HIF__c = false and HI__c = false and HPA__c = false and  HS__c = false and  CI__c = false and  DIS__c = false and  OP__c = false and  OPF__c = false and  MAT__c = false  ';  
        }*/
        if(!cItem.HIF__c && !cItem.HI__c && !cItem.HPA__c && !cItem.HS__c && !cItem.CI__c && !cItem.DIS__c && !cItem.OP__c && !cItem.OPF__c && !cItem.MAT__c && !cItem.WL__c){
            query_condition += ' HIF__c = false and HI__c = false and HPA__c = false and  HS__c = false and  CI__c = false and  DIS__c = false and  OP__c = false and  OPF__c = false and  MAT__c = false and WL__c = false ';  
        }
        if(cItem.WL__c){
            if(String.isBlank(query_condition)){query_condition += ' WL__c = true';}
            else{query_condition += ' or WL__c = true ';}
        }        
        //Added by minglei 2018.05.15 [add Wellness type to claim] end        
        if(cItem.HIF__c){
            if(String.isBlank(query_condition)){query_condition += ' HIF__c = true';}
            else{query_condition += ' or HIF__c = true ';}
        }
        if(cItem.HI__c){
            if(String.isBlank(query_condition)){query_condition += ' HI__c = true';}
            else{query_condition += ' or HI__c = true ';}
        }
        
        if(cItem.HPA__c && cItem.HPA_Less_Than_2_Yrs__c){
            if(String.isBlank(query_condition)){query_condition += ' (HPA__c = true and  Other_Rule_s__c = \'brokerPAC\')';}    
            else{query_condition += ' or (HPA__c = true and  Other_Rule_s__c = \'brokerPAC\') ';} 
        }
        
        if(cItem.HS__c && cItem.HS_Less_Than_3_Yrs_or_Broker_PAC__c){
            if(String.isBlank(query_condition)){query_condition += ' (HS__c = true and  Other_Rule_s__c = \'brokerPAC\')';}
            else{query_condition += ' or (HS__c = true and  Other_Rule_s__c = \'brokerPAC\') ';}
        }
        // 20190918 - Raistlin - GS user download doctor form
        if(cItem.HS__c && !cItem.HS_Less_Than_3_Yrs_or_Broker_PAC__c){
            if(String.isBlank(query_condition)){query_condition += ' MAT__c = true';}
            else{query_condition += ' or MAT__c = true ';}
        }
        if(cItem.CI__c){
            if(String.isBlank(query_condition)){query_condition += ' CI__c = true';}    
            else{query_condition += ' or CI__c = true ';}
        }
        if(cItem.DIS__c){
            if(String.isBlank(query_condition)){query_condition += ' DIS__c = true';}
            else{query_condition += ' or DIS__c = true ';}
        }
        if(cItem.OP__c){
            if(String.isBlank(query_condition)){query_condition += ' OP__c = true';}
            else{query_condition += ' or OP__c = true ';} 
        }
        if(cItem.OPF__c){
            if(String.isBlank(query_condition)){query_condition += ' OPF__c = true';}    
            else{query_condition += ' or OPF__c = true ';} 
        }
        if(cItem.MAT__c){
            if(String.isBlank(query_condition)){query_condition += ' MAT__c = true';}
            else{query_condition += ' or MAT__c = true ';}
        }
        
        if(isCustomer){query_condition_on_portal = 'Is_Customer__c = true';}
        else{query_condition_on_portal = 'Is_Broker__c = true';}
                
        String soql_claimTypeDoc = ClaimHelper.CLAIM_TYPE_DOCUMENT_ALL_FIELD;
        if(!String.isBlank(query_condition)){soql_claimTypeDoc += ' where Active__c = true and ' + query_condition_on_portal + ' and ('+query_condition+') ';}
        // system.debug('to see soql_claimTypeDoc: ' + soql_claimTypeDoc);
        
        List<Claim_Type_Document__c> claimTypeDocumentList = new List<Claim_Type_Document__c>();
        claimTypeDocumentList = Database.query(soql_claimTypeDoc);
        // system.debug('claimTypeDocumentList '+claimTypeDocumentList);
        Set<String> claimTypeDocIdSet = new Set<String>{};
        for(Claim_Type_Document__c cTypeDocItem: claimTypeDocumentList){
            claimTypeDocIdSet.add(cTypeDocItem.id);
        }
        Map<String,List<Attachment>> claimTypeDocIdAttachmentMap = loadClaimTypeDocumentAttachement(claimTypeDocIdSet);    //save data in claimTypeDocIdAttachmentMap
        system.debug('claimTypeDocIdAttachmentMap size: ' + claimTypeDocIdAttachmentMap.size() ) ;//HKITSFDC-413 debug only
        String typeNameEng ='';
        String typeNameChi ='';
        
        //SPS-344
        String templateName = isChi?'Claim: Send Attachment Email Chinese':'Claim: Send Attachment Email';
        EmailTemplate template = [SELECT Id, Body FROM EmailTemplate WHERE Name = :templateName limit 1];
        emailBody = template.Body;
        //SPS-344
        
        List<Map<String,String>> urlMapList = new List<Map<String,String>>{};
        for(Claim_Type_Document__c cTypeDocItem: claimTypeDocumentList){
            // system.debug('to see cTypeDocItem.Other_Rule_s__c: '+cTypeDocItem.Other_Rule_s__c);
            if(cTypeDocItem.Downloadable_as_PDF__c){
                // system.debug('to see cTypeDocItem: '+cTypeDocItem);
                //need to download
                List<Attachment> attList_tmp = new List<Attachment>{};
                if(claimTypeDocIdAttachmentMap.get(cTypeDocItem.id)!=null){attList_tmp =  claimTypeDocIdAttachmentMap.get(cTypeDocItem.id);}
                    List<String> attUrlList_tmp = new List<String>{};
                    for(Attachment att: attList_tmp){
                        String url = '';
                        url = ClaimHelper.ATT_EMAIL_PREFIX + att.id;
                        attUrlList_tmp.add(url);
                        //add url / name
                        Map<String,String> tmpMap = new Map<String,String>{};
                        if(isChi){tmpMap.put('name', cTypeDocItem.Document_Name_Chinese__c);}
                        else{tmpMap.put('name', cTypeDocItem.Document_Name__c);}
                        tmpMap.put('attId', att.Id);
                        tmpMap.put('url', url);
                        urlMapList.add(tmpMap);    
                    }
        
                if(!String.isBlank(cTypeDocItem.Attachment_Of_Benefit_Type_In_English__c)){
                    String targetTypeName = cTypeDocItem.Attachment_Of_Benefit_Type_In_English__c;
                    String[] typeArr = cTypeDocItem.Attachment_Of_Benefit_Type_In_English__c.split(';');
                    // system.debug('*********Attachment_Of_Benefit_Type_In_English__c List: ' + typeArr);
                    // system.debug('*********Attachment_Of_Benefit_Type_In_English__c size: ' + typeArr.size());
                    if(typeArr.size()> 1){
                        if(cItem.HPA__c && cItem.HS__c && cTypeDocItem.HPA__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[0] + '\',\'' + typeArr[1];
                        }else if(cItem.HPA__c && cTypeDocItem.HPA__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.HS__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[1];
                        }
                        
                        //for DIS / WD
                        if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0] + '”，“' + typeArr[1];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[1];
                        }
                    }
                    if(String.isBlank(typeNameEng)){typeNameEng = '\''+targetTypeName+'\'';}
                    else{typeNameEng += ' ,\''+targetTypeName+'\'';}
                }
                if(!String.isBlank(cTypeDocItem.Attachment_Of_Benefit_Type_In_Chinese__c)){
                    String targetTypeName = cTypeDocItem.Attachment_Of_Benefit_Type_In_Chinese__c;
                    String[] typeArr = cTypeDocItem.Attachment_Of_Benefit_Type_In_Chinese__c.split(';');
                    // system.debug('*********Attachment_Of_Benefit_Type_In_Chinese__c List: ' + typeArr);
                    // system.debug('*********Attachment_Of_Benefit_Type_In_Chinese__c size: ' + typeArr.size());
                    if(typeArr.size()> 1){
                        if(cItem.HPA__c && cItem.HS__c && cTypeDocItem.HPA__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[0] + '”，“' + typeArr[1];
                        }else if(cItem.HPA__c && cTypeDocItem.HPA__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.HS__c && cTypeDocItem.HS__c){
                            targetTypeName = typeArr[1];
                        }
                        
                        //for DIS / WD
                        if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0] + '”，“' + typeArr[1];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Temporary_or_Permanent_Dis__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[0];
                        }else if(cItem.DIS__c && cItem.Is_Selected_Waiver_of_Premium__c && cTypeDocItem.DIS__c){
                            targetTypeName = typeArr[1];
                        }
                    }
                    if(String.isBlank(typeNameChi)){typeNameChi= '“'+targetTypeName+'”';}
                    else{typeNameChi += '，“'+targetTypeName+'”';}
                }
            }
            //SPS-344
            emailBody = emailBody.replace('###imgUrl###', Label.Claim_Email_Header_Logo_URL);
            if(isCustomer){
                if(String.isNotBlank(cList[0].Created_From_Account_Person_Name__c)){
                    emailBody = emailBody.replace('###Name###',cList[0].Created_From_Account_Person_Name__c);}
            }else{
                if(String.isNotBlank(cList[0].Policy_Holder_Name__c)){
                    emailBody = emailBody.replace('###Name###',cList[0].Policy_Holder_Name__c);}
            }
            
            String typeName = isChi?typeNameChi:typeNameEng;
            // system.debug('typeName='+typeName);
            if(String.isNotBlank(typeName)){
                emailBody = emailBody.replace('###fileName###',typeName);}
            String fileUrl = '';
            for(Map<String,String> urlMap : urlMapList){
                //emailBody = emailBody + '<a href="' + urlMap.get('url') + '">' + urlMap.get('name') + '</a><br/>';
                fileUrl += '<a href="' + urlMap.get('url') + '">' + urlMap.get('name') + '</a><br/>';
            }
            // system.debug('fileUrl='+fileUrl);
            if(String.isNotBlank(fileUrl)){
                emailBody = emailBody.replace('###fileUrl###',fileUrl);}
        }
        emailBody = emailBody.replace('###Name###','');
        emailBody = emailBody.replace('###fileName###','');
        emailBody = emailBody.replace('###fileUrl###','');
        emailBody = '<![CDATA[' + emailBody + ']]>';
        //SPS-344
        return emailBody;
        
    }   
    
    public Map<String,List<Attachment>> loadClaimTypeDocumentAttachement(Set<String> claimTypeDocIdSet){
        Map<String,List<Attachment>> claimTypeDocIdAttachmentMap = new Map<String,List<Attachment>>();
        // system.debug('to see claimTypeDocIdSet at loadClaimTypeDocumentAttachement: '+claimTypeDocIdSet);
        String soql_attDoc = ClaimHelper.ATTACHMENT_URL_FIELD;
        soql_attDoc += ' where ParentId =: claimTypeDocIdSet';
        List<Attachment> attList = Database.query(soql_attDoc);
        // system.debug('to see attList : '+attList);
        for(Attachment att: attList){
            List<Attachment> tmp_attList = new List<Attachment>{};
            if(claimTypeDocIdAttachmentMap.get(att.ParentId) != null){tmp_attList = claimTypeDocIdAttachmentMap.get(att.ParentId);}
            tmp_attList.add(att);
            claimTypeDocIdAttachmentMap.put(att.ParentId, tmp_attList);
        }
        system.debug('to see claimTypeDocIdAttachmentMap: '+claimTypeDocIdAttachmentMap);
        return claimTypeDocIdAttachmentMap;
    } 

    public static void sendNotification(Id claimId){
        //JOBR-238 lijun select Is_Contain_Life_Policy__c and Is_Contain_GI_Policy__c
        //List<Claim__c> claimList = [select id, Is_Fast_Track__c, Is_Chosen_Sign_On_Screen__c, Is_Chosen_Send_Esignature__c, Is_Contain_Individual_Policy__c, Is_Contain_Group_Policy__c, Is_Created_By_Customer__c, Is_Created_By_Broker__c,All_Policy_IPMI__c, Policy__c, Policy_Holder_ID__c from Claim__c where id = :claimId];
        List<Claim__c> claimList = [select id,Is_Contain_Life_Policy__c,Is_Contain_GI_Policy__c,Is_Fast_Track__c, Is_Chosen_Sign_On_Screen__c, Is_Chosen_Send_Esignature__c, Is_Contain_Individual_Policy__c, Is_Contain_Group_Policy__c, Is_Created_By_Customer__c, Is_Created_By_Broker__c,All_Policy_IPMI__c, Policy__c, Policy_Holder_ID__c from Claim__c where id = :claimId];
        // system.debug('>> MyClaimController.sendNotification Future>>');
        if(!claimList.isEmpty()){
            Claim__c claim = claimList[0];
            // system.debug('>> MyClaimController.sendNotification>> claim: ' + claim.id);
            // system.debug('>> MyClaimController.sendNotification>> isIndividual: ' + claim.Is_Contain_Individual_Policy__c);
            // system.debug('>> MyClaimController.sendNotification>> isGroup: ' + claim.Is_Contain_Group_Policy__c);
            // system.debug('>> MyClaimController.sendNotification>> isFastTrack: ' + claim.Is_Fast_Track__c);
            // system.debug('>> MyClaimController.sendNotification>> isSignOnScreen: ' + claim.Is_Chosen_Sign_On_Screen__c);
            // system.debug('>> MyClaimController.sendNotification>> isSendEsignature: ' + claim.Is_Chosen_Send_Esignature__c);
            // system.debug('>> MyClaimController.sendNotification>> isCreatedByCustomer: ' + claim.Is_Created_By_Customer__c);
            // system.debug('>> MyClaimController.sendNotification>> isCreatedByBroker: ' + claim.Is_Created_By_Broker__c);
            
            Claim_Setting__c claimSetting = Claim_Setting__c.getInstance('Cigna');
            String directSalesId = claimSetting != null ? claimSetting.Direct_Sales_TM_Policy_Trigger_Id__c : '';
            //JOBR-238 lijun get the triggerId by Is_Contain_Life_Policy__c and Is_Contain_GI_Policy__c
            //String cusInitiatedId = claimSetting != null ? claimSetting.Brk_Policy_Cus_Initiated_Trigger_Id__c: '';
            String cusInitiatedId = claimSetting.Brk_Policy_Cus_Initiated_Trigger_Id__c;
            if(claim.Is_Contain_Life_Policy__c){
                cusInitiatedId = claimSetting.Brk_Policy_Cus_Initiated_CWWL_Trigger_Id__c;
            }
            String brkInitiatedId = claimSetting != null ? claimSetting.Brk_Policy_Brk_Initiated_Trigger_Id__c : '';
            ServiceCalloutHelper helper = new ServiceCalloutHelper();
            HttpCalloutVO.Notification notification = new HttpCalloutVO.Notification();
            notification.sourceCode = 'SFD';
            notification.ssn = claim.Policy_Holder_ID__c;
            // from CAM2, this only apply to customer portal.
            // if the it's a broker policy, use cusInitiatedId, if the policy is not a broker policy, use directSalesId.
            if(claim.Is_Created_By_Customer__c){
                notification.triggerId  = cusInitiatedId;
                //Comment by David for send notification issue
                /*PolicyCalloutHelper phelper = new PolicyCalloutHelper();
                HttpCalloutVO.Policy policy = phelper.getPolicyBasic(claim.Policy__c);
                if(policy != null && (policy.broker == null || String.isBlank(policy.broker.brokerAgentCode))){
                    notification.triggerId  = directSalesId;
                }*/
                HttpCalloutVO.Notification result = helper.sendNotification(notification);
                // system.debug('>> MyClaimController.sendNotification>> isSuccess: ' + result.isSuccess);
            } else if(claim.Is_Created_By_Broker__c){
                notification.triggerId  = brkInitiatedId;
            }
        }
    }

    //20190918 - Raistlin - get user is GS or not
    public boolean getIsGSUser(){
        MemberManagementHelper helper = new MemberManagementHelper();
        return helper.isGSUser(userSsn, null);
    }
    //20191024 - Raistlin - masterListHandler
    private List<SelectOption> masterListHandler(Integer masterTypeId,String languageKey){
        List<SelectOption> selectionList = new List<SelectOption>();
        
        MasterListCalloutHelper masterCalloutHelper = null;
        if(String.IsNotBlank(languageKey)){
            masterCalloutHelper = new MasterListCalloutHelper(masterTypeId, languageKey);
        }else{
            if(this.userLanguage == 'zh_HK' || this.userLanguage == 'zh_TW'){
                masterCalloutHelper = new MasterListCalloutHelper(masterTypeId, 'zh');
            }else{
                masterCalloutHelper = new MasterListCalloutHelper(masterTypeId, 'en');
            }
        }

        if(masterCalloutHelper != null){
            List<HttpCalloutVO.MasterList> masterList = (List<HttpCalloutVO.MasterList>) masterCalloutHelper.RequestMasterList();
            masterList.sort();
            system.debug('get masterList: ' + masterList);
            for(HttpCalloutVO.MasterList master : masterList){
                selectionList.add(new SelectOption(master.code, master.name));
            }
            system.debug('get selectionList: ' + selectionList);
        }
        return selectionList;
    }

    private void getPolicyPaymentForGS(String policyNumber){
        // 20211216 - minghua - JOBR-67, Performance Tuning - Claim submission
        List<HttpCalloutVO.Person> personList=new List<HttpCalloutVO.Person>();
        if (basePPBBList!=null&&basePPBBList.size()>0) {
            personList=basePPBBList;
        }else{
            PolicyCalloutHelper pHelper = new PolicyCalloutHelper();
            personList = pHelper.getPolicyPersonListBasicByCriteria(policyNumber, '','','',userSsn);
        }
        if(personList.size()>0 && personList[0].bankAccount!=null && String.IsNotBlank(personList[0].bankAccount.accountNumber)){
            bankAccInfoForGS = personList[0].bankAccount;       
            Map<String,String> tmp_nameInfoMap = new Map<String,String>{};
            tmp_nameInfoMap.put('accountNumber', bankAccInfoForGS.accountNumber);
            if(employeeMember!=null && employeeMember.Region==ClaimHelper.MEMBER_REGION_HK){
                tmp_nameInfoMap.put('bankCode', bankAccInfoForGS.bankCode); 
            }
            if(employeeMember.region == ClaimHelper.MEMBER_REGION_TW){
                tmp_nameInfoMap.put('swiftCode', bankAccInfoForGS.swiftCode);
            }
            bankAccInfoForGSJSon = JSON.serialize(tmp_nameInfoMap);
            
            if(employeeMember!=null && employeeMember.SSN!=userSsn && String.IsNotBlank(bankAccInfoForGSJSon)){
                cList[0].Bank_Account_Information__c = bankAccInfoForGSJSon;
            }
         }
    }

    //Nicole_20200225_GS Claim
    public void loadBankAccountRecordByPassingId(String claimId){
        bankAccountList = new List<Bank_Account__c>();
        if(String.IsNotBlank(claimId)){
            String soql = ClaimHelper.BANK_ACCOUNT_ALL_FIELD;
            soql += ' where Claim__c =\''+claimId+'\'';
             /* Nicole_GS Claim UAT_20210430_bankAccountList = Database.query(soql);*/
            onPolicyChange();
        }
    }
    
     /* Nicole_GS Claim UAT_20210430_public Boolean isAddBCEnable{get;set;}
    public Void addInputBankAccount(){
        if(isAddBCEnable){
            Bank_Account__c bank = new Bank_Account__c(Claim__c = cId,Policy_Number__c = policyOptions[0].getValue());            
            bankAccountList.add(bank);    
            onPolicyChange();     
        }
    }
    
    public Void removeInputBankAccount(){
        if(String.IsNotBlank(onChangeBankIndex) && !bankAccountList.isEmpty()){
            Bank_Account__c removeBank = bankAccountList.remove(Integer.valueof(onChangeBankIndex));
            if(removeBank.Id!=null){
                delete removeBank;
            } 
            onPolicyChange();
        }    
    }*/
    
    public String onChangeBankIndex{get;set;}
    public void showHKBankAccount(){
        if(String.IsNotBlank(onChangeBankIndex) && !bankAccountList.isEmpty()){
            Integer index = Integer.Valueof(onChangeBankIndex);                              
            bankAccountList[index].Is_Selected_Transfer_to_HK_Bank__c = true;
            bankAccountList[index].Is_Selected_Transfer_to_Oversea_Bank__c = false;
            bankAccountList[index].Account_Holder__c = null;
            bankAccountList[index].Bank_Account_Country_Code__c = null;
            bankAccountList[index].Bank_Account_No__c = null;
            bankAccountList[index].Bank_Code__c = null;
            bankAccountList[index].Bank_Name__c = null;
            bankAccountList[index].Branch_Code__c = null;
            bankAccountList[index].SWIFT_Code__c = null;
            
            isNextEnable_Bank = true;
            for(Bank_Account__c temBank : bankAccountList){            
                if(!temBank.Is_Selected_Transfer_to_HK_Bank__c &&  !temBank.Is_Selected_Transfer_to_Oversea_Bank__c){
                    isNextEnable_Bank = false;
                    break;
                }
            }    
        }
    }
    
    public void showOverseaBankAccount(){
        if(String.IsNotBlank(onChangeBankIndex) && !bankAccountList.isEmpty()){
            Integer index = Integer.Valueof(onChangeBankIndex);                              
            bankAccountList[index].Is_Selected_Transfer_to_HK_Bank__c = false;
            bankAccountList[index].Is_Selected_Transfer_to_Oversea_Bank__c = true;
            bankAccountList[index].Account_Holder__c = null;
            bankAccountList[index].Bank_Account_No__c = null;
            bankAccountList[index].Bank_Code__c = null;
            bankAccountList[index].Bank_Name__c = null;
            bankAccountList[index].Branch_Code__c = null;
            bankAccountList[index].SWIFT_Code__c = null;
            if(employeeMember.region == ClaimHelper.MEMBER_REGION_TW){
                bankAccountList[index].Bank_Account_Country_Code__c = ClaimHelper.COUNTRY_CODE_TW;
            }
            
            isNextEnable_Bank = true;
            for(Bank_Account__c temBank : bankAccountList){            
                if(!temBank.Is_Selected_Transfer_to_HK_Bank__c && !temBank.Is_Selected_Transfer_to_Oversea_Bank__c){
                    isNextEnable_Bank = false;
                    break;
                }
            }
        }
    }
    
    public boolean isNextEnable_Bank{get;set;}
    /*Nicole_GS Claim UAT_20210430_public boolean isPolicyValidationPass{get;set;}
    public String policyValidationErrorMessage{get;set;}
    public void onPolicyChange(){
        Set<String> selectedPolicyList = new Set<String>();
        isNextEnable_Bank = true;        
        isPolicyValidationPass = true;
        policyValidationErrorMessage = '';
        
        if(bankAccountList!=null && bankAccountList.size()>0){    
            for(Bank_Account__c bank : bankAccountList){            
                if(String.IsNotBlank(bank.Policy_Number__c)){selectedPolicyList.add(bank.Policy_Number__c);}
                if(!bank.Is_Selected_Transfer_to_HK_Bank__c && !bank.Is_Selected_Transfer_to_Oversea_Bank__c){isNextEnable_Bank = false;}
            }
        }else{
            isNextEnable_Bank = false; 
        }
               
        isAddBCEnable = false;        
        if(selectedPolicyList!=null && selectedPolicyList.size()>0){
            if(selectedPolicyList.contains(ClaimHelper.CLAIM_OPTION_ALL)){
                isAddBCEnable = false;
                if(bankAccountList.size()>1){
                    policyValidationErrorMessage = 'The policy is Duplicate!';
                    isPolicyValidationPass = false;
                }
            }else{
                if(selectedPolicyList.size()<bankAccountList.size()){
                    policyValidationErrorMessage = 'The policy is Duplicate!';
                    isPolicyValidationPass = false;
                }
                
                if(policyOptions.size()>1 && bankAccountList.size()<policyOptions.size()-1){
                    isAddBCEnable = true;
                    policyValidationErrorMessage = 'The policy is missed!';
                    isPolicyValidationPass = false;
                }
            }
            
            for(Integer i=0; i<policyOptions.size(); i++){
                if(selectedPolicyList.contains(policyOptions[i].getValue())){policyOptions[i].setDisabled(true);}
                else{policyOptions[i].setDisabled(false);}
            }
        }
    }
    
    public void validateBankPolicy(){
        if(!isPolicyValidationPass && String.IsNotBlank(policyValidationErrorMessage)){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, policyValidationErrorMessage));}             
    }*/
    public boolean isPolicyValidationPass{get;set;}
    public Boolean isAddBCEnable{get;set;}
    public void onPolicyChange(){}
    public void validateBankPolicy(){}
    public void addInputBankAccount(){}
    public void removeInputBankAccount(){}    

    public PageReference getPersonBasicAfterLoadPage(){
        for(Claim__c cItem: cList){            
            String PISsn = '';
            if(cItem.Person_s_Insured__c != null){
                PISsn = cItem.Person_s_Insured__c;
                //reset policy data
                if(previousSelectedSsn != PISsn){
                    previousSelectedSsn = PISsn ;
                    cItem.Policy__c = null;
                }
            }

            if(wPolicyList_selected.size()>0 && !String.isBlank(PISsn)){
                for(ClaimHelper.WrapperPolicy wPolicyItem: wPolicyList_selected){
                    String pNum_tmp = '';
                    pNum_tmp = wPolicyItem.policyNum;                    
                    pNum_tmp = pNum_tmp.trim();
                    if(!String.isBlank(pNum_tmp) && wPolicyItem.PIMapList != null && wPolicyItem.PIMapList.size()>0){
                        for(Map<String,String> tmpMap: wPolicyItem.PIMapList){
                            String ssnFromMap = '';
                            if(tmpMap.get('ssnNumber') != null){ssnFromMap = tmpMap.get('ssnNumber');}
                            ssnFromMap = ssnFromMap.trim();
                            if(!String.isBlank(ssnFromMap) && ssnFromMap.equals(PISsn)){
                                system.debug('start getting person basic async ');
                                if(!isHideWSForTesting){getPersonBasic(PISsn, true);}
                                system.debug('completed getting person basic async ');
                            }
                        }
                    }                   
                }
            }
        }
        return null;
    }
    // 20200817 - minghua - Performance issue in claim flow Step 2
    public PageReference performanceGetPersonBasic(){
        if(isCustomer){
            if(steps == 7){
                    if(cList[0].Person_s_Insured__c != null){
                        // system.debug('getPersonBasic Performance issue in claim flow Step 2');
                        getPersonBasic(cList[0].Person_s_Insured__c, true);
                    }
            }
        }else{
            if(steps == 5){
                if(cList[0].Person_s_Insured__c != null){
                    // system.debug('getPersonBasic Performance issue in claim flow Step 2');
                    getPersonBasic(cList[0].Person_s_Insured__c, true);
                }
            }
        }
        return null;
    }

    //20210803 - Kirk - CR48, ClaimSD is claim symptoms and diagnosis
    public class ClaimSD{
        public String sDCode{get;set;}
        public String sDDscpEN{get;set;}
        public String sDDscpTC{get;set;}
        public Boolean isDesignate{get;set;}
    }
    public void loadClaimSymptomsAndDiagnosis(){
        List<Claim_Symptoms_And_Diagnosis__c> sDList = new List<Claim_Symptoms_And_Diagnosis__c>();
        sDList=[SELECT Id,Diagnosis_Code__c,Diagnosis_Description_EN__c,Diagnosis_Description_TC__c,Is_Designated__c,Benefit_Code__c FROM Claim_Symptoms_And_Diagnosis__c ORDER BY Sequence__c];
        if (sDList!=null&&!sDList.isEmpty()) {
            for (Claim_Symptoms_And_Diagnosis__c item : sDList) {
                ClaimSD claimSD=new ClaimSD();
                claimSD.sDCode=item.Diagnosis_Code__c;
                claimSD.sDDscpEN=item.Diagnosis_Description_EN__c;
                claimSD.sDDscpTC=item.Diagnosis_Description_TC__c;
                claimSD.isDesignate=item.Is_Designated__c;
                if (claimSDBenefit.containsKey(item.Benefit_Code__c)) {
                    claimSDBenefit.get(item.Benefit_Code__c).add(claimSD);
                }else{
                    List<ClaimSD> sDItem = new List<ClaimSD>();
                    sDItem.add(claimSD);
                    claimSDBenefit.put(item.Benefit_Code__c, sDItem);
                }
            }
        }
    }

    public void loadClaimSymptoms(String benefitClaim){
        if (String.isNotBlank(benefitClaim)) {
            benefitClaim=benefitClaim.replaceAll(',','').trim();
            if (benefitClaim.length()==1&&(benefitClaim=='A'||benefitClaim=='D'||benefitClaim=='E'||benefitClaim=='F')) {
                claimSDList=claimSDBenefit.get(benefitClaim);
                claimDesignated=new Map<String,Boolean>();
                for (ClaimSD item: claimSDList) {
                    claimDesignated.put(item.sDCode, item.isDesignate);
                }
            }
        }
    }

    /**
     * check group policy is or not economist policy
     * @Author   minghua
     * @DateTime 2021-09-21T16:21:48+0800
     * @param    selectedPolicy    
     */
    private void checkEconomistPolicy(String selectedPolicy){
        isEconomistPolicy=false;
        String economistPolicy=Claim_Setting__c.getInstance('Cigna').Group_Policy_Equal_To_Economist__c;
        if (String.isNotBlank(economistPolicy)) {
            List<String> pNoList = selectedPolicy.split(',');
            if (pNoList!=null && !pNoList.isEmpty()) {
                for (String item : pNoList) {
                    if (economistPolicy.containsIgnoreCase(item)) {
                        isEconomistPolicy=true;
                        break;
                    }
                }
            }
        }
    }
    /**
     * check group policy is or not ESF
     * @Author   Rancho
     * @DateTime 2021-11-08T15:03:48+0800
     * @param    selectedPolicy    
     */
    @TestVisible
    private Boolean checkESFPolicy(String selectedPolicy){
        GS_ESF_Policy_Match_Setting__c matchRecord = GS_ESF_Policy_Match_Setting__c.getInstance(selectedPolicy);
        if(null != matchRecord && matchRecord.Policy_Type__c == 'ESF'){
            return true;
        }
        return false;
    }
    /**
     * Check user only selected OP claim type
     * @Author   minghua
     * @DateTime 2021-09-21T17:48:45+0800
     * @param    selectedClaimType
     */
    private void checkOnlySelectedOP(String selectedClaimType){
        onlySelectedOP=false;
        List<String> claimTypeList=selectedClaimType.split(';');
        if (claimTypeList!=null&&!claimTypeList.isEmpty()) {
            for (String item : claimTypeList) {
                if (item.equalsIgnoreCase('OP')||item.equalsIgnoreCase('OPF')) {
                    onlySelectedOP=true;
                }else{
                    onlySelectedOP=false;
                    break;
                }
            }
        }
    }

    /********************************************************************
     * generateSignatureTC
     * @decs Rancho_JOBR133_20220530 - generate claim flow T&C according to selected policy
     * 1. only contains life -> life entity, 2. only contains GI -> GI entity, 3. contains both life and GI or ws returned indicator is null -> both entity
     * @author ranzhao@deloitte.com.cn
     * @JOBR-184: JOBR-232 edited by Kermit
    ********************************************************************/
    public void generateSignatureTC(){
        String tempStr;
        if(!localIsPIForTC){
            tempStr = Label.Submit_Claim_T_C_Selected_PI_is_PH_3 + Label.Submit_Claim_T_C_Selected_PI_is_PH_4 + Label.Submit_Claim_T_C_Selected_PI_is_PH_5 + Label.Submit_Claim_T_C_Selected_PI_is_PH_6;
        }else{
            tempStr = Label.Submit_Claim_T_C_Selected_PI_is_not_PH_1 + Label.Submit_Claim_T_C_Selected_PI_is_not_PH_2 + Label.Submit_Claim_T_C_Selected_PI_is_not_PH_3;
        }
        
        if(cList[0].Is_Contain_Life_Policy__c && !cList[0].Is_Contain_GI_Policy__c){
            claimFlowTerms = tempStr.replace('###EntityName###', Label.Chubb_Life_Entity_Name);
            claimFlowTerms = claimFlowTerms.replace('###EntityAbbr###', Label.Life_Abbr_Name).replace('#Abbr#',Label.Life_Abbr_Name).replace('###EntityAbbr2###',Label.Life_Abbr_Name);
        }else if(!cList[0].Is_Contain_Life_Policy__c && cList[0].Is_Contain_GI_Policy__c){
            claimFlowTerms = tempStr.replace('###EntityName###', Label.GI_Entity_Name);
            claimFlowTerms = claimFlowTerms.replace('###EntityAbbr###', Label.GI_Abbr_Name).replace('#Abbr#',Label.GI_Abbr_Name).replace('###EntityAbbr2###',Label.GI_Abbr_Name);
        }else{
            claimFlowTerms = tempStr.replace('###EntityName###', Label.Chubb_And_Cigna_Entity_Name);
            claimFlowTerms = claimFlowTerms.replace('###EntityAbbr###', Label.Both_Life_And_GI_Abbr_Name).replace('#Abbr#',Label.Both_Life_And_GI_Abbr_Name).replace('###EntityAbbr2###',Label.Both_Life_And_GI_Abbr_Name_2);
        }
        System.debug('claimFlowTerms: '+claimFlowTerms);
        
        String picsDocName = '';
        Portal_Settings__c portalDocumentURL = Portal_Settings__c.getInstance();
        String portal;
        if(isCustomer){
            portal = portalDocumentURL.Customer_Portal_Url__c;
            if(cList[0].Is_Contain_Life_Policy__c && !cList[0].Is_Contain_GI_Policy__c){
                picsDocName = Label.Life_PIC_Doc_Customer;
            }else if(!cList[0].Is_Contain_Life_Policy__c && cList[0].Is_Contain_GI_Policy__c){
                picsDocName = Label.GI_PIC_Doc_Customer;
            }else{
                picsDocName = Label.Both_Life_And_GI_PIC_Doc_Customer;
            }
        }else{
            portal = portalDocumentURL.Broker_Portal_Url__c;
            if(cList[0].Is_Contain_Life_Policy__c && !cList[0].Is_Contain_GI_Policy__c){
                picsDocName = Label.Life_PIC_Doc_Broker;
            }else if(!cList[0].Is_Contain_Life_Policy__c && cList[0].Is_Contain_GI_Policy__c){
                picsDocName = Label.GI_PIC_Doc_Broker;
            }else{
                picsDocName = Label.Both_Life_And_GI_PIC_Doc_Broker;
            }
        }
        if(this.userLanguage == 'zh_TW'){
            //picLink = portalDocumentURL.File_Download_URL__c + CignaUtil.getBrokerPersonalInformationCollectionStatement_chi();
            picLink = CignaUtil.getPersonalInformationCollectionStatement_chi();                
        }else{
            //picLink = portalDocumentURL.File_Download_URL__c + CignaUtil.getBrokerPersonalInformationCollectionStatement_eng();
            picLink = CignaUtil.getPersonalInformationCollectionStatement_eng();
        } 
        // List<Document> picsDoc = [SELECT Id FROM Document WHERE DeveloperName = :picsDocName LIMIT 1];
        // if(picsDoc.size() == 1){
        //     picLink = portal + '/servlet/servlet.FileDownload?file='+picsDoc.get(0).Id;
        //     system.debug('[MyClaimSubmitController] picLink='+picLink);
        // }
    }
}