/********************************************************************************
 * Apex Class Name - TMCreatePolicyCtrlTest
 * Version - 1.0
 * Created Date - Mar 28, 2018
 * @description Test class for TMCreatePolicyCtrl
 * 
 * Modification Log : 
 * -------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Franco          28/03/2018              Original Version
 ********************************************************************************/
@isTest
public class TMCreatePolicyCtrlTest {
    private static Product__c selectedProduct;
    private static List<TMCreatePolicyCtrl.PersonInsuredStructure> pisList;
    private static TMCreatePolicyCtrl.PersonInsuredStructure pis;
    private static Policy_Validation_Checking__c pvc;
    private static TMCreatePolicyCtrl ctrl;
    private static TMCreatePolicyCtrl ctrlNoPT;
    private static Person_Insured__c pi;
    private static Policy_Transaction__c pt;
    private static New_Policy__c np;
    private static Product__c prod;    
    
    /********************************************************************************
     * Prepare test data
    ********************************************************************************/
    @testSetup 
    static void init(){
        TestClassUtility.initCustomSetting();
        TestClassUtility.initTMCampaignSetting();       
        TestClassUtility.initCountryListSettings();
        TestClassUtility.initBusinessNature();
        TestClassUtility.initDiscountCode();// friend discount
        TestClassUtility.initTMProductCat();// friend discount
    }
    
    /********************************************************************************
     * Prepare test data
    ********************************************************************************/
    static void generateData(){
    
        Channel__c chnl = new Channel__c(Channel_Code__c='others',name='others');
        insert chnl;
        RecordType tmProductRT = [select id from Recordtype where sobjecttype = 'Product__c' and developername = 'TM_Product'];
        prod = new Product__c(Name='Cigna Senior Life Plan',Product_code__c='@SP100',Is_Life__c=true,CRS_Indicator__c=false,Is_Basic_Plan__c=false,Policy_Prefix__c='CTM00',Is_AML__c=true,currency__c='HKD',recordtypeid = tmProductRT.id);
        insert prod;
        Campaign cam = new Campaign(Name='Core Campaign',Channel__c=chnl.id,Core_Product__c=prod.id,Credit_Card__c='CC;CM',BF_Annual__c = 1, BF_Month__c = 2, BF_Quater__c = 3, BF_Semi_Annual__c = 4, BF_Single__c = 5);
        insert cam;
        Account acc = new Account(Name='Test Account',Credit_Card_No_BackEnd__c='testcard',Email__c = 'test@cigna.com'); 
        insert acc;
        Opportunity opp = new Opportunity(accountid=acc.id,Name='Test Opportunity',closedate=Date.today().addDays(180),stagename='NMB',campaign__c=cam.id);       
        insert opp;
        opp.Prod_Rider_Map__c = '{"PBC":["ALL"],"PBT":["ALL"],"LPC":["ALL"],"ROP108":["ALL"],"VHIS":["ALL"],"DMB":["ALL"],"TUP":["ALL"],"TUL":["ALL"],"TU":["ALL"],"PM":["ALL"],"NEL":["ALL"]}';
		update opp;
        //Jack Shao 2020_08_18 add Custom_Value__c data for testing
		Custom_Value__c productSetting = new Custom_Value__c(Name = 'Replacement_Product',Value__c = 'C15L1,C15L6,C15R6,C25L1,C25L6,C25R6,@KIDSL,RSM,RSPH,RSPHS,RSPU,RSPUS,@SP100',Description__c = 'Replacement product group');
        insert productSetting;
        //Commented by Jack Shao on 2020_08_18: attribute not used 
        //ctrlNoPT = new TMCreatePolicyCtrl(new ApexPages.StandardController(new Policy_Transaction__c(Opportunity__c = opp.id)));
        
        pt = TestClassUtility.createPolicyTransaction(acc, opp, 1, '5');
        np = TestClassUtility.createNewPolicy(acc, opp, pt,'Pending Basic Information', prod);
        np.Bank_Name__c = 'test';
        np.Name_of_Card_Issuing_Bank__c = '101';
        np.Card_Expiry_Date_Text__c = 'test';
        //upsert np;
        pi = TestClassUtility.createPersonInsured(np);
        pvc = new Policy_Validation_Checking__c(Duplicate_Policy_Checking__c='Y',
                                                Post_Duplication_Checking__c='N',
                                                AUW__c='N',BMI__c='Test',
                                                Smoking__c='N',
                                                Product_Code__c='SP100',
                                                UW_Requirement__c='GA',
                                                Name='SP100');
        insert pvc;
        GA_Product_Validation_Checking__c gapvc = new GA_Product_Validation_Checking__c (Name='type1',AUW__c='R',Channel__c='others',
                                                                                         Insured_Type__c='PH = PI',
                                                                                         Post_Duplication_Checking__c='R',
                                                                                         Side_Order__c='N',
                                                                                         UW_Requirement__c='R');        
        insert gapvc;
        
        //prepare WS
        //ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        //Test.setMock(HttpcalloutMock.class,ResponseMock);
        pt = [select Account__c,Opportunity__c,Number_of_Person_Insured__c,Product_Code__c,Step__c,Status__c,Core_Campaign__c,Product_Name__c,Web_Site_Running_Number__c,Opportunity__r.Campaign__r.Core_Product__c from policy_transaction__c where Web_Site_Running_Number__c = 'forTest'];
        System.debug('[TMCreatePolicyCtrlTest] generateData().pt='+pt);
		//2020_12_16_Nicole_auto
		//pt.Opportunity__c = opp.Id;
        ctrl = new TMCreatePolicyCtrl(new ApexPages.StandardController(pt));
        
        
        //fill in the fields in step 1 
        ctrl.newPolicy.Product__c = pt.Opportunity__r.Campaign__r.Core_Product__c;
        System.debug('[TMCreatePolicyCtrlTest] generateData().ctrl.newPolicy.Product__c='+ctrl.newPolicy.Product__c);
        //fill in the fields in step 2    
            
        pis = new TMCreatePolicyCtrl.PersonInsuredStructure();
        
        pis.pi = pi;
        np.UW_Result__c = 'Rejected';
        
        pis.piPolicy = np;
        
        TMCreatePolicyCtrl.BeneficiaryStruct bis= new TMCreatePolicyCtrl.BeneficiaryStruct();
        pis.beneficiaryList.add(bis);
        pisList = new List<TMCreatePolicyCtrl.PersonInsuredStructure>(); 
        //2020_12_14_Nicole_auto
        pis.piPolicy.to_Save_Policy_No__c = 'test';
        // friend discount
        pis.piPolicy.Master_Policy_No__c = 'TEST00001';
        pis.piPolicy.Master_Policy_of_Friend_Discount__c = 'TEST00002';
        pisList.add(pis);

        ctrl.personInsuredStructureList = pisList;

        Bank_Account__c bank = new Bank_Account__c();
        bank.Name = 'Testing bank acc';
        bank.Opportunity__c = opp.Id;
        bank.Policy_Number__c = np.Policy_No__c;
        bank.Credit_Card_No__c = '123443212344321';
        bank.Bank_Account_No__c = '1234432112344321';
        bank.Payment_Type__c = 'Credit_Card';
        insert bank;

        Bank_Account__c bank2 = new Bank_Account__c();
        bank2.Name = 'Testing bank acc2';
        bank2.Opportunity__c = opp.Id;
        bank2.Policy_Number__c = np.Policy_No__c;
        bank2.Credit_Card_No__c = '123443212344322';
        bank2.Bank_Account_No__c = '1234432112344322';
        bank2.Payment_Type__c = 'Bank';
        insert bank2;
    }       
    
    @isTest
    static void testInitPolicyTransactionWithPara(){
        generateData();
        Test.startTest();
        ctrl.initPolicyTransaction();
        pt.Status__c = 'Completed';
        ctrl.initPolicyTransaction(pt.id);
        pt.Status__c = 'Submitted';
        update pt;  
        ctrl.newPolicy.Refund_Discount__c = 'test';
        ctrl.newPolicy.Bank_Name__c = 'test';
        ctrl.newPolicy.Name_of_Card_Issuing_Bank__c = 'test';
        ctrl.newPolicy.Card_Expiry_Date_Text__c = 'test';
        ctrl.initPolicyTransaction(pt.id);
        
        Test.stopTest();
    }
    
    @isTest
    static void testActionFunctions(){
        generateData();
        Test.startTest();
        ctrl.displayEducationInfo();
        ctrl.displayMeansOfIncomeInfo();
        ctrl.displayPIResidenceAddId();
        ctrl.displayPurposeOfInsurance();
        ctrl.displayOtherSourceOfFund();
        ctrl.displayInchInput();
        ctrl.displayAppealForPresales();
        ctrl.refreshTMInsuredType();
        Test.stopTest();
    }

    @isTest
    static void testPicklistInitilize(){
        generateData();        
        Test.startTest();
        ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
       
        System.debug('[TMCreatePolicyCtrlTest] testPicklistInitilize().ctrl.productMap='+ctrl.productMap);
        System.debug('[TMCreatePolicyCtrlTest] testPicklistInitilize().ctrl.newPolicy.Product__c='+ctrl.newPolicy.Product__c);
        System.debug('[TMCreatePolicyCtrlTest] testPicklistInitilize().ctrl.selectedProduct='+ctrl.selectedProduct);
        ctrl.selectedProduct.Product_Code__c = 'CBOG';
        ctrl.personInsuredStructureList[0].pi.Rider__c = '';
         ctrl.currentStep = 1;
        ctrl.pickListInitialize();        
        ctrl.onProductChange();
        //ctrl.nextStep();
        ctrl.currentStep = 2;
        //ctrl.nextStep();
        ctrl.currentStep = 3;
        //ctrl.nextStep();
        ctrl.currentStep = 4;
        ctrl.personInsuredStructureList.get(0).pi.Benefit_Level__c = '1';
        ctrl.previousStep();
        ctrl.currentStep = 3;
        ctrl.currentStep = 6;
        ctrl.personInsuredStructureList[0].piValidationItem.otherValidation = true;
        ctrl.personInsuredStructureList[0].piValidationItem.isDuplicate = false;
        ctrl.personInsuredStructureList[0].piPolicy.Pre_Sales_Result__c = 'Accepted';
        ctrl.getPaymentPremium();
        ctrl.personInsuredStructureList[0].pi.Gender__c = 'Female';
        ctrl.personInsuredStructureList[0].pi.Smoker__c = 'Yes';
        ctrl.personInsuredStructureList[0].pi.Benefit_Level__c = '1';
        ctrl.personInsuredStructureList[0].pi.Rider__c = 'test';
        ctrl.personInsuredStructureList[0].pi.Basic_Plan__c = '@CBOG';
        ctrl.getPaymentPremium();
        ctrl.personInsuredStructureList[0].pi.Basic_Plan__c = 'CBOG;@CBOG;PBTG;@PBTG';
        ctrl.getPaymentPremium();
        ctrl.personInsuredStructureList[0].pi.Basic_Plan__c = 'SP100;@SP100';
        ctrl.getPaymentPremium();
        TMEsalesHelper.PremiumAmt amt = new TMEsalesHelper.PremiumAmt();
        amt.premiumPerson = 'PI' + 1;
        amt.isRider = false;
        amt.premiumDescription = 'PMGH';
        amt.originalPremiumMonth = 2000;
        amt.annualPremium = 12000;
        amt.discountPercent = 10;
        amt.discountPremium = 1200;
        amt.totalDiscountPercent = 10;
        amt.totalDiscountPremium = 1200;
        amt.originalPremium = 12000;
        amt.loadingPremium = 0;
        amt.actualPremium = 12000;
        amt.policyId = ctrl.newPolicy.id;
        amt.benefitLevel = '1';        
        amt.productCode = 'PMGH';
        
        amt.modalFactor = 0.0833333;
        //ctrl.isSpecialProduct = false;
        ctrl.premiumAmountList.add(amt);
        ctrl.selectedPaymentFrequency = 'Monthly';
        ctrl.selectedProduct.Product_Code__c = 'PMGH';
        ctrl.initPremiumAmountList(true);
        ctrl.selectedProduct.Product_Code__c = 'SP100';
        ctrl.initPremiumAmountList(true);
        ctrl.selectedProduct.Product_Code__c = 'NELG';
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedPaymentFrequency = 'Quarterly';
        ctrl.selectedProduct.Product_Code__c = 'PMGH';
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedProduct.Product_Code__c = 'SP100';
        amt.totalDiscountPercent = null;
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedProduct.Product_Code__c = 'NELG';
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedPaymentFrequency = 'Semi Annually';
        ctrl.selectedProduct.Product_Code__c = 'PMGH';
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedProduct.Product_Code__c = 'SP100';
        amt.totalDiscountPercent = null;
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedProduct.Product_Code__c = 'NELG';
        ctrl.initPremiumAmountList(true);
        
        ctrl.selectedPaymentFrequency = '';
        ctrl.initPremiumAmountList(true);
        amt.productCode = 'RSPU';
        ctrl.initPremiumAmountList(true);
        
        
        Test.stopTest(); 
    }
    /*
    @isTest
    static void testTMCreatePolicyCtrlConstruction(){
        Test.startTest();
        generateDataWithNoPolicyTransaction();
        Test.stopTest(); 
    }*/
    
    @isTest
    static void testinitPersonInsuredInfo(){
        generateData();
        Test.startTest();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        HttpCalloutVO.Rider rider1 = new HttpCalloutVO.Rider();
        rider1.riderCode = 'PH';
        rider1.riderName = 'TestRiderName';
        List<HttpCalloutVO.Rider> riList = new List<HttpCalloutVO.Rider>();
        riList.add(rider1);
        ctrl.riderMap = new Map<String,List<HttpCalloutVO.Rider>>();
        ctrl.riderMap.put('1',riList);
        ctrl.benefitLevelOption = new List<SelectOption>();
        ctrl.benefitLevelOption.add(new SelectOption('1','Level 1'));
        //List<SelectOption> benefitLevelOptionForRider = ctrl.benefitLevelOptionForRider;
        
        ctrl.initPersonInsuredInfo();  // ctrl.amountOfPI == 1
        
        ctrl.amountOfPI = 2;
        ctrl.initPersonInsuredInfo();
        
        ctrl.amountOfPI = 0;
        ctrl.initPersonInsuredInfo();

        Test.stopTest(); 
    }
    
    @isTest
    static void testisUWResultExisting(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.isUWResultExisting();
        Test.stopTest(); 
    }
    /**
    @isTest
    static void testpreSalesOnPage(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        pis.piValidationItem.needPresales = true;
        ctrl.preSalesOnPage();
        Test.stopTest(); 
    }
    **/
    @isTest
    static void testJumpToPI(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.uwPISIndex = 1;
        ctrl.uwPISListForDisplay.add(pis);
        ctrl.JumpToPI();
        Test.stopTest(); 
    }
    
    @isTest
    static void testSave(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.save();
        Test.stopTest(); 
    }
    
    @isTest
    static void testCancelRemoveInvalidPI(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.cancelRemovePolicyNumber = 'CTM0009999';
        ctrl.cancelRemoveInvalidPI();
        Test.stopTest(); 
    }
    
    @isTest
    static void testRemoveInvalidPI(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.removePolicyNumber = 'CTM0009999';
        ctrl.removeInvalidPI();
        Test.stopTest(); 
    }
    
    @isTest
    static void testEditCrerditCardNumber(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.editCrerditCardNumber();
        Test.stopTest(); 
    }
    
    @isTest
    static void testEditBankNumber(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.editBankNumber();
        Test.stopTest(); 
    }
    
    @isTest
    static void testSelectUWAppeal(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.selectUWAppeal();
        Test.stopTest(); 
    }

    @isTest
    static void testAddBenefit(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.selectedPINoBNNum = '0,0';
        ctrl.AddBenefit();
        Test.stopTest(); 
    }
    
    @isTest
    static void testRemoveBenefit(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.selectedPINoBNNum = '0,1';
        ctrl.removeBenefit();
        Test.stopTest(); 
    }
    
    @isTest
    static void testAutoCalculateAge(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.autoCalculateAge();
        ctrl.autoCalculatePHAge();
        Test.stopTest(); 
    }
    
    @isTest
    static void testchangeRider(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = 'RSM';   // not one of SP100;DMBG;@SP100;@DMBG;
        ctrl.piIndex = 0;
        HttpCalloutVO.Rider rider1 = new HttpCalloutVO.Rider();
        List<HttpCalloutVO.Rider> riList = new List<HttpCalloutVO.Rider>();
        riList.add(rider1);
        ctrl.riderMap = new Map<String,List<HttpCalloutVO.Rider>>();
        ctrl.riderMap.put('1',riList);
        ctrl.newPolicy.Product_Code__c ='@CBOG';
        ctrl.changeRider();
        
        ctrl.selectedProduct.Product_Code__c = 'PBTG';
        Map<String, Map<String,Set<String>>>  riderCodeBenefitLevelListMap = new Map<String, Map<String,Set<String>>>();
        Set<String> riderbenefitlevelSet = new Set<String>();
        riderbenefitlevelSet.add('1');
        Map<String,Set<String>> tmpMap = new Map<String,Set<String>>();
        tmpMap.put('1', riderbenefitlevelSet);
        riderCodeBenefitLevelListMap.put('PBTG',tmpMap);
        ctrl.riderCodeBenefitLevelListMap = riderCodeBenefitLevelListMap;
        TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai = new TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem();
        ai.selectedRiderCode = 'PBTG';
        ai.benefitLevelOption = new List<SelectOption>();
        ctrl.personInsuredStructureList.get(0).pi.Benefit_Level__c = '1';
        ctrl.personInsuredStructureList.get(0).availableRiderBenefitlevelItemList = new List<TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem>();
        ctrl.personInsuredStructureList.get(0).availableRiderBenefitlevelItemList.add(ai);
        Map<String,HttpCalloutVO.Benefit> benefitMap = new Map<String,HttpCalloutVO.Benefit>();
        HttpCalloutVO.Benefit benefit = new HttpCalloutVO.Benefit();
        benefit.benefitLevelName = 'First';
        benefitMap.put('1',benefit);
        ctrl.benefitMap = benefitMap;
        ctrl.changeRider();
        Test.stopTest(); 
    }
    
    @isTest
    static void testAutoGenerateInsureType(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        pi.Relationship__c = 'Policy Holder';
        ctrl.newPolicy.Product_Code__c = '@PBTG';
        ctrl.autoGenerateInsureType();
        pi.Relationship__c = 'Spouse';
        ctrl.autoGenerateInsureType();
        pi.Relationship__c = 'Son';
        ctrl.autoGenerateInsureType();
        pi.Relationship__c = 'others';
        ctrl.autoGenerateInsureType();
        Test.stopTest(); 
    }
    
    @isTest
    static void testpaymentMethodInitialize(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.cam.Payment_Method__c = 'Others;Others';
        ctrl.paymentMethodInitialize();
        Test.stopTest(); 
    }
    
    @isTest
    static void testbankInitialize(){
        Test.startTest();
        generateData();
        ctrl.cam.Select_All_Bank__c = true;
        ctrl.bankInitialize();
        ctrl.cam.Select_All_Bank__c = false;
        ctrl.cam.Bank__c = 'BANK OF INDIA;CANARA BANK';
        ctrl.bankInitialize();
        Test.stopTest(); 
    }
    
    @isTest
    static void testisAML(){
        Test.startTest();
        generateData();
        boolean result1 = ctrl.isAML;
        
        Country_List_Settings__c cls = new Country_List_Settings__c(
            Name = 'CHINA',
            Aml_Highrisk__c = true,
            Chi_Desc__c = '中國',
            Country_Id__c = 'CHN',
            Crs_Ind__c = true,
            Eng_Desc__c = 'CHINA',
            s6_code__c = 'CN'
        );
        insert cls;
        ctrl.countryList.add(cls); 
        boolean result2 = ctrl.isAML;
        Test.stopTest(); 
    }
    
    @isTest 
    static void testgetUWStatus(){
        generateData();
        Test.startTest();
        UW_Result__c uwresult = new UW_Result__c(Policy__c = np.id,Application_Id__c = 'TM_CTM00000497_20180803122812');
        insert uwresult;
        TMCreatePolicyCtrl.getUWStatus('TM_CTM00000497_20180803122812', '2018-09-10');
        Test.stopTest(); 
    }
    
    @isTest 
    static void testCopyAboveBeneficiary(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        //pis.beneficiaryList
        TMCreatePolicyCtrl.PersonInsuredStructure pis1 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pis1.pi = new Person_Insured__c(Insured_First_Name__c = 'fisrtname',Insured_Last_Name__c = 'lastname');
        ctrl.personInsuredStructureList.add(pis1);
        ctrl.PINoOfStep3 = 1;
        ctrl.copyAboveBeneficiary();
        TMCreatePolicyCtrl.getUWStatus('xxxxxxx', '2018-09-10');
        Test.stopTest(); 
    }
    
    @isTest 
    static void testriderbtn(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        pis.selectedRiderCodes.add('PH'); 
        pis.removedRiderCodes.add('PH');
        pis.addRiderBtn();
        pis.removeRiderBtn();
        Test.stopTest(); 
    }
    
    @isTest 
    static void testsavePersonInsuredInfo(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai = new TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem();
        ai.selectedRiderCode = 'PH';
        ai.benefitlevel = '1';
        pi.Rider__c = '';
        pis.availableRiderBenefitlevelItemList.add(ai);
        ctrl.savePersonInsuredInfo();
        pi.Rider__c = 'PH';
        ctrl.savePersonInsuredInfo();
        //
        ctrl.selectedProduct.Product_Code__c = 'RSM';   // not one of SP100;DMBG;@SP100;@DMBG;
        pis.selectedRidersMap.put('PH','PH');
        ctrl.savePersonInsuredInfo();
        pi.Rider__c = '';
        //2020_12_17__Nicole_auto
        //ctrl.personInsuredStructureList[0].pi.New_Policy__c = null;
        ctrl.personInsuredStructureList[0].beneficiaryList[0].beneficiary.Percent__c = null;
        ctrl.personInsuredStructureList[0].beneficiaryList[0].beneficiary.Person_Insured__c = null;
        ctrl.personInsuredStructureList[0].beneficiaryList[0].beneficiary.Policy__c = null;
        ctrl.savePersonInsuredInfo();
        ctrl.selectedProduct.Product_Code__c = '@KIDSL';
        ctrl.savePersonInsuredInfo();
        Test.stopTest(); 
    }
    
    @isTest 
    static void testinitRiderRelated4PI(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        List<String> allRiderCodes = new List<String>();
        allRiderCodes.add('PH');
        Map<String,String> allRiders = new Map<String,String>();
        allRiders.put('PH','PH');
        allRiders.put('RSM','RSM');
        List<String> existingRiderCode = new List<String>();
        existingRiderCode.add('RSM');
        String productCode = '@SP100';

        TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai = new TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem();
        ai.selectedRiderCode = 'PH';
        TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai2 = new TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem();
        ai2.selectedRiderCode = 'RSM';
        pi.Rider__c = '1:PH;1:RSM';
        pi.Benefit_Level__c = '1';
        pis.availableRiderBenefitlevelItemList.add(ai);
        pis.availableRiderBenefitlevelItemList.add(ai2);
        Map<String, Map<String,Set<String>>>  riderCodeBenefitLevelListMap = new Map<String, Map<String,Set<String>>>();
        Map<String,Set<String>> basicplanlevelAvailableriderplanlevelSet = new Map<String,Set<String>>();
        Set<String> riderPlanlevelSet = new Set<String>();
        riderPlanlevelSet.add('1');
        riderPlanlevelSet.add('2');
        riderPlanlevelSet.add('3');
        basicplanlevelAvailableriderplanlevelSet.put('1',riderPlanlevelSet);
        basicplanlevelAvailableriderplanlevelSet.put('2',riderPlanlevelSet);
        basicplanlevelAvailableriderplanlevelSet.put('3',riderPlanlevelSet);
        riderCodeBenefitLevelListMap.put('PH',basicplanlevelAvailableriderplanlevelSet);
        riderCodeBenefitLevelListMap.put('RSM',basicplanlevelAvailableriderplanlevelSet);
        Map<String, HttpCalloutVO.Benefit> benefitMap = new Map<String, HttpCalloutVO.Benefit>();
        HttpCalloutVO.Benefit benefitVO = new HttpCalloutVO.Benefit();
        benefitVO.benefitLevelName = 'test';
        benefitMap.put('1',benefitVO);
        benefitMap.put('2',benefitVO);
        benefitMap.put('3',benefitVO);
        Opportunity opp = [select Prod_Rider_Map__c from opportunity limit 1];
        //GL31 - Tovid 20210611
        //pis.initRiderRelated4PI(allRiderCodes,allRiders,existingRiderCode,productCode,riderCodeBenefitLevelListMap,benefitMap,opp.Prod_Rider_Map__c);
        pis.initRiderRelated4PI(allRiderCodes,allRiders,existingRiderCode,productCode,riderCodeBenefitLevelListMap,benefitMap);
        productCode = 'PBTG';
        //GL31 - Tovid 20210611
        //pis.initRiderRelated4PI(allRiderCodes,allRiders,existingRiderCode,productCode,riderCodeBenefitLevelListMap,benefitMap,opp.Prod_Rider_Map__c);
        pis.initRiderRelated4PI(allRiderCodes,allRiders,existingRiderCode,productCode,riderCodeBenefitLevelListMap,benefitMap);
        Test.stopTest(); 
    }
    
    @isTest 
    static void testridermethods(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        pis.selectedRiderCodes.add('PH'); 
        pis.removedRiderCodes.add('PH');
        TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai = new TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem();
        ai.benefitlevel = '1';
        //combo: test for: if(selectedRidersMap.containsKey('CCAG')){
        ai.selectedRiderCode = 'CCAG';

        TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai2 = new TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem();
        ai2.benefitlevel = '2';
        //combo: test for: if(selectedRidersMap.containsKey('CADG')){
        ai2.selectedRiderCode = 'CADG';
        pis.availableRiderBenefitlevelItemList.add(ai);
        pis.availableRiderBenefitlevelItemList.add(ai2);

        pis.availableRidersMap.put('CADG','CADGCADG');
        pis.availableRidersMap.put('CCAG','CCAGCCAG');

        pis.availableRidersMap.put('PH','PH');
        pis.selectedRidersMap.put('PH1','PH1');
        pis.getSelectedRiders();
        pis.selectAvailableRider();
        pis.getAvailableRiders();

        //Combo: test disableRiderItem()
        pis.declaRiderCode = 'CCAG';
        ai.benefitlevel = '';
        pis.pi.Cancer_Declaration__c = '';
        pis.disableRiderItem();

        ai.benefitlevel = '1';
        pis.pi.Cancer_Declaration__c = 'Yes';
        pis.disableRiderItem();

        pis.pi.Cancer_Declaration__c = 'No';
        pis.disableRiderItem();


        pis.declaRiderCode = 'CADG';
        ai2.benefitlevel = '';
        pis.pi.Accident_Declaration__c = '';
        pis.disableRiderItem();

        ai2.benefitlevel = '1';
        pis.pi.Accident_Declaration__c = 'Yes';
        pis.disableRiderItem();

        pis.pi.Accident_Declaration__c = 'No';
        pis.disableRiderItem();

        Test.stopTest(); 
    }
    
    @isTest 
    static void testdisplayOptionalField(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        ctrl.selectedPaymentType = 'Direct Debit';
        ctrl.displayOptionalField();
        ctrl.selectedPaymentType = 'Credit Card Billing';
        ctrl.displayOptionalField();
        ctrl.selectedPaymentType = 'Others'; 
        ctrl.displayOptionalField();
        ctrl.selectedPaymentType = 'Cheque';
        ctrl.displayOptionalField();
        ctrl.selectedPaymentType = 'Direct Billing';
        ctrl.displayOptionalField();
        Test.stopTest(); 
    }
    
    
    
    @isTest
    static void testSelectDiscount1(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        Premium_Discount__c pd1 = new Premium_Discount__c(Discount__c = 0.7);
        Premium_Discount__c pd2 = new Premium_Discount__c(Discount__c = 0.6);
        ctrl.premiumDiscountMap.put('BUNDLE DISCOUNT',pd1);
        ctrl.premiumDiscountMap.put('LOYALTY DISCOUNT',pd2);
        ctrl.selectedDiscount1 = 'TestDiscount';
        ctrl.selectedDiscount2 = 'TestDiscount';
        ctrl.selectDiscount1(); 
        ctrl.selectedDiscount1 = 'BUNDLE DISCOUNT';
        ctrl.selectedDiscount2 = 'LOYALTY DISCOUNT';
        ctrl.selectDiscount1();  
        Test.stopTest(); 
    }
    
    @isTest
    static void testSelectDiscount2(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';
        Premium_Discount__c pd1 = new Premium_Discount__c(Discount__c = 0.7);
        Premium_Discount__c pd2 = new Premium_Discount__c(Discount__c = 0.6);
        ctrl.premiumDiscountMap.put('BUNDLE DISCOUNT',pd1);
        ctrl.premiumDiscountMap.put('LOYALTY DISCOUNT',pd2);
        ctrl.selectedDiscount1 = 'TestDiscount';
        ctrl.selectedDiscount2 = 'TestDiscount';
        ctrl.selectDiscount2(); 
        ctrl.selectedDiscount1 = 'BUNDLE DISCOUNT';
        ctrl.selectedDiscount2 = 'LOYALTY DISCOUNT';
        ctrl.selectDiscount2();  
        Test.stopTest(); 
    }   
    
    @isTest
    static void testsavePolicy(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100';       
        ctrl.PolIdPolicyNoMap = new Map<String,String>();
        Premium_Discount__c pd1 = new Premium_Discount__c(Discount__c = 0.7);
        Premium_Discount__c pd2 = new Premium_Discount__c(Discount__c = 0.6);
        ctrl.premiumDiscountMap.put('BUNDLE DISCOUNT',pd1);
        ctrl.premiumDiscountMap.put('LOYALTY DISCOUNT',pd2);
        ctrl.selectedDiscount1 = 'BUNDLE DISCOUNT';
        ctrl.selectedDiscount2 = 'LOYALTY DISCOUNT';
        ctrl.selectedPaymentType = 'Cheque';
        ctrl.selectedBank = 'CANARA BANK';
        ctrl.selectedCreditCardBank = 'CANARA BANK';
        ctrl.selectedCardYear = '2017';
        ctrl.selectedCardMonth = 'Oct';
        ctrl.currentStep = 6; 
        ctrl.isComplete = true;
        
        TMEsalesHelper.PremiumAmt amt = new TMEsalesHelper.PremiumAmt();
        amt.premiumPerson = 'PI' + 1;
        amt.isRider = false;
        amt.premiumDescription = 'SP100';
        amt.originalPremiumMonth = 2000;
        amt.annualPremium = 12000;
        amt.discountPercent = 10;
        amt.discountPremium = 1200;
        amt.totalDiscountPercent = 10;
        amt.totalDiscountPremium = 1200;
        amt.medicalLoadingPercent = 10;
        amt.medicalLoadingAmount = 10000;
        amt.originalPremium = 12000;
        amt.loadingPremium = 0;
        amt.actualPremium = 12000;
        amt.policyId = ctrl.newPolicy.id;
        amt.benefitLevel = '1';        
        amt.productCode = 'SP100';
        ctrl.premiumAmountList.add(amt);
                
        ctrl.newPolicy.Policy_No__c = null;     
        //ctrl.personInsuredStructureList.add(new TMCreatePolicyCtrl.PersonInsuredStructure());
        New_policy__c policy = new New_policy__c();
        policy.Policy_No__c = 'CTM0009999';
        policy.Policy_Status__c = 'Completed';
        
        policy.Bank_Name__c = 'test';
        policy.Name_of_Card_Issuing_Bank__c = '101';
        policy.Card_Expiry_Date_Text__c = '101';
        
        New_policy__c policy2 = new New_policy__c();
        policy2.Policy_Status__c = 'Completed';
        policy2.Policy_No__c = 'CTM0009998';
        policy2.Bank_Name__c = 'test';
        policy2.Name_of_Card_Issuing_Bank__c = '101';
        policy2.Card_Expiry_Date_Text__c = '101';
        //2020_12_14_Nicole_auto
        New_policy__c policy3 = new New_policy__c();
        policy3.Policy_Status__c = 'Completed';
        policy3.Policy_No__c = null;
        policy.Policy_Transaction__c = ctrl.newPolicy.Policy_Transaction__c;
        policy.Account__c = ctrl.newPolicy.Account__c;
        policy.Opportunity__c = ctrl.newPolicy.Opportunity__c;
        policy3.Bank_Name__c = 'test';
        policy3.Name_of_Card_Issuing_Bank__c = '101';
        policy3.Card_Expiry_Date_Text__c = '101';
        TMCreatePolicyCtrl.PersonInsuredStructure pi2 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pi2.piPolicy = policy2;
        ctrl.personInsuredStructureList.add(pi2);
        
        ctrl.policyList.clear();
        ctrl.policyList.add(policy);
        ctrl.policyList.add(policy2);
        ctrl.policyList.add(policy3);
        ctrl.policyList.add(ctrl.newPolicy);  
        system.debug('[TMCreatePolicyCtrl] savePolicy testing start');   
        //2020_12_17_Nicole_auto
        ctrl.newPolicy.Account__c = null;
        ctrl.newPolicy.Opportunity__c = null;
        ctrl.selectedPaymentType = 'Direct Billing';
        ctrl.policyTransaction.LC_Assessed__c = 'Approved';
        ctrl.newPolicy.Missing_CDD_Info__c = true;
        ctrl.defaultMasterPolicyNum = null;
        ctrl.selectedPaymentType = 'Cheque';
        
        ctrl.savePolicy();
		ctrl.currentStep = 3;
		ctrl.selectedPaymentType = 'Credit Card Billing';        
        ctrl.savePolicy();
        Test.stopTest(); 
    } 
    
    @isTest
    static void testNextStep(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100'; 
        pi.Rider__c = 'PH';
        HttpCalloutVO.Rider rider1 = new HttpCalloutVO.Rider();
        rider1.riderCode = 'PH';
        rider1.riderName = 'TestRiderName';
        List<HttpCalloutVO.Rider> riList = new List<HttpCalloutVO.Rider>();
        riList.add(rider1);
        ctrl.riderMap = new Map<String,List<HttpCalloutVO.Rider>>();
        ctrl.riderMap.put('1',riList);
        
        ctrl.currentStep = 0; 
        ctrl.nextStep();
        ctrl.currentStep = 1; 
        ctrl.nextStep();
        ctrl.currentStep = 2; 
        ctrl.nextStep();
        ctrl.currentStep = 3; 
        ctrl.nextStep();
        //2020_12_16_Nicole
        ctrl.ptvs.policyTransactionValidationItem.showBMIInd = true;
        ctrl.selectedProduct.product_code__c = '@PBTG';
        ctrl.acc.RecordType.developerName = 'TM_Dummy_Account';
        ctrl.ptvs.policyTransactionValidationItem.showBMIInd = true;
        ctrl.nextStep();
        //ctrl.currentStep = 4; 
        //ctrl.nextStep();
        //ctrl.currentStep = 5; 
        //ctrl.nextStep();
        //ctrl.currentStep = 6; 
        //ctrl.nextStep();
        Test.stopTest(); 
    }
    
    @isTest
    static void testNextStep_1(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100'; 
        pi.Rider__c = 'PH';
        HttpCalloutVO.Rider rider1 = new HttpCalloutVO.Rider();
        rider1.riderCode = 'PH';
        rider1.riderName = 'TestRiderName';
        List<HttpCalloutVO.Rider> riList = new List<HttpCalloutVO.Rider>();
        riList.add(rider1);
        ctrl.riderMap = new Map<String,List<HttpCalloutVO.Rider>>();
        ctrl.riderMap.put('1',riList);
        
        //ctrl.currentStep = 0; 
        //ctrl.nextStep();
        //ctrl.currentStep = 1; 
        //ctrl.nextStep();
        //ctrl.currentStep = 2; 
        //ctrl.nextStep();
        //ctrl.currentStep = 3; 
        //ctrl.nextStep();
        ctrl.currentStep = 4; 
        ctrl.nextStep();
        ctrl.currentStep = 5; 
        ctrl.nextStep();
        ctrl.currentStep = 6; 
        ctrl.nextStep();
        
        ctrl.updatePIBenefitLevel();
        
        Test.stopTest(); 
    }
    
    @isTest
    static void testpreviousStep(){
        Test.startTest();
        generateData();
        ctrl.selectedProduct.Product_Code__c = '@SP100'; 
        ctrl.currentStep = 6; 
        ctrl.previousStep();
        ctrl.currentStep = 2; 
        ctrl.previousStep();
        ctrl.currentStep = 3; 
        ctrl.previousStep();
        ctrl.currentStep = 4; 
        ctrl.previousStep();
        
        Test.stopTest(); 
    }
    
    @isTest
    static void testSavePlanQuoteList(){
        Test.startTest();
        generateData();        
        TMEsalesHelper.PremiumAmt amt = new TMEsalesHelper.PremiumAmt();
        amt.premiumPerson = 'PI' + 1;
        amt.isRider = TRUE;
        amt.premiumDescription = 'SP100';
        amt.originalPremiumMonth = 2000;
        amt.annualPremium = 12000;
        amt.discountPercent = 10;
        amt.discountPremium = 1200;
        amt.totalDiscountPercent = 10;
        amt.totalDiscountPremium = 1200;
        amt.originalPremium = 12000;
        amt.loadingPremium = 0;
        amt.actualPremium = 12000;
        amt.policyId = ctrl.newPolicy.id;
        amt.benefitLevel = '1';        
        amt.productCode = 'SP100';
        ctrl.premiumAmountList.add(amt);
        
        HttpCalloutVO.Rider rider = new HttpCalloutVO.Rider();
        rider.riderName = 'SP100';
        rider.riderCode = 'SP100';
        rider.benefitLevelCode = '1';
        List<HttpCalloutVO.BenefitDetail> benefitDetaillist = new List<HttpCalloutVO.BenefitDetail>();
        HttpCalloutVO.BenefitDetail bd = new HttpCalloutVO.BenefitDetail();
        bd.description = 'SP100:XXXX';
        bd.amount = 100;
        benefitDetaillist.add(bd);
        rider.benefitDetailList = benefitDetaillist;
        ctrl.wsProduct.riderList.add(rider);        
        ctrl.savePlanQuoteList();
        
        amt.isRider = false;
        ctrl.mandatoryRiderCodesList = new List<String>();
        ctrl.mandatoryRiderCodesList.add('SP100');
        HttpCalloutVO.Benefit benefit = new HttpCalloutVO.Benefit();
        benefit.benefitLevelCode = '1';
        benefit.planCode = 'SP100';
        benefit.benefitDetailList = benefitDetaillist;
        ctrl.wsProduct.benefitList.add(benefit);
        TMCreatePolicyCtrl.PersonInsuredStructure pis = new TMCreatePolicyCtrl.PersonInsuredStructure();
        
        pis.displayParentPIId = false;
        pis.displaySpousePIId = false;
        pis.portableWardLevelFromWS = 'test';
        pis.portableWardLevelFromWSInt = 1;
        pis.isReplacement = false;
        pis.isCopyHolder = false;
        pis.iscopyHlderAddress = false;
        pis.isCopyCrspdAddress = false;
        pis.piPolicy = ctrl.newPolicy;
        pis.auwURL = 'test';
        pis.uwResultLastModifiedDate = 'test';
        pis.personalIDCache = 'test';
        Person_insured__c pi = new Person_insured__c();
        pi.Benefit_Level__c = '1';
        pis.pi = pi;
        ctrl.personInsuredStructureList.add(pis);
        ctrl.benefitMap = new Map<String,HttpCallOutVO.Benefit>();
        ctrl.benefitMap.put('1',benefit);
        ctrl.savePlanQuoteList();
        
        Test.stopTest(); 
    }
    @isTest
    static void testinitProductOutOfCam(){       
        Test.startTest();
        generateData();
        Map<Id, Product__c> proMap = new Map<Id, Product__c>();
        String productId = prod.id;
        System.debug('productId='+productId);
        //proMap.put(prod.id,prod);
        ctrl.initProductOutOfCam(proMap,productId);
        Test.stopTest();
    }
    
    @isTest
    static void testInitCurrentStep(){
        Test.startTest();
        generateData();       
        ctrl.presalesAccepted = false;
        ctrl.policyTransaction.Step__c = '5';
        ctrl.initCurrentStep();
        
        ctrl.productMap = null;
        ctrl.presalesAccepted = true;
        ctrl.initCurrentStep();
        
        ctrl.cam = null;
        ctrl.opp = null;
        ctrl.initCurrentStep();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testBackToPaymentStatus(){
        Test.startTest();
        generateData();        
        for(Product__c pro : ctrl.productMap.values()){
            if(null == pro.product_code__c )
                pro.product_code__c = '@SP100';
        }
        ctrl.backToPaymentStatus();
        Test.stopTest();        
    }
    
    @isTest
    static void tsetOnAmountOfPIChange(){
        Test.startTest();
        generateData();        
        ctrl.onAmountOfPIChange();
        Test.stopTest();        
        
    }
    
    private static TM_address__c tmAddress;
    static void generateTMAdress(){
        tmAddress = new TM_address__c(
            Building_Name__c = 'Building 001',
            Street_Name__c = 'Street 001',
            District__c = 'District 001'
        );
        
        insert tmAddress;
    }
    
    @isTest
    static void CDDTestMethod(){
        generateData();
        generateTMAdress();
        Test.startTest();
            List<SelectOption> jobList = ctrl.jobTitleList;
            ctrl.TMResidentialAddress = tmAddress.Id;
            ctrl.TMResidentialAddressChange();
            ctrl.TMCorrespondingAddress = tmAddress.Id;
            ctrl.TMCorrespondingAddressChange();
            ctrl.companyAddressLookUp = tmAddress.Id;
            ctrl.companyAddressChange();
            ctrl.newPolicy.Missing_CDD_Info__c = true;
            ctrl.onchangeMissingCDD();
            system.assert(jobList.size()==11);
        Test.stopTest();  
    }
	//Jack Shao 2020_08_18 TM Work From Home
    @isTest
    static void testmaskSensiData(){
        Test.startTest();
        generateData();
		//ctrl.createTestCase();        
        ctrl.maskSensiData();
        Test.stopTest();        
        
    }
    
    //Jack Shao 2020_08_18 TM Work From Home
    @isTest
    static void testDeMaskSensiData(){
        Test.startTest();
        generateData();

        // maskSensiData()
        ctrl.orgnDataBeforeMask.isMaskedPIPH = false;
        ctrl.newPolicy.Home_Phone__c = '12345678';
        ctrl.newPolicy.Mobile_Phone__c = '12345678';
        ctrl.newPolicy.Personal_ID__c = 'T2345678';
        ctrl.newPolicy.Residential_Address_1__c = '12345678';
        ctrl.newPolicy.Corresponding_Address_1__c = '12345678';

        ctrl.personInsuredStructureList[0].pi.Personal_ID__c = 'T2345678';
        ctrl.personInsuredStructureList[0].pi.Parent_PI_ID__c = 'T2345678';
        ctrl.personInsuredStructureList[0].pi.Spouse_PI_ID__c = 'T2345678';
        ctrl.personInsuredStructureList[0].pi.Residential_Address_1__c = 'test address';
        ctrl.personInsuredStructureList[0].beneficiaryList[0].beneficiary.Person_ID__c = 'T45234';

        ctrl.maskSensiData();
        ctrl.deMaskSensiData();

        ctrl.maskSensiData();
        ctrl.personInsuredStructureList[0].isCopyHolder = true;
        ctrl.orgnDataBeforeMask.PI_Parent_Personal_ID_Map_Ori.clear();
        ctrl.orgnDataBeforeMask.PI_Spouse_Personal_ID_Map_Ori.clear();
        ctrl.personInsuredStructureList[0].iscopyHlderAddress = true;
        ctrl.personInsuredStructureList[0].isCopyCrspdAddress = true;
        ctrl.personInsuredStructureList[0].pi.Residential_Address_1__c = ctrl.newPolicy.Residential_Address_1__c;
        ctrl.personInsuredStructureList[0].beneficiaryList[0].origPersonId = 'T2345678';
        ctrl.deMaskSensiData();


        //refreshPaymentInformation()
        ctrl.opportunityId = np.Id;
        ctrl.PolIdPolicyNoMap.put('CBOG'+ np.Id, np.Policy_No__c);
        ctrl.selectedPaymentType = 'Credit Card Billing';
        ctrl.refreshPaymentInformation();
        ctrl.selectedPaymentType = 'Direct Billing';
        ctrl.refreshPaymentInformation();
        Test.stopTest();        
        
    }
    
    @isTest
    static void testOnSelectedRefund(){
        generateData();
        ctrl.personInsuredStructureList[0].availableDiscountMap.put('Loyalty premium refund',true);
        ctrl.personInsuredStructureList[0].availableDiscountMap.put('Bundle premium refund',false);
        Test.startTest();
        ctrl.selectedRefund = 'Bundle premium refund';
        ctrl.onSelectedRefund();
        ctrl.selectedRefund = 'Loyalty premium refund';
        ctrl.onSelectedRefund();
        ctrl.selectedRefund = '';
        ctrl.onSelectedRefund();
        Test.stopTest();
    }
    @isTest
    static void testSupplement(){
        Test.startTest();
        generateData();
        generateTMAdress();
        System.debug(ctrl.SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE);
        System.debug(ctrl.SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE2);
        System.debug(ctrl.SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE3);
        System.debug(ctrl.policyId);
        System.debug( ctrl.tin1+ ctrl.tin2+ ctrl.tin3+ctrl.smokePIIndex);
        System.debug(ctrl.SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE);
        ctrl.piIndexOfRider = 2;
        ctrl.isSmoke = false;
        ctrl.selectedBenefitLevelCode = 'test';
        System.debug(ctrl.transField);
        System.debug(ctrl.DisplayNoRider);
		ApexCombinedCalloutHelperMock ResponseMock = new ApexCombinedCalloutHelperMock();
        Test.setMock(HttpcalloutMock.class,ResponseMock);
        String newPIName = 'test';
        ctrl.companyAddress = tmAddress.id;
        ctrl.companyAddressLookUp = tmAddress.id;
        ctrl.companyAddressChange();
        Beneficiary__c b = new Beneficiary__c();
        TMCreatePolicyCtrl.PersonInsuredStructure tmp = new TMCreatePolicyCtrl.PersonInsuredStructure();
        List<HttpCalloutVO.Policy> p;
       	tmp.parentIDPolicylist = p;
        TMCreatePolicyCtrl.BeneficiaryStruct tmb= new TMCreatePolicyCtrl.BeneficiaryStruct(newPIName, tmAddress.id, b);
        System.debug('[TMCreatePolicyCtrlTest] testPicklistInitilize().ctrl.productMap='+ctrl.productMap);
        System.debug('[TMCreatePolicyCtrlTest] testPicklistInitilize().ctrl.newPolicy.Product__c='+ctrl.newPolicy.Product__c);
        System.debug('[TMCreatePolicyCtrlTest] testPicklistInitilize().ctrl.selectedProduct='+ctrl.selectedProduct);
        ctrl.selectedProduct.Product_Code__c = 'CBOG';
        ctrl.personInsuredStructureList[0].pi.Rider__c = '';
        TMCreatePolicyCtrl.Rider tmr = new TMCreatePolicyCtrl.Rider('test');
        ctrl.detectCorAddressChange();
        ctrl.initPolIdPolicyNoMap();
        ctrl.personInsuredStructureList[0].piPolicy.Policy_No__c = null;
        ctrl.validateInfoIntegrity();
        ctrl.personInsuredStructureList[0].piPolicy.Application_Id__c = 'app';
        ctrl.personInsuredStructureList[0].piPolicy.to_Save_Policy_No__c = 'test';
        ctrl.validateInfoIntegrity();
        //ctrl.showBMIforSpecialProduct();
        Test.stopTest(); 
    }
    // friend discount
    @isTest
    static void testFriendDiscount(){
        ApexCalloutHelperMock testMock=new ApexCalloutHelperMock();
        testMock.BodyName('GetPolicyListBasicByCriteria_ResponseMock3');
        Test.setMock(HttpCalloutMock.class,testMock);
        generateData();
        ctrl.initCustomSettingData();
        
        Test.startTest();
        TMCreatePolicyCtrl.PersonInsuredStructure pis1 = new TMCreatePolicyCtrl.PersonInsuredStructure();
        pis1.pi = new Person_Insured__c(Insured_First_Name__c = 'fisrtname',Insured_Last_Name__c = 'lastname');
        pis1.piPolicy = new New_Policy__c();
        ctrl.personInsuredStructureList.add(pis1);
        ctrl.selectedDiscount1='FAMILY POLICY DISCOUNT (2 PAX)';
        ctrl.initFamilyDiscountPannel(false);
        ctrl.initFamilyDiscountPannel(true);
        ctrl.selectedDiscount1='EARLY BIRD';
        ctrl.selectedDiscount2='EARLY BIRD';
        ctrl.initFamilyDiscountPannel(true);
        ctrl.referralMobile='12345678';
        ctrl.referralPolicyNum='TEST00001';
        ctrl.searchWithMobileNo();
        Test.stopTest();
    }
}