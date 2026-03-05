/********************************************************************************
Apex Class Name - ClaimHelper    //CommonUtils_WC
Version - 1.0
Created Date - Nov 08, 2016
@description helper class to share common info, static string, all fields for query

Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer             DateDescription
* ------    -----------     ------------            -----------------------
* 1.0       Wincy             26/10/2016               Original Version
* 1.1       Wincy             09/12/2016               change naming
********************************************************************************/
global class ClaimHelper{
    global static final Integer MAX_PAGING_COUNT_RECORD = Integer.valueOf(Claim_Setting__c.getInstance('Cigna').Max_Record_Count_Per_Page__c);    //list of record limit for paging for WS
    global static final Integer MAX_COUNT_RECORD = Integer.valueOf(Claim_Setting__c.getInstance('Cigna').Max_Record_GetPolicyListBasicByCriteria__c);    //record limit for WS
    global static final String EMAIL_ADDRESS_QHMS = Claim_Setting__c.getInstance('Cigna').Email_Address_QHMS__c;    //send email to QHMS with claim form attachement   
    //attachment prefix
    global static final String ATT_BRK_PREFIX = System.URL.getSalesforceBaseUrl().toExternalForm()+ Site.getPathPrefix() + '/servlet/servlet.FileDownload?file=';
    global static final String ATT_CUS_PREFIX = System.URL.getSalesforceBaseUrl().toExternalForm()+ Site.getPathPrefix() + '/servlet/servlet.FileDownload?file=';    
    global static final String ATT_EMAIL_PREFIX = Claim_Setting__c.getInstance('Cigna').Claim_Form_Download_Prefix__c;       
    //picklist field
    global static final String RELATIONSHIP_POLICY_HOLDER = 'Policy Holder';
    global static final String RELATIONSHIP_POLICY_INSURED_PERSON = 'Policy Insured Person';  
    global static final String GROUP_POLICY_RELATIONSHIP = 'Group Policy Relationship';
    global static final String INDIVIDUAL_POLICY_RELATIONSHIP = 'Individual Policy Relationship';    
    //recordTypeName
    global static final String POLICY_INDIVIDUAL = 'Individual Policy';
    global static final String POLICY_GROUP = 'Group Policy';   
    
    //query field
    global static final String ATTACHMENT_ALL_FIELD = 'SELECT Id, Name, ParentId, LastModifiedDate, '
        +'Body, BodyLength, ContentType, Description, IsPrivate, OwnerId '
        +'FROM Attachment ';//attachmentAllField;           
    
    global static final String ATTACHMENT_URL_FIELD = 'SELECT Id, Name, ParentId, LastModifiedDate, '
        +'IsPrivate, OwnerId,BodyLength '//PI20 jack add
        +'FROM Attachment ';//attachmentURLField;                
    
    global static final String ACCOUNT_ALL_FIELD = 'select id, name, RecordTypeId, RecordType.Name, Salutation, Firstname, Lastname, AccountNumber, Site,AccountSource, AnnualRevenue, PersonAssistantName, PersonAssistantPhone, BillingAddress,PersonBirthdate, IsCustomerPortal, Jigsaw, PersonDepartment, Description, PersonDoNotCall, PersonEmail,PersonHasOptedOutOfEmail, NumberOfEmployees, Fax, PersonHasOptedOutOfFax, PersonHomePhone,Industry, PersonLastCURequestDate, PersonLastCUUpdateDate, PersonLeadSource,PersonMailingAddress, PersonMobilePhone, PersonOtherAddress, PersonOtherPhone, Ownership, IsPartner,Phone, Rating, ShippingAddress, Sic, SicDesc, TickerSymbol, PersonTitle, Type, Website,SSN__c, Gender__c, Marital_Status__c, G4S__Customer_ID__pc '
        +'from Account ';//accountAllField;       
    
    global static final String POLICY_ALL_FIELD = 'select id, name, RecordTypeId, RecordType.Name, Insured__c, Amount__c, Bank_Account_No__c, Beneficiary__c, Benefit_Type__c, Coverage_Period_From__c, '
        +'Coverage_Period_To__c, Currency__c, Date_of_Birthday__c, Debt_Date__c, Maturity_Date__c, Modal_Premium__c, Paid_to_date__c,Pay_To_Date__c, Payment_Method__c, Per_Mode_Premium_Amount__c, Person_Insured_ID__c, Person_Insured_Name__c, Plan_code__c,Plan_Name__c, Plan_Type__c, Policy_Effective_Date__c, Policy_Holder_Email_Address__c, Policy_Holder_ID__c, Policy_Holder_Name__c, Policy_Holder_Phone_Number__c,toLabel(Policy_Status__c), Premium_Pay_Mode__c, Product_Name__c, Source_System__c, Sum_Insured__c '
        +'from Policy__c ';//policyAllField;
    
    //Updated by Nicole for Encryption: Remove Is_PI_Greater_Then_18__c
    global static final String CLAIM_ALL_FIELD = 'select id, name,Is_Contain_Individual_Life_Policy__c, Is_Selected_Waiver_of_Premium__c, Is_Selected_Temporary_or_Permanent_Dis__c, HS_Less_Than_3_Yrs_or_Broker_PAC__c, HPA_Less_Than_2_Yrs__c, Is_Chosen_Send_Esignature__c, Is_Chosen_Sign_On_Screen__c, Is_Contain_Life_Policy__c, '
        +'All_Policy_IPMI__c, Ask_If_More_Than_One_Claim__c, All_Claims_Related_To_Same_Event__c, Is_Selected_A__c, Is_Selected_B__c, Is_Selected_C__c, Is_Selected_D__c, Is_Selected_E__c, Is_Selected_F__c, Is_Selected_G__c, Is_Selected_H__c, Is_Selected_I__c, Cannot_Enter_Bank_Account_Information__c, Is_Displayed_For_Customer__c, Amount_Of_Sum_Insured__c, Allow_Types_Of_Doctor_To_Claim__c, sj_OP_d__c, Selected_Question_s__c, Is_Contain_Group_Policy__c, Is_Contain_Individual_Policy__c, '
        +'Is_Prefer_Payment_in_Policy_Currency__c, Is_Selected_Transfer_to_HK_Bank__c, Is_Selected_Transfer_to_Oversea_Bank__c, Display_Currency_Type__c, Display_Currency_Type_In_Chi__c, Is_Contain_US_Policy__c, Selected_Type_Of_Doctor__c, Selected_Type_Of_Doctor_In_Chi__c, '
        +' Display_Selected_Benefit_Type_s_In_Chi__c, sj_OP_a__c, sj_HIF_d__c, Is_All_Selected_Policy_EffDate_6_month__c , OPF__c, All_Non_IPMI_policy__c, is_Selected_Broker_PAC_plan__c, PI_without_any_Sen_Code_N6__c, '
        +'Policy_Holder_ID__c, E_Signature_Link__c, Created_From_Account_Person_Name__c, Policy_Holder_Email_Address__c, Policy_Holder_Contact_No__c, Person_Insured_Gender__c, Person_Insured_Date_Of_Birth__c, Policy_Holder_Name__c, Submission_Date__c, Is_Created_By_Broker__c, Is_Created_By_Customer__c, Is_Fast_Track__c, Is_Using_Chinese_Version__c, Date_To_Send_Email_Reminder__c, Visit_Date__c, Is_Person_Insured_Claim__c, Person_Insured_Name__c, Policy_Holder__c, Email_Address_to_send__c, What_is_the_phone_of_hospital_doctor__c, Do_you_have_the_admission_details__c, '
        +'Bank_Account_Holder__c, Bank_Account_Name__c, Bank_Account_Number__c, Bank_Branch_Address__c, '
        +'Bank_Branch_Code__c, Bank_Code__c, Bank_Name__c, Bank_Routing_Code_ABA__c, Bank_SWIFT__c, '
        +'What_would_you_like_to_claim_for__c, What_is_of_work_allocation_Clerical__c, What_is_of_work_allocation_Manual__c, Admitted_and_discharged_from_hospital__c, '
        +'Display_Selected_Benefit_Type_s__c, Bank_Account_Information__c, RecordTypeId, RecordType.Name, Steps__c, Person_s_Insured__c, Account__c,HIF__c, HI__c, HPA__c, HS__c, DIS__c, OP__c, CI__c, MAT__c, '
        //Added by minglei 2018.05.15 [add Wellness type to claim] start
        +'WL__c, Is_Selected_J__c, createdBy.name,createdById,ownerId,' // Added by IBM(Roy) due to PPS-21(OWNer related field)
        //Added by minglei 2018.05.15 [add Wellness type to claim] end 
        +'Account__r.name, Account__r.Salutation, Account__r.firstname, Account__r.lastname,Account__r.SSN__c, Account__r.Gender__c, Owner.Name,Claim_Type__c, Date_of_stop_working_due_to_disability__c,Do_you_stay_in_hospital__c, Information_from_other_companies__c, Information_of_benifit_from_other_comp__c, Is_there_any_room_charge__c, '
        //20210803 - Kirk - CR48
        //Rancho_CR48_20210706: add Is_Public_Hospital__c
        +'What_Are_Your_Symptoms_And_Diagnosis__c,Ask_If_Include_Separate_Medication__c,Consultation_Currency_Code__c,Is_Public_Hospital__c, '        
        +'Payment_Currency__c, Please_input_the_amount_of_charge_HKD__c,Please_input_the_amount_of_charge_Con__c,Please_input_the_amount_of_charge_Oth__c,Please_input_the_amount_of_charge_Med__c,Policy__c, Receive_reimbursement_from_other_comp__c,Is_Insured_for_Similar_Benefits__c, Have_All_Documents_To_Upload__c,Still_on_sick_leave__c, Type_of_benefit_to_claim__c,What_is_the_hospital_doctor_name__c, What_is_your_1st_consultation_date__c,toLabel(Status__c) status_translated,Status__c, '
        +'CreatedDate, LastModifiedDate,Certificate_Number__c, ' //Add by Manuel on Sep 28 that supplement parameter for claim request
        +'RecordType.developerName, ' //add by minghua for claim submitClaim - 20190718
        +'Incurred_Country_Code__c,Incurred_Country_Name__c,Incurred_Currency_Code__c,Incurred_Currency_Name__c,Bank_Account_Sync_Up_Status__c, '/*add by Raistlin foor GS claim -20191024*/      
        +'Making_other_insurance_claim__c' // 20200107-minghua-JR1811
        // 20200928 - minghua - new Claim flow
        +',Selected_Type_Of_Doctor_Display__c,Is_Selected_K__c,Is_Selected_L__c,Is_Selected_M__c,Is_Selected_N__c,Is_Selected_O__c,Is_Selected_P__c,Is_Selected_Q__c,Is_Selected_R__c,Is_Selected_S__c,Fast_Track_Claim__c '//20210803 - Kirk - CR48
        +',Is_Contain_GI_Policy__c ' // Rancho_JOBR133_20220530
        +',Batch_ID__c,Caller_Platform__c ' // Quinto_MRP-242_20230911 //JOBR-375 GOP claim in analyst report
        +'from Claim__c ';    //claimAllField;
    
    global static final String CLAIM_TYPE_DOCUMENT_ALL_FIELD = 'select id, name, Active__c, MAT__c, Other_Rule_s__c,Attachment_Of_Benefit_Type_In_Chinese__c, Attachment_Of_Benefit_Type_In_English__c, ACC__c, CI__c, DIS__c,Document_Name__c, Document_Name_Chinese__c, Downloadable_as_PDF__c,HI__c, HIF__c, HPA__c, HS__c,OP__c, OPF__c, TTD__c, '
        //Added by minglei 2018.05.15 [add Wellness type to claim] start
         +'WL__c, '
        //Added by minglei 2018.05.15 [add Wellness type to claim] end 
        +'Is_Broker__c, Is_Customer__c,CreatedDate, LastModifiedDate '
        +'from Claim_Type_Document__c ';    //claimTypeDocumentAllField;    
    
    //global static final String PLAN_CODE_CLAIM_TYPE_ALL_FIELD = 'select id, name, Broker_PAC__c, IPMI__c, A_General_Practitioner__c, ACC__c, B_Specialist_Practitioner__c, Benefit_Code_Can_Choose__c, '
    global static final String PLAN_CODE_CLAIM_TYPE_ALL_FIELD = 'select id, name, Wonder_Woman__c, Broker_PAC__c, IPMI__c, A_General_Practitioner__c, ACC__c, B_Specialist_Practitioner__c, Benefit_Code_Can_Choose__c, '   //IBM KOU WONDER WOMAN     
        +'C_Laboratory_Testing_X_Ray__c, CI__c, Claim_Type__c, D_Chinese_Herbalist_Bonesetter_Acupunc__c, DIS__c,E_Physiotherapy_Chiropractic__c, F_Long_Term_Prescribed_Medicine__c, Fast_Track_Allow__c, G_Medical_Check_Up_Vaccination__c,H_Dental__c, HI__c, HIF__c, HPA__c, HS__c, I_Others__c, Inforce_Policy__c, MAT__c, '
        //Added by minglei 2018.05.15 [add Wellness type to claim] start
        +'J_Wellness__c, K_Physiotherapy__c,L_Dentist__c,M_Speech_Therapy__c,N_Occupational_Therapy__c,O_Dietetic_Guidance__c,P_Prescribed_Western_Medicine_pharmacy__c,Q_Diagnostic_Imaging_Laboratory_Test__c,R_Health_Check_Up__c,S_Vaccination__c,WL__c,Is_Entitled__c,Allow_Government_Hospital_Visit__c, '//20210803 - Kirk - CR48 //20210917 - Kirk - T_Tui_Na__c removed // Rancho_CR48_20210706: Allow_Government_Hospital_Visit__c
        //Added by minglei 2018.05.15 [add Wellness type to claim] end 
        //Rancho_Covid19_20221019 - add field
        +'Covid_19_Benefit__c, MIS__c, OP__c, OTH__c, Package_Code__c, Package_Desc__c, Plan_code__c,Plan_Title__c, Product_Code__c, Product_Name__c, Rate_Scale__c, SD__c, System__c, TTD__c, WP__c,CreatedDate, LastModifiedDate '
        +'from Plan_Code_Claim_Type__c ';    //planCodeClaimTypeAllField;       
    
    global static final String CLAIM_TYPE_CODE_MAPPING_FROM_WS_ALL_FIELD = 'select id, name, Claim_Type_Display_Wordings_Chinese__c, Claim_Type_Display_Wordings_English__c, CTM_CODE__c, CTM_CODE_WS__c, CTM_DESC__c,CTM_DESC_WS__c, CTM_SYSTEM__c '
                +'FROM Claim_Type_Code_Mapping_From_WS__c ';
    
    //Nicole_20200226_GS Claim
    global static final String BANK_ACCOUNT_ALL_FIELD = 'Select Id,Account_Holder__c,Bank_Account_Country__c,Bank_Account_Country_Code__c,Bank_Account_No__c,Bank_Code__c,Bank_Name__c,Branch_Code__c,Claim__c,Policy_Number__c,SWIFT_Code__c,Is_Selected_Transfer_to_HK_Bank__c,Is_Selected_Transfer_to_Oversea_Bank__c '
                  + 'From Bank_Account__c ';
    global static final Integer MASTER_TYPE_CURRENCY = 9;
    global static final Integer MASTER_TYPE_BANK = 8;
    global static final Integer MASTER_TYPE_COUNTRY = 1;
    global static final Integer MASTER_TYPE_INCURRED_COUNTRY = 10;
    global static final String  COUNTRY_CODE_HK = '852';
    global static final String  COUNTRY_CODE_TW = '886';
    global static final String  MEMBER_REGION_HK = 'HK';
    global static final String  MEMBER_REGION_TW = 'TW';
    global static final String  CURRENCY_CODE_HK = 'HKD';
    global static final String  CURRENCY_CODE_TW = 'TWD';
    global static final String  CLAIM_OPTION_ALL = 'All';
    global static final String  GS_BC_SYNC_UP_STATUS_SUCCESS = 'SUCCESS';
    global static final String  GS_BC_SYNC_UP_STATUS_FAILURE = 'FAILURE';
                     
    //claim status
    global static final String CLAIM_STATUS_CANCELLED = System.Label.Cancelled;    //claimStatus_Cancelled;
    global static final String CLAIM_STATUS_PROCESSING = System.Label.Processing;    //claimStatus_Processing;
    global static final String CLAIM_STATUS_PAID = System.Label.Paid;    //claimStatus_Paid
    global static final String CLAIM_STATUS_REVERSAL = System.Label.Reversal;    //claimStatus_Reversal;
    global static final String CLAIM_STATUS_REJECTED= System.Label.Rejected;    //claimStatus_Rejected;
    global static final String CLAIM_STATUS_PENDING_INFORMATION = System.Label.Pending_Information;    //claimStatus_Pending_Information;
    global static final String CLAIM_STATUS_NOT_SUBMITTED = System.Label.Not_Submitted;    //claimStatus_Not_Submitted;    //claim record created at salesforce
    global static final String CLAIM_STATUS_SENT = System.Label.Sent;    //claim record created at salesforce and sent to System db
    
    /** 170317
    //plan status mapping
    global static final Map<String, String> claimStatusCode_NCSMap;
    global static final Map<String, String> claimStatusCode_QNCSMap;
    global static final Map<String, String> claimStatusCode_GroupClaimMap;    
    static{       
        claimStatusCode_NCSMap = new Map <String, String>{};
        claimStatusCode_NCSMap.put('C', CLAIM_STATUS_CANCELLED);
        claimStatusCode_NCSMap.put('N', CLAIM_STATUS_PROCESSING );
        claimStatusCode_NCSMap.put('P', CLAIM_STATUS_PAID );
        claimStatusCode_NCSMap.put('Q', CLAIM_STATUS_REVERSAL );
        claimStatusCode_NCSMap.put('R', CLAIM_STATUS_REJECTED );
        claimStatusCode_NCSMap.put('S', CLAIM_STATUS_PENDING_INFORMATION );
    }
    
    static{       
        claimStatusCode_QNCSMap = new Map <String, String>{};
        claimStatusCode_QNCSMap.put('C', CLAIM_STATUS_CANCELLED);
        claimStatusCode_QNCSMap.put('S_WO', CLAIM_STATUS_PROCESSING );
        claimStatusCode_QNCSMap.put('P', CLAIM_STATUS_PAID );
        claimStatusCode_QNCSMap.put('Q', CLAIM_STATUS_REVERSAL );
        claimStatusCode_QNCSMap.put('R', CLAIM_STATUS_REJECTED );
        claimStatusCode_QNCSMap.put('S_W', CLAIM_STATUS_PENDING_INFORMATION );
    }
    
    static{      
        claimStatusCode_GroupClaimMap = new Map <String, String>{};
        claimStatusCode_GroupClaimMap.put('REJ', CLAIM_STATUS_REJECTED  );
        claimStatusCode_GroupClaimMap.put('APP', CLAIM_STATUS_PAID );
    }
    **/
    
    /**
        WS call
        GetPersonBasic  
        GetClinicVisitCount  
        GetPolicyListBasicByCriteria 
        GetClaimListBasicByCriteria  
        GetPolicyPaymentBasic   
    **/   
    global Class WrapperClaimTypeRelatedDocument{   
        global Boolean isPdf {get;set;}
        global String rules {get;set;}
        global String docId {get;set;}
        global String attIdPrefix {get;set;}
        global String docTypeName_chi {get;set;}    //e.g. sick leave cert
        global String docTypeName_eng {get;set;}    //e.g. sick leave cert
        global List <String> attUrlList {get;set;}
        global List <Attachment> attList {get;set;}
        global List <Claim_Type_Document__c> cTypeDocList {get;set;}
        global WrapperClaimTypeRelatedDocument() {}
    }
    
    global Class WrapperClaimUploadAttachment{
        global String attId {get;set;}
        global String attName {get;set;}
        global String relatedClaimTypeDocumentId {get;set;}
        global String parentClaimId {get;set;}
        global Attachment attItem {get;set;}
        global WrapperClaimUploadAttachment() {}
    }
    
    global Class WrapperClaim{    //GetClaimListBasicByCriteria by login id / policy number
        global Boolean isIndividual {get;set;}
        global String policyType {get;set;}
        global String policyNum {get;set;}
        global String claimNum {get;set;}
        global String PIName {get;set;}
        global Date submitDate {get;set;}
        global Date claimDate {get;set;}
        global String claimStatusCode {get;set;}
        global String ssnNum {get;set;}
        global String certNum {get;set;}
        global String memberName {get;set;}
        global String consultationDate {get;set;}    //Consultation date (admission date) - Loss period from
        global String dischargeDate {get;set;}    //Discharge date - Loss period to
        global String claimType {get;set;}         
        global String status {get;set;}         
        global String accId {get;set;}
        global Claim__c cItem {get;set;}    //get from sf
        global String claimPIAge {get;set;}  //Added by Nicole for Encryption CR
        // Rancho_PI101_20230428 - set default value to avoid null pointer error
        global Boolean isPIGreaterThan18 {get;set;}{isPIGreaterThan18=false;} //Added by Nicole for Encryption CR        
        global HttpCalloutVO.Claim cItem_in {get;set;}    //get from ws - individual
        global HttpCalloutVO.Claim cItem_grp {get;set;}    //get from ws - group                      
        global WrapperClaim() {}
        // MR-376 Missing claim history record under MyPolicy Claim History tab
        public Integer compareTo(Object compareTo) {
            WrapperClaim compareToClaim = (WrapperClaim)compareTo;
            Integer result = 0;
            if(submitDate != null && compareToClaim.submitDate == null){
                result = 1;
            }else if(submitDate >= compareToClaim.submitDate){
                result = 1;
            }else if(submitDate == null && compareToClaim.submitDate != null){
                result = -1;
            }else if(submitDate < compareToClaim.submitDate){
                result = -1;
            }
            return result;
        }
    }
    
    global Class WrapperPolicy{    //GetPolicyListBasicByCriteria - by login id
        //IBM KOU 20180531 ticket productType start
        global String productType {get;set;}
        //IBM KOU 20180531 ticket productType end 
        global Boolean isLifePolicy {get;set;}
        global Boolean isTotalAndPermanentDisability {get;set;}
        global Boolean isBrokerPAC {get;set;}
        global Boolean isLessThan6Months {get;set;}
        global Boolean isLessThan1Yr {get;set;}  //IBM KOU Wonder Woman CR 20180430
        global Boolean isLessThan2Yrs {get;set;}
        global Boolean isLessThan3Yrs {get;set;}        
        global Boolean isIndividualPolicy {get;set;}
        global Boolean isFastTrackAllow {get;set;}    //For OP - iEB only (group policy)
        global Boolean isUSDPolicy {get;set;}    //get value from modal Premium which include currency and amt      
        global Boolean isIPMI {get;set;}    //is IPMI policy
        /** useless **/
        global String PIName {get;set;}    
        global String PIID {get;set;}
        global String name {get;set;}
        /** end useless **/
        
        global String policyNum {get;set;}    //policy number        
        global String status {get;set;}    //policy status
        global String productCode {get;set;}    //Product code
        global String productName {get;set;}    //Product name
        global String marketingName {get;set;}    //Marketing name
        global String paidToDate {get;set;}    //Paid to date
        global String effectiveDate {get;set;}    //Effective date
        global String modalPremium {get;set;}    //Modal premium means paid 3/6/12 months amount currency USD/HKD -split ourselves        
        global Map<String, String> PHMap {get;set;}    //PH ssn/name
        global List <Map<String, String>> PIMapList {get;set;}    //PI List ssn/name       
        global Date coveragePeriodFrom {get;set;}    //coverage period from
        global Date coveragePeriodTo {get;set;}    //coverage period to      
        global String planTypeCode {get;set;}    //plan type code
        global String rateScale {get;set;}    //rate scale
        global String planTypeCodeStr {get;set;}    //plan type code original str       
        global String policyHolderName {get;set;}
        global String policyHolderId {get;set;}
        global String policyHolderPhoneNum {get;set;}
        global String policyHolderEmailAddr {get;set;}
        global String currenyCode {get;set;}
        /** end useless **/
        
        global String benefitTypeListStr {get;set;}    //HI, HIF, DIS
        global String claimTypeListStr {get;set;}    //claim type - A, B, C        
        global Policy__c pItem {get;set;}    //get from sf       
        global HttpCalloutVO.Policy pItem_in {get;set;}    //get from ws - individual
        global HttpCalloutVO.Policy pItem_grp {get;set;}    //get from ws - group
        
        //Nicole_20200403_GS Claim
        global Boolean isDisable {get;set;}
        global WrapperPolicy() {}
    }
    
    global Class WrapperPerson{    //GetPersonBasic - follow ppl by ssn       
        //global Boolean isIndividualPolicy {get;set;}
        //ind.
        global String ssnNum {get;set;}
        global String memberName {get;set;}
        global String emailAddr {get;set;}
        global String sensitivityCode {get;set;}
        global String gender {get;set;}
        //group.
        global String certNum {get;set;}
        global String certEffectiveDate {get;set;}
        global String memberStatusDescription {get;set;}       
        global String birthDate {get;set;}
        /**
        e.g. Mobile phone = {Country code : 86, Area code: 12,  Telephone number : 21234567 }
        Country code = 86
        Area code = 12
        Telephone number = 21234567  
        **/
        global String mobilePhoneNo {get;set;}
        global String mobileCountryCode {get;set;}
        global String mobileAreaCode {get;set;}
        global String mobileTelephoneNo {get;set;}      
        global List <Map<String, String>> senMapList {get;set;}
        global WrapperPerson() {}
    }
    
    global Class WrapperClinicVisitCount{    //GetClinicVisitCount by policy number / cert number           
        global String policyNum {get;set;}
        global String certNum {get;set;}
        global String planTypeCode {get;set;}
        global String rateScale {get;set;}
        global String planTypeCodeStr {get;set;}    //original plan type code str      
        global List <Map<String, String>> benefitDetailItemMapList {get;set;}
        /**
        Benefit detail item code
        Max. no. of visit per year
        Visited count
        **/
        global List <Map<String, String>> combinedBenefitDetailItemMapList {get;set;}
        /**
        Combined benefit list
        Overall outpatient maximum no. of visit per policy year
        Total visited count
        **/
        global WrapperClinicVisitCount() {}   
    }
    
    global Class WrapperPolicyPaymentBasic{    //getPolicyPaymentBasic  by policy number - for individual policy only      
        global String policyNum {get;set;}
        //ind.
        /** 
        Payer
        -SSN number
        -Full name
        -Account number
        -Account holder name
        -Bank name
        **/
        global String modalPremium {get;set;}    //Modal premium
        global String payerSsnNum {get;set;}
        global String payerFullName {get;set;}
        global String payerAccNumber {get;set;}
        global String payAccHolderName {get;set;}
        global String payBankName {get;set;}
        //group - no need now
        /**
        Coverage period from
        Coverage period to
        Payment mode code
        **/      
        /** 170316 useless
        global String coveragePeriodFrom {get;set;}
        global String coveragePeriodTo {get;set;}
        global String paymentModeCode {get;set;}
        **/      
        global WrapperPolicyPaymentBasic() {}
    }
    
    /** temp save data **/
    global Class WrapperInfoFromOtherCompany{   
        global String nameOfInsurer {get;set;}
        global String policyNum {get;set;}
        global WrapperInfoFromOtherCompany(){}  
    }
    
    global Class WrapperAdmittedAndDischargedFromHospital{   
        global Date admissionDate {get;set;}
        global Date dischargeDate{get;set;}    
        global Long admissionDateTimeStamp {get;set;}
        global Long dischargeDateTimeStamp{get;set;}
        global WrapperAdmittedAndDischargedFromHospital(){}  
    }
    
    global Class WrapperVisit{   
        global Date visitDate{get;set;}
        global Long visitDateTimeStamp {get;set;}
        global WrapperVisit(){} 
    }
    
    /** 170316 useless  
    global Class WrapperAccountHolder{
        global String accountHolder {get;set;}
        global WrapperAccountHolder(){}
    }
    
    public static String getPrivacy_statement_chi() {
        return '';
    }  
    **/
    
    global Class BankAccount{   
        global HttpCallOutVO.BankAccount bankAccount {get;set;}
        global List<SelectOption> policyOptions {get;set;}
        global Boolean IsSelectedTransfertoHKBank {get;set;}
        global Boolean IsSelectedTransfertoOverseaBank {get;set;}  
    }
    
    //HKITSFDC-412 BEGIN
     global Class WrapperInfoBenefitFromOtherCompany{   
        global String nameOfInsurer {get;set;}
        global String policyNum {get;set;}
        global WrapperInfoBenefitFromOtherCompany(){}  
    }
    //HKITSFDC-412 ENDED
}