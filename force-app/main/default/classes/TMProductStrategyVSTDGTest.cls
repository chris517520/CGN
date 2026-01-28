/********************************************************************************
 * Apex Class Name - TMProductStrategyVSTDGTest
 * Created Date - Jan 15, 2019
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Manuel          15/01/2019              Revise Version
 ********************************************************************************/
 
@isTest
public class TMProductStrategyVSTDGTest{

    private static TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    private static Product__c selectedProduct;
    private static List<TMCreatePolicyCtrl.PersonInsuredStructure> piList = new List<TMCreatePolicyCtrl.PersonInsuredStructure>(); 
    private static TMCreatePolicyCtrl.PersonInsuredStructure pis1; 
    private static TMCreatePolicyCtrl.PersonInsuredStructure pis2; 
    private static TMCreatePolicyCtrl.PersonInsuredStructure pis3; 

    @testSetup
    static void init(){
        TestClassUtility.initCustomSetting();
        TestClassUtility.initTMCampaignSetting();  // for creating objects like Campaign
    }

    static void generateData(){
        Channel__c chnl = new Channel__c(Channel_Code__c='others',name='others');
        insert chnl;
        Campaign cam = new Campaign(Name='VSTDG Test Campaign');
        insert cam;
        Account acc = new Account(Name='VSTDG Test Account'); 
        insert acc;
        Opportunity opp = new Opportunity(accountid=acc.id,Name='VSTDG Test Opportunity',closedate=Date.today().addDays(180),stagename='NMB',campaign__c=cam.id);       
        insert opp;
        Policy_Transaction__c pt = TestClassUtility.createPolicyTransaction(acc, opp, 1, '1'); 
        
        New_Policy__c np1 = TestClassUtility.createNewPolicy(acc, opp, pt);
        np1.Pre_Sales_Result__c = 'Accepted';
        np1.UW_Result__c = 'Accepted';
        update np1;
        
        New_Policy__c np2 = TestClassUtility.createNewPolicy(acc, opp, pt);
        np2.Pre_Sales_Result__c = 'Accepted';
        np2.UW_Result__c = 'Accepted';
        update np2;
        
        New_Policy__c np3 = TestClassUtility.createNewPolicy(acc, opp, pt);
        np3.Pre_Sales_Result__c = 'Accepted';
        np3.UW_Result__c = 'Accepted';
        update np3;
        
        Person_Insured__c pi1 = TestClassUtility.createPersonInsured(np1);
        Person_Insured__c pi2 = TestClassUtility.createPersonInsured(np2);
        Person_Insured__c pi3 = TestClassUtility.createPersonInsured(np3);
        
        ptvs = new TMPolicyUtil.PolicyTransactionValidationStruct(new TMCreatePolicyCtrl(new ApexPages.StandardController(pt)));
        selectedProduct = new Product__c(Name='Cigna VHIS Standard Plan');
        ptvs.ctrl.selectedProduct = selectedProduct;
        
        Policy_Validation_Checking__c pcv = new Policy_Validation_Checking__c(Duplicate_Policy_Checking__c='Y3',
                                                                              Post_Duplication_Checking__c='R',
                                                                              AUW__c='R',BMI__c='VSTDG Test',
                                                                              Smoking__c='VSTDG Test',
                                                                              Product_Code__c='VSTDG', 
                                                                              UW_Requirement__c='R',
                                                                              Name='VSTDG Policy_Validation_Checking__c');
        insert pcv;
        
        GA_Product_Validation_Checking__c gapvc = new GA_Product_Validation_Checking__c (Name='type1',AUW__c='R',Channel__c='others',
                                                                                         Insured_Type__c='PH = PI',
                                                                                         Post_Duplication_Checking__c='R',
                                                                                         Side_Order__c='N',
                                                                                         UW_Requirement__c='R');
        insert gapvc;
        
        gapvc = new GA_Product_Validation_Checking__c (Name='type1',AUW__c='R',Channel__c='others',
                                                       Insured_Type__c='Dependent',
                                                       Post_Duplication_Checking__c='R',
                                                       Side_Order__c='N',
                                                       UW_Requirement__c='R');
        insert gapvc;
        
        pis1 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pi1.Insured_Type__c = 'PH = PI';
        pi1.Relationship__c = 'Policy Holder';
        pi1.Benefit_Level__c = 'VSTDG testbenefit'; 
        pi1.PI_Age__c = 40;
        pis1.availableDiscountMap = new Map<String, Boolean>();
        pis1.availableDiscountMap.put('SPOUSE DISCOUNT',true);
        pis1.pi = pi1;
        pis1.piPolicy = np1;
        piList.add(pis1); 
        
        pis2 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pi2.Insured_Type__c = 'Spouse';
        pi2.Relationship__c = 'Spouse';
        pi2.Spouse_PI_ID__c = 'J1234010';
        pi2.Benefit_Level__c = 'VSTDG testbenefit'; 
        pi2.PI_Age__c = 38;
        pis2.availableDiscountMap = new Map<String, Boolean>();
        pis2.availableDiscountMap.put('SPOUSE DISCOUNT',true);
        pis2.pi = pi2;
        pis2.piPolicy = np2;
        piList.add(pis2); 
        
        pis3 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pi3.Insured_Type__c = 'Dependent';
        pi3.Benefit_Level__c = 'VSTDG testbenefit'; 
        pi3.PI_Age__c = 16;
        pi3.Relationship__c = 'Son';
        pi3.Parent_PI_ID__c = 'testparent';
        pis3.availableDiscountMap = new Map<String, Boolean>();
        pis3.availableDiscountMap.put('CHILD DISCOUNT*',true);
        pis3.availableDiscountMap.put('GROUP DISCOUNT (CHILD)',true);
        pis3.availableDiscountMap.put('KIDS DISCOUNT',true);
        pis3.pi = pi3;
        pis3.piPolicy = np3;
        piList.add(pis3); 
        
        ptvs.ctrl.personInsuredStructureList = piList;
    
    }
    
    static testMethod void testConstrutor(){
        generateData();
        Test.startTest();
        TMProductStrategyVSTDG tmpsvstdg = new TMProductStrategyVSTDG(ptvs);
        system.assert(tmpsvstdg != null);
        Test.stopTest();
    }

    @isTest
    static void testDiscountValidation1(){
        generateData();
        selectedProduct.Product_Code__c = 'VSMMG';
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyVSMMG tmpsvsmmg = new TMProductStrategyVSMMG(ptvs);   
        tmpsvsmmg.discountValidation();
        Test.stopTest();
    }
    
    @isTest
    static void testDiscountValidation2(){
        generateData();
        ptvs.ctrl.personInsuredStructureList.clear();
        ptvs.ctrl.personInsuredStructureList.add(pis2);
        selectedProduct.Product_Code__c = 'VSMMG';
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyVSMMG tmpsvsmmg = new TMProductStrategyVSMMG(ptvs);   
        tmpsvsmmg.discountValidation();
        Test.stopTest();
    }
    
    @isTest
    static void testDiscountValidation3(){
        generateData();
        ptvs.ctrl.personInsuredStructureList.clear();
        ptvs.ctrl.personInsuredStructureList.add(pis3);
        selectedProduct.Product_Code__c = 'VSMMG';
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyVSMMG tmpsvsmmg = new TMProductStrategyVSMMG(ptvs);   
        tmpsvsmmg.discountValidation();
        Test.stopTest();
    }
    
    @isTest
    static void testPiValidation(){
        generateData();
        selectedProduct.Product_Code__c = 'VSTDG';
        ptvs.ctrl.selectedDiscount1 = 'BUNDLE DISCOUNT';
        ptvs.ctrl.selectedDiscount2 = 'LOYALTY DISCOUNT';
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyVSTDG tmpsvstdg = new TMProductStrategyVSTDG(ptvs);   
        tmpsvstdg.piValidation();
        Test.stopTest();
    }
    
    @isTest
    static void testTransactionValidation(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        TMProductStrategyVSTDG tmpsvstdg = new TMProductStrategyVSTDG(ptvs);
        selectedProduct.Product_Code__c = 'VSTDG';
        tmpsvstdg.transactionValidation();
        Test.stopTest();
    }

}