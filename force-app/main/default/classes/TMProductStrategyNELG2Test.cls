@isTest
public class TMProductStrategyNELG2Test {
    private static TMPolicyUtil.PolicyTransactionValidationStruct ptvs;

    @testSetup 
    static void init(){
        TestClassUtility.initCustomSetting();
        TestClassUtility.initTMCampaignSetting();  // for creating a Campaign object
    }
    
    /********************************************************************************
     * Prepare data for test
     ********************************************************************************/
    static void generateData(){
        Campaign cam = new Campaign(Name='Test Campaign'); 
        insert cam;

        RecordType discRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Premium_Discount__c' AND DeveloperName = 'Premium_Discount'];
        Premium_Discount__c pd1 = new Premium_Discount__c(
            Campaign__c=cam.id,
            Discount__c=10,
            Discount_Type__c='1 App. W/O Ext. Coverage'
            ,RecordTypeId=discRt.id
        );
        insert pd1;

        Account acc = new Account(Name='Test Account'); 
        insert acc;
        Opportunity opp = new Opportunity(accountid=acc.id,Name='Test Opportunity',closedate=Date.today().addDays(180),stagename='NMB',campaign__c=cam.id);       
        insert opp;
        Policy_Transaction__c pt = TestClassUtility.createPolicyTransaction(acc, opp, 1, '1'); 
        New_Policy__c np = TestClassUtility.createNewPolicy(acc, opp, pt);
        Person_Insured__c pi = TestClassUtility.createPersonInsured(np);
        ptvs = new TMPolicyUtil.PolicyTransactionValidationStruct(new TMCreatePolicyCtrl(new ApexPages.StandardController(pt)));

        RecordType prodRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Product__c' AND DeveloperName = 'Product'];
        Product__c cProduct = new Product__c(
            Name='Cigna HealthFirst Elite 360 Medical Plan',
            Product_Code__c = 'NEL2',
            RecordTypeId = prodRt.id
        );
        insert cProduct;

        RecordType planRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Product__c' AND DeveloperName = 'Plan'];
        Product__c cPlan = new Product__c(
            Name='Cigna HealthFirst Elite 360 Medical Plan',
            Product_Code__c = 'NELG2',
            Rate_Scale__c = 2,
            RecordTypeId = planRt.id,
            Product__c = cProduct.Id,
            area_of_coverage__c = 'Worldwide'
        );
        insert cPlan;

        ptvs.ctrl.selectedProduct = cPlan;
        cPlan.Product_Code__c = 'NELG2';

        //steup availableDiscountMap
        Map<String, Boolean> availableDiscountMap = new Map<String, Boolean>();
        availableDiscountMap.put('1 App. W/O Ext. Coverage', true);
        for (TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList) {
            System.debug('PersonInsuredStructure:');
            pis.availableDiscountMap = availableDiscountMap;
        }
    }
    
     /********************************************************************************
     * Test TMProductStrategyNELG2 construtor method
     ********************************************************************************/
    static testMethod void testConstrutor(){
        generateData();
        Test.startTest();
        TMProductStrategyNELG2 tmpsNELG2 = new TMProductStrategyNELG2(ptvs);
        system.assert(tmpsNELG2 != null);
        Test.stopTest();
    }

    static testMethod void testNELdiscountValidationCTM(){
        generateData();
        Test.startTest();
        TMProductStrategyNELG2 tmpsNELG2 = new TMProductStrategyNELG2(ptvs);
        tmpsNELG2.elite360_2026Q1ValidationCMT();
        
        Test.stopTest();
    }

    static testMethod void testNELdiscountValidationSTP(){
        generateData();
        for (TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList) {
            System.debug('PersonInsuredStructure:');
            // Replace CMT WITH STP
            pis.piPolicy.Policy_No__c = pis.piPolicy.Policy_No__c.replace('CTM', 'STP');
        }
        Test.startTest();
        TMProductStrategyNELG2 tmpsNELG2 = new TMProductStrategyNELG2(ptvs);
        tmpsNELG2.elite360_2026Q1ValidationSTP();
        Test.stopTest();
    }
}