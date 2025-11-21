@isTest
private class MyClaimSubmitControllerTest{
    
    private static user AdminUser;  
    private static user AdminUser2;  
    private static user BrokerUser;
    private static user CustomerUser;
    private static user CustomerUser_chi;
    private static List <Claim__c> cList;
    private static Claim__c cItem;
    private static Member_Management__c member;
    
    private static List <Claim_Type_Document__c> cTypeDocList;
    private static Claim_Type_Document__c cTypeDocItem;
    
    private static List <Plan_Code_Claim_Type__c> pCodeClaimTypeList;
    private static Plan_Code_Claim_Type__c pCodeClaimTypeItem;
    
     static void defaultSetting(){
        // Rancho_HKITSFDC212_20250401 - remove hard-code url
        WS_Callout_Setting__c calloutSetting = new WS_Callout_Setting__c(Name = 'Default',
                                                                         Endpoint__c= 'http://uat.cigna.com.hk/CignaFW/CignaDigitalWSService',
                                                                         CignaWSErrorLogRest_Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm()+'/customer/services/apexrest/CignaWSErrorLogRest'
                                                                        );
        insert calloutSetting;
    }

    static void PrepareData(){
        User aa = [select id, Name, ProfileId, UserRoleId, UserName, User_Type__c, LanguageLocaleKey, AccountId, Account.ssn__c from User where id = : Userinfo.getUserId()];
        
            
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        User User1 = new User(
            Username = System.now().millisecond() + 'test12e45mm2@test.com',
            ProfileId = p.Id,
            Alias = 'te23mm2',
            Email = 'test12345@cigna.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12ee45mm2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            agent_code__c = 'T90010',
            isActive =true                               
        );
        insert User1;
        
        AdminUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = p.Id,
            Username = 'TestENotificationSearchCtrl123@YIX.com',
            Contact_No_Country_Code__c='+86',
            Alias = 'batman',
            Email='tes23t@cigna.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Contact_No__c='214211',
            Lastname='TestABC',
            LanguageLocaleKey='zh_CN',
            LocaleSidKey='zh_CN',
            TimeZoneSidKey='America/Chicago',
            isActive =true,
            Agent_code__c ='test1234'
        );
        insert AdminUser;
        
        AdminUser2 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = p.Id,
            Username = 'TestENotificationSearchCtrl1234@YIX.com',
            Contact_No_Country_Code__c='+86',
            Alias = 'batman',
            Email='tes23t@cigna.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce1',
            Contact_No__c='214211',
            Lastname='TestABC2',
            LanguageLocaleKey='zh_TW',
            LocaleSidKey='zh_TW',
            TimeZoneSidKey='America/Chicago',
            isActive =true,
            Agent_code__c ='test1234'
        );
        insert AdminUser2;
        
        System.runAs ( AdminUser ) {
            Client_Portal_Setting__c cps = new Client_Portal_Setting__c();
            cps.Client_Portal_Cert_No_Ctrl__c = '59';
            cps.Client_Portal_Key__c='vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv';
            cps.Name = 'Key';
            insert cps;
            Op_Swat_Scan_Setting__c op=new Op_Swat_Scan_Setting__c();
            op.Name='OpSwat';
            op.profile_name__c ='Cigna Customer User;Cigna Customer User Profile;Cigna Broker Admin';
            op.endPoint__c='https://api.metadefender.com/v4/file';
            op.apikey__c='eed511da95125dc112b363b2cc73b1a6';
            op.turn_on__c=true;
            op.checkTime__c=2000;
            op.maxTime__c=30000;
            insert op;
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = AdminUser.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
                Lastname = 'Test Test',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@cigna.com'
            );
            Database.insert(contact1);
            
            Contact contact2 = new Contact(
                Lastname = 'Test Test',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@cigna.com'
            );
            Database.insert(contact2);
            
            //Create user
            //Profile portalProfile = [SELECT Id FROM Profile Where Name = 'Cigna Customer User' Limit 1];
            CustomerUser = new User(
                Username = System.now().millisecond() + 'test@test.com',
                ContactId = contact1.Id,
                ProfileId = TestClassUtility.initProfileId(),
                Alias = 'test123',
                Email = 'test12345@cigna.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'Asia/Hong_Kong',
                LocaleSidKey = 'en_HK',
                LanguageLocaleKey = 'en_US'
                
            );
            Database.insert(CustomerUser);
            
            CustomerUser_chi = new User(
                Username = System.now().millisecond() + 'test1@test.com',
                ContactId = contact2.Id,
                ProfileId = TestClassUtility.initProfileId(),
                Alias = 'test456',
                Email = 'test123456@cigna.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test123456',
                TimeZoneSidKey = 'Asia/Hong_Kong',
                LocaleSidKey = 'en_HK',
                LanguageLocaleKey = 'zh_TW'
                
            );
            Database.insert(CustomerUser_chi);
            
            Claim_Setting__c claimSetting =new Claim_Setting__c (
                name = 'Cigna',
                Claim_Form_Download_Prefix__c = 'UNIT_TEST',
                Email_Address_QHMS__c = 'test@test.com',
                Max_Record_Count_Per_Page__c = 2,
                Max_Record_GetPolicyListBasicByCriteria__c = '10',
                Claim_HKCode__c='2000',
                Group_Policy_Equal_To_Economist__c='91137'
            );
            insert  claimSetting;   
            
            Claim_Type_Code_Mapping_From_WS__c cTypeCodeMapping = new Claim_Type_Code_Mapping_From_WS__c(
                name = 'TEST',
                Claim_Type_Display_Wordings_Chinese__c = 'TEST',
                Claim_Type_Display_Wordings_English__c = 'TEST',
                CTM_CODE__c = 'TEST',
                CTM_CODE_WS__c = 'TEST',
                CTM_DESC__c = 'TEST',
                CTM_DESC_WS__c = 'TEST',
                CTM_SYSTEM__c = 'TEST'
            );
            insert cTypeCodeMapping;   
            
            cTypeDocList = new List <Claim_Type_Document__c>{};
            cTypeDocItem = new Claim_Type_Document__c(
                ACC__c = true,
                Active__c = true,
                CI__c = true,
                DIS__c = true,
                Document_Name__c = 'TEST',
                Document_Name_Chinese__c = 'TEST',
                Downloadable_as_PDF__c = true,
                HI__c = true,
                HIF__c = true,
                HPA__c = true,
                HS__c = true,
                MAT__c = true,
                OP__c = true,
                WL__c = true,
                OPF__c = true,
                Other_Rule_s__c = null,
                TTD__c = true,
                Is_Broker__c = true,
                Is_Customer__c = true
            );
            cTypeDocList.add(cTypeDocItem);
            
            Claim_Type_Document__c cTypeDocItem2 = new Claim_Type_Document__c();
            cTypeDocItem2 = cTypeDocItem.clone();
            cTypeDocItem2.Downloadable_as_PDF__c = false;
            cTypeDocItem2.Other_Rule_s__c = 'brokerPAC';
            cTypeDocList.add(cTypeDocItem2);
            insert cTypeDocList;
            
            List <Attachment> attList = new List <Attachment>{};
            for(Claim_Type_Document__c cTypeDocItem_tmp:    cTypeDocList){
                Attachment att1 = new Attachment();
                att1.parentId= cTypeDocItem_tmp.id;
                att1.name ='TEST';
                att1.body = Blob.valueof('TEST');
                attList.add(att1);
            }
            
            /**
            Attachment att1 = new Attachment();
            att1.parentId= cTypeDocItem.id;
            att1.name ='TEST';
            att1.body = Blob.valueof('TEST');
            attList.add(att1);
            
            Attachment att2 = new Attachment();
            att2.parentId= cTypeDocItem2.id;
            att2.name ='TEST';
            att2.body = Blob.valueof('TEST');
            attList.add(att2);
            insert attList;
             **/
            pCodeClaimTypeList = new List <Plan_Code_Claim_Type__c>{};
            pCodeClaimTypeItem = new Plan_Code_Claim_Type__c(
                A_General_Practitioner__c = true,
                ACC__c = true,
                AllowPreApproval__c = true,
                B_Specialist_Practitioner__c = true,
                Benefit_Code_Can_Choose__c = 'TEST',
                C_Laboratory_Testing_X_Ray__c = true,
                CI__c = true,
                Claim_Type__c = 'DIS',
                D_Chinese_Herbalist_Bonesetter_Acupunc__c = true,
                DIS__c = true,
                E_Physiotherapy_Chiropractic__c = true,
                F_Long_Term_Prescribed_Medicine__c = true,
                Fast_Track_Allow__c = true,
                G_Medical_Check_Up_Vaccination__c = true,
                H_Dental__c = true,
                HG__c = true,
                HI__c = true,
                HIF__c = true,
                HPA__c = true,
                HS__c = true,
                I_Others__c = true,
                Inforce_Policy__c = 'Y',
                IPMI__c = true,
                MAT__c = true,
                MIS__c = true,
                OP__c = true, 
                WL__c = true, 
                OTH__c = true,
                Package_Code__c = 'TEST',
                Package_Desc__c = 'TEST',
                Plan_code__c = 'TEST',
                Plan_Title__c = 'TEST',
                Product_Code__c = 'TEST',
                Product_Name__c = 'TEST',
                Rate_Scale__c = '1',
                SD__c = true,
                System__c = 'S6',
                TOPUP__c = true,
                TTD__c = true,
                WP__c = true,
                Is_Entitled__c = true,
                Allow_Government_Hospital_Visit__c = true
                
            );
            pCodeClaimTypeList.add(pCodeClaimTypeItem );
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem2 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem2 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem2.Plan_code__c = 'CHK';
            pCodeClaimTypeItem2.Rate_Scale__c = '';
            pCodeClaimTypeList.add(pCodeClaimTypeItem2);
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem3 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem3 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem3.Plan_code__c = 'ODC';
            pCodeClaimTypeItem3.Rate_Scale__c = '';
            pCodeClaimTypeList.add(pCodeClaimTypeItem3);
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem4 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem4 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem4.Plan_code__c = 'BHERAP';
            pCodeClaimTypeItem4.Rate_Scale__c = '';
            pCodeClaimTypeList.add(pCodeClaimTypeItem4);
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem5 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem5 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem5.Plan_code__c = 'OSP';
            pCodeClaimTypeItem5.Rate_Scale__c = '';
            pCodeClaimTypeList.add(pCodeClaimTypeItem5);
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem6 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem6 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem6.Plan_code__c = 'OPB';
            pCodeClaimTypeItem6.Rate_Scale__c = '';
            pCodeClaimTypeList.add(pCodeClaimTypeItem6);
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem7 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem7 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem7.Plan_code__c = 'DEN';
            pCodeClaimTypeItem7.Rate_Scale__c = '';
            pCodeClaimTypeList.add(pCodeClaimTypeItem7);
            
            Plan_Code_Claim_Type__c pCodeClaimTypeItem8 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem8 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem8.Plan_code__c = 'TEST';
            pCodeClaimTypeItem8.Rate_Scale__c = '1';
            pCodeClaimTypeList.add(pCodeClaimTypeItem8);

            Plan_Code_Claim_Type__c pCodeClaimTypeItem9 = new Plan_Code_Claim_Type__c();
            pCodeClaimTypeItem9 = pCodeClaimTypeItem.clone();
            pCodeClaimTypeItem9.Plan_code__c = 'LMDO';
            pCodeClaimTypeItem9.Rate_Scale__c = '1';
            pCodeClaimTypeList.add(pCodeClaimTypeItem9);
            
            insert pCodeClaimTypeList;
            
            
            cList = new List<Claim__c>();
            
            cItem =new Claim__c(
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
                WL__c = true,
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
                Admitted_and_discharged_from_hospital__c = '[{"dischargeDateTimeStamp":1488384000000,"dischargeDate":"2017-03-02","admissionDateTimeStamp":1488297600000,"admissionDate":"2017-03-01"}]',    //in json
                Information_from_other_companies__c = '[{"policyNum":"TEST","nameOfInsurer":"TEST"}]',    //in json
                Policy__c = 'CTA9000019, 123, 234',
                Visit_Date__c = '[{"visitDateTimeStamp":1488384000000,"visitDate":"2017-03-02"}]',    //in json
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
                Allow_Types_Of_Doctor_To_Claim__c = 'A B C D E F G H I J',
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
            
            Claim__c cItem2 = new Claim__c();
            cItem2 = cItem.clone();
            cItem.Policy__c = '';
            cList.add(cItem2);
            
            Claim__c cItem3 = new Claim__c();
            cItem3 = cItem.clone();
            cItem3.HIF__c = true;
            cItem3.HI__c = true;
            cItem3.HPA__c = true;
            cItem3.HS__c = true;
            cItem3.CI__c = true;
            cItem3.DIS__c = true;
            cItem3.MAT__c = true;
            cItem3.OP__c = true;
            cItem3.OPF__c = true;
            cItem3.Type_of_benefit_to_claim__c = '';
            cItem3.Person_s_Insured__c = '';
            cList.add(cItem3);
            
            Claim__c cItem4 = new Claim__c();
            cItem4 = cItem.clone();
            cItem4.Is_Using_Chinese_Version__c = true;
            cItem4.HIF__c = false;
            cItem4.HI__c = false;
            cItem4.HPA__c = false;
            cItem4.HS__c = false;
            cItem4.CI__c = false;
            cItem4.DIS__c = false;
            cItem4.OP__c = false;
            cItem4.WL__c = false;
            cItem4.OPF__c = false;
            cItem4.MAT__c = false;
            
            cList.add(cItem4);
            
            //HPA true / HS false
            Claim__c cItem5 = new Claim__c();
            cItem5 = cItem.clone();
            cItem5.Is_Using_Chinese_Version__c = false;
            cItem5.HIF__c = true;
            cItem5.HI__c = true;
            cItem5.HPA__c = true;
            cItem5.HS__c = false;
            cItem5.CI__c = true;
            cItem5.DIS__c = true;
            cItem5.OP__c = true;
            cItem5.WL__c = true;
            cItem5.OPF__c = true;
            cItem5.MAT__c = true;
            cItem5.HPA_Less_Than_2_Yrs__c= true;
            cItem5.HS_Less_Than_3_Yrs_or_Broker_PAC__c= true;
            cList.add(cItem5);
            
            //HPA false / HS true
            Claim__c cItem6 = new Claim__c();
            cItem6 = cItem.clone();
            cItem6.Is_Using_Chinese_Version__c = false;
            cItem6.HIF__c = true;
            cItem6.HI__c = true;
            cItem6.HPA__c = false;
            cItem6.HS__c = true;
            cItem6.CI__c = true;
            cItem6.DIS__c = true;
            cItem6.OP__c = true;
            cItem6.WL__c = true;
            cItem6.OPF__c = true;
            cItem6.MAT__c = true;
            cItem6.HPA_Less_Than_2_Yrs__c= true;
            cItem6.HS_Less_Than_3_Yrs_or_Broker_PAC__c= true;
            cList.add(cItem6);
            
            //WP
            Claim__c cItem7 = new Claim__c();
            cItem7 = cItem.clone();
            cItem7.Is_Using_Chinese_Version__c = false;
            cItem7.HIF__c = true;
            cItem7.HI__c = true;
            cItem7.HPA__c = true;
            cItem7.HS__c = true;
            cItem7.CI__c = true;
            cItem7.DIS__c = true;
            cItem7.OP__c = true;
            cItem7.WL__c = true;
            cItem7.OPF__c = true;
            cItem7.MAT__c = true;
            cItem7.HPA_Less_Than_2_Yrs__c= true;
            cItem7.HS_Less_Than_3_Yrs_or_Broker_PAC__c= true;
            cItem7.Is_Selected_Waiver_of_Premium__c = true;
            cItem7.Is_Selected_Temporary_or_Permanent_Dis__c = false;
            cList.add(cItem7);
            
            //DIS only , not WP
            Claim__c cItem8 = new Claim__c();
            cItem8 = cItem.clone();
            cItem8.Is_Using_Chinese_Version__c = false;
            cItem8.HIF__c = true;
            cItem8.HI__c = true;
            cItem8.HPA__c = true;
            cItem8.HS__c = true;
            cItem8.CI__c = true;
            cItem8.DIS__c = true;
            cItem8.OP__c = true;
            cItem8.WL__c = true;
            cItem8.OPF__c = true;
            cItem8.MAT__c = true;
            cItem8.HPA_Less_Than_2_Yrs__c= true;
            cItem8.HS_Less_Than_3_Yrs_or_Broker_PAC__c= true;
            cItem8.Is_Selected_Waiver_of_Premium__c = false;
            cItem8.Is_Selected_Temporary_or_Permanent_Dis__c = true;
            cList.add(cItem8);
            
            
            Claim__c cItem9 = new Claim__c();
            cItem9 = cItem.clone();
            cItem9.Visit_Date__c = '';
            cItem9.steps__c = 2;
            //cItem9.Visit_Date__c = '';
            
            cItem9.Is_Using_Chinese_Version__c = false;
            cItem9.HIF__c = true;
            cItem9.HI__c = true;
            cItem9.HPA__c = true;
            cItem9.HS__c = true;
            cItem9.CI__c = true;
            cItem9.DIS__c = true;
            cItem9.OP__c = true;
            cItem9.WL__c = true;
            cItem9.OPF__c = true;
            cItem9.MAT__c = true;
            cItem9.HPA_Less_Than_2_Yrs__c= true;
            cItem9.HS_Less_Than_3_Yrs_or_Broker_PAC__c= true;
            cList.add(cItem9);
            
            for(integer i = 0; i< 40; i++){
                Claim__c cItem_tmp = new Claim__c();
                cItem_tmp = cItem.clone();
                cList.add(cItem_tmp);
            }
            insert cList;  
            
            List <Attachment> attList_claim = new List <Attachment>{};
            Attachment att1_claim = new Attachment();
            att1_claim.parentId= cList[0].id;
            att1_claim.ContentType = 'application/pdf';
            att1_claim.name ='TEST';
            att1_claim.body = Blob.valueof('TEST');
            attList_claim.add(att1_claim);
            
            Attachment att2_claim = new Attachment();
            att2_claim.parentId= cList[0].id;
            att2_claim.ContentType = 'application/pdf';
            att2_claim.name ='TEST';
            att2_claim.body = Blob.valueof('TEST');
            attList_claim.add(att2_claim);
            
            insert attList_claim;
            
            Claim__c cItem_tmp = new Claim__c();
            cItem_tmp = cItem.clone();
            insert cItem_tmp;
                               
            TestClassUtility.prepareTestData(); 
            TestClassUtility.prepareTestDataOfCustomerCalloutHelper(); 
            TestClassUtility.prepareTestDataOfClaimCalloutHelper();    
            TestClassUtility.prepareTestDataofPolicyCalloutHelper();
            TestClassUtility.initCustomSetting();
            TestClassUtility.initClaimSymptomsAndDiagnosis();
            
            //wing  
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Claim__c request = new Claim__c();
            request.Credit_Card_No__c = '0000000000000000';
            request.Expiry_Date_of_Credit_Card_Month__c = 3;
            insert request;
            String myString = 'StringToBlob';
            Blob myBlob = Blob.valueof(myString);
            insert new Attachment(Name='test', parentId = request.Id, Body = myBlob);
            ApexPages.currentPage().getParameters().put('claimId', request.Id);
            Attachment attToRemove = new Attachment(Name='test2', parentId = request.Id, Body = myBlob);
            insert attToRemove;
            ClaimCtrl.removeAttId = attToRemove.Id;
            system.assert(ClaimCtrl.removeAttId!=null);
         //wing add end  
     
        }                 
    }  
    
    
    Static testmethod void TestMyClaimSubmitController(){
            
        PrepareData();
        System.runAs(adminUser){ 
            //create new ApexCalloutHelperMock
            // ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            // Test.setMock(HttpCalloutMock.class, ResponseMock);
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
          
            
            ClaimCtrl.loadDataFromWS();
            ClaimCtrl.cList[0].Policy__c = 'CTA9000019, TEST';
            ClaimCtrl.initData();
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.getGroupPolicyListBasicByCriteria('TEST','TEST');
            ClaimCtrl.getIndividualPolicyListBasicByCriteria('TEST','TEST','TEST','TEST','TEST','TEST');
            ClaimCtrl.getPersonBasic('TEST', true);
            ClaimCtrl.getPersonBasic('TEST', false);
            ClaimCtrl.getClinicVisitCount('TEST','TEST','TEST');
            //junda update
            ClaimCtrl.getPolicyPersonCoverageBasic('TEST','TEST');
            //junda update end
            ClaimCtrl.getPolicyPersonListBasic('TEST');
            ClaimCtrl.getPolicyPaymentBasic('3018');
            
            Map <String, String>    tmp_nameInfoMap = new Map <String, String>{};
            tmp_nameInfoMap.put('acctHolderName', 'WoXX ChXX PaXX' );
            tmp_nameInfoMap.put('accountNumber', 'N/A' );
            tmp_nameInfoMap.put('bankName', 'N/A');
            String tmpJSON = JSON.serialize(tmp_nameInfoMap);
            tmp_nameInfoMap.put('json', tmpJSON );
             
            ClaimCtrl.bankAccInfoList.add(tmp_nameInfoMap );
            ClaimCtrl.getPolicyPaymentBasic('HMKHK0000693908');
            ClaimCtrl.getPolicyBasic('CTA9000019');
            ClaimCtrl.getPolicyBasic('3018');
            ClaimCtrl.getPolicyBasic('HMKHK0000238958');
            ClaimCtrl.getPolicyBasic('HMKHK0001203152');
            ClaimCtrl.getPolicyBasic('HMKHK0000693908');
            ClaimCtrl.getPolicyBasic('TEST');
            //junda update
            ClaimCtrl.getPolicyPersonCoverageBasic('CTA9000019','A123456(7)');
            ClaimCtrl.getPolicyPersonCoverageBasic('3018','A123456(7)');
            //junda update end
            ClaimCtrl.getPersonBasic('CTA9000019', true);
            ClaimCtrl.getPersonBasic('CTA9000019', false);
            ClaimCtrl.createSamplePolicy();
            ClaimCtrl.CreateClaimRecord();
            ClaimCtrl.selectTransferHKBank();
            ClaimCtrl.selectTransferOverseaBank();
            ClaimCtrl.SelectBrokerPAC();
            ClaimCtrl.ResetBrokerPAC();
            ClaimCtrl.SelectHSBrokerPAC();
            ClaimCtrl.ResetHSBrokerPAC();
            ClaimCtrl.SelectHPABrokerPAC();
            ClaimCtrl.ResetHPABrokerPAC();
            ClaimCtrl.removeSelectedQuestion();
            ClaimCtrl.saveSelectedQuestion();
            ClaimCtrl.clearwAdmittedAndDischargedFromHospitalList();
            ClaimCtrl.calculationForAddmissionAndDischargedDate();
            ClaimCtrl.clearwVisitDateStrList();
            ClaimCtrl.calculationForVisitDate();
            ClaimCtrl.reloadClaimRecord();
            ClaimCtrl.loadClaimTypeDocument('HPA');
            ClaimCtrl.checkIfLessThanNumOfYears(System.today(), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addYears(-1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addMonths(-1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addDays(-1), System.today(), 1);
            ClaimCtrl.SearchPolicyBySelectedPH();
            ClaimCtrl.loadClaimTypeFromStr();
            ClaimCtrl.passOneBenefitTypeFlag();
            // ClaimCtrl.benefitTypeStr = 'HIF;HI;HPA;HS;CI;DIS;MAT;OP;OPF';
            // ClaimCtrl.SelectBenefitType();
            // ClaimCtrl.AllowTypeOfDoctorToClaim();
            
            // ClaimCtrl.currentSelectedQuestionId = '"q2"';
            // ClaimCtrl.saveSelectedQuestion();
            
            // ClaimCtrl.currentSelectedQuestionId = '"c2"';
            // ClaimCtrl.saveSelectedQuestionBrk();
            
            // ClaimCtrl.currentSelectedQuestionId = null;
            // ClaimCtrl.saveSelectedQuestionBrk();
            
            
            // ClaimCtrl.currentSelectedQuestionId = '"cx2"';
            // ClaimCtrl.saveSelectedExtraQuestionBrk();
            
            // ClaimCtrl.getListAtt('TEST');
            // ClaimCtrl.selectedPolicy = 'CTA9000019';
            //ClaimCtrl.LoadPIToGetPlanType();
            Test.stopTest();
            
   
                    
        }
    }
   
    Static testmethod void TestMyClaimSubmitController1(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();

            System.currentPageReference().getParameters().put('cId', cList[8].id);            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.AddPolicyIntoClaim();
            ClaimCtrl.DummyAction();
            ClaimCtrl.CannotEnterBankAccountInformation();
            ClaimCtrl.CanEnterBankAccountInformation();
            ClaimCtrl.clearFirstConsultationDateTimestamp();
            list<Bank_Account__c> bankAccountlist = new list<Bank_Account__c>();
            Bank_Account__c bankAccount = new Bank_Account__c();
            bankAccount.Account_Holder__c = '0';
            bankAccountlist.add(bankAccount);
            insert bankAccountlist; 
            ClaimCtrl.includeGSClaim=true;
            ClaimCtrl.steps=7;
            List <Claim__c> cList_tmp = new List <Claim__c>{};
            cList_tmp.add(cItem);
            ClaimCtrl.cList = cList_tmp;
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl.SaveRecord();
            ClaimCtrl.SavePIRecord();
            ClaimCtrl.SavePolicyRecord();
            ClaimCtrl.FindUploadAttachment();
            ClaimCtrl.RemoveUploadAttachment();
            ClaimCtrl.NextSteps();
            ClaimCtrl.PreviousSteps();
            ClaimCtrl.transformListStrToSet('[\'HIF\',\'CI\', \'HIF\']');
            ClaimCtrl.transformSetToListStr(new Set<String>{'HIF','CI'});
            
            ClaimCtrl.searchAllDocumentsByClaimType('HIF,HI,HPA,DIS,CI,MAT,HS,OP,OPF');
            ClaimCtrl.AddInfoFromOtherComp();
            ClaimCtrl.RemoveInfoFromOtherComp();
            ClaimCtrl.clearwInfoFromOtherCompanyList();
            ClaimCtrl.AddAdmissionAndDischargeDate();
            ClaimCtrl.RemoveAdmissionAndDischargeDate();
            ClaimCtrl.AddVisitDate();
            ClaimCtrl.RemoveVisitDate();
            ClaimCtrl.cList[0].HPA__c = true;
            ClaimCtrl.cList[0].HS__c = true;
            ClaimCtrl.cList[0].DIS__c = true;
            ClaimCtrl.getEmailContentBody(cItem);
            ClaimCtrl.cList[0].Is_Selected_Temporary_or_Permanent_Dis__c= true;
            ClaimCtrl.cList[0].Is_Selected_Waiver_of_Premium__c= false;
            ClaimCtrl.cList[0].Is_Using_Chinese_Version__c = true;
            ClaimCtrl.getEmailContentBody(cItem);
            ClaimCtrl.cList[0].Is_Selected_Temporary_or_Permanent_Dis__c= false;
            ClaimCtrl.cList[0].Is_Selected_Waiver_of_Premium__c= true;
            ClaimCtrl.getEmailContentBody(cItem);
            ClaimCtrl.submitEsignature();
            ClaimCtrl.eSignature = '123';
            ClaimCtrl.submitEsignature();
            
            ClaimCtrl.submitClaim();
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';
            
            List <Map <String, String>> tmpMapList = new List <Map <String, String>>{};
            Map <String, String> tmpMap1 = new Map <String, String>{};
            tmpMap1.put('productCode', 'TEST');
            tmpMap1.put('benefitCode', 'TEST');
            tmpMap1.put('rateScale', '1');
            
            Map <String, String> tmpMap2 = new Map <String, String>{};
            tmpMap2.put('productCode', 'OPB');
            tmpMap2.put('benefitCode', 'CHK');
            tmpMap2.put('rateScale', '');
            
            Map <String, String> tmpMap3 = new Map <String, String>{};
            tmpMap3 = tmpMap1.clone();
            
            tmpMapList.add(tmpMap1); 
            tmpMapList.add(tmpMap2); 
            tmpMapList.add(tmpMap3); 
            ClaimCtrl.searchAllClaimTypesByPlanCode( tmpMapList );
            
            Map <String, String> tmpKeyMap1 = new Map <String, String>{};
            tmpKeyMap1.put(  'CTA9000019', 'A123456(7)' );
            
            Map <String, String> tmpKeyMap2 = new Map <String, String>{};
            tmpKeyMap2.put( 'TEST', '123');
            
            Map <String, String> tmpKeyMap3 = new Map <String, String>{};
            tmpKeyMap3.put( 'TEST', '234');
            
            Map <Map<String, String>, List <Map<String, String>>> tmpKeyMapListMapList = new Map <Map<String, String>, List <Map<String, String>>>{};
            tmpKeyMapListMapList.put(tmpKeyMap1, tmpMapList);
            tmpKeyMapListMapList.put(tmpKeyMap2, tmpMapList);
            tmpKeyMapListMapList.put(tmpKeyMap3, tmpMapList);
            
            ClaimCtrl.pNumSsnValueListMap = tmpKeyMapListMapList;
            ClaimCtrl.getPolicyListForPI( ClaimCtrl.wPolicyList_PI, ClaimCtrl.wPolicyList_unchanged, ClaimCtrl.cList[0].Person_s_Insured__c);
            Test.stopTest();
            
                    
        }
    }
    
    
    Static testmethod void TestMyClaimSubmitController2(){
            
        PrepareData();
        System.runAs(adminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);

            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.loadDataFromWS();
            ClaimCtrl.initData();
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.clearClericalManualValue();
            ClaimCtrl.changeManualValue();
            ClaimCtrl.sendESignatureEmail();
            ClaimCtrl.sendAttachmentEmail();
            ClaimCtrl.SubmitClaimRequest();
            ClaimCtrl.loadFirstConsultationDate();
            ClaimCtrl.loadDateToStopWorkDate();
            ClaimCtrl.clearStopToWorkDateTimestamp();
            
            List <Map <String, String>> tmpMapList = new List <Map <String, String>>{};
            Map <String, String> tmpMap = new Map <String, String>{};
            tmpMap.put('productCode', 'TEST');
            tmpMap.put('benefitCode', 'TEST');
            tmpMap.put('benefitCode', '1');
            
            tmpMapList.add(tmpMap); 
            ClaimCtrl.searchAllClaimTypesByPlanCode( tmpMapList );
            ClaimCtrl.getClaimTypeStrForEmailTitle(cItem);
            ClaimCtrl.updatePIRecord();
            ClaimCtrl.NextStepsToSeven();
            ClaimCtrl.refreshSearch();
            
            ClaimCtrl.getPolicyListForPI( new List <ClaimHelper.WrapperPolicy>{}, new List <ClaimHelper.WrapperPolicy>{}, 'TEST');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','zh_TW');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','en_US');
            Test.stopTest();
            
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController3(){
            
        PrepareData();
        System.runAs(adminUser){
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.loadDataFromWS();
            ClaimCtrl.initData();
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.clearClericalManualValue();
            ClaimCtrl.changeManualValue();
            ClaimCtrl.sendESignatureEmail();
            ClaimCtrl.sendAttachmentEmail();
            ClaimCtrl.SubmitClaimRequest();
            ClaimCtrl.loadFirstConsultationDate();
            ClaimCtrl.loadDateToStopWorkDate();
            ClaimCtrl.clearStopToWorkDateTimestamp();
            
            List <Map <String, String>> tmpMapList = new List <Map <String, String>>{};
            Map <String, String> tmpMap = new Map <String, String>{};
            tmpMap.put('productCode', 'TEST');
            tmpMap.put('benefitCode', 'TEST');
            tmpMap.put('benefitCode', '1');
            
            tmpMapList.add(tmpMap); 
            ClaimCtrl.searchAllClaimTypesByPlanCode( tmpMapList );
            ClaimCtrl.getClaimTypeStrForEmailTitle(cItem);
            ClaimCtrl.updatePIRecord();
            ClaimCtrl.NextStepsToSeven();
            ClaimCtrl.refreshSearch();
            
            ClaimCtrl.getPolicyListForPI( new List <ClaimHelper.WrapperPolicy>{}, new List <ClaimHelper.WrapperPolicy>{}, 'TEST');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','zh_TW');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','en_US');
            Test.stopTest();
            
                    
        }
    }
    
    
    Static testmethod void TestMyClaimSubmitController6(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController controller = new MyClaimSubmitController();
            controller.bankName = '';
            controller.paramDMConsent = '';
            controller.esignatureEmail = '';
            controller.previousSelectedSsn= '';
            controller.errorMsg = '';
            controller.userSsn = '';
            controller.idx_bankAccountInfoHK  = '';
            controller.idx_bankAccountInfoOversea = '';
            controller.cId = cItem.id;
            controller.steps = 1;
            controller.loadDataFromWS();
            controller.EarliestPaidToDate = System.today();
            controller.wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c, List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
            controller.calculationForAddmissionAndDischargedDate();
            controller.loadData(0);
            controller.loadData(1);
            Map<String, String> pAccInfoMap_tmp = new Map <String, String>{};
            Map <String, Map<String, String>> tmpStrKeyMap = new Map <String, Map <String, String>>{};
            pAccInfoMap_tmp.put('fullName', 'TEST'); 
            pAccInfoMap_tmp.put('ssnNumber', 'A123456(7)'); 
            tmpStrKeyMap.put('A123456(7)', pAccInfoMap_tmp);    //assume ssn unique
            controller.allSsnNamePIMap = tmpStrKeyMap;
            controller.loadData(1);
            //controller.loadData(2);
            controller.CreateClaimRecord();
            controller.cList[0].Email_Address_to_send__c = 'test@test.com';
            controller.cList[0].Is_Using_Chinese_Version__c = true;
            //controller.sendESignatureEmail();
            // Zoe commented on 0504
            controller.cList[0].What_is_of_work_allocation_Clerical__c= '50';
            controller.changeManualValue();
            
            /**
            MyClaimSubmitController.toSendAttachmentEmail( String.valueOf(cList[0].id),'test@test.com','test@test.com', 'TEST', 'TEST', 'zh_TW' );
            MyClaimSubmitController.toSendAttachmentEmail( String.valueOf(cList[0].id),'test@test.com','test@test.com', 'TEST', 'TEST', 'en_US' );
            MyClaimSubmitController.toSendClaimFormEmail( String.valueOf(cList[0].id),'test@test.com','test@test.com');
            MyClaimSubmitController.toSendClaimFormToServer( String.valueOf(cList[0].id), new List <String>{'123','TEST'}, true );
            MyClaimSubmitController.toSendClaimFormToServer( String.valueOf(cList[0].id), new List <String>{'123','TEST'}, false );
            */
            MyClaimSubmitController.SubmitClaimRequestFromEmail( String.valueOf(cList[0].id),true);
            
            // Zoe commented on 0504
            
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController7(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            
            Test.startTest();
            MyClaimSubmitController controller = new MyClaimSubmitController();
            controller.getEmailContentBody( cList[3]);
            controller.getEmailContentBody( cList[4]);
            controller.getEmailContentBody( cList[5]);
            controller.getEmailContentBody( cList[6]);
            controller.getEmailContentBody( cList[7]);
            controller.getClaimTypeStrForEmailTitle( cList[3]);
            controller.getClaimTypeStrForEmailTitle( cList[4]);
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController8(){
            
        PrepareData();
        System.runAs(AdminUser2){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            
            Test.startTest();
            MyClaimSubmitController controller = new MyClaimSubmitController();
            controller.getEmailContentBody( cList[3]);
            controller.getEmailContentBody( cList[4]);
            controller.getEmailContentBody( cList[5]);
            controller.getEmailContentBody( cList[6]);
            controller.getEmailContentBody( cList[7]);
            controller.getClaimTypeStrForEmailTitle( cList[3]);
            controller.getClaimTypeStrForEmailTitle( cList[4]);
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController9(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            
            ClaimCtrl.loadDataFromWS();
            ClaimCtrl.initData();
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            //junda update
            ClaimCtrl.getPolicyPersonCoverageBasic('CTA9000019','A123456(7)');
            //junda update end
            ClaimCtrl.transformListStrToSet('[\'HIF\',\'CI\', \'HIF\']');
            ClaimCtrl.transformSetToListStr(new Set<String>{'HIF','CI'});
            
            ClaimCtrl.searchAllDocumentsByClaimType('HIF,HI,HPA,DIS,CI,MAT,HS,OP,OPF');
            List <Claim__c> cList_tmp = new List <Claim__c>{};
            cList_tmp.add(cItem);
            ClaimCtrl.cList = cList_tmp;
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';
            
            List <Map <String, String>> tmpMapList = new List <Map <String, String>>{};
            Map <String, String> tmpMap = new Map <String, String>{};
            tmpMap.put('productCode', 'TEST');
            tmpMap.put('benefitCode', 'TEST');
            tmpMap.put('benefitCode', '1');
            
            tmpMapList.add(tmpMap); 
            ClaimCtrl.searchAllClaimTypesByPlanCode( tmpMapList );
            
            Map <String, String> tmpKeyMap1 = new Map <String, String>{};
            tmpKeyMap1.put( 'CTA9000019', 'A123456(7)');
            
            Map <String, String> tmpKeyMap2 = new Map <String, String>{};
            tmpKeyMap2.put( '123', 'TEST');
            
            Map <String, String> tmpKeyMap3 = new Map <String, String>{};
            tmpKeyMap3.put( '234', 'TEST');
            
            Map <Map<String, String>, List <Map<String, String>>> tmpKeyMapListMapList = new Map <Map<String, String>, List <Map<String, String>>>{};
            tmpKeyMapListMapList.put(tmpKeyMap1, tmpMapList);
            tmpKeyMapListMapList.put(tmpKeyMap2, tmpMapList);
            tmpKeyMapListMapList.put(tmpKeyMap3, tmpMapList);
            
            ClaimCtrl.pNumSsnValueListMap = tmpKeyMapListMapList;
            ClaimCtrl.getIndividualPolicyListBasicByCriteria('','', 'A123456(7)','','','');    //CTA9005525
            ClaimCtrl.getGroupPolicyListBasicByCriteria('','');
            
            List <Map <String, String>> tmpStringMapList = new List <Map <String, String>>{};
            for(ClaimHelper.WrapperPolicy tmpWrapperItem:    ClaimCtrl.wPolicyList_unchanged){
                Map <String, String> tmpMapForPI1 = new Map <String, String>{};
                tmpMapForPI1.put('fullName', 'TEST'); 
                tmpMapForPI1.put('ssnNumber', 'TEST'); 
                tmpStringMapList.add(tmpMapForPI1);
                Map <String, String> tmpMapForPI2 = new Map <String, String>{};
                tmpMapForPI2.put('fullName', 'TEST'); 
                tmpMapForPI2.put('ssnNumber', 'A123456(7)'); 
                tmpStringMapList.add(tmpMapForPI2);
                tmpWrapperItem.PIMapList = tmpStringMapList;
                
            }
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';   
            ClaimCtrl.createSamplePolicy();
            
            //List <Map <String, String>> tmpStringMapList = new List <Map <String, String>>{};
            Map <String, String> tmpStrMap = new Map <String, String>{};
            tmpStrMap.put('fullName', 'Wincy Chan' ); 
            tmpStrMap.put('ssnNumber', 'A123456(7)'); 
            tmpStringMapList.add(tmpStrMap);
            
            Map <Map<String, String>, List<Map <String, String>>>    pNumSsnValueListMap = new Map <Map<String, String>, List<Map <String, String>>>{};
            
            for(ClaimHelper.WrapperPolicy wPolicy:    ClaimCtrl.wPolicyList_PI){
                wPolicy.PIMapList = tmpStringMapList;   
                List <Map <String, String>> tmpValueMapList = new List <Map<String, String>>{};
                Map <String, String> tmpKeyMap = new Map <String, String>{};
                tmpKeyMap.put( wPolicy.policyNum , 'A123456(7)');
                    
                Map <String, String> tmpValueMap = new Map <String, String>{};
                tmpValueMap.put( 'benefitAmount', '100');    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                tmpValueMap.put( 'benefitCode', 'TEST' );
                tmpValueMap.put( 'rateScale', '1' );
                
                tmpValueMapList.add(tmpValueMap);
                Map <String, String> tmpValueMap2 = new Map <String, String>{};
                tmpValueMap2.put( 'benefitAmount', '100');    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                tmpValueMap2.put( 'benefitCode', 'OPB' );
                tmpValueMap2.put( 'rateScale', '' );
                
                tmpValueMapList.add(tmpValueMap2);
                Map <String, String> tmpValueMap3 = new Map <String, String>{};
                tmpValueMap3.put( 'benefitAmount', '100');    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                tmpValueMap3.put( 'benefitCode', 'ODC' );
                tmpValueMap3.put( 'rateScale', '' );
                
                tmpValueMapList.add(tmpValueMap3);
                Map <String, String> tmpValueMap4 = new Map <String, String>{};
                tmpValueMap4.put( 'benefitAmount', '100');    //Sum Insured (ie. $/per day) x no of days =<HKD2000?
                tmpValueMap4.put( 'benefitCode', '0010' );
                tmpValueMap4.put( 'rateScale', '' );
                
                tmpValueMapList.add(tmpValueMap4);
                
                pNumSsnValueListMap.put(tmpKeyMap, tmpValueMapList);
            }      
            
            
            ClaimCtrl.pNumSsnValueListMap = pNumSsnValueListMap;
            //ClaimCtrl.loadSelectedWrapperPolicyList( ClaimCtrl.wPolicyList_PI, ClaimCtrl.wPolicyList_unchanged, ClaimCtrl.cList[0].Person_s_Insured__c);
            //ClaimCtrl.loadSelectedWrapperPolicyList( ClaimCtrl.wPolicyList_PI, ClaimCtrl.wPolicyList_unchanged, 'TEST');
            ClaimCtrl.loadSelectedWrapperPolicyList( ClaimCtrl.wPolicyList_PI, ClaimCtrl.wPolicyList_unchanged, 'A123456(7)');
            
            Test.stopTest();
            
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController10(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.checkIfLessThanNumOfYears(System.today(), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addYears(-1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addYears(-1).addMonths(-1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addYears(-1).addMonths(1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addYears(-1).addDays(1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addMonths(-1), System.today(), 1);
            ClaimCtrl.checkIfLessThanNumOfYears(System.today().addDays(-1), System.today(), 1);
            //ClaimCtrl.checkIfLessThanNumOfMonths(System.today(), System.today(), 1);
            //ClaimCtrl.checkIfLessThanNumOfMonths(System.today().addYears(-1), System.today(), 1);
            //ClaimCtrl.checkIfLessThanNumOfMonths(System.today().addDays(-1), System.today(), 1);
            //ClaimCtrl.checkIfLessThanNumOfMonths(System.today().addMonths(-1).addDays(-1), System.today(), 1);
            
            Test.stopTest();
            
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController11(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            String emailBody = ClaimCtrl.getEmailContentBody(cList[0]);
            String emailTitle = ClaimCtrl.getClaimTypeStrForEmailTitle(cList[0]);
            MyClaimSubmitController.toSendAttachmentEmail( String.valueOf(cList[0].id),'test@test.com','Cigna', emailBody, emailTitle, 'zh_TW' );
            MyClaimSubmitController.toSendAttachmentEmail( String.valueOf(cList[0].id),'test@test.com','Cigna', emailBody, emailTitle, 'en_US' );
            
            // Zoe updated on 0509 for queue
            /**
            List<String> attIdList = new List<String>();
            for (Attachment a : [Select Id From Attachment Where parentId =: cList[0].id]){
                attIdList.add(a.Id);
            }
            System.enqueueJob(new SubmitClaimToQHMSQueue(cList[0].id, attIdList, 'test@test.com', 1, attIdList.size()));
            */
            
            Test.stopTest();
                    
        }
    }
    
    
    
    Static testmethod void TestMyClaimSubmitController12(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Claim__c C0 = NEW Claim__c();
            C0.Person_s_Insured__c = 'A123456(7)';
            C0.HIF__c = true;
            C0.Submission_Date__c = system.today();
            C0.Selected_Question_s__c = '"q1""q2""q3"';
            C0.sj_HIF_d__c = true;
            C0.Admitted_and_discharged_from_hospital__c = '[{"dischargeDateTimeStamp":1473177600000,"dischargeDate":"2016-09-07","admissionDateTimeStamp":1473004800000,"admissionDate":"2016-09-05"}]';
            ClaimCtrl.cList[0] = C0;
            ClaimCtrl.wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c, List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
            ClaimCtrl.SavePIRecord();
            
            MyClaimSubmitController ClaimCtrl2 =new MyClaimSubmitController();
            ClaimCtrl2.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl2.cList[0].HIF__c = true;
            ClaimCtrl2.cList[0].Submission_Date__c = system.today();
            ClaimCtrl2.cList[0].Selected_Question_s__c = '"q1""q2""q3"';
            ClaimCtrl2.cList[0].sj_HIF_d__c = true;
            ClaimCtrl2.cList[0].Admitted_and_discharged_from_hospital__c = '[{"dischargeDateTimeStamp":1473177600000,"dischargeDate":"2016-09-07","admissionDateTimeStamp":1473004800000,"admissionDate":"2016-09-05"}]';
            ClaimCtrl2.wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c, List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
            ClaimCtrl2.SavePIRecord();
            ClaimCtrl2.EarliestPaidToDate = System.today().addDays(-1);
            ClaimCtrl2.calculationForAddmissionAndDischargedDate();
            ClaimCtrl2.EarliestPaidToDate = System.today().addYears(-2);
            ClaimCtrl2.calculationForAddmissionAndDischargedDate();
            ClaimCtrl2.SavePIRecord();
            
            MyClaimSubmitController ClaimCtrl3 =new MyClaimSubmitController();
            ClaimCtrl3.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl3.cList[0].HIF__c = true;
            ClaimCtrl3.cList[0].Submission_Date__c = system.today();
            ClaimCtrl3.cList[0].Selected_Question_s__c = '"q1""q2""q3"';
            ClaimCtrl3.cList[0].sj_HIF_d__c = true;
            ClaimCtrl3.cList[0].Admitted_and_discharged_from_hospital__c = '[{"dischargeDateTimeStamp":1473177600000,"dischargeDate":"2016-09-07","admissionDateTimeStamp":1473004800000,"admissionDate":"2016-09-05"}]';
            ClaimCtrl3.wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c, List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
            ClaimCtrl3.SavePIRecord();
            ClaimCtrl3.EarliestPaidToDate = System.today().addDays(-1);
            ClaimCtrl3.calculationForAddmissionAndDischargedDate();
            ClaimCtrl3.EarliestPaidToDate = System.today().addYears(-2);
            ClaimCtrl3.calculationForAddmissionAndDischargedDate();
            ClaimCtrl3.SavePIRecord();
            
            ClaimCtrl.getClaimTypeStrForEmailTitle(cList[4]);
            ClaimCtrl.getClaimTypeStrForEmailTitle(cList[5]);
            ClaimCtrl.getClaimTypeStrForEmailTitle(cList[6]);
            ClaimCtrl.getClaimTypeStrForEmailTitle(cList[7]);
            
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController14(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController15(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('phid', 'A12346(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController17(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl.cList[0].HIF__c = false;
            ClaimCtrl.cList[0].OP__c = true;
            ClaimCtrl.cList[0].WL__c = true;
            ClaimCtrl.cList[0].HI__c = false;
            ClaimCtrl.cList[0].HPA__c = false;
            ClaimCtrl.cList[0].CI__c = false;
            ClaimCtrl.cList[0].HS__c = false;
            ClaimCtrl.cList[0].DIS__c = false;
            ClaimCtrl.cList[0].MAT__c = false;
            ClaimCtrl.cList[0].OPF__c = true;
            ClaimCtrl.cList[0].Submission_Date__c = system.today();
            ClaimCtrl.cList[0].Selected_Question_s__c = '"q10""q11""q12""q13""q14"';
            ClaimCtrl.cList[0].sj_OP_d__c = true;
            ClaimCtrl.cList[0].Visit_Date__c = '[{"visitDateTimeStamp":1488384000000,"visitDate":"2017-03-02"}]';    //in json
            ClaimCtrl.wVisitDateStrList= (List<ClaimHelper.WrapperVisit>)JSON.deserialize(cItem.Visit_Date__c, List<ClaimHelper.WrapperVisit>.class);
            ClaimCtrl.SavePIRecord();
            
            MyClaimSubmitController ClaimCtrl2 =new MyClaimSubmitController();
            ClaimCtrl2.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl2.cList[0].HIF__c = false;
            ClaimCtrl2.cList[0].OP__c = true;
            ClaimCtrl2.cList[0].WL__c = true;
            ClaimCtrl2.cList[0].HI__c = false;
            ClaimCtrl2.cList[0].HPA__c = false;
            ClaimCtrl2.cList[0].CI__c = false;
            ClaimCtrl2.cList[0].HS__c = false;
            ClaimCtrl2.cList[0].DIS__c = false;
            ClaimCtrl2.cList[0].MAT__c = false;
            ClaimCtrl2.cList[0].OPF__c = true;
            ClaimCtrl2.cList[0].Submission_Date__c = system.today();
            ClaimCtrl2.cList[0].Selected_Question_s__c = '"q10""q11""q12""q13""q14"';
            ClaimCtrl2.cList[0].sj_OP_d__c = true;
            ClaimCtrl2.cList[0].Visit_Date__c = '[{"visitDateTimeStamp":1488384000000,"visitDate":"2017-03-02"}]';    //in json
            ClaimCtrl2.wVisitDateStrList= (List<ClaimHelper.WrapperVisit>)JSON.deserialize(cItem.Visit_Date__c, List<ClaimHelper.WrapperVisit>.class);
            ClaimCtrl2.SavePIRecord();
            ClaimCtrl2.EarliestPaidToDate = System.today().addDays(-1);
            ClaimCtrl2.calculationForVisitDate();
            ClaimCtrl2.EarliestPaidToDate = System.today().addYears(-2);
            ClaimCtrl2.calculationForVisitDate();
            ClaimCtrl2.SavePIRecord();
            
            MyClaimSubmitController ClaimCtrl3 =new MyClaimSubmitController();
            MyClaimSubmitController.toSendClaimFormEmail(ClaimCtrl3.cList[0].id, ClaimHelper.EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong' );
            
            ClaimCtrl3.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl3.cList[0].HIF__c = false;
            ClaimCtrl3.cList[0].OP__c = true;
            ClaimCtrl3.cList[0].WL__c = true;
            ClaimCtrl3.cList[0].HI__c = false;
            ClaimCtrl3.cList[0].HPA__c = false;
            ClaimCtrl3.cList[0].CI__c = false;
            ClaimCtrl3.cList[0].HS__c = false;
            ClaimCtrl3.cList[0].DIS__c = false;
            ClaimCtrl3.cList[0].MAT__c = false;
            ClaimCtrl3.cList[0].OPF__c = true;
            ClaimCtrl3.cList[0].Submission_Date__c = system.today();
            ClaimCtrl3.cList[0].Selected_Question_s__c = '"q10""q11""q12""q13""q14"';
            ClaimCtrl3.cList[0].sj_OP_d__c = true;
            ClaimCtrl3.cList[0].Visit_Date__c = '[{"visitDateTimeStamp":1488384000000,"visitDate":"2017-03-02"}]';    //in json
            ClaimCtrl3.wVisitDateStrList= (List<ClaimHelper.WrapperVisit>)JSON.deserialize(cItem.Visit_Date__c, List<ClaimHelper.WrapperVisit>.class);
            ClaimCtrl3.SavePIRecord();
            ClaimCtrl3.EarliestPaidToDate = System.today().addDays(-1);
            ClaimCtrl3.calculationForVisitDate();
            ClaimCtrl3.EarliestPaidToDate = System.today().addYears(-2);
            ClaimCtrl3.calculationForVisitDate();
            ClaimCtrl3.SavePIRecord();
            
            
            Test.stopTest();
                    
        }
    }
    
    
    Static testmethod void TestMyClaimSubmitController18(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna Hong Kong', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            //MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            List <String> tmpStrList = new List <String>{};
            tmpStrList.add('CTA9000019');
            tmpStrList.add('123');
            tmpStrList.add('234');
            MyClaimSubmitController.toSendClaimFormEmail(cList[0].id, ClaimHelper.EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong' );
            MyClaimSubmitController.toSendClaimFormToServer(cList[0].id, tmpStrList, true  );
            MyClaimSubmitController.toSendClaimFormToServer(cList[0].id, tmpStrList, false  );
            Test.stopTest();
                    
        }
    }
    
    
    Static testmethod void TestMyClaimSubmitController19(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna Hong Kong', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            List <String> tmpStrList = new List <String>{};
            tmpStrList.add('CTA9000019');
            tmpStrList.add('123');
            tmpStrList.add('234');
            MyClaimSubmitController.toSendClaimFormEmail(cList[0].id, ClaimHelper.EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong' );
            MyClaimSubmitController.toSendClaimFormToServer(cList[0].id, tmpStrList, true );
            MyClaimSubmitController.toSendClaimFormToServer(cList[0].id, tmpStrList, false );
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.cList[0].Policy__c = 'CTA9000019, 123, 234';
            lIST<ClaimHelper.WrapperPolicy> WPL = NEW lIST<ClaimHelper.WrapperPolicy>(); 
            
            ClaimHelper.WrapperPolicy WP = NEW ClaimHelper.WrapperPolicy();
            WP.policyNum = 'CTA9000019';
            wp.isIndividualPolicy = true;
            wp.isIPMI = true;                       
            wp.isIndividualPolicy = true;
            wp.isLessThan6Months = true;
            wp.isUSDPolicy = true;
            wp.isLifePolicy = true;
            wp.isUSDPolicy = true;            
            WPL.ADD(WP);
            
            ClaimHelper.WrapperPolicy WP1 = NEW ClaimHelper.WrapperPolicy();
            WP1.policyNum = 'Test';
            wp1.isIndividualPolicy = true;
            wp1.isIPMI = false;                       
            wp1.isIndividualPolicy = false;
            wp1.isLessThan6Months = false;
            wp1.isUSDPolicy = false;
            wp1.isLifePolicy = false;
            wp1.isUSDPolicy = false;            
            WPL.ADD(WP1);
            
            ClaimCtrl.wPolicyList_PI = WPL;
            ClaimCtrl.AddPolicyIntoClaim();
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController20(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            ApexCombinedCalloutHelperMock calloutResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, calloutResponseMock);
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna Hong Kong', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            List <String> tmpStrList = new List <String>{};
            tmpStrList.add('CTA9000019');
            tmpStrList.add('123');
            tmpStrList.add('234');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.cList[0].Policy__c = 'CTA9000019, 123, 234';
            ClaimCtrl.isHideWSForTesting = true;
            ClaimCtrl.AddPolicyIntoClaim();
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController21(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna Hong Kong', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.steps = 7;
            ClaimCtrl.PreviousSteps();
            ClaimCtrl.steps = 5;
            ClaimCtrl.PreviousSteps();
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController22(){
            
        PrepareData();
        System.runAs(CustomerUser_chi){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna Hong Kong', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            MyClaimSubmitController controller = new MyClaimSubmitController();
            controller.checkIfLessThanNumOfMonths(System.today(), System.today(), 1);
            controller.checkIfLessThanNumOfMonths(System.today().addMonths(-1).addDays(1), System.today(), 1);
            controller.checkIfLessThanNumOfMonths(System.today().addDays(-1), System.today(), 1);
            
            Date d1 = date.newinstance(2017, 1, 1);
            Date d2 = date.newinstance(2016, 12, 31);
            
            controller.checkIfLessThanNumOfMonths(d2, d1, 1);
            controller.checkIfLessThanNumOfMonths(d2, d1, 2);
            
            ClaimHelper.WrapperClaimUploadAttachment tmp1 = new ClaimHelper.WrapperClaimUploadAttachment();
            tmp1.attId = '';
            tmp1.attName = '';
            tmp1.relatedClaimTypeDocumentId = '';
            tmp1.parentClaimId = '';
            tmp1.attItem = null;
            
            ClaimHelper.WrapperClaim tmp2 = new ClaimHelper.WrapperClaim();
            
            ClaimHelper.WrapperPolicy tmp3 = new ClaimHelper.WrapperPolicy();
            tmp3.isTotalAndPermanentDisability = false;
            tmp3.isBrokerPAC = false;
            tmp3.isFastTrackAllow = false;
            tmp3.isIPMI = false;
            tmp3.PIName = '';
            tmp3.PIID = '';
            tmp3.productCode = '';
            tmp3.productName = '';
            tmp3.marketingName = '';
            tmp3.modalPremium = '';
            tmp3.PHMap = null;
            tmp3.coveragePeriodFrom = System.today();
            tmp3.coveragePeriodTo = System.today();
            tmp3.planTypeCode = '';
            tmp3.rateScale = '';
            tmp3.planTypeCodeStr = '';
            tmp3.benefitTypeListStr= '';
            tmp3.claimTypeListStr = '';
            
            ClaimHelper.WrapperClinicVisitCount tmp4 = new ClaimHelper.WrapperClinicVisitCount();
            tmp4.planTypeCode = '';
            tmp4.rateScale = '';
            tmp4.planTypeCodeStr = '';
            
            ClaimHelper.WrapperInfoFromOtherCompany tmp5 = new ClaimHelper.WrapperInfoFromOtherCompany();
            tmp5.nameOfInsurer = '';
            tmp5.policyNum = '';
            
            ClaimHelper.WrapperClaimTypeRelatedDocument tmp6 = new ClaimHelper.WrapperClaimTypeRelatedDocument();
            tmp6.attIdPrefix = '';
            
            ClaimHelper.WrapperClaim tmp7 = new ClaimHelper.WrapperClaim();
            tmp7.claimDate = System.today();
            tmp7.claimStatusCode = '';
            tmp7.ssnNum = '';
            tmp7.certNum = '';
            tmp7.memberName = '';
            tmp7.consultationDate = '';
            tmp7.dischargeDate = '';
            
            ClaimHelper.WrapperPerson tmp8 = new ClaimHelper.WrapperPerson();
            tmp8.sensitivityCode = '';
            
            Test.stopTest();
            
                    
        }
    }
    
    
    
    Static testmethod void TestMyClaimSubmitController23(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id+'#');
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Map<String,Map<String,String>> tmpNestedMap = new Map<String,Map<String,String>>{};
            Map<String, String> tmpValueMap = new Map <String, String>{};
            tmpValueMap.put('TEST','TESt');
            tmpNestedMap.put('TEST', tmpValueMap);
            ClaimCtrl.allSsnNamePIMap = tmpNestedMap;
            ClaimCtrl.loadData(1);
            Test.stopTest();
            
        }
    }
    
    Static testmethod void TestMyClaimSubmitController24(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Map<String,Map<String,String>> tmpNestedMap = new Map<String,Map<String,String>>{};
            Map<String, String> tmpValueMap = new Map <String, String>{};
            tmpValueMap.put('TEST','TEST');
            tmpValueMap.put('mobilePhoneNo','mobilePhoneNo');
            tmpValueMap.put('emailAddr','emailAddr');
            tmpNestedMap.put('TEST', tmpValueMap);
            tmpNestedMap.put('TEST2', tmpValueMap);
            ClaimCtrl.allSsnNamePIMap = tmpNestedMap;
            ClaimCtrl.cList = cList;
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.pAccIdInfoMap = tmpNestedMap;
            ClaimCtrl.getPHPersonBasic();
            Set<String> cTypeIdSet = new Set <String>{};
            cTypeIdSet.add(String.valueOf(cTypeDocItem.id));
            ClaimCtrl.loadClaimTypeDocumentAttachement(cTypeIdSet);
            Test.stopTest();
            
        }
    }
    
    // Zoe added on 0509 for queue
    Static testmethod void TestMyClaimSubmitController25(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            cList[0].Policy__c = 'test, test';
            update cList[0];
            
            List<String> attIdList = new List<String>();
            attIdList.add('');
            System.enqueueJob(new SubmitClaimQueue(cList[0].id, attIdList, 'test@test.com', 1, attIdList.size(), null, true, false));
            
            attIdList.remove(0);
            for (Attachment a : [Select Id From Attachment Where parentId =: cList[0].id]){
                attIdList.add(a.Id);
            }
            System.enqueueJob(new SubmitClaimQueue(cList[0].id, attIdList, 'test@test.com', 1, attIdList.size(), null, true, false));
            
            System.enqueueJob(new SubmitClaimQueue(cList[0].id, attIdList, null, null, null, cList[0].Is_Contain_Group_Policy__c, false, true));
            Test.stopTest();
                    
        }
    }
    
    // Zoe added on 0605 for queue
    Static testmethod void TestMyClaimSubmitController26(){
            
        PrepareData();
        System.runAs(AdminUser){ 
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
        
            Test.startTest();
            //SubmitHospitalController ctrl = setupCtrl(); 
            
            Claim__c request = new Claim__c();
            request.Upload_Admission_Note__c = true;
            insert request;
            
            String myString = 'StringToBlob';
            Blob myBlob = Blob.valueof(myString);
            insert new Attachment(Name='test', parentId = request.Id, Body = myBlob);
            
            // 12. submit
            ApexPages.currentPage().getParameters().put('claimId', request.Id);
            SubmitHospitalController ctrl2 = new SubmitHospitalController(null);
            ctrl2.acceptPaymentTC = true;
            insert new Claim_Setting__c(Name = 'Cigna', Email_Address_QHMS__c = 'testclass@cigna.com');
            insert new EmailTemplate(Name = 'Email to QHMS for GOP by WS', FolderId = UserInfo.getUserId(), TemplateType = 'text', developername = 'Email_to_QHMS_for_GOP_by_WS', Body = 'test');
            ctrl2.eSignature = 'abcd1234';
            ctrl2.admissionDateTimestamp = System.now().millisecond();
            ctrl2.policyNo = 'HMKHK0000238958';

            ctrl2.submitPreAdmission();
            
            // 13. submit from e-signature page
            SubmitHospitalController.submitPreAdmissionFromEmail(ctrl2.claimId, false);
            
            // SubmitHospitalController.clearGOPDetailsAfterSubmit(ctrl2.claimId);
            
            Test.stopTest();
                    
        }
    }
    
    // Zoe added on 0504
    Static testmethod void TestMyClaimSubmitController27(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            
            ClaimCtrl.cList = cList; 
            ClaimCtrl.refreshAckBrk();
            ClaimCtrl.refreshTCBrk();
            //MyClaimSubmitController.toSendESignatureEmail(cList[0].Id, 'Email to send signature link English', 'Test@test.com');
            
            MyClaimSubmitController.clearClaimDetailsAfterSubmit(cList[0].Id);
            Test.stopTest();
            
        }
    }
    
    // Jason added on 20180403
    Static testmethod void TestMyClaimSubmitController28(){
            
        PrepareData();
        ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
        //set the corrent body of response
        Test.setMock(HttpCalloutMock.class, ResponseMock);
        OrgWideEmailAddress owa = new OrgWideEmailAddress (
            DisplayName = 'Cigna', 
            Address= 'Cigna@Cigna.com'
        );
        Test.startTest();            
        System.currentPageReference().getParameters().put('cId', cList[8].id);
        System.currentPageReference().getParameters().put('phid', 'A123456(7)');
        System.currentPageReference().getParameters().put('phname', 'Test');
        MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
        
        ClaimCtrl.cList = cList;             
        ClaimCtrl.isCustomer = false;
        ClaimCtrl.userLanguage = 'zh_TW';
        ClaimCtrl.refreshAckBrk();
        ClaimCtrl.refreshTCBrk();            
        ClaimCtrl.getEmailContentBody(cItem);
        Test.stopTest();

    }
        
    // Jason added on 20180403
    Static testmethod void TestMyClaimSubmitController29(){
            
        PrepareData();
        ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
        //set the corrent body of response
        Test.setMock(HttpCalloutMock.class, ResponseMock);
        OrgWideEmailAddress owa = new OrgWideEmailAddress (
            DisplayName = 'Cigna', 
            Address= 'Cigna@Cigna.com'
        );        
        System.runAs(CustomerUser){ 
            Test.startTest();            
            MyClaimSubmitController controller = new MyClaimSubmitController();
            controller.bankName = '';
            controller.paramDMConsent = '';
            controller.esignatureEmail = '';
            controller.previousSelectedSsn= '';
            controller.errorMsg = '';
            controller.userSsn = '';
            controller.idx_bankAccountInfoHK  = '';
            controller.idx_bankAccountInfoOversea = '';
            controller.cId = cItem.id;
            controller.steps = 1;
            controller.loadDataFromWS();
            controller.EarliestPaidToDate = System.today();
            controller.wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c, List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
            controller.calculationForAddmissionAndDischargedDate();            
            Test.stopTest();
                    
        }
    }
    
    
    // Jason added on 20180403
    Static testmethod void TestMyClaimSubmitController30(){
            
        PrepareData();
        ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
        //set the corrent body of response
        Test.setMock(HttpCalloutMock.class, ResponseMock);
        ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
        OrgWideEmailAddress owa = new OrgWideEmailAddress (
            DisplayName = 'Cigna', 
            Address= 'Cigna@Cigna.com'
        );        
        System.runAs(Adminuser2){ 
            Test.startTest();            
            MyClaimSubmitController controller = new MyClaimSubmitController();
            controller.bankName = '';
            controller.paramDMConsent = '';
            controller.esignatureEmail = '';
            controller.previousSelectedSsn= '';
            controller.errorMsg = '';
            controller.userSsn = '';
            controller.idx_bankAccountInfoHK  = '';
            controller.idx_bankAccountInfoOversea = '';
            controller.cId = cItem.id;
            controller.steps = 1;
            controller.loadDataFromWS();
            controller.EarliestPaidToDate = System.today();
            controller.wAdmittedAndDischargedFromHospitalList = (List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>)JSON.deserialize(cItem.Admitted_and_discharged_from_hospital__c, List<ClaimHelper.WrapperAdmittedAndDischargedFromHospital>.class);
            controller.calculationForAddmissionAndDischargedDate();            
            Test.stopTest();
                    
        }
    }
    
    Static testmethod void TestMyClaimSubmitController31(){
            
        PrepareData();
        System.runAs(adminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
                        
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Map<String,Map<String,String>> tmpNestedMap = new Map<String,Map<String,String>>{};
            Map<String, String> tmpValueMap = new Map <String, String>{};
            tmpValueMap.put('TEST','TEST');
            tmpValueMap.put('mobilePhoneNo','mobilePhoneNo');
            tmpValueMap.put('emailAddr','emailAddr');
            tmpNestedMap.put('TEST', tmpValueMap);
            tmpNestedMap.put('TEST2', tmpValueMap);
            ClaimCtrl.allSsnNamePIMap = tmpNestedMap;
            ClaimCtrl.cList = cList;
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.pAccIdInfoMap = tmpNestedMap;
            cList[0].Email_Address_to_send__c = 'Test';
            ClaimCtrl.cList = cList;
            ClaimCtrl.sendESignatureEmail();
            ClaimCtrl.sendAttachmentEmail();
            ClaimCtrl.SubmitClaimRequest();
            ClaimCtrl.loadFirstConsultationDate();
            ClaimCtrl.loadDateToStopWorkDate();
            ClaimCtrl.clearStopToWorkDateTimestamp();
            
            List <Map <String, String>> tmpMapList = new List <Map <String, String>>{};
            Map <String, String> tmpMap = new Map <String, String>{};
            tmpMap.put('productCode', 'TEST');
            tmpMap.put('benefitCode', 'TEST');
            tmpMap.put('benefitCode', '1');
            
            tmpMapList.add(tmpMap); 
            ClaimCtrl.searchAllClaimTypesByPlanCode( tmpMapList );
            ClaimCtrl.getClaimTypeStrForEmailTitle(cItem);
            ClaimCtrl.updatePIRecord();
            ClaimCtrl.NextStepsToSeven();
            ClaimCtrl.refreshSearch();
            
            ClaimCtrl.getPolicyListForPI( new List <ClaimHelper.WrapperPolicy>{}, new List <ClaimHelper.WrapperPolicy>{}, 'TEST');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','zh_TW');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','en_US');
            Test.stopTest();
                                
        }
    }
    
      
    Static testmethod void TestMyClaimSubmitController32(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock   ResponseMock = new ApexCombinedCalloutHelperMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Map<String,Map<String,String>> tmpNestedMap = new Map<String,Map<String,String>>{};
            Map<String, String> tmpValueMap = new Map <String, String>{};
            tmpValueMap.put('TEST','TEST');
            tmpValueMap.put('emailAddr','emailAddr');
            tmpNestedMap.put('TEST', tmpValueMap);
            tmpNestedMap.put('TEST2', tmpValueMap);
            ClaimCtrl.allSsnNamePIMap = tmpNestedMap;
            ClaimCtrl.cList = cList;
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.pAccIdInfoMap = tmpNestedMap;
            ClaimCtrl.getPHPersonBasic();
            Set<String> cTypeIdSet = new Set <String>{};
            cTypeIdSet.add(String.valueOf(cTypeDocItem.id));
            ClaimCtrl.loadClaimTypeDocumentAttachement(cTypeIdSet);
            Test.stopTest();
            
        }
    }
    
    
    Static testmethod void TestMyClaimSubmitController34(){
            
        PrepareData();
        System.runAs(adminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
                        
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            Map<String,Map<String,String>> tmpNestedMap = new Map<String,Map<String,String>>{};
            Map<String, String> tmpValueMap = new Map <String, String>{};
            tmpValueMap.put('TEST','TEST');
            tmpValueMap.put('emailAddr','emailAddr');
            tmpNestedMap.put('TEST', tmpValueMap);
            tmpNestedMap.put('TEST2', tmpValueMap);
            ClaimCtrl.allSsnNamePIMap = tmpNestedMap;
            ClaimCtrl.cList = cList;
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            ClaimCtrl.pAccIdInfoMap = tmpNestedMap;
            cList[0].Email_Address_to_send__c = 'Test';
            ClaimCtrl.cList = cList;
            ClaimCtrl.sendESignatureEmail();
            ClaimCtrl.sendAttachmentEmail();
            ClaimCtrl.SubmitClaimRequest();
            ClaimCtrl.loadFirstConsultationDate();
            ClaimCtrl.loadDateToStopWorkDate();
            ClaimCtrl.clearStopToWorkDateTimestamp();
            
            List <Map <String, String>> tmpMapList = new List <Map <String, String>>{};
            Map <String, String> tmpMap = new Map <String, String>{};
            tmpMap.put('productCode', 'TEST');
            tmpMap.put('benefitCode', 'TEST');
            tmpMap.put('benefitCode', '1');
            
            tmpMapList.add(tmpMap); 
            ClaimCtrl.searchAllClaimTypesByPlanCode( tmpMapList );
            ClaimCtrl.getClaimTypeStrForEmailTitle(cItem);
            ClaimCtrl.updatePIRecord();
            ClaimCtrl.NextStepsToSeven();
            ClaimCtrl.refreshSearch();
            
            ClaimCtrl.getPolicyListForPI( new List <ClaimHelper.WrapperPolicy>{}, new List <ClaimHelper.WrapperPolicy>{}, 'TEST');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','zh_TW');
            MyClaimSubmitController.toSendAttachmentEmail('a0FN000000AqNl4','test@test.com','test@test.com','test','test','en_US');
            Test.stopTest();
                                
        }
    }
    
        
    Static testmethod void TestMyClaimSubmitController35(){
            
        PrepareData();
        System.runAs(adminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
                        
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            List<Claim__c> cl = new List<Claim__c>();
            Claim__c c = new Claim__c();
            c.Email_Address_to_send__c = 'Test';
            cl.add(c);
            ClaimCtrl.cList = cl;
            ClaimCtrl.sendAttachmentEmail();
            
            Test.stopTest();
                                
        }
    }
        
    Static testmethod void TestMyClaimSubmitController36(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
                        
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimHelper.WrapperPolicy wPolicyList_unchanged = new ClaimHelper.WrapperPolicy();
            wPolicyList_unchanged.policyNum = 'test1';
            Map<String, String> maptest = new Map<String, String>();
            maptest.put('ssnNumber', 'TEST');
            maptest.put('fullName', 'test2');
            maptest.put('certNum', 'test3');
            System.debug('maptest'+maptest);
            List<Map<String, String>> listTest = new List<Map<String, String>>();
            listTest.add(maptest);
            wPolicyList_unchanged.PIMapList = listTest;
            ClaimCtrl.wPolicyList_unchanged.add(wPolicyList_unchanged);
            ClaimCtrl.isCustomer = false;
            ClaimCtrl.selectedPolicy = 'Test';
            ClaimCtrl.cList = clist;
            System.debug('ClaimCtrl.wPolicyList_unchanged test:'+ClaimCtrl.wPolicyList_unchanged);
            for(ClaimHelper.WrapperPolicy wPolicyItem: ClaimCtrl.wPolicyList_unchanged){
                ClaimCtrl.wPolicyList_selected.add(wPolicyItem);
            }
            System.debug('ClaimCtrl.wPolicyList_selected test:'+ClaimCtrl.wPolicyList_selected);
            // ClaimCtrl.LoadPIToGetPlanType();
            ClaimCtrl.steps = 6;
            ClaimCtrl.PreviousSteps();
            ClaimCtrl.steps = 7;
            ClaimCtrl.PreviousSteps();
            ClaimCtrl.steps = 8;
            ClaimCtrl.PreviousSteps();
            Test.stopTest();
                                
        }
    }
    Static testmethod void TestMyClaimSubmitController37(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();
            //wing
            claim__c c = new claim__c();
            c.Policy__c = 'CTA9000019, 123, 234,testmethod';
            c.Type_of_benefit_to_claim__c = 'HIF;HI;HPA;HS;CI;DIS;MAT;OP;OPF';
            c.Person_Insured_Date_Of_Birth__c = System.today();
            c.Selected_Question_s__c = '"q1""q2""q3""q4""q5""q6""q7""q8""q9""q10""q11""q12""q13""q14""q16""q17""q18""q19""q20"';
            c.Admitted_and_discharged_from_hospital__c = '[{"dischargeDateTimeStamp":1488384000000,"dischargeDate":"2017-03-02","admissionDateTimeStamp":1488297600000,"admissionDate":"2017-03-01"}]';
            c.What_is_your_1st_consultation_date__c = System.today();
            c.Date_of_stop_working_due_to_disability__c = System.today();
            c.Please_input_the_amount_of_charge_HKD__c = 100;
            c.Visit_Date__c ='[{"visitDateTimeStamp":1488384000000,"visitDate":"2017-03-02"}]';
            c.Receive_reimbursement_from_other_comp__c = true;
            c.Information_from_other_companies__c =  '[{"policyNum":"TEST","nameOfInsurer":"TEST"}]';
            c.Is_Selected_Transfer_to_HK_Bank__c = true;
            c.Is_Selected_Transfer_to_Oversea_Bank__c = true;
            c.Payment_Currency__c = 'HKD';
            c.Is_Created_By_Customer__c = true;
            c.Is_Created_By_Broker__c = true;
            c.Certificate_Number__c = 'test1;test2;t3;t4';
            c.Is_Contain_Individual_Policy__c = false;
            c.Incurred_Country_Code__c = 'test';
            c.What_Are_Your_Symptoms_And_Diagnosis__c = 'test,test';
            insert c;
            
            Attachment attachment = new Attachment();
            attachment.ParentId = c.Id;
            attachment.Name = 'test';
            attachment.contentType='application/pdf';
            attachment.body = Blob.valueof('TEST');
            insert attachment;
            
            
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[0].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.selectedPolicy = 'Test';
            ClaimCtrl.cList = clist;
            ClaimCtrl.onChangeBankIndex = '0';
            for(ClaimHelper.WrapperPolicy wPolicyItem: ClaimCtrl.wPolicyList_unchanged){
                ClaimCtrl.wPolicyList_selected.add(wPolicyItem);
            }
            //MyClaimSubmitController.submitClaimWithAllAttachments(cList[8].id,false);
            //MyClaimSubmitController.sendNotification(cList[8].id);
            
            MyClaimSubmitController.submitClaimWithAllAttachments(c.id,true);
            // MyClaimSubmitController.sendNotification(c.id);
            //MyClaimSubmitController.SubmitClaimRequestFromEmail(c.Id);

            Test.stopTest();
                                
        }
    }  
    
    static testMethod void TestMyClaimSubmitController38() {
        prepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );            
            Test.startTest();                     
            MyClaimSubmitController ctrl = new MyClaimSubmitController();
            ctrl.getIsGSUser();
            List<Claim__c> tempClaim = [SELECT Id FROM Claim__c LIMIT 1];
            MyClaimSubmitController.sendNotification(tempClaim[0].Id);
            ctrl.loadBankAccountRecordByPassingId(tempClaim[0].Id);
            test.stopTest();              
         }  
    }

    @isTest
    static void TestMyClaimSubmitController39() {
        prepareData();
        System.runAs(AdminUser){ 
            GS_ESF_Policy_Match_Setting__c setting = new GS_ESF_Policy_Match_Setting__c();
            setting.Name = 'TestPolNumber';
            setting.Policy_Type__c = 'ESF';
            insert setting;
            MyClaimSubmitController ctrl = new MyClaimSubmitController();
            ctrl.checkESFPolicy('TestPolNumber');
            ctrl.checkESFPolicy('TestPolNumber-Non');
        }
    }
      
 
    //Wing
    
    //onPolicyChange
    static testMethod void testonPolicyChange() {
        prepareData();
        System.runAs(AdminUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );            
            Test.startTest();                     
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            
            ClaimCtrl.cList[0].OPF__c = true;
            ClaimCtrl.cList[0].OP__c = true;
            ClaimCtrl.selectedPolicy = 'Test';
            //ClaimCtrl.selectedPolicylist[0] = 'Test';
            
            list<Bank_Account__c> bankAccountlist = new list<Bank_Account__c>();
            Bank_Account__c bankAccount = new Bank_Account__c();
            bankAccount.Account_Holder__c = 'test';
            bankAccountlist.add(bankAccount);
            insert bankAccountlist;
            system.assert(bankAccountlist.size()>0);
            system.assert(bankAccountlist != null);

            
            MyClaimSubmitController helper = new MyClaimSubmitController();
            helper.onPolicyChange();
            system.assert(ClaimCtrl.cList != null);
            test.stopTest();              
         }  
    }
      
    
    //getPersonBasicAfterLoadPage
    static testMethod void testgetPersonBasicAfterLoadPage() {
        prepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock); 
            //set the corrent body of response
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );            
            Test.startTest();                     
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            ClaimCtrl.loadDataFromWS();
            ClaimCtrl.initData();
            ClaimCtrl.loadData(1);
            ClaimCtrl.loadData(2);
            
            ClaimCtrl.cList[0].OPF__c = true;
            ClaimCtrl.cList[0].OP__c = true;
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';
            for(ClaimHelper.WrapperPolicy wPolicyItem: ClaimCtrl.wPolicyList_unchanged){
                ClaimCtrl.wPolicyList_selected.add(wPolicyItem);
            }
            system.assert(ClaimCtrl.wPolicyList_selected != null);
            ClaimCtrl.LoadPIToGetPlanType();            
            MyClaimSubmitController helper = new MyClaimSubmitController();
            helper.getPersonBasicAfterLoadPage();
            system.assert( ClaimCtrl.cList != null);
            test.stopTest();              
         }  
    }
    
    //performanceGetPersonBasic
    Static testmethod void TestperformanceGetPersonBasic(){
            
        PrepareData();
        System.runAs(CustomerUser){ 
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            //set the corrent body of response
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            OrgWideEmailAddress owa = new OrgWideEmailAddress (
                DisplayName = 'Cigna', 
                Address= 'Cigna@Cigna.com'
            );
            Test.startTest();                      
            Test.setCurrentPageReference(new PageReference('Page.BaseMyClaimVFP')); 
            System.currentPageReference().getParameters().put('cId', cList[8].id);
            System.currentPageReference().getParameters().put('phid', 'A123456(7)');
            System.currentPageReference().getParameters().put('phname', 'TEST');
            MyClaimSubmitController ClaimCtrl =new MyClaimSubmitController();
            for(ClaimHelper.WrapperPolicy wPolicyItem: ClaimCtrl.wPolicyList_unchanged){
                ClaimCtrl.wPolicyList_selected.add(wPolicyItem);
            }
            //ClaimCtrl.LoadPIToGetPlanType();
            ClaimCtrl.steps = 7;
            ClaimCtrl.PreviousSteps();
            ClaimCtrl.cList[0].Person_s_Insured__c = 'A123456(7)';
            ClaimCtrl.cList[0].OPF__c = true;
            ClaimCtrl.cList[0].OP__c = true;
            MyClaimSubmitController helper = new MyClaimSubmitController();
            helper.performanceGetPersonBasic();
            
            helper.bankNameList=new List<SelectOption>();
            helper.bankCountryList=new List<SelectOption>();
            helper.incurredCountryList=new List<SelectOption>();
            helper.currencyList=new List<SelectOption>();
            helper.employeeMember=null;
            helper.bankAccInfoForGSJSon='';
            helper.isMultiplePolicy=false;
            system.assert(helper.transField!=null);
            system.assert(helper.transKey!=null);
            //system.assert(ClaimCtrl.cList != null);
            Test.stopTest();
                                
        }
    }

    static testMethod void testCR48FastTrackClaim(){
        PrepareData();
        System.runAs(CustomerUser){
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            Test.startTest();
            MyClaimSubmitController ctrl =new MyClaimSubmitController();
            ctrl.loadClaimSymptomsAndDiagnosis();
            ctrl.loadClaimSymptoms('A');
            Test.stopTest();
        }
    }
    static testMethod void testshowHKBankAccount(){
         PrepareData();
        System.runAs(CustomerUser){
            ApexCombinedCalloutHelperForClaimMock ResponseMock = new ApexCombinedCalloutHelperForClaimMock();
            Test.setMock(HttpCalloutMock.class, ResponseMock);
            Test.startTest();
            MyClaimSubmitController ctrl =new MyClaimSubmitController();
            list<Bank_Account__c> bankAccountlist = new list<Bank_Account__c>();
            Bank_Account__c bankAccount = new Bank_Account__c();
            bankAccount.Account_Holder__c = 'test';
            bankAccountlist.add(bankAccount);
            ctrl.bankAccountList=bankAccountlist;
            insert bankAccountlist; 
           EsalesMember member = new EsalesMember('MemberId', 'PolicyNumber', 'CertNumber', 'PolicyYear', 'FirstName', 'LastName', system.today(), 
                        system.today(), system.today(), EsalesMember.MemberRelationshipType.Employee, 'Region', 'RelatedCertNumber', 
                        'SSN', 'AllowTopUp', 'DDASignatureReqiured', 'DDASignatureCompleted', 'SubmitStatus', 'TopUpStatus', 
                        system.today(), system.today());
            member.Region='HK';
            ctrl.employeeMember=member;
            ctrl.onChangeBankIndex='0';
            ctrl.showHKBankAccount();
            ctrl.showOverseaBankAccount();
            Test.stopTest();
        }
    } 
}