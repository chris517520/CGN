/********************************************************************************
 * Apex Class Name - TMCreatePolicyStep6Strategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps 6
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMCreatePolicyStep6Strategy implements TMCreatePolicyStepStrategy{
 
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMCreatePolicyStep6Strategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        this.ptvs = ptvs;
    }
    
    public void stepInit(){
        if(ptvs.ctrl.isAUWcompleted){
            System.debug('auw completed');
            ptvs.ctrl.initPisMap();//AM project coupon jack add
            refreshUWResultFromDB(ptvs.ctrl.personInsuredStructureList);
            //clear the set for call out next time
            ptvs.ctrl.uwPISSet.clear();
            ptvs.ctrl.prePISSet.clear();
            ptvs.ctrl.uwPISListForDisplay.clear();
            //adjust the over all result by any conditions
            adjustOverallResultByAnyconditions(ptvs.ctrl.personInsuredStructureList);
            //adjust child's over all result by parent's over all result
            TMProductStrategy.adjustChildOverallResultByParent(ptvs.ctrl.personInsuredStructureList);
            //adjust over all result by appeal question, appeal question default value "no"
            TMPolicyUtil.changeUWResultByAppeal(ptvs.ctrl.personInsuredStructureList);
            //adjust policy status by presales result
            adjustPolicyStatusByPresalesResult(ptvs.ctrl.personInsuredStructureList);
            //adjust policy status by appeal question
            TMPolicyUtil.adjustPolicyStatusByAppeal(ptvs.ctrl.personInsuredStructureList);
            //Some product need to go 2nd otherValidation checking becasuse some condition only appear after auw
            TMPolicyUtil.piValidation(ptvs);
            //Discount depends on over all result
            TMPolicyUtil.piDiscountInitAndValidation(ptvs);
            //Master Policy Number setting
            //Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            TMProductStrategy.setMasterPolicyNumber(ptvs.ctrl.personInsuredStructureList, ptvs.ctrl.PHPersonalIDPolicylist);
            String piNo = '';
            Integer i = 1;
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                System.debug('[TMCreatePolicyStep6Strategy] pis.piValidationItem.otherValidation'+pis.piValidationItem.otherValidation); 
                System.debug('[TMCreatePolicyStep6Strategy] pis.piPolicy.Policy_Status__c'+pis.piPolicy.Policy_Status__c); 
                System.debug('[TMCreatePolicyStep6Strategy] pis.piPolicy.Pre_Sales_Result__c'+pis.piPolicy.Pre_Sales_Result__c);
                System.debug('[TMCreatePolicyStep6Strategy] pis.piValidationItem.isDuplicate'+pis.piValidationItem.isDuplicate); 
                
                if(!'Invalid'.equals(pis.piPolicy.Policy_Status__c) && (pis.piValidationItem.otherValidation == false || TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED.equals(pis.piPolicy.Pre_Sales_Result__c) || pis.piValidationItem.isDuplicate == true)){
                    piNo += i + ', ';
                }
                ++i;
                
                //delete UW_Result__c and Referral_Exclusion_Reason__c for no need auw policy
                //if(!pis.piValidationItem.needAUW ){
                if(!pis.piValidationItem.needAUW && !(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true)){// change by jakc for policy replacement
                    pis.piPolicy.UW_Result__c = null;
                    pis.piPolicy.Referral_Exclusion_Reason__c = null;
                    //pis.piPolicy.Referral_Exclusion_Reason_Long__c = null;
                    pis.reasonList.clear();
                }
                //delete completed
                
            }
            if(piNo != ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Person Insured '+ piNo +' is not eligible.'));
            }
        }else{
            System.debug('handle next pi auw url');
            TMCreatePolicyCtrl.PersonInsuredStructure pis = ptvs.ctrl.personInsuredStructureList.get(ptvs.ctrl.auwPIindex);
            ptvs.ctrl.piName = pis.pi.Person_Insured_Name__c;
            ptvs.ctrl.auwUrl = pis.auwURL;
            ptvs.ctrl.applicationId = pis.applicationId;
            ptvs.ctrl.lastModifiedDate = pis.uwResultLastModifiedDate;
            //lastModifiedDate = personInsuredStructureList[auwPIindex].uwResult.lastmodifieddate.format();
            System.debug('[TMCreatePolicyStep6Strategy] piDiscountInitAndValidation().applicationId:'+ptvs.ctrl.applicationId);
            ptvs.ctrl.currentStep -= 1;
            ptvs.ctrl.canSave = false;
        }        
    }
     
    public Boolean stepValidation(){
        System.debug('current auw result: '+ptvs.ctrl.isAUWcompleted);
        if(ptvs.ctrl.isAUWcompleted){
            return true;
        }else{
            //updateUWResult(ptvs.ctrl.personInsuredStructureList.get(ptvs.ctrl.auwPIindex));
            TMPolicyUtil.updateUWRelatedFieldsInPolicies(ptvs.ctrl.personInsuredStructureList.get(ptvs.ctrl.auwPIindex).piPolicy);
            
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                system.debug('[TMCreatePolicyStep6Strategy] stepValidation before adjust pis.piPolicy.UW_Result__c= '+pis.piPolicy.UW_Result__c);
            }
            
            adjustUWRelatedFieldsForPolicyReplacement();//jack add for policy replacement 
            
            ptvs.ctrl.auwPIindex ++;
            while(!ptvs.ctrl.uwPISSet.isEmpty() && ptvs.ctrl.auwPIindex < ptvs.ctrl.personInsuredStructureList.size() && !ptvs.ctrl.uwPISSet.contains(ptvs.ctrl.personInsuredStructureList.get(ptvs.ctrl.auwPIindex).pi.id)){
                ptvs.ctrl.auwPIindex ++;
            }
            System.debug('pi index: '+ptvs.ctrl.auwPIindex);
            System.debug('pi list size: '+ptvs.ctrl.personInsuredStructureList.size());
            if(ptvs.ctrl.auwPIindex < ptvs.ctrl.personInsuredStructureList.size()){
                return false;
            }else{
                ptvs.ctrl.isAUWcompleted= true;
                return true;
            }
        }        
    }
    
    public void nextStep(){}
        
    /**    
    private void updateUWResult(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        
        String uwId = pis.uwResult.id;
        if(String.isNotEmpty(uwId)){
            pis.uwResult = [select Id, Application_Id__c, Full_Result__c, Is_Basic_Plan__c, Loading__c, Person_Insured__c, Policy__c, Presales_Result__c, Product__c, Source__c, Submission_Date_Time__c, Overrall_Result__c, 
                                           Appeal__c, UW_EXCL_1__c, UW_EXCL_10__c, UW_EXCL_2__c, UW_EXCL_3__c, UW_EXCL_4__c, UW_EXCL_5__c, UW_EXCL_6__c, UW_EXCL_7__c, UW_EXCL_8__c, UW_EXCL_9__c,Remarks_to_Cigna_Underwriter__c,
                                           Presales_Result_Attribute__c,AUW_URL__c,LastModifiedDate from UW_Result__c where id = :uwId];
        }
        pis.uwResultLastModifiedDate = pis.uwResult.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss.SSSZ');
        
        
    }
    **/
    /**
    private void riderOptionInit(List<TMCreatePolicyCtrl.PersonInsuredStructure> pisList, Map<String,List<HttpCalloutVO.Rider>> riderMap){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : pisList){
            List<String> allRiderCodes = new List<String>();
            Map<String,String> allRiders = new Map<String,String>();
            List<HttpCalloutVO.Rider> initVORiderList = riderMap.get(pis.pi.Benefit_Level__c);
            if(null != initVORiderList){
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>riderMap:'+riderMap);
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>pis.pi.Rider__c:'+pis.pi.Rider__c);
            //if(!riderMap.isEmpty()){
                
                for(HttpCalloutVO.Rider riderVO: initVORiderList){
                    allRiders.put(riderVO.riderCode,riderVO.riderName);
                    allRiderCodes.add(riderVO.riderCode);
                }
                
                //List<String> allRiderCodes = new List<String>(riderMap.keySet());
                //Map<String,String> allRiders = riderMap;
                List<String> riderList = String.isNotEmpty(pis.pi.Rider__c)?pis.pi.Rider__c.split(';'):new List<String>();
                
                pis.initRiderRelated4PI(allRiderCodes, allRiders, riderList);
            }
        }            
    }
    **/
    private void refreshUWResultFromDB(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){
        
        /**
        Set<String> piIdsSet = new Set<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            piIdsSet.add(pis.pi.id);
        }
        Map<Id,Person_insured__c> piMap = new Map<Id,Person_insured__c>([select Id, New_Policy__r.Referral_Exclusion_Reason__c, (select Id, Application_Id__c, Full_Result__c, Is_Basic_Plan__c, Loading__c, Person_Insured__c, Policy__c, Presales_Result__c, Product__c, Source__c, Submission_Date_Time__c, Overrall_Result__c, 
                                           Appeal__c, UW_EXCL_1__c, UW_EXCL_10__c, UW_EXCL_2__c, UW_EXCL_3__c, UW_EXCL_4__c, UW_EXCL_5__c, UW_EXCL_6__c, UW_EXCL_7__c, UW_EXCL_8__c, UW_EXCL_9__c,Remarks_to_Cigna_Underwriter__c,
                                           Presales_Result_Attribute__c,AUW_URL__c,LastModifiedDate,PreSales_Result_Msg__c from UW_Result__r order by createddate desc) from person_insured__c where id in :piIdsSet ]);
        **/
        List<New_policy__c> policyList = new List<New_policy__c>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            policyList.add(pis.piPolicy);
        }
        TMPolicyUtil.updateUWRelatedFieldsInPolicies(policyList);
        
        adjustUWRelatedFieldsForPolicyReplacement();//jack add for policy replacement 
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            //Person_insured__c piFromDB = piMap.get(pis.pi.id);
            //if(null != piFromDB && null != piFromDB.UW_Result__r && piFromDB.UW_Result__r.size() > 0){                
            pis.presalesResultMsgList = TMPolicyUtil.preSalesResultMsgBuild(pis.piPolicy.PreSales_Result_Msg__c);
            //pis.uwResult = piFromDB.UW_Result__r[0];
            pis.applicationId = pis.piPolicy.Application_Id__c;
            //add by jack for policy replacement
            for(TMEsalesHelper.PreSalesResultMessage preMsg4Display : pis.presalesResultMsgList){
                system.debug('preMsg4Display.message'+preMsg4Display.message);
                system.debug('preMsg4Display.message.contains('+preMsg4Display.message.contains('<br/>'));
                String tempMessageString = preMsg4Display.message;
                if(tempMessageString.contains('<br/>')){tempMessageString = tempMessageString.replace('<br/>', '');}
                system.debug('tempMessageString after remove br:'+tempMessageString);
                if(String.isNotBlank(pis.piPolicy.Referral_Exclusion_Reason__c)){
                    if(!pis.piPolicy.Referral_Exclusion_Reason__c.contains(tempMessageString)){
                        if(pis.piPolicy.Referral_Exclusion_Reason__c.endsWith(';')){
                            pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c + tempMessageString;
                        }else{
                            pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c + ';' + tempMessageString;
                        }
                    }
                }else{
                    pis.piPolicy.Referral_Exclusion_Reason__c = tempMessageString;
                }
            }
            //add by jack for policy replacement
            //Add by Andy for init reasonList 
            //pis.piPolicy.Referral_Exclusion_Reason__c = piFromDB.New_Policy__r.Referral_Exclusion_Reason__c; 
            system.debug('[TMCreatePolicyStep6Strategy] pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c);
            if(String.isNotBlank(pis.piPolicy.Referral_Exclusion_Reason__c)){
                pis.reasonList = pis.piPolicy.Referral_Exclusion_Reason__c.split(';');
            }else if(String.isBlank(pis.piPolicy.Referral_Exclusion_Reason__c)){
                pis.reasonList = new List<String>();
            }
            system.debug('[TMCreatePolicyStep6Strategy] reasonList'+pis.reasonList);
            //}            
        }
    }    
    
    private void adjustOverallResultByAnyconditions(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            System.debug('[TMCreatePolicyStep6Strategy] adjustOverallResultByAnyconditions().pis.piPolicy.UW_Overrall_Result__c='+pis.piPolicy.UW_Overrall_Result__c);
            System.debug('[TMCreatePolicyStep6Strategy] adjustOverallResultByAnyconditions().selectedProduct.product_code__c='+ptvs.ctrl.selectedProduct.product_code__c+' pis.pi.Benefit_lv_DP_SP_larger_than_MI__c='+pis.pi.Benefit_lv_DP_SP_larger_than_MI__c);
            //set overall result as 'Accepted' for those policies which do not need to go presales & auw
            if(pis.piValidationItem.needPresales == false && pis.piValidationItem.needAUW == false){
                pis.piPolicy.UW_Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED;
            }
            //add by jack for JR1829 begin
            if((pis.piPolicy.UW_Overrall_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED) && (pis.pi.Reason_for_PI_age_over_18__c == 'Others' || (pis.pi.Reason_for_PI_age_over_18__c == 'Full-time Student' && pis.pi.PI_Age__c > 25))){
                pis.piPolicy.UW_Overrall_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED;
            }
            //add by jack for JR1829 end
            //DPSP-975:  TMC50, TMCPU AUW requirement, Benefit level of DP/SP > Benefit level of MI? No -> then go with RB1 only, overall result = pre-sales result
            System.debug('[TMCreatePolicyStep6Strategy] adjustOverallResultByAnyconditions().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);
            if(('TMC50'.equals(ptvs.ctrl.selectedProduct.product_code__c) || 'TMCPU'.equals(ptvs.ctrl.selectedProduct.product_code__c)) && 'no'.equalsIgnoreCase(pis.pi.Benefit_lv_DP_SP_larger_than_MI__c)){
                pis.piPolicy.UW_Overrall_Result__c = pis.piPolicy.Pre_Sales_Result__c;
            }
            //if presales result is declined, over all result should be declined
            if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED.equals(pis.piPolicy.Pre_Sales_Result__c) ){
                pis.piPolicy.UW_Overrall_Result__c = pis.piPolicy.Pre_Sales_Result__c;
            }
            //if policy need to go presales but no need to go auw , over all result shouled be the same as presales result
            if(pis.piValidationItem.needPresales == true && pis.piValidationItem.needAUW == false){
                pis.piPolicy.UW_Overrall_Result__c = pis.piPolicy.Pre_Sales_Result__c;
            }
            //jack add for policy replacement
            System.debug('[TMCreatePolicyStep6Strategy] adjustOverallResultByAnyconditions() pis.piPolicy.isReplacement__c'+pis.piPolicy.isReplacement__c+'pis.piValidationItem.needAUW:'+pis.piValidationItem.needAUW);
            if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true && pis.piValidationItem.needAUW == false){
                system.debug('pis.piPolicy.Pre_Sales_Result__c'+pis.piPolicy.Pre_Sales_Result__c);
                pis.piPolicy.UW_Overrall_Result__c = pis.piPolicy.Pre_Sales_Result__c;
            }
            System.debug('[TMCreatePolicyStep6Strategy] adjustOverallResultByAnyconditions().pis.piPolicy.UW_Overrall_Result__c='+pis.piPolicy.UW_Overrall_Result__c);
        }
    }
    
    private void adjustPolicyStatusByPresalesResult(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED.equals(pis.piPolicy.Pre_Sales_Result__c)){
                pis.piPolicy.policy_status__c = 'Invalid';
            }
        }
    }
    //jack add for policy replacement
    public void adjustUWRelatedFieldsForPolicyReplacement(){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            system.debug('TMCreatePolicyStep6Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c); 
            system.debug('[TMCreatePolicyStep6Strategy] pis.piPolicy.isReplacement__c '+pis.piPolicy.isReplacement__c+' pis.piPolicy.Pre_Sales_Result__c:'+pis.piPolicy.Pre_Sales_Result__c);
            if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true && (pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED || pis.piPolicy.Pre_Sales_Result__c == null || pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED) ){
                pis.piPolicy.Pre_Sales_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED;
                system.debug('[TMCreatePolicyStep6Strategy] pis.piPolicy.UW_Result__c '+pis.piPolicy.UW_Result__c+' pis.piPolicy.Pre_Sales_Result__c:'+pis.piPolicy.Pre_Sales_Result__c);
                if(pis.piPolicy.UW_Result__c == null){
                    pis.piPolicy.UW_Overrall_Result__c = pis.piPolicy.Pre_Sales_Result__c;
                }else{
                    if( ( pis.piPolicy.UW_Result__c == 'Accepted' || pis.piPolicy.UW_Result__c.equalsIgnoreCase('Accepted with Exclusion') ) && pis.piPolicy.Pre_Sales_Result__c == 'Accepted'){
                        pis.piPolicy.UW_Overrall_Result__c = 'Accepted';
                    }else if(pis.piPolicy.UW_Result__c == 'Declined'){
                        pis.piPolicy.UW_Overrall_Result__c = 'Declined';
                    }else{
                        pis.piPolicy.UW_Overrall_Result__c = 'Referred';
                    }
                }    
            }
            system.debug('[TMCreatePolicyStep6Strategy] pis.piPolicy.Pre_Sales_Result__c:'+pis.piPolicy.Pre_Sales_Result__c+' pis.piPolicy.UW_Overrall_Result__c:'+pis.piPolicy.UW_Overrall_Result__c);
            if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true){
                if(String.isNotBlank(pis.piPolicy.Referral_Exclusion_Reason__c)){
                    system.debug('[TMCreatePolicyStep6Strategy] not blank');
                    List<String> tempList = pis.piPolicy.Referral_Exclusion_Reason__c.split(';');
                    pis.piPolicy.Referral_Exclusion_Reason__c = '';
                    Boolean havePolicyReplacementReason = false;
                    for(String temp : tempList){
                        if(temp == TMCreatePolicyStep4Strategy.POLICYREPLACEMENTREFFEREDREASON){havePolicyReplacementReason = true;}
                        pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c + temp +';';
                    }
                    if(!havePolicyReplacementReason){pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c + TMCreatePolicyStep4Strategy.POLICYREPLACEMENTREFFEREDREASON +';';}
                }else{
                    system.debug('[TMCreatePolicyStep6Strategy] blank');
                    pis.piPolicy.Referral_Exclusion_Reason__c = TMCreatePolicyStep4Strategy.POLICYREPLACEMENTREFFEREDREASON;
                    system.debug('TMCreatePolicyStep6Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c); 
                }
            }
        system.debug('TMCreatePolicyStep6Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c); 
        }
    }
    //jack add for policy replacement
}