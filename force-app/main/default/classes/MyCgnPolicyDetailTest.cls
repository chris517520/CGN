@isTest
private class MyCgnPolicyDetailTest {
    public static User testUser;

    @TestSetup
    static void testSetup(){
        TestClassUtility.initCustomSetting();
    }

    static void prepareData() {
        User admin = TestClassUtility.createUser('System Administrator', 'CEO', 'TEST', 'GETMESSAGE');
        System.runAs(admin){
            //Create PolicyFieldByType__c
            List<PolicyFieldByType__c> pfList = new List<PolicyFieldByType__c>();
            pfList.add(new PolicyFieldByType__c(Name = 'Policy Doc',ILAS__c = true,non_ILAS__c = true ,Group__c = true));
            pfList.add(new PolicyFieldByType__c(Name = 'Policy Correspondence',ILAS__c = true,non_ILAS__c = true ,Group__c = true));
            pfList.add(new PolicyFieldByType__c(Name = 'individual',ILAS__c = true,non_ILAS__c = true ,Group__c = false));
            pfList.add(new PolicyFieldByType__c(Name = 'group',ILAS__c = false,non_ILAS__c = false ,Group__c = true));
            insert pfList;
            
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = admin.Id, SSN__c = 'TEST-0001-00');
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', Lastname = 'Test', AccountId = portalAccount1.Id, Email = System.now().millisecond() + 'test@test.com');
            Database.insert(contact1);
            
            //Create user
            testUser = new User(Username = System.now().millisecond() + 'cusLandingTest@test.com',ContactId = contact1.Id,ProfileId = TestClassUtility.initProfileId(),Alias = 'test123',Email = 'test12345@test.com',EmailEncodingKey = 'UTF-8',LastName = 'Test',CommunityNickname = 'test12345',TimeZoneSidKey = 'Asia/Hong_Kong',LocaleSidKey = 'en_HK',LanguageLocaleKey = 'en_US');
            Database.insert(testUser);

            TestClassUtility.initPlanCodeClaimType(testUser.Id);

            Member_Management__c member = new Member_Management__c(
            Name='Nicole Lin',OwnerId=testUser.Id,Policy_Number__c='91516',Policy_Anniversary_Date__c=System.today() - 1,SSN__c='TEST-0001-00',Allow_Top_Up__c='Y',Policy_Year__c='2023',Top_Up_Status__c='NO',DDA_Signature_completed__c='N',DDA_signature_reqiured__c='Y',Enrolment_End_Date__c=system.today() + 30,Enrolment_Start_Date__c=system.today(),Relationship__c='Employee',Region__c='HK',Cert_Number__c='0000-00',Date_of_Birth__c=Date.newInstance(system.today().Year()-30, system.today().month(), system.today().day()),First_Name__c='Nicole',Last_Name__c='Lin',File_Uploaded_Status__c='');
            insert member;

            RecordType recdType = [SELECT Id FROM RecordType WHERE Name = 'Basic Information' AND SObjectType = 'Policy_Change_Request__c'];
            Policy_Change_Request__c pc = new Policy_Change_Request__c(RecordType = recdType, Status__c = 'Not Submitted', Policy_No__c = 'TEST001', Date_of_Birth__c = date.today(), OwnerId = testUser.Id);
            insert pc;
            
            Attachment att = new Attachment(Name='TEST001', Body=Blob.valueOf('TEST'), ContentType='image/png', ParentId=pc.Id);
            insert att;
        }
    }

    static testMethod void testSearchAll() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/searchAll';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testRemovePolicy() {
        prepareData();
        Test.startTest();
        System.runAs(testUser){
            ESales_Policy_Transaction__c et = new ESales_Policy_Transaction__c(AUW_Overall_Result__c='Accept');
            insert et;

            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polId": "'+et.Id+'"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/removePolicy';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetAllPolChangeRecord() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getAllPolChangeRecord';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testRemoveChangeRecord() {
        prepareData();
        Test.startTest();
        System.runAs(testUser){
            Policy_Change_Request__c pc = [SELECT Id FROM Policy_Change_Request__c LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"id": "'+pc.Id+'"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/removeChangeRecord';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetPolicyInfo() {
        prepareData();
        Set<String> statusSet = MyCgnPolicyDetail.statusCodeSet;
        List<String> tabs = MyCgnPolicyDetail.getTabs('ILAS');
        tabs = MyCgnPolicyDetail.getTabs('Group');
        List<String> buttons = MyCgnPolicyDetail.getButtons('ILAS', false, false);
        buttons = MyCgnPolicyDetail.getButtons('nonILAS', true, false);
        buttons = MyCgnPolicyDetail.getButtons('Group', true, true);
        
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            // individual
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "TEST001", "polType": "ILAS"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getPolicyInfo';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();

            // group
            RestRequest request1 = new RestRequest();
            RestResponse res1 = new RestResponse();
            String requestBody1 = '{"polNo": "91516", "polType": "Group", "targetCertNo": "0001-00"}';
            request1.requestBody = Blob.valueOf(requestBody1);
            request1.httpMethod = 'POST';
            request1.requestURI = '/policyDetail/getPolicyInfo';

            RestContext.request = request1;
            RestContext.response = res1;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetPolicyChangeList() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "TEST001"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getPolicyChangeList';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetPolicyChangeListByStatus() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            List<HttpCalloutVO.WorkStatus> allList = new List<HttpCalloutVO.WorkStatus>();
            HttpCalloutVO.WorkStatus work = new HttpCalloutVO.WorkStatus();
            work.requestStatus = 'Processing';
            allList.add(work);

            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"workStatus": "Processing", "policyChangeList": '+JSON.serialize(allList)+'}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getPolicyChangeListByStatus';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetClinicVisitByCertNo() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "91516", "tabType": "clinic"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getClinicVisitByCertNo';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetCoverageInfo() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            List<HttpCalloutVO.Person> insuredList = new List<HttpCalloutVO.Person>();
            HttpCalloutVO.Person insure = new HttpCalloutVO.Person();
            insure.ssnNumber = 'TEST001';
            insure.fullName = 'TEST';
            insuredList.add(insure);

            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "TEST001", "insuredList": '+JSON.serialize(insuredList)+'}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getCoverageInfo';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetBillingInfo() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "TEST001"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getBillingInfo';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetClaimHistory() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "TEST001"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getClaimHistory';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetBenefitScheduleByCertNo() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            Map<String, String> ssnMap = new Map<String, String>{'0001-00'=>'SSN001'};
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "91516", "certNo": "0001-00", "certNoSSNMap": '+JSON.serialize(ssnMap)+'}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getBenefitScheduleByCertNo';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetAttachment() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "91516", "polType": "Group", "certNo": "0001-00"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getAttachment';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetPolicyList() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getPolicyList';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetChangeRecordPI() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"polNo": "TEST001"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getChangeRecordPI';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetAttBody() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"attID": "ATT_ID", "pol": "91516", "attKey": "ATT_KEY"}';
          
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getAttBody';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testCheckIsDocumentDownloadComplete() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            Attachment att = [SELECT Id FROM Attachment LIMIT 1];
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            String requestBody = '{"attId": "'+att.Id+'"}';
            request.requestBody = Blob.valueOf(requestBody);
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/checkIsDocumentDownloadComplete';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }

    static testMethod void testGetMedicalCardAction() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.httpMethod = 'POST';
            request.requestURI = '/policyDetail/getMedicalCardAction';

            RestContext.request = request;
            RestContext.response = res;
            MyCgnPolicyDetail.policyDetail();

            Member_Management__c m = [SELECT Id, Relationship__c FROM Member_Management__c LIMIT 1];
            m.Relationship__c = 'Dependent';
            update m;
            MyCgnPolicyDetail.policyDetail();
        }
        Test.stopTest();
    }
}