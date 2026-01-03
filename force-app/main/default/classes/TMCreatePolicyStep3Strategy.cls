/********************************************************************************
 * Apex Class Name - TMCreatePolicyStep3Strategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps 3
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMCreatePolicyStep3Strategy implements TMCreatePolicyStepStrategy{
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    public static final String assessmentRiderCheckList = '@CBOG, @SP100';//GL31 jack add

    public TMCreatePolicyStep3Strategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        this.ptvs = ptvs;
    }
    
    public void stepInit(){
        system.debug('[TMCreatePolicyStep3Strategy] stepInit().isSkipStep3='+ptvs.ctrl.isSkipStep3);
        ptvs.ctrl.isStep2ValidationCalled = true;
        if(!ptvs.ctrl.isSkipStep3){
            this.updateBeneficaryName(ptvs.ctrl.personInsuredStructureList);
        }
        TMPolicyUtil.updateBankAccoutNumber(ptvs.ctrl.newPolicy);
        //call ws to set parentId policyList for any discount validation or other checking
        TMPolicyUtil.setParentIDPolicyList(ptvs.ctrl.personInsuredStructureList, ptvs.ctrl.policyCalloutHelper);        
        //TMPolicyUtil.discountInit(ptvs);
        setIsReplacement(ptvs.ctrl);// add by jack for policy replacement
    }
    
    public Boolean stepValidation(){
        
        if(step3Validation(ptvs.ctrl.newPolicy, ptvs.ctrl.isShowCRSField, ptvs.ctrl.isShow, ptvs.ctrl.displayCompanyPosition, ptvs.ctrl.personInsuredStructureList, ptvs.policyTransactionValidationItem.isParentIDMandatory, ptvs.ctrl.selectedProduct.is_AML__c)){
            //get PersonalID Policylist From WS( compare the personal id in the object field with the one in memory)
            TMPolicyUtil.setPersonalIDPolicylistFromWS(ptvs.ctrl);
            //pi validation checking
            ptvs.ctrl.pageMsg = null;//clear the msg before
            TMPolicyUtil.piValidation(ptvs);
            Boolean isPass = true;
            Integer i = 1;
            //String errorMsg = '';
            System.debug('lihao test personInsuredStructureList'+ptvs.ctrl.personInsuredStructureList);

            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                System.debug('[TMCreatePolicyStep3Strategy] stepValidation().pis.piValidationItem.otherValidation='+pis.piValidationItem.otherValidation);
                System.debug(cignaUtil.checkAssessResult('','',ptvs.ctrl.policyTransaction.Prod_Rider_Map__c,ptvs.ctrl.selectedProduct.Product_Code__c,pis.selectedRidersMap.keySet(),true,true));
                if(pis.piValidationItem.otherValidation == false || pis.piValidationItem.isDuplicate == true){
                    isPass = false;
                    if(String.isEmpty(ptvs.ctrl.pageMsg))
                        ptvs.ctrl.pageMsg = pis.piValidationItem.isDuplicate?('Person Insured '+ i +' is not eligible due to Duplicate Policy.'):('Person Insured '+ i +' is not eligible.');
                    break;
                //}else if(assessmentRiderCheckList.containsIgnoreCase(ptvs.ctrl.selectedProduct.Product_Code__c) && (ptvs.ctrl.availableRider == null || (!ptvs.ctrl.availableRider.containsIgnoreCase('ALL') && TMPolicyUtil.assessRiderValide(pis.selectedRidersMap,ptvs.ctrl.availableRider,false).size() > 0)) ){//GL31 jack add
                }else if(cignaUtil.checkAssessResult('','',ptvs.ctrl.policyTransaction.Prod_Rider_Map__c,ptvs.ctrl.selectedProduct.Product_Code__c,pis.selectedRidersMap.keySet(),true,true) != CignaUtil.FINE_RESULT){
                    isPass = false;
                     ptvs.ctrl.pageMsg = 'Sorry, the selected product riders do not hit with the needs assessment. Please try again.';
                    break;
                }
                ++i;
            }
            if(isPass){                
                if(ptvs.ctrl.isSkipStep3)
                    ptvs.ctrl.currentStep += 1;
                return true;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ptvs.ctrl.pageMsg));
                ptvs.ctrl.currentStep -= 1;
                System.debug('[TMCreatePolicyStep3Strategy] stepValidation().ptvs.currentStep='+ptvs.ctrl.currentStep);
                ptvs.ctrl.canSave = false;
                return false;
            }            
        }else{
            ptvs.ctrl.currentStep -= 1;
            ptvs.ctrl.canSave = false;
            return false;
        }
    }

    public void nextStep(){
        if(stepValidation())
            stepInit();
    }
    
    private Boolean step3Validation(New_Policy__c newPolicy, Integer isShowCRSField, Integer isShow, Boolean displayCompanyPosition,
                                          List<TMCreatePolicyCtrl.PersonInsuredStructure> piList, Boolean isParentIDMandatory, Boolean isAML){
        System.debug('[TMCreatePolicyStep3Strategy] step3Validation()');
        boolean pass = true;
        String warningMsg = 'You must enter a value in the required field';
        String personalId = '[0-9a-zA-Z]{7,8}';//'[\\s\\S]*?';
        Pattern personalIdPattern = Pattern.compile(personalId);
        String phoneFormat = '[0-9]{8}';
        Pattern phonePattern = Pattern.compile(phoneFormat);
                      
        Integer no = 1;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : piList){ 
             //***************************************pi validation***************************************
            
            //add by kermit to auto populate Insured_Type__c when Relationship__c is not blank
            if(String.isBlank(pis.pi.Insured_Type__c) && String.isNotBlank(pis.pi.Relationship__c)){
                if(pis.pi.Relationship__c == 'Policy Holder'){
                    pis.pi.Insured_Type__c = 'PH = PI';
                }else if(pis.pi.Relationship__c == 'Spouse'){
                    pis.pi.Insured_Type__c = 'Spouse';
                }else if(pis.pi.Relationship__c == 'Son' || pis.pi.Relationship__c == 'Daughter' || pis.pi.Relationship__c == 'Dependent'){
                    pis.pi.Insured_Type__c = 'Dependent';
                }else{
                    pis.pi.Insured_Type__c = '';
                }
            }
            //end add
            
            if(null == pis.pi.Insured_Type__c
                  || null == pis.pi.Gender__c
                  || null == pis.pi.Date_of_Birth__c
                  || null == pis.pi.Personal_ID__c
                  || null == pis.pi.Benefit_Level__c
                  || null == pis.pi.Insured_First_Name__c
                  || null == pis.pi.Insured_Last_Name__c
                  || null == pis.pi.ID_Type__c//DPSP-1024
                  //|| null == pis.pi.Mobile_Phone__c
                  //|| null == pis.pi.Smoker__c // comment by ken for test , there is a bug here for andy  // Fixed
                  || null == pis.pi.Relationship__c
                  /* add by Jack on 2022-01-19 for project: IA AML */
                  || null == pis.pi.Place_of_Birth__c
                  || null == pis.pi.Residential_Address_Country__c
                  || null == pis.pi.nationality__c
                  || (!pis.pi.Is_Email_Needed__c && null == pis.pi.Email__c)
            ){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().pis.pi.Insured_Type__c='+pis.pi.Insured_Type__c);
                system.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().pis.pi.Is_GA__c='+pis.pi.Is_GA__c);      
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi validation');
                System.debug('lihao test auw need auw:'+pis.piValidationItem.needAUW);
                if(!pis.pi.Is_GA__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi validation');
                    pass = false;
                    break;
                }
            }else if(('CIB25'.equalsIgnoreCase(ptvs.ctrl.selectedProduct.product_code__c) || 'CIR25'.equalsIgnoreCase(ptvs.ctrl.selectedProduct.product_code__c)) && String.isBlank(pis.sumInsured)){
                // Rancho_HKITSFDC402_20250930 - sum insured is mandatory for CI product
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi sumInsured validation');
                pass = false;
                break;
            }else if(pis.pi.Is_Email_Needed__c && null != pis.pi.Email__c){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi validation email validation');
                pass = false; 
                warningMsg = 'Please check the email field.';
                break;                      
            }
            /* add by Jack on 2022-01-19 for project: IA AML */
            if(String.isNotBlank(pis.pi.nationality__c) && TMPolicyUtil.nationalityMap.get(pis.pi.nationality__c).Sanction_Nationality__c){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> pi validation nationality validation');
                pass = false; 
                warningMsg = 'Cigna is prohibited from providing any service to persons with nationality of a sanctioned jurisdiction';
                break;
            }    

            if((String.isNotBlank(pis.pi.place_of_birth__c) && TMPolicyUtil.countryMap.get(pis.pi.place_of_birth__c).Sanction_Nationality__c) 
            || (String.isNotBlank(pis.pi.Residential_Address_Country__c) && TMPolicyUtil.countryMap.get(pis.pi.Residential_Address_Country__c).Sanction_Nationality__c)){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> pi validation country validation');
                pass = false; 
                warningMsg = 'Cigna is prohibited from providing any service to persons with Residential Address Country of a sanctioned jurisdiction';
                break;
            }
            /* add by Jack on 2022-01-19 for project: IA AML */
            //validation for DOB, birthday can not later than today
            if(pis.pi.Date_of_Birth__c > Date.today()){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> pi validation DOB validation');
                pass = false; 
                warningMsg = 'Please input valid Date of Birth field.';
                break;
            }
            
            //add by Andy for PI Personal ID validation
            if(null != pis.pi.Personal_ID__c){
                Matcher personalIdMatcher = personalIdPattern.matcher(pis.pi.Personal_ID__c);
                if(null!=personalIdMatcher && !personalIdMatcher.matches()){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() personalIdMatcher:'+personalIdMatcher.matches());
                    pass = false; 
                    warningMsg = 'Please input valid Personal ID number.';
                    break;                  
                }
            }
            
            //special case
            if(pis.isParentPIIdMandatory && pis.displayParentPIId){
                if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                    Matcher parentPIIdMatcher = personalIdPattern.matcher(pis.pi.Parent_PI_ID__c);
                    if(!parentPIIdMatcher.matches()){
                        System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi parentPIId format validation');
                        warningMsg = 'Please input valid Personal ID number.';
                        pass = false;
                        break;
                    }
                }else{
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi Parent_PI_ID not null validation');
                    pass = false;
                    break;
                }
            }else if(pis.displayParentPIId && String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                Matcher parentPIIdMatcher = personalIdPattern.matcher(pis.pi.Parent_PI_ID__c);
                if(!parentPIIdMatcher.matches()){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi parentPIId format validation');
                    warningMsg = 'Please input valid Personal ID number.';
                    pass = false;
                    break;
                }
            }
            //SP100
            //if(productCode == '@SP100'){
            if(newPolicy.Product_Code__c == '@SP100'){
                //|| null == pis.pi.Residential_Address_2__c || null == pis.pi.Residential_Address_3__c || null == pis.pi.Residential_Address_4__c
                if('PH = PI' != pis.pi.Insured_Type__c && (null == pis.pi.Residential_Address_1__c )){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi Residential Address validation');
                    pass = false;
                    break;
                }
                
                Integer age = pis.pi.Date_of_Birth__c.monthsBetween(Date.today())/12;
                if(!(age >= 55 && age <= 85)){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi validation age validation(SLP)');
                    pass = false; 
                    warningMsg = 'Person Insured ' + no +' is not eligible.';
                    break;
                }
            }
            //TMC50 or TMCPU
            if(('TMC50'.equalsIgnoreCase(newPolicy.Product_Code__c) || 'TMCPU'.equalsIgnoreCase(newPolicy.Product_Code__c)) && !'PH = PI'.equalsIgnoreCase(pis.pi.Insured_Type__c)){
                if(String.isEmpty(pis.pi.Benefit_lv_DP_SP_larger_than_MI__c)){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() TMC50 validation');
                    pass = false;
                    break;
                }
            }
            //if(productCode != 'TMC50' && (null == pis.pi.Weight__c
            //comment by ken for test , there is a bug here for andy   // Fixed
            /**
            if(newPolicy.Product_Code__c != 'TMC50' && (null == pis.pi.Weight__c
                  || null == pis.pi.Height__c 
                  || null == pis.pi.Height_Unit__c
                  || null == pis.pi.Weight_Unit__c) ){
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>pi validation:weight Height');
                pass = false;
                break;
            }
            **/
            
            // add by kermit for special product BMI change
            if(ptvs.ctrl.productNeedBMIMap.get(newPolicy.Product_Code__c)!=null && ptvs.ctrl.productNeedBMIMap.get(newPolicy.Product_Code__c)){
                if(pis.isSpecialProductShowBMIInd && (String.isEmpty(pis.weight) || String.isEmpty(pis.height))){
                    pass = false;
                    warningMsg = 'You must enter a value in the required field';
                }else if(!pis.isSpecialProductShowBMIInd && !ptvs.policyTransactionValidationItem.showBMIInd){
                    pis.weight = '';
                    pis.pi.Weight__c = null;
                    pis.height = '';
                    pis.pi.Height__c = null;
                }
            }
            // end add by kermit
            
            //update by Andy from deloitte. Move this validation to TMCreatePolicyCtrl
            //As for AUW bypass portalble product(PBTG), don't need input height and weight, and whetehr need AUW is judged after all those logic
            /* add by Andy for BMI & Smoke validation begin */
            if(ptvs.policyTransactionValidationItem.showBMIInd && !'@PBTG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
                if((String.isEmpty(pis.weight) || String.isEmpty(pis.height) 
                    || null == pis.pi.Height_Unit__c || null == pis.pi.Weight_Unit__c ) ){
                        System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi validation:weight Height');
                        if(!pis.pi.Is_GA__c){
                            pass = false;
                            break;
                        }
                //Only digits are allowed.
                }else if(pis.height.contains('.') || pis.weight.contains('.')){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().Height__c & Weight__c validation');
                    pass = false;
                    warningMsg = 'Please enter only digits.';
                    break;
                }else if(pis.pi.Height_Unit__c == 'ft'){
                    if(String.isEmpty(pis.heightInch)){
                        System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().Height__c & Weight__c validation');
                        pass = false;
                        break;
                    }else if(Double.valueOf(pis.height)>999 || Double.valueOf(pis.height)<0){
                        System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().Height__c & Weight__c validation');
                        pass = false;
                        warningMsg = 'Please enter a value in "Height - ft" less than or equal to 999. ';
                        break;
                    }else if(Double.valueOf(pis.heightInch) >11 || Double.valueOf(pis.heightInch)<0){
                        System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().Height__c & Weight__c validation');
                        pass = false;
                        warningMsg = 'Please enter a value in "Height - inch" less than or equal to 11.';
                        break;
                    }
                }            
            }

            if(ptvs.policyTransactionValidationItem.showSmokingInd && null == pis.pi.Smoker__c){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().pis.pi.Insured_Type__c='+pis.pi.Insured_Type__c);
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() pi validation');
                pass = false;
                break;
            }
            /* add by Andy for BMI & Smoke validation end */
            
            /*add by Andy for Portable CR begin */
            if(newPolicy.Product_Code__c == '@PBTG'){
                if(String.isBlank(pis.pi.LHB_policy_number__c) 
                    || String.isBlank(pis.pi.LHB_certificate_number__c) ){
                    pass = false;
                    break;
                }else{
                    if( !pis.pi.LHB_policy_number__c.isNumeric() || pis.pi.LHB_policy_number__c.length() > 5 || pis.pi.LHB_policy_number__c.length() < 4){
                        pass = false;
                        warningMsg = 'LHB policy number only allow 4-5 numeric characters';
                        break;
                    }
                    if(pis.pi.LHB_certificate_number__c.length() != 7){
                        pass = false;
                        warningMsg = 'LHB certificate number only allow 7 characters only';
                        break;
                    }
                }       
            }
            /*add by Andy for Portable CR end */
            //AM project jack add
            /* add by Jack on 2022-10-12 for project: JOBR-217 Enhance Asiamiles membership info validation start*/
            // if(!((String.isBlank(pis.pi.Asia_Miles_Membership_First_Name__c) && String.isBlank(pis.pi.Asia_Miles_Membership_Last_Name__c) && String.isBlank(pis.pi.Asia_Miles_Membership_Num__c)) || (String.isNotBlank(pis.pi.Asia_Miles_Membership_First_Name__c) && String.isNotBlank(pis.pi.Asia_Miles_Membership_Last_Name__c) && String.isNotBlank(pis.pi.Asia_Miles_Membership_Num__c)))){
            //     pass = false;
            //     warningMsg = 'AM Fields are either all empty or all filled';
            //     break;
            // }
            // if(String.isNotBlank(pis.pi.Asia_Miles_Membership_Num__c) && pis.pi.Asia_Miles_Membership_Num__c.length() > 0){
            //     String piAMNumberResult = validateAsiaMilesNumber(pis.pi.Asia_Miles_Membership_Num__c);
            //     if(String.isNotBlank(piAMNumberResult)){
            //         pass = false;
            //         warningMsg = piAMNumberResult;
            //         break;     
            //     }
            // }
            String piAsiaMilesResult = validateAsiaMilesFields(pis.pi.Asia_Miles_Membership_First_Name__c, pis.pi.Asia_Miles_Membership_Last_Name__c,pis.pi.Asia_Miles_Membership_Num__c,ptvs.ctrl.isCXagent,false);
            if(String.isNotBlank(piAsiaMilesResult)){
                pass = false;
                warningMsg = piAsiaMilesResult;
                break;
            }
            
            
            //***************************************ph validation***************************************

            /* add by Jack on 2022-01-19 for project: IA AML */            
            if(String.isNotBlank(newPolicy.nationality__c) && TMPolicyUtil.nationalityMap.get(newPolicy.nationality__c).Sanction_Nationality__c){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> pi validation nationality validation');
                pass = false; 
                warningMsg = 'Cigna is prohibited from providing any service to persons with nationality of a sanctioned jurisdiction';
                break;
            }    

            if((String.isNotBlank(newPolicy.place_of_birth__c) && TMPolicyUtil.countryMap.get(newPolicy.place_of_birth__c).Sanction_Nationality__c) 
            || (String.isNotBlank(newPolicy.Residential_Address_Country__c) && TMPolicyUtil.countryMap.get(newPolicy.Residential_Address_Country__c).Sanction_Nationality__c)){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> pi validation country validation');
                pass = false; 
                warningMsg = 'Cigna is prohibited from providing any service to persons with Residential Address Country of a sanctioned jurisdiction';
                break;
            }
            /* add by Jack on 2022-01-19 for project: IA AML */
            //AM project jack add
            String asiaMilesResult = validateAsiaMilesFields(newPolicy.Asia_Miles_Membership_First_Name__c,newPolicy.Asia_Miles_Membership_Last_Name__c,newPolicy.Asia_Miles_Membership_Num__c,ptvs.ctrl.isCXagent,true);
            if(String.isNotBlank(asiaMilesResult)){
                pass = false;
                warningMsg = asiaMilesResult;
                break;
            }
            /* add by Jack on 2022-10-12 for project: JOBR-217 Enhance Asiamiles membership info validation end*/
            //jack add for Elite Revamp 2021
            /* add by Jack on 2022-01-28 for project: IA AML */
            // if(newPolicy.Product_Code__c=='VSTDG'||newPolicy.Product_Code__c=='VSMMG'||newPolicy.Product_Code__c=='VSUPG'){
            //     if(String.isBlank(PIS.pi.Place_of_Residence_picklist__c)){
            //         pass = false;
            //         break;
            //     }
            //     if(String.isBlank(newPolicy.Place_of_Residence_picklist__c)){
            //         pass = false;
            //         break;
            //     }
            // }
            /* add by Jack on 2022-01-28 for project: IA AML */

            if(null == newPolicy.Policy_Holder_First_Name__c
               || null == newPolicy.Policy_Holder_Last_Name__c
               || null == newPolicy.Gender__c
               || null == newPolicy.Date_of_Birth__c
               || null == newPolicy.ID_Type__c
               || null == newPolicy.Personal_ID__c
               || null == newPolicy.Mobile_Phone__c
               || null == newPolicy.Residential_Address_1__c
               /* add by Jack on 2022-01-19 for project: IA AML */
               || null == newPolicy.Place_of_Birth__c
               || null == newPolicy.Residential_Address_Country__c
               || null == newPolicy.nationality__c
               //|| null == newPolicy.Residential_Address_2__c
               //|| null == newPolicy.Residential_Address_3__c
               //|| null == newPolicy.Residential_Address_4__c                  
               //|| null == newPolicy.Relationship__c          commented by Andy DPSP-675
               || (!newPolicy.Is_Email_Needed__c && null == newPolicy.Policy_Holder_Email_Address__c)){
                   System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() ph validation');
                   pass = false;                
                   break;                
            }else if(null != newPolicy.Personal_ID__c){
                Matcher personalIdMatcher = personalIdPattern.matcher(newPolicy.Personal_ID__c);
                if(null!=personalIdMatcher && !personalIdMatcher.matches()){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField().personalIdMatcher='+personalIdMatcher.matches());
                    pass = false; 
                    warningMsg = 'Please input valid Personal ID number.';
                    break;                  
                }
            }
            
            Matcher phoneFormatMatcher = phonePattern.matcher(newPolicy.Mobile_Phone__c);
            if(null != phoneFormatMatcher && !phoneFormatMatcher.matches()){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> ph validation mobile phone fail');
                pass = false;
                warningMsg = 'Please input valid mobile phone number.';
                break;
            }
            
            if(String.isNotBlank(newPolicy.Home_Phone__c)){
                Matcher homePhoneFormatMatcher = phonePattern.matcher(newPolicy.Home_Phone__c);
                if(null != homePhoneFormatMatcher && !homePhoneFormatMatcher.matches()){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> ph validation home phone fail');
                    pass = false;
                    warningMsg = 'Please input valid home phone number.';
                    break;
                }
            }
            
            if(newPolicy.Date_of_Birth__c > Date.today()){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() >> ph validation DOB validation');
                pass = false; 
                warningMsg = 'Please input valid Date of Birth field.';
                break;
            }
            
            if(newPolicy.Is_Email_Needed__c && null != newPolicy.Policy_Holder_Email_Address__c){
                System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() ph validation email validation');
                pass = false; 
                warningMsg = 'Please check the email field.';
                break;
            }
            
            system.debug('[TMCreatePolicyStep3] newPolicy.Missing_CDD_Info__c='+newPolicy.Missing_CDD_Info__c);
            
            if(invalidAddress(newPolicy.Corresponding_Address_1__c) ||
               invalidAddress(newPolicy.Corresponding_Address_2__c) ||
               invalidAddress(newPolicy.Corresponding_Address_3__c) ||
               invalidAddress(newPolicy.Corresponding_Address_4__c) ||
               invalidAddress(newPolicy.Residential_Address_1__c) ||
               invalidAddress(newPolicy.Residential_Address_2__c) ||
               invalidAddress(newPolicy.Residential_Address_3__c) ||
               invalidAddress(newPolicy.Residential_Address_4__c) ||
               invalidAddress(pis.pi.Residential_Address_1__c) ||
               invalidAddress(pis.pi.Residential_Address_2__c) ||
               invalidAddress(pis.pi.Residential_Address_3__c) ||
               invalidAddress(pis.pi.Residential_Address_4__c) ){
                   pass = false; 
                   warningMsg = 'The length of each residential address has a limit of 80 characters.';
                   break;
               }
            // life product
            if(isShow == 1){
                if(//null == newPolicy.Corresponding_Address_1__c  
                    //||null == newPolicy.Corresponding_Address_2__c
                    //||null == newPolicy.Corresponding_Address_3__c
                    //||null == newPolicy.Corresponding_Address_4__c
                    null == newPolicy.Nationality__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() life product');
                    pass = false;
                    break;
                }else if(newPolicy.Source_of_Fund__c == '06 - Other (Please specify)' && null == newPolicy.Other_Source_of_Fund__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Source_of_Fund__c'); 
                    pass = false;                
                    break;
                }else if(newPolicy.Means_of_Income__c == 'Others' && null == newPolicy.Means_of_Income_Additional_Information__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Means_of_Income__c'); 
                    pass = false;                
                    break;
                }else if(newPolicy.Education_Level__c == 'Others' && null == newPolicy.Education_Level_Additional_Information__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Education_Level__c'); 
                    pass = false;                
                    break;
                }else if(newPolicy.Purpose_of_Insurance__c == 'Others' && null == newPolicy.Purpose_of_Insurance_Others__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Purpose_of_Insurance__c'); 
                    pass = false;                
                    break;
                }
                //Nicole_20200408_CDD
                else if(String.IsBlank(newPolicy.Company__c) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Company__c'); 
                    pass = false;                
                    break;
                }
                //Nicole_CDDUAT-1_20200427
                /*else if((String.IsBlank(newPolicy.Company_Address__c) || String.IsBlank(newPolicy.Company_Address_1__c)) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Company_Address__c + Company_Address_1__c'); 
                    pass = false;                
                    break;
                }*/
                else if(String.IsBlank(newPolicy.Company_Address_1__c) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() + Company_Address_1__c'); 
                    pass = false;                
                    break;
                }
                else if(String.IsBlank(newPolicy.Position__c) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Position__c'); 
                    pass = false;                
                    break;
                }else if((String.IsBlank(newPolicy.Other_Job__c) && newPolicy.Position__c=='其他 - Others') && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Other_Job__c'); 
                    pass = false;                
                    break;
                }else if(String.IsBlank(newPolicy.Business_Nature__c) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Business_Nature__c'); 
                    pass = false;                
                    break;
                }else if((String.IsBlank(newPolicy.Industry__c) && newPolicy.Business_Nature__c=='以上皆否 - None of the above') && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Industry__c'); 
                    pass = false;                
                    break;
                }else if(String.IsBlank(newPolicy.Means_of_Income__c) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Means_of_Income__c'); 
                    pass = false;                
                    break;
                }else if(String.IsBlank(newPolicy.Income_HKD__c) && !newPolicy.Missing_CDD_Info__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() Income_HKD__c'); 
                    pass = false;                
                    break;
                }
            }
            //CRS product
            if(isShowCRSField == 1){
                if(null == newPolicy.Place_of_Birth__c || null == newPolicy.Tax_Residence_1__c){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() CRS product');
                    pass = false;
                    break;
                }               
            }
            //AML product
            if(isAML){
                system.debug('[TMCreatePolicyStep3Strategy] isAML Country__c = '+ newPolicy.Country__c);
                if(null == newPolicy.Source_of_Fund__c
                    || null == newPolicy.Means_of_Income__c
                    //|| null == newPolicy.Income_HKD__c  // Chapin's Email(29/10/2018 (周一) 2:34 PM) : SFDC Day 1 - Change of Compulsory Field & Optional Field
                    || null == newPolicy.Purpose_of_Insurance__c
                    || null == newPolicy.Education_Level__c
                    || null == newPolicy.Business_Nature__c
                    //|| (displayCompanyPosition
                    ||(ptvs.ctrl.isShow == 1
                        && (null == newPolicy.Company__c|| null == newPolicy.Position__c || null == newPolicy.Country__c))){
                    System.debug('[TMCreatePolicyStep3Strategy] checkPIPHRequiredField() AML product');
                    pass = false;
                    break;
                }
                
            }            
            no++;
        }
        
        if(pass == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, warningMsg));
        }

        return pass;
    }
    
    private void updateBeneficaryName(List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList){
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            for(TMCreatePolicyCtrl.BeneficiaryStruct bs : pis.beneficiaryList){
                bs.PIName = pis.pi.Insured_First_Name__c + pis.pi.Insured_Last_Name__c;
                if('Dependent'.equals(pis.pi.Insured_Type__c) && '@SP100'.equals(pis.piPolicy.product_code__c) ){
                    bs.beneficiary.First_Name__c = ptvs.ctrl.newPolicy.Policy_Holder_First_Name__c;
                    bs.beneficiary.Last_Name__c = ptvs.ctrl.newPolicy.Policy_Holder_Last_Name__c;
                    bs.beneficiary.Person_ID__c = ptvs.ctrl.newPolicy.Personal_ID__c;
                    bs.beneficiary.Beneficiary_Type__c = 'Primary';
                    bs.beneficiary.Gender__c = ptvs.ctrl.newPolicy.Gender__c;
                    bs.beneficiary.Relationship__c = 'Policy Holder';
                    bs.beneficiary.Percent__c = 100;
                }
            }
        }
    }
    
    private boolean invalidAddress(String addr){
        if(String.isNotBlank(addr) && addr.length() > 80){
            return true;
        }
        return false;
    }
    /**
    private void updateBankAccoutNumber(New_Policy__c newPolicy){
        if(String.isNotBlank(newPolicy.Personal_ID__c) && String.isBlank(newPolicy.Bank_Account_No__c) 
            && String.isBlank(newPolicy.Credit_Card_Number__c)){
            system.debug('[TMCreatePolicyStep3Strategy] updateBankAccoutNumber() Get Bank Account Number from WS >> Personal Id : ' + newPolicy.Personal_ID__c );    
            PersonCalloutHelper personCalloutHelper = new PersonCalloutHelper();
            List<HttpCalloutVO.PersonPayment> personPaymentList = personCalloutHelper.getPersonPaymentBasic(newPolicy.Personal_ID__c);
            if(!personPaymentList.isEmpty()){
                HttpCalloutVO.PersonPayment pp = personPaymentList[0];
                newPolicy.Bank_Account_No__c = pp.accountNumber;
                newPolicy.Bank_Account_No_Mask__c = TMPolicyUtil.maskBankAccountNumber(pp.accountNumber);
                newPolicy.Credit_Card_Number__c = pp.accountNumber;
                newPolicy.Credit_Card_Number_Mask__c = TMPolicyUtil.maskBankAccountNumber(pp.accountNumber);
                system.debug('[TMCreatePolicyStep3Strategy] updateBankAccoutNumber() Get Bank Account Number from WS Success>> Bank Acc No. : ' + pp.accountNumber);  
            }
        }
    }
    **/
    
     // add by jack for policy replacement

    @TestVisible private void clearPresalesResult(TMCreatePolicyCtrl ctrl){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ctrl.personInsuredStructureList){
            if(!pis.piValidationItem.needPresales){
                pis.piPolicy.Pre_Sales_Result__c = null;
            }else{
                Set<String> tempPrePISSet = new Set<String>();
                if(!TMPolicyUtil.compare2Object(pis.piPolicy.Presales_Result_Attribute__c,pis.pi)){
                    pis.piPolicy.Pre_Sales_Result__c = null;
                    pis.presalesResultMsgList = new List<TMEsalesHelper.PreSalesResultMessage>();
                    pis.piPolicy.PreSales_Result_Msg__c = null;
                    system.debug('TMPolicyUtil before giving value pis.piPolicy.Pre_Sales_Result__c:'+pis.piPolicy.Pre_Sales_Result__c+' pis.presalesResultMsgList:'+pis.presalesResultMsgList+' pis.piPolicy.PreSales_Result_Msg__c:'+pis.piPolicy.PreSales_Result_Msg__c);
                }
            }
        }
    }

    @TestVisible private void setIsReplacement(TMCreatePolicyCtrl ctrl){
        
        String customerChoice ;
        String internalInfo;
        if(String.isNotBlank(ctrl.policyTransaction.PolicyReplacement__c)){
            customerChoice = ctrl.policyTransaction.PolicyReplacement__c;  
            if(ctrl.GAList.contains(ctrl.selectedProduct.Product_Code__c)){
               clearPresalesResult(ctrl);
            }
        }
        
            system.debug('[TMCreatePolicyStep3Strategy] setIsReplacement() customerChoice' + customerChoice);
            if(customerChoice !=Null && String.isNotBlank(customerChoice)){
                if(customerChoice == 'Not yet decided' || customerChoice == 'Yes'){
                    for(TMCreatePolicyCtrl.PersonInsuredStructure pisLoop1 : ctrl.personInsuredStructureList){
                        pisLoop1.piPolicy.isReplacement__c = true;
                    }
                    // if(pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED){
                    //     pis.piPolicy.Pre_Sales_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED; 
                    // }
                }else{
                    try{
                        TMCreatePolicyCtrl.PersonInsuredStructure pis;
                        for(TMCreatePolicyCtrl.PersonInsuredStructure pisLoop : ctrl.personInsuredStructureList){
                            if(pisLoop.pi.Relationship__c == 'Policy Holder'){
                                pis = pisLoop;
                                break;
                            }
                        }
                        system.debug('[TMCreatePolicyStep3Strategy] pis' + pis);
                        if(pis != null){
                            policyCalloutHelper helper = new policyCalloutHelper();
                            List<HttpCalloutVO.policyReplacement> plist= helper.GetPolicyReplacementChangeHistory(pis.piPolicy.Policy_No__c,PIS.pi.Personal_ID__c,null);
                            system.debug('[TMCreatePolicyStep3Strategy] setIsReplacement() plist' + plist);
                            Boolean isReplacementWS = false;
                            if(plist.size()>0){
                                /*Set<String> polNumberSet = new Set<String>();
                                for(HttpCalloutVO.policyReplacement replacement : pList){
                                    if(String.isNotBlank(replacement.polNumber)){
                                        polNumberSet.add(replacement.polNumber);
                                    }
                                }
                                system.debug('[TMCreatePolicyStep3Strategy] setIsReplacement() polNumberSet' + polNumberSet);
                                if(polNumberSet.contains(pis.piPolicy.Policy_No__c)){
                                    polNumberSet.remove(pis.piPolicy.Policy_No__c);
                                }
                                system.debug('[TMCreatePolicyStep3Strategy] setIsReplacement() polNumberSet' + polNumberSet);
                                */

                                if(plist[0].replacementInfoList.size() > 0 ){
                                    isReplacementWS = true;
                                    // system.debug('[TMCreatePolicyStep3Strategy] PIS.pi.Relationship__c: '+PIS.pi.Relationship__c);
                                    // if(PIS.pi.Relationship__c == 'Policy Holder'){
                                    //     system.debug('[TMCreatePolicyStep3Strategy] policy holder hit policy replacement');
                                    //     for(TMCreatePolicyCtrl.PersonInsuredStructure pisInLoop : ctrl.personInsuredStructureList){
                                    //         pisInLoop.piPolicy.isReplacement__c = true;
                                    //     }
                                    //     system.debug('[TMCreatePolicyStep3Strategy] break');
                                    //     break;
                                    // }else{
                                    //     system.debug('[TMCreatePolicyStep3Strategy] non policy holder hit policy replacement');
                                    //     pis.piPolicy.isReplacement__c = true;
                                    // }
                                    

                                    // if(pis.piPolicy.Pre_Sales_Result__c == TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED){
                                    //     pis.piPolicy.Pre_Sales_Result__c = TMCreatePolicyCtrl.PRESALES_UW_RESULT_REFERRED; 
                                    // }
                                }else{
                                    isReplacementWS = false;
                                }
                            }else{
                                isReplacementWS = false;
                            }
                            system.debug('[TMCreatePolicyStep3Strategy] isReplacementWS' + isReplacementWS);
                            if(isReplacementWS){
                                for(TMCreatePolicyCtrl.PersonInsuredStructure pisLoop2 : ctrl.personInsuredStructureList){
                                    pisLoop2.piPolicy.isReplacement__c = true;
                                }
                            }else{
                                for(TMCreatePolicyCtrl.PersonInsuredStructure pisLoop3 : ctrl.personInsuredStructureList){
                                    pisLoop3.piPolicy.isReplacement__c = false;
                                }
                            }
                        }
                    }catch(Exception e){
                        system.debug(e);
                    }
                    
                }
            }
            
        
    }
    /* add by Jack on 2022-10-12 for project: JOBR-217 Enhance Asiamiles membership info validation */
    /**
    * @description check if asia meiles number meets validation
    * @author jackshao@deloitte.com.cn | 10-05-2022 
    * @param String asiaMilesNumber 
    * @return Boolean 
    **/
    public String validateAsiaMilesNumber(String asiaMilesNumber){
        String warningMsg='';
        if(String.isBlank(asiaMilesNumber)){
            return warningMsg;
        }
        if(asiaMilesNumber.length() <> 10){
            warningMsg = 'AM membership num should include 10 digits.';
        }else{
           integer checksum = 0; 
            
           if(asiaMilesNumber.isNumeric() == false){
                warningMsg = 'Only number is allowed in PH AM membership num.';
                return warningMsg;
            }
            
           checksum = Integer.ValueOf(asiaMilesNumber.substring(0,1)) * 1 +
                      Integer.ValueOf(asiaMilesNumber.substring(1,2)) * 2  +
                      Integer.ValueOf(asiaMilesNumber.substring(2,3)) * 3  +
                      Integer.ValueOf(asiaMilesNumber.substring(3,4)) * 4  +
                      Integer.ValueOf(asiaMilesNumber.substring(4,5)) * 5  +
                      Integer.ValueOf(asiaMilesNumber.substring(5,6)) * 6  +
                      Integer.ValueOf(asiaMilesNumber.substring(6,7)) * 7 +
                      Integer.ValueOf(asiaMilesNumber.substring(7,8)) * 8  +
                      Integer.ValueOf(asiaMilesNumber.substring(8,9)) * 9 ;
           
            if(Math.mod(checksum,10) <>Integer.ValueOf(asiaMilesNumber.substring(9,10))) {
                warningMsg = 'Invalid AM membership num.';
            }                         
        } 
        return warningMsg;
    }

    /**
    * @description validate Asia Miles fields
    * @author jackshao@deloitte.com.cn | 10-05-2022 
    * @return boolean 
    **/
    public String validateAsiaMilesFields(String AMfirstName,String AMlastName,String AMNumber,Boolean isAM,Boolean isPH){
        String warningMsg='';
        if(isAM){
            if(String.isBlank(AMNumber) && isPH){
                warningMsg = 'AM membership num is mandatory when it is CX agent';
            }else if(AMNumber == '0000000000'){
            }else{
                if(String.isBlank(AMlastName) || String.isBlank(AMfirstName)){
                    warningMsg = 'AM membership first name and last name are mandatory when it is CX agent'; 
                }else{
                    warningMsg = validateAsiaMilesNumber(AMNumber);
                }
            }
        }else{
            if(!((String.isBlank(AMfirstName) && String.isBlank(AMlastName) && String.isBlank(AMNumber)) || (String.isNotBlank(AMfirstName) && String.isNotBlank(AMlastName) && String.isNotBlank(AMNumber)))){
                warningMsg = 'AM Fields are either all empty or all filled';
                return warningMsg;
            }
            if(String.isNotBlank(AMNumber) && AMNumber.length() > 0){
                warningMsg = validateAsiaMilesNumber(AMNumber);
            }
        }
        return warningMsg;
    }
}