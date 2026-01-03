public class TMProductStrategyCIR25 extends TMProductStrategyCI {
    
    public static final String productCode = 'CIR25';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyCIR25(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode);
        this.ptvs = ptvs;
    }

    public override void piValidation(){        
        basePiValidation();

        // CIR25 can only be applied to the person insured who has active policy
        Set<String> piIdSet = new Set<String>();
        Set<String> hkidWithSFDCPolicySet = new Set<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            piIdSet.add(pis.pi.Personal_ID__c);
        }
        for(Person_Insured__c np : [SELECT Id,Personal_ID__c FROM Person_Insured__c WHERE Personal_ID__c IN :piIdSet AND (New_Policy__r.Policy_Status__c='Completed' OR New_Policy__r.Policy_Status__c='Submitted') AND New_Policy__r.Product_Code__c!=:productCode AND New_Policy__r.Opportunity__c = :ptvs.ctrl.opportunityId]){
            hkidWithSFDCPolicySet.add(np.Personal_ID__c);
        }
        System.debug('current PI HKID set: ' + piIdSet);
        System.debug('HKID with SFDC policy set: ' + hkidWithSFDCPolicySet);

        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            // bypass below validation if already validated failed
            if(pis.piValidationItem.otherValidation){
                ptvs.ctrl.pageMsg = 'Bundle CI must be applied with medical policy';
                pis.piValidationItem.otherValidation = false;
                
                // check SFDC completed or submitted policy under the same opportunity
                if(hkidWithSFDCPolicySet.contains(pis.pi.Personal_ID__c)){
                    pis.piValidationItem.otherValidation = true;
                    continue;
                }

                // further check WS inforce policy
                List<HttpCalloutVO.Policy> plist = ptvs.ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', pis.pi.Personal_ID__c);
                if(null != plist && plist.size() > 0){
                    for(HttpCalloutVO.Policy p : plist){
                        if(p.productCode != 'CIR25' && p.policyStatusDisplayName == 'Inforce'){
                            pis.piValidationItem.otherValidation = true;
                            break;
                        }
                    }
                }
            }
        }
    }
}