/********************************************************************************
 * Apex Class Name - TMProductStrategyVHIS
 * Created Date - Jan 15, 2019
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Manuel          15/01/2019              Revise Version
 ********************************************************************************/
 
public abstract class TMProductStrategyVHIS extends TMProductStrategy{

    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    public string productCode;
    
    public TMProductStrategyVHIS(TMPolicyUtil.PolicyTransactionValidationStruct ptvs, string productCode){
        super();
        this.ptvs = ptvs;
        this.productCode = productCode;
    }
    
    public override void discountValidation(){
        super.discountValidation(ptvs,productCode);
        childOfferDiscountValidation();
        childGroupOfferDiscountValidation();
        kidsOfferDiscountValidation();
        spouseOfferDiscountValidation();
    }
    
    public override void piValidation(){
        super.piValidation(ptvs,productCode);
    }
    
    public override void transactionValidation(){
        super.transactionValidation(ptvs,productCode);
    }
    
    /*
     * VHIS product
     * Discount offer to child
    */
    public void childOfferDiscountValidation(){
        List<String> lstPolicyHolderAsPersonInsured = new List<String>();
        List<String> lstSpouseAsPersonInsured = new List<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.Insured_Type__c=='PH = PI'||'Policy Holder'.equals(pis.pi.Relationship__c)){
                lstPolicyHolderAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
            if(pis.pi.Insured_Type__c=='Spouse'||'Spouse'.equals(pis.pi.Relationship__c)){
                lstSpouseAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
        }
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.availableDiscountMap.containsKey('CHILD DISCOUNT*')){
                pis.availableDiscountMap.put('CHILD DISCOUNT*',false);
                if(pis.pi.PI_Age__c<18&&('Son'.equals(pis.pi.Relationship__c)||'Daughter'.equals(pis.pi.Relationship__c))&&null!=pis.pi.Parent_PI_ID__c){
                    if(lstPolicyHolderAsPersonInsured.size()>0||lstSpouseAsPersonInsured.size()>0){
                        pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                    }else{
                    
                        if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                            //JL20211206 List<New_policy__c> parentPolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Parent_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG')];
                            List<New_policy__c> parentPolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Parent_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG' or product_code__c = 'VSPWG' )];
                            if(null != parentPolicies && parentPolicies.size() > 0){
                                pis.availableDiscountMap.put('CHILD DISCOUNT*', true);
                            }
                        }
                    
                        for(HttpCalloutVO.Policy p : ptvs.ctrl.PHPersonalIDPolicylist){
                            //JL20211206 if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                            if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG'||p.productCode=='VSPWG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                                pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     * VHIS product
     * Discount offer to child group
    */
    public void childGroupOfferDiscountValidation(){
        List<String> lstPolicyHolderAsPersonInsured = new List<String>();
        List<String> lstSpouseAsPersonInsured = new List<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.Insured_Type__c=='PH = PI'||'Policy Holder'.equals(pis.pi.Relationship__c)){
                lstPolicyHolderAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
            if(pis.pi.Insured_Type__c=='Spouse'||'Spouse'.equals(pis.pi.Relationship__c)){
                lstSpouseAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
        }
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.availableDiscountMap.containsKey('GROUP DISCOUNT (CHILD)')){
                pis.availableDiscountMap.put('GROUP DISCOUNT (CHILD)',false);
                if(pis.pi.PI_Age__c<18&&('Son'.equals(pis.pi.Relationship__c)||'Daughter'.equals(pis.pi.Relationship__c))&&null!=pis.pi.Parent_PI_ID__c){
                    if(lstPolicyHolderAsPersonInsured.size()>0||lstSpouseAsPersonInsured.size()>0){
                        pis.availableDiscountMap.put('GROUP DISCOUNT (CHILD)',true);
                    }else{
                    
                        if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                            //JL20211206 List<New_policy__c> parentPolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Parent_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG')];
                            List<New_policy__c> parentPolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Parent_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG' or product_code__c = 'VSPWG')];
                            if(null != parentPolicies && parentPolicies.size() > 0){
                                pis.availableDiscountMap.put('GROUP DISCOUNT (CHILD)', true);
                            }
                        }
                    
                        for(HttpCalloutVO.Policy p : ptvs.ctrl.PHPersonalIDPolicylist){
                            //JL20211206 if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                            if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG'||p.productCode=='VSPWG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                                pis.availableDiscountMap.put('GROUP DISCOUNT (CHILD)',true);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     * VHIS product
     * Discount offer to kids
    */
    public void kidsOfferDiscountValidation(){
        List<String> lstPolicyHolderAsPersonInsured = new List<String>();
        List<String> lstSpouseAsPersonInsured = new List<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.Insured_Type__c=='PH = PI'||'Policy Holder'.equals(pis.pi.Relationship__c)){
                lstPolicyHolderAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
            if(pis.pi.Insured_Type__c=='Spouse'||'Spouse'.equals(pis.pi.Relationship__c)){
                lstSpouseAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
        }
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.availableDiscountMap.containsKey('KIDS DISCOUNT')){
                pis.availableDiscountMap.put('KIDS DISCOUNT',false);
                if(pis.pi.PI_Age__c<18&&('Son'.equals(pis.pi.Relationship__c)||'Daughter'.equals(pis.pi.Relationship__c))&&null!=pis.pi.Parent_PI_ID__c){
                    if(lstPolicyHolderAsPersonInsured.size()>0||lstSpouseAsPersonInsured.size()>0){
                        pis.availableDiscountMap.put('KIDS DISCOUNT',true);
                    }else{
                    
                        if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                            //JL20211206 List<New_policy__c> parentPolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Parent_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG')];
                            List<New_policy__c> parentPolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Parent_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG' or product_code__c = 'VSPWG')];
                            if(null != parentPolicies && parentPolicies.size() > 0){
                                pis.availableDiscountMap.put('KIDS DISCOUNT', true);
                            }
                        }
                        
                        for(HttpCalloutVO.Policy p : ptvs.ctrl.PHPersonalIDPolicylist){
                            //JL20211206 if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                            if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG'||p.productCode=='VSPWG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                                pis.availableDiscountMap.put('KIDS DISCOUNT',true);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     * VHIS product
     * Discount offer to spouse
    */
    public void spouseOfferDiscountValidation(){
        
        List<String> lstPolicyHolderAsPersonInsured = new List<String>();
        List<String> lstSpouseAsPersonInsured = new List<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.Insured_Type__c=='PH = PI'||'Policy Holder'.equals(pis.pi.Relationship__c)){
                lstPolicyHolderAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
            if(pis.pi.Insured_Type__c=='Spouse'||'Spouse'.equals(pis.pi.Relationship__c)){
                lstSpouseAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
        }
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.availableDiscountMap.containsKey('SPOUSE DISCOUNT')){
                pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                if('PH = PI'.equals(pis.pi.Insured_Type__c) || pis.pi.Insured_Type__c=='Spouse'){
                    pis.availableDiscountMap.put('SPOUSE DISCOUNT', true);
                    /*if(lstPolicyHolderAsPersonInsured.size()>0&&lstSpouseAsPersonInsured.size()>0){
                        pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                    }else{
                        if(String.isNotEmpty(pis.pi.Spouse_PI_ID__c)){
                            List<New_policy__c> spousePolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Spouse_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG')];
                            if(null != spousePolicies && spousePolicies.size() > 0){
                                pis.availableDiscountMap.put('SPOUSE DISCOUNT', true);
                            }
                        }
                        for(HttpCalloutVO.Policy p : ptvs.ctrl.PHPersonalIDPolicylist){
                            if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                                pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                                break;
                            }
                        }
                    }*/
                }
            }
        }
        
    
        /*
        List<String> lstPolicyHolderAsPersonInsured = new List<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.Insured_Type__c=='PH = PI'||'Policy Holder'.equals(pis.pi.Relationship__c)){
                lstPolicyHolderAsPersonInsured.add(pis.pi.Personal_ID__c);
            }
        }
        boolean dosePolicyHolderNeedDiscount = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.availableDiscountMap.containsKey('SPOUSE DISCOUNT')){
                pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                if(pis.pi.Insured_Type__c=='Spouse'){
                    if(lstPolicyHolderAsPersonInsured.size()>0){
                        dosePolicyHolderNeedDiscount = true;
                        pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                    }else{
                        
                        if(String.isNotEmpty(pis.pi.Spouse_PI_ID__c)){
                            List<New_policy__c> spousePolicies = [select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c = :pis.pi.Spouse_PI_ID__c) and (policy_status__c = 'Completed' or policy_status__c = 'Submitted') and (product_code__c = :productCode or product_code__c = 'VSTDG' or product_code__c = 'VSMMG' or product_code__c = 'VSUPG')];
                            if(null != spousePolicies && spousePolicies.size() > 0){
                                pis.availableDiscountMap.put('SPOUSE DISCOUNT', true);
                            }
                        }

                        for(HttpCalloutVO.Policy p : ptvs.ctrl.PHPersonalIDPolicylist){
                            if((p.productCode=='VSTDG'||p.productCode=='VSMMG'||p.productCode=='VSUPG')&&(p.policyStatusDisplayName=='Inforce'||p.policyStatusDisplayName=='生效')){
                                pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                                break;
                            }
                        }
                    }
                }
            }
        }
        if(dosePolicyHolderNeedDiscount){
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                if('PH = PI'.equals(pis.pi.Insured_Type__c)||'Policy Holder'.equals(pis.pi.Relationship__c)){
                    pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                }
            }
        }
        */
        
    }
    
}