/********************************************************************************
 * Apex Class Name - TMCreatePolicyCtrl
 * Created Date - Mar 23,2018
 * @description Policy Creation
 * Modification Log : T
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken,Franco     11/10/2018              Revise Version
 ********************************************************************************/
global class TMCreatePolicyCtrl {  
    public static final Integer DISPLAY_COMPLETED_MESSAGE=-1;
    public static final Integer NO_PERMISSION=0;
    public static final Integer STEP_POLICY_INFORMATION=1;
    public static final Integer STEP_PHPI_INFORMATION=2;
    public static final Integer STEP_BENEFICIARY_INFORMATION=3;
    public static final Integer STEP_UW_INFORMATION=4;
    public static final Integer STEP_UW_INFORMATION_2=5;
    public static final Integer STEP_CONFIRMATION_PAYMENT=6;
    public static final Integer IS_COMPLETED=7;
    
    public static final String NULL_APPEAL='nullAppeal';
    public static final String APPEAL_YES='Appeal';
    public static final String APPEAL_NO='Accept';
    public static final String APPEAL_WITHDRAWN='Withdrawn';   
    public static final String PRESALES_UW_RESULT_ACCEPTED='Accepted';
    public static final String PRESALES_UW_RESULT_REFERRED='Referred';
    public static final String PRESALES_UW_RESULT_DECLINED='Declined';
    public static final String PRESALES_UW_RESULT_WITHDRAWN='Withdrawn';//add by andy for DPSP-608 policy withdrawn function    
    public static final String PAYMENTTYPE_CREDIT='Credit_Card';
    public static final String PAYMENTTYPE_BANK='Bank';
    
    public static final String POLICY_IQ_ID='11154662';//dafult policy IQID 11154662
    public static final String SPECIAL_RIDER_PRODUCTCODE='DMBG;@DMBG;SP100;@SP100';
    public String SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE{get{
        return SPECIAL_RIDER_PRODUCTCODE;
    }set;}    
    //20201113 Combo add CBOD;@CBOG code
    public static final String SPECIAL_RIDER_PRODUCTCODE2='CBOG;@CBOG;PBTG;@PBTG;@KIDSG;KIDSG;@KIDSL;KIDSL;@ABAG;@ABEG;ABWG';//jack add for AM project Bespoke product
    public String SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE2{get{
        return SPECIAL_RIDER_PRODUCTCODE2;
    }set;}    
    // Combo:it can select every rider for combo prodcut but only has an dummy benefity level for selecting.
    // this product has not plan level and different offer code with rider product
    public static final String SPECIAL_RIDER_PRODUCTCODE3='CBOG;@CBOG';
    public String SPECIAL_RIDER_PRODUCTCODE_FOR_PAGE3{get{
        return SPECIAL_RIDER_PRODUCTCODE3;
    }set;}
    public String wsErrorMsg='A Web Service error has occurred,please contact your system administrator for assistance.';
    public String discountErrorMsg{get;set;}     
    public Id policyTxnId{get;set;}
    public Id policyId{get;set;}
    public Id opportunityId{get;set;}
    public Id accountId{get;set;}
    public Id campaignId{get;set;}
    global String applicationId{get;set;} {applicationId='';}
    
    public Integer currentStep{get;set;} {currentStep=NO_PERMISSION;}
    public Policy_Transaction__c policyTransaction{get;set;}
    public Opportunity opp{get;set;}
    public Campaign cam{get;set;}
    public Account acc{get;set;}
    public New_Policy__c newPolicy{get;set;} {newPolicy=new New_Policy__c();}
    public Integer amountOfPI{get;set;} {amountOfPI=1;}
    public List<New_Policy__c> policyList{get;set;} {policyList=new List<New_Policy__c>();}
    public List<New_Policy__c> deletePolicyList{get;set;} {deletePolicyList=new List<New_Policy__c>();}    
    public List<PersonInsuredStructure> personInsuredStructureList{get;set;} {personInsuredStructureList=new List<PersonInsuredStructure>();}
    public List<Person_insured__c> deletePersonInsuredList{get;set;} {deletePersonInsuredList=new List<Person_insured__c>();}
    public Set<String> uwPISSet{get;set;}{uwPISSet=new Set<String>();}
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs{get;set;}
    public Set<String> prePISSet{get;set;}{prePISSet=new Set<String>();}
    public List<PersonInsuredStructure> uwPISListForDisplay{get;set;}{uwPISListForDisplay=new List<PersonInsuredStructure>();}
    public Map<String,Campaign> productIdCampaignMap;{productIdCampaignMap=new Map<String,Campaign>();}/* add by Jack on 2022-01-11 for project: Discount enhancement */
    public String defaultMasterPolicyNum{get;set;}{defaultMasterPolicyNum=null;}
    public PolicyCalloutHelper policyCalloutHelper{get;set;}{policyCalloutHelper=new PolicyCalloutHelper();}
    public List<HttpCalloutVO.Policy> PHPersonalIDPolicylist{get;set;}{PHPersonalIDPolicylist=new List<HttpCalloutVO.Policy>();}
    public String pageMsg{get;set;}{pageMsg='';}
    public Map<String,Map<String,Set<String>>> riderCodeBenefitLevelListMap{get;set;}{riderCodeBenefitLevelListMap=new Map<String,Map<String,Set<String>>>();}
    
    public String tin1{get;set;}
    public String tin2{get;set;}
    public String tin3{get;set;}    
    public Integer piIndex{get;set;}
    public Integer PINoOfStep3{get;set;}  
    public String smokePIIndex{get;set;}
    public Integer piIndexOfRider{get;set;}    
    //Flag related
    public Boolean isAllowToRead{get;set;}
    public boolean isSmoke{get;set;}
    public Integer isShow{get{return (null!=selectedProduct && selectedProduct.Is_Life__c==true)?1:0;}set;}
    public Integer isShowCRSField{get{return (null!=selectedProduct && selectedProduct.CRS_Indicator__c==true)?1:0;}set;}
    public boolean isShowStep4Page{get;set;}{isShowStep4Page=false;}
    public boolean isPIChange{get;set;}{isPIChange=false;}
    public Boolean isAUWcompleted{get;set;} {isAUWcompleted=true;}
    public Integer isExists{get;set;}{isExists=0;}
    public Integer isDiscountInitialize{get;set;}{isDiscountInitialize=0;}
    public Boolean isComplete{get;set;}{isComplete=false;}
    public Boolean isSubmitted{get;set;}{isSubmitted=false;}
    public Boolean isGAChannel{get;set;}
    public Boolean isGAProduct{get;set;}{isGAProduct=false;}
    public Boolean presalesAccepted{get;set;}{presalesAccepted=false;}
    public Boolean uwResultAccepted{get;set;}{uwResultAccepted=true;}
    public Boolean callPreSalesOnPage{get;set;}{callPreSalesOnPage=false;}
    public Boolean displayOptionalField{get;set;}{displayOptionalField=false;}
    public Boolean displayCreditCardOptionalField{get;set;}{displayCreditCardOptionalField=false;}
    public Boolean displayCompanyPosition{get;set;}{displayCompanyPosition=true;}
    public boolean isWSError{get;set;}{isWSError=false;}
    public boolean canSave{get;set;}
    public Boolean isStep2ValidationCalled{get;set;}{isStep2ValidationCalled=false;}
    public Boolean isPaymentButtonClicked{get;set;}{isPaymentButtonClicked=false;}
    
    //selectOption related
    public List<business_nature__c> businessNatureList{get;set;}
    public List<Country_List_Settings__c> countryList{get;set;}   
    public String countryListJson{get;set;}
    public String businessNatureJson{get;set;}
    public Product__c selectedProduct{get;set;}
    public Map<Id,Product__c> productMap{get;set;} {productMap=new Map<Id,Product__c>();}
    public Map<Id,List<Premium_Discount__c>> productIdPremiumDiscountMap{get;set;}
    public Product__c productWithOutOfCamPro{get;set;}
    public List<SelectOption> productOptions{get;set;} {productOptions=new List<SelectOption>();}    
    // benefit level and riders related
    public List<SelectOption> benefitLevelOption{get;set;}
    /**
    public List<SelectOption> benefitLevelOptionForRider{get{
        List<SelectOption> tmp=new List<SelectOption>();
        tmp.add(new SelectOption('','-None-'));
        tmp.addAll(benefitLevelOption);
        return tmp;
    }set;}
    **/
    public Map<String,HttpCalloutVO.Benefit> benefitMap{get;set;} {benefitMap=new Map<String,HttpCalloutVO.Benefit>();}
    public String selectedBenefitLevelCode{get;set;}
    // init by GetPlanInfoListBasic
    public HttpCalloutVO.Product WSProduct{get;set;} {WSProduct=new HttpCalloutVO.Product();}
    public Map<String,List<HttpCalloutVO.Rider>> riderMap{get;set;}
    public List<String> mandatoryRiderCodesList {get;set;} {mandatoryRiderCodesList=new List<String>();}
    
    // Discounts and payment related
    public List<SelectOption> discount12Options{get;set;}
    public String selectedDiscount1{get;set;}
    public String selectedDiscount2{get;set;}        
    public List<SelectOption> paymentFrequencyOptions{get;set;}
    public String selectedPaymentFrequency{get;set;}
    public List<SelectOption> paymentTypeOptions{get;set;}
    public String selectedPaymentType{get;set;}
    public List<SelectOption> bankOptions{get;set;}
    public String selectedBank{get;set;}
    public List<SelectOption> creditCardTypeOptions{get;set;}
    public String selectedCreditCardBank{get;set;}
    public String selectedPINoBNNum{get;set;}
    public List<SelectOption> amountOfPIOptions{get;set;}
    public String selectedCardYear{get;set;}
    public String selectedCardMonth{get;set;}
    public String selectedBusinessNature{get;set;}
    public Map<String,Premium_Discount__c> premiumDiscountMap{get;set;}{premiumDiscountMap=new Map<String,Premium_Discount__c>();} 
    public Map<String,Decimal> paymentFrequencyDiscountMap{get;set;}{paymentFrequencyDiscountMap=new Map<String,Decimal>();} 
    
    public String auwUrl{get;set;}
    public String piName{get;set;}
    public Integer auwPIindex{get;set;} {auwPIindex=0;}
    public Integer uwPISIndex{get;set;} {uwPISIndex=0;}
    public String lastModifiedDate {get;set;}    
    //get quote premium related
    public List<TMEsalesHelper.PremiumAmt> premiumAmountList {get;set;} {premiumAmountList=new List<TMEsalesHelper.PremiumAmt>();}
    public List<Plan_Quote__c> planQuoteList {get;set;}{planQuoteList=new List<Plan_Quote__c>();}
    public Map<String,String> basicPlancodeMap {get;set;}
    public TMEsalesHelper.PremiumAmt totalPremium {get;set;}
    public Integer showDiscountErrorMsg {get;set;}{showDiscountErrorMsg=0;}
     //add from hao Li for TM address
    public String TMResidentialAddress{get;set;}
    public String TMCorrespondingAddress{get;set;}
    //end    
    //Nicole_20200407_CDD
    public String companyAddress{get;set;}
    public String companyAddressLookUp{get;set;}
    public Boolean isOtherJobEnable{get;set;}{isOtherJobEnable=false;}
    public Boolean isIndustryEnable{get;set;}{isIndustryEnable=false;}
    public List<SelectOption> jobTitleList {
        get{
            List<SelectOption> jobList=new List<SelectOption>();
            jobList.add(new SelectOption('','--None--'));
            jobList.add(new SelectOption('Business owner / director with controlling power','企業所有者 / 有控制權的董事 - Business owner / director with controlling power'));
            jobList.add(new SelectOption('Managers and administrators','經理及行政級人員 - Managers and administrators'));
            jobList.add(new SelectOption('Professionals','專業人員 - Professionals'));
            jobList.add(new SelectOption('Associate professionals','輔助專業人員 - Associate professionals'));
            jobList.add(new SelectOption('Clerical support workers','文書支援人員 - Clerical support workers'));
            jobList.add(new SelectOption('Service and sales workers','服務工作及銷售人員 - Service and sales workers'));
            jobList.add(new SelectOption('Craft and related workers','工藝及有關人員 - Craft and related workers'));
            jobList.add(new SelectOption('Plant and machine operators and assemblers','機台及機器操作員及裝配員 - Plant and machine operators and assemblers'));
            jobList.add(new SelectOption('Elementary occupations','非技術工人 - Elementary occupations'));
            jobList.add(new SelectOption('Others','其他 - Others'));
            return jobList;
        }set;
    }
    
    public User currentUser{
        get{
          User currentUser=[select id,Name,ProfileId,UserRoleId,UserName,User_Type__c,Work_From_Home__c,userrole.developername from User where id=: Userinfo.getUserId()];
          return currentUser ; 
        }set;          
    }
    
    public boolean showEditCreditCardNumber {get;set;} {showEditCreditCardNumber=false;}//to show input field for / credit card no.
    public boolean showEditBankNumber {get;set;} {showEditBankNumber=false;}//to show input field for / bank acc no.   
    public String removePolicyNumber {get;set;}  //add by andy for remove invalid PI function
    public String cancelRemovePolicyNumber {get;set;} //remove invalid PI function    
    public Map<String,Map<String,TMEsalesHelper.Portalproduct>> planLevelProductMap {get;set;}    
    //TM Work From Home_20200827
    public Boolean wortAtHome {get;set;}    
    //WEI-296
    public static Map<String,String> hex2DecMap=new Map<String,String>{'A'=>'10','B'=>'11','C'=>'12','D'=>'13','E'=>'14','F'=>'15','G'=>'16','H'=>'17'};//jack add for Elite Revamp 32            
    public static Map<String,String> dec2HexMap=new Map<String,String>{'10'=>'A','11'=>'B','12'=>'C','13'=>'D','14'=>'E','15'=>'F','16'=>'G','17'=>'H'};//jack add for Elite Revamp 32
    //WEI-296
    
    //SPS-237
    public String productCodeInd='';
    public Map<String,Boolean> productNeedBMIMap=new Map<String,Boolean>();
    public List<GA_Product_Validation_Checking__c> GAProductValidationList=new List<GA_Product_Validation_Checking__c>();
    //SPS-237   
    //This map will be initialize after initPersonInsuredInfo()
    //@Key:Product Code+Policy Id
    //@Value:Policy Number
    public Map<String,String> PolIdPolicyNoMap=new Map<String,String>();
    //Indicate is the first time of policy initialization
    Boolean initIndicator=true;
    
    // 20200427 - minghua - PolicyReplacement
    public Boolean showPolicyReplacement {get;set;}
    public Set<String> productCodeSet=new Set<String>();
    public Map<String,Map<String,String>> transField {
        get{
            if (transField==null){
                transField=new Map<String,Map<String,String>>();
                for(Translate__mdt t : [select DeveloperName,zh_TW__c,en_US__c from Translate__mdt where Category__c='PolicyReplacement']){
                    transField.put(t.DeveloperName,new Map<String,String>{'zh_TW'=>t.zh_TW__c,'en_US'=>t.en_US__c });           
                } 
            }
            return transField ;
        }set;
    }
    
    private ID productBeforeChange;//SPS-449   
    public Integer tabIndex{get;set;}
    //TM work at Home
    public OriginalData orgnDataBeforeMask {get;set;}    
    public Map<String,Product__c> productCodeProductMap=new Map<String,Product__c>();  
    //Wellness
    public String DisplayNoRider {
        get{
            List<String> productCodes=new List<String>();
            Map<String,Policy_Validation_Checking__c> pvcMap=Policy_Validation_Checking__c.getAll();
            for(String s : pvcMap.keySet()){
                if(pvcMap.get(s).Display_Rider__c=='N')
                    productCodes.add(s);
            }
            return String.join(productCodes,',');
        }set;
    }
    
    public String availableRider {get;set;}//GL31 jack add
    public List<SelectOption> refundOptions {get;set;}
    public String selectedRefund{get;set;}
    public String refundErrorMessage{get;set;}
    public Map<String,Premium_Discount__c> premiumRefundMap=new Map<String,Premium_Discount__c>();
    public Integer showRefundErrorMessage{get;set;}{showRefundErrorMessage=0;}
    public List<HttpCalloutVO.Policy> holderPolicyList=new List<HttpCalloutVO.Policy>();
    public String GAList {get;set;}//add by jack for policy replacement    
    // public Map<String,Boolean> firstYDisEliMap {get;set;}//Nicole_Elite Revamp_20210319 Rancho_AH24240_20220224
    //JR1817 - End

    //GL31 Tovid add --start
    public final static String NO_SUCH_PRODUCT = 'N/A';
    List<TM_Product_Category__c> tmProcatList;
    List<Assessment_Questions_Product_Mapping__c> mappingList;
    //GL31 Tovid add --end

    //AM project coupon jack add
    public Map<String,TMCreatePolicyCtrl.PersonInsuredStructure> pisMap;
    public Boolean enableCoupon{get;set;}
    public Boolean isCXagent{get;private set;}/* add by Jack on 2022-10-12 for project: JOBR-217 Enhance Asiamiles membership info validation */
    //public String couponMsg{get;set;}{couponMsg='';}

    // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
    public String currentPolicyNo{get;set;}
    
    /* add by Jack on 2022-02-24 for project: Discount enhancement*/
    // String holderSSN;
    // public List<HttpCalloutVO.Policy> holderPolicyList{
    //     get{
    //         if((holderSSN!=null && !holderSSN.equalsIgnoreCase(newPolicy.Personal_ID__c)) || holderSSN==null){
    //             if(orgnDataBeforeMask.workAtHome){
    //                 deMaskSensiData();
    //             }
    //             holderSSN=newPolicy.Personal_ID__c;
    //             holderPolicyList=policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', newPolicy.Personal_ID__c);
    //             if(orgnDataBeforeMask.workAtHome){
    //                 maskSensiData();
    //             }
    //             return holderPolicyList;
    //         }else{
    //             return holderPolicyList;
    //         }
    //     }
    //     set;
    // }
    /**
   * @description The Construction of TMCreatePolicyCtrl
   * @param ApexPages.StandardController controller
   */
    public TMCreatePolicyCtrl(ApexPages.StandardController controller){
        init();
        Policy_Transaction__c policyTran=(Policy_Transaction__c) controller.getRecord();
        System.debug('[TMCreatePolicyCtrl] TMCreatePolicyCtrl().policyTransaction='+policyTran);
        ////System.debug('[TMCreatePolicyCtrl] TMCreatePolicyCtrl().isSkipStep3='+isSkipStep3);
        if(policyTran!=null){
            if(policyTran.Id!=null){
                // existing record
                policyTxnId=policyTran.Id;
                initPolicyTransaction(policyTxnId);
                initOpportunity(policyTransaction.Opportunity__c);
                initCampaign(campaignId);
                initPolicy(policyTxnId);
                initPersonInsuredInfo(policyList);
                initAccount(accountId);
                initPolIdPolicyNoMap();//Add by Kermit at 20191216
                ////System.debug('[TMCreatePolicyCtrl] TMCreatePolicyCtrl().PolIdPolicyNoMap='+this.PolIdPolicyNoMap);
                //System.debug('[TMCreatePolicyCtrl] TMCreatePolicyCtrl().personInsuredStructureList.size()'+personInsuredStructureList.size());
            }else if(policyTran.Opportunity__c!=null){
                // new record
                initOpportunity(policyTran.Opportunity__c);
                initAccount(accountId);
                initCampaign(campaignId);
                initPolicyTransaction();
                initPolicy();
                initPersonInsuredInfo();
            }                      
            initCurrentStep();
            if(this.currentStep>=6){
                for(PersonInsuredStructure pis : personInsuredStructureList){
                    pis.pi.Benefit_Level__c=dec2HexMap.get(pis.pi.Benefit_Level__c)==null? 
                    pis.pi.Benefit_Level__c:dec2HexMap.get(pis.pi.Benefit_Level__c);
                }
            }
            initPolicyTransactionValidationStruct();  
            //GL31 Tovid add --start
            if(policyTransaction != null && policyTransaction.Objectives_Question__c == null && policyTransaction.Which_type_s_of_medical_insurance__c == null){
                policyTransaction.Objectives_Question__c = opp.Objectives_Question__c;
                policyTransaction.Which_type_s_of_medical_insurance__c = opp.Which_type_s_of_medical_insurance__c; 
                policyTransaction.Available_Product_Code_For_Assessment__c = opp.Available_Product_Code_For_Assessment__c; 
                policyTransaction.Available_Product_Name_For_Assessment__c = opp.Available_Product_Name_For_Assessment__c;
                policyTransaction.Prod_Rider_Map__c = opp.Prod_Rider_Map__c;  
            }  
            // tmProcatList=TM_Product_Category__c.getAll().values();//jack add for friend and family discount in SFDC
            // mappingList=Assessment_Questions_Product_Mapping__c.getAll().values();//jack add for friend and family discount in SFDC
            //GL31 Tovid add --end
                      
        }
        
        // 20200427 - minghua - PolicyReplacement
        showPolicyReplacement=false;
        System.debug('newPolicy:'+newPolicy);
        if (newPolicy!=null){
            String productCod=newPolicy.Product_Code__c;
            ////System.debug('productCode:'+productCod);
            Custom_Value__c productSetting=Custom_Value__c.getValues('Replacement_Product');
            if(productSetting!=null && productSetting.Value__c!=null){
                for(String productCode : productSetting.Value__c.split(',')){
                    productCodeSet.add(productCode);
                }   
            }
            //System.debug('TMCreatePolicyCtrl productCodeSet'+productCodeSet);
            //if (String.isNotBlank(productCod) && (productCod=='ROP' || productCod=='KIDs' || productCod=='SLP')){
            if (String.isNotBlank(productCod) && productCodeSet.contains(productCod)){
                showPolicyReplacement=true;
            }
            ////System.debug('TMCreatePolicyCtrl showPolicyReplacement:'+showPolicyReplacement+'policyTransaction.PolicyReplacement__c'+policyTransaction.PolicyReplacement__c);
        }
        // if(currentStep==STEP_PHPI_INFORMATION){
        //     //initAssessRider(this.opp.Prod_Rider_Map__c,this.selectedProduct.Product_Code__c,this);//GL31 jack add
        //     initAssessRider();//GL31 Tovid add
        // }
    }
    
    /**    
    * @param         
    * @return         
    * @author Ken    
    * @Time 2018-10-12 15:02:29    
    */
    public void init(){
        //TMLeader is only allowed to view the standard page of policy 
        isAllowToRead=(CignaUtil.isTMLeader(UserInfo.getUserId()) || currentUser.userrole.developername=='TM_Back_Office' || currentUser.userrole.developername=='QE_User');        
         //TM Work From Home_20200827
        wortAtHome=currentUser.Work_From_Home__c;        
        businessNatureList=[select Aml_Highrisk__c,Business_Nature_Chinese__c,Business_Nature_English__c,Business_Nature_Code__c,Description__c from business_nature__c ];
        businessNatureJson=JSON.serialize(businessNatureList);        
        countryList=[select name,Crs_Ind__c,Aml_Highrisk__c from Country_List_Settings__c ];
        countryListJson=JSON.serialize(countryList);

        GAList='@SP100,@PBTG,';//add by jack for policy replacement
        //SPS-237
        for(Policy_Validation_Checking__c pvc : [SELECT UW_Requirement__c,Product_Code__c,AUW__c,BMI__c FROM Policy_Validation_Checking__c]){
            if((pvc.AUW__c=='R' || pvc.AUW__c=='Y') && pvc.BMI__c=='N'){
                productNeedBMIMap.put(pvc.Product_Code__c,true);
            }else{
                productNeedBMIMap.put(pvc.Product_Code__c,false);
            }
            //add by jack for policy replacement
            if(pvc.UW_Requirement__c=='GA'){
                GAList=GAList+pvc.Product_Code__c+',';}
            //System.debug('GAList:'+GAList);
        }
        
        GAProductValidationList=[SELECT Name,Post_Duplication_Checking__c,AUW__c,Channel__c,Insured_Type__c,Side_Order__c,UW_Requirement__c FROM GA_Product_Validation_Checking__c];
        //SPS-237        
        tabIndex=1;
        // TM Work at Home
        orgnDataBeforeMask=new OriginalData();
        if(currentUser.Work_From_Home__c){
            orgnDataBeforeMask.workAtHome=true;
        }else{
            orgnDataBeforeMask.workAtHome=false;
        }   
        initCustomSettingData();//jack add for friend and family discount in SFDC 
    }
    
    /** 
    * @Title: initOpportunity
    * @Description: initialize Opportunity
    * @param Id oppId
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initOpportunity(Id oppId){
        this.opp=[select id,Name,Accountid,Campaign__c,Is_Success__c,RecordType.DeveloperName,Source_of_Activity__c,Is_Side_Order__c,Reference3__c,Reference5__c,Reference2__c,Reference4__c,Running_No__c,IQ_ID__c,OwnerId,Product_1__c,Quote_Product1__c,Is_GA__c,Available_Product_Code_For_Assessment__c,Prod_Rider_Map__c,Objectives_Question__c,  Which_type_s_of_medical_insurance__c,Available_Product_Name_For_Assessment__c,Assessment_Question_1__c,Assessment_Questoin_2__c,Asia_Miles_Membership_First_Name__c,Asia_Miles_Membership_Last_Name__c,Asia_Miles_Membership_Num__c   from Opportunity where id=:oppId];//GL31 jack add//AM project AM info enhancement jack add
        this.opportunityId=this.opp.Id;
        this.campaignId=this.opp.Campaign__c;
        this.accountId=this.opp.Accountid;
    }
    
    /** 
    * @Title: initAccount
    * @Description: initialize account
    * @param Id accountId
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initAccount(Id accountId){
        // 20200717 - minghua - SF Modeling
        this.acc = [select firstName,lastName,Chinese_Name__c,Gender__c,Nationality__c,PersonBirthdate__c,PersonHomePhone,PersonMobilePhone,Office_Phone__c,PersonEmail,Home_Address_Line_1__c,Home_Address_Line_2__c,Home_Address_Line_3__c,Home_Address_Line_4__c,Company__c,Position__c,SSN__c,Email__c, Credit_Card_No_BackEnd__c,Credit_Card_No__c,Call_List_Address_Line_1__c,Call_List_Address_Line_2__c,Call_List_Address_Line_3__c,Call_List_Address_Line_4__c,Maturity_Policy_Number__c, LHB_certificate_number__c, LHB_policy_number__c, recordType.developerName,Prospect_reference1__c, Reference2__pc, Reference3__pc, Reference4__pc, Reference5__pc,Bank_Account_No__c, Bank_Account_No_BackEnd__c from account where id = :accountId];
        //AH19572 adjust gender
        if(String.isNotBlank(this.acc.Gender__c)){
            this.acc.Gender__c=adjustGender(this.acc.Gender__c);
        }
    }

    /** 
    * @Title: TMResidentialAddressChange
    * @Description: auto fill Building Name and Street Name
    * @param 
    * @return 
    * @author Hao Li
    * @date 2019-10-14 15:02:29 
    */ 
    public void TMResidentialAddressChange(){
        ////System.debug('[TMCreatePolicy] TMResidentialAddressChange'+TMResidentialAddress);
         if(TMResidentialAddress!=null){
            newPolicy.TM_Residential_Address__c=TMResidentialAddress;
            TM_address__c tmAddress=[select id,Name,Building_Name__c,Street_Name__c,District__c,Region__c from TM_address__c where id=:newPolicy.TM_Residential_Address__c];
            newPolicy.Residential_Address_2__c=tmAddress.Building_Name__c;
            newPolicy.Residential_Address_3__c=tmAddress.Street_Name__c;
            newPolicy.Residential_Address_4__c=tmAddress.District__c==null?(tmAddress.Region__c==NULL? '':tmAddress.Region__c):(tmAddress.Region__c==NULL? tmAddress.District__c :tmAddress.District__c+','+tmAddress.Region__c);
        }
    }


    /** 
    * @Title: autoPopulateAvailableProduct
    * @Description: auto Populate vailableProduct for policytransaction
    * @param 
    * @return 
    * @author Tovid Chen
    * @date 2021-05-20 14:02:29 
    */ 
    public void autoPopulateAvailableProduct(){
        //Opportunity sOpp=[select id,Name,Accountid,Campaign__c,Is_Success__c,RecordType.DeveloperName,Source_of_Activity__c,Is_Side_Order__c,Reference3__c,Reference5__c,Reference2__c,Reference4__c,Running_No__c,IQ_ID__c,OwnerId,Product_1__c,Quote_Product1__c,Is_GA__c,Available_Product_Code_For_Assessment__c,Prod_Rider_Map__c,Objectives_Question__c,  Which_type_s_of_medical_insurance__c,Available_Product_Name_For_Assessment__c from Opportunity where id=:policyTransaction.Opportunity__c];//GL31 jack add
        
        // List<Assessment_Questions_Product_Mapping__c> mappingList = Assessment_Questions_Product_Mapping__c.getAll().values();
        //if(policyTransaction.Objectives_Question__c != this.opp.Objectives_Question__c || policyTransaction.Which_type_s_of_medical_insurance__c != this.opp.Which_type_s_of_medical_insurance__c){
        if(String.isNotBlank(policyTransaction.Objectives_Question__c) && String.isNotBlank(policyTransaction.Which_type_s_of_medical_insurance__c)){
            Map<String,Set<String>> prodRiderMap = CignaUtil.getAvailableProductScope(mappingList,policyTransaction.Objectives_Question__c,policyTransaction.Which_type_s_of_medical_insurance__c);
            policyTransaction.Prod_Rider_Map__c = JSON.serialize(prodRiderMap);
            //List<TM_Product_Category__c> tmProList = TM_Product_Category__c.getAll().values();
            policyTransaction.Available_Product_Code_For_Assessment__c =  CignaUtil.getTMProductCode(tmProcatList, prodRiderMap);
            List<String> productCodeList = policyTransaction.Available_Product_Code_For_Assessment__c.split(',');
                List<Product__c> pList = [Select Name from Product__c where product_code__c in :productCodeList and recordType.DeveloperName ='TM_Product'];
                String availProdName = '';
                for (Product__c pro : pList) {
                    System.debug('pro.name'+pro.name);
                    availProdName = availProdName + pro.Name + '\n';
                }
                Set<String> riderNameSet= TMPolicyUtil.getRiderNameForAssessment(prodRiderMap);
                if(riderNameSet.size()>0){
                    availProdName = availProdName + '\n' + 'Rider part:' + '\n';
                    for (String rider : riderNameSet) {
                        availProdName = availProdName + rider + '\n';
                    }
                }
                if (availProdName.endsWith('\n')) {
                    availProdName = availProdName.substringBeforeLast('\n');
                }
                if(String.isEmpty(availProdName)){
                    availProdName = NO_SUCH_PRODUCT;
                }
                policyTransaction.Available_Product_Name_For_Assessment__c = availProdName;
        }else{
            policyTransaction.Available_Product_Code_For_Assessment__c = '';
            policyTransaction.Prod_Rider_Map__c = '';
            policyTransaction.Available_Product_Name_For_Assessment__c = '';
        }
        //}
        //initAssessRider();//GL31 Tovid add
        
    }


   /** 
    * @Title: TMCorrespondingAddressChange
    * @Description: auto fill Building Name and Street Name
    * @param 
    * @return 
    * @author Hao Li
    * @date 2019-10-14 15:02:29 
    */ 

    public void TMCorrespondingAddressChange(){
         if(TMCorrespondingAddress!=null){
            newPolicy.TM_Corresponding_address__c=TMCorrespondingAddress;
            TM_address__c tmAddress=[select id,Name,Building_Name__c,Street_Name__c,District__c,Region__c from TM_address__c where id=:newPolicy.TM_Corresponding_address__c];
            newPolicy.Corresponding_Address_2__c=tmAddress.Building_Name__c;
            newPolicy.Corresponding_Address_3__c=tmAddress.Street_Name__c;
            newPolicy.Corresponding_Address_4__c=tmAddress.District__c==null?(tmAddress.Region__c==NULL? '':tmAddress.Region__c):(tmAddress.Region__c==NULL? tmAddress.District__c :tmAddress.District__c+','+tmAddress.Region__c);
        }
    }
    
    //Nicole_20200407_CDD
    public void companyAddressChange(){
         if(companyAddress!=null){
            companyAddress=companyAddressLookUp;
            newPolicy.Company_Address__c=companyAddressLookUp;          
            TM_address__c tmAddress=[select id,Name,Building_Name__c,Street_Name__c,District__c,Region__c from TM_address__c where id=:newPolicy.Company_Address__c ];
            newPolicy.Company_Address_1__c=tmAddress.Building_Name__c;
            newPolicy.Company_Address_2__c=tmAddress.Street_Name__c;
            newPolicy.Company_Address_3__c=tmAddress.District__c;
            newPolicy.Company_Address_4__c=tmAddress.Region__c;
        }
    }
    
    public void onJobTitleChange(){
        isOtherJobEnable=false;
        if(String.IsNotBlank(newPolicy.Position__c) && newPolicy.Position__c=='其他 - Others'){
            isOtherJobEnable=true;
        }
    }
    
    public void onBusinessNatureChange(){
        isIndustryEnable=false;
        if(String.IsNotBlank(newPolicy.Business_Nature__c) && newPolicy.Business_Nature__c=='以上皆否 - None of the above'){
            isIndustryEnable=true;
        }
    }
    
    /** 
    * @Title: initCampaign
    * @Description: initialize campaign
    * @param Id campId
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */     
    public void initCampaign(Id campId){
        cam=[select id,Core_Product__c,Status,IPAS_Campaign_Code__c,Bank__c,Payment_Method__c,BF_Annual__c,BF_Month__c,BF_Quater__c,BF_Semi_Annual__c,BF_Single__c,Channel__c,Expiry_Date__c,Channel__r.Is_GA_Channel__c,Credit_Card__c,Campaign_Type__c,Channel__r.Channel_Code__c,Select_All_Bank__c,Campaign_Type__r.Name,Name,Campaign_Code__c,Batch_No__c,(select id,Alt_Campaign__r.Core_Product__c,Alt_Campaign__c from Core_Campaign_Alter_Campaign__r),(select id,name,Campaign__c,Discount__c,Discount_Type__c,Duration__c,Lapse_Surrender_Policy_Checking__c,Mandatory__c from Premium_Discounts__r WHERE RecordType.DeveloperName!='Premium_Refund'),Business_Partner__r.Sponsor_Code__c,Is_GA__c from Campaign where id=:campId];//AM project coupon jack add/* add by Jack on 2022-01-11 for project: Discount Enhancement */       
        isGAChannel=(cam.Channel__r.Is_GA_Channel__c==true);
        initProduct(cam);
        productIdCampaignMap.put(cam.Core_Product__c,cam);
        isCXagent=couponUtil.checkCampaignScope(cam.Business_Partner__r.Sponsor_Code__c);//JOBR-217
    }
    
    /** 
    * @Title: initCampaign
    * @Description: initialize product information,product select list
    * @param Campaign cam
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */     
    public void initProduct(Campaign cam){
        this.productMap=new Map<Id,Product__c>();
        this.productOptions=new List<SelectOption>();       
        List<Id> productIdList=new List<Id>();
        List<String> altCamIds=new List<String>();
        this.productIdPremiumDiscountMap=new Map<Id,List<Premium_Discount__c>>();
        productIdList.add(cam.Core_Product__c);//first Product of productIdList
        for(Core_Campaign_Alter_Campaign__c ccac : cam.Core_Campaign_Alter_Campaign__r){           
            if(cam.Core_Product__c!=ccac.Alt_Campaign__r.Core_Product__c){
                altCamIds.add(ccac.Alt_Campaign__c);
                productIdList.add(ccac.Alt_Campaign__r.Core_Product__c);
            }
        }
        for(Product__c prod : [select id,Disable_Monthly_Payment__c,name,Is_Life__c,CRS_Indicator__c,Product_code__c,Is_Basic_Plan__c,Rate_Scale__c,Policy_Prefix__c,Is_AML__c,currency__c,Website_Product_Code__c/*Nicole_Elite Revamp_20210318*/  from product__c where id in :productIdList]){           /* add by Jack on 2022-04-21 for project: Disable monthly payment */
            this.productMap.put(prod.Id,prod);
            this.productOptions.add(new SelectOption(prod.id,prod.name));
            this.productCodeProductMap.put(prod.Product_Code__c,prod);
        }
        ////System.debug('[TMCreatePolicyCtrl] initProduct().altCamIds='+altCamIds);
        List<Campaign> campaignList=[select id,Core_Product__c,Is_GA__c,(select id,name,Campaign__c,Discount__c,Discount_Type__c,Duration__c,Lapse_Surrender_Policy_Checking__c,Mandatory__c from Premium_Discounts__r WHERE RecordType.DeveloperName!='Premium_Refund') from Campaign where id in :altCamIds];/* add by Jack on 2022-01-11 for project: Discount Enhancement */
        ////System.debug('[TMCreatePolicyCtrl] initProduct().campaignList='+campaignList);
        campaignList.add(cam);
        for(Campaign ca : campaignList){
            productIdPremiumDiscountMap.put(ca.Core_Product__c,ca.Premium_Discounts__r);
            productIdCampaignMap.put(ca.Core_Product__c,ca);
        }
        ////System.debug('[TMCreatePolicyCtrl] initProduct().productIdPremiumDiscountMap='+productIdPremiumDiscountMap);               
    }
    
    /** 
    * @Title: initProductOutOfCam
    * @Description: initialize product without Campaign( the product is the old data of the policy,the new data product of the Campaign don't have the old product)
    * @param Map proMap
    * @param String productId
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */         
    public void initProductOutOfCam(Map<Id,Product__c> proMap,String productId){        
        if(!proMap.containsKey(productId) && String.isNotEmpty(productId)){
            productWithOutOfCamPro=[select id,name,Is_Life__c,CRS_Indicator__c,Product_code__c,Is_Basic_Plan__c,Rate_Scale__c,Policy_Prefix__c from product__c where id=:productId];
            proMap.put(productWithOutOfCamPro.id,productWithOutOfCamPro);
            productOptions.add(new SelectOption(productWithOutOfCamPro.id,productWithOutOfCamPro.name));
        }
        
    }
    
    /** 
    * @Title: initPolicyTransaction
    * @Description: initialize policy transaction details
    * @param Id policyTxnId
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */     
    public void initPolicyTransaction(Id policyTxnId){
        policyTransaction=[select Id,Account__c,Opportunity__c,Opportunity__r.AccountId,Core_Campaign__c,Step__c,Status__c,Product_Name__c,Effective_Date__c,Master_Policy_No__c,Number_of_Person_Insured__c,(select id from NewPolicies__r ),LC_Assessed__c,LC_Reviewer__c,LC_Reviewer_Date__c,PolicyReplacement__c,Objectives_Question__c,Which_type_s_of_medical_insurance__c,Available_Product_Code_For_Assessment__c,Available_Product_Name_For_Assessment__c,Prod_Rider_Map__c from Policy_transaction__c where id=:policyTxnId];//GL31 jack add
        isExists=1;
        currentStep=Integer.valueOf(policyTransaction.Step__c);        
        if(policyTransaction.Status__c=='Completed'){
            isComplete=true;
        }else{
            isComplete=false;
        }       
        if(policyTransaction.Status__c=='Submitted' || policyTransaction.Status__c==TMSubmitPolicyToIpasBatchable.TO_APPLIAN_FIALED  || policyTransaction.Status__c==TMSubmitPolicyToIpasBatchable.TO_ILAS_AND_APPLIAN_FIALED || policyTransaction.Status__c==TMSubmitPolicyToIpasBatchable.TO_IPAS_FIALED){//SPS-667 jack add
            isSubmitted=true;
        }else{
            isSubmitted=false;
        }
    }
    
    /** 
    * @Title: initPolicy
    * @Description: initialize policy details
    * @param Id policyTxnId
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */     
    public void initPolicy(Id policyTxnId){
        List<Id> pIds=new List<Id>();
        for(new_policy__c policy : policyTransaction.NewPolicies__r){
            pIds.add(policy.id);
        }
        // jack add for friend and family discount in SFDC Master_Policy_of_Friend_Discount__c Relationship_of_Friend_Discount__c
        // add Discount2__c to avoid without querying the requested field error
        // Rancho_HKITSFDC402_20250930 - add sum insured
        policyList = [select id,Sum_Insured__c,SI_Referral_Policy_No__c,Policy_Holder_First_Name__c,Policy_Holder_Last_Name__c,Policy_Holder_Name_Chi__c,TM_Residential_Address__c ,TM_Corresponding_address__c,Relationship__c,Gender__c,Date_of_Birth__c,Nationality__c,Place_of_Birth__c,ID_Type__c,Personal_ID__c,Residential_address__c,ID_Expiry_Date__c,Education_Level__c,Home_Phone__c,Mobile_Phone__c,Office_Phone__c,Email__c,Corresponding_address__c,Corresponding_Address_1__c,Corresponding_Address_2__c,Corresponding_Address_3__c,Corresponding_Address_4__c,Corresponding_Address_Country__c,name, Account__c, Policy_Effective_Date__c,Plan_Type__c,Business_Nature__c,Country__c,Company__c,Position__c,Tax_Residence_1__c,Tax_Residence_2__c,Tax_Num_1__c,Tax_Num_2__c,Tax_Num_3__c,Tax_Residence_3__c,Source_of_Fund__c,Other_Source_of_Fund__c,Means_of_Income__c,Reason_In_HK__c,Purpose_of_Insurance__c,Purpose_of_Insurance_Others__c,Product_Name__c,Referral_Exclusion_Reason__c,Appeal__c,Master_Policy_No__c,Relationship_Of_Policy__c,Discount_1__c,Discount_2__c,Payment_Type__c,Payment_Frequency__c,Bank_Name__c,Account_No__c,Remarks__c,Card_Expiry_Date_Text__c,Product__c,Opportunity__c,Benefit_Type__c,Policy_Transaction__c,Discount_Code_1_to_IPAS__c,Discount_Code_2_to_IPAS__c,Opportunity__r.RecordType.DeveloperName,Permanent_Address_1__c,Permanent_Address_2__c,Permanent_Address_3__c,Permanent_Address_4__c,Permanent_Address_Country__c,Residential_Address_1__c,Residential_Address_2__c,Residential_Address_3__c,Residential_Address_4__c,Residential_Address_Country__c,Product_Code__c,Policy_Holder_Name__c,Policy_Status__c,Remarks_to_Cigna_Underwriter__c,Is_Side_Order__c,Name_of_Card_Issuing_Bank__c,Credit_Card_Holder_Full_Name__c,Credit_Card_Number__c,Policy_Holder_Email_Address__c,Actual_Premium__c, Annual_Premium__c, Amount__c, Discount__c,Discount2__c,AML_High_Risk_Ind__c,Company_Address_1__c,Company_Address_2__c,Company_Address_3__c,Company_Address_4__c,Discount_Premium__c, Loading__c, Loading_Amount__c, Modal_Premium__c, Age__c,Income_HKD__c, Bank_Account_No__c, Bank_Account_No_Mask__c, Credit_Card_Number_Mask__c, Original_Premium__c,Policy_No__c,Remarks_to_Cigna_Underwriter_2__c,Appeal_For_UW_Result__c,Credit_Card_Type__c, Pre_Sales_Result__c, UW_Result__c, UW_Overrall_Result__c ,Is_Email_Needed__c,Education_Level_Additional_Information__c,Means_of_Income_Additional_Information__c,Application_Id__c,AUW_URL__c,Presales_Result_Attribute__c,PreSales_Result_Msg__c, Core_Campaign__c, Place_of_Residence_picklist__c,Master_Policy_no_Saved__c, to_Save_Policy_No__c,Company_Address__c,Other_Job__c,Industry__c,Missing_CDD_Info__c,Personal_Choice_Policy_Number__c,isReplacement__c,Initial_Pre_Sales_Result__c,Refund_Discount__c,Unexpected__c,Asia_Miles_Membership_First_Name__c,Asia_Miles_Membership_Last_Name__c,Asia_Miles_Membership_Num__c,(select Error_Message__c,Coupon_status__c,coupon_number__c,coupon_amount__c,id from Coupons__r),Is_Corr_Address_Country_Changed__c,Master_Policy_of_Friend_Discount__c,Relationship_of_Friend_Discount__c from new_policy__c where id in :pIds];//AM project coupon jack add
        newPolicy=policyList.get(0);
        productBeforeChange=newPolicy.Product__c;
        selectedProduct=productMap.get(newPolicy.Product__c);
        System.debug('>>>>>selectedProduct='+selectedProduct);
        initProductOutOfCam(productMap,newPolicy.Product__c);//initialize the productOutOfCampaign                
                
        isShow=0;
        //System.debug('[TMCreatePolicyCtrl] initPolicy().newPolicy.Product__c='+newPolicy.Product__c);
        selectedBusinessNature=newPolicy.Business_Nature__c;
        displayCompanyPosition();
        /**
        if('Appeal'.equals(newPolicy.Appeal__c)){
            isCheckAppeal=true;
        }else{
            isCheckAppeal=false;
        }        
        if('Appeal'.equals(newPolicy.Appeal_For_UW_Result__c)){
            isCheckAppeal2=true;
            isCheckAppeal3=false;
        }else if('Accept'.equals(newPolicy.Appeal_For_UW_Result__c)){
            isCheckAppeal2=false;
            isCheckAppeal3=false;
        }else if('Withdrawn'.equals(newPolicy.Appeal_For_UW_Result__c)){
            isCheckAppeal2=false;
            isCheckAppeal3=true;
        }
        **/
        /*if(null!=newPolicy.Discount_1__c){
            selectedDiscount1=newPolicy.Discount_1__c;
        }
        if(null!=newPolicy.Discount_2__c){
            selectedDiscount2=newPolicy.Discount_2__c;
        }*/
        for(New_Policy__c np : policyList){
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            // if(null!=np.Discount_1__c){
            //     if(String.isBlank(selectedDiscount1)){
            //         selectedDiscount1=np.Discount_1__c;}
            //     else if(String.isBlank(selectedDiscount2) && selectedDiscount1!=np.Discount_1__c){
            //         selectedDiscount2=np.Discount_1__c;}
            // }
            // if(null!=np.Discount_2__c){
            //     if(String.isBlank(selectedDiscount1)){
            //         selectedDiscount1=np.Discount_2__c;}
            //     else if(String.isBlank(selectedDiscount2) && selectedDiscount1!=np.Discount_2__c){
            //         selectedDiscount2=np.Discount_2__c;}
            // }
            //Wellness CI refund
            // if(null!=np.Refund_Discount__c){
            //     selectedRefund=np.Refund_Discount__c;
            // }
        }
        if(null!=newPolicy.Payment_Frequency__c){
            selectedPaymentFrequency=newPolicy.Payment_Frequency__c;//SPS-695 jack add
            //Add by Manuel
            // if(this.opp.Source_of_Activity__c!='STPRefer' && this.opp.Source_of_Activity__c!='STPDropOff'){
            //     selectedPaymentFrequency=newPolicy.Payment_Frequency__c;
            // }else{
            //     selectedPaymentFrequency='Monthly';
            // }
        }
        if(null!=newPolicy.Payment_Type__c){
            //selectedPaymentType=newPolicy.Payment_Type__c;
            //Add by Manuel
            if(this.opp.Source_of_Activity__c!='STPRefer' && this.opp.Source_of_Activity__c!='STPDropOff'){
                selectedPaymentType=newPolicy.Payment_Type__c;
            }
        }
        
        displayOptionalField();        
        if(null!=newPolicy.Bank_Name__c){
            selectedBank=newPolicy.Bank_Name__c;
        }
        if(null!=newPolicy.Name_of_Card_Issuing_Bank__c){
            selectedCreditCardBank=newPolicy.Name_of_Card_Issuing_Bank__c;
        }
        if(null!=newPolicy.Card_Expiry_Date_Text__c){
            String[] tmp=newPolicy.Card_Expiry_Date_Text__c.split('/');
            selectedCardYear=tmp[1];
            selectedCardMonth=tmp[0];
        }
        initAmountOfPI();
        
        boolean isAccepted=true;
        for(New_Policy__c p : policyList){
            if(!'Accepted'.equals(p.Pre_Sales_Result__c)){
                isAccepted=false;
            }
            if(!'Accepted'.equals(p.UW_Result__c)){
                uwResultAccepted=false;
            }
        }
        //if presales result is not accepted,the step 4 page must show
        //System.debug('[TMCreatePolicyCtrl] initPolicy().isAccepted='+isAccepted);
        if(isAccepted){
            presalesAccepted=true;
            isShowStep4Page=false;
        }else{
            presalesAccepted=false;
            isShowStep4Page=true;
        }
        //initCardExpiryDateSelectOption();
        
        //Nicole_20200408_CDD
        if(isShow==1){
            if(String.IsNotBlank(newPolicy.Company_Address__c)){
                TM_address__c tmAddress=[select id,TM_Address_Name__c from TM_address__c where id=:newPolicy.Company_Address__c ];
                companyAddress=tmAddress.TM_Address_Name__c;
                companyAddressLookUp=tmAddress.TM_Address_Name__c;
            }            
            onJobTitleChange();
            onBusinessNatureChange();
        }
    }
    
    /** 
    * @Title: initPersonInsuredInfo
    * @Description: initialize person insured information
    * @param List<new_policy__c> newPolicies
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */         
    public void initPersonInsuredInfo(List<new_policy__c> newPolicies){
        List<Id> pIds=new List<Id>();
        for(new_policy__c policy : newPolicies){
            pIds.add(policy.id);
        }
        personInsuredStructureList=new List<PersonInsuredStructure>();
         List<person_insured__c> piList = [select Id, Name, Other_Reason_for_PI_age_over_18__c,Reason_for_PI_age_over_18__c, Insured_Type__c,Benefit_Level__c,Rider__c,Insured_Last_Name__c, Basic_Plan__c,Insured_First_Name__c,Insured_Name_Chi__c,Marital_Status__c,Gender__c,Smoker__c,Date_of_Birth__c,Nationality__c,ID_Type__c,Personal_ID__c,Weight__c,Benefit_lv_DP_SP_larger_than_MI__c,Weight_Unit__c,Height__c,Height_Unit__c,Home_Phone__c,Mobile_Phone__c,Office_Phone__c,Email__c,Position__c,Income_HKD__c,Corresponding_Address_1__c,Insured_Type_Code__c,Corresponding_Address_2__c,Corresponding_Address_3__c,Corresponding_Address_4__c,Corresponding_Address_Country__c,New_Policy__c,New_Policy__r.Opportunity__r.RecordType.DeveloperName,New_Policy__r.Product_Code__c,New_Policy__r.Id, Person_Insured_Name__c, PI_Age__c,Relationship__c,Education_Level__c,Place_of_Birth__c,Parent_PI_ID__c,New_Policy__r.Pre_Sales_Result__c, New_Policy__r.UW_Result__c, New_Policy__r.UW_Overrall_Result__c,Residential_Address_1__c,Residential_Address_2__c,Residential_Address_3__c,Residential_Address_4__c,Is_Email_Needed__c,Height_Inch__c, LHB_certificate_number__c, LHB_policy_number__c, Declare_new_marriage_new_born_baby__c, Residential_Address_Country__c,Place_of_Residence_picklist__c,Spouse_PI_ID__c,Cancer_Declaration__c, Accident_Declaration__c,Is_GA__c,Asia_Miles_Membership_First_Name__c,Asia_Miles_Membership_Last_Name__c,Asia_Miles_Membership_Num__c,(select id,Last_Name__c,First_Name__c,Person_ID__c,Beneficiary_Type__c,Gender__c,Relationship__c,Percent__c,Person_Insured__c,Policy__c from Beneficiary__r )//AM project jack add/* add by Jack on 2021-12-03 for project: JR1829 */
         //(select Id, Application_Id__c, Full_Result__c, Is_Basic_Plan__c, Loading__c, Person_Insured__c, Policy__c, Presales_Result__c, Product__c, Source__c, Submission_Date_Time__c, Overrall_Result__c, 
//Appeal__c, UW_EXCL_1__c, UW_EXCL_10__c, UW_EXCL_2__c, UW_EXCL_3__c, UW_EXCL_4__c, UW_EXCL_5__c, UW_EXCL_6__c, UW_EXCL_7__c, UW_EXCL_8__c, UW_EXCL_9__c,Remarks_to_Cigna_Underwriter__c,
// Presales_Result_Attribute__c,AUW_URL__c,LastModifiedDate,PreSales_Result_Msg__c from UW_Result__r order by createddate desc)                                    
 from person_insured__c where New_Policy__c in :pIds];       
        //to make sure the order of policyList is equal to PIList's
        Map<String,person_insured__c> policyIdPIMap=new Map<String,person_insured__c>();
        for(person_insured__c pi : piList){
            policyIdPIMap.put(pi.New_Policy__c,pi);
        }        
        amountOfPI=piList.size();
        boolean isAccepted=true;

        //add basic plan for calculate payment
        //System.debug('###initPersonInsuredInfo: '+piList);        
        for(new_policy__c policy : newPolicies){
            person_insured__c pi=policyIdPIMap.get(policy.id);
            List<BeneficiaryStruct> beneStructList=new List<BeneficiaryStruct>();
            if(null!=pi.Beneficiary__r){
                for(Beneficiary__c b : pi.Beneficiary__r){
                    beneStructList.add(new BeneficiaryStruct(pi.Insured_First_Name__c+pi.Insured_Last_Name__c,pi.id,b));
                }
            }
            if(beneStructList.size()==0){
                beneStructList.add(new BeneficiaryStruct(pi.Insured_First_Name__c+pi.Insured_Last_Name__c));
            }                       
            //riderMap,riderCodeBenefitLevelListMap,benefitMap -----these three param are null in these method,rider structure in pi wont be built in PersonInsuredStructure Construction Method 
            //they will be built in beneficiaryLevelAndRiderInitialize()
            //System.debug('andy add the debug,pi='+pi);
            //System.debug('andy add the debug,riderMap='+riderMap);
            PersonInsuredStructure pis=new PersonInsuredStructure(beneStructList,pi,policy,riderMap,riderCodeBenefitLevelListMap,benefitMap);//GL31 jakc add
            personInsuredStructureList.add(pis);
            /**
            if(null!=pi.UW_Result__r && pi.UW_Result__r.size()>0){
                if(!'Accepted'.equals(pi.UW_Result__r[0].Presales_Result__c)){
                    isAccepted=false;
                }
                if(!'Accepted'.equals(pi.UW_Result__r[0].Full_Result__c)){
                    uwResultAccepted=false;
                }
            }
            **/            
            //Add by Manuel
            if(this.opp.Source_of_Activity__c=='STPRefer' || this.opp.Source_of_Activity__c=='STPDropOff'){
                if(pi.Email__c==null||String.isBlank(pi.Email__c)){
                    pi.Is_Email_Needed__c=true;
                }
            }            
        }
        //initialize master policy number
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if('PH = PI'.equalsIgnoreCase(pis.pi.Insured_Type__c)){
                defaultMasterPolicyNum=pis.piPolicy.policy_no__c;
                break;
            }
        }        
        // add by kermit for SPS-237
        //this.showBMIforSpecialProduct();
        // end for SPS-237
        
        //if presales result is not accepted,the step 4 page must show
        //if(isAccepted){
        //    presalesAccepted=true;
        //    isShowStep4Page=false;
        //}else{
        //    presalesAccepted=false;
        //    isShowStep4Page=true;
        //}
        //System.debug('[TMCreatePolicyCtrl] initPersonInsuredInfo().personInsuredStructureList.size()'+personInsuredStructureList.size());
    }
    
    /** 
    * @Title: initPolicyTransaction
    * @Description: initialize policy transaction details
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initPolicyTransaction(){
        policyTransaction=new Policy_Transaction__c();
        policyTransaction.Number_of_Person_Insured__c=amountOfPI;
        policyTransaction.Account__c=accountId;
        policyTransaction.Core_Campaign__c=campaignId;
        policyTransaction.Opportunity__c=opportunityId;
        //policyTransaction.Product_Code__c=productCode;
        //policyTransaction.Product_Name__c=productMap.get(selectedProductId).Name;
        policyTransaction.Step__c=String.valueOf(STEP_POLICY_INFORMATION);
    }
    
    /** 
    * @Title: initPolicy
    * @Description: init policy if id is null
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initPolicy(){               
        if(amountOfPI>policyList.size()){
            if(policyList.size()==0){
                String selectedProductId=newPolicy.Product__c;//save productid and productcode temporarily
                newPolicy=new New_Policy__c();
                //AM project AM info enhancement jack add
                newPolicy.Asia_Miles_Membership_First_Name__c=opp.Asia_Miles_Membership_First_Name__c;
                newPolicy.Asia_Miles_Membership_Last_Name__c=opp.Asia_Miles_Membership_Last_Name__c;
                newPolicy.Asia_Miles_Membership_Num__c=opp.Asia_Miles_Membership_Num__c;
                newPolicy.Policy_Holder_First_Name__c=acc.firstName;
                newPolicy.Policy_Holder_Last_Name__c=acc.lastName;
                newPolicy.Policy_Holder_Name_Chi__c=acc.Chinese_Name__c;
                newPolicy.Gender__c=acc.Gender__c;
                newPolicy.Date_of_Birth__c=acc.PersonBirthdate__c;               
                newPolicy.Home_Phone__c=acc.PersonHomePhone;
                newPolicy.Mobile_Phone__c=acc.PersonMobilePhone;
                newPolicy.Office_Phone__c=acc.Office_Phone__c;
                newPolicy.Personal_ID__c=acc.SSN__c;
                Pattern emailPattern=Pattern.compile('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$');
                if(null==acc.Email__c){
                    newPolicy.Is_Email_Needed__c=true;
                }else{
                    //System.debug('[TMCreatePolicyCtrl] policy_holder_email_address='+newPolicy.Policy_Holder_Email_Address__c);
                    if(String.isNotBlank(newPolicy.Policy_Holder_Email_Address__c) && !emailPattern.matcher(newPolicy.Policy_Holder_Email_Address__c).matches()){
                        newPolicy.Is_Email_Needed__c=true;
                    }else{
                        newPolicy.Policy_Holder_Email_Address__c=acc.Email__c;
                    }
                }
                newPolicy.Company__c=acc.Company__c;
                
                //DPSP-973 : no default value for corresponding address
                //add by andy for DPSP-898 put default value in residential address to be the same as corresponding address
                //newPolicy.Corresponding_Address_1__c=acc.Home_Address_Line_1__c;
                //newPolicy.Corresponding_Address_2__c=acc.Home_Address_Line_2__c;
                //newPolicy.Corresponding_Address_3__c=acc.Home_Address_Line_3__c;
                //newPolicy.Corresponding_Address_4__c=acc.Home_Address_Line_4__c;                                
                newPolicy.Position__c=acc.Position__c;
                newPolicy.Corresponding_Address_Country__c='HONG KONG';
                //newPolicy.Permanent_Address_Country__c='HONG KONG';
                //newPolicy.Residential_Address_Country__c=((isShow==1)?'HONG KONG' : null);                
                newPolicy.ID_Type__c='HK PERM RESIDENT';
                //any opportunity created by TMR would be treated as Side Order.Other situation,such as from customer portal(e-sales) or website,the is_side_order fiele is false.
                newPolicy.Is_Side_Order__c=opp.Is_Side_Order__c;
                //newPolicy.Appeal__c='no';//appeal default to no
                newPolicy.Appeal_For_UW_Result__c=APPEAL_NO;//appeal default to no                    
                newPolicy.Opportunity__c=opportunityId;
                newPolicy.Account__c=accountId;
                newPolicy.Core_Campaign__c=campaignId;
                if(String.isNotBlank(acc.Credit_Card_No_BackEnd__c)){
                    //System.debug('[TMCreatePolicyCtrl].initPolicy() Init Credit Card No.>>> '+acc.Credit_Card_No_BackEnd__c);
                    // 20200717 - minghua - SF Modeling
                    // newPolicy.Bank_Account_No__c=acc.Credit_Card_No_BackEnd__c; //add by andy for Credit Card auto pop function
                    // newPolicy.Bank_Account_No_Mask__c=TMPolicyUtil.maskBankAccountNumber(acc.Credit_Card_No_BackEnd__c);
                    String ccNumber=acc.Credit_Card_No_BackEnd__c;
                    String patCardNumber='[45][0-9]{3}([0-9]{8}|X{8}|\\*{8})[0-9]{4}';
                    Pattern rCardNum=Pattern.compile(patCardNumber);
                    Matcher mCardNum=rCardNum.matcher(ccNumber);
                    if (mCardNum.matches()){
                        newPolicy.Credit_Card_Number__c=ccNumber;
                        newPolicy.Credit_Card_Number_Mask__c=TMPolicyUtil.maskBankAccountNumber(ccNumber);
                    }else{
                        if(String.isBlank(acc.Bank_Account_No_BackEnd__c)){
                            if (ccNumber.isNumeric() && !ccNumber.startsWith('4') && !ccNumber.startsWith('5') && ccNumber.length() <=20){
                                newPolicy.Credit_Card_Number__c='';
                                newPolicy.Credit_Card_Number_Mask__c='';
                                newPolicy.Bank_Account_No__c=ccNumber;
                                newPolicy.Bank_Account_No_Mask__c=TMPolicyUtil.maskBankAccountNumber(ccNumber);
                            }
                        }
                    }
                }
                
                // 20200717 - minghua - SF Modeling
                if (String.isNotBlank(acc.Bank_Account_No_BackEnd__c)){
                    newPolicy.Bank_Account_No__c=acc.Bank_Account_No_BackEnd__c;
                    newPolicy.Bank_Account_No_Mask__c=TMPolicyUtil.maskBankAccountNumber(acc.Bank_Account_No_BackEnd__c);
                }
                if(productMap.containsKey(selectedProductId)){
                    Product__c prod=productMap.get(selectedProductId);
                    newPolicy.Product__c=selectedProductId;
                    newPolicy.Product_Name__c=prod.Name;
                    newPolicy.Product_Code__c=prod.Product_Code__c;
                    selectedProduct=prod;
                    newPolicy.Nationality__c=(isShow==1?acc.Nationality__c : null);
                    // Rancho_IA AML_20220120: update nationality default value
                    // newPolicy.Nationality__c=(isShow==1 && null==newPolicy.Nationality__c?'HONG KONG' : null);
                    // newPolicy.Nationality__c=(isShow==1 && null==newPolicy.Nationality__c?'Chinese' : null);
                    newPolicy.Nationality__c=((isShow==1 &&(null==acc.Nationality__c||acc.Nationality__c=='HONG KONG'))?'Chinese' : acc.Nationality__c);
                }else if(String.isEmpty(selectedProductId)){
                    if(null==newPolicy.Product__c){
                        newPolicy.Product__c=cam.Core_Product__c;//default value is the first Product of productIdList
                        selectedProduct=productMap.get(newPolicy.Product__c);
                        //this.selectedProductId=cam.Core_Product__c;//default value is the first Product of productIdList
                    }
                    //System.debug('[TMCreatePolicyCtrl] initPolicy().newPolicy.Product_Code__c='+newPolicy.Product_Code__c);
                    if(null==newPolicy.Product_Code__c){
                        newPolicy.Product_Code__c=productMap.get(newPolicy.Product__c).Product_code__c;
                        //this.productCode=productMap.get(selectedProductId).Product_code__c;
                    }
                }
                
                //add by jack for JR1641 default value on nationality
                if(newPolicy.Product_Code__c=='@NELG' || newPolicy.Product_Code__c=='@NESG'){
                    // Rancho_IA AML_20220120: update nationality default value
                    // newPolicy.Nationality__c=(null==acc.Nationality__c?'HONG KONG' : acc.Nationality__c);
                    newPolicy.Nationality__c=(((null==acc.Nationality__c||acc.Nationality__c=='HONG KONG'))?'Chinese' : acc.Nationality__c);
                }                
                //no default value for residential address,use a front end button to copy address
                //TS-726 : in policy creation,for Residential Address,default value should be call list address if any,otherwise default value should be residential address
                newPolicy.Residential_Address_1__c=String.isNotEmpty(acc.Call_List_Address_Line_1__c)?acc.Call_List_Address_Line_1__c:acc.Home_Address_Line_1__c;
                newPolicy.Residential_Address_2__c=String.isNotEmpty(acc.Call_List_Address_Line_2__c)?acc.Call_List_Address_Line_2__c:acc.Home_Address_Line_2__c;
                newPolicy.Residential_Address_3__c=String.isNotEmpty(acc.Call_List_Address_Line_3__c)?acc.Call_List_Address_Line_3__c:acc.Home_Address_Line_3__c;
                newPolicy.Residential_Address_4__c=String.isNotEmpty(acc.Call_List_Address_Line_4__c)?acc.Call_List_Address_Line_4__c:acc.Home_Address_Line_4__c;
                //newPolicy.Nationality__c='HONG KONG';
                newPolicy.Residential_Address_Country__c='HONG KONG';
                                
                initAmountOfPI();//add selectOptions to amountOfPI
                //System.debug('[TMCreatePolicyCtrl] initPolicy().isShow='+isShow);
                //System.debug('[TMCreatePolicyCtrl] initPolicy().isShowCRSField='+isShowCRSField);
                //initCardExpiryDateSelectOption();//add selectOptions to cardExpiryDate
                policyList.add(newPolicy);
            }else{               
                while(amountOfPI>policyList.size()){
                    New_Policy__c tmpPolicy=new New_Policy__c();
                    //tmpPolicy.Appeal__c='no';//appeal default to no
                    tmpPolicy.Appeal_For_UW_Result__c=APPEAL_NO;//appeal default to no
                    policyList.add(tmpPolicy);
                }
                initPersonInsuredInfo();
            }
        }else if(amountOfPI<policyList.size()){
            while(amountOfPI<policyList.size()){              
                New_Policy__c tpPolicy=policyList.remove(policyList.size()-1);
                personInsuredStructureList.remove(personInsuredStructureList.size()-1);               
                if(null!=tpPolicy.Id){
                    deletePolicyList.add(tpPolicy);
                }
            }
            //System.debug('[TMCreatePolicyCtrl] initPolicy().policyList.size():'+policyList.size());
            //System.debug('[TMCreatePolicyCtrl] initPolicy().personInsuredStructureList.size():'+personInsuredStructureList.size());
        }else if(amountOfPI==policyList.size()){// if change productCode,this situation will happen
            //SPS-449 changing product between Elite product,remain the policies unchange
            if(productBeforeChange!=null && newPolicy.Product__c!=null){
                Product__c proBeforeChange = productMap.get(productBeforeChange);
                Product__c proAfterChange = productMap.get(newPolicy.Product__c);
                if(proBeforeChange!=null && proAfterChange!=null){
                    //System.debug('[TMCreatePolicyCtrl] proBeforeChange='+proBeforeChange);
                    //System.debug('[TMCreatePolicyCtrl] proAfterChange='+proAfterChange);
                    if(String.isNotBlank(proBeforeChange.Product_Code__c) && String.isNotBlank(proAfterChange.Product_Code__c)
                       &&'@NELG,@NESG'.contains(proBeforeChange.Product_Code__c) && '@NELG,@NESG'.contains(proAfterChange.Product_Code__c)){
                        productBeforeChange = proAfterChange.Id;
                        newPolicy.Product_Code__c = proAfterChange.Product_Code__c;
                        beneficiaryLevelAndRiderInitialize();
                        return;
                    }
                }
            }
            //SPS-449
            
            defaultMasterPolicyNum='';
            if(!policyList.isEmpty()){
                for(new_policy__c policy : policyList){
                    if(null!=policy.id){//SPS-449
                        deletePolicyList.add(policy);
                    }                    
                }
                if(amountOfPI !=1){
                    policyList.clear();
                    personInsuredStructureList.clear();
                    initPolicy();
                    initPolicy();
                }else{
                    policyList.clear();
                    personInsuredStructureList.clear();
                    initPolicy();
                    initPersonInsuredInfo();
                }
            }
            premiumAmountList.clear();
        }               
        productBeforeChange=newPolicy.Product__c;
    }
    
    /** 
    * @Title: initPersonInsuredInfo
    * @Description: init personInsuredStructureList 
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initPersonInsuredInfo(){
        if(amountOfPI==personInsuredStructureList.size()){
            personInsuredStructureList.clear();
            initPersonInsuredInfo();
        }else if(amountOfPI>personInsuredStructureList.size()){
            //System.debug('[TMCreatePolicyCtrl] initPersonInsuredInfo().amountOfPI>personInsuredStructureList.size()');
            boolean isPIListClear=personInsuredStructureList.size()==0?true:false;
            Integer i=personInsuredStructureList.size();
            while(amountOfPI>personInsuredStructureList.size()){
                PersonInsuredStructure newPIS=new PersonInsuredStructure();
                //Wellness CI GA system approach
                newPIS.pi.Is_GA__c=productIdCampaignMap.containsKey(this.selectedProduct.Id)?productIdCampaignMap.get(this.selectedProduct.Id).Is_GA__c:false;
                //Wellness CI GA system approach
                newPIS.pi.Weight_Unit__c='kg';
                newPIS.pi.Height_Unit__c='cm';
                newPIS.pi.ID_Type__c='HK PERM RESIDENT';
                // Rancho_IA AML_20220120: set PH residential address country as default value for PI
                if(String.isBlank(newPIS.pi.Residential_Address_Country__c) && String.isNotBlank(newPolicy.Residential_Address_Country__c)){
                    newPIS.pi.Residential_Address_Country__c = newPolicy.Residential_Address_Country__c;
                }
                if(i<policyList.size()){
                    newPIS.piPolicy=policyList.get(i);
                    ++i;
                } 
                
                //after changing the amount of the PI,initialize the riders of new PI which is added 
                //after changing the product or new application(in this case,benefitAndRider WS is executing after the PI initilization,the rider Initialization is in the benefitAndRiderInit)
                if(!isPIListClear && null!=benefitLevelOption && !benefitLevelOption.isEmpty()){                   
                    List<String> allRiderCodes=new List<String>();
                    Map<String,String> allRiders=new Map<String,String>();
                    List<HttpCalloutVO.Rider> initVORiderList=riderMap.get(benefitLevelOption.get(0).getValue());//for new Policy Creation,default BenefitLevel is the first level
                    //System.debug('[TMCreatePolicyCtrl] initPersonInsuredInfo().initVORiderList='+initVORiderList);
                    if(null!=initVORiderList && !initVORiderList.isEmpty()){
                        for(HttpCalloutVO.Rider riderVO: initVORiderList){
                            allRiders.put(riderVO.riderCode,riderVO.riderName);
                            allRiderCodes.add(riderVO.riderCode);                           
                        }
                        //List<String> allRiderCodes=new List<String>(riderMap.keySet());
                        //Map<String,String> allRiders=riderMap;
                        List<String> riderList=new List<String>();
                        //Map<String,List<String>> benefitlevelRidersCodeMap=new Map<String,List<String>>();
                        //add by jack for policy replacement
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitMap='+benefitMap);
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() newPIS.pi.Benefit_Level__c='+newPIS.pi.Benefit_Level__c);
                        if(String.isBlank(newPIS.pi.Benefit_Level__c) && selectedProduct.Product_Code__c=='@KIDSL'){/* add by Jack on 2022-09-07 for project: JOBR-167 if need to disable benefit option for @KIDSL, need to modify here */
                            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() special handling');
                            newPIS.pi.Benefit_Level__c='12';
                            for(String s : benefitMap.keySet()){
                                if(Integer.valueOf(s)<Integer.valueOf(newPIS.pi.Benefit_Level__c))
                                    newPIS.pi.Benefit_Level__c=s;
                            }
                            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() pi.BenefitLevel='+newPIS.pi.Benefit_Level__c);
                        }
                        //add by jack for policy replacement
                        //System.debug('###before initRiderRelated4PI###');
                        //System.debug('###allRiderCodes###'+allRiderCodes);
                        //System.debug('###allRiders###'+allRiders);
                        //System.debug('###riderList###'+riderList);
                        //System.debug('###selectedProduct.Product_Code__c###'+selectedProduct.Product_Code__c);
                        //System.debug('###riderCodeBenefitLevelListMap###'+riderCodeBenefitLevelListMap);
                        //System.debug('###benefitMap###'+benefitMap);
                        newPIS.initRiderRelated4PI(allRiderCodes,allRiders,riderList,selectedProduct.Product_Code__c,riderCodeBenefitLevelListMap,benefitMap);//GL31 jakc add
                    }else{
                        newPIS.availableRidersMap.clear();
                        newPIS.selectedRidersMap.clear();
                        //newPIS.benefitlevelRidersMap.clear();
                        newPIS.availableRiderBenefitlevelItemList.clear();
                    }
                }                                                   
                personInsuredStructureList.add(newPIS);               
            }
        }else if(amountOfPI<personInsuredStructureList.size()){           
            //deletePersonInsuredList.clear();
            while(amountOfPI<personInsuredStructureList.size()){
                Person_insured__c pi=personInsuredStructureList.remove(personInsuredStructureList.size()-1).pi;
                if(null!=pi.id){
                    deletePersonInsuredList.add(pi);
                }                
            }            
        }
        //TMPolicyUtil.piDiscountInitAndValidation(personInsuredStructureList,cam,selectedProduct);
    }    
    
    /** 
    * @Title: initCurrentStep
    * @Description: init current step 
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initCurrentStep(){
        currentStep=STEP_POLICY_INFORMATION;        
        if( null==cam || null==opp){
            currentStep=NO_PERMISSION;
        }
        if(policyTransaction!=null){//add by jack for JR1641
            if( null!=policyTransaction.Id && null!=policyTransaction.Step__c){
                currentStep=Integer.valueOf(policyTransaction.Step__c);
                if(currentStep==STEP_UW_INFORMATION_2){
                    if(presalesAccepted){
                        if(isSkipStep3){
                            currentStep=STEP_PHPI_INFORMATION;
                        }else{
                            currentStep=STEP_BENEFICIARY_INFORMATION;
                        }
                    }else{
                        currentStep=STEP_UW_INFORMATION;
                        //isPIChange();
                    }
                }
            }
        }
        if(newPolicy!=null && newPolicy.Unexpected__c)
            currentStep=STEP_POLICY_INFORMATION;
        // TM Work at Home
        if(orgnDataBeforeMask.workAtHome){           
            maskSensiData();
        }
    }
    
    /** 
    * @Title: initAmountOfPI
    * @Description: init Amount Of Person insured
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initAmountOfPI(){       
        //initialize the picklist of the amountOfPI
        amountOfPIOptions=new List<SelectOption>();
        Integer maxPIcount=13;        
        for(Integer i=1;i<maxPIcount;i++){
            amountOfPIOptions.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
    }
    
    /** 
    * @Title: initPolicyTransactionValidationStruct
    * @Description: init policyTransactionStruct
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public void initPolicyTransactionValidationStruct(){       
        ptvs=new TMPolicyUtil.PolicyTransactionValidationStruct(this);
        //System.debug('[TMCreatePolicyCtrl] initPolicyTransactionValidationStruct ptvs='+ptvs);
    }
    
    /** 
    * @Title: save
    * @Description: save current status
    * @param
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */ 
    public PageReference save(){       
        //System.debug('[TMCreatePolicyCtrl] save() opp.Name='+this.opp.Name);
        //System.debug('[TMCreatePolicyCtrl] save() condition='+this.opp.Name.startsWith('XXXXXX-'));
        //System.debug('[TMCreatePolicyCtrl] save this.productCodeProductMap='+productCodeProductMap);
        //System.debug('[TMCreatePolicyCtrl] save this.newPolicy.Product_Code__c='+this.newPolicy.Product_Code__c);
        this.selectedProduct=productCodeProductMap.containsKey(this.newPolicy.Product_Code__c)?productCodeProductMap.get(this.newPolicy.Product_Code__c):this.selectedProduct;
        // avoid create application under dummy account's opportunity
        if('TM_Dummy_Account'.equals(this.acc.RecordType.developerName)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dummy account opportunity is not allowed to create application.'));
            return null;
        } 
        // end
        else if(String.isNotBlank(this.opp.Name) && this.opp.Name.startsWith('XXXXXX-')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dummy opportunity is not allowed to create application.'));
            return null;
        }
        else if(this.opp.OwnerId!=userInfo.getUserId()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Can not create application in the opportunity that is not assigned to you'));
            return null;
        }
        //AM project coupon jack comment for canceling save validation and set status to pending payment after getPaymentPremium
        /* else if(!saveValidation()){//SPS-728 jack add
            return null;
        } */
        
        // TM Work at Home : de-mask sensitive data before saving records
        if(orgnDataBeforeMask.workAtHome){
            deMaskSensiData();
        }
        this.savePolicyTransaction();
        this.savePolicy();
        this.savePersonInsuredInfo();
        if(currentStep>=STEP_CONFIRMATION_PAYMENT){
            this.savePlanQuoteList();
        }

        // TM Work at Home : mask sensitive data after saved records
        if(orgnDataBeforeMask.workAtHome){
            maskSensiData();
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You have successfully saved the record.'));
        return null;
    }

    //AM project coupon jack comment for canceling save validation and set status to pending payment after getPaymentPremium
    /* //validation for save button to avoid incorrect data saving into data base SPS-728 jack add
    public Boolean saveValidation(){
        Boolean result=true;
        //validation for payment step save button
        if(isInStep(STEP_CONFIRMATION_PAYMENT)){
            if(!isPaymentButtonClicked){
                return result;
            }
            TMCreatePolicyStepStrategy policyStepStrategy=new TMCreatePolicyStep7Strategy(ptvs);
            if(!policyStepStrategy.stepValidation()){
                result=false;
            }
            this.currentStep ++;
        }
        return result;
    } */

    /** 
    * @Title: saveByNext
    * @Description: save after next step
    * @param Boolean toSave
    * @return 
    * @author Ken
    * @date 2018-10-12 15:02:29 
    */     
    public void saveByNext(Boolean toSave){
        if(toSave){
            //System.debug('[TMCreatePolicyCtrl] saveByNext this.productCodeProductMap='+productCodeProductMap);
            //System.debug('[TMCreatePolicyCtrl] saveByNext this.newPolicy.Product_Code__c='+this.newPolicy.Product_Code__c);
            this.selectedProduct=productCodeProductMap.containsKey(this.newPolicy.Product_Code__c)?productCodeProductMap.get(this.newPolicy.Product_Code__c):this.selectedProduct;
            this.savePolicyTransaction();
            this.savePolicy();
            this.savePersonInsuredInfo();
            if(currentStep>=STEP_CONFIRMATION_PAYMENT){
                this.savePlanQuoteList();
            }
        }
    }
    
    public PageReference nextStep(){
        TMCreatePolicyStepStrategy policyStepStrategy;        
        // avoid create application under dummy account's opportunity
        if('TM_Dummy_Account'.equals(this.acc.RecordType.developerName)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dummy account opportunity is not allowed to create application.'));
            return null;
        }
        // end
        else if(String.isNotBlank(this.opp.Name) && this.opp.Name.startsWith('XXXXXX-')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dummy opportunity is not allowed to create application.'));
            return null;
        }
        else if(this.opp.OwnerId!=userInfo.getUserId()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Can not create application in the opportunity that is not assigned to you'));
            return null;
        }
        System.debug('>>>>>> TMCreatePolicy,this.currentStep='+this.currentStep);
        List<String> ssnList=new List<String>();//Nicole_Elite Revamp_20210319
        for(PersonInsuredStructure pis : personInsuredStructureList){
            ssnList.add(pis.pi.Personal_ID__c);
            //System.debug('TMCreatePolicy,pis.piPolicy.Pre_Sales_Result__c'+pis.piPolicy.Pre_Sales_Result__c+'pis.piPolicy.UW_Overrall_Result__c:'+pis.piPolicy.UW_Overrall_Result__c);
        }        
                       
        // TM Work at Home : recover data
        if(orgnDataBeforeMask.workAtHome){
            deMaskSensiData();
        }        
        this.currentStep ++;
        this.canSave=true;
        System.debug('>>>>>> TMCreatePolicy,this.currentStep='+this.currentStep);        
        //Nicole_Elite Revamp_20210319
        // Rancho_AH24240_20220224: comment for duplicate logic
        // if(isInStep(STEP_CONFIRMATION_PAYMENT)&&selectedProduct!=null&&'@NELG,@NESG'.contains(selectedProduct.Product_Code__c)){
        //     firstYDisEliMap=TMPolicyUtil.getFirstYDisEliMap(selectedProduct.Website_Product_Code__c,ssnList);
        // }     
        updatePIBenefitLevel(); //WEI-296
                
        if(isInStep(STEP_POLICY_INFORMATION)){
            //saveByNext();
        }
        //PH & PI step2
        if(isInStep(STEP_PHPI_INFORMATION)){
            policyStepStrategy=new TMCreatePolicyStep2Strategy(ptvs);
            policyStepStrategy.nextStep();           
        }
        //Beneficiary step3
        if(isInStep(STEP_BENEFICIARY_INFORMATION)){
            //System.debug('>>>>>> TMCreatePolicy,C this.currentStep='+this.currentStep);
            policyStepStrategy=new TMCreatePolicyStep3Strategy(ptvs);
            policyStepStrategy.nextStep();
            //System.debug('>>>>>> TMCreatePolicy,B this.currentStep='+this.currentStep);
            //Add by Andy Li from Deloitte
            /***********************************************Start***************************************************************************
            ***The new requirement is: If the person don't need do AUW,we should set the height&weight as optional
            ***As original code is validate in next button logic,so we need first get the value whether need AUW,then 
            ***to do the height and weight validate. So I move the validate from TMCreatePolicyStep3Strategy->step3Validation(XX) to here.
            *******************************************************************************************************************************/
            if(ptvs.policyTransactionValidationItem.showBMIInd && '@PBTG'.equals(selectedProduct.product_code__c)){
                Boolean pass=true;
                String warningMsg='You must enter Height and Weight values for ';
                for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                    //System.debug('>>>>>> TMCreatePolicy,pis.piValidationItem.needAUW='+pis.piValidationItem.needAUW);
                    if(pis.piValidationItem.needAUW !=null && pis.piValidationItem.needAUW){  
                        if(String.isEmpty(pis.weight) || String.isEmpty(pis.height) || (pis.pi.Height_Unit__c=='ft' && String.isEmpty(pis.heightInch))){
                            warningMsg=warningMsg+pis.pi.Person_Insured_Name__c+' ';
                            pass=false;
                        }
                    }
                }
                warningMsg+='due to AUW requirements.';
                //if the first warning message contruct method found pass is false,don't need do the next validation.
                if(pass){
                    for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                        //System.debug('andy test ,pis='+pis);
                        if(pis.piValidationItem.needAUW !=null && pis.piValidationItem.needAUW){  
                            if(String.isEmpty(pis.weight) || String.isEmpty(pis.height) 
                               || null==pis.pi.Height_Unit__c || null==pis.pi.Weight_Unit__c){
                                //System.debug('[TMCreatePolicyCtrl] checkPIPHRequiredField() pi validation:weight Height');
                                pass=false;
                                break;
                            //Only digits are allowed.
                            }else if(pis.height.contains('.') || pis.weight.contains('.')){
                                //System.debug('[TMCreatePolicyCtrl] checkPIPHRequiredField().Height__c & Weight__c validation');
                                pass=false;
                                warningMsg='Please enter only digits for height or weight.';
                                break;
                            }else if(pis.pi.Height_Unit__c=='ft'){
                                if(String.isEmpty(pis.heightInch)){
                                    //System.debug('[TMCreatePolicyCtrl] checkPIPHRequiredField().Height__c & Weight__c validation');
                                    pass=false;
                                    break;
                                }else if(Double.valueOf(pis.height)>999 || Double.valueOf(pis.height)<0){
                                    //System.debug('[TMCreatePolicyCtrl] checkPIPHRequiredField().Height__c & Weight__c validation');
                                    pass=false;
                                    warningMsg='Please enter a value in "Height - ft" less than or equal to 999. ';
                                    break;
                                }else if(Double.valueOf(pis.heightInch)>11 || Double.valueOf(pis.heightInch)<0){
                                    //System.debug('[TMCreatePolicyCtrl] checkPIPHRequiredField().Height__c & Weight__c validation');
                                    pass=false;
                                    warningMsg='Please enter a value in "Height - inch" less than or equal to 11.';
                                    break;
                                }
                            } 
                        }           
                    }
                }                
                if(pass==false){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,warningMsg));
                    this.currentStep=STEP_PHPI_INFORMATION;
                    this.canSave=false;
                    return null;
                }
               
            }
            /***********************************************End***************************************************************************/
            // add by kermit for missing master policy number issue
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                if('PH = PI'.equalsIgnoreCase(pis.pi.Insured_Type__c)){
                    defaultMasterPolicyNum=pis.piPolicy.policy_no__c;
                    break;
                }
            }
            
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                if(String.isEmpty(pis.piPolicy.Master_Policy_No_Saved__c)){
                    pis.piPolicy.Master_Policy_No__c=null==defaultMasterPolicyNum?pis.piPolicy.policy_no__c:defaultMasterPolicyNum;
                    //DPSP-571 : last comment,for RSM application,maturity policy number of the account=master policy number
                    TMProductStrategyRSM.setMasterPolicyNumberFromAccMaturityPolicyNum(acc.Maturity_Policy_Number__c,pis);
                }else{
                    pis.piPolicy.Master_Policy_No__c=pis.piPolicy.Master_Policy_No_Saved__c;
                }               
            }
            // end add
        }
        //Before AUW step4
        if(isInStep(STEP_UW_INFORMATION)){
            //System.debug('>>>>>> TMCreatePolicy,D this.currentStep='+this.currentStep);
            //System.debug('TMCreatePolicyCtrl canSave'+canSave);
            policyStepStrategy=new TMCreatePolicyStep4Strategy(ptvs);
            policyStepStrategy.nextStep();
            //System.debug('after step 4 strategy');
            for(PersonInsuredStructure pis : personInsuredStructureList){
                //System.debug('after step 4 strategy pis.piPolicy.application_Id__c='+pis.piPolicy.Application_Id__c);
            }
            //System.debug('TMCreatePolicyCtrl canSave'+canSave);
            //System.debug('>>>>>> TMCreatePolicy,E this.currentStep='+this.currentStep);
        }
        //AUW step5
        if(isInStep(STEP_UW_INFORMATION_2)){
            //System.debug('[TMCreatePolicyCtrl] nextStep().piName='+piName);
            //System.debug('[TMCreatePolicyCtrl] nextStep().auwUrl: '+auwUrl);
            //System.debug('[TMCreatePolicyCtrl] nextStep().applicationId: '+applicationId);
            policyStepStrategy=new TMCreatePolicyStep5Strategy(ptvs);
            policyStepStrategy.nextStep();
            //System.debug('[TMCreatePolicyCtrl] nextStep().piName: '+piName);
            //System.debug('[TMCreatePolicyCtrl] nextStep().auwUrl: '+auwUrl);
            //System.debug('[TMCreatePolicyCtrl] nextStep().applicationId: '+applicationId);
        }
        //payment step6
        if(isInStep(STEP_CONFIRMATION_PAYMENT)){
            //System.debug('>>>>>> TMCreatePolicy,F this.currentStep='+this.currentStep);
            policyStepStrategy=new TMCreatePolicyStep6Strategy(ptvs);
            if(policyStepStrategy.stepValidation()){
                //TMPolicyUtil.updateUWResult(personInsuredStructureList);
                policyStepStrategy.stepInit();               
                //getPaymentPremium();
            }else{
                policyStepStrategy.stepInit();
            }
            //System.debug('>>>>>> TMCreatePolicy,G this.currentStep='+this.currentStep);
        }
        //policy complete
        if(isInStep(IS_COMPLETED)){
            policyStepStrategy=new TMCreatePolicyStep7Strategy(ptvs);
            if(policyStepStrategy.stepValidation()){
                policyStepStrategy.stepInit();
                saveByNext(true);
                this.currentStep=DISPLAY_COMPLETED_MESSAGE;
            }            
        }
        //System.debug('>>>>>> TMCreatePolicy,A this.currentStep='+this.currentStep);
        saveByNext(canSave);       
        /*TM Work at Home : mask sensitive data if current user work at home*/
        // mask data when step is 2,3 or 6
        if(orgnDataBeforeMask.workAtHome){
            maskSensiData();
        }
        
        //System.debug('>>>>>> TMCreatePolicy,this.currentStep='+this.currentStep);
        System.debug('>>>>>> TMCreatePolicy,canSave='+canSave); 
        for(PersonInsuredStructure pis : personInsuredStructureList){
            //System.debug('[TMCreatePolicyCtrl] after '+currentStep+' Strategy pis.piPolicy.UW_Result__c=' +pis.piPolicy.UW_Result__c);
            //System.debug('[TMCreatePolicyCtrl] after '+currentStep+' Strategy pis.piPolicy.Application_Id__c=' +pis.piPolicy.Application_Id__c);
        }
        for(PersonInsuredStructure pis : personInsuredStructureList){
            //System.debug('TMCreatePolicy,pis.piPolicy.Pre_Sales_Result__c'+pis.piPolicy.Pre_Sales_Result__c+'pis.piPolicy.UW_Overrall_Result__c:'+pis.piPolicy.UW_Overrall_Result__c);
        }
        return null;
    }
       
    /**
     * back logic：
        1、normal
        6->4->3->2->1
        6->3->2->1(accepted)
        
        2、skip step3
        6->4->2->1
        6->2->1(accepted)
        
        3、skip step4&5
        6->3->2->1
        
        4、skip step3&4&5
        6->2->1
        isSkipStep4And5 isSkipStep3  
     **/
    public void previousStep(){
        //System.debug('[TMCreatePolicyCtrl] previousStep().before back step='+currentStep);
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(!pis.pi.Benefit_Level__c.isNumeric()){
                pis.pi.Benefit_Level__c=hex2DecMap.get(pis.pi.Benefit_Level__c);
            }
        }
        if(isInStep(STEP_CONFIRMATION_PAYMENT)){
            isPaymentButtonClicked=false;        
            showDiscountErrorMsg=0;
            if(isSkipStep3 && presalesAccepted){
                currentStep=STEP_PHPI_INFORMATION;
                isStep2ValidationCalled=false;
            }else if(!isSkipStep3 && presalesAccepted){
                currentStep=STEP_BENEFICIARY_INFORMATION;
            }else{
                currentStep=STEP_UW_INFORMATION;
            }
            //add by kermit start
            policyTransaction.Status__c='Pending AUW';
            policyTransaction.Step__c=String.valueOf(currentStep);
            upsert policyTransaction;
            //add by kermit end
        }else if(isInStep(STEP_UW_INFORMATION)){
            if(isSkipStep3){
                currentStep=STEP_PHPI_INFORMATION;
                isStep2ValidationCalled=false;
            }else{
                currentStep=STEP_BENEFICIARY_INFORMATION;
            }
        }else if(isInStep(STEP_BENEFICIARY_INFORMATION)){
            currentStep=STEP_PHPI_INFORMATION;
            isStep2ValidationCalled=false;
        }else if(isInStep(STEP_PHPI_INFORMATION)){
            currentStep=STEP_POLICY_INFORMATION;
            isStep2ValidationCalled=false;
        }
        previousStepInit();//GL31 jack add
        //System.debug('[TMCreatePolicyCtrl] previousStep().after back step:'+currentStep);
    }
    //GL31 jack add
    public void previousStepInit(){
        if(isInStep(STEP_PHPI_INFORMATION)){
            //initAssessRider(this.opp.Prod_Rider_Map__c,this.selectedProduct.Product_Code__c,this);//GL31 jack add
            initAssessRider();//GL31 Tovid add
        }
    }
    public PageReference backToPaymentStatus(){
        isComplete=false;
        // TM Work at Home : recover data
        if(orgnDataBeforeMask.workAtHome){
            deMaskSensiData();
        }
        saveByNext(true);
        // TM Work at Home : recover data
        if(orgnDataBeforeMask.workAtHome){
            maskSensiData();
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Policy application is stopped.'));
        return null;
    }

    public void onProductChange(){
        //System.debug('[TMCreatePolicyCtrl] onProductChange().newPolicy.Product__c='+newPolicy.Product__c);
        Product__c prod=productMap.get(newPolicy.Product__c);       
        initPolicy();
        initIndicator=true;

        //add by jack for policy replacement
        showPolicyReplacement=false;
        if (String.isNotBlank(newPolicy.Product_Code__c) && productCodeSet.contains(newPolicy.Product_Code__c)){
            showPolicyReplacement=true;
        }else{
            policyTransaction.PolicyReplacement__c=null;
        }
    }
    
    public void onAmountOfPIChange(){
        //System.debug('[TMCreatePolicyCtrl] onAmountOfPIChange().amountOfPI：'+amountOfPI);
        //System.debug('[TMCreatePolicyCtrl] onAmountOfPIChange().personInsuredStructureList.size：'+personInsuredStructureList.size());
        initPolicy();
        //initPersonInsuredInfo();        
    }
        
    public Class PersonInsuredStructure{
        // Rancho_HKITSFDC402_20250930 - allow user to input sum insured for CI product
        public String sumInsured{get;set;}
        public String parentPolicyNumber{get;set;}
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        public String discount1{get;set;}
        public String discount2{get;set;}   
        public String discountErrorMsg{get;set;}
        public Integer showDiscountErrorMsg{get;set;}{showDiscountErrorMsg=0;}
        public String selectedRefund{get;set;}
        public String refundErrorMessage{get;set;}
        public Integer showRefundErrorMessage{get;set;}{showRefundErrorMessage=0;}
        public Boolean selectFamilyDiscount{get;set;}
        public String referralMobile{get;set;}
        public String referralPolicyNum{get;set;}
        public Map<String,Coupon> couponMap{get;set;}//AM project coupon jack add for Coupon
        // public Boolean displayCouponTable{get;set;}
        public String newCouponNumber{get;set;}//AM project coupon jack add
        public String couponMsg{get;set;}{couponMsg='';}//AM project coupon jack add for display invalid message for coupon
        public New_Policy__c piPolicy{get;set;}
        public Person_Insured__c pi{get;set;}
        public List<BeneficiaryStruct> beneficiaryList{get;set;}
        //public UW_Result__c uwResult{get;set;}
        public String applicationId{get;set;}
        public String auwURL{get;set;}
        public String uwResultLastModifiedDate{get;set;}
        public String policyNumber{get;set;}
        public List<TMEsalesHelper.PreSalesResultMessage> presalesResultMsgList{get;set;}
        public List<String> reasonList{get;set;} {reasonList=new List<String>();}
        public TMPolicyUtil.PIValidationItem piValidationItem{get;set;}
        public String height{get;set;}
        public String heightInch{get;set;}
        public String weight{get;set;}
        public List<HttpCalloutVO.Policy> parentIDPolicylist{get;set;}
        public List<HttpCalloutVO.Policy> personalIDPolicylistFromWS{get;set;}{personalIDPolicylistFromWS=new List<HttpCalloutVO.Policy>();}
        public String personalIDCache {get;set;}

        public List<String> selectedRiderCodes{get;set;}
        public List<String> removedRiderCodes{get;set;}
        public Map<String,String> availableRidersMap;
        public Map<String,String> selectedRidersMap;
        public String forDisplayedRiders{get;set;}
        //public Map<String,List<String>> benefitlevelRidersMap{get;set;}//Map<benefitlevel ,List<riderCode>>(),user for product SP100 and DMBG
        public List<AvailableRiderBenefitlevelItem> availableRiderBenefitlevelItemList{get;set;}//
        
        public Map<String,Boolean> availableDiscountMap;//Map(discountCode,isAvailable )
        public Boolean displayParentPIId{get{
            return ('Dependent'.equals(pi.Insured_Type__c) && ('Son'.equals(pi.Relationship__c) || 'Daughter'.equals(pi.Relationship__c)));
        }set;}        
        //Add by Manuel for VHIS
        public Boolean displaySpousePIId{get{
            return ('Spouse'.equals(pi.Insured_Type__c) && ('Spouse'.equals(pi.Relationship__c)));
        }set;}
        
        public Boolean isParentPIIdMandatory{get;set;}{isParentPIIdMandatory=false;}
        //public boolean isSkipStep4And5ForPI{get;set;}{isSkipStep4And5ForPI=false;}
        public String portableWardLevelFromWS {get;set;}
        public Integer portableWardLevelFromWSInt {get;set;}        
        public String PIDefaultMasterPolicyNum;// add by kermit for master_policy_no__c issue        
        public Boolean isSpecialProductShowBMIInd{get;set;} // add by kermit for TMC product BMI change
        public Boolean isReplacement {get;set;}// add by jack for policy replacement        
        //TM Work at Home
        public Boolean isCopyHolder {get;set;}        // person insured is copied from policy holder. click copy holder button
        public Boolean iscopyHlderAddress {get;set;}   // person insured residential address is copied from policy holder. Copy Holder Address button
        public Boolean isCopyCrspdAddress {get;set;} // copyCorrespondingAddress function. click Copy Address button on holder panel
        
        //Combo product: To determine display the declaration field
      public Boolean isCCAGSelected{get;set;} //Cancer Health
      public Boolean isCADGSelected{get;set;} //Accident
        //Combo declaration
        public String declaRiderCode {get;set;}
      //Combo product: To determine display the declaration field

        public String assessAvailableRider {get;set;}//GL31 jack add
        public PersonInsuredStructure(){
            beneficiaryList=new List<BeneficiaryStruct>();
            beneficiaryList.add(new BeneficiaryStruct());
            //uwResult=new UW_Result__c();
            pi=new Person_Insured__c();
            availableDiscountMap=new Map<String,Boolean>();
            height=String.valueOf(pi.Height__c);
            weight=String.valueOf(pi.Weight__c);
            heightInch=String.valueOf(pi.Height_Inch__c);
            
            selectedRiderCodes=new List<String>();
            removedRiderCodes=new List<String>();
            availableRidersMap=new Map<String,String>();
            selectedRidersMap=new Map<String,String>(); 
            //benefitlevelRidersMap=new Map<String,List<String>>();
            availableRiderBenefitlevelItemList=new List<AvailableRiderBenefitlevelItem>();
            forDisplayedRiders='';
            piValidationItem=new TMPolicyUtil.PIValidationItem();
            isSpecialProductShowBMIInd=false;// add by kermit for TMC product BMI change
            
            //Combo product
            isCCAGSelected=false;
            isCADGSelected=false;
            //Combo declaration
            declaRiderCode='';
            //Combo product
            assessAvailableRider='';//GL31 jack add
        }
        
        public PersonInsuredStructure(List<BeneficiaryStruct> benePara,Person_Insured__c piPara,New_Policy__c policyPara,Map<String,List<HttpCalloutVO.Rider>> riderMap,Map<String,Map<String,Set<String>>>  riderCodeBenefitLevelListMap,Map<String,HttpCalloutVO.Benefit> benefitMap){//GL31 jakc add
            //this();
            beneficiaryList=benePara;
            //the below object initialization is in the method initRiderRelated4PI()
            selectedRiderCodes=new List<String>();           
            removedRiderCodes=new List<String>();
            availableRidersMap=new Map<String,String>();//map(riderCode,riderName)
            selectedRidersMap=new Map<String,String>();
            //benefitlevelRidersMap=new Map<String,List<String>>();
            availableRiderBenefitlevelItemList=new List<AvailableRiderBenefitlevelItem>();
            forDisplayedRiders='';
            pi=piPara;
            policyNumber=policyPara.Policy_No__c;
            piPolicy=policyPara;
            availableDiscountMap=new Map<String,Boolean>();
            piValidationItem=new TMPolicyUtil.PIValidationItem();
            height=String.valueOf(pi.Height__c);
            weight=String.valueOf(pi.Weight__c);
            heightInch=String.valueOf(pi.Height_Inch__c);
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            if(String.isNotBlank(policyPara.Discount_1__c)){
                discount1=policyPara.Discount_1__c;
            }
            if(String.isNotBlank(policyPara.Discount_2__c)){
                if(String.isBlank(discount1)){
                    discount1=policyPara.Discount_2__c;
                }else if(String.isBlank(discount2) && discount1!=policyPara.Discount_2__c){
                    discount2=policyPara.Discount_2__c;
                }
            }
            if(String.isNotBlank(policyPara.Refund_Discount__c)){
                selectedRefund=policyPara.Refund_Discount__c;
            }
            // Rancho_HKITSFDC402_20250930 - set value for sum insured
            String tempSumInsured = null!=policyPara.Sum_Insured__c ? String.valueOf(policyPara.Sum_Insured__c) : null;
            sumInsured = String.isNotBlank(tempSumInsured) ? tempSumInsured.substringBefore('.') : null;
            parentPolicyNumber = policyPara.SI_Referral_Policy_No__c;
            //personalIDCache=pi.Personal_ID__c;
            /**
            if(null!=uwResultList && !uwResultList.isEmpty()){
                presalesResultMsgList=TMPolicyUtil.preSalesResultMsgBuild(uwResultList[0].PreSales_Result_Msg__c);
                uwResult=uwResultList[0];
                applicationId=uwResultList[0].Application_Id__c;
            }
            **/
            presalesResultMsgList=TMPolicyUtil.preSalesResultMsgBuild(policyPara.PreSales_Result_Msg__c);
            applicationId=policyPara.Application_Id__c;                                          
                                          
            if(null!=riderMap){
                List<String> allRiderCodes=new List<String>();
                Map<String,String> allRiders=new Map<String,String>();
                if(!this.pi.Benefit_Level__c.isNumeric()){
                    this.pi.Benefit_Level__c=hex2DecMap.get(this.pi.Benefit_Level__c);
                }

                List<HttpCalloutVO.Rider> initVORiderList=riderMap.get(this.pi.Benefit_Level__c);
                //System.debug('andy add the debug,initVORiderList='+initVORiderList);
                //System.debug('andy add the debug,this.pi.Benefit_Level__c='+this.pi.Benefit_Level__c);
                if(null!=initVORiderList){                   
                    for(HttpCalloutVO.Rider riderVO: initVORiderList){
                        allRiders.put(riderVO.riderCode,riderVO.riderName);
                        allRiderCodes.add(riderVO.riderCode);
                    }
                    //List<String> riderList=String.isNotEmpty(this.pi.Rider__c)?this.pi.Rider__c.split(';'):new List<String>();
                    List<String> riderList=TMPolicyUtil.getRiderCodeList(this.pi.Rider__c);
                    this.initRiderRelated4PI(allRiderCodes,allRiders,riderList,policyPara.product_code__c,riderCodeBenefitLevelListMap,benefitMap);//GL31 jakc add
                }
            }            
            if(policyPara.Referral_Exclusion_Reason__c!=null){
                reasonList=policyPara.Referral_Exclusion_Reason__c.split(';');
            }                                          
            isSpecialProductShowBMIInd=false;// add by kermit for TMC product BMI change
            
            //Combo product: show health declaration checkbox on PI page
            //System.debug('[TMCreatePolicyCtrl] personInsuredStructure piPara.Rider__c='+piPara.Rider__c);
            //System.debug('[TMCreatePolicyCtrl] personInsuredStructure piPolicy.Product_code__c='+piPolicy.Product_code__c);
            isCCAGSelected=false;
            isCADGSelected=false;
            //Combo declaration
            declaRiderCode='';
            if(String.isNotBlank(piPara.Rider__c) && piPara.Rider__c.contains('CCAG')){
                isCCAGSelected=true;
                //Combo declaration
                declaRiderCode='CCAG';
                disableRiderItem();
            }
            if(String.isNotBlank(piPara.Rider__c) && piPara.Rider__c.contains('CADG')){
                isCADGSelected=true;
                //Combo declaration
                declaRiderCode='CADG';
                disableRiderItem();
            }
            //System.debug('[TMCreatePolicyCtrl] personInsuredStructure isCCAGSelected='+isCCAGSelected);                    
            //System.debug('[TMCreatePolicyCtrl] personInsuredStructure isCADGSelected='+isCADGSelected); 
            //Combo product
        }
        
        public void initRiderRelated4PI(List<String> allRiderCodes,Map<String,String> allRiders,List<String> existingRiderCode,String productCode,Map<String,Map<String,Set<String>>>  riderCodeBenefitLevelListMap,Map<String,HttpCalloutVO.Benefit> benefitMap){//GL31 jakc add            
            List<String> availableRiderCodes=new List<String>();
            availableRidersMap.clear();
            selectedRidersMap.clear();
            //benefitlevelRidersMap.clear();
            availableRiderBenefitlevelItemList.clear();
            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().existingRiderCode='+existingRiderCode);
            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().allRiders='+allRiders);
            if(SPECIAL_RIDER_PRODUCTCODE.contains(productCode) || SPECIAL_RIDER_PRODUCTCODE2.contains(productCode) || '@SP100;SP100'.contains(productCode)){
                for(String riderCode : allRiderCodes){
                    if(existingRiderCode.contains(riderCode)){
                        availableRiderCodes.add(riderCode);
                    }                
                }
            }else{
                for(String riderCode : allRiderCodes){
                    if(!existingRiderCode.contains(riderCode)){
                        availableRiderCodes.add(riderCode);
                    }                
                }
            }
            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().availableRiderCodes='+availableRiderCodes);
            for(String riderCode : existingRiderCode){
                if(allRiders.containsKey(riderCode)){
                    selectedRidersMap.put(riderCode,allRiders.get(riderCode));
                    forDisplayedRiders+=allRiders.get(riderCode)+';';//to display the riderName instead of the riderCode on the page
                }
            }
            for(String riderCode : availableRiderCodes){
                if(allRiders.containsKey(riderCode)){
                    availableRidersMap.put(riderCode,allRiders.get(riderCode));
                }
            }
            
            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().availableRidersMap='+availableRidersMap);
            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().productCode='+productCode);
            if(SPECIAL_RIDER_PRODUCTCODE.contains(productCode) || SPECIAL_RIDER_PRODUCTCODE2.contains(productCode) || '@SP100;SP100'.contains(productCode)){
                //initialize ridercode,ridername
                for(String riderCode : allRiders.keySet()){
                    AvailableRiderBenefitlevelItem ai=new AvailableRiderBenefitlevelItem();
                    ai.riderName=allRiders.get(riderCode);
                    ai.selectedRiderCode=riderCode;
                    availableRiderBenefitlevelItemList.add(ai);
                }
                //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().pi.Rider__c='+pi.Rider__c);
                //initialize plan level of each rider
                if(String.isNotEmpty(this.pi.Rider__c)){
                    List<String> riderCodes=this.pi.Rider__c.split(';');
                    Integer k=0;
                    while(null!=riderCodes && k<riderCodes.size()){
                        if(riderCodes.get(k).contains(':')){
                            String[] benefitLevelRiderCode=riderCodes.get(k).split(':');
                            for(AvailableRiderBenefitlevelItem ai : availableRiderBenefitlevelItemList){
                                if(ai.selectedRiderCode==benefitLevelRiderCode[1]){
                                    ai.benefitlevel=benefitLevelRiderCode[0];
                                    break;
                                }
                            }
                        }else{//Adapt old data: OPTG;MATG;SLG
                            for(AvailableRiderBenefitlevelItem ai : availableRiderBenefitlevelItemList){
                                if(ai.selectedRiderCode==riderCodes.get(k)){
                                    if(!this.pi.Benefit_Level__c.isNumeric()){
                                        this.pi.Benefit_Level__c=hex2DecMap.get(this.pi.Benefit_Level__c);
                                    }
                                    ai.benefitlevel=this.pi.Benefit_Level__c;
                                    break;
                                }
                            }
                        }
                        ++k;
                    }
                }
                //initialize rider's plan level selectOptions
                //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().pi.Benefit_Level__c='+pi.Benefit_Level__c);
                //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().benefitMap.keySet()='+benefitMap.keySet());
                
                for(AvailableRiderBenefitlevelItem ai : availableRiderBenefitlevelItemList){
                    ai.benefitLevelOption=new List<SelectOption>();
                    ai.benefitLevelOption.add(new SelectOption('','--None--'));
                    if(SPECIAL_RIDER_PRODUCTCODE.contains(productCode)){//SP100,DMBG can match all benefitlevel,no limitation
                        for(String key : benefitMap.keySet()){
                            ai.benefitLevelOption.add(new SelectOption(key,benefitMap.get(key).benefitLevelName));
                        }
                    }else{// PBTG has limitation with optional benefitlevel
                        if(riderCodeBenefitLevelListMap.containsKey(ai.selectedRiderCode)){
                            String piBenefitLevel;
                            if(null==pi.Benefit_Level__c){
                                for(String key : benefitMap.keySet()){
                                    piBenefitLevel=key;
                                    break;
                                }
                            }else{ // Combo: add "{}" block with else. to aviod piBenefitLevel=pi.Benefit_Level__c;line code
                                if(!pi.Benefit_Level__c.isNumeric()){
                                    pi.Benefit_Level__c=hex2DecMap.get(pi.Benefit_Level__c);
                                } 
                                piBenefitLevel=pi.Benefit_Level__c;
                            }
                            
                            Set<String> availableBenefitLevelSet=riderCodeBenefitLevelListMap.get(ai.selectedRiderCode).get(piBenefitLevel);
                            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().riderCodeBenefitLevelListMap='+riderCodeBenefitLevelListMap);
                            //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().pi.Benefit_Level__c='+pi.Benefit_Level__c);
                            if(null!=availableBenefitLevelSet && availableBenefitLevelSet.size()>0){
                                List<String> availableBenefitLevelList=new List<String>(availableBenefitLevelSet);
                                availableBenefitLevelList.sort();
                                /**
                                Iterator<String> it=availableBenefitLevelSet.iterator();
                                while(it.hasNext()){
                                    String benefitlevel=it.next();
                                    ai.benefitLevelOption.add(new SelectOption(benefitlevel,benefitMap.get(benefitlevel).benefitLevelName));
                                }
                                **/

                                //Combo product: only has one benefit level. will get exception out of list index if using benefitMap --2020-09-18
                                system.debug('productCode:'+productCode);
                                if('@CBOG'==productCode||'@ABAG'==productCode||'@ABEG'==productCode){//jack add for AM project Bespoke product
                                    for(String benefitlevel : availableBenefitLevelList){
                                        ai.benefitLevelOption.add(new SelectOption(benefitlevel,benefitlevel+': '+ai.riderName));
                                    }
                                }else{
                                    for(String benefitlevel : availableBenefitLevelList){
                                        ai.benefitLevelOption.add(new SelectOption(benefitlevel,benefitMap.get(benefitlevel).benefitLevelName));
                                    }
                                }
                                //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().availableBenefitLevelList='+availableBenefitLevelList);
                                //System.debug('[TMCreatePolicyCtrl] initRiderRelated4PI().ai.benefitLevelOption='+ai.benefitLevelOption);
                            }                        
                        }
                    }
                }
            }//end first if
            //GL31 jakc add
            // Map<String,String> AvailRiderMap=getAvailRiderMap(productCode);
            // this.initAssessRider(prodRiderMapS,productCode,availRiderMap);
        }
        
        public void addRiderBtn(){           
            for(String riderCode : selectedRiderCodes){
                if(String.isNotBlank(riderCode)){
                    selectedRidersMap.put(riderCode,availableRidersMap.get(riderCode));
                    availableRidersMap.remove(riderCode);
                }
            }            
        }
        
        public void removeRiderBtn(){           
            for(String riderCode : removedRiderCodes){
                availableRidersMap.put(riderCode,selectedRidersMap.get(riderCode));
                selectedRidersMap.remove(riderCode);
            }
        }
        
        public void selectAvailableRider(){
            selectedRidersMap.clear();
            //benefitlevelRidersMap.clear();
            //System.debug('selectAvailableRider() availableRidersMap'+availableRidersMap);
            for(AvailableRiderBenefitlevelItem ai : availableRiderBenefitlevelItemList){
                if(String.isNotEmpty(ai.benefitlevel))
                    selectedRidersMap.put(ai.selectedRiderCode,availableRidersMap.get(ai.selectedRiderCode));               
            }
            //availableRiderBenefitlevelItemList.get(piIndexOfRider).;           
            
            //Combo product 
            //System.debug('[TMCreatePolicyCtrl] selectAvailableRider selectedRidersMap='+selectedRidersMap);
            if(selectedRidersMap.containsKey('CCAG')){
                isCCAGSelected=true;
                //Combo declaration
                declaRiderCode='CCAG';
                disableRiderItem();
            }else{
                if(isCCAGSelected && 'No'!=pi.Cancer_Declaration__c){
                    isCCAGSelected=false;
                }
            }
            
            if(selectedRidersMap.containsKey('CADG')){
                isCADGSelected=true;
                //Combo declaration
                declaRiderCode='CADG';
                disableRiderItem();
            }else{
                if(isCADGSelected && 'No'!=pi.Accident_Declaration__c){
                    isCADGSelected=false;
                }
            }
            //System.debug('[TMCreatePolicyCtrl] selectAvailableRider isCADGSelected='+isCADGSelected);
            //System.debug('[TMCreatePolicyCtrl] selectAvailableRider isCCAGSelected='+isCCAGSelected);
            //Combo product
        }
        
        public List<SelectOption> getAvailableRiders(){
            List<SelectOption> availabelRiders=new List<SelectOption>();
            //Owen_JOBR324_20230905 - hide special rider
            List<String> specialRider=Custom_Value__c.getInstance('Hide Product Rider').Value__c?.split(';');
            Map<String,String> hiddenRiderMap = new Map<String,String>();
            for(String i:specialRider){
                hiddenRiderMap.put(i,i);
            }
            for(String riderCode : availableRidersMap.keySet()){
                if(hiddenRiderMap.get(riderCode)==null){
                    availabelRiders.add(new SelectOption(riderCode,availableRidersMap.get(riderCode)));
                }
            }
            if(availabelRiders.isEmpty()){
                availabelRiders.add(new SelectOption('','--None--'));
            }
            return availabelRiders;
        }
        
        public List<SelectOption> getSelectedRiders(){
            List<SelectOption> selectedRiders=new List<SelectOption>();
            for(String riderCode : selectedRidersMap.keySet()){
                selectedRiders.add(new SelectOption(riderCode,selectedRidersMap.get(riderCode)));
            }
            return selectedRiders;
        }

        //Combo declaration
        // clear selected rider benefit level and disable this picklist if corrensponding declaration is selected No meaned declined
        public void disableRiderItem(){
            //System.debug(LoggingLevel.INFO,'[TMCreatePolicyCtrl] disableRiderItem().declaRiderCode : '+declaRiderCode);
            //System.debug(LoggingLevel.INFO,'[TMCreatePolicyCtrl] disableRiderItem() pi.Cancer_Declaration__c : '+pi.Cancer_Declaration__c);
            if('CCAG'==declaRiderCode){
                for(AvailableRiderBenefitlevelItem arbi : availableRiderBenefitlevelItemList){
                    if('CCAG'==arbi.selectedRiderCode && 'No'==pi.Cancer_Declaration__c){
                        arbi.benefitlevel='';
                        arbi.disableSelct=true;
                        selectedRidersMap.remove(arbi.selectedRiderCode);
                    }else if('CCAG'==arbi.selectedRiderCode && 'Yes'==pi.Cancer_Declaration__c){
                        arbi.disableSelct=false;
                    }else if('CCAG'==arbi.selectedRiderCode && String.isBlank(arbi.benefitlevel) && String.isBlank(pi.Cancer_Declaration__c)){
                        arbi.disableSelct=false;
                        // hidden declaration field when rider plab level=none && declaration=none
                        isCCAGSelected=false;
                    }
                    //System.debug(LoggingLevel.INFO,'[TMCreatePolicyCtrl] disableRiderItem() selectedRidersMap : '+selectedRidersMap);
                }
            }
            /* add by Jack on 2022-04-07 for project: Separation project - TM */
            // else if('CADG'==declaRiderCode){
            //     for(AvailableRiderBenefitlevelItem arbi : availableRiderBenefitlevelItemList){
            //         if('CADG'==arbi.selectedRiderCode && 'No'==pi.Accident_Declaration__c){
            //             arbi.benefitlevel='';
            //             arbi.disableSelct=true;
            //             selectedRidersMap.remove(arbi.selectedRiderCode);
            //         }else if('CADG'==arbi.selectedRiderCode && 'Yes'==pi.Accident_Declaration__c){
            //             arbi.disableSelct=false;
            //         }else if('CADG'==arbi.selectedRiderCode && String.isBlank(arbi.benefitlevel) && String.isBlank(pi.Accident_Declaration__c)){
            //             arbi.disableSelct=false;
            //             isCADGSelected=false;
            //         }

            //     }
            // }
 
        }

        //GL31 jack add get code -> name rider map
        public Map<String,String> getAvailRiderMap(String productCode){
            Map<String,String> result=new Map<String,String>();
            if(SPECIAL_RIDER_PRODUCTCODE.contains(productCode) || SPECIAL_RIDER_PRODUCTCODE2.contains(productCode) || '@SP100;SP100'.contains(productCode)){
                for(AvailableRiderBenefitlevelItem ai : availableRiderBenefitlevelItemList){
                    result.put(ai.selectedRiderCode,ai.riderName);
                }
            }else{
                result=availableRidersMap;
            }
            //System.debug('getAvailRiderMap result:'+result);
            return result;
        }
        
        public void initAssessRider(String proRiderMapS,String selectedProCode,Map<String,String> availRiderMap){
            //System.debug('proRiderMapS'+proRiderMapS);
            if(string.isNotBlank(proRiderMapS)){
                Map<String,Set<String>> proRiderMap=(Map<String,Set<String>>)JSON.deserialize(proRiderMapS,Map<String,Set<String>>.class);
                // List<TM_Product_Category__c> tmProcatList=TM_Product_Category__c.getAll().values();//jack add for friend and family discount in SFDC
                List<TM_Product_Category__c> tmProcatList=[Select Product_Code__c,Parent_Product__c,Name from TM_Product_Category__c where Module__c='Assessment Question'];//jack add for friend and family discount in SFDC
                Set<String> riderSet=CignaUtil.getAvailableRider(tmProcatList,proRiderMap,selectedProCode);
                if(riderSet!=null){
                    if(riderSet.contains('ALL')){
                        assessAvailableRider='ALL';
                    }else{
                        List<String> riderList=TMPolicyUtil.assessRiderValide(availRiderMap,String.join(new List<String>(riderSet),','),true);
                        assessAvailableRider=String.join(riderList,',');
                    }
                }
            }
            //System.debug('assessAvailableRider:'+assessAvailableRider);
        }
    }
    
    public Class BeneficiaryStruct{       
        public String PIName{get;set;}
        public Beneficiary__c beneficiary{get;set;}
        //TM Work at Home.  copy holder button on step 3
        // public Boolean isCopyHolder {get;set;}
        public String origPersonId {get;set;}
        
        public BeneficiaryStruct(){           
            beneficiary=new Beneficiary__c();
        }
        
        public BeneficiaryStruct(String newPIName,Id personInsuredId){           
            beneficiary=new Beneficiary__c();
            beneficiary.Person_Insured__c=personInsuredId;
            PIName=newPIName;
        }
        
        public BeneficiaryStruct(String newPIName){           
            beneficiary=new Beneficiary__c();
            PIName=newPIName;
        }
        
        public BeneficiaryStruct(String newPIName,Id personInsuredId,Beneficiary__c b){           
            beneficiary=new Beneficiary__c();
            beneficiary.Person_Insured__c=personInsuredId;
            PIName=newPIName;
            beneficiary=b;
        }
    }
    
    public Class AvailableRiderBenefitlevelItem{       
        public String selectedRiderCode{get;set;}
        public String benefitlevel{get;set;}
        public String riderName{get;set;}
        public List<SelectOption> benefitLevelOption{get;set;}
        //Combo declaration
        public Boolean disableSelct{get;set;}
    }
    
    public void addBenefit(){
        //System.debug(selectedPINoBNNum);
        List<String> piNoBNNum=selectedPINoBNNum.split(',');
        Integer piNo=Integer.valueOf(piNoBNNum.get(0));
        Integer BNNum=Integer.valueOf(piNoBNNum.get(1));        
        BeneficiaryStruct bsOld=personInsuredStructureList.get(piNo).beneficiaryList.get(BNNum);
        BeneficiaryStruct bs=new BeneficiaryStruct(bsOld.PIName,bsOld.beneficiary.Person_Insured__c);
        personInsuredStructureList.get(piNo).beneficiaryList.add(bs);
        //System.debug('>>>>>>>>>>>>>>>addBenefit End');
    }
    
    public void removeBenefit(){
        //System.debug(selectedPINoBNNum);
        List<String> piNoBNNum=selectedPINoBNNum.split(',');
        Integer piNo=Integer.valueOf(piNoBNNum.get(0));
        Integer BNNum=Integer.valueOf(piNoBNNum.get(1));
        BeneficiaryStruct  beneSt=personInsuredStructureList.get(piNo).beneficiaryList.remove(BNNum);
        if(null!=beneSt.beneficiary.id){
            Database.DeleteResult DR_Dels=Database.delete(beneSt.beneficiary.id,true);
            //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>deleteBeneficiary:'+DR_Dels);
        }        
        //System.debug('>>>>>>>>>>>>>>>removeBenefit End');
    }
    
    public Boolean isInStep(Integer s){
        return this.currentStep==s;
    }
    
    public void savePolicyTransaction(){        
        policyTransaction.Number_of_Person_Insured__c=amountOfPI;
        //policyTransaction.Product_Code__c=productCode;
        //policyTransaction.Product_Name__c=productMap.get(selectedProductId).Name;
        // add income_hkc_c and nationality by tovid 2021.04.30
        policyTransaction.Policy_Holder_Monthly_Income__c = newPolicy.Income_HKD__c;
        policyTransaction.Policy_Holder_Nationality__c = newPolicy.Nationality__c; 
        policyTransaction.Product_Code__c=productMap.get(newPolicy.Product__c).Product_Code__c;
        policyTransaction.Product_Name__c=productMap.get(newPolicy.Product__c).Name;
        policyTransaction.Step__c=String.valueOf(currentStep);
        List<Premium_discount__c> premiumDiscountTmpList=productIdPremiumDiscountMap.get(newPolicy.Product__c);
        policyTransaction.Selected_Campaign__c=productIdCampaignMap.get(selectedProduct.id).id;
        if(currentStep>3){
            if(currentStep<6){
                if(currentStep==4 && isComplete){
                    policyTransaction.Submission_Date_Time__c=DateTime.now();
                    if(!'RSM'.equals(selectedProduct.Product_Code__c))
                        policyTransaction.Effective_Date__c=Date.today().day()>28?Date.newInstance(Date.today().year(),Date.today().month(),28):Date.today();
                    policyTransaction.Status__c='Completed';
                    //policyTransaction.Submission_Date_Time__c=DateTime.now();
                }else{
                    policyTransaction.Status__c='Pending AUW';
                }                
            }else if(currentStep==6){
                if(isComplete){
                    policyTransaction.Submission_Date_Time__c=DateTime.now();                   
                    policyTransaction.Status__c='Completed';
                }else{
                    if(!'RSM'.equals(selectedProduct.Product_Code__c))
                        policyTransaction.Effective_Date__c=Date.today().day()>28?Date.newInstance(Date.today().year(),Date.today().month(),28):Date.today();
                    policyTransaction.Status__c='Pending Payment';
                }                
            }
        }else{
            policyTransaction.Status__c='Pending Basic Information';
        }
        upsert policyTransaction;
    }
    
    public void savePolicy(){
        //delete policy before insert
        if(!deletePolicyList.isEmpty()){
            Set<ID> polIdSet=new Set<ID>();
            for(New_Policy__c p : deletePolicyList){
                polIdSet.add(p.Id);
            }
            List<New_Policy__c> tempList=new List<New_Policy__c>();
            for(New_Policy__c p : [SELECT Id FROM NEW_Policy__c WHERE Id IN :polIdSet]){
                tempList.add(p);
            }
            deletePolicyList=tempList;
            if(!deletePolicyList.isEmpty()){
                Database.DeleteResult[] DR_Dels=Database.delete(deletePolicyList,true);
                //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>deletePolicy:'+DR_Dels);
                deletePolicyList.clear();
            }
        }
        //TMPolicyUtil.updateUWRelatedFieldsInPolicies(policyList);

        //AH19572 adjust gender
        if(String.isNotBlank(newPolicy.Gender__c)){
            newPolicy.Gender__c=adjustGender(newPolicy.Gender__c);
        }
        //System.debug('[TMCreatePolicyCtrl] savePolicy currentStep='+this.currentStep);
        for(PersonInsuredStructure pis : personInsuredStructureList){
            //System.debug('policy_no__c='+pis.piPolicy.policy_no__c+' application_id__c='+pis.piPolicy.Application_Id__c);
        }
                
        if(null==newPolicy.Policy_Transaction__c){
            newPolicy.Policy_Transaction__c=policyTransaction.Id;}       
        if(null==newPolicy.Account__c){
            newPolicy.Account__c=acc.Id;}
        if(null==newPolicy.Core_Campaign__c){
            newPolicy.Core_Campaign__c=policyTransaction.Core_Campaign__c;}
        if(null==newPolicy.Opportunity__c){
            newPolicy.Opportunity__c=policyTransaction.Opportunity__c;}

        //policy number will be created after clicking 'save' or 'next' step 2.Once created,the policy number cannot be changed again ，even though user changes the Product Code.
        if(String.isBlank(newPolicy.Policy_No__c) && currentStep>1){
            //Product__c pro=productMap.get(selectedProductId);
            Product__c pro=productMap.get(newPolicy.Product__c);
            //Add by Kermit at 20191216
            String tempKey=pro.Product_Code__c+newPolicy.Id;
            if(PolIdPolicyNoMap.get(tempKey)==null || initIndicator){
                //System.debug('[TMCreatePolicyCtrl] savePolicy() hit');
                newPolicy.Policy_No__c=TMPolicyUtil.generatePolicyNumber(pro.Policy_Prefix__c);
            }else{
                newPolicy.Policy_No__c=PolIdPolicyNoMap.get(tempKey);
            }
            //End add
            newPolicy.to_Save_Policy_No__c=newPolicy.Policy_No__c;
            //newPolicy.Master_Policy_No__c=newPolicy.Policy_No__c;
            newPolicy.IQ_ID__c=POLICY_IQ_ID;
            newPolicy.running_no__c=opp.Running_No__c;
            //newPolicy.Name=newPolicy.Policy_No__c;
        }
        
        //Retrive bank account no. & credit card number added by andy
        /* You have uncommitted work pending. Please commit or rollback before calling out
        if(String.isNotBlank(newPolicy.Personal_ID__c) && String.isBlank(newPolicy.Bank_Account_No__c) 
            && String.isBlank(newPolicy.Credit_Card_Number__c) && currentStep>2){
            
            PersonCalloutHelper personCalloutHelper=new PersonCalloutHelper();
            List<HttpCalloutVO.PersonPayment> personPaymentList=personCalloutHelper.getPersonPaymentBasic(newPolicy.Personal_ID__c);
            if(!personPaymentList.isEmpty()){
                HttpCalloutVO.PersonPayment pp=personPaymentList[0];
                newPolicy.Bank_Account_No__c=pp.accountNumber;
                newPolicy.Credit_Card_Number__c=pp.accountNumber;
            }
        }
        */
        
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            if(pis.piPolicy.Policy_No__c == newPolicy.Policy_No__c){
                // Using Premium Discount insteaded
                if(String.isNotBlank(pis.discount1)){
                    Premium_Discount__c discount1=premiumDiscountMap.get(pis.discount1);
                    if(discount1!=null){
                        newPolicy.Discount__c=discount1.Discount__c;
                        newPolicy.Discount_1__c=pis.discount1;
                    }
                }

                if(String.isNotBlank(pis.discount2)){
                    Premium_Discount__c discount2=premiumDiscountMap.get(pis.discount2);
                    if(discount2!=null){
                        newPolicy.Discount2__c=discount2.Discount__c;
                        newPolicy.Discount_2__c=pis.discount2;
                    }
                }

                if(String.isNotBlank(pis.selectedRefund)){
                    newPolicy.Refund_Discount__c=pis.selectedRefund;
                }

                // Rancho_HKITSFDC402_20250930 - set value for sum insured
                System.debug('save sum insured: ' + pis.sumInsured);
                newPolicy.Sum_Insured__c = TMPolicyUtil.isSafeStringToInteger(pis.sumInsured) ? Decimal.valueOf(pis.sumInsured) : null;
                newPolicy.SI_Referral_Policy_No__c = pis.parentPolicyNumber;

                break;
            }
        }
        if(String.isNotBlank(selectedPaymentFrequency)){
            newPolicy.Payment_Frequency__c=selectedPaymentFrequency;
        }
        if(String.isNotBlank(selectedPaymentType)){
            newPolicy.Payment_Type__c=selectedPaymentType;
            if(newPolicy.Payment_Type__c=='Cheque'){
                newPolicy.Bank_Account_No__c='';
                newPolicy.Bank_Account_No_Mask__c='';
                newPolicy.Credit_Card_Number__c='';
                newPolicy.Credit_Card_Number_Mask__c='';
            }
        }
        if(String.isNotBlank(selectedBank)){
            newPolicy.Bank_Name__c=selectedBank;
        }
        if(String.isNotBlank(selectedCreditCardBank)){
            newPolicy.Name_of_Card_Issuing_Bank__c=selectedCreditCardBank;
        }
        if(String.isNotBlank(selectedCardYear) && String.isNotBlank(selectedCardMonth)){
            newPolicy.Card_Expiry_Date_Text__c=selectedCardMonth+'/'+selectedCardYear;
        }
        //if(String.isBlank(newPolicy.Product_Code__c) || String.isBlank(newPolicy.Product_Name__c)){
        Product__c prod=this.productMap.get(newPolicy.Product__c);
        //newPolicy.Product__c=selectedProductId;
        newPolicy.Product_Code__c=prod.Product_Code__c;
        newPolicy.Product_Name__c=prod.Name;
        newPolicy.Plan_code__c=prod.Product_Code__c.replace('@','');
        //}
        newPolicy.Policy_Holder_Name__c=newPolicy.Policy_Holder_Last_Name__c+' '+newPolicy.Policy_Holder_First_Name__c;
        
        //change by andy for different policy status handling
        TMPolicyUtil.updatePolicyStatusSubmissionEffectiveDate(newPolicy,currentStep,selectedProduct.Product_Code__c,isComplete);
        List<Premium_discount__c> premiumDiscountTmpList=productIdPremiumDiscountMap.get(newPolicy.Product__c);
        newPolicy.Selected_Campaign__c=productIdCampaignMap.get(selectedProduct.id).id; 
        if(currentStep<6){
            newPolicy.Relationship_Of_Policy__c=TMPolicyUtil.getRelationshipOfPolicy(personInsuredStructureList.get(0));
        }
        
        // 20200717 - minghua - SF Modeling
        if('Credit Card Billing'.equals(selectedPaymentType)){
            newPolicy.Is_Masked_Payment_Info__c=false;
            newPolicy.Bank_Account_No__c='';
            newPolicy.Bank_Account_No_Mask__c='';
            String creditCardNumber=newPolicy.Credit_Card_Number__c;
            if (String.isNotBlank(creditCardNumber) && creditCardNumber.length()>8){
                if (creditCardNumber.contains('*') || creditCardNumber.contains('X')){
                    newPolicy.Is_Masked_Payment_Info__c=true;
                }
            }
        }
        if('Direct Billing'.equals(selectedPaymentType)){
            newPolicy.Credit_Card_Number__c='';
            newPolicy.Credit_Card_Number_Mask__c='';
        }
        
        if(currentStep==6 && isComplete){//only when clicking submit button,corresponding address should be filled
            newPolicy.Corresponding_Address_1__c=String.isEmpty(newPolicy.Corresponding_Address_1__c)?newPolicy.Residential_Address_1__c:newPolicy.Corresponding_Address_1__c;
            newPolicy.Corresponding_Address_2__c=String.isEmpty(newPolicy.Corresponding_Address_2__c)?newPolicy.Residential_Address_2__c:newPolicy.Corresponding_Address_2__c;
            newPolicy.Corresponding_Address_3__c=String.isEmpty(newPolicy.Corresponding_Address_3__c)?newPolicy.Residential_Address_3__c:newPolicy.Corresponding_Address_3__c;
            newPolicy.Corresponding_Address_4__c=String.isEmpty(newPolicy.Corresponding_Address_4__c)?newPolicy.Residential_Address_4__c:newPolicy.Corresponding_Address_4__c;                  
        }
        
        
        //for payment
        for(TMEsalesHelper.PremiumAmt pa : premiumAmountList){
            //System.debug('[TMCreatePolicyCtrl] savePolicy forpaymentloop current policyid='+pa.policyId+' subtotal='+pa.subTotal);
            if(pa.policyId==newPolicy.id && pa.isRider==false){
                newPolicy.Actual_Premium__c=pa.subTotal;
                newPolicy.Annual_Premium__c=pa.annualPremium;
                newPolicy.Amount__c=pa.subTotal;
                //newPolicy.Discount__c=totalPremium.totalDiscountPercent;
                newPolicy.Discount_Premium__c=pa.totalDiscountPremium;
                newPolicy.Loading__c=pa.medicalLoadingPercent;
                newPolicy.Loading_Amount__c=pa.medicalLoadingAmount;
                newPolicy.Original_Premium__c=pa.originalPremiumMonth;
                break;
            }
        }
        
        //Nicole_20200408_CDD
        if(policyTransaction.LC_Assessed__c=='Approved' && newPolicy.Missing_CDD_Info__c){
            newPolicy.Missing_CDD_Info__c=false;
        }
        
        //Jack JR1641
        //System.debug('TMCreatePolicyCtrl newPolicy.Is_Corr_Address_Country_Changed__c'+newPolicy.Is_Corr_Address_Country_Changed__c);
        if(( newPolicy.Is_Corr_Address_Country_Changed__c==false || String.isBlank(newPolicy.Corresponding_Address_Country__c) )&& String.isBlank(newPolicy.Corresponding_Address_1__c) && String.isBlank(newPolicy.Corresponding_Address_2__c) && String.isBlank(newPolicy.Corresponding_Address_3__c) && String.isBlank(newPolicy.Corresponding_Address_4__c) && String.isNotBlank(newPolicy.Residential_Address_Country__c)){
            newPolicy.Corresponding_Address_Country__c=newPolicy.Residential_Address_Country__c;
        }
        
        //upsert newPolicy;
        //SPS-417
        try{
            upsert newPolicy;
            //System.debug('[TMCreatePolicy] savePolicy after upsert newPolicy.Application_Id__c='+newPolicy.Application_Id__c);
        }catch(DmlException e){
            //System.debug('[TMCreatePolicyCtrl] save() e.getMessage:'+e.getMessage());
            if(e.getMessage().contains('duplicates value')){
                Product__c pro=productMap.get(newPolicy.Product__c);
                newPolicy.Policy_No__c=TMPolicyUtil.generatePolicyNumber(pro.Policy_Prefix__c);
                newPolicy.Unexpected__c=true;
                //System.debug('[TMCreatePolicyCtrl] regenerate policy num:'+newPolicy.Policy_No__c);
                upsert newPolicy;
            }
        }
        //SPS-417
        
        Integer i=0;
        //List<new_policy__c> toSavePolicyList=new List<new_policy__c>();
        for(new_policy__c policy : policyList){
            if(i==0){
                policy=newPolicy;//the first policy in policylist is referenced to newPolicy 
            }else{

                //AH19572 adjust gender
                if(String.isNotBlank(policy.Gender__c)){
                    policy.Gender__c=adjustGender(policy.Gender__c);
                }

                TMPolicyUtil.copyPolicyNotNull(newPolicy,policy);
                if(null==policy.Policy_Transaction__c)
                    policy.Policy_Transaction__c=policyTransaction.id;
                if(null==policy.Core_Campaign__c)
                    policy.Core_Campaign__c=policyTransaction.Core_Campaign__c;
                if(null==policy.Account__c)
                    policy.Account__c=policyTransaction.Account__c;
                if(null==policy.Opportunity__c)
                    policy.Opportunity__c=policyTransaction.Opportunity__c;
                policy.Selected_Campaign__c=productIdCampaignMap.get(selectedProduct.id).id;
                if(String.isBlank(policy.Policy_No__c) && currentStep>1){
                    Product__c pro=productMap.get(newPolicy.Product__c);
                    //Add by Kermit at 20191216
                    String tempKey=pro.Product_Code__c+policy.Id;
                    if(PolIdPolicyNoMap.get(tempKey)==null || initIndicator){
                        policy.Policy_No__c=TMPolicyUtil.generatePolicyNumber(pro.Policy_Prefix__c);
                    }else{
                        policy.Policy_No__c=PolIdPolicyNoMap.get(tempKey);
                    }
                    policy.to_Save_Policy_No__c=policy.Policy_No__c;
                    //End add
                    policy.running_no__c=opp.Running_No__c;
                    policy.IQ_ID__c=POLICY_IQ_ID;
                    //policy.Master_Policy_No__c=policy.Policy_No__c;
                }
                if(i<personInsuredStructureList.size()){
                    if(personInsuredStructureList.get(i).pi.PI_Age__c>18){
                        policy.Plan_Type__c='A';
                    }else{
                        policy.Plan_Type__c='C';
                    }
                    if(currentStep<6){
                        policy.Relationship_Of_Policy__c=TMPolicyUtil.getRelationshipOfPolicy(personInsuredStructureList.get(i));
                    }                   
                }

                // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
                for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                    if(pis.piPolicy.Policy_No__c == policy.Policy_No__c){
                        if(String.isNotBlank(pis.discount1)){
                            Premium_Discount__c discount1=premiumDiscountMap.get(pis.discount1);
                            if(discount1!=null){
                                policy.Discount__c=discount1.Discount__c;
                                policy.Discount_1__c=pis.discount1;
                            }
                        }
        
                        if(String.isNotBlank(pis.discount2)){
                            Premium_Discount__c discount2=premiumDiscountMap.get(pis.discount2);
                            if(discount2!=null){
                                policy.Discount2__c=discount2.Discount__c;
                                policy.Discount_2__c=pis.discount2;
                            }
                        }

                        // Rancho_HKITSFDC402_20250930 - set value for sum insured
                        policy.Sum_Insured__c = TMPolicyUtil.isSafeStringToInteger(pis.sumInsured) ? Decimal.valueOf(pis.sumInsured) : null;
                    }
                }

                //change by andy for different policy status handling
                TMPolicyUtil.updatePolicyStatusSubmissionEffectiveDate(policy,currentStep,selectedProduct.Product_Code__c,isComplete);
                for(TMEsalesHelper.PremiumAmt pa : premiumAmountList){
                    //System.debug('[TMCreatePolicyCtrl] savePolicy after handling policy status loop current policyid='+pa.policyId+' subtotal='+pa.actualPremium+' isRider='+pa.isRider);
                    if(pa.policyId==policy.id && pa.isRider==false){
                        //policy.Actual_Premium__c=pa.actualPremium;
                        policy.Actual_Premium__c=pa.subTotal;
                        policy.Annual_Premium__c=pa.annualPremium;
                        policy.Amount__c=pa.subTotal;
                        //newPolicy.Discount__c=totalPremium.totalDiscountPercent;
                        policy.Discount_Premium__c=pa.totalDiscountPremium;
                        policy.Loading__c=pa.medicalLoadingPercent;
                        policy.Loading_Amount__c=pa.medicalLoadingAmount;
                        policy.Original_Premium__c=pa.originalPremiumMonth;
                        break;
                    }
                }  
                
                if(String.isNotBlank(newPolicy.Asia_Miles_Membership_Num__c) && String.isBlank(policy.Asia_Miles_Membership_Num__c)){
                    policy.Asia_Miles_Membership_First_Name__c=newPolicy.Asia_Miles_Membership_First_Name__c;
                    policy.Asia_Miles_Membership_Last_Name__c=newPolicy.Asia_Miles_Membership_Last_Name__c;
                    policy.Asia_Miles_Membership_Num__c=newPolicy.Asia_Miles_Membership_Num__c;
                }
            }
            ++i;
        }
        //upsert toSavePolicyList;       
        
        //first time to generate default Master_Policy_No__c
        if(null==defaultMasterPolicyNum && currentStep>2){           
            for(PersonInsuredStructure pis : personInsuredStructureList){
                if('PH = PI'.equalsIgnoreCase(pis.pi.Insured_Type__c)){
                    defaultMasterPolicyNum=pis.piPolicy.policy_no__c;
                    break;
                }
            }
            for(PersonInsuredStructure pis : personInsuredStructureList){
                if(String.isEmpty(pis.piPolicy.Master_Policy_No__c)){
                    pis.piPolicy.Master_Policy_No__c=null==defaultMasterPolicyNum?pis.piPolicy.policy_no__c:defaultMasterPolicyNum;
                    pis.PIDefaultMasterPolicyNum=pis.piPolicy.Master_Policy_No__c;// add by kermit 
                    //DPSP-571 : last comment,for RSM application,maturity policy number of the account=master policy number
                    TMProductStrategyRSM.setMasterPolicyNumberFromAccMaturityPolicyNum(acc.Maturity_Policy_Number__c,pis);
                }               
            }
            
        }        
        //if user click save/submit after step6,master policy no will be saved into Master_Policy_No_Saved__c
        //if Master_Policy_No_Saved__c is null,Master_Policy_No__c will be generated every time users reach Step6
        if(currentStep>=STEP_CONFIRMATION_PAYMENT){
            for(PersonInsuredStructure pis : personInsuredStructureList){
                if(String.isBlank(pis.piPolicy.Master_Policy_No__c) && String.isBlank(pis.piPolicy.Master_Policy_No_Saved__c)){
                    pis.piPolicy.Master_Policy_No__c=pis.piPolicy.Policy_No__c;
                }
                if(String.isNotBlank(pis.piPolicy.Master_Policy_No__c)){
                    pis.piPolicy.Master_Policy_No_Saved__c=pis.piPolicy.Master_Policy_No__c;
                }
            }
        }
        
        //upsert policyList;
        //System.debug('[TMCreatePolicyCtrl] policyList='+policyList);
        //SPS-417
        try{
            upsert policyList;
        }catch(DmlException e){
            //System.debug('[TMCreatePolicyCtrl] save() upsert policyList e.getMessage:'+e.getMessage());
            if(e.getMessage().contains('duplicates value')){
                Product__c pro=productMap.get(newPolicy.Product__c);
                for(New_Policy__c np : policyList){
                    np.Policy_No__c=TMPolicyUtil.generatePolicyNumber(pro.Policy_Prefix__c);
                    np.UnExpected__c=true;
                    //System.debug('[TMCreatePolicyCtrl] regenerate policyList policy num np.Policy_No__c='+np.Policy_No__c);
                }
                upsert policyList;
            }
        }
        //SPS-417
        
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(!Test.isRunningTest()){PolIdPolicyNoMap.put(pis.piPolicy.product_code__c+pis.piPolicy.Id,pis.piPolicy.Policy_No__c);}
        }        
        initIndicator=false;
        //System.debug('[TMCreatePolicyCtrl] savePolicy() PolIdPolicyNoMap='+this.PolIdPolicyNoMap);
    }
    
    public void savePersonInsuredInfo(){       
        if(!deletePersonInsuredList.isEmpty()){
            Database.DeleteResult[] DR_Dels=Database.delete(deletePersonInsuredList,true);
            //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>deletePolicy:'+DR_Dels);
            deletePersonInsuredList.clear();
        }
        
        List<Person_Insured__c> piList=new List<Person_Insured__c>();
        List<Beneficiary__c> benList=new List<Beneficiary__c>();
        //List<UW_Result__c> uwResultList=new List<UW_Result__c>();
        //fill the field of the PI
        Integer i=0;
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(null==pis.pi.New_Policy__c){
                pis.pi.New_Policy__c=policyList.get(i).id;
            }
            if(null==pis.policyNumber){
                pis.policyNumber=policyList.get(i).Policy_No__c;
            }
            //save rider
            pis.pi.Rider__c='';
            pis.forDisplayedRiders='';
            if(SPECIAL_RIDER_PRODUCTCODE.contains(selectedProduct.Product_Code__c) || SPECIAL_RIDER_PRODUCTCODE2.contains(selectedProduct.Product_Code__c)){
                for(AvailableRiderBenefitlevelItem ai : pis.availableRiderBenefitlevelItemList){
                    if(String.isNotEmpty(ai.benefitlevel)){
                        if(String.isEmpty(pis.pi.Rider__c)){
                            pis.pi.Rider__c+=ai.benefitlevel+':'+ai.selectedRiderCode;
                        }else{
                            pis.pi.Rider__c+=';'+ai.benefitlevel+':'+ai.selectedRiderCode;
                        }
                        //System.debug('[TMCreatePolicyCtrl] savePersonInsuredInfo pis.availableRidersMap='+pis.availableRidersMap);
                        //System.debug('[TMCreatePolicyCtrl] savePersonInsuredInfo ai.selectedRiderCode='+ai.selectedRiderCode);
                        //System.debug('[TMCreatePolicyCtrl] savePersonInsuredInfo ai.riderName='+ai.riderName);
                        //add by jack for policy replacement fixing @KIDSL do not display rider in payment step begin
                        //Combo: availableRidersMap only has no-selected rider so pis.availableRidersMap.get(ai.selectedRiderCode) get null value
                        // it should use selectedRidersMap
                        if(selectedProduct.Product_Code__c=='@KIDSL' || selectedProduct.Product_Code__c=='@CBOG'){
                            if(String.isEmpty(pis.forDisplayedRiders)){
                                pis.forDisplayedRiders+=ai.riderName;
                            }else{
                                pis.forDisplayedRiders+=';'+ai.riderName;
                            }
                        }else{
                            if(String.isEmpty(pis.forDisplayedRiders)){
                                pis.forDisplayedRiders+=pis.availableRidersMap.get(ai.selectedRiderCode);
                            }else{
                                pis.forDisplayedRiders+=';'+pis.availableRidersMap.get(ai.selectedRiderCode);
                            }
                        }
                        //add by jack for policy replacement fixing @KIDSL do not display rider in payment step end
                    }
                }
            }else{
                for(String riderCode : pis.selectedRidersMap.keySet()){
                    if(String.isNotEmpty(pis.pi.Rider__c)){
                        pis.pi.Rider__c+=';'+pis.pi.Benefit_Level__c+':'+riderCode;
                    }else{
                        pis.pi.Rider__c+=pis.pi.Benefit_Level__c+':'+riderCode;                       
                    }                    
                    String riderName=pis.selectedRidersMap.get(riderCode);
                    pis.forDisplayedRiders+=(String.isNotEmpty(riderName)?riderName:'') +';';
                }
            }
            //System.debug('[TMCreatePolicyCtrl] savePersonInsuredInfo pis.forDisplayedRiders'+pis.forDisplayedRiders);
            //System.debug('[TMCreatePolicyCtrl] savePersonInsuredInfo pis.pi.Rider__c'+pis.pi.Rider__c);
            pis.pi.Person_Insured_Name__c=pis.pi.Insured_Last_Name__c+' '+pis.pi.Insured_First_Name__c;
            //pis.pi.Person_Insured_Name__c=pis.pi.Name;

            //AH19572 adjust gender
            if(String.isNotBlank(pis.pi.Gender__c)){
                pis.pi.Gender__c=adjustGender(pis.pi.Gender__c);
            }

            if(pis.pi.Date_of_Birth__c!=null){               
                pis.pi.PI_Age__c=TMPolicyUtil.calculateAge(pis.pi.Date_of_Birth__c);
                if(pis.pi.PI_Age__c<18){
                    pis.pi.Smoker__c='no';//TS-672 All products: The smoking status for children default to "False" regardless what the agent choose in front end.
                }
                //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>Pi.PI_Age__c:'+pis.pi.PI_Age__c);
            }
            if(basicPlancodeMap!=null && pis.pi.Benefit_Level__c!=null && basicPlancodeMap.containsKey(pis.pi.Benefit_Level__c)){
                pis.pi.Basic_Plan__c=basicPlancodeMap.get(pis.pi.Benefit_Level__c);
            }
            
            pis.pi.Height__c=String.isEmpty(pis.height)?null:Decimal.valueOf(pis.height);
            pis.pi.Weight__c=String.isEmpty(pis.weight)?null:Decimal.valueOf(pis.weight);
            pis.pi.Height_Inch__c=String.isEmpty(pis.heightInch)?null:Decimal.valueOf(pis.heightInch);
            //if('PH = PI'.equals(pis.pi.Insured_Type__c)){
            //    pis.pi.Income_HKD__c=newPolicy.Income_HKD__c;//DPSP-664: monthly income should copied to person_isured level
            //    pis.pi.Mobile_Phone__c=newPolicy.Mobile_Phone__c;//PI Mobile Phone is removed,PI Mobile Phone is equaled to PH
            //}
            piList.add(pis.pi);
            i++;
        }
        //save the PI
        if(!piList.isEmpty()){
            upsert piList;
        }
        //save Beneficiary
        if(!isSkipStep3){
            Integer j=0;
            for(PersonInsuredStructure pis : personInsuredStructureList){
                for(BeneficiaryStruct bs : pis.beneficiaryList){
                    if(!(String.isEmpty(bs.beneficiary.Beneficiary_Type__c)||String.isEmpty(bs.beneficiary.First_Name__c)||String.isEmpty(bs.beneficiary.Last_Name__c)||null==bs.beneficiary.Percent__c||String.isEmpty(bs.beneficiary.Person_ID__c)||String.isEmpty(bs.beneficiary.Gender__c)||String.isEmpty(bs.beneficiary.Relationship__c))){
                            if(null==bs.beneficiary.Person_Insured__c){
                                bs.beneficiary.Person_Insured__c=pis.pi.id;
                            }
                            if(null==bs.beneficiary.Policy__c){
                                bs.beneficiary.Policy__c=policyList.get(j).id;
                            }

                            //AH19572 adjust gender
                            if(String.isNotBlank(bs.beneficiary.Gender__c)){
                                bs.beneficiary.Gender__c=adjustGender(bs.beneficiary.Gender__c);
                            }
                            //bs.beneficiary.name=bs.beneficiary.Last_Name__c+bs.beneficiary.First_Name__c;
                            benList.add(bs.beneficiary);
                    }                    
                }
                ++j;
            }
        }
        if(!benList.isEmpty()){
            upsert benList;
        }       
    }
    
    public class Rider {
        public String val{get;set;}        
        public Rider(){val='';}        
        public Rider(String valueParam){
            val=valueParam;
        }
    }
    
    public void displayOptionalField(){       
        if('Direct Debit'.equals(selectedPaymentType) || 'Direct Billing'.equals(selectedPaymentType)){
            //System.debug('>>>>>>>>>>>>>displayOptionalField.matched');
            displayOptionalField=true;
            displayCreditCardOptionalField=false;
        }else if('Credit Card Billing'.equals(selectedPaymentType)){
            displayCreditCardOptionalField=true;
            displayOptionalField=false;
        }else{
            displayOptionalField=false;
            displayCreditCardOptionalField=false;
        }        
        //auto select annual if cheque is selected
        // if('Cheque'.equals(selectedPaymentType)){
        if('Cheque'.equals(selectedPaymentType)&&String.isBlank(selectedPaymentFrequency)){//AM project issue fix, set default value when frequency is blank
            selectedPaymentFrequency='Annual';
            selectPaymentFrequency();
        }
        //auto select monthly if Direct Billing is selected
        // if('Direct Billing'.equals(selectedPaymentType)){
        if('Direct Billing'.equals(selectedPaymentType)&&String.isBlank(selectedPaymentFrequency)&&!selectedProduct.disable_monthly_payment__c){//AM project issue fix, set default value when frequency is blank/* add by Jack on 2022-04-21 for project: Disable monthly payment */
            selectedPaymentFrequency='Monthly';
            selectPaymentFrequency();
        }    
    }
    
    public void displayCompanyPosition(){
        //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>displayCompanyPosition():'+displayCompanyPosition);
        if('以上皆否 - None of the above'.equals(selectedBusinessNature) || String.isEmpty(selectedBusinessNature)){//if 'None of the above' or 'None' is selected,the fields will not be mandatory.
            displayCompanyPosition=false;
        }else{
            displayCompanyPosition=true;
        }
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>displayCompanyPosition():'+displayCompanyPosition);        
        //Nicole_CDD_20200429
        onBusinessNatureChange();
    }
    
    public PageReference displayEducationInfo(){
        return null;
    }
    
    public PageReference displayMeansOfIncomeInfo(){
        return null;
    }
    
    public PageReference displayPIResidenceAddId(){
        return null;
    }
    
    public PageReference displayPurposeOfInsurance(){
        return null;
    }
    
    public PageReference displayOtherSourceOfFund(){
        return null;
    }
    
    public PageReference displayInchInput(){
        for(PersonInsuredStructure pis : personInsuredStructureList){
            //System.debug('>>>>>>>>>pis.pi.Height_Unit__c='+pis.pi.Height_Unit__c);
        }        
        return null;
    }
    
    public void autoCalculateAge(){
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(null!=pis.pi.Date_of_Birth__c){               
                pis.pi.PI_Age__c=TMPolicyUtil.calculateAge(pis.pi.Date_of_Birth__c);
                if(pis.pi.PI_Age__c<18){
                    pis.pi.Smoker__c='no';//TS-672 All products: The smoking status for children default to "False"
                }
                //add by jack for JR1829
                PIS.pi.Reason_for_PI_age_over_18__c='';
                PIS.pi.Other_Reason_for_PI_age_over_18__c='';
                //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>Pi.PI_Age__c:'+pis.pi.PI_Age__c);
            }
        }
        TMPolicyUtil.policyTransactionValidation(ptvs);//parent hk id mandatory indicator
        for(PersonInsuredStructure pis : personInsuredStructureList){
            //System.debug('[TMCreatePolicyCtrl] autoCalculateAge().pis.isParentPIIdMandatory='+pis.isParentPIIdMandatory);
        }
    }
    
    public void autoGenerateInsureType(){
        autoCalculateAge();
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(String.isNotBlank(pis.pi.Relationship__c)){             
                if(pis.pi.Relationship__c=='Policy Holder'){
                    pis.pi.Insured_Type__c='PH = PI';
                    //add by jack for JR1829
                    PIS.pi.Reason_for_PI_age_over_18__c='';
                    PIS.pi.Other_Reason_for_PI_age_over_18__c='';
                    if(newPolicy.Product_Code__c=='@PBTG'){
                        pis.pi.LHB_certificate_number__c=acc.LHB_certificate_number__c;
                        pis.pi.LHB_policy_number__c=acc.LHB_policy_number__c;
                    }
                }else if(pis.pi.Relationship__c=='Spouse'){
                    pis.pi.Insured_Type__c='Spouse';
                    //add by jack for JR1829
                    PIS.pi.Reason_for_PI_age_over_18__c='';
                    PIS.pi.Other_Reason_for_PI_age_over_18__c='';
                }else if(pis.pi.Relationship__c=='Son' || pis.pi.Relationship__c=='Daughter' || pis.pi.Relationship__c=='Dependent'){
                    pis.pi.Insured_Type__c='Dependent';
                }else{
                    pis.pi.Insured_Type__c='';
                }
                pis.pi.Parent_PI_ID__c=null;
                //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>Pi.Insured_Type__c:'+pis.pi.Insured_Type__c);
            }
        }
    }
    
    public void autoCalculatePHAge(){
        if(null!=newPolicy.Date_of_Birth__c){
            newPolicy.Age__c=TMPolicyUtil.calculateAge(newPolicy.Date_of_Birth__c);
            //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>newPolicy.Age__c:'+newPolicy.Age__c);
        }
    }
    
    public PageReference displayAppealForPresales(){
        //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>appeal:'+newPolicy.Appeal__c);
        return null;
    }
    
    public PageReference refreshTMInsuredType(){
        return null;
    }
    
    public void changeRider(){
        PersonInsuredStructure pis=personInsuredStructureList.get(piIndex);       
        if(SPECIAL_RIDER_PRODUCTCODE.contains(selectedProduct.Product_Code__c)){
        }else if(SPECIAL_RIDER_PRODUCTCODE2.contains(selectedProduct.Product_Code__c)){
            pis.forDisplayedRiders='';
            pis.selectedRidersMap.clear();
            for(AvailableRiderBenefitlevelItem ai : pis.availableRiderBenefitlevelItemList){
                if(riderCodeBenefitLevelListMap.containsKey(ai.selectedRiderCode)){
                    ai.benefitlevel=null;
                    String piBenefitLevel=(null==pis.pi.Benefit_Level__c?benefitLevelOption.get(0).getValue():pis.pi.Benefit_Level__c);
                    Set<String> availableBenefitlevelSet=riderCodeBenefitLevelListMap.get(ai.selectedRiderCode).get(piBenefitLevel);
                    if(null!=availableBenefitlevelSet && availableBenefitlevelSet.size()>0){                       
                        ai.benefitLevelOption.clear();
                        ai.benefitLevelOption.add(new SelectOption('','--None--'));
                        List<String> availableBenefitLevelList=new List<String>(availableBenefitLevelSet);
                        availableBenefitLevelList.sort();
                        /**
                        Iterator<String> it=availableBenefitlevelSet.iterator();
                        while(it.hasNext()){
                            String benefitlevel=it.next();
                            ai.benefitLevelOption.add(new SelectOption(benefitlevel,benefitMap.get(benefitlevel).benefitLevelName));
                        }
                        **/
                        //System.debug(LoggingLevel.INFO,'*** changeRider.AvailableRiderBenefitlevelItem ai benefitlevel: '+ai.benefitlevel);
                        //Combo product: only has one benefit level. will get exception out of list index if using benefitMap --2020-09-18
                        if('@CBOG'==newPolicy.Product_Code__c||'@ABAG'==newPolicy.Product_Code__c||'@ABEG'==newPolicy.Product_Code__c){//AM project AM info jack add
                            for(String benefitlevel : availableBenefitLevelList){
                                ai.benefitLevelOption.add(new SelectOption(benefitlevel,benefitlevel+': '+ai.riderName));
                            }
                        }else{
                            for(String benefitlevel : availableBenefitLevelList){
                                ai.benefitLevelOption.add(new SelectOption(benefitlevel,benefitMap.get(benefitlevel).benefitLevelName));
                            }
                        }
                    }
                }
            }
        }else{
            pis.forDisplayedRiders='';
            pis.selectedRidersMap.clear();
            String selectedBenefitLevelCode=pis.pi.Benefit_Level__c;
            if(!selectedBenefitLevelCode.isNumeric()){
                selectedBenefitLevelCode=hex2DecMap.get(selectedBenefitLevelCode);
            }
            List<HttpCalloutVO.Rider> riderVOList=riderMap.get(selectedBenefitLevelCode);           
            if(null!=riderVOList){
                Map<String,String> tmp=new Map<String,String>();
                for(HttpCalloutVO.Rider riderVO : riderVOList){
                    tmp.put(riderVO.riderCode,riderVO.riderName);               
                }
                pis.availableRidersMap.clear();
                pis.availableRidersMap.putAll(tmp);
            }else{
                pis.availableRidersMap.clear();
            }            
        }        
    }
       
    public void beneficiaryLevelAndRiderInitialize(){
        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() start>>>>>>>>>>');
        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().productCode='+newPolicy.Product_Code__c);
        benefitLevelOption=new List<SelectOption>();        
        riderMap=new Map<String,List<HttpCalloutVO.Rider>>();
        basicPlancodeMap=new Map<String,String>();

        //AM Tovid 20210831 -- add Epic 79907 - Asia miles partnership
        //Guarantee100 code: 15R6L,25R6L
        //Worry free: 15C6L,25C6L,15C8L,25C8L,15C1L,25C1L
        Set<String> cx4productCodeSet = new Set<String>{'15R6L','25R6L','15C6L','25C6L','15C8L','25C8L','15C1L','25C1L'};

        try {
            //if(String.isNotBlank(productCode)){
            if(String.isNotBlank(newPolicy.Product_Code__c)){
                ServiceCalloutHelper helper=new ServiceCalloutHelper();
                List<HttpCalloutVO.Product> productList=helper.getPlanInfoListBasic(newPolicy.Product_Code__c);// comment temporarily 
                //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().productList='+productList);
                benefitMap=new Map<String,HttpCalloutVO.Benefit>();
                /* add by Jack on 2022-09-07 for project: JOBR-167 init setting to check if meet condition */
                String proCode = TMCallListGenerator.productCodeMap.get(selectedProduct.product_code__c)==null?selectedProduct.product_code__c:TMCallListGenerator.productCodeMap.get(selectedProduct.product_code__c);
                String channelCode = cam.Channel__r.Channel_Code__c;
                List<TM_Channel_Setting__c> channelSetting = [Select Hidden_Benefit_Level__c from TM_Channel_Setting__c where product_code__c = :proCode and channel_Code__c =:channelCode];
                Set<String> disableBenefitLevelSet;
                if(channelSetting.size()>0){
                    disableBenefitLevelSet=new Set<String>(channelSetting[0].Hidden_Benefit_Level__c.split(','));
                }
                /* add by Jack on 2022-09-07 for project: JOBR-167 init setting to check if meet condition */
                if(!productList.isEmpty()){
                    WSProduct=productList[0];
                    Set<String> basicPlanSet=new Set<String>();
                    for(HttpCalloutVO.Benefit b : WSProduct.benefitList){
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().HttpCalloutVO.Benefit b.isAvailable='+b.isAvailable);
                        if(b.isAvailable){
                            benefitMap.put(b.benefitLevelCode,b);
                            basicPlancodeMap.put(b.benefitLevelCode,b.planCode);
                            basicPlanSet.add(b.planCode);
                        }
                    }
                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().basicPlancodeMap:'+basicPlancodeMap);
                    for(String key : benefitMap.keySet()){
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitMap.key='+key);
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitMap.get(key).benefitLevelName='+benefitMap.get(key).benefitLevelName);
                        //AM Tovid 20210831 -- add Epic 79907 - Asia miles partnership
                        system.debug('productCode 2874:'+newPolicy.Product_Code__c);
                        system.debug('sponsorCode 2875:'+cam.Business_Partner__r.Sponsor_Code__c);
                        system.debug('ai.riderName 2876:'+benefitMap.get(key).benefitLevelName);
                        if(cx4productCodeSet.contains(newPolicy.Product_Code__c) && isCXagent && benefitMap.get(key).benefitLevelName == '3:Level 3 300K' ){/* add by Jack on 2022-10-12 for project: JOBR-217 Enhance Asiamiles membership info validation */
                            continue;
                        }
                        benefitLevelOption.add(new SelectOption(key,benefitMap.get(key).benefitLevelName));
                    }
                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitLevelOption='+benefitLevelOption);
                    TMProductStrategyRSM.productRSMBenefitOptionFilter(ptvs);
                    
                    Map<String,TMEsalesHelper.Portalproduct> basicProductMap=new Map<String,TMEsalesHelper.Portalproduct>();    
                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().basicPlanSet='+basicPlanSet);
                    basicProductMap=TMEsalesHelper.getProductMappingByBasicPlan(basicPlanSet);// {NELG。。。。。。。。。}  {NELG_1 ,NELG_2}   ////                  
                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().basicProductMap='+basicProductMap);
                    Map<String,HttpCalloutVO.Rider> riderCodeRiderVOMap=new Map<String,HttpCalloutVO.Rider>(); 
                    mandatoryRiderCodesList.clear();//clear data in memory when recall the WS
                    planQuoteList.clear();//clear plan quote when recall ws
                    //Deduplication of riderCode
                    for(HttpCalloutVO.Rider r : WSProduct.riderList){
                        if(r.isAvailable)
                            riderCodeRiderVOMap.put(r.riderCode,r);                 
                        if(null!=r.isUWProduct && r.isUWProduct)//DPSP-1052 : add madatory rider ("isUWProduct" is true in GetPlanInfoListBasic)
                            mandatoryRiderCodesList.add(r.riderCode);
                    }
                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().riderCodeRiderVOMap='+riderCodeRiderVOMap);//rider data from ws
                    
                    //every benefitlevel has a same list of All riders
                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitMap='+benefitMap);
                    TMEsalesHelper.Portalproduct basicPlanProduct=new TMEsalesHelper.Portalproduct();
                    planLevelProductMap=new Map<String,Map<String,TMEsalesHelper.Portalproduct>>();
                    for(String benefitLevelCode : basicPlancodeMap.keySet()){
                        String basicProductMapKey=basicPlancodeMap.get(benefitLevelCode)+'_'+benefitLevelCode;
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().basicProductMapKey='+basicProductMapKey);
                        basicPlanProduct=basicProductMap.get(basicProductMapKey);
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().basicPlanProduct='+basicPlanProduct);
                        if(null!=basicPlanProduct){
                            Set<String> riderCodeSet=new Set<String>();
                            Map<String,TMEsalesHelper.Portalproduct> riderProductMap=TMEsalesHelper.getProductMappingByRiders(riderCodeRiderVOMap.keySet(),basicPlanProduct);//rider data in our database {ridercode,riderVO}
                            planLevelProductMap.put(benefitLevelCode,riderProductMap);
                            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().riderProductMap='+riderProductMap);                               
                            List<HttpCalloutVO.Rider> riderList=new List<HttpCalloutVO.Rider>();
                            for(String portalproductKey : riderProductMap.keySet()){
                                //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().portalproductKey='+portalproductKey);
                                //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().portalproductKey='+portalproductKey);
                                HttpCalloutVO.Rider riderVO=riderCodeRiderVOMap.get(riderProductMap.get(portalproductKey).productCode);//filter the riders from ws by riders from our db
                                //System.debug('### riderCodeRiderVOMap.get(riderProductMap.get(portalproductKey).productCode)'+riderCodeRiderVOMap.get(riderProductMap.get(portalproductKey).productCode));
                                //System.debug('### riderProductMap.get(portalproductKey).productCode='+riderProductMap.get(portalproductKey).productCode);
                                if(null!=riderVO){
                                    riderList.add(riderVO);
                                }
                            }
                            riderList.sort();
                            riderMap.put(benefitLevelCode,riderList);
                            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().riderMap='+riderMap);
                            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() for loop end,benefitLevelCode='+benefitLevelCode +'   riderMap.get(benefitLevelCode)='+riderMap.get(benefitLevelCode));
                        }                        
                    }
                    //to deal with the rider which can match any benefitlevel,for SP100,DMBG,PBTG
                    List<String> allRiderCodeList=new List<String>(riderCodeRiderVOMap.keySet());
                    if(SPECIAL_RIDER_PRODUCTCODE2.contains(selectedProduct.product_code__c)){
                        riderCodeBenefitLevelListMap=TMEsalesHelper.getRiderCodeBenefitListMap(allriderCodeList,selectedProduct.Product_Code__c.replace('@',''));                        
                        //Combo: combo product has a null key: {CADG={null={1,2,3}},CAXG={null={1}},CCAG={null={1,2,3}},CDEG={null={1,2}},COPG={null={1}},COSG={null={1}},CVSG={null={1}}}
                        // change the key to 1 as this special product only has an dummy benifit level.
                        if(SPECIAL_RIDER_PRODUCTCODE3.contains(selectedProduct.product_code__c)){
                            for(String tempKeyRcbllm: riderCodeBenefitLevelListMap.keySet()){
                                Map<String,Set<String>> riderRateMap=riderCodeBenefitLevelListMap.get(tempKeyRcbllm);
                                if (riderRateMap.containsKey(null)){
                                    riderRateMap.put('1',riderRateMap.get(null));
                                    riderRateMap.remove(null);
                                } 
                            }
                        }
                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().riderCodeBenefitLevelListMap='+riderCodeBenefitLevelListMap);
                    }
                    
                    //System.debug('####Loop End riderMap='+riderMap);                                       
                    if(!benefitLevelOption.isEmpty()){                       
                        for(PersonInsuredStructure pis : personInsuredStructureList){
                            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().pis.pi.Benefit_Level__c='+pis.pi.Benefit_Level__c);                            
                            List<String> allRiderCodes=new List<String>();
                            Map<String,String> allRiders=new Map<String,String>();
                            //System.debug('andy add the debug,pis='+pis);
                            if(String.isNotEmpty(pis.pi.Rider__c)){                               
                                List<String> riderList=TMPolicyUtil.getRiderCodeList(pis.pi.Rider__c);
                                //WEI-296
                                if(!pis.pi.Benefit_Level__c.isNumeric()){
                                    pis.pi.Benefit_Level__c=hex2DecMap.get(pis.pi.Benefit_Level__c);
                                }
                                List<HttpCalloutVO.Rider> initVORiderList=riderMap.get(pis.pi.Benefit_Level__c);
                                //System.debug('andy add the debug,initVORiderList='+initVORiderList);
                                if(null!=initVORiderList){
                                    for(HttpCalloutVO.Rider riderVO : initVORiderList){
                                        allRiders.put(riderVO.riderCode,riderVO.riderName);
                                        allRiderCodes.add(riderVO.riderCode);
                                    }
                                    //Map<String,List<String>> benefitlevelRidersCodeMap=TMPolicyUtil.getBenefitLevelRiderCodeMap(pis.pi.Rider__c);
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().riderList='+riderList);
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().allRiders='+allRiders);
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().allRiderCodes='+allRiderCodes);
                                    ////System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitlevelRidersCodeMap='+benefitlevelRidersCodeMap);
                                    
                                    // add by kermit at 20190814
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitMap='+benefitMap);
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() pis.pi.Benefit_Level__c='+pis.pi.Benefit_Level__c);
                                    if(String.isBlank(pis.pi.Benefit_Level__c)){
                                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() special handling');
                                        pis.pi.Benefit_Level__c='12';
                                        for(String s : benefitMap.keySet()){
                                            if(Integer.valueOf(s)<Integer.valueOf(pis.pi.Benefit_Level__c) && (disableBenefitLevelSet == null || !disableBenefitLevelSet.contains(s)))/* add by Jack on 2022-09-07 for project: JOBR-167 benefit level can not be this option if option is disabled  */
                                                pis.pi.Benefit_Level__c=s;
                                        }
                                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() pi.BenefitLevel='+pis.pi.Benefit_Level__c);
                                    }
                                    // end add                                    
                                    pis.initRiderRelated4PI(allRiderCodes,allRiders,riderList,selectedProduct.Product_Code__c,riderCodeBenefitLevelListMap,benefitMap);//GL31 jakc add
                                }else{
                                    pis.pi.Rider__c=null;
                                    pis.pi.Benefit_Level__c=null;
                                    pis.availableRidersMap.clear();
                                    pis.selectedRidersMap.clear();
                                    //pis.benefitlevelRidersMap.clear();
                                    pis.availableRiderBenefitlevelItemList.clear();
                                }
                            }else{
                                //for new Policy Creation,default BenefitLevel is the first level
                                //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitLevelOption.get(0).getValue()='+benefitLevelOption.get(0).getValue());
                                List<HttpCalloutVO.Rider> initVORiderList=riderMap.get(benefitLevelOption.get(0).getValue());
                                //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().initVORiderList='+initVORiderList);
                                if(null!=initVORiderList){
                                    for(HttpCalloutVO.Rider riderVO: initVORiderList){
                                        allRiders.put(riderVO.riderCode,riderVO.riderName);
                                        allRiderCodes.add(riderVO.riderCode);
                                    }
                                    List<String> riderList=new List<String>();
                                    //Map<String,List<String>> benefitlevelRidersCodeMap=new Map<String,List<String>>();
                                    
                                    // add by kermit at 20190814
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitMap='+benefitMap);
                                    //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() pis.pi.Benefit_Level__c='+pis.pi.Benefit_Level__c);
                                    if(String.isBlank(pis.pi.Benefit_Level__c)){
                                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() special handling');
                                        pis.pi.Benefit_Level__c='12';
                                        for(String s : benefitMap.keySet()){
                                            if(Integer.valueOf(s)<Integer.valueOf(pis.pi.Benefit_Level__c) && (disableBenefitLevelSet == null || !disableBenefitLevelSet.contains(s))){/* add by Jack on 2022-09-07 for project: JOBR-167 benefit level can not be this option if option is disabled  */
                                                pis.pi.Benefit_Level__c=s;
                                            }
                                        }
                                        //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize() pi.BenefitLevel='+pis.pi.Benefit_Level__c);
                                    }else if(!pis.pi.Benefit_Level__c.isNumeric()){//jack add for Elite Revamp 32
                                        pis.pi.Benefit_Level__c=hex2DecMap.get(pis.pi.Benefit_Level__c);
                                    }//jack add for Elite Revamp 32
                                    // end add
                                    
                                    pis.initRiderRelated4PI(allRiderCodes,allRiders,riderList,selectedProduct.Product_Code__c,riderCodeBenefitLevelListMap,benefitMap);//GL31 jakc add
                                }else{
                                    pis.availableRidersMap.clear();
                                    pis.selectedRidersMap.clear();
                                    //pis.benefitlevelRidersMap.clear();
                                    pis.availableRiderBenefitlevelItemList.clear();
                                }
                            }
                        }
                    }
                    if(disableBenefitLevelSet != null){
                        disableBenefitLevelOption(disableBenefitLevelSet);
                    }
                }
            }
            this.isWSError=false;
            //System.debug('[TMCreatePolicyCtrl] beneficiaryLevelAndRiderInitialize().benefitLevelOption='+benefitLevelOption);
        } catch(Exception e){
            this.isWSError=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,wsErrorMsg));
            //System.debug('>>>>WS Error:'+e.getMessage());
            //System.debug('>>>>WS Error:'+e.getLineNumber());
            //System.debug('>>>>WS Error:'+e.getStackTraceString());
        }
    }
    
    public void discount12Initialize(){
        try{
            discount12Options=new List<SelectOption>();
            discount12Options.add(new SelectOption('','--None--'));
            //System.debug('[TMCreatePolicyCtrl] discount12Initialize().productIdPremiumDiscountMap'+productIdPremiumDiscountMap);
            //System.debug('[TMCreatePolicyCtrl] discount12Initialize().newPolicy.Product__c'+newPolicy.Product__c);
            List<Premium_Discount__c> premiumDiscountList=productIdPremiumDiscountMap.get(newPolicy.Product__c);
            //System.debug('[TMCreatePolicyCtrl] discount12Initialize().premiumDiscountList.size()='+premiumDiscountList.size());
            premiumDiscountMap.clear();
            if(null!=premiumDiscountList && premiumDiscountList.size()>0){
                for(Premium_Discount__c pd : premiumDiscountList){
                    premiumDiscountMap.put(pd.Discount_Type__c,pd);
                    // if(pd.Mandatory__c!=true){/* add by Jack on 2022-01-11 for project: Discount Enhancement display mandatory field */
                        discount12Options.add(new SelectOption(pd.Discount_Type__c,pd.Discount_Type__c));
                    // }/* add by Jack on 2022-01-11 for project: Discount Enhancement display mandatory field */
                }
            }                
            //System.debug('[TMCreatePolicyCtrl]discount12Initialize.premiumDiscountList'+premiumDiscountList);
            //System.debug('[TMCreatePolicyCtrl]discount12Initialize.premiumDiscountMap'+premiumDiscountMap);
        }catch(Exception e){
            //System.debug('[discount12Initialize] catch an error:'+e.getMessage());
        }
    }
       
    /*
    * DPSP-1019 retrive the Selected Campaign's billing frequency and discount info
    * 
    */
    public void paymentFrequencyInitialize(){              
        Campaign selectedCampaign;
        try{
            // if(this.newPolicy.Product_Code__c.replace('@','')!=selectedProduct.Product_Code__c.replace('@','')){
            //     CignaException exc=new CignaException();
            //     throw exc;
            // }
            selectedCampaign=productIdCampaignMap.get(selectedProduct.Id);
        }catch(Exception e){
            Product__c prod=[SELECT Id,Product_Code__c FROM Product__c WHERE Id=:this.newPolicy.Product__c];
            CignaException exc=new CignaException();
            exc.setMessage('Please contact TM administrator to add Campaign: Product '+prod.Product_Code__c+' is not available in the Campaign "'+this.cam.Name+'" now');
            throw exc;
        }
        Campaign selectedCampaignDetail=[Select Id,name,BF_Annual__c,BF_Month__c,BF_Quater__c,BF_Semi_Annual__c,BF_Single__c from Campaign where id=:selectedCampaign.Id];
        
        //System.debug('[TMCreatePolicyCtrl] paymentFrequencyInitialize() selectedCampaignDetail.BF_Annual__c='+selectedCampaignDetail.BF_Annual__c+';selectedCampaignDetail.BF_Month__c='+selectedCampaignDetail.BF_Month__c+';selectedCampaignDetail.BF_Quater__c='+selectedCampaignDetail.BF_Quater__c+';selectedCampaignDetail.BF_Semi_Annual__c='+selectedCampaignDetail.BF_Semi_Annual__c+';selectedCampaignDetail.BF_Single__c='+selectedCampaignDetail.BF_Single__c);
        paymentFrequencyOptions=new List<SelectOption>();
        paymentFrequencyOptions.add(new SelectOption('','--None--'));
        if(null!=selectedCampaignDetail.BF_Annual__c){
            paymentFrequencyOptions.add(new SelectOption('Annual','Annual'));
            paymentFrequencyDiscountMap.put('Annual',selectedCampaignDetail.BF_Annual__c);
        }
        if(null!=selectedCampaignDetail.BF_Month__c && !selectedProduct.disable_monthly_payment__c){
            paymentFrequencyOptions.add(new SelectOption('Monthly','Monthly'));
            paymentFrequencyDiscountMap.put('Monthly',selectedCampaignDetail.BF_Month__c);
        }
        if(null!=selectedCampaignDetail.BF_Quater__c){
            paymentFrequencyOptions.add(new SelectOption('Quarterly','Quarterly'));
            paymentFrequencyDiscountMap.put('Quarterly',selectedCampaignDetail.BF_Quater__c);  
        }
        if(null!=selectedCampaignDetail.BF_Semi_Annual__c){
            paymentFrequencyOptions.add(new SelectOption('Semi Annually','Semi Annually'));
            paymentFrequencyDiscountMap.put('Semi Annually',selectedCampaignDetail.BF_Semi_Annual__c);
        }
        if(null!=selectedCampaignDetail.BF_Single__c){
            paymentFrequencyOptions.add(new SelectOption('Semi Premium','Semi Premium'));
            paymentFrequencyDiscountMap.put('Semi Premium',selectedCampaignDetail.BF_Single__c);
        }
    }
    
    public void paymentMethodInitialize(){
        System.debug('[TMCreatePolicyCtrl] paymentMethodInitialize().cam.Payment_Method__c='+cam.Payment_Method__c);
        paymentTypeOptions=new List<SelectOption>();
        paymentTypeOptions.add(new SelectOption('','--None--'));
        String[] paymentMethodArr;
        //Chapin Requirement：remove non-standard billing and initial credit card billing options for their UAT first
        String[] exceptMethodArr=new String[]{'Initial Credit Card Billing','Non-standard Billing'};
        if(null!=cam.Payment_Method__c){
           paymentMethodArr=cam.Payment_Method__c.split(';');
            for(String pm : paymentMethodArr){
                if(!exceptMethodArr.contains(pm)){
                    /*DPSP-877/883
                    * if monthly option in payment frequency is available,direct billing in payment means will be shown
                    * if annual option is payment frequency is available,cheque in payment means will be shown. 
                    */
                    if( pm=='Cheque' && !paymentFrequencyOptions.contains(new SelectOption('Annual','Annual'))){
                        //Not to show Cheque payment method
                    }else if( pm=='Direct Billing' && !selectedProduct.disable_monthly_payment__c && !paymentFrequencyOptions.contains(new SelectOption('Monthly','Monthly'))){
                        //Not to show Direct Billing payment method
                    }else{
                        paymentTypeOptions.add(new SelectOption(pm,pm));
                    }
                }                
            }
        }
        System.debug('paymentTypeOptions:'+paymentTypeOptions+' paymentFrequencyOptions:'+paymentFrequencyOptions);
    }
    
    public void bankInitialize(){
        //System.debug('[TMCreatePolicyCtrl] bankInitialize().cam.Bank__c='+cam.Bank__c);
        bankOptions=new List<SelectOption>();
        bankOptions.add(new SelectOption('','--None--'));
        //bankOptions.add(new SelectOption('','--None--'));
        String[] bankArr;
        if(cam.Select_All_Bank__c){
            Schema.DescribeFieldResult fieldResult=Campaign.bank__c.getDescribe();
            List<Schema.PicklistEntry> ple=fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pe : ple){
                bankOptions.add(new SelectOption(pe.getValue(),pe.getLabel()));
            }
        }else if(null!=cam.Bank__c){
            bankArr=cam.Bank__c.split(';');
            for(String bk : bankArr){
                bankOptions.add(new SelectOption(bk,bk));
            }
        }
    }
    
    public void creditCardBankInitialize(){       
        // selectedCreditCardBank
        //System.debug('[TMCreatePolicyCtrl] creditCardBankInitialize().cam.Credit_Card__c='+cam.Credit_Card__c);
        Schema.DescribeFieldResult F=Campaign.Credit_Card__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries=F.getPicklistValues();
        Map<String,String> picklistMap=new Map<String,String>();
        for(Schema.PicklistEntry pe : picklistEntries){
            picklistMap.put(pe.getValue(),pe.getLabel());
        }
        creditCardTypeOptions=new List<SelectOption>();
        creditCardTypeOptions.add(new SelectOption('','--None--'));
        String[] cbankArr;
        if(null!=cam.Credit_Card__c){
           cbankArr=cam.Credit_Card__c.split(';');
            for(String cbk : cbankArr){
                creditCardTypeOptions.add(new SelectOption(cbk,picklistMap.get(cbk)));
            }
        }
    }
    
    public void pickListInitialize(){
        // for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
        //     //System.debug('[TMCreatePolicyCtrl]pickListInitialize().p.availableDiscountMap='+pis.availableDiscountMap);
        // }
        beneficiaryLevelAndRiderInitialize();
        initAssessRider();//GL31 Jack add
        discount12Initialize();
        initializeRefund();
        paymentFrequencyInitialize();
        paymentMethodInitialize();
        bankInitialize();
        creditCardBankInitialize();
        // for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
        //     //System.debug('[TMCreatePolicyCtrl]pickListInitialize().p.availableDiscountMap='+pis.availableDiscountMap);
        // }
        //System.debug('[TMCreatePolicy] pickListInitialize().premiumDiscountMap='+premiumDiscountMap);
        //System.debug('[TMCreatePolicy] pickListInitialize().ptvs.ctrl.premiumDiscountMap='+ptvs.ctrl.premiumDiscountMap);
        //System.debug('[TMCreatePolicy] add by li hao currentStep'+currentStep);
        if(currentStep>STEP_POLICY_INFORMATION){
            TMPolicyUtil.policyTransactionValidation(ptvs);
        }
        //initialize piValidation indicator & parentIDPolicyList 
        if(currentStep>STEP_PHPI_INFORMATION){
            TMPolicyUtil.setPersonalIDPolicylistFromWS(ptvs.ctrl);
            TMPolicyUtil.setParentIDPolicyList(personInsuredStructureList,policyCalloutHelper);
            //System.debug('[TMCreatePolicy] add by li hao currentStep>STEP_PHPI_INFORMATION'+currentStep);
            TMPolicyUtil.piValidation(ptvs); 
            /*
            *   Added by Andy for DPSP787
            */ 
            //Initialize bank account and credit card no.
            TMPolicyUtil.updateBankAccoutNumber(newPolicy);
        }
        List<String> ssnList=new List<String>();//Nicole_Elite Revamp_20210319
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            ssnList.add(pis.pi.Personal_ID__c);
            //System.debug('[TMCreatePolicyCtrl]pickListInitialize().p.availableDiscountMap='+pis.availableDiscountMap);
        }
        //initialize premium discount
        //System.debug('[TMCreatePolicy] pickListInitialize() currentStep:'+currentStep);
        //System.debug('[TMCreatePolicy] pickListInitialize() selectedProduct:'+selectedProduct);
        if(currentStep==STEP_CONFIRMATION_PAYMENT){
            //Nicole_Elite Revamp_20210319
            // Rancho_AH24240_20220224: comment for duplicate logic
            // if(selectedProduct!=null&&'@NELG,@NESG'.contains(selectedProduct.Product_Code__c)){
            //     firstYDisEliMap=TMPolicyUtil.getFirstYDisEliMap(selectedProduct.Website_Product_Code__c,ssnList);
            //     //System.debug('[TMCreatePolicy] pickListInitialize() firstYDisEliMap:'+firstYDisEliMap);
            // }
            //System.debug('[TMCreatePolicyCtrl] pickListInitialize().currentStep==STEP_CONFIRMATION_PAYMENT');
            TMCreatePolicyStepStrategy policyStepStrategy=new TMCreatePolicyStep6Strategy(ptvs);
            policyStepStrategy.stepInit();
        }
        // for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
        //     //System.debug('[TMCreatePolicyCtrl]pickListInitialize().p.availableDiscountMap='+pis.availableDiscountMap);
        // }
        validateInfoIntegrity();        
    }    
    
    /*
     * isAMLHighRisk indicator
     *     check by Country_List_Settings__c and Business_Nature__c
     */
    public Boolean isAML {
        get {
            Boolean result=false;
            Boolean isFinishCheck=false;
            if(null!=businessNatureList){
                /* add by Jack on 2022-01-27 for project: IA AML */
                // for(Country_List_Settings__c c : countryList){
                    // if((c.name.equals(newPolicy.Nationality__c) || c.name.equals(newPolicy.Corresponding_Address_Country__c)) && c.Aml_Highrisk__c==true){
                if((TMPolicyUtil.nationalityMap.containsKey(newPolicy.Nationality__c)&&TMPolicyUtil.nationalityMap.get(newPolicy.Nationality__c).Aml_Highrisk__c) || (TMPolicyUtil.countryMap.containsKey(newPolicy.Corresponding_Address_Country__c)&&TMPolicyUtil.countryMap.get(newPolicy.Corresponding_Address_Country__c).Aml_Highrisk__c)){
                    result=true;
                    isFinishCheck=true;
                }
                // }
                /* add by Jack on 2022-01-27 for project: IA AML */
                if(!isFinishCheck){
                    for(Business_nature__c bn : businessNatureList){
                        if(bn.Description__c.equals(newPolicy.Business_Nature__c) && bn.Aml_Highrisk__c==true){
                            result=true;
                            break;
                        }
                    }
                }
            }
            return result;     
        }
    }
    
    /*
     * Step 3: Beneficiary
     */
    public Boolean isSkipStep3 {
        get {return (productMap!=null && productMap.get(newPolicy.Product__c)!=null && productMap.get(newPolicy.Product__c).Is_Life__c==false);}
    }
    /**
    public void updateAppeal(){
        
        if(isCheckAppeal){
            newPolicy.Appeal__c=APPEAL_YES;
            //isNotCheckAppeal=false;
        }else{
            newPolicy.Appeal__c=APPEAL_NO;
            //isNotCheckAppeal=true;
        }
    }
    
    public void updateAppeal2(){
        
        if(isCheckAppeal2){
            newPolicy.Appeal_For_UW_Result__c=APPEAL_YES;
        }else if(isCheckAppeal3){
            newPolicy.Appeal_For_UW_Result__c=APPEAL_WITHDRAWN;
        }else{
            newPolicy.Appeal_For_UW_Result__c=APPEAL_NO;
        }
        
    }
    **/
    public void copyAboveBeneficiary(){             
        List<BeneficiaryStruct> tmpList=new List<BeneficiaryStruct>();
        String PIName=personInsuredStructureList.get(PINoOfStep3).pi.Insured_First_Name__c+personInsuredStructureList.get(PINoOfStep3).pi.Insured_Last_Name__c;
        for(BeneficiaryStruct bs : personInsuredStructureList.get(PINoOfStep3-1).beneficiaryList){
            BeneficiaryStruct newBs=new BeneficiaryStruct(PIName);
            newBs.beneficiary=bs.beneficiary.clone(false,true,false,false);           
            // TM Work at Home
            if(orgnDataBeforeMask.workAtHome){
                newBs.origPersonId=bs.origPersonId;
            }
 
            tmpList.add(newBs);
        }        
        personInsuredStructureList.get(PINoOfStep3).beneficiaryList.clear();
        personInsuredStructureList.get(PINoOfStep3).beneficiaryList.addAll(tmpList);
    }    
    /**        
    public void preSalesOnPage(){
        callPreSalesOnPage=false;       
        //initialize prePISSet by result of piValidation
        for(PersonInsuredStructure pis : personInsuredStructureList){
            //System.debug('[TMCreatePolicyCtrl] preSalesOnPage() pis.piValidationItem.needPresales='+pis.piValidationItem.needPresales);
            if(pis.piValidationItem.needPresales==true){
                prePISSet.add(pis.pi.id);
            }else{//if policy dont need to call presales,the uw result record also should be created
                
                //if(null==pis.uwResult){                   
                //    pis.uwResult=new UW_Result__c();
                //    pis.uwResult.Person_Insured__c=pis.pi.id;
                //    if(pis.uwResult.Policy__c==null){
                //        pis.uwResult.Policy__c=pis.pi.New_Policy__c;
                //    }
                //    pis.uwResult.Product__c=newPolicy.Product__c;
                //}
                
            }
        }
        //If the necessary information has not changed(sex,height,weight and so on),dont need to call presale ws again.
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(prePISSet.contains(pis.pi.id) && TMPolicyUtil.compare2Object(pis.piPolicy.Presales_Result_Attribute__c,pis.pi)){
                prePISSet.remove(pis.pi.Id);
            }
        }        
        
        preSales();
        
        boolean isAccepted=false;
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if('Accepted'.equals(pis.piPolicy.Pre_Sales_Result__c) || null==pis.piPolicy.Pre_Sales_Result__c){
                //System.debug('[TMCreatePolicyCtrl] preSalesOnPage().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);
                isAccepted=true;
            }else{
                isAccepted=false;
                break;
            }                
        }
        if(isAccepted){
            presalesAccepted=true;
            isShowStep4Page=false;
        }else{
            presalesAccepted=false;
            isShowStep4Page=true;
            for(PersonInsuredStructure pis : personInsuredStructureList){
                if(null==pis.presalesResultMsgList && null!=pis.piPolicy.PreSales_Result_Msg__c){
                    pis.presalesResultMsgList=TMPolicyUtil.preSalesResultMsgBuild(pis.piPolicy.PreSales_Result_Msg__c);
                }                    
            }
        }
        //System.debug('[TMCreatePolicyCtrl] preSalesOnPage() after presales presalesAccepted='+presalesAccepted);
        //System.debug('[TMCreatePolicyCtrl] preSalesOnPage() after presales isShowStep4Page='+isShowStep4Page);
        
    }
    **/
           
    public Boolean isUWResultExisting(){      
        Boolean isExisting=false;
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(null!=pis.piPolicy.UW_Result__c){
                isExisting=true;
                break;
            }
        }       
        return isExisting;
    }
    
    /**Custom Multi-rider Selection start**/       
    TMEsalesHelper.PreSalesAttribute att;
    /**
    public void preSales(){
        try{
            //To check whether parent HKID of PI which need to go presales has inforce policies in SFDC or from WS
            List<PersonInsuredStructure> tmpList=new List<PersonInsuredStructure>();
            for(PersonInsuredStructure pis : personInsuredStructureList){
                if(prePISSet.contains(pis.pi.id)){
                    tmpList.add(pis);
                }
            }
            Map<String,Boolean> PIIdHasInforcePolicyMap=TMPolicyUtil.getPIIdHasInforcePolicyMap(tmpList,selectedProduct.Product_Code__c);
            List<New_Policy__c> policyListToUpdate=new List<New_Policy__c>();
            //System.debug('[TMCreatePolicyCtrl] preSales().prePISSet='+prePISSet);
            for(PersonInsuredStructure pis : personInsuredStructureList){               
                if(prePISSet.contains(pis.pi.id)){
                    //TMPolicyUtil.preSales(pis,opp,newPolicy,this.productCode);                                       
                    TMPolicyUtil.preSales(pis,cam,newPolicy.Product_Code__c,WSProduct,PIIdHasInforcePolicyMap.containsKey(pis.pi.Parent_PI_ID__c));
                    policyListToUpdate.add(pis.piPolicy);
                    //uwResultList.add(pis.uwResult);
                }else{
                    //uwResultList.add(pis.uwResult);
                    continue;
                }
            }
            if(!policyListToUpdate.isEmpty()){
                //upsert uwResultList;
                upsert policyListToUpdate;
                applicationId=personInsuredStructureList[0].applicationId;
            }
            prePISSet.clear();
        }catch(Exception e){
            this.isWSError=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,wsErrorMsg));
            //System.debug('[TMCreatePolicyCtrl] preSales() error>>>>>>>'+e.getMessage());
            //System.debug('[TMCreatePolicyCtrl] preSales() error>>>>>>>'+e.getLineNumber());
            //System.debug('[TMCreatePolicyCtrl] preSales() error>>>>>>>'+e.getStackTraceString());
        }
    }
    **/
        
    @RemoteAction
    global static Boolean getUWStatus(String appId,String lastModifiedDate){
        DateTime submissionDateTime;
        //System.debug('[TMCreatePolicy] getUWStatus().appId='+appId);
        /**
        //System.debug('[TMCreatePolicy] getUWStatus().lastModifiedDate='+lastModifiedDate);
        DateTime lmd;
        if(String.isNotBlank(lastModifiedDate)){
            lmd=DateTime.valueOf(lastModifiedDate);
        }
        //System.debug('[TMCreatePolicy] getUWStatus().lmd='+lmd);
        **/
        //if(String.isNotBlank(appId) && null!=lmd){
        if(String.isNotBlank(appId)){
            //List<UW_Result__c> uwResultList=[select id from UW_Result__c where Application_Id__c=:appId and Overrall_Result__c!=null and lastmodifieddate!=:lmd];
            List<UW_Result__c> uwResultList=[select id from UW_Result__c where Application_Id__c=:appId];
            //System.debug('[TMCreatePolicy] getUWStatus().uwResultList='+uwResultList);
            if(null!=uwResultList && uwResultList.size()>0){               
                return true;               
            }
        }
        return false;
    }
    
    public void JumpToPI(){
        if(null!=uwPISIndex){
            for(Integer i=0;i<personInsuredStructureList.size();i++){
                if(personInsuredStructureList.get(i).pi.id==uwPISListForDisplay.get(uwPISIndex-1).pi.id){
                    auwPIindex=i;
                    break;
                }
            }
            piName=personInsuredStructureList[auwPIindex].pi.Person_Insured_Name__c;
            auwUrl=personInsuredStructureList[auwPIindex].auwURL;
            applicationId=personInsuredStructureList[auwPIindex].applicationId;
            lastModifiedDate=personInsuredStructureList[auwPIindex].uwResultLastModifiedDate;
            //System.debug('[TMCreatePolicyCtrl] JumpToPI().applicationId='+applicationId);
        }
    }
    
    //get quote start
    public void getPaymentPremium(){
        try{
            // TM Work at Home
            if(orgnDataBeforeMask.workAtHome){               
                deMaskSensiData();
            }
            //System.debug('[getPaymentPremium] currentStep='+currentStep);
            if(currentStep==STEP_CONFIRMATION_PAYMENT){
                isComplete=false;//AM project coupon jack add for canceling save validation and set status to pending payment after getPaymentPremium
                isPaymentButtonClicked=true;// control the submit button
                premiumAmountList=new List<TMEsalesHelper.PremiumAmt>();         
                //piPolicyIdList=new List<String>(); 
                String campaignCode;
                Set<String> planCodeSet=new Set<String>(); // plan code of product
              
                //Set<String> mandatoryRiderCodeSet=new Set<String>();// mandatory rider code            
                Set<String> piBasicPlanSet=new Set<String>();
                // get basic Plan list
                if(!personInsuredStructureList.isEmpty()){   
                    for(PersonInsuredStructure pis : personInsuredStructureList){
                        Person_Insured__c pi=pis.pi;
                        if(String.isNotBlank(pi.Basic_Plan__c)){
                            piBasicPlanSet.add(pi.Basic_Plan__c);
                        }
                    }
                } 
                //System.debug('[getPaymentPremium] piBasicPlanSet: '+piBasicPlanSet);               
                //get basic plan product mapping           
                Map<String,TMEsalesHelper.Portalproduct> basicProductMap=new Map<String,TMEsalesHelper.Portalproduct>();                      
                basicProductMap=TMEsalesHelper.getProductMappingByBasicPlan(piBasicPlanSet);
                //System.debug('[getPaymentPremium] basicProductMap='+basicProductMap);               
                // get Mandatory Riders for policy product 
                //String mandatoryRiders=TMEsalesHelper.getMandatoryRidersByProductCode(newPolicy.Product_Code__c);
                //if(String.isNotBlank(mandatoryRiders)){
                //    mandatoryRiderCodeSet.addAll(mandatoryRiders.split(';'));// add mandatory riders - define custom setting                
                //}
                ////System.debug('[getPaymentPremium] mandatoryRiderCodeSet='+mandatoryRiderCodeSet);               
                //prepare PI map
                Map<String,TMEsalesHelper.PersonInsured> personMap=new Map<String,TMEsalesHelper.PersonInsured>();
                TMEsalesHelper.PersonInsured person=new TMEsalesHelper.PersonInsured();                           
                //Map<String,Decimal> discountMap=getPremiumDiscounts();// get discount ;comment by ken
               
                Integer cnt=0;
                for(PersonInsuredStructure p : personInsuredStructureList){                   
                    //piPolicyIdList.add(p.pi.New_Policy__c);                   
                    if(p.piValidationItem.otherValidation==true && p.piValidationItem.isDuplicate==false 
                       && !PRESALES_UW_RESULT_DECLINED.equals(p.piPolicy.Pre_Sales_Result__c)){//added by ken
                        person=new TMEsalesHelper.personInsured();
                        cnt=cnt+1;
                        person.key='PI'+cnt;
                        person.description=p.pi.Insured_Type__c;
                        person.age=Integer.valueOf(p.pi.PI_Age__c);
                        person.dateOfBirth=p.pi.Date_of_Birth__c;//added by ken
                        person.insuredType=p.pi.Insured_Type__c;//added by ken
                        //person.loading=p.uwResult==null?0 : p.uwResult.Loading__c;
                        person.loading=p.piPolicy==null?0 : p.piPolicy.Loading__c;
                        person.personName=p.pi.Person_Insured_Name__c;//added by ken
                        if(String.isNotBlank(p.pi.Gender__c) && p.pi.Gender__c.equalsIgnoreCase('Female')){
                            person.gender='F';
                        }else if(String.isNotBlank(p.pi.Gender__c) && p.pi.Gender__c.equalsIgnoreCase('Male')){
                            person.gender='M';
                        }
                        if(String.isNotBlank(p.pi.Smoker__c) && p.pi.Smoker__c.equalsIgnoreCase('Yes')){
                            person.smokingStatus='true';
                        }else{
                            person.smokingStatus='false';
                        }
                        // Rancho_HKITSFDC402_20250930 - add sum insured
                        person.quoteSumInsured = p.sumInsured;

                        if(!personMap.containsKey(person.key)){
                            personMap.put(person.key,person);
                        }
                        
                        //prepare plan code for basic plan
                        TMEsalesHelper.Portalproduct basicPlanProduct=new TMEsalesHelper.Portalproduct();
                        if(!p.pi.Benefit_Level__c.isNumeric()){
                            p.pi.Benefit_Level__c=hex2DecMap.get(p.pi.Benefit_Level__c);  
                        }
                        String basicProductMapKey=p.pi.Basic_Plan__c+'_'+p.pi.Benefit_Level__c;// Actually,pi.Basic_Plan__c==productCode (From Cigna WS). I.E. RSPHS_1,RSPHS_2,RSPHS_3,RSPHS_4
                        //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().basicProductMapKey='+basicProductMapKey);
                        //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().basicProductMap='+basicProductMap);
                        if(basicProductMap.containsKey(basicProductMapKey) && basicProductMap.get(basicProductMapKey)!=null){
                            basicPlanProduct=basicProductMap.get(basicProductMapKey);
                            //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().basicPlanProduct='+basicPlanProduct);
                            person.basicPlanCode=basicProductMap.get(basicProductMapKey).planCode;
                            //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().person.basicPlanCode='+person.basicPlanCode);
                            campaignCode=basicProductMap.get(basicProductMapKey).campaignCode;
                            //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().campaignCode='+campaignCode);
                            //Rancho_HKITSFDC402_20250930 - add sum insured
                            if(String.isNotBlank(person.quoteSumInsured)){
                                planCodeSet.add(person.basicPlanCode+'_'+person.quoteSumInsured);
                            }else{
                                planCodeSet.add(person.basicPlanCode);
                            }
                            person.planProductMap.put(person.basicPlanCode,newPolicy.Product_Code__c); // PI product code is same as basic policy product code           
                        }
                        
                        //prepare plan code for rider
                        if(String.isNotBlank(p.pi.Rider__c)){
                            Set<String> riderCodeSet=new Set<String>();
                            if(String.isNotBlank(p.pi.Rider__c)){
                                riderCodeSet.addAll(TMPolicyUtil.getRiderCodeSet(p.pi.Rider__c));// add selected riders 
                            }                            
                            //get product mapping for riders                            
                            Map<String,TMEsalesHelper.Portalproduct> riderProductMap;
                            //change by ken,for DPSP-789、DPSP-796. For SLP and DMBG,rider can correspond to benefitlevel which is not its benefitlevel
                            Map<String,List<String>> benefitLevelRiderCode=TMPolicyUtil.getBenefitLevelRiderCodeMap(p.pi.Rider__c);
                            
                            //for Combo: only has a dummy benefity and has mutiple level rider
                            if(SPECIAL_RIDER_PRODUCTCODE3.contains(p.pi.Basic_Plan__c)){
                                riderProductMap=TMEsalesHelper.getProductMappingByRidersAndBenefit(riderCodeSet,p.availableRiderBenefitlevelItemList ,basicPlanProduct,true);
                            }else if(SPECIAL_RIDER_PRODUCTCODE2.contains(p.pi.Basic_Plan__c)){//for PBTG
                                riderProductMap=TMEsalesHelper.getProductMappingByRidersAndBenefit(riderCodeSet,p.availableRiderBenefitlevelItemList ,basicPlanProduct);
                            }else if(SPECIAL_RIDER_PRODUCTCODE.contains(p.pi.Basic_Plan__c) && !benefitLevelRiderCode.isEmpty()){//for SP100,DMBG
                                riderProductMap=TMEsalesHelper.getProductMappingByRidersAndBenefit(benefitLevelRiderCode,basicProductMap,p.pi.Basic_Plan__c);
                            }else{//for others
                                //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().riderCodeSet='+riderCodeSet);
                                riderProductMap=TMEsalesHelper.getProductMappingByRiders(riderCodeSet,basicPlanProduct);
                            }
                            //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().riderProductMap='+riderProductMap);
                            Set<String> personRiderPlanCodeSet=new Set<String>();//add by ken,for SLP ridercode Deduplication
                            For(String portalproductKey : riderProductMap.keySet()){
                                personRiderPlanCodeSet.add(riderProductMap.get(portalproductKey).planCode);
                                //comment by ken,for SLP ridercode Deduplication
                                planCodeSet.add(riderProductMap.get(portalproductKey).planCode);
                                person.planProductMap.put(riderProductMap.get(portalproductKey).planCode,riderProductMap.get(portalproductKey).productCode);//map<plancode,ridercode>        
                                if(String.isBlank(campaignCode)){
                                    campaignCode=riderProductMap.get(portalproductKey).campaignCode;
                                }
                            }
                            //add by ken,for SLP ridercode Deduplication
                            for(String personRiderPlanCode : personRiderPlanCodeSet){
                                if(String.isBlank(person.riderPlanCode)){
                                    person.riderPlanCode=personRiderPlanCode;
                                }else{
                                    person.riderPlanCode+=';'+personRiderPlanCode;
                                }
                            }
                            /*
                            For(String riderCode: riderCodeSet){
    
                                String riderProductMapKey=riderCode+'_'+p.pi.Benefit_Level__c;           
                                if(riderProductMap!=null && riderProductMap.containsKey(riderProductMapKey) && riderProductMap.get(riderProductMapKey)!=null){                    
                                    if(String.isBlank(person.riderPlanCode)){
                                        person.riderPlanCode=riderProductMap.get(riderProductMapKey).planCode;
                                    }else{
                                        person.riderPlanCode=person.riderPlanCode+';'+riderProductMap.get(riderProductMapKey).planCode;
                                    }
                                    planCodeSet.add(riderProductMap.get(riderProductMapKey).planCode);
                                    person.planProductMap.put(riderProductMap.get(riderProductMapKey).planCode,riderProductMap.get(riderProductMapKey).productCode);// riderCode=productcode
            
                                    if(String.isBlank(campaignCode)){
                                        campaignCode=riderProductMap.get(riderProductMapKey).campaignCode;
                                    }
                                    //System.debug('[getPaymentPremium] person.riderPlanCode='+person.riderPlanCode+',riderCode='+riderCode);                          
                                }   
                                            
                            }
                            */ 
                            //person.riderProductMap=riderProductMap;//added by ken ,for getting portalproduct's offercode & si to call get quote ws
                        }
                        
                        if(String.isNotBlank(person.basicPlanCode)){
                            person.planCode=person.basicPlanCode;
                        }
                        if(String.isNotBlank(person.riderPlanCode)){
                            if(!String.isBlank(person.planCode)){
                                person.planCode=person.planCode+';'+person.riderPlanCode;
                            }else{
                                person.planCode=person.riderPlanCode;
                            }
                        }               
                        person.policyId=p.pi.New_Policy__c;
                        //WEI-296
                        if(!p.pi.Benefit_Level__c.isNumeric()){
                           p.pi.Benefit_Level__c=hex2DecMap.get(p.pi.Benefit_Level__c);   
                        }
                        person.benefitLevel=p.pi.Benefit_Level__c;                       
                        //person.basicPlanProduct=basicPlanProduct;//added by ken ,for getting portalproduct's offercode & si to call get quote ws
                           
                        //System.debug('[TMCreatePolicyCtrl]getPaymentPremium().p.availableDiscountMap='+p.availableDiscountMap);
                        //add by ken
                        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
                        currentPolicyNo = p.piPolicy.Policy_No__c;// only validate current policy discount
                        selectMandatoryDiscount(p.availableDiscountMap, p);/* add by Jack on 2022-01-04 for project: Discount enhancement select mandatory discount by default */
                        person.discountMap=TMPolicyUtil.getPremiumDiscounts(p.availableDiscountMap,selectedProduct,paymentFrequencyDiscountMap,premiumDiscountMap,p.discount1,p.discount2,selectedPaymentFrequency,false);
                        //System.debug('[TMCreatePolicyCtrl]getPaymentPremium().person.discountMap='+person.discountMap);
                        person.availableRiderBenefitlevelItemList=p.availableRiderBenefitlevelItemList;
                        //getPremiumDiscount(person);
                    }

                    // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
                    if(p.availableDiscountMap.containsKey('Personal Choice premium refund')){
                        p.selectedRefund='Personal Choice premium refund';
                    }
                }
                currentPolicyNo = '';// reset value
                //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().personMap: '+personMap);
                //System.debug('[TMCreatePolicyCtrl] getPaymentPremium().planCodeSet: '+planCodeSet+' campaignCode: '+campaignCode);
                TMEsalesHelper helper=new TMEsalesHelper();//add by ken 
                premiumAmountList=helper.calculateQuotation(personMap,planCodeSet,campaignCode,newPolicy.Payment_Frequency__c);//add by andy
                //premiumAmountList=TMEsalesHelper.calculateQuotation(personMap,planCodeSet,campaignCode);//comment by ken
                //initPremiumAmountList(false);    
                initPremiumAmountList(true);//Add by Manuel
                initCouponInfo();//AM project coupon jack add init coupon information
                initCouponTotal();//AM project coupon jack init total coupon
                initFamilyDiscountPannel(false);//jack add for friend and family discount in SFDC
                //System.debug('[TMCreatePolicyCtrl]getPaymentPremium().totalPremium: '+totalPremium);
                // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-17
                System.debug('executing getPaymentPremium()');
                for (String code: planCodeSet){
                    System.debug('code '+ code);
                }
				// END https://jira.express-scripts.com/browse/HKITSFDC-17
            }
            this.isWSError=false;
           
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            // WellnessCI
            // if(!personInsuredStructureList.isEmpty()){
            //     PersonInsuredStructure structure=personInsuredStructureList.get(0);
            //     if(structure.availableDiscountMap.containsKey('Personal Choice premium refund')){
            //         this.selectedRefund='Personal Choice premium refund';
            //     }
            // }
            // WellnessCI
        }catch(Exception e){
            this.isWSError=true;
            isPaymentButtonClicked=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,wsErrorMsg));
            System.debug('>>>> WS Error:'+e.getMessage());
            System.debug('>>>> WS Error:'+e.getLineNumber());
            System.debug('>>>> WS Error:'+e.getStackTraceString());
        }
        // TM Work at Home
        if(orgnDataBeforeMask.workAtHome){
            maskSensiData();
        }
    }
    //get quote end
    
    public void initPremiumAmountList(Boolean recalculateFlag){       
        totalPremium=new TMEsalesHelper.PremiumAmt();
        totalPremium.originalPremiumMonth=0;
        totalPremium.annualPremium=0;
        totalPremium.discountPercent=0;
        totalPremium.discountPremium=0;
        totalPremium.medicalLoadingPercent=0;
        totalPremium.medicalLoadingAmount=0;
        totalPremium.actualPremium=0;
        totalPremium.subTotal=0;
        totalPremium.totalDiscountPercent=0;
        totalPremium.totalDiscountPremium=0;
        System.debug('[initPremiumAmountList] premiumAmountList='+premiumAmountList);
        if(premiumAmountList!=null && premiumAmountList.size()>0){         
            //Map<String,Decimal> discountMap=getPremiumDiscounts();// comment by ken
            List<Decimal> discountList=new List<Decimal>();
            discountList.add(premiumAmountList.get(0).discountPercent);//add ws default discount
            
            Decimal tempSubTotal=0;
            String tempPIKey='';
            Map<String,Decimal> subTotalMap=new Map<String,Decimal>();
            for(TMEsalesHelper.PremiumAmt tol: premiumAmountList){               
                if(recalculateFlag){                   
                    Decimal finalDiscountPercentage=0;
                    System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().pisMap.get(tol.policyId).availableDiscountMap='+pisMap.get(tol.policyId).availableDiscountMap);
                    // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
                    Map<String,Decimal> piDiscountMap=TMPolicyUtil.getPremiumDiscounts(pisMap.get(tol.policyId).availableDiscountMap,selectedProduct,paymentFrequencyDiscountMap,premiumDiscountMap,pisMap.get(tol.policyId).discount1,pisMap.get(tol.policyId).discount2,selectedPaymentFrequency,false);
                    System.debug('ctrl.selected discount1 '+pisMap.get(tol.policyId).discount1);
                    System.debug('ctrl.selected discount2 '+pisMap.get(tol.policyId).discount2);

                    if('DETG'.equalsIgnoreCase(tol.productCode) && pisMap.get(tol.policyId).pi.PI_Age__c<18){
                        piDiscountMap.put('CHILD DISCOUNT*',0);
                    }
                    //Add by Owen, 2024.1.12 add for elite360 for child DETG2.
                    //Rancho_JOBR378_20240717 - CHILD DISCOUNT (GROUP) not support dental rider
                    if('DETG2'.equalsIgnoreCase(tol.productCode) && pisMap.get(tol.policyId).pi.PI_Age__c<18){
                        piDiscountMap.put('CHILD DISCOUNT*',0);
                        piDiscountMap.put('CHILD DISCOUNT (GROUP)',0);
                    }
                    
                    System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().piDiscountMap='+piDiscountMap);
                    finalDiscountPercentage=TMEsalesHelper.getFinalDiscountPercentage(piDiscountMap);
                    //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().tol.annualPremium='+tol.annualPremium);
                    if(finalDiscountPercentage>0){
                        tol.totalDiscountPercent=finalDiscountPercentage;
                        tol.totalDiscountPremium=(null!=tol.annualPremium)?(tol.annualPremium * (finalDiscountPercentage/100)).Round(System.RoundingMode.HALF_UP):0;
                    }else{
                        tol.totalDiscountPremium=0;
                        tol.totalDiscountPercent=0;
                    }                                         
                }
                
                Decimal loading=0;
                if(null==pisMap.get(tol.policyId).piPolicy){
                    loading=0;
                }else{
                    loading=null==pisMap.get(tol.policyId).piPolicy.Loading__c?0 : pisMap.get(tol.policyId).piPolicy.Loading__c;
                }
                Boolean isSpecialProduct=TMEsalesHelper.specialProductCodeList.contains(tol.productCode);
                
                if(!String.isBlank(selectedPaymentFrequency) && selectedPaymentFrequency.equalsIgnoreCase('Monthly')){
                    tol.originalPremium=tol.originalPremiumMonth.Round(System.RoundingMode.HALF_UP);
                    tol.loadingPremium=(tol.originalPremium * loading/100).Round(System.RoundingMode.HALF_UP);
                    //tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct);
                    // if(selectedProduct.Product_Code__c.contains('PMGH')){
                    tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.annualPremium,tol.totalDiscountPercent,null,loading,isSpecialProduct,tol.modalFactor);/* add by Jack on 2022-03-25 for project: Premium mismatch with IPAS */
                    system.debug('tol.actualPremium:'+tol.actualPremium);
                    // }else{
                    //     tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct,null);
                    // }
                    
                }else if(!String.isBlank(selectedPaymentFrequency) && selectedPaymentFrequency.equalsIgnoreCase('Quarterly')){
                    tol.originalPremium=tol.originalPremiumMonth.Round(System.RoundingMode.HALF_UP) * 3;
                    tol.loadingPremium=(tol.originalPremium * loading/100).Round(System.RoundingMode.HALF_UP);
                    //tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct)*3;
                    if(selectedProduct.Product_Code__c.contains('PMGH')){
                        tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.annualPremium,tol.totalDiscountPercent,null,loading,isSpecialProduct,tol.modalFactor) * 3;
                    }else if(selectedProduct.Product_Code__c.contains('SP100')){//DPSP-1078
                        //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().selectedProduct.Product_Code__c='+selectedProduct.Product_Code__c);
                        //amt.actualPremium=TMEsalesHelper.calWithDiscount(amt.annualPremium,amt.totalDiscountPercent,null,pi.loading,isSpecialProductCode,modalFactor) * 3;
                        if(null==tol.totalDiscountPercent)
                            tol.totalDiscountPercent=0;
                        //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().tol.modalFactor='+tol.modalFactor+' tol.annualPremium='+tol.annualPremium+' tol.totalDiscountPercent='+tol.totalDiscountPercent);
                        tol.actualPremium=(tol.annualPremium * (1-tol.totalDiscountPercent/100) * tol.modalFactor * 3).Round(System.RoundingMode.HALF_UP);
                    }else{
                        tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct,null) * 3;
                    }
                }else if(!String.isBlank(selectedPaymentFrequency) && selectedPaymentFrequency.equalsIgnoreCase('Semi Annually')){
                    tol.originalPremium=tol.originalPremiumMonth.Round(System.RoundingMode.HALF_UP) * 6;
                    tol.loadingPremium=(tol.originalPremium * loading/100).Round(System.RoundingMode.HALF_UP);
                    //tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct)*6;
                    if(selectedProduct.Product_Code__c.contains('PMGH')){
                        tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.annualPremium,tol.totalDiscountPercent,null,loading,isSpecialProduct,tol.modalFactor) * 6;
                    }else if(selectedProduct.Product_Code__c.contains('SP100')){
                        if(null==tol.totalDiscountPercent)
                            tol.totalDiscountPercent=0;
                        tol.actualPremium=(tol.annualPremium * (1-tol.totalDiscountPercent/100) * 0.5).Round(System.RoundingMode.HALF_UP);
                    }else{
                        tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct,null) * 6;
                    }
                }else{//for annual
                    //Updated by Andy Li for JIRA ROP-13,as all specila product will return the BPAnnualPrem and BPMonthlyPrem;
                    //so we can use the data directly,no need to multiplied by 12
                    /*if(isSpecialProduct){
                        tol.originalPremium=tol.originalPremiumMonth.Round(System.RoundingMode.HALF_UP) * 12;
                        tol.loadingPremium=(tol.originalPremium * loading/100).Round(System.RoundingMode.HALF_UP);
                        tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.originalPremiumMonth,tol.totalDiscountPercent,null,loading,isSpecialProduct,null)*12;
                    }else{*/
                        tol.originalPremium=tol.annualPremium;
                        tol.loadingPremium=(tol.originalPremium * loading/100).Round(System.RoundingMode.HALF_UP);
                        tol.actualPremium=TMEsalesHelper.calWithDiscount(tol.annualPremium,tol.totalDiscountPercent,null,loading,isSpecialProduct,null);
                    /*}*/
                }
                
                //System.debug('[TMCreatePolicy] initPremiumAmountList().tol.actualPremium='+tol.actualPremium);               
                if(tol.originalPremiumMonth!=null){
                    totalPremium.originalPremiumMonth=totalPremium.originalPremiumMonth+tol.originalPremiumMonth;
                }    
                if(tol.annualPremium!=null){
                    totalPremium.annualPremium=totalPremium.annualPremium+tol.annualPremium;
                }
                if(tol.discountPremium!=null){
                    totalPremium.discountPremium=totalPremium.discountPremium+tol.discountPremium;
                }
                if(tol.totalDiscountPercent!=null){
                    totalPremium.totalDiscountPercent=totalPremium.totalDiscountPercent ;//+tol.totalDiscountPercent;
                }
                if(tol.totalDiscountPremium!=null){
                    totalPremium.totalDiscountPremium=totalPremium.totalDiscountPremium+tol.totalDiscountPremium;
                }
                if(tol.medicalLoadingPercent!=null){
                    totalPremium.medicalLoadingPercent=totalPremium.medicalLoadingPercent+tol.medicalLoadingPercent;
                }    
                if(tol.medicalLoadingAmount!=null){
                    totalPremium.medicalLoadingAmount=totalPremium.medicalLoadingAmount+tol.medicalLoadingAmount;
                }    
                if(tol.actualPremium!=null){
                    totalPremium.actualPremium=totalPremium.actualPremium+tol.actualPremium;
                    totalPremium.subTotal=totalPremium.actualPremium;
                    //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().totalPremium.subTotal='+totalPremium.subTotal);
                }                 
                if(recalculateFlag){
                    //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().tempPIkey='+tempPIkey);
                    //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().tol.premiumPerson='+tol.premiumPerson);
                    if(String.isBlank(tempPIKey) || !tempPIKey.equalsIgnoreCase(tol.premiumPerson)){
                        tempPIKey=tol.premiumPerson;
                        tempSubTotal=tol.actualPremium;
                    }else{
                        tempSubTotal=tempSubTotal+tol.actualPremium;
                    }
                    tol.subTotal=tempSubTotal;
                    subTotalMap.put(tol.premiumPerson,tol.subTotal);
                }
                //if(tol.subTotal!=null){
                //totalPremium.subTotal=totalPremium.subTotal+tol.subTotal;
                //}
            } // for loop end;            
            //To show error msg for unable to apply the discount ,added by ken
            Boolean isAllSelectedDiscount1Unavailable=true;
            Boolean isAllSelectedDiscount2Unavailable=true;
            
            //Add by Manuel to remind user there's available discount
            Map<String,String> mapAvailableDiscount=new Map<String,String>();            
            if(recalculateFlag){
                for(TMEsalesHelper.PremiumAmt tol: premiumAmountList){
                    if(!tol.isRider){// basic
                        tol.subTotal=subTotalMap.get(tol.premiumPerson);
                    }else{//rider
                        tol.subTotal=null;
                    }
                    //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList policyno='+pisMap.get(tol.policyId).piPolicy.Policy_No__c);
                    //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList pisMap.get(tol.policyId).availableDiscountMap='+pisMap.get(tol.policyId).availableDiscountMap);
                    //To show error msg for unable to apply the discount ,added by ken
                    //Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - validate in selectDiscount1 and selectDiscount2
                    // if(pisMap.get(tol.policyId).availableDiscountMap.get(selectedDiscount1)==true)
                    //     isAllSelectedDiscount1Unavailable=false;
                    // if(pisMap.get(tol.policyId).availableDiscountMap.get(selectedDiscount2)==true)
                    //     isAllSelectedDiscount2Unavailable=false;                   
                        
                    //Add by Manuel to remind user there's available discount
                    // for(integer i=0;i<discount12Options.size();i++){
                    //     String strCurrentDiscount=discount12Options.get(i).getValue();
                    //     if(pisMap.get(tol.policyId).availableDiscountMap.get(strCurrentDiscount)==true){
                    //         mapAvailableDiscount.put(strCurrentDiscount,'Eligible');
                    //     }
                    // }
                }
                //To show error msg for unable to apply the discount ,added by ken
                // if(null!=selectedDiscount1 && isAllSelectedDiscount1Unavailable){
                //     showDiscountErrorMsg=2;
                //     discountErrorMsg='This discount 1 is not eligible';
                //     selectedDiscount1=null;
                // }else if(null!=selectedDiscount2 && isAllSelectedDiscount2Unavailable){
                //     showDiscountErrorMsg=2;
                //     discountErrorMsg='This discount 2 is not eligible';
                //     selectedDiscount2=null;
                // }                
                //Add by Manuel to remind user there's available discount
                //SPS-104: remove warm reminder
                /*if(newPolicy.Product_Code__c=='VSTDG'||newPolicy.Product_Code__c=='VSMMG'||newPolicy.Product_Code__c=='VSUPG'){
                    if(null==selectedDiscount1 && null==selectedDiscount2 && mapAvailableDiscount.size()>0){
                        Set<String> keySetAvailableDiscount=mapAvailableDiscount.keySet();
                        showDiscountErrorMsg=2;
                        discountErrorMsg='Warm reminder: This application is eligible for '+keySetAvailableDiscount+' discount.';
                    }
                }*/
            }            
        } // end first if           
    }
        
    public void savePlanQuoteList(){
        //AM project coupon jack add comment to use public pisMap
        // Map<String,PersonInsuredStructure> pisMap=new Map<String,PersonInsuredStructure>();
        List<String> piPolicyIdList=new List<String>();
        for(PersonInsuredStructure pis : PersonInsuredStructureList){
            //System.debug('[TMCreatePolicyCtrl] initPremiumAmountList().pis.piPolicy.id'+pis.piPolicy.id);
            // pisMap.put(pis.piPolicy.id,pis);
            piPolicyIdList.add(pis.piPolicy.id);
        }
        planQuoteList.clear();
        for(TMEsalesHelper.PremiumAmt tol: premiumAmountList){
            Plan_Quote__c newObj=new Plan_Quote__c();    
            newObj.Premium__c=tol.actualPremium;
            newObj.Is_Rider__c=tol.isRider==null?false : tol.isRider;
            newObj.Product_Code__c=tol.productCode;
            newObj.Plan_Level__c=tol.benefitLevel;
            newObj.Policy__c=tol.policyId;
            
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            System.debug('tol.policyId: '+tol.policyId);
            System.debug('pismap: '+pisMap.get(tol.policyId));
            TMPolicyUtil.setDiscountCodeToPlanQuote(newObj,pisMap.get(tol.policyId),selectedProduct,paymentFrequencyDiscountMap,premiumDiscountMap,pisMap.get(tol.policyId).discount1,pisMap.get(tol.policyId).discount2,selectedPaymentFrequency);                        
            TM_General_Setting__c generalSetting=TM_General_Setting__c.getValues('Default');
            if(generalSetting!=null && String.isNotBlank(generalSetting.Special_Level_Rider_Product__c)){
                List<String> specialRiderList=generalSetting.Special_Level_Rider_Product__c.split(';');
                if(specialRiderList.contains(newPolicy.Plan_code__c)){
                    //System.debug('[[TMCreatePolicyCtrl]] specialRiderList contains '+newObj.Product_Code__c);
                    for(String riderkey : planLevelProductMap.get(newObj.Plan_Level__c).keySet()){
                        if(riderkey.contains(newObj.Product_Code__c)){
                            //System.debug('[[TMCreatePolicyCtrl]] riderkey contains '+newObj.Product_Code__c);
                            newObj.Rate_Scale__c=planLevelProductMap.get(newObj.Plan_Level__c).get(riderkey).rateScale;
                            
                            //jack add for Elite Revamp
                            //change rider's rate scale to hex
                            // if('10'.equals(newObj.Rate_Scale__c)){
                            //     newObj.Rate_Scale__c='A';
                            // }else if('11'.equals(newObj.Rate_Scale__c)){
                            //     newObj.Rate_Scale__c='B';
                            // }else if('12'.equals(newObj.Rate_Scale__c)){
                            //     newObj.Rate_Scale__c='C';
                            // }else if('13'.equals(newObj.Rate_Scale__c)){
                            //     newObj.Rate_Scale__c='D';
                            // }else if('14'.equals(newObj.Rate_Scale__c)){
                            //     newObj.Rate_Scale__c='E';
                            // }else if('15'.equals(newObj.Rate_Scale__c)){
                            //     newObj.Rate_Scale__c='F';
                            // }
                            newObj.Rate_Scale__c=dec2HexMap.get(newObj.Rate_Scale__c)==null?newObj.Rate_Scale__c:dec2HexMap.get(newObj.Rate_Scale__c);
                            //end                           
                            //System.debug('[[TMCreatePolicyCtrl]] savePlanQuoteList Rate_Scale__c '+newObj.Rate_Scale__c);
                        }
                    }
                }
            }
            
            //change basic plan rate scale to hex
            if(!newObj.Is_Rider__c){
                //jack add for Elite Revamp
                // if('10'.equals(newObj.Plan_Level__c)){
                //     newObj.Plan_Level__c='A';
                // }else if('11'.equals(newObj.Plan_Level__c)){
                //     newObj.Plan_Level__c='B';
                // }else if('12'.equals(newObj.Plan_Level__c)){
                //     newObj.Plan_Level__c='C';
                // }else if('13'.equals(newObj.Plan_Level__c)){
                //     newObj.Plan_Level__c='D';
                // }else if('14'.equals(newObj.Plan_Level__c)){
                //     newObj.Plan_Level__c='E';
                // }else if('15'.equals(newObj.Plan_Level__c)){
                //     newObj.Plan_Level__c='F';
                // }
                newObj.Plan_Level__c=dec2HexMap.get(newObj.Plan_Level__c)==null?newObj.Plan_Level__c:dec2HexMap.get(newObj.Plan_Level__c);
            }
            //end
            
            // add benefit amount
            if(wsProduct!=null){
                if(tol.isRider){
                    for(HttpCalloutVO.Rider r : wsProduct.riderList){
                        if(r.benefitLevelCode==tol.benefitLevel && r.riderCode==tol.productCode.replace('@','')){
                            for(HttpCalloutVO.BenefitDetail bd : r.benefitDetailList){
                                String code=bd.description.split(':')[0];
                                if(code==tol.productCode.replace('@','')){
                                    newObj.Benefit_amount__c=bd.amount;
                                }
                            }
                        }
                    }
                }else{
                    for(HttpCalloutVO.Benefit b : wsProduct.benefitList){
                        if(b.benefitLevelCode==tol.benefitLevel && b.planCode==tol.productCode.replace('@','')){
                            for(HttpCalloutVO.BenefitDetail bd : b.benefitDetailList){
                                String code=bd.description.split(':')[0];
                                if(code==tol.productCode.replace('@','')){
                                    newObj.Benefit_amount__c=bd.amount;
                                }
                            }
                        }
                    }
                }
            }
            planQuoteList.add(newObj);
        }
        //add mandatory rider plan quote
        if(mandatoryRiderCodesList.size()>0){
            for(PersonInsuredStructure pis : PersonInsuredStructureList){
                for(String ridercode : mandatoryRiderCodesList){
                    Plan_Quote__c newPlanQuote=new Plan_Quote__c();           
                    newPlanQuote.Is_Rider__c=true;
                    newPlanQuote.Product_Code__c=ridercode;
                    newPlanQuote.Policy__c=pis.piPolicy.id;
                    newPlanQuote.Is_Mandatory_Rider__c=true;
                    //WEI-296
                    if(!pis.pi.Benefit_Level__c.isNumeric()){
                        pis.pi.Benefit_Level__c=hex2DecMap.get(pis.pi.Benefit_Level__c);   
                    }
                    TMPolicyUtil.setPlanQuoteBenefitAmount(pis.pi.Benefit_Level__c,benefitMap,newPlanQuote);
                    planQuoteList.add(newPlanQuote);
                }
            }
        }
        //System.debug('[savePlanQuoteList] planQuoteList='+planQuoteList);              
        if(!planQuoteList.isEmpty()){
            List<Plan_Quote__c> oldList=[Select ID FROM Plan_Quote__c WHERE Policy__c in :piPolicyIdList];
            if(!oldList.isEmpty()){
                delete oldList;
            }
            // insert new records
           insert planQuoteList;
           planQuoteList.clear();
        }         
    }
    
    public void selectDiscount1(){
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        Boolean isError = false;
        System.debug('[selectDiscount1] currentPolicyNo='+currentPolicyNo);
        for(PersonInsuredStructure pis : personInsuredStructureList){
            // only validate the discount for current policy if current policy number is not blank
            // or validate the discount for all policies
            if(String.isNotBlank(currentPolicyNo) && pis.piPolicy.Policy_No__c != currentPolicyNo){
                continue;
            }
            
            System.debug('selected discount1='+pis.discount1);
            System.debug('selected discount2='+pis.discount2);
            System.debug('pis.availableDiscountMap='+pis.availableDiscountMap);

            if(String.isNotBlank(pis.discount1) && pis.discount1.equalsIgnoreCase(pis.discount2)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.TM_Discount_1_and_Discount_2_cannot_be_the_same));
                pis.showDiscountErrorMsg=1;                  
                pis.discount1=null;
                isError = true;
            }else if(('BUNDLE DISCOUNT'.equals(pis.discount1) && 'LOYALTY DISCOUNT'.equals(pis.discount2)) || ('LOYALTY DISCOUNT'.equals(pis.discount1) && 'BUNDLE DISCOUNT'.equals(pis.discount2))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.TM_Discount_Error_Msg));
                Premium_Discount__c pd1=premiumDiscountMap.get(pis.discount1);
                Premium_Discount__c pd2=premiumDiscountMap.get(pis.discount2);
                pis.discountErrorMsg=' is the larger discount. '+Label.TM_Discount_Error_Msg;
                if(pd1.Discount__c>pd2.Discount__c){
                    pis.discountErrorMsg=pd1.Discount_Type__c+pis.discountErrorMsg;
                    pis.discount2=null;
                }else if(pd1.Discount__c<pd2.Discount__c){
                    pis.discountErrorMsg=pd2.Discount_Type__c+pis.discountErrorMsg;
                    pis.discount1=null;
                    initPremiumAmountList(true);
                }else{
                    pis.discount1=null;
                    pis.discountErrorMsg='Discount 1 is the same as Discount 2';
                }
                pis.showDiscountErrorMsg=2;
                isError = true;
            }else if(String.isNotBlank(pis.discount1) && discountGroupValidation(pis.discount1,pis.discount2)){//jack add for friend and family discount in SFDC
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.TM_Discount_1_and_Discount_2_cannot_be_the_same));
                pis.showDiscountErrorMsg=1;                  
                pis.discount1=null;
                isError = true;
            }else if(String.isNotBlank(pis.discount1) && !discount12MonthChecking(pis.discount1)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Client owns lapsed/surrendered policy in past 12 months'));
                pis.showDiscountErrorMsg=2;
                pis.discountErrorMsg='Client owns lapsed/surrendered policy in past 12 months';
                pis.discount1=null;
                isError = true;
            }else if(String.isNotBlank(pis.discount1) && !pis.availableDiscountMap.get(pis.discount1)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This discount 1 is not eligible'));
                pis.showDiscountErrorMsg=2;
                pis.discountErrorMsg='This discount 1 is not eligible';
                pis.discount1=null;
                isError = true;
            }else if('YR1 50% DISCOUNT'.equals(pis.discount1) && amountOfPI > 5 && exceedDiscountUsageLimit(pis.discount1)){// Rancho_HKITSFDC402_20250930 - discount 83 only available for up to 5 policies
                System.debug('discount usage limit exceeded');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This discount 1 is not eligible'));
                pis.showDiscountErrorMsg=2;
                pis.discountErrorMsg='This discount 1 is not eligible';
                pis.discount1=null;
                isError = true;
            }else{//jack add for friend and family discount in SFDC
                pis.showDiscountErrorMsg=0;
            }
        }
        initFamilyDiscountPannel(true);//jack add for friend and family discount in SFDC
        currentPolicyNo = '';
        
        if(!isError){
            try{
                initPremiumAmountList(true); 
                TMProductStrategy.setMasterPolicyNumber(personInsuredStructureList,PHPersonalIDPolicylist);
            }catch(Exception e){
                System.debug('[selectDiscount1] catch an error:'+e.getMessage());
                System.debug('[TMCreatePolicyCtrl] selectDiscount1().error'+e.getLineNumber());
                System.debug('[TMCreatePolicyCtrl] selectDiscount1().error'+e.getStackTraceString());               
            }
        }
    }
    
    public void selectDiscount2(){
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        Boolean isError = false;
        System.debug('[selectDiscount2] currentPolicyNo='+currentPolicyNo);
        for(PersonInsuredStructure pis : personInsuredStructureList){
            System.debug('pi policy no: '+pis.piPolicy.Policy_No__c);
            if(String.isNotBlank(currentPolicyNo) && pis.piPolicy.Policy_No__c != currentPolicyNo){
                continue;
            }
            
            System.debug('selected discount1='+pis.discount1);
            System.debug('selected discount2='+pis.discount2);
            System.debug('pis.availableDiscountMap='+pis.availableDiscountMap);

            if(String.isNotBlank(pis.discount2) && pis.discount2.equalsIgnoreCase(pis.discount1)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.TM_Discount_1_and_Discount_2_cannot_be_the_same));
                pis.showDiscountErrorMsg=1;
                pis.discount2=null;
                isError = true;
            }else if(('BUNDLE DISCOUNT'.equals(pis.discount1) && 'LOYALTY DISCOUNT'.equals(pis.discount2)) || ('LOYALTY DISCOUNT'.equals(pis.discount1) && 'BUNDLE DISCOUNT'.equals(pis.discount2))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.TM_Discount_Error_Msg));
                Premium_Discount__c pd1=premiumDiscountMap.get(pis.discount1);
                Premium_Discount__c pd2=premiumDiscountMap.get(pis.discount2);
                pis.discountErrorMsg=' is the larger discount. '+Label.TM_Discount_Error_Msg;
                if(pd1.Discount__c>pd2.Discount__c){
                    pis.discountErrorMsg=pd1.Discount_Type__c+pis.discountErrorMsg;
                    pis.discount2=null;
                }else if(pd1.Discount__c<pd2.Discount__c){
                    pis.discountErrorMsg=pd2.Discount_Type__c+pis.discountErrorMsg;
                    pis.discount1=null;
                    initPremiumAmountList(true);
                }else{
                    pis.discountErrorMsg='Discount 1 is the same as Discount 2';
                    pis.discount2=null;
                }
                pis.showDiscountErrorMsg=2;           
                isError = true;
            }else if(String.isNotBlank(pis.discount2) && discountGroupValidation(pis.discount1,pis.discount2)){//jack add for friend and family discount in SFDC
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.TM_Discount_1_and_Discount_2_cannot_be_the_same));
                pis.showDiscountErrorMsg=1;                  
                pis.discount2=null;
                isError = true;
            }else if(String.isNotBlank(pis.discount2) && !discount12MonthChecking(pis.discount2)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Client owns lapsed/surrendered policy in past 12 months'));
                pis.showDiscountErrorMsg=2;
                pis.discountErrorMsg='Client owns lapsed/surrendered policy in past 12 months';
                pis.discount2=null;
                isError = true;
            }else if(String.isNotBlank(pis.discount2) && !pis.availableDiscountMap.get(pis.discount2)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This discount 2 is not eligible'));
                pis.showDiscountErrorMsg=2;
                pis.discountErrorMsg='This discount 2 is not eligible';
                pis.discount2=null;
                isError = true;
            }else if('YR1 50% DISCOUNT'.equals(pis.discount2) && amountOfPI > 5 && exceedDiscountUsageLimit(pis.discount2)){// Rancho_HKITSFDC402_20250930 - discount 83 only available for up to 5 policies
                System.debug('discount usage limit exceeded');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This discount 2 is not eligible'));
                pis.showDiscountErrorMsg=2;
                pis.discountErrorMsg='This discount 2 is not eligible';
                pis.discount2=null;
                isError = true;
            }else{
                pis.showDiscountErrorMsg=0;
            }
        }
        initFamilyDiscountPannel(true);//jack add for friend and family discount in SFDC
        currentPolicyNo = '';

        if(!isError){
            try{
                initPremiumAmountList(true);
                TMProductStrategy.setMasterPolicyNumber(personInsuredStructureList,PHPersonalIDPolicylist);
            }catch(Exception e){
                System.debug('[selectDiscount2] catch an error:'+e.getMessage());
                System.debug('[TMCreatePolicyCtrl] selectDiscount2().error'+e.getLineNumber());
                System.debug('[TMCreatePolicyCtrl] selectDiscount2().error'+e.getStackTraceString());               
            }
        }
    } 
    
    public void selectPaymentFrequency(){
        //System.debug('[selectPaymentFrequency] selectedPaymentFrequency='+selectedPaymentFrequency);
        try{
            initPremiumAmountList(true);
        }catch(Exception e){
            //System.debug('[TMCreatePolicyCtrl] selectPaymentFrequency() catch an error>>>>>>'+e.getMessage());
            //System.debug('[TMCreatePolicyCtrl] selectPaymentFrequency() catch an error>>>>>>'+e.getLineNumber());
            //System.debug('[TMCreatePolicyCtrl] selectPaymentFrequency() catch an error>>>>>>'+e.getStackTraceString());

        }
    }
    
    public void selectUWAppeal(){
        //System.debug('[TMCreatePolicyCtrl] selectUWAppeal() start ');
        try{
            TMPolicyUtil.changeUWResultByAppeal(ptvs.ctrl.personInsuredStructureList);
            TMPolicyUtil.adjustPolicyStatusByAppeal(ptvs.ctrl.personInsuredStructureList);
            TMPolicyUtil.discountValidation(ptvs);// When agent change appeal question,PI's over all result will be changed so that PI's availableDiscountMap will be changed 
            initPremiumAmountList(true);
        }catch(Exception e){
            //System.debug('[TMCreatePolicyCtrl] selectUWAppeal() catch an error>>>>>>'+e.getMessage());
            //System.debug('[TMCreatePolicyCtrl] selectUWAppeal() catch an error>>>>>>'+e.getLineNumber());
            //System.debug('[TMCreatePolicyCtrl] selectUWAppeal() catch an error>>>>>>'+e.getStackTraceString());
        }
    }
    
    //Action function for edit credit card button
    public void editCrerditCardNumber(){
        //System.debug('[TMCreatePolicyCtrl] editCrerditCardNumber');
        newPolicy.Credit_Card_Number_Mask__c='';
        newPolicy.Credit_Card_Number__c='';
        this.showEditCreditCardNumber=true;
    }
    //Action function for edit bank acc button
    public void editBankNumber(){
        //System.debug('[TMCreatePolicyCtrl] editBankNumber');
        newPolicy.Bank_Account_No_Mask__c='';
        newPolicy.Bank_Account_No__c='';
        this.showEditBankNumber=true;
        //System.debug('[TMCreatePolicyCtrl] editBankNumber end');
    }
    
    //Action function for remove invalid PI
    public void removeInvalidPI(){
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(pis.piPolicy.policy_no__c==this.removePolicyNumber){
                pis.piPolicy.policy_status__c='Invalid';
            }
        }
    }
    
    //Action function for cancel remove invalid PI
    public void cancelRemoveInvalidPI(){
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(pis.piPolicy.policy_no__c==this.cancelRemovePolicyNumber){
                pis.piPolicy.policy_status__c='Pending Payment';
            }
        }
    }
    
    public void updatePIBenefitLevel(){
        if(this.currentStep<STEP_CONFIRMATION_PAYMENT){
            return;
        }
        List<Person_Insured__c> piList=new List<Person_Insured__c>();
        //System.debug('[TMCreatePolicyCtrl] updatePIBenefitLevel currentStep='+this.currentStep);
        for(personInsuredStructure pis : personInsuredStructureList){
            //System.debug('[TMCreatePolicyCtrl] updatePIBenefitLevel pis.pi.benefit_Level__c='+pis.pi.Benefit_Level__c);
            if(this.currentStep>=STEP_CONFIRMATION_PAYMENT){
                pis.pi.Benefit_Level__c=dec2HexMap.get(pis.pi.Benefit_Level__c)==null? 
                    pis.pi.Benefit_Level__c:dec2HexMap.get(pis.pi.Benefit_Level__c);
                piList.add(pis.pi);
            }else{
                pis.pi.Benefit_Level__c=hex2DecMap.get(pis.pi.Benefit_Level__c)==null? 
                   pis.pi.Benefit_Level__c:hex2DecMap.get(pis.pi.Benefit_Level__c);
                piList.add(pis.pi);
            }
        }
        // update piList;/* add by Jack on 2022-01-11 for project: Discount Enhancement */
    }
    
    public void showBMIforSpecialProduct(){
        TMPolicyUtil.policyTransactionValidation(ptvs);
    }
    // end add
    
    //Add by Kermit at 20191216
    //Validate integrity of PIs' basic information
    public void validateInfoIntegrity(){       
        for(personInsuredStructure pis : personInsuredStructureList){
            //System.debug('TMCreatePolicyCtrl.validateInfoIntegrity() to_Save_Policy_No__c='+pis.piPolicy.to_Save_Policy_No__c);
            if(String.isBlank(pis.piPolicy.Policy_No__c)){
                if(String.isNotBlank(pis.piPolicy.Application_Id__c)){
                    pis.piPolicy.Policy_No__c=pis.piPolicy.Application_Id__c.split('_')[0];}
                else if(String.isNotBlank(pis.piPolicy.to_Save_Policy_No__c)){
                    pis.piPolicy.Policy_No__c=pis.piPolicy.to_Save_Policy_No__c;}
                else{
                    //System.debug('[TMCreatePolicyCtrl] validateInfoIntegrity newPolicy.Product__c='+newPolicy.Product__c);
                    Product__c pro=productMap.get(newPolicy.Product__c);
                    pis.piPolicy.Policy_No__c=TMPolicyUtil.generatePolicyNumber(pro.Policy_Prefix__c);
                    //System.debug('[TMCreatePolicyCtrl] validateInfoIntegrity pis.piPolicy.Policy_No__c='+pis.piPolicy.Policy_No__c);
                }
                pis.piPolicy.to_Save_Policy_No__c=pis.piPolicy.Policy_No__c;
            }
        }
    }
    //end
    
    public void initPolIdPolicyNoMap(){
        initIndicator=false;
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(String.isNotBlank(pis.piPolicy.Policy_No__c))
                this.PolIdPolicyNoMap.put(pis.piPolicy.Product_Code__c+pis.piPolicy.Id,pis.piPolicy.Policy_No__c);
        }
    }
    //End add
    
    public void onchangeMissingCDD(){
        if(newPolicy.Missing_CDD_Info__c){
            policyTransaction.LC_Assessed__c=null;
            policyTransaction.LC_Reviewer__c=null;
            policyTransaction.LC_Reviewer_Date__c=null;
        }
        //System.debug('[TMCreatePolicyCtrl] newPolicy.Missing_CDD_Info__c='+newPolicy.Missing_CDD_Info__c);
    }    
    
    public void createTestCase(){
        //System.debug('[TMCreatePolicyCtrl] create Test case');
        init();
        initPolicyTransaction();
        initPolicy();
        New_Policy__c tmp=[SELECT Id,Policy_No__c,Product__c FROM New_Policy__c WHERE Opportunity__c=:opportunityId order by createddate desc limit 1];
        Product__c pro=productMap.get(tmp.Product__c);
        policyTransaction=new Policy_Transaction__c(
            Number_of_Person_Insured__c=1,
            Core_Campaign__c=campaignId,
            Opportunity__c=opportunityId,
            Account__c=accountId,
            Step__c='2',
            Product_Code__c=pro.Product_Code__c,
            Product_Name__c=pro.Name,
            Status__c='Pending Basic Information'
       );
        savePolicyTransaction();
        newPolicy=new New_Policy__c(
            Policy_no__c=tmp.Policy_No__c,
            Policy_Transaction__c=policyTransaction.Id,
            Opportunity__c=opportunityId,
            Appeal__c=APPEAL_YES,
            Product_Code__c=policyTransaction.Product_Code__c,
            Policy_Status__c='Pending Basic Information',
            Appeal_For_UW_Result__c=APPEAL_YES,
            Product__c=pro.Id
       );
        policyList.clear();
        policyList.add(newPolicy);
        savePolicy();
        initPersonInsuredInfo();
        this.currentStep++;
    }

    //jack JR1641
    public void detectCorAddressChange(){
        newPolicy.Is_Corr_Address_Country_Changed__c=true ;
    }

    /**
    *   AH19572 avoid invalid value is copied to person insured records,include: '男'， '女','F','M',' F 'with white space
    *   @param inGender - old gender value
    *   @return String - new gender value
    *   @Author Zane Zh  - 10082020
    **/
    private String adjustGender(String inGender){
        String adjGen=inGender;
        Map<String,String> adjustGenderMap=new Map<String,String>{                                                  
            'F'=>'Female','M'=>'Male',
            '女'=>'Female','男'=>'Male'
        };

        if(String.isNotBlank(adjGen)){
                String tempGender=adjGen.trim();
                if (adjustGenderMap.containsKey(tempGender)){
                    adjGen=adjustGenderMap.get(tempGender);
                }
        }
        return adjGen;     
    }

    /**
    *   TM Work at Home: mask certain sensitive information if TM user works at home
    *   @param  newPolicy - policy holder information
    *   @param personInsuredStructureList - list of person insured information
    *   @Author Zane Zh  - 10082020
    **/
    public void maskSensiData(){
        if(!orgnDataBeforeMask.isMaskedPIPH){
            // show information on step 2
            // mask policy holder information block
            orgnDataBeforeMask.Home_Phone_Ori=newPolicy.Home_Phone__c;
            orgnDataBeforeMask.Home_Phone=orgnDataBeforeMask.maskData(newPolicy.Home_Phone__c,4);
            newPolicy.Home_Phone__c=orgnDataBeforeMask.maskData(newPolicy.Home_Phone__c,4);
            orgnDataBeforeMask.Mobile_Phone_Ori=newPolicy.Mobile_Phone__c;
            orgnDataBeforeMask.Mobile_Phone=orgnDataBeforeMask.maskData(newPolicy.Mobile_Phone__c,4);
            newPolicy.Mobile_Phone__c=orgnDataBeforeMask.maskData(newPolicy.Mobile_Phone__c,4);
            orgnDataBeforeMask.Personal_ID_Ori=newPolicy.Personal_ID__c;
            orgnDataBeforeMask.Personal_ID=orgnDataBeforeMask.maskData(newPolicy.Personal_ID__c,4);
            newPolicy.Personal_ID__c=orgnDataBeforeMask.maskData(newPolicy.Personal_ID__c,4);
            orgnDataBeforeMask.Residential_Address_1_Ori=newPolicy.Residential_Address_1__c;
            orgnDataBeforeMask.Residential_Address_1=orgnDataBeforeMask.maskData(newPolicy.Residential_Address_1__c,0);
            newPolicy.Residential_Address_1__c=orgnDataBeforeMask.maskData(newPolicy.Residential_Address_1__c,0);            
            orgnDataBeforeMask.Corresponding_Address_1_Ori=newPolicy.Corresponding_Address_1__c;
            orgnDataBeforeMask.Corresponding_Address_1=orgnDataBeforeMask.maskData(newPolicy.Corresponding_Address_1__c,0);
            newPolicy.Corresponding_Address_1__c=orgnDataBeforeMask.maskData(newPolicy.Corresponding_Address_1__c,0);           
            // mask person insured block
            orgnDataBeforeMask.PI_Personal_ID_Map=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Personal_ID_Map_Ori=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Parent_Personal_ID_Map=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Parent_Personal_ID_Map_Ori=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Spouse_Personal_ID_Map=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Spouse_Personal_ID_Map_Ori=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Residential_Address_1_Map=new Map<Integer,String>();
            orgnDataBeforeMask.PI_Residential_Address_1_Map_Ori=new Map<Integer,String>();

            for(Integer i=0;personInsuredStructureList.size()>i;i++){
                //personal id
                orgnDataBeforeMask.PI_Personal_ID_Map_Ori.put(i,personInsuredStructureList[i].pi.Personal_ID__c);
                orgnDataBeforeMask.PI_Personal_ID_Map.put(i,orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Personal_ID__c,4));
                personInsuredStructureList[i].pi.Personal_ID__c=orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Personal_ID__c,4);
                // parent id
                orgnDataBeforeMask.PI_Parent_Personal_ID_Map_Ori.put(i,personInsuredStructureList[i].pi.Parent_PI_ID__c);
                orgnDataBeforeMask.PI_Parent_Personal_ID_Map.put(i,orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Parent_PI_ID__c,4));
                personInsuredStructureList[i].pi.Parent_PI_ID__c=orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Parent_PI_ID__c,4);
                // spouce id
                orgnDataBeforeMask.PI_Spouse_Personal_ID_Map_Ori.put(i,personInsuredStructureList[i].pi.Spouse_PI_ID__c);
                orgnDataBeforeMask.PI_Spouse_Personal_ID_Map.put(i,orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Spouse_PI_ID__c,4));
                personInsuredStructureList[i].pi.Spouse_PI_ID__c=orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Spouse_PI_ID__c,4);
                // residential address
                orgnDataBeforeMask.PI_Residential_Address_1_Map_Ori.put(i,personInsuredStructureList[i].pi.Residential_Address_1__c);
                orgnDataBeforeMask.PI_Residential_Address_1_Map.put(i,orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Residential_Address_1__c,0));
                personInsuredStructureList[i].pi.Residential_Address_1__c=orgnDataBeforeMask.maskData(personInsuredStructureList[i].pi.Residential_Address_1__c,0);
                
                // show bebeficiary information on step 3
                for(Integer j=0;personInsuredStructureList[i].beneficiaryList.size()>j;j++){
                    //Beneficiary Personal Id
                    BeneficiaryStruct bnfStru=personInsuredStructureList[i].beneficiaryList[j];
                    bnfStru.origPersonId=bnfStru.beneficiary.Person_ID__c;
                    bnfStru.beneficiary.Person_ID__c=orgnDataBeforeMask.maskData(bnfStru.origPersonId,4);
                }
            }
            orgnDataBeforeMask.isMaskedPIPH=true;            
        }
    }

    /**
    *   TM Work at Home: get original sensitive information when save policy or back to step 2: PH/ PI information
    *   @param  newPolicy - policy holder information
    *   @param personInsuredStructureList - list of person insured information
    *   @Author Zane Zh  - 10082020
    **/
    public void deMaskSensiData(){
        // retrie original value when masked value is not changed. will not put original value if new value is difference with stored value in orgnDataBeforeMask record.
        if(String.isNotBlank(newPolicy.Home_Phone__c) && newPolicy.Home_Phone__c==orgnDataBeforeMask.Home_Phone){
            newPolicy.Home_Phone__c=orgnDataBeforeMask.Home_Phone_Ori;
        }

        if(String.isNotBlank(newPolicy.Mobile_Phone__c) && newPolicy.Mobile_Phone__c==orgnDataBeforeMask.Mobile_Phone){
            newPolicy.Mobile_Phone__c=orgnDataBeforeMask.Mobile_Phone_Ori;
        }

        if(String.isNotBlank(newPolicy.Personal_ID__c) && newPolicy.Personal_ID__c==orgnDataBeforeMask.Personal_ID){
            newPolicy.Personal_ID__c=orgnDataBeforeMask.Personal_ID_Ori;
        }

        if(String.isNotBlank(newPolicy.Residential_Address_1__c) && newPolicy.Residential_Address_1__c==orgnDataBeforeMask.Residential_Address_1){
            newPolicy.Residential_Address_1__c=orgnDataBeforeMask.Residential_Address_1_Ori;
        }

        //scenario: corresponding address 1 was copied from residential address by 'Copy Address' button. copied address is a masked value so we need refer to residential address
        if(String.isNotBlank(newPolicy.Corresponding_Address_1__c) && true==personInsuredStructureList[0].isCopyCrspdAddress && newPolicy.Corresponding_Address_1__c==orgnDataBeforeMask.Residential_Address_1){
            newPolicy.Corresponding_Address_1__c=orgnDataBeforeMask.Residential_Address_1_Ori;
        }else if(String.isNotBlank(newPolicy.Corresponding_Address_1__c) && newPolicy.Corresponding_Address_1__c==orgnDataBeforeMask.Corresponding_Address_1){
            newPolicy.Corresponding_Address_1__c=orgnDataBeforeMask.Corresponding_Address_1_Ori;
        }
        personInsuredStructureList[0].isCopyCrspdAddress=false;
        
        // retrive original value for person insured
        for(Integer i=0;personInsuredStructureList.size()>i;i++){
            //scenario: Copy Holder button : masked personal ID from copying holder. we should get real value and reset the value on person insured.
            if(String.isNotBlank(personInsuredStructureList[i].pi.Personal_ID__c) && true==personInsuredStructureList[i].isCopyHolder 
                && personInsuredStructureList[i].pi.Personal_ID__c==orgnDataBeforeMask.Personal_ID){
                personInsuredStructureList[i].pi.Personal_ID__c=orgnDataBeforeMask.Personal_ID_Ori;
            }else if(String.isNotBlank(personInsuredStructureList[i].pi.Personal_ID__c) && personInsuredStructureList[i].pi.Personal_ID__c==orgnDataBeforeMask.PI_Personal_ID_Map.get(i)){
                // de-mask data for confirmation payment page. 
                personInsuredStructureList[i].pi.Personal_ID__c=orgnDataBeforeMask.PI_Personal_ID_Map_Ori.get(i);
            }

            // de-mask parent personal id
            if(String.isNotBlank(personInsuredStructureList[i].pi.Parent_PI_ID__c) && personInsuredStructureList[i].pi.Parent_PI_ID__c==orgnDataBeforeMask.Personal_ID 
                && String.isBlank(orgnDataBeforeMask.PI_Parent_Personal_ID_Map_Ori.get(i))){
                personInsuredStructureList[i].pi.Parent_PI_ID__c=orgnDataBeforeMask.Personal_ID_Ori;
            }else if(String.isNotBlank(personInsuredStructureList[i].pi.Parent_PI_ID__c) && personInsuredStructureList[i].pi.Parent_PI_ID__c==orgnDataBeforeMask.PI_Parent_Personal_ID_Map.get(i)){
                // de-mask data for confirmation payment page. 
                personInsuredStructureList[i].pi.Parent_PI_ID__c=orgnDataBeforeMask.PI_Parent_Personal_ID_Map_Ori.get(i);
            }

            //spouse personal id
            if(String.isNotBlank(personInsuredStructureList[i].pi.Spouse_PI_ID__c) && personInsuredStructureList[i].pi.Spouse_PI_ID__c==orgnDataBeforeMask.Personal_ID 
                && String.isBlank(orgnDataBeforeMask.PI_Spouse_Personal_ID_Map_Ori.get(i))){
                personInsuredStructureList[i].pi.Spouse_PI_ID__c=orgnDataBeforeMask.Personal_ID_Ori;
            }else if(String.isNotBlank(personInsuredStructureList[i].pi.Spouse_PI_ID__c) && personInsuredStructureList[i].pi.Spouse_PI_ID__c==orgnDataBeforeMask.PI_Spouse_Personal_ID_Map.get(i)){
                personInsuredStructureList[i].pi.Spouse_PI_ID__c=orgnDataBeforeMask.PI_Spouse_Personal_ID_Map_Ori.get(i);
            }

            personInsuredStructureList[i].isCopyHolder=false;
            // de-mask residential address of PI .  click 'Copy Holder Address'
            if(String.isNotBlank(personInsuredStructureList[i].pi.Residential_Address_1__c) && true==personInsuredStructureList[i].iscopyHlderAddress 
                && personInsuredStructureList[i].pi.Residential_Address_1__c==orgnDataBeforeMask.Residential_Address_1){
                personInsuredStructureList[i].pi.Residential_Address_1__c=orgnDataBeforeMask.Residential_Address_1_Ori;
            }else if(String.isNotBlank(personInsuredStructureList[i].pi.Residential_Address_1__c) && personInsuredStructureList[i].pi.Residential_Address_1__c==orgnDataBeforeMask.PI_Residential_Address_1_Map.get(i)){
                personInsuredStructureList[i].pi.Residential_Address_1__c=orgnDataBeforeMask.PI_Residential_Address_1_Map_Ori.get(i);
            }
            personInsuredStructureList[i].iscopyHlderAddress=false;

            // de-mask data for beneficiary : at step 3. scenario:  back to step2 or next to step4
            for(Integer j=0;personInsuredStructureList[i].beneficiaryList.size()>j;j++){              
                BeneficiaryStruct bnfStru=personInsuredStructureList[i].beneficiaryList[j];
                if(String.isNotBlank(bnfStru.beneficiary.Person_ID__c) && bnfStru.beneficiary.Person_ID__c.contains('*') && String.isNotBlank(bnfStru.origPersonId)){
                    bnfStru.beneficiary.Person_ID__c=bnfStru.origPersonId;
                }   
            }
        }

        orgnDataBeforeMask.isMaskedPIPH=false;
        //System.debug(LoggingLevel.INFO,'***deMask data newPolicy: '+newPolicy);
        //System.debug(LoggingLevel.INFO,'***deMask data personInsuredStructureList: '+personInsuredStructureList);
    }

    /**
    *   TM Work at Home: store original sensitive information in this structrue after masking sensitive data
    *   @Author Zane Zh  - 10082020
    **/
    public class OriginalData {
        public Boolean isMaskedPIPH {get;set;} // indicate whether be masked
        public Boolean isMaskedBenefi {get;set;} // indicate whether be masked
        public Boolean workAtHome{get;set;} //indicate whether user work at home
        public String Home_Phone {get;set;} // masked value
        public String Home_Phone_Ori{get;set;} // original value
        public String Mobile_Phone{get;set;}
        public String Mobile_Phone_Ori{get;set;}
        public String Personal_ID{get;set;}
        public String Personal_ID_Ori{get;set;}
        public String Residential_Address_1{get;set;}
        public String Residential_Address_1_Ori{get;set;}
        public String Corresponding_Address_1{get;set;}
        public String Corresponding_Address_1_Ori{get;set;}
        /*Person Insured data*/
        public Map<Integer,String> PI_Personal_ID_Map{get;set;}  // of person insureds
        public Map<Integer,String> PI_Personal_ID_Map_Ori{get;set;}  // of person insureds
        public Map<Integer,String> PI_Parent_Personal_ID_Map{get;set;}  // of person insureds
        public Map<Integer,String> PI_Parent_Personal_ID_Map_Ori{get;set;}  // of person insureds
        public Map<Integer,String> PI_Spouse_Personal_ID_Map{get;set;}  // of person insureds
        public Map<Integer,String> PI_Spouse_Personal_ID_Map_Ori{get;set;}  // of person insureds
        public Map<Integer,String> PI_Residential_Address_1_Map{get;set;}  // of person insureds
        public Map<Integer,String> PI_Residential_Address_1_Map_Ori{get;set;}  // of person insureds

        public OriginalData(){
            workAtHome=false;
            isMaskedPIPH=false;
            isMaskedBenefi=false;
        }
        /**
        * @param oriStr - original string; retainLen - how length that the string donse't be masked
        **/
        public String maskData(String oriStr,Integer retainLen){
            String maskStr=oriStr;
            if(String.isNotBlank(oriStr) && oriStr.length()>retainLen){               
                maskStr=oriStr.left(retainLen).rightPad(oriStr.length(),'*');
            }
            return maskStr;
        }
    }
    
    //TM Work From Home_20200827
    public void refreshPaymentInformation(){
        BankAccountHelper helper=new BankAccountHelper();
        Bank_Account__c bank=helper.getBankAccountbyOpportunity(this.opportunityId,this.PolIdPolicyNoMap.values(),selectedPaymentType);
        if(bank!=null){
            if(bank.Payment_Type__c==PAYMENTTYPE_BANK){
                newPolicy.Bank_Account_No__c=bank.Bank_Account_No__c;
                newPolicy.Bank_Account_No_Mask__c=TMPolicyUtil.maskBankAccountNumber(newPolicy.Bank_Account_No__c);
            }else if(bank.Payment_Type__c==PAYMENTTYPE_CREDIT){
                newPolicy.Credit_Card_Number__c=bank.Credit_Card_No__c;
                newPolicy.Credit_Card_Number_Mask__c=TMPolicyUtil.maskBankAccountNumber(newPolicy.Credit_Card_Number__c);
            }
        }
    }
    
    public void initializeRefund(){
        Campaign selectedCampaign;
        if(selectedProduct==null){
            selectedCampaign=this.cam;
        }else{
          selectedCampaign=productIdCampaignMap.get(selectedProduct.Id);
        }
        this.refundOptions=new List<SelectOption>();
        refundOptions.add(new SelectOption('','--None--'));
        for(Premium_Discount__c refund : [SELECT Id,Discount_Type__c FROM Premium_Discount__c WHERE RecordType.DeveloperName='Premium_Refund' AND Campaign__c=:selectedCampaign.Id]){
            this.refundOptions.add(new SelectOption(refund.Discount_Type__c,refund.Discount_Type__c));
            this.premiumRefundMap.put(refund.Discount_Type__c,refund);
            //System.debug('[TMCreatePolicyCtrl] initializeRefund Discount_Type__c='+refund.Discount_Type__c);
        }
    }
    //wellness
    public void onSelectedRefund(){
        Boolean isEligible=false;
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        // this.showRefundErrorMessage=0;
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(String.isNotBlank(currentPolicyNo) && pis.piPolicy.Policy_No__c != currentPolicyNo){
                continue;
            }

            if(String.isBlank(pis.selectedRefund)){
                pis.piPolicy.Refund_Discount__c=pis.selectedRefund;
                return;
            }

            if(pis.availableDiscountMap.get(pis.selectedRefund)){
                pis.piPolicy.Refund_Discount__c=pis.selectedRefund;
                isEligible=true;
            }else{
                pis.selectedRefund=null;
                pis.showRefundErrorMessage=1;
                pis.refundErrorMessage='Premium refund isn\'t eligible';
            }
        }
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        if(isEligible){
            TMProductStrategy.setMasterPolicyNumber(personInsuredStructureList,PHPersonalIDPolicylist);
        }

        // if(String.isBlank(selectedRefund)){
        //     for(PersonInsuredStructure pis : personInsuredStructureList){
        //         pis.piPolicy.Refund_Discount__c=selectedRefund;
        //     }
        //     return;
        // }
        // for(PersonInsuredStructure pis : personInsuredStructureList){
        //     //System.debug('[TMCreatePolicyCtrl] onSelectedRefund pis.availableDiscountMap='+pis.availableDiscountMap);
        //     if(pis.availableDiscountMap.get(selectedRefund)){
        //         pis.piPolicy.Refund_Discount__c=selectedRefund;
        //         isEligible=true;
        //     }
        // }
        // if(!isEligible){
        //     selectedRefund=null;
        //     this.showRefundErrorMessage=1;
        //     refundErrorMessage='Premium refund isn\'t eligible';
        // }else{
        //     TMProductStrategy.setMasterPolicyNumber(personInsuredStructureList,selectedRefund,PHPersonalIDPolicylist);
        // }
    }
    
    public void onCheckIsGA(){       
    }
    //wellness

    //GL31 jack add
    public void initAssessRider(){
        //System.debug('proRiderMapS'+proRiderMapS);
        // if(string.isBlank(ctrl.availableRider) && string.isNotBlank(proRiderMapS)){
        //     Map<String,Set<String>> proRiderMap=(Map<String,Set<String>>)JSON.deserialize(proRiderMapS,Map<String,Set<String>>.class);
        //     List<TM_Product_Category__c> tmProcatList=TM_Product_Category__c.getAll().values();
        //     Set<String> riderSet=CignaUtil.getAvailableRider(tmProcatList,proRiderMap,selectedProCode);
        //     if(riderSet!=null){
        //         if(riderSet.contains('ALL')){
        //             ctrl.availableRider='ALL';
        //         }else{
        //             ctrl.availableRider=String.join(new List<String>(riderSet),',');
        //         }
        //     }
        // }
        // System.debug('ctrl.availableRider:'+ctrl.availableRider);
        for(PersonInsuredStructure pi : personInsuredStructureList){
            System.debug('selected product: '+selectedProduct);
            Map<String,String> availRiderMap=pi.getAvailRiderMap(selectedProduct.product_code__c);
            pi.initAssessRider(policyTransaction.Prod_Rider_Map__c,selectedProduct.product_code__c,availRiderMap);
        }
    }

    //AM project coupon jack add 
    /**********************************************************************
     * initCouponInfo
     * @description:load couopn data from SF and validate the coupon through WS
     **********************************************************************/
    public void initCouponInfo(){
        pageMsg=null;
        //couponMsg='';
        try{
            List<coupon> couponList=new List<coupon>();
            enableCoupon=isCXagent;/* add by Jack on 2022-10-12 for project: JOBR-217 Enhance Asiamiles membership info validation */
            //enableCoupon=true;//Comment this if need to check if Sponsor code is CX4
            for(PersonInsuredStructure pi : personInsuredStructureList){
                Map<String,coupon> couponMaptemp=new Map<string,coupon>();
                if(pi.piPolicy.Coupons__r != null){
                    for(Coupon__c coupon:pi.piPolicy.Coupons__r){
                        Coupon couWrapper = new Coupon(coupon);
                        couponMaptemp.put(coupon.coupon_number__c,couWrapper);
                        // if(String.isBlank(couWrapper.getStatus())){
                        //     couponList.add(couWrapper);
                        // }
                    }
                }
                pi.couponMap=couponMaptemp;
                pi.couponMsg='';
                //use all coupon
                if(enableCoupon && couponMaptemp.values().size()>0){
                    CouponUtil.useCoupon(couponMaptemp.values(),pi.piPolicy.policy_no__c,'TM');
                    couponList.addAll(couponMaptemp.values());
                }
            }
            CouponUtil.saveCouponList(couponList);
            //check sponsor code of campaign
            System.debug('enableCoupon:'+enableCoupon+' cam.Business_Partner__r.Sponsor_Code__c:'+cam.Business_Partner__r.Sponsor_Code__c);
        }catch(Exception e){
            system.debug('initCouponInfo() getStackTraceString:'+e.getStackTraceString());
            pageMsg=e.getMessage();
        }
        if(pageMsg!=null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMsg));
        }
    }

    /**********************************************************************
     * initPisMap
     * @description:init pis map key->policy id, value->PersonInsuredStructure
     **********************************************************************/
    public void initPisMap(){
        pisMap=new Map<String,PersonInsuredStructure>();
        for(PersonInsuredStructure pis : PersonInsuredStructureList){
            pisMap.put(pis.piPolicy.id,pis);
        }
    }
    
    /**********************************************************************
     * addCoupon
     * @description: here is the back-end function for add button in coupon pannel
     * call ws to validate the coupon and then save the data from WS
     **********************************************************************/
    public void addCoupon(){
        // pageMsg=null;
        //couponMsg='';
        String policyId=ApexPages.currentPage().getParameters().get('policyId');
        PersonInsuredStructure pis=pisMap.get(policyId);
        pis.couponMsg='';
        try{
            if(CouponUtil.couponLengthValidate(pis.couponMap.size())){
                String couponNumber=pis.newCouponNumber;
                if(String.isBlank(pis.newCouponNumber)){
                    pis.couponMsg='No coupon number is inputted.';
                }else if(pis.couponMap.containsKey(pis.newCouponNumber)){
                    pis.couponMsg='Duplicated coupon cannot be added into policy.';
                }else{
                    //Call WS to use couopn and get result
                    Coupon couponWrap=new Coupon(couponNumber,policyId);
                    // CouponWrap.setAmount(200);
                    // CouponWrap.setStatus('Valid');
                    List<coupon> couponList=new List<coupon>();
                    couponList.add(couponWrap);
                    CouponUtil.useCoupon(couponList,pis.piPolicy.policy_no__c,'TM');
                    //display error message for invalid couopn and display and save valid coupon
                    List<coupon> validCoupon=new List<coupon>();
                    if(pis.couponMap==null){
                        pis.couponMap=new Map<string,coupon>();
                    }
                    for(Coupon cou:couponList){
                        if(cou.getStatus()=='Valid'){
                            validCoupon.add(cou);
                            pis.couponMap.put(cou.getCouponNumber(),cou);
                        }else{
                            //pis.couponMsg=pis.couponMsg+'Coupon with coupon number \''+cou.getCouponNumber()+'\' is invalid because '+cou.getErrorMessage()+'. ';
                            pis.couponMsg=cou.getErrorMessage();
                            system.debug('pis.couponMsg:'+pis.couponMsg);
                        }
                    }
                    CouponUtil.saveCouponList(validCoupon);
                    System.debug('pis.couponMap:'+pis.couponMap);
                    initCouponTotal();//clear coupon input text box
                    pis.newCouponNumber='';
                }
            }else{
                pis.couponMsg='Coupon cannot be added because it supports up to 10 coupons only.';
            }
        }catch(Exception e){
            system.debug('addCoupon() getStackTraceString:'+e.getStackTraceString());
            pis.couponMsg=e.getMessage();
        }
        // if(pageMsg!=null){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMsg));
        // }
    }

    /**********************************************************************
     * deleteCoupon
     * @description:here is the back-end function for delete button in coupon pannel
     * call WS to release the coupon and delte the coupon from SF
     **********************************************************************/
    public void deleteCoupon(){
        // pageMsg=null;
        //couponMsg='';
        String policyId=ApexPages.currentPage().getParameters().get('policyId');
        String couponNumber=ApexPages.currentPage().getParameters().get('couponNumber');
        PersonInsuredStructure pis=pisMap.get(policyId);
        Coupon couponWrap=pis.couponMap.get(couponNumber);
        pis.couponMsg='';
        try{
            List<coupon> couponList=new List<coupon>();
            couponList.add(couponWrap);
            CouponUtil.ReactiveCoupon(couponList,'TM');
            CouponUtil.deleteCouponList(couponList);
        
            pis.couponMap.remove(couponNumber);
            initCouponTotal();
        }catch(Exception e){
            system.debug('deleteCoupon() getStackTraceString:'+e.getStackTraceString());
             pis.couponMsg=e.getMessage();
        }
        // if(pageMsg!=null){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMsg));
        // }
    }

    /**********************************************************************
     * initCouponTotal
     * @description:calculate coupon total amount for each policy
     **********************************************************************/
    public void initCouponTotal(){
        for(TMEsalesHelper.PremiumAmt tol: premiumAmountList){
            if(!tol.isRider){
                PersonInsuredStructure pis=pisMap.get(tol.policyId);
                tol.totalCoupon=CouponUtil.calculateAllCouponAmount(pis.couponMap.values());
                system.debug('initCouponTotal() tol.totalCoupon:'+tol.totalCoupon);
            }
        } 
    }
    //AM project coupon jack add 

    /********************************************************************************
     * Created Date - Aug 10, 2021
     * @description friend and family discount need to input mobile no to search Referral
     * policy. If one policy transaction which has Two PIs can use its master policy as default Referral policy
     * jack add for friend and family discount in SFDC begin
     ********************************************************************************/
    // jack add for friend and family discount in SFDC begin move the var to top later
    public Map<String,Discount_Code__c> discountCodeMap;
    // Map<String,String> productCategoryMap;/* add by Jack on 2022-01-11 for project: Discount Enhancement */
    public String referralMobile{get;set;}
    public String referralPolicyNum{get;set;}
    public Boolean selectFamilyDiscount{get;set;}

     /**
     * @description use group__c field in discount code custom setting to judge if the two discount is in same group
     * @author Jackshao@deloitte.com.cn | 08-11-2021 
     * @return Boolean 
     **/
     public Boolean discountGroupValidation(String selectedDiscount1, String selectedDiscount2){
        //system.debug('discountCodeMap.get(selectedDiscount2).group__c:'+discountCodeMap.get(selectedDiscount2).group__c+' discountCodeMap.get(selectedDiscount1).group__c:'+discountCodeMap.get(selectedDiscount1).group__c);
        if(String.isNotBlank(selectedDiscount2) && String.isNotBlank(selectedDiscount1) && discountCodeMap!= null && discountCodeMap.containsKey(selectedDiscount1)&& discountCodeMap.containsKey(selectedDiscount2)){
            if(String.isNotBlank(discountCodeMap.get(selectedDiscount2).group__c) && String.isNotBlank(discountCodeMap.get(selectedDiscount1).group__c) && discountCodeMap.get(selectedDiscount2).group__c==discountCodeMap.get(selectedDiscount1).group__c){
                return true;
            }
        }
        return false;
        // if(PersonInsuredStructureList.size()==1){return true;}
        // return false;
    }

    /**
    * @description init data in family discount pannel
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    **/
    public void initFamilyDiscountPannel(Boolean needRecalculate){
        // referralMobile='';
        // referralPolicyNum='';

        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            pis.referralMobile='';
            pis.referralPolicyNum='';

            System.debug('discountCodeMap: '+discountCodeMap+' selectedDiscount1:'+pis.discount1+' selectedDiscount2:'+pis.discount2+' getDiscount:'+discountCodeMap.get(pis.discount1));
            if((String.isNotBlank(pis.discount1)&&discountCodeMap.get(pis.discount1).group__c=='FAMILY DISCOUNT') || (String.isNotBlank(pis.discount2)&&discountCodeMap.get(pis.discount2).group__c=='FAMILY DISCOUNT')){
                pis.selectFamilyDiscount=true;

                String tempMasterPolNum=personInsuredStructureList[0].piPolicy.Master_Policy_No__c;
                String tempFriendMasterPolNum=personInsuredStructureList[0].piPolicy.Master_Policy_of_Friend_Discount__c;
                System.debug('needRecalculate: '+needRecalculate+' tempMasterPolNum: '+tempMasterPolNum+' tempFriendMasterPolNum: '+tempFriendMasterPolNum);
                System.debug('personInsuredStructureList: '+personInsuredStructureList.size());
                // keep original data when init if original data is not empty
                if(!needRecalculate&&String.isNotBlank(tempMasterPolNum)&&String.isNotBlank(tempFriendMasterPolNum)){
                    if(personInsuredStructureList.size()>1 || (personInsuredStructureList.size()==1&&tempMasterPolNum!=tempFriendMasterPolNum)){
                        pis.referralPolicyNum=tempFriendMasterPolNum;
                    }
                }else{
                    needRecalculate=true;
                }
                // calculate referral policy number when discount changed or first time init
                System.debug('needRecalculate: '+needRecalculate);
                if(needRecalculate){
                    if(personInsuredStructureList.size()>1){
                        pis.referralPolicyNum=tempMasterPolNum;

                        if(String.isNotBlank(tempMasterPolNum)){
                            for(PersonInsuredStructure pi : personInsuredStructureList){
                                pi.piPolicy.Master_Policy_of_Friend_Discount__c=tempMasterPolNum;
                                pi.piPolicy.Relationship_of_Friend_Discount__c='FD';
                            }
                        }
                    }else{
                        pis.referralPolicyNum='';
                    }
                }
            }else{
                pis.selectFamilyDiscount=false;
                if(needRecalculate){
                    for(PersonInsuredStructure pi : personInsuredStructureList){
                        pi.piPolicy.Master_Policy_of_Friend_Discount__c='';
                        pi.piPolicy.Relationship_of_Friend_Discount__c='';
                    }
                }
            }
            System.debug('selectFamilyDiscount: '+pis.selectFamilyDiscount);
        }
    }

    /**
    * @description function to call when user click search in family discount pannel
    check in SFDC first, and then check with WS
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    **/
    public void searchWithMobileNo(){
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        if(String.isNotBlank(currentPolicyNo)){
            for(PersonInsuredStructure pis : personInsuredStructureList){
                if(pis.piPolicy.Policy_No__c == currentPolicyNo && String.isNotBlank(pis.referralMobile)){
                    List<New_Policy__c> policyResultList=mobileNoSearchInSFDC(pis.referralMobile);
                    // List<New_Policy__c> policyResultList=new List<New_policy__c>();
                    if(policyResultList.size()>0){
                        pis.showDiscountErrorMsg=0;    
                        pis.referralPolicyNum=policyResultList[0].policy_no__c;
                    }else{
                        HttpCalloutVO.Policy fulfillPolicy=mobileNoSearchByWS(pis.referralMobile);
                        if(null!=fulfillPolicy&&String.isNotBlank(fulfillPolicy.masterPolicyNo)){
                            pis.showDiscountErrorMsg=0;
                            pis.referralPolicyNum=fulfillPolicy.masterPolicyNo;
                        }else{
                            pis.showDiscountErrorMsg=3;
                        }
                    }
                    //mobileNoSearchWithWS(referralMobile);
                    if(String.isNotBlank(pis.referralPolicyNum)){
                        for(PersonInsuredStructure pi : personInsuredStructureList){
                            pi.piPolicy.Master_Policy_of_Friend_Discount__c=pis.referralPolicyNum;
                            pi.piPolicy.Relationship_of_Friend_Discount__c='FD';
                        }
                    }
                }
            }
        }
        currentPolicyNo = '';
    }

    /**
    * @description search completed or submitted policy in SFDC with mobile no
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    * @param String referralMobile 
    * @return List<New_Policy__c> 
    **/
    public List<New_Policy__c> mobileNoSearchInSFDC(String referralMobile){
        List<New_Policy__c> result=new List<New_Policy__c>();
        List<New_Policy__c> policyList=[Select id,policy_no__c,product_code__c from New_Policy__c where (policy_Transaction__r.status__c='Completed' or policy_Transaction__r.status__c='Submitted') and Mobile_Phone__c=:referralMobile and LastModifiedDate=TODAY];
        for(New_Policy__c policy:policyList){
            system.debug('policy.product_code__c,selectedProduct.product_code__c:'+policy.product_code__c+' '+selectedProduct.product_code__c);
            if(TMPolicyUtil.compareProductCodeInGroup(policy.product_code__c,selectedProduct.product_code__c)){/* add by Jack on 2022-01-11 for project: Discount Enhancement */
                result.add(policy);
            }
        }
        return result;
    }

    /**
    * @description search completed or submitted policy by WS with mobile no
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    * @param String referralMobile 
    * @return HttpCalloutVO.Policy
    **/
    public HttpCalloutVO.Policy mobileNoSearchByWS(String referralMobile){
        Date effDate;
        HttpCalloutVO.Policy fulfillPolicy = new HttpCalloutVO.Policy();
        if(String.isNotBlank(referralMobile)){
            List<HttpCalloutVO.Policy> wsPolicyList=policyCalloutHelper.getIndividualPolicyListBasicByCriteria(userinfo.getUserName(),referralMobile);
            if(wsPolicyList.size()>0){
                
                for(HttpCalloutVO.Policy p : wsPolicyList){
                    if(String.isNotBlank(p.policyStatus)&&p.policyStatusCode=='1'
                        &&String.isNotBlank(p.policyNumber)&&String.isNotBlank(p.masterPolicyNo)&&p.policyNumber==p.masterPolicyNo
                        &&String.isNotBlank(p.productCode)&&TMPolicyUtil.compareProductCodeInGroup(p.productCode,selectedProduct.product_code__c)/* add by Jack on 2022-01-11 for project: Discount Enhancement */
                        && (String.isNotBlank(p.effDate)&& policyTransaction.Effective_Date__c != null &&(Date.valueOf(p.effDate).daysBetween(policyTransaction.Effective_Date__c)<=30)) ){
                            system.debug('Date.valueOf(p.effDate).daysBetween(system.Today():'+Date.valueOf(p.effDate).daysBetween(policyTransaction.Effective_Date__c));
                        if(null==effDate || (String.isNotBlank(p.effDate)&&Date.valueOf(p.effDate)>effDate) ){
                            effDate=Date.valueOf(p.effDate);
                            fulfillPolicy=p;
                        }
                    }
                }
            }
        }
        return fulfillPolicy;
    }

    /**
    * @description compare if the product code is same group with TM Product Category custom setting
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    * @param String productCode1 
    * @param String productCode2 
    * @return Boolean 
    **/
    /* add by Jack on 2022-01-11 for project: Discount Enhancement*/
    // public Boolean compareProductCodeInGroup(String productCode1,String productCode2){
    //     system.debug('productCategoryMap:'+productCategoryMap);
    //     system.debug('productCategoryMap.get(productCode1) '+productCategoryMap.get(productCode1)+' productCategoryMap.containsKey(productCode2):'+productCategoryMap.containsKey(productCode2));
    //     if(productCategoryMap.containsKey(productCode1) && productCategoryMap.containsKey(productCode2)){
    //         if(productCategoryMap.get(productCode1)==productCategoryMap.get(productCode2)){
    //             return true;
    //         }
    //     }else if(productCode1==productCode2){
    //         return true;
    //     }
    //     return false;
    // }

    
    /**
    * @description init TM Product Category custom setting data
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    **/
    public void initTMProductCatInfo(){
        // productCategoryMap=new Map<String,String>();
        
        List<TM_Product_Category__c> tempList=TM_Product_Category__c.getAll().values();
        tmProcatList=new List<TM_Product_Category__c>();
        for(TM_Product_Category__c productCat : tempList){
            if(productCat.Module__c=='Assessment Question'){
                tmProcatList.add(productCat);
            }
            // else if(productCat.Module__c=='Family Discount'){
            //     for(String productCode : productCat.product_code__c.split(',')){
            //         productCategoryMap.put(productCode,productCat.parent_product__c);
            //     }
            // }
        }
    }
    /* add by Jack on 2022-01-11 for project: Discount Enhancement*/

    /**
    * @description init discount code custom setting data
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    **/
    public void initDiscountCodeInfo(){
        discountCodeMap=new Map<String,Discount_Code__c>();
        for(Discount_Code__c dc : Discount_Code__c.getAll().values()){
            discountCodeMap.put(dc.description__c,dc);
        }
    }

    /**
    * @description init all custom setting data here
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    **/
    public void initCustomSettingData(){
        initDiscountCodeInfo();
        initTMProductCatInfo();
        // tmProcatList=TM_Product_Category__c.getAll().values();
        mappingList=Assessment_Questions_Product_Mapping__c.getAll().values();
    }
    /********************************************************************************
     * Created Date - Aug 10, 2021
     * jack add for friend and family discount in SFDC end
     ********************************************************************************/

    /* add by Jack on 2022-01-11 for project: Discount Enhancement*/
     /**
     * @description 
     * @author Jackshao@deloitte.com.cn | 01-04-2022 
     * @param Map<String Boolean> availableDiscountMap 
     * @param PersonInsuredStructure pis
     * @return void
     **/
    // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
     public void selectMandatoryDiscount(Map<String, Boolean> availableDiscountMap, PersonInsuredStructure pis){
        for(Premium_Discount__c pd : premiumDiscountMap.values()){
            system.debug('pd.Discount_Type__c:'+pd.Discount_Type__c);
            if(pd.Mandatory__c && pd.Discount__c != null && pd.Discount__c > 0 && availableDiscountMap.get(pd.Discount_Type__c) == true){
                if(String.isBlank(pis.discount1) && !pd.Discount_type__c.equals(pis.discount2)){
                    pis.discount1=pd.Discount_Type__c;
                    system.debug('selectedDiscount1:'+pis.discount1);
                    selectDiscount1();
                }else if(String.isBlank(pis.discount2) && !pd.Discount_type__c.equals(pis.discount1)){
                    pis.discount2=pd.Discount_type__c;
                    system.debug('selectedDiscount2:'+pis.discount2);
                    selectDiscount2();
                }
                if(String.isNotBlank(pis.discount2) && String.isNotBlank(pis.discount1)){
                    break;
                }
            }
        }
        if(showDiscountErrorMsg!=0){
            // showDiscountErrorMsg=0;
        }
     }

     /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
    /**
    * @description 
    * @author Jackshao@deloitte.com.cn | 01-18-2022 
    * @return Boolean 
    **/
    public Boolean discount12MonthChecking(String discountDesc){
        Premium_Discount__c pd=premiumDiscountMap.get(discountDesc);
        system.debug('discount12MonthChecking() pd'+pd);
        if(pd.Lapse_Surrender_Policy_Checking__c){
            for(personInsuredStructure pis : personInsuredStructureList){
                if(TMPolicyUtil.lapseSurrenderPolicyChecking(selectedProduct.product_code__c, pis.personalIDPolicylistFromWS)){
                    return false; 
                }
            }
        }
        return true;
    }

    /**
    * @description check if the discount is exceed the usage limit
    * @author ranzhao@deloitte.com.cn | 11-03-2025 
    * @param String discountDesc 
    * @return Boolean 
    **/
    public Boolean exceedDiscountUsageLimit(String discountDesc){
        Integer discountUsageCount = 0;
        for(PersonInsuredStructure pis : personInsuredStructureList){
            if(discountDesc.equals(pis.discount1) || discountDesc.equals(pis.discount2)){
                discountUsageCount++;
            }
        }
        return discountUsageCount > 5;
    }

    /**
    * @description disable benefit option if product code and channel code meet condition
    * @author jackshao@deloitte.com.cn | 09-07-2022 
    * @param Set<String> disableBenefitLevelSet 
    **/
    public void disableBenefitLevelOption(Set<String> disableBenefitLevelSet){
        if(!benefitLevelOption.isEmpty()){
            // List<SelectOption> enableList = new List<SelectOption>();
            // List<SelectOption> disableList = new List<SelectOption>();
            for(SelectOption option : benefitLevelOption){
                system.debug('option.getValue():'+option.getValue());
                if(disableBenefitLevelSet.contains(option.getValue())){
                    option.setDisabled(true);
                    // disableList.add(option);
                }else{
                    // enableList.add(option);
                }
            }
            // benefitLevelOption = enableList;
            // benefitLevelOption.addAll(disableList);
            system.debug('benefitLevelOption:'+benefitLevelOption);
        }
    }
}