/********************************************************************************
 * Apex Class Name - TMProductStrategyCI
 * Created Date - Sep 30, 2025
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Rancho          09/30/2025              Initial Version
 ********************************************************************************/
public abstract class TMProductStrategyCI extends TMproductStrategy{
    
    public String productCode;
    public Map<String, Integer> piSIMap;
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyCI(TMPolicyUtil.PolicyTransactionValidationStruct ptvs, String productCode){ 
        super();
        this.ptvs = ptvs;
        this.productCode = productCode;
        this.piSIMap = new Map<String, Integer>();
    }

    public override void discountValidation(){
        super.discountValidation(ptvs, productCode);
    }
    
    public virtual override void piValidation(){
        System.debug('TMProductStrategyCI.piValidation()');
        basePiValidation();
    }
    
    protected void basePiValidation(){
        System.debug('TMProductStrategyCI.basePiValidation()');
        super.piValidation(ptvs, productCode);
        validateAllPISumInsured();
        validateAllPISameProduct();
    }

    /**
     * Validate all PIs have the same product already submitted in current day
     * HKITSFDC_505_506
     */
    private void validateAllPISameProduct(){
        Set<String> piIdSet = new Set<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            piIdSet.add(pis.pi.Personal_ID__c);
        }
        List<Person_Insured__c> lstTodaySubmittedPI = [
            SELECT Id, Personal_ID__c  
            FROM Person_Insured__c 
            WHERE 
                Personal_ID__c IN :piIdSet 
                AND New_Policy__r.Policy_Transaction__r.Status__c = 'Completed' 
                AND New_Policy__r.Policy_Transaction__r.Submission_Date_Time__c = TODAY
                AND New_Policy__r.Product_Code__c IN ('CIB25','CIR25')
        ];
        Map<String, List<Person_Insured__c>> mapTodaySubmittedPI = new Map<String, List<Person_Insured__c>>();
        for(Person_Insured__c pi : lstTodaySubmittedPI){
            if(!mapTodaySubmittedPI.containsKey(pi.Personal_ID__c)){
                mapTodaySubmittedPI.put(pi.Personal_ID__c, new List<Person_Insured__c>());
            }
            mapTodaySubmittedPI.get(pi.Personal_ID__c).add(pi);
        }
        System.debug('mapTodaySubmittedPI: ' + mapTodaySubmittedPI);
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            // if otherValidation is already false, break same product checking
            if(!pis.piValidationItem.otherValidation){
                break;
            }
            // if there is already submitted PI(Same Personal_ID__c and Id) with same product today
            if(mapTodaySubmittedPI.containsKey(pis.pi.Personal_ID__c)){
                for (Person_Insured__c pi : mapTodaySubmittedPI.get(pis.pi.Personal_ID__c)) {
                    if(pi.Id != pis.pi.Id){
                        ptvs.ctrl.pageMsg = 'Duplicate submission, Please double check and follow up with customer';
                        pis.piValidationItem.otherValidation = false;
                        break;
                    }
                }
            }
        }
    }
    
    /**
     * Validate Sum Insured for all PIs
     */
    private void validateAllPISumInsured(){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            // if otherValidation is already false, skip sum insured checking
            if(!pis.piValidationItem.otherValidation || !validateSumInsuredForPI(pis)){
                break;
            }
        }
    }
    
    /**
     * Validate Sum Insured for a single PI
     * @param pis PersonInsuredStructure object
     * @return Boolean whether validation passes
     */
    private Boolean validateSumInsuredForPI(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        System.debug('TMProductStrategyCI.validateSumInsuredForPI() - PI: ' + pis.pi.Personal_ID__c);
        
        if(!validateBasicSumInsured(pis)){
            return false;
        }
        
        return validateAdvancedSumInsured(pis);
    }

    /**
     * Basic Sum Insured validation
     * @param pis PersonInsuredStructure object
     * @return Boolean whether validation passes
     */
    private Boolean validateBasicSumInsured(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        // Cannot be empty
        if(String.isBlank(pis.sumInsured)){
            ptvs.ctrl.pageMsg = 'You must enter a value in the required field';
            pis.piValidationItem.otherValidation = false;
            return false;
        }
        
        // Must be a valid number
        if(!TMPolicyUtil.isSafeStringToInteger(pis.sumInsured)){
            ptvs.ctrl.pageMsg = 'Sum Insured must be a valid integer';
            pis.piValidationItem.otherValidation = false;
            return false;
        }

        Integer tempSI = Integer.valueOf(pis.sumInsured);
        
        // Minimum value validation
        if(tempSI < 300000){
            ptvs.ctrl.pageMsg = 'Sum Insured must be greater than HKD300,000';
            pis.piValidationItem.otherValidation = false;
            return false;
        }
        
        // Thousand unit validation
        if(Math.mod(tempSI, 1000) != 0){
            ptvs.ctrl.pageMsg = 'Sum Insured have to input as a unit by thousand';
            pis.piValidationItem.otherValidation = false;
            return false;
        }
        
        return true;
    }
    
    /**
     * Advanced Sum Insured validation (including existing coverage check and limit calculation)
     * @param pis PersonInsuredStructure object
     * @return Boolean whether validation passes
     */
    private Boolean validateAdvancedSumInsured(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        Integer currentSI = Integer.valueOf(pis.sumInsured);
        Integer tempAge = (null != pis.pi.PI_Age__c ? Integer.valueOf(pis.pi.PI_Age__c) : null);
        
        Integer existingCISumInsured = getExistingCISumInsured(pis);
        piSIMap.put(pis.pi.Personal_ID__c, existingCISumInsured);
        System.debug('Existing CI Sum Insured: ' + pis.pi.Personal_ID__c + ' ' + existingCISumInsured);
        
        Integer maxAllowedSI = calculateMaxAllowedSumInsured(pis, tempAge, existingCISumInsured);
        System.debug('Max Allowed Sum Insured: ' + pis.pi.Personal_ID__c + ' ' + maxAllowedSI);
        
        return validateFinalSumInsuredLimit(pis, currentSI, maxAllowedSI);
    }
    
    /**
     * Validate final Sum Insured limit
     * @param pis PersonInsuredStructure object
     * @param currentSI current Sum Insured
     * @param maxAllowedSI maximum allowed Sum Insured
     * @return Boolean whether validation passes
     */
    private Boolean validateFinalSumInsuredLimit(TMCreatePolicyCtrl.PersonInsuredStructure pis, Integer currentSI, Integer maxAllowedSI){
        System.debug('current Sum Insured: ' + currentSI + ' currentSI <= maxAllowedSI: ' + (currentSI <= maxAllowedSI));
        if(currentSI <= maxAllowedSI){
            return true;
        }
        
        System.debug('sum insured exceeds limit');
        ptvs.ctrl.pageMsg = 'Inputted Sum Insured value are out of limitation, please double check';
        pis.piValidationItem.otherValidation = false;
        return false;
    }
    
    /**
     * Get existing CI Sum Insured (query from WS and SFDC)
     * @param pis PersonInsuredStructure object
     * @return Integer total existing CI Sum Insured
     */
    private Integer getExistingCISumInsured(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        Integer totalExistingSI = 0;
        Set<String> wsPolicyNoSet = new Set<String>();
        
        // get sum insured from WS
        if(null != pis.personalIDPolicylistFromWS && !pis.personalIDPolicylistFromWS.isEmpty()){
            for(HttpCalloutVO.Policy policy : pis.personalIDPolicylistFromWS){
                System.debug('existing policy: ' + policy.policyNumber + ' ' + policy.productCode + ' ' + policy.policyStatusDisplayName);
                if((policy.productCode == 'CIB25' || policy.productCode == 'CIR25') && policy.policyStatusDisplayName == 'Inforce'){
                    wsPolicyNoSet.add(policy.policyNumber);
                    try{
                        List<HttpCalloutVO.PolicyPersonCoverage> coverageList = ptvs.ctrl.policyCalloutHelper.getPolicyPersonCoverageBasic(policy.policyNumber, pis.pi.Personal_ID__c);
                        
                        if(coverageList != null && !coverageList.isEmpty()){
                            for(HttpCalloutVO.PolicyPersonCoverage coverage : coverageList){
                                // Check if it is a CI product and active
                                if((coverage.benefitCode == 'CIB25' || coverage.benefitCode == 'CIR25') && coverage.coverageIndicator == 'Base'){
                                    if(coverage.benefitAmountInNumber != null){
                                        totalExistingSI += Integer.valueOf(coverage.benefitAmountInNumber);
                                    }
                                }
                            }
                        }
                    } catch(Exception e){
                        System.debug('Error getting CI coverage from WS: ' + e.getMessage());
                        System.debug(e.getStackTraceString());
                    }
                }
            }
        }

        // get sum insured from SFDC
        System.debug('ws policy numbers: '+wsPolicyNoSet);
        for(Person_Insured__c pi : [SELECT Id, Personal_ID__c, New_Policy__r.Sum_Insured__c, New_Policy__r.Policy_No__c FROM Person_Insured__c WHERE Personal_ID__c = :pis.pi.Personal_ID__c AND New_Policy__r.Product_Code__c IN ('CIB25', 'CIR25') AND (New_Policy__r.Policy_Status__c = 'Completed' OR New_Policy__r.Policy_Status__c = 'Submitted') AND New_Policy__c != :pis.piPolicy.Id]){
            if(!wsPolicyNoSet.contains(pi.New_Policy__r.Policy_No__c) && pi.New_Policy__r.Sum_Insured__c != null){
                totalExistingSI += Integer.valueOf(pi.New_Policy__r.Sum_Insured__c);
            }
        }

        return totalExistingSI;
    }
    
    /**
     * Calculate maximum allowed Sum Insured
     * @param pis PersonInsuredStructure object
     * @param age age
     * @param existingSI existing Sum Insured
     * @return Integer maximum allowed Sum Insured
     */
    private Integer calculateMaxAllowedSumInsured(TMCreatePolicyCtrl.PersonInsuredStructure pis, Integer age, Integer existingSI){
        Integer baseMaxSI = getBaseMaxSumInsuredByAge(pis, age);
        Integer finalMaxSI = baseMaxSI - existingSI;
        System.debug('Final Max Sum Insured: ' + baseMaxSI + ' - ' + existingSI + ' = ' + finalMaxSI);
        return Math.max(0, finalMaxSI);
    }
    
    /**
     * Get base maximum Sum Insured by age
     * @param pis PersonInsuredStructure object
     * @param age age
     * @return Integer base maximum Sum Insured
     */
    private Integer getBaseMaxSumInsuredByAge(TMCreatePolicyCtrl.PersonInsuredStructure pis, Integer age){
        if(age < 18){
            return calculateChildMaxSumInsured(pis);
        } else if(age >= 18 && age <= 45){
            return 4000000;
        } else if(age > 45 && age <= 55){
            return 2500000;
        } else if(age > 55 && age <= 65){
            return 1000000;
        } else {
            return 0; // Over 65 years old not allowed to purchase
        }
    }
    
    /**
     * Calculate child maximum Sum Insured
     * @param pis PersonInsuredStructure object
     * @return Integer child maximum Sum Insured
     */
    private Integer calculateChildMaxSumInsured(TMCreatePolicyCtrl.PersonInsuredStructure pis){
        Integer childMaxSI = 2000000; // Default child maximum Sum Insured
        Integer wsParentSI = 0;

        if(String.isNotBlank(pis.parentPolicyNumber)){
            try{
                Boolean isParentInSameApplication = false;
                // check in current transaction
                if(ptvs.ctrl.amountOfPI > 1){
                    for(TMCreatePolicyCtrl.PersonInsuredStructure parentPis : ptvs.ctrl.personInsuredStructureList){
                        if(String.isNotBlank(parentPis.piPolicy.Policy_No__c) && (parentPis.piPolicy.Policy_No__c == pis.parentPolicyNumber)){
                            isParentInSameApplication = true;
                            wsParentSI += Integer.valueOf(parentPis.sumInsured);
                        }
                    }
                    System.debug('parent SI value in same transaction: ' + wsParentSI);
                }
                if(!isParentInSameApplication){
                    // check existing policy in SFDC
                    List<New_Policy__c> piList = [SELECT Id, Sum_Insured__c,Policy_No__c FROM New_Policy__c WHERE Policy_No__c = :pis.parentPolicyNumber AND Personal_ID__c = :pis.piPolicy.Personal_ID__c AND Product_Code__c IN ('CIB25', 'CIR25') AND (Policy_Status__c = 'Completed' OR Policy_Status__c = 'Submitted') LIMIT 1];
                    if(piList != null && !piList.isEmpty() && piList[0].Sum_Insured__c != null){
                        wsParentSI += Integer.valueOf(piList[0].Sum_Insured__c);
                    }else{
                        // check in WS
                        List<HttpCalloutVO.PolicyPersonCoverage> coverageList = ptvs.ctrl.policyCalloutHelper.getPolicyPersonCoverageBasic(pis.parentPolicyNumber, '');
                        if(coverageList != null && !coverageList.isEmpty()){
                            for(HttpCalloutVO.PolicyPersonCoverage coverage : coverageList){
                                if(String.isNotBlank(coverage.coverageIndicator) && coverage.coverageIndicator == 'Base'
                                && (coverage.benefitCode == 'CIB25' || coverage.benefitCode == 'CIR25')
                                && coverage.benefitAmountInNumber != null){
                                    System.debug('check holder id');
                                    List<HttpCalloutVO.Policy> tempPolList = ptvs.ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria(pis.parentPolicyNumber, '', '', '', '', '');
                                    if(null != tempPolList && !tempPolList.isEmpty() && tempPolList[0].holderSSN == pis.piPolicy.Personal_ID__c){
                                        wsParentSI += Integer.valueOf(coverage.benefitAmountInNumber);
                                    }
                                }
                            }
                        }
                    }
                }
            }catch(Exception e){
                System.debug('Error getting parent sum insured from WS: ' + e.getMessage());
            }
        }else if(String.isNotBlank(pis.pi.Parent_PI_ID__c)){
            
            System.debug('PI SI Map: '+piSIMap);
            System.debug('parent PI ID: '+pis.pi.Parent_PI_ID__c);

            if(ptvs.ctrl.amountOfPI > 1){
                for(TMCreatePolicyCtrl.PersonInsuredStructure parentPis : ptvs.ctrl.personInsuredStructureList){
                    if(String.isNotBlank(parentPis.pi.Personal_ID__c) && (parentPis.pi.Personal_ID__c == pis.pi.Parent_PI_ID__c)){
                        wsParentSI += Integer.valueOf(parentPis.sumInsured);
                    }
                }
                System.debug('parent SI value in same transaction: ' + wsParentSI);
            }
            
            if(piSIMap.containsKey(pis.pi.Parent_PI_ID__c)){
                wsParentSI += piSIMap.get(pis.pi.Parent_PI_ID__c);
            }else{
                // get sum insured from SFDC
                Set<String> wsPolicyNoSet = new Set<String>();
                for(Person_Insured__c pi : [SELECT Id, Personal_ID__c, New_Policy__r.Sum_Insured__c, New_Policy__r.Policy_No__c FROM Person_Insured__c WHERE Personal_ID__c = :pis.pi.Parent_PI_ID__c AND New_Policy__r.Product_Code__c IN ('CIB25', 'CIR25') AND (New_Policy__r.Policy_Status__c = 'Completed' OR New_Policy__r.Policy_Status__c = 'Submitted') AND New_Policy__c != :pis.piPolicy.Id]){
                    if(!wsPolicyNoSet.contains(pi.New_Policy__r.Policy_No__c) && pi.New_Policy__r.Sum_Insured__c != null){
                        wsPolicyNoSet.add(pi.New_Policy__r.Policy_No__c);
                        wsParentSI += Integer.valueOf(pi.New_Policy__r.Sum_Insured__c);
                    }
                }
                
                System.debug('ws SI value of parent PI ID: '+wsParentSI);
                System.debug('parent PI ws policy numbers: '+wsPolicyNoSet);

                // get sum insured from WS with parent PI ID
                List<HttpCalloutVO.Policy> parentPolicyList = ptvs.ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', pis.pi.Parent_PI_ID__c);
                if(parentPolicyList != null && !parentPolicyList.isEmpty()){
                    for(HttpCalloutVO.Policy policy : parentPolicyList){
                        if(!wsPolicyNoSet.contains(policy.policyNumber) && (policy.productCode == 'CIB25' || policy.productCode == 'CIR25') && policy.policyStatusDisplayName == 'Inforce'){
                            try{
                                List<HttpCalloutVO.PolicyPersonCoverage> coverageList = ptvs.ctrl.policyCalloutHelper.getPolicyPersonCoverageBasic(policy.policyNumber, '');
                                
                                if(coverageList != null && !coverageList.isEmpty()){
                                    for(HttpCalloutVO.PolicyPersonCoverage coverage : coverageList){
                                        if(coverage.insuredSSN == pis.pi.Parent_PI_ID__c
                                        && String.isNotBlank(coverage.coverageIndicator) && coverage.coverageIndicator == 'Base'
                                        && (coverage.benefitCode == 'CIB25' || coverage.benefitCode == 'CIR25')
                                        && coverage.benefitAmountInNumber != null){
                                            wsParentSI += Integer.valueOf(coverage.benefitAmountInNumber);
                                        }
                                    }
                                }
                            } catch(Exception e){
                                System.debug('Error getting CI coverage from WS: ' + e.getMessage());
                                System.debug(e.getStackTraceString());
                            }
                        }
                    }
                }
            }
        }
        System.debug('final child max SI: ' + wsParentSI);
        
        if(wsParentSI > childMaxSI){
            childMaxSI = wsParentSI;
        }
        
        return childMaxSI;
    }
    
    public override void transactionValidation(){
        super.transactionValidation(ptvs,productCode);
    }

}