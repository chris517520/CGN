/********************************************************************************
Apex Class Name - TMPolicyUtil
Created Date - Apr 24, 2018
@description TMPolicyUtil
Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer       Date                    Description
* ------    -----------     ------------            -----------------------
* 10.0       Franco          11/10/2018              Revise Version
********************************************************************************/
public class TMPolicyUtil {

    public static TM_General_Setting__c generalSetting = TM_General_Setting__c.getValues('Default');
    public static ESales_Endpoint__c esalesSetting = ESales_Endpoint__c.getValues('Default');
    public static List<Product_Discount__c> productDiscountList = [select Code__c,Discount__c from Product_Discount__c];
    
    
    public static List<Discount_Code__c> discountCodeList = [select Code__c, Description__c from Discount_Code__c ];
    
    public static Map<String, String> discountCodeDecripMap{get{
        
        Map<String, String> tmpMap = new Map<String, String>();
        for(Discount_Code__c dc : discountCodeList){
            tmpMap.put(dc.Description__c, dc.Code__c);
        }
        return tmpMap;
        
    }set;}
    
    public static Map<String, Decimal> productDiscountMap{get{
        Map<String, Decimal> tmpMap = new Map<String, Decimal>();
        for(Product_Discount__c pd : productDiscountList){
            tmpMap .put(pd.Code__c, pd.Discount__c);
        }
        return tmpMap;
    }set;}
    
    
    public static Map<String,String> productCategoryMap{
        get{
            if(productCategoryMap==null){
                productCategoryMap=new Map<String,String>();
                for(TM_Product_Category__c productCat : TM_Product_Category__c.getAll().values()){
                    if(productCat.Module__c=='Family Discount'){
                        for(String productCode : productCat.product_code__c.split(',')){
                            productCategoryMap.put(productCode,productCat.parent_product__c);
                        }
                    }
                }
                return productCategoryMap;
            }else{
                return productCategoryMap;
            }
        }
        set;
    }
    /* add by Jack on 2022-01-19 for project: IA AML */
    public static Map<String,Country_List_Settings__c> nationalityMap{
        get{
            if(nationalityMap==null){
                nationalityMap=new Map<String,Country_List_Settings__c>();
                for(Country_List_Settings__c country : Country_List_Settings__c.getAll().values()){
                    nationalityMap.put(country.Nationality__c,country);
                }
                return nationalityMap;
            }else{
                return nationalityMap;
            }
        }
        set;
    }
    
    public static Map<String,Country_List_Settings__c> countryMap{
        get{
            if(countryMap==null){
                countryMap=new Map<String,Country_List_Settings__c>();
                for(Country_List_Settings__c country : Country_List_Settings__c.getAll().values()){
                    countryMap.put(country.Name,country);
                }
                return countryMap;
            }else{
                return countryMap;
            }
        }
        set;
    }
    /* add by Jack on 2022-01-19 for project: IA AML */

    public static Map<String,Policy_Validation_Checking__c> policyValidationMap{
        get{
            if(policyValidationMap==null){
                policyValidationMap=new Map<String,Policy_Validation_Checking__c>();
                for(Policy_Validation_Checking__c pvc : Policy_Validation_Checking__c.getAll().values()){
                    policyValidationMap.put(pvc.product_Code__c,pvc);
                }
                return policyValidationMap;
            }else{
                return policyValidationMap;
            }
        }
        set;
    }
    public static New_policy__c copyPolicyNotNull(New_Policy__c fromPolicy, New_Policy__c toPolicy){
        
        /**
            Opportunity__r.RecordType.DeveloperName
            **/
        toPolicy.Policy_Holder_First_Name__c = fromPolicy.Policy_Holder_First_Name__c;
        toPolicy.Policy_Holder_Last_Name__c = fromPolicy.Policy_Holder_Last_Name__c;
        toPolicy.Policy_Holder_Name_Chi__c = fromPolicy.Policy_Holder_Name_Chi__c;
        toPolicy.Relationship__c = fromPolicy.Relationship__c;
        toPolicy.Date_of_Birth__c = fromPolicy.Date_of_Birth__c;
        toPolicy.Nationality__c = fromPolicy.Nationality__c;
        toPolicy.Place_of_Birth__c = fromPolicy.Place_of_Birth__c;
        toPolicy.ID_Type__c = fromPolicy.ID_Type__c;
        toPolicy.Personal_ID__c = fromPolicy.Personal_ID__c;
        toPolicy.ID_Expiry_Date__c = fromPolicy.ID_Expiry_Date__c;
        toPolicy.Education_Level__c = fromPolicy.Education_Level__c;
        toPolicy.Home_Phone__c = fromPolicy.Home_Phone__c;
        toPolicy.Mobile_Phone__c = fromPolicy.Mobile_Phone__c;
        toPolicy.Office_Phone__c = fromPolicy.Office_Phone__c;
        toPolicy.Email__c = fromPolicy.Email__c;
        toPolicy.Corresponding_Address_1__c = fromPolicy.Corresponding_Address_1__c;
        toPolicy.Corresponding_Address_2__c = fromPolicy.Corresponding_Address_2__c;
        toPolicy.Corresponding_Address_3__c = fromPolicy.Corresponding_Address_3__c;
        toPolicy.Corresponding_Address_4__c = fromPolicy.Corresponding_Address_4__c;
        toPolicy.Corresponding_Address_Country__c = fromPolicy.Corresponding_Address_Country__c;
        //toPolicy.name = fromPolicy.name;
        toPolicy.Business_Nature__c = fromPolicy.Business_Nature__c;
        toPolicy.Country__c = fromPolicy.Country__c;
        toPolicy.Position__c = fromPolicy.Position__c;
        toPolicy.Tax_Residence_1__c = fromPolicy.Tax_Residence_1__c;
        toPolicy.Tax_Num_1__c = fromPolicy.Tax_Num_1__c;
        toPolicy.Tax_Num_2__c = fromPolicy.Tax_Num_2__c;
        toPolicy.Tax_Num_3__c = fromPolicy.Tax_Num_3__c;
        toPolicy.Tax_Residence_3__c = fromPolicy.Tax_Residence_3__c;
        toPolicy.Tax_Residence_2__c = fromPolicy.Tax_Residence_2__c;
        toPolicy.Source_of_Fund__c = fromPolicy.Source_of_Fund__c;
        toPolicy.Other_Source_of_Fund__c = fromPolicy.Other_Source_of_Fund__c;
        toPolicy.Means_of_Income__c = fromPolicy.Means_of_Income__c;
        toPolicy.Reason_In_HK__c = fromPolicy.Reason_In_HK__c;
        toPolicy.Purpose_of_Insurance__c = fromPolicy.Purpose_of_Insurance__c;
        toPolicy.Purpose_of_Insurance_Others__c = fromPolicy.Purpose_of_Insurance_Others__c;
        toPolicy.Product_Name__c = fromPolicy.Product_Name__c;
        //toPolicy.Referral_Exclusion_Reason__c = fromPolicy.Referral_Exclusion_Reason__c;
        //toPolicy.Appeal__c = fromPolicy.Appeal__c;
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        // toPolicy.Discount_1__c = fromPolicy.Discount_1__c;
        // toPolicy.Discount_2__c = fromPolicy.Discount_2__c;
        toPolicy.Payment_Type__c = fromPolicy.Payment_Type__c;
        toPolicy.Payment_Frequency__c = fromPolicy.Payment_Frequency__c;
        toPolicy.Bank_Name__c = fromPolicy.Bank_Name__c;
        toPolicy.Account_No__c = fromPolicy.Account_No__c;
        toPolicy.Remarks__c = fromPolicy.Remarks__c;
        toPolicy.Card_Expiry_Date_Text__c = fromPolicy.Card_Expiry_Date_Text__c;
        toPolicy.Product__c = fromPolicy.Product__c;
        //toPolicy.Opportunity__c = fromPolicy.Opportunity__c;
        toPolicy.Benefit_Type__c = fromPolicy.Benefit_Type__c;
        //if(null==toPolicy.Policy_Transaction__c){
        //    toPolicy.Policy_Transaction__c = fromPolicy.Policy_Transaction__c;
        //}
        toPolicy.Permanent_Address_1__c = fromPolicy.Permanent_Address_1__c;
        toPolicy.Permanent_Address_2__c = fromPolicy.Permanent_Address_2__c;
        toPolicy.Permanent_Address_3__c = fromPolicy.Permanent_Address_3__c;
        toPolicy.Permanent_Address_4__c = fromPolicy.Permanent_Address_4__c;
        toPolicy.Permanent_Address_Country__c = fromPolicy.Permanent_Address_Country__c;
        toPolicy.Product_Code__c = fromPolicy.Product_Code__c;
        toPolicy.Residential_Address_1__c = fromPolicy.Residential_Address_1__c;
        toPolicy.Residential_Address_2__c = fromPolicy.Residential_Address_2__c;
        toPolicy.Residential_Address_3__c = fromPolicy.Residential_Address_3__c;
        toPolicy.Residential_Address_4__c = fromPolicy.Residential_Address_4__c;
        toPolicy.Residential_Address_Country__c = fromPolicy.Residential_Address_Country__c;
        toPolicy.Policy_Holder_Name__c = fromPolicy.Policy_Holder_Name__c;
        //toPolicy.Policy_Status__c = fromPolicy.Policy_Status__c; comment by andy for remove invalid PI function. policy status may be "invalid"
        //toPolicy.Remarks_to_Cigna_Underwriter__c = fromPolicy.Remarks_to_Cigna_Underwriter__c;
        toPolicy.Is_Side_Order__c = fromPolicy.Is_Side_Order__c;
        toPolicy.Name_of_Card_Issuing_Bank__c = fromPolicy.Name_of_Card_Issuing_Bank__c;
        toPolicy.Credit_Card_Holder_Full_Name__c = fromPolicy.Credit_Card_Holder_Full_Name__c;
        toPolicy.Credit_Card_Number__c = fromPolicy.Credit_Card_Number__c;
        toPolicy.Policy_Holder_Email_Address__c = fromPolicy.Policy_Holder_Email_Address__c;
        //toPolicy.Actual_Premium__c = fromPolicy.Actual_Premium__c;
        //toPolicy.Annual_Premium__c = fromPolicy.Annual_Premium__c;
        //toPolicy.Amount__c = fromPolicy.Amount__c;
        // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
        // toPolicy.Discount__c = fromPolicy.Discount__c;
        // toPolicy.Discount2__c = fromPolicy.Discount2__c;
        //toPolicy.Discount_Premium__c = fromPolicy.Discount_Premium__c;
        //toPolicy.Loading__c = fromPolicy.Loading__c;
        //toPolicy.Loading_Amount__c = fromPolicy.Loading_Amount__c;
        toPolicy.Modal_Premium__c = fromPolicy.Modal_Premium__c;
        //toPolicy.Original_Premium__c = fromPolicy.Original_Premium__c;
        toPolicy.Company_Address_1__c = fromPolicy.Company_Address_1__c;
        toPolicy.Company_Address_2__c = fromPolicy.Company_Address_2__c;
        toPolicy.Company_Address_3__c = fromPolicy.Company_Address_3__c;
        toPolicy.Company_Address_4__c = fromPolicy.Company_Address_4__c;
        toPolicy.Education_Level_Additional_Information__c = fromPolicy.Education_Level_Additional_Information__c;
        toPolicy.Means_of_Income_Additional_Information__c = fromPolicy.Means_of_Income_Additional_Information__c;
        toPolicy.AML_High_Risk_Ind__c = fromPolicy.AML_High_Risk_Ind__c;
        //toPolicy.Appeal_For_UW_Result__c = fromPolicy.Appeal_For_UW_Result__c;
        toPolicy.Bank_Account_No__c = fromPolicy.Bank_Account_No__c;        
        //toPolicy.Remarks_to_Cigna_Underwriter_2__c = fromPolicy.Remarks_to_Cigna_Underwriter_2__c;
        toPolicy.Is_Email_Needed__c = fromPolicy.Is_Email_Needed__c;
        toPolicy.Age__c = fromPolicy.Age__c;
        //if(null==toPolicy.Account__c){
        //    toPolicy.Account__c = fromPolicy.Account__c;
        //}
        //toPolicy.Core_Campaign__c = fromPolicy.Core_Campaign__c;        
        toPolicy.Gender__c = fromPolicy.Gender__c;
        //toPolicy.Submission_Date_Time__c = fromPolicy.Submission_Date_Time__c;
        //toPolicy.Policy_Effective_Date__c = fromPolicy.Policy_Effective_Date__c;
        toPolicy.Selected_Campaign__c = fromPolicy.Selected_Campaign__c;
        //toPolicy.UW_Requirement__c = fromPolicy.UW_Requirement__c;
        toPolicy.Plan_code__c = fromPolicy.Plan_code__c;
        
        //Nicole_20200408_CDD
        toPolicy.Company_Address__c = fromPolicy.Company_Address__c;
        toPolicy.Other_Job__c = fromPolicy.Other_Job__c;
        toPolicy.Missing_CDD_Info__c = fromPolicy.Missing_CDD_Info__c;
        toPolicy.Industry__c = fromPolicy.Industry__c;

        //toPolicy.Cigna_Staff__c = fromPolicy.Cigna_Staff__c;
        toPolicy.Personal_Choice_Policy_Number__c = fromPolicy.Personal_Choice_Policy_Number__c;
        
        //SPS-537
        toPolicy.Company__c = fromPolicy.Company__c;
        //SPS-537
        
        return toPolicy;
    }
    
    public static Boolean compare2Object(String attr, Person_insured__c pi2){
        //Person_Insured_Name__c,Date_of_Birth__c,Personal_ID__c,Height__c,Weight__c,Gender__c,Smoker__c
        Boolean isTheSame = true;
        //system.debug('[TMPolicyUtil] compare2Object attr >> ' + attr);
        if(null != attr){
            String[] fieldDatas = attr.split(';');
            Map<String, Object> fieldsToValue = pi2.getPopulatedFieldsAsMap();
            for(String fd : fieldDatas){
                if(String.isNotEmpty(fd)){
                    String[] fieldData = fd.split(':',2);
                    if(fieldData.size()>1){
                        if(fieldsToValue.containsKey(fieldData[0])){
                            if(String.valueOf(fieldsToValue.get(fieldData[0]))  != fieldData[1]){                            
                                system.debug('isTheSame1: '+fieldData[0]+':'+fieldData[1]);
                                system.debug('isTheSame2: '+fieldData[0]+':'+String.valueOf(fieldsToValue.get(fieldData[0])));
                                isTheSame = false;
                                break;
                            }
                        }                    
                    }
                }
            }
        }else{//if attr is null, the PI is a new one which is added on step 1, but first PI in the PI List is old record(so that it go into this method) 
            isTheSame = false;
        }                
        return isTheSame;
    }
    
    public static Boolean compare2Object(String attr, Person_Insured__c pi2, List<String> originalRiderList, Map<String,String> selectedRidersMap){
        Boolean validationResult1 = compare2Object(attr, pi2);
        //system.debug('[TMPolicyUtil] compare2Object validationResult1= '+validationResult1);
        Boolean validationResult2 = true;
        List<String> selectedRiders = new List<String>();
        selectedRiders.addAll(selectedRidersMap.keySet());
        if((originalRiderList.isEmpty()&&!selectedRiders.isEmpty())||(!originalRiderList.isEmpty()&&selectedRiders.isEmpty())||(originalRiderList.size()!=selectedRiders.size())){
            validationResult2 = false;
        }else{
            for(String rider : selectedRiders){
                if(!originalRiderList.contains(rider)){
                    validationResult2 = false;
                    break;
                }
            }
        }
        //system.debug('[TMPolicyUtil] compare2Object validationResult2= '+validationResult2);
        return validationResult1 && validationResult2;
    }
    
    public static String preSalesAttSerialize(TMCreatePolicyCtrl.PersonInsuredStructure pis, String productCode){
        //Person_Insured_Name__c,Date_of_Birth__c,Personal_ID__c,Height__c,Weight__c,Gender__c,Smoker__c
        String att = '';
        att += 'Person_Insured_Name__c' + ':' + pis.pi.Insured_Last_Name__c + ' ' + pis.pi.Insured_First_Name__c +';';
        att += 'Date_of_Birth__c' + ':' + pis.pi.Date_of_Birth__c + ';';
        att += 'Personal_ID__c' + ':' + pis.pi.Personal_ID__c + ';';
        att += 'Height__c' + ':' + pis.height + ';';
        att += 'Weight__c' + ':' + pis.weight + ';';
        att += 'Gender__c' + ':' + pis.pi.Gender__c + ';';
        att += 'Smoker__c' + ':' + pis.pi.Smoker__c + ';';
        att += 'Product_Code__c' + ':' + productCode + ';';
        att += 'Sum_Insured__c' + ':' + pis.sumInsured;// Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
        
        return att;
    }
     
    /*
     * Call preSales for a person insured
     */
    
    public static void preSales(TMCreatePolicyCtrl.PersonInsuredStructure pis, Campaign cam, String productCode, HttpCalloutVO.Product wsProduct, Boolean isParentHKIDHasInforcePolicy){
        
        pis.applicationId = pis.piPolicy.policy_no__c  + '_' + DateTime.now().formatGmt('yyyyMMddHHmmss');
        
        // 1. build basic plan and riders information
        List<TMEsalesHelper.ProductRecord> prdList = new List<TMEsalesHelper.ProductRecord>();
        //TMEsalesHelper.ProductRecord basicPlan = new TMEsalesHelper.ProductRecord(pis.pi.Basic_Plan__c, pis.pi.Benefit_Level__c, false);//commetn by ken
        TMEsalesHelper.ProductRecord basicPlan = new TMEsalesHelper.ProductRecord(productCode.replace('@', ''), pis.pi.Benefit_Level__c, false);//added by ken
        prdList.add(basicPlan);
        for(String key : pis.selectedRidersMap.keySet()){
            TMEsalesHelper.ProductRecord rider = new TMEsalesHelper.ProductRecord(key, pis.pi.Benefit_Level__c, true);
            prdList.add(rider);
        }
        // add madatory rider (UWProductInd is true in GetPlanInfoListBasic)
        if(wsProduct != null){
            for(HttpCalloutVO.Rider r : wsProduct.riderList){
                if(r.isUWProduct == true){
                    TMEsalesHelper.ProductRecord rider = new TMEsalesHelper.ProductRecord(r.RiderCode, pis.pi.Benefit_Level__c, true);
                    prdList.add(rider);
                }
            }
        }
        
        // 2. call presales WS
        //    Currently in CITAS, they are using the following two channel codes
        //    a.  Outbound channel: TMOU
        //    b.  Inbound channel (channel =  148,149,152) TMIN
        TMEsalesHelper helper = new TMEsalesHelper();
        Boolean isInbound = false;
        if(TMEsalesHelper.auwInboundChannels.contains(cam.Channel__r.Channel_Code__c)){
            isInbound = true;
        }
        TMEsalesHelper.PreSalesAttribute preAtt = helper.getPreSalesAttribute(isInbound, prdList, pis.piPolicy.product_code__c, pis, isParentHKIDHasInforcePolicy);
        TMEsalesHelper.PreSalesResult preSalesResult = helper.preSales(preAtt);
        //SPS-699 jack add
        if(String.isBlank(preSalesResult.result)){
            CignaUtil.createCheckingLog('TMEsalesHelper.preSales','','','empty preSales result',pis.piPolicy.Policy_No__c);
        }
        // System.debug('before preSalesResult.result:'+preSalesResult.result);
        // if(String.isBlank(preSalesResult.result) && pis.piValidationItem.needAUW == false && String.isNotBlank(pis.piPolicy.Pre_Sales_Result_From_Website__c)){
        //     preSalesResult.result = pis.piPolicy.Pre_Sales_Result_From_Website__c;
        // }
        System.debug('after preSalesResult.result:'+preSalesResult.result);
        //system.debug('TMPolicyUtil pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c);
        // 3. update result
        //pis.uwResult = new UW_Result__c();
        //pis.uwResult.Application_Id__c = pis.applicationId;
        //pis.uwResult.Presales_Result__c = preSalesResult.result;
        //pis.uwResult.PreSales_Result_Msg__c = '';
        pis.piPolicy.Application_Id__c = pis.applicationId;
        pis.piPolicy.Pre_Sales_Result__c = preSalesResult.result;
        pis.piPolicy.Initial_Pre_Sales_Result__c = preSalesResult.result;//add by jack for policy replacement
        //jack add for policy replacement
        /*if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true && pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED  ){
            pis.piPolicy.Pre_Sales_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED; 
        }*/
        pis.piPolicy.PreSales_Result_Msg__c = '';
        pis.piPolicy.AUW_URL__c = null;
        pis.piPolicy.Loading__c = null;
        pis.piPolicy.UW_Overrall_Result__c = null;
        pis.piPolicy.Presales_Result_Attribute__c = null;
        pis.piPolicy.UW_Result__c = null;
        if(null != preSalesResult.resultMsgList){
            Integer j = 1;
            pis.presalesResultMsgList = new List<TMEsalesHelper.PreSalesResultMessage>();
            for(TMEsalesHelper.PreSalesResultMessage msg : preSalesResult.resultMsgList){
                pis.piPolicy.PreSales_Result_Msg__c += msg.ProductCode + '|';
                if(null != msg.msgList){
                    Integer i = 1;
                    for(String message : msg.msgList){
                        if(i != msg.msgList.size())
                            pis.piPolicy.PreSales_Result_Msg__c += message + ';<br/>';
                        else
                            pis.piPolicy.PreSales_Result_Msg__c += message;
                        ++i;
                    }
                }
                if(j != preSalesResult.resultMsgList.size())
                    pis.piPolicy.PreSales_Result_Msg__c += ',';
                msg.setMessage();
                pis.presalesResultMsgList.add(msg);
                ++j;
            }
        }        
        
        if(TMAUWResultHandler.UW_RESULT_MAP.containsKey(preSalesResult.result)){
            pis.piPolicy.Pre_Sales_Result__c = TMAUWResultHandler.UW_RESULT_MAP.get(preSalesResult.result);  
            pis.piPolicy.Initial_Pre_Sales_Result__c   = TMAUWResultHandler.UW_RESULT_MAP.get(preSalesResult.result);  //add by jack for policy replacement
        }
        //jack add for policy replacement
        /*if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true && pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED  ){
            pis.piPolicy.Pre_Sales_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED; 
        }*/
        //pis.uwResult.Person_Insured__c = pis.pi.Id;
        //if(pis.uwResult.Policy__c == null){
        //    pis.uwResult.Policy__c = pis.pi.New_Policy__c;
        //}
        //pis.uwResult.Product__c = pis.piPolicy.Product__c;
        pis.piPolicy.Presales_Result_Attribute__c = TMPolicyUtil.preSalesAttSerialize(pis, productCode); //add attribute to uwResult
        //system.debug('TMPolicyUtil pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c);
    }
    
    /*
     * Call fullUnderwriting for a person insured
     */
    public static void fullUnderwriting(TMCreatePolicyCtrl.PersonInsuredStructure pis, Campaign cam){
        
        // 1. build basic plan and riders information
        List<TMEsalesHelper.ProductRecord> prdList = new List<TMEsalesHelper.ProductRecord>();
        TMEsalesHelper.ProductRecord basicPlan = new TMEsalesHelper.ProductRecord(pis.pi.Basic_Plan__c, pis.pi.Benefit_Level__c, false);
        prdList.add(basicPlan);
        for(String key : pis.selectedRidersMap.keySet()){
            TMEsalesHelper.ProductRecord rider = new TMEsalesHelper.ProductRecord(key, pis.pi.Benefit_Level__c, true);
            prdList.add(rider);
        }
        
        // 2. call fullUnderwriting WS
        TMEsalesHelper helper = new TMEsalesHelper();
        Boolean isInbound = false;
        if(TMEsalesHelper.auwInboundChannels.contains(cam.Channel__r.Channel_Code__c)){
            isInbound = true;
        }
        TMEsalesHelper.PreSalesAttribute preAtt = helper.getPreSalesAttribute(isInbound, prdList, null, pis, false);
        String auwUrl = helper.fullUnderwriting(preAtt);
        
        // 3. update result
        //pis.uwResult.AUW_URL__c = pis.auwURL = auwUrl;
        pis.piPolicy.AUW_URL__c = pis.auwURL = auwUrl;
    }
    
    public static List<TMEsalesHelper.PreSalesResultMessage> preSalesResultMsgBuild(String attr){
        
        List<TMEsalesHelper.PreSalesResultMessage> resultList = new List<TMEsalesHelper.PreSalesResultMessage>();
        if(String.isNotEmpty(attr)){
            String[] productAndMsglistList = attr.split(',');
            //system.debug('>>>>>>>>>>>>>>>>>>>>>productAndMsglistList='+productAndMsglistList);    
            if(null != productAndMsglistList){
                for(String productAndMsglist : productAndMsglistList){
                    TMEsalesHelper.PreSalesResultMessage preMsg4Display = new TMEsalesHelper.PreSalesResultMessage();
                    String[] paras = productAndMsglist.split('\\|');
                    //system.debug('>>>>>>>>>>>>>>>>>>>>>paras='+paras);
                    if(null != paras && paras.size() > 1){
                        preMsg4Display.ProductCode = paras[0];
                        //system.debug('>>>>>>>>>>>>>>>>>>>>>paras[0]='+paras[0]);
                        preMsg4Display.message = null!=paras[1]?paras[1]:'';
                        //system.debug('>>>>>>>>>>>>>>>>>>>>>paras[1]='+paras[1]);
                    }
                    resultList.add(preMsg4Display);
                }
            }
        }
        //system.debug('>>>>>>>>>>>>>>>>>>>>>resultList='+resultList);        
        return resultList;
    }
    
    public static Map<String, Decimal> piDiscountFilter(Map<String, Boolean> availableDiscountMap, Map<String, Decimal> discountMap){
        if(null != availableDiscountMap){
            for(String dicountCode : discountMap.keySet()){
                if(availableDiscountMap.get(dicountCode) == false)
                    discountMap.remove(dicountCode);
            }
        }        
        return discountMap;
    }
    
    public static Decimal getProductDiscountPercent(String dicountCode){
        //system.debug('[TMPolicyUtil]getProductDiscountPercent.productDiscountMap='+productDiscountMap);
        return productDiscountMap.get(dicountCode);    
    }
    
    public static String getDiscountCode(String dicountDecription){
        //system.debug('[TMPolicyUtil]getDiscountCode.discountCodeDecripMap='+discountCodeDecripMap);
        return discountCodeDecripMap.get(dicountDecription);
    }
    
    public static Map<String, Decimal> getPremiumDiscounts(Map<String, Boolean> availableDiscountMap, Product__c selectedProduct, Map<String, Decimal> paymentFrequencyDiscountMap,
                                                           Map<String, Premium_Discount__c> premiumDiscountMap, String selectedDiscount1, 
                                                           String selectedDiscount2, String selectedPaymentFrequency, Boolean sumMandatoryDiscount){
        Map<String, Decimal> discountMap = new Map<String,Decimal>();
        //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().availableDiscountMap='+availableDiscountMap);
        //add by ken, product discount
        //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().selectedProduct.Product_Code__c='+selectedProduct.Product_Code__c);
        if('@PMGH'.equals(selectedProduct.Product_Code__c)){            
            //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().availableDiscountMap.get(95)='+availableDiscountMap.get('95'));                       
            if(availableDiscountMap.get('95') == true && null != TMPolicyUtil.getProductDiscountPercent('95'))
                discountMap.put('95',TMPolicyUtil.getProductDiscountPercent('95'));
            if(availableDiscountMap.get('97') == true && null != TMPolicyUtil.getProductDiscountPercent('97'))
                discountMap.put('97',TMPolicyUtil.getProductDiscountPercent('97'));
        }else if('TMC50'.equals(selectedProduct.Product_Code__c) || 'TMCPU'.equals(selectedProduct.Product_Code__c)){
            if(availableDiscountMap.get('95') == true && null != TMPolicyUtil.getProductDiscountPercent('95'))
                discountMap.put('95',TMPolicyUtil.getProductDiscountPercent('95'));
        } 

        //Combo:  every PI has owned discount according to the number of riders.
        else if('@CBOG'.equals(selectedProduct.Product_Code__c)){

            Premium_Discount__c discount1 = premiumDiscountMap.get('Multiple benefit discount (2)');
            Premium_Discount__c discount2 = premiumDiscountMap.get('Multiple benefit discount (3)');
            Premium_Discount__c discount3 = premiumDiscountMap.get('Multiple benefit discount (4 or more)');

            if(availableDiscountMap.get('Multiple benefit discount (2)') == true && null != discount1 && discount1.Discount__c > 0){

                discountMap.put('Multiple benefit discount (2)', discount1.Discount__c);
            }

            if(availableDiscountMap.get('Multiple benefit discount (3)') == true && null != discount2 && discount2.Discount__c > 0){
                
                discountMap.put('Multiple benefit discount (3)', discount2.Discount__c);
            }

            if(availableDiscountMap.get('Multiple benefit discount (4 or more)') == true && null != discount3 && discount3.Discount__c > 0){
                
                discountMap.put('Multiple benefit discount (4 or more)', discount3.Discount__c);
            }
        }
        
        //mandatory discount
        /*
        List<Decimal> mandatoryDiscountList = new List<Decimal>();
        for(Premium_Discount__c pd : premiumDiscountMap.values()){
            if(pd.Mandatory__c && pd.Discount__c != null && pd.Discount__c > 0){
                mandatoryDiscountList.add(pd.Discount__c);
            }
        }*/
        /* add by Jack on 2022-01-04 for project: Discount enhancement will save in selectedDiscount1 or selectedDiscount2  */
        // if(sumMandatoryDiscount){
        //     Map<String, Decimal> mandatoryDiscountMap = new Map<String, Decimal>();
        //     //system.debug('[TMCreatePolicy]getPremiumDiscounts().premiumDiscountMap='+premiumDiscountMap);
        //     for(Premium_Discount__c pd : premiumDiscountMap.values()){
        //         if(pd.Mandatory__c && pd.Discount__c != null && pd.Discount__c > 0 && availableDiscountMap.get(pd.Discount_Type__c) == true){
        //             mandatoryDiscountMap.put(pd.Discount_Type__c, pd.Discount__c);
        //         }
        //     }    
        //     if(mandatoryDiscountMap != null){
        //         //Decimal mandatoryDiscount = TMEsalesHelper.getFinalDiscountPercentage(mandatoryDiscountList);
        //         Decimal mandatoryDiscount = TMEsalesHelper.getFinalDiscountPercentage(mandatoryDiscountMap);
        //         //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().mandatoryDiscount='+mandatoryDiscount);
        //         if(mandatoryDiscount != 0)
        //             discountMap.put('MandatoryDiscount', mandatoryDiscount);
        //     }
        // }else{
        //     for(Premium_Discount__c pd : premiumDiscountMap.values()){
        //         if(pd.Mandatory__c && pd.Discount__c != null && pd.Discount__c > 0 && availableDiscountMap.get(pd.Discount_Type__c) == true){
        //             discountMap.put(pd.Discount_Type__c, pd.Discount__c);
        //         }
        //     }
        // }   
        /* add by Jack on 2022-01-04 for project: Discount enhancement will save in selectedDiscount1 or selectedDiscount2  */                                                            

        //discount 1
        //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().selectedDiscount1='+selectedDiscount1);
        if(premiumDiscountMap.get(selectedDiscount1) != null){            
            Premium_Discount__c discount1 = premiumDiscountMap.get(selectedDiscount1);
            //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().discount1='+discount1);
            if(discount1.Discount__c != null && discount1.Discount__c > 0 && availableDiscountMap.get(discount1.Discount_Type__c) == true){
                if(discountMap.size()<2){
                    discountMap.put(discount1.Discount_Type__c, discount1.Discount__c);
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Discount is not available'));
                }                
            }
        } 
        //discount 2
        //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().selectedDiscount2='+selectedDiscount2);
        if(premiumDiscountMap.get(selectedDiscount2) != null){
            Premium_Discount__c discount2 = premiumDiscountMap.get(selectedDiscount2);
            //system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().discount2='+discount2);
            if(discount2.Discount__c != null && discount2.Discount__c > 0 && availableDiscountMap.get(discount2.Discount_Type__c) == true){  
                if(discountMap.size()<2){
                    //discountMap.put('Discount2', discount2.Discount__c);
                    discountMap.put(discount2.Discount_Type__c, discount2.Discount__c);
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Discount is not available'));
                }
            }
        } 
        
        
        //payment frequency discount
        Decimal paymentDiscount = paymentFrequencyDiscountMap.get(selectedPaymentFrequency);
        discountMap.put('PaymentDiscount', paymentDiscount);
        
        system.debug('[TMCreatePolicyCtrl]getPremiumDiscounts().discountMap = '+discountMap);
        return discountMap;
    }
    
    public static void changeUWResultByAppeal(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            //if appeal yes, overall result change to referred
            if(TMCreatePolicyCtrl.APPEAL_YES.equalsIgnoreCase(pis.piPolicy.Appeal_For_UW_Result__c)){
                pis.piPolicy.UW_Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED;
                List<UW_Result__c> uwReuslts = [select id,Overrall_Result__c from UW_Result__c where policy__c = :pis.piPolicy.id];
                for(UW_Result__c uw : uwReuslts){
                    uw.Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED;
                }
                if(null != uwReuslts && uwReuslts.size() > 0)
                    upsert uwReuslts;
            }
            //SPS-439
            if(TMCreatePolicyCtrl.APPEAL_WITHDRAWN.equalsIgnoreCase(pis.piPolicy.Appeal_For_UW_Result__c)){
                pis.piPolicy.UW_Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED;
                List<UW_Result__c> uwReuslts = [select id,Overrall_Result__c from UW_Result__c where policy__c = :pis.piPolicy.id];
                for(UW_Result__c uw : uwReuslts){
                    uw.Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED;
                }
                if(null != uwReuslts && uwReuslts.size() > 0)
                    upsert uwReuslts;
            }
            //SPS-439
            //if appeal no ,remain unchanged 
            
            //if appeal result is withdraw, overall result remain unchanged, but policy status change to Rejected
            //if(TMCreatePolicyCtrl.APPEAL_WITHDRAWN.equalsIgnoreCase(pis.piPolicy.Appeal_For_UW_Result__c)){
                //pis.uwResult.Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_WITHDRAWN;
                //pis.piPolicy.policy_status__c = 'Rejected';
            //}
        }
    }
    
    public static void adjustPolicyStatusByAppeal(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            //if appeal result is withdraw, overall result remain unchanged, but policy status change to Rejected
            if(TMCreatePolicyCtrl.APPEAL_WITHDRAWN.equalsIgnoreCase(pis.piPolicy.Appeal_For_UW_Result__c) && !TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED.equals(pis.piPolicy.Pre_Sales_Result__c)){
                //pis.uwResult.Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_WITHDRAWN;
                pis.piPolicy.policy_status__c = 'Rejected';
            }
        }
    }
    
    /*
    * Generate Policy Number. Make sure the length of policy number is 10.
    * @param productCode : The selected campaign core product code
    * @return New Policy number
    */
    public static String generatePolicyNumber(String productCode){
        String policyNumber = '';
        Integer seqNum;
        if(String.isEmpty(productCode)){
            productCode = 'TMC';
        }
        String reusablePolicyNO = getReusablePolicyList(productCode);
        system.debug('TMPolicyUtil generatePolicyNumber() reusablePolicyNO'+reusablePolicyNO);
        if( String.isEmpty(reusablePolicyNO) ){
            try{
                seqNum = SequenceNumberGenerator.getNext(productCode);
            } catch(SequenceNumberGenerator.SequenceNumberGenerationException e){
                Sequence_Number__c sn = new Sequence_Number__c(name_space__c = productCode, current_number__c = 0);
                insert sn;
                seqNum = SequenceNumberGenerator.getNext(productCode);
            } catch(Exception e1){
                system.debug('>>> Fail to generate policy number: ' + e1.getMessage());
            }
            if(seqNum != null){
                Integer leftPadPlace = 10 - ( String.isBlank(productCode) ? 0 : productCode.length() );
                policyNumber = productCode + String.valueOf(seqNum).leftpad(leftPadPlace, '0');
            }
            return policyNumber;
        }else{
            return reusablePolicyNO;
        }
    }
    
    
    public static String getReusablePolicyList(String prefix){
        String prefixFilter = prefix + '%';
        List<Reusable_Policy_No__c> rpnList = [Select Policy_No__c,Have_Been_Used__c from Reusable_Policy_No__c where Have_Been_Used__c = false And Policy_No__c like :prefixFilter order by Policy_No__c asc limit 1];
        system.debug('TMPolicyUtil getReusablePolicyList() rpnList'+rpnList);
        if(rpnList.size() > 0){
            String temp = rpnList[0].Policy_No__c;
            rpnList[0].Have_Been_Used__c = true;
            update rpnList[0];
            return temp;
        }else{
            return null;
        }
    }
    
    /*
    * TS-692
    * Generate Policy running no. Default format :
    * Running No = “HK” + YYYYMMDD + “J” + “0000” (0000 – is the serial no. The num of inbound call in the transaction date)
    */
    public static String generateRunningNumber(){
        String runningNo = '';
        Integer seqNum;
        
        String prefixDateStr = String.ValueOf(Date.today().year()) 
                                + String.valueOf(Date.today().month()).leftPad(2, '0') 
                                + String.valueOf(Date.today().day()).leftPad(2, '0');
        try{
            seqNum = SequenceNumberGenerator.getNext(prefixDateStr);
        } catch(SequenceNumberGenerator.SequenceNumberGenerationException e){
            Sequence_Number__c sn = new Sequence_Number__c(name_space__c = prefixDateStr, current_number__c = 1);
            insert sn;
            seqNum = SequenceNumberGenerator.getNext(prefixDateStr);
        } catch(Exception e1){
            //system.debug('>>> Fail to generate policy running number: ' + e1.getMessage());
        }
        if(seqNum != null){
            runningNo = 'HK' + prefixDateStr + 'J' + String.valueOf(seqNum).leftpad(4, '0');
        }
        return runningNo;
    }
    
    //Calculate age
    public static Integer calculateAge(Date d){
        
        // Leap Year handling
        Date d1 = Date.newInstance(2000, d.month(), d.day());
        Date d2 = Date.newInstance(2000, Date.today().month(), Date.today().day());
        
        //when today's day is 29-31,swap to 28
        if (Date.today().day() >= 29){
            d2 = Date.newInstance(2000, Date.today().month(), 28);
        }
        
        if ( d1 <= d2 ){
            return Date.today().year() - d.year();
        } else {
            return Math.max(Date.today().year() - d.year() - 1, 0);
        }
    }

    public static Set<String> getRiderCodeSet(String riderField){

        Set<String> riderCodes = new Set<String>();        
        for(String riderCode : getRiderCodeList(riderField)){
            riderCodes.add(riderCode);
        }
        return riderCodes;
    }
    
    public static List<String> getRiderCodeList(String riderField){
        List<String> riderCodes;
        if(String.isNotEmpty(riderField)){
            riderCodes = riderField.split(';');
            Integer i = 0;
            List<String> additionalRiderCodes = new List<String>();
            while(null != riderCodes && i < riderCodes.size()){
                if(riderCodes.get(i).contains(':')){
                    String[] benefitLevelRiderCode = riderCodes.get(i).split(':');
                    additionalRiderCodes.add(benefitLevelRiderCode[1]);
                    riderCodes.remove(i);
                    --i;
                }
                ++i;
            }
            riderCodes.addAll(additionalRiderCodes);
        }
                
        return riderCodes==null?new List<String>():riderCodes;
    }
    
    public static Map<String, List<String>> getBenefitLevelRiderCodeMap(String riderField){
        //system.debug('[TMPolicyUtil] getBenefitLevelRiderCodeMap().riderField='+riderField);
        Map<String, List<String>> resultMap = new Map<String, List<String>>();
        if(String.isNotEmpty(riderField)){
            List<String> riderCodes = riderField.split(';');
            Integer i = 0;
            while(null != riderCodes && i < riderCodes.size()){
                if(riderCodes.get(i).contains(':')){
                    String[] benefitLevelRiderCode = riderCodes.get(i).split(':');
                    if(!benefitLevelRiderCode[0].isNumeric()){
                        benefitLevelRiderCode[0] = TMCreatePolicyCtrl.hex2DecMap.get(benefitLevelRiderCode[0]);
                    }
                    if(resultMap.containsKey(benefitLevelRiderCode[0])){
                        resultMap.get(benefitLevelRiderCode[0]).add(benefitLevelRiderCode[1]);
                    }else{
                        List<String> riderCodeList = new List<String>();
                        riderCodeList.add(benefitLevelRiderCode[1]);
                        resultMap.put(benefitLevelRiderCode[0], riderCodeList);
                    }                    
                }
                ++i;
            }
        }
        //system.debug('[TMPolicyUtil] getBenefitLevelRiderCodeMap().resultMap='+resultMap);
        return resultMap;
    }
    
    public static String getRelationshipOfPolicy(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        String relationshipOfPolicy = null;
        
        if('PH = PI'.equals(pis.pi.Insured_Type__c)){
            relationshipOfPolicy = 'MI';
        }else if('Spouse'.equals(pis.pi.Insured_Type__c)){
            relationshipOfPolicy = 'SP';
        }else if('Dependent'.equals(pis.pi.Insured_Type__c)){
            relationshipOfPolicy = 'Son;Daughter'.contains(pis.pi.Relationship__c)?'CH':'DP'; 
        }
        //system.debug('[TMPolicyUtil] getRelationshipOfPolicy: '+relationshipOfPolicy);
        return relationshipOfPolicy;
    }
    
    /*
     * return the masked bank account number
     * Version 1.0
     *   Author : Nicole
     *   Date : 20200902
     *   Description : Change mask way, avoid to mask repeated number like 4321432143214321 as ****************
     */
    public static String maskBankAccountNumber(String accountNumber){
        String maskAccountNumber = '';
        if(String.isNotBlank(accountNumber) ){
            if(accountNumber.length() >= 9){//avoid index outof bound
                //Nicole_Version 1.0_20200902
                //maskAccountNumber = accountNumber;
                //String maskStr = accountNumber.substring(4, accountNumber.length() - 4);
                //maskAccountNumber = maskAccountNumber.replace(maskStr,'*'.repeat(maskStr.length()));
                maskAccountNumber = accountNumber.substring(0, 4) + '*'.repeat(accountNumber.length()-8) + accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
            }else{
                maskAccountNumber = accountNumber;
            }
        }
        return maskAccountNumber;
    }
    
    public static String calWeightValue(Decimal paramWeight, String paramWeightUnit){
        String preWeight = '';
        if(null != paramWeight){
            if('lbs'.equalsIgnoreCase(paramWeightUnit)){
                Integer kgWei = Math.round(paramWeight*0.45359237);
                preWeight = String.valueOf(kgWei);                
            }else{
                preWeight = String.valueOf(paramWeight);
            }
        }
        return preWeight;
    }
    
    public static void updatePolicyStatusSubmissionEffectiveDate(New_policy__c policy, Integer currentStep, String selectedProductCode, Boolean isComplete){
        if(currentStep>3){
            if(currentStep<6){
                //system.debug('[TMPolicyUtil] updatePolicyStatusSubmissionEffectiveDate().currentStep='+currentStep);
                //system.debug('[TMPolicyUtil] updatePolicyStatusSubmissionEffectiveDate().isComplete='+isComplete);
                if(currentStep == 4 && isComplete){
                    policy.Submission_Date_Time__c = DateTime.now();
                    if(!'RSM'.equals(selectedProductCode))
                        policy.Policy_Effective_Date__c = Date.today().day()>28?Date.newInstance(Date.today().year(), Date.today().month(), 28):Date.today();
                    policy.Policy_Status__c = 'Completed';
                }else{
                    policy.Policy_Status__c = 'Pending AUW';
                }                
            }else if(currentStep == 6){
                if(isComplete){
                    policy.Submission_Date_Time__c = DateTime.now();    
                    if(!'Invalid;Rejected'.containsIgnoreCase(policy.Policy_Status__c))
                        policy.Policy_Status__c = 'Completed';
                }else{
                    if(!'RSM'.equals(selectedProductCode))
                        policy.Policy_Effective_Date__c = Date.today().day()>28?Date.newInstance(Date.today().year(), Date.today().month(), 28):Date.today();
                    if(!'Invalid'.equals(policy.Policy_Status__c) && !'Rejected'.equals(policy.Policy_Status__c)){//if policy status is invalid or rejected, click the "cancel" button will not change the status until click "cancle remove" button or change the appeal question's answer for each PI 
                        policy.Policy_Status__c = 'Pending Payment';
                    }                    
                }                
            }
        }else{
            policy.Policy_Status__c = 'Pending Basic Information';
        }
    }
    
    public static void setParentIDPolicyList(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList, PolicyCalloutHelper helper){
        //PolicyCalloutHelper helper = new PolicyCalloutHelper();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            pis.parentIDPolicylist = new List<HttpCalloutVO.Policy>();
            if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                if(pis.pi.Parent_PI_ID__c != pis.pi.Personal_ID__c ){        //Added by Nicole for the case Parent ID equals Child ID 
                     pis.parentIDPolicylist = helper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', pis.pi.Parent_PI_ID__c);
                }
            }
            //system.debug('[TMPolicyUtil] setParentIDPolicyList().pis.parentIDPolicylist='+pis.parentIDPolicylist);            
        }
    }
    
    public static void updateBankAccoutNumber(New_Policy__c newPolicy){
        if(String.isNotBlank(newPolicy.Personal_ID__c) && String.isBlank(newPolicy.Bank_Account_No__c) 
            && String.isBlank(newPolicy.Credit_Card_Number__c)){
            //system.debug('[TMPolicyUtil] updateBankAccoutNumber() Get Bank Account Number from WS >> Personal Id =' + newPolicy.Personal_ID__c );    
            PersonCalloutHelper personCalloutHelper = new PersonCalloutHelper();
            List<HttpCalloutVO.PersonPayment> personPaymentList = personCalloutHelper.getPersonPaymentBasic(newPolicy.Personal_ID__c);
            if(!personPaymentList.isEmpty()){
                HttpCalloutVO.PersonPayment pp = personPaymentList[0];
                newPolicy.Bank_Account_No__c = pp.accountNumber;
                newPolicy.Bank_Account_No_Mask__c = TMPolicyUtil.maskBankAccountNumber(pp.accountNumber);
                newPolicy.Credit_Card_Number__c = pp.accountNumber;
                newPolicy.Credit_Card_Number_Mask__c = TMPolicyUtil.maskBankAccountNumber(pp.accountNumber);
                //system.debug('[TMPolicyUtil] updateBankAccoutNumber() Get Bank Account Number from WS Success>> Bank Acc No. =' + pp.accountNumber);  
            }
        }
    }
    
    //to get AUW URL for website case
    /*
    public static void getAuwUrl(TMCreatePolicyCtrl ctrl){
        if(ctrl.policyTransaction != null && String.isNotBlank(ctrl.policyTransaction.Web_Site_Running_Number__c) && ctrl.currentStep > 5 ){
            TMEsalesHelper tmEhelper = new TMEsalesHelper();
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
                if( String.isBlank(pis.piPolicy.AUW_URL__c) ){
                    try{
                        //system.debug('[TMPolicyUtil] retrive AUW URL policy number > ' + pis.piPolicy.policy_no__c);
                        Person_Insured__c pi = pis.pi;
                        
                        Boolean isInbound = false;
                        if(TMEsalesHelper.auwInboundChannels.contains(ctrl.cam.Channel__r.Channel_Code__c)){
                            isInbound = true;
                        }
                        TMEsalesHelper.PreSalesAttribute uwAtt = new TMEsalesHelper.PreSalesAttribute();
                        String dob = '';
                        if(pi.Date_of_Birth__c != null){
                            String birth_year = String.valueOf(pi.Date_of_Birth__c.year());
                            String birth_month = String.valueOf(pi.Date_of_Birth__c.month());
                            String birth_day = String.valueOf(pi.Date_of_Birth__c.day());
                            dob = birth_year + birth_month.leftPad(2, '0') + birth_day.leftPad(2, '0');
                        }
                        uwAtt.applicationId = pis.piPolicy.Application_Id__c;
                        uwAtt.channel = ( isInbound ? generalSetting.Channel_Code_Inbound__c : generalSetting.Channel_Code_Outbound__c );
                        uwAtt.piId = pi.Personal_ID__c;
                        uwAtt.locale = 'ZH';
                        uwAtt.dob = dob;
                        uwAtt.issueAge = String.valueOf(pi.PI_Age__c);
                        
                        uwAtt.height = String.valueOf(pi.height__c);
                        //uwAtt.height = '170';
                        uwAtt.weight = String.valueOf(pi.weight__c);
                        //uwAtt.weight = '55';
                        
                        if(pi.Gender__c == 'Male'){
                            uwAtt.gender = 'M';
                        }else if(pi.Gender__c == 'Female'){
                            uwAtt.gender = 'F';
                        }
                        if(pi.Smoker__c == 'yes'){
                            uwAtt.smoker ='true';
                        }else if(pi.Smoker__c == 'no'){
                            uwAtt.smoker ='false';
                        }else{
                            uwAtt.smoker = null;
                        }
                        uwAtt.clientRole = 'UW';
                        uwAtt.country = 'HK';
                        uwAtt.triggerType = 'FULL_UW';
                        uwAtt.preSalesStatus = '';
                        uwAtt.fullTriggerType = '';
                        uwAtt.campaignCode = '';
                        
                        String endpoint = esalesSetting.AUW_Endpoint__c;
                        String body = tmEhelper.getFullUWRequestBody(uwAtt);
                        HttpResponse res = tmEhelper.getCalloutResponse(TMEsalesHelper.WS_FULLUW, endpoint, 'POST', body);
                        //system.debug('[TMPolicyUtil] response >> ' + res);
                        String url = tmEhelper.processFullUnderwritingResponse(res.getBodyDocument());
                        //system.debug('[TMPolicyUtil] get auw url= ' + url);
                        
                        pis.piPolicy.AUW_URL__c = url;
                        pis.auwURL = url;
                        
                        pis.piPolicy.Presales_Result_Attribute__c = TMPolicyUtil.preSalesAttSerialize(pis, ctrl.newPolicy.Product_Code__c);
                        //system.debug('[TMPolicyUtil] get auw url > Set  Presales_Result_Attribute__c >> ' + pis.piPolicy.Presales_Result_Attribute__c);
                    }catch(Exception e){
                        //system.debug('[TMPolicyUtil] get auw url exception >>' + e.getMessage());
                        //system.debug('[TMPolicyUtil] get auw url exception >>' + e.getStackTraceString());
                    }                           
                }
            }
        }
    }
    */
    
    public static void updateUWRelatedFieldsInPolicies(New_policy__c policy){
        List<New_policy__c> policyList = new List<New_policy__c>();
        policyList.add(policy);
        updateUWRelatedFieldsInPolicies(policyList);
    }
    
    public static void updateUWRelatedFieldsInPolicies(List<New_policy__c> policyList){
        Set<String> policyIds = new Set<String>();
        for(New_policy__c policy : policyList){
            policyIds.add(policy.id);
        }
        Map<Id,New_policy__c> policyInDBMap = new Map<Id, New_policy__c>([select id,Application_Id__c,AUW_URL__c,UW_Overrall_Result__c,Pre_Sales_Result__c,Presales_Result_Attribute__c,PreSales_Result_Msg__c,UW_Result__c,Referral_Exclusion_Reason__c,Loading__c from New_policy__c where id in :policyIds]);
        for(New_policy__c policy : policyList){
            New_policy__c policyInDB = policyInDBMap.get(policy.Id);
            //system.debug('[TMPolicyUtil] policyInDB.Pre_Sales_Result__c='+policyInDB.Pre_Sales_Result__c+' policyInDB.Referral_Exclusion_Reason__c '+policyInDB.Referral_Exclusion_Reason__c+' UW_Overrall_Result__c:'+policyInDB.UW_Overrall_Result__c);
            if(null != policyInDB){
                /* Comment for AH17265
                policy.Application_Id__c = policyInDB.Application_Id__c;
                policy.AUW_URL__c = policyInDB.AUW_URL__c;
                policy.UW_Overrall_Result__c = policyInDB.UW_Overrall_Result__c;
                policy.Pre_Sales_Result__c = policyInDB.Pre_Sales_Result__c;
                policy.Presales_Result_Attribute__c = policyInDB.Presales_Result_Attribute__c;
                policy.PreSales_Result_Msg__c = policyInDB.PreSales_Result_Msg__c;
                policy.UW_Result__c = policyInDB.UW_Result__c;
                policy.Referral_Exclusion_Reason__c = policyInDB.Referral_Exclusion_Reason__c;
                policy.Loading__c = policyInDB.Loading__c;
                */
                
                /* Fixing for AH17265*/
                policy.Application_Id__c = String.isBlank(policyInDB.Application_Id__c)?policy.Application_Id__c:policyInDB.Application_Id__c;
                policy.AUW_URL__c = String.isBlank(policyInDB.AUW_URL__c)?policy.AUW_URL__c:policyInDB.AUW_URL__c;
                policy.UW_Overrall_Result__c = String.isBlank(policyInDB.UW_Overrall_Result__c)?policy.UW_Overrall_Result__c:policyInDB.UW_Overrall_Result__c;
                policy.Pre_Sales_Result__c = String.isBlank(policyInDB.Pre_Sales_Result__c)?policy.Pre_Sales_Result__c:policyInDB.Pre_Sales_Result__c;
                policy.Presales_Result_Attribute__c = String.isBlank(policyInDB.Presales_Result_Attribute__c)?policy.Presales_Result_Attribute__c:policyInDB.Presales_Result_Attribute__c;
                policy.PreSales_Result_Msg__c = String.isBlank(policyInDB.PreSales_Result_Msg__c)?policy.PreSales_Result_Msg__c:policyInDB.PreSales_Result_Msg__c;
                //system.debug('[TMPolicyUtil] updateUWRelatedFieldsInPolicies policyInDB.UW_Result__c='+policyInDB.UW_Result__c);
                //system.debug('[TMPolicyUtil] updateUWRelatedFieldsInPolicies policy.UW_Result__c='+policy.UW_Result__c);
                policy.UW_Result__c = String.isBlank(policyInDB.UW_Result__c)?policy.UW_Result__c:policyInDB.UW_Result__c;
                policy.Referral_Exclusion_Reason__c = policyInDB.Referral_Exclusion_Reason__c;
                policy.Loading__c = policyInDB.Loading__c==null?policy.Loading__c:policyInDB.Loading__c;
                /* Fixing for AH17265*/
            }
        }
    }
    
    public static Map<String,Boolean> getPIIdHasInforcePolicyMap(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList, String productCode){
        Map<String,Boolean> PIIdHasInforcePolicyMap = new Map<String,Boolean>();
        Set<String> piParentHKIds = new Set<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                PIIdHasInforcePolicyMap.put(pis.pi.Parent_PI_ID__c, false);
                piParentHKIds.add(pis.pi.Parent_PI_ID__c);
                if(null != productCode && null != pis.parentIDPolicylist){
                    for(HttpCalloutVO.Policy p : pis.parentIDPolicylist){
                        //system.debug('[TMPolicyUtil] getPIIdHasInforcePolicyMap().p.productCode='+p.productCode+' p.policyStatusDisplayName='+p.policyStatusDisplayName);
                        if((p.policyStatusDisplayName == 'Inforce' || p.policyStatusDisplayName == '生效') && productCode.contains(p.productCode)){
                            PIIdHasInforcePolicyMap.put(pis.pi.Parent_PI_ID__c, true);
                            break;
                        }
                    }
                }
            }            
        }
        if(piParentHKIds.size() > 0){
            List<Person_Insured__c> inforcePIPolicyInSFDC = [select id, new_policy__r.id, Personal_ID__c from Person_Insured__c
                                                               where Personal_ID__c in :piParentHKIds
                                                               and (new_policy__r.policy_status__c = 'Completed' or  new_policy__r.policy_status__c = 'Submitted')
                                                               and new_policy__r.Product_Code__c = :productCode
                                                               and new_policy__r.UW_Overrall_Result__c = :TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED];
        
            for(Person_Insured__c pi : inforcePIPolicyInSFDC){
                PIIdHasInforcePolicyMap.put(pi.Personal_ID__c, true);
            }
        }
        
        
        return PIIdHasInforcePolicyMap;
    }
    
    public static void setPersonalIDPolicylistFromWS(TMCreatePolicyCtrl ctrl){
        //PolicyCalloutHelper helper = new PolicyCalloutHelper();
        Boolean hasHolder = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
            if( null != pis.pi.Personal_ID__c && !pis.pi.Personal_ID__c.equals(pis.personalIDCache)){
                List<HttpCalloutVO.Policy> plist = ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', pis.pi.Personal_ID__c);
                pis.personalIDPolicylistFromWS = plist;
                pis.personalIDCache = pis.pi.Personal_ID__c;//update PersonalID InMemory
                //system.debug(' pis.personalIDPolicylistFromWS+'+ pis.personalIDPolicylistFromWS);
                if(pis.pi.Insured_Type__c == 'PH = PI'){
                    hasHolder = true;
                    ctrl.holderPolicyList = plist;
                }
            }
        }
        if(String.isNotEmpty(ctrl.newPolicy.Personal_ID__c)){
            ctrl.PHPersonalIDPolicylist = ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', ctrl.newPolicy.Personal_ID__c, '', '', '');
            //system.debug('trl.PHPersonalIDPolicylist'+ctrl.PHPersonalIDPolicylist);
        }else{
            ctrl.PHPersonalIDPolicylist = new List<HttpCalloutVO.Policy>();
        }
        
        if(!hasHolder){
            //system.debug('[TMPolicyUtil] setPersonalIDPolicylistFromWS no holder in transaction');
            TMCreatePolicyCtrl.PersonInsuredStructure pis = ctrl.personInsuredStructureList[0];
            String holderSSN = pis.piPolicy.Personal_Id__c;
            if(String.isNotBlank(holderSSN)){
                ctrl.holderPolicyList = ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', holderSSN);
            }
        }
    }
    
    public static void setDiscountCodeToPlanQuote(Plan_Quote__c planQuote, TMCreatePolicyCtrl.PersonInsuredStructure pis, Product__c selectedProduct, Map<String, Decimal> paymentFrequencyDiscountMap, Map<String, Premium_Discount__c> premiumDiscountMap, String selectedDiscount1, String selectedDiscount2, String selectedPaymentFrequency){
        planQuote.Duration_Discount1__c = null;
        planQuote.Duration_Discount2__c = null;
        //system.debug('[TMPolicyUtil] setDiscountCodeToPolicy().pis.availableDiscountMap='+pis.availableDiscountMap);
        Map<String, Decimal> discountToApply = getPremiumDiscounts(pis.availableDiscountMap, selectedProduct, paymentFrequencyDiscountMap, premiumDiscountMap, selectedDiscount1, selectedDiscount2, selectedPaymentFrequency, false);
        for(String discountDescr : discountToApply.keySet()){            
            Decimal productDiscountValue = getProductDiscountPercent(discountDescr);
            //system.debug('[TMPolicyUtil] setDiscountCodeToPolicy().productDiscountValue='+productDiscountValue);
            if(null != productDiscountValue){//check whether discount belongs to productDiscount
                if(null == planQuote.Duration_Discount1__c){
                    //planQuote.Duration_Discount1__c = String.valueOf(productDiscountValue);//let duration be null for product discount
                    planQuote.Discount_1__c = productDiscountValue;
                }else if(null == planQuote.Duration_Discount2__c){
                    //planQuote.Duration_Discount2__c = String.valueOf(productDiscountValue);
                    planQuote.Discount_2__c = productDiscountValue;
                }
            }
            /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
            // else if(null != premiumDiscountMap.get(discountDescr) && premiumDiscountMap.get(discountDescr).Mandatory__c){
            //     if(null == planQuote.Duration_Discount1__c){
            //         planQuote.Duration_Discount1__c = null==premiumDiscountMap.get(discountDescr).Duration__c?null:String.valueOf(premiumDiscountMap.get(discountDescr).Duration__c);
            //         planQuote.Discount_1__c = premiumDiscountMap.get(discountDescr).Discount__c;
            //     }else if(null == planQuote.Duration_Discount2__c){
            //         planQuote.Duration_Discount2__c = null==premiumDiscountMap.get(discountDescr).Duration__c?null:String.valueOf(premiumDiscountMap.get(discountDescr).Duration__c);
            //         planQuote.Discount_2__c = premiumDiscountMap.get(discountDescr).Discount__c;
            //     }
            // }
            /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
            //if duration is empay, the first discount will be covered by second discount
        }
        system.debug('planQuote.Discount_1__c:'+planQuote.Discount_1__c+' planQuote.Discount_2__c'+planQuote.Discount_2__c);
        system.debug('selectedDiscount1:'+selectedDiscount1+' pis.availableDiscountMap.get(selectedDiscount1)'+pis.availableDiscountMap.get(selectedDiscount1));
        if(null != selectedDiscount1 && pis.availableDiscountMap.get(selectedDiscount1) == true){
            if(null == planQuote.Duration_Discount1__c){
                System.debug(' selectedDiscount1:'+selectedDiscount1+' premiumDiscountMap.get(selectedDiscount1):'+premiumDiscountMap.get(selectedDiscount1));
                //if(premiumDiscountMap.get(selectedDiscount1) != null){
                    planQuote.Duration_Discount1__c = null==premiumDiscountMap.get(selectedDiscount1).Duration__c?null:String.valueOf(premiumDiscountMap.get(selectedDiscount1).Duration__c);
                    planQuote.Discount_1__c = premiumDiscountMap.get(selectedDiscount1).Discount__c;
                //}
            }else if(null == planQuote.Duration_Discount2__c){
                planQuote.Duration_Discount2__c = null==premiumDiscountMap.get(selectedDiscount1).Duration__c?null:String.valueOf(premiumDiscountMap.get(selectedDiscount1).Duration__c);
                planQuote.Discount_2__c = premiumDiscountMap.get(selectedDiscount1).Discount__c;
            }
        }
        system.debug('planQuote.Discount_1__c:'+planQuote.Discount_1__c+' planQuote.Discount_2__c'+planQuote.Discount_2__c);
        if(null != selectedDiscount2 && pis.availableDiscountMap.get(selectedDiscount2) == true){
            if(null == planQuote.Duration_Discount1__c){
                planQuote.Duration_Discount1__c = null==premiumDiscountMap.get(selectedDiscount2).Duration__c?null:String.valueOf(premiumDiscountMap.get(selectedDiscount2).Duration__c);
                planQuote.Discount_1__c = premiumDiscountMap.get(selectedDiscount2).Discount__c;
            }else if(null == planQuote.Duration_Discount2__c){
                planQuote.Duration_Discount2__c = null==premiumDiscountMap.get(selectedDiscount2).Duration__c?null:String.valueOf(premiumDiscountMap.get(selectedDiscount2).Duration__c);
                planQuote.Discount_2__c = premiumDiscountMap.get(selectedDiscount2).Discount__c;
            }
        }
        system.debug('planQuote.Discount_1__c:'+planQuote.Discount_1__c+' planQuote.Discount_2__c'+planQuote.Discount_2__c);
    }
    
    public static Map<String, List<String>> getRiderCodeBenefitListMap(Map<String, TMEsalesHelper.Portalproduct> riderproductMap){//key is meaningless
        Map<String, List<String>> riderCodeBenefitListMap = new Map<String, List<String>>();
        for(TMEsalesHelper.Portalproduct product : riderproductMap.values()){
            if(riderCodeBenefitListMap.containsKey(product.productCode)){
                riderCodeBenefitListMap.get(product.productCode).add(product.rateScale);
            }else{
                List<String> benefitlevelList = new List<String>();
                benefitlevelList.add(product.rateScale);
                riderCodeBenefitListMap.put(product.productCode, benefitlevelList);
            }
        }
        return riderCodeBenefitListMap;
    }
    
    public static void setPlanQuoteBenefitAmount(String piBenefitLevel, Map<String, HttpCalloutVO.Benefit> benefitMap, Plan_Quote__c newObj){
        if(newObj.Is_Rider__c){
            HttpCalloutVO.Benefit benefitVO = benefitMap.get(piBenefitLevel);
            if(null != benefitVO){
                for(HttpCalloutVO.BenefitDetail bd : benefitVO.benefitDetailList){
                    String code = bd.description.split(':')[0];
                    if(code == newObj.Product_Code__c.replace('@', '')){
                        newObj.Benefit_amount__c = bd.amount;
                    }
                }
            }            
        }
    }
    
/** ******************************************************************** PI Validation & Discount Validation **********************************************************************/    
    public static void piDiscountInitAndValidation(PolicyTransactionValidationStruct ptvs){
        //system.debug('[TMPolicyUtil] piDiscountInitAndValidation() <<<<<<<<<<<< start >>>>>>>>>>>>>');
        discountInit(ptvs);        
        discountValidation(ptvs);
        //system.debug('[TMPolicyUtil] piDiscountInitAndValidation() <<<<<<<<<<<< end >>>>>>>>>>>>>');
    }
    
    public static void discountInit(PolicyTransactionValidationStruct ptvs){
        //system.debug('[TMPolicyUtil] discountInit() <<<<<<<<<<<< start >>>>>>>>>>>>>');
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            pis.availableDiscountMap = new Map<String,boolean>();
            for(String disDec : ptvs.ctrl.premiumDiscountMap.keySet()){
                //if(ptvs.ctrl.premiumDiscountMap.get(disDec).Mandatory__c == true){
                pis.availableDiscountMap.put(ptvs.ctrl.premiumDiscountMap.get(disDec).Discount_Type__c, true);//discount default true                
            }
            System.debug('discountInit pis.availableDiscountMap:'+pis.availableDiscountMap);
            for(String refund : ptvs.ctrl.premiumRefundMap.keySet()){
                pis.availableDiscountMap.put(ptvs.ctrl.premiumRefundMap.get(refund).Discount_Type__c, true);
            }
            System.debug('discountInit pis.availableDiscountMap:'+pis.availableDiscountMap);
            //hard code
            if('@PMGH'.equals(ptvs.ctrl.selectedProduct.Product_Code__c)){
                pis.availableDiscountMap.put('95',true);
                pis.availableDiscountMap.put('97',true);
            }else if('TMC50'.equals(ptvs.ctrl.selectedProduct.Product_Code__c) || 'TMCPU'.equals(ptvs.ctrl.selectedProduct.Product_Code__c)){
                pis.availableDiscountMap.put('95',true);
            }
            //system.debug('[TMPolicyUtil] discountInit().pis.availableDiscountMap='+pis.availableDiscountMap);
        }
        //system.debug('[TMPolicyUtil] discountInit() <<<<<<<<<<<< end >>>>>>>>>>>>>');
    }
    
    public static void discountValidation(PolicyTransactionValidationStruct ptvs){
                
        TMproductStrategy tmProductStrategy = TMDiscountFactory.createProdcutDiscountStrategy(ptvs);
        tmProductStrategy.discountValidation();
    }
    
    public static void policyTransactionValidation(PolicyTransactionValidationStruct ptvs){
        
        TMproductStrategy tmProductStrategy = TMPolicyTransactionValidationFactory.createProductStrategy(ptvs);
        tmProductStrategy.transactionValidation();
    }
    
    public static void piValidation(PolicyTransactionValidationStruct ptvs){
        TMproductStrategy tmProductStrategy = TMPolicyTransactionValidationFactory.createProductStrategy(ptvs);
        tmProductStrategy.piValidation();
    }
        
    public class PolicyTransactionValidationStruct{
        
        public PolicyTransactionValidationItem policyTransactionValidationItem{get;set;}
        public TMCreatePolicyCtrl ctrl {get;set;}
        
        public PolicyTransactionValidationStruct(TMCreatePolicyCtrl ctrl){
            
            this.ctrl = ctrl;            
            this.policyTransactionValidationItem = new PolicyTransactionValidationItem();
        }
    }
    
    public class PIValidationItem{
        
        public boolean otherValidation{get;set;}{otherValidation = true;}
        public boolean isDuplicate{get;set;}
        public boolean needPresales{get;set;}
        public boolean needAUW{get;set;}
        
        public PIValidationItem(){}
    }
    
    public class PolicyTransactionValidationItem{
        
        public boolean productValidation{get;set;}{productValidation = true;}
        public boolean showBMIInd {get;set;} {showBMIInd = false;}
        public boolean showSmokingInd {get;set;} {showSmokingInd = false;}
        public boolean isParentIDMandatory{get;set;} {isParentIDMandatory = false;}        
        
        public PolicyTransactionValidationItem(){}
    }
    
    //GL31 jack add
    public static List<String> assessRiderValide(Map<String, String> selectedRidersMap,String availableRider,Boolean getAailOrNot){
        Set<String> result = new Set<String>();
        Set<String> resultNot = new Set<String>();
        for(String rider : selectedRidersMap.keySet()) {
            system.debug('rider:'+rider);            
            Boolean isAvaiRider = false;
            if(availableRider != null){
                for(String riderKey : availableRider.split(',')){
                    System.debug('riderKey:'+riderKey);
                    if(rider.startsWithIgnoreCase(riderKey)){
                        isAvaiRider = true;
                        break;
                    }
                }
            }
            if(!isAvaiRider){
                resultNot.add(selectedRidersMap.get(rider));
            }else{
                result.add(selectedRidersMap.get(rider));
            }
        }
        if(getAailOrNot){
            return new List<String>(result);
        }else{
            return new List<String>(resultNot);
        }
    } 

    public static Set<String> getRiderNameForAssessment(Map<String,Set<String>> proRiderMap){
        Set<String> riderCodeSet = new Set<String>();
        for(String key : proRiderMap.keySet()){
            if(CignaUtil.TM_PRO_SCOPE.contains(key)){
                riderCodeSet.addAll(proRiderMap.get(key));
            }
        }
        if(riderCodeSet.size()>0){
            return getRiderName(riderCodeSet);
        }
        return new Set<String>();
    }

    public static Set<String> getRiderName(Set<String> riderCodeSet){
        Set<String> addedSet = new Set<String>();
        Set<String> result = new Set<String>();
        List<product__c> pList = [select name,product_code__c from product__c where product_code__c in: riderCodeSet];
        for(product__c prod : pList){
            if (!addedSet.contains(prod.Product_Code__c)) {
                result.add(prod.name);
            }
        }
        return result;
    }
    /************************************************************
    *Author     :Nicole
    *Date       :2021_03_19
    *Description:Check if person isnured have first year discount
    *************************************************************/
    public static Map<String,Boolean> getFirstYDisEliMap(String proCode,List<String> ssnList){
        Map<String,Boolean> result=new Map<String,Boolean>();
        CheckPolicyExistCalloutHelper cpHelper=new CheckPolicyExistCalloutHelper();
        for(String ssn : ssnList){
            String firstYD=cpHelper.CheckFirstYearDiscount(proCode,ssn);
            if(String.isNotBlank(firstYD) && firstYD.equalsIgnoreCase('Y')){
                result.put(ssn,true);
            }else{
                result.put(ssn,false);
            }
        }
        system.debug('[TMPolicyUtil.getFirstYDisEliMap]:'+result);
        return result;
    }

    /**
    * @description 
    * @author Jackshao@deloitte.com.cn | 01-04-2022 
    * @param String currentProductCode 
    * @param String holderSSN 
    * @return Boolean 
    **/
    public static Boolean lapseSurrenderPolicyChecking(String currentProductCode,List<HttpCalloutVO.Policy> wsPolicyList){
        // PolicyCalloutHelper helper=new PolicyCalloutHelper();
        // List<HttpCalloutVO.Policy> wsPolicyList=helper.getIndividualPolicyListBasicByCriteria('', '', holderSSN, '', '', '');
        system.debug('wsPolicyList:'+wsPolicyList.size());
        if(wsPolicyList.size()>0){
            for(HttpCalloutVO.Policy p : wsPolicyList){
                if(String.isNotBlank(p.policyStatusCode)&&(p.policyStatusCode=='6' || p.policyStatusCode=='4')
                    &&String.isNotBlank(p.productCode)&&compareProductCodeInGroupPolicyChecking(p.productCode,currentProductCode)
                    && (p.CancelDate != null &&(p.CancelDate.daysBetween(system.today())<=365)) ){
                        return true;
                }
            }
        }
        return false;
    } 

    /**
    * @description compare if the product code is same group with Policy Validation checking custom setting
    * @author Jackshao@deloitte.com.cn | 24-02-2022 
    * @param String productCode1 
    * @param String productCode2 
    * @return Boolean 
    **/
    public static Boolean compareProductCodeInGroupPolicyChecking(String productCode1,String productCode2){
        productCode1=productCode1.replace('@', '');
        productCode2=productCode2.replace('@', '');
        system.debug('policyValidationMap.get(productCode1) '+policyValidationMap.get(productCode1)+' policyValidationMap.get(productCode2):'+policyValidationMap.get(productCode2));
        if(policyValidationMap.containsKey(productCode1) && policyValidationMap.containsKey(productCode2)){
            if(policyValidationMap.get(productCode1).Duplicate_Policy_Checking__c==policyValidationMap.get(productCode2).Duplicate_Policy_Checking__c){
                return true;
            }
        }else if(productCode1==productCode2){
            return true;
        }
        return false;
    }

        /**
    * @description compare if the product code is same group with TM Product Category custom setting
    * @author Jackshao@deloitte.com.cn | 08-11-2021 
    * @param String productCode1 
    * @param String productCode2 
    * @return Boolean 
    **/
    public static Boolean compareProductCodeInGroup(String productCode1,String productCode2){
        system.debug('productCategoryMap:'+productCategoryMap);
        system.debug('productCategoryMap.get(productCode1) '+productCategoryMap.get(productCode1)+' productCategoryMap.containsKey(productCode2):'+productCategoryMap.containsKey(productCode2));
        if(productCategoryMap.containsKey(productCode1) && productCategoryMap.containsKey(productCode2)){
            if(productCategoryMap.get(productCode1)==productCategoryMap.get(productCode2)){
                return true;
            }
        }else if(productCode1==productCode2){
            return true;
        }
        return false;
    }

    /**
    * @description 
    * @author Jackshao@deloitte.com.cn | 04-29-2022 
    * @param String oriStr 
    * @param Integer retainLen 
    * @return String 
    **/
    public static String maskData(String oriStr,Integer retainLen){
        String maskStr=oriStr;
        if(String.isNotBlank(oriStr) && oriStr.length()>retainLen){               
            maskStr=oriStr.left(retainLen).rightPad(oriStr.length(),'*');
        }
        return maskStr;
    }

    /**
    * @description check if is eligible full-time student
    * @author ranzhao@deloitte.com.cn | 12-08-2024
    * @param String productCode 
    * @param Decimal age 
    * @param String reason 
    * @return Boolean 
    **/
    public static Boolean checkFullTimeStudent(String productCode, Decimal age, String reason){
        List<String> prodCodeList = new List<String>{'NELG2','NESG2'};
        if(String.isNotBlank(productCode) && prodCodeList.contains(productCode) && null!=age && age>=18 && age<=25 && reason=='Full-time Student'){
            System.debug('is full-time student');
            return true;
        }
        System.debug('is not full-time student');
        return false;
    }

    // Rancho_HKITSFDC402_20250930 - Helper method to check if string is a valid integer
    public static Boolean isSafeStringToInteger(String inputString){
        if(String.isBlank(inputString)){
            return false;
        }
        
        // Remove any whitespace
        String trimmed = inputString.trim();
        // Check if string contains only digits
        String numberPattern = '^[0-9]+$';
        Pattern p = Pattern.compile(numberPattern);
        Matcher m = p.matcher(trimmed);
        if(!m.matches()){
            System.debug('String contains non-numeric characters: ' + inputString);
            return false;
        }
        return true;
    }
}