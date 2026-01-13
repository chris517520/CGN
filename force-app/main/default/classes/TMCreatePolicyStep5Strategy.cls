/********************************************************************************
 * Apex Class Name - TMCreatePolicyStep5Strategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps 5
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMCreatePolicyStep5Strategy implements TMCreatePolicyStepStrategy{
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;    
    
    public TMCreatePolicyStep5Strategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        this.ptvs = ptvs;
    }
    
    public void stepInit(){
        //initialize uwPISSet by result of piValidation
        System.debug('[TMCreatePolicyStep5Strategy] stepInit().ptvs.ctrl.uwPISSet='+ptvs.ctrl.uwPISSet);
        system.debug('[TMCreatePolicyStep5Strategy] personInsuredStructureList.size()= '+ ptvs.ctrl.personInsuredStructureList.size());
        
        List<String> NoNeedAUWPolicy = new List<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            system.debug('[TMCreatePolicyStep5Strategy] stepInit() in the loop policy = ' + pis.piPolicy.policy_no__c);
            system.debug('[TMCreatePolicyStep5Strategy] stepInit() in the loop policy = ' + pis.piValidationItem.needAUW);
            if(pis.piValidationItem.needAUW == true){
                // both appeal yes and no in presales result referred case can go through auw
                System.debug('[TMCreatePolicyStep5Strategy] stepInit().pis.piPolicy.Pre_Sales_Result__c='+pis.piPolicy.Pre_Sales_Result__c);                
                if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED.equals(pis.piPolicy.Pre_Sales_Result__c) || TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED.equals(pis.piPolicy.Pre_Sales_Result__c)){
                    ptvs.ctrl.uwPISSet.add(pis.pi.id);
                }
                /**
                else if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED.equals(pis.uwResult.Presales_Result__c) && APPEAL_YES.equals(pis.piPolicy.Appeal__c) && ptvs.ctrl.prePISSet.contains(pis.pi.id)){
                    ptvs.ctrl.uwPISSet.add(pis.pi.id);
                }
                **/
            }else{
                system.debug('[TMCreatePolicyStep5Strategy] handle no need auw');
                NoNeedAUWPolicy.add(pis.piPolicy.Policy_No__c);
                pis.piPolicy.UW_Result__c = null;
                //pis.piPolicy.Referral_Exclusion_Reason_Long__c = null;
                pis.piPolicy.Referral_Exclusion_Reason__c = null;
            }          
        }
        if(!NoNeedAUWPolicy.isEmpty()){
            List<UW_Result__c> deleteUWResult = [SELECT Id FROM UW_Result__c WHERE Policy__r.Policy_No__c in :NoNeedAUWPolicy];
            if(!deleteUWResult.isEmpty())
                delete deleteUWResult;
        }
        System.debug('[TMCreatePolicyStep5Strategy] stepInit().ptvs.ctrl.uwPISSet='+ptvs.ctrl.uwPISSet);
        
        clearAppealForAll(ptvs.ctrl.personInsuredStructureList);//add by jack for policy replacement to clear the appeal questions 
        if(ptvs.ctrl.uwPISSet.isEmpty()){
            ptvs.ctrl.currentStep += 1;
            ptvs.ctrl.isAUWcompleted = true;
        }else{
            //clearAppealForUWPISet(ptvs.ctrl.personInsuredStructureList, ptvs.ctrl.uwPISSet);// PIs who need to go AUW again will be clear their appeal questions
            auw(ptvs.ctrl);
        }
        
    }
    
    public Boolean stepValidation(){
        
        Boolean appealIsEmpty = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if('Referred'.equals(pis.piPolicy.Pre_Sales_Result__c) && String.isEmpty(pis.piPolicy.Appeal__c)){
                appealIsEmpty = true;
                ptvs.ctrl.currentStep -= 1;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an option of the appeal question.'));
                break;
            }
        }
        
        return appealIsEmpty?false:true;
    }
    
    public void nextStep(){
        if(stepValidation())
            stepInit();
    }
    
    private void auw(TMCreatePolicyCtrl ctrl){
        ctrl.auwPIindex = 0;
        //Integer firstPIToUWIndex = 0;
        try{
            Set<String> policyIds = new Set<String>();
            system.debug('[TMCreatePolicyStep5Strategy] auw ctrl.personInsuredStructureList: '+ctrl.personInsuredStructureList);
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){ 
                system.debug('[TMCreatePolicyStep5Strategy] auw uwPISSet: '+ctrl.uwPISSet);
                if(ctrl.uwPISSet.contains(pis.pi.id)){
                    TMPolicyUtil.fullUnderwriting(pis, ctrl.cam);
                    ctrl.uwPISListForDisplay.add(pis);
                    ctrl.auwUrl = pis.auwURL;
                    ctrl.isAUWcompleted = false;
                    policyIds.add(pis.piPolicy.id);
                }else{
                    system.debug('[TMCreatePolicyStep5Strategy] auw else');
                    ctrl.isAUWcompleted = false;
                    pis.auwURL = pis.piPolicy.AUW_URL__c;
                    //firstPIToUWIndex ++;
                    continue;
                }                
            }
            List<UW_Result__c> uwResultListToDele = new List<UW_Result__c>();
            uwResultListToDele = [select id from UW_Result__c where policy__c in :policyIds];
            Database.DeleteResult[] DR_Dels = Database.delete(uwResultListToDele, true);
            System.debug('[TMCreatePolicyStep5Strategy] auw().DR_Dels = '+DR_Dels); 
            
        }catch(Exception e){
            ctrl.isWSError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ctrl.wsErrorMsg));
            System.debug('[TMCreatePolicyStep5Strategy] auw() error >>>>> '+e.getMessage());
            System.debug('[TMCreatePolicyStep5Strategy] auw() error >>>>> '+e.getLineNumber());
            System.debug('[TMCreatePolicyStep5Strategy] auw() error >>>>> '+e.getStackTraceString());
        }
        
        if(!ctrl.isAUWcompleted){
            while(!ctrl.uwPISSet.isEmpty() && !ctrl.uwPISSet.contains(ctrl.personInsuredStructureList.get(ctrl.auwPIindex).pi.id)){
                ++ctrl.auwPIindex;
            }
            ctrl.piName = ctrl.personInsuredStructureList[ctrl.auwPIindex].pi.Insured_Last_Name__c + ctrl.personInsuredStructureList[ctrl.auwPIindex].pi.Insured_First_Name__c;
            ctrl.auwUrl = ctrl.personInsuredStructureList[ctrl.auwPIindex].auwURL;
            ctrl.applicationId = ctrl.personInsuredStructureList[ctrl.auwPIindex].piPolicy.Application_Id__c;
            ctrl.lastModifiedDate = ctrl.personInsuredStructureList[ctrl.auwPIindex].uwResultLastModifiedDate;
            
            //lastModifiedDate = personInsuredStructureList[auwPIindex].uwResult.lastmodifieddate.format();
        }
        if(String.isEmpty(ctrl.auwUrl)){
            ctrl.isWSError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ctrl.wsErrorMsg));
        }
        system.debug('[TMCreatePolicyStep5Strategy] auw().piName=' + ctrl.piName);
        system.debug('[TMCreatePolicyStep5Strategy] auw().auwUrl=' + ctrl.auwUrl);
        system.debug('[TMCreatePolicyStep5Strategy] auw().applicationId=' + ctrl.applicationId);
    }
    /**
    private String checkAppeal(List<TMCreatePolicyCtrl.PersonInsuredStructure> piList, Policy_transaction__c policyTransaction){
          
        String checkAppeal = '';
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : piList){
            System.debug('>>>>>>>>>>>>>>>>>>>pis.piPolicy.Appeal__c='+pis.piPolicy.Appeal__c);
            if(String.isBlank(pis.piPolicy.Appeal__c)){
                checkAppeal = NULL_APPEAL;
            }else if('Accept'.equals(pis.piPolicy.Appeal__c)){
                policyTransaction.Status__c = 'Completed';            
                checkAppeal = APPEAL_NO;            
            }else if('Appeal'.equals(pis.piPolicy.Appeal__c)){
                checkAppeal = APPEAL_YES;
            }
        }
        
        return checkAppeal;
    }
    **/
    private void clearAppealForUWPISet(List<TMCreatePolicyCtrl.PersonInsuredStructure> piList, Set<String> uwPISSet){
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : piList){
            if(uwPISSet.contains(pis.pi.id)){
                pis.piPolicy.Appeal_For_UW_Result__c = TMCreatePolicyCtrl.APPEAL_NO;//appeal default to no
            }
        }
    }

    //add by jack for policy replacement to clear the appeal questions 
    private void clearAppealForAll(List<TMCreatePolicyCtrl.PersonInsuredStructure> piList){
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : piList){
            pis.piPolicy.Appeal_For_UW_Result__c = TMCreatePolicyCtrl.APPEAL_NO;//appeal default to no
            system.debug('clearAppealForAll pis.piPolicy.Appeal_For_UW_Result__c:'+pis.piPolicy.Appeal_For_UW_Result__c);
        }
    }
    //add by jack for policy replacement to clear the appeal questions 
}