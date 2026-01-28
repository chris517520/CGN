@isTest
private class TMProductStrategyABTest {
    @testSetup static void setup() {
        TestClassUtility.initCustomSetting();
        TestClassUtility.initTMCampaignSetting(); 

        Policy_Validation_Checking__c ABAG = new Policy_Validation_Checking__c();
        ABAG.Name = 'ABAG';
        ABAG.AUW__c = 'Y';
        ABAG.BMI__c = 'Y';
        ABAG.Duplicate_Policy_Checking__c = 'Y';
        ABAG.Post_Duplication_Checking__c = 'Y';
        ABAG.Product_Code__c = 'ABAG';
        ABAG.Smoking__c = 'Y';
        ABAG.UW_Requirement__c = 'SU';
        insert ABAG;


        Channel__c chnl = new Channel__c(Channel_Code__c='others',name='others');
        insert chnl;        
        Campaign cam = new Campaign(Name='Test Campaign',Channel__c=chnl.id);
        insert cam;
        Account acc = new Account(Name='Test Account'); 
        insert acc;
        Opportunity opp = new Opportunity(accountid=acc.id,Name='Test Opportunity',closedate=Date.today().addDays(180),stagename='NMB',campaign__c=cam.id);       
        insert opp;


        Policy_Transaction__c polTran = new Policy_Transaction__c();
        polTran.Account__c = acc.Id;
        polTran.Number_of_Person_Insured__c = 1;
        polTran.Opportunity__c = opp.Id;
        insert polTran;

        New_Policy__c piPolicy = new New_Policy__c();
        piPolicy.Policy_No__c = 'Test1234';
        piPolicy.Policy_Transaction__c = polTran.Id;
        insert piPolicy;
    }

    @isTest
    private static void testMethod1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ApexCombinedCalloutHelperMock());

        List<New_Policy__c> piPolicyList = [SELECT Id,Policy_No__c,Product_Code__c FROM New_Policy__c WHERE Policy_No__c = 'Test1234'];

        Policy_Transaction__c policyTran = new Policy_Transaction__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(policyTran);
        TMCreatePolicyCtrl ext = new TMCreatePolicyCtrl (sc);
        TMPolicyUtil.PolicyTransactionValidationStruct ptvs = new TMPolicyUtil.PolicyTransactionValidationStruct(ext);
        TMProductStrategyABAG strategyABAG = new TMProductStrategyABAG(ptvs);
        //create person insured.
        ptvs.ctrl.personInsuredStructureList = new List<TMCreatePolicyCtrl.PersonInsuredStructure>();
        TMCreatePolicyCtrl.PersonInsuredStructure pis = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pis.pi = new Person_Insured__c(Insured_Type__c='Dependent',Relationship__c='Son',PI_Age__c = 16);
        pis.piPolicy = piPolicyList[0];
        ptvs.ctrl.personInsuredStructureList.add(pis);

        strategyABAG.piValidation();
        strategyABAG.discountValidation();
        Test.stopTest();
    }
}