@isTest 
public class BrkSubmitHospitalControllerTest{
    public static user AdminUser;
    public static user TestUser;
    
    public static BrkSubmitHospitalController setupCtrl() { 
        BrkSubmitHospitalController ctrl = new BrkSubmitHospitalController(null);
        return ctrl;
    }

    @TestSetup
    static void setupSetting(){
        TestClassUtility.prepareTestDataofPolicyCalloutHelper();
        TestClassUtility.initCustomSetting();
    }
    
    static void prepareTestData() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        AdminUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'gopTestAdmin@test.com',
            Alias = 'test',
            Email='test@cigna.com',
            EmailEncodingKey='UTF-8',
            Firstname='test',
            Lastname='test',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_HK',
            TimeZoneSidKey='Asia/Hong_Kong'
        );
        Database.insert(AdminUser);
        
        System.runAs ( AdminUser ) {
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = AdminUser.Id
            );
            Database.insert(portalAccount1);
            Ingage_NPS_Setting__c setting = new Ingage_NPS_Setting__c();
            setting.Name='English Survey';
            setting.Company_Name__c = 'Test Company';
            setting.Customer_NPS_Survey_ID__c = '0asdkf324';
            setting.Survey_Site_URL__c = 'http://testurl';
            insert setting;
            Ingage_NPS_Setting__c setting2 = new Ingage_NPS_Setting__c();
            setting2.Name='Chinese Survey';
            setting2.Company_Name__c = 'Test Company';
            setting2.Customer_NPS_Survey_ID__c = '0asdkf3242';
            setting2.Survey_Site_URL__c = 'http://testurl2';
            insert setting2;
            //Create contact
            Contact contact1 = new Contact(
                // FirstName = 'Test',
                Lastname = 'Test',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);
            
            //Create user
            //Profile portalProfile = [SELECT Id FROM Profile Where Name = 'Cigna Customer User' Limit 1];
            TestUser = new User(
                Username = System.now().millisecond() + 'gopTest@test.com',
                ContactId = contact1.Id,
                ProfileId = TestClassUtility.initProfileId(),
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'Asia/Hong_Kong',
                LocaleSidKey = 'en_HK',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(TestUser);
        }
        
        System.runAs(TestUser) {
            
            String myString = 'StringToBlob';
            Blob myBlob = Blob.valueof(myString);
            insert new Document(Name='test', DeveloperName = 'PIC_Statement_Text', FolderId = UserInfo.getUserId(), Body = myBlob);
            
        }
    }
    
    static void changeLanguage() {
        System.runAs ( AdminUser ) {
            if (TestUser.LanguageLocaleKey == 'en_US'){
                TestUser.LanguageLocaleKey = 'zh_TW';
            }
            else{
                TestUser.LanguageLocaleKey = 'en_US';
            }
            update TestUser;
        }
    }
    
    @isTest 
    //search PI
    public static void testSearchPI() {
        prepareTestData();
        System.runAs(TestUser) {
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
        
            Test.startTest();
            
            BrkSubmitHospitalController ctrl = setupCtrl();
            ctrl.getSearchType();
            ctrl.brokerContactNo = '1234';
            ctrl.phIsNotPi = false;
            system.assert(String.isBlank(ctrl.errorMsg));
            
            
            ctrl.selectedSearchValue = 'X343163';
            ctrl.selectedSearchType = 'Person_Insured_ID';
            ctrl.claimRequest.Person_s_Insured__c = 'X343163';
            ctrl.searchPI();
            system.assert(ctrl.personInsuredList != null);
            
            ctrl.selectedSearchValue = 'RUI ****** T******';
            ctrl.selectedSearchType = 'Person_Insured';
            ctrl.searchPI();
            system.assert(ctrl.personInsuredList != null);

            ctrl.selectedSearchValue = 'BROKER';
            ctrl.selectedSearchType = 'Policy_Holder_Name';
            ctrl.searchPI();
            system.assert(ctrl.personInsuredList != null);

            ctrl.selectedSearchValue = 'P234245';
            ctrl.selectedSearchType = 'Policy_Holder_ID';
            ctrl.searchPI();
            system.assert(ctrl.personInsuredList != null);

            ctrl.selectedSearchValue = 'TEST0003248';
            ctrl.selectedSearchType = 'Policy_Number';
            ctrl.searchPI();
            system.assert(ctrl.personInsuredList != null);
        }
    }
    
    @isTest 
    //scenario1: pre-admission list 
    public static void testList() {
        ApexPages.currentPage().getParameters().put('claimId', 'test');
        BrkSubmitHospitalController ctrl = setupCtrl();
        
        List<Claim__c> claimList = ctrl.getPreAdmissionList();
        ctrl.removePreAdmination();
        
        system.assertNotEquals(null,ctrl); 
    }
    
    @isTest 
    //scenario2: saved record
    public static void savedRecordDefault() {
        prepareTestData();
        System.runAs(TestUser) {
        	Op_Swat_Scan_Setting__c op=new Op_Swat_Scan_Setting__c();
            op.Name='OpSwat';
            op.profile_name__c ='Cigna Customer User;Cigna Customer User Profile;Cigna Broker Admin';
            op.endPoint__c='https://api.metadefender.com/v4/file';
            op.apikey__c='eed511da95125dc112b363b2cc73b1a6';
            op.turn_on__c=false;
            op.checkTime__c=2000;
            op.maxTime__c=30000;
            insert op;
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
        
            Test.startTest();
            
            BrkSubmitHospitalController ctrl = setupCtrl();
            ctrl.acceptPaymentTC = true;
            ctrl.expiryMonth = '10';
            ctrl.expiryYear = '2020';
            ctrl.claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c = '';
            ctrl.claimRequest.Contact_No_Country_Code__c = '86';
            
            ctrl.SavePreAdmission();
            system.assertNotEquals(null, ctrl.claimId);  
            
            Claim__c request = new Claim__c();
            request.Credit_Card_No__c = '0000000000000000';
            request.Expiry_Date_of_Credit_Card_Month__c = 3;
            
            insert request;
            
            ApexPages.currentPage().getParameters().put('claimId', request.Id);
            BrkSubmitHospitalController ctrl2 = setupCtrl();
            
            ctrl2.InputCurrentStep();
            ctrl2.currentStep = 4;
            ctrl2.JustForSaveCurrentStep();
            
            String myString = 'StringToBlob';
            Blob myBlob = Blob.valueof(myString);
            insert new Attachment(Name='test', parentId = request.Id, Body = myBlob, ContentType='application/pdf');
            
            Attachment attToRemove = new Attachment(Name='test2', parentId = request.Id, Body = myBlob, ContentType='application/pdf');
            insert attToRemove;
            ctrl2.removeAttId = attToRemove.Id;
            ctrl2.removeAtt();
            
            system.assertNotEquals(null,ctrl2); 
        
            Test.stopTest();
        }
    }
    
    @isTest 
    //scenario3: happy path
    public static void happyPath() {
        prepareTestData();
        System.runAs(TestUser) {
        
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
        
            Test.startTest();
            
            BrkSubmitHospitalController ctrl = setupCtrl(); 
            ctrl.acceptPaymentTC = true;
            ctrl.uSSN = 'X343163';
            ctrl.initPersonInsuredList();
            // BrkSubmitHospitalController.PersonInsured pi = new BrkSubmitHospitalController.PersonInsured();
            System.Debug('test class uSSN: ' + ctrl.uSSN);
            
            // 1. select PI
            ctrl.selectedPersonInsuredId = 'X343163';
            ctrl.selectedPersonInsuredName = 'RUI ****** T******';
            ctrl.selectedPolicyMember();
            
            system.assertNotEquals(null,ctrl);  
            
            // 2. answer if admission note
            ctrl.uploadAdmissionNote = true;
            ctrl.selectedUploadAdmissionNote();
            
            // 4. answer if credit card
            ctrl.hasCreditCard = false;
            ctrl.selectedFillInCreditCard();
                        
            Claim__c request = new Claim__c();
            insert request;
            ctrl.claimRequest = request;
            ctrl.claimId = request.Id;
            
            // 11. send e-signature email
            ctrl.esignatureEmail = 'testclass@cigna.com';
            ctrl.sendEmailSignature();
            ctrl.toSendGOPEmailSignature();
            
            // 12. submit
            //insert new Claim_Setting__c(Name = 'Cigna', Email_Address_QHMS__c = 'testclass@cigna.com');
    
            //ctrl.SavePreAdmission();
            //ctrl.submitPreAdmission();
            
            // 13. submit from e-signature page
            //BrkSubmitHospitalController.submitPreAdmissionFromEmail(ctrl.claimId);
            
            Test.stopTest();
        }
    }
    
    @isTest
    //scenario4: pass policy no
    public static void passPolicyNo() {
        prepareTestData();
        changeLanguage();
        System.runAs(TestUser) {
        
            //create new ApexCalloutHelperMock
            ApexCombinedCalloutHelperMock CombinedResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, CombinedResponseMock);
        
            Test.startTest();
            ApexPages.currentPage().getParameters().put('policyNo', 'HMKHK0000238958');
            
            BrkSubmitHospitalController ctrl = setupCtrl();             
            //ctrl.acceptPaymentTC = true;
            ctrl.uSSN = 'D343163';
            ctrl.claimRequest.Person_s_Insured__c = 'D343163';
            ctrl.selectedPolicyNo = 'HKD0002222';
            ctrl.initPersonInsuredList();
            
            ctrl.selectedPersonInsuredId = 'D343163';
            ctrl.selectedPersonInsuredName = 'RUI ****** T******';
            ctrl.selectedPolicyNo = 'HKD0002222';
            ctrl.selectedPolicyMember();
            
            ctrl.selectedPersonInsuredId = 'X343163';
            ctrl.selectedPolicyNo = 'HKD0002222';
            ctrl.selectedPolicyMember();
            
            Test.stopTest();
        }
    }
    
    @isTest 
    //scenario5: submission
    public static void submission() {
        prepareTestData();
        
        System.runAs(TestUser) {
        	Op_Swat_Scan_Setting__c op=new Op_Swat_Scan_Setting__c();
            op.Name='OpSwat';
            op.profile_name__c ='Cigna Customer User;Cigna Customer User Profile;Cigna Broker Admin';
            op.endPoint__c='https://api.metadefender.com/v4/file';
            op.apikey__c='eed511da95125dc112b363b2cc73b1a6';
            op.turn_on__c=false;
            op.checkTime__c=2000;
            op.maxTime__c=30000;
            insert op;
        
            Test.startTest();
            //BrkSubmitHospitalController ctrl = setupCtrl(); 
            
            Claim__c request = new Claim__c();
            request.Upload_Admission_Note__c = true;
            insert request;
            
            String myString = 'StringToBlob';
            Blob myBlob = Blob.valueof(myString);
            insert new Attachment(Name='test file.png', parentId = request.Id, Body = myBlob, ContentType='image/png');
            
            // 12. submit
            ApexPages.currentPage().getParameters().put('claimId', request.Id);
            BrkSubmitHospitalController ctrl2 = setupCtrl();
            ctrl2.selectedPolicyNo = 'HMKHK0000238958';
            ctrl2.acceptPaymentTC = true;
            insert new Claim_Setting__c(Name = 'Cigna', GOP_Email_Recipient__c = 'testclass@cigna.com', Email_Address_QHMS__c = 'testclass@cigna.com');
            insert new EmailTemplate(Name = 'Email to QHMS for GOP by WS', FolderId = UserInfo.getUserId(), TemplateType = 'text', developername = 'Email_to_QHMS_for_GOP_by_WS', Body = 'test');
            ctrl2.eSignature = 'abcd1234';
            ctrl2.admissionDateTimestamp = System.now().millisecond();

            ctrl2.submitPreAdmission();
            System.debug('phEmail:'+ctrl2.phEmail);
            // 13. submit from e-signature page
            BrkSubmitHospitalController.submitPreAdmissionFromEmail(ctrl2.claimId, false);            
            Test.stopTest();
        }
    }
}