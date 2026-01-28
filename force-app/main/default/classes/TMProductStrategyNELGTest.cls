/********************************************************************************
* Apex Class Name - TMProductStrategyNELGTest
* Version - 1.0
* Created Date - Aug 27, 2018
* @description Test class for TMProductStrategyNELG
* 
* Modification Log : 
* -------------------------------------------------------------------------
* Version   Developer       Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       Connor          27/08/2018              Original Version
********************************************************************************/
@isTest
public class TMProductStrategyNELGTest {
    private static TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    private static Product__c selectedProduct;
    private static List<TMCreatePolicyCtrl.PersonInsuredStructure> piList = new List<TMCreatePolicyCtrl.PersonInsuredStructure>(); 
    private static TMCreatePolicyCtrl.PersonInsuredStructure pis;
    private static Policy_Validation_Checking__c pvc;
    
    @testSetup 
    static void init(){
        TestClassUtility.initCustomSetting();
        TestClassUtility.initTMCampaignSetting();  // for creating a Campaign object
    }
    
    /********************************************************************************
    * Prepare data for test
    ********************************************************************************/
    static void generateData(){
        Channel__c chnl = new Channel__c(Channel_Code__c='others',name='others');
        insert chnl;        
        Campaign cam = new Campaign(Name='Test Campaign',Channel__c=chnl.id);
        insert cam;
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
            Name='Cigna Plus Medical Test',
            Product_Code__c = 'NELG',
            Rate_Scale__c = 1,
            RecordTypeId = prodRt.id
        );
        insert cProduct;
        
        RecordType planRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Product__c' AND DeveloperName = 'Plan'];
        Product__c cPlan = new Product__c(
            Name='Cigna Plus Medical Test',
            Product_Code__c = 'NELG',
            Rate_Scale__c = 1,
            RecordTypeId = planRt.id,
            Product__c = cProduct.Id,
            area_of_coverage__c = 'Asia (include AUS NZ)'
        );
        insert cPlan;
        
        RecordType prdRt = [SELECT Id FROM RecordType WHERE SobjectType = 'Product__c' AND DeveloperName = 'Plan'];
        selectedProduct = new Product__c(
            Name='Cigna Plus Medical Test',
            Product_Code__c = 'NELG',
            Rate_Scale__c = 1,
            RecordTypeId = prdRt.id,
            Product__c = cProduct.id
        );
        insert selectedProduct;
        
        ptvs.ctrl.selectedProduct = selectedProduct;   
        selectedProduct.Product_Code__c = 'NELG';
        pvc = new Policy_Validation_Checking__c(Duplicate_Policy_Checking__c='Y',
                                                Post_Duplication_Checking__c='R',
                                                AUW__c='Y',BMI__c='Test',
                                                Smoking__c='Test',
                                                Product_Code__c='NELG',
                                                UW_Requirement__c='R',
                                                Name='Test Policy_Validation_Checking__c');
        insert pvc;
        GA_Product_Validation_Checking__c gapvc = new GA_Product_Validation_Checking__c (Name='type1',AUW__c='R',Channel__c='others',
                                                                                         Insured_Type__c='PH = PI',
                                                                                         Post_Duplication_Checking__c='R',
                                                                                         Side_Order__c='N',
                                                                                         UW_Requirement__c='R');
        insert gapvc;
        pis = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pi.Insured_Type__c = 'PH = PI';
        Pi.basic_plan__c = 'NELG';
        pi.Benefit_Level__c = '1'; 
        pi.Date_of_Birth__c = Date.today();
        pi.PI_Age__c = 5;
        pi.Relationship__c = 'Daughter';
        pi.Parent_PI_ID__c = '123456';
        pi.Personal_ID__c = '123456';
        pis.pi = pi;
        pis.piPolicy = np;
        pis.parentIDPolicylist = new List<HttpCalloutVO.Policy>();
        HttpCalloutVO.Policy p = new HttpCalloutVO.Policy();
        p.policyStatusDisplayName = 'Inforce';
        p.productCode = 'NELG';
        p.rateScale = '1';
        pis.parentIDPolicylist.add(p);
        piList.add(pis); 
        ptvs.ctrl.personInsuredStructureList = piList;
    }
    
    /********************************************************************************
    * Test TMProductStrategyNELG construtor method
    ********************************************************************************/
    static testMethod void testConstrutor(){
        generateData();
        Test.startTest();
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);
        system.assert(tmpsnelg != null);
        Test.stopTest();
    }
    
    static testMethod void testNELdiscountValidation(){
        generateData();
        Test.startTest();
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);
        ptvs.ctrl.newPolicy.Personal_ID__c = 'testpid';        
        tmpsnelg.discountValidation();
        Test.stopTest();
    }
    
    static testMethod void testNELPiValidationCase1(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);
        tmpsnelg.productCode = 'NELG';
        ptvs.ctrl.currentStep = 3;  // greater than 2
        ptvs.ctrl.isStep2ValidationCalled = false;  
        tmpsnelg.piValidation();
        Test.stopTest();
    }
    
    static testMethod void testNELPiValidationCase2(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);
        tmpsnelg.productCode = 'NELG';
        ptvs.ctrl.currentStep = 6;  // greater than 5
        ptvs.ctrl.isStep2ValidationCalled = true;
        tmpsnelg.piValidation();
        Test.stopTest();
    }
    
    static testMethod void testNELTransactionValidation(){
        generateData();
        Test.startTest();
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);      
        tmpsnelg.transactionValidation();
        Test.stopTest();
    }
    
    //isPHEqualsPI is true
    /*static testMethod void testNELspouseDiscountValidationCase1(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        ptvs.ctrl.newPolicy.Personal_ID__c = 'testpid';
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);
        tmpsnelg.spouseDiscountValidation();
        piList.remove(0);
        //piList.remove(1);
        tmpsnelg = new TMProductStrategyNELG(ptvs);
        tmpsnelg.spouseDiscountValidation();
        Test.stopTest();
    }*/
    
    //isPHEqualsPI is false
    static testMethod void testNELspouseDiscountValidationCase2(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure temp :piList){
            temp.pi.Insured_Type__c = 'Spouse';
        }
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);
        ptvs.ctrl.newPolicy.Personal_ID__c = 'testpid';
        
        tmpsnelg.discountValidation();
        Test.stopTest();
    }
    
    static testMethod void testNELGChildDiscountValidation(){
        generateData();
        Test.startTest(); 
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);      
        tmpsnelg.childDiscountValidation();
        Test.stopTest();
    }
    
    static testMethod void testNELG2ChildDiscount(){
        generateData();
        Test.startTest(); 
        TMProductStrategyNELG tmpsnelg = new TMProductStrategyNELG(ptvs);  
        tmpsnelg.productCode = 'NELG2';
        tmpsnelg.childDiscountValidation();
        Test.stopTest();
    }
    
    
}