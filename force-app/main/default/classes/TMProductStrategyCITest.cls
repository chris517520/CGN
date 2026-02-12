/********************************************************************************
 * Apex Class Name - TMProductStrategyCITest
 * Created Date - Sep 30, 2025
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Rancho          09/30/2025              Initial Version
 ********************************************************************************/
@isTest
public class TMProductStrategyCITest {
    private static TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    private static Product__c selectedProduct;
    private static List<TMCreatePolicyCtrl.PersonInsuredStructure> piList;
    private static TMCreatePolicyCtrl.PersonInsuredStructure pis;
    private static Policy_Validation_Checking__c pvc;
    private static TMCreatePolicyCtrl ctrl;
    private static Person_Insured__c pi;
    private static New_Policy__c np;
    private static Account acc;
    private static Opportunity opp;
    private static Policy_Transaction__c pt;
    
    @testSetup 
    static void init(){
        TestClassUtility.initCustomSetting();
        TestClassUtility.initTMCampaignSetting();    
        TestClassUtility.initTMGeneralSetting();
        TestClassUtility.initESalesEndpoint();
        TestClassUtility.initWSsetting();
    }
    
    /**
     * 准备测试数据
     */
    static void generateData(){
        Channel__c chnl = new Channel__c(Channel_Code__c='others', name='others');
        insert chnl;        
        
        Campaign cam = new Campaign(Name='Test Campaign', Channel__c=chnl.id);
        insert cam;
        
        acc = new Account(Name='Test Account'); 
        insert acc;
        
        opp = new Opportunity(
            accountid=acc.id,
            Name='Test Opportunity',
            closedate=Date.today().addDays(180),
            stagename='NMB',
            campaign__c=cam.id
        );       
        insert opp;
        
        pt = TestClassUtility.createPolicyTransaction(acc, opp, 1, '1'); 
        np = TestClassUtility.createNewPolicy(acc, opp, pt);
        np.Product_Code__c = 'CIB25';
        np.Policy_No__c = 'TESTPOL001';
        update np;
        
        pi = TestClassUtility.createPersonInsured(np);
        pi.Personal_ID__c = 'ddddddd';
        pi.PI_Age__c = 30;
        update pi;
        
        ctrl = new TMCreatePolicyCtrl(new ApexPages.StandardController(pt));
        ptvs = new TMPolicyUtil.PolicyTransactionValidationStruct(ctrl);
        
        selectedProduct = new Product__c(Name='CI Product Test', Product_Code__c='CIB25');
        ptvs.ctrl.selectedProduct = selectedProduct;

        HttpCalloutVO.Policy p = new HttpCalloutVO.Policy();
        p.policyNumber = 'TEST000001';
        p.productCode = 'CIB25';
        p.effDateInDate = Date.today();
        p.policyStatusDisplayName = 'Inforce';
        
        piList = new List<TMCreatePolicyCtrl.PersonInsuredStructure>();
        pis = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pis.PersonalIDPolicylistFromWS = new List<HttpCalloutVO.Policy>{p};
        pis.pi = pi;
        pis.piPolicy = np;
        pis.sumInsured = '500000';
        pis.piValidationItem = new TMPolicyUtil.PIValidationItem();
        pis.piValidationItem.otherValidation = true;
        piList.add(pis);
        
        ptvs.ctrl.personInsuredStructureList = piList;
        ptvs.ctrl.amountOfPI = 1;
        ptvs.ctrl.opportunityId = opp.Id;
    }
    
    /**
     * 测试构造函数
     */
    @isTest
    static void testConstructor(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        System.assert(strategy != null);
        System.assertEquals('CIB25', strategy.productCode);
        System.assert(strategy.piSIMap != null);
        Test.stopTest();
    }
    
    /**
     * 测试discountValidation方法
     */
    @isTest
    static void testDiscountValidation(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.discountValidation();
        Test.stopTest();
    }
    
    /**
     * 测试transactionValidation方法
     */
    @isTest
    static void testTransactionValidation(){
        generateData();
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.transactionValidation();
        Test.stopTest();
    }
    
    /**
     * 测试piValidation方法 - 基本保额验证成功
     */
    @isTest
    static void testPiValidation_Success(){
        generateData();
        pis.sumInsured = '500000';
        pis.pi.PI_Age__c = 30;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 空值
     */
    @isTest
    static void testSumInsuredValidation_Empty(){
        generateData();
        pis.sumInsured = '';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 无效数字
     */
    @isTest
    static void testSumInsuredValidation_InvalidNumber(){
        generateData();
        pis.sumInsured = 'abc';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        System.assertEquals(false, pis.piValidationItem.otherValidation);
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 小于最小值
     */
    @isTest
    static void testSumInsuredValidation_BelowMinimum(){
        generateData();
        pis.sumInsured = '200000';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        System.assertEquals(false, pis.piValidationItem.otherValidation);
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 不是千的倍数
     */
    @isTest
    static void testSumInsuredValidation_NotThousandMultiple(){
        generateData();
        pis.sumInsured = '500123';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        System.assertEquals(false, pis.piValidationItem.otherValidation);
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 不同年龄段的保额限制
     */
    @isTest
    static void testSumInsuredValidation_AgeLimits(){
        generateData();
        pis.sumInsured = '4000000';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        // 测试18-45岁
        pis.pi.PI_Age__c = 30;
        TMProductStrategyCIB25 strategy1 = new TMProductStrategyCIB25(ptvs);
        strategy1.piValidation();
        
        // 测试46-55岁
        pis.pi.PI_Age__c = 50;
        pis.piValidationItem.otherValidation = true;
        TMProductStrategyCIB25 strategy2 = new TMProductStrategyCIB25(ptvs);
        strategy2.piValidation();
        
        // 测试56-65岁
        pis.pi.PI_Age__c = 60;
        pis.piValidationItem.otherValidation = true;
        TMProductStrategyCIB25 strategy3 = new TMProductStrategyCIB25(ptvs);
        strategy3.piValidation();
        
        // 测试超过65岁
        pis.pi.PI_Age__c = 70;
        pis.sumInsured = '1000000';
        pis.piValidationItem.otherValidation = true;
        TMProductStrategyCIB25 strategy4 = new TMProductStrategyCIB25(ptvs);
        strategy4.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 儿童保额（18岁以下）
     */
    @isTest
    static void testSumInsuredValidation_Child(){
        generateData();
        pis.pi.PI_Age__c = 10;
        pis.pi.Parent_PI_ID__c = 'TEST000001';
        pis.sumInsured = '2000000';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 有现有保额的情况
     */
    @isTest
    static void testSumInsuredValidation_WithExistingSI(){
        generateData();
        pis.sumInsured = '3000000';
        pis.pi.PI_Age__c = 30;
        pis.piValidationItem.otherValidation = true;
        
        // 创建现有保单
        New_Policy__c existingPolicy = new New_Policy__c();
        existingPolicy.Account__c = acc.Id;
        existingPolicy.Opportunity__c = opp.Id;
        existingPolicy.Policy_Transaction__c = pt.Id;
        existingPolicy.Policy_Status__c = 'Completed';
        existingPolicy.Product_Code__c = 'CIB25';
        existingPolicy.Policy_No__c = 'EXISTPOL001';
        existingPolicy.Sum_Insured__c = 1000000;
        insert existingPolicy;
        
        Person_Insured__c existingPI = new Person_Insured__c();
        existingPI.New_Policy__c = existingPolicy.Id;
        existingPI.Personal_ID__c = pi.Personal_ID__c;
        insert existingPI;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 儿童有父保单的情况
     */
    @isTest
    static void testSumInsuredValidation_ChildWithParent(){
        generateData();
        
        // 创建父保单
        New_Policy__c parentPolicy = new New_Policy__c();
        parentPolicy.Account__c = acc.Id;
        parentPolicy.Opportunity__c = opp.Id;
        parentPolicy.Policy_Transaction__c = pt.Id;
        parentPolicy.Policy_Status__c = 'Completed';
        parentPolicy.Product_Code__c = 'CIB25';
        parentPolicy.Policy_No__c = 'PARENTPOL001';
        parentPolicy.Sum_Insured__c = 3000000;
        insert parentPolicy;
        
        Person_Insured__c parentPI = new Person_Insured__c();
        parentPI.New_Policy__c = parentPolicy.Id;
        parentPI.Personal_ID__c = 'P123456(7)';
        insert parentPI;
        
        // 设置子保单
        pis.pi.PI_Age__c = 10;
        pis.pi.Parent_PI_ID__c = 'P123456(7)';
        pis.parentPolicyNumber = 'PARENTPOL001';
        pis.sumInsured = '3000000';
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 多个PI的情况
     */
    @isTest
    static void testSumInsuredValidation_MultiplePI(){
        generateData();
        
        // 添加第二个PI
        Person_Insured__c pi2 = TestClassUtility.createPersonInsured(np);
        pi2.Personal_ID__c = 'B123456(7)';
        pi2.PI_Age__c = 25;
        update pi2;
        
        TMCreatePolicyCtrl.PersonInsuredStructure pis2 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pis2.pi = pi2;
        pis2.piPolicy = np;
        pis2.sumInsured = '1000000';
        pis2.piValidationItem = new TMPolicyUtil.PIValidationItem();
        pis2.piValidationItem.otherValidation = true;
        piList.add(pis2);
        
        ptvs.ctrl.amountOfPI = 2;
        ptvs.ctrl.personInsuredStructureList = piList;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - 超过最大限制
     */
    @isTest
    static void testSumInsuredValidation_ExceedsMaxLimit(){
        generateData();
        pis.sumInsured = '5000000';
        pis.pi.PI_Age__c = 30;
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
        
        System.assertEquals(false, pis.piValidationItem.otherValidation);
        Test.stopTest();
    }
    
    /**
     * 测试CIR25产品
     */
    @isTest
    static void testCIR25Product(){
        generateData();
        selectedProduct.Product_Code__c = 'CIR25';
        np.Product_Code__c = 'CIR25';
        update np;
        pis.sumInsured = '500000';
        pis.pi.PI_Age__c = 30;
        pis.piValidationItem.otherValidation = true;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIR25 strategy = new TMProductStrategyCIR25(ptvs);
        strategy.piValidation();
        
        Test.stopTest();
    }
    
    /**
     * 测试保额验证 - otherValidation为false时跳过验证
     */
    @isTest
    static void testSumInsuredValidation_SkipWhenOtherValidationFalse(){
        generateData();
        pis.sumInsured = '500000';
        pis.piValidationItem.otherValidation = false;
        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class, ResponseMock);
        
        TMProductStrategyCIB25 strategy = new TMProductStrategyCIB25(ptvs);
        strategy.piValidation();
    
        Test.stopTest();
    }
}