@isTest
private class ManagePolicyChangeCRTLTest {

    private static user CustomerUser;
    private static List < Policy_Change_Request__c > ListNewPolicyChange;
    private static Policy_Change_Request__c policyChange;
    private static Policy_Change_Request__c policyChange1;
    private static Policy_Change_Request_Detail__c policyChangeDetail;
    private static Policy_Change_Request_Detail__c policyChangeDetailRider; 
    private static Policy_Change_Request_Detail__c policyChangeDetailSumInsured; 
    private static Policy_Change_Request_Detail__c policyChangeDetailAdditionalCon;
    private static List<SelectOption> availBenefitSumInsuredOptions { get; set; }
    private static Attachment att;
    private static Id policyChangeId;

    @TestSetup
    static void init(){
        TestClassUtility.initClientPortalSetting();
        TestClassUtility.initOptSwatScanSetting();
    }
 
    static void prepareTestData() {

        UserRole portalRole = [Select Id From UserRole Where DeveloperName LIKE '%Broker%'
          Limit 1
        ];
        
        
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Customer' and SObjectType = 'Account'];
        Account a = new account(
          RecordType = personAccountRecordType,
          firstname = 'alex',
          lastname = 'test',
          ssn__c = 'A123456(7)'
        
        );
        insert a;

        Id contactId = [Select id From Contact Where AccountId =:a.id][0].id;

        //Profile p = [SELECT Id FROM Profile WHERE Name = 'Cigna Customer User'];

        CustomerUser = new User(
          ProfileId = TestClassUtility.initProfileId(),
          Username = 'TestENotificationSearchCtrl123@YIX.com',
          Alias = 'batman',
          Email = 'tes23t@cigna.com',
          EmailEncodingKey = 'UTF-8',
          Firstname = 'Bruce',
          Lastname = 'TestABC',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          TimeZoneSidKey = 'America/Chicago',
          isActive = true,
          //  UserRoleId = portalRole.Id,
          Agent_code__c = 'test1234',
          ContactId = contactId
        );
        
        insert CustomerUser;

        TestClassUtility.prepareTestDataofPolicyCalloutHelper();
        List < Portal_Settings__c > portalSettings = new List < Portal_Settings__c > ();
        Portal_Settings__c portalSetting1 = new Portal_Settings__c(Broker_Portal_Prefix__c = '/broker',
          Customer_Portal_Prefix__c = '/customer',
          Glance_Cobrowse_Group_ID__c = '19736',
          Glance_Cobrowse_Site__c = 'staging',
          Live_Agent_Deployment_ID__c = '57228000000L2cM',
          Live_Agent_Init_URL__c = 'https://d.la10cs.salesforceliveagent.com/chat',
          Live_Agent_JavaScript_URL__c = 'https://c.la10cs.salesforceliveagent.com/content/g/js/38.0/deployment.js',
          File_Download_URL__c = URL.getSalesforceBaseUrl().toExternalForm()+'/filedownload/servlet/servlet.FileDownload?file='
        );
        // Rancho_HKITSFDC212_20250401 - remove hard-code url
        portalSettings.add(portalSetting1);
        insert portalSettings;
        
        PolicyFieldByType__c policyfield = new PolicyFieldByType__c(Name = 'test', Group__C = true);
        insert policyfield;
        
        availBenefitSumInsuredOptions = new List<SelectOption>();
        availBenefitSumInsuredOptions.add(new SelectOption('a','a'));
    }
    
    static void preparePolicyChangeRecord(String type){
    
        /**Create policy change request according to record type**/
        
        String requestRecordType = '';
        
        if (type == 'basic'){
            requestRecordType = 'Basic Information';
        }else if (type == 'copy'){
            requestRecordType = 'Request for Policy copy or / and Medical Report copy';
        }else if (type == 'renew'){
            requestRecordType = 'Application for policy reinstatement';
        }else if (type == 'owner'){
            requestRecordType = 'Ownership';
        }else if (type == 'app'){
            requestRecordType = 'Automatic Premium Payment';
        }else if (type == 'benefit'){
            requestRecordType = 'Benefit';
        }else if (type == 'beneficiary'){
            requestRecordType = 'Beneficiary';
        }else if (type == 'payment'){
            requestRecordType = 'Payment Information';
        }
        
        RecordType policyChangeRecordType =  [SELECT Id FROM RecordType WHERE Name =: requestRecordType AND SObjectType = 'Policy_Change_Request__c'];
      
        policyChange = new Policy_Change_Request__c();
        policyChange.recordType = policyChangeRecordType;
        policyChange.status__c = 'Not Submitted';
        policyChange.ownerId = CustomerUser.id;
        policyChange.Policy_No__c = 'HL12961';
        policyChange.Date_of_Birth__c = date.today();
        policyChange.VisaMaster_Card_Credit_Card_Account__c = '0000000000000000';
        policyChange.Additional_Contribution__c = 'Single';

        insert policyChange;

        policyChange1 = new Policy_Change_Request__c();
        policyChange1.recordType = policyChangeRecordType;
        policyChange1.status__c = 'Not Submitted';
        policyChange1.ownerId = CustomerUser.id;
        policyChange1.Policy_No__c = 'HL12961';
        policyChange1.Date_of_Birth__c = date.today();
        policyChange1.VisaMaster_Card_Credit_Card_Account__c = '0000000000000000';
        policyChange1.Additional_Contribution__c = 'Single';
        insert policyChange1;

        
        policyChangeId = policyChange.id;
        
        RecordType policyChangeDetailRecordType =  [SELECT Id FROM RecordType WHERE Name ='Beneficiary' AND SObjectType = 'Policy_Change_Request_Detail__c'];
        
        policyChangeDetail = new Policy_Change_Request_Detail__c();
        policyChangeDetail.Policy_Change_Request__c = policyChangeId;
        policyChangeDetail.RecordType = policyChangeDetailRecordType;
        policyChangeDetail.English_Name__c='test';
        policyChangeDetail.HKID_Birth_Cert_Passport_No__c='123';
        policyChangeDetail.Relationship_with_Person_Insured__c='test';
        policyChangeDetail.Share__c=100;
        policyChangeDetail.Sum_Insured_From_Currency__c ='HKD';
        insert policyChangeDetail; 
        
        RecordType benfitRiderRecordType = [SELECT Id FROM RecordType WHERE Name ='Benefit Rider' AND SObjectType = 'Policy_Change_Request_Detail__c'];
        RecordType benefitSumInsuredRecordType = [SELECT Id FROM RecordType WHERE Name ='Benefit Change Sum Insured' AND SObjectType = 'Policy_Change_Request_Detail__c'];
        RecordType benefitAdditionConRecordType = [SELECT Id FROM RecordType WHERE Name ='Benefit Additional Contribution' AND SObjectType = 'Policy_Change_Request_Detail__c'];
        
        policyChangeDetailRider = new Policy_Change_Request_Detail__c();
        policyChangeDetailRider.Policy_Change_Request__c = policyChangeId;
        policyChangeDetailRider.RecordType = benfitRiderRecordType;
        policyChangeDetailRider.Sum_Insured_From_Currency__c='HKD';
        insert policyChangeDetailRider;
        
        policyChangeDetailSumInsured = new Policy_Change_Request_Detail__c();
        policyChangeDetailSumInsured.Policy_Change_Request__c = policyChangeId;
        policyChangeDetailSumInsured.RecordType = benefitSumInsuredRecordType;
        policyChangeDetailSumInsured.Sum_Insured_From_Currency__c='HKD';
        insert policyChangeDetailSumInsured;
        
        policyChangeDetailAdditionalCon = new Policy_Change_Request_Detail__c();
        policyChangeDetailAdditionalCon.Policy_Change_Request__c = policyChangeId;
        policyChangeDetailAdditionalCon.RecordType = benefitSumInsuredRecordType;
        policyChangeDetailAdditionalCon.Sum_Insured_From_Currency__c ='HKD';
        insert policyChangeDetailAdditionalCon;
        
        att = new Attachment ();
        att.parentId  = policyChangeId;
        att.Name='HKIDAtt';
        att.Body=Blob.valueOf('Unit Test Attachment Body');
        insert att;

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
        System.debug('requestRecordType:'+requestRecordType);
        
    }
    
    
    
  
    static testmethod void testBasicInfoManagePolicyChangeCRTL() {
        prepareTestData();
        preparePolicyChangeRecord('basic');
        System.runAs(CustomerUser) {

            ApexCombinedCalloutHelperMock GetPolicyListBasicByCriteria_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyListBasicByCriteria_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyPersonCoverageBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyPersonCoverageBasic_ResponseMock);
            
            ApexCombinedCalloutHelperMock SubmitWorkRequest_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, SubmitWorkRequest_ResponseMock);
            
            

            
            ApexPages.currentPage().getParameters().put('pcid', policyChangeId);
            ApexPages.currentPage().getParameters().put('phid', '123');
            ApexPages.currentPage().getParameters().put('phname', 'D1234');
            ApexPages.currentPage().getParameters().put('phemail', '123@test.com');
            ApexPages.currentPage().getParameters().put('pclist', 'test123');
            ApexPages.currentPage().getParameters().put('tab', 'all');

            
            Test.startTest();
            
            ManagePolicyChangeCRTL ctrl = new ManagePolicyChangeCRTL(new ApexPages.StandardController(policyChange));
            
            ctrl.policyChangeId = policyChangeId;
            
            ManagePolicyChangeCRTL.Policy policy = new ManagePolicyChangeCRTL.Policy();
            policy.policyName = System.Label.Plan_Type_Cigna_Plus;
            policy.policyNo = 'HL12961';
            policy.policyHolderId='Y1234001';
            policy.policyStatus='Inforce';
            policy.policyHolder='Cherry Huang';
            policy.agentCode ='A1234';
            policy.brokerName ='Chan Dai Man';
            policy.allowChangeOwner = true ;
            policy.allowChangePaymentDate = true ;
            policy.isLifePolicy = true ;
            policy.policySelected=true;
            policy.policyHolderSelected=true;
            
            ctrl.ListPolicy.add(policy);
            
            
            
            ctrl.init();
            ctrl.sitePrefix = '/customer';
            ctrl.InputCurrentStep();
            
            ctrl.changetype = 'dd';
            ctrl.selectChangeType();
            ctrl.changetype = 'copyDoc';
            ctrl.selectChangeType();
            ctrl.changetype = 'renew';
            ctrl.selectChangeType();
            ctrl.changetype = 'benefit';
            ctrl.selectChangeType();
            ctrl.changetype = 'app';
            ctrl.selectChangeType();
            ctrl.changetype = 'owner';
            ctrl.selectChangeType();
            ctrl.changetype = 'beneficiary';
            ctrl.selectChangeType();
            ctrl.changetype = 'personal';
            ctrl.selectChangeType();
            
            ctrl.policyChoice = 'HL12961';
            ctrl.multiPolicy = true;
            
            ctrl.IsPersonal = true;
            ctrl.IsBeneficiary = true;
            ctrl.IsOwner = true;
            ctrl.IsDD = true;
            ctrl.IsCopyDoc =true;
            ctrl.IsRenew = true;
            ctrl.IsBenefit = true;
            ctrl.IsApp = true;
            ctrl.IsThirdParty = true;
            ctrl.isLife = true;
            
            ctrl.selectPolicy();
            
            ctrl.multiPolicy = false;
            ctrl.selectPolicy();
            
            ctrl.policyMemberName='test';
            ctrl.selectedPolicyMember();
            ctrl.ListPolicy.add(policy);
            ctrl.ListAvaliblePolicy.add(policy);
            ctrl.showListPolicy();
            ctrl.getListinforcePolicy();
            ctrl.getListLapsedPolicy();
            ctrl.getListHasBrokerPolicy();
            ctrl.getListAllowChangeOwnerPolicy();
            ctrl.getListAllowChangePaymentdatePolicy();
            ctrl.getListIsLifePolicy();
            ctrl.getListIsGeneralPolicy();
            
            
            ctrl.getListDDAAtt();
            ctrl.getListBenefitFNA();
            ctrl.getListRPQAtt();
            
            ctrl.showPolicyMember();
            ctrl.hasPolicy = true;
            ctrl.hasChangeType= true;
            ctrl.IsPersonal = true;
            ctrl.SavePolicyChange();
            ctrl.IsPersonal = false;
            ctrl.IsBeneficiary = true;
            ctrl.SavePolicyChange();
            ctrl.IsBeneficiary = false;
            ctrl.IsOwner = true;
            ctrl.ListRequestDetail.add(policyChangeDetail);
            ctrl.SavePolicyChange();
            ctrl.IsOwner = false;
            ctrl.IsDD = true;
            ctrl.SavePolicyChange();
            ctrl.IsDD = false;
            ctrl.IsCopyDoc =true;
            ctrl.SavePolicyChange();
            ctrl.IsCopyDoc =false;
            ctrl.IsRenew = true;
            ctrl.SavePolicyChange();
            // ctrl.IsRenew = false;
            // ctrl.IsBenefit = true;
            // ctrl.SavePolicyChange();
            // ctrl.IsBenefit = false;
            // ctrl.IsApp = true;
            // ctrl.SavePolicyChange();
            // ctrl.IsApp = false;
            // ctrl.IsThirdParty = true;
            // ctrl.isLife = true;
            // ctrl.SavePolicyChange();
            ctrl.eSignature = 'test';
            ctrl.eSignature2 = 'test2';
            ctrl.submitEsignature();
            
            Policy_Change_Request__c policyChangecheck = [select id, name, Policy_No__c, RecordType.Name from Policy_Change_Request__c where id = :policyChangeId];
            policyChangecheck.Policy_No__c = 'HL12961';
            update policyChangecheck;
            
            
            ctrl.submitPolicyChange();
        
            Test.stopTest();
        
        }
    }
    
    static testmethod void testBasicInfoManagePolicyChangeCRTL2() {
        prepareTestData();
        preparePolicyChangeRecord('basic');
        
        System.runAs(CustomerUser) {

            ApexCombinedCalloutHelperMock GetPolicyListBasicByCriteria_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyListBasicByCriteria_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyPersonCoverageBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyPersonCoverageBasic_ResponseMock);
            
            ApexCombinedCalloutHelperMock SubmitWorkRequest_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, SubmitWorkRequest_ResponseMock);
    
            ApexPages.currentPage().getParameters().put('pcid', policyChangeId);
            ApexPages.currentPage().getParameters().put('phid', '123');
            ApexPages.currentPage().getParameters().put('phname', 'D1234');
            ApexPages.currentPage().getParameters().put('phemail', '123@test.com');
            ApexPages.currentPage().getParameters().put('pclist', 'test123');
            ApexPages.currentPage().getParameters().put('tab', 'all');

            Test.startTest();
            
            ManagePolicyChangeCRTL ctrl = new ManagePolicyChangeCRTL(new ApexPages.StandardController(policyChange));
            
            ctrl.policyChangeId = policyChangeId;
            
            ManagePolicyChangeCRTL.Policy policy = new ManagePolicyChangeCRTL.Policy();
            policy.policyName = System.Label.Plan_Type_Cigna_Plus;
            policy.policyNo = 'HL12961';
            policy.policyHolderId='Y1234001';
            policy.policyStatus='Inforce';
            policy.policyHolder='Cherry Huang';
            policy.agentCode ='A1234';
            policy.brokerName ='Chan Dai Man';
            policy.allowChangeOwner = true ;
            policy.allowChangePaymentDate = true ;
            policy.isLifePolicy = true ;
            policy.policySelected=true;
            policy.policyHolderSelected=true;
            
            ctrl.ListPolicy.add(policy);
            
            
            ctrl.init();
            ctrl.sitePrefix = '/customer';
            ctrl.InputCurrentStep();
            
            ctrl.changetype = 'personal';
            ctrl.selectChangeType();
            
            ctrl.policyChoice = 'HL12961';
            ctrl.multiPolicy = true;
            
            ctrl.IsPersonal = true;
            ctrl.IsBeneficiary = true;
            ctrl.IsOwner = true;
            ctrl.IsDD = true;
            ctrl.IsCopyDoc =true;
            ctrl.IsRenew = true;
            ctrl.IsBenefit = true;
            ctrl.IsApp = true;
            ctrl.IsThirdParty = true;
            ctrl.isLife = true;
            ctrl.multiPolicy = false;
            ctrl.selectPolicy();
            
            ctrl.policyMemberName='test';
            ctrl.selectedPolicyMember();
            ctrl.ListPolicy.add(policy);
            ctrl.ListAvaliblePolicy.add(policy);
            ctrl.showListPolicy();
            ctrl.getListinforcePolicy();
            ctrl.getListLapsedPolicy();
            ctrl.getListHasBrokerPolicy();
            ctrl.getListAllowChangeOwnerPolicy();
            ctrl.getListAllowChangePaymentdatePolicy();
            ctrl.getListIsLifePolicy();
            ctrl.getListIsGeneralPolicy();
            
            
            ctrl.getListDDAAtt();
            ctrl.getListBenefitFNA();
            ctrl.getListRPQAtt();
            
            ctrl.showPolicyMember();
            ctrl.hasPolicy = true;
            ctrl.hasChangeType= true;
            ctrl.IsPersonal = true;
            ctrl.IsPersonal = false;
            ctrl.IsBeneficiary = true;
            ctrl.IsBeneficiary = false;
            ctrl.IsOwner = true;
            ctrl.ListRequestDetail.add(policyChangeDetail);
            ctrl.IsOwner = false;
            ctrl.IsDD = true;
            ctrl.IsDD = false;
            ctrl.IsCopyDoc =true;
            ctrl.IsCopyDoc =false;
            ctrl.IsRenew = true;
            ctrl.IsRenew = false;
            ctrl.IsBenefit = true;
            ctrl.IsBenefit = false;
            ctrl.IsApp = true;
            ctrl.IsApp = false;
            ctrl.IsThirdParty = true;
            ctrl.isLife = true;
            ctrl.SavePolicyChange();
            ctrl.eSignature = 'test';
            ctrl.eSignature2 = 'test2';
            ctrl.submitEsignature();
            
            Policy_Change_Request__c policyChangecheck = [select id, name, Policy_No__c, RecordType.Name from Policy_Change_Request__c where id = :policyChangeId];
            policyChangecheck.Policy_No__c = 'HL12961';
            update policyChangecheck;
            
            ctrl.submitPolicyChange();
            
            att = new Attachment ();
            att.parentId  = policyChangeId;
            att.Name='HKIDAtt';
            att.Body=Blob.valueOf('Unit Test Attachment Body');
            att.contentType='application/pdf';
            insert att;
            
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Basic',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Beneficiary',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Ownership',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Payment Information',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'copy',false);
            
            Blob policychangePDF;
            List<Attachment> attachmentList = new List<Attachment>();
            attachmentList=[SELECT id FROM Attachment WHERE parentId =:att.parentId];
            System.enqueueJob(new SubmitWorkRequestQueue(policyChangeId, attachmentList, '/customer', true, 1, '', '', '', ''));
            //ManagePolicyChangeCRTL.submitRequestToAppian(policyChangeId, policychangePDF, '/customer');
            ctrl.sendEmailSignature();
            ctrl.checkAttDisplay();
            ctrl.addRowBeneficiary();
            ctrl.deleteReqDetailId = policyChangeDetail.id;
            ctrl.removeRowBeneficiary();
            ctrl.clearBeneficiary();
            ctrl.checkAtt();
            ctrl.removeAttId = att.id;
            ctrl.removeAtt();
        
            Test.stopTest();
        
        }
    }

    static testmethod void testBasicInfoManagePolicyChangeCRTL3() {
        prepareTestData();
        preparePolicyChangeRecord('basic');
        System.runAs(CustomerUser) {
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'reinstatement',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Benefit',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Automatic',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Switch',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Reallocation',false);
            ManagePolicyChangeCRTL.submitPolicyChangeFromEmail(policyChangeId, '/customer', 'Withdrawal',false);
        }
    }

    static testmethod void testRenewManagePolicyChangeCRTL() {
        prepareTestData();
        preparePolicyChangeRecord('renew');
        
        System.runAs(CustomerUser) {
            ApexCombinedCalloutHelperMock GetPolicyListBasicByCriteria_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyListBasicByCriteria_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyPersonCoverageBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyPersonCoverageBasic_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyFundListBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyFundListBasic_ResponseMock);
        
            Test.startTest();
                
            ManagePolicyChangeCRTL ctrl = new ManagePolicyChangeCRTL(new ApexPages.StandardController(policyChange));
            ctrl.policyChangeId = policyChangeId;
            ctrl.init();
            ctrl.sitePrefix = '/customer';
            ctrl.getAllAvailFundOptions();
            List<Attachment> attachmentList = new List<Attachment>();
            System.enqueueJob(new SubmitWorkRequestQueue(policyChangeId, attachmentList , '/customer', true, 1, 'requestID', '', '', ''));
            
            Test.stopTest();
        }
    }
    
    static testmethod void testBenefitManagePolicyChangeCRTL() {
        prepareTestData();
        preparePolicyChangeRecord('benefit');
        
        System.runAs(CustomerUser) {
            ApexCombinedCalloutHelperMock GetPolicyListBasicByCriteria_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyListBasicByCriteria_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyPersonCoverageBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyPersonCoverageBasic_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyFundListBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyFundListBasic_ResponseMock);
        
            Test.startTest();
                
            ManagePolicyChangeCRTL ctrl = new ManagePolicyChangeCRTL(new ApexPages.StandardController(policyChange));
            ctrl.policyChangeId = policyChangeId;
            ctrl.init();
            ctrl.sitePrefix = '/broker';
            ctrl.getAllAvailFundOptions();
            ctrl.addRowBenefitSingle();
            ctrl.removeRowBenefitSingle();
            ctrl.clearBenefitSingle();
            
            ctrl.addRowBenefitRegular();
            ctrl.removeRowBenefitRegular();
            ctrl.clearBenefitRegular();

            ctrl.addRowBenefitRider();
            ctrl.removeRowBenefitRider();
            ctrl.clearBenefitRider();
            
            ctrl.ListBenefitSumInsured.add(policyChangeDetailSumInsured);
            ctrl.availBenefitSumInsuredOptions = availBenefitSumInsuredOptions;
            ctrl.addRowBenefitSumInsured();
            ctrl.removeRowBenefitSumInsured();
            ctrl.clearBenefitSumInsured();
            
            ctrl.IsBenefit = true;
            ctrl.ListBenefitRider.add(policyChangeDetailRider);
            ctrl.ListBenefitSumInsured.add(policyChangeDetailSumInsured);
            ctrl.ListBenefitSingle.add(policyChangeDetailAdditionalCon);
            ctrl.ListBenefitRegular.add(policyChangeDetailAdditionalCon);
            
            ManagePolicyChangeCRTL.Policy policy = new ManagePolicyChangeCRTL.Policy();
            policy.policyName = System.Label.Plan_Type_Cigna_Plus;
            policy.policyNo = 'HL12961';
            policy.policyHolderId='Y1234001';
            policy.policyStatus='Inforce';
            policy.policyHolder='Cherry Huang';
            policy.agentCode ='A1234';
            policy.brokerName ='Chan Dai Man';
            policy.allowChangeOwner = true ;
            policy.allowChangePaymentDate = true ;
            policy.isLifePolicy = true ;
            policy.policySelected=true;
            policy.policyHolderSelected=true;
            
            ctrl.ListPolicy.add(policy);
            ctrl.SavePolicyChange();
            
            att = new Attachment ();
            att.parentId  = policyChangeId;
            att.Name='0policychange.pdf';
            att.Body=Blob.valueOf('Unit Test Attachment Body');
            att.contentType='application/pdf';
            insert att;
            
            List<Attachment> attachmentList = new List<Attachment>();
            attachmentList=[SELECT id FROM Attachment WHERE parentId =:att.parentId];
            System.enqueueJob(new SubmitWorkRequestQueue(policyChangeId, attachmentList, '/customer', true, 1, 'requestID', '', '', ''));

            ctrl.rowIndex=0;
            ctrl.deleteBenefitDetailId=policyChange1.Id;
            ctrl.removeRowBenefitSumInsured();
            ctrl.removeRowBenefitRider();
            ctrl.removeRowBenefitSingle();
            ctrl.removeRowBenefitRegular();

            Test.stopTest();
        }
    }
    
    static testmethod void testGL31() {
        prepareTestData();
        preparePolicyChangeRecord('renew');
        
        System.runAs(CustomerUser) {
            ApexCombinedCalloutHelperMock GetPolicyListBasicByCriteria_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyListBasicByCriteria_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyPersonCoverageBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyPersonCoverageBasic_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyFundListBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyFundListBasic_ResponseMock);
        
            Test.startTest();
                
            ManagePolicyChangeCRTL ctrl = new ManagePolicyChangeCRTL(new ApexPages.StandardController(policyChange));
            ctrl.assessmentQuestionList = ESalesUtility.getQuestionData('');
            for (ESaleQuestion question : ctrl.assessmentQuestionList) {
                for(ESaleQuestion.ESaleOption option : question.esaleOptions){
                    option.setAnswer(option.getValue());
                }
            }
            ctrl.setAvailableRiderMap();
            ctrl.ThirdPartyRelationshipList.size();
            ctrl.iLASPlanCodesRiskSellMap.size();
            Test.stopTest();
        }
    }

    static testmethod void testMethod1() {
        prepareTestData();
        preparePolicyChangeRecord('renew');
        
        System.runAs(CustomerUser) {
            ApexCombinedCalloutHelperMock GetPolicyListBasicByCriteria_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyListBasicByCriteria_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyPersonCoverageBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyPersonCoverageBasic_ResponseMock);
            
            ApexCombinedCalloutHelperMock GetPolicyFundListBasic_ResponseMock = new ApexCombinedCalloutHelperMock();
            Test.setMock(HttpCalloutMock.class, GetPolicyFundListBasic_ResponseMock);
        
            Test.startTest();
                
            ManagePolicyChangeCRTL ctrl = new ManagePolicyChangeCRTL(new ApexPages.StandardController(policyChange));
            ctrl.assessmentQuestionList = ESalesUtility.getQuestionData('');
            Map<String,Map<String,String>> mapTest=ctrl.transField;
            ctrl.getListAddressAtt();
            ctrl.getListDeedPollAtt();
            ctrl.getListPiHkidAtt();
            ctrl.getListNewPhHkidAtt();
            ctrl.getListNewPhAddressAtt();
            ctrl.getListPhHkidAtt();
            ctrl.getListTpHkidAtt();
            ctrl.getListTpAddressAtt();
            ctrl.getListGMAtt();
            ctrl.getListJCAtt();
            ctrl.getListGMPAtt();
            ctrl.getListPMAtt();
            ctrl.getListCIPLAtt();
            Test.stopTest();
        }
    }
    
}