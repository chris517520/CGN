/********************************************************************************
 * Apex Class Name - TMCreatePolicyStep7Strategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps 7
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMCreatePolicyStep7Strategy implements TMCreatePolicyStepStrategy{
     
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public static final String PAYMENT_MONTHLY='Monthly';
    public static final String PAYMENT_ANNUAL='Annual';
    public static final String PAYMENT_TYPE_CHEQUE='Cheque';
    public Map<String,String> discountCodeDiscountDescriptionMap;
    
    public static Map<String,String> genderSalutationMap=new Map<String,String>{
        'Male'=>'Mr.',
        'Female'=>'Ms.'
    };
        
    private String AccID='';
    
    public TMCreatePolicyStep7Strategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        this.ptvs=ptvs;
        discountCodeDiscountDescriptionMap=new Map<String,String>();
        List<Discount_Code__c> discountList=[select Code__c,Description__c from Discount_Code__c];
        for(Discount_Code__c discount : discountList){
            discountCodeDiscountDescriptionMap.put(discount.Code__c, discount.Description__c);
        }
    }
    
    public void stepInit(){        
        ptvs.ctrl.isComplete=true;
        setDiscountCodeToPolicy();
        amendAccountRecordType(ptvs.ctrl.newPolicy);  //add by andy TS-609
        //changeUWResult();
        //AH18329
        if(String.isBlank(AccID)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Policy is completed.'));
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                                       'Because the SSN of PH of this policy is different from the Account, thus, a new account for the actual PH of this policy would be created by the system automatically'));
        }
        //AH18329
    }
    
    public Boolean stepValidation(){
        //save step6, when user click 'edit' to go into the policy next time, step 6 page will be displayed, not the completed page(step7)
        if(step7Validation(ptvs.ctrl.selectedPaymentType,ptvs.ctrl.selectedPaymentFrequency,ptvs.ctrl.displayOptionalField,ptvs.ctrl.selectedBank,ptvs.ctrl.newPolicy
                                   ,ptvs.ctrl.displayCreditCardOptionalField,ptvs.ctrl.selectedCreditCardBank)){
            ptvs.ctrl.currentStep -= 1;//to display the paymentInformaiton page
            ptvs.ctrl.canSave=false;
            return true;
        }else{
            ptvs.ctrl.currentStep -= 1;
            ptvs.ctrl.canSave=false;
            return false;
        }
    }
    
    public void nextStep(){}
    
    private Boolean step7Validation(String selectedPaymentType,String selectedPaymentFrequency,Boolean displayOptionalField,String selectedBank,New_policy__c newPolicy
                                       ,Boolean displayCreditCardOptionalField,String selectedCreditCardBank){
        
        
        boolean notNull=true;
        String errorMsg='You must enter a value in the required field';
        String patMon='[0-1]{1}[0-9]{1}';
        Pattern rMon=Pattern.compile(patMon);
        String patYear='[1-9]{1}[0-9]{3}';
        Pattern rYear=Pattern.compile(patYear);
        //|| String.isEmpty(newPolicy.Appeal_For_UW_Result__c)
        //Rancho_HKITSFDC402_20250930 - discount 83 only available for up to 5 policies
        Integer discount83Count = 0;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            /**
            if(String.isEmpty(pis.piPolicy.Appeal_For_UW_Result__c)&&pis.piValidationItem.needAUW==true){
                notNull=false;
                break;
            }
            **/
            System.debug('[TMCreatePolicyStep7Strategy] step7Validation Policy_Status__c >> '+pis.piPolicy.Policy_Status__c);
            System.debug('[TMCreatePolicyStep7Strategy] step7Validation isDuplicate >> '+pis.piValidationItem.isDuplicate);
            System.debug('[TMCreatePolicyStep7Strategy] step7Validation otherValidation >> '+pis.piValidationItem.otherValidation);
            System.debug('[TMCreatePolicyStep7Strategy] step7Validation Pre_Sales_Result__c >> '+pis.piPolicy.Pre_Sales_Result__c);
            //DPSP-1018 : when pre-sales result=declined,display a "submit" button to end the application
            if(!'Invalid'.equals(pis.piPolicy.Policy_Status__c)&&(pis.piValidationItem.otherValidation==false || pis.piValidationItem.isDuplicate==true || TMCreatePolicyCtrl.PRESALES_UW_RESULT_DECLINED.equals(pis.piPolicy.Pre_Sales_Result__c))){
                notNull=false;
                errorMsg='Any Person is not eligible.Please remove not eligible policy before submitting.';
                break;
            }
            
            if(notNull){ // add by kermit. To check Master_policy_no__c is null or not
                if(String.isBlank(pis.piPolicy.Master_Policy_No__c)){
                    notNull=false;
                    errorMsg='Master Policy No. of Person Insured '+ (ptvs.ctrl.personInsuredStructureList.indexOf(pis)+1)+'should not be empty,default is '+pis.PIDefaultMasterPolicyNum;
                    break;
                }
            }

            //GL31 jack add
            if(!Test.isRunningTest() && cignaUtil.checkAssessResult('','',ptvs.ctrl.policyTransaction.Prod_Rider_Map__c,ptvs.ctrl.selectedProduct.Product_Code__c,pis.selectedRidersMap.keySet(),true,true) != CignaUtil.FINE_RESULT){
                notNull=false;
                errorMsg='Sorry, the selected product riders do not hit with the needs assessment. Please try again.';
                break;
            }
            //AM project coupon jack add for coupon status validate
            if(pis.couponMap != null && pis.couponMap.values()!=null && pis.couponMap.values().size()>0 && !couponUtil.checkCouponValid(pis.couponMap.values())){
                notNull=false;
                errorMsg='Policy cannot be submitted because it contains invalid coupons, please remove them.';
                break;
            }
            /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
            // if(!discount12MonthChecking()){
            //     notNull=false;
            //     errorMsg='Client owns lapsed/surrendered policy in past 12 months';
            //     break;
            // }
            // jack add for friend and family discount in SFDC
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            System.debug('discount info: '+pis.discount1+', '+pis.discount2+', '+pis.referralPolicyNum);
            if(((String.isNotBlank(pis.discount1)&&ptvs.ctrl.discountCodeMap.containsKey(pis.discount1)&&ptvs.ctrl.discountCodeMap.get(pis.discount1).group__c=='FAMILY DISCOUNT') || (String.isNotBlank(pis.discount2)&&ptvs.ctrl.discountCodeMap.containsKey(pis.discount2)&&ptvs.ctrl.discountCodeMap.get(pis.discount2).group__c=='FAMILY DISCOUNT'))
                &&String.isBlank(pis.referralPolicyNum)){
                notNull=false;
                errorMsg='Ineligible discount selected';
            }
            // Rancho_HKITSFDC402_20250930 - discount 83 only available for up to 5 policies
            if('YR1 50% DISCOUNT'.equalsIgnoreCase(pis.discount1) || 'YR1 50% DISCOUNT'.equalsIgnoreCase(pis.discount2)){
                discount83Count++;
            }
        }

        if(discount83Count > 5){
            notNull=false;
            errorMsg='Ineligible discount selected';
        }

        if(notNull){
            if(null!=ptvs.ctrl.premiumAmountList&&ptvs.ctrl.premiumAmountList.size() > 0&&(String.isEmpty(selectedPaymentType) || String.isEmpty(selectedPaymentFrequency)))
                notNull=false;
        }

        System.debug('displayCreditCardOptionalField >> '+displayCreditCardOptionalField);
        System.debug('selectedPaymentType >> '+selectedPaymentType);
        if(notNull){
            if(displayOptionalField){
                //JR1896 - JR - annual mode premium payment for DDA optio, allow payment frequency 12/05/2021 Tovid
                /*if(selectedPaymentFrequency != PAYMENT_MONTHLY){
                    errorMsg = 'Direct Billing only apply to Monthly Payment Frequency';
                    notNull = false;
                }else*/
                if(String.isEmpty(newPolicy.Bank_Account_No__c)){//String.isEmpty(selectedBank) 
                    notNull=false;
                }else if(!newPolicy.Bank_Account_No__c.isNumeric()){
                    errorMsg='The Bank account number can only be number.';
                    notNull=false;
                }else if(newPolicy.Bank_Account_No__c.length() > 20){
                    errorMsg='The max length of Bank account number is 20 character.';
                    notNull=false;
                }
            }
            if(selectedPaymentType==PAYMENT_TYPE_CHEQUE&&selectedPaymentFrequency!=PAYMENT_ANNUAL){
                errorMsg='Cheque only apply to Annual Payment Frequency';
                notNull=false;
            }
            // Rancho_CreditCardIssue_20250318 - credit card number must have value if payment type is Credit Card Billing
            // if(displayCreditCardOptionalField){
            if(String.isNotBlank(selectedPaymentType) && 'Credit Card Billing'.equals(selectedPaymentType)){ 
                if(  //String.isEmpty(selectedCreditCardBank) //Chapin's Email(02/11/2018 (周五) 1:34 PM) : production: credit card billing - name of card issuing bank is optional
                      //||String.isEmpty(newPolicy.Credit_Card_Holder_Full_Name__c)
                       String.isEmpty(newPolicy.Credit_Card_Number__c) 
                      //|| String.isEmpty(selectedCardMonth)
                      //|| String.isEmpty(selectedCardYear)
                      || String.isEmpty(newPolicy.Credit_Card_Type__c)){
                    notNull=false;                                                
                }else{
                    /**
                    Matcher mMon=rMon.matcher(selectedCardMonth);
                    Matcher mYear=rYear.matcher(selectedCardYear);
                    System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>mMon:'+mMon.matches());
                    System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>mYear:'+mYear.matches());
                    if(!mMon.matches() || !mYear.matches()){
                        errorFormat='Please enter the correct Card Expiry Date format.';
                        notNull=false;
                    }else if(Integer.valueOf(selectedCardMonth) > 12 || Integer.valueOf(selectedCardMonth) < 1){
                        errorFormat='The month of Card Expiry Date cannot be greater than 12 or less than Zero.';
                        notNull=false;
                    }else if(Integer.valueOf(selectedCardYear) < Date.today().year()){
                        errorFormat='The year of Card Expiry Date cannot be less than this year.';
                        notNull=false;
                    }else if(Integer.valueOf(selectedCardYear)==Date.today().year()&&Integer.valueOf(selectedCardMonth) <= Date.today().month()){
                        errorFormat='The month of Card Expiry Date cannot be less than this month.';
                        notNull=false;
                    }
                    **/
                    
                    //String patCardNumber='[0-9]{16,}';
                    // 20200717 - minghua - SF Modeling
                    String patCardNumber;
                    if('CC'.equals(newPolicy.Credit_Card_Type__c)){
                        // patCardNumber='4+[0-9]{15,15}';
                        patCardNumber= '4[0-9]{3}([0-9]{8}|X{8}|\\*{8})[0-9]{4}';
                    }else{
                        // patCardNumber='5+[0-9]{15,15}';
                        patCardNumber= '5[0-9]{3}([0-9]{8}|X{8}|\\*{8})[0-9]{4}';
                    }
                    Pattern rCardNum=Pattern.compile(patCardNumber);
                    Matcher mCardNum=rCardNum.matcher(newPolicy.Credit_Card_Number__c);
                    System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>mCardNum:'+mCardNum.matches());
                    if(!mCardNum.matches() || newPolicy.Credit_Card_Number__c.length() > 16){
                        //errorMsg='Please enter the correct Card Number format.';
                        errorMsg='The Card Number format is invalid,please enter a valid Card Number';
                        notNull=false;
                    }
                }                                      
            }
        }
        
        //Nicole_CDD_20200504         
        if(ptvs.ctrl.newPolicy.Missing_CDD_Info__c&&String.IsBlank(ptvs.ctrl.policyTransaction.LC_Assessed__c)){
            notNull=false;
            errorMsg='Please note this policy is still pending because it is a missing CDD information case and needs L&C further assessment';
        }else if(String.IsNotBlank(ptvs.ctrl.policyTransaction.LC_Assessed__c)&&
             (String.IsBlank(ptvs.ctrl.policyTransaction.LC_Reviewer__c) || ptvs.ctrl.policyTransaction.LC_Reviewer_Date__c==null)){
            notNull=false;
        }

        if(!notNull){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));
        }

        if(notNull){// Validation pass,keep the account No. or credit card No. according to payment type
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                if('Credit Card Billing'.equals(selectedPaymentType)){
                    pis.piPolicy.Bank_Account_No__c='';
                    pis.piPolicy.Bank_Account_No_Mask__c='';
                }else if('Direct Billing'.equals(selectedPaymentType)){
                    pis.piPolicy.Credit_Card_Number__c='';
                    pis.piPolicy.Credit_Card_Number_Mask__c='';
                }else if('Cheque'.equals(selectedPaymentType)){
                    pis.piPolicy.Bank_Account_No__c='';
                    pis.piPolicy.Bank_Account_No_Mask__c='';
                    pis.piPolicy.Credit_Card_Number__c='';
                    pis.piPolicy.Credit_Card_Number_Mask__c='';
                }
            }
        } 

        return notNull;
    }

    /*
    * TS-609
    * update respective account with PH information (DPSP-675)
    * change account record type
    * if currently the account (record type=customer) exists,merge account record 
    * (i.e. move TM customer records and related lists to customer records then delete TM customer records)
    */
    private void amendAccountRecordType(New_policy__c newPolicy){
        String ssn=newPolicy.Personal_ID__c.toUpperCase();
        List<Account> possibleDuplicateAccList=[Select id,lastname,firstname,salutation,Chinese_Name__c,PersonMobilePhone,PersonEmail,Fax,SSN__c,Gender__c,PersonBirthdate__c,Age__c,Nationality__c,TM_Industry__c,Home_Address_Line_1__c,Home_Address_Line_2__c,Home_Address_Line_3__c,Home_Address_Line_4__c,PersonHomePhone,RecordType.developerName from Account where SSN__c=:ssn  and (RecordType.developerName='Customer' or RecordType.developerName='TM_Customer') ];
        if(!possibleDuplicateAccList.isEmpty()){
            //If these two a different account then put it into delete list
            Account ac=possibleDuplicateAccList[0];
                
            if(ac.id!=newPolicy.Account__c){
                String newAccountId=newPolicy.Account__c;
                
                system.debug('TM Customer >> '+newPolicy.Account__c+' has existing account >>'+ac.id);
                system.debug('Update account with PH information begin : '+ac.Id);
                ac.lastname=newPolicy.Policy_Holder_Last_Name__c;
                ac.firstname=newPolicy.Policy_Holder_First_Name__c;
                ac.Chinese_Name__c=newPolicy.Policy_Holder_Name_Chi__c;
                ac.PersonMobilePhone=newPolicy.Mobile_Phone__c;
                ac.PersonEmail=newPolicy.Policy_Holder_Email_Address__c;
                ac.Gender__c=newPolicy.Gender__c;
                if(ac.Gender__c=='Female'&&ac.Salutation=='Mr.'){
                    ac.Salutation=genderSalutationMap.get(ac.Gender__c);
                }else if(ac.Gender__c=='Male'&&(ac.Salutation=='Mrs.' || ac.Salutation=='Ms.')){
                    ac.Salutation=genderSalutationMap.get(ac.Gender__c);
                }
                ac.PersonBirthdate__c=newPolicy.Date_of_Birth__c;
                ac.Age__c=newPolicy.Age__c;
                ac.Nationality__c=newPolicy.Nationality__c;
                ac.PersonHomePhone=newPolicy.Home_Phone__c;
                ac.Office_Phone__c=newPolicy.Office_Phone__c;
                ac.Home_Address_Line_1__c=newPolicy.Residential_Address_1__c;
                ac.Home_Address_Line_2__c=newPolicy.Residential_Address_2__c;
                ac.Home_Address_Line_3__c=newPolicy.Residential_Address_3__c;
                ac.Home_Address_Line_4__c=newPolicy.Residential_Address_4__c;
                
                update ac;
                system.debug('Update account with PH information end : '+ac.Id);
            }else{
                system.debug('TM Customer >> '+newPolicy.Account__c+' already has input SSN >>'+newPolicy.Personal_ID__c);
                system.debug('Update account with PH information begin : '+ac.Id);
                ac.lastname=newPolicy.Policy_Holder_Last_Name__c;
                ac.firstname=newPolicy.Policy_Holder_First_Name__c;
                ac.Chinese_Name__c=newPolicy.Policy_Holder_Name_Chi__c;
                ac.PersonMobilePhone=newPolicy.Mobile_Phone__c;
                ac.PersonEmail=newPolicy.Policy_Holder_Email_Address__c;
                ac.Gender__c=newPolicy.Gender__c;
                if(ac.Gender__c=='Female'&&ac.Salutation=='Mr.'){
                    ac.Salutation=genderSalutationMap.get(ac.Gender__c);
                }else if(ac.Gender__c=='Male'&&(ac.Salutation=='Mrs.' || ac.Salutation=='Ms.')){
                    ac.Salutation=genderSalutationMap.get(ac.Gender__c);
                }
                ac.PersonBirthdate__c=newPolicy.Date_of_Birth__c;
                ac.Age__c=newPolicy.Age__c;
                ac.Nationality__c=newPolicy.Nationality__c;
                ac.PersonHomePhone=newPolicy.Home_Phone__c;
                ac.Office_Phone__c=newPolicy.Office_Phone__c;
                ac.Home_Address_Line_1__c=newPolicy.Residential_Address_1__c;
                ac.Home_Address_Line_2__c=newPolicy.Residential_Address_2__c;
                ac.Home_Address_Line_3__c=newPolicy.Residential_Address_3__c;
                ac.Home_Address_Line_4__c=newPolicy.Residential_Address_4__c;
                
                update ac;
                system.debug('Update account with PH information end : '+ac.Id);
                
            }
        }else{
            system.debug('TM Customer >> '+newPolicy.Account__c+' is new customer, process change Record Type begin');
            Account ac=[Select id,lastname,firstname,salutation,Chinese_Name__c,PersonMobilePhone,PersonEmail,Fax,SSN__c,Gender__c,PersonBirthdate__c,Age__c,Nationality__c,TM_Industry__c,Home_Address_Line_1__c,Home_Address_Line_2__c,Home_Address_Line_3__c,Home_Address_Line_4__c,PersonHomePhone,RecordType.developerName,recordTypeId from Account where id=:newPolicy.Account__c];
                            
            //AH18329
            if(String.isBlank(ac.SSN__c)){
                system.debug('Update account with PH information begin : '+ac.Id);
                ac.lastname=newPolicy.Policy_Holder_Last_Name__c;
                ac.firstname=newPolicy.Policy_Holder_First_Name__c;
                ac.Chinese_Name__c=newPolicy.Policy_Holder_Name_Chi__c;
                ac.PersonMobilePhone=newPolicy.Mobile_Phone__c;
                ac.PersonEmail=newPolicy.Policy_Holder_Email_Address__c;
                ac.Gender__c=newPolicy.Gender__c;
                if(ac.Gender__c=='Female'&&ac.Salutation=='Mr.'){
                    ac.Salutation=genderSalutationMap.get(ac.Gender__c);
                }else if(ac.Gender__c=='Male'&&(ac.Salutation=='Mrs.' || ac.Salutation=='Ms.')){
                    ac.Salutation=genderSalutationMap.get(ac.Gender__c);
                }
                ac.PersonBirthdate__c=newPolicy.Date_of_Birth__c;
                ac.SSN__c=newPolicy.Personal_ID__c;
                ac.Age__c=newPolicy.Age__c;
                ac.Nationality__c=newPolicy.Nationality__c;
                ac.PersonHomePhone=newPolicy.Home_Phone__c;
                ac.Office_Phone__c=newPolicy.Office_Phone__c;
                ac.Home_Address_Line_1__c=newPolicy.Residential_Address_1__c;
                ac.Home_Address_Line_2__c=newPolicy.Residential_Address_2__c;
                ac.Home_Address_Line_3__c=newPolicy.Residential_Address_3__c;
                ac.Home_Address_Line_4__c=newPolicy.Residential_Address_4__c;
                //ac.recordTypeId=customerRt[0].Id;
            
                update ac;
                
                system.debug('Update account with PH information end : '+ac.Id);
            }else{
                Account newAcc=createAccountWithExistingInfo(newPolicy);
                system.debug('[TMCreatePolicyStep7Strategy] createAccountWithExistingInfo newAcc='+newAcc);
                if(newAcc.Id!=null){
                    AccId=newAcc.Id;
                    /*Opportunity newOpp=createOpptyWithExistingInfo(newPolicy,newAcc);
                    system.debug('[TMCreatePolicyStep7Strategy] createOpptyWithExistingInfo newOpp='+newOpp);
                    if(newOpp.Id!=null){
                        assignTransactionToNewOppty(ptvs.ctrl.policyTransaction, ptvs.ctrl.personInsuredStructureList, newAcc, newOpp);
                        Opportunity temp=[SELECT Id, Opportunity_Id__c from Opportunity WHERE Id=:newOpp.Id];
                        OpptyID=temp.Opportunity_ID__c;
                    }*/
                }
                //system.debug('[TMCreatePolicyStep7] created new account & oppty because the personal ID of holder is different from the account\'s');
            }
            //AH18329
        }
    }
    
    private void setDiscountCodeToPolicy(){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            pis.piPolicy.Discount_Code_1_to_IPAS__c=null;
            pis.piPolicy.Discount_Code_2_to_IPAS__c=null;
            System.debug('[TMCreatePolicyStep7Strategy]pis.availableDiscountMap='+pis.availableDiscountMap);
            // Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - allow select different discount for each policy
            Map<String,Decimal> discountToApply=TMPolicyUtil.getPremiumDiscounts(pis.availableDiscountMap, ptvs.ctrl.selectedProduct, ptvs.ctrl.paymentFrequencyDiscountMap, ptvs.ctrl.premiumDiscountMap, pis.discount1, pis.discount2, ptvs.ctrl.selectedPaymentFrequency, false);
            System.debug('discountToApply.keySet(): '+discountToApply.keySet());
            for(String discountDescr : discountToApply.keySet()){
                System.debug('[TMCreatePolicyStep7Strategy]TMPolicyUtil.getProductDiscountPercent(discountDescr)='+TMPolicyUtil.getProductDiscountPercent(discountDescr));
                if(null!=TMPolicyUtil.getProductDiscountPercent(discountDescr)){//check whether discount belongs to productDiscount
                    if(null==pis.piPolicy.Discount_Code_1_to_IPAS__c)
                        pis.piPolicy.Discount_Code_1_to_IPAS__c=TMPolicyUtil.getDiscountCode(discountDescr);
                    else if(null==pis.piPolicy.Discount_Code_2_to_IPAS__c)
                        pis.piPolicy.Discount_Code_2_to_IPAS__c=TMPolicyUtil.getDiscountCode(discountDescr);
                }
                /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
                // else if(null!=ptvs.ctrl.premiumDiscountMap.get(discountDescr)&&ptvs.ctrl.premiumDiscountMap.get(discountDescr).Mandatory__c){
                //     if(null==pis.piPolicy.Discount_Code_1_to_IPAS__c)
                //         pis.piPolicy.Discount_Code_1_to_IPAS__c=TMPolicyUtil.getDiscountCode(discountDescr);
                //     else if(null==pis.piPolicy.Discount_Code_2_to_IPAS__c)
                //         pis.piPolicy.Discount_Code_2_to_IPAS__c=TMPolicyUtil.getDiscountCode(discountDescr);
                // }
                /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
            }
            System.debug('Discount_Code_1_to_IPAS__c='+pis.piPolicy.Discount_Code_1_to_IPAS__c);
            System.debug('Discount_Code_2_to_IPAS__c='+pis.piPolicy.Discount_Code_2_to_IPAS__c);
            system.debug('[TMCreatePolicyStep7Strategy] ptvs.ctrl.selectedDiscount1= '+pis.discount1);
            system.debug('[TMCreatePolicyStep7Strategy] ptvs.ctrl.selectedDiscount2= '+pis.discount2);
            if(null!=pis.discount1&&pis.availableDiscountMap.get(pis.discount1)==true){
                if(null==pis.piPolicy.Discount_Code_2_to_IPAS__c){
                    pis.piPolicy.Discount_Code_2_to_IPAS__c=TMPolicyUtil.getDiscountCode(pis.discount1);
                }else if(null==pis.piPolicy.Discount_Code_1_to_IPAS__c){
                    pis.piPolicy.Discount_Code_1_to_IPAS__c=TMPolicyUtil.getDiscountCode(pis.discount1);
                }
            }
            if(null!=pis.discount2&&pis.availableDiscountMap.get(pis.discount2)==true){
                if(null==pis.piPolicy.Discount_Code_2_to_IPAS__c){
                    pis.piPolicy.Discount_Code_2_to_IPAS__c=TMPolicyUtil.getDiscountCode(pis.discount2);
                }else if(null==pis.piPolicy.Discount_Code_1_to_IPAS__c){
                    pis.piPolicy.Discount_Code_1_to_IPAS__c=TMPolicyUtil.getDiscountCode(pis.discount2);
                }
            }
            pis.piPolicy.Discount_Code_1_to_IPAS_Description__c=(null!=discountCodeDiscountDescriptionMap.get(pis.piPolicy.Discount_Code_1_to_IPAS__c)?discountCodeDiscountDescriptionMap.get(pis.piPolicy.Discount_Code_1_to_IPAS__c):pis.piPolicy.Discount_Code_1_to_IPAS__c);
            pis.piPolicy.Discount_Code_2_to_IPAS_Description__c=(null!=discountCodeDiscountDescriptionMap.get(pis.piPolicy.Discount_Code_2_to_IPAS__c)?discountCodeDiscountDescriptionMap.get(pis.piPolicy.Discount_Code_2_to_IPAS__c):pis.piPolicy.Discount_Code_2_to_IPAS__c);
            System.debug('[TMCreatePolicyStep7Strategy]setDiscountCodeToPolicy().pis.piPolicy.Discount_Code_1_to_IPAS__c='+pis.piPolicy.Discount_Code_1_to_IPAS__c);
            System.debug('[TMCreatePolicyStep7Strategy]setDiscountCodeToPolicy().pis.piPolicy.Discount_Code_2_to_IPAS__c='+pis.piPolicy.Discount_Code_2_to_IPAS__c);
            
            // Rancho_AvoidTheSameDiscount_20210908: clear discount 2 when the Discount Code or Group of two discount are the same
            if((String.isNotBlank(pis.piPolicy.Discount_Code_1_to_IPAS__c)&&String.isNotBlank(pis.piPolicy.Discount_Code_2_to_IPAS__c)&&pis.piPolicy.Discount_Code_1_to_IPAS__c.equalsIgnoreCase(pis.piPolicy.Discount_Code_2_to_IPAS__c))
                ||(String.isNotBlank(pis.piPolicy.Discount_Code_1_to_IPAS_Description__c)&&String.isNotBlank(pis.piPolicy.Discount_Code_2_to_IPAS_Description__c)&&ptvs.ctrl.discountGroupValidation(pis.piPolicy.Discount_Code_1_to_IPAS_Description__c,pis.piPolicy.Discount_Code_2_to_IPAS_Description__c))){
                pis.piPolicy.Discount_2__c=null;
                pis.piPolicy.Discount_Code_2_to_IPAS__c=null;
                pis.piPolicy.Discount_Code_2_to_IPAS_Description__c=null;
            }
        }
    }
    
    /**
    private void changeUWResult(){
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if('yes'.equalsIgnoreCase(pis.piPolicy.Appeal_For_UW_Result__c)){
                pis.uwResult.Overrall_Result__c='Referred';
            }else if('no'.equalsIgnoreCase(pis.piPolicy.Appeal_For_UW_Result__c)){
                pis.uwResult.Overrall_Result__c='Declined';
            }
        }
    }
    **/
    
    //AH18329
    public Account createAccountWithExistingInfo(New_Policy__c np){
        RecordType tmCustomerRt=[SELECT Id FROM RecordType WHERE DeveloperName='TM_Customer'];
        Account newAccount=new Account(RecordTypeId=tmCustomerRt.Id,lastname=np.Policy_Holder_Last_Name__c,firstname=np.Policy_Holder_First_Name__c,Chinese_Name__c=np.Policy_Holder_Name_Chi__c,PersonMobilePhone=np.Mobile_Phone__c,PersonEmail=np.Policy_Holder_Email_Address__c,Gender__c=np.Gender__c,Salutation=genderSalutationMap.get(np.Gender__c),PersonBirthdate__c=np.Date_of_Birth__c,Age__c=np.Age__c,Nationality__c=np.Nationality__c,Office_Phone__c=np.Office_Phone__c,PersonHomePhone=np.Home_Phone__c,Home_Address_Line_1__c=np.Residential_Address_1__c,Home_Address_Line_2__c=np.Residential_Address_2__c,Home_Address_Line_3__c=np.Residential_Address_3__c,Home_Address_Line_4__c=np.Residential_Address_4__c,Prospect_reference1__c=ptvs.ctrl.acc.Prospect_reference1__c,Reference2__pc=ptvs.ctrl.acc.Reference2__pc,Reference3__pc=ptvs.ctrl.acc.Reference3__pc,Reference4__pc=ptvs.ctrl.acc.Reference4__pc,Reference5__pc=ptvs.ctrl.acc.Reference5__pc,SSN__c=np.Personal_ID__c);
        PreProcessingHelper pHelper=new PreProcessingHelper();
        List<Account> newAccountList=pHelper.process(new List<Account>{newAccount});
        return newAccountList.get(0);
        //upsert newAccount;
        //return newAccount;
    }
    
    public Opportunity createOpptyWithExistingInfo(New_Policy__c np, Account acc){
        //Oppty field:
        //Account,Campaign,Hotline_Number__c,recordtype,stageName, is_side_order__c,
        //Hotline_Type__c,TVC_version__c,Avaya_VDN__c,Spot_Number__c,TD_hotline__c,Lead_Source__c,Hotline_Product__c,Hotline_Channel__c
        RecordType tmOpptyRt=[SELECT Id FROM RecordType WHERE DeveloperName='TM_Opportunity'];
        Opportunity newOppty=new Opportunity(RecordTypeId=tmOpptyRt.Id,AccountId=acc.Id,CampaignId=ptvs.ctrl.opp.Campaign__c,Campaign__c=ptvs.ctrl.opp.Campaign__c,StageName='Cigna',Name='DO NOT MODIFY',CloseDate=ptvs.ctrl.cam.Expiry_Date__c,Product_1__c=ptvs.ctrl.opp.Product_1__c,Quote_Product1__c=ptvs.ctrl.opp.Quote_Product1__c,Reference2__c=ptvs.ctrl.opp.Reference2__c,Reference3__c=ptvs.ctrl.opp.Reference3__c,Reference4__c=ptvs.ctrl.opp.Reference4__c,Reference5__c=ptvs.ctrl.opp.Reference5__c,ownerId=userInfo.getUserId());
        //insert newOppty;
        //return newOppty;
        Set<Id> campaignIdSet=new Set<Id>();
        campaignIdSet.add(ptvs.ctrl.opp.Campaign__c);
        Set<Id> AccIdSet=new Set<Id>();
        AccIdSet.add(acc.Id);
        List<Opportunity> oppList=new List<Opportunity>();
        oppList.add(newOppty);
        OpportunityDeDuplicationHelper oppHelper=new OpportunityDeDuplicationHelper(campaignIdSet, AccIdSet);
        List<Opportunity> newOppList=oppHelper.deDuplicatedInsert(oppList,true);
        return newOppList.get(0);
    }
    
    public void assignTransactionToNewOppty(Policy_Transaction__c pt, List<TMCreatePolicyCtrl.PersonInsuredStructure> personInsuredStructureList, Account acc, Opportunity oppty){
        //pt:Opportunity__c, Account__c
        //np:Opportunity__c, Account__c
        pt.Opportunity__c=oppty.Id;
        pt.Account__c=acc.Id;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : personInsuredStructureList){
            pis.piPolicy.Opportunity__c=oppty.Id;
            pis.piPolicy.Account__c=acc.Id;
        }
    }
    //AH18329

    
    /* add by Jack on 2022-01-04 for project: comment by jack for discount enhancement, mandatory is selected in discount by default */
    /**
    * @description 
    * @author Jackshao@deloitte.com.cn | 01-18-2022 
    * @return Boolean 
    **/
    // public Boolean discount12MonthChecking(){
    //     system.debug('ptvs.ctrl.selectedProduct.id:'+ptvs.ctrl.selectedProduct.id+' ptvs.ctrl.productIdCampaignMap:'+ptvs.ctrl.productIdCampaignMap);
    //     system.debug('ptvs.ctrl.productIdCampaignMap.get(ptvs.ctrl.selectedProduct.id).id'+ptvs.ctrl.productIdCampaignMap.get(ptvs.ctrl.selectedProduct.id).id);
    //     system.debug('ptvs.ctrl.productIdPremiumDiscountMap:'+ptvs.ctrl.productIdPremiumDiscountMap);
    //     if(String.isNotBlank(ptvs.ctrl.selectedDiscount1) || String.isNotBlank(ptvs.ctrl.selectedDiscount2)){
    //         for(Premium_Discount__c discount : ptvs.ctrl.productIdPremiumDiscountMap.get(ptvs.ctrl.selectedProduct.id)){
    //             if(discount.Discount_Type__c == ptvs.ctrl.selectedDiscount1 || discount.Discount_Type__c == ptvs.ctrl.selectedDiscount2){
    //                 if(discount.Lapse_Surrender_Policy_Checking__c){
    //                     List<HttpCalloutVO.Policy> wsPolicyList=ptvs.ctrl.policyCalloutHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', ptvs.ctrl.newPolicy.Personal_ID__c);
    //                     if(TMPolicyUtil.lapseSurrenderPolicyChecking(ptvs.ctrl.selectedProduct.product_code__c, wsPolicyList)){
    //                         return false; 
    //                     }
    //                 }
    //             }
    //         }
    //     }
    //     return true;
    // }
}