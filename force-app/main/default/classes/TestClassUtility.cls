/*********************************************************************************
* Name: TestClassUtility
*
* Version History
* Version           Author                 Date                      Description
* ---------------  --------------------    -----------------------  ---------------------------------------------------------
* V1.0             Franco                  2016-12-06               Provides utility functions for Test methods.
* V2.0             Jason Guo               2018-07-06               Add utility functions.
********************************************************************************/
@isTest
public class TestClassUtility {
    
    public static void initCustomSetting(){
        if(Portal_Settings__c.getOrgDefaults() == null || Portal_Settings__c.getOrgDefaults().Id == NULL){
            Portal_Settings__c portalSetting=new Portal_Settings__c (Customer_Portal_Prefix__c='UNIT_TEST',
                                                                 Broker_Portal_Prefix__c='UNIT_TEST',
                                                                 Glance_Cobrowse_Group_ID__c='19736',
                                                                 Glance_Cobrowse_Site__c='staging',
                                                                 Live_Agent_Deployment_ID__c='57228000000L2cM', 
                                                                 Live_Agent_Init_URL__c='https://d.la10cs.salesforceliveagent.com/chat', 
                                                                 Live_Agent_JavaScript_URL__c='https://c.la10cs.salesforceliveagent.com/content/g/js/38.0/deployment.js', 
                                                                 File_Download_URL__c='UNIT_TEST',
                                                                 File_Store_Attachment_Clean_Up_Hours__c = 24,
                                                                 Customer_User_Profile__c = 'Cigna Customer User Profile',
                                                                 Customer_Virtual_User_Profile__c='Virtual Health User Profile',
                                                                 Enable_Login_As__c=false,
                                                                 Client_Portal_User_Profile__c='Cigna Client Portal HR User'
                                                                );
            insert  portalSetting;
        }
        
        Client_Portal_Setting__c cps = new Client_Portal_Setting__c();
        cps.Client_Portal_Cert_No_Ctrl__c = '59';
        cps.Client_Portal_Key__c='vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv';
        cps.Name = 'Key';
        insert cps;
        
        Op_Swat_Scan_Setting__c op=new Op_Swat_Scan_Setting__c();
        op.Name='OpSwat';
        op.profile_name__c ='Cigna Customer User;Cigna Customer User Profile;Cigna Broker Admin';
        op.endPoint__c='https://test.api.metadefender.com/v4/file';
        op.apikey__c='eed511da95125dc112b363b2cc73b1a6';
        op.turn_on__c=true;
        op.checkTime__c=2000;
        op.maxTime__c=30000;
        insert op;
        
        initWSsetting();
        initPolicyStatusMapping();
        initSubmitWorkRequestWorkTypeMapping();
        initClaimSetting();
        initClientPortalSetting();
        initOptSwatScanSetting();
        initOktaMFASettings();
        initAuditTrailSetting();
        initCustomValue();
        initProductValidationChecking();
    }

    public static void initProductValidationChecking(){
        List<Policy_Validation_Checking__c> pvcList = new List<Policy_Validation_Checking__c>();
        pvcList.add(new Policy_Validation_Checking__c(Duplicate_Policy_Checking__c='N',Post_Duplication_Checking__c='Y',AUW__c='Y',BMI__c='Y',Smoking__c='Y',Product_Code__c='CIR25',UW_Requirement__c='SU',Name='CIR25'));
        pvcList.add(new Policy_Validation_Checking__c(Duplicate_Policy_Checking__c='N',Post_Duplication_Checking__c='Y',AUW__c='Y',BMI__c='Y',Smoking__c='Y',Product_Code__c='CIB25',UW_Requirement__c='SU',Name='CIB25'));
        insert pvcList;
    }

    public static void initCustomValue(){
        List<Custom_Value__c> cvList = new List<Custom_Value__c>();
        cvList.add(new Custom_Value__c(Name = 'Elite 360 Product Code', Value__c = 'NELG2;NESG2'));
        cvList.add(new Custom_Value__c(Name = 'Exclude_Code_from_Coverage', Value__c = 'CBOG'));
        cvList.add(new Custom_Value__c(Name = 'Hide Product Rider', Value__c = 'PWLG2'));
        cvList.add(new Custom_Value__c(Name = 'Customer_Function_TD', Value__c = 'TD', Description__c = 'Customer Function Teladoc'));// Rancho_HKITSFDC250_20250514
        insert cvList;
    }

    public static void initAuditTrailSetting(){
        List<Audit_Trail_Setting__c> setList = new List<Audit_Trail_Setting__c>();
        setList.add(new Audit_Trail_Setting__c(Name='Default', Policy_No__c='3018;3077;9221;9223;91271;91272;91273;A462;A527;A528'));
        setList.add(new Audit_Trail_Setting__c(Name='System Administrator', Role__c='Customer Service', Available_Category__c='I01;I02;I03;G01;G02'));// Rancho_HKITSFDC250_20250514
        setList.add(new Audit_Trail_Setting__c(Name='Customer Service', Role__c='Customer Service', Available_Category__c='I01;I02;I03;G01;G02'));
        insert setList;
    }
    
    public static void initOktaMFASettings(){
        List<Okta_MFA_Callout_Setting__c> oktaMFASettings = new List<Okta_MFA_Callout_Setting__c>();
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='oktaDomain',
                                                            GroupID__c='00g84bjekpVnochC21d7',
                                                            Okta_Domian__c='https://dev.testlogin.mycigna.com.hk'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='oktaToken',
                                                            API_Token__c='00x_YKsWvD1o27zoTik_WBeocIX8N-0NGKMhzT24av'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Network Provider User External',
                                                            GroupID__c='00gaiogfm2coF8bne1d7'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Broker Admin',
                                                            GroupID__c='00gaioe6vmbnCskBu1d7'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Broker User',
                                                            GroupID__c='00gaiogfm2coF8bne1d7'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Client Portal HR User',
                                                            GroupID__c='00gaiogfm2coF8bne1d7'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Altruist Broker User',
                                                            GroupID__c='00gaiogfm2coF8bne1d7'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Altruist Broker Admin',
                                                            GroupID__c='00gaiogfm2coF8bne1d7'));
        oktaMFASettings.add(new Okta_MFA_Callout_Setting__c(Name='Cigna Customer User Profile',
                                                            GroupID__c='00gaiogfm2coF8bne1d7'));
        insert oktaMFASettings;
        
        List<Cigna_WS_Log_Setting__c> wsLogSettings = new List<Cigna_WS_Log_Setting__c>();
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAResetAllFactor',
                                                    API_Name__c='reset all factor',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/lifecycle/reset_factors',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAGetUser',
                                                    API_Name__c='Get User',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/',
                                                    Request_Method__c='GET'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAListEnrolledFactors',
                                                    API_Name__c='List enrolled Factors',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors',
                                                    Request_Method__c='GET'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFARequestOktaOTP',
                                                    API_Name__c='Issue an SMS/Email Factor challenge',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors/${factorId}/verify',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAResetFactor',
                                                    API_Name__c='Reset Factor',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors/${factorId}',
                                                    Request_Method__c='DELETE'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAUnlockUser',
                                                    API_Name__c='Unlock User',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/lifecycle/unlock',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAUpdateLoginEmail',
                                                    API_Name__c='UpdateLoginEmail',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAVerifyOTP',
                                                    API_Name__c='VerifyOTP',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors/${factorId}/verify',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAActivateFactor',
                                                    API_Name__c='Activate Factor',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors/${factorId}/lifecycle/activate',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFACreateUserWithPWD',
                                                    API_Name__c='Create User with password',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAEnrollFactor',
                                                    API_Name__c='Enroll Factor',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAGetFactor',
                                                    API_Name__c='Get Factor',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors/${factorId}',
                                                    Request_Method__c='GET'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAUpdatePW',
                                                    API_Name__c='set password',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}',
                                                    Request_Method__c='PUT'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAResendEnrollFactor',
                                                    API_Name__c='Resend enroll factor',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/users/${userId}/factors/${factorId}/resend',
                                                    Request_Method__c='POST'));
        wsLogSettings.add(new Cigna_WS_Log_Setting__c(Name='MFAAddUserToGroup',
                                                    API_Name__c='add user to group',
                                                    Enable_Logging__c=true,
                                                    Endpoint_Domain__c='https://dev.testlogin.mycigna.com.hk',
                                                    Related_Path__c='/api/v1/groups/${groupId}/users/${userId}',
                                                    Request_Method__c='PUT'));
        insert wsLogSettings;
    }
    
    public static void initWSsetting(){
        // Rancho_HKITSFDC212_20250401 - remove hard-code url
        List<WS_Callout_Setting__c> calloutSettings = new List<WS_Callout_Setting__c>();
        calloutSettings.add(new WS_Callout_Setting__c(Name = 'Default',
                                                     Endpoint__c= 'http://uat.cigna.com.hk/CignaFW/CignaDigitalWSService',
                                                     Request_Max_Records__c = 1000,
                                                     CignaWSErrorLogRest_Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm()+'/customer/services/apexrest/CignaWSErrorLogRest',
                                                    CignaCacheRest_Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm()+'/ws/services/apexrest/CignaCacheRest'
                                                    ));
        calloutSettings.add(new WS_Callout_Setting__c(Name = 'Internal User Default',
                                                     Endpoint__c= 'http://uat.cigna.com.hk/CignaFW/CignaDigitalWSService',
                                                     Request_Max_Records__c = 1000,
                                                     CignaWSErrorLogRest_Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm()+'/customer/services/apexrest/CignaWSErrorLogRest',
                                                    CignaCacheRest_Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm()+'/ws/services/apexrest/CignaCacheRest'
                                                    ));
        calloutSettings.add(new WS_Callout_Setting__c(Name = 'System Administrator', Parent__c = 'Internal User Default', Enable_Cache__c = true));
        calloutSettings.add(new WS_Callout_Setting__c(Name = 'Cigna BD Agent', Parent__c = 'Internal User Default'));
        calloutSettings.add(new WS_Callout_Setting__c(Name = 'Cigna BD Manager', Parent__c = 'Internal User Default'));
        calloutSettings.add(new WS_Callout_Setting__c(Name = 'Cigna Customer User Profile', Parent__c = 'Default', Enable_Cache__c = true, Cache_Partition__c = 'CustomerPortal'));
        insert calloutSettings;
    }
    
    public static void initClaimSetting(){
        Claim_Setting__c claimSetting=new Claim_Setting__c (
            name = 'Cigna',
            Claim_Form_Download_Prefix__c = 'UNIT_TEST',
            Email_Address_QHMS__c = 'test@test.com',
            Max_Record_Count_Per_Page__c = 2,
            Max_Record_GetPolicyListBasicByCriteria__c = '10',
            Brk_Policy_Brk_Initiated_Trigger_Id__c = '123456',
            Brk_Policy_Cus_Initiated_Trigger_Id__c = '123456',
            Direct_Sales_TM_Policy_Trigger_Id__c = '123456',
            Claim_HKCode__c='200'
        );
        insert claimSetting;  
    }

    // init Cigna_WS_Log_Setting__c
    public static void initCignaWSCalloutSetting(){
        List<Cigna_WS_Log_Setting__c> calloutSettings = new List<Cigna_WS_Log_Setting__c>();
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'UseCoupon', Endpoint_Domain__c = 'https://uat-asia.apigateway.cigna.com/hongkong/esales/', Related_Path__c = 'UseCoupon.do', Request_Method__c = 'POST', Reset_Endpoint__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'GetFieldFormat', Endpoint_Domain__c = 'https://uat-asia.apigateway.cigna.com/hongkong/esales/', Related_Path__c = 'GetFieldFormat.do', Request_Method__c = 'GET', Reset_Endpoint__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'ReactiveCoupon', Endpoint_Domain__c = 'https://uat-asia.apigateway.cigna.com/hongkong/esales/', Related_Path__c = 'ReactiveCoupon.do', Request_Method__c = 'POST', Reset_Endpoint__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'ValidateCoupon', Endpoint_Domain__c = 'https://uat-asia.apigateway.cigna.com/hongkong/esales/', Related_Path__c = 'ValidateCoupon.do', Request_Method__c = 'POST', Reset_Endpoint__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'GetIllustrationListByPlan', Endpoint_Domain__c = 'https://uatts.cigna.com.hk/eSalesHKWS/', Related_Path__c = 'GetIllustrationListByPlan.do', Request_Method__c = 'GET', Reset_Endpoint__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'GetQuote', API_Name__c = 'GET_QUOTE', Endpoint_Domain__c = 'https://uatts.cigna.com.hk/eSalesHKWS/', Related_Path__c = 'GetQuote.do', Request_Method__c = 'GET', Reset_Endpoint__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'GetProductInfo', API_Name__c = 'GetProductInfo', Endpoint_Domain__c = 'https://uatts.cigna.com.hk/eSalesHKWS/', Related_Path__c = 'GetProductInfo.do', Request_Method__c = 'GET', Reset_Endpoint__c = TRUE, Enable_cache__c = TRUE, Enable_Logging__c = TRUE));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'GetQuoteByProductCode', API_Name__c = 'GetQuoteByProductCode', Endpoint_Domain__c = 'https://uatts.cigna.com.hk/eSalesHKWS/', Related_Path__c = 'GetQuoteByProductCode.do', Request_Method__c = 'GET', Reset_Endpoint__c = TRUE, Enable_cache__c = TRUE, Enable_Logging__c = TRUE, Cache_TTL__c=28800));
        calloutSettings.add(new Cigna_WS_Log_Setting__c(Name = 'ValidatePromoteCode', Endpoint_Domain__c = 'https://uatts.cigna.com.hk/eSalesHKWS/', Related_Path__c = 'ValidatePromoteCode.do', Request_Method__c = 'POST', Reset_Endpoint__c = TRUE));

        insert calloutSettings;
    }

    public static void initClientPortalSetting(){
        List<Client_Portal_Setting__c> clientSettings = new List<Client_Portal_Setting__c>();
        clientSettings.add(new Client_Portal_Setting__c(Name = 'Key', Client_Portal_Key__c = 'EcDL/9AHHLResCGEwUaiO6TiGTHKLjiLybtcTYVf7EA='));

        insert clientSettings;
    }

    public static void initOptSwatScanSetting(){
        List<Op_Swat_Scan_Setting__c> optSettings = new List<Op_Swat_Scan_Setting__c>();
        optSettings.add(new Op_Swat_Scan_Setting__c(Name='OpSwat', profile_name__c = 'Cigna Altruist Broker Admin;Cigna Altruist Broker User;Cigna Broker Admin;Cigna Broker User;Cigna Customer User Profile', endPoint__c='https://api.metadefender.com/v4/file', apikey__c='eed511da95125dc112b363b2cc73b1a6', turn_on__c=true, checkTime__c=2000, maxTime__c=30000));
        insert optSettings;
    }
    
    public static void initClaimData(){
        List<Claim__c> cList = new List<Claim__c>();
        Claim__c cItem = new Claim__c(
            All_Claims_Related_To_Same_Event__c = true,
            All_Non_IPMI_policy__c = true,
            All_Policy_IPMI__c = true,
            Ask_If_More_Than_One_Claim__c = true,
            Cannot_Enter_Bank_Account_Information__c = true,
            CI__c = true,
            DIS__c = true,
            Do_you_have_the_admission_details__c = true,
            Do_you_stay_in_hospital__c = true,
            GOP_Payment_T_C__c = true,
            Has_Credit_Card__c = true,
            HI__c = true,
            HIF__c = true,
            HPA__c = true,
            HPA_Less_Than_2_Yrs__c = true,
            HS__c = true,
            HS_Less_Than_3_Yrs_or_Broker_PAC__c = true,
            Is_All_Selected_Policy_EffDate_6_month__c = true,
            Is_Chosen_Send_Esignature__c = true,
            Is_Chosen_Sign_On_Screen__c = true,
            Is_Contain_Group_Policy__c = true,
            Is_Contain_Individual_Life_Policy__c = true,
            Is_Contain_Individual_Policy__c = true,
            Is_Contain_Life_Policy__c = true,
            Is_Contain_US_Policy__c = true,
            Is_Created_By_Broker__c = true,
            Is_Created_By_Customer__c = true,
            Is_Displayed_For_Customer__c = true,
            is_Selected_Broker_PAC_plan__c = true,
            Is_Selected_Temporary_or_Permanent_Dis__c = true,
            Is_Selected_Transfer_to_HK_Bank__c = true,
            Is_Selected_Transfer_to_Oversea_Bank__c = true,
            Is_Selected_Waiver_of_Premium__c = true,
            Is_there_any_room_charge__c = true,
            Is_Using_Chinese_Version__c = true,
            MAT__c = true,
            OP__c = true,
            OPF__c = true,
            PI_without_any_Sen_Code_N6__c = true,
            Receive_reimbursement_from_other_comp__c = true,
            sj_HIF_d__c = true,
            sj_OP_a__c = true,
            sj_OP_d__c = true,
            Still_on_sick_leave__c = true,
            Upload_Admission_Note__c = true,
            Amount_Of_Sum_Insured__c = 100,
            Please_input_the_amount_of_charge_HKD__c = 100,
            Admission_Date__c = System.today(),
            Date_of_stop_working_due_to_disability__c = System.today(),
            Person_Insured_Date_Of_Birth__c = System.today(),
            Submission_Date__c = System.today(),
            What_is_your_1st_consultation_date__c = System.today(),
            Email_Address_to_send__c = 'test12345@test.com',
            Admitted_and_discharged_from_hospital__c = '',    //in json
            Information_from_other_companies__c = '',    //in json
            Policy__c = '123, 234',
            Visit_Date__c = '',    //in json
            Account__c = null,
            Policy_Holder__c = null,
            Expiry_Date_of_Credit_Card_Month__c = 1,
            Expiry_Date_of_Credit_Card_Year__c = 2018,
            Steps__c = 1,
            Contact_No_Country_Code__c = '22222222',
            Contact_No__c = '22222222',
            Dr_or_Clinic_Phone_Number__c = '22222222',
            Dr_or_Clinic_Phone_Number_Country_Code__c = '22222222',
            Status__c = 'Not Submitted',
            What_would_you_like_to_claim_for__c = 'A,B,C,D,E,F,G,H,I,',
            Policy_Holder_Email_Address__c = 'test12345@test.com',
            Card_Holder_HKID__c = '123456',
            Policy_Holder_Contact_No__c = '123456',
            Allow_Types_Of_Doctor_To_Claim__c = 'A B C D E F G H I',
            Attending_Dr_Name__c = 'TEST',
            Bank_Account_Holder__c = 'TEST',
            Bank_Account_Information__c = 'TEST',
            Bank_Account_Name__c = 'TEST',
            Bank_Account_Number__c = 'TEST',
            Bank_Branch_Address__c = 'TEST',
            Bank_Branch_Code__c = 'TEST',
            Bank_Code__c = 'TEST',
            Bank_Name__c = 'TEST',
            Bank_Routing_Code_ABA__c = 'TEST',
            Bank_SWIFT__c = 'TEST',
            Card_Holder_Name__c = 'TEST',
            Claim_Type__c = 'TEST',
            Credit_Card_No__c = 'TEST',
            E_Signature_Link__c = 'TEST',
            Hospital_Name__c = 'TEST',
            Payment_Currency__c = 'HKD',
            Person_Insured_Date_Of_Birth_Text__c = 'TEST',
            Person_Insured_Gender__c = 'TEST',
            Person_s_Insured__c = 'TEST',
            Person_Insured_Name__c = 'TEST',
            Policy_Holder_ID__c = 'TEST',
            Policy_Holder_Name__c = 'TEST',
            Selected_Question_s__c = 'TEST',
            Type_of_benefit_to_claim__c  = 'HIF;HI;HPA;HS;CI;DIS;MAT;OP;OPF',
            What_is_of_work_allocation_Clerical__c = '50',
            What_is_of_work_allocation_Manual__c = '50',
            What_is_the_hospital_doctor_name__c = 'TEST',
            What_is_the_phone_of_hospital_doctor__c = 'TEST'
        );
        cList.add(cItem);
        insert cList;
        
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(new Attachment(Parentid = cItem.Id, 
                                              Body = Blob.valueOf('test'),
                                              ContentType = 'text/plain;charset=UTF-8',
                                              Name = 'claim_test.txt'));
        insert attachmentList;
    }
    
    public static void initClaimData2(){
        List<Claim__c> cList = new List<Claim__c>();
        Claim__c cItem = new Claim__c(
            All_Claims_Related_To_Same_Event__c = true,
            All_Non_IPMI_policy__c = true,
            All_Policy_IPMI__c = true,
            Ask_If_More_Than_One_Claim__c = true,
            Cannot_Enter_Bank_Account_Information__c = true,
            CI__c = true,
            DIS__c = true,
            Do_you_have_the_admission_details__c = true,
            Do_you_stay_in_hospital__c = true,
            GOP_Payment_T_C__c = true,
            Has_Credit_Card__c = true,
            HI__c = true,
            HIF__c = true,
            HPA__c = true,
            HPA_Less_Than_2_Yrs__c = true,
            HS__c = true,
            HS_Less_Than_3_Yrs_or_Broker_PAC__c = true,
            Is_All_Selected_Policy_EffDate_6_month__c = true,
            Is_Chosen_Send_Esignature__c = true,
            Is_Chosen_Sign_On_Screen__c = true,
            Is_Contain_Group_Policy__c = true,
            Is_Contain_Individual_Life_Policy__c = true,
            Is_Contain_Individual_Policy__c = true,
            Is_Contain_Life_Policy__c = true,
            Is_Contain_US_Policy__c = true,
            Is_Created_By_Broker__c = true,
            Is_Created_By_Customer__c = true,
            Is_Displayed_For_Customer__c = true,
            is_Selected_Broker_PAC_plan__c = true,
            Is_Selected_Temporary_or_Permanent_Dis__c = true,
            Is_Selected_Transfer_to_HK_Bank__c = true,
            Is_Selected_Transfer_to_Oversea_Bank__c = true,
            Is_Selected_Waiver_of_Premium__c = true,
            Is_there_any_room_charge__c = true,
            Is_Using_Chinese_Version__c = true,
            MAT__c = true,
            OP__c = true,
            OPF__c = true,
            PI_without_any_Sen_Code_N6__c = true,
            Receive_reimbursement_from_other_comp__c = true,
            sj_HIF_d__c = true,
            sj_OP_a__c = true,
            sj_OP_d__c = true,
            Still_on_sick_leave__c = true,
            Upload_Admission_Note__c = true,
            Amount_Of_Sum_Insured__c = 100,
            Please_input_the_amount_of_charge_HKD__c = 100,
            Admission_Date__c = System.today(),
            Date_of_stop_working_due_to_disability__c = System.today(),
            Person_Insured_Date_Of_Birth__c = System.today(),
            Submission_Date__c = System.today(),
            What_is_your_1st_consultation_date__c = System.today(),
            Email_Address_to_send__c = 'test12345@test.com',
            Admitted_and_discharged_from_hospital__c = '',    //in json
            Information_from_other_companies__c = '',    //in json
            Policy__c = '123, 234',
            Visit_Date__c = '',    //in json
            Account__c = null,
            Policy_Holder__c = null,
            Expiry_Date_of_Credit_Card_Month__c = 1,
            Expiry_Date_of_Credit_Card_Year__c = 2018,
            Steps__c = 1,
            Contact_No_Country_Code__c = '22222222',
            Contact_No__c = '22222222',
            Dr_or_Clinic_Phone_Number__c = '22222222',
            Dr_or_Clinic_Phone_Number_Country_Code__c = '22222222',
            Status__c = 'Not Submitted',
            What_would_you_like_to_claim_for__c = 'A,B,C,D,E,F,G,H,I,',
            Policy_Holder_Email_Address__c = 'test12345@test.com',
            Card_Holder_HKID__c = '123456',
            Policy_Holder_Contact_No__c = '123456',
            Allow_Types_Of_Doctor_To_Claim__c = 'A B C D E F G H I',
            Attending_Dr_Name__c = 'TEST',
            Bank_Account_Holder__c = 'TEST',
            Bank_Account_Information__c = 'TEST',
            Bank_Account_Name__c = 'TEST',
            Bank_Account_Number__c = 'TEST',
            Bank_Branch_Address__c = 'TEST',
            Bank_Branch_Code__c = 'TEST',
            Bank_Code__c = 'TEST',
            Bank_Name__c = 'TEST',
            Bank_Routing_Code_ABA__c = 'TEST',
            Bank_SWIFT__c = 'TEST',
            Card_Holder_Name__c = 'TEST',
            Claim_Type__c = 'TEST',
            Credit_Card_No__c = 'TEST',
            E_Signature_Link__c = 'TEST',
            Hospital_Name__c = 'TEST',
            Payment_Currency__c = 'HKD',
            Person_Insured_Date_Of_Birth_Text__c = 'TEST',
            Person_Insured_Gender__c = 'TEST',
            Person_s_Insured__c = 'TEST',
            Person_Insured_Name__c = 'TEST',
            Policy_Holder_ID__c = 'TEST',
            Policy_Holder_Name__c = 'TEST',
            Selected_Question_s__c = 'TEST',
            Type_of_benefit_to_claim__c  = 'HIF;HI;HPA;HS;CI;DIS;MAT;OP;OPF',
            What_is_of_work_allocation_Clerical__c = '50',
            What_is_of_work_allocation_Manual__c = '50',
            What_is_the_hospital_doctor_name__c = 'TEST',
            What_is_the_phone_of_hospital_doctor__c = 'TEST'
        );
        cList.add(cItem);
        insert cList;
        
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(new Attachment(Parentid = cItem.Id, 
                                              Body = Blob.valueOf('test'),
                                              ContentType = 'text/plain;charset=UTF-8',
                                              Name = 'bigfile.txt'));
        insert attachmentList;
    }
    
    public static void initSubmitWorkRequestWorkTypeMapping(){
        List<RecordType> listPolicyChangeType = new List<RecordType>();
        listPolicyChangeType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Policy_Change_Request__c'];
        List<Submit_Work_Request_Work_Type__c> listWorkType = new List<Submit_Work_Request_Work_Type__c>();
        for(RecordType pct: listPolicyChangeType){
            Submit_Work_Request_Work_Type__c workType = new Submit_Work_Request_Work_Type__c();
            workType.Name = pct.id;
            workType.Policy_Change_Record_Type__c = pct.Name;
            workType.Sub_Work_type__c = 'test';
            workType.Work_Type__c = 'test';
            workType.Salesforce_Work_Type__c = 'test';
            listWorkType .add(workType);
        }
        insert listWorkType;
    }
    
    public static void initPolicyStatusMapping(){
        List<Policy_Status_Mapping__c> psmList = new List<Policy_Status_Mapping__c>();
        psmList.add(new Policy_Status_Mapping__c(Name='1', Code_old__c='1', Description__c='Premium paying', Hide_After_1_year__c=FALSE, PolicyCode__c='1', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='3', Code_old__c='3', Description__c='Paid-up life, RPU', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500001', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='4', Code_old__c='4', Description__c='ETI, paid-up endowment or annuity', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500002', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='5', Code_old__c='6', Description__c='Application incomplete', Hide_After_1_year__c=FALSE, PolicyCode__c='23', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='6', Code_old__c='A', Description__c='Not taken', Hide_After_1_year__c=TRUE, PolicyCode__c='7', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='7', Code_old__c='B', Description__c='Lapsed', Hide_After_1_year__c=TRUE, PolicyCode__c='4', PolicyStatus__c='Lapsed', PolicyStatusChinese__c='已逾期', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='8', Code_old__c='C', Description__c='Converted', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500003', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='9', Code_old__c='D', Description__c='Death', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500004', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='10', Code_old__c='E', Description__c='Surrendered', Hide_After_1_year__c=TRUE, PolicyCode__c='6', PolicyStatus__c='Surrendered', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='11', Code_old__c='F', Description__c='Matured', Hide_After_1_year__c=FALSE, PolicyCode__c='40', PolicyStatus__c='Matured', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='12', Code_old__c='H', Description__c='Expired', Hide_After_1_year__c=TRUE, PolicyCode__c='17', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='13', Code_old__c='G', Description__c='LAPSED WITH VALUE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500027', PolicyStatus__c='Lapsed', PolicyStatusChinese__c='已逾期', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='14', Code_old__c='P', Description__c='Terminated for disability', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500005', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='15', Code_old__c='W', Description__c='Vested annuity', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500006', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='16', Code_old__c='O', Description__c='FOR DEEMED DISPOSITION', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500007', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='17', Code_old__c='Z', Description__c='DEATH (W / O AC#)', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500008', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='18', Code_old__c='J', Description__c='REJECT APPLICATION', Hide_After_1_year__c=TRUE, PolicyCode__c='98', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='19', Code_old__c='K', Description__c='FOR ANTICIPATED DEPOSIT SURRENDER', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500009', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='20', Code_old__c='R', Description__c='FOR REINSTATEMENT', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500010', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='21', Code_old__c='S', Description__c='FOR DIV ON DEP SURRENDER', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500011', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='22', Code_old__c='T', Description__c='FOR PUA SURRENDER', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500012', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='23', Code_old__c='X', Description__c='FOR EXTENDED TERM QUOTE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500013', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='24', Code_old__c='Y', Description__c='FOR REDUCED PAID-UP QUOTE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500014', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='25', Code_old__c='N', Description__c='FOR PAID-UP ENDOWMENT OR ANNUITY', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500015', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='26', Code_old__c='U', Description__c='FOR REDUCED PAID-UP LIFE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500016', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='27', Code_old__c='V', Description__c='FOR RPU ENDOWMENT OR ANNUITY', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500017', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='28', Code_old__c='0', Description__c='READY TO GO INFORCE', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500018', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='29', Code_old__c='5', Description__c='APPLICATION REJECTED', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500019', PolicyStatus__c='Rejected', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='30', Code_old__c='7', Description__c='APPLICATION DATA COMPLETE', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500020', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='31', Code_old__c='8', Description__c='COMPLETE CASH, NO UNDERWRITING', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500021', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='32', Code_old__c='9', Description__c='COMPLETE, NO CASH', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500022', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='33', Code_old__c='I', Description__c='PREVIOUS YEAR TERMINATED', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500023', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='CAPSIL'));
        psmList.add(new Policy_Status_Mapping__c(Name='34', Code_old__c='1', Description__c='Premium paying', Hide_After_1_year__c=FALSE, PolicyCode__c='1', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='35', Code_old__c='2', Description__c='Premium waiver or payor death', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500024', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='36', Code_old__c='3', Description__c='Paid-up life, RPU', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500001', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='37', Code_old__c='4', Description__c='ETI, paid-up endowment or annuity', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500002', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='38', Code_old__c='6', Description__c='Application incomplete', Hide_After_1_year__c=FALSE, PolicyCode__c='23', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='39', Code_old__c='A', Description__c='Not taken', Hide_After_1_year__c=TRUE, PolicyCode__c='7', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='40', Code_old__c='B', Description__c='Lapsed', Hide_After_1_year__c=TRUE, PolicyCode__c='4', PolicyStatus__c='Lapsed', PolicyStatusChinese__c='已逾期', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='41', Code_old__c='C', Description__c='Converted', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500003', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='42', Code_old__c='D', Description__c='Death', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500004', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='43', Code_old__c='E', Description__c='Surrendered', Hide_After_1_year__c=TRUE, PolicyCode__c='6', PolicyStatus__c='Surrendered', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='44', Code_old__c='F', Description__c='Matured', Hide_After_1_year__c=FALSE, PolicyCode__c='40', PolicyStatus__c='Matured', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='45', Code_old__c='H', Description__c='Expired', Hide_After_1_year__c=TRUE, PolicyCode__c='17', PolicyStatus__c='Cancelled', PolicyStatusChinese__c='已取消', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='46', Code_old__c='P', Description__c='Terminated for disability', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500005', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='47', Code_old__c='W', Description__c='Vested annuity', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500006', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='48', Code_old__c='O', Description__c='FOR DEEMED DISPOSITION', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500007', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='49', Code_old__c='Z', Description__c='DEATH (W / O AC#)', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500008', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='50', Code_old__c='J', Description__c='REJECT APPLICATION', Hide_After_1_year__c=TRUE, PolicyCode__c='98', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='51', Code_old__c='K', Description__c='FOR ANTICIPATED DEPOSIT SURRENDER', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500009', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='52', Code_old__c='R', Description__c='FOR REINSTATEMENT', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500010', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='53', Code_old__c='S', Description__c='FOR DIV ON DEP SURRENDER', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500011', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='54', Code_old__c='T', Description__c='FOR PUA SURRENDER', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500012', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='55', Code_old__c='X', Description__c='FOR EXTENDED TERM QUOTE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500013', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='56', Code_old__c='Y', Description__c='FOR REDUCED PAID-UP QUOTE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500014', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='57', Code_old__c='N', Description__c='FOR PAID-UP ENDOWMENT OR ANNUITY', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500015', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='58', Code_old__c='U', Description__c='FOR REDUCED PAID-UP LIFE', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500016', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='59', Code_old__c='V', Description__c='FOR RPU ENDOWMENT OR ANNUITY', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500017', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='60', Code_old__c='0', Description__c='READY TO GO INFORCE', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500018', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='61', Code_old__c='5', Description__c='APPLICATION REJECTED', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500019', PolicyStatus__c='Rejected', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='62', Code_old__c='7', Description__c='APPLICATION DATA COMPLETE', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500020', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='63', Code_old__c='8', Description__c='COMPLETE CASH, NO UNDERWRITING', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500021', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='64', Code_old__c='9', Description__c='COMPLETE, NO CASH', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500022', PolicyStatus__c='Pending', PolicyStatusChinese__c='期滿', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='65', Code_old__c='I', Description__c='PREVIOUS YEAR TERMINATED', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500023', PolicyStatus__c='Terminated', PolicyStatusChinese__c='已終止', System__c='IPAS'));
        psmList.add(new Policy_Status_Mapping__c(Name='66', Code_old__c='A', Description__c='Active', Hide_After_1_year__c=FALSE, PolicyCode__c='1', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='S6'));
        psmList.add(new Policy_Status_Mapping__c(Name='67', Code_old__c='P', Description__c='Policy Suspended', Hide_After_1_year__c=FALSE, PolicyCode__c='55', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='S6'));
        psmList.add(new Policy_Status_Mapping__c(Name='68', Code_old__c='T', Description__c='Transaction Suspended', Hide_After_1_year__c=FALSE, PolicyCode__c='1052500025', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='S6'));
        psmList.add(new Policy_Status_Mapping__c(Name='69', Code_old__c='C', Description__c='Cancel', Hide_After_1_year__c=TRUE, PolicyCode__c='1052500026', PolicyStatus__c='Inforce', PolicyStatusChinese__c='生效', System__c='S6'));
        insert psmList;
    }
    
    public static User createSystemAdminUser(String lastName){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User adminUser = new User(
            ProfileId = p.Id,
            Username = 'TestUser_Admin' + System.now().millisecond() + '@CignaTest.com',
            Contact_No_Country_Code__c = '+86',
            Alias = 'testuser',
            Email = 'test12345678@cigna.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Test',
            Contact_No__c = '214211',
            Lastname = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Chicago',
            isActive =true
        );
        insert adminUser;
        return adminUser;
    }
    
    public static User createBDManager(String lastName){
        Profile BDp = [SELECT Id FROM Profile WHERE Name = 'Cigna BD Manager'];
        List<UserRole> bdUserRole = [SELECT Id, DeveloperName FROM UserRole where DeveloperName='BD_Manager'];  
        UserRole userRole = bdUserRole.get(0);
        User bdUser = new User(
            ProfileId = BDp.Id,
            Username = 'BDManagerTest' + System.now().millisecond() + '@CignaTest.com',
            Contact_No_Country_Code__c = '+86',
            Alias = 'bdM',
            Email = 'BDManagerTest@cigna.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Test',
            Contact_No__c = '21421',
            Lastname = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Chicago',
            isActive =true,
            userroleid = userRole.Id
        );
        insert bdUser;
        return bdUser;
    }
    
    public static void prepareTestData(){
        //create calloutSetting
        initWSsetting();
    }
    
    public static void prepareTestDataofPolicyCalloutHelper(){
        initWSsetting();
    }
    
    
    public static void prepareTestDataOfCustomerCalloutHelper(){
        initWSsetting();
    }    
    
    public static void prepareTestDataOfAgentHierarchyCalloutHelper(){
        initWSsetting();
    }  
    
    // Nationality & Country of Residence CR
    public static void prepareTestDataOfMasterListCalloutHelper(){
        initWSsetting();
    } 
    
    public static void prepareTestDataOfClaimCalloutHelper(){
        initWSsetting();
    }
    
    public static void prepareTestDataOfWorkCalloutHelper(){
        initWSsetting();
    }    
    
    //create test data for FAQ
    public static void prepareTestDataOfFAQPage(){
        
    }
    
    public static Date today = Date.today();
    public static Date startDate = today.addDays(-180);
    public static Date endDate = today.addDays(180);
    
    public static User createUser(String profileName, String roleName, String lastName){
        User u = createUser(profileName, roleName, lastName, '');        
        return u;
    }
    
    public static User createTMManager(){
        return createUser('TM Management', 'TM_Management', 'TM Management', '');
    }
    
    public static User createTMLeader(){
        return createUser('TM DTC Leader', 'TM_DTC_Leader', 'TM DTC Leader', '');
    }
    
    public static User createTMAgent(){
        return createUser('TM DTC TMR', 'TM_DTC_Sub_Team_1_TMR', 'TM DTC TMR', '');
    }
    
    public static User createCVMUser(){
        return createUser('CVM User', 'CVM_User', 'CVM User', '');
    }
    
    public static User createUser(String profileName, String roleName, String lastName, String firstName){        
        User u = new User();
        if(String.isNotBlank(profileName)){        
            Profile pro = [SELECT Id FROM Profile WHERE Name = :profileName];
            u.ProfileId = pro.Id;
        }        
        if(String.isNotBlank(roleName)){ 
            UserRole role = [SELECT Id FROM UserRole WHERE DeveloperName = :roleName];
            u.UserRoleId = role.Id;            
        }
        u.Lastname = lastName;
        u.Firstname = firstName;
        u.Username = 'TestUser_' + System.now().millisecond() + '@cigna.com';
        u.Contact_No_Country_Code__c = '+86';
        u.Alias = 'testuser';
        u.Email = 'test12345678@cigna.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey='America/Chicago';
        u.isActive =true;
        u.Contact_No__c = '214211';
        u.Agent_Code__c = '12345678';
        u.Seller_ID__c = '1k';
        u.Supervisor_ID__c = 'S001';
        u.TM_Agent_ID__c = 'TM9022';
        u.Work_Group_ID__c = '1234';
        u.Extension_No__c = '0000';// Rancho_CallCenterUCID_20210618
        insert u;
        return u;
    }
    
    public static Account createAccount(String recordTypeDevName, String LastName){      
        return createAccount(recordTypeDevName, lastName, '', '');
    }
    
    public static Account createAccount(String recordTypeDevName, String LastName, String Name){      
        return createAccount(recordTypeDevName, lastName, Name, '');
    }
    
    public static Account createAccount(String recordTypeDevName, String LastName, String Name, String ssn){      
        Account acc = new Account();
        if(String.isNotBlank(recordTypeDevName)){
            RecordType accRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = :recordTypeDevName];
            acc.RecordTypeId = accRt.Id;            
        }
        //Person Account
        if(String.isNotBlank(LastName)){
            acc.LastName = LastName;
            acc.PersonMobilePhone = '12345678';
            acc.PersonHomePhone = '123456789';
        }
        //Not Person Account
        else if(String.isNotBlank(Name)){
            acc.Name = Name;
        }
        if(String.isNotBlank(ssn)){
            acc.SSN__c = ssn;
        }
        
        insert acc;
        return acc;
    }
    
    public static Contact createContact(String LastName){
        Contact con = createContact(Null, LastName);
        return con;        
    }
    
    public static Contact createContact(Account acc, String LastName){
        Contact con = new Contact();
        con.LastName = LastName;
        if(acc != Null){
            con.AccountId = acc.Id;           
        }
        insert con;
        return con;        
    }
    
    public static Campaign createCampaign(String DeveloperName, String Name){        
        Campaign cam = createCampaign(DeveloperName, Name, null, '');
        return cam;           
    }
    
    public static Campaign createCampaign(String DeveloperName, String Name, Product__c prod, String Category){
        initTMCampaignSetting();
        RecordType camRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = :DeveloperName];
        Campaign cam = new Campaign();
        cam.RecordTypeId = camRt.Id;
        cam.Name = Name;    
        cam.endDate = endDate;    
        cam.Expiry_Date__c = cam.endDate;
        if(prod != null){
            cam.core_product__c = prod.Id;        
        }
        cam.Campaign_Category__c = 'DTC';
        insert cam;
        return cam;        
    }
    
    public static Campaign_Type__c createCampaignType(){
        Campaign_Type__c ct = new Campaign_Type__c();
        ct.Name = 'EIN';    
        ct.Description__c = 'eSales Inbound';    
        ct.Is_Inbound_Campaign__c = true;
        ct.Is_Auto_dialing__c = false;    
        ct.Need_Approval__c = false;
        ct.is_auto_assignment__c = true;
        insert ct;
        return ct;        
    }
    
    public static CampaignMember createCampaignMember(Contact con, Campaign cam){
        CampaignMember cm = new CampaignMember();
        if(con != null){
            cm.ContactId = con.Id;        
        }
        if(cam != null){
            cm.CampaignId = cam.Id;        
        }
        insert cm;
        return cm;        
    }
    
    public static Opportunity createOpportunity(String DeveloperName, String Name, String stageName){
        Opportunity opp = createOpportunity(DeveloperName, Null, Null, Name, stageName, Null);
        return opp;        
    }   
    
    public static Opportunity createOpportunity(String DeveloperName, Account acc, String Name, String stageName){
        Opportunity opp = createOpportunity(DeveloperName, acc, Null, Name, stageName, Null);
        return opp;        
    }    
    
    public static Opportunity createOpportunity(String DeveloperName, Campaign cam, String Name, String stageName){
        Opportunity opp = createOpportunity(DeveloperName, Null, cam, Name, stageName, Null);
        return opp;        
    }
    
    public static Opportunity createOpportunity(String DeveloperName, Account acc, Campaign cam, String Name, String stageName){
        Opportunity opp = createOpportunity(DeveloperName, acc, cam, Name, stageName, Null);
        return opp;        
    }
    
    public static Opportunity createOpportunity(String DeveloperName, Account acc, Campaign cam, String Name, String stageName, User owner){
        initTMCampaignSetting();
        Opportunity opp = new Opportunity();        
        if(String.isNotBlank(DeveloperName)){
            RecordType oppRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = :DeveloperName];
            opp.RecordTypeId = oppRt.Id;            
        }
        opp.Name = Name;
        String Salutation = '';   
        if(acc != Null){
            opp.AccountId = acc.Id;  
            String acctLastName = acc.lastname;
            String acctFirstName = acc.firstname;
            if(acctFirstName == null){
                acctFirstName = '';
            }        
            if(!opp.Name.startsWith('XXXXXX-')){ //for dummy oppty name, not to change the oppty name.
                opp.Name = Salutation + acctLastName + acctFirstName;
                opp.Name = opp.Name.replace(' ','');
            }              
            if(acc.Gender__c != null){
                if(acc.Gender__c == 'Male'){
                    Salutation = 'Mr';
                }else if(acc.Gender__c == 'Female'){
                    Salutation = 'Ms';
                }
                
            }       
        }
        opp.CloseDate = endDate;
        if(cam != Null){
            opp.Campaign__c = cam.Id;  
            if(cam.Expiry_Date__c != Null){
                opp.CloseDate = cam.Expiry_Date__c;
            }        
        }
        if(String.isNotBlank(stageName)){
            opp.stageName = stageName;
        }
        if(owner != Null){
            opp.OwnerId = owner.Id;           
        }
        insert opp;
        return opp;        
    }     
    
    public static Opportunity createOpportunityWithoutInsert(String DeveloperName, Account acc, Campaign cam, String Name, String stageName, User owner){
        initTMCampaignSetting();
        Opportunity opp = new Opportunity();        
        if(String.isNotBlank(DeveloperName)){
            RecordType oppRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = :DeveloperName];
            opp.RecordTypeId = oppRt.Id;            
        }
        opp.Name = Name;
        String Salutation = '';   
        if(acc != Null){
            opp.AccountId = acc.Id;  
            String acctLastName = acc.lastname;
            String acctFirstName = acc.firstname;
            if(acctFirstName == null){
                acctFirstName = '';
            }        
            if(!opp.Name.startsWith('XXXXXX-')){ //for dummy oppty name, not to change the oppty name.
                opp.Name = Salutation + acctLastName + acctFirstName;
                opp.Name = opp.Name.replace(' ','');
            }              
            if(acc.Gender__c != null){
                if(acc.Gender__c == 'Male'){
                    Salutation = 'Mr';
                }else if(acc.Gender__c == 'Female'){
                    Salutation = 'Ms';
                }
                
            }       
        }
        opp.CloseDate = endDate;
        if(cam != Null){
            opp.Campaign__c = cam.Id;  
            if(cam.Expiry_Date__c != Null){
                opp.CloseDate = cam.Expiry_Date__c;
            }        
        }
        if(String.isNotBlank(stageName)){
            opp.stageName = stageName;
        }
        if(owner != Null){
            opp.OwnerId = owner.Id;           
        }
        return opp;        
    } 
    
    public static OpportunityContactRole createOpportunityContactRole(Opportunity opp, Contact con, Boolean IsPrimary, String Role){
        OpportunityContactRole ocr = new OpportunityContactRole();
        if(opp != Null){
            ocr.OpportunityId = opp.Id;           
        }
        if(con != Null){
            ocr.ContactId = con.Id;           
        }
        if(IsPrimary != Null){
            ocr.IsPrimary = IsPrimary;        
        }
        if(String.isNotBlank(Role)){
            ocr.Role = Role;
        }
        insert ocr;
        return ocr;        
    }    
    
    public static void initBDCommonSetting(){        
        BD_Common_Setting__c bdcs = BD_Common_Setting__c.getValues('Default');
        if(bdcs != null){
            return;
        }
        bdcs = new BD_Common_Setting__c();
        bdcs.Name = 'Default';
        bdcs.OppBrokerNameBatchQty__c = 100;
        bdcs.OppCleanDays__c  = 90;
        insert bdcs;
    }
    
    public static void initTMGeneralSetting(){   
        TM_General_Setting__c gs = new TM_General_Setting__c();
        gs.Name = 'Default';
        gs.Default_Working_Hour__c = 7.5;
        gs.Contact_Window__c = 3;
        gs.Channel_Code_Inbound__c = 'SALESFP2DTMIN_SB';
        gs.Channel_Code_Outbound__c = 'SALESFP2DTMOU_SB';
        gs.Number_of_Asia_Miles_Membership__c = 10;
        gs.Submit_Policy_to_IPAS_Batch_Size__c = 2;
        gs.Task_Reminder_time_mins__c = 15;
        gs.UpdateWorkingHour_Batch_Size__c = '10';
        gs.UpdateWorkGroup_Enabled__c = true;
        gs.Contact_Window__c = 30;
        gs.Avaya_App_Id__c = '96CFA801-5AF0-4760-AB8D-C386381CB6EF';// Rancho_CallCenterUCID_20210618
        gs.Avaya_UCID_Endpoint__c = 'https://avyws.cigna.com.hk/api/aes_ucid_query';
        gs.Avaya_CHK_Campaign__c = 'rR0qYRWdqadmCihONRRev1crYJQwkNz2qfW0AEvmPKzNLDMtp3Mmo6oF4uh4Crnv';
        gs.Avaya_API_Callout_Enabled__c = true;// Rancho
        if(TM_General_Setting__c.getValues('Default') == null){
            insert gs;
        }
    }
    
    public static void initTMCampaignSetting(){ 
        TM_Campaign_Setting__c tcs = new TM_Campaign_Setting__c();
        tcs.Name = 'Default';
        tcs.Campaign_Group__c = 'EAP,ECM,EIN';
        tcs.Campaign_Batch_No__c = '0001';
        tcs.Prospect_Id_Running_No__c = '00000001';
        tcs.Campaign_Code_Running_No__c = '0001';
        tcs.term_code_Need_Dedup__c = ',114,115,301,380,400';
        tcs.Next_Batch_Num_Reset_Begin_Date__c = Date.today(); 
        //tcs.Batch_size__c = 200;

        if(TM_Campaign_Setting__c.getValues('Default') == null){
            insert tcs;
        }
    }
    
    public static void initCountryListSettings(){        
        Country_List_Settings__c cls = new Country_List_Settings__c(
            Name = 'CHINA',
            Aml_Highrisk__c = false,
            Chi_Desc__c = '中國',
            Country_Id__c = 'CHN',
            Crs_Ind__c = true,
            Eng_Desc__c = 'CHINA',
            s6_code__c = 'CN',
            Sanction_Country__c = false,
            Sanction_Nationality__c = false,
            Nationality__c = 'Chinese'// IA_AML_Inspection
        );
        Country_List_Settings__c cls3 = new Country_List_Settings__c(
            Name = 'HONG KONG',
            Aml_Highrisk__c = false,
            Chi_Desc__c = '香港',
            Country_Id__c = 'HKG',
            Crs_Ind__c = true,
            Eng_Desc__c = 'HONG KONG',
            s6_code__c = 'HKG',
            Sanction_Country__c = false,
            Sanction_Nationality__c = false,
            Nationality__c = 'Chinese'// IA_AML_Inspection
        );
        Country_List_Settings__c cls2 = new Country_List_Settings__c(
            Name = 'IRAN',
            Aml_Highrisk__c = true,
            Chi_Desc__c = '伊朗',
            Country_Id__c = 'IRN',
            Crs_Ind__c = false,
            Eng_Desc__c = 'IRAN',
            s6_code__c = 'IR',
            Sanction_Country__c = true,
            Sanction_Nationality__c = true,
            Nationality__c = 'Iranian'// IA_AML_Inspection
        );
        List<Country_List_Settings__c> clist=new List<Country_List_Settings__c>();
        clist.add(cls);
        clist.add(cls2);
        clist.add(cls3);
        if(Country_List_Settings__c.getValues('CHINA') == null){
            insert clist;
        }
    }
    
    public static void initBusinessNature(){        
        Business_Nature__c bn1 = new Business_Nature__c(
            name = 'ZZZZZZ',
            description__c = '以上皆否 - None of the above',
            Business_Nature_Chinese__c = '以上皆否',
            Business_Nature_English__c = 'None of the above',
            Business_Nature_Code__c = 'ZZZZZZ',
            Aml_Highrisk__c = FALSE
        );
        Business_Nature__c bn2 = new Business_Nature__c(
            name = 'ARTDLC',
            description__c = '藝術品商 - Art dealer',
            Business_Nature_Chinese__c = '藝術品商',
            Business_Nature_English__c = 'Art dealer',
            Business_Nature_Code__c = 'ARTDLC',
            Aml_Highrisk__c = TRUE
        );
        if(Business_Nature__c.getValues('ZZZZZZ') == null){
            insert bn1;
        }
        if(Business_Nature__c.getValues('ARTDLC') == null){
            insert bn2;
        }
    }    
    
    public static Company__c createCompany(String Name, String CompanyCode, String CompanyType){
        Company__c com = new Company__c();
        com.Name = Name;
        com.Company_Code__c = CompanyCode;
        com.Company_Type__c = CompanyType;
        insert com;
        return com;        
    }
    
    public static Product__c createProduct(String DeveloperName, String Name, String ProductCode){        
        Product__c pro = createProduct(DeveloperName, Name, ProductCode, null);
        return pro;        
    }
    
    public static Product__c createProduct(String DeveloperName, String Name, String ProductCode, Product__c Prod){        
        RecordType proRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Product__c' AND DeveloperName = :DeveloperName];
        Product__c pro = new Product__c();
        pro.RecordTypeId = proRt.Id;
        pro.Name = Name;
        if(DeveloperName == 'TM_Product'){
            pro.Code__c = ProductCode;
            pro.Product_Code__c = pro.Code__c;            
        } else{
            pro.Product_Code__c = ProductCode;
        }
        if(Prod != null){
            pro.Product__c = Prod.Id;
        }
        insert pro;
        return pro;        
    }
    
    public static Company_Product_Access_Control__c createCompanyProductAccessControl(Company__c com, Product__c pro, Boolean GI, Boolean Life){
        Company_Product_Access_Control__c cpac = new Company_Product_Access_Control__c();
        cpac.Company__c = com.Id;
        cpac.Custom_Product__c = pro.Id;
        cpac.GI__c = GI;
        cpac.Life__c = Life;
        insert cpac;
        return cpac;        
    }
    
    public static HttpCalloutVO.NBCriteria newNBCriteria(){
        
        Date myDate = date.newinstance(2017, 12, 12);
        DateTime myDatetime = DateTime.newInstance(2017, 2, 2, 2, 2, 2);
        String myDatetimeStr = myDatetime.format('yyyy-MM-dd HH:mm:ss.SSS\'Z\'');
        System.debug(myDatetimeStr);
        
        HttpCalloutVO.NBCriteria criteria = new HttpCalloutVO.NBCriteria();
        criteria.polNumber = 'PTP0000167';
        criteria.policyStatus = 'Submitted';
        criteria.transId = 'EST0000012000';
        criteria.applicantNumber = 'PTP0000170_20180301042846';
        
        criteria.planType = 'A';
        criteria.sumInsured = '1200000';
        criteria.productCode = 'NELG';
        
        criteria.rateScale = '6';
        criteria.rider1 = 'OPTG';
        criteria.campaignCode = 'PAR2014';
        
        criteria.firstName = 'firstName';
        criteria.lastName = 'lastName';
        criteria.maritalStatus = 'Single';
        criteria.gender = 'M';
        criteria.nationalityCode = '1';
        criteria.nationality = 'Chinese';// IA_AML_Inspection
        criteria.relationship = 'Policy Holder';
        criteria.IDType = 'HK PERM RESIDENT';
        criteria.ssnNumber = 'BP25A1R4';
        criteria.birthDate = String.ValueOf(mydate.addYears(-18));
        criteria.emailAddress = 'frank.yung@cigna.com';
        criteria.phoneNumber = '92022562';
        criteria.resAddrLine1 = 'resAddrLine1';
        criteria.resAddrLine2 = 'resAddrLine2';
        criteria.resAddrLine3 = 'resAddrLine3';
        criteria.resAddrLine4Code = '1';
        criteria.resAddrLine4 = 'resAddrLine4';
        criteria.permAddrLine1 = 'permAddrLine1';
        criteria.permAddrLine2 = 'permAddrLine2';
        criteria.permAddrLine3 = 'permAddrLine3';
        criteria.permAddrLine4 = 'permAddrLine4';
        criteria.corrAddrLine1 = 'corrAddrLine1';
        criteria.corrAddrLine2 = 'corrAddrLine2';
        criteria.corrAddrLine3 = 'corrAddrLine3';
        criteria.corrAddrLine4 = 'corrAddrLine4';
        criteria.height = '162';
        criteria.weight = '59';
        criteria.smokeInd = 'N';
        criteria.eligible = 'eligible';
        criteria.income = '15,001 - 20,000';
        criteria.occupation = 'occupation';
        
        HttpCalloutVO.NBPolicyHolder holder = new HttpCalloutVO.NBPolicyHolder();
        holder.title = 'title';
        holder.firstName = 'firstName';
        holder.lastName = 'lastName';
        holder.chineseName = '1';
        holder.maritalStatus = 'maritalStatus';
        holder.gender = 'M';
        holder.nationalityCode = '1';
        holder.nationality = 'CHINA';
        holder.IDType = 'IDType';
        holder.ssnNumber = 'BP25A1R3';
        holder.IDExpiryDate = mydate.addYears(2);
        holder.birthDate = String.ValueOf(mydate.addYears(-18));
        holder.birthPlace = 'CHINA';
        holder.emailAddress = 'esdg@cigna.com';
        holder.homePhoneNumber = '94613154';
        holder.officePhoneNumber = '34567890';
        holder.mobilePhoneNumber = '98765432';
        holder.phoneNumber = '98765432';
        holder.resAddrLine1 = 'line1';
        holder.resAddrLine2 = 'line2';
        holder.resAddrLine3 = 'line3';
        holder.resAddrLine4Code = '1';
        holder.resAddrLine4 = 'line4';
        holder.resCountry = 'CHINA';
        holder.permAddrLine1 = 'permAddrLine1';
        holder.permAddrLine2 = 'permAddrLine2';
        holder.permAddrLine3 = 'permAddrLine3';
        holder.permAddrLine4 = 'permAddrLine4';
        holder.permCountry = 'permCountry';
        holder.corrAddrLine1 = 'DP';
        holder.corrAddrLine2 = 'DP';
        holder.corrAddrLine3 = 'DP';
        holder.corrAddrLine4 = 'DP';
        holder.corrCountry = 'CHINA';
        holder.emplAddrLine1 = 'emplAddrLine1';
        holder.emplAddrLine2 = 'emplAddrLine2';
        holder.emplAddrLine3 = 'emplAddrLine3';
        holder.emplAddrLine4 = 'emplAddrLine4';
        holder.smokeInd = 'N';
        holder.taxNumber1 = '1';
        holder.taxCountry1 = 'CHINA';
        holder.taxNumber2 = '2';
        holder.taxCountry2 = 'CHINA';
        holder.taxNumber3 = '3';
        holder.taxCountry3 = 'CHINA';
        criteria.policyHolderList = new List<HttpCalloutVO.NBPolicyHolder>();
        criteria.policyHolderList.add(holder);
        
        criteria.fcCode = '213121';
        criteria.companyCode = 'DIR';
        criteria.jobTitle = 'jobTitle';
        criteria.privacyStatementInd = 'Y';
        criteria.optOutInd = 'Y';
        criteria.discountCode1 = '6';
        criteria.discountCode2 = '6';
        criteria.policyProduct = 'policyProduct';
        criteria.BenefitLevel = 'BenefitLevel';
        criteria.loadingPremiumRate = '1';
        criteria.uwPreUWId = '40962';
        criteria.uwPreUWResult = '1';
        criteria.uwFullUWId = '40963';
        criteria.uwFullUWResult = '3';
        criteria.fullUWProductCode = 'NELG';
        criteria.uwFullUWRiskType = 'R2_IPMIEO';
        criteria.uwBasicProductResult = '1';
        criteria.uwRiderResult1 = '1';
        criteria.uwRiderResult2 = '2';
        criteria.uwRiderResult3 = '3';
        criteria.uwRiderResult4 = '4';
        criteria.uwRiderResult5 = '5';
        criteria.uwRiderResult6 = '6';
        
        HttpCalloutVO.NBFullUWRiskResult fuwrr = new HttpCalloutVO.NBFullUWRiskResult();
        fuwrr.fullUWCode = 'fullUWCode';
        fuwrr.fullUWPlan = 'fullUWPlan';
        fuwrr.fullUWType = 'fullUWType';
        fuwrr.fullUWDescription = 'fullUWDescription';
        criteria.fullUWRiskList = new List<HttpCalloutVO.NBFullUWRiskResult>();
        criteria.fullUWRiskList.add(fuwrr);
        
        HttpCalloutVO.NBFullUWProductLoadingResult fuwplr = new HttpCalloutVO.NBFullUWProductLoadingResult();
        fuwplr.fullUWProductCode = '1';
        fuwplr.fullUWLoadingType = '1';
        fuwplr.fullUWLoadingValue = '1';
        fuwplr.fullUWLoadingDuration = 'fullUWLoadingDuration';
        criteria.fullUWProductLoadingResultList = new List<HttpCalloutVO.NBFullUWProductLoadingResult>();
        criteria.fullUWProductLoadingResultList.add(fuwplr);
        
        criteria.paymentMode = 'M';
        criteria.paymentModeCode = 'paymentModeCode';
        criteria.paymentStatusCode = 'paymentStatusCode';
        criteria.transactionVpcCode = '1';
        criteria.payAmount = '2';
        criteria.billFreq = '2';
        criteria.billMethod = '2';
        criteria.transactionDate = String.valueOf(mydate.addDays(8));
        criteria.transactionTime = String.valueOf(Datetime.now().time());
        criteria.policyRef = 'policyRef';
        criteria.bankCodeOrCreditCardCollectorID = 'Collector';
        criteria.accountNumber = 'acctno';
        criteria.creditCardExpiryDate = mydate.addDays(8);
        criteria.policyCurrency = 'USD';
        criteria.initialBillDate = mydate.addDays(8);
        criteria.masterPolicy = 'masterPolicy';
        criteria.relationshipOfPolicy = 'Policy Holder';
        criteria.policyPremium = '1';
        criteria.AMLHighRiskInd = true;
        criteria.exclusion = '2';
        criteria.medicalLoading = '2';
        criteria.loadingDuration = '2';
        
        HttpCalloutVO.BeneficiaryOwner be = new HttpCalloutVO.BeneficiaryOwner();
        be.firstName = 'firstName';
        be.lastName = 'lastName'; 
        be.gender = 'M';
        be.SSNNumber = 'Y1232130';
        be.birthDate = mydate.addDays(3);
        criteria.beneficiaryOwnerList = new List<HttpCalloutVO.BeneficiaryOwner>();
        criteria.beneficiaryOwnerList.add(be);
        
        HttpCalloutVO.Beneficiary bene = new HttpCalloutVO.Beneficiary();
        bene.firstName = 'firstName';
        bene.lastName = 'lastName'; 
        bene.gender = 'M';
        bene.relationship = 'relationship';
        bene.SSNNumber = 'SSNNumber';
        bene.birthDate = mydate.addDays(15);
        bene.interestPercent = 'interestPercent';
        criteria.beneficiaryList.add(bene);
        
        return criteria;         
        
    }
    
    //No Insert
    public static ESales_Transaction__c newESalesTransaction(){
        ESales_Transaction__c est = new ESales_Transaction__c();        
        est.Third_Party_Payer_Full_Name__c = 'david lin';
        est.Payment_Method_1st_Payment__c = 'Credit Card';
        est.First_Payment_DDA_Credit_Card_Number__c = '4111-1111-1111-1111';
        est.First_Pay_Credit_Card_Expiry_Date_Month__c = '03';
        est.First_Pay_Credit_Card_Expiry_Date_Year__c = '2030';
        est.Cheque_Number_1st_Paymet__c = '123321443';
        est.Payment_Method_Subsequent_Payment__c = 'Credit Card';
        est.DDA_Credit_Card_Number__c = '4111-1111-1111-1111';
        est.Current_Step__c = 2;
        est.Credit_Card_Expiry_Date_Month__c = '04';
        est.Credit_Card_Expiry_Date_Year__c = '2050';
        est.First_Pay_Credit_Card_Holder_Full_Name__c = 'holder1';
        est.Credit_Card_Second_Holder_Full_Name__c = 'holder2';
        est.Credit_Card_Third_Holder_Full_Name__c = 'holder3';
        est.Bank_Name__c = 'cool bank';
        est.Branch_Name__c = 'GZ';
        est.Bank_Account_No__c = '112-343-100863';
        est.DDA_Effective_Month__c = 'Feb';
        est.Request_Id__c = 'PH:324324;PI:5465465;C1:879879;C3:123324';
        est.Pending_Memo_Id__c = 'PH:4444;PI:2222;C1:5555;C3:1111';
        est.Is_From_Website__c = false;
        est.From_Broker_Portal__c = false;
        est.Policy_Number_PH__c = 'PTP0000170';
        est.Policy_Number_C1__c = 'PTP0000170';
        est.Policy_Number_C2__c = 'PTP0000170';
        est.Policy_Number_C3__c = 'PTP0000170';
        est.Nature_of_Business__c = '以上皆否 - None of the above';
        est.Campaign_Code__c = 'HK180000';
        est.riders__c = 'Rider1;Rider2';
        est.PI_Last_Name__c = 'PI Last Name';
        est.PH_is_PI__c = true;
        est.Date_of_Birth_PH__c = Date.today().addYears(-18);
        insert est;
        return est;   
    }
    
    public static Policy_Transaction__c createPolicyTransaction(Account acc, Opportunity opp, Integer NumberOfPersonInsured, String Step){
        return createPolicyTransaction(acc, opp, NumberOfPersonInsured, Step, 'Pending Payment');
    }
    
    public static Policy_Transaction__c createPolicyTransaction(Account acc, Opportunity opp, Integer NumberOfPersonInsured, String Step, String status){
        initRelationshipMapping();
        Policy_Transaction__c pt = new Policy_Transaction__c();
        pt.Account__c = acc.Id;
        pt.Opportunity__c = opp.Id;
        pt.Number_of_Person_Insured__c = NumberOfPersonInsured;
        pt.Product_Code__c = '@SP100';
        pt.Step__c = Step;
        //pt.Submission_Date_Time__c = Datetime.now();
        pt.Status__c = status;
        pt.Core_Campaign__c = opp.Campaign__c;
        pt.Product_Name__c = 'Cigna Senior Life Plan';
        pt.Web_Site_Running_Number__c = 'forTest';
        insert pt;
        return pt;   
    }
    
    public static New_Policy__c createNewPolicy(Account acc, Opportunity opp, Policy_Transaction__c pt){        
        return createNewPolicy(acc, opp, pt, 'Pending Basic Information', null);
    }
    
    public static New_Policy__c createNewPolicy(Account acc, Opportunity opp, Policy_Transaction__c pt, String status){        
        return createNewPolicy(acc, opp, pt, status, null);
    }
    
    public static New_Policy__c createNewPolicy(Account acc, Opportunity opp, Policy_Transaction__c pt, String status, Product__c prod){        
        initBusinessNature();
        initCountryListSettings();
        New_Policy__c np = new New_Policy__c();
        np.Account__c = acc.Id;
        np.Opportunity__c = opp.Id;
        np.Policy_Transaction__c = pt.Id;
        np.Policy_Status__c = status;
        np.nationality__c = 'Chinese';// IA_AML_Inspection
        np.Place_of_Birth__c = 'CHINA';// IA_AML_Inspection
        np.Residential_Address_Country__c = 'CHINA';
        np.Permanent_Address_Country__c = 'CHINA';
        np.Corresponding_Address_Country__c = 'CHINA';
        np.Tax_Residence_1__c = 'CHINA';
        np.Tax_Residence_2__c = 'CHINA';
        np.Tax_Residence_3__c = 'CHINA';
        np.business_nature__c = '以上皆否 - None of the above';  
        np.ID_Type__c = 'HK PERM RESIDENT';  
        np.Plan_Type__c = 'MI';
        np.Mobile_Phone__c = '12345678';
        np.Payment_Frequency__c = 'Annual';
        np.Age__c = 25;
        np.Date_of_Birth__c = Date.newInstance(1993,1,1);
        np.Personal_ID__c = 'ddddddd';
        np.gender__c = 'Male';
        np.ID_Type__c = 'HK PERM RESIDENT';
        np.UW_Requirement__c = 'GA';
        np.Payment_Type__c = 'Credit Card Billing';
        np.Credit_Card_Number__c = '4242424242424242';
        np.Submission_Date_Time__c = Datetime.now();
        np.UW_Overrall_Result__c = 'Referred';
        np.policy_no__c = 'CTM0009999';
        np.Product_Code__c = '@SP100';
        np.Pre_Sales_Result__c = 'Accepted';
        np.Discount_1__c = 'BUNDLE DISCOUNT';
        np.Discount_2__c = 'CHILD DISCOUNT*';
        np.Master_Policy_No__c = 'CTM0001111';
        if(null != prod){
            np.Product__c = prod.id;
        }
        
        
        insert np; 
        return np;   
    }
    
    public static New_Policy__c createNewPolicy(Account acc, Opportunity opp, Policy_Transaction__c pt, Product__c prod, String policyNumber){        
        initBusinessNature();
        initCountryListSettings();
        New_Policy__c np = new New_Policy__c();
        np.Account__c = acc.Id;
        np.Opportunity__c = opp.Id;
        np.Policy_Transaction__c = pt.Id;
        np.Policy_Status__c = 'Pending Basic Information';
        np.nationality__c = 'Chinese';
        np.Residential_Address_Country__c = 'CHINA';
        np.Permanent_Address_Country__c = 'CHINA';
        np.Corresponding_Address_Country__c = 'CHINA';
        np.Tax_Residence_1__c = 'CHINA';
        np.Tax_Residence_2__c = 'CHINA';
        np.Tax_Residence_3__c = 'CHINA';
        np.business_nature__c = '以上皆否 - None of the above';  
        np.ID_Type__c = 'HK PERM RESIDENT';  
        np.Plan_Type__c = 'MI';
        np.Mobile_Phone__c = '12345678';
        np.Payment_Frequency__c = 'Annual';
        np.Age__c = 25;
        np.Date_of_Birth__c = Date.newInstance(1993,1,1);
        np.Personal_ID__c = 'ddddddd';
        np.gender__c = 'Male';
        np.ID_Type__c = 'HK PERM RESIDENT';
        np.UW_Requirement__c = 'GA';
        np.Payment_Type__c = 'Credit Card Billing';
        np.Credit_Card_Number__c = '4242424242424242';
        np.Submission_Date_Time__c = Datetime.now();
        np.UW_Overrall_Result__c = 'Referred';
        np.policy_no__c = policyNumber;
        np.Product_Code__c = '@SP100';
        np.Pre_Sales_Result__c = 'Accepted';
        np.Discount_1__c = 'BUNDLE DISCOUNT';
        np.Discount_2__c = 'CHILD DISCOUNT*';
        np.Master_Policy_No__c = 'CTM0001111';
        if(null != prod){
            np.Product__c = prod.id;
        }
        
        
        insert np; 
        return np;
    }
    
    public static Plan_Quote__c createPlanQuote(New_Policy__c np){  
        Plan_Quote__c pq = new Plan_Quote__c();
        if(np != null){
            pq.Policy__c = np.Id;             
        }             
        pq.Is_Rider__c = false;
        pq.Premium__c = 6102;
        pq.Plan_Level__c = '1';
        pq.Product_Code__c = '@SP100'; 
        insert pq;   
        return pq;  
    }
    
    public static Person_Insured__c createPersonInsured(New_Policy__c np){
        Person_Insured__c pi = new Person_Insured__c();
        pi.Insured_First_Name__c = 'InsuredFirstName';
        pi.Insured_Last_Name__c = 'InsuredLastName';
        pi.ID_Type__c = 'HK PERM RESIDENT';
        
        pi.Insured_Type__c = 'PH = PI';
        pi.Benefit_Level__c = '1';
        pi.Date_of_Birth__c = Date.today();
        pi.PI_Age__c = 19;
        pi.Person_Insured_Name__c = 'InsuredName';
        pi.Personal_ID__c = 'ddddddd';
        pi.Height__c = 180;
        pi.Weight__c = 160;
        pi.Gender__c = 'Male';
        pi.Smoker__c = 'yes';
        pi.Relationship__c = 'Policy Holder';
        
        if(np != null){
            pi.New_Policy__c = np.Id;
        }
        insert pi;
        return pi;
    }
    
    public static Beneficiary__c createBeneficiary(New_Policy__c np, Person_Insured__c pi, String LastName){
        Beneficiary__c b = new Beneficiary__c();
        b.Last_Name__c = LastName;
        b.Policy__c = np.Id;
        b.Person_Insured__c = pi.Id;
        b.Relationship__c = 'Policy Holder';
        insert b;
        return b;  
    }
    
    public static UW_Result__c createUWResult(New_Policy__c np, String ApplicationId){
        UW_Result__c uwr = new UW_Result__c();
        uwr.Application_Id__c = ApplicationId;
        uwr.Policy__c = np.Id;
        insert uwr;
        return uwr;  
    }
    
    public static void initDataArchiveSetting(){   
        Data_Archive_Setting__c das = Data_Archive_Setting__c.getValues('Default');
        if(das != null){
            return;
        }     
        das = new Data_Archive_Setting__c();
        das.Name = 'Default';
        das.Batch_Size__c = 5000;
        das.Email_Address__c = 'andgan@cigna.com.cn;zhqing@cigna.com'; 
        das.Years__c = 7; 
        insert das;
    }    
    
    public static void initESalesEndpoint(){   
        ESales_Endpoint__c ese = ESales_Endpoint__c.getValues('Default');
        if(ese != null){
            return;
        }     
        ese = new ESales_Endpoint__c();
        ese.Name = 'Default';
        ese.AUW_Endpoint__c = 'https://autouwqa.cigna.com.hk/UWHK/services/UW?WSDL';
        ese.Get_Quote_Endpoint__c = 'https://uatts.cigna.com.hk/eSalesHKWS/getquoteproduct.do'; 
        ese.UAT_Private_URL__c = 'http://192.168.139.163:9081/';
        ese.UW_URL_Prefix__c = 'https://autouwqa.cigna.com.hk'; 
        ese.Get_Quote_Single_Endpoint__c = 'https://uatts.cigna.com.hk/eSalesHKWS/GetQuoteByPlan.do';
        ese.Esales_Endpoint__c = 'https://uatts.cigna.com.hk/eSalesHKWS/';
        insert ese;
    }
    
    public static void initRelationshipMapping(){   
        Relationship_Mapping__c rm = Relationship_Mapping__c.getValues('Policy Holder');
        if(rm != null){
            return;
        }             
        rm = new Relationship_Mapping__c();
        rm.Name = 'Policy Holder';
        rm.Code__c = 'PH';    
        rm.Description__c = 'Policy Holder';      
        insert rm;
    }
    
    public static void initTMSensitivityCodeList(){
        TM_Sensitivity_Code_List__c sencode1 = new TM_Sensitivity_Code_List__c(
            name = '01',
            Sencode__c = '01',
            description__c = 'Senior Govt Official',
            X3rd_Party_Opt_out__c = false,
            Email_opt_out__c = false,
            Opt_out__c = true,
            Overinsured_Exclusion__c = false,
            Phone_opt_out__c = false,
            ROP_extension_Opt_out__c = false,
            UW_Opt_out__c = false
        );
        if(TM_Sensitivity_Code_List__c.getValues('01') == null){
            insert sencode1;
        }
    }

    //junda add
    public static String initProfileId(){
        String ProfileId;
        List<Profile> portalProfile = [SELECT Id FROM Profile Where Name ='Cigna Customer User Profile' Limit 1];

        if(portalProfile!=null&&portalProfile.size()>0){
            ProfileId = portalProfile[0].Id;
        }

        return ProfileId;
    }

    // Rancho_CallCenterUCID_20210618
    public static void initCalloutRetrySetting(){
        Callout_Retry_Setting__c cr = new Callout_Retry_Setting__c();
        cr.Name = 'Default';
        cr.Max_Retry_Time_Scope__c = 3;
        cr.Max_Number_of_Retry__c = 3;
        cr.Retry_Interval_in_Millisecond__c = 1000;
        insert cr;

        Callout_Retry_Setting__c cr1 = new Callout_Retry_Setting__c();
        cr1.Name = 'Avaya_Retry';
        cr1.Max_Retry_Time_Scope__c = 3;
        cr1.Max_Number_of_Retry__c = 3;
        cr1.Retry_Interval_in_Millisecond__c = 1000;
        insert cr1;
    }
        
    public static List<Assessment_Questions_Product_Mapping__c> initAssessmentSetting(){
        List<Assessment_Questions_Product_Mapping__c> result=new List<Assessment_Questions_Product_Mapping__c>();
        Assessment_Questions_Product_Mapping__c mapping = new Assessment_Questions_Product_Mapping__c();
        mapping.name='Q1A4_Q2A2';
        mapping.Answer_of_Q1__c = 'For the expenses of outpatient visits and other medical needs (such as Dental, Vision benefit, etc)';
        mapping.Answer_of_Q2__c = 'Indemnity (cover the eligible expenses by the policy)';
        mapping.Available_Product_Code__c = 'NEL[OPT,DRT,DET]; PM[OPT,DEN]; DMB[DMO]; GAOP[ALL]; CBO[COP,COS,CAX,CDE,CVS]; @KIDSG[KOPSG]; PBT[OPT,ODT]; PBC[OPT,ODT]';
        result.add(mapping);
        return result;
    }

    public static List<TM_Product_Category__c> initTMProductCatSetting(){
        List<TM_Product_Category__c> result=new List<TM_Product_Category__c>();
        TM_Product_Category__c cat = new TM_Product_Category__c();
        cat.Product_Code__c = '@CBOG';
        cat.Parent_Product__C = 'CBO';
        cat.name='COMBO';
        result.add(cat);
        
        TM_Product_Category__c cat2 = new TM_Product_Category__c();
        cat2.Product_Code__c = '@NELG,@NESG';
        cat2.Parent_Product__C = 'NEL';
        cat2.name='Elite';
        result.add(cat2);
        return result;
    }

    // friend discount
    public static void initDiscountCode(){
        List<Discount_Code__c> discountList = new List<Discount_Code__c>();
        discountList.add(new Discount_Code__c(Name='00', Code__c='00', Description__c='EARLY BIRD', Group__c='EARLY BIRD'));
        discountList.add(new Discount_Code__c(Name='32',Code__c='32', Description__c='FAMILY POLICY DISCOUNT (2 PAX)', Group__c='FAMILY DISCOUNT'));
        discountList.add(new Discount_Code__c(Name='01',Code__c='01', Description__c='BUNDLE DISCOUNT', Group__c='BUNDLE DISCOUNT'));
        discountList.add(new Discount_Code__c(Name='02',Code__c='02', Description__c='CHILD DISCOUNT*', Group__c='CHILD DISCOUNT'));
        insert discountList;
    }
    public static void initTMProductCat(){
        List<TM_Product_Category__c> prodCateList = new List<TM_Product_Category__c>();
        prodCateList.add(new TM_Product_Category__c(Name='Elite_Friend_Discount_Group', Module__c='Family Discount', Parent_Product__c='NE_FD', Product_Code__c='NELG,@NELG,NESG,@NESG'));
        prodCateList.add(new TM_Product_Category__c(Name='Bespoke', Module__c='Assessment Question', Parent_Product__c='AB', Product_Code__c='@ABAG,@ABEG,ABWG'));
        insert prodCateList;
    }

    // CR48
    public static void initClaimSymptomsAndDiagnosis(){
        List<Claim_Symptoms_And_Diagnosis__c> diagnosisList = new List<Claim_Symptoms_And_Diagnosis__c>();
        diagnosisList.add(new Claim_Symptoms_And_Diagnosis__c(Diagnosis_Code__c='J06.9',Benefit_Code__c='A',Sequence__c=1,Diagnosis_Description_EN__c='test1',Diagnosis_Description_TC__c='test2',Is_Designated__c=true));
        insert diagnosisList;
    }

    public static void initPlanCodeClaimType(String ownerId){
        List<Plan_Code_Claim_Type__c> pcList = new List<Plan_Code_Claim_Type__c>();
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='ATUP',Rate_Scale__c='1',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='TUP',Rate_Scale__c='2',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='TUW',Rate_Scale__c='3',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='0000',Rate_Scale__c='1',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='0010',Rate_Scale__c='2',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='8030',Rate_Scale__c='3',TOPUP__C =true,OwnerId=ownerId)); 
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='TUS',Rate_Scale__c='1',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='ATUS',Rate_Scale__c='2',TOPUP__C =true,OwnerId=ownerId));
        pcList.add(new Plan_Code_Claim_Type__c(Plan_code__c='ATUW',Rate_Scale__c='3',TOPUP__C =true,OwnerId=ownerId));         
        insert pcList;
    }

    public static void initChatSetting(){
        MyChat_Setting__c myChat=new MyChat_Setting__c(name='chat',chatApiEndPoint__c='https://testd.la1-c1cs-it3.salesforceliveagent.com/chat/rest',deployId__c='deployId',orgId__c='orgId',liveVersion__c='50',vButIdCN__c='vbutidcn',vButIdEN__c='vbutiden',butIdCN__c='butidcn',butIdEN__c='butiden',butGroupId__c='vbutidcn,vbutiden,butidcn,butiden');
        insert myChat;
    }
}