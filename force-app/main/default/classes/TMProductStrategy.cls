/********************************************************************************
 * Apex Class Name - TMProductStrategy
 * Created Date - Apr 23, 2018
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 * 10.1       Jinni Liang     22/06/2020              JR1825 - 
 *                                                    1.Duplicate sell control enhancment
 *                                                    2.Not allow to buy CI product at the same day
 ********************************************************************************/
public abstract class TMProductStrategy{    
    public List<TMCreatePolicyCtrl.PersonInsuredStructure> piList;
    public Set<String> groupProductCode;   
    public Set<String> groupProductCode2;   
    //Add by Manuel for VHIS products
    public Set<String> groupProductCode3;
    /*Add by Andy Li for ROP Revamp start*/
    public Set<String> groupProductCode4;
    public Set<String> groupProductCode5;
    /*Add by Andy Li for ROP Revamp end*/   
  
    //JL20200622 - Start - Add for JR1825 - It is for CI product same day control
    public Set<String> groupProductCode6;
    //JL20200622 - End    
    public Map<String, String> insuredTypeConversionMap;    
    //Double check with Chapin/Connie should be @DMBG  + DPSP-657 : isolate TMC50, TMCPU to have same child AUW result handling as @DMBG
    //public static String adjustChildOverallResultExceptProductcode = '@DMBG;TMC50;TMCPU'; 
    public static String adjustChildOverallResultProductCode='TUPG;TUSG;TUWG';      
    public static String specificGAChannelCode='113,114,147';
    // Rancho_HKITSFDC351_20250827
    public List<String> discountCodeList = new List<String>{'YR1 17% & YR2 UP TO 51% DISCOUNT', 'YR1 17% YR2 58% YR3 25% DISCOUNT'};
    public List<String> vhisProdCodeList = new List<String>{'VSUPG', 'VSPWG'};
    public List<String> eliteProdCodeList = new List<String>{'NELG2', 'NESG2'};
    
    public TMproductStrategy(){
        groupProductCode=new Set<String>();
        groupProductCode.add('PMGH');
        groupProductCode.add('DMBG');
        groupProductCode.add('NELG');
        groupProductCode.add('NESG');
        groupProductCode.add('@PMGH');
        groupProductCode.add('@DMBG');
        groupProductCode.add('@NELG');
        groupProductCode.add('@NESG');     
          
        groupProductCode2=new Set<String>();
        groupProductCode2.add('TUPG');
        groupProductCode2.add('TUSG');
        groupProductCode2.add('TUWG');     
          
        //Add by Manuel for VHIS products
        groupProductCode3=new Set<String>();
        groupProductCode3.add('VSTDG');
        groupProductCode3.add('VSMMG');
        groupProductCode3.add('VSUPG');
        groupProductCode3.add('VSPWG');
        
        /*Add by Andy Li for ROP Revamp start*/
        groupProductCode4=new Set<String>();
        groupProductCode4.add('RSM');
        groupProductCode4.add('RSPH');
        groupProductCode4.add('RSPHS');
        groupProductCode4.add('RSPHG');
        groupProductCode4.add('RSPU');
        groupProductCode4.add('RSPUS');
        groupProductCode4.add('RSPSG');    
        
        groupProductCode5 = new Set<String>();
        groupProductCode5.add('@KIDSG');
        groupProductCode5.add('@KIDSL');
        groupProductCode5.add('KIDSG');
        groupProductCode5.add('KIDSL');
        /*Add by Andy Li for ROP Revamp end*/
        
        //JL20200622 - Start - Add for JR1825 - CI product control
        groupProductCode6 = new Set<String>();
        groupProductCode6.add('15R6L');
        groupProductCode6.add('25R6L');
        groupProductCode6.add('15C1L');
        groupProductCode6.add('15C6L');
        groupProductCode6.add('15C8L');
        groupProductCode6.add('25C1L'); 
        groupProductCode6.add('25C6L');
        groupProductCode6.add('25C8L');
        groupProductCode6.add('SCIL');
        groupProductCode6.add('SCIY');
        groupProductCode6.add('TMC50');
        groupProductCode6.add('TMCPU');        
        //JL20200622 - End
        
        insuredTypeConversionMap=new Map<String,String>();
        insuredTypeConversionMap.put('PH = PI','MI');
        insuredTypeConversionMap.put('Spouse','SP');
        insuredTypeConversionMap.put('Dependent','DP');
    }
    
    public TMproductStrategy(List<TMCreatePolicyCtrl.PersonInsuredStructure> piList){
        this();
        this.piList=piList;
    }
        
    public abstract void discountValidation();   
    public abstract void piValidation();   
    public abstract void transactionValidation();
    
    //Overload
    public void discountValidation(TMPolicyUtil.PolicyTransactionValidationStruct ptvs, String productCode){
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
        
        Integer eligiblePICount = 0;// Rancho_HKITSFDC351_20250827 - WOW campaign discount code
        //DPSP-992 : Please remove the "SP Discount" validation for all products, but only apply Spouse Discount for PH = PI or Spouse
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.availableDiscountMap.containsKey('SPOUSE DISCOUNT')){
                if(!'PH = PI'.equals(pis.pi.Insured_Type__c) && !'Spouse'.equals(pis.pi.Insured_Type__c)){
                    pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                }
            }
            // only apply Child Discount for pi age < 18
            if(pis.availableDiscountMap.containsKey('CHILD DISCOUNT*')){
                if(pis.pi.PI_Age__c>=18){
                    pis.availableDiscountMap.put('CHILD DISCOUNT*',false);
                }
            }

            // Rancho_HKITSFDC272_20250611 - hide discount 59 if no deductible
            if(pis.availableDiscountMap.containsKey('SPECIAL 2ND & 3RD YR DISCOUNT')){
                System.debug('current selected product code: '+productCode);
                System.debug('benefit level: '+pis.pi.Benefit_Level__c);
                if(('VSUPG'.equals(productCode) || 'VSPWG'.equals(productCode)) && pis.pi.Benefit_Level__c == '1'){
                    pis.availableDiscountMap.put('SPECIAL 2ND & 3RD YR DISCOUNT',false);
                }
            }

            // Rancho_HKITSFDC351_20250827 - WOW campaign discount code
            if(!bypassValidation && (vhisProdCodeList.contains(productCode) || eliteProdCodeList.contains(productCode))){
                if(vhisProdCodeList.contains(productCode) && pis.pi.Benefit_Level__c != '1'){
                    eligiblePICount++;
                }
                
                for(String discountCode : discountCodeList){
                    System.debug('current selected product code: '+productCode);
                    System.debug('benefit level: '+pis.pi.Benefit_Level__c);
                    // discount code for VSUPG & VSPWG not eligible if no deductible
                    if(pis.availableDiscountMap.containsKey(discountCode) && vhisProdCodeList.contains(productCode) && pis.pi.Benefit_Level__c == '1'){
                        pis.availableDiscountMap.put(discountCode,false);
                    }else if(pis.availableDiscountMap.containsKey(discountCode) && eliteProdCodeList.contains(productCode)){
                        // discount 78 is family discount, not eligible for standalone policy
                        if(ptvs.ctrl.amountOfPI == 1 && discountCode == discountCodeList[1]){
                            pis.availableDiscountMap.put(discountCode,false);
                        // discount 76 is single discount, not eligible for multi-policy
                        }else if(ptvs.ctrl.amountOfPI > 1 && discountCode == discountCodeList[0]){
                            pis.availableDiscountMap.put(discountCode,false);
                        }
                    }
                }   
            }
            System.debug('current available discount map: '+pis.availableDiscountMap);
        }

        System.debug('eligiblePICount: '+eligiblePICount);
        if(!bypassValidation && eligiblePICount > 0){
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                for(String discountCode : discountCodeList){
                    if(pis.availableDiscountMap.containsKey(discountCode)){
                        if(eligiblePICount == 1 && discountCode == discountCodeList[1]){
                            pis.availableDiscountMap.put(discountCode,false);
                        }else if(eligiblePICount > 1 && discountCode == discountCodeList[0]){
                            pis.availableDiscountMap.put(discountCode,false);
                        }
                    }
                }
                System.debug('available discount map: '+pis.availableDiscountMap);
            }
        }
    }
        
    //Overload
    public void piValidation(TMPolicyUtil.PolicyTransactionValidationStruct ptvs,String productCode){
        system.debug('[TMProductStrategy] piValidation productCode >> '+productCode);
        Policy_Validation_Checking__c pvc = [select Duplicate_Policy_Checking__c,Post_Duplication_Checking__c,AUW__c,BMI__c,Smoking__c,Product_Code__c,UW_Requirement__c from Policy_Validation_Checking__c where Product_Code__c = :productCode limit 1];
        System.debug('[TMProductStrategy] piValidation().pvc='+pvc);
        if(null!=ptvs){
            //PI inforcePolicies in SFDC preparation
            Map<String,List<Person_insured__c>> piPersonalIdPIPolicyListMap = getPiPersonalIdPIPolicyListMap(ptvs.ctrl.personInsuredStructureList, productCode, pvc.Duplicate_Policy_Checking__c);            
            List<GA_Product_Validation_Checking__c> GAProductValidationCheckingTable = getGAProductValidationCheckingTable();
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){                
                // rest flag
                pis.piValidationItem.otherValidation=true;
                pis.piValidationItem.isDuplicate=false;
                
                // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
                if(('BUNDLE DISCOUNT'.equals(pis.discount1) && 'LOYALTY DISCOUNT'.equals(pis.discount2)) || ('BUNDLE DISCOUNT'.equals(pis.discount2) && 'LOYALTY DISCOUNT'.equals(pis.discount1))){
                    pis.piValidationItem.otherValidation=false;
                }
                
                //SPS-333
                system.debug('>>> Relationship checking: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                if(ptvs.ctrl.currentStep>TMCreatePolicyCtrl.STEP_PHPI_INFORMATION && String.isBlank(pis.pi.Relationship__c)){
                    pis.piValidationItem.otherValidation=false;
                    ptvs.ctrl.currentStep=TMCreatePolicyCtrl.STEP_PHPI_INFORMATION;
                    ptvs.ctrl.policyTransaction.Number_of_Person_Insured__c=ptvs.ctrl.personInsuredStructureList.size();
                    break;
                }
                //SPS-333
                
                 /**
                 * SSN Check add by kermit
                 * when PI = PH , PI.SSN <> PH.SSN , validate fail
                 * when PI <> PH , PI.SSN = PH.SSN , validate fail
                 */
                system.debug('>>> SSN Check: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                if(!pis.pi.Relationship__c.equals('Policy Holder') && pis.pi.Personal_ID__c!=null && pis.pi.Personal_ID__c.equals(ptvs.ctrl.newPolicy.Personal_ID__c)){//SPS-681 jack add
                    pis.piValidationItem.otherValidation=false;
                }else if(pis.pi.Relationship__c.equals('Policy Holder') &&  pis.pi.Personal_ID__c!=null && !pis.pi.Personal_ID__c.equals(ptvs.ctrl.newPolicy.Personal_ID__c)){//SPS-681 jack add
                    pis.piValidationItem.otherValidation=false;
                }
                
                // EligibleAge checking for all product
                // Age checking to both basic plan and optional rider for each product, PI age outside the range is not allowed to create policy
                system.debug('>>> EligibleAge checking pis.pi.Benefit_Level__c: ' + pis.pi.Benefit_Level__c);
                system.debug('>>> EligibleAge checking pis.pi.Rider__c: ' + pis.pi.Rider__c);
                system.debug('>>> EligibleAge checking pis.selectedRidersMap: ' + pis.selectedRidersMap);
                system.debug('>>> benefitMap: ' + ptvs.ctrl.benefitMap);
                //system.debug('>>> PI Age: ' + pis.pi.PI_Age__c);
                //system.debug('>>> Insured Type: ' + pis.pi.Insured_Type__c);
                system.debug('>>> EligibleAge checking: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                String insuredType=pis.pi.Insured_Type__c;
                if(insuredType=='PH = PI'){
                    insuredType='Owner';
                }

                // Rancho_FullTimeStudent_20240807 - elite 360 allows dependent's age > 18 for full time student
                Boolean bypassAgeCheck = TMPolicyUtil.checkFullTimeStudent(productCode, pis.pi.PI_Age__c, pis.pi.Reason_for_PI_age_over_18__c);
                
                HttpCalloutVO.Benefit ben = ptvs.ctrl.benefitMap.get(pis.pi.Benefit_Level__c);
                if(ben!=null && !bypassAgeCheck){
                    for(HttpCalloutVO.EligibleAge age : ben.eligibleAgeList){                        
                        if(insuredType==age.RelationRoleCode){
                            system.debug('[TMProductStrategy] piValidation() MinAgeYear >>> '+age.MinAgeYear);
                            Integer days = pis.pi.Date_of_Birth__c.daysBetween(date.today())+1;
                            system.debug('[TMProductStrategy] piValidation() MaxAgeYear >>> '+age.MaxAgeYear);
                            //change by jack for JR1829
                            // if(PIS.pi.Relationship__c=='Policy Holder' || PIS.pi.Relationship__c=='Spouse' || productCode=='VSMMG' || productCode == 'VSUPG' || productCode == 'VSTDG' || age.MaxAgeYear < 17){
                            if(pis.pi.PI_Age__c >= 0 && ( (age.MaxAgeYear != null && pis.pi.PI_Age__c > age.MaxAgeYear) || (age.MinAgeYear != null &&  pis.pi.PI_Age__c < age.MinAgeYear) )){ 
                                pis.piValidationItem.otherValidation=false;
                            } else if( (age.MaxAgeDay != null && days>age.MaxAgeDay) || (age.MinAgeDay!=null && days<age.MinAgeDay)){
                                pis.piValidationItem.otherValidation=false;
                            } else if((null==age.MaxAgeDay || age.MaxAgeDay==0) && age.MaxAgeYear==0){
                                pis.piValidationItem.otherValidation=false;
                            }
                            System.debug('basic plan age check result:'+pis.piValidationItem.otherValidation);
                            // }
                            // else{
                                //if(pis.pi.PI_Age__c >= 0 && ( (age.MaxAgeYear != null && pis.pi.PI_Age__c > age.MaxAgeYear) || (age.MinAgeYear != null &&  pis.pi.PI_Age__c < age.MinAgeYear) )){ 
                                // if(pis.pi.PI_Age__c>=0 &&  (age.MinAgeYear!=null &&  pis.pi.PI_Age__c<age.MinAgeYear)){
                                //     pis.piValidationItem.otherValidation = false;
                                // //} else if( (age.MaxAgeDay != null && days > age.MaxAgeDay) || (age.MinAgeDay != null && days < age.MinAgeDay) ) {
                                // } else if(age.MinAgeDay!=null && days<age.MinAgeDay){
                                //     pis.piValidationItem.otherValidation=false;
                                // } else if( (null==age.MaxAgeDay || age.MaxAgeDay==0) && age.MaxAgeYear==0){
                                //     pis.piValidationItem.otherValidation=false;
                                // }else if(pis.pi.PI_Age__c>0 && (age.MaxAgeYear!=null && pis.pi.PI_Age__c>age.MaxAgeYear)){
                                //     pis.piValidationItem.otherValidation=false;
                                // }
                            // }
                            //change by jack for JR1829
                        }
                    }
                }
                //system.debug('>>> EligibleAge checking: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                // Rancho_FullTimeStudent_20240807 - elite 360 allows dependent's age > 18 for full time student
                if(pis.pi.Rider__c!=null && ptvs.ctrl.riderMap.containsKey(pis.pi.Benefit_Level__c) && !bypassAgeCheck){
                    for(String selectedRiderCode : pis.selectedRidersMap.keySet()){//pis.pi.Rider__c.split(';')
                        List<HttpCalloutVO.Rider> riList=ptvs.ctrl.riderMap.get(pis.pi.Benefit_Level__c);
                        for(HttpCalloutVO.Rider ri : riList){
                            if(ri.riderCode==selectedRiderCode){
                                for(HttpCalloutVO.EligibleAge age : ri.eligibleAgeList){
                                    if(insuredType==age.RelationRoleCode){
                                        Integer days=pis.pi.Date_of_Birth__c.daysBetween(date.today())+1;
                                        //system.debug('>>> EligibleAge checking: pis.pi.PI_Age__c: ' + pis.pi.PI_Age__c);
                                        //system.debug('>>> EligibleAge checking: days: ' + days);
                                        system.debug('>>> EligibleAge checking: age.MaxAgeYear: '+age.MaxAgeYear);
                                        system.debug('>>> EligibleAge checking: age.MinAgeYear: '+age.MinAgeYear);
                                        if(pis.pi.PI_Age__c>0 && ((age.MaxAgeYear!=null && pis.pi.PI_Age__c>age.MaxAgeYear) || (age.MinAgeYear != null &&  pis.pi.PI_Age__c < age.MinAgeYear) )){
                                            //system.debug('>>> EligibleAge checking: matched >>>>>>>>>> age.RelationRoleCode: ' + age.RelationRoleCode);
                                            system.debug('>>> EligibleAge checking: matched >>>>>>>>>> insuredType: ' + insuredType);
                                            system.debug('>>> EligibleAge checking: matched >>>>>>>>>> ri.riderCode: ' + ri.riderCode);
                                            pis.piValidationItem.otherValidation=false;
                                        } else if((age.MaxAgeDay!=null && days>age.MaxAgeDay) || (age.MinAgeDay!=null && days<age.MinAgeDay)) {
                                            //system.debug('>>> EligibleAge checking: matched >>>>>>>>>> age.RelationRoleCode: ' + age.RelationRoleCode);
                                            system.debug('>>> EligibleAge checking: matched >>>>>>>>>> insuredType: ' + insuredType);
                                            system.debug('>>> EligibleAge checking: matched >>>>>>>>>> ri.riderCode: ' + ri.riderCode);
                                            pis.piValidationItem.otherValidation=false;
                                        } else if( (null==age.MaxAgeDay || age.MaxAgeDay==0) && age.MaxAgeYear==0){
                                            //system.debug('>>> EligibleAge checking: matched >>>>>>>>>> age.RelationRoleCode: ' + age.RelationRoleCode);
                                            system.debug('>>> EligibleAge checking: matched >>>>>>>>>> insuredType: ' + insuredType);
                                            system.debug('>>> EligibleAge checking: matched >>>>>>>>>> ri.riderCode: ' + ri.riderCode);
                                            pis.piValidationItem.otherValidation=false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                system.debug('>>> EligibleAge checking: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                
                //duplicate policy checking
                //List<HttpCalloutVO.Policy> plist = helper.getIndividualPolicyListBasicByCriteria('', '', pis.pi.Personal_ID__c, '', '', '');
                //if('Y1'.equals(pvc.Duplicate_Policy_Checking__c) || 'Y2'.equals(pvc.Duplicate_Policy_Checking__c)){//Y1 Product in "Duplicate Policy Checking": check as a group on policy status = in-force AND same day policy submission
                    //Set<String> groupProductCodeToCheck = 'Y1'.equals(pvc.Duplicate_Policy_Checking__c)?groupProductCode:groupProductCode2;                   
                //Update by Andy Li for ROP Revamp, add Y4&Y5 
                //Add by Manuel for VHIS products etc checking
                //Check if inforce/pending policy found from IPAS
                if(!'Y'.equals(pvc.Duplicate_Policy_Checking__c) && !'N'.equals(pvc.Duplicate_Policy_Checking__c)){  
                    Set<String> groupProductCodeToCheck;
                    if('Y1'.equals(pvc.Duplicate_Policy_Checking__c)){
                        groupProductCodeToCheck = groupProductCode;
                    }else if('Y2'.equals(pvc.Duplicate_Policy_Checking__c)){
                        groupProductCodeToCheck = groupProductCode2;
                    }else if('Y3'.equals(pvc.Duplicate_Policy_Checking__c)){
                        groupProductCodeToCheck = groupProductCode3;
                    }else if('Y4'.equals(pvc.Duplicate_Policy_Checking__c)){
                        groupProductCodeToCheck = groupProductCode4;
                    }else if('Y5'.equals(pvc.Duplicate_Policy_Checking__c)){
                        groupProductCodeToCheck = groupProductCode5;
                    }else if('Y6'.equals(pvc.Duplicate_Policy_Checking__c)){     //JL20200622
                        groupProductCodeToCheck = groupProductCode6;            //JL20200622
                    }                                                           //JL20200622
                    
                    System.debug('groupProductCodeToCheck:'+groupProductCodeToCheck);
                    for(HttpCalloutVO.Policy p : pis.personalIDPolicylistFromWS){
                        System.debug('p.policyStatusDisplayName:'+p.policyStatusDisplayName);
                        //JL20200622 if((p.policyStatusDisplayName == 'Inforce' || p.policyStatusDisplayName == '生效') && groupProductCodeToCheck.contains(p.productCode) ){//&& Date.today() == p.effDateInDate
                        if((p.policyStatusDisplayName == 'Inforce' || p.policyStatusDisplayName == '生效' || p.policyStatusDisplayName == 'Pending' || p.policyStatusDisplayName == '待辦中') && groupProductCodeToCheck.contains(p.productCode) ){ //JL20200622    
                            //JL20200622 pis.piValidationItem.isDuplicate = true;
                            //JL20200622 break; 
                            //JL20200622  - Start                          
                            if(groupProductCode6.contains(productCode)){        
                                break;
                            }else{
                                pis.piValidationItem.isDuplicate = true;
                                break;
                            }
                            //JL20200622 - End
                        }
                    }
                    //For DPSP-931, duplicate policy checking in SFDC //Find inforce policy from SFDC
                    
                    List<Person_insured__c> inforcePolicyInSFDC = piPersonalIdPIPolicyListMap.get(pis.pi.Personal_ID__c);
                    System.debug('[TMProductStrategy] piValidation().pis.pi.Personal_ID__c='+pis.pi.Personal_ID__c);
                    System.debug('[TMProductStrategy] piValidation().pis.piPolicy.Product_Code__c='+pis.piPolicy.Product_Code__c);
                    System.debug('[TMProductStrategy] piValidation().inforcePolicyInSFDC='+inforcePolicyInSFDC);
                    if(null != inforcePolicyInSFDC){
                        for(Person_insured__c inforcePiPolicy : inforcePolicyInSFDC){
                            System.debug('[TMProductStrategy] piValidation().inforcePiPolicy.new_policy__r.UW_Overrall_Result__c='+inforcePiPolicy.new_policy__r.UW_Overrall_Result__c);
                            System.debug('[TMProductStrategy] piValidation().inforcePiPolicy.new_policy__r.Product_Code__c='+inforcePiPolicy.new_policy__r.Product_Code__c);
                            //JL20200622  if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPT.equals(inforcePiPolicy.new_policy__r.UW_Overrall_Result__c) && groupProductCodeToCheck.contains(inforcePiPolicy.new_policy__r.Product_Code__c) ){
                            if((!TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED.equals(inforcePiPolicy.new_policy__r.UW_Overrall_Result__c)) && groupProductCodeToCheck.contains(inforcePiPolicy.new_policy__r.Product_Code__c) ){   //JL20200622
                                pis.piValidationItem.isDuplicate = true;
                                break;
                            }
                        }
                    }                    
                }else if('Y'.equals(pvc.Duplicate_Policy_Checking__c)){//"Y" Products except GAOP: checking on policy status = in-force AND same day policy submission
                    if(productCode.equals('GAOP')){//GAOP: checking policy status = in-force, lapse AND same day policy submission
                        for(HttpCalloutVO.Policy p : pis.personalIDPolicylistFromWS){
                            System.debug('[TMProductStrategy] piValidation().p.policyStatusDisplayName='+p.policyStatusDisplayName);
                            //DPSP-630 : remove the condition "Date.today() == p.effDateInDate"
                            //JL20200622 if(('Inforce;Lapsed;Surrendered'.contains(p.policyStatusDisplayName) || p.policyStatusDisplayName == '生效') && productCode.equals(p.productCode)){// && Date.today() == p.effDateInDate
                            if(('Inforce;Pending'.contains(p.policyStatusDisplayName) || p.policyStatusDisplayName == '生效' || p.policyStatusDisplayName == '待辦中') && productCode.equals(p.productCode)){//JL20200622
                                pis.piValidationItem.isDuplicate = true;
                                break;
                            }
                        }
                    }else{
                        for(HttpCalloutVO.Policy p : pis.personalIDPolicylistFromWS){
                            //JL20200622 if((p.policyStatusDisplayName == 'Inforce' || p.policyStatusDisplayName == '生效') && productCode.equals(p.productCode)){//&& Date.today() == p.effDateInDate
                            if((p.policyStatusDisplayName == 'Inforce' || p.policyStatusDisplayName == '生效' || p.policyStatusDisplayName == 'Pending' || p.policyStatusDisplayName == '待辦中') && productCode.equals(p.productCode)){//JL20200622
                                pis.piValidationItem.isDuplicate = true;
                                break;
                            }
                        }
                    }
                    //For DPSP-931, duplicate policy checking in SFDC
                    System.debug('[TMProductStrategy] piValidation().pis.piPolicy.Product_Code__c='+pis.piPolicy.Product_Code__c);
                    List<Person_insured__c> inforcePolicyInSFDC = piPersonalIdPIPolicyListMap.get(pis.pi.Personal_ID__c);
                    if(null != inforcePolicyInSFDC){
                        for(Person_insured__c inforcePiPolicy : inforcePolicyInSFDC){
                            System.debug(inforcePiPolicy);
                            if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED.equals(inforcePiPolicy.new_policy__r.UW_Overrall_Result__c)){
                                pis.piValidationItem.isDuplicate = true;
                                break;
                            }
                        }
                    }                                        
                }else if('N'.equals(pvc.Duplicate_Policy_Checking__c)){
                    pis.piValidationItem.isDuplicate = false;
                }
                
                //'R' means referring to GA_Product_Validation_Checking__c
                if('R'.equals(pvc.Post_Duplication_Checking__c) || 'R'.equals(pvc.AUW__c) || 'R'.equals(pvc.UW_Requirement__c)){
                    /**
                    String queryParam1 = '%' + ('113;114;147'.contains(ptvs.ctrl.cam.Channel__r.Channel_Code__c)?ptvs.ctrl.cam.Channel__r.Channel_Code__c:'others') + '%';
                    String queryParam2 = '%' + (ptvs.ctrl.opp.Is_Side_Order__c?'Y':'N') + '%';
                    String queryParam3 = '%' + pis.pi.Insured_Type__c + '%';
                    System.debug('[TMProductStrategy] piValidation().queryParam1='+queryParam1);
                    System.debug('[TMProductStrategy] piValidation().queryParam2='+queryParam2);
                    System.debug('[TMProductStrategy] piValidation().queryParam3='+queryParam3);
                    GA_Product_Validation_Checking__c gpvc = [select AUW__c,Channel__c,Insured_Type__c,Post_Duplication_Checking__c,Side_Order__c,UW_Requirement__c from GA_Product_Validation_Checking__c 
                                                              where Channel__c like :queryParam1 and Side_Order__c like :queryParam2 and Insured_Type__c like :queryParam3];
                    **/
                    Boolean isMatched = false;
                    GA_Product_Validation_Checking__c gpvOfOthers = null;
                    for(GA_Product_Validation_Checking__c gpv : GAProductValidationCheckingTable){
                        System.debug('test by lihaoptvs.ctrl.cam.Channel__r.Channel_Code__c'+ptvs.ctrl.cam.Channel__r.Channel_Code__c+'ptvs.ctrl.opp.Is_Side_Order__c'+ptvs.ctrl.opp.Is_Side_Order__c+'pis.pi.Insured_Type__c'+pis.pi.Insured_Type__c);
                        if(gpv.Channel__c.equalsIgnoreCase('others')){
                            gpvOfOthers = gpv;
                        }else if(gpv.Channel__c.contains(ptvs.ctrl.cam.Channel__r.Channel_Code__c) && gpv.Side_Order__c.contains(ptvs.ctrl.opp.Is_Side_Order__c?'Y':'N') &&  gpv.Insured_Type__c.contains(pis.pi.Insured_Type__c)){
                            pis.piValidationItem.needPresales = gpv.Post_Duplication_Checking__c == 'Y'?true:false;
                            pis.piValidationItem.needAUW =  gpv.AUW__c == 'Y'?true:false;
                            pis.piPolicy.UW_Requirement__c = gpv.UW_Requirement__c;
                            isMatched = true;
                            break;
                        }
                        System.debug('test lihao need auw1'+pis.piValidationItem.needAUW);
                    }
                    if(isMatched == false){
                        if(gpvOfOthers.Side_Order__c.contains(ptvs.ctrl.opp.Is_Side_Order__c?'Y':'N') &&  gpvOfOthers.Insured_Type__c.contains(pis.pi.Insured_Type__c)){
                            pis.piValidationItem.needPresales = gpvOfOthers.Post_Duplication_Checking__c == 'Y'?true:false;
                            pis.piValidationItem.needAUW = gpvOfOthers.AUW__c == 'Y'?true:false;
                            pis.piPolicy.UW_Requirement__c = gpvOfOthers.UW_Requirement__c;
                            System.debug('test lihao need auw1'+pis.piValidationItem.needAUW);
                        }
                    }


                    /**
                    System.debug('[TMProductStrategy] piValidation().gpvc='+gpvc);
                    if(null != gpvc){
                        pis.piValidationItem.needPresales = gpvc.Post_Duplication_Checking__c == 'Y'?true:false;
                        pis.piValidationItem.needAUW = gpvc.AUW__c == 'Y'?true:false;
                        pis.piPolicy.UW_Requirement__c = gpvc.UW_Requirement__c;
                    }
                    **/
                }
                system.debug('>>> before rule book All Checking end: current policy: ' + pis.piPolicy.policy_no__c);
                system.debug('>>> before rule book All Checking end: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                system.debug('>>> before rule book All Checking end: pis.piValidationItem.isDuplicate: ' + pis.piValidationItem.isDuplicate);
                //system.debug('>>> before rule book All Checking end: pis.piValidationItem.needPresales: ' + pis.piValidationItem.needPresales);
                //system.debug('>>>  before rule bookAll Checking end: pis.piValidationItem.needAUW: ' + pis.piValidationItem.needAUW);
                //Rule book 1 : Post Duplication Checking
                if('Y'.equals(pvc.Post_Duplication_Checking__c)){
                    pis.piValidationItem.needPresales = true;
                }else if('N'.equals(pvc.Post_Duplication_Checking__c)){
                    pis.piValidationItem.needPresales = false;
                }
                //Rule book2 : auw
                if('Y'.equals(pvc.AUW__c)){
                    pis.piValidationItem.needAUW = true;
                }else if('N'.equals(pvc.AUW__c)){
                    pis.piValidationItem.needAUW = false;
                }
                //fill the UW_Requirement__c field
                if(!'R'.equals(pvc.UW_Requirement__c)){
                    pis.piPolicy.UW_Requirement__c = pvc.UW_Requirement__c;
                }
                //system.debug('>>> All Checking end: current policy: ' + pis.piPolicy.policy_no__c);
                //system.debug('>>> All Checking end: pis.piValidationItem.otherValidation: ' + pis.piValidationItem.otherValidation);
                //system.debug('>>> All Checking end: pis.piValidationItem.isDuplicate: ' + pis.piValidationItem.isDuplicate);
                system.debug('>>> All Checking end: pis.piValidationItem.needPresales: ' + pis.piValidationItem.needPresales);
                system.debug('>>> All Checking end: pis.piValidationItem.needAUW: ' + pis.piValidationItem.needAUW);
            }
        }
        //ptvs.ctrl.isStep2ValidationCalled = true;
    }
    
    //Overload
    /*public void transactionValidation(TMPolicyUtil.PolicyTransactionValidationStruct ptvs, String productCode){
        
        ptvs.policyTransactionValidationItem.productValidation = true;
        
        
         //For show BMI and smoking indicator
         
        
        if(String.isNotBlank(productCode)){
            List<Policy_Validation_Checking__c> pvcList = [select Duplicate_Policy_Checking__c,Post_Duplication_Checking__c,AUW__c,BMI__c,Smoking__c,Product_Code__c,UW_Requirement__c from Policy_Validation_Checking__c where Product_Code__c = :productCode limit 1];
            if(!pvcList.isEmpty()){
                if('Y' == pvcList[0].BMI__c){
                    ptvs.policyTransactionValidationItem.showBMIInd = true;
                }else if('N' == pvcList[0].BMI__c){
                    ptvs.policyTransactionValidationItem.showBMIInd = false;
                }
                if('Y' == pvcList[0].Smoking__c){
                    ptvs.policyTransactionValidationItem.showSmokingInd = true;
                }else if('N' == pvcList[0].Smoking__c){
                    ptvs.policyTransactionValidationItem.showSmokingInd = false;
                }
                System.debug('[TMProductStrategy] transactionValidation().policyTransactionValidationItem.showSmokingInd='+ptvs.policyTransactionValidationItem.showSmokingInd);
                System.debug('[TMProductStrategy] transactionValidation().policyTransactionValidationItem.showBMIInd='+ptvs.policyTransactionValidationItem.showBMIInd);
            }
        }
    }*/
    //Overload
    public void transactionValidation(TMPolicyUtil.PolicyTransactionValidationStruct ptvs, String productCode){       
        ptvs.policyTransactionValidationItem.productValidation = true;       
        /*
        * For show BMI and smoking indicator
        * 
        */
        //if(String.isNotBlank(productCode)){
        if(String.isNotBlank(productCode) && !productCode.equals(ptvs.ctrl.productCodeInd)){
            //system.debug('[TMProductStrategy] productCodeInd Changed');
            ptvs.ctrl.productCodeInd = productCode;
            System.debug('[TMProductStrategy] productCode'+productCode);
            List<Policy_Validation_Checking__c> pvcList = [select Duplicate_Policy_Checking__c,Post_Duplication_Checking__c,AUW__c,BMI__c,Smoking__c,Product_Code__c,UW_Requirement__c from Policy_Validation_Checking__c where Product_Code__c = :productCode limit 1];
            if(!pvcList.isEmpty()){
                if('Y' == pvcList[0].BMI__c){
                    ptvs.policyTransactionValidationItem.showBMIInd = true;
                }else if('N' == pvcList[0].BMI__c){
                    ptvs.policyTransactionValidationItem.showBMIInd = false;
                }
                if('Y' == pvcList[0].Smoking__c){
                    ptvs.policyTransactionValidationItem.showSmokingInd = true;
                }else if('N' == pvcList[0].Smoking__c){
                    ptvs.policyTransactionValidationItem.showSmokingInd = false;
                }
                System.debug('[TMProductStrategy] transactionValidation().policyTransactionValidationItem.showSmokingInd='+ptvs.policyTransactionValidationItem.showSmokingInd);
                System.debug('[TMProductStrategy] transactionValidation().policyTransactionValidationItem.showBMIInd='+ptvs.policyTransactionValidationItem.showBMIInd);
            }
        }       
        /**
        For show BMI restructure
         */
        if(ptvs.ctrl.productNeedBMIMap.containsKey(productCode) && ptvs.ctrl.productNeedBMIMap.get(productCode)){
            //system.debug('General transactionValidation');
            String isSideOrder = ptvs.ctrl.opp.Is_Side_Order__c ? 'Y':'N';
            GA_Product_Validation_Checking__c gpvOthers;
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                system.debug('[TMProductStrategy] pis.pi.Insured_Type__c= '+pis.pi.Insured_Type__c);
                system.debug('[TMProductStrategy] pis.pi.PI_Age__c= '+pis.pi.PI_Age__c);
                //system.debug('[TMProductStrategy] isSideOrder= '+isSideOrder);
                //system.debug('[TMProductStrategy] ptvs.ctrl.cam.Channel__r.Channel_Code__c= '+ptvs.ctrl.cam.Channel__r.Channel_Code__c);
                Boolean isMatched = false;
                for(GA_Product_Validation_Checking__c gpv : ptvs.ctrl.GAProductValidationList){
                    system.debug('[TMProductStrategy] gpv.Name= '+gpv.Name);
                    system.debug('[TMProductStrategy] gpv.Insured_Type__c= '+gpv.Insured_Type__c);
                    /*if(String.isNotBlank(pis.pi.Insured_Type__c))
                        system.debug('[TMProductStrategy] gpv.Insured_Type__c contains= '+gpv.Insured_Type__c.contains(pis.pi.Insured_Type__c));
                    system.debug('[TMProductStrategy] gpv.Channel__c= '+gpv.Channel__c);
                    if(String.isNotBlank(ptvs.ctrl.cam.Channel__r.Channel_Code__c))
                        system.debug('[TMProductStrategy] gpv.Channel__c contains= '+gpv.Channel__c.contains(ptvs.ctrl.cam.Channel__r.Channel_Code__c));
                    system.debug('[TMProductStrategy] gpv.Side_Order__c= '+gpv.Side_Order__c);
                    if(String.isNotBlank(isSideOrder))
                        system.debug('[TMProductStrategy] gpv.Side_Order__c contains= '+gpv.Side_Order__c.contains(isSideOrder));*/
                    if(String.isNotBlank(pis.pi.Insured_Type__c) && gpv.Insured_Type__c.contains(pis.pi.Insured_Type__c) && gpv.Channel__c.contains(ptvs.ctrl.cam.Channel__r.Channel_Code__c) && gpv.Side_Order__c.contains(isSideOrder)){
                        //system.debug('[TMProductStrategy] gpv.Name= '+gpv.Name);
                        if(gpv.AUW__c == 'Y'){ pis.isSpecialProductShowBMIInd = true; }
                        isMatched = true;
                        break;
                    }
                    if(gpv.Channel__c.equalsIgnoreCase('others')){ gpvOthers = gpv; }
                }
                //system.debug('[TMProductStrategy] pis.isSpecialProductShowBMIInd(before others)= '+pis.isSpecialProductShowBMIInd);
                system.debug('[TMProductStrategy] isMatched= '+isMatched);
                if(!isMatched && null != gpvOthers){
                    if(String.isNotBlank(pis.pi.Insured_Type__c) && gpvOthers.Insured_Type__c.contains(pis.pi.Insured_Type__c) && gpvOthers.Side_Order__c.contains(isSideOrder)){
                        pis.isSpecialProductShowBMIInd = true;
                    }else{
                        pis.isSpecialProductShowBMIInd = false;
                    }
                }
                system.debug('[TMProductStrategy] pis.isSpecialProductShowBMIInd= '+pis.isSpecialProductShowBMIInd);
            }
        }
    }
    
    /*public static void adjustChildOverallResultByParent(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){

        Boolean allAdultOverallResultDecline = true;
        Boolean allAdultOverallResultReferred = true;
        Boolean notAdult = true;        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){  
            if(pis.pi.PI_Age__c > 17)
                notAdult = false;
            if(pis.pi.PI_Age__c > 17 && !'Referred'.equals(pis.piPolicy.UW_Overrall_Result__c) ){
                allAdultOverallResultReferred = false;
                system.debug('[TMProductStrategy] adjustChildOverallResultByParent().allAdultOverallResultReferred='+allAdultOverallResultReferred);
            }
            if(pis.pi.PI_Age__c > 17 && !'Declined'.equals(pis.piPolicy.UW_Overrall_Result__c) ){
                allAdultOverallResultDecline = false;
                system.debug('[TMProductStrategy] adjustChildOverallResultByParent().allAdultOverallResultDecline='+allAdultOverallResultDecline);
            }
        }
        if(notAdult){
            allAdultOverallResultDecline = allAdultOverallResultReferred = false;
        }
        if(!adjustChildOverallResultExceptProductcode.contains(personInsuredStructureList.get(0).piPolicy.Product_Code__c)){
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                system.debug('[TMProductStrategy] adjustChildOverallResultByParent().pis.pi.PI_Age__c='+pis.pi.PI_Age__c);
                system.debug('[TMProductStrategy] adjustChildOverallResultByParent().pis.pi.Insured_Type__c='+pis.pi.Insured_Type__c);
                system.debug('[TMProductStrategy] adjustChildOverallResultByParent().pis.pi.Relationship__c='+pis.pi.Relationship__c);
                if(pis.pi.PI_Age__c <= 17 && 'Dependent'.equals(pis.pi.Insured_Type__c) && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c)) && allAdultOverallResultReferred){
                    pis.piPolicy.UW_Overrall_Result__c = 'Referred';
                }
                if(pis.pi.PI_Age__c <= 17 && 'Dependent'.equals(pis.pi.Insured_Type__c) && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c)) && allAdultOverallResultDecline){
                    pis.piPolicy.UW_Overrall_Result__c = 'Declined';
                }
                system.debug('[TMProductStrategy] adjustChildOverallResultByParent().pis.piPolicy.UW_Overrall_Result__c='+pis.piPolicy.UW_Overrall_Result__c);
            }
        }
    }*/
    
    public static void adjustChildOverallResultByParent(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){        
        if(adjustChildOverallResultProductCode.contains(personInsuredStructureList.get(0).piPolicy.Product_Code__c) || Test.isRunningTest()){
            Boolean notAdult = true;            
            Map<String, String> PIIDOverallResultMap = new Map<String,String>();
            Map<String,String> parentIDPlanLevelMap = new Map<String,String>();
            Map<String,String> parentIDProductCodeMap = new Map<String,String>();
            Map<String,TMCreatePolicyCtrl.PersonInsuredStructure> parentIDChildPIMap = new Map<String,TMCreatePolicyCtrl.PersonInsuredStructure>();
            
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                if(pis.pi.PI_Age__c > 17){ notAdult = false; }               
                PIIDOverallResultMap.put(pis.pi.Personal_ID__c, pis.piPolicy.UW_Overrall_Result__c);
                if(String.isNotBlank(pis.pi.Parent_PI_ID__c)){
                    parentIDPlanLevelMap.put(pis.pi.Parent_PI_ID__c, pis.pi.Benefit_Level__c);
                    parentIDProductCodeMap.put(pis.pi.Parent_PI_ID__c, pis.piPolicy.Product_Code__c);
                    parentIDChildPIMap.put(pis.pi.Parent_PI_ID__c, pis);
                }
            }
            
            // Child(ren) and Parent in the same pt
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                if(pis.pi.PI_Age__c <= 17 && 'Dependent'.equals(pis.pi.Insured_Type__c) && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c))){
                    if(PIIDOverallResultMap.get(pis.pi.Parent_PI_ID__c)!=null && 'Referred'.equals(PIIDOverallResultMap.get(pis.pi.Parent_PI_ID__c))){
                        if(!'Declined'.equals(pis.piPolicy.UW_Overrall_Result__c)){pis.piPolicy.UW_Overrall_Result__c = 'Referred';}
                    }else if(PIIDOverallResultMap.get(pis.pi.Parent_PI_ID__c)!=null && 'Declined'.equals(PIIDOverallResultMap.get(pis.pi.Parent_PI_ID__c))){
                        pis.piPolicy.UW_Overrall_Result__c = 'Declined';
                    }
                }
            }
            // same pt
            
            //Child(ren) and Parent in the different pt
            if(notAdult){
                if(!parentIDPlanLevelMap.isEmpty() && !parentIDProductCodeMap.isEmpty()){
                    String soql = 'SELECT ID, Personal_ID__c, New_Policy__r.UW_Overrall_Result__c FROM Person_Insured__c WHERE ';
                    Integer counter = 0;
                    for(String key : parentIDPlanLevelMap.keySet()){
                        soql += '( New_Policy__r.Product_Code__c = \'' + parentIDProductCodeMap.get(key)+ '\' AND Benefit_Level__c = \'' + parentIDPlanLevelMap.get(key) + '\' AND Personal_ID__c = \'' + key + '\' )';
                        counter++;
                        if(counter != parentIDPlanLevelMap.keySet().size()){soql += ' OR ';}
                    }
                    system.debug('soql= '+soql);
                    List<Person_Insured__c> parentPIList = database.query(soql);
                    for(Person_Insured__c pi : parentPIList){
                        if('Referred'.equals(pi.New_Policy__r.UW_Overrall_Result__c) && parentIDChildPIMap.containsKey(pi.Personal_ID__c)){
                            TMCreatePolicyCtrl.PersonInsuredStructure childPIS = parentIDChildPIMap.get(pi.Personal_ID__c);
                            if(!'Declined'.equals(childPIS.piPolicy.UW_Overrall_Result__c)){childPIS.piPolicy.UW_Overrall_Result__c = 'Referred';}
                        }else if('Declined'.equals(pi.New_Policy__r.UW_Overrall_Result__c) && parentIDChildPIMap.containsKey(pi.Personal_ID__c)){
                            TMCreatePolicyCtrl.PersonInsuredStructure childPIS = parentIDChildPIMap.get(pi.Personal_ID__c);
                            childPIS.piPolicy.UW_Overrall_Result__c = 'Declined';
                        }
                    }
                }
            } //different pt
        }       
    }

    // DPSP-963 & DPSP-571
    // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
    public static void setMasterPolicyNumber(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList, List<HttpCalloutVO.Policy> PHPersonalIDPolicylist){
        //Default master policy number = first policy number of the same application
        //PolicyCalloutHelper helper = new PolicyCalloutHelper();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            System.debug('[TMProductStrategy] setMasterPolicyNumberForProductSCI().pis.piPolicy.Master_Policy_No__c='+pis.piPolicy.Master_Policy_No__c);
            String tmpMasterPolicyNumber = pis.piPolicy.Master_Policy_No__c;
            String selectedDiscount1 = pis.discount1;
            String selectedDiscount2 = pis.discount2;
            String refundDiscount = pis.selectedRefund;
            pis.piPolicy.Master_Policy_No__c = null;
            //When user is eligible for bundle discount (after selecting bundle discount), put the in-force/accepted result policy number to master policy number field
            if('BUNDLE DISCOUNT'.equalsIgnoreCase(selectedDiscount1) || 'BUNDLE DISCOUNT'.equalsIgnoreCase(selectedDiscount2) || 'Bundle premium refund'.equalsIgnoreCase(refundDiscount)){
                //For bundle discount, master policy number value should be the in-force NELG/NESG policy number HKID is holding
                //List<HttpCalloutVO.Policy> plist = helper.getIndividualPolicyListBasicByCriteria('', '', pis.piPolicy.Personal_ID__c, '', '', '');
                System.debug('[TMProductStrategySC] discountValidation().PHPersonalIDPolicylist='+PHPersonalIDPolicylist);
                for(HttpCalloutVO.Policy p : PHPersonalIDPolicylist){
                    System.debug('[TMProductStrategy] setMasterPolicyNumberForProductSCI().p.productCode='+p.productCode+' p.policyStatusDisplayName='+p.policyStatusDisplayName+' p.policyNumber='+p.policyNumber);
                    if((null != p.productCode && (p.productCode.contains('NELG') || p.productCode.contains('NESG'))) && ('Inforce'.equalsIgnoreCase(p.policyStatusDisplayName) || '生效'.equalsIgnoreCase(p.policyStatusDisplayName))){
                        pis.piPolicy.Master_Policy_No__c = p.policyNumber;
                        //pis.piPolicy.Relationship_Of_Policy__c = 'MI'; //Remove this logic according to SPS-616 by Kermit
                        break;
                    }
                }
                if(null == pis.piPolicy.Master_Policy_No__c){
                    //PH has completed @NELG/@NESG policy on SFDC with overall result being accepted
                    List<New_Policy__c> phPolicyList = [select id,policy_no__c,UW_Overrall_Result__c from new_policy__c where Personal_ID__c = :pis.piPolicy.Personal_ID__c and (Product_Code__c = 'NELG' or Product_Code__c = '@NELG' or Product_Code__c = 'NESG' or Product_Code__c = '@NESG') and (Policy_Status__c = 'Completed' or Policy_Status__c = 'Submitted')];
                    System.debug('[TMProductStrategySC] discountValidation().phPolicyList='+phPolicyList);
                    for(New_Policy__c policy : phPolicyList){
                        //if(null != policy.UW_Result__r && policy.UW_Result__r.size() > 0){
                        if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED.equals(policy.UW_Overrall_Result__c)){
                            pis.piPolicy.Master_Policy_No__c = policy.policy_no__c;
                            //pis.piPolicy.Relationship_Of_Policy__c = 'MI'; //Remove this logic according to SPS-616 by Kermit
                            break;
                        } //}
                    }
                }
                System.debug('[TMProductStrategy] setMasterPolicyNumberForProductSCI().pis.piPolicy.Master_Policy_No__c='+pis.piPolicy.Master_Policy_No__c);
            }else if('LOYALTY DISCOUNT'.equalsIgnoreCase(selectedDiscount1) || 'LOYALTY DISCOUNT'.equalsIgnoreCase(selectedDiscount2) || 'Loyalty premium refund'.equalsIgnoreCase(refundDiscount)){
                //For LOYALTY DISCOUNT, master policy number value should be in-force policy number HKID is holding
                //List<HttpCalloutVO.Policy> plist = helper.getIndividualPolicyListBasicByCriteria('', '', pis.piPolicy.Personal_ID__c, '', '', '');
                System.debug('[TMProductStrategySC] discountValidation().PHPersonalIDPolicylist='+PHPersonalIDPolicylist);
                for(HttpCalloutVO.Policy p : PHPersonalIDPolicylist){
                    System.debug('[TMProductStrategy] setMasterPolicyNumberForProductSCI().p.policyStatusDisplayName='+p.policyStatusDisplayName+' p.policyNumber='+p.policyNumber);
                    if('Inforce'.equalsIgnoreCase(p.policyStatusDisplayName) || '生效'.equalsIgnoreCase(p.policyStatusDisplayName)){
                           pis.piPolicy.Master_Policy_No__c = p.policyNumber;
                           //pis.piPolicy.Relationship_Of_Policy__c = 'MI'; //Remove this logic according to SPS-616 by Kermit
                           break;
                    }
                }
                if(null == pis.piPolicy.Master_Policy_No__c){
                    //PH HKID has any completed policy with overall result being accepted
                    List<New_Policy__c> phPolicyList = [select id, policy_no__c, UW_Overrall_Result__c from new_policy__c where Personal_ID__c = :pis.piPolicy.Personal_ID__c and (Policy_Status__c = 'Completed' or Policy_Status__c = 'Submitted')];
                    System.debug('[TMProductStrategySC] discountValidation().phPolicyList='+phPolicyList);
                    for(New_Policy__c policy : phPolicyList){
                        //if(null != policy.UW_Result__r && policy.UW_Result__r.size() > 0){
                        if(TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED.equals(policy.UW_Overrall_Result__c)){
                            pis.piPolicy.Master_Policy_No__c = policy.policy_no__c;
                            //pis.piPolicy.Relationship_Of_Policy__c = 'MI'; //Remove this logic according to SPS-616 by Kermit
                            break;
                        } //}
                    }
                }
                System.debug('[TMProductStrategy] setMasterPolicyNumberForProductSCI().pis.piPolicy.Master_Policy_No__c='+pis.piPolicy.Master_Policy_No__c);
            }
            
            // BEGIN Jira HKITSFDC-39
            // When PH (parent) purchase either one of 6 below with inforce status : (From ws) NESGM , NELGM , NESG , NELG , NESG2 , NELG2
            // Master Policy Number is the policy number of the PH 
            System.debug('Before tmpMasterPolicyNumber HKITSFDC-39'+ tmpMasterPolicyNumber);
            if(null == pis.piPolicy.Master_Policy_No__c){
                System.debug('pis.piPolicy.Master_Policy_No__c is null HKITSFDC-39');
                Boolean isPhEqPi = false;//check if ph is included in pi list 20240617
                if(PHPersonalIDPolicylist != null && !PHPersonalIDPolicylist.isEmpty() && personInsuredStructureList != null && !personInsuredStructureList.isEmpty()){
                    System.debug('PHPersonalIDPolicylist is not null HKITSFDC-39');
                    //check if any policy pi=ph ,if yes isPhEqPi = true
                   
                    for(TMCreatePolicyCtrl.PersonInsuredStructure outerPis : personInsuredStructureList){
                         if('PH = PI'.equalsIgnoreCase(outerPis.pi.Insured_Type__c)){
                             isPhEqPi = true;
                              System.debug('HKITSFDC-39 PI = PH found, no change to master policy number');
                             break;
                         }
                         else{
                             System.debug('HKITSFDC-39 pis.pi.Insured_Type__c :' + outerPis.pi.Insured_Type__c);
                         }
                    }
                    if( !isPhEqPi ){
                         for(HttpCalloutVO.Policy p : PHPersonalIDPolicylist){
                            System.debug('[TMProductStrategy] setMasterPolicyNumberForProductSCI().p.productCode='+p.productCode+' p.policyStatusDisplayName='+p.policyStatusDisplayName+' p.policyNumber='+p.policyNumber);
                           
                            if((null != p.productCode && (p.productCode.contains('NESGM') 
                                                          || p.productCode.contains('NELGM')
                                                          || p.productCode.contains('NESG')
                                                          || p.productCode.contains('NELG')
                                                          || p.productCode.contains('NESG2')
                                                          || p.productCode.contains('NELG2')
                                                         )) 
                                            && ('Inforce'.equalsIgnoreCase(p.policyStatusDisplayName) 
                                                || '生效'.equalsIgnoreCase(p.policyStatusDisplayName))){
                                    
                                                       System.debug('p.masterPolicyNo HKITSFDC-39 '+ p.masterPolicyNo + ' ,  policyno : ' + p.policyNumber);
                                                       pis.piPolicy.Master_Policy_No__c = p.masterPolicyNo;// 20240624p.policyNumber;
                                                       System.debug('After p.holderSSN '+ p.holderSSN + ' , ' + p.insuredSsn);
                                                       System.debug('After pis.piPolicy.Master_Policy_No__c HKITSFDC-39'+ pis.piPolicy.Master_Policy_No__c);
                                                       
                                                       break;
                                                   
                            } 
                        }
                    }
                }
               
            } else {
                  System.debug('Assigned by conditions above pis.piPolicy.Master_Policy_No__c HKITSFDC-39'+ pis.piPolicy.Master_Policy_No__c);
            }
             System.debug('Finally pis.piPolicy.Master_Policy_No__c HKITSFDC-39'+ pis.piPolicy.Master_Policy_No__c);
            // END Jira HKITSFDC-39
            
            if(null == pis.piPolicy.Master_Policy_No__c){
                pis.piPolicy.Master_Policy_No__c = tmpMasterPolicyNumber;
            }
            pis.PIDefaultMasterPolicyNum = pis.piPolicy.Master_Policy_No__c;// add by kermit
        }
    }
    
    private Map<String,List<Person_Insured__c>> getPiPersonalIdPIPolicyListMap(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList, String productCode, String DuplicatePolicyChecking){       
        Map<String, List<Person_insured__c>> piPersonalIdPIPolicyListMap = new Map<String, List<Person_insured__c>>();
        Set<String> piPersonalIdSetY1 = new Set<String>();
        Set<String> piPersonalIdSetY = new Set<String>();
        Set<String> policyIdSetY1 = new Set<String>();
        Set<String> policyIdSetY = new Set<String>();
        String productCodeWithAt = '@' + productCode;
        //if('Y1'.equals(DuplicatePolicyChecking) || 'Y2'.equals(DuplicatePolicyChecking)){
        
        //Update by Andy Li for ROP Revamp
        //Add by Manuel for VHIS products etc checking
        if(!'Y'.equals(DuplicatePolicyChecking) && !'N'.equals(DuplicatePolicyChecking)){
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                System.debug('[TMProductStrategy] getPiPersonalIdPIPolicyListMap().pis.pi.Personal_ID__c='+pis.pi.Personal_ID__c);
                piPersonalIdSetY1.add(pis.pi.personal_id__c);
                policyIdSetY1.add(pis.piPolicy.id);
            }
            System.debug('[TMProductStrategy]policyIdSetY1'+policyIdSetY1+DuplicatePolicyChecking+'productCode'+productCode);
            //For DPSP-931, duplicate policy checking in SFDC
            
            //JL20200622 - Add for JR1825 - Check the policy transaction created at the same today only
            //JL20200622 List<Person_insured__c> piPersonalIdlistY1 = [select new_policy__r.id, new_policy__r.UW_Overrall_Result__c, new_policy__r.Product_Code__c,personal_id__c
            //JL20200622                                              from  person_insured__c
            //JL20200622                                              where personal_id__c in :piPersonalIdSetY1 
            //JL20200622                                              and (new_policy__r.policy_status__c = 'Completed' or  new_policy__r.policy_status__c = 'Submitted')
            //JL20200622                                              and new_policy__r.id not in :policyIdSetY1];            
            List<Person_insured__c> piPersonalIdlistY1 = [select new_policy__r.id, new_policy__r.UW_Overrall_Result__c, new_policy__r.Product_Code__c,personal_id__c, new_policy__r.LastModifiedDate, new_policy__r.policy_status__c  from person_insured__c where personal_id__c in :piPersonalIdSetY1 and (new_policy__r.policy_status__c = 'Completed' or (new_policy__r.policy_status__c = 'Submitted' and DAY_ONLY(new_policy__r.Submission_Date_Time__c) = :Date.today())) and new_policy__r.id not in :policyIdSetY1];
            //JL20200622 - End
            System.debug('[TMProductStrategy] getPiPersonalIdPIPolicyListMap().piPersonalIdlistY1='+piPersonalIdlistY1);
            for(Person_insured__c pi : piPersonalIdlistY1){
                if(piPersonalIdPIPolicyListMap.containsKey(pi.personal_id__c)){
                        piPersonalIdPIPolicyListMap.get(pi.personal_id__c).add(pi);
                }else{
                    List<Person_insured__c> newList = new List<Person_insured__c>();
                    newList.add(pi);
                    piPersonalIdPIPolicyListMap.put(pi.personal_id__c, newList);   
                }                
            }
        }else if('Y'.equals(DuplicatePolicyChecking)){
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
                System.debug('[TMProductStrategy] getPiPersonalIdPIPolicyListMap().pis.pi.Personal_ID__c='+pis.pi.Personal_ID__c);
                piPersonalIdSetY.add(pis.pi.personal_id__c);
                policyIdSetY.add(pis.piPolicy.id);
            }
            //and DAY_ONLY(Submission_Date_Time__c) = :Date.today() 
            //and Product_Code__c = :pis.piPolicy.Product_Code__c];
            List<Person_insured__c> piPersonalIdlistY = [select new_policy__r.id, new_policy__r.UW_Overrall_Result__c,personal_id__c from person_insured__c where personal_id__c in :piPersonalIdSetY
            //JL20200622 and (new_policy__r.policy_status__c = 'Completed' or  new_policy__r.policy_status__c = 'Submitted') 
            and (new_policy__r.policy_status__c = 'Completed' or  (new_policy__r.policy_status__c = 'Submitted' and DAY_ONLY(new_policy__r.Submission_Date_Time__c) = :Date.today())) //JL20200622 - Add
            //and DAY_ONLY(Submission_Date_Time__c) = :Date.today()
            and (new_policy__r.Product_Code__c = :productCode or new_policy__r.Product_Code__c = :productCodeWithAt) and new_policy__r.id not in :policyIdSetY];
            System.debug('[TMProductStrategy] getPiPersonalIdPIPolicyListMap().piPersonalIdlistY='+piPersonalIdlistY);
            for(Person_insured__c pi : piPersonalIdlistY){
                if(piPersonalIdPIPolicyListMap.containsKey(pi.personal_id__c)){
                    piPersonalIdPIPolicyListMap.get(pi.personal_id__c).add(pi);
                }else{
                    List<Person_insured__c> newList = new List<Person_insured__c>();
                    newList.add(pi);
                    piPersonalIdPIPolicyListMap.put(pi.personal_id__c, newList);
                }                
            }
        }
        System.debug('[TMProductStrategy] getPiPersonalIdPIPolicyListMap().piPersonalIdPIPolicyListMap='+piPersonalIdPIPolicyListMap);
        return piPersonalIdPIPolicyListMap;
    }
    
    private List<GA_Product_Validation_Checking__c> getGAProductValidationCheckingTable(){       
        return [select name,AUW__c,Channel__c,Insured_Type__c,Post_Duplication_Checking__c,Side_Order__c,UW_Requirement__c from GA_Product_Validation_Checking__c];
    }
}