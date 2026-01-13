/********************************************************************************
 * Apex Class Name - TMCreatePolicyStep4Strategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps 4
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 7.0       Ken             11/9/2018              Revise Version
 ********************************************************************************/
public class TMCreatePolicyStep4Strategy implements TMCreatePolicyStepStrategy{

    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMCreatePolicyStep4Strategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        this.ptvs = ptvs;
    }
    
    //jack add for policy replacement
    public static String POLICYREPLACEMENTREFFEREDREASON = 'Policy detected as replacement 保單被認定為 ”轉移保單”';

    public void stepInit(){
        //ptvs.ctrl.callPreSalesOnPage = true;
        ptvs.ctrl.isShowStep4Page = false;
        ptvs.ctrl.currentStep = preSalesAccepted(ptvs.ctrl)?ptvs.ctrl.currentStep+1:ptvs.ctrl.currentStep;
        System.debug('[TMCreatePolicyStep4Strategy] stepInit().isShowStep4Page:'+ptvs.ctrl.isShowStep4Page);
    }
    
    public Boolean stepValidation(){
        if(ptvs.ctrl.isSkipStep3){            
            return true;
        }else{
            if(checkBeneficiaryFieldNotNull(ptvs.ctrl.personInsuredStructureList, ptvs.ctrl.newPolicy)){                
                return true;
            }else{
                ptvs.ctrl.currentStep -= 1;
                ptvs.ctrl.canSave = false;
                return false;
            }
        }
    }
    
    public void nextStep(){
        if(stepValidation())
            stepInit();
    }
    
    private boolean checkBeneficiaryFieldNotNull(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList, New_Policy__c newPolicy){
        boolean notNull = true;
        String errorMsg = 'You must enter a value in the required field';
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            //if(productCode == '@SP100' && pis.pi.Insured_Type__c != 'PH = PI'){
            /**
            if(newPolicy.Product_Code__c == '@SP100' && pis.pi.Insured_Type__c != 'PH = PI'){
                for(TMCreatePolicyCtrl.BeneficiaryStruct bs : pis.beneficiaryList){
                    System.debug('>>>>>>>>>>>Beneficiary_Type__c:'+bs.beneficiary.Beneficiary_Type__c);
                    System.debug('>>>>>>>>>>>First_Name__c'+bs.beneficiary.First_Name__c);
                    System.debug('>>>>>>>>>>>Gender__c'+bs.beneficiary.Gender__c);
                    System.debug('>>>>>>>>>>>Last_Name__c+'+bs.beneficiary.Last_Name__c);
                    System.debug('>>>>>>>>>>>Percent__c+'+bs.beneficiary.Percent__c);
                    System.debug('>>>>>>>>>>>Person_ID__c+'+bs.beneficiary.Person_ID__c);
                    System.debug('>>>>>>>>>>>Relationship__c+'+bs.beneficiary.Relationship__c);
                    if(String.isEmpty(bs.beneficiary.Beneficiary_Type__c)
                       ||String.isEmpty(bs.beneficiary.First_Name__c)
                       ||String.isEmpty(bs.beneficiary.Last_Name__c)
                       ||null == bs.beneficiary.Percent__c
                       ||String.isEmpty(bs.beneficiary.Person_ID__c)
                       ||String.isEmpty(bs.beneficiary.Gender__c)
                       ||String.isEmpty(bs.beneficiary.Relationship__c)){                           
                           notNull = false;
                           break;
                    }
                }
                if(notNull){
                    if(!checkBeneficiaryPercent(pis)){
                        errorMsg = null;
                        notNull = false;
                    }                    
                }                
            }else{
                boolean isAllFieldNull = true;
                boolean isAllFieldFill = true;
                for(TMCreatePolicyCtrl.BeneficiaryStruct bs : pis.beneficiaryList){
                    if(String.isEmpty(bs.beneficiary.Beneficiary_Type__c)
                       ||String.isEmpty(bs.beneficiary.First_Name__c)
                       ||String.isEmpty(bs.beneficiary.Last_Name__c)
                       ||null == bs.beneficiary.Percent__c
                       ||String.isEmpty(bs.beneficiary.Person_ID__c)
                       ||String.isEmpty(bs.beneficiary.Gender__c)
                       ||String.isEmpty(bs.beneficiary.Relationship__c)){
                           isAllFieldFill = false;
                       }
                    if(String.isNotEmpty(bs.beneficiary.Beneficiary_Type__c)
                       ||String.isNotEmpty(bs.beneficiary.First_Name__c)
                       ||String.isNotEmpty(bs.beneficiary.Last_Name__c)
                       ||null != bs.beneficiary.Percent__c
                       ||String.isNotEmpty(bs.beneficiary.Person_ID__c)
                       ||String.isNotEmpty(bs.beneficiary.Gender__c)
                       ||String.isNotEmpty(bs.beneficiary.Relationship__c)){
                           isAllFieldNull = false;
                    }  
                }
                
                if(!(isAllFieldNull == true || isAllFieldFill == true)){
                    notNull = false;
                    errorMsg = 'Please complete all information about PI\'s beneficiary if you fill out some information';
                }
                
                if(!checkBeneficiaryPercent(pis)){
                    errorMsg = null;
                    notNull = false;
                }
            }
            
            if(!notNull){
                break;
            }
            **/
            if(!checkBeneficiaryPercent(pis)){
                errorMsg = null;
                notNull = false;
            }
        }
        
        if(notNull == false && null != errorMsg){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
        }
        
        return notNull;
    }
    
    private boolean checkBeneficiaryPercent(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        
        boolean canGo = true;
        Decimal sum = 0;
        //boolean needToFill = false;
        Integer nullCount = 0;
        System.debug('[TMCreatePolicyStep4Strategy] checkBeneficiaryPercent().pis.beneficiaryList.size():'+pis.beneficiaryList.size());
        for(TMCreatePolicyCtrl.BeneficiaryStruct bs : pis.beneficiaryList){
            if(null != bs.beneficiary.Percent__c){
                if(bs.beneficiary.Percent__c > 0){
                    sum += bs.beneficiary.Percent__c;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of percentage for each person insured should be 100.')); 
                    canGo = false;
                    break;
                }
                //needToFill = true;
            }else{
                nullCount++;
                //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>bs.beneficiary.Percent__c is null,but one field is filled, need to fill all');
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of percentage for each person insured should be 100.')); 
                //canGo = false;
            }
        }
        if(nullCount != pis.beneficiaryList.size()){
            if(sum<100){
                canGo = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of beneficiary\'s percentage should be 100 for each person insured.'));
            }else if(sum>100){
                canGo = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Percentage can not be more than 100'));
            }
        }
        
            
        return canGo;    
    }
    
    private boolean preSalesAccepted(TMCreatePolicyCtrl ctrl){
        //ctrl.callPreSalesOnPage = false;
        //initialize prePISSet by result of piValidation
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
            System.debug('[TMCreatePolicyStep4Strategy] preSalesAccepted() pis.piValidationItem.needPresales='+pis.piValidationItem.needPresales);
            if(pis.piValidationItem.needPresales == true){
                ctrl.prePISSet.add(pis.pi.id);
            }else{//if policy dont need to call presales, the uw result record also should be created
                /**
                if(null == pis.uwResult){                    
                    pis.uwResult = new UW_Result__c();
                    pis.uwResult.Person_Insured__c = pis.pi.id;
                    if(pis.uwResult.Policy__c == null){
                        pis.uwResult.Policy__c = pis.pi.New_Policy__c;
                    }
                    pis.uwResult.Product__c = newPolicy.Product__c;
                }
                **/
            }
        }
        System.debug('[TMCreatePolicyStep4Strategy] preSalesAccepted() ctrl.prePISSet='+ctrl.prePISSet);
        //If the necessary information has not changed(sex, height, weight and so on), dont need to call presale ws again.
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
            System.debug('preSales attribute: '+pis.piPolicy.Presales_Result_Attribute__c);
            if(ctrl.prePISSet.contains(pis.pi.id) && TMPolicyUtil.compare2Object(pis.piPolicy.Presales_Result_Attribute__c,pis.pi) ){
                // Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
                System.debug('sumInsured changed: '+pis.piPolicy.Sum_Insured__c+' -> '+pis.sumInsured);
                if(String.isNotBlank(pis.sumInsured) && null != pis.piPolicy.Sum_Insured__c && Integer.valueOf(pis.sumInsured) != Integer.valueOf(pis.piPolicy.Sum_Insured__c)){
                    break;
                }
                ctrl.prePISSet.remove(pis.pi.Id);
            }
            
            System.debug('[TMCreatePolicyStep4Strategy] preSalesAccepted().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);
            System.debug('TMCreatePolicyStep4Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c);
        }    
        System.debug('pi set: '+ctrl.prePISSet);
        
        preSales(ctrl);

        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
            system.debug('TMCreatePolicyStep4Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c);
            adjustForPolicyReplacement(pis,ctrl);//add by jack for policy replacement
            System.debug('[TMCreatePolicyStep4Strategy] preSalesAccepted().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);
        }

        boolean isAccepted = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
            System.debug('TMCreatePolicyStep4Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c);
            //adjustForPolicyReplacement(pis,ctrl);//add by jack for policy replacement
            System.debug('current pi: '+pis.pi.Personal_ID__c+' preSalesResult: '+pis.piPolicy.Pre_Sales_Result__c);
            if('Accepted'.equals(pis.piPolicy.Pre_Sales_Result__c) || null==pis.piPolicy.Pre_Sales_Result__c){
                isAccepted = true;
            }else{
                isAccepted = false;
                break;
            }                
        }
        if(isAccepted){
            ctrl.presalesAccepted = true;
            ctrl.isShowStep4Page = false;
        }else{
            ctrl.presalesAccepted = false;
            ctrl.isShowStep4Page = true;
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
                if(null == pis.presalesResultMsgList && null != pis.piPolicy.PreSales_Result_Msg__c){
                    pis.presalesResultMsgList = TMPolicyUtil.preSalesResultMsgBuild(pis.piPolicy.PreSales_Result_Msg__c);
                }
                if(pis.presalesResultMsgList != null){
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
                }
            }
        }
        
        System.debug('[TMCreatePolicyStep4Strategy] preSalesAccepted() after presales presalesAccepted='+ctrl.presalesAccepted);
        System.debug('[TMCreatePolicyStep4Strategy] preSalesAccepted() after presales isShowStep4Page='+ctrl.isShowStep4Page);
        
        return ctrl.presalesAccepted;
    }
    
    private void preSales(TMCreatePolicyCtrl ctrl){
        try{ 
            //To check whether parent HKID of PI which need to go presales has inforce policies in SFDC or from WS
            List<TMCreatePolicyCtrl.PersonInsuredStructure> tmpList = new List<TMCreatePolicyCtrl.PersonInsuredStructure>();
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
                if(ctrl.prePISSet.contains(pis.pi.id)){
                    tmpList.add(pis);
                }
            }
            Map<String,Boolean> PIIdHasInforcePolicyMap = TMPolicyUtil.getPIIdHasInforcePolicyMap(tmpList, ctrl.selectedProduct.Product_Code__c);
            //List<New_Policy__c> policyListToUpdate = new List<New_Policy__c>();
            System.debug('[TMCreatePolicyStep4Strategy] preSales().prePISSet='+ctrl.prePISSet);
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){                
                if(ctrl.prePISSet.contains(pis.pi.id)){
                    //TMPolicyUtil.preSales(pis, opp, newPolicy, this.productCode);                   
                    System.debug('[TMCreatePolicyStep4Strategy] preSales().pis'+pis);                     
                    TMPolicyUtil.preSales(pis, ctrl.cam, ctrl.newPolicy.Product_Code__c, ctrl.WSProduct, PIIdHasInforcePolicyMap.containsKey(pis.pi.Parent_PI_ID__c));
                    System.debug('[TMCreatePolicyStep4Strategy] preSales().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);
                    system.debug('[TMCreatePolicyStep4Strategy] preSales().pis.piPolicy.Application_Id__c='+pis.piPolicy.Application_Id__c);
                    //policyListToUpdate.add(pis.piPolicy);
                    //uwResultList.add(pis.uwResult);
                }/*else if(ctrl.showPolicyReplacement){// add by jack for policy replacement
                    System.debug('[TMCreatePolicyStep4Strategy] preSales().pis'+pis);                     
                    TMPolicyUtil.preSales(pis, ctrl.cam, ctrl.newPolicy.Product_Code__c, ctrl.WSProduct, PIIdHasInforcePolicyMap.containsKey(pis.pi.Parent_PI_ID__c));
                    System.debug('[TMCreatePolicyStep4Strategy] preSales().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);
                    system.debug('[TMCreatePolicyStep4Strategy] preSales().pis.piPolicy.Application_Id__c='+pis.piPolicy.Application_Id__c);
                }*/// add by jack for policy replacement
                else{
                    //uwResultList.add(pis.uwResult);
                    continue;
                }
            }
            //if(!policyListToUpdate.isEmpty()){
            if(!ctrl.prePISSet.isEmpty()){
                //upsert uwResultList;
                //upsert policyListToUpdate;
                ctrl.applicationId = ctrl.personInsuredStructureList[0].applicationId;
            }
            ctrl.prePISSet.clear();
        }catch(Exception e){
            ctrl.isWSError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ctrl.wsErrorMsg));
            System.debug('[TMCreatePolicyCtrl] preSales() error >>>>>>>'+e.getMessage());
            System.debug('[TMCreatePolicyCtrl] preSales() error >>>>>>>'+e.getLineNumber());
            System.debug('[TMCreatePolicyCtrl] preSales() error >>>>>>>'+e.getStackTraceString());
        }
    }
    //jack add for policy replacement
    private void adjustForPolicyReplacement(TMCreatePolicyCtrl.PersonInsuredStructure pis, TMCreatePolicyCtrl ctrl){
        system.debug('[TMCreatePolicyStep4Strategy] adjustForPolicyReplacement() ctrl.showPolicyReplacement '+ctrl.showPolicyReplacement+'pis.piValidationItem.needPresale: '+pis.piValidationItem.needPresales);
        system.debug('ctrl.showPolicyReplacement'+ctrl.showPolicyReplacement+' pis.piValidationItem'+pis.piValidationItem );
        
        if(ctrl.showPolicyReplacement && pis.piValidationItem.needPresales != null && !pis.piValidationItem.needPresales){
            pis.piPolicy.Pre_Sales_Result__c = null;
        }else if(ctrl.showPolicyReplacement && pis.piValidationItem.needPresales != null &&  pis.piValidationItem.needPresales){
            system.debug('adjustForPolicyReplacement() pis.piPolicy.Initial_Pre_Sales_Result__c'+pis.piPolicy.Initial_Pre_Sales_Result__c);
            pis.piPolicy.Pre_Sales_Result__c = pis.piPolicy.Initial_Pre_Sales_Result__c;
        }
        
        system.debug('[TMCreatePolicyStep4Strategy] adjustForPolicyReplacement() pis.piPolicy.Referral_Exclusion_Reason__c:' +pis.piPolicy.Referral_Exclusion_Reason__c);
        if(ctrl.showPolicyReplacement){
            String reason = POLICYREPLACEMENTREFFEREDREASON + ';';
            if(pis.piPolicy.Referral_Exclusion_Reason__c != null && !Test.isRunningTest()){
                // if(pis.piPolicy.Referral_Exclusion_Reason__c.contains(reason)){
                //     pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c.replace(reason,'');
                // }else if(pis.piPolicy.Referral_Exclusion_Reason__c.contains(POLICYREPLACEMENTREFFEREDREASON)){
                //     pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c.replace(POLICYREPLACEMENTREFFEREDREASON,'');
                // }
                pis.piPolicy.Referral_Exclusion_Reason__c = '';
            }
            //pis.piPolicy.Referral_Exclusion_Reason__c = null;
        }
        system.debug('[TMCreatePolicyStep4Strategy] adjustForPolicyReplacement() pis.piPolicy.Pre_Sales_Result__c '+pis.piPolicy.Pre_Sales_Result__c+'pis.piPolicy.Referral_Exclusion_Reason__c '+pis.piPolicy.Referral_Exclusion_Reason__c);
        system.debug('[TMCreatePolicyStep4Strategy] pis.piPolicy.isReplacement__c'+pis.piPolicy.isReplacement__c);
        //if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true && pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED  ){
        if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true && (pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED || pis.piPolicy.Pre_Sales_Result__c == null) ){
            pis.piPolicy.Pre_Sales_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED; 
        }
        if(pis.piPolicy.isReplacement__c != Null && pis.piPolicy.isReplacement__c == true){
            system.debug('[TMCreatePolicyStep4Strategy] pis.piPolicy.Pre_Sales_Result__c'+pis.piPolicy.Pre_Sales_Result__c);
            if(String.isNotBlank(pis.piPolicy.Referral_Exclusion_Reason__c)){
                system.debug('[TMCreatePolicyStep4Strategy] not blank');
                List<String> tempList = pis.piPolicy.Referral_Exclusion_Reason__c.split(';');
                pis.piPolicy.Referral_Exclusion_Reason__c = '';
                Boolean havePolicyReplacementReason = false;
                for(String temp : tempList){
                    if(temp == POLICYREPLACEMENTREFFEREDREASON){havePolicyReplacementReason = true;}
                    pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c + temp +';';
                }
                if(!havePolicyReplacementReason){pis.piPolicy.Referral_Exclusion_Reason__c = pis.piPolicy.Referral_Exclusion_Reason__c + POLICYREPLACEMENTREFFEREDREASON +';';}
            }else{
                system.debug('[TMCreatePolicyStep4Strategy] blank');
                pis.piPolicy.Referral_Exclusion_Reason__c = POLICYREPLACEMENTREFFEREDREASON;
                system.debug('TMCreatePolicyStep4Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c); 
            }
        }
        system.debug('TMCreatePolicyStep4Strategy pis.piPolicy.Referral_Exclusion_Reason__c'+pis.piPolicy.Referral_Exclusion_Reason__c); 
        
    }
    //jack add for policy replacement
}