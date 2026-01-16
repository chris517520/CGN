/**
 * @description       : TM product strategy for Bespoke
 * @author            : Jackshao@deloitte.com.cn
 * @last modified on  : 08-12-2021
 * @last modified by  : Jackshao@deloitte.com.cn
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-12-2021   Jackshao@deloitte.com.cn   Initial Version
 * 2.0                Chris                      pi validation part
**/
public abstract class TMProductStrategyAB extends TMProductStrategy{   
    public string productCode;    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;    

    public TMProductStrategyAB(TMPolicyUtil.PolicyTransactionValidationStruct ptvs,String productCode) {
        super();
        this.ptvs=ptvs; 
        this.productCode=productCode;

    }
    public override void discountValidation(){     
        super.discountValidation(ptvs,productCode);

        // Rancho_HKITSFDC398_20251017 - CX Campaign - discount validation update
        // if transaction contains one policy not inited in SFDC, bypass validation
        Boolean bypassValidation = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(!pis.piPolicy.Policy_No__c.startsWith('CTM')){
                bypassValidation = true;
                break;
            }
        }
        System.debug('bypassValidation='+bypassValidation);
        
        if(!bypassValidation){
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - discount 80 only eligible for family policy
            Integer eligiblePICount = 0;
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                System.debug('current selected product code: '+productCode);
                System.debug('benefit level: '+pis.pi.Benefit_Level__c);
                if(pis.availableDiscountMap.containsKey('YR2 59% YR3 25% DISCOUNT')){
                    if(pis.pi.Benefit_Level__c != '1'){
                        eligiblePICount++;
                    }else if(pis.pi.Benefit_Level__c == '1'){
                        pis.availableDiscountMap.put('YR2 59% YR3 25% DISCOUNT',false);
                    }
                }
                System.debug('AB current available discount map: '+pis.availableDiscountMap);
            }

            System.debug('AB eligiblePICount: '+eligiblePICount);
            if(eligiblePICount == 1){
                for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                    pis.availableDiscountMap.put('YR2 59% YR3 25% DISCOUNT',false);
                    System.debug('AB available discount map: '+pis.availableDiscountMap);
                }
            }
        }
    }

    public override void piValidation(){     
        super.piValidation(ptvs,productCode);
        System.debug(LoggingLevel.INFO, '*** TMProductStrategyAB piValidation start');
        Set<String> piTypeSet  = New Set<String>();
        Boolean controlFlag = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            // Rancho_HKITSFDC333_20250818 - CX product not allow standalone child
            System.debug('pis.pi.Insured_Type__c: '+pis.pi.Insured_Type__c + ', pis.pi.PI_Age__c: '+pis.pi.PI_Age__c);
            if(pis.pi.Insured_Type__c == 'Dependent' && pis.pi.PI_Age__c < 18){
                if(pis.pi.Relationship__c == 'Son' || pis.pi.Relationship__c == 'Daughter'){
                    controlFlag = true;
                }
                
                if(ptvs.ctrl.amountOfPI == 1){
                    System.debug('standalone child policy');
                    ptvs.ctrl.pageMsg = 'Cathy Premier plan does not allow standalone child enrollment';
                    pis.piValidationItem.otherValidation=false;
                    return;
                }
            }
            piTypeSet.add(pis.pi.Relationship__c);
        }
        if(controlFlag){
            System.debug(LoggingLevel.INFO, '*** whether PH exsit in pi');
            if(!piTypeSet.contains('Policy Holder')){
                System.debug(LoggingLevel.INFO, '*** whether Spouse exsit in pi');
                if(!piTypeSet.contains('Spouse')){
                    System.debug(LoggingLevel.INFO, '*** whether PH has completed policy with same plan which created in current date in SFDC');
                    System.debug(LoggingLevel.INFO, '*** policy holder ID: ' + ptvs.ctrl.newPolicy.Personal_ID__c);
                    System.debug(LoggingLevel.INFO, '*** product code in StrategyAB: ' + productCode);
                    System.debug(LoggingLevel.INFO, '*** product code in TMCreatePolicyVFP: ' + ptvs.ctrl.selectedProduct.product_code__c);
                    if (!isExistCompletedPolicyToday(ptvs.ctrl.newPolicy.Personal_ID__c,ptvs.ctrl.selectedProduct.product_code__c)) {
                        System.debug(LoggingLevel.INFO, '*** whether PH has same inforce plan in IPAS');
                        if (!isSameInforcePlanInIPAS(ptvs.ctrl.newPolicy.Personal_ID__c)) {
                            //pop error message : since this is a general error, only use the first index
                            ptvs.ctrl.personInsuredStructureList[0].piValidationItem.otherValidation = false;
                            if(String.isEmpty(ptvs.ctrl.pageMsg)){
                                ptvs.ctrl.pageMsg = 'Insured is not eligible';
                            }
                        }
                    }
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** TMProductStrategyAB piValidation end');
    }

    public override void transactionValidation(){
        super.transactionValidation(ptvs,productCode);
    }

    /**************************************************************************************
     * isExistCompletedPolicyToday
     * @param holderSSN
     * @param planCode
     * @return Boolean
     * @desc:if PH has completed policy with same plan which created in current date in SFDC
     **************************************************************************************/
    public Boolean isExistCompletedPolicyToday(String holderSSN,String productCode){
        List<New_Policy__c> policyLst = [SELECT Id,Personal_ID__c,Policy_Status__c,Product_Code__c FROM New_Policy__c WHERE Personal_ID__c =:holderSSN AND Policy_Status__c = 'Completed' AND Product_Code__c =: productCode AND LastModifiedDate = TODAY];
        if(policyLst.size() > 0){
            return true;
        }else{
            return false;
        }
    }

    /**************************************************************************************
     * isSameInforcePlanInIPAS
     * @param 
     * @param 
     * @return Boolean
     * @desc:Call WS "GetPolicyListBasicByCriteria" to check if PH has same inforce plan in IPAS
     **************************************************************************************/
    public Boolean isSameInforcePlanInIPAS(String holderSSN){
        PolicyCalloutHelper pHelper = new PolicyCalloutHelper();
        List<HttpCalloutVO.Policy> policyLst = pHelper.getIndividualPolicyListBasicByCriteria('','',holderSSN,'','','');
        System.debug(LoggingLevel.INFO, '*** policyLst.size(): ' + policyLst.size());
        if(policyLst.size() > 0){
            for(HttpCalloutVO.Policy policy : policyLst){
                if(policy.productCode == productCode && policy.sourceSystem == 'IPAS'){
                    return true;
                }
            }
            return false;
        }else{
            return false;
        }
    }
}