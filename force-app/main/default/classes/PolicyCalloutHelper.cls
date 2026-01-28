/*********************************************************************************
 * Name: PolicyCalloutHelper
 *
 * Version History
 * Version           Author                 Date                      Description
 * ---------------  --------------------    -----------------------  ---------------------------------------------------------
 * V1.0             Franco                  2016-10-24                Provides functions for retrieving policy related data from WS
 * ......           
 * JR1774           Lawrence BP Wong        2019-11                   JR1774
 * AH18454          Lawrence BP Wong        2020-01                   AH18454
 * HKITSFDC-8       Kamlesh, PCCW           2024-01                  Add 3 new field for Elite 360 Migration
 ********************************************************************************/
public with sharing class PolicyCalloutHelper extends HttpCalloutHelperAbstract{
    // Function Name 
    public static final String GetPolicyListBasicByCriteria='GetPolicyListBasicByCriteria';
    public static final String GetPolicyPersonListBasic='GetPolicyPersonListBasic';
    public static final String GetPolicyPaymentBasic='GetPolicyPaymentBasic';
    public static final String GetPolicyBillingListBasic='GetPolicyBillingListBasic';
    public static final String GetPolicyFundListBasic='GetPolicyFundListBasic';
    public static final String GetPolicyFundListHistBasic='GetPolicyFundListHistBasic';
    public static final String GetPolicyAvailFundListBasic='GetPolicyAvailFundListBasic';
    public static final String GetPolicyPersonCoverageBasic='GetPolicyPersonCoverageBasic';
    public static final String GetPolicyBasic='GetPolicyBasic';
    public static final String GetPolicyClaimBasic='GetPolicyClaimBasic';
    public static final String GetPolicyDoc='GetPolicyDoc';
    public static final String GetPolicyDocTypeList='GetPolicyDocTypeList';
    public static final String GetClinicVisitCount='GetClinicVisitCount';
    public static final String GetPolicyPersonListBasicByCriteria='GetPolicyPersonListBasicByCriteria';
    public static final String GetUWComments='GetUWComments';
    public static final String VerifyPolicyInfo='VerifyPolicyInfo';    // JR1774
    public static final String UpdatePolicyDoc = 'UpdatePolicyDoc';  // added by Connor CR-47
    public static final String GetPersonShortfallBasicByCriteria = 'GetPersonShortfallBasicByCriteria'; // added by Connor  CP-156(Client Portal)
    public static final String GetPersonMovementHistory = 'GetPersonMovementHistory'; // added by Connor  CP-156(Client Portal)
    public static final String GetClientMemberMovementResult = 'GetClientMemberMovementResult'; // added by Connor CP-163(Client Portal)
    public static final String GetEMedicalCardsByCriteria='GetEMedicalCardsByCriteria';
    public static final String GetEMedicalCardsBasicByCriteria='GetEMedicalCardsBasicByCriteria';
    public static final String GetPolicyTransactionHistory='GetPolicyTransactionHistory'; //add by kit
    public static final String GetAuditTrail='GetAuditTrail'; //CS Member Level Jack add
    public static final String GetPolicyReplacementChangeHistory='GetPolicyReplacementChangeHistory';//policy replacement jack add
    public static final String GetMemberListByCriteria='GetMemberListByCriteria';//Rancho_JOBR347_20231108
    
    public static final String GetBodyCheckEligibility = 'GetBodyCheckEligibility'; // 21-02-2024 BodyCheckEligibility
        
    //add by kermit
    public static final String BROKER_PORTAL_APPNAME='BROKER_PORTAL';
    public static final String CUSTOMER_PORTAL_APPNAME='CUSTOMER_PORTAL';
    public static final String SERVICE_CONSOLE_APPNAME='SERVICE_CONSOLE';
    public static final String ONEDEGREE_APPNAME='ONEDEGREE';
    //end add by kermit
    public static final String WEB_PORTAL_APPNAME='Web Portal';    // JR1774
    
    // RelationRoleCode / PartyTypeCode
    public static final String OWNER='8';         // OLI_REL_OWNER
    public static final String INSURED='32';      // OLI_REL_INSURED
    public static final String BENEFICIARY='34';  // OLI_REL_BENEFICIARY
    public static final String ANYPERSON='999';   // OLI_REL_ANY   'ANY' is a reserved name
    public static final String POLICY_TYPE_INDIVIDUAL='I';
    public static final String POLICY_TYPE_GROUP='G';
    public static final String NO_BROKER_AGENT='NO_BROKER_AGENT';  // for GetPolicyListBasicByCriteria
    
    //Add by Caden for JR1753 - change from policy level to member level coverage start
    public static final String MEMBER_STATUS_ACTIVE_ENG='Active';
    public static final String MEMBER_STATUS_INACTIVE_ENG='Inactive';
    public static final String MEMBER_STATUS_ACTIVE_CHI='生效';
    public static final String MEMBER_STATUS_INACTIVE_CHI='無效';
    //Add by Caden for JR1753 - change from policy level to member level coverage end
    
    public static final Map<String,String> statusCodeMap{get;set;}
    public static final Map<String,String> partyTypeCodeMap{get;set;}
    public static Map<String,Policy_Status_Mapping__c> policyStatusMapping=Policy_Status_Mapping__c.getAll();
    public String userLanguage='';
    public Boolean downloadSign = TRUE;//Kirk-20211103-CP549-Add download Excel sign
    public String TXLifeRequest='';
    public Map<String,String> paramsMap;
    private Boolean showAllPI=false;
    public static Map<String,String> currencyCodeMap;//SPS-165
    private Boolean isAllFamilyRec=false;// Rancho_PI66_20220428
    //add Bob 20210310
    private static User currentUser=[select id, Name, ProfileId, UserRoleId, UserName, LanguageLocaleKey, AccountId, Profile.UserLicense.Name,AccessLevel__c, Company_Code__c from User where id=:Userinfo.getUserId()];     //Company_Code__c added by Connor LPCSC-8
    static{
        statusCodeMap=new Map<String,String>();
        for(String keyName:policyStatusMapping.keySet()){
            Policy_Status_Mapping__c psm=policyStatusMapping.get(keyName);
            statusCodeMap.put(psm.Description__c,psm.PolicyCode__c);
        }
        
        partyTypeCodeMap=new Map<String,String>();
        partyTypeCodeMap.put('8','Owner');
        partyTypeCodeMap.put('32','Insured');
        partyTypeCodeMap.put('34','Beneficiary');
        partyTypeCodeMap.put('999','Any');
        
        //SPS-165
        currencyCodeMap=new Map<String,String>();
        for(Currency_Code_Mapping__c ccm:[SELECT Id,Currency_Code__c,Currency_Symbol__c from Currency_Code_Mapping__c]){
            currencyCodeMap.put(ccm.Currency_Code__c,ccm.Currency_Symbol__c);
        }
        //SPS-165
    }
    
    // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-15
    // Elite 360 Migration  NCD
    public static final List<String> nCDProductList = new List<String>{
        'NELG', 'NESG', 'NELGA', 'NESGA', 'NELGM', 'NESGM', 'NELG2', 'NESG2'
    };
    // END https://jira.express-scripts.com/browse/HKITSFDC-15  

    //Added by Nicole in Phase2
    public static final Map<String,String> familyRecordMap{get;set;}
    static{
        familyRecordMap=new Map<String,String>();
        familyRecordMap.put('all','1');
        familyRecordMap.put('spouse','2');
        familyRecordMap.put('dependent','3');
        familyRecordMap.put('employee','4');
    }
    public static final Map<String,String> personTypeMap{get;set;}
    static{
        personTypeMap=new Map<String,String>();
        personTypeMap.put('Owner','8');
        personTypeMap.put('Insured','32');
        personTypeMap.put('Beneficiary','34');
        personTypeMap.put('Any','999');
    }
        
    public PolicyCalloutHelper(){
        this.TXName='TXLife';
        paramsMap=new Map<String,String>();
        this.userLanguage=UserInfo.getLanguage();
        if(String.isBlank(this.roleId)){
            User currentUser = [SELECT id,UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
            if('CEO'.equals(currentUser.UserRole.Name)){this.roleId = 'TM';}
        }
    }
    
    public PolicyCalloutHelper(Integer pageSize){
        this();
        this.maxRecords=this.pageSize=pageSize;
    }
    
    public PolicyCalloutHelper(Boolean asyn){
        this();
        if(asyn!=null){
            this.asyn=asyn;
        }
    }

    public PolicyCalloutHelper(String language){
        this();
        if(String.isNotBlank(language)){
            this.userLanguage=language;
            if('zh_HK'.equalsIgnoreCase(language) || 'zh_CN'.equalsIgnoreCase(language) || 'zh_TW'.equalsIgnoreCase(language)){
                currentLanguageNode='<CurrentLanguage tc="523">Chinese (Cantonese)</CurrentLanguage>';
            }else if('en_US'.equalsIgnoreCase(language)){
                currentLanguageNode='<CurrentLanguage tc="9">English</CurrentLanguage>';
            }
        }
    }
    
    public PolicyCalloutHelper(String roleId,String language){
        this();
        if(String.isNotBlank(roleId)){
            this.roleId=roleId;
        }
        if(String.isNotBlank(language)){
            this.userLanguage=language;
            if('zh_HK'.equalsIgnoreCase(language) || 'zh_CN'.equalsIgnoreCase(language) || 'zh_TW'.equalsIgnoreCase(language)){
                currentLanguageNode='<CurrentLanguage tc="523">Chinese (Cantonese)</CurrentLanguage>';
            }else if('en_US'.equalsIgnoreCase(language)){
                currentLanguageNode='<CurrentLanguage tc="9">English</CurrentLanguage>';
            }
        }
    }
    
    /********************************************************************
     * getPolicyBillingListBasic
     * @param String
     * @decs:Call getPolicyBillingListBasic WS to get billing list
     * @return List<HttpCalloutVO.PolicyBilling>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyBilling> getPolicyBillingListBasic(String policyNumber){
        system.debug('PolicyCalloutHelper.getPolicyBillingListBasic');
        this.functionName=PolicyCalloutHelper.getPolicyBillingListBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('BrokerPortalBillingInd','N');	//HKITSFDC-148
        return (List<HttpCalloutVO.PolicyBilling>)execute(new Map<String,String>());
    }
    //BEGIN HKITSFDC-148
    public List<HttpCalloutVO.PolicyBilling> getPolicyBillingListBasic(String policyNumber,Boolean isBrokerPortalBillingIndicator){
        system.debug('PolicyCalloutHelper.getPolicyBillingListBasic overloaded 2 args');
        String brokerPortalBillingIndicatorStr = (isBrokerPortalBillingIndicator==true) ? 'Y' : 'N';
        this.functionName=PolicyCalloutHelper.getPolicyBillingListBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('BrokerPortalBillingInd',brokerPortalBillingIndicatorStr);
        return (List<HttpCalloutVO.PolicyBilling>)execute(new Map<String,String>());
    }
    //END HKITSFDC-148
    
    /********************************************************************
     * processPolicyBillingListBasicResult
     * @param Dom.document
     * @decs:Handle the getPolicyBillingListBasic WS result
     * @return List<HttpCalloutVO.PolicyBilling>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyBilling> processPolicyBillingListBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyBillingListBasicResult');
        List<HttpCalloutVO.PolicyBilling> objList=new List<HttpCalloutVO.PolicyBilling>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        Dom.XmlNode holdingNode=getChildNodeIfNotNull('Holding',oLifeNode);
        Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',holdingNode);
        List<Dom.XmlNode> faNodeList=getChildElementsIfNotNull(policyNode);
        for(Dom.XmlNode faNode:faNodeList){
            if(faNode.getName()=='FinancialActivity'){
                HttpCalloutVO.PolicyBilling billing=new HttpCalloutVO.PolicyBilling();
                billing.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                billing.Description=getChildNodeTextIfNotEmpty('Description',faNode);
                billing.FinActivityGrossAmt=getChildNodeDecimalIfNotEmpty('FinActivityGrossAmt',faNode);
                billing.FinActivityDate=getChildNodeTextIfNotEmpty('FinActivityDate',faNode);
                billing.FinActivityDateInDate=getChildNodeDateIfNotEmpty('FinActivityDate',faNode,'yyyy-MM-dd');
                billing.commissionAmt=getChildNodeDecimalIfNotEmpty('CommissionAmt',faNode);
                //BEGIN HKITSFDC-148
                billing.paymentDescription=getChildNodeTextIfNotEmpty('PaymentDescription',faNode);
                //END HKITSFDC-148
                Dom.XmlNode paymentNode=getChildNodeIfNotNull('Payment',faNode);
                billing.paymentAmt=getChildNodeDecimalIfNotEmpty('PaymentAmt',paymentNode);

                // 20200610 - minghua - levyII
                billing.levy=getChildNodeDecimalIfNotEmpty('PaymentLevy',paymentNode);
                String levyStatus=getChildNodeTextIfNotEmpty('LevyStatus',paymentNode);
                if(String.isNotBlank(levyStatus)){
                    // “S”: levy settled ,“O”,"P": levy outstanding
                    if(billing.paymentAmt==null){
                        billing.paymentAmt=0;
                    }
                    billing.outstandingLevyIndicator='';
                    if(levyStatus.equalsIgnoreCase('S')){
                        billing.outstandingLevyIndicator='Levy Settled';       //Rancho_LevyIndicator_20210219
                        if(billing.levy!=null){
                            billing.totalPremiumIncludingLevy=billing.paymentAmt+billing.levy;
                        }else{
                            billing.totalPremiumIncludingLevy=billing.paymentAmt;
                        }
                    }else if(levyStatus.equalsIgnoreCase('O') || levyStatus.equalsIgnoreCase('P')){
                        // billing.outstandingLevyIndicator='Y';               //Rancho_LevyIndicator_20210219
                        billing.outstandingLevyIndicator='Levy Outstanding';   //Rancho_LevyIndicator_20210219
                    }
                }

                billing.paymentStatusDate=getChildNodeTextIfNotEmpty('PaymentStatusDate',paymentNode);
                billing.paymentStatusDateInDate=getChildNodeDateIfNotEmpty('PaymentStatusDate',paymentNode,'yyyy-MM-DD');
                if(billing.FinActivityGrossAmt!=null && billing.paymentAmt!=null){
                    billing.unsettleBalance=billing.FinActivityGrossAmt - billing.paymentAmt;
                }
                
                Dom.XmlNode faOLifeExtensionNode=getChildNodeIfNotNull('OLifEExtension',faNode);
                billing.payerName=getChildNodeTextIfNotEmpty('PayerName',faOLifeExtensionNode);
                billing.rejCode=getChildNodeTextIfNotEmpty('RejCode',faOLifeExtensionNode);
                billing.rejCodeDesc=getChildNodeTextIfNotEmpty('RejCodeDesc',faOLifeExtensionNode);
                billing.invoiceNumber=getChildNodeTextIfNotEmpty('InvoiceNumber',faOLifeExtensionNode);
                billing.branchCode=getChildNodeTextIfNotEmpty('BranchCode',faOLifeExtensionNode);
                billing.branchDesc=getChildNodeTextIfNotEmpty('BranchDesc',faOLifeExtensionNode);
                billing.currencyTypeCode=getChildNodeAttributeIfNotEmpty('CurrencyTypeCode','tc',faOLifeExtensionNode);
                billing.currencyTypeDesc=getChildNodeTextIfNotEmpty('CurrencyTypeCode',faOLifeExtensionNode);
                billing.automaticPremiumPayment=getChildNodeDecimalIfNotEmpty('APPAmt',faOLifeExtensionNode);
                billing.Collector=getChildNodeTextIfNotEmpty('Collector',faOLifeExtensionNode);
                billing.PayDate=getChildNodeDateIfNotEmpty('PayDate',faOLifeExtensionNode,'yyyy-MM-DD');
                billing.Status=getChildNodeTextIfNotEmpty('Status',faOLifeExtensionNode);
                billing.Period=getChildNodeTextIfNotEmpty('Period ',faOLifeExtensionNode);
                billing.BillingStartDate=getChildNodeDateIfNotEmpty('BillingStartDate',faOLifeExtensionNode,'yyyy-MM-DD');
                objList.add(billing);
            }
        }
        system.debug('List<HttpCalloutVO.PolicyBilling> '+objList.size());
        return objList;
    }
    
    /********************************************************************
     * getPolicyPaymentBasic
     * @param String
     * @decs:Call GetPolicyPaymentBasic WS to get payment info
     * @return List<HttpCalloutVO.PolicyPayment>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyPayment> getPolicyPaymentBasic(String policyNumber){
        system.debug('PolicyCalloutHelper.getPolicyPaymentBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyPaymentBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        return (List<HttpCalloutVO.PolicyPayment>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyPaymentBasicResult
     * @param Dom.document
     * @decs:Handle GetPolicyPaymentBasic WS result
     * @return List<HttpCalloutVO.PolicyPayment>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyPayment> processPolicyPaymentBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyPaymentBasicResult');
        Map<String,Discount_Code__c> discountMap=Discount_Code__c.getAll();
        List<HttpCalloutVO.PolicyPayment> objList=new List<HttpCalloutVO.PolicyPayment>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        HttpCalloutVO.PolicyPayment payment=new HttpCalloutVO.PolicyPayment();
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                String holdingTypeCode=getChildNodeAttributeIfNotEmpty('HoldingTypeCode','tc',childNode);
                if(holdingTypeCode=='2'){ //Policy
                    Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                    payment.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    payment.effDate=getChildNodeTextIfNotEmpty('EffDate',policyNode);
                    payment.effDateInDate=getChildNodeDateIfNotEmpty('EffDate',policyNode,'yyyy-MM-dd');
                    payment.termDate=getChildNodeTextIfNotEmpty('TermDate',policyNode);
                    payment.termDateInDate=getChildNodeDateIfNotEmpty('TermDate',policyNode,'yyyy-MM-dd');
                    payment.paidToDate=getChildNodeTextIfNotEmpty('PaidToDate',policyNode);
                    payment.paidToDateInDate=getChildNodeDateIfNotEmpty('PaidToDate',policyNode,'yyyy-MM-dd');
                    payment.paymentAmt=getChildNodeTextIfNotEmpty('PaymentAmt',policyNode);
                    payment.paymentMode=getChildNodeTextIfNotEmpty('PaymentMode',policyNode);
                    payment.paymentModeCode=getChildNodeAttributeIfNotEmpty('PaymentMode','tc',policyNode);
                    payment.paymentMethod=getChildNodeTextIfNotEmpty('PaymentMethod',policyNode);
                    payment.paymentMethodCode=getChildNodeAttributeIfNotEmpty('PaymentMethod','tc',policyNode);
                    payment.modalPremium=getChildNodeDecimalIfNotEmpty('PaymentAmt',policyNode);
                    // JR1797 - add Last Mode Premium in portal to avoid confusion with current mode premium
                    payment.lastModalPremium=getChildNodeDecimalIfNotEmpty('LastPaymentAmt',policyNode);
                    //payment.annualPremium=calculateAnnualModalPremium(payment.modalPremium,payment.paymentModeCode);
                    payment.annualPremium=getChildNodeDecimalIfNotEmpty('AnnualPaymentAmt',policyNode);
                    // Zoe updated on 0614,PPCP-33
                    payment.couponUsedAmt=getChildNodeDecimalIfNotEmpty('CouponUsedAmt',policyNode);//AM project coupon jack add
                    //payment.renewalNoticeInd=getChildNodeTextIfNotEmpty('RenewalNoticeInd',policyNode);//HKITSFDC-438 remove Rancho_JOBR367_20240513 - update premium display
                    
                    // 20200610 - minghua - levyII
                    payment.levyCurrentPremium=getChildNodeDecimalIfNotEmpty('LastPaymentLevy',policyNode);
                    payment.nextLevy=getChildNodeDecimalIfNotEmpty('NextLevy',policyNode);
                    if(payment.modalPremium==null){
                        payment.modalPremium=0;
                    }
                    if(payment.levyCurrentPremium==null){
                        payment.levyCurrentPremium=0;
                    }
                    if(payment.lastModalPremium==null){
                        payment.lastModalPremium=0;
                    }
                    if(payment.nextLevy==null){
                        payment.nextLevy=0;
                    }
                    payment.totalModalPremiumIncludeLevy=payment.modalPremium+payment.nextLevy;
                    payment.currentPremiumIncludeLevy=payment.lastModalPremium+payment.levyCurrentPremium;
                    Date levyEffectiveDate=Portal_Settings__c.getInstance().Levy_EffectiveDate__c;
                    Date todayNow=Date.today();
                    if(levyEffectiveDate!=null && todayNow >=levyEffectiveDate){
                        payment.effectiveLevy=true;
                    }else{
                        payment.effectiveLevy=false;
                    }
                    
                    // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-15
                    // Elite 360 Migration - NCD
                        payment.nCDEligibility = getChildNodeTextIfNotEmpty('NcdEligibility',policyNode);
                        payment.nCDUpdateDate = getChildNodeTextIfNotEmpty('NcdUpdDate',policyNode);
                    // END https://jira.express-scripts.com/browse/HKITSFDC-15  


                    //JR1783
                    payment.discountList=new List<HttpCalloutVO.Discount>();
                    payment.couponList=new List<Coupon>();//AM project coupon jack add
                    List<Dom.XmlNode> policyChildNodes=getChildElementsIfNotNull(policyNode);
                    for(Dom.XmlNode policyChildNode:policyChildNodes){
                        if(policyChildNode.getName()=='Discount'){
                            HttpCalloutVO.Discount discount=new HttpCalloutVO.Discount();
                            discount.discountCode=getChildNodeTextIfNotEmpty('DiscountCode',policyChildNode);
                            if(discountMap.get(discount.discountCode.trim())!=null){
                                discount.description=discountMap.get(discount.discountCode.trim()).description__c;
                            }
                            discount.discountDuration=Integer.valueOf(getChildNodeDecimalIfNotEmpty('DiscountDuration',policyChildNode));
                            discount.discountPercentage=getChildNodeDecimalIfNotEmpty('DiscountPercentage',policyChildNode);
                            payment.discountList.add(discount);
                        }else if(policyChildNode.getName()=='Coupon'){//AM project coupon jack add
                            Coupon coupon=new Coupon(new Coupon__c());
                            coupon.setCouponNumber(getChildNodeTextIfNotEmpty('CouponCode',policyChildNode));
                            coupon.setAmount(getChildNodeDecimalIfNotEmpty('CouponAmount',policyChildNode));
                            payment.couponList.add(coupon);
                        }//AM project coupon jack add
                    }
                    //JR1783
                    
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',policyNode);
                    payment.polDebitDay=getChildNodeTextIfNotEmpty('DebitDay',OLifEExtensionNode);
                    payment.polDebitDayDisplay=findLabelforDebitDay(payment.polDebitDay,payment.paymentMethodCode);
                    payment.polAdditionalFundContribution=getChildNodeDecimalIfNotEmpty('AFCAmt',OLifEExtensionNode);
                    payment.startDateofAutomaticPremiumPayment=getChildNodeTextIfNotEmpty('APPStartDate',OLifEExtensionNode);
                    payment.endDateofAutomaticPremiumPayment=getChildNodeTextIfNotEmpty('APPEndDate',OLifEExtensionNode);
                    payment.startDateofAutomaticPremiumPaymentInDate=getChildNodeDateIfNotEmpty('APPStartDate',OLifEExtensionNode,'yyyy-MM-dd');
                    payment.endDateofAutomaticPremiumPaymentInDate=getChildNodeDateIfNotEmpty('APPEndDate',OLifEExtensionNode,'yyyy-MM-dd');
                }
                if(holdingTypeCode=='7'){ //Banking
                    Dom.XmlNode bankingNode=getChildNodeIfNotNull('Banking',childNode);
                    payment.creditCardType=getChildNodeTextIfNotEmpty('CreditCardTypeCode',bankingNode);
                    payment.creditCardExpDate=getChildNodeTextIfNotEmpty('CreditCardExpDate',bankingNode);
                    payment.creditCardExpDateInDate=getChildNodeDateIfNotEmpty('CreditCardExpDate',bankingNode,'yyyy-MM-dd');
                    payment.accountNumber=getChildNodeTextIfNotEmpty('AccountNumber',bankingNode);
                    payment.acctHolderName=getChildNodeTextIfNotEmpty('AcctHolderName',bankingNode);
                    payment.bankName=getChildNodeTextIfNotEmpty('BankName',bankingNode);
                    payment.LatestAutopayRejectDateandReason=getChildNodeTextIfNotEmpty('LatestAutopayReject',bankingNode);
                    payment.AutopayLimit=getChildNodeTextIfNotEmpty('AutopayLimit',bankingNode);
                    payment.CardHolderID=getChildNodeTextIfNotEmpty('CardHolderID',bankingNode);
                    payment.CardType=getChildNodeTextIfNotEmpty('CardType',bankingNode);
                }
            }
            if(childNode.getName()=='Party'){
                payment.fullName=getChildNodeTextIfNotEmpty('FullName',childNode);
                payment.ssnNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                Dom.XmlNode personNode=getChildNodeIfNotNull('Person',childNode);
                payment.firstName=getChildNodeTextIfNotEmpty('FirstName',personNode);
                payment.middleName=getChildNodeTextIfNotEmpty('MiddleName',personNode);
                payment.lastName=getChildNodeTextIfNotEmpty('LastName',personNode);
                if(String.isBlank(payment.fullName)){
                    payment.fullName=(String.isNotBlank(payment.lastName)?payment.lastName:'') +' '+ (String.isNotBlank(payment.firstName)?payment.firstName:'');
                }
            }
        }
        if(String.isNotBlank(payment.policyNumber)){
            objList.add(payment);
        }
        system.debug('List<HttpCalloutVO.PolicyPayment> '+objList.size());
        return objList;
    }
    
    /********************************************************************
     * calculateAnnualModalPremium
     * @param Decimal,@param String
     * @decs:Calculate the annual modal premium
     * @return Decimal
   ********************************************************************/
    public static Decimal calculateAnnualModalPremium(Decimal modelPremium,String paymentModeCode){
        Decimal total;
        if(String.isNotBlank(paymentModeCode) && modelPremium!=null){
            if(paymentModeCode=='1'){ //Annually
                total=modelPremium;
            }else if(paymentModeCode=='4'){ //Monthly
                total=modelPremium * 12;
            }else if(paymentModeCode=='3'){ //Quarterly
                total=modelPremium * 4;
            }else if(paymentModeCode=='2'){ //Semi-Annual
                total=modelPremium * 2;
            }else if(paymentModeCode=='7'){ //Bi-Weekly
                total=modelPremium * 24;
            }else if(paymentModeCode=='6'){ //Weekly
                total=modelPremium * 48;
            }
        }
        return total;
    }
    
    /********************************************************************
     * findLabelforDebitDay
     * @param String,@param String
     * @decs:Set the label for the debit day
     * @return String
   ********************************************************************/
    public static String findLabelforDebitDay(String polDebitDay,String paymentMethodCode){
        polDebitDay=polDebitDay.trim();
        String result;
        if(polDebitDay.equals('3')){
            if(userInfo.getLanguage().contains('zh')){
                result='付款月的第3日';
            }else{
                result='On the 3rd day of the billing month';
            }
        }else if(polDebitDay.equals('14')){
            if(userInfo.getLanguage().contains('zh')){
                 result='付款月的第14日';
            }else{
                result='On the 14th day of the billing month';
            }
        }else if(polDebitDay.equals('18')){
            if(userInfo.getLanguage().contains('zh')){
                result='付款月的第18日';
            }else{
                result='On the 18th day of the billing month';
            }
        }else if(polDebitDay.equals('28')){
            if(userInfo.getLanguage().contains('zh')){
                result='付款月的第28日';
            }else{
                result='On the 28th day of the billing month';
            }
        }else{
            if(userInfo.getLanguage().contains('zh')){
                result='付款月的第10至20日';
            }else{
                result='Between 10th and 20th of the billing month';
            }
        }
        
        if(paymentMethodCode=='1052500003' || paymentMethodCode=='1052500005'){
            result='';
        }
        // Zoe updated on 0614,PPCP-68        
        return result;
    }
    
    /********************************************************************
     * getPolicyFundListBasic
     * @param String
     * @decs:Call GetPolicyFundListBasic WS to get fund list
     * @return  List<HttpCalloutVO.PolicyFund>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyFund> getPolicyFundListBasic(String policyNumber){
        system.debug('PolicyCalloutHelper.getPolicyFundListBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyFundListBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        return (List<HttpCalloutVO.PolicyFund>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyFundListBasicResult
     * @param Dom.document
     * @decs:Handle GetPolicyFundListBasic WS result
     * @return  List<HttpCalloutVO.PolicyFund>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyFund> processPolicyFundListBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyFundListBasicResult');
        List<HttpCalloutVO.PolicyFund> objList=new List<HttpCalloutVO.PolicyFund>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                String holdingTypeCode=getChildNodeAttributeIfNotEmpty('HoldingTypeCode','tc',childNode);
                if(holdingTypeCode=='2'){ //Policy
                    Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                    Dom.XmlNode investmentNode=getChildNodeIfNotNull('Investment',childNode);
                    HttpCalloutVO.PolicyFund fund=new HttpCalloutVO.PolicyFund();
                    fund.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    fund.accountValue=getChildNodeDecimalIfNotEmpty('AccountValue',investmentNode);
                    if(fund.accountValue!=null){
                        fund.accountValue=fund.accountValue.setScale(2,System.RoundingMode.FLOOR);
                    }

                    fund.netSurrValueAmt=getChildNodeDecimalIfNotEmpty('NetSurrValueAmt',investmentNode);
                    if(fund.netSurrValueAmt!=null){
                        fund.netSurrValueAmt=fund.netSurrValueAmt.setScale(2,System.RoundingMode.FLOOR);
                    }

                    fund.surrenderChargeAmt=getChildNodeDecimalIfNotEmpty('SurrenderChargeAmt',investmentNode);
                    if(fund.surrenderChargeAmt!=null){
                        fund.surrenderChargeAmt=fund.surrenderChargeAmt.setScale(2,System.RoundingMode.FLOOR);
                    }

                    Dom.XmlNode OLifEExtension=getChildNodeIfNotNull('OLifEExtension',investmentNode);
                    fund.totalCashValue=getChildNodeDecimalIfNotEmpty('TotalCashValue',OLifEExtension);
                    if(fund.totalCashValue!=null){
                        fund.totalCashValue=fund.totalCashValue.setScale(2,System.RoundingMode.FLOOR);
                    }

                    fund.totalInterimFundValue=getChildNodeDecimalIfNotEmpty('TotalInterimFundValue',OLifEExtension);
                    if(fund.totalInterimFundValue!=null){
                        fund.totalInterimFundValue=fund.totalInterimFundValue.setScale(2,System.RoundingMode.FLOOR);
                    }

                    fund.valuationDate=getChildNodeTextIfNotEmpty('ValuationDate',OLifEExtension);
                    fund.valuationDateInDate=getChildNodeDateIfNotEmpty('ValuationDate',OLifEExtension,'yyyy-MM-dd');
                    fund.maxFundWithdrawalAmt=getChildNodeDecimalIfNotEmpty('MaxFundWithdrawalAmt',OLifEExtension);
                    if(fund.maxFundWithdrawalAmt!=null){
                        fund.maxFundWithdrawalAmt=fund.maxFundWithdrawalAmt.setScale(2,System.RoundingMode.FLOOR);
                    }

                    fund.withdrawalCharge=getChildNodeDecimalIfNotEmpty('WithdrawalCharge',OLifEExtension);
                    if(fund.withdrawalCharge!=null){
                        fund.withdrawalCharge=fund.withdrawalCharge.setScale(2,System.RoundingMode.FLOOR);
                    }
                    
                    fund.fundAllocType=getChildNodeTextIfNotEmpty('FundAllocType',OLifEExtension);
                
                    //add by kit for CR Fund / Bonus Details for individual policy 2018/07/09
                    fund.CurrencyType=getChildNodeTextIfNotEmpty('Currency',OLifEExtension);
                    fund.TotalDeclaredBonus=getChildNodeTextIfNotEmpty('TotalDeclaredBonus',OLifEExtension);
                    fund.bonusTransactionList=new List<HttpCalloutVO.BonusTransaction>();
                    List<Dom.XmlNode> bList=getChildElementsIfNotNull(OLifEExtension);
                    for(Dom.XmlNode bonusTransactionNode:bList){
                        if(bonusTransactionNode.getName()=='BonusTransaction'){
                            HttpCalloutVO.BonusTransaction bTransaction=new HttpCalloutVO.BonusTransaction();
                            //bTransaction.transDate=getChildNodeDateIfNotEmpty('TransactionDate',bonusTransactionNode,'yyyy-MM-dd');
                            bTransaction.transDate=getChildNodeTextIfNotEmpty('TransactionDate',bonusTransactionNode);
                            bTransaction.currencyType=getChildNodeTextIfNotEmpty('Currency',bonusTransactionNode);
                            bTransaction.amount=getChildNodeDecimalIfNotEmpty('Amount',bonusTransactionNode);
                            if(bTransaction.amount!=null){
                                bTransaction.amount=bTransaction.amount.setScale(2,System.RoundingMode.FLOOR);
                            }
                            bTransaction.acct=getChildNodeTextIfNotEmpty('Account',bonusTransactionNode);
                            bTransaction.description=getChildNodeTextIfNotEmpty('Description',bonusTransactionNode);
                            fund.bonusTransactionList.add(bTransaction);
                        }
                    }
                    objList.add(fund);
                }
            }
        }
        system.debug('List<HttpCalloutVO.PolicyFund> '+objList.size());
        return objList;
    }
    
    public List<HttpCalloutVO.PolicyFundHist> getPolicyFundListHistBasic(String policyNumber){
        return getPolicyFundListHistBasic(policyNumber,null,null);
    }
    
    /********************************************************************
     * getPolicyFundListHistBasic
     * @param String,@param String,@param String
     * @decs:Call getPolicyFundListHistBasic WS to get fund list hist data
     * @return List<HttpCalloutVO.PolicyFundHist
   ********************************************************************/
    public List<HttpCalloutVO.PolicyFundHist> getPolicyFundListHistBasic(String policyNumber,String coverageNumber,String productCode){
        system.debug('PolicyCalloutHelper.getPolicyFundListHistBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyFundListHistBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        if(String.IsNotBlank(coverageNumber)){
            paramsMap.put('CoverageNumber',coverageNumber);
        }
        if(String.IsNotBlank(productCode)){
            paramsMap.put('ProductCode',productCode);
        }
        return (List<HttpCalloutVO.PolicyFundHist>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyFundListHistBasicResult
     * @param Dom.document
     * @decs:Handle the getPolicyFundListHistBasic WS repsonse
     * @return List<HttpCalloutVO.PolicyFundHist>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyFundHist> processPolicyFundListHistBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyFundListHistBasicResult');
        List<HttpCalloutVO.PolicyFundHist> objList=new List<HttpCalloutVO.PolicyFundHist>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                String holdingTypeCode=getChildNodeAttributeIfNotEmpty('HoldingTypeCode','tc',childNode);
                if(holdingTypeCode=='2'){ //Policy
                    Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                    Dom.XmlNode investmentNode=getChildNodeIfNotNull('Investment',childNode);
                    List<Dom.XmlNode> subAccountList=getChildElementsIfNotNull(investmentNode);
                    for(Dom.XmlNode subAccount:subAccountList){
                        HttpCalloutVO.PolicyFundHist fundHist=new HttpCalloutVO.PolicyFundHist();
                        fundHist.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                        fundHist.productCode=getChildNodeTextIfNotEmpty('ProductCode',subAccount);
                        fundHist.productFullName=getChildNodeTextIfNotEmpty('ProductFullName',subAccount);
                        System.debug('productFullName:'+fundHist.productFullName);

                        fundHist.unitValue=getChildNodeDecimalIfNotEmpty('UnitValue',subAccount);
                        if(fundHist.unitValue!=null){
                            fundHist.unitValue=fundHist.unitValue.setScale(2,System.RoundingMode.FLOOR);
                        }

                        fundHist.unitValueBuyRate=getChildNodeDecimalIfNotEmpty('UnitValueBuyRate',subAccount);
                        if(fundHist.unitValueBuyRate!=null){
                            fundHist.unitValueBuyRate=fundHist.unitValueBuyRate.setScale(2,System.RoundingMode.FLOOR);
                        }
                        if(fundHist.unitValueBuyRate==null){
                            fundHist.unitValueBuyRate=0.0;
                        }

                        //System.debug('UnitValueBuyRate:'+fundHist.unitValueBuyRate);
                        fundHist.payoutUnitValue=getChildNodeDecimalIfNotEmpty('PayoutUnitValue',subAccount);
                        if(fundHist.payoutUnitValue!=null){
                            fundHist.payoutUnitValue=fundHist.payoutUnitValue.setScale(2,System.RoundingMode.FLOOR);
                        }

                        fundHist.totValue=getChildNodeDecimalIfNotEmpty('TotValue',subAccount);
                        if(fundHist.totValue!=null){
                            fundHist.totValue=fundHist.totValue.setScale(2,System.RoundingMode.FLOOR);
                        }

                        fundHist.initPurchaseDate=getChildNodeTextIfNotEmpty('InitPurchaseDate',subAccount);
                        fundHist.initPurchaseDateInDate=getChildNodeDateIfNotEmpty('InitPurchaseDate',subAccount,'yyyy-MM-dd');
                        
                        //add by Andy
                        fundHist.coverageNumber=getChildNodeTextIfNotEmpty('CoverageNumber',subAccount);
                        fundHist.transactionType=getChildNodeTextIfNotEmpty('TransactionType',subAccount);
                        fundHist.valuationDate=getChildNodeTextIfNotEmpty('ValuationDate ',subAccount);
                        fundHist.valuationDateInDate=getChildNodeDateIfNotEmpty('ValuationDate',subAccount,'yyyy-MM-dd');
                        
                        fundHist.grossAmount=getChildNodeDecimalIfNotEmpty('GrossAmount',subAccount);
                        if(fundHist.grossAmount!=null){
                            fundHist.grossAmount=fundHist.grossAmount.setScale(2,System.RoundingMode.FLOOR);
                        }
                        if(fundHist.grossAmount==null){
                            fundHist.grossAmount=0.0;
                        }
                        fundHist.netAmount=getChildNodeDecimalIfNotEmpty('NetAmount',subAccount);
                        if(fundHist.netAmount!=null){
                            fundHist.netAmount=fundHist.netAmount.setScale(2,System.RoundingMode.FLOOR);
                        }
                        if(fundHist.netAmount==null){
                            fundHist.netAmount=0.0;
                        }
                        
                        Dom.XmlNode OLifEExtension=getChildNodeIfNotNull('OLifEExtension',subAccount);
                        fundHist.distRatioBasic=getChildNodeTextIfNotEmpty('DistRatioBasic',OLifEExtension);
                        fundHist.distRatioRegular=getChildNodeTextIfNotEmpty('DistRatioRegular',OLifEExtension);
                        fundHist.distRatioSingle=getChildNodeTextIfNotEmpty('DistRatioSingle',OLifEExtension);
                        objList.add(fundHist);
                    }
                }
            }
        }
        system.debug('List<HttpCalloutVO.PolicyFundHist> '+objList.size());
        return objList;
    }
    
    /********************************************************************
     * getPolicyAvailFundListBasic
     * @param String,@param String
     * @decs:Call GetPolicyAvailFundListBasic WS to get avail fund list
     * @return List<HttpCalloutVO.PolicyAvailFund>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyAvailFund> getPolicyAvailFundListBasic(String policyNumber,String fundPriceType){
        system.debug('PolicyCalloutHelper.getPolicyAvailFundListBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyAvailFundListBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('FundAllocType',fundPriceType);
        return (List<HttpCalloutVO.PolicyAvailFund>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyAvailFundListBasicResult
     * @param Dom.document
     * @decs:Handle GetPolicyAvailFundListBasic WS repsonse
     * @return List<HttpCalloutVO.PolicyAvailFund>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyAvailFund> processPolicyAvailFundListBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyAvailFundListBasicResult');
        List<HttpCalloutVO.PolicyAvailFund> objList=new List<HttpCalloutVO.PolicyAvailFund>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                Dom.XmlNode investmentNode=getChildNodeIfNotNull('Investment',childNode);
                List<Dom.XmlNode> subAccountNodes=getChildElementsIfNotNull(investmentNode);
                //Dom.XmlNode subAccountNode=getChildNodeIfNotNull('SubAccount',investmentNode);
                for(Dom.XmlNode subAccountNode:subAccountNodes){
                    HttpCalloutVO.PolicyAvailFund availFund=new HttpCalloutVO.PolicyAvailFund();
                    availFund.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    availFund.productCode=getChildNodeTextIfNotEmpty('ProductCode',subAccountNode);
                    availFund.productFullName=getChildNodeTextIfNotEmpty('ProductFullName',subAccountNode);
                    availFund.currNumberUnits=getChildNodeDecimalIfNotEmpty('CurrNumberUnits',subAccountNode);
                    if(availFund.currNumberUnits!=null){
                        availFund.currNumberUnits=availFund.currNumberUnits.setScale(2,System.RoundingMode.FLOOR);
                    }

                    availFund.unitValue=getChildNodeDecimalIfNotEmpty('UnitValue',subAccountNode);
                    if(availFund.unitValue!=null){
                        availFund.unitValue=availFund.unitValue.setScale(2,System.RoundingMode.FLOOR);
                    }

                    availFund.unitValueBuyRate=getChildNodeDecimalIfNotEmpty('UnitValueBuyRate',subAccountNode);
                    if(availFund.unitValueBuyRate!=null){
                        availFund.unitValueBuyRate=availFund.unitValueBuyRate.setScale(2,System.RoundingMode.FLOOR);
                    }

                    availFund.totValue=getChildNodeDecimalIfNotEmpty('TotValue',subAccountNode);
                    if(availFund.totValue!=null){
                        availFund.totValue=availFund.totValue.setScale(2,System.RoundingMode.FLOOR);
                        //system.debug('[PolicyCalloutHelper] availFund.totValue='+availFund.totValue);
                    }
                    if(Test.isRunningTest() || availFund.totValue==null){
                        //system.debug('[PolicyCalloutHelper] availFund.totValue is null and update to 0.0');
                        availFund.totValue=0.0;
                    }

                    Dom.XmlNode oLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',subAccountNode);
                    availFund.basicPlanPercent=getChildNodeTextIfNotEmpty('BasicPlanPercent',oLifEExtensionNode);
                    availFund.regularAFCPercent=getChildNodeTextIfNotEmpty('RegularAFCPercent',oLifEExtensionNode);
                    availFund.singleAFCPercent=getChildNodeTextIfNotEmpty('SingleAFCPercent',oLifEExtensionNode);
                    availFund.basicPlanPercentInNumber=getChildNodeDecimalIfNotEmpty('BasicPlanPercent',oLifEExtensionNode);
                    availFund.regularAFCPercentInNumber=getChildNodeDecimalIfNotEmpty('RegularAFCPercent',oLifEExtensionNode);
                    availFund.singleAFCPercentInNumber=getChildNodeDecimalIfNotEmpty('SingleAFCPercent',oLifEExtensionNode);
                    
                    // Added by Linus 2020-Jun-24
                    availFund.withdrawalValue=getChildNodeDecimalIfNotEmpty('WithdrawalValue',investmentNode);
                    if(availFund.withdrawalValue!=null){
                        availFund.withdrawalValue=availFund.withdrawalValue.setScale(2,System.RoundingMode.FLOOR);
                        //system.debug('[PolicyCalloutHelper] availFund.withdrawalValue='+availFund.withdrawalValue);
                    }
                    if(availFund.withdrawalValue==null){
                        //system.debug('[PolicyCalloutHelper] availFund.withdrawalValue is null and update to 0.0');
                        availFund.withdrawalValue=0.0;
                    }
                    
                    // Added by Linus 2020-Jul-9
                    availFund.totalcurrNumberUnits=getChildNodeDecimalIfNotEmpty('TotalCurrNumberUnits',subAccountNode);
                    if(availFund.totalcurrNumberUnits!=null){
                        availFund.totalcurrNumberUnits=availFund.totalcurrNumberUnits.setScale(2,System.RoundingMode.FLOOR);
                        //system.debug('[PolicyCalloutHelper] availFund.totalcurrNumberUnits='+availFund.totalcurrNumberUnits);
                    }
                    if(availFund.totalcurrNumberUnits==null){
                        //system.debug('[PolicyCalloutHelper] availFund.totalcurrNumberUnits is null and update to 0.0');
                        availFund.totalcurrNumberUnits=0.0;
                    }
                    
                    objList.add(availFund);
                }
            }
        }
        system.debug('List<HttpCalloutVO.PolicyAvailFund> '+objList.size());
        return objList;
    }
    
    /********************************************************************
     * getPolicyPersonCoverageBasic
     * @param String,@param String
     * @decs:Call GetPolicyPersonCoverageBasic WS to get person coverage info
     * @return List<HttpCalloutVO.PolicyPersonCoverage>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyPersonCoverage> getPolicyPersonCoverageBasic(String policyNumber,String govtID){
        system.debug('PolicyCalloutHelper.getPolicyPersonCoverageBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonCoverageBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('GovtID',govtID);
        paramsMap.put('PartyTypeCode',PolicyCalloutHelper.INSURED);
        return (List<HttpCalloutVO.PolicyPersonCoverage>)execute(new Map<String,String>());
    }
  
    /********************************************************************
     * getPolicyPersonCoverageBasic
     * @param String,@param String,@param String
     * @decs:Call GetPolicyPersonCoverageBasic WS to get person coverage info
     * @return List<HttpCalloutVO.PolicyPersonCoverage>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyPersonCoverage> getPolicyPersonCoverageBasic(String policyNumber,String govtID,String planNumber){
        system.debug('PolicyCalloutHelper.getPolicyPersonCoverageBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonCoverageBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('GovtID',govtID);
        paramsMap.put('planNo',planNumber);
        paramsMap.put('PartyTypeCode',PolicyCalloutHelper.INSURED);
        return (List<HttpCalloutVO.PolicyPersonCoverage>)execute(new Map<String,String>());
    }

    /********************************************************************
     * getPolicyPersonCoverageBasic
     * @param
     * @decs:Call GetPolicyPersonCoverageBasic WS to get List plan and benefits
     * @return List<HttpCalloutVO.PolicyPersonCoverage>
     * @author chris
    ********************************************************************/
    public List<HttpCalloutVO.PolicyPersonCoverage> getPolicyPersonCoverageBasic(String policyNumber,List<String> planNumberList,String renewal){
        system.debug('PolicyCalloutHelper.getPolicyPersonCoverageBasic');
        this.functionName = PolicyCalloutHelper.GetPolicyPersonCoverageBasic;
        paramsMap = new Map<String, String>();
        paramsMap.put('PolNumber', policyNumber);
        paramsMap.put('PartyTypeCode', PolicyCalloutHelper.INSURED);
        paramsMap.put('RenewalPosition', renewal);
        String planNoList = planNumberList[0];
        planNumberList.remove(0);
        while(!planNumberList.isEmpty()){
            planNoList += ',' + planNumberList[0];
            planNumberList.remove(0);
        }
        system.debug('planNoList = ' + planNoList);
        paramsMap.put('planNoList', planNoList);
        return (List<HttpCalloutVO.PolicyPersonCoverage>)execute(new Map<String, String>());
    }
    
    public List<HttpCalloutVO.PolicyPersonCoverage> getPolicyPersonCoverageBasic(String policyNumber,String govtID,String planNumber,String certNo){
        return getPolicyPersonCoverageBasic(policyNumber,govtID,planNumber,certNo,null);
    }
    
    /********************************************************************
     * getPolicyPersonCoverageBasic
     * @param String,@param String,@param String,@String
     * @decs:Call GetPolicyPersonCoverageBasic WS to get person coverage info
     * @return List<HttpCalloutVO.PolicyPersonCoverage>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyPersonCoverage> getPolicyPersonCoverageBasic(String policyNumber,String govtID,String planNumber,String certNo,String familyRecInd){
        system.debug('PolicyCalloutHelper.getPolicyPersonCoverageBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonCoverageBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('GovtID',govtID);
        paramsMap.put('planNo',planNumber);
        paramsMap.put('PartyTypeCode',PolicyCalloutHelper.INSURED);
        paramsMap.put('CertNo',certNo);
        if(String.IsNotBlank(familyRecInd)){
            paramsMap.put('FamilyRecInd',familyRecInd);
        }
        return (List<HttpCalloutVO.PolicyPersonCoverage>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyPersonCoverageBasicResult
     * @param String,@param String,@param String,@String
     * @decs:Handle GetPolicyPersonCoverageBasic repsonse
     * @return List<HttpCalloutVO.PolicyPersonCoverage>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyPersonCoverage> processPolicyPersonCoverageBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyPersonCoverageBasicResult');
        Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> holdingMap=new Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>();
        Map<String,HttpCalloutVO.Person> partyMap=new Map<String,HttpCalloutVO.Person>();
        List<HttpCalloutVO.Relation> relationList=new List<HttpCalloutVO.Relation>();
        List<HttpCalloutVO.PolicyPersonCoverage> objList=new List<HttpCalloutVO.PolicyPersonCoverage>();
         
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                Dom.XmlNode lifeNode=getChildNodeIfNotNull('Life',policyNode);
                List<Dom.XmlNode> coverageNodeList=getChildElementsIfNotNull(lifeNode);
                List<HttpCalloutVO.PolicyPersonCoverage> coverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
                String lastCoverageName='';
                String holdingId=childNode.getAttributeValue('id',null);
                
                HttpCalloutVO.Policy policy=new HttpCalloutVO.Policy();
                Policy.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                Policy.currencyCode=getChildNodeAttributeIfNotEmpty('CurrencyTypeCode','tc',childNode);
                Policy.currencyCodeDesc=getChildNodeTextIfNotEmpty('CurrencyTypeCode',childNode);
                if(Policy.currencyCode=='344'){
                    Policy.currencySymbol='HKD';
                }else if(Policy.currencyCode=='840'){
                    Policy.currencySymbol='USD';
                }else if(Policy.currencySymbol=='156'){
                    Policy.currencySymbol='RMB';
                }else{
                    Policy.currencySymbol=Policy.currencyCodeDesc;
                }

                Policy.effDate=getChildNodeTextIfNotEmpty('EffDate',policyNode);
                Policy.effDateInDate=getChildNodeDateIfNotEmpty('EffDate',policyNode,'yyyy-MM-dd');
                Policy.issueDate=getChildNodeTextIfNotEmpty('IssueDate',policyNode);
                Policy.issueDateInDate=getChildNodeDateIfNotEmpty('IssueDate',policyNode,'yyyy-MM-dd');
                Policy.termDate=getChildNodeTextIfNotEmpty('TermDate',policyNode);
                Policy.termDateInDate=getChildNodeDateIfNotEmpty('TermDate',policyNode,'yyyy-MM-dd');
                Policy.paymentInfo=new HttpCalloutVO.PolicyPayment();
                Policy.paymentInfo.modalPremium=getChildNodeDecimalIfNotEmpty('PaymentAmt',policyNode);
                Policy.paymentInfo.annualPremium=getChildNodeDecimalIfNotEmpty('AnnualPaymentAmt',policyNode);
                Policy.paymentInfo.sumInsured=getChildNodeDecimalIfNotEmpty('PolicyValue',policyNode);
                Policy.productCode=getChildNodeTextIfNotEmpty('ProductCode',policyNode);
                Policy.marketingName=getChildNodeTextIfNotEmpty('MarketingName',policyNode);
                Policy.productType=getChildNodeTextIfNotEmpty('ProductType',policyNode);
                Policy.productTypeCode=getChildNodeAttributeIfNotEmpty('ProductType','tc',policyNode);
                Policy.renewalNoticeInd=getChildNodeTextIfNotEmpty('RenewalNoticeInd',policyNode);// Rancho_JOBR367_20240513 - update premium display
                
                Dom.XmlNode PoLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',policyNode);
                List<Dom.XmlNode> benefitNodeList=getChildElementsIfNotNull(PoLifEExtensionNode);
                List<HttpCalloutVO.BenefitScheduleRemark> benefitRemarkList=new List<HttpCalloutVO.BenefitScheduleRemark>();
                for(Dom.XmlNode benefitNode: benefitNodeList){
                    if(benefitNode.getName()=='BenefitScheduleRemark'){
                        HttpCalloutVO.BenefitScheduleRemark remark=new HttpCalloutVO.BenefitScheduleRemark();
                        remark.BenefitScheduleRemarkItem=getChildNodeTextIfNotEmpty('BenefitScheduleRemarkItem',benefitNode);
                        remark.BenefitScheduleRemarkDesc=getChildNodeTextIfNotEmpty('BenefitScheduleRemarkDesc',benefitNode);
                        benefitRemarkList.add(remark);
                    }
                }
                
                for(Dom.XmlNode coverageNode: coverageNodeList){
                    HttpCalloutVO.PolicyPersonCoverage coverage=new HttpCalloutVO.PolicyPersonCoverage();
                    // policy node
                    String currentCoverage=getChildNodeTextIfNotEmpty('CovNumber',coverageNode);
                    //if(!currentCoverage.equals(lastCoverageName)){
                        lastCoverageName=currentCoverage;
                        //add by chris li for planNo value in coverage for benefit mapping
                        coverage.planNo = getChildNodeTextIfNotEmpty('PlanNumber',policyNode);
                        //end
                        coverage.sectionType=getChildNodeTextIfNotEmpty('SectionType',coverageNode);
                        coverage.coverageNumber=getChildNodeTextIfNotEmpty('CovNumber',coverageNode);
                        coverage.coverageStatus=getChildNodeTextIfNotEmpty('LifeCovStatus',coverageNode);
                        coverage.holdingID=coverageNode.getAttributeValue('id',null);
                        coverage.currencySymbol=Policy.currencySymbol;
                        coverage.currencyTypeCodeTC=Policy.currencyCode;
                        coverage.policyNumber=Policy.policyNumber;
                        coverage.effectiveDate=getChildNodeTextIfNotEmpty('IssueDate',coverageNode);
                        coverage.effectiveDateInDate=getChildNodeDateIfNotEmpty('IssueDate',coverageNode,'yyyy-MM-dd');
                        coverage.issueDate=getChildNodeTextIfNotEmpty('IssueDate',coverageNode);
                        coverage.issueDateInDate=getChildNodeDateIfNotEmpty('IssueDate',coverageNode,'yyyy-MM-dd');
                        coverage.policyEffectiveDate=Policy.effDateInDate;
                        coverage.policyIssueDate=Policy.issueDateInDate;
                        coverage.termDate=getChildNodeTextIfNotEmpty('ExpiryDate',coverageNode);
                        coverage.termDateInDate=getChildNodeDateIfNotEmpty('ExpiryDate',coverageNode,'yyyy-MM-dd');
                        //coverage.modalPremium=Policy.paymentInfo.modalPremium;
                        //coverage.annualPremium=Policy.paymentInfo.annualPremium;
                        coverage.annualPremium=getChildNodeDecimalIfNotEmpty('AnnualPremAmt',coverageNode);
                        // Zoe updated on 0614,PPCP-33
                        coverage.sumInsured=Policy.paymentInfo.sumInsured;
                        if(coverage.sumInsured!=null){
                            coverage.sumInsured=coverage.sumInsured.setScale(2,System.RoundingMode.FLOOR);
                        }
                        coverage.policyProductCode=Policy.productCode;
                        coverage.marketingName=Policy.marketingName;
                        coverage.productType=Policy.productType;
                        coverage.planTypeCode=Policy.planTypeCode;
                        coverage.planTypeDesc=Policy.productType;
                    
                        //START HKITSFDC-265
                        coverage.planLevel=getChildNodeTextIfNotEmpty('PlanLevel',policyNode);
                        coverage.AreaOfCover=getChildNodeTextIfNotEmpty('AreaOfCover',policyNode);
                        coverage.RoomType=getChildNodeTextIfNotEmpty('RoomType',policyNode);
                        //END HKITSFDC-265

                        //START HKITSFDC-412
                        coverage.RemainSumInsured=getChildNodeTextIfNotEmpty('RemainSumInsured',coverageNode);
                        coverage.CoveragePeriodFrom=getChildNodeTextIfNotEmpty('CoveragePeriodFrom',coverageNode);
                        coverage.CoveragePeriodFromInDate=getChildNodeDateIfNotEmpty('CoveragePeriodFrom',coverageNode,'yyyy-MM-dd');
                        coverage.CoveragePeriodTo=getChildNodeTextIfNotEmpty('CoveragePeriodTo',coverageNode);
                        coverage.CoveragePeriodToInDate=getChildNodeDateIfNotEmpty('CoveragePeriodTo',coverageNode,'yyyy-MM-dd');
                        //END HKITSFDC-412
                        
                        // Coverage node
                        String benefitCodeRateScale=getChildNodeTextIfNotEmpty('ProductCode',coverageNode);
                        coverage.benefitCode=benefitCodeRateScale;
                        if(benefitCodeRateScale.indexOf(':')!=-1){  //assume the format is:BenefiCode:RateScale
                            coverage.benefitCode=benefitCodeRateScale.split(':')[0].trim();
                            coverage.rateScale=benefitCodeRateScale.split(':')[1].trim();
                        }
                        coverage.planName=getChildNodeTextIfNotEmpty('PlanName',coverageNode);
                        coverage.benefitName=getChildNodeTextIfNotEmpty('PlanName',coverageNode);
                        coverage.benefitDesc=getChildNodeTextIfNotEmpty('PlanName',coverageNode); // for individual
                        coverage.benefitAmountInNumber=getChildNodeDecimalIfNotEmpty('CurrentAmt',coverageNode);
                        if(coverage.benefitAmountInNumber !=null){
                            coverage.benefitAmountInNumber=coverage.benefitAmountInNumber.setScale(2,System.RoundingMode.FLOOR);
                        }
                        coverage.modalPremium=getChildNodeDecimalIfNotEmpty('ModalPremAmt',coverageNode);
                        coverage.coverageIndicator=getChildNodeTextIfNotEmpty('IndicatorCode',coverageNode);
                        coverage.benefitDetailItemNo=getChildNodeTextIfNotEmpty('CovNumber',coverageNode);

                        //add by Andy Li for GOP 2020-05-26 start
                        coverage.wardType=getChildNodeTextIfNotEmpty('WardType',coverageNode);
                        //add by Andy Li for GOP 2020-05-26 end
                        
                        // DeductionOption Node
                        Dom.XmlNode DeductionOptionNode=getChildNodeIfNotNull('DeductionOption',coverageNode);
                        coverage.deductibleAmount=getChildNodeDecimalIfNotEmpty('DeductAmt',DeductionOptionNode);
                        coverage.deductibleType=getChildNodeTextIfNotEmpty('DeductAmtType',DeductionOptionNode);
                        coverage.benefitMarketingName=getChildNodeTextIfNotEmpty('MarketingName',coverageNode);
                        coverage.productMarketingName=getChildNodeTextIfNotEmpty('MarketingName',coverageNode);
                        // OLifEExtension Node
                        
                        //JR1783
                        coverage.faceAmt=getChildNodeDecimalIfNotEmpty('FaceAmt',coverageNode);
                        //JR1783
                        
                        Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',coverageNode);
                        coverage.benefitDetailItemDesc=getChildNodeTextIfNotEmpty('BenefitItemDesc',OLifEExtensionNode);
                        coverage.benefitLevelDesc=getChildNodeTextIfNotEmpty('BenefitLevelDesc',OLifEExtensionNode);
                        coverage.benefitItemIdentity=getChildNodeTextIfNotEmpty('BenefitItemIdentity',OLifEExtensionNode);
                        coverage.benefitItemDescDtl=getChildNodeTextIfNotEmpty('BenefitItemDescDtl',OLifEExtensionNode);
                        coverage.benefitItemCode=getChildNodeTextIfNotEmpty('BenefitItemCode',OLifEExtensionNode);
                        
                        coverage.benefitLevel=getChildNodeTextIfNotEmpty('BenefitLevelDesc',OLifEExtensionNode);     // for group
                        coverage.benefitPlanName=getChildNodeTextIfNotEmpty('PlanName',OLifEExtensionNode);
                        coverage.productName=getChildNodeTextIfNotEmpty('PlanName',OLifEExtensionNode);              // for individual
                        coverage.benefitCodeDesc=getChildNodeTextIfNotEmpty('PlanName',OLifEExtensionNode);          // for group
                        // Rancho_JOBR382_20240730 - this value remains the same in EN/TC version
                        coverage.benefitEnName=getChildNodeTextIfNotEmpty('MarketingName',OLifEExtensionNode);
                        //coverage.productMarketingName=getChildNodeTextIfNotEmpty('MarketingName',OLifEExtensionNode); // for individual
                        coverage.productCode=getChildNodeTextIfNotEmpty('ProductCode',OLifEExtensionNode);           // for individual
                        if(String.isBlank(coverage.benefitCode)){
                            coverage.benefitCode=getChildNodeTextIfNotEmpty('ProductCode',OLifEExtensionNode);       // for group
                        }
                        coverage.businessCompanyCode=getChildNodeTextIfNotEmpty('BusinessCompanyCode',OLifEExtensionNode);
                        coverage.additionalFundContributionAmount=getChildNodeTextIfNotEmpty('AFCAmt',OLifEExtensionNode);
                        coverage.additionalFundContributionAmountInNumber=getChildNodeDecimalIfNotEmpty('AFCAmt',OLifEExtensionNode);
                        coverage.additionalFundContributionAnnualAmount=getChildNodeTextIfNotEmpty('AFCAnnualAmt',OLifEExtensionNode);
                        coverage.additionalFundContributionAnnualAmountInNumber=getChildNodeDecimalIfNotEmpty('AFCAnnualAmt',OLifEExtensionNode);
                    
                        // Loading Node
                        Dom.XmlNode LoadingNode=getChildNodeIfNotNull('Loading',OLifEExtensionNode);
                        coverage.loadingAmount=getChildNodeDecimalIfNotEmpty('LoadingAmount',LoadingNode);
                        if(getChildNodeDecimalIfNotEmpty('LoadingPercentage',LoadingNode)!=null){
                            coverage.loadingPercentage=getChildNodeDecimalIfNotEmpty('LoadingPercentage',LoadingNode) * 100;
                        }
                        coverage.loadingAmountDuration=getChildNodeDecimalIfNotEmpty('LoadingAmountDuration',LoadingNode);
                        coverage.loadingPercentageDuration=getChildNodeDecimalIfNotEmpty('LoadingPercentageDuration',LoadingNode);
                    
                         //JR1783
                        coverage.exclusionList=new List<HttpCalloutVO.Exclusion>();
                        List<Dom.XmlNode> extensionChildNodes=getChildElementsIfNotNull(OLifEExtensionNode);
                        for(Dom.XmlNode extensionChildNode:extensionChildNodes){
                            if(extensionChildNode.getName()=='Exclusion'){
                                HttpCalloutVO.Exclusion exclusion=new HttpCalloutVO.Exclusion();
                                exclusion.ExclusionSeqNo=Integer.valueOf(getChildNodeDecimalIfNotEmpty('ExclusionSeqNo',extensionChildNode));
                                exclusion.ExclusionCode=getChildNodeTextIfNotEmpty('ExclusionCode',extensionChildNode);
                                exclusion.ExclusionDesc=getChildNodeTextIfNotEmpty('ExclusionDesc',extensionChildNode);
                                // Rancho_HKITSFDC352_20250825 - add plan code
                                exclusion.planCode=coverage.benefitCode;
                                coverage.exclusionList.add(exclusion);
                            }
                        }
                        //JR1783
    
                        //objList.add(coverage);
                        if(benefitRemarkList!=null){
                            if(benefitRemarkList.size()>0){
                                coverage.benefitScheduleRemarkList.addAll(benefitRemarkList);
                            }
                        }
                        //SPS-323
                        coverage.insuredSSN=getChildNodeTextIfNotEmpty('GovtID',coverageNode);
                        //SPS-323
                        coverageList.add(coverage);
                    //}
                }
                holdingMap.put(holdingId,coverageList);
            }else if(childNode.getName()=='Party'){
                //coverage.PlanNo
                HttpCalloutVO.Person party=new HttpCalloutVO.Person();
                party.partyID=childNode.getAttributeValue('id',null);
                party.fullName=getChildNodeTextIfNotEmpty('FullName',childNode);
                party.ssnNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                party.insuredName=getChildNodeTextIfNotEmpty('FullName',childNode);    // for individual
                party.memberName=getChildNodeTextIfNotEmpty('FullName',childNode);     // for group
                Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',childNode);
                party.certificateNo=getChildNodeTextIfNotEmpty('CertificateNo',OLifEExtensionNode);
                party.planNumber=getChildNodeTextIfNotEmpty('PlanNumber',OLifEExtensionNode);
                party.planDescription=getChildNodeTextIfNotEmpty('PlanDescription',OLifEExtensionNode);
                partyMap.put(party.partyID,party);
            }else if(childNode.getName()=='Relation'){
                HttpCalloutVO.Relation relation=new HttpCalloutVO.Relation();
                relation.id=childNode.getAttributeValue('id',null);
                relation.OriginatingObjectID=childNode.getAttributeValue('OriginatingObjectID',null);
                relation.RelatedObjectID=childNode.getAttributeValue('RelatedObjectID',null);
                relation.OriginatingObjectType=getChildNodeTextIfNotEmpty('OriginatingObjectType',childNode);
                relation.OriginatingObjectCode=getChildNodeAttributeIfNotEmpty('OriginatingObjectType','tc',childNode);
                relation.RelatedObjectType=getChildNodeTextIfNotEmpty('RelatedObjectType',childNode);
                relation.RelatedObjectCode=getChildNodeAttributeIfNotEmpty('RelatedObjectType','tc',childNode);
                relation.RelationRoleCode=getChildNodeAttributeIfNotEmpty('RelationRoleCode','tc',childNode);
                relation.RelationRoleType=getChildNodeTextIfNotEmpty('RelationRoleCode',childNode);
                relationList.add(relation);
            }
        }
        //SPS-323: For individual policy,the response should contain SSN
        //chris troubleshoot NullPointerException
        if(relationList.size() > 0){
            HttpCalloutVO.Relation r=relationList.get(0);
            HttpCalloutVO.PolicyPersonCoverage indicator=holdingMap.get(r.OriginatingObjectID).get(0);
            if(String.isBlank(indicator.insuredSSN)){ // For Group Policy
                for(HttpCalloutVO.Relation relation:relationList){
                    List<HttpCalloutVO.PolicyPersonCoverage> holding=holdingMap.get(relation.OriginatingObjectID);
                    HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
                    if(party !=null && holding!=null){
                        for(HttpCalloutVO.PolicyPersonCoverage p :holding){
                            p.memberCertNo=party.certificateNo;
                            p.planNo=party.planNumber;
                            p.planDescription=party.planDescription;
                            p.insuredName=party.insuredName;
                            p.memberName=party.memberName;
                            // Rancho_HKITSFDC402_20250930 - set value for insured ssn
                            p.insuredSSN=party.ssnNumber;
                        }
                    }
                }
                for(List<HttpCalloutVO.PolicyPersonCoverage> h:holdingMap.values() ){
                    objList.addAll(h);
                }
            }else{ // For Individual Policy
                for(HttpCalloutVO.Relation relation:relationList){
                    List<HttpCalloutVO.PolicyPersonCoverage> holding=holdingMap.get(relation.OriginatingObjectID);
                    HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
                    List<HttpCalloutVO.PolicyPersonCoverage> tempList=new List<HttpCalloutVO.PolicyPersonCoverage>();
                    for(HttpCalloutVO.PolicyPersonCoverage coverage:holding){
                        if(coverage.insuredSSN==party.ssnNumber){
                            coverage.insuredName=party.fullName;
                            tempList.add(coverage);
                            //system.debug('[PolicyCalloutHelper] coverageNumber='+coverage.coverageNumber);
                        }
                    }
                    tempList.sort();
                    //system.debug('[PolicyCalloutHelper] tempList after sort='+tempList);
                    objList.addAll(tempList);
                }
            }
        }else{
            //for client portal benefits
            for(List<HttpCalloutVO.PolicyPersonCoverage> coverageList:holdingMap.values()){
                objList.addAll(coverageList);
            }
        }
        system.debug('List<HttpCalloutVO.PolicyPersonCoverage> '+objList.size());
        return objList;
    }
    
    public List<HttpCalloutVO.Person> getPolicyHolderListBasic(String policyNumber){
        return getPolicyPersonListBasic(policyNumber,PolicyCalloutHelper.OWNER);
    }
    
    public List<HttpCalloutVO.Person> getPolicyInsuredListBasic(String policyNumber){
        return getPolicyPersonListBasic(policyNumber,PolicyCalloutHelper.INSURED);
    }
    
    public List<HttpCalloutVO.Person> getPolicyInsuredListBasic(String policyNumber,Boolean allPI){    // AH18767 - David
        return getPolicyPersonListBasic(policyNumber,PolicyCalloutHelper.INSURED,allPI);
    }
    
    public List<HttpCalloutVO.Person> getPolicyBeneficiaryListBasic(String policyNumber){
        return getPolicyPersonListBasic(policyNumber,PolicyCalloutHelper.BENEFICIARY);
    }
    
    /********************************************************************
     * getPolicyPersonListBasic
     * @param String,@param String
     * @decs:Get policy person basic info
     * @return List<HttpCalloutVO.Person>
     * @remark: personTypeCode:8=OLI_REL_OWNER
     *                         32=OLI_REL_INSURED
     *                         34=OLI_REL_BENEFICIARY
     *                         999=OLI_REL_ANY
   ********************************************************************/
    public List<HttpCalloutVO.Person> getPolicyPersonListBasic(String policyNumber,String personTypeCode){
        return getPolicyPersonListBasic(policyNumber,personTypeCode,false);
    }
    
    public List<HttpCalloutVO.Person> getPolicyPersonListBasic(String policyNumber,String personTypeCode,Boolean allPI){     // AH18767 - David
        system.debug('PolicyCalloutHelper.getPolicyPersonListBasic');
        this.functionName = PolicyCalloutHelper.GetPolicyPersonListBasic;
        paramsMap=new Map<String, String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('PartyTypeCode',personTypeCode);
        paramsMap.put('ShowAllPI',allPI!=NULL&&allPI?'Y':'N');         // AH18767 - David
        return (List<HttpCalloutVO.Person>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyPersonListBasicResult
     * @param Dom.document
     * @decs:Handle the GetPolicyPersonListBasic WS repsonse
     * @return List<HttpCalloutVO.Person>
   ********************************************************************/
    public List<HttpCalloutVO.Person> processPolicyPersonListBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyPersonListBasicResult');
        List<HttpCalloutVO.Person> objList=new List<HttpCalloutVO.Person>();
        Map<String,HttpCalloutVO.Person> partyMap=new Map<String,HttpCalloutVO.Person>();
        List<HttpCalloutVO.Relation> relationList=new List<HttpCalloutVO.Relation>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Party'){
                String partyTypeCode=getChildNodeAttributeIfNotEmpty('PartyTypeCode','tc',childNode);
                if(partyTypeCode=='1'){ //Person
                    Dom.XmlNode personNode=getChildNodeIfNotNull('Person',childNode);
                    HttpCalloutVO.Person person=new HttpCalloutVO.Person();
                    person.partyID=childNode.getAttributeValue('id',null);
                    person.ssnNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                    person.fullName=getChildNodeTextIfNotEmpty('FullName',childNode);
                    person.firstName=getChildNodeTextIfNotEmpty('FirstName',personNode);
                    person.middleName=getChildNodeTextIfNotEmpty('MiddleName',personNode);
                    person.lastName=getChildNodeTextIfNotEmpty('LastName',personNode);
                    
                    //20210621 Bob Asia Mile 
                    Dom.XmlNode membershipNode = getChildNodeIfNotNull('Membership', childNode);
                    HttpCalloutVO.Membership membership = new HttpCalloutVO.Membership();
                    membership.channel=getChildNodeTextIfNotEmpty('Channel', membershipNode); 
                    if(membership.channel=='M'){
                        membership.membershipId = getChildNodeTextIfNotEmpty('MembershipId', membershipNode); 
                        membership.membershipFirstName = getChildNodeTextIfNotEmpty('MembershipFirstName', membershipNode); 
                        membership.membershipLastName = getChildNodeTextIfNotEmpty('MembershipLastName', membershipNode);
                        person.membership=membership;
                    }
                    //end
                    if(String.isBlank(person.fullName)){
                        person.fullName=(String.isNotBlank(person.lastName)?person.lastName:'') +' '+ (String.isNotBlank(person.firstName)?person.firstName:'');
                    }
                    person.title=getChildNodeTextIfNotEmpty('Title',personNode);
                    person.gender=getChildNodeTextIfNotEmpty('Gender',personNode);
                    person.birthDate=getChildNodeTextIfNotEmpty('BirthDate',personNode);
                    person.birthDateInDate=getChildNodeDateIfNotEmpty('BirthDate',personNode,'yyyy-MM-dd');
                    Dom.XmlNode emailAddressNode=getChildNodeIfNotNull('EmailAddress',childNode);
                    person.emailAddress=getChildNodeTextIfNotEmpty('AddrLine',emailAddressNode);
                    
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',personNode);
                    person.certificateNo=getChildNodeTextIfNotEmpty('CertificateNo',OLifEExtensionNode);
                    person.certificateEffDate=getChildNodeTextIfNotEmpty('CertificateEffDate',OLifEExtensionNode);
                    person.certificateEffDateInDate=getChildNodeDateIfNotEmpty('CertificateEffDate',OLifEExtensionNode,'yyyy-MM-dd');
                    person.memberStatusDesc=getChildNodeTextIfNotEmpty('MemberStatusDesc',OLifEExtensionNode);
                    person.planNumber=getChildNodeTextIfNotEmpty('PlanNumber',OLifEExtensionNode);
                    person.branchCode=getChildNodeTextIfNotEmpty('BranchCode',OLifEExtensionNode);
                    person.branchDesc=getChildNodeTextIfNotEmpty('BranchDesc',OLifEExtensionNode);
                    person.lifeSumAssured=getChildNodeTextIfNotEmpty('LifeSumAssured',OLifEExtensionNode);
                    person.tpdSumAssured=getChildNodeTextIfNotEmpty('TPDSumAssured',OLifEExtensionNode);
                    person.addSumAssured=getChildNodeTextIfNotEmpty('ADDSumAssured',OLifEExtensionNode);
                    person.ltdSumAssured=getChildNodeTextIfNotEmpty('LTDSumAssured',OLifEExtensionNode);
                    person.cibSumAssured=getChildNodeTextIfNotEmpty('CIBSumAssured',OLifEExtensionNode);
                    person.lifeSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('LifeSumAssured',OLifEExtensionNode);
                    person.tpdSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('TPDSumAssured',OLifEExtensionNode);
                    person.addSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('ADDSumAssured',OLifEExtensionNode);
                    person.ltdSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('LTDSumAssured',OLifEExtensionNode);
                    person.cibSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('CIBSumAssured',OLifEExtensionNode);
                    person.GroupMedicalBenefitStr=getChildNodeTextIfNotEmpty('GroupMedicalBenefitStr',OLifEExtensionNode);
                    person.isIndividual=getChildNodeBooleanIfNotEmpty('IndividualPersonInd',OLifEExtensionNode);
                    if(person.isIndividual!=null && !person.isIndividual){
                        person.memberName=getChildNodeTextIfNotEmpty('FullName',childNode);
                    }
                    //objList.add(person);
                    partyMap.put(person.partyID,person);
                }
            }else if(childNode.getName()=='Relation'){
                HttpCalloutVO.Relation relation=new HttpCalloutVO.Relation();
                relation.id=childNode.getAttributeValue('id',null);
                relation.OriginatingObjectID=childNode.getAttributeValue('OriginatingObjectID',null);
                relation.RelatedObjectID=childNode.getAttributeValue('RelatedObjectID',null);
                relation.OriginatingObjectType=getChildNodeTextIfNotEmpty('OriginatingObjectType',childNode);
                relation.OriginatingObjectCode=getChildNodeAttributeIfNotEmpty('OriginatingObjectType','tc',childNode);
                relation.RelatedObjectType=getChildNodeTextIfNotEmpty('RelatedObjectType',childNode);
                relation.RelatedObjectCode=getChildNodeAttributeIfNotEmpty('RelatedObjectType','tc',childNode);
                relation.RelationRoleCode=getChildNodeAttributeIfNotEmpty('RelationRoleCode','tc',childNode);
                relation.RelationRoleType=getChildNodeTextIfNotEmpty('RelationRoleCode',childNode);
                relation.InsurableInterestReason=getChildNodeTextIfNotEmpty('InsurableInterestReason',childNode);
                relationList.add(relation);
            }
        }
        for(HttpCalloutVO.Relation relation:relationList){
            HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
            if(party!=null){
                party.insurableInterestReason=relation.InsurableInterestReason;
            }
        }
        objList.addAll(partyMap.values());
        system.debug('List<HttpCalloutVO.Person> '+objList.size());
        return objList;
    }

    // Client portal MemberDetail
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (Map<String, String> params){
        system.debug('PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria');
        this.functionName = PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria;
        paramsMap = new Map<String, String>();
        if(!params.isEmpty()){
            paramsMap=params;
        }

        return (List<HttpCalloutVO.Person>)execute(new Map<String, String>());
    }

    //Kirk-20211103-CP549-Add download Excel sign-Client portal MemberDetail
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (Map<String, String> params,Boolean download){
        system.debug('PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria');
        this.functionName = PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria;
        paramsMap = new Map<String, String>();
        if(!params.isEmpty()){
            paramsMap=params;
        }
        downloadSign = download;

        return (List<HttpCalloutVO.Person>)execute(new Map<String, String>());
    }


    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (String policyNumber,String memberName,String certNumber,String branchCode){
        system.debug('PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('InsuredMemberFullName',memberName);
        paramsMap.put('CertificateNo',certNumber);
        paramsMap.put('BranchCode',branchCode);
        return (List<HttpCalloutVO.Person>)execute(new Map<String,String>());
    }
    
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (String policyNumber,String memberName,String certNumber,String branchCode,Boolean showAllPI){
        if(showAllPI){
            this.roleId='CS';
            this.showAllPI=true;
        }
        return getPolicyPersonListBasicByCriteria(policyNumber,memberName,certNumber,branchCode);
    }
    
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (String policyNumber,String memberName,String certNumber,String branchCode,String holderGovtID,String roleId){
        this.roleId=roleId;
        return getPolicyPersonListBasicByCriteria(policyNumber,memberName,certNumber,branchCode,holderGovtID);
    }
    
     public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (String policyNumber,String memberName,String certNumber,String branchCode,String holderGovtID){
         return getPolicyPersonListBasicByCriteria(policyNumber,'',memberName,null,'',certNumber,branchCode,holderGovtID,'','');
     }
    
    /*
     * @ holderName,memberDOB,ssnNumber
     * @ memberDOB,claimNumber,personType(Owner/Insured/Beneficiary/Any),certNumber(Group Only) added by Nicole in Pahse2
     * @remove claimNumber
     */
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria(String policyNumber,String holderName,String memberName,Date memberDOB,String ssnNumber,String certNumber,String branchCode,String holderGovtID,String personType,String familyRecInd){
        system.debug('PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('InsuredMemberFullName',memberName);
        paramsMap.put('CertificateNo',certNumber);
        paramsMap.put('BranchCode',branchCode);
        paramsMap.put('HolderGovtID',holderGovtID);
        paramsMap.put('PolicyType',PolicyCallOutHelper.POLICY_TYPE_GROUP);
        if(holderName !=null){
            paramsMap.put('PolicyHolderName',holderName);
        }
        if(memberName !=null){
            paramsMap.put('MemberName',memberName);
        }
        
        if(memberDOB !=null){
        //system.debug('###test memberDOB22 '+ memberDOB);
            paramsMap.put('memberDOB',memberDOB.year()+'-'+memberDOB.month()+'-'+memberDOB.day());
        }
        if(ssnNumber !=null){
            paramsMap.put('InsuredGovtID',ssnNumber);
        }
        
        if(String.IsNotBlank(personType) && String.IsNotBlank(personTypeMap.get(personType))){
            paramsMap.put('RelationRole',personType);
            paramsMap.put('RelationRoleCode',personTypeMap.get(personType));
        }else{
            paramsMap.put('RelationRole','Any');
            paramsMap.put('RelationRoleCode','999');
        }
        if(String.IsNotBlank(ssnNumber)){
            paramsMap.put('ssnNumber',ssnNumber);
        }
        if(String.IsNotBlank(familyRecInd)){
            paramsMap.put('FamilyRecInd',familyRecInd);
        }
        system.debug('----paramsMap--'+paramsMap);
        //system.debug('FamilyRecInd==========================='+FamilyRecInd);
        //system.debug('RelationRole==========================='+personType);
        return (List<HttpCalloutVO.Person>)execute(new Map<String,String>());
    }
    // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --START
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria (String policyNumber,String certNumber,String familyInd){
        system.debug('PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('CertificateNo4Family',certNumber);
        paramsMap.put('FamilyInd',familyInd);
        return (List<HttpCalloutVO.Person>)execute(new Map<String,String>());
    }
    // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --END
    
    //SPS-323
    /*
     * @ WS name: GetPolicyPersonListBasicByCriteria
     * @ params: String policyNumber,Boolean showAllPI
     * @ return: List<HttpCalloutVO.Person>
     **/
    public List<HttpCalloutVO.Person> getPolicyPersonListBasicByCriteria(String policyNumber,Boolean showAllPI){
        system.debug('PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria');
        this.functionName=PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('ShowAllPI',(showAllPI?'Y':'N'));
        return (List<HttpCalloutVO.Person>)execute(new Map<String,String>());
    }
    //SPS-323
  
    /********************************************************************
     * processPolicyPersonListBasicByCriteriaResult
     * @param Dom.document
     * @decs:Handle the GetPolicyPersonListBasicByCriteria WS repsonse
     * @return List<HttpCalloutVO.Person>
   ********************************************************************/
    public List<HttpCalloutVO.Person> processPolicyPersonListBasicByCriteriaResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyPersonListBasicByCriteriaResult');
        List<HttpCalloutVO.Person> objList=new List<HttpCalloutVO.Person>();
        Map<String,HttpCalloutVO.Person> partyMap=new Map<String,HttpCalloutVO.Person>();
        Map<String,HttpCalloutVO.Policy> holdingMap=new Map<String,HttpCalloutVO.Policy>();
        List<HttpCalloutVO.Relation> relationList=new List<HttpCalloutVO.Relation>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Party'){
                String partyTypeCode=getChildNodeAttributeIfNotEmpty('PartyTypeCode','tc',childNode);
                if(partyTypeCode=='1'){ //Person
                    Dom.XmlNode personNode=getChildNodeIfNotNull('Person',childNode);
                    HttpCalloutVO.Person person=new HttpCalloutVO.Person();
                    person.partyID=childNode.getAttributeValue('id',null);
                    person.idType = getChildNodeTextIfNotEmpty('IDType', childNode);// added by Connor CP-156(Client Portal)
                    person.idTypeCode = getChildNodeTextIfNotEmpty('IDTypeCode', childNode);// added by Connor (Client Portal)
                    person.ssnNumber = getChildNodeTextIfNotEmpty('GovtID', childNode);
                    person.countryOfResidence = getChildNodeTextIfNotEmpty('CountryOfResidence', childNode); // added by Connor CP-156(Client Portal)
                    person.countryOfResidenceCode = getChildNodeTextIfNotEmpty('CountryOfResidenceCode', childNode); // added by Connor(Client Portal)
                    person.maritalStatus = getChildNodeTextIfNotEmpty('MaritalStatus', childNode);// added by Connor CP-156(Client Portal)
                    person.maritalStatusCode = getChildNodeTextIfNotEmpty('MaritalStatusCode', childNode);// added by Connor(Client Portal)
                    person.fullName = getChildNodeTextIfNotEmpty('FullName', childNode);
                    person.firstName = getChildNodeTextIfNotEmpty('FirstName', personNode);
                    person.middleName = getChildNodeTextIfNotEmpty('MiddleName', personNode);
                    person.lastName = getChildNodeTextIfNotEmpty('LastName', personNode);

                    if(String.isBlank(person.fullName)){
                        person.fullName=(String.isNotBlank(person.lastName)?person.lastName:'') +' '+ (String.isNotBlank(person.firstName)?person.firstName:'');
                    }
                    person.title=getChildNodeTextIfNotEmpty('Title',personNode);
                    person.gender=getChildNodeTextIfNotEmpty('Gender',personNode);
                    person.birthDate=getChildNodeTextIfNotEmpty('BirthDate',personNode);
                    person.birthDateInDate=getChildNodeDateIfNotEmpty('BirthDate',personNode,'yyyy-MM-dd');
                    Dom.XmlNode emailAddressNode=getChildNodeIfNotNull('EMailAddress',childNode); // change EmailAddress to EMailAddress for fix CSSIT-73
                    person.emailAddress=getChildNodeTextIfNotEmpty('AddrLine',emailAddressNode);
                    person.emailValidFlag=getChildNodeAttributeIfNotEmpty('isValid','tc',emailAddressNode);//CS Member Level Jack add
                    
                    //ILAS jack add begin
                    Dom.XmlNode riskProfileNode=getChildNodeIfNotNull('RiskProfile',childNode);
                    person.rPQStatusCode=getChildNodeTextIfNotEmpty('RiskLevelCode',riskProfileNode);
                    person.rPQStatus=getChildNodeTextIfNotEmpty('RiskLevelDesc',riskProfileNode);
                    person.rPQEffectiveDate=getChildNodeDateIfNotEmpty('RiskEffDate',riskProfileNode,'yyyy-MM-dd');
                    person.rPQUpdateSource=getChildNodeTextIfNotEmpty('UpdateSource',riskProfileNode);
                    person.rPQUpdateDate=getChildNodeDateIfNotEmpty('UpdateDate',riskProfileNode,'yyyy-MM-dd');
                    String rPQUpdateTime=getChildNodeTextIfNotEmpty('UpdateTime',riskProfileNode);
                    if(rPQUpdateTime!=null){
                        List<String> timeList=rPQUpdateTime.split(':');
                        if(timeList.size()>2){
                            person.rPQUpdateTime=Time.newInstance(Integer.Valueof(timeList[0]),Integer.Valueof(timeList[1]),Integer.Valueof(timeList[2]),0);
                        }
                    }
                    //ILAS jack add end
                    
                    //Start for fix CSSIT-73:Email,Contact Number and Correspondence Address
                    Dom.XmlNode AddressNode=getChildNodeIfNotNull('Address',childNode);
                    String addressTypeCode = getChildNodeAttributeIfNotEmpty('AddressTypeCode', 'tc', AddressNode);
                    person.addressType=getChildNodeTextIfNotEmpty('AddressTypeCode',AddressNode);
                    person.addressLine1=getChildNodeTextIfNotEmpty('Line1',AddressNode);
                    person.addressLine2=getChildNodeTextIfNotEmpty('Line2',AddressNode);
                    person.addressLine3=getChildNodeTextIfNotEmpty('Line3',AddressNode);
                    person.addressLine4=getChildNodeTextIfNotEmpty('Line4',AddressNode);
                    person.addressState=getChildNodeTextIfNotEmpty('AddressState',AddressNode);
                    person.addressCountry=getChildNodeTextIfNotEmpty('AddressCountry',AddressNode);
                    person.fullAddress=handleString(person.addressLine1,',')+handleString(person.addressLine2,',')
                       +handleString(person.addressLine3,',')+handleString(person.addressLine4,',')
                       +handleString(person.addressState,',')+handleString(person.addressCountry,'');
                    if(String.isBlank(person.fullAddress.substringAfterLast(','))){
                        person.fullAddress=person.fullAddress.substringBeforeLast(',');
                    }
                    //add Bob CP-155
                    person.postalAddress = handleString(person.addressLine1,', ') + handleString(person.addressLine2,', ')
                        + handleString(person.addressLine3,', ')+ handleString(person.addressCountry,'');
                    if(addressTypeCode=='17'&&String.isBlank(person.postalAddress.substringAfterLast(','))){
                        person.postalAddress = person.postalAddress.substringAfterLast(',');
                    }
                    //CS Member Level Jack add begin
                    person.addressValidFlag=getChildNodeAttributeIfNotEmpty('isValid','tc',AddressNode);

                    person.nationality=getChildNodeTextIfNotEmpty('NationalityDesc',childNode);
                    //system.debug('addressValidFlag'+person.addressValidFlag+' nationality'+person.nationality);
                    //CS Member Level Jack add end
                    
                    //CS Member Level Jack change to access all the phone node
                    List<Dom.XmlNode> partyChildNodes=getChildElementsIfNotNull(childNode);
                    for(Dom.XmlNode pChildNode:partyChildNodes){
                        if(pChildNode.getName()=='Phone'){
                            Dom.XmlNode phoneNode=pChildNode;
                            String phoneTypeCode=getChildNodeAttributeIfNotEmpty('PhoneTypeCode','tc',phoneNode);
                            if(phoneTypeCode=='1'){ // Home
                                person.homePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.homePhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.homePhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }else if(phoneTypeCode=='2'){ // Business
                                person.businessPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.businessPhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.businessPhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }else if(phoneTypeCode=='4'){ // Business Fax
                                person.businessFaxNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.businessFaxCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.businessFaxAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }else if(phoneTypeCode=='12'){ // Mobile
                                person.mobilePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.mobileCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.mobileAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }else if(phoneTypeCode=='15'){ // Home Fax
                                person.homeFaxNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.homeFaxCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.homeFaxAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }else if(phoneTypeCode=='2147483647'){ // Other Phone
                                person.otherPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.otherPhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.otherPhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }else if(phoneTypeCode=='1052500002'){ //Correspondence Phone
                                person.correspondencePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                                person.correspondencePhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                                person.correspondencePhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            }
                        }
                    }
                    //End for fix CSSIT-73
                    //system.debug('mobilePhoneNo'+person.mobilePhoneNo+' homePhoneNo:'+person.homePhoneNo+' businessPhoneNo'+person.businessPhoneNo);
                   
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',personNode);
                    person.certificateNo=getChildNodeTextIfNotEmpty('CertificateNo',OLifEExtensionNode);
                    person.staffID = getChildNodeTextIfNotEmpty('StaffID', OLifEExtensionNode); // added by Connor CP-156(Client Portal)
                    person.companyDesc = getChildNodeTextIfNotEmpty('CompanyDesc', OLifEExtensionNode); // added by Connor CP-156(Client Portal)
                    person.departmentDesc = getChildNodeTextIfNotEmpty('DepartmentDesc', OLifEExtensionNode); // added by Connor CP-156(Client Portal)
                    person.departmentCode = getChildNodeTextIfNotEmpty('DepartmentCode', OLifEExtensionNode); //Rancho_CP782_20220206
                    person.certificateEffDate=getChildNodeTextIfNotEmpty('CertificateEffDate',OLifEExtensionNode);
                    person.effDate=getChildNodeTextIfNotEmpty('EffDate',OLifEExtensionNode); //IBM KOU PEI-156
                    person.effDateInDate=getChildNodeDateIfNotEmpty('EffDate',OLifEExtensionNode,'yyyy-MM-dd'); //by Caden for HKSIR4516
                    person.certificateEffDateInDate=getChildNodeDateIfNotEmpty('CertificateEffDate',OLifEExtensionNode,'yyyy-MM-dd');
                    person.memberStatusDesc=getChildNodeTextIfNotEmpty('MemberStatusDesc',OLifEExtensionNode);
                    if(person.memberStatusDesc!=null){
                        if(person.memberStatusDesc.startsWithIgnoreCase('Active')){
                            person.memberStatusDisplay='Inforced';
                        }else if(person.memberStatusDesc.startsWithIgnoreCase('Inactive')){
                            person.memberStatusDisplay='Cancelled';
                        }
                    }
                    
                    person.planNumber=getChildNodeTextIfNotEmpty('PlanNumber',OLifEExtensionNode);
                    person.branchCode=getChildNodeTextIfNotEmpty('BranchCode',OLifEExtensionNode);
                    person.branchDesc=getChildNodeTextIfNotEmpty('BranchDesc',OLifEExtensionNode);
                    person.FamilyRecInd=getChildNodeTextIfNotEmpty('FamilyRecInd',OLifEExtensionNode);
                    if(String.IsNotBlank(person.FamilyRecInd)){
                        if(person.FamilyRecInd=='2'){
                            person.RelationRole='spouse';
                        }else if(person.FamilyRecInd=='3'){
                            person.RelationRole='dependent';
                        }else if(person.FamilyRecInd=='4'){
                            person.RelationRole='employee';
                        }
                    }
                    //system.debug('person.FamilyRecInd >>>>>>>>>>>>>' +person.FamilyRecInd);
                    //system.debug('person.RelationRole >>>>>>>>>>>>>' +person.RelationRole);
                    person.lifeSumAssured=getChildNodeTextIfNotEmpty('LifeSumAssured',OLifEExtensionNode);
                    person.tpdSumAssured=getChildNodeTextIfNotEmpty('TPDSumAssured',OLifEExtensionNode);
                    person.addSumAssured=getChildNodeTextIfNotEmpty('ADDSumAssured',OLifEExtensionNode);
                    person.ltdSumAssured=getChildNodeTextIfNotEmpty('LTDSumAssured',OLifEExtensionNode);
                    person.cibSumAssured=getChildNodeTextIfNotEmpty('CIBSumAssured',OLifEExtensionNode);
                    person.lifeSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('LifeSumAssured',OLifEExtensionNode);
                    person.tpdSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('TPDSumAssured',OLifEExtensionNode);
                    person.addSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('ADDSumAssured',OLifEExtensionNode);
                    person.ltdSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('LTDSumAssured',OLifEExtensionNode);
                    person.cibSumAssuredInNumber=getChildNodeDecimalIfNotEmpty('CIBSumAssured',OLifEExtensionNode);
                    person.effectiveDate=getChildNodeDateIfNotEmpty('EffDate',OLifEExtensionNode,'yyyy-MM-dd');
                    person.terminationDate=getChildNodeDateIfNotEmpty('TermDate',OLifEExtensionNode,'yyyy-MM-dd');
                    
                    // Start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                    person.PlanName=getChildNodeTextIfNotEmpty('PlanName',OLifEExtensionNode);
                    person.eMedicalCardType=getChildNodeTextIfNotEmpty('EMedicalCardType',OLifEExtensionNode);
                    // end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx

                    //add Bob CP-155
                    person.years = getChildNodeTextIfNotEmpty('Age', OLifEExtensionNode);
                    person.employmentDate = getChildNodeTextIfNotEmpty('EmploymentDate', OLifEExtensionNode);
                    person.salary = getChildNodeTextIfNotEmpty('Salary', OLifEExtensionNode);
                    person.occupation = getChildNodeTextIfNotEmpty('Occupation', OLifEExtensionNode);
                    person.stationedCountry = getChildNodeTextIfNotEmpty('StationedCountry', OLifEExtensionNode);
                    person.stationedCountryCode = getChildNodeTextIfNotEmpty('StationedCountryCode', OLifEExtensionNode); //added by Connor(Client Portal)
                    person.alias = getChildNodeTextIfNotEmpty('Alias', OLifEExtensionNode);
                    person.planDesc = getChildNodeTextIfNotEmpty('PlanDesc', OLifEExtensionNode);
                    //end
                    person.hasEMedicalCard = 'Y'.equals(getChildNodeTextIfNotEmpty('HasEMedicalCard', OLifEExtensionNode));//added by Connor CP-266(Client Portal)
                    //junda 20200925 add
                    person.waiverPreExist=getChildNodeTextIfNotEmpty('WaiverPreExist',OLifEExtensionNode);
                    person.productCode=getChildNodeTextIfNotEmpty('ProductCode',OLifEExtensionNode);
                    //end
                    //Add by Owen ,2023.06.30 for GetPolicyPersonListBasicByCriteria to get GOPIndicator and PreAuthIndicator
                    //person.PreAuthIndicator='True'.equals(getChildNodeTextIfNotEmpty('PreAuthIndicator',OLifEExtensionNode));
                    //Hardcopy Indicator added start
                    Dom.XmlNode HardCopyIndicatorNode=getChildNodeIfNotNull('HardCopyIndicator',OLifEExtensionNode);
                    person.medCardIndicator=getChildNodeTextIfNotEmpty('MedCardIndicator',HardCopyIndicatorNode);
                    person.letterIndicator=getChildNodeTextIfNotEmpty('LetterIndicator',HardCopyIndicatorNode);
                    //Hardcopy Indicator added end
                    
                    person.GroupMedicalBenefitStr=getChildNodeTextIfNotEmpty('GroupMedicalBenefitStr',OLifEExtensionNode);
                    person.isIndividual=getChildNodeBooleanIfNotEmpty('IndividualPersonInd',OLifEExtensionNode);
                    if(person.isIndividual!=null && !person.isIndividual){
                        person.memberName=getChildNodeTextIfNotEmpty('FullName',childNode);
                    }
                    
                    person.ImpairmentList=new List<HttpCalloutVO.Impairment>();
                    List<Dom.XmlNode> ImpairmentNodeList=getChildElementsIfNotNull(OLifEExtensionNode);
                    for(Dom.XmlNode ImpairmentNode:ImpairmentNodeList){
                        HttpCalloutVO.Impairment Impairment=new HttpCalloutVO.Impairment();
                        Impairment.ImpairmentId=ImpairmentNode.getAttributeValue('id',null);
                        Impairment.ImpairmentCode=getChildNodeTextIfNotEmpty('ImpairmentCode',ImpairmentNode);
                        Impairment.ImpairmentDesc=getChildNodeTextIfNotEmpty('ImpairmentDesc',ImpairmentNode);
                        person.ImpairmentList.add(Impairment);
                    }
                    
                    //Raistlin - GS claim - 20191024
                    Dom.XmlNode bankAccountNode=getChildNodeIfNotNull('BankAccount',OLifEExtensionNode);
                    if(bankAccountNode!=null){
                        HttpCalloutVO.BankAccount bankAccount = new HttpCalloutVO.BankAccount();
                        bankAccount.accountNumber = getChildNodeTextIfNotEmpty('AccountNumber', bankAccountNode);
                        bankAccount.acctHolderName = getChildNodeTextIfNotEmpty('AcctHolderName', bankAccountNode);
                        bankAccount.bankName = getChildNodeTextIfNotEmpty('BankName', bankAccountNode);
                        bankAccount.bankCode = getChildNodeTextIfNotEmpty('BankCode', bankAccountNode);
                        person.bankName = getChildNodeTextIfNotEmpty('BankName', bankAccountNode);//add Bob cp-155
                        person.bankCode = getChildNodeTextIfNotEmpty('BankCode', bankAccountNode);//add Bob cp-155
                        bankAccount.branchCode = getChildNodeTextIfNotEmpty('BranchCode', bankAccountNode);
                        bankAccount.routingCode = getChildNodeTextIfNotEmpty('RoutingCode', bankAccountNode);
                        bankAccount.branchAddress = getChildNodeTextIfNotEmpty('BranchAddress', bankAccountNode);
                        bankAccount.swiftCode = getChildNodeTextIfNotEmpty('SwiftCode', bankAccountNode);
                        bankAccount.bankAccountCountry = getChildNodeTextIfNotEmpty('Country', bankAccountNode);
                        //junda add 20200925
                        bankAccount.payMethod=getChildNodeTextIfNotEmpty('PayMethod',bankAccountNode);
                        //end
                        person.bankAccount=bankAccount;
                    }
                    
                    //objList.add(person);
                    partyMap.put(person.partyID,person);
                }
            }else if(childNode.getName()=='Relation'){
                HttpCalloutVO.Relation relation=new HttpCalloutVO.Relation();
                relation.id=childNode.getAttributeValue('id',null);
                relation.OriginatingObjectID=childNode.getAttributeValue('OriginatingObjectID',null);
                relation.RelatedObjectID=childNode.getAttributeValue('RelatedObjectID',null);
                relation.OriginatingObjectType=getChildNodeTextIfNotEmpty('OriginatingObjectType',childNode);
                relation.OriginatingObjectCode=getChildNodeAttributeIfNotEmpty('OriginatingObjectType','tc',childNode);
                relation.RelatedObjectType=getChildNodeTextIfNotEmpty('RelatedObjectType',childNode);
                relation.RelatedObjectCode=getChildNodeAttributeIfNotEmpty('RelatedObjectType','tc',childNode);
                relation.RelationRoleCode=getChildNodeAttributeIfNotEmpty('RelationRoleCode','tc',childNode);
                relation.RelationRoleType=getChildNodeTextIfNotEmpty('RelationRoleCode',childNode);
                relation.InsurableInterestReason=getChildNodeTextIfNotEmpty('InsurableInterestReason',childNode);
                relation.InterestPercent=getChildNodeTextIfNotEmpty('InterestPercent',childNode);
                relationList.add(relation);
            }else if(childNode.getName()=='Holding'){
                HttpCalloutVO.Policy policy=new HttpCalloutVO.Policy();
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                policy.holdingID=childNode.getAttributeValue('id',null);
                policy.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                policy.productType=getChildNodeTextIfNotEmpty('ProductType',policyNode);
                policy.productTypeCode=getChildNodeAttributeIfNotEmpty('ProductType','tc',policyNode);
                policy.effDateInDate=getChildNodeDateIfNotEmpty('EffDate',policyNode,'yyyy-MM-dd');
                policy.termDateInDate=getChildNodeDateIfNotEmpty('TermDate',policyNode,'yyyy-MM-dd');
                policy.policyStatus=getChildNodeTextIfNotEmpty('PolicyStatus',policyNode);
                Dom.XmlNode pOLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',policyNode);
                policy.isIndividual=getChildNodeBooleanIfNotEmpty('IndividualPolicyInd',pOLifEExtensionNode);
                policy.policyRemark=getChildNodeTextIfNotEmpty('Remarks',pOLifEExtensionNode);
                policy.holderName=getChildNodeTextIfNotEmpty('PolicyHolderName',pOLifEExtensionNode);
                //Add by Owen ,2023.06.30 for GetPolicyPersonListBasicByCriteria to get GOPIndicator and PreAuthIndicator
                //policy.GOPIndicator='True'.equals(getChildNodeTextIfNotEmpty('GOPIndicator',pOLifEExtensionNode));
                //Added by Connor
                Dom.XmlNode pOLifExHardCopyIndicatorNode=getChildNodeIfNotNull('HardCopyIndicator',pOLifEExtensionNode);
                policy.medCardIndicator=getChildNodeTextIfNotEmpty('MedCardIndicator',pOLifExHardCopyIndicatorNode);
                policy.letterIndicator=getChildNodeTextIfNotEmpty('LetterIndicator',pOLifExHardCopyIndicatorNode);
                //Added by Connor
                
                //JR1785
                policy.category=getChildNodeTextIfNotEmpty('PolCategory',policyNode);
                holdingMap.put(policy.holdingID,policy);
            }
        }
        for(HttpCalloutVO.Relation relation:relationList){
            HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
            HttpCalloutVO.Policy policy=holdingMap.get(relation.OriginatingObjectID);
            if(party!=null){
                party.insurableInterestReason=relation.InsurableInterestReason;
                party.InterestPercent=relation.InterestPercent;
                party.policyNumber=policy.policyNumber;
                party.isIndividual=policy.isIndividual;
                party.productType=policy.productType;
                party.productTypeCode=policy.productTypeCode;
                party.policyEffectiveDate=policy.effDateInDate;
                party.policyTerminationDate=policy.termDateInDate;
                party.policyStatus=policy.policyStatus;
                party.CFARemark_PolicyLevel=policy.policyRemark ;
                party.category=policy.category;//JR1785
            }
        }
        for(String partyID:partyMap.keySet()){
            HttpCalloutVO.Person party=partyMap.get(partyID);
            for(HttpCalloutVO.Relation relation:relationList){
                if(relation.RelatedObjectID==partyID){
                    HttpCalloutVO.Policy policy=holdingMap.get(relation.OriginatingObjectID);
                    party.policyList.add(policy);
                }
            }
        }
        objList.addAll(partyMap.values());
        system.debug('List<HttpCalloutVO.Person> '+objList.size());
        return objList;
    }
    
    //Deprecated
    /*
    public List<HttpCalloutVO.Claim> getPolicyClaimBasic(String policyNumber){
        system.debug('>>>>> PolicyCalloutHelper.getPolicyClaimBasic >>>>>');
        this.functionName=PolicyCalloutHelper.GetPolicyClaimBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        return (List<HttpCalloutVO.Claim>)execute(new Map<String,String>());
    }
    */
    
    /********************************************************************
     * getPolicyClaimBasicIndividual
     * @param String,@param String,@param String,@param String,@param String
     * @decs:Call GetPolicyClaimBasic WS to get individual claim info
     * @return List<HttpCalloutVO.Claim>
   ********************************************************************/
    public List<HttpCalloutVO.Claim> getPolicyClaimBasicIndividual(String policyNumber,String claimNumber,String insuredName,String productCode,String benefitDesc){
        system.debug('PolicyCalloutHelper.getPolicyClaimBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyClaimBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('HOClaimReferenceID',claimNumber);
        paramsMap.put('FullName',insuredName);
        paramsMap.put('ProductCode',productCode);
        paramsMap.put('CoverageProductCode',benefitDesc);
        return (List<HttpCalloutVO.Claim>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * getPolicyClaimBasicGroup
     * @param String,@param String,@param String
     * @decs:Call GetPolicyClaimBasic WS to get group claim info
     * @return List<HttpCalloutVO.Claim>
   ********************************************************************/
    public List<HttpCalloutVO.Claim> getPolicyClaimBasicGroup(String policyNumber,String claimNumber,String certNumber){
        system.debug('PolicyCalloutHelper.getPolicyClaimBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyClaimBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('HOClaimReferenceID',claimNumber);
        paramsMap.put('CertificateNo',certNumber);
        return (List<HttpCalloutVO.Claim>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyClaimBasicResult
     * @param Dom.document
     * @decs:Handle the GetPolicyClaimBasic WS repsonse
     * @return List<HttpCalloutVO.Claim>
   ********************************************************************/
    public List<HttpCalloutVO.Claim> processPolicyClaimBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyClaimBasicResult');
        List<HttpCalloutVO.Claim> objList=new List<HttpCalloutVO.Claim>();
        Map<String,HttpCalloutVO.Claim> holdingMap=new Map<String,HttpCalloutVO.Claim>();
        Map<String,HttpCalloutVO.Person> partyMap=new Map<String,HttpCalloutVO.Person>();
        List<HttpCalloutVO.Relation> relationList=new List<HttpCalloutVO.Relation>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        List<Claim_Type_Code_Mapping_From_WS__c> psm=Claim_Type_Code_Mapping_From_WS__c.getAll().values();
        String amountPayable;
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode bankingNode=getChildNodeIfNotNull('Banking',childNode);
                amountPayable=getChildNodeTextIfNotEmpty('AccountNumber',bankingNode);
                if(String.isNotBlank(amountPayable)){
                    continue;
                }
                HttpCalloutVO.Claim claim=new HttpCalloutVO.Claim();
                claim.currencyCode=getChildNodeAttributeIfNotEmpty('CurrencyTypeCode','tc',childNode);
                claim.currencyDescription=getChildNodeTextIfNotEmpty('CurrencyTypeCode',childNode);
                
                if(claim.currencyCode=='344'){
                    claim.currencySymbol='HKD';
                }else if(claim.currencyCode=='840'){
                    claim.currencySymbol='USD';
                }else if(claim.currencySymbol=='156'){
                    claim.currencySymbol='RMB';
                }else{
                    claim.currencySymbol=claim.currencyDescription;
                }
                    
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                Dom.XmlNode claimNode=getChildNodeIfNotNull('Claim',policyNode);
                if(claimNode!=null){
                    claim.holdingID=childNode.getAttributeValue('id',null);
                    claim.polNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    claim.sumInsured=getChildNodeDecimalIfNotEmpty('PolicyValue',policyNode);
                    claim.paymentMethodCode=getChildNodeAttributeIfNotEmpty('PaymentMethod','tc',policyNode);
                    claim.paymentMethodDescription=getChildNodeTextIfNotEmpty('PaymentMethod',policyNode);
                    
                    Dom.XmlNode lifeNode=getChildNodeIfNotNull('Life',policyNode);
                    Dom.XmlNode coverageNode=getChildNodeIfNotNull('Coverage',lifeNode);
                    Dom.XmlNode OLifEExtension1=getChildNodeIfNotNull('OLifEExtension',coverageNode);
                    
                    claim.benefitType=getChildNodeTextIfNotEmpty('ProductCode',OLifEExtension1);
                    claim.benefitTypeDescription=getChildNodeTextIfNotEmpty('PlanName',OLifEExtension1);
                    claim.benefitItemDescription=getChildNodeTextIfNotEmpty('BenefitItemDesc',OLifEExtension1);
                    claim.benefitItemCode=getChildNodeTextIfNotEmpty('BenefitItemCode',OLifEExtension1);
                    
                    if(String.isNotBlank(claim.benefitType)){
                        if('zh_HK'.equalsIgnoreCase(this.userLanguage) || 'zh_CN'.equalsIgnoreCase(this.userLanguage) || 'zh_TW'.equalsIgnoreCase(this.userLanguage)){
                            for(Claim_Type_Code_Mapping_From_WS__c p:psm){
                                if(p.CTM_CODE_WS__c==claim.benefitType){
                                    claim.benefitTypeDisplay=p.Claim_Type_Display_Wordings_Chinese__c;
                                }
                            }
                        }else{
                            for(Claim_Type_Code_Mapping_From_WS__c p:psm){
                                if(p.CTM_CODE_WS__c==claim.benefitType){
                                    claim.benefitTypeDisplay=p.Claim_Type_Display_Wordings_English__c;
                                }
                            }
                        }
                        if(String.isBlank(claim.benefitTypeDisplay)){
                            claim.benefitTypeDisplay=claim.benefitTypeDescription;
                        }
                    }
                    
                    claim.claimNumber=getChildNodeTextIfNotEmpty('HOClaimReferenceID',claimNode);
                    claim.actualObjectType=getChildNodeTextIfNotEmpty('ActualObjectType',claimNode);
                    claim.submitDate=getChildNodeTextIfNotEmpty('LossReportDate',claimNode);
                    claim.submitDateInDate=getChildNodeDateIfNotEmpty('LossReportDate',claimNode,'yyyy-MM-dd');
                    claim.claimDate=getChildNodeTextIfNotEmpty('ClaimDateOfLoss',claimNode);
                    claim.claimStatusCode=getChildNodeAttributeIfNotEmpty('ClaimStatus','tc',claimNode);
                    claim.claimStatus=getChildNodeTextIfNotEmpty('ClaimStatus',claimNode);
                    claim.claimStatusDescription=claim.claimStatus;
                    claim.claimTypeCode=getChildNodeAttributeIfNotEmpty('ClaimType','tc',claimNode);
                    claim.claimTypeDescription=getChildNodeTextIfNotEmpty('ClaimType',claimNode);
                    
                    if(String.isNotBlank(claim.claimTypeCode)){
                        if('zh_HK'.equalsIgnoreCase(this.userLanguage) || 'zh_CN'.equalsIgnoreCase(this.userLanguage)|| 'zh_TW'.equalsIgnoreCase(this.userLanguage)){
                            for(Claim_Type_Code_Mapping_From_WS__c p:psm){
                                if(p.CTM_CODE_WS__c==claim.claimTypeCode){
                                    claim.claimTypeDisplay=p.Claim_Type_Display_Wordings_Chinese__c;
                                }
                            }
                        }else{
                            for(Claim_Type_Code_Mapping_From_WS__c p:psm){
                                if(p.CTM_CODE_WS__c==claim.claimTypeCode){
                                    claim.claimTypeDisplay=p.Claim_Type_Display_Wordings_English__c;
                                }
                            }
                        }
                        
                        if(String.isBlank(claim.claimTypeDisplay)){
                            claim.claimTypeDisplay=claim.claimTypeDescription;
                            if(String.isBlank(claim.claimTypeDisplay)){
                                claim.claimTypeDisplay='N/A';
                            }
                        }
                    }else{
                        claim.claimTypeDisplay='N/A';
                    }
                    
                    claim.paidAmount=getChildNodeDecimalIfNotEmpty('AmountPaidToDate',claimNode);
                    // AH18015 revise claim paid amount retrieval in claim detail
                    claim.refundAmount=getChildNodeDecimalIfNotEmpty('RefundAmount',claimNode);
                    claim.deductPremium=getChildNodeDecimalIfNotEmpty('DeductPremium',claimNode);
                    claim.incurredAmount=getChildNodeDecimalIfNotEmpty('TotalCost',claimNode);
                    
                    // ClaimMedConditionInfo
                    Dom.XmlNode claimMedConditionInfoNode=getChildNodeIfNotNull('ClaimMedConditionInfo',claimNode);
                    claim.consultationDate=getChildNodeTextIfNotEmpty('StartDate',claimMedConditionInfoNode);
                    claim.consultationDateInDate=getChildNodeDateIfNotEmpty('StartDate',claimMedConditionInfoNode,'yyyy-MM-dd');
                    claim.lossPeriodFrom=getChildNodeDateIfNotEmpty('StartDate',claimMedConditionInfoNode,'yyyy-MM-dd');
                    claim.dischargeDate=getChildNodeTextIfNotEmpty('EndDate',claimMedConditionInfoNode);
                    claim.dischargeDateInDate=getChildNodeDateIfNotEmpty('EndDate',claimMedConditionInfoNode,'yyyy-MM-dd');
                    claim.lossPeriodTo=getChildNodeDateIfNotEmpty('EndDate',claimMedConditionInfoNode,'yyyy-MM-dd');
                    
                     // OLifEExtension
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',claimNode);
                    claim.lastUpdateDate=getChildNodeTextIfNotEmpty('LastUpdateDate',OLifEExtensionNode);
                    claim.lastUpdateDateInDate=getChildNodeDateIfNotEmpty('LastUpdateDate',OLifEExtensionNode,'yyyy-MM-dd');
                    claim.isBrokerClaim=getChildNodeBooleanIfNotEmpty('BrokerClaimInd',OLifEExtensionNode);
                    claim.paymentDate=getChildNodeTextIfNotEmpty('SettleDate',OLifEExtensionNode); // payment date ?
                    claim.paymentDateInDate=getChildNodeDateIfNotEmpty('SettleDate',OLifEExtensionNode,'yyyy-MM-dd');
                    claim.eventDate=getChildNodeDateIfNotEmpty('EventDate',OLifEExtensionNode,'yyyy-MM-dd');
                    claim.adviceRemarks=getChildNodeTextIfNotEmpty('AdviceRemarks',OLifEExtensionNode);
                    claim.claimRemarks=getChildNodeTextIfNotEmpty('ClaimRemarks',OLifEExtensionNode);
                    claim.renewalRemarks=getChildNodeTextIfNotEmpty('RenewalRemarks',OLifEExtensionNode);
                    claim.hgRemarks=getChildNodeTextIfNotEmpty('HGRemarks',OLifEExtensionNode);
                    claim.remarks=claim.adviceRemarks;
                    claim.rejectCode=getChildNodeTextIfNotEmpty('RejectCode',OLifEExtensionNode);
                    claim.rejectReason=getChildNodeTextIfNotEmpty('RejectMessage',OLifEExtensionNode);
                    claim.paymentCurrencyCode=getChildNodeAttributeIfNotEmpty('PaymentCurrencyTypeCode','tc',OLifEExtensionNode);
                    claim.paymentCurrencyDescription=getChildNodeTextIfNotEmpty('PaymentCurrencyTypeCode',OLifEExtensionNode);
                    
                    if(claim.paymentCurrencyCode=='344'){
                        claim.paymentCurrencySymbol='HKD';
                    }else if(claim.paymentCurrencyCode=='840'){
                        claim.paymentCurrencySymbol='USD';
                    }else if(claim.paymentCurrencySymbol=='156'){
                        claim.paymentCurrencySymbol='RMB';
                    }else{
                        claim.paymentCurrencySymbol=claim.paymentCurrencyDescription;
                    }
                    
                    claim.billingCurrencyCode=getChildNodeAttributeIfNotEmpty('HGBillCurrencyTypeCode','tc',OLifEExtensionNode);
                    claim.billingCurrencyDescription=getChildNodeTextIfNotEmpty('HGBillCurrencyTypeCode',OLifEExtensionNode);
                    if(claim.billingCurrencyCode=='344'){
                        claim.billingCurrencySymbol='HKD';
                    }else if(claim.billingCurrencyCode=='840'){
                        claim.billingCurrencySymbol='USD';
                    }else if(claim.billingCurrencyCode=='156'){
                        claim.billingCurrencySymbol='RMB';
                    }else{
                        claim.billingCurrencySymbol=claim.billingCurrencyDescription;
                    }
                    
                    // HealthGuard
                    claim.healthGuardList=new List<HttpCalloutVO.HealthGuard>();
                    List<Dom.XmlNode> hgNodes=getChildElementsIfNotNull(OLifEExtensionNode);
                    for(Dom.XmlNode hgNode:hgNodes){
                        if(hgNode.getName()=='HealthGuard'){
                            HttpCalloutVO.HealthGuard hg=new HttpCalloutVO.HealthGuard();
                            hg.dayClass=getChildNodeTextIfNotEmpty('DayClass',hgNode);
                            hg.benefitLevel=getChildNodeDecimalIfNotEmpty('BenefitLevel',hgNode);
                            hg.benefitName=getChildNodeTextIfNotEmpty('BenefitName',hgNode);
                            hg.maxDay=getChildNodeTextIfNotEmpty('MaxDay',hgNode);
                            hg.amountBilled=getChildNodeDecimalIfNotEmpty('BillAmt',hgNode);
                            hg.amountPayable=getChildNodeDecimalIfNotEmpty('PayAmt',hgNode);
                            //Nicole_20200218_Customer Portal - Display Issue
                            if(hg.benefitLevel==null){
                                hg.benefitLevelonString=getChildNodeTextIfNotEmpty('BenefitLevel',hgNode);
                            }
                            claim.healthGuardList.add(hg);
                        }
                    }
                    holdingMap.put(claim.holdingID,claim);
                    //objList.add(claim);
                }
            }else if(childNode.getName()=='Party'){
                HttpCalloutVO.Person party=new HttpCalloutVO.Person();
                party.partyID=childNode.getAttributeValue('id',null);
                party.fullName=getChildNodeTextIfNotEmpty('FullName',childNode);
                party.ssnNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                
                Dom.XmlNode riskNode=getChildNodeIfNotNull('Risk',childNode);
                Dom.XmlNode medicalConditionNode=getChildNodeIfNotNull('MedicalCondition',riskNode);
                Dom.XmlNode medicalTreatmentNode=getChildNodeIfNotNull('MedicalTreatment',medicalConditionNode);
                party.diagnosisCode=getChildNodeTextIfNotEmpty('TreatmentCode',medicalTreatmentNode);
                party.diagnosisDesc=getChildNodeTextIfNotEmpty('TreatmentDesc',medicalTreatmentNode);
                
                Dom.XmlNode oLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',childNode);
                party.certificateNo=getChildNodeTextIfNotEmpty('CertificateNo',oLifEExtensionNode);
                party.memberStatusDesc=getChildNodeTextIfNotEmpty('MemberStatusDesc',oLifEExtensionNode);
                party.branchCode=getChildNodeTextIfNotEmpty('BranchCode',oLifEExtensionNode);
                party.branchDesc=getChildNodeTextIfNotEmpty('BranchDesc',oLifEExtensionNode);
                partyMap.put(party.partyID,party);
            }else if(childNode.getName()=='Relation'){
                HttpCalloutVO.Relation relation=new HttpCalloutVO.Relation();
                relation.id=childNode.getAttributeValue('id',null);
                relation.OriginatingObjectID=childNode.getAttributeValue('OriginatingObjectID',null);
                relation.RelatedObjectID=childNode.getAttributeValue('RelatedObjectID',null);
                relation.OriginatingObjectType=getChildNodeTextIfNotEmpty('OriginatingObjectType',childNode);
                relation.OriginatingObjectCode=getChildNodeAttributeIfNotEmpty('OriginatingObjectType','tc',childNode);
                relation.RelatedObjectType=getChildNodeTextIfNotEmpty('RelatedObjectType',childNode);
                relation.RelatedObjectCode=getChildNodeAttributeIfNotEmpty('RelatedObjectType','tc',childNode);
                relation.RelationRoleCode=getChildNodeAttributeIfNotEmpty('RelationRoleCode','tc',childNode);
                relation.RelationRoleType=getChildNodeTextIfNotEmpty('RelationRoleCode',childNode);
                relationList.add(relation);
            }
        }
        for(HttpCalloutVO.Relation relation:relationList){
            HttpCalloutVO.claim holding=holdingMap.get(relation.OriginatingObjectID);
            HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
            if(holding!=null){
                holding.paymentTo=amountPayable;
            }
            if(holding!=null && party!=null){
                holding.ssnNumber=party.ssnNumber;
                holding.diagnosisCode=party.diagnosisCode;
                holding.diagnosisDesc=party.diagnosisDesc;
                holding.certNumber=party.certificateNo;
                holding.memberStatusDescription=party.memberStatusDesc;
                holding.branchCode=party.branchCode;
                holding.branchDesc=party.branchDesc;
            }
            /* add by Jack on 2022-06-07 for project: wrong insured name */
            if(relation.RelationRoleType == 'Coverage Insured'){
                holding.policyInsuredName=party.fullName;
            }
        }
        objList.addAll(holdingMap.values());
        system.debug('List<HttpCalloutVO.Claim> '+objList.size());
        return objList;
    }
    
    /********************************************************************
     * getPolicyDocTypeList
     * @param String
     * @decs:Call GetPolicyDocTypeList WS to get doc type list
     * @return List<HttpCalloutVO.PolicyDocType>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyDocType> getPolicyDocTypeList(String policyNumber){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName=PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        //add by kermit
        if(CignaUtil.isCustomerPortal()){
            this.appName=PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
        }else if(CignaUtil.isBrokerPortal()){
            this.appName=PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
        }else if(CignaUtil.isCSUser()){
            this.appName=PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
        }
        //end add by kermit
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String,String>());
    }
    public List<HttpCalloutVO.PolicyDocType> getPolicyDocTypeList(String policyNumber,String appName){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName=PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        this.appName=appName;
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String,String>());
    }
    /*efulfillment enhanced add start*/
    
    /********************************************************************
     * getPolicyDocTypeList
     * @param String policyNumber,String appName,String ssn
     * @decs:Call GetPolicyDocTypeList WS to get doc type list
     * @return List<HttpCalloutVO.PolicyDocType>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyDocType> getPolicyDocTypeList(String policyNumber,String appName,String ssn){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName=PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        if(String.IsNotBlank(ssn)){
            paramsMap.put('HolderGovtID',ssn);
        }
        if(String.IsNotBlank(appName)){
            this.appName=appName;
        }else{
            if(CignaUtil.isCustomerPortal()){
                this.appName=PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
            }else if(CignaUtil.isBrokerPortal()){
                this.appName=PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
            }else if(CignaUtil.isCSUser()){
                this.appName=PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
            }
        }
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String,String>());
    }
    
    /*efulfillment enhanced add start*/
    public List<HttpCalloutVO.PolicyDocType> getPolicyDocTypeList(String policyNumber,boolean isIndividual,string docLocation,string certNumber,string claimNumber,string startDateStr,string endDateStr ){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName=PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        if(isIndividual){
            paramsMap.put('GetDocPolicyType','I');
        }else{
            paramsMap.put('GetDocPolicyType','G');
        }
        if(!string.isBlank(docLocation)){
            paramsMap.put('GetDocAttachmentLocation',docLocation);
        }
        if(!string.isBlank(certNumber)){
            paramsMap.put('CertificateNo',certNumber);
        }
        if(!string.isBlank(claimNumber)){
            paramsMap.put('HOClaimReferenceID',claimNumber);
        }
        if(!string.isBlank(startDateStr)){
            paramsMap.put('GetDocStartDate',startDateStr);
        }
        if(!string.isBlank(claimNumber)){
            paramsMap.put('GetDocEndDate',startDateStr);
        }

        //add by kermit
        if(CignaUtil.isCustomerPortal()){
            this.appName=PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
        }else if(CignaUtil.isBrokerPortal()){
            this.appName=PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
        }else if(CignaUtil.isCSUser()){
            this.appName=PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
        }
        //end add by kermit
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String,String>());
    }
/*efulfillment enhanced add end*/
    
    //add by kermit
    public List<HttpCalloutVO.PolicyDocType> getPolicyDocTypeList(String policyNumber,boolean isIndividual,string docLocation,string certNumber,string claimNumber,string startDateStr,string endDateStr,String appName ){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName=PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        if(isIndividual){
            paramsMap.put('GetDocPolicyType','I');
        }else{
            paramsMap.put('GetDocPolicyType','G');
        }
        if(!string.isBlank(docLocation)){
            paramsMap.put('GetDocAttachmentLocation',docLocation);
        }
        if(!string.isBlank(certNumber)){
            paramsMap.put('CertificateNo',certNumber);
        }
        if(!string.isBlank(claimNumber)){
            paramsMap.put('HOClaimReferenceID',claimNumber);
        }
        if(!string.isBlank(startDateStr)){
            paramsMap.put('GetDocStartDate',startDateStr);
        }
        if(!string.isBlank(claimNumber)){
            paramsMap.put('GetDocEndDate',startDateStr);
        }
        this.appName=appName;
        
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String,String>());
    }
    //end add by kermit
    
    /********************************************************************
     * getPolicyDocTypeList
     * @param String policyNumber,boolean isIndividual,string docLocation,
     *        String certNumber,string claimNumber,string startDateStr,
     *        String endDateStr,String appName,String insuredGovtID
     * @decs:Call GetPolicyDocTypeList WS to get doc type list
     * @return List<HttpCalloutVO.PolicyDocType>
     ********************************************************************/
    public List<HttpCalloutVO.PolicyDocType> getPolicyDocTypeList(String policyNumber,boolean isIndividual,string docLocation,string certNumber,string claimNumber,string startDateStr,string endDateStr,String appName,String ssn){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName=PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        if(isIndividual){
            paramsMap.put('GetDocPolicyType','I');
        }else{
            paramsMap.put('GetDocPolicyType','G');
        }
        if(!string.isBlank(docLocation)){
            paramsMap.put('GetDocAttachmentLocation',docLocation);
        }
        if(!string.isBlank(certNumber)){
            paramsMap.put('CertificateNo',certNumber);
        }
        if(!string.isBlank(claimNumber)){
            paramsMap.put('HOClaimReferenceID',claimNumber);
        }
        if(!string.isBlank(startDateStr)){
            paramsMap.put('GetDocStartDate',startDateStr);
        }
        if(!string.isBlank(claimNumber)){
            paramsMap.put('GetDocEndDate',startDateStr);
        }
        if(String.IsNotBlank(appName)){
            this.appName=appName;
        }else{
            if(CignaUtil.isCustomerPortal()){
                this.appName=PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
            }else if(CignaUtil.isBrokerPortal()){
                this.appName=PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
            }else if(CignaUtil.isCSUser()){
                this.appName=PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
            }
        }
        if(String.IsNotBlank(ssn)){
            paramsMap.put('HolderGovtID',ssn);
        }
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String,String>());
    }
    
    /*
    * Jira: LPCSC-12 LPCSC-16
    * search premium reminders by criteria in broker lightning portal or in policy detail page in client portal
    * @param policyNo: policy number as search criteria
    * @param holderName: policy holder name as search criteria
    * @param docStartDate: start date as search criteria
    * @param docEndDate: end date as search criteria
    * @param isClientPortal: in client portal, will pass AccessLevel
    * @return List<HttpCalloutVO.PolicyDocType> containing attachment key and policy no to download document
    * @author Connor Huang
    * @version V1.0 init this method 2021-07-28 Connor Huang
    */
    public List<HttpCalloutVO.PolicyDocType> getPremiumReminders(String policyNo,String holderName,String docStartDate,String docEndDate,Boolean isClientPortal){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName = PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap = new Map<String, String>();
        paramsMap.put('GetDocPolicyType','G');
        paramsMap.put('PolNumber',policyNo);
        paramsMap.put('PolicyHolderName',holderName);
        paramsMap.put('GetDocAttachmentLocation','LHB OS Premium Reminder'); 
        paramsMap.put('AttachmentDurationYear','3'); 
        paramsMap.put('GetDocStartDate',docStartDate);
        paramsMap.put('GetDocEndDate',docEndDate);
        if(isClientPortal){paramsMap.put('AccessLevel','Y');}
        if(CignaUtil.isCustomerPortal()){
            this.appName = PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
        }else if(CignaUtil.isBrokerPortal()){
            this.appName = PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
        }else if(CignaUtil.isCSUser()){
            this.appName = PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
        }         
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String, String>());
    }


    /*
    * Jira: LPCSC-8
    * Get statements of account in broker lightning portal
    * @param attachmentDurationYear: default value is 3 passed from lwc, as requirement
    * @return List<HttpCalloutVO.PolicyDocType> containing attachment key and policy no to download document
    * @author Connor Huang
    * @version V1.0 init this method 2021-07-16 Connor Huang
    */
    public List<HttpCalloutVO.PolicyDocType> getBrokerStatementList(String attachmentDurationYear){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName = PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap = new Map<String, String>();
        paramsMap.put('GetDocPolicyType','G');
        paramsMap.put('PolNumber','LHBMONSTATEMENT');
        paramsMap.put('GetDocAttachmentLocation','LHB Monthly Statement'); 
        paramsMap.put('AttachmentDurationYear',attachmentDurationYear); 
        this.appName = PolicyCalloutHelper.BROKER_PORTAL_APPNAME;        
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String, String>());
    }

    // 20210610 - chris - Client Portal Document
    // Rancho_PI90_20221219 - add policy number into parameter, could not get doc without it
    // public List<HttpCalloutVO.PolicyDocType> getClientPolicyDocTypeList(String policyNo, String docLocation){
    //     system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
    //     this.functionName = PolicyCalloutHelper.GetPolicyDocTypeList;
    //     paramsMap = new Map<String, String>();
    //     paramsMap.put('GetDocPolicyType', 'G');
    //     paramsMap.put('PolNumber',policyNo);
    //     paramsMap.put('GetDocAttachmentLocation',docLocation); 
    //     if(docLocation == 'Client Portal Billing'){
    //         paramsMap.put('AccessLevel','Y'); 
    //     }
    //     if(CignaUtil.isCustomerPortal()){
    //         this.appName = PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
    //     }else if(CignaUtil.isBrokerPortal()){
    //         this.appName = PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
    //     }else if(CignaUtil.isCSUser()){
    //         this.appName = PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
    //     }        
    //     return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String, String>());
    // }

    // 20210319 - minghua - Client Portal Document
    public List<HttpCalloutVO.PolicyDocType> getClientPolicyDocTypeList(String policyNumber, String policyYear){
        return getClientPolicyDocTypeList(policyNumber, policyYear, 'Client Portal Document');
    }

    // Rancho_PI90_20221219 - expand parameters
    public List<HttpCalloutVO.PolicyDocType> getClientPolicyDocTypeList(String policyNumber, String policyYear, String docLocation){
        system.debug('PolicyCalloutHelper.getPolicyDocTypeList');
        this.functionName = PolicyCalloutHelper.GetPolicyDocTypeList;
        paramsMap = new Map<String, String>();
        paramsMap.put('PolNumber', policyNumber);
        paramsMap.put('GetDocPolicyType', 'G');
        paramsMap.put('GetDocAttachmentLocation', docLocation);
        if(String.isNotBlank(policyYear)){
            paramsMap.put('AttachmentPolicyYear', policyYear);
        }
        if(docLocation == 'Client Portal Billing'){
            paramsMap.put('AccessLevel','Y'); 
        }
        if(CignaUtil.isCustomerPortal()){
            this.appName = PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
        }else if(CignaUtil.isBrokerPortal()){
            this.appName = PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
        }else if(CignaUtil.isCSUser()){
            this.appName = PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
        }
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String, String>());
    }

    // 20210623  Added by Connor CR-47
    public List<HttpCalloutVO.PolicyDocType> updatePolicyDoc(String attKey, String docStatus){
        system.debug('PolicyCalloutHelper.UpdatePolicyDoc');
        this.functionName = PolicyCalloutHelper.UpdatePolicyDoc;
        paramsMap = new Map<String, String>();
        paramsMap.put('AttachmentKey', attKey);
        paramsMap.put('DocStatus', docStatus);     
        return (List<HttpCalloutVO.PolicyDocType>)execute(new Map<String, String>());
    }

    // 20210623  Added by Connor CR-47
    public List<HttpCalloutVO.PolicyDocType> processUpdatePolicyDocResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processUpdatePolicyDocResult');
        List<HttpCalloutVO.PolicyDocType> objList=new List<HttpCalloutVO.PolicyDocType>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXNBResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode TransResultNode = getChildNodeIfNotNull('TransResult', TXNBResponse);
        String resultCode = getChildNodeTextIfNotEmpty('ResultCode', TransResultNode);
        HttpCalloutVO.PolicyDocType docType = new HttpCalloutVO.PolicyDocType(); 
        if('Failure'.equalsIgnoreCase(resultCode)){
            docType.resultCode = 'Failure'; 
        }else{
            docType.resultCode = 'Success'; 
        }
        objList.add(docType);
        return objList;
    }

    /********************************************************************
     * processPolicyDocTypeListResult
     * @param (Dom.document
     * @decs:Handle GetPolicyDocTypeList WS repsonse
     * @return List<HttpCalloutVO.PolicyDocType>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyDocType> processPolicyDocTypeListResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyDocTypeListResult');
        List<HttpCalloutVO.PolicyDocType> objList=new List<HttpCalloutVO.PolicyDocType>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                /*efulfillment enhanced add start*/
                Dom.XmlNode claimNode=getChildNodeIfNotNull('Claim',policyNode);
                /*efulfillment enhanced add end*/
                List<Dom.XmlNode> attachments=getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode attachmentNode:attachments){
                    if(attachmentNode.getName()=='Attachment'){
                        HttpCalloutVO.PolicyDocType docType=new HttpCalloutVO.PolicyDocType();
                        docType.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                        docType.attachmentTypeCode=getChildNodeAttributeIfNotEmpty('AttachmentType','tc',attachmentNode);
                        docType.attachmentType=getChildNodeTextIfNotEmpty('AttachmentType',attachmentNode);
                        docType.fileName=getChildNodeTextIfNotEmpty('FileName',attachmentNode);
                        /*efulfillment enhanced add start*/
                        docType.createdDateStr=getChildNodeTextIfNotEmpty('CreationTime',attachmentNode);
                        docType.followUpDateStr=getChildNodeTextIfNotEmpty('FollowUpDate',attachmentNode);
                        docType.attachmentKey=getChildNodeTextIfNotEmpty('AttachmentKey',attachmentNode);
                        docType.documentLocation=getChildNodeTextIfNotEmpty('AttachmentLocation',attachmentNode);
                        docType.documentLocationTypeCode=getChildNodeAttributeIfNotEmpty('AttachmentLocation','tc',attachmentNode);
                        docType.Description=getChildNodeTextIfNotEmpty('Description',attachmentNode);
                        docType.certNumber=getChildNodeTextIfNotEmpty('CertificateNo',policyNode);
                        docType.claimNumber=getChildNodeTextIfNotEmpty('HOClaimReferenceID',claimNode);

                        Dom.XmlNode AttClaimNode=getChildNodeIfNotNull('AttachmentOLifeExtension',attachmentNode);
                        docType.claimNo=getChildNodeTextIfNotEmpty('ClaimNo',AttClaimNode);
                        docType.attchmentPolNumber=getChildNodeTextIfNotEmpty('PolicyNo',AttClaimNode);
                        docType.policyHolderName=getChildNodeTextIfNotEmpty('HolderName',AttClaimNode);//Premium Reminders search Connor LPCSC-12
                        // Rancho_HKITSFDC70_20240802 - use initial date
                        docType.docPolicyYear = getChildNodeTextIfNotEmpty('AttachmentPolicyYear',AttClaimNode);
                        /*efulfillment enhanced add end*/
                        docType.status = getChildNodeTextIfNotEmpty('Status',attachmentNode); //added by Connor CR-47
                        objList.add(docType);
                    }
                }
            }
        }
        system.debug('List<HttpCalloutVO.PolicyDocType> '+objList.size());
        return objList;
    }
    
    /*efulfillment endhanced backup start*/
/*
    public List<HttpCalloutVO.PolicyDoc> getPolicyDoc(String policyNumber,String fileName){
        system.debug('>>>>> PolicyCalloutHelper.getPolicyDoc >>>>>');
        this.functionName=PolicyCalloutHelper.GetPolicyDoc;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('FileName',fileName);
        return (List<HttpCalloutVO.PolicyDoc>)execute(new Map<String,String>());
    }

    */
/*efulfillment endhanced backup end*/
/*efulfillment endhanced add start*/
    
    /********************************************************************
     * getPolicyDoc
     * @param String,@param String
     * @decs:Call GetPolicyDoc WS to get policy doc
     * @return List<HttpCalloutVO.PolicyDoc>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyDoc> getPolicyDoc(String policyNumber,String attachmentKey){
        system.debug('PolicyCalloutHelper.getPolicyDoc');
        this.functionName=PolicyCalloutHelper.GetPolicyDoc;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('AttachmentKey',attachmentKey);
        //add by kermit
        if(CignaUtil.isCustomerPortal()){
            this.appName=PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
        }else if(CignaUtil.isBrokerPortal()){
            this.appName=PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
        }else if(CignaUtil.isCSUser()){
            this.appName=PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
        }
        //end add by kermit
        return (List<HttpCalloutVO.PolicyDoc>)execute(new Map<String,String>());
    }
    /*efulfillment endhanced add end*/

    // Rancho_HKITSFDC321_20251013 - add file store id, WS will insert attachment in file store
    public List<HttpCalloutVO.PolicyDoc> getPolicyDoc(String policyNumber,String attachmentKey,String appName){
        return getPolicyDoc(policyNumber,attachmentKey,appName,'');
    }
    
    //add by kermit
    public List<HttpCalloutVO.PolicyDoc> getPolicyDoc(String policyNumber,String attachmentKey,String appName,String parentId){
        system.debug('PolicyCalloutHelper.getPolicyDoc');
        this.functionName=PolicyCalloutHelper.GetPolicyDoc;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('AttachmentKey',attachmentKey);
        // Rancho_HKITSFDC321_20251013 - add file store id, WS will insert attachment in file store
        paramsMap.put('ParentId',parentId);
        this.appName=appName;
        return (List<HttpCalloutVO.PolicyDoc>)execute(new Map<String,String>());
    }
    //end add by kermit
    
    /********************************************************************
     * processPolicyDocResult
     * @param Dom.document
     * @decs:Handle GetPolicyDoc WS repsonse
     * @return List<HttpCalloutVO.PolicyDoc>
   ********************************************************************/
    public List<HttpCalloutVO.PolicyDoc> processPolicyDocResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyDocResult');
        List<HttpCalloutVO.PolicyDoc> objList=new List<HttpCalloutVO.PolicyDoc>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                List<Dom.XmlNode> attachments=getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode attachmentNode:attachments){
                    if(attachmentNode.getName()=='Attachment'){
                        HttpCalloutVO.PolicyDoc policyDoc=new HttpCalloutVO.PolicyDoc();
                        policyDoc.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                        policyDoc.attachmentType=getChildNodeTextIfNotEmpty('AttachmentType',attachmentNode);
                        policyDoc.fileName=getChildNodeTextIfNotEmpty('FileName',attachmentNode);
                        //policyDoc.attachmentData64Binary=getChildNodeTextIfNotEmpty('AttachmentData64Binary',attachmentNode);  //Comment by Nicole for large file download
                        //Rancho_HKITSFDC321_20251013 - get attachment id
                        //policyDoc.attBody=getChildNodeBlobIfNotEmpty('AttachmentData64Binary',attachmentNode);
                        policyDoc.sfdcAttachmentId=getChildNodeTextIfNotEmpty('AttachmentData64Binary',attachmentNode);
                        policyDoc.mimeTypeTC=getChildNodeTextIfNotEmpty('MimeTypeTC',attachmentNode);
                        policyDoc.mimeTypeTCNumber=getChildNodeAttributeIfNotEmpty('MimeTypeTC','tc',attachmentNode);//Autumn_SMT_20210408               
                        policyDoc.attachmentLocation=getChildNodeTextIfNotEmpty('AttachmentLocation',attachmentNode);
                        policyDoc.attachmentHashValue=getChildNodeTextIfNotEmpty('AttachmentHashValue',attachmentNode);
                        objList.add(policyDoc);
                    }
                }
            }
        }
        return objList;
    }
    
    /********************************************************************
     * getPolicyBasic
     * @param String
     * @decs:Call GetPolicyBasic WS to get policy basic info
     * @return List<HttpCalloutVO.PolicyDoc>
   ********************************************************************/
    public HttpCalloutVO.Policy getPolicyBasic(String policyNumber){
        system.debug('PolicyCalloutHelper.getPolicyBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        List<HttpCalloutVO.Policy> policyList=asyn?new List<HttpCalloutVO.Policy>():(List<HttpCalloutVO.Policy>)execute(new Map<String,String>());
        return policyList.isEmpty()?null:policyList[0];
    }
    
    /********************************************************************
     * getPolicyBasic
     * @param String policyNumber,String userLoginName
     * @decs:Call GetPolicyBasic WS to get policy basic info
     * @return List<HttpCalloutVO.PolicyDoc>
   ********************************************************************/
    public HttpCalloutVO.Policy getPolicyBasic(String policyNumber,String userLoginName){
        system.debug('PolicyCalloutHelper.getPolicyBasic');
        this.functionName=PolicyCalloutHelper.GetPolicyBasic;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('UserLoginName',userLoginName);
        List<HttpCalloutVO.Policy> policyList=asyn?new List<HttpCalloutVO.Policy>():(List<HttpCalloutVO.Policy>)execute(new Map<String,String>());
        return policyList.isEmpty()?null:policyList[0];
    }

    /********************************************************************
     * getPolicyBasic
     * @param String
     * @decs:Call GetPolicyBasic WS to get policy basic info
     * @return List<HttpCalloutVO.PolicyDoc>
   ********************************************************************/
    public HttpCalloutVO.Policy getPolicyBasic(String policyNumber,String userLoginName,String renewal){
        system.debug('PolicyCalloutHelper.getPolicyBasic');
        this.functionName = PolicyCalloutHelper.GetPolicyBasic;
        paramsMap = new Map<String, String>();
        paramsMap.put('PolNumber', policyNumber);
        paramsMap.put('RenewalPosition',renewal);
        List<HttpCalloutVO.Policy> policyList = asyn ? new List<HttpCalloutVO.Policy>() : (List<HttpCalloutVO.Policy>)execute(new Map<String, String>());
        return policyList.isEmpty() ? null : policyList[0];
    }
    
    /********************************************************************
     * processPolicyBasicResult
     * @param Dom.document
     * @decs:Handle GetPolicyBasic WS repsonse
     * @return List<HttpCalloutVO.Policy>
   ********************************************************************/
    public List<HttpCalloutVO.Policy> processPolicyBasicResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyBasicResult');
        List<HttpCalloutVO.Policy> objList=new List<HttpCalloutVO.Policy>();
        Map<String,HttpCalloutVO.Policy> holdingMap=new Map<String,HttpCalloutVO.Policy>();
        Map<String,HttpCalloutVO.Person> partyMap=new Map<String,HttpCalloutVO.Person>();
        List<HttpCalloutVO.Relation> relationList=new List<HttpCalloutVO.Relation>();
        List<HttpCalloutVO.IncentivesInformation> messageList=new List<HttpCalloutVO.IncentivesInformation>();
        
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                String holdingTypeCode=getChildNodeAttributeIfNotEmpty('HoldingTypeCode','tc',childNode);
                if(holdingTypeCode=='2'){ //Policy
                    Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                    HttpCalloutVO.Policy policy=new HttpCalloutVO.Policy();
                    policy.currencyCode=getChildNodeAttributeIfNotEmpty('CurrencyTypeCode','tc',childNode);
                    policy.currencyCodeDesc=getChildNodeTextIfNotEmpty('CurrencyTypeCode',childNode);
                    
                    if(policy.currencyCode=='344'){
                        policy.currencySymbol='HKD';
                    }else if(policy.currencyCode=='840'){
                        policy.currencySymbol='USD';
                    }else if(policy.currencyCode=='156'){
                        policy.currencySymbol='RMB';
                    }
                    policy.holdingID=childNode.getAttributeValue('id',null);
                    policy.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    policy.policyValue=getChildNodeTextIfNotEmpty('PolicyValue',policyNode);
                    policy.policyStatusCode=getChildNodeAttributeIfNotEmpty('PolicyStatus','tc',policyNode);
                    policy.policyStatus=getChildNodeTextIfNotEmpty('PolicyStatus',policyNode);
                    
                    if(String.isNotBlank(policy.policyStatusCode)){
                        //System.debug('policy.policyStatusCode:'+policy.policyStatusCode);
                        //System.debug('UserInfo.getLanguage():'+UserInfo.getLanguage());
                        
                        if((this.roleID=='CS' || this.roleID=='TM') && (policy.policyStatusCode=='55' || policy.policyStatusCode=='1052500025')){
                            policy.policyStatusDisplayName='Suspended';  // updated for UAT ISSUE DPSP-71
                        }else{
                            List<Policy_Status_Mapping__c> psm=Policy_Status_Mapping__c.getAll().values();
                            if('zh_HK'.equalsIgnoreCase(this.userLanguage) || 'zh_CN'.equalsIgnoreCase(this.userLanguage) || 'zh_TW'.equalsIgnoreCase(this.userLanguage)){                                
                                for(Policy_Status_Mapping__c p:psm){
                                    if(p.PolicyCode__c==policy.policyStatusCode){
                                        policy.policyStatusDisplayName=p.PolicyStatusChinese__c;
                                    }
                                }
                            }else{
                                for(Policy_Status_Mapping__c p:psm){
                                    //System.debug('psm:'+ p.PolicyCode__c+' '+  p.PolicyStatus__c);
                                    if(p.PolicyCode__c==policy.policyStatusCode){
                                        policy.policyStatusDisplayName=p.PolicyStatus__c;
                                    }
                                }
                            }
                            if(String.isBlank(policy.policyStatusDisplayName)){
                                policy.policyStatusDisplayName=policy.policyStatus;
                            }
                        }
                    }
                    
                    policy.effDate=getChildNodeTextIfNotEmpty('EffDate',policyNode);
                    policy.effDateInDate=getChildNodeDateIfNotEmpty('EffDate',policyNode,'yyyy-MM-dd');
                    policy.termDate=getChildNodeTextIfNotEmpty('TermDate',policyNode);
                    policy.termDateInDate=getChildNodeDateIfNotEmpty('TermDate',policyNode,'yyyy-MM-dd');
                    policy.paidToDate=getChildNodeTextIfNotEmpty('PaidToDate',policyNode);
                    policy.paidToDateInDate=getChildNodeDateIfNotEmpty('PaidToDate',policyNode,'yyyy-MM-dd');
                    policy.issueDate=getChildNodeTextIfNotEmpty('IssueDate',policyNode);
                    policy.issueDateInDate=getChildNodeDateIfNotEmpty('IssueDate',policyNode,'yyyy-MM-dd');
                    policy.paymentAmt=getChildNodeDecimalIfNotEmpty('PaymentAmt',policyNode);
                    // JR1797 - add Last Mode Premium in portal to avoid confusion with current mode premium
                    policy.lastPaymentAmt=getChildNodeDecimalIfNotEmpty('LastPaymentAmt',policyNode);
                    
                    // BEGIN changes HKITSFDC-22
                    policy.currentInsuredAge = getChildNodeIntegerIfNotEmpty('CurrentInsuredAge',policyNode);
                    policy.daysSincePolicyEffectiveDate = getChildNodeIntegerIfNotEmpty('DaysSincePolicyEffectiveDate',policyNode);
                    policy.totalIpClaimAmt = getChildNodeDecimalIfNotEmpty('TotalIpClaimAmt',policyNode);
                    policy.retentionHealthEligible=getChildNodeTextIfNotEmpty('RetentionHealthEligible',policyNode);                    
                    // END changes HKITSFDC-22
                    
                    // 20200610 - minghua - levyII
                    policy.levyCurrentPremium=getChildNodeDecimalIfNotEmpty('LastPaymentLevy',policyNode);
                    policy.nextLevy=getChildNodeDecimalIfNotEmpty('NextLevy',policyNode);
                    if(policy.lastPaymentAmt==null){
                        policy.lastPaymentAmt=0;
                    }
                    if(policy.levyCurrentPremium==null){
                        policy.levyCurrentPremium=0;
                    }
                    if(policy.nextLevy==null){
                        policy.nextLevy=0;
                    }
                    if(policy.paymentAmt==null){
                        policy.paymentAmt=0;
                    }
                    policy.currentPremiumIncludeLevy=policy.lastPaymentAmt+policy.levyCurrentPremium;
                    policy.modalPremiumIncludeLevy=policy.paymentAmt+policy.nextLevy;
                    Date levyEffectiveDate=Portal_Settings__c.getInstance().Levy_EffectiveDate__c;
                    Date todayNow=Date.today();
                    if(levyEffectiveDate!=null && todayNow >=levyEffectiveDate){
                        policy.effectiveLevy=true;
                    }else{
                        policy.effectiveLevy=false;
                    }

                    policy.annualPaymentAmt=getChildNodeTextIfNotEmpty('AnnualPaymentAmt',policyNode);
                    policy.paymentMode=getChildNodeTextIfNotEmpty('PaymentMode',policyNode);
                    policy.paymentModeCode=getChildNodeAttributeIfNotEmpty('PaymentMode','tc',policyNode);
                    policy.paymentMethod=getChildNodeTextIfNotEmpty('PaymentMethod',policyNode);
                    policy.productCode=getChildNodeTextIfNotEmpty('ProductCode',policyNode);
                    policy.productType=getChildNodeTextIfNotEmpty('ProductType',policyNode);
                    policy.planName=getChildNodeTextIfNotEmpty('PlanName',policyNode);
                    policy.marketingName=getChildNodeTextIfNotEmpty('MarketingName',policyNode);
                    policy.workingDaysFromEffDate=Integer.Valueof(getChildNodeDecimalIfNotEmpty('WorkingDaysFromEffDate',policyNode));//add by Andy
                    policy.rateScale=getChildNodeTextIfNotEmpty('RateScale',policyNode); // WS GetPolicyBasic enhanced added by ZaiHong 20180427
                    policy.rateScaleName=getChildNodeTextIfNotEmpty('RateScaleName',policyNode);//AM project rate scale name
                    policy.sourceSystem=getChildNodeTextIfNotEmpty('SourceSystem',policyNode);// Added by lu weizheng at 20180516
                    policy.renewalNoticeInd=getChildNodeTextIfNotEmpty('RenewalNoticeInd',policyNode);// Rancho_JOBR367_20240513 - update premium display
                    
                    // Add 3 new field for Elite 360 Migration https://jira.express-scripts.com/browse/HKITSFDC-8
                    if(!String.isBlank(policy.marketingName) && policy.marketingName.toLowerCase().contains('elite')) {
                        policy.internalProductName=getChildNodeTextIfNotEmpty('InternalProductName',policyNode);
                        policy.renewalSegment=getChildNodeTextIfNotEmpty('RenewalSegment',policyNode);
                        policy.actualSegment=getChildNodeTextIfNotEmpty('ActualSegment',policyNode);
                    }
                    
                    // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-15
                    // Elite 360 Migration - NCD
                        policy.nCDEligibility = getChildNodeTextIfNotEmpty('NcdEligibility',policyNode);
                        policy.nCDUpdateDate = getChildNodeTextIfNotEmpty('NcdUpdDate',policyNode);
                    // END https://jira.express-scripts.com/browse/HKITSFDC-15
                     
                    // BEGIN HKITSFDC-267
                    policy.NcdInd = getChildNodeTextIfNotEmpty('NcdInd', policyNode);
					policy.NcdPercentage = getChildNodeDecimalIfNotEmpty('NcdPercentage', policyNode);
                    // END HKITSFDC-267  

                    
                    //JR1783
                    policy.campaignCode=getChildNodeTextIfNotEmpty('CampaignCode',policyNode);
                    //20220829 - minghua - JOBR-152 Health Migration
                    policy.sourceCode=getChildNodeTextIfNotEmpty('SourceCode',policyNode);
                    //JR1783
                    
                    Dom.XmlNode LifeNode=getChildNodeIfNotNull('Life',policyNode);
                    if(LifeNode!=null){
                        policy.SuspenseAmt=getChildNodeDecimalIfNotEmpty('SuspenseAmt',LifeNode);
                        policy.PremiumSuspenseAmt=getChildNodeDecimalIfNotEmpty('PremiumSuspenseAmt',LifeNode);
                    }
                    
                    if(String.isNotBlank(policy.productCode) && policy.productCode.startsWith('@')){
                        policy.isSystem6=true;
                    }else{
                        policy.isSystem6=false;
                    }

                    // 20200306 - minghua - ILAS
                    policy.applicationDate=getChildNodeDateIfNotEmpty('ApplicationDate',policyNode,'yyyy-MM-dd');
                    Dom.XmlNode clientAcknowledgementNode=getChildNodeIfNotNull('ClientAcknowledgement',policyNode);
                    policy.acknowledgementType=getChildNodeTextIfNotEmpty('AcknowledgementType',clientAcknowledgementNode);
                    policy.acknowledgementDate=getChildNodeDateIfNotEmpty('AcknowledgementDate',clientAcknowledgementNode,'yyyy-MM-dd');

                    Dom.XmlNode investmentNode=getChildNodeIfNotNull('Investment',childNode);
                    HttpCalloutVO.Investment investment=new HttpCalloutVO.Investment();
                    if(investmentNode!=null){
                        investment.id=investmentNode.getAttributeValue('id',null);
                    }
                    List<Dom.XmlNode> subAccountNodes=getChildElementsIfNotNull(investmentNode);
                    for(Dom.XmlNode subAccountNode:subAccountNodes){
                        if(subAccountNode.getName()=='SubAccount'){
                            HttpCalloutVO.SubAccount subAccount=new HttpCalloutVO.SubAccount();
                            if(subAccountNode!=null){
                                subAccount.id=subAccountNode.getAttributeValue('id',null);
                            }
                            subAccount.productCode=getChildNodeTextIfNotEmpty('ProductCode',subAccountNode);
                            subAccount.productFullName=getChildNodeTextIfNotEmpty('ProductFullName',subAccountNode);
                            
                            Dom.XmlNode riskProfileNode=getChildNodeIfNotNull('RiskProfile',subAccountNode);
                            subAccount.riskLevelCode=getChildNodeTextIfNotEmpty('RiskLevelCode',riskProfileNode);
                            subAccount.riskLevelDesc=getChildNodeTextIfNotEmpty('RiskLevelDesc',riskProfileNode);
                            subAccount.riskEffDate=getChildNodeDateIfNotEmpty('RiskEffDate',riskProfileNode,'yyyy-MM-dd');
                            investment.subAccountList.add(subAccount);
                        }
                    }

                    Dom.XmlNode groupPolicyNode=getChildNodeIfNotNull('GroupPolicy',policyNode);
                    Dom.XmlNode groupOLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',groupPolicyNode);
                    policy.numberofChildren=getChildNodeTextIfNotEmpty('NumChildren',groupOLifEExtensionNode);
                    policy.numberofEmployees=getChildNodeTextIfNotEmpty('NumEmployees',groupPolicyNode);
                    policy.numberofSpouse=getChildNodeTextIfNotEmpty('NumSpouse',groupOLifEExtensionNode);
                    
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',policyNode);
                    policy.isLifePolicy=getChildNodeBooleanIfNotEmpty('LifePolicyInd',OLifEExtensionNode);
                    policy.isILAS=getChildNodeBooleanIfNotEmpty('ILASPolicyInd',OLifEExtensionNode);
                    policy.isIndividual=getChildNodeBooleanIfNotEmpty('IndividualPolicyInd',OLifEExtensionNode);
                    policy.isIPMIPolicy=getChildNodeBooleanIfNotEmpty('IPMIPolicyInd',OLifEExtensionNode);
                    policy.isTUpPolicy=getChildNodeBooleanIfNotEmpty('TUpPolicyInd',OLifEExtensionNode);
                    //policy.isCPlusPolicy=getChildNodeBooleanIfNotEmpty('CPlusPolicyInd',OLifEExtensionNode);
                    policy.isLHBPolicy=getChildNodeBooleanIfNotEmpty('LHBPolicyInd',OLifEExtensionNode);
                    policy.isLHBPackagePolicy=getChildNodeBooleanIfNotEmpty('LHBPackagePolicyInd',OLifEExtensionNode);
                    policy.isLHBEligibleForGOPPolicy=getChildNodeBooleanIfNotEmpty('LHBEligibleForGOPPolicyInd',OLifEExtensionNode);
                    policy.isGAOPPolicy=getChildNodeBooleanIfNotEmpty('GAOPPolicyInd',OLifEExtensionNode);
                    policy.allowChangeOwner=getChildNodeBooleanIfNotEmpty('AllowChangeOwnerInd',OLifEExtensionNode);
                    policy.allowChangePaymentDate=getChildNodeBooleanIfNotEmpty('AllowChangePaymentDateInd',OLifEExtensionNode);
                    policy.distChannelCode=getChildNodeTextIfNotEmpty('DistChannelCode',OLifEExtensionNode);
                    policy.distChannelDesc=getChildNodeTextIfNotEmpty('DistChannelDesc',OLifEExtensionNode);
                    
                    policy.RiskClass=getChildNodeTextIfNotEmpty('RiskClass',OLifEExtensionNode);
                    policy.PolicyYear=Integer.Valueof(getChildNodeDecimalIfNotEmpty('PolicyYear',OLifEExtensionNode));
                    policy.SellerId=getChildNodeTextIfNotEmpty('SellerId',OLifEExtensionNode);
                    policy.renewalInd=getChildNodeBooleanIfNotEmpty('RenewalInd',OLifEExtensionNode);
                    policy.renewalDate=getChildNodeDateIfNotEmpty('RenewalDate',OLifEExtensionNode,'yyyy-MM-dd');
                    policy.cashRewardInd=getChildNodeBooleanIfNotEmpty('CashRewardInd',OLifEExtensionNode);
                    policy.cashRewardDate=getChildNodeDateIfNotEmpty('CashRewardDate',OLifEExtensionNode,'yyyy-MM-dd');
                    policy.diabetesTypeCode=getChildNodeTextIfNotEmpty('DiabetesTypeCode',OLifEExtensionNode);
                    
                    //BEGIN HKITSFDC-148
                    policy.lastAgent=getChildNodeTextIfNotEmpty('LastAgent',OLifEExtensionNode);
                    policy.writingAgent=getChildNodeTextIfNotEmpty('WritingAgent',OLifEExtensionNode);
                    policy.brokerChangeDate=getChildNodeDateIfNotEmpty('BrokerChangeDate',OLifEExtensionNode,'yyyy-MM-dd');
                    //END HKITFSFDC-148
                    
                    //Hardcopy Indicator added start
                    Dom.XmlNode HardCopyIndicatorNode=getChildNodeIfNotNull('HardCopyIndicator',OLifEExtensionNode);
                    policy.medCardIndicator=getChildNodeTextIfNotEmpty('MedCardIndicator',HardCopyIndicatorNode);
                    policy.letterIndicator=getChildNodeTextIfNotEmpty('LetterIndicator',HardCopyIndicatorNode);
                    //Hardcopy Indicator added end
                    
                    //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                    List<Dom.XmlNode> refChildNodes=getChildElementsIfNotNull(OLifEExtensionNode);
                    for(Dom.XmlNode refChildNode:refChildNodes){
                        if(refChildNode.getName()=='Reference'){
                            HttpCalloutVO.Reference reference=new HttpCalloutVO.Reference();
                            reference.referenceId=getChildNodeAttributeIfNotEmpty('Reference','tc',OLifEExtensionNode);
                            reference.referenceDesc=getChildNodeTextIfNotEmpty('Description',refChildNode);
                            policy.referenceList.add(reference);
                        }
                    }  
                    //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                    policy.sellerName=getChildNodeTextIfNotEmpty('SellerName',OLifEExtensionNode);// Added by lu weizheng at 20180516
                    policy.insuredList=new List<HttpCalloutVO.Person>();
                    holdingMap.put(policy.holdingID,policy);
                }
            }else if(childNode.getName()=='Party'){
                HttpCalloutVO.Person party=new HttpCalloutVO.Person();
                party.partyID=childNode.getAttributeValue('id',null);
                party.fullName=getChildNodeTextIfNotEmpty('FullName',childNode);
                party.ssnNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                //Christina CP-435 added ContactPerson for broker
                party.contactPerson=getChildNodeTextIfNotEmpty('ContactPerson',childNode);
                Dom.XmlNode EmailAddressNode=getChildNodeIfNotNull('EMailAddress',childNode);
                party.emailAddress=getChildNodeTextIfNotEmpty('AddrLine',EmailAddressNode);
                
                //SPS-381
                List<Dom.XmlNode> partyChildNodes=getChildElementsIfNotNull(childNode);
                //Dom.XmlNode phoneNode=getChildNodeIfNotNull('Phone',childNode);
                for(Dom.XmlNode partyChildNode:partyChildNodes){
                    if(partyChildNode.getName()=='Phone'){
                        Dom.XmlNode phoneNode=partyChildNode;
                        String phoneTypeCode=getChildNodeAttributeIfNotEmpty('PhoneTypeCode','tc',phoneNode);
                        if(phoneTypeCode=='1'){ // Home
                            party.homePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.homePhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.homePhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] homePhone');
                        }else if(phoneTypeCode=='2'){ // Business
                            party.businessPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.businessPhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.businessPhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] businessPhone');
                        }else if(phoneTypeCode=='4'){ // Business Fax
                            party.businessFaxNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.businessFaxCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.businessFaxAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] businessFax');
                        }else if(phoneTypeCode=='12'){ // Mobile
                            party.mobilePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.mobileCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.mobileAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] mobilePhone');
                        }else if(phoneTypeCode=='15'){ // Home Fax
                            party.homeFaxNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.homeFaxCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.homeFaxAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] homeFax');
                        }else if(phoneTypeCode=='2147483647'){ // Other Phone
                            party.otherPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.otherPhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.otherPhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                        }else if(phoneTypeCode=='1052500002'){ //Correspondence Phone
                            party.correspondencePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.correspondencePhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.correspondencePhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                        }
                    }
                    //CS Member Level Jack change to access all address code
                    if(partyChildNode.getName()=='Address'){
                        Dom.XmlNode AddressNode=partyChildNode;
                        String addressTypeCode=getChildNodeAttributeIfNotEmpty('AddressTypeCode','tc',AddressNode);
                        if(addressTypeCode=='1052500002'){//AR address
                            party.ARaddressLine1=getChildNodeTextIfNotEmpty('Line1',AddressNode);
                            party.ARaddressLine2=getChildNodeTextIfNotEmpty('Line2',AddressNode);
                            party.ARaddressLine3=getChildNodeTextIfNotEmpty('Line3',AddressNode);
                            party.ARaddressLine4=getChildNodeTextIfNotEmpty('Line4',AddressNode);
                            party.ARaddressState=getChildNodeTextIfNotEmpty('AddressState',AddressNode);
                            party.ARaddressCountry=getChildNodeTextIfNotEmpty('AddressCountry',AddressNode);
                            party.ARdefaultAddressInd=getChildNodeAttributeIfNotEmpty('DefaultAddressInd','tc',AddressNode);
                            //system.debug('party.ARaddressCountry:'+party.ARaddressLine1);
                        }else if(addressTypeCode=='1052500003'){//Claim address
                            party.ClaimAddressLine1=getChildNodeTextIfNotEmpty('Line1',AddressNode);
                            party.ClaimAddressLine2=getChildNodeTextIfNotEmpty('Line2',AddressNode);
                            party.ClaimAddressLine3=getChildNodeTextIfNotEmpty('Line3',AddressNode);
                            party.ClaimAddressLine4=getChildNodeTextIfNotEmpty('Line4',AddressNode);
                            party.ClaimAddressState=getChildNodeTextIfNotEmpty('AddressState',AddressNode);
                            party.ClaimAddressCountry=getChildNodeTextIfNotEmpty('AddressCountry',AddressNode);
                            party.ClaimDefaultAddressInd=getChildNodeAttributeIfNotEmpty('DefaultAddressInd','tc',AddressNode);
                            //system.debug('party.ClaimAddressCountry:'+party.ClaimAddressLine1);
                        }else{
                            party.addressLine1=getChildNodeTextIfNotEmpty('Line1',AddressNode);
                            party.addressLine2=getChildNodeTextIfNotEmpty('Line2',AddressNode);
                            party.addressLine3=getChildNodeTextIfNotEmpty('Line3',AddressNode);
                            party.addressLine4=getChildNodeTextIfNotEmpty('Line4',AddressNode);
                            party.addressState=getChildNodeTextIfNotEmpty('AddressState',AddressNode);
                            party.addressCountry=getChildNodeTextIfNotEmpty('AddressCountry',AddressNode);
                            //system.debug('party.addressCountry:'+party.addressLine1);
                            //add by Andy
                            Dom.XmlNode OLifEExtension=getChildNodeIfNotNull('OLifEExtension',AddressNode);
                            party.addressIndex=getChildNodeTextIfNotEmpty('AddressIndex',OLifEExtension);
                            
                            party.fullAddress=handleString(party.addressLine1,',')+handleString(party.addressLine2,',')
                               +handleString(party.addressLine3,',')+handleString(party.addressLine4,',')
                               +handleString(party.addressState,',')+handleString(party.addressCountry,'');
                            if(String.isBlank(party.fullAddress.substringAfterLast(','))){
                                party.fullAddress=party.fullAddress.substringBeforeLast(',');
                            }
                            
                            party.addressType=getChildNodeTextIfNotEmpty('AddressTypeCode',AddressNode);
                            party.city=getChildNodeTextIfNotEmpty('city',AddressNode);
                            party.zip=getChildNodeTextIfNotEmpty('Zip',AddressNode);
                        }
                    }   
                    //20210621 Bob Asia Mile 
                    if(partyChildNode.getName()=='Membership'){
                        Dom.XmlNode memberNode = partyChildNode;
                        HttpCalloutVO.Membership membership = new HttpCalloutVO.Membership();
                        membership.channel = getChildNodeTextIfNotEmpty('Channel', memberNode);
                        if (membership.channel=='M') {
                            membership.membershipId = getChildNodeTextIfNotEmpty('MembershipId', memberNode);
                            membership.membershipFirstName = getChildNodeTextIfNotEmpty('MembershipFirstName', memberNode);
                            membership.membershipLastName = getChildNodeTextIfNotEmpty('MembershipLastName', memberNode);
                            party.membership=membership;
                        }
                    }
                    if(partyChildNode.getName()=='Phone'){
                        Dom.XmlNode phoneNode=partyChildNode;
                        String phoneTypeCode=getChildNodeAttributeIfNotEmpty('PhoneTypeCode','tc',phoneNode);
                        //add Bob 20210318 Client Policy Information
                        String phoneTypeCodeText = getChildNodeTextIfNotEmpty('PhoneTypeCode', phoneNode);  
                        if(phoneTypeCode=='1'){ // Home
                            party.homePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.homePhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.homePhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] homePhone');
                        }else if(phoneTypeCode=='2'){ // Business
                            party.businessPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.businessPhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.businessPhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] businessPhone');
                        }else if(phoneTypeCode=='4'){ // Business Fax
                            party.businessFaxNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.businessFaxCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.businessFaxAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] businessFax');
                        }else if(phoneTypeCode=='12'){ // Mobile
                            party.mobilePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.mobileCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.mobileAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] mobilePhone');
                        }else if(phoneTypeCode=='15'){ // Home Fax
                            party.homeFaxNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.homeFaxCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.homeFaxAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                            //system.debug('[PolicyCalloutHelper] homeFax');
                        }else if(phoneTypeCode=='2147483647'){ // Other Phone
                            party.otherPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.otherPhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.otherPhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                        }else if(phoneTypeCode=='1052500002'){ //Correspondence Phone
                            party.correspondencePhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                            party.correspondencePhoneCountryCode=getChildNodeTextIfNotEmpty('CountryCode',phoneNode);
                            party.correspondencePhoneAreaCode=getChildNodeTextIfNotEmpty('AreaCode',phoneNode);
                        }else if(phoneTypeCode=='1052500007'){ //Contact Person Phone
                            party.contactPersonPhoneNo=getChildNodeTextIfNotEmpty('DialNumber',phoneNode);
                        //add Bob 20210318 Client Policy Information
                        }else if(phoneTypeCodeText=='Admin'){
                            party.adminName = getChildNodeTextIfNotEmpty('FullName', childNode);
                            party.adminNo = getChildNodeTextIfNotEmpty('DialNumber', phoneNode);
                        }else if(phoneTypeCodeText=='Claims'){
                            party.claimsName = getChildNodeTextIfNotEmpty('FullName', childNode);
                            party.claimsNo = getChildNodeTextIfNotEmpty('DialNumber', phoneNode);
                        }
                        //end
                    }

                    //add Bob 20210318 Client Policy Information
                    if(partyChildNode.getName() == 'EMailAddress'){
                        Dom.XmlNode EMailAddrNode = partyChildNode;
                        if(String.isNotBlank(party.adminName)){
                            party.adminEmail = getChildNodeTextIfNotEmpty('AddrLine', EMailAddrNode);
                        }else if(String.isNotBlank(party.claimsName)){
                            party.claimsEmail = getChildNodeTextIfNotEmpty('AddrLine', EMailAddrNode);
                        }
                    }
                    //end  
                }
                //SPS-381
                //SPS-400
                party.homePhoneNo=processPhoneNumString(party.homePhoneNo);
                party.businessPhoneNo=processPhoneNumString(party.businessPhoneNo);
                party.businessFaxNo=processPhoneNumString(party.businessFaxNo);
                party.mobilePhoneNo=processPhoneNumString(party.mobilePhoneNo);
                party.homeFaxNo=processPhoneNumString(party.homeFaxNo);
                party.otherPhoneNo=processPhoneNumString(party.otherPhoneNo);
                party.correspondencePhoneNo=processPhoneNumString(party.correspondencePhoneNo);
                //SPS-400

                Dom.XmlNode OrgNode=getChildNodeIfNotNull('Organization',childNode);
                party.OrgCode=getChildNodeTextIfNotEmpty('OrgCode',OrgNode);
                Dom.XmlNode ProducerNode=getChildNodeIfNotNull('Producer',childNode);
                Dom.XmlNode CarrierAppointmentNode=getChildNodeIfNotNull('CarrierAppointment',ProducerNode);
                party.brokerAgentCode=getChildNodeTextIfNotEmpty('CompanyProducerID',CarrierAppointmentNode);
                partyMap.put(party.partyID,party);
            }else if(childNode.getName()=='Relation'){
                HttpCalloutVO.Relation relation=new HttpCalloutVO.Relation();
                relation.id=childNode.getAttributeValue('id',null);
                relation.OriginatingObjectID=childNode.getAttributeValue('OriginatingObjectID',null);
                relation.RelatedObjectID=childNode.getAttributeValue('RelatedObjectID',null);
                relation.OriginatingObjectType=getChildNodeTextIfNotEmpty('OriginatingObjectType',childNode);
                relation.OriginatingObjectCode=getChildNodeAttributeIfNotEmpty('OriginatingObjectType','tc',childNode);
                relation.RelatedObjectType=getChildNodeTextIfNotEmpty('RelatedObjectType',childNode);
                relation.RelatedObjectCode=getChildNodeAttributeIfNotEmpty('RelatedObjectType','tc',childNode);
                relation.RelationRoleCode=getChildNodeAttributeIfNotEmpty('RelationRoleCode','tc',childNode);
                relation.RelationRoleType=getChildNodeTextIfNotEmpty('RelationRoleCode',childNode);
                relationList.add(relation);
            }else if(childNode.getName()=='OLifEExtension'){ // get incentiviesInfoList
               //List<HttpCalloutVO.IncentivesInformation> messageList=new List<HttpCalloutVO.IncentivesInformation>();
               List<Dom.XmlNode> extensionChildNode=getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode exeChildNode:extensionChildNode){
                    if(exeChildNode.getName()=='Message'){
                        HttpCalloutVO.IncentivesInformation message=new HttpCalloutVO.IncentivesInformation();
                        message.messageID=getChildNodeTextIfNotEmpty('ID',exeChildNode);
                        message.description=getChildNodeTextIfNotEmpty('Description',exeChildNode);
                        messageList.add(message);
                    }
                }
                //policy.incentiviesInfoList=messageList;
                //system.debug('messageList='+messageList);
            }
        }
        
        for(HttpCalloutVO.Relation relation:relationList){
            if(relation.OriginatingObjectID.containsIgnoreCase('party')){
                HttpCalloutVO.Person holding=partyMap.get(relation.OriginatingObjectID);
                HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
                if(relation.RelationRoleCode=='48'){
                    holding.organization=party;
                }
            }else{
                HttpCalloutVO.Policy holding=holdingMap.get(relation.OriginatingObjectID);
                HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
                // 1 policy has 1 holder and manay insured
                if(relation.RelationRoleType=='Owner'){
                    holding.holder=party;
                    //SPS-381
                    if(String.isNotBlank(holding.holder.mobilePhoneNo)){
                        holding.contactNo=holding.holder.mobilePhoneNo;
                    }else if(String.isNotBlank(holding.holder.homePhoneNo)){
                        holding.contactNo=holding.holder.homePhoneNo;
                    }else if(String.isNotBlank(holding.holder.businessPhoneNo)){
                        holding.contactNo=holding.holder.businessPhoneNo;
                    }else if(String.isNotBlank(holding.holder.homeFaxNo)){
                        holding.contactNo=holding.holder.homeFaxNo;
                    }else if(String.isNotBlank(holding.holder.businessFaxNo)){
                        holding.contactNo=holding.holder.businessFaxNo;
                    }
                    //SPS-381
                }else if(relation.RelationRoleType=='Insured'){
                    holding.insuredList.add(party);
                }else if(relation.RelationRoleCode=='38'){
                    holding.broker=party;                  
                }else if(relation.RelationRoleType == 'Admin'){
                    //bob add for client portal policyInformation
                    System.debug(LoggingLevel.INFO, '*** get Admin Type holding/party name in relation : ' + party.fullName);
                    holding.adminPer = party;
                    if(String.isNotBlank(party.fullName)){
                        holding.adminPer.adminAddr = handleString(party.ARaddressLine1,', ') + handleString(party.ARaddressLine2,', ')
                                    + handleString(party.ARaddressLine3,', ') + handleString(party.ARaddressLine4,', ')
                                    + handleString(party.ARaddressState,', ') + handleString(party.ARaddressCountry,'');
                        if(String.isBlank(holding.adminPer.adminAddr.substringAfterLast(','))){
                            holding.adminPer.adminAddr = holding.adminPer.adminAddr.substringBeforeLast(',');
                        }
                    }
                }else if(relation.RelationRoleType == 'Claims'){
                    //bob add for client portal policyInformation
                    System.debug(LoggingLevel.INFO, '*** get Claims Type holding/party name in relation : ' + party.fullName);
                    holding.claimsPer = party;
                    if(String.isNotBlank(party.fullName)){
                        holding.claimsPer.claimsAddr = handleString(party.ClaimAddressLine1,', ') + handleString(party.ClaimAddressLine2,', ')
                            + handleString(party.ClaimAddressLine3,', ') + handleString(party.ClaimAddressLine4,', ')
                            + handleString(party.ClaimAddressState,', ') + handleString(party.ClaimAddressCountry,'');
                        if(String.isBlank(holding.claimsPer.claimsAddr.substringAfterLast(','))){
                            holding.claimsPer.claimsAddr = holding.claimsPer.claimsAddr.substringBeforeLast(',');
                        }
                    }
                }
            }
        }
        
        if(!messageList.isEmpty()){
            for(HttpCalloutVO.Policy policy:holdingMap.values()){
                policy.incentiviesInfoList=messageList;
                objList.add(policy);
            }
        }else{
            objList.addAll(holdingMap.values());
        }
        
        //objList.addAll(holdingMap.values());
        //system.debug('>>>>> List<HttpCalloutVO.Policy> >>>>> '+objList.size());
        system.debug('List<HttpCalloutVO.Policy> '+objList);
        return objList;
    }
    
    private static String handleString(string str,String after){
        return String.isNotBlank(str)?str+after:'';
    }
    
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId){
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,null);
    }
    
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,String status){
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,status,null);
    }
    
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,String status,String brokerAgentCode){
        List<String> statusList=new List<String>();
        if(String.isNotBlank(status)){
            statusList.add(status);
        }
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode);
    }
    
    /*
     * support multiple policy status
     * the status values are from the Description__c of Policy_Status_Mapping__c
     */
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode){
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode,null);
    }
    
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode,Boolean isIPMI){
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode,isIPMI,null);
    }
    
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode,Boolean isIPMI,String companyCode){
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode,isIPMI,companyCode,null,null);
    }
    
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode,Boolean isIPMI,String companyCode,String userLoginName,String roleID){
        return getIndividualPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,null,insuredName,insuredId,null ,statusList,brokerAgentCode,isIPMI,companyCode,userLoginName,roleID,null,null);
    }
    
    // Rancho_FriendDiscount_20210812: enable phone number search for TM
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String userLoginName,String holderPhone){
        return getIndividualPolicyListBasicByCriteria(null,null,null,holderPhone,null,null,null,null,null,null,null,null,userLoginName,null,null,null);
    }

    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,Date holderDOB,String insuredName,String insuredId,Date insuredDOB,List<String> statusList,String brokerAgentCode,Boolean isIPMI,String companyCode,String userLoginName,String roleID,String claimNumber,String bankAccountNumber){
        HttpCalloutVO.PolicyRequest request=new HttpCalloutVO.PolicyRequest();
        request.PolicyType=PolicyCalloutHelper.POLICY_TYPE_INDIVIDUAL;
        if(!String.IsBlank(policyNumber)){
            request.policyNumber=policyNumber;
        }
        if(!String.IsBlank(holderName)){
            request.holderName=holderName;
        }
        if(!String.IsBlank(holderId)){
            request.holderId=holderId;
        }
        if(!String.IsBlank(holderPhone)){
            request.holderPhone=holderPhone;
        }
        if(holderDOB!=null){
            request.holderDOB=holderDOB;
        }
        if(!String.IsBlank(insuredName)){
            request.insuredName=insuredName;
        }
        if(!String.IsBlank(insuredId)){
            request.insuredId=insuredId;
        }
        if(insuredDOB!=null){
            request.insuredDOB=insuredDOB;
        }
        if(statusList!=null && !statusList.isEmpty()){
            request.statusList=statusList;
        }
        if(!String.IsBlank(brokerAgentCode)){
            request.brokerAgentCode=brokerAgentCode;
        }
        if(isIPMI!=null){
            request.isIPMI=isIPMI;
        }
        if(!String.IsBlank(companyCode)){
            request.companyCode=companyCode;
        }
        if(!String.IsBlank(userLoginName)){
            request.userLoginName=userLoginName;
        }
        if(!String.IsBlank(roleID)){
            request.roleID=roleID;
        }
        if(!String.IsBlank(claimNumber)){
            request.claimNumber=claimNumber;
        }
        if(!String.IsBlank(bankAccountNumber)){
            request.bankAccountNumber=bankAccountNumber;
        }
        return getIndividualPolicyListBasicByCriteria(request);
    }
    /*
     * this is the latest version,support isIPMI filter
     *     @brokerAgentCode if you want to search policies without broker agent,please specify the brokerAgentCode=PolicyCalloutHelper.NO_BROKER_AGENT
     *     @claimNumber,bankAccountNumber added by Nicole in Phase2
     *     @Added All Criterira into Class HttpCalloutVO.PolicyRequest // Updated by Nicole in Phase2
     */
    public List<HttpCalloutVO.Policy> getIndividualPolicyListBasicByCriteria(HttpCalloutVO.PolicyRequest request){
        system.debug('PolicyCalloutHelper.getIndividualPolicyListBasicByCriteria');
        this.functionName=PolicyCalloutHelper.GetPolicyListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolicyType',PolicyCalloutHelper.POLICY_TYPE_INDIVIDUAL);
        paramsMap.put('PolNumber',String.isNotBlank(request.policyNumber)?request.policyNumber:'');
        paramsMap.put('HolderFullName',String.isNotBlank(request.holderName)?request.holderName:'');
        paramsMap.put('HolderGovtID',String.isNotBlank(request.holderId)?request.holderId:'');
        paramsMap.put('HolderDialNumber',String.isNotBlank(request.holderPhone)?request.holderPhone:'');
        paramsMap.put('InsuredFullName',String.isNotBlank(request.insuredName)?request.insuredName:'');
        paramsMap.put('InsuredGovtID',String.isNotBlank(request.insuredId)?request.insuredId:'');
        //add Bob 20201116 Additional option to search their client case by renewing month
        paramsMap.put('PolicyRenewingMonth',String.isNotBlank(request.policyRenewingMonth)?request.policyRenewingMonth:'');
        paramsMap.put('PolicyRenewingYear',String.isNotBlank(request.policyRenewingYear)?request.policyRenewingYear:'');
        //end Bob 20201116 Additional option to search their client case by renewing month
        if(request.statusList!=null && !request.statusList.isEmpty()){
            paramsMap.put('PolicyStatus',String.join(request.statusList,';'));
        }
        if(String.isNotBlank(request.brokerAgentCode)){
            paramsMap.put('BrokerAgentCode',request.brokerAgentCode);
        }
        if(request.isIPMI!=null){
            paramsMap.put('IPMIPolicyInd',String.valueOf(request.isIPMI));
            paramsMap.put('IPMIPolicyIndCode',request.isIPMI?'1':'0');
        }
        
        paramsMap.put('OrgCode',String.isNotBlank(request.companyCode)?request.companyCode:'');
        paramsMap.put('UserLoginName',String.isNotBlank(request.userLoginName)?request.userLoginName:'');
        paramsMap.put('RoleID',String.isNotBlank(request.roleID)?request.roleID:'');
        
        if(!String.IsBlank(request.claimNumber)){
            paramsMap.put('ClaimNumber',request.claimNumber);
        }
        if(!String.IsBlank(request.bankAccountNumber)){
            paramsMap.put('AccountNumber',request.bankAccountNumber);
        }
        if(request.holderDOB!=null){
            paramsMap.put('HolderDOB',String.Valueof(request.holderDOB));
        }
        if(request.insuredDOB!=null){
            paramsMap.put('InsuredDOB',String.Valueof(request.insuredDOB));
        }
        if(request.policyCreationDateTime!=null){
            paramsMap.put('PolicyCreationDate',String.Valueof(request.policyCreationDateTime).substring(0,10));
            paramsMap.put('PolicyCreationTime',String.Valueof(request.policyCreationDateTime).substring(11));
        }
        if(!String.IsBlank(request.SellerId)){
            paramsMap.put('SellerId',request.SellerId);
        }
        paramsMap.put('SortOrder',String.isNotBlank(request.SortOrder)?request.SortOrder: '');
        if(request.isTDUser!=null&&request.isTDUser){paramsMap.put('isTDUser','TRUE');} //Nicole_SMT_20210425
        return asyn?new List<HttpCalloutVO.Policy>():(List<HttpCalloutVO.Policy>)execute(new Map<String,String>());
    }
    
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName){ //,String memberName
        return getGroupPolicyListBasicByCriteria(policyNumber,holderName,null);
    }
    
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName,String status){ //,String memberName
        /*system.debug('>>>>> PolicyCalloutHelper.getGroupPolicyListBasicByCriteria >>>>>');
        this.functionName=PolicyCalloutHelper.GetPolicyListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolicyType',PolicyCalloutHelper.POLICY_TYPE_GROUP);
        paramsMap.put('PolNumber',String.isNotBlank(policyNumber)?policyNumber:'');
        paramsMap.put('HolderFullName',String.isNotBlank(holderName)?holderName:'');
        paramsMap.put('PolicyStatus',String.isNotBlank(status)?status:'');
        //paramsMap.put('MemberName',String.isNotBlank(memberName)?memberName:'');
        return asyn?new List<HttpCalloutVO.Policy>():(List<HttpCalloutVO.Policy>)execute(new Map<String,String>());*/
        
        return getGroupPolicyListBasicByCriteria(policyNumber,holderName,null,null,null,null,status,null);
    }
    
     public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,String status,String brokerAgentCode){ //,String memberName
        List<String> statusList=new List<String>();
        if(String.isNotBlank(status)){
            statusList.add(status);
        }
        return getGroupPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode);
    }
    
    /*
     * support multiple policy status
     * the status values are from the Description__c of Policy_Status_Mapping__c
     */
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode){ //,String memberName
        return getGroupPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode,null);
    }
    
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode,Boolean isIPMI){ //,String memberName
        return getGroupPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode,isIPMI,null);
    }
    
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode,Boolean isIPMI,String companyCode){ //,String memberName
        return getGroupPolicyListBasicByCriteria(policyNumber,holderName,holderId,holderPhone,insuredName,insuredId,statusList,brokerAgentCode,isIPMI,companyCode,null);
    }
    
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(String policyNumber,String holderName,String holderId,String holderPhone,String insuredName,String insuredId,List<String> statusList,String brokerAgentCode,Boolean isIPMI,String companyCode,String userLoginName){ //,String memberName
        HttpCalloutVO.PolicyRequest request=new HttpCalloutVO.PolicyRequest();
        if(!String.IsBlank(policyNumber)){
            request.policyNumber=policyNumber;
        }
        if(!String.IsBlank(holderName)){
            request.holderName=holderName;
        }
        if(!String.IsBlank(holderId)){
            request.holderId=holderId;
        }
        if(!String.IsBlank(holderPhone)){
            request.holderPhone=holderPhone;
        }
        if(!String.IsBlank(insuredName)){
            request.insuredName=insuredName;
        }
        if(!String.IsBlank(insuredId)){
            request.insuredId=insuredId;
        }
        if(statusList!=null && !statusList.isEmpty()){
            request.statusList=statusList;
        }
        if(!String.IsBlank(brokerAgentCode)){
            request.brokerAgentCode=brokerAgentCode;
        }
        if(isIPMI!=null){
            request.isIPMI=isIPMI;
        }
        if(!String.IsBlank(companyCode)){
            request.companyCode=companyCode;
        }
        if(!String.IsBlank(userLoginName)){
            request.userLoginName=userLoginName;
        }
        return getGroupPolicyListBasicByCriteria(request);
    }
    
    /*
     * this is the latest version,support isIPMI filter
     *     @brokerAgentCode if you want to search policies without broker agent,please specify the brokerAgentCode=PolicyCalloutHelper.NO_BROKER_AGENT
     *     @userLoginName Added by Nicole in Phase2
     *     @Added All Criterira into Class HttpCalloutVO.PolicyRequest // Updated by Nicole in Phase2
     */
    public List<HttpCalloutVO.Policy> getGroupPolicyListBasicByCriteria(HttpCalloutVO.PolicyRequest request){
        system.debug('PolicyCalloutHelper.getGroupPolicyListBasicByCriteria');
        this.functionName=PolicyCalloutHelper.GetPolicyListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolicyType',PolicyCalloutHelper.POLICY_TYPE_GROUP);
        paramsMap.put('PolNumber',String.isNotBlank(request.policyNumber)?request.policyNumber:'');
        paramsMap.put('HolderFullName',String.isNotBlank(request.holderName)?request.holderName:'');
        //paramsMap.put('MemberName',String.isNotBlank(memberName)?memberName:'');
        paramsMap.put('HolderGovtID',String.isNotBlank(request.holderId)?request.holderId:'');
        paramsMap.put('HolderDialNumber',String.isNotBlank(request.holderPhone)?request.holderPhone:'');
        paramsMap.put('InsuredFullName',String.isNotBlank(request.insuredName)?request.insuredName:'');
        paramsMap.put('InsuredGovtID',String.isNotBlank(request.insuredId)?request.insuredId:'');
        //add Bob 20201116 Additional option to search their client case by renewing month
        paramsMap.put('PolicyRenewingMonth',String.isNotBlank(request.policyRenewingMonth)?request.policyRenewingMonth:'');
        paramsMap.put('PolicyRenewingYear',String.isNotBlank(request.policyRenewingYear)?request.policyRenewingYear:'');
        //end Bob 20201116 Additional option to search their client case by renewing month
        if(request.statusList!=null && !request.statusList.isEmpty()){
            paramsMap.put('PolicyStatus',String.join(request.statusList,';'));
        }
        if(String.isNotBlank(request.brokerAgentCode)){
            paramsMap.put('BrokerAgentCode',request.brokerAgentCode);
        }
        if(request.isIPMI!=null){
            paramsMap.put('IPMIPolicyInd',String.valueOf(request.isIPMI));
            paramsMap.put('IPMIPolicyIndCode',request.isIPMI?'1':'0');
        }
        paramsMap.put('OrgCode',String.isNotBlank(request.companyCode)?request.companyCode:'');
        paramsMap.put('UserLoginName',String.isNotBlank(request.userLoginName)?request.userLoginName:'');
        paramsMap.put('FamilyRecInd',String.isNotBlank(request.FamilyRecInd)?request.FamilyRecInd: '');
        if(!String.IsBlank(request.claimNumber)){
            paramsMap.put('ClaimNumber',request.claimNumber);
        }
        if(!String.IsBlank(request.bankAccountNumber)){
            paramsMap.put('AccountNumber',request.bankAccountNumber);
        }
        if(request.holderDOB!=null){
            paramsMap.put('HolderDOB',String.Valueof(request.holderDOB));
        }
        if(request.insuredDOB!=null){
            paramsMap.put('InsuredDOB',String.Valueof(request.insuredDOB));
        }
        if(request.policyCreationDateTime!=null){
            paramsMap.put('PolicyCreationDate',String.Valueof(request.policyCreationDateTime).substring(0,10));
            paramsMap.put('PolicyCreationTime',String.Valueof(request.policyCreationDateTime).substring(11));
        }
        if(!String.IsBlank(request.SellerId)){
            paramsMap.put('SellerId',request.SellerId);
        }
        paramsMap.put('SortOrder',String.isNotBlank(request.SortOrder)?request.SortOrder: '');
        return asyn?new List<HttpCalloutVO.Policy>():(List<HttpCalloutVO.Policy>)execute(new Map<String,String>());
    }
    
    public List<HttpCalloutVO.Policy> getPolicyListBasicByCriteria(HttpCalloutVO.PolicyRequest critieria){
        system.debug('PolicyCalloutHelper.getIndividualPolicyListBasicByCriteria');
        /*system.debug('>>> isIndividual: '+critieria.isIndividual);
        system.debug('>>> policyNumber: '+critieria.policyNumber);
        system.debug('>>> holderName: '+critieria.holderName);
        system.debug('>>> holderId: '+critieria.holderId);
        system.debug('>>> holderPhone: '+critieria.holderPhone);
        system.debug('>>> insuredName: '+critieria.insuredName);
        system.debug('>>> insuredId: '+critieria.insuredId);
        system.debug('>>> statusList: '+critieria.statusList);
        system.debug('>>> brokerAgentCode: '+critieria.brokerAgentCode);
        system.debug('>>> isIPMI: '+critieria.isIPMI);
        system.debug('>>> companyCode: '+critieria.companyCode);
        system.debug('>>> userLoginName: '+critieria.userLoginName);
        system.debug('>>> roleID: '+critieria.roleID);
        system.debug('>>> isTUpPolicy: '+critieria.isTUpPolicy);*/
        //system.debug('>>> isCPlusPolicy: '+critieria.isCPlusPolicy);
        /*system.debug('>>> isLHBPolicy: '+critieria.isLHBPolicy);
        system.debug('>>> isLHBPackagePolicy: '+critieria.isLHBPackagePolicy);
        system.debug('>>> isLHBEligibleForGOPPolicy: '+critieria.isLHBEligibleForGOPPolicy);
        system.debug('>>> isGAOPPolicy: '+critieria.isGAOPPolicy);*/
        system.debug('critieria: '+critieria);
        this.functionName=PolicyCalloutHelper.GetPolicyListBasicByCriteria;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolicyType',(critieria.isIndividual!=null && critieria.isIndividual)?PolicyCalloutHelper.POLICY_TYPE_INDIVIDUAL:PolicyCalloutHelper.POLICY_TYPE_GROUP);
        paramsMap.put('PolNumber',String.isNotBlank(critieria.policyNumber)?critieria.policyNumber:'');
        paramsMap.put('HolderFullName',String.isNotBlank(critieria.holderName)?critieria.holderName:'');
        //paramsMap.put('MemberName',String.isNotBlank(critieria.memberName)?critieria.memberName:'');
        paramsMap.put('HolderGovtID',String.isNotBlank(critieria.holderId)?critieria.holderId:'');
        paramsMap.put('HolderDialNumber',String.isNotBlank(critieria.holderPhone)?critieria.holderPhone:'');
        paramsMap.put('InsuredFullName',String.isNotBlank(critieria.insuredName)?critieria.insuredName:'');
        paramsMap.put('InsuredGovtID',String.isNotBlank(critieria.insuredId)?critieria.insuredId:'');
        if(critieria.statusList!=null && !critieria.statusList.isEmpty()){
            paramsMap.put('PolicyStatus',String.join(critieria.statusList,';'));
        }
        if(String.isNotBlank(critieria.brokerAgentCode)){
            paramsMap.put('BrokerAgentCode',critieria.brokerAgentCode);
        }
        if(critieria.isIPMI!=null){
            paramsMap.put('IPMIPolicyInd',String.valueOf(critieria.isIPMI));
            paramsMap.put('IPMIPolicyIndCode',critieria.isIPMI?'1':'0');
        }
        paramsMap.put('OrgCode',String.isNotBlank(critieria.companyCode)?critieria.companyCode:'');
        paramsMap.put('UserLoginName',String.isNotBlank(critieria.userLoginName)?critieria.userLoginName:'');
        paramsMap.put('RoleID',String.isNotBlank(critieria.roleID)?critieria.roleID:'');
        if(critieria.isTUpPolicy!=null){
            paramsMap.put('TUpPolicyInd',String.valueOf(critieria.isTUpPolicy));
            paramsMap.put('TUpPolicyIndCode',critieria.isTUpPolicy?'1':'0');
        }
        //if(critieria.isCPlusPolicy!=null){
        //    paramsMap.put('CPlusPolicyInd',String.valueOf(critieria.isCPlusPolicy));
        //    paramsMap.put('CPlusPolicyIndCode',critieria.isCPlusPolicy?'1':'0');
        //}
        if(critieria.isLHBPolicy!=null){
            paramsMap.put('LHBPolicyInd',String.valueOf(critieria.isLHBPolicy));
            paramsMap.put('LHBPolicyIndCode',critieria.isLHBPolicy?'1':'0');
        }
        if(critieria.isLHBPackagePolicy!=null){
            paramsMap.put('LHBPackagePolicyInd',String.valueOf(critieria.isLHBPackagePolicy));
            paramsMap.put('LHBPackagePolicyIndCode',critieria.isLHBPackagePolicy?'1':'0');
        }
        if(critieria.isLHBEligibleForGOPPolicy!=null){
            paramsMap.put('LHBEligibleForGOPPolicyInd',String.valueOf(critieria.isLHBEligibleForGOPPolicy));
            paramsMap.put('LHBEligibleForGOPPolicyIndCode',critieria.isLHBEligibleForGOPPolicy?'1':'0');
        }
        if(critieria.isGAOPPolicy!=null){
            paramsMap.put('GAOPPolicyInd',String.valueOf(critieria.isGAOPPolicy));
            paramsMap.put('GAOPPolicyIndCode',critieria.isGAOPPolicy?'1':'0');
        }
        return asyn?new List<HttpCalloutVO.Policy>():(List<HttpCalloutVO.Policy>)execute(new Map<String,String>());
    }
    
    /********************************************************************
     * processPolicyListBasicByCriteriaResult
     * @param Dom.document
     * @decs:Handle GetPolicyListBasicByCriteria WS repsonse
     * @return List<HttpCalloutVO.Policy>
   ********************************************************************/
    public List<HttpCalloutVO.Policy> processPolicyListBasicByCriteriaResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processPolicyListBasicByCriteriaResult');
        List<HttpCalloutVO.Policy> objList=new List<HttpCalloutVO.Policy>();
        Map<String,HttpCalloutVO.Policy> holdingMap=new Map<String,HttpCalloutVO.Policy>();
        Map<String,HttpCalloutVO.Person> partyMap=new Map<String,HttpCalloutVO.Person>(); // temporarily store the party information
        List<HttpCalloutVO.Relation> relationList=new List<HttpCalloutVO.Relation>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                if(policyNode!=null){
                    HttpCalloutVO.Policy policy=new HttpCalloutVO.Policy();
                    //SPS-165
                    policy.currencyCode=getChildNodeAttributeIfNotEmpty('CurrencyTypeCode','tc',childNode);
                    policy.currencySymbol=currencyCodeMap.get(policy.currencyCode);
                    //SPS-165
                    policy.holdingID=childNode.getAttributeValue('id',null);
                    policy.policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    policy.masterPolicyNo=getChildNodeTextIfNotEmpty('MasterPolicy',policyNode); // Rancho_FriendDiscount_20210812: enable phone number search for TM
                    policy.policyValue=getChildNodeTextIfNotEmpty('PolicyValue',policyNode);
                    policy.policyStatusCode=getChildNodeAttributeIfNotEmpty('PolicyStatus','tc',policyNode);
                    policy.policyStatus=getChildNodeTextIfNotEmpty('PolicyStatus',policyNode);
                    policy.isHideAfter1Year=false;
                    if(String.isNotBlank(policy.policyStatusCode)){
                        if((this.roleID=='CS' || this.roleID=='TM') && (policy.policyStatusCode=='55' || policy.policyStatusCode=='1052500025')){ 
                            policy.policyStatusDisplayName='Suspended';  // updated for UAT ISSUE DPSP-71
                        }else{
                            List<Policy_Status_Mapping__c> psm=Policy_Status_Mapping__c.getAll().values();
                            Policy_Status_Mapping__c temp;
                            
                            for(Policy_Status_Mapping__c p:psm){
                                if(p.PolicyCode__c==policy.policyStatusCode){
                                    temp=p;
                                }
                            }
                            if(temp!=null){
                                policy.isHideAfter1Year=temp.Hide_After_1_year__c;
                                if('zh_HK'.equalsIgnoreCase(this.userLanguage) || 'zh_CN'.equalsIgnoreCase(this.userLanguage) || 'zh_TW'.equalsIgnoreCase(this.userLanguage)){
                                    policy.policyStatusDisplayName=temp.PolicyStatusChinese__c;
                                }else{
                                    policy.policyStatusDisplayName=temp.PolicyStatus__c;
                                }
                            }
                            
                            if(String.isBlank(policy.policyStatusDisplayName)){
                                policy.policyStatusDisplayName=policy.policyStatus;
                            }
                        }
                    }
                    
                    policy.effDate=getChildNodeTextIfNotEmpty('EffDate',policyNode);
                    policy.effDateInDate=getChildNodeDateIfNotEmpty('EffDate',policyNode,'yyyy-MM-dd');
                    //Add by Caden for JR1753 - change from policy level to member level coverage start
                    policy.memberEffDateInDate=getChildNodeDateIfNotEmpty('MemberEffDate',policyNode,'yyyy-MM-dd');
                    policy.memberTermDate=getChildNodeTextIfNotEmpty('MemberTermDate',policyNode);// Rancho_JOBR376_20240612
                    policy.memberTermDateInDate=getChildNodeDateIfNotEmpty('MemberTermDate',policyNode,'yyyy-MM-dd');
                    policy.memberStatusDisplayName=getChildNodeTextIfNotEmpty('MemberStatus',policyNode);
                    if(policy.memberStatusDisplayName!=null){
                        if('zh_HK'.equalsIgnoreCase(this.userLanguage) || 'zh_CN'.equalsIgnoreCase(this.userLanguage) || 'zh_TW'.equalsIgnoreCase(this.userLanguage)){
                                if(policy.memberStatusDisplayName.equalsIgnoreCase(MEMBER_STATUS_ACTIVE_ENG)){
                                    policy.memberStatusDisplayName=MEMBER_STATUS_ACTIVE_CHI;
                                }else{
                                    policy.memberStatusDisplayName=MEMBER_STATUS_INACTIVE_CHI;
                                }
                        }else{
                            if(policy.memberStatusDisplayName.equalsIgnoreCase(MEMBER_STATUS_ACTIVE_ENG)){
                                policy.memberStatusDisplayName=MEMBER_STATUS_ACTIVE_ENG;
                            }else{
                                policy.memberStatusDisplayName=MEMBER_STATUS_INACTIVE_ENG;
                            }
                        }
                    }
                    ////Add by Caden for JR1753 - change from policy level to member level coverage end
                    policy.termDate=getChildNodeTextIfNotEmpty('TermDate',policyNode);
                    policy.termDateInDate=getChildNodeDateIfNotEmpty('TermDate',policyNode,'yyyy-MM-dd');
                    
                    //Add for SPS-165
                    policy.cancelDate=getChildNodeDateifNotEmpty('CancelDate',policyNode,'yyyy-MM-dd');
                    //End Add
                    
                    policy.paidToDate=getChildNodeTextIfNotEmpty('PaidToDate',policyNode);
                    policy.paidToDateInDate=getChildNodeDateIfNotEmpty('PaidToDate',policyNode,'yyyy-MM-dd');
                    policy.issueDate=getChildNodeTextIfNotEmpty('IssueDate',policyNode);
                    policy.issueDateInDate=getChildNodeDateIfNotEmpty('IssueDate',policyNode,'yyyy-MM-dd');
                    policy.paymentAmt=getChildNodeDecimalIfNotEmpty('PaymentAmt',policyNode);

                    // 20200610 - minghua - levyII
                    // policy.levyCurrentPremium=getChildNodeDecimalIfNotEmpty('PaymentLevy',policyNode);
                    policy.levyCurrentPremium=getChildNodeDecimalIfNotEmpty('LastPaymentLevy',policyNode);
                    policy.nextLevy=getChildNodeDecimalIfNotEmpty('NextLevy',policyNode);
                    if(policy.paymentAmt==null){
                        policy.paymentAmt=0;
                    }
                    if(policy.levyCurrentPremium==null){
                        policy.levyCurrentPremium=0;
                    }
                    if(policy.nextLevy==null){
                        policy.nextLevy=0;
                    }
                    policy.currentPremiumIncludeLevy=policy.paymentAmt+policy.levyCurrentPremium;
                    policy.modalPremiumIncludeLevy=policy.paymentAmt+policy.nextLevy;
                                       
                    policy.annualPaymentAmt=getChildNodeTextIfNotEmpty('AnnualPaymentAmt',policyNode);
                    policy.sourceSystem=getChildNodeTextIfNotEmpty('SourceSystem',policyNode);
                    policy.paymentMode=getChildNodeTextIfNotEmpty('PaymentMode',policyNode);
                    policy.paymentModeCode=getChildNodeAttributeIfNotEmpty('PaymentMode','tc',policyNode);
                    policy.paymentMethod=getChildNodeTextIfNotEmpty('PaymentMethod',policyNode);
                    policy.productType=getChildNodeTextIfNotEmpty('ProductType',policyNode);
                    //add Bob cp-77 20210310
                    policy.numOfBranchs = getChildNodeTextIfNotEmpty('NumOfBranchs',policyNode);
                    policy.numOfPlans =  getChildNodeTextIfNotEmpty('NumOfPlans',policyNode);
                    //end Bob 20210310
                    // fix bug PEI-73 IBM minglei 20180611 start
                    policy.productTypeCode=getChildNodeAttributeIfNotEmpty('ProductType','tc',policyNode);
                    // fix bug PEI-73 IBM minglei 20180611 end
                    policy.productCode=getChildNodeTextIfNotEmpty('ProductCode',policyNode);
                    policy.planName=getChildNodeTextIfNotEmpty('PlanName',policyNode);
                    policy.marketingName=getChildNodeTextIfNotEmpty('MarketingName',policyNode);
                    policy.rateScale=getChildNodeTextIfNotEmpty('RateScale',policyNode);
                    //JR-1785
                    policy.category=getChildNodeTextIfNotEmpty('PolCategory',policyNode);
                    //JR-1785
                    policy.partnerCode=getChildNodeTextIfNotEmpty('PartnerCode',policyNode);//Owen 20230530 For PS-23 add new columu 'Partner Code'
                    
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',policyNode);
                    policy.isLifePolicy=getChildNodeBooleanIfNotEmpty('LifePolicyInd',OLifEExtensionNode);
                    policy.isILAS=getChildNodeBooleanIfNotEmpty('ILASPolicyInd',OLifEExtensionNode);
                    policy.isIndividual=getChildNodeBooleanIfNotEmpty('IndividualPolicyInd',OLifEExtensionNode);
                    policy.isIPMIPolicy=getChildNodeBooleanIfNotEmpty('IPMIPolicyInd',OLifEExtensionNode);
                    policy.isTUpPolicy=getChildNodeBooleanIfNotEmpty('TUpPolicyInd',OLifEExtensionNode);
                    //policy.isCPlusPolicy=getChildNodeBooleanIfNotEmpty('CPlusPolicyInd',OLifEExtensionNode);
                    policy.isLHBPolicy=getChildNodeBooleanIfNotEmpty('LHBPolicyInd',OLifEExtensionNode);
                    policy.isLHBPackagePolicy=getChildNodeBooleanIfNotEmpty('LHBPackagePolicyInd',OLifEExtensionNode);
                    policy.isLHBEligibleForGOPPolicy=getChildNodeBooleanIfNotEmpty('LHBEligibleForGOPPolicyInd',OLifEExtensionNode);
                    policy.isGAOPPolicy=getChildNodeBooleanIfNotEmpty('GAOPPolicyInd',OLifEExtensionNode);
                    policy.allowChangeOwner=getChildNodeBooleanIfNotEmpty('AllowChangeOwnerInd',OLifEExtensionNode);
                    policy.allowChangePaymentDate=getChildNodeBooleanIfNotEmpty('AllowChangePaymentDateInd',OLifEExtensionNode);
                    //JR1809 see if policy been inactive more than 90 days
                    policy.inactiveDays=getChildNodeIntegerIfNotEmpty('InactiveDays',OLifEExtensionNode);
                    policy.distChannelCode=getChildNodeTextIfNotEmpty('DistChannelCode',OLifEExtensionNode);
                    policy.distChannelDesc=getChildNodeTextIfNotEmpty('DistChannelDesc',OLifEExtensionNode);
                    policy.policyAddressInd=getChildNodeTextIfNotEmpty('PolicyAddressInd',OLifEExtensionNode);//add by Andy
                    
                    if(policy.isILAS!=null && policy.isILAS){
                        policy.policyType='ILAS';
                    }else if(policy.isIndividual!=null &&  policy.isIndividual){
                        policy.policyType='nonILAS';
                    }else{
                        policy.policyType='Group';
                    }
                    
                    //Hardcopy Indicator added start
                    Dom.XmlNode HardCopyIndicatorNode=getChildNodeIfNotNull('HardCopyIndicator',OLifEExtensionNode);
                    policy.medCardIndicator=getChildNodeTextIfNotEmpty('MedCardIndicator',HardCopyIndicatorNode);
                    policy.letterIndicator=getChildNodeTextIfNotEmpty('LetterIndicator',HardCopyIndicatorNode);
                    //Hardcopy Indicator added end
                    
                    //Policy Function Start
                    Dom.XmlNode policyFunctionMapListNode=getChildNodeIfNotNull('PolicyFunctionMapList',OLifEExtensionNode);
                    if(policyFunctionMapListNode!=null){
                        List<Dom.XmlNode> policyFunctionChildNodes=getChildElementsIfNotNull(policyFunctionMapListNode);
                        for(Dom.XmlNode pfChildNode:policyFunctionChildNodes){
                           if(pfChildNode.getName()=='FunctionMap'){
                               HttpCalloutVO.FunctionMap fm=new HttpCalloutVO.FunctionMap();
                               fm.functionName=getChildNodeTextIfNotEmpty('FunctionName',pfChildNode);
                               fm.functionDesc=getChildNodeTextIfNotEmpty('FunctionDesc',pfChildNode);
                               fm.priority=getChildNodeIntegerIfNotEmpty('Priority',pfChildNode);
                               fm.isActive=getChildNodeTextIfNotEmpty('IsActive',pfChildNode);
                               policy.functionMap.put(fm.functionName.trim(),fm);
                           }
                        }
                    }
                                      
                    policy.insuredList=new List<HttpCalloutVO.Person>();
                    holdingMap.put(policy.holdingID,policy);
                }
            }else if(childNode.getName()=='Party'){
                HttpCalloutVO.Person party=new HttpCalloutVO.Person();
                party.partyID=childNode.getAttributeValue('id',null);
                party.fullName=getChildNodeTextIfNotEmpty('FullName',childNode); // temporarily store in this field
                party.ssnNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);  // temporarily store in this field
                    
                Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',childNode);
                if(OLifEExtensionNode!=null){
                    party.certificateNo=getChildNodeTextIfNotEmpty('CertificateNo',OLifEExtensionNode );
                }else{
                    party.certificateNo=getChildNodeTextIfNotEmpty('CertificateNo',childNode);
                }
                
                Dom.XmlNode orgNode=getChildNodeIfNotNull('Organization',childNode);
                if(orgNode!=null){
                     party.orgCode=getChildNodeTextIfNotEmpty('OrgCode',orgNode);
                }
                party.policyRemark=getChildNodeTextIfNotEmpty('PolicyRemark',childNode);
                
                Dom.XmlNode ProducerNode=getChildNodeIfNotNull('Producer',childNode);
                Dom.XmlNode CarrierAppointmentNode=getChildNodeIfNotNull('CarrierAppointment',ProducerNode);
                party.brokerAgentCode=getChildNodeTextIfNotEmpty('CompanyProducerID',CarrierAppointmentNode);
                partyMap.put(party.partyID,party);
            }else if(childNode.getName()=='Relation'){
                HttpCalloutVO.Relation relation=new HttpCalloutVO.Relation();
                relation.id=childNode.getAttributeValue('id',null);
                relation.OriginatingObjectID=childNode.getAttributeValue('OriginatingObjectID',null);
                relation.RelatedObjectID=childNode.getAttributeValue('RelatedObjectID',null);
                relation.OriginatingObjectType=getChildNodeTextIfNotEmpty('OriginatingObjectType',childNode);
                relation.OriginatingObjectCode=getChildNodeAttributeIfNotEmpty('OriginatingObjectType','tc',childNode);
                relation.RelatedObjectType=getChildNodeTextIfNotEmpty('RelatedObjectType',childNode);
                relation.RelatedObjectCode=getChildNodeAttributeIfNotEmpty('RelatedObjectType','tc',childNode);
                relation.RelationRoleCode=getChildNodeAttributeIfNotEmpty('RelationRoleCode','tc',childNode);
                relation.RelationRoleType=getChildNodeTextIfNotEmpty('RelationRoleCode',childNode);
                relationList.add(relation);
            }
        }
        
        for(HttpCalloutVO.Relation relation:relationList){
            HttpCalloutVO.Policy holding=holdingMap.get(relation.OriginatingObjectID);
            HttpCalloutVO.Person party=partyMap.get(relation.RelatedObjectID);
            // 1 policy has 1 holder and manay insured
            if(relation.RelationRoleType=='Owner'){
                holding.holderName=party.fullName;
                holding.holderSSN=party.ssnNumber;
                holding.holder=party;
            }else if(relation.RelationRoleType=='Insured'){
                holding.insuredList.add(party);
            }else if(relation.RelationRoleCode=='38'){
                holding.brokerCode=party.brokerAgentCode;
                holding.broker=party;
                holding.certNumber=party.certificateNo;
                holding.orgCode=party.orgCode;
                holding.policyRemark=party.policyRemark ;
            }
        }
        objList.addAll(holdingMap.values());
        system.debug('List<HttpCalloutVO.Policy> '+objList.size());
        return objList;
    }
    
    
    public List<HttpCalloutVO.ClinicVisit> getClinicVisitCount(String policyNumber,String ssnNumber,String certNumber){
        system.debug('PolicyCalloutHelper.getClinicVisitCount');
        return getClinicVisitCount(policyNumber,ssnNumber,certNumber,'');
    }
    
    /*
     * policyNumber
     * ssnNumber i.e. GovtID
     * certNumber i.e. Certificate number
     * benefitSectionCode i.e Benefit Section Code (OPB=Out-patient Benefits HOS=Hospitalization & Surgical Benefits)
     * paramter 'benefitSectionCode': added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
     */
    public List<HttpCalloutVO.ClinicVisit> getClinicVisitCount(String policyNumber,String ssnNumber,String certNumber,String benefitSectionCode){
        system.debug('PolicyCalloutHelper.getClinicVisitCount');
        this.functionName=PolicyCalloutHelper.GetClinicVisitCount;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',String.isNotBlank(policyNumber)?policyNumber:'');
        paramsMap.put('GovtID',String.isNotBlank(ssnNumber)?ssnNumber:'');
        paramsMap.put('CertificateNo',String.isNotBlank(certNumber)?certNumber:'');
        paramsMap.put('BenefitSectionCode',String.isNotBlank(benefitSectionCode)?benefitSectionCode:'');
        return (List<HttpCalloutVO.ClinicVisit>)execute(new Map<String,String>());
    }
    
    /*
     * policyNumber
     * ssnNumber i.e. GovtID
     * certNumber i.e. Certificate number
     * benefitSectionCode i.e Benefit Section Code (OPB=Out-patient Benefits HOS=Hospitalization & Surgical Benefits)
     * showAmountLimit True(Display all benefits with benefit limit and/or with amount limit)/False(Only display benefits with benefit limit)
     * paramter 'benefitSectionCode': added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
     */
    public List<HttpCalloutVO.ClinicVisit> getClinicVisitCount(String policyNumber,String ssnNumber,String certNumber,String benefitSectionCode,Boolean showAmountLimit){
        system.debug('PolicyCalloutHelper.getClinicVisitCount');
        this.functionName=PolicyCalloutHelper.GetClinicVisitCount;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',String.isNotBlank(policyNumber)?policyNumber:'');
        paramsMap.put('GovtID',String.isNotBlank(ssnNumber)?ssnNumber:'');
        paramsMap.put('CertificateNo',String.isNotBlank(certNumber)?certNumber:'');
        paramsMap.put('BenefitSectionCode',String.isNotBlank(benefitSectionCode)?benefitSectionCode:'');
        paramsMap.put('ShowAmountLimit',showAmountLimit==null? 'false':(showAmountLimit?'true': 'false'));
        return (List<HttpCalloutVO.ClinicVisit>)execute(new Map<String,String>());
    }

    public List<HttpCalloutVO.ClinicVisit> processClinicVisitCountResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processClinicVisitCountResult');
        List<HttpCalloutVO.ClinicVisit> clinicVisitList=new List<HttpCalloutVO.ClinicVisit>();
        if(!this.isCalloutSuccessfully){
            return clinicVisitList ;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        
        String policyNo='';
        String productType='';
        String productTypeCode='';
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                String holdingTypeCode=getChildNodeAttributeIfNotEmpty('HoldingTypeCode','tc',childNode);
                if(holdingTypeCode=='2'){ //Policy
                    Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                    policyNo=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    productType=getChildNodeTextIfNotEmpty('ProductType',policyNode);
                    productTypeCode=getChildNodeAttributeIfNotEmpty('ProductType','tc',policyNode);
                }
            }else if(childNode.getName()=='Party'){
                HttpCalloutVO.ClinicVisit clinicVisit=new HttpCalloutVO.ClinicVisit();
                Dom.XmlNode extensionNode=getChildNodeIfNotNull('OLifEExtension',childNode);
                clinicVisit.certNumber=getChildNodeTextIfNotEmpty('CertificateNo',extensionNode);
                clinicVisit.memberStatusDescription=getChildNodeTextIfNotEmpty('MemberStatusDesc',extensionNode);
                clinicVisit.planNumber=getChildNodeTextIfNotEmpty('PlanNumber',extensionNode);
                // temporary comment by kermit at 20190805 11:55
                //clinicVisit.benefitList=new List<HttpCalloutVO.BenefitDetailItem>();//to remove
                //clinicVisit.combinedBenefitList=new  List<HttpCalloutVO.CombinedBenefit>();//to remove
                clinicVisit.benefitCategoryList=new  List<HttpCalloutVO.BenefitCategory>();
                Map<String,HttpCalloutVO.BenefitCategory> sortBenefitCategoryMap=new Map<String,HttpCalloutVO.BenefitCategory>();
                List<String> sortBenefitCategoryList=new List<String>();
                
                clinicVisit.policyNumber=policyNo;
                clinicVisit.planTypeCode=productTypeCode;
                clinicVisit.planTypeDescription=productType;
                
                List<Dom.XmlNode> exChildNodes=getChildElementsIfNotNull(extensionNode);
                for(Dom.XmlNode exChildNode:exChildNodes){
                    if(exChildNode.getName()=='BenefitCategoryList'){
                        //system.debug('exChildNode'+exChildNode);
                        List<Dom.XmlNode> seChildNodes=getChildElementsIfNotNull(exChildNode);
                        for(Dom.XmlNode seChildNode:seChildNodes){
                            if(seChildNode.getName()=='BenefitCategory'){
                                //system.debug('seChildNode'+seChildNode);
                                HttpCalloutVO.BenefitCategory benCategory=new HttpCalloutVO.BenefitCategory();
                                benCategory.categoryCode=getChildNodeTextIfNotEmpty('CategoryCode',seChildNode);
                                benCategory.categoryDescription=getChildNodeTextIfNotEmpty('CategoryDescription',seChildNode);
                                benCategory.sequence=getChildNodeTextIfNotEmpty('Sequence',seChildNode);
                                sortBenefitCategoryMap.put(benCategory.sequence+benCategory.categoryCode,benCategory);
                                sortBenefitCategoryList.add(benCategory.sequence+benCategory.categoryCode);
                                
                                benCategory.benefitList=new List<HttpCalloutVO.BenefitDetailItem>();
                                //benCategory.combinedBenefitList=new  List<HttpCalloutVO.CombinedBenefit>();
                                Map<String,HttpCalloutVO.BenefitDetailItem> sortBenefitMap=new Map<String,HttpCalloutVO.BenefitDetailItem>();
                                //Map<String,HttpCalloutVO.CombinedBenefit> sortComBenefitMap=new Map<String,HttpCalloutVO.CombinedBenefit>();
                                List<String> sortBenefitList=new List<String>();
                                //List<String> sortComBenefitList=new List<String>();
                                
                                List<Dom.XmlNode> thChildNodes=getChildElementsIfNotNull(seChildNode);
                                for(Dom.XmlNode thChildNode:thChildNodes){
                                    if(thChildNode.getName()=='BenefitDetailsList'){
                                        //system.debug('thChildNode'+thChildNode);
                                        List<Dom.XmlNode> forChildNodes=getChildElementsIfNotNull(thChildNode);
                                        for(Dom.XmlNode forChildNode:forChildNodes){
                                            if(forChildNode.getName()=='BenefitDetails'){
                                                Dom.XmlNode benChildNode=forChildNode;
                                                HttpCalloutVO.BenefitDetailItem benefit=new HttpCalloutVO.BenefitDetailItem();
                                                benefit.sequenceNumber=getChildNodeTextIfNotEmpty('Sequence',benChildNode);
                                                benefit.benefitDetailItemCode=getChildNodeTextIfNotEmpty('BenefitCode',benChildNode);
                                                benefit.benefitDetailItemDescription=getChildNodeTextIfNotEmpty('BenefitDescription',benChildNode);
                                                benefit.maxNoofVisitPerYear=getChildNodeIntegerIfNotEmpty('MaxVisitCount',benChildNode);
                                                benefit.maxNoofVisitPerYearStr=getChildNodeTextIfNotEmpty('MaxVisitCount',benChildNode);        //Modified by Caden for change the variable type from Integer to String
                                                benefit.visitedCount=getChildNodeIntegerIfNotEmpty('VisitCount',benChildNode);
                                                benefit.visitBalance=getChildNodeTextIfNotEmpty('VisitBalance',benChildNode);         //Modified by Caden for add variable for visit balance
                                                //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                                                benefit.benefitSectionCode=getChildNodeTextIfNotEmpty('SectionCode',benChildNode);
                                                benefit.networkType=getChildNodeTextIfNotEmpty('NetworkType',benChildNode);
                                                benefit.benefitVisitBalance=getChildNodeIntegerIfNotEmpty('VisitBalance',benChildNode);
                                                benefit.benefitMaxAmt=getChildNodeDecimalIfNotEmpty('MaxAmount',benChildNode);
                                                benefit.benefitPaidAmt=getChildNodeDecimalIfNotEmpty('AmountPaid',benChildNode);
                                                benefit.benefitAmtBalance=getChildNodeDecimalIfNotEmpty('AmountBalance',benChildNode);
                                                //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                                                
                                                benefit.IsCombinedBenefit=getChildNodeBooleanIfNotEmpty('IsCombinedBenefit',benChildNode);
                                                benefit.IsSummary=getChildNodeBooleanIfNotEmpty('IsSummary',benChildNode);
                                                benefit.RemarkList=new List<String>();
                                                List<Dom.XmlNode> remChildNodes=getChildElementsIfNotNull(benChildNode);
                                                for(Dom.XmlNode remChildNode:remChildNodes){
                                                    if(remChildNode.getName()=='RemarkList'){
                                                        benefit.RemarkList.add(getChildNodeTextIfNotEmpty('Remark',remChildNode));
                                                    }
                                                }
                                                
                                                sortBenefitMap.put(benefit.sequenceNumber+benefit.benefitDetailItemCode,benefit);
                                                sortBenefitList.add(benefit.sequenceNumber+benefit.benefitDetailItemCode);
                                            }
                                        }
                                    }
                                }
                                sortBenefitList.sort();
                                for(String key:sortBenefitList){
                                    if(sortBenefitMap.containsKey(key)) benCategory.benefitList.add(sortBenefitMap.get(key));
                                }
                            }
                        }
                    }
                }
                
                sortBenefitCategoryList.sort();
                for(String key:sortBenefitCategoryList){
                    if(sortBenefitCategoryMap.containsKey(key)) clinicVisit.benefitCategoryList.add(sortBenefitCategoryMap.get(key));
                }
                
                clinicVisitList.add(clinicVisit);
                
                /*List<Dom.XmlNode> exChildNodes=getChildElementsIfNotNull(extensionNode);
                for(Dom.XmlNode exChildNode:exChildNodes){
                    if(exChildNode.getName()=='BenefitClinicVisit'){
                        HttpCalloutVO.BenefitDetailItem benefit=new HttpCalloutVO.BenefitDetailItem();
                        benefit.benefitDetailItemCode=getChildNodeTextIfNotEmpty('BenefitItemCode',exChildNode );
                        benefit.benefitDetailItemDescription=getChildNodeTextIfNotEmpty('BenefitItemDesc',exChildNode);
                        benefit.maxNoofVisitPerYear=getChildNodeIntegerIfNotEmpty('BenefitMaxVisit',exChildNode);
                        benefit.maxNoofVisitPerYearStr=getChildNodeTextIfNotEmpty('BenefitMaxVisit',exChildNode);        //Modified by Caden for change the variable type from Integer to String
                        benefit.visitedCount=getChildNodeIntegerIfNotEmpty('BenefitVisitCount',exChildNode);
                        benefit.visitBalance=getChildNodeTextIfNotEmpty('BenefitVisitBalance',exChildNode);         //Modified by Caden for add variable for visit balance
                        //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                        benefit.benefitSectionCode=getChildNodeTextIfNotEmpty('BenefitSectionCode',exChildNode);
                        benefit.networkType=getChildNodeTextIfNotEmpty('NetworkType',exChildNode);
                        benefit.benefitVisitBalance=getChildNodeIntegerIfNotEmpty('BenefitVisitBalance',exChildNode);
                        benefit.benefitMaxAmt=getChildNodeDecimalIfNotEmpty('BenefitMaxAmt',exChildNode);
                        benefit.benefitPaidAmt=getChildNodeDecimalIfNotEmpty('BenefitPaidAmt',exChildNode);
                        benefit.benefitAmtBalance=getChildNodeDecimalIfNotEmpty('BenefitAmtBalance',exChildNode);
                        //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                        clinicVisit.benefitList.add(benefit);
                    }
                    if(exChildNode.getName()=='CombinedBenefitClinicVisit'){
                        HttpCalloutVO.CombinedBenefit combinedBenefit=new HttpCalloutVO.CombinedBenefit();
                        combinedBenefit.sequenceNumber=getChildNodeTextIfNotEmpty('SequenceNumber',exChildNode );
                        combinedBenefit.overallOutpatientMaximumNo=getChildNodeIntegerIfNotEmpty('AllMaxVisit',exChildNode);
                        combinedBenefit.overallOutpatientMaximumNoStr=getChildNodeTextIfNotEmpty('AllMaxVisit',exChildNode);         //Modified by Caden for change the variable type from Integer to String
                        combinedBenefit.totalVisitedCount=getChildNodeIntegerIfNotEmpty('TotalVisitCount',exChildNode);
                        combinedBenefit.benefitItemCodeList=getChildNodeTextIfNotEmpty('BenefitItemCodeList',exChildNode);
                        //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                        combinedBenefit.benefitSectionCode=getChildNodeTextIfNotEmpty('BenefitSectionCode',exChildNode);
                        combinedBenefit.networkType=getChildNodeTextIfNotEmpty('NetworkType',exChildNode);
                        combinedBenefit.benefitVisitBalance=getChildNodeIntegerIfNotEmpty('BenefitVisitBalance',exChildNode);
                        combinedBenefit.benefitMaxAmt=getChildNodeDecimalIfNotEmpty('BenefitMaxAmt',exChildNode);
                        combinedBenefit.benefitPaidAmt=getChildNodeDecimalIfNotEmpty('BenefitPaidAmt',exChildNode);
                        combinedBenefit.benefitAmtBalance=getChildNodeDecimalIfNotEmpty('BenefitAmtBalance',exChildNode);
                        //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
                        
                        //Add by Manuel that supplement the fields of GetClinicVisitCount response
                        combinedBenefit.benefitItemDescList=getChildNodeTextIfNotEmpty('BenefitItemDescList',exChildNode);
                        combinedBenefit.totalVisitBalance=getChildNodeIntegerIfNotEmpty('TotalVisitBalance',exChildNode);
                        combinedBenefit.allMaxVisit=getChildNodeIntegerIfNotEmpty('AllMaxVisit',exChildNode);
                        
                        clinicVisit.combinedBenefitList.add(combinedBenefit);
                    }
                }
                clinicVisitList.add(clinicVisit);*/
            }
        }
        system.debug('List<HttpCalloutVO.ClinicVisit> '+clinicVisitList.size());
        return clinicVisitList;
    }
    
    /*
     * buildCriteriaExpressionNode
     *     -- only for GetPolicyListBasicByCriteria and GetPolicyPersonListBasicByCriteria
     */
    public String buildCriteriaExpressionNode(Map<String,String> paramsMap){
        String node='';
        String criterias='';
        String memberStatus = paramsMap.get('MemberStatus') == null ? '' : paramsMap.get('MemberStatus');
        String companyCode = paramsMap.get('CompanyCode') == null ? '' : paramsMap.get('CompanyCode'); //added by Connor(Client Portal)
        String deptCode = paramsMap.get('DeptCode') == null ? '' : paramsMap.get('DeptCode'); //added by Connor(Client Portal)
        String memberDeptCode = paramsMap.get('MemberDeptCode') == null ? '' : paramsMap.get('MemberDeptCode'); //Rancho_CP782_20220206 - as criteria node is diff with above, add a new dept code
        String employeeId = paramsMap.get('EmployeeId') == null ? '' : paramsMap.get('EmployeeId'); //added by Connor(Client Portal)
        String shorfallDate = paramsMap.get('ShorfallDate') == null ? '' : paramsMap.get('ShorfallDate'); //added by Connor(Client Portal)
        String claimNoShortfall = paramsMap.get('ClaimNumber') == null ? '' : paramsMap.get('ClaimNumber'); //added by Connor(Client Portal)
        String policyYear = paramsMap.get('PolYear') == null ? '' : paramsMap.get('PolYear'); //added by Connor(Client Portal)
        String shortfallStatus = paramsMap.get('ShortfallStatus') == null ? '' : paramsMap.get('ShortfallStatus'); //added by Connor(Client Portal)
        String endorsementNo = paramsMap.get('EndorsementNo') == null ? '' : paramsMap.get('EndorsementNo'); //added by Connor(Client Portal)                                                                                                                            
        String policyType=paramsMap.get('PolicyType')==null?'':paramsMap.get('PolicyType');
        String policyNumber=paramsMap.get('PolNumber')==null?'':paramsMap.get('PolNumber');
        String holderGovtID=paramsMap.get('HolderGovtID')==null?'':paramsMap.get('HolderGovtID');
        String holderFullName=paramsMap.get('HolderFullName')==null?'':paramsMap.get('HolderFullName');
        String holderDialNumber=paramsMap.get('HolderDialNumber')==null?'':paramsMap.get('HolderDialNumber');
        String holderDOB=paramsMap.get('HolderDOB')==null?'':paramsMap.get('holderDOB');                      //Added by Nicole in Phases2 for GetPolicyListBasicByCriteria
        String insuredGovtID=paramsMap.get('InsuredGovtID')==null?'':paramsMap.get('InsuredGovtID');
        //add Bob 20201116 Additional option to search their client case by renewing month
        String policyRenewalYear=paramsMap.get('PolicyRenewingYear')==null?'':paramsMap.get('PolicyRenewingYear');
        String policyRenewalMonth=paramsMap.get('PolicyRenewingMonth')==null?'':paramsMap.get('PolicyRenewingMonth');
        //end Bob 20201116
        String insuredFullName=paramsMap.get('InsuredFullName')==null?'':paramsMap.get('InsuredFullName');
        String insuredDOB=paramsMap.get('InsuredDOB')==null?'':paramsMap.get('insuredDOB');                  //Added by Nicole in Phases2 for GetPolicyListBasicByCriteria
        String claimNumber=paramsMap.get('ClaimNumber')==null?'':paramsMap.get('ClaimNumber');               //Added by Nicole in Phases2 for GetPolicyListBasicByCriteria
        String policyStatus=paramsMap.get('PolicyStatus')==null?'':paramsMap.get('PolicyStatus');
        String brokerAgentCode=paramsMap.get('BrokerAgentCode')==null?'':paramsMap.get('BrokerAgentCode');
        String IPMIPolicyInd=paramsMap.get('IPMIPolicyInd')==null?'':paramsMap.get('IPMIPolicyInd');
        String IPMIPolicyIndCode=paramsMap.get('IPMIPolicyIndCode')==null?'':paramsMap.get('IPMIPolicyIndCode');
        String TUpPolicyInd=paramsMap.get('TUpPolicyInd')==null?'':paramsMap.get('TUpPolicyInd');
        String TUpPolicyIndCode=paramsMap.get('TUpPolicyIndCode')==null?'':paramsMap.get('TUpPolicyIndCode');
        //String CPlusPolicyInd=paramsMap.get('CPlusPolicyInd')==null?'':paramsMap.get('CPlusPolicyInd');
        //String CPlusPolicyIndCode=paramsMap.get('CPlusPolicyIndCode')==null?'':paramsMap.get('CPlusPolicyIndCode');
        String LHBPolicyInd=paramsMap.get('LHBPolicyInd')==null?'':paramsMap.get('LHBPolicyInd');
        String LHBPolicyIndCode=paramsMap.get('LHBPolicyIndCode')==null?'':paramsMap.get('LHBPolicyIndCode');
        String LHBPackagePolicyInd=paramsMap.get('LHBPackagePolicyInd')==null?'':paramsMap.get('LHBPackagePolicyInd');
        String LHBPackagePolicyIndCode=paramsMap.get('LHBPackagePolicyIndCode')==null?'':paramsMap.get('LHBPackagePolicyIndCode');
        String LHBEligibleForGOPPolicyInd=paramsMap.get('LHBEligibleForGOPPolicyInd')==null?'':paramsMap.get('LHBEligibleForGOPPolicyInd');
        String LHBEligibleForGOPPolicyIndCode=paramsMap.get('LHBEligibleForGOPPolicyIndCode')==null?'':paramsMap.get('LHBEligibleForGOPPolicyIndCode');
        String GAOPPolicyInd=paramsMap.get('GAOPPolicyInd')==null?'':paramsMap.get('GAOPPolicyInd');
        String GAOPPolicyIndCode=paramsMap.get('GAOPPolicyIndCode')==null?'':paramsMap.get('GAOPPolicyIndCode');
        String memberName=paramsMap.get('MemberName')==null?'':paramsMap.get('MemberName');
        String orgCode=paramsMap.get('OrgCode')==null?'':paramsMap.get('OrgCode');
        String userLoginName=Userinfo.getUserName();        
        String userLoginNameParam=paramsMap.get('UserLoginName')==null?'':paramsMap.get('UserLoginName');
        if(String.isNotBlank(userLoginNameParam)){
            userLoginName=userLoginNameParam;
        }                             
         
        String roleIDParam=paramsMap.get('RoleID')==null?'':paramsMap.get('RoleID');
        if(String.isNotBlank(roleIDParam)){
            this.roleID=roleIDParam;
        }
        
        String insuredMemberFullName=paramsMap.get('InsuredMemberFullName')==null?'':paramsMap.get('InsuredMemberFullName');
        String certNo=paramsMap.get('CertificateNo')==null?'':paramsMap.get('CertificateNo');
        String branchCode=paramsMap.get('BranchCode')==null?'':paramsMap.get('BranchCode');
        String coverageNumber=paramsMap.get('coverageNumber')==null?'':paramsMap.get('coverageNumber');              //Added by Nicole in Phases2 for GetPolicyListBasicByCriteria
        String memberDOB=paramsMap.get('memberDOB')==null?'':paramsMap.get('memberDOB');              //Added by Nicole in Phases2 for GetPolicyPersonListBasicByCriteria
        String policyCreationDate=paramsMap.get('PolicyCreationDate')==null?'':paramsMap.get('PolicyCreationDate');
        String policyCreationTime=paramsMap.get('PolicyCreationTime')==null?'':paramsMap.get('PolicyCreationTime');
        String sellerId=paramsMap.get('SellerId')==null?'':paramsMap.get('SellerId');
        String FamilyRecInd=paramsMap.get('FamilyRecInd')==null?'':paramsMap.get('FamilyRecInd');
        //chris client portal cp-155 only search employee
        String familyEmployee = paramsMap.get('familyEmployee')==null?'':paramsMap.get('familyEmployee');    
        String AccountNumber=paramsMap.get('AccountNumber')==null?'':paramsMap.get('AccountNumber');
        String SortOrder=paramsMap.get('SortOrder')==null?'A':paramsMap.get('SortOrder');
        String relationRole=paramsMap.get('RelationRole')==null?'':paramsMap.get('RelationRole');
        String relationRoleCode=paramsMap.get('RelationRoleCode')==null?'':paramsMap.get('RelationRoleCode');
        String ssnNumber=paramsMap.get('ssnNumber')==null?'':paramsMap.get('ssnNumber');
        String policyHolderName=paramsMap.get('PolicyHolderName')==null?'':paramsMap.get('PolicyHolderName');    //getPolicyPersonListBasicbyCriteria

        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --START
        String certNo4Family=paramsMap.get('CertificateNo4Family')==null?'':paramsMap.get('CertificateNo4Family');
        String familyInd=paramsMap.get('FamilyInd')==null?'':paramsMap.get('FamilyInd');
        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --END
        //Add by jack CS Member Level begin
        String submissionDateTimeFrom=paramsMap.get('SubmissionDateTimeFrom')==null?'':paramsMap.get('SubmissionDateTimeFrom');
        String submissionDateTimeTo=paramsMap.get('SubmissionDateTimeTo')==null?'':paramsMap.get('SubmissionDateTimeTo');
        //Add by jack CS Member Level end
        String showAllPI=paramsMap.get('ShowAllPI'); //SPS-323
        //add by chris group member StaffId
        String staffId = paramsMap.get('StaffId') == null ? '' : paramsMap.get('StaffId');
        Boolean isTDUser=paramsMap.get('isTDUser')!=null&&paramsMap.get('isTDUser').equalsIgnoreCase('TRUE')?True:False; //Nicole_SMT_20210425
        //added by chris 2021-08-12(Client Portal): search shortfall by HOClaimReferenceID
        String hOClaimReferenceID = paramsMap.get('hOClaimReferenceID') == null ? '' : paramsMap.get('hOClaimReferenceID');
        //system.debug('FamilyRecInd >>>>>>'+FamilyRecInd );
        //system.debug('relationRole >>>>>>'+relationRole );
        //system.debug('policyType   >>>>>>' +policyType  );
        String ssnNumberCriteria='';
        if(String.IsNotBlank(ssnNumber)){
            ssnNumberCriteria='<Criteria>'
                                    +'    <ObjectType tc="6">Party</ObjectType>'
                                    +'    <PropertyName>GovtID</PropertyName>'
                                    +'    <PropertyValue>'+ssnNumber+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        
        String SortOrderCriteria='';
        if(String.isNotBlank(SortOrder)){
            if(SortOrder.equalsIgnoreCase('a')){
                SortOrder='A';
            }
            if(SortOrder.equalsIgnoreCase('d')){
                SortOrder='D';
            }
            SortOrderCriteria='<SortOrder>'+SortOrder+'</SortOrder>';
        }
                
        String policyCreationDateCriteria='';
        if(String.isNotBlank(policyCreationDate)){
            policyCreationDateCriteria='<Criteria>'
                                    +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                    +'    <PropertyName>PolCreationDate</PropertyName>'
                                    +'    <PropertyValue>'+policyCreationDate+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        //add Bob 20201116 Additional option to search their client case by renewing month
        String policyRenewalYearCriteria='';
        //System.debug('policyRenewalYear:'+policyRenewalYear);
        if(String.isNotBlank(policyRenewalYear)){
            policyRenewalYearCriteria='<Criteria>'
                   +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                   +'    <PropertyName>PolicyRenewalYear</PropertyName>'
                   +'    <PropertyValue>'+policyRenewalYear+ '</PropertyValue>'
                   +'    <Operation tc="1">Equal</Operation>'
                   +'</Criteria>';
        }
        String policyRenewalMonthCriteria='';
        //System.debug('policyRenewalMonth:'+policyRenewalMonth);
        if(String.isNotBlank(policyRenewalMonth)){
            policyRenewalMonthCriteria='<Criteria>'
                   +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                   +'    <PropertyName>PolicyRenewalMonth</PropertyName>'
                   +'    <PropertyValue>'+policyRenewalMonth+ '</PropertyValue>'
                   +'    <Operation tc="1">Equal</Operation>'
                   +'</Criteria>';
        }
        //end Bob 20201116
        String policyCreationTimeCriteria='';
        if(String.isNotBlank(policyCreationTime)){
            policyCreationTimeCriteria='<Criteria>'
                                    +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                    +'    <PropertyName>PolCreationDate</PropertyName>'
                                    +'    <PropertyValue>'+policyCreationTime+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        String sellerIdCriteria='';
        if(String.isNotBlank(sellerId)){
            sellerIdCriteria='<Criteria>'
                                    +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                    +'    <PropertyName>SellerId</PropertyName>'
                                    +'    <PropertyValue>'+sellerId+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        String FamilyRecIndCriteria='';
        if(String.isNotBlank(familyRecordMap.get(FamilyRecInd)) && policyType==POLICY_TYPE_GROUP){
            FamilyRecIndCriteria='<Criteria>'
                                    +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                    +'    <PropertyName>FamilyRecInd</PropertyName>'
                                    +'    <PropertyValue>'+familyRecordMap.get(FamilyRecInd)+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        //chris client employee member 
        //Kirk-CP444-remove FamilyRecInd-20211018 //Kirk-20211103-CP549
        String familyRecIndEmployeeCriteria='';
        if(String.isNotBlank(familyRecordMap.get(familyEmployee)) && policyType==POLICY_TYPE_GROUP){
            familyRecIndEmployeeCriteria='<Criteria>'
                                    +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                    +'    <PropertyName>FamilyRecInd</PropertyName>'
                                    +'    <PropertyValue tc="4">'+familyRecordMap.get(familyEmployee)+ '</PropertyValue>'
                                    +'    <Operation tc="1">equal to</Operation>'
                                    +'</Criteria>';
        }

        //system.debug('familyRecordMap.get(FamilyRecInd)======>>>>>>>>'+familyRecordMap.get(FamilyRecInd));
        //system.debug('FamilyRecIndCriteria   >>>>>>>>>>>'+FamilyRecIndCriteria );
        String AccountNumberCriteria='';
        if(String.isNotBlank(AccountNumber)){
            AccountNumberCriteria='<Criteria>'
                                    +'    <ObjectType tc="221">Banking</ObjectType>'
                                    +'    <PropertyName>AccountNumber</PropertyName>'
                                    +'    <PropertyValue>'+AccountNumber+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        
        String payerCriteria='';
        if(String.isNotBlank(AccountNumberCriteria)){
            payerCriteria='<CriteriaExpression>'
                         +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                         +     AccountNumberCriteria
                         +'    <Criteria>'
                         +'        <ObjectType tc="8">Relation</ObjectType>'
                         +'        <PropertyName>RelationRoleCode</PropertyName>'
                         +'        <PropertyValue tc="8">Payer</PropertyValue>'
                         +'        <Operation tc="1">Equal</Operation>'
                         +'    </Criteria>'
                         +'</CriteriaExpression>';
        }
        
        String relationRoleCriteria='';
        if(String.IsNotBlank(relationRole) && String.IsNotBlank(relationRoleCode)){
             relationRoleCriteria=' <Criteria> '
                                   +'     <ObjectType tc="8">Relation</ObjectType> '
                                   +'     <PropertyName>RelationRoleCode</PropertyName> '
                                   +'     <PropertyValue tc="'+relationRoleCode+'">'+relationRole+'</PropertyValue>'
                                   +'     <Operation tc="1">equal to</Operation> '
                                   +' </Criteria> ';
        }
        
        String fullNameCriteria='';
        if(String.IsNotBlank(memberName)){
             fullNameCriteria=' <Criteria> '
                                   +'     <ObjectType tc="6">Party</ObjectType> '
                                   +'     <PropertyName>FullName</PropertyName> '
                                   +'     <PropertyValue tc="'+relationRoleCode+'">'+memberName+'</PropertyValue>'
                                   +'     <Operation tc="9">Wildcard match</Operation> '
                                   +' </Criteria> ';
        }
        
        String policyNumberCriteria='';
        if(String.isNotBlank(policyNumber)){
            policyNumberCriteria='<Criteria>'
                                +'    <ObjectType tc="18">Policy</ObjectType>'
                                +'    <PropertyName>PolNumber</PropertyName>'
                                +'    <PropertyValue>'+policyNumber +'</PropertyValue>'
                                +'    <Operation tc="1">Equal</Operation>'
                                +'</Criteria>';
        }

        //added by Connor(Client Portal)
        String companyCodeCriteria = CignaUtil.buildCriteriaNode('6','Party','Company Code',companyCode,'1','Equal');
        //added by Connor(Client Portal)
        String deptCodeCriteria = CignaUtil.buildCriteriaNode('252','OLifEExtension','Department code',deptCode,'1','Equal');
        //Rancho_CP782_20220206 - as criteria node is diff with above, add a new dept code
        String memberDeptCriteria = CignaUtil.buildCriteriaNode('6','Party','DepartmentCode',memberDeptCode,'1','equal to');

        //added by Connor(Client Portal)
        String policyYearCriteria = '';
        if(String.isNotBlank(policyYear)){
            policyYearCriteria = '<Criteria>'
            + '    <ObjectType tc="252">OLifEExtension</ObjectType>'
            + '    <PropertyName>Policy year</PropertyName>'
            + '    <PropertyValue>' + policyYear  + '</PropertyValue>'
            + '    <Operation tc="1">Equal</Operation>'
            + '</Criteria>';
        }

        //added by Connor(Client Portal)
        String shorfallDateCriteria = CignaUtil.buildCriteriaNode('105','Claim','ShortfallDate',shorfallDate,'1','Equal');

         //added by Connor(Client Portal)
        String employeeIdCriteria = '';
        if(String.isNotBlank(employeeId)){
            employeeIdCriteria = '<Criteria>'
            + '    <ObjectType tc="252">OLifEExtension</ObjectType>'
            + '    <PropertyName>employee ID</PropertyName>'
            + '    <PropertyValue>' + employeeId  + '</PropertyValue>'
            + '    <Operation tc="1">Equal</Operation>'
            + '</Criteria>';
        }

        //added by chris 2021-08-12(Client Portal): search shortfall by HOClaimReferenceID
        String hOClaimReferenceIDCriteria = CignaUtil.buildCriteriaNode('105','Claim','HOClaimReferenceID',hOClaimReferenceID,'1','Equal');

        //added by Connor(Client Portal)
        String shortfallStatusCriteria = CignaUtil.buildCriteriaNode('105','Claim','ShortfallStatus',shortfallStatus,'1','Equal');

        //added by Connor
        String claimNoShortfallCriteria = CignaUtil.buildCriteriaNode('115','Person','Claim Number',claimNoShortfall,'3','Equal');

        //added by Connor(Client Portal)
        String endorsementNoCriteria = CignaUtil.buildCriteriaNode('6','Party','Endorsement No',endorsementNo,'1','Equal');

        String holderGovtIDCriteria='';
        if(String.isNotBlank(holderGovtID)){
            holderGovtIDCriteria='<Criteria>'
                                +'    <ObjectType tc="6">Party</ObjectType>'
                                +'    <PropertyName>GovtID</PropertyName>'
                                +'    <PropertyValue>'+holderGovtID+'</PropertyValue>'
                                +'    <Operation tc="1">Equal</Operation>'
                                +'</Criteria>';
        }
        
        String holderFullNameCriteria='';
        holderFullName=holderFullName.unescapeXml(); //IBM KOU PPS-20 20180716
        List<String> nameList=holderFullName.split(';');
        // IBM KOU PPS-20 20180716 Start
        List<String> tempNameList=new List<String>();
        for(String name:nameList){
            tempNameList.add(name.escapeXml());
        }
        nameList=tempNameList;
        // IBM KOU PPS-20 20180716 End
        //system.debug('holderFullName:'+holderFullName);
            if(nameList.size()>=1){
                if(nameList.size()==1){
                    String hname=nameList[0];
                    holderFullNameCriteria +='<Criteria>'
                                          +'    <ObjectType tc="6">Party</ObjectType>'
                                          +'    <PropertyName>FullName</PropertyName>'
                                          +'    <PropertyValue>'+hname+'</PropertyValue>'
                                          +'    <Operation tc="9">Wildcard match</Operation>'
                                          +'</Criteria>';
                }else{
                    holderFullNameCriteria='<CriteriaExpression>'
                                        +'    <CriteriaOperator tc="1">Or</CriteriaOperator>';
                    for(String hname:nameList){
                        holderFullNameCriteria +='<Criteria>'
                                              +'    <ObjectType tc="6">Party</ObjectType>'
                                              +'    <PropertyName>FullName</PropertyName>'
                                              +'    <PropertyValue>'+hname+'</PropertyValue>'
                                              +'    <Operation tc="9">Wildcard match</Operation>'
                                              +'</Criteria>';
                    }
                    holderFullNameCriteria +='</CriteriaExpression>';
                }
            }
        /*
        if(String.isNotBlank(holderFullName)){
            holderFullNameCriteria='<Criteria>'
                                  +'    <ObjectType tc="6">Party</ObjectType>'
                                  +'    <PropertyName>FullName</PropertyName>'
                                  +'    <PropertyValue>'+holderFullName+'</PropertyValue>'
                                  +'    <Operation tc="9">Wildcard match</Operation>'
                                  +'</Criteria>';
        }
        */
        
        String holderDialNumberCriteria='';
        if(String.isNotBlank(holderDialNumber) && policyType==POLICY_TYPE_INDIVIDUAL){ // For Group policy type,cannot search for Holder Phone Number.
            holderDialNumberCriteria='<Criteria>'
                                    +'    <ObjectType tc="3">Phone</ObjectType>'
                                    +'    <PropertyName>DialNumber</PropertyName>'
                                    +'    <PropertyValue>'+holderDialNumber+'</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        
        String holderDOBCriteria='';
        if(String.isNotBlank(holderDOB) && policyType==POLICY_TYPE_INDIVIDUAL){ // For Group policy type,cannot search for Holder DOB.
            holderDOBCriteria='<Criteria>'
                                    +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                    +'    <PropertyName>HolderBirthDate</PropertyName>'
                                    +'    <PropertyValue>'+holderDOB+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'

                                    +'</Criteria>';
        }
        
        String insuredGovtIDCriteria='';
        if(String.isNotBlank(insuredGovtID)){
            insuredGovtIDCriteria='<Criteria>'
                                 +'    <ObjectType tc="6">Party</ObjectType>'
                                 +'    <PropertyName>GovtID</PropertyName>'
                                 +'    <PropertyValue>'+insuredGovtID+'</PropertyValue>'
                                 +'    <Operation tc="1">Equal</Operation>'
                                 +'</Criteria>';
        }
        
        String insuredFullNameCriteria='';
        if(String.isNotBlank(insuredFullName)){
            insuredFullNameCriteria='<Criteria>'
                                   +'    <ObjectType tc="6">Party</ObjectType>'
                                   +'    <PropertyName>FullName</PropertyName>'
                                   +'    <PropertyValue>'+insuredFullName+'</PropertyValue>'
                                   +'    <Operation tc="9">Wildcard match</Operation>'
                                   +'</Criteria>';
        }
        
        //Added by Nicole in Phase2
        String insuredDOBCriteria='';
        if(String.isNotBlank(insuredDOB) && policyType==POLICY_TYPE_INDIVIDUAL){ // For Group policy type,cannot search for Holder Phone Number.
            insuredDOBCriteria='<Criteria>'
                                    +'    <ObjectType tc="3">Phone</ObjectType>'
                                    +'    <PropertyName>DialNumber</PropertyName>'
                                    +'    <PropertyValue>'+insuredDOB+ '</PropertyValue>'
                                    +'    <Operation tc="1">Equal</Operation>'
                                    +'</Criteria>';
        }
        
        String ownerCriteria='';
        if(String.isNotBlank(holderGovtIDCriteria) || String.isNotBlank(holderFullNameCriteria) || String.isNotBlank(holderDialNumberCriteria) || String.isNotBlank(FamilyRecIndCriteria)){
            ownerCriteria='<CriteriaExpression>'
                         +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                         +     holderGovtIDCriteria
                         +     holderFullNameCriteria
                         +     FamilyRecIndCriteria
                         +     holderDialNumberCriteria
                         +'    <Criteria>'
                         +'        <ObjectType tc="8">Relation</ObjectType>'
                         +'        <PropertyName>RelationRoleCode</PropertyName>'
                         +'        <PropertyValue tc="8">Owner</PropertyValue>'
                         +'        <Operation tc="1">Equal</Operation>'
                         +'    </Criteria>'
                         +'</CriteriaExpression>';
        }
        
        String insuredCriteria='';
        
                      
        if(String.isNotBlank(insuredGovtIDCriteria) || String.isNotBlank(insuredFullNameCriteria)){
            insuredCriteria='<CriteriaExpression>'
                         +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                         +     insuredGovtIDCriteria
                         +     insuredFullNameCriteria
                         +'    <Criteria>'
                         +'        <ObjectType tc="8">Relation</ObjectType>'
                         +'        <PropertyName>RelationRoleCode</PropertyName>'
                         +'        <PropertyValue tc="32">Insured</PropertyValue>'
                         +'        <Operation tc="1">Equal</Operation>'
                         +'    </Criteria>'
                         +'</CriteriaExpression>';
        }
        
        String policyStatusCriteria='';
        if(String.isNotBlank(policyStatus)){
            List<String> statusList=policyStatus.split(';');
            if(statusList.size()>=1){
                if(statusList.size()==1){
                    String pStatus=statusList[0];
                    policyStatusCriteria +='<Criteria>'
                                         +'    <ObjectType tc="18">Policy</ObjectType>'
                                         +'    <PropertyName>PolicyStatus</PropertyName>'
                                         +'    <PropertyValue tc="'+statusCodeMap.get(pStatus)+'">'+pStatus+'</PropertyValue>'
                                         +'    <Operation tc="1">Equal</Operation>'
                                         +'</Criteria>';
                }else{
                    policyStatusCriteria='<CriteriaExpression>'
                                        +'    <CriteriaOperator tc="1">Or</CriteriaOperator>';
                    for(String pStatus:statusList){
                        policyStatusCriteria +='<Criteria>'
                                             +'    <ObjectType tc="18">Policy</ObjectType>'
                                             +'    <PropertyName>PolicyStatus</PropertyName>'
                                             +'    <PropertyValue tc="'+statusCodeMap.get(pStatus)+'">'+pStatus+'</PropertyValue>'
                                             +'    <Operation tc="1">Equal</Operation>'
                                             +'</Criteria>';
                    }
                    policyStatusCriteria +='</CriteriaExpression>';
                }
            }
        }
        
        String brokerAgentCodeCriteria='';
        if(String.isNotBlank(brokerAgentCode)){
            if(brokerAgentCode==PolicyCalloutHelper.NO_BROKER_AGENT){
                // search policies without broker agent
                brokerAgentCodeCriteria='<Criteria>'
                                     +'    <ObjectType tc="11">OLI_CARRIERAPPOINTMENT</ObjectType>'
                                     +'    <PropertyName>CompanyProducerID</PropertyName>'
                                     +'    <PropertyValue></PropertyValue>'
                                     +'    <Operation tc="1">Equal</Operation>'
                                     +'</Criteria>';
            }
            //cx added Mar26 2018,supporting multiple broker agent search
           else if(brokerAgentCode.contains(';')){
                string [] tmp=brokerAgentCode.split(';');
                brokerAgentCodeCriteria='<CriteriaExpression>'
                                    +'    <CriteriaOperator tc="1">Or</CriteriaOperator>';
                for(string str:tmp){
                   brokerAgentCodeCriteria +='<Criteria>'
                                     +'    <ObjectType tc="11">CarrierAppointment</ObjectType>'
                                     +'    <PropertyName>CompanyProducerID</PropertyName>'
                                     +'    <PropertyValue>'+str+'</PropertyValue>'
                                     +'    <Operation tc="1">Equal</Operation>'
                                     +'</Criteria>';

                }
                brokerAgentCodeCriteria +='</CriteriaExpression>';
            }else{//cx added end
                // search policies with the specify agent
                brokerAgentCodeCriteria='<Criteria>'
                                     +'    <ObjectType tc="11">CarrierAppointment</ObjectType>'
                                     +'    <PropertyName>CompanyProducerID</PropertyName>'
                                     +'    <PropertyValue>'+brokerAgentCode+'</PropertyValue>'
                                     +'    <Operation tc="1">Equal</Operation>'
                                     +'</Criteria>';
            }
        }
        
        String IPMICriteria='';
        if(String.isNotBlank(IPMIPolicyInd)){
            IPMICriteria='<Criteria>'
                         +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
                         +'    <PropertyName>IPMIPolicyInd</PropertyName>'
                         +'    <PropertyValue tc="'+IPMIPolicyIndCode+'">'+IPMIPolicyInd+'</PropertyValue>'
                         +'    <Operation tc="1">Equal</Operation>'
                         +'</Criteria>';
        }
        
        String TUpPolicyCriteria='';
        if(String.isNotBlank(TUpPolicyInd)){
            TUpPolicyCriteria='<Criteria>'
                         +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
                         +'    <PropertyName>TUpPolicyInd</PropertyName>'
                         +'    <PropertyValue tc="'+TUpPolicyIndCode+'">'+TUpPolicyInd+'</PropertyValue>'
                         +'    <Operation tc="1">Equal</Operation>'
                         +'</Criteria>';
        }
        //String CPlusPolicyIndCriteria='';
        //if(String.isNotBlank(CPlusPolicyInd)){
        //    CPlusPolicyIndCriteria='<Criteria>'
        //                 +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
        //                 +'    <PropertyName>CPlusPolicyInd</PropertyName>'
        //                 +'    <PropertyValue tc="'+CPlusPolicyIndCode+'">'+CPlusPolicyInd+'</PropertyValue>'
        //                 +'    <Operation tc="1">Equal</Operation>'
        //                 +'</Criteria>';
        //}
        
        String LHBPolicyIndCriteria='';
        if(String.isNotBlank(LHBPolicyInd)){
            LHBPolicyIndCriteria='<Criteria>'
                         +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
                         +'    <PropertyName>LHBPolicyInd</PropertyName>'
                         +'    <PropertyValue tc="'+LHBPolicyIndCode+'">'+LHBPolicyInd+'</PropertyValue>'
                         +'    <Operation tc="1">Equal</Operation>'
                         +'</Criteria>';
        }
        
        String LHBPackagePolicyIndCriteria='';
        if(String.isNotBlank(LHBPackagePolicyInd)){
            LHBPackagePolicyIndCriteria='<Criteria>'
                         +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
                         +'    <PropertyName>LHBPackagePolicyInd</PropertyName>'
                         +'    <PropertyValue tc="'+LHBPackagePolicyIndCode+'">'+LHBPackagePolicyInd+'</PropertyValue>'
                         +'    <Operation tc="1">Equal</Operation>'
                         +'</Criteria>';
        }
        
        String LHBEligibleForGOPPolicyIndCriteria='';
        if(String.isNotBlank(LHBEligibleForGOPPolicyInd)){
            LHBEligibleForGOPPolicyIndCriteria='<Criteria>'
                         +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
                         +'    <PropertyName>LHBEligibleForGOPPolicyInd</PropertyName>'
                         +'    <PropertyValue tc="'+LHBEligibleForGOPPolicyIndCode+'">'+LHBEligibleForGOPPolicyInd+'</PropertyValue>'
                         +'    <Operation tc="1">Equal</Operation>'
                         +'</Criteria>';
        }
        
        String GAOPPolicyIndCriteria='';
        if(String.isNotBlank(GAOPPolicyInd)){
            GAOPPolicyIndCriteria='<Criteria>'
                         +'    <ObjectType tc="252">OLifeExtension</ObjectType>'
                         +'    <PropertyName>GAOPPolicyInd</PropertyName>'
                         +'    <PropertyValue tc="'+GAOPPolicyIndCode+'">'+GAOPPolicyInd+'</PropertyValue>'
                         +'    <Operation tc="1">Equal</Operation>'
                         +'</Criteria>';
        }
        
        String orgCodeCriteria='';
        if(String.isNotBlank(orgCode)){
            orgCodeCriteria='<Criteria>'
                           +'    <ObjectType tc="116">Organization</ObjectType>'
                           +'    <PropertyName>OrgCode</PropertyName>'
                           +'    <PropertyValue>'+orgCode+'</PropertyValue>'
                           +'    <Operation tc="1">Equal</Operation>'
                           +'</Criteria>';
        }

        String insuredMemberFullNameCriteria='';
        if(String.isNotBlank(insuredMemberFullName)){
            insuredMemberFullNameCriteria='<Criteria>'
                                +'    <ObjectType tc="6">Party</ObjectType>'
                                +'    <PropertyName>FullName</PropertyName>'
                                +'    <PropertyValue>'+insuredMemberFullName +'</PropertyValue>'
                                +'    <Operation tc="9">Wildcard match</Operation>'
                                +'</Criteria>';
        }

        //jack add for cs member level
        String certNoWildCriteria='';
        if(String.isNotBlank(certNo)){
            certNoWildCriteria='<Criteria>'
                                +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                +'    <PropertyName>CertificateNo</PropertyName>'
                                +'    <PropertyValue>'+certNo +'</PropertyValue>'
                                +'    <Operation tc="9">WILDCARDMATCH</Operation>'
                                +'</Criteria>';
        }
        //jack add for cs member level

        String certNoCriteria='';
        if(String.isNotBlank(certNo)){
            certNoCriteria='<Criteria>'
                                +'    <ObjectType tc="252">OLIFEEXTENSION</ObjectType>'
                                +'    <PropertyName>CertificateNo</PropertyName>'
                                +'    <PropertyValue>'+certNo +'</PropertyValue>'
                                +'    <Operation tc="1">Equal</Operation>'
                                +'</Criteria>';
        }

        String branchCodeCriteria='';
        if(String.isNotBlank(branchCode)){
            branchCodeCriteria='<Criteria>'
                                +'    <ObjectType tc="252">OLIFEEXTENSION</ObjectType>'
                                +'    <PropertyName>BranchCode</PropertyName>'
                                +'    <PropertyValue>'+branchCode +'</PropertyValue>'
                                +'    <Operation tc="1">equal to</Operation>'
                                +'</Criteria>';
        }
        
        
        String claimNumberCriteria='';
        if(String.isNotBlank(claimNumber)){
            claimNumberCriteria='<Criteria>'
                                +'    <ObjectType tc="252">Claim</ObjectType>'
                                +'    <PropertyName>HOClaimReferenceID</PropertyName>'
                                +'    <PropertyValue>'+claimNumber+'</PropertyValue>'
                                +'    <Operation tc="9">claimNumber</Operation>'
                                +'</Criteria>';
        }
        String claimCriteria='';
        if(String.isNotBlank(claimNumberCriteria)){
            claimCriteria='<CriteriaExpression>'
                         +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                         +     claimNumberCriteria
                         +'</CriteriaExpression>';
        }
        
        //system.debug('###test memberDOB: '+memberDOB);
        String memberDOBCriteria='';
        if(String.isNotBlank(memberDOB)){
            memberDOBCriteria='<Criteria>'
                                +'    <ObjectType tc="115">Person</ObjectType>'
                                +'    <PropertyName>BirthDate</PropertyName>'
                                +'    <PropertyValue>'+memberDOB+'</PropertyValue>'
                                +'    <Operation tc="1">Equal</Operation>'
                                +'</Criteria>';
        }
               
        String policyHolderNameCriteria='';
        if(String.isNotBlank(policyHolderName)){
            policyHolderNameCriteria='<Criteria>'
                                +'    <ObjectType tc="115">Person</ObjectType>'
                                +'    <PropertyName>PolicyHolderName</PropertyName>'
                                +'    <PropertyValue>'+policyHolderName+'</PropertyValue>'
                                +'    <Operation tc="1">Equal</Operation>'
                                +'</Criteria>';
        }
        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --START
        String certNo4FamilyCriteria='';
        if(String.isNotBlank(certNo4Family)){
            certNo4FamilyCriteria='<Criteria>'
                                +'    <ObjectType tc="252">OLIFEEXTENSION</ObjectType>'
                                +'    <PropertyName>CertificateNo</PropertyName>'
                                +'    <PropertyValue>'+certNo4Family +'</PropertyValue>'
                                +'    <Operation tc="9">Wildcard match</Operation>'
                                +'</Criteria>';
        }

        String familyIndCriteria='';
        if(String.isNotBlank(familyInd)){
            familyIndCriteria='<Criteria>'
                                +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                +'    <PropertyName>FamilyRecInd</PropertyName>'
                                +'    <PropertyValue>'+familyInd +'</PropertyValue>'
                                +'    <Operation tc="1">Equal</Operation>'
                                +'</Criteria>';
        }
        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --START
        
        //Add by jack CS Member Level begin
        String submissionDateTimeFromCriteria='';
        if(String.isNotBlank(submissionDateTimeFrom)){
            submissionDateTimeFromCriteria='<Criteria>'
                                           +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                           +'    <PropertyName>Date Time From</PropertyName>'
                                           +'    <PropertyValue>'+submissionDateTimeFrom+'</PropertyValue>'
                                           +'    <Operation tc="6">Greater than or equal to</Operation>'
                                           +'</Criteria>';
        }
        
        String submissionDateTimeToCriteria='';
        if(String.isNotBlank(submissionDateTimeTo)){
            submissionDateTimeToCriteria='<Criteria>'
                                           +'    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                           +'    <PropertyName>Date Time To</PropertyName>'
                                           +'    <PropertyValue>'+submissionDateTimeTo+'</PropertyValue>'
                                           +'    <Operation tc="5">Less than or equal to</Operation>'
                                           +'</Criteria>';
        }
        //Add by jack CS Member Level end

        //SPS-323
        String showAllPINode='';
        if(String.isNotBlank(showAllPI)){
            showALlPINode='<ShowAllPI>'+showAllPI+'</ShowAllPI>';
        }
        //SPS-323

        //Client Portal - add new memberStatus Search Criteria
        String memberStatusCriteria='';
        if(String.isNotBlank(memberStatus)){
            memberStatusCriteria = '<Criteria>'
                                + '    <ObjectType tc="6">Party</ObjectType>'
                                + '    <PropertyName>MemberStatus</PropertyName>'
                                + '    <PropertyValue>' + memberStatus + '</PropertyValue>'
                                + '    <Operation tc="1">equal to</Operation>'
                                + '</Criteria>';
        }

        System.debug('GetPolicyListBasicByCriteria roleID: '+this.roleID);

        //chris client portal member search StaffID
        String staffIdforSfCriteria = CignaUtil.buildCriteriaNode('6','Party','StaffID',staffId,'1','Equal');
        String staffIdCriteria='';
        if(String.isNotBlank(staffId)){
            staffIdCriteria = '<Criteria>'
                                + '    <ObjectType tc="6">Party</ObjectType>'
                                + '    <PropertyName>StaffID</PropertyName>'
                                + '    <PropertyValue>' + staffId + '</PropertyValue>'
                                + '    <Operation tc="1">equal to</Operation>'
                                + '</Criteria>';
        }

        if(this.functionName==PolicyCalloutHelper.GetPolicyListBasicByCriteria){
            criterias +='<CriteriaExpression>'
                       +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                       +'    <Criteria>'
                       +'        <ObjectType tc="252">OLifEExtension</ObjectType>'
                       +'        <PropertyName>PolicyType</PropertyName>'
                       //Nicole_SMT_20210425
                       //+'        <PropertyValue>'+policyType+'</PropertyValue>'
                       +'        <PropertyValue>'+(isTDUser?CignaUtil.cusFuncTD+'+':'')+policyType+'</PropertyValue>'
                       +'        <Operation tc="1">Equal</Operation>'
                       +'    </Criteria>'
                       +'    <Criteria>'
                       +'        <ObjectType tc="1043">SecurityCredential</ObjectType>'
                       +'        <PropertyName>UserLoginName</PropertyName>'
                       +'        <PropertyValue>'+userLoginName+'</PropertyValue>'
                       +'        <Operation tc="1">Equal</Operation>'
                       +'    </Criteria>'
                       +     policyNumberCriteria
                       +     policyStatusCriteria
                       +     policyCreationDateCriteria
                       +     policyCreationTimeCriteria
                       +     sellerIdCriteria
                       +     brokerAgentCodeCriteria
                        // add Bob 20201116 Additional option to search their client case by renewing month
                       +     policyRenewalYearCriteria
                       +     policyRenewalMonthCriteria
                        // end Bob 20201116 Additional option to search their client case by renewing month
                       +     IPMICriteria
                       +     TUpPolicyCriteria
                        //+      CPlusPolicyIndCriteria
                       +     LHBPolicyIndCriteria
                       +     LHBPackagePolicyIndCriteria
                       +     LHBEligibleForGOPPolicyIndCriteria
                       +     GAOPPolicyIndCriteria
                       +     orgCodeCriteria
                       +     policyNumberCriteria
                       +     ownerCriteria
                       +     insuredCriteria
                       +     holderDOBCriteria
                       +     payerCriteria
                       +     claimCriteria
                       +'</CriteriaExpression>'
                       +'<OLifE>'
                       +     this.currentLanguageNode
                       +'    <OLifEExtension VendorCode="525">'
                       +'        <RoleId>'+this.roleID+'</RoleId>'
                       +     SortOrderCriteria
                       +'    </OLifEExtension>'
                       +'</OLifE>';
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria&&!downloadSign){//Kirk-20211103-CP549-Add download Excel sign
            criterias  +='<CriteriaExpression>'
                       +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                       +     policyNumberCriteria
                       +     insuredMemberFullNameCriteria
                       +     relationRoleCriteria
                       +     ssnNumberCriteria
                       +     fullNameCriteria
                       +     certNoCriteria
                       +     holderGovtIDCriteria
                       +     branchCodeCriteria
                       +     familyRecIndCriteria
                       //Kirk-CP444-remove FamilyRecInd-20211018 //Kirk-20211103-CP549
                       +     familyRecIndEmployeeCriteria
                       +     memberDOBCriteria
                       +     policyHolderNameCriteria
                       //  Added by chrisLi due to client portal member search
                       +     staffIdCriteria
                        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --START
                       +     certNo4FamilyCriteria
                       +     familyIndCriteria
                       +      memberStatusCriteria
                        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --END
                       // Rancho_CP782_20220206 - add dept as search criteria
                       +     memberDeptCriteria
                       +'    <Criteria> '
                       +'        <ObjectType tc="8">Relation</ObjectType> '
                       +'        <PropertyName>RelationRoleCode</PropertyName> '
                       +'        <PropertyValue tc="32">Insured</PropertyValue>'
                       +'        <Operation tc="1">equal to</Operation> '
                       +'    </Criteria> '
                       +'</CriteriaExpression>'
                       +'<OLifE>'
                       +     this.currentLanguageNode
                       +'    <OLifEExtension VendorCode="525">'
                       +'        <RoleId>'+this.roleID+'</RoleId>'
                       +          showAllPINode //SPS-323
                       +'    </OLifEExtension>'
                       +'</OLifE>';

        }else if(this.functionName==PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria&&downloadSign){//Kirk-20211103-CP549-Add download Excel sign
            criterias  +='<CriteriaExpression>'
                       +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                       +     policyNumberCriteria
                       +     insuredMemberFullNameCriteria
                       +     relationRoleCriteria
                       +     ssnNumberCriteria
                       +     fullNameCriteria
                       +     certNoCriteria
                       +     holderGovtIDCriteria
                       +     branchCodeCriteria
                       +     familyRecIndCriteria
                       //Kirk-CP444-remove FamilyRecInd-20211018
                       //+     familyRecIndEmployeeCriteria
                       +     memberDOBCriteria
                       +     policyHolderNameCriteria
                       //  Added by chrisLi due to client portal member search
                       +     staffIdCriteria
                        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --START
                       +     certNo4FamilyCriteria
                       +     familyIndCriteria
                       +      memberStatusCriteria
                       // Rancho_CP782_20220206 - add dept as search criteria
                       +     memberDeptCriteria
                        // Added by IBM(Roy) due to PEI-143/PORTABLE R2 --END
                       +'    <Criteria> '
                       +'        <ObjectType tc="8">Relation</ObjectType> '
                       +'        <PropertyName>RelationRoleCode</PropertyName> '
                       +'        <PropertyValue tc="32">Insured</PropertyValue>'
                       +'        <Operation tc="1">equal to</Operation> '
                       +'    </Criteria> '
                       +'</CriteriaExpression>'
                       +'<OLifE>'
                       +     this.currentLanguageNode
                       +'    <OLifEExtension VendorCode="525">'
                       +'        <RoleId>'+this.roleID+'</RoleId>'
                       +          showAllPINode //SPS-323
                       +'    </OLifEExtension>'
                       +'</OLifE>';

        }else if(this.functionName==PolicyCalloutHelper.GetAuditTrail){//add by jack cs member level begin
            this.roleID='CS';
            criterias  +='<CriteriaExpression>'
               +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
               +     policyNumberCriteria
               +     certNoWildCriteria
               +     submissionDateTimeFromCriteria
               +     submissionDateTimeToCriteria
               +'</CriteriaExpression>'
               +'<OLifE>'
               +     this.currentLanguageNode
               +'    <OLifEExtension VendorCode="525">'
               +'        <RoleId>'+this.roleID+'</RoleId>'
               +'    </OLifEExtension>'
               +'</OLifE>';
        }//add by jack cs member level end
        else if(this.functionName == PolicyCalloutHelper.GetPersonShortfallBasicByCriteria){//added by Connor(Client Portal)
            //this.roleID = 'CS';  //PH, FC BK, CS, PCS, BCS?
            criterias  += '<CriteriaExpression>'
                + '    <CriteriaOperator tc="2">And</CriteriaOperator>'
                +      ssnNumberCriteria
                +      policyNumberCriteria
                +      staffIdforSfCriteria
                +      insuredMemberFullNameCriteria
                +      shortfallStatusCriteria
                +      branchCodeCriteria
                +      shorfallDateCriteria
                +      claimNoShortfallCriteria
                +      familyRecIndCriteria
                +      hOClaimReferenceIDCriteria  //added by chris 2021-08-12(Client Portal)
                + '</CriteriaExpression>'
                + '<OLifE>'
                +      this.currentLanguageNode
                + '    <OLifEExtension VendorCode="525">'
                + '        <RoleId>' + this.roleID + '</RoleId>'
                + '    </OLifEExtension>'
                + '</OLifE>';
        }else if(this.functionName == PolicyCalloutHelper.GetPersonMovementHistory){//added by Connor(Client Portal)
            //this.roleID = 'CS';  //PH, FC BK, CS, PCS, BCS
            criterias  += '<CriteriaExpression>'
                + '    <CriteriaOperator tc="2">And</CriteriaOperator>'
                +      insuredMemberFullNameCriteria
                +      policyYearCriteria
                +      certNoCriteria
                +      policyNumberCriteria
                +      endorsementNoCriteria
                + '</CriteriaExpression>'
                + '<OLifE>'
                +      this.currentLanguageNode
                + '    <OLifEExtension VendorCode="525">'
                + '        <RoleId>' + this.roleID + '</RoleId>'
                + '    </OLifEExtension>'
                + '</OLifE>';
        }else if(this.functionName == PolicyCalloutHelper.GetClientMemberMovementResult){//added by Connor CP-163(Client Portal)
            //this.roleID = 'CS';  //PH, FC BK, CS, PCS, BCS
            if(String.isBlank(companyCodeCriteria) && String.isBlank(deptCodeCriteria) && String.isBlank(policyNumberCriteria) && String.isBlank(branchCodeCriteria)){
                criterias  += '<OLifE>'
                +      this.currentLanguageNode
                + '    <OLifEExtension VendorCode="525">'
                + '        <RoleId>' + this.roleID + '</RoleId>'
                + '    </OLifEExtension>'
                + '</OLifE>';
            }else{
            criterias  += '<CriteriaExpression>'
                + '    <CriteriaOperator tc="2">And</CriteriaOperator>'
                +      companyCodeCriteria
                +      deptCodeCriteria
                +      policyNumberCriteria
                +      branchCodeCriteria
                + '</CriteriaExpression>'
                + '<OLifE>'
                +      this.currentLanguageNode
                + '    <OLifEExtension VendorCode="525">'
                + '        <RoleId>' + this.roleID + '</RoleId>'
                + '    </OLifEExtension>'
                + '</OLifE>';
            }
        }else if(this.functionName == PolicyCalloutHelper.GetMemberListByCriteria){// Rancho_JOBR347_20231108
            // HKITSFDC-57 add node GovtID
            criterias +='<CriteriaExpression>'
                       +'    <CriteriaOperator tc="2">And</CriteriaOperator>'
                       +     CignaUtil.buildCriteriaNode('252','OLifEExtension','PolicyType',paramsMap.get('PolicyType'),'1','Equal')
                       +     CignaUtil.buildCriteriaNode('1043','SecurityCredential','UserLoginName',paramsMap.get('UserLoginName'),'1','Equal')
                       +     CignaUtil.buildCriteriaNode('18','Policy','PolNumber',paramsMap.get('PolNumber'),'1','Equal')
                       +     CignaUtil.buildCriteriaNode('252','OLifEExtension','CertificateNo',paramsMap.get('CertificateNo'),'1','Equal')
                       +     CignaUtil.buildCriteriaNode('18','Policy','PolicyStatus',paramsMap.get('PolicyStatus'),'1','Equal')
                       +     CignaUtil.buildCriteriaNode('6','Party','FullName',paramsMap.get('FullName'),'9','WildCardMatch')
                       +     CignaUtil.buildCriteriaNode('6','Party','GovtID',paramsMap.get('GovtID'),'1','Equal') 
                       +'</CriteriaExpression>'
                       +'<OLifE>'
                       +     this.currentLanguageNode
                       +'    <OLifEExtension VendorCode="525">'
                       +'        <RoleId>'+this.roleID+'</RoleId>'
                       +         SortOrderCriteria
                       +'    </OLifEExtension>'
                       +'</OLifE>';
        }
        return criterias;
    }
    
    /*
     * buildOLifENode
     *     -- for Policy functions except GetPolicyListBasicByCriteria
     */
/*efulfillment enhanced backup start */
/*
    public String buildOLifENode(){
        String policyNumber=paramsMap.get('PolNumber')==null?'':paramsMap.get('PolNumber');
        String partyTypeCode=paramsMap.get('PartyTypeCode')==null?'':paramsMap.get('PartyTypeCode');
        String partyType=partyTypeCodeMap.get(partyTypeCode)==null?'':partyTypeCodeMap.get(partyTypeCode);
        String partyTypeCodeNode='<PartyTypeCode tc="'+partyTypeCode+'">'+partyType+'</PartyTypeCode>';
        
        String result='';
        if(this.functionName!=PolicyCalloutHelper.GetPolicyListBasicByCriteria &&
           this.functionName!=PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria){
            result='<OLifE>'
                  +     this.currentLanguageNode
                  +'    <Holding id="Holding001">'
                  +'        <HoldingTypeCode tc="2">Policy</HoldingTypeCode>'
                  +'        <Policy id="Policy001">'
                  +'            <PolNumber>'+policyNumber+'</PolNumber>'
                  +             buildClaimNode()
                  +'        </Policy>'
                  +         buildInvestmentNode()
                  +         buildAttachmentNode()
                  +'    </Holding>'
                  +     buildPartyNode()
                  +     buildRelationNode(partyTypeCode,partyType,'Holding001')
                  +'    <OLifEExtension VendorCode="525">'
                  +'        <RoleId>'+this.roleID+'</RoleId>'
                  +         (this.functionName==PolicyCalloutHelper.GetPolicyPersonListBasic?partyTypeCodeNode:'')
                  +'    </OLifEExtension>'
                  +'</OLifE>';
        }
        return result;
    }
*/
/*efulfillment enhanced backup end */
/*efulfillment enhanced start */
    public String buildOLifENode(){
        String attachmentKey=paramsMap.get('AttachmentKey')==null?'':paramsMap.get('AttachmentKey'); // added by Connor CR-47
        String docStatus=paramsMap.get('DocStatus')==null?'':paramsMap.get('DocStatus'); // added by Connor CR-47
        String policyNumber=paramsMap.get('PolNumber')==null?'':paramsMap.get('PolNumber');
        String brokerPortalBillingInd=paramsMap.get('BrokerPortalBillingInd')==null?'N':paramsMap.get('BrokerPortalBillingInd'); //HKITSFDC-148
        //add Bob 20210318
        String renewal = paramsMap.get('RenewalPosition') == null ? '' : paramsMap.get('RenewalPosition');
        //end
        String partyTypeCode=paramsMap.get('PartyTypeCode')==null?'':paramsMap.get('PartyTypeCode');
        String partyType=partyTypeCodeMap.get(partyTypeCode)==null?'':partyTypeCodeMap.get(partyTypeCode);
        String partyTypeCodeNode='<PartyTypeCode tc="'+partyTypeCode+'">'+partyType+'</PartyTypeCode>';
        String productCode=paramsMap.get('ProductCode')==null?'':paramsMap.get('ProductCode');
        String coverageNumber=paramsMap.get('CoverageNumber')==null?'':paramsMap.get('CoverageNumber');
        String familyRecInd=paramsMap.get('FamilyRecInd')==null?'':paramsMap.get('FamilyRecInd');
        
        //BenefitSectionCode for getClinicVisitCount :added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
        String benefitSectionCode=paramsMap.get('BenefitSectionCode')==null?'':paramsMap.get('BenefitSectionCode');
        String benefitSectionCodeNode=String.isNotBlank(benefitSectionCode)?'<BenefitSectionCode>'+benefitSectionCode+'</BenefitSectionCode>':'';
        
        //ShowAmountLimit for getClinicVisitCount :added by Nicole 20190730
        String showAmountLimit=paramsMap.get('ShowAmountLimit')==null?'false':paramsMap.get('ShowAmountLimit');
        String showAmountLimitNode=String.isNotBlank(ShowAmountLimit)?'<ShowAmountLimit>'+ShowAmountLimit+'</ShowAmountLimit>':'';
        
        /*efulfillment enhanced start */
        String certificateNo=paramsMap.get('CertificateNo')==null?'':paramsMap.get('CertificateNo');
        String certificateNoNode='<CertificateNo>'+certificateNo+'</CertificateNo>';
        
        //Nicole_202020331_getPolicyDocTypeList enhancement
        String holderGovtID=paramsMap.get('HolderGovtID')==null?'':paramsMap.get('HolderGovtID');
        String holderGovtIDNode=paramsMap.get('HolderGovtID')==null?'' :'<Holder><GovtID>'+holderGovtID+'</GovtID></Holder>';
        /*efulfillment enhanced end */
        
        String showAllPI=paramsMap.get('ShowAllPI');      // AH18767 - David
               
        //add by jack for policy replacement
        String filterDate=paramsMap.get('FilterDate')==null?'':paramsMap.get('FilterDate');
        String filterDateNode=String.isNotBlank(filterDate)?'            <FilterDate>'+filterDate+'</FilterDate>':'';
               
        String coverageNumberCriteria='';
        if(String.IsNotBlank(coverageNumber)){
            coverageNumberCriteria='<Life id="life01"><Coverage id="coverage01"><CovNumber>'+coverageNumber+'</CovNumber></Coverage></Life>';
        }else{
            if(this.functionName!=PolicyCalloutHelper.GetPolicyClaimBasic && this.functionName!=PolicyCalloutHelper.GetPolicyReplacementChangeHistory){// change by jack for policy replacement
                coverageNumberCriteria='<Life id="life01"><Coverage id="coverage01"><CovNumber></CovNumber></Coverage></Life>';
            }
        }
        String productCodeCriteria='';
        if(String.IsNotBlank(productCode)){
            productCodeCriteria='<ProductCode>'+productCode+'</ProductCode>';
        }
        String familyRecIndCriteria='';
        if(String.IsNotBlank(familyRecInd) && String.IsNotBlank(familyRecordMap.get(familyRecInd))){
            familyRecIndCriteria='<Criteria>'
                                +   '<ObjectType tc="252">OLifEExtension</ObjectType>'
                                +   '<PropertyName>FamilyRecInd</PropertyName>'
                                +   '<PropertyValue>'+familyRecordMap.get(familyRecInd)+'</PropertyValue>'
                                +   '<Operation tc="1">Equal</Operation>'
                                 +'</Criteria>';
        }
        
        String result='';
        if(this.functionName == PolicyCalloutHelper.UpdatePolicyDoc){  //added by Connor CR-47
            result = '<OLifE>'
                   + '   <Holding id="Holding001">'
                   +'       <Attachment>' 
                   +'        <AttachmentKey>'+attachmentKey+'</AttachmentKey>'
                   +'        <Status>'+docStatus+'</Status>'
                   +'       </Attachment>'
                   +'    </Holding>'                  
                   +'    <OLifEExtension VendorCode="525">'
                   +'        <RoleId>'+this.roleID+'</RoleId>'
                   +'    </OLifEExtension>'
                   +'</OLifE>';
        }
        // Rancho_JOBR347_20231108
        if(this.functionName != PolicyCalloutHelper.UpdatePolicyDoc &&    //added by Connor CR-47
           this.functionName!=PolicyCalloutHelper.GetPolicyListBasicByCriteria &&
           this.functionName!=PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria &&
           this.functionName!=PolicyCalloutHelper.GetAuditTrail&&
           this.functionName != PolicyCalloutHelper.GetPersonShortfallBasicByCriteria &&
           this.functionName != PolicyCalloutHelper.GetPersonMovementHistory &&
           this.functionName!=PolicyCalloutHelper.GetClientMemberMovementResult &&
           this.functionName!=PolicyCalloutHelper.GetMemberListByCriteria){//jack add for cs member level   //added by Connor(Client Portal)                                            
            result='<OLifE>'
                  +     this.currentLanguageNode
                  +'    <Holding id="Holding001">'
                  +'        <HoldingTypeCode tc="2">Policy</HoldingTypeCode>'
                  +'        <Policy id="Policy001">'
                  +'            <PolNumber>'+policyNumber+'</PolNumber>'
                   +  (String.isNotBlank(renewal)?'            <RenewalPosition>' + renewal + '</RenewalPosition>':'')
                  + (this.functionName==PolicyCalloutHelper.GetPolicyReplacementChangeHistory?filterDateNode:'')//jack add for policy replacement
                   +  ((this.functionName == PolicyCalloutHelper.GetPolicyDocTypeList)?certificateNoNode:'') // for efulfillment enhanced
                                                                                                            
                  +             buildPolicyTypeNode()    // for efulfillment enhanced
                  +             buildCompanyCodeNode()   //added by Connor LPCSC-8  
                  +             coverageNumberCriteria
                  +             productCodeCriteria
                  +             buildClaimNode()
                  + (this.functionName==PolicyCalloutHelper.GetPolicyDocTypeList || this.functionName==PolicyCalloutHelper.GetPolicyReplacementChangeHistory ?holderGovtIDNode:'') // for efulfillment enhanced //jack add for policy replacement
                  + (this.functionName==PolicyCalloutHelper.GetPolicyBillingListBasic ? '<BrokerPortalBillingInd>'+brokerPortalBillingInd+'</BrokerPortalBillingInd>':'') //HKITSFDC-148            
                  +'        </Policy>'
                  +         buildInvestmentNode()
                  +         buildAttachmentNode()
                  +'    </Holding>'
                  +     buildPartyNode()
                  +     buildRelationNode(partyTypeCode,partyType,'Holding001')
                  +     familyRecIndCriteria
                  +'    <OLifEExtension VendorCode="525">'
                  +'        <RoleId>'+this.roleID+'</RoleId>'
                  +         (this.functionName==PolicyCalloutHelper.GetPolicyPersonListBasic?partyTypeCodeNode:'')
                  +         (this.functionName==PolicyCalloutHelper.getClinicVisitCount?benefitSectionCodeNode:'')
                  +         (this.functionName==PolicyCalloutHelper.getClinicVisitCount?showAmountLimitNode:'')
                  +         (this.functionName==PolicyCalloutHelper.GetPolicyPersonListBasic & 'Y'==showAllPI? '<ShowAllPI>Y</ShowAllPI>':'')      // AH18767 - David
                  +       buildPolicyDocTypeListOptionNode()   //for efulfillment enhanced
                  +'    </OLifEExtension>'
                  +'</OLifE>';
        }
        return result;
    }
    
    /*efulfillment enhanced start */
    //for efulfillment
    public string buildPolicyTypeNode(){
        String policyTypeInd=paramsMap.get('GetDocPolicyType')==null?'I':paramsMap.get('GetDocPolicyType');
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyDocTypeList){//    || this.functionName==PolicyCalloutHelper.GetPolicyPersonCoverageBasic
            result='<OLifEExtension VendorCode=\"525\">';
            if(policyTypeInd!='I'){
                result+='<IndividualPolicyInd tc="0">false</IndividualPolicyInd>';
            }else{
                result+='<IndividualPolicyInd tc="1">true</IndividualPolicyInd>';
            }
            // Rancho_PI66_20220428 - for getting all families' doc
            if(isAllFamilyRec){
                result+='<AllFamilyRecInd tc="1">true</AllFamilyRecInd>';
            }
            if(String.isNotBlank(paramsMap.get('PolicyHolderName'))){  //added by Connor LPCSC-12
                result+='<PolicyHolderName>'+paramsMap.get('PolicyHolderName')+'</PolicyHolderName>';
            }        
            result +='</OLifEExtension>';
        }
        return result;
    }
    
    //for efulfillment
    public string buildPolicyDocTypeListOptionNode(){
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyDocTypeList){
            String sortOrder=paramsMap.get('GetDocSortOrder')==null?'D':paramsMap.get('GetDocSortOrder');
            String docStartDate=paramsMap.get('GetDocStartDate')==null?'':paramsMap.get('GetDocStartDate'); // format yyyy-mm-dd
            String docEndDate=paramsMap.get('GetDocEndDate')==null?'':paramsMap.get('GetDocEndDate');// format yyyy-mm-dd
            if(sortOrder=='D'){
                result='<SortOrder>D</SortOrder>';
            }else{
                result='<SortOrder>A</SortOrder>';
            }
            if(docStartDate!=''){
                result +='<DocStartDate>'+docStartDate +'</DocStartDate>';
            }
            if(docEndDate!=''){
                result +='<DocEndDate>'+docEndDate +'</DocEndDate>';
            }
        }
        return result;
    }
/*efulfillment enhanced end */
    public String buildPartyNode(){
        String govtID=paramsMap.get('GovtID')==null?'':paramsMap.get('GovtID'); // SSN Number
        String fullName=paramsMap.get('FullName')==null?'':paramsMap.get('FullName');
        String certificateNo=paramsMap.get('CertificateNo')==null?'':paramsMap.get('CertificateNo');
        String planNo=paramsMap.get('planNo')==null?'':paramsMap.get('planNo');
        String certNo=paramsMap.get('CertNo')==null?'':paramsMap.get('CertNo');
        //chris work for client portal benefits
        String planNoList = paramsMap.get('planNoList') == null ? '' : paramsMap.get('planNoList');
        system.debug('planNoList='+planNoList);
        String govtIDStr='';
        if(String.isNotBlank(govtID)){
            govtIDStr='<GovtID>'+govtID+'</GovtID>';
        }

        String fullNameStr='';
        if(String.isNotBlank(fullName)){
            fullNameStr='<FullName>'+fullName+'</FullName>';
        }        

        String CertificateNoNode='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyClaimBasic || this.functionName==PolicyCalloutHelper.GetClinicVisitCount){
            CertificateNoNode='<OLifEExtension VendorCode="525">'
                             +'    <CertificateNo>'+certificateNo+'</CertificateNo>'
                             +'</OLifEExtension>';
        }
        
        String planNumberStr='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyPersonCoverageBasic &&
            (String.isNotBlank(planNo)|| String.isNotBlank(certNo) || String.isNotBlank(planNoList))){
            planNumberStr='<OLifEExtension VendorCode="525">';

            if(String.isNotBlank(planNo)){
                planNumberStr +='  <PlanNumber>'+ planNo +'</PlanNumber>';
            }

            if(String.isNotBlank(certNo)){
                planNumberStr +='  <CertificateNo>'+ certNo +'</CertificateNo>';
            }
            //chris work for client portal benefits
            if(String.isNotBlank(planNoList)){
                List<String> planNumberList = planNoList.split(',');
                system.debug('planNumberList='+planNumberList);
                if(planNumberList.size() > 0){
                    planNumberStr += '  <PlanNumberList>';
                    for(String planNumber : planNumberList){
                        planNumberStr += '  <PlanNumber>'+ planNumber +'</PlanNumber>';
                    }
                    planNumberStr += '  </PlanNumberList>';
                }
            }
            //benefits end

            planNumberStr +='</OLifEExtension>';
                                                         
        }
        
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyClaimBasic || this.functionName==PolicyCalloutHelper.GetPolicyPersonCoverageBasic || this.functionName==PolicyCalloutHelper.GetClinicVisitCount){
            result='    <Party id="Party001">'
                  +'        <PartyTypeCode tc="0">Unknown</PartyTypeCode>'
                  +         fullNameStr
                  +         govtIDStr
                  +         CertificateNoNode
                  +         planNumberStr
                  +'    </Party>';
        }
        return result;
    }
    
    public String buildRelationNode(String relatetionRoleCode,String partyType,String holdingId){
        String result='';
        if(this.functionName==PolicyCalloutHelper.getPolicyPersonListBasic || this.functionName==PolicyCalloutHelper.GetPolicyPersonCoverageBasic){
            result='<Relation OriginatingObjectID="'+holdingId+'" id="relation001">'
                  +'    <OriginatingObjectType tc="4">Holding</OriginatingObjectType>'
                  +'    <RelatedObjectType tc="6">Party</RelatedObjectType>'
                  +'    <RelationRoleCode tc="'+relatetionRoleCode+'">'+partyType+'</RelationRoleCode>'
                  +'</Relation>';
        }
        return result;
    }
    
    public String buildInvestmentNode(){
        String fundAllocType=paramsMap.get('FundAllocType')==null?'':paramsMap.get('FundAllocType');
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyAvailFundListBasic){
            result='<Investment>'
                  +'    <OLifEExtension VendorCode="525">'
                  +'        <FundAllocType>'+fundAllocType+'</FundAllocType>'
                  +'    </OLifEExtension>'
                  +'</Investment>';
        }
        return result;
    }
    
    /*efulfillment updated buildAttachmentNode backup start */
    /*
    public String buildAttachmentNode(){
        String fileName=paramsMap.get('FileName')==null?'':paramsMap.get('FileName');
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyDoc){
            result='<Attachment>'
                  +'    <FileName>'+fileName+'</FileName>'
                  +'</Attachment>';
        }
        return result;
    }
    */
    /*efulfillment updated buildAttachmentNode backup start */
    
    /*efulfillment updated buildAttachmentNode start */
    public String buildAttachmentNode(){
        String attachmentKey=paramsMap.get('AttachmentKey')==null?'':paramsMap.get('AttachmentKey');
        String fileName=paramsMap.get('FileName')==null?'':paramsMap.get('FileName');
        //set default attachment location=Policy Document
        String attachmentLocation=paramsMap.get('GetDocAttachmentLocation')==null?'Policy Document':paramsMap.get('GetDocAttachmentLocation');
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyDocTypeList){
            result='<Attachment>';
            if(attachmentLocation=='Policy Document'){
                result +='    <AttachmentLocation tc=\"1001\">Policy Document</AttachmentLocation>';
            }else if(attachmentLocation=='Policy Correspondence'){
                result +='    <AttachmentLocation tc=\"1002\">Policy Correspondence</AttachmentLocation>';
            }else if(attachmentLocation=='Claim Correspondence'){
                result +='    <AttachmentLocation tc=\"1003\">Claim Correspondence</AttachmentLocation>';
            }else if(attachmentLocation=='All'){
                result +='    <AttachmentLocation tc=\"1004\">All</AttachmentLocation>';
            }else if(attachmentLocation=='Client Portal Document'){ //20210319 - minghua - Client Portal Document
                result +='    <AttachmentLocation tc=\"1005\">Client Portal Document</AttachmentLocation>';
                String aPolicyYear = paramsMap.get('AttachmentPolicyYear') == null ? '':paramsMap.get('AttachmentPolicyYear');
                if(String.isNotBlank(aPolicyYear)){
                    result +='    <AttachmentPolicyYear>'+aPolicyYear+ '</AttachmentPolicyYear>';
                }
            }else if(attachmentLocation=='Client Portal Billing'){
                result +='    <AttachmentLocation tc=\"1006\">Client Portal Billing Document</AttachmentLocation>';
            }else if(attachmentLocation=='LHB Monthly Statement'  || attachmentLocation=='LHB OS Premium Reminder'){  //added by Connor LPCSC-8 LPCSC-12 start
                result +='    <AttachmentLocation tc=\"1001\">'+attachmentLocation+'</AttachmentLocation>';
                String attachmentDurationYear = paramsMap.get('AttachmentDurationYear') == null ? '':paramsMap.get('AttachmentDurationYear');
                if(String.isNotBlank(attachmentDurationYear)){
                    result +='    <AttachmentDurationInYear>'+attachmentDurationYear+ '</AttachmentDurationInYear>';
                }
            } //added by Connor LPCSC-8 LPCSC-12 end
            if(fileName!=''){
                result +='    <FileName>'+processXMLEscape(fileName,'')+'</FileName>';
            }
            result +='</Attachment>';
        }
        if(this.functionName==PolicyCalloutHelper.GetPolicyDoc){
            result='<Attachment>'
                  +'    <AttachmentKey>'+attachmentKey+'</AttachmentKey>'
                  // Rancho_HKITSFDC321_20251013 - add file store id, WS will insert attachment in file store
                  +'    <ParentId>'+paramsMap.get('ParentId')+'</ParentId>'
                  +'</Attachment>';
        }

        return result;
    }
    /*efulfillment updated buildAttachmentNode end */
    
    public String buildClaimNode(){
        String HOClaimReferenceID=paramsMap.get('HOClaimReferenceID')==null?'':paramsMap.get('HOClaimReferenceID');
        String productCode=paramsMap.get('ProductCode')==null?'':paramsMap.get('ProductCode');
        String coverageProductCode=paramsMap.get('CoverageProductCode')==null?'':paramsMap.get('CoverageProductCode');
        String result='';
        if(this.functionName==PolicyCalloutHelper.GetPolicyClaimBasic){
            result='<Life>'
                  +'    <Coverage>'
                  +'        <PlanName>'+coverageProductCode+'</PlanName>'
                  +'        <OLifEExtension VendorCode="525">'
                  +'            <ProductCode>'+productCode+'</ProductCode>'
                  +'        </OLifEExtension>'
                  +'    </Coverage>'
                  +'</Life>'
                  +'<Claim>'
                  +'    <HOClaimReferenceID>'+HOClaimReferenceID+'</HOClaimReferenceID>'
                  +'</Claim>';
        }
/*efulfillment enhanced add start*/
        if(this.functionName==PolicyCalloutHelper.GetPolicyDocTypeList){
            result='<Claim>'
                  +'    <HOClaimReferenceID>'+HOClaimReferenceID+'</HOClaimReferenceID>'
                  +'</Claim>';
        }
/*efulfillment enhanced add end*/
        return result;
    }
    
    /*
    * Jira: LPCSC-8, LPCSC-12
    * build company code node in ws GetPolicyDocTypeList to get LHB Statement and Premium Reminder
    * @author Connor Huang
    * @version V1.0 init this method 2021-07-16 Connor Huang
    */
    public String buildCompanyCodeNode(){
        String result='';
        String attachmentLocation=paramsMap.get('GetDocAttachmentLocation')==null?'Policy Document':paramsMap.get('GetDocAttachmentLocation');
        if((attachmentLocation=='LHB Monthly Statement' || attachmentLocation=='LHB OS Premium Reminder')&& String.isNotBlank(currentUser.Company_Code__c)){  
            result = '<CompanyCode>'+currentUser.Company_Code__c+'</CompanyCode>';
        }
        return result;
    }
    
    
    protected override String buildTXObjectRequestNode(){
        //system.debug('>>>>> parameters:'+paramsMap);
        if(paramsMap!=null && paramsMap.size() > 0){
            for(String key:paramsMap.keySet()){
                if(String.isNotBlank(paramsMap.get(key))){
                    paramsMap.put(key,paramsMap.get(key).escapeXML());
                }
            }
        }

        system.debug('>>>>> parameters after escapeXML:'+paramsMap);
        String datetimeStr=DateTime.now().formatGmt('yyyy-MM-dd HH:mm:ss');
        if(this.functionName==PolicyCalloutHelper.GetEMedicalCardsByCriteria || this.functionName==PolicyCallOutHelper.GetEMedicalCardsBasicByCriteria){
            String userAccess = currentUser.AccessLevel__c;  //CTUI-220-20220622-Kirk  
            TXLifeRequest='<TXServiceRequest id="request001">';
            TXLifeRequest +='    <TransRefGUID>'+GuidUtil.NewGuid()+'</TransRefGUID>'
                           +'    <TransExeDate>'+datetimeStr.substring(0,10)+'</TransExeDate>'
                           +'    <TransExeTime>'+datetimeStr.substring(11)+'</TransExeTime>'
                           + ( (this.functionName == GetEMedicalCardsByCriteria && String.isNotBlank(userAccess)) ? '    <AccessLevel>'+ userAccess + '</AccessLevel>' : '') //CTUI-220-20220622-Kirk
                           +'    <MaxRecords>'+this.maxRecords+'</MaxRecords>'
                           +buildOServiceNode()
                           +'</TXServiceRequest>';
        }
        // JR1774 - [[
       else if(this.functionName==PolicyCalloutHelper.VerifyPolicyInfo){
            TXLifeRequest=   '<TXServiceRequest id="Request001">';
            TXLifeRequest +=   '    <TransRefGUID>'+GuidUtil.NewGuid()+'</TransRefGUID>'
                         +    '    <TransExeDate>'+datetimeStr.substring(0,10)+'</TransExeDate>'
                         +    '    <TransExeTime>'+datetimeStr.substring(11)+'</TransExeTime>'
                         +    buildOServiceNode()
                         +    '</TXServiceRequest>';
        // Rancho_JOBR347_20231108
        }else if(this.functionName==PolicyCalloutHelper.GetAuditTrail || this.functionName == GetPersonShortfallBasicByCriteria || this.functionName == GetPersonMovementHistory || this.functionName == GetClientMemberMovementResult || this.functionName == GetMemberListByCriteria){//jack add for cs member level //added by Connor CP-156 CP-163(Client Portal)
            String userAccess = currentUser.AccessLevel__c;                                      
            TXLifeRequest ='<TXLifeRequest id="Request001">'
                           +'    <TransRefGUID>'+GuidUtil.NewGuid()+'</TransRefGUID>'
                           +'    <TransType tc="302">Holding Search</TransType>'
                           +'    <TransSubType tc="30200">Holding Search</TransSubType>'
                           +'    <TransExeDate>'+datetimeStr.substring(0,10)+'</TransExeDate>'
                           +'    <TransExeTime>'+datetimeStr.substring(11)+'</TransExeTime>'
                           +'    <InquiryLevel tc="3">Target Object,all relations,and all related objects</InquiryLevel>'
                           + ( (this.functionName == GetPersonShortfallBasicByCriteria || this.functionName == GetClientMemberMovementResult ) && String.isNotBlank(userAccess) ? '    <AccessLevel>'+ userAccess + '</AccessLevel>' : '') // added by Connor (Client Portal)                                                                                                                                                                                                                                                   
                           +'    <MaxRecords>'+this.maxRecords+'</MaxRecords>'
                           +'    <StartRecord>'+this.startRecord+'</StartRecord>'
                           +     buildCriteriaExpressionNode(paramsMap)
                           +     buildOLifENode()
                           +'</TXLifeRequest>';
        }else{// ]] - JR1774
            String primaryObjectIDAttr=(this.functionName!=GetPolicyListBasicByCriteria && this.functionName!=GetPolicyPersonListBasicByCriteria?'PrimaryObjectID="Holding001"':'');
            TXLifeRequest ='<TXLifeRequest '+primaryObjectIDAttr+' id="Request001">'
                           +'    <TransRefGUID>'+GuidUtil.NewGuid()+'</TransRefGUID>'
                           +'    <TransType tc="203">Holding Inquiry</TransType>'
                           +'    <TransSubType tc="20300">Holding Inquiry</TransSubType>'
                           +'    <TransExeDate>'+datetimeStr.substring(0,10)+'</TransExeDate>'
                           +'    <TransExeTime>'+datetimeStr.substring(11)+'</TransExeTime>'
                           +'    <InquiryLevel tc="3">Target Object,all relations,and all related objects</InquiryLevel>';
            //add Bob 20210310
            String userAccess = '';
            userAccess = currentUser.AccessLevel__c;
            if(String.isNotBlank(userAccess)){
                if((this.functionName == GetPolicyListBasicByCriteria || this.functionName == GetPolicyPersonListBasicByCriteria || this.functionName == GetPolicyBasic)){
                    TXLifeRequest   += '    <AccessLevel>' + userAccess + '</AccessLevel>';
                }else if(this.functionName == GetPolicyDocTypeList||this.functionName == GetPolicyPersonCoverageBasic){//CTUI-220-20220622-Kirk
                    TXLifeRequest   += '    <AccessLevel>' + userAccess + '</AccessLevel>';
                }
            }
            //end Bob 20210310
            TXLifeRequest  +='    <MaxRecords>'+this.maxRecords+'</MaxRecords>'
                           +'    <StartRecord>'+this.startRecord+'</StartRecord>'
                           +(this.functionName!=GetPolicyPersonListBasicByCriteria?'<PrimaryObjectType tc="4">Holding</PrimaryObjectType>':'')
                           +     buildCriteriaExpressionNode(paramsMap)
                           +     buildOLifENode()
                           +'</TXLifeRequest>';
        }
        return TXLifeRequest;
    }
    
    //Nicole_SMT_20210429 start
    public List<HttpCalloutVO.EMedicalCard> getEMedicalCards(List<String> policyNumberList,Boolean hasAttachment,Boolean isIndividual){
        return getEMedicalCards(policyNumberList,hasAttachment,(isIndividual?'I':'G'));
    }
    /****************************************************************************************
     * Description: API getEMedicalCards to get emedical card information by policy no and policy type(I/G/TD)
     * Author: Nicole
     ***************************************************************************************/
    public List<HttpCalloutVO.EMedicalCard> getEMedicalCards(List<String> policyNumberList,Boolean hasAttachment,String policyType){
        system.debug('>>>>> PolicyCalloutHelper.getEMedicalCards >>>>>');
        TXName='TXService';
        if(hasAttachment){
            this.functionName=PolicyCalloutHelper.GetEMedicalCardsByCriteria;              
        }else{
            this.functionName=PolicyCalloutHelper.GetEMedicalCardsBasicByCriteria;
        }
        paramsMap=new Map<String,String>();
        string policyNumberListStr='';
        if(hasAttachment){
            paramsMap.put('FileSize','L');
        }else{
            paramsMap.put('FileSize','N');
        }
        paramsMap.put('PolicyType',policyType);
        for(String tmp: policyNumberList){
            if(tmp.trim().length()>0){
                policyNumberListStr +=tmp+';';
            }
        }
        paramsMap.put('policyNumberListStr',policyNumberListStr);
        return (List<HttpCalloutVO.EMedicalCard>)execute(new Map<String,String>());
    }
    //Nicole_SMT_20210429 end

    public string buildOServiceNode(){
        // JR1774 - [[
        string policyNumberListStr=null;
        string [] ls=null;
        string poltype=null;
                    
        if(this.functionName!=PolicyCalloutHelper.VerifyPolicyInfo){
        // ]] - JR1774
        // JR1774 - COMMENTED- [[
        /*
            string policyNumberListStr=paramsMap.get('policyNumberListStr');
            string [] ls=policyNumberListStr.split(';');
            string poltype=paramsMap.get('PolicyType');
        */
        // ]] - JR1774 - COMMENTED
        // JR1774 - [[
            policyNumberListStr=paramsMap.get('policyNumberListStr');
            ls=policyNumberListStr.split(';');
            poltype=paramsMap.get('PolicyType');
        }
        // ]] - JR1774
        string retStr='<OService>';
        // JR1774 - [[
        //system.debug('[PolicyCalloutHelper][buildOServiceNode] To build the XML for SOAP request - Function name: '+((null!=this.functionName)? this.functionName:''));
        if(this.functionName==PolicyCalloutHelper.VerifyPolicyInfo){
            retStr +=currentLanguageNode
                  +'<RoleId>CS</RoleId>'
                  +'<CriteriaExpression>'
                  +'    <CriteriaOperator tc="1">OR</CriteriaOperator>'
                  +'    <CriteriaExpression>'
                  +'        <CriteriaOperator tc="2">AND</CriteriaOperator>'
                  +'        <Criteria>'
                  +'            <ObjectType tc="18">Policy</ObjectType>'
                  +'            <PropertyName>PolNumber</PropertyName>'
                  +'            <PropertyValue tc="0">'+paramsMap.get('PolNumber')+'</PropertyValue>'
                  +'            <Operation tc="1">EQUAL</Operation>'
                  +'        </Criteria>'
                  +'        <Criteria>'
                  +'            <ObjectType tc="252">OLifEExtension</ObjectType>'
                  +'            <PropertyName>CreditCard</PropertyName>'
                  +'            <PropertyValue tc="0">'+paramsMap.get('CreditCard')+'</PropertyValue>'
                  +'            <Operation tc="1">EQUAL</Operation>'
                  +'        </Criteria>'
                  +'    </CriteriaExpression>';
        }else{
        // ]] - JR1774
            retStr +=currentLanguageNode
                   +'<SortOrder>Ascending</SortOrder>'
                   +'<FileSize>'+ paramsMap.get('FileSize')+'</FileSize>'
                   +'<CriteriaExpression>'
                   +'<CriteriaOperator tc="1">Or</CriteriaOperator>';
            for(string tmpStr:ls){
                if(tmpStr.trim().length()>0){
                    string pl=tmpStr;
                    string ssn=''; 
                    if(tmpStr.contains('--')){
                        pl=tmpStr.split('--').get(0);
                        ssn=tmpStr.split('--').get(1);
                    }
                        
                    retStr +='<CriteriaExpression>'
                       +'<CriteriaOperator tc="2">And</CriteriaOperator>'
                       +'<Criteria>'
                       +'<ObjectType tc="252">OLifEExtension</ObjectType>'
                        +'<PropertyName>PolicyType</PropertyName>'
                        +'<PropertyValue>'+  paramsMap.get('PolicyType') +'</PropertyValue>'
                        +'<Operation tc="1">Equal</Operation>'
                        +'</Criteria>'
                       +'<Criteria>'
                       +'<ObjectType tc="18">Policy</ObjectType>'
                       +'<PropertyName>PolNumber</PropertyName>'
                       +'<PropertyValue>'+pl+'</PropertyValue>'
                       +'<Operation tc="1">Equal</Operation>'
                       +'</Criteria>';
                    if(ssn.length()>0){
                        //Nicole_SMT_20210414
                        //if(poltype=='I'){
                        if(poltype=='I' || poltype==CignaUtil.cusFuncTD){
                            retStr   += '<Criteria>'
                           +'<ObjectType tc="6">Party</ObjectType>'
                           +'<PropertyName>GovtID</PropertyName>'
                           +'<PropertyValue>'+ssn+'</PropertyValue>'
                           +'<Operation tc="1">Equal</Operation>'
                           +'</Criteria>';
                        }else{
                            retStr   += '<Criteria>'
                           +'<ObjectType tc="252">OLifEExtension</ObjectType>'
                           +'<PropertyName>CertificateNo</PropertyName>'
                           +'<PropertyValue>'+ssn+'</PropertyValue>'
                           +'<Operation tc="9">WILDCARDMATCH</Operation>'
                           +'</Criteria>';
                        }
                    }
                     retStr   +='</CriteriaExpression>';
                }
            }
        }    // JR1774
        retStr +='</CriteriaExpression></OService>';
        return retStr;
    }

    public List<HttpCalloutVO.EMedicalCard> processGetEMedicalCardsResult(Dom.document doc){
        Portal_Settings__c  tmp=Portal_Settings__c.getInstance();
        // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
        // String pref=tmp.File_Download_URL__c;
        Boolean isClient=false;
        String pref=Site.getBaseUrl()+'/servlet/servlet.FileDownload?file=';
        if (currentUserProfile.contains(tmp.Client_Portal_User_Profile__c)) {
            pref=Site.getBaseUrl()+tmp.Client_Portal_Download_URL__c;
            isClient=true;
        }
        System.debug('PolicyCalloutHelper:'+pref);
        
        List<HttpCalloutVO.EMedicalCard>  objList=new List<HttpCalloutVO.EMedicalCard> () ;
        Boolean hasAttachment=false;
        
        if( paramsMap.get('FileSize')=='L'){
            hasAttachment=true;
        }
        string PolicyType=paramsMap.get('PolicyType');
        
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXServiceResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode OServiceNode=getChildNodeIfNotNull('OService',TXServiceResponseNode);
      //
        Dom.XmlNode TransResultNode=getChildNodeIfNotNull('TransResult',TXServiceResponseNode);
        String resultCode=getChildNodeTextIfNotEmpty('ResultCode',TransResultNode);
        system.debug('PolicyCalloutHelper.processGetEMedicalCardsResult result code:'+ resultCode );

        if(!hasAttachment){
            List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(OServiceNode);
            for(Dom.XmlNode childNode :childNodes){
                HttpCalloutVO.EMedicalCard hce=new HttpCalloutVO.EMedicalCard();
                hce.InsuredName=getChildNodeTextIfNotEmpty('FullName',childNode);
                hce.PolicyNumber=getChildNodeTextIfNotEmpty('PolNumber',childNode);
                if(PolicyType=='G'){
                    hce.CertNumber=getChildNodeTextIfNotEmpty('CertificateNo',childNode);
                }else{
                    hce.InsuredSSNNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                }
                objList.add(hce);
            }
        }else{
            // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
            File_Store__c fileStore;
            if (!isClient) {
                fileStore=new File_Store__c();
                fileStore.OwnerId=UserInfo.getUserId();
                fileStore.Owner_id__c=UserInfo.getUserId();
                Insert fileStore;
            }
        
            List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(OServiceNode);
            for(Dom.XmlNode childNode:childNodes){
                if(childNode.getName()=='EMedicalCard'){
                    HttpCalloutVO.EMedicalCard hce=new HttpCalloutVO.EMedicalCard();
                    hce.InsuredName=getChildNodeTextIfNotEmpty('FullName',childNode);
                    hce.PolicyNumber=getChildNodeTextIfNotEmpty('PolNumber',childNode);
                    if(PolicyType=='G'){
                        hce.CertNumber=getChildNodeTextIfNotEmpty('CertificateNo',childNode);
                    }else{
                         hce.InsuredSSNNumber=getChildNodeTextIfNotEmpty('GovtID',childNode);
                    }
             
                    if(hasAttachment){
                        // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
                        ContentVersion cv;
                        Attachment tempAtt;
                        List<Dom.XmlNode>  attNodeList=getChildElementsIfNotNull(childNode);
                        Map<String,Attachment> attMap = new Map<String,Attachment>();
                        // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
                        Map<String,ContentVersion> cvMap = new Map<String,ContentVersion>();
                        for(Dom.XmlNode attNode:attNodeList){
                            if(attNode.getName()=='Attachment' && (attNode.getAttribute('id','')!=null && attNode.getAttribute('id','')=='001'  ) ){
                                Dom.XmlNode attFrontNode=attNode;
                                string filename=getChildNodeTextIfNotEmpty('FileName',attFrontNode);
                                string  blobstr=getChildNodeTextIfNotEmpty('AttachmentData64Binary',attFrontNode);
                                Blob theBlob=EncodingUtil.base64Decode(blobstr);
                                // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
                                if (isClient) {
                                    cv = new ContentVersion();
                                    cv.Description='tempDoc';
                                    cv.ContentLocation = 'S';
                                    cv.VersionData = theBlob;
                                    cv.Title = filename;
                                    cv.PathOnClient = filename;
                                    cvMap.put(attNode.getAttribute('id',''), cv);
                                }else{
                                    tempAtt=new Attachment();
                                    tempAtt.parentId=fileStore.Id;
                                    tempAtt.contentType='image/png';
                                    tempAtt.name=filename;
                                    tempAtt.body=theBlob;
                                    // Insert tempAtt;
                                    attMap.put(attNode.getAttribute('id',''),tempAtt);
                                    hce.frontUrl=pref+tempAtt.Id ;
                                }
                                //hce.frontUrl='/servlet/servlet.FileDownload?file='+tempAtt.Id+'&date='+system.Now().millisecondGmt();                                
                            }else if(attNode.getName()=='Attachment' && (attNode.getAttribute('id','')!=null && attNode.getAttribute('id','')=='002'  )){
                                 Dom.XmlNode attBackNode=attNode;
                                string filename=getChildNodeTextIfNotEmpty('FileName',attBackNode);
                                string  blobstr=getChildNodeTextIfNotEmpty('AttachmentData64Binary',attBackNode);
                                Blob theBlob=EncodingUtil.base64Decode(blobstr);
                                // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
                                if (isClient) {
                                    cv = new ContentVersion();
                                    cv.ContentLocation = 'S';
                                    cv.Description='tempDoc';
                                    cv.VersionData = theBlob;
                                    cv.Title = filename;
                                    cv.PathOnClient = filename;
                                    cvMap.put(attNode.getAttribute('id',''), cv);
                                }else{
                                    tempAtt=new Attachment();
                                    tempAtt.parentId=fileStore.Id;
                                    tempAtt.contentType='image/png';
                                    tempAtt.name=filename;
                                    tempAtt.body=theBlob;
                                    // Insert tempAtt;
                                    attMap.put(attNode.getAttribute('id',''),tempAtt);
                                    hce.backurl=pref+tempAtt.Id ;
                                }
                                //hce.backurl='/apex?downloadLink='+'/servlet/servlet.FileDownload?file='+tempAtt.Id+'&date='+system.Now().millisecondGmt();
                            }
                         }
                         // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
                         if (isClient) {
                             insert cvMap.values();
                             for (String attId : cvMap.keySet()) {
                                String cvId=cvMap.get(attId)?.Id;
                                if(attId=='001'){
                                    hce.frontUrl=pref+cvId;
                                }else if(attId=='002'){
                                    hce.backurl=pref+cvId;
                                }
                             }
                         }else{
                             insert attMap.values();
                             for(String attId : attMap.keySet()){
                                if(attId=='001'){                  
                                    hce.frontUrl=pref+attMap.get(attId)?.Id;
                                }else if(attId=='002'){
                                    hce.backurl=pref+attMap.get(attId)?.Id;
                                }
                             }
                         }
                    }
                    objList.add(hce);
                    system.debug('hce :' +hce);
                }
            }
        }
        return objList;
     }
    
    public List<HttpCalloutVO.UWComment> getUWCommentList(String policyNumber){
        system.debug('PolicyCalloutHelper.getUWCommentList');
        this.functionName=PolicyCalloutHelper.GetUWComments;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        return asyn?new List<HttpCalloutVO.UWComment>():(List<HttpCalloutVO.UWComment>)execute(new Map<String,String>());
    }
    
    public List<HttpCalloutVO.UWComment> processUWCommentResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processUWCommentResult');
        List<HttpCalloutVO.UWComment> objList=new List<HttpCalloutVO.UWComment>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }

        try{
            Dom.XmlNode root=doc.getRootElement();
            Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
            Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
            List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
            for(Dom.XmlNode childNode:childNodes){
                String holdingTypeCode=getChildNodeAttributeIfNotEmpty('HoldingTypeCode','tc',childNode);
                if(holdingTypeCode=='2'){ //Policy
                    Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                    String policyNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                    Dom.XmlNode OLifEExtensionNode=getChildNodeIfNotNull('OLifEExtension',childNode);
                    String requestId=getChildNodeTextIfNotEmpty('TrackingID',OLifEExtensionNode);
                    String uwCommentDetails=getChildNodeTextIfNotEmpty('UWCommentDetails',OLifEExtensionNode);

                    // Parse details from UWCommentDetails
                    uwCommentDetails=uwCommentDetails.replace('<![CDATA[','').replace(']]>',''); // .unescapeXml()
                    if(String.isNotBlank(uwCommentDetails) && !'No Records Found'.equalsIgnoreCase(uwCommentDetails)){
                        String commentDetailsXML='<?xml version="1.0" encoding="UTF-8"?>'
                       +'<Cigna>'
                       +uwCommentDetails
                       +'</Cigna>';

                        Dom.Document commentDetailsDoc=new Dom.Document();
                        commentDetailsDoc.load(commentDetailsXML);
                        Dom.XmlNode commentDetailsRoot=commentDetailsDoc.getRootElement();
                        List<Dom.XmlNode> commentDetailNodeList=commentDetailsRoot.getChildElements();
                        
                        for(Dom.XmlNode commentDetailNode:commentDetailNodeList){
                            HttpCalloutVO.UWComment uwComment=new HttpCalloutVO.UWComment();
                            uwComment.policyNumber=policyNumber;
                            uwComment.appianRequestID=requestId;
                            uwComment.commentedBy=getChildNodeTextIfNotEmpty('commentedBy',commentDetailNode);
                            String commentDateTimeStr=getChildNodeTextIfNotEmpty('commentedDateTime',commentDetailNode);
                            uwComment.commentedDateTime=String.isNotBlank(commentDateTimeStr)?Date.valueOf(commentDateTimeStr):null;
                            uwComment.comments=getChildNodeTextIfNotEmpty('comments',commentDetailNode);
                            objList.add(uwComment);
                        }
                    }
                }
            }
        }catch(Exception e){
            system.debug('processUWCommentResult exception:'+e);
        }
        //system.debug('>>>>> List<HttpCalloutVO.UWComment> >>>>> '+objList.size());
        system.debug('List<HttpCalloutVO.UWComment> '+objList);
        return objList;
    }
      
    // JR1774 - [[
    /*
    * verifyPolicyInfo
    * Author: Lawrence BP Wong
    * Project code: JR1774
    * For credit card number validation.
    *
    * @param:
    *     1) Policy number using the credit card number for settling the payment of the policy (String); 
    *     2) Credit card number for settling the payment of the policy number of 1) (String);
    * @decs: Call VerifyPolicyInfo WS to get the validation result of the credit card number.
    * @return List<HttpCalloutVO.CreditCardNumber>
    */
    public List<HttpCalloutVO.CreditCardNumber> verifyPolicyInfo(String policyNumber,String creditCardNumber){
        system.debug('PolicyCalloutHelper.verifyPolicyInfo');
        //system.debug('[PolicyCalloutHelper][verifyPolicyInfo] - Current User: '+UserInfo.getName()+' ('+UserInfo.getUserName()+')');
        //system.debug('[PolicyCalloutHelper][verifyPolicyInfo] - Inputted Parameters - 1) Policy Number(policyNumber): '+((null!=policyNumber)?policyNumber:'')
        //    +'; 2) Credit Card Number: '+((null!=creditCardNumber)?creditCardNumber:''));
        if(null!=policyNumber){
            policyNumber=policyNumber.trim();
        }
        if(null!=creditCardNumber){
            creditCardNumber=creditCardNumber.trim();
        }
        this.functionName=PolicyCalloutHelper.VerifyPolicyInfo;
        
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        paramsMap.put('CreditCard',creditCardNumber);
        try{
            this.appName=PolicyCalloutHelper.WEB_PORTAL_APPNAME;
            return (List<HttpCalloutVO.CreditCardNumber>)execute(new Map<String,String>());
        } catch (Exception e){
            system.debug('[PolicyCalloutHelper][verifyPolicyInfo] - The information provided for validation by verifyPolicyInfo web-service is invalid! The <ResultInfoDesc> from response: '+e.getMessage());
            return null;
        }
    }
    
    /*
    * processVerifyPolicyInfoResult
    * Author: Lawrence BP Wong
    * Project code: JR1774
    * For credit card number validation.
    *
    * @param: Dom.document
    * @decs: Handle VerifyPolicyInfo WS result.
    * @return List<HttpCalloutVO.CreditCardNumber>
    */
    public List<HttpCalloutVO.CreditCardNumber> processVerifyPolicyInfoResult(Dom.document doc){
        system.debug('PolicyCalloutHelper.processVerifyPolicyInfoResult');
        //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - Current User: '+UserInfo.getName()+' ('+UserInfo.getUserName()+')');
        List<HttpCalloutVO.CreditCardNumber> objList=new List<HttpCalloutVO.CreditCardNumber>();
        HttpCalloutVO.CreditCardNumber creditCardNo=new HttpCalloutVO.CreditCardNumber(); // AH18454
        if(!this.isCalloutSuccessfully){
            creditCardNo.isWebServiceCallSuccess=false;    // AH18454
            //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - [Failure] Callout failed!');
            return objList;
        }else{
            creditCardNo.isWebServiceCallSuccess=true;    // AH18454
            //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - Callout Succeed!');
            Dom.XmlNode root=doc.getRootElement();
            Dom.XmlNode TXServiceResponseNode=getTXObjectResponseNode(doc);
            Dom.XmlNode transResultNode=getChildNodeIfNotNull('TransResult',TXServiceResponseNode);
            List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(transResultNode);
            //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - Total child node within <TransResult>: '+((null!=childNodes)?childNodes.size():0));

            String resultCode=getChildNodeAttributeIfNotEmpty('ResultCode','tc',transResultNode);
            //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - TC of Result Code: '+((null!=resultCode)?resultCode:''));
            // if(resultCode=='1'){    // AH18454 - Commented
            if(resultCode=='1' || resultCode=='5'){    // AH18454
                //Dom.XmlNode nodeResultCode=getChildNodeIfNotNull('ResultCode',transResultNode);
                //HttpCalloutVO.CreditCardNumber creditCardNo=new HttpCalloutVO.CreditCardNumber();    // AH18454 - Commented
                String szIsCreditCardNumberValid=getChildNodeTextIfNotEmpty('ResultCode',transResultNode);
                //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - Value if <ResultCode>: '+((null!=szIsCreditCardNumberValid)?szIsCreditCardNumberValid:''));
                //if(null==szIsCreditCardNumberValid){    // AH18454 - Commented
                // AH18454 - [[
                //szIsCreditCardNumberValid=null;    // AH18454 - POC Only
                if(null!=szIsCreditCardNumberValid){
                    if(!szIsCreditCardNumberValid.equalsIgnoreCase('Success')){
                // ]] - AH18454
                        //system.debug('[PolicyCalloutHelper][processVerifyPolicyInfoResult] - [Warning] The IsCreditCardNumberValid field from WS response is null! Thus,set the response value to be false.');
                        creditCardNo.isCreditCardNumberValid=false;
                    }else{
                        szIsCreditCardNumberValid=szIsCreditCardNumberValid .trim();
                        szIsCreditCardNumberValid=szIsCreditCardNumberValid .toUpperCase();
                        if(0=='SUCCESS'.compareTo(szIsCreditCardNumberValid)){
                            creditCardNo.isCreditCardNumberValid=true;
                        }else{
                            creditCardNo.isCreditCardNumberValid=false;
                        }
                    }
                // AH18454 - [[
                }else{
                    creditCardNo.isCreditCardNumberValid=false;
                    creditCardNo.isWebServiceCallSuccess=false;
                }
                // ]] - AH18454
                
                String szMessage='[PolicyCalloutHelper][processVerifyPolicyInfoResult] - The policy validation result is ';
                if(creditCardNo.isCreditCardNumberValid){
                    szMessage=szMessage+'valid.';
                }else{
                    szMessage=szMessage+'invalid.';
                }
                //system.debug(szMessage);
                objList.add(creditCardNo);
            } // AH18454 - Commented

            system.debug('>>>>> List<HttpCalloutVO.CreditCardNumber> >>>>> '+objList.size());
            return objList;
        }
    }
    // ]] - JR1774
    
    /*
     * add by kit for CR CS Policy Transaction History
     */
    public List<HttpCalloutVo.TransactionHistory> getPolicyTransactionHistory(String policyNumber){
        this.functionName=PolicyCalloutHelper.GetPolicyTransactionHistory;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',policyNumber);
        return (List<HttpCalloutVO.TransactionHistory>)execute(new Map<String,String>());
    }
    
    public List<HttpCalloutVO.TransactionHistory> processPolicyTransactionHistoryResult(Dom.document doc){
        List<HttpCalloutVO.TransactionHistory> policyTransactionHistoryList=new List<HttpCalloutVO.TransactionHistory>();
        if(!this.isCalloutSuccessfully){
            return policyTransactionHistoryList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        Dom.XmlNode holdingNode=getChildNodeIfNotNull('Holding',oLifeNode);
        Dom.XmlNode extensionNode=getChildNodeIfNotNull('OLifEExtension',holdingNode);
        List<Dom.XmlNode> policyTransactionNodes=getChildElementsIfNotNull(extensionNode);
        for(Dom.XmlNode p: policyTransactionNodes){
            List<Dom.XmlNode> childNodeList=getChildElementsIfNotNull(p);
            HttpCalloutVO.TransactionHistory transactionHistroy=new HttpCalloutVO.TransactionHistory();
            transactionHistroy.benefitLevelChangeList=new List<HttpCalloutVO.benefitLevelChange>();
            transactionHistroy.beneficiaryChangeList=new List<HttpCalloutVO.BeneficiaryChange>();
            //start to dom parse
            transactionHistroy.seqNum=getChildNodeTextIfNotEmpty('SeqNum',p);
            transactionHistroy.status=getChildNodeTextIfNotEmpty('Status',p);
            transactionHistroy.effective=getChildNodeDateIfNotEmpty('EffDate',p,'yyyy-MM-dd');
            transactionHistroy.userId=getChildNodeTextIfNotEmpty('UserID',p);
            transactionHistroy.transactionDate=getChildNodeDateIfNotEmpty('TransactionDate',p,'yyyy-MM-dd');
            transactionHistroy.sellerId=getChildNodeTextIfNotEmpty('SellerID',p);
            transactionHistroy.premiumAmount=getChildNodeTextIfNotEmpty('PremiumAmount',p);
            transactionHistroy.paymentMode=getChildNodeTextIfNotEmpty('PaymentMode',p);
            transactionHistroy.PremiumChangeAmount=getChildNodeTextIfNotEmpty('PremiumChangeAmount',p);
            transactionHistroy.premiumOverrideAmount=getChildNodeTextIfNotEmpty('PremiumOverrideAmount',p);
            transactionHistroy.suspendReason=getChildNodeTextIfNotEmpty('SuspendReason',p);
            transactionHistroy.unsuspendDate=getChildNodeDateIfNotEmpty('UnsuspendDate',p,'yyyy-MM-dd');
            transactionHistroy.unsuspendUserID=getChildNodeTextIfNotEmpty('UnsuspendUserID',p);
            transactionHistroy.cancellationReason=getChildNodeTextIfNotEmpty('CancellationReason',p);
            transactionHistroy.adjustmentAmount=getChildNodeTextIfNotEmpty('AdjustmentAmount',p);
            transactionHistroy.adjustmentReason=getChildNodeTextIfNotEmpty('AdjustmentReason',p);
            
            Dom.XmlNode accountNumberNode=getChildNodeIfNotNull('AccountNumberChange',p);
            if(accountNumberNode!=null){
                transactionHistroy.hasAccountNumberChange=true;
            }else{
                transactionHistroy.hasAccountNumberChange=false;
            }
            transactionHistroy.accountNumberChange_ValueFrom=getChildNodeTextIfNotEmpty('ValueFrom',accountNumberNode);
            transactionHistroy.accountNumberChange_ValueTo=getChildNodeTextIfNotEmpty('ValueTo',accountNumberNode);
            
            Dom.XmlNode creditCardNumberNode=getChildNodeIfNotNull('CreditCardNumberChange',p);
            if(creditCardNumberNode!=null){
                transactionHistroy.hasCreditCardNumberChange=true;
            }else{
                transactionHistroy.hasCreditCardNumberChange=false;
            }
            transactionHistroy.creditCardNumberChange_ValueFrom=getChildNodeTextIfNotEmpty('ValueFrom',creditCardNumberNode);
            transactionHistroy.creditCardNumberChange_ValueTo=getChildNodeTextIfNotEmpty('ValueTo',creditCardNumberNode);
            
            //add for mask the credit card No
            if(String.isNotEmpty(transactionHistroy.accountNumberChange_ValueFrom)){
                String maskCardNoFrom=transactionHistroy.accountNumberChange_ValueFrom;
                maskCardNoFrom=maskCardNoFrom.substring(0,4)+'********'+maskCardNoFrom.substring(12,maskCardNoFrom.length());
                transactionHistroy.accountNumberChange_ValueFrom=maskCardNoFrom;
            }
            if(String.isNotEmpty(transactionHistroy.accountNumberChange_ValueTo)){
                String maskCardNoTo=transactionHistroy.accountNumberChange_ValueTo;
                maskCardNoTo=maskCardNoTo.substring(0,4)+'********'+maskCardNoTo.substring(12,maskCardNoTo.length());
                transactionHistroy.accountNumberChange_ValueTo=maskCardNoTo;
            }
            transactionHistroy.taxExclusion=getChildNodeTextIfNotEmpty('TaxExclusion',p);
            transactionHistroy.campaignCode=getChildNodeTextIfNotEmpty('CampaignCode',p);
            transactionHistroy.campaignSplit=getChildNodeTextIfNotEmpty('CampaignSplit',p);
            transactionHistroy.packageShortName=getChildNodeTextIfNotEmpty('PackageShortName',p);
            
            for(Dom.XmlNode childNode:childNodeList){
                if(childNode.getName()=='BenefitLevelChange'){
                    HttpCalloutVO.BenefitLevelChange benefitLevelChange=new HttpCalloutVO.BenefitLevelChange();
                    benefitLevelChange.beneficiaryName=getChildNodeTextIfNotEmpty('BeneficiaryName',childNode);
                    benefitLevelChange.productCode=getChildNodeTextIfNotEmpty('ProductCode',childNode);
                    benefitLevelChange.valueFrom=getChildNodeTextIfNotEmpty('ValueFrom',childNode);
                    benefitLevelChange.valueTo=getChildNodeTextIfNotEmpty('ValueTo',childNode);
                    benefitLevelChange.relationship=getChildNodeTextIfNotEmpty('Relationship',childNode);
                    benefitLevelChange.action=getChildNodeTextIfNotEmpty('Action',childNode);
                    transactionHistroy.benefitLevelChangeList.add(benefitLevelChange);
                }
                if(childNode.getName()=='BeneficiaryChange'){
                    HttpCalloutVO.BeneficiaryChange beneficiaryChange=new HttpCalloutVO.BeneficiaryChange();
                    beneficiaryChange.beneficiaryName=getChildNodeTextIfNotEmpty('BeneficiaryName',childNode);
                    beneficiaryChange.productName=getChildNodeTextIfNotEmpty('ProductName',childNode);
                    transactionHistroy.beneficiaryChangeList.add(beneficiaryChange);
                }
            }
            transactionHistroy.coverageChangeInd=getChildNodeTextIfNotEmpty('CoverageChangeInd',p);
            
            Dom.XmlNode overrideExpireDateChangeNode=getChildNodeIfNotNull('OverrideExpireDateChange',p);
            if(overrideExpireDateChangeNode!=null){
                transactionHistroy.hasOverrideExpireDateChange=true;
            }else{
                transactionHistroy.hasOverrideExpireDateChange=false;
            }
            transactionHistroy.overrideExpireDateChange_valueFrom=getChildNodeTextIfNotEmpty('ValueFrom',overrideExpireDateChangeNode);
            transactionHistroy.overrideExpireDateChange_ValueTo=getChildNodeTextIfNotEmpty('ValueTo',overrideExpireDateChangeNode);
            
            transactionHistroy.notes=getChildNodeTextIfNotEmpty('Notes',p);
            transactionHistroy.productName=getChildNodeTextIfNotEmpty('ProductName',p);
                       
            if(transactionHistroy.benefitLevelChangeList.size()>0){
                transactionHistroy.hasBenefitLevelChange=true;
            }else{
               transactionHistroy.hasBenefitLevelChange=false;
            }
            
            if(transactionHistroy.beneficiaryChangeList.size()>0){
                transactionHistroy.hasBeneficiaryChange=true;
            }else{
                transactionHistroy.hasBeneficiaryChange=false;
            }
            policyTransactionHistoryList.add(transactionHistroy);
        }
        return policyTransactionHistoryList;
    }
    /** end add **/
    
    //CS Member Level Jack add begin
    public List<HttpCalloutVO.auditLog> GetAuditTrail(String policyNumber,String certNumber,String dateFrom,String dateTo){
        system.debug('PolicyCalloutHelper.GetAuditTrail');
        this.functionName=PolicyCalloutHelper.GetAuditTrail;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',String.isNotBlank(policyNumber)?policyNumber:'');
        paramsMap.put('CertificateNo',String.isNotBlank(certNumber)?certNumber:'');
        paramsMap.put('SubmissionDateTimeFrom',String.isNotBlank(dateFrom)?dateFrom:'');
        paramsMap.put('SubmissionDateTimeTo',String.isNotBlank(dateTo)?dateTo:'');
        return (List<HttpCalloutVO.auditLog>)execute(new Map<String,String>());
    }
    
    public List<HttpCalloutVO.auditLog> processAuditTrailListBasic(Dom.document doc){
        List<HttpCalloutVO.auditLog> auditList=new List<HttpCalloutVO.auditLog>();
        system.debug('PolicyCalloutHelper.processAuditTrailListBasic');
        if(!this.isCalloutSuccessfully){
            return auditList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
               
            }
            if(childNode.getName()=='Party'){
                List<Dom.XmlNode> partyChildNodes=getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode partyChildNode:partyChildNodes){
                    if(partyChildNode.getName()=='TrackedChange'){
                        HttpCalloutVO.auditLog audit=new HttpCalloutVO.auditLog();
                        audit.fieldCode=getChildNodeTextIfNotEmpty('FieldCode',partyChildNode);
                        audit.fieldName=getChildNodeTextIfNotEmpty('FieldName',partyChildNode);
                        audit.valueFrom=getChildNodeTextIfNotEmpty('ValueFrom',partyChildNode);
                        audit.valueTo=getChildNodeTextIfNotEmpty('ValueTo',partyChildNode);
                        audit.updateUser=getChildNodeTextIfNotEmpty('UpdateUser',partyChildNode);
                        audit.updateDate=getChildNodeTextIfNotEmpty('UpdateDate',partyChildNode);
                        audit.updateTime=getChildNodeTextIfNotEmpty('UpdateTime',partyChildNode);
                        auditList.add(audit);
                    }
                }
            }
        }
        system.debug('auditList size:'+auditList);
        return auditList;
    }
    //CS Member Level Jack add end
    
    //policy replacement jack add begin
    public List<HttpCalloutVO.policyReplacement> GetPolicyReplacementChangeHistory(String policyNumber,String HolderGovtID,Date filterDate){
        system.debug('PolicyCalloutHelper.GetPolicyReplacementChangeHistory');
        this.functionName=PolicyCalloutHelper.GetPolicyReplacementChangeHistory;
        paramsMap=new Map<String,String>();
        paramsMap.put('PolNumber',String.isNotBlank(policyNumber)?policyNumber:'');
        paramsMap.put('HolderGovtID',String.isNotBlank(HolderGovtID)?HolderGovtID:'');
        String filterDateStr;
        if(filterDate==Null){
            String datetimeStr=DateTime.now().formatGmt('yyyy-MM-dd HH:mm:ss');
            filterDateStr=datetimeStr.substring(0,10);
        }else{
            Datetime dt=(DateTime)filterDate;
            filterDateStr=dt.format('YYYY-MM-DD');
        }
        paramsMap.put('FilterDate',filterDateStr);
        return (List<HttpCalloutVO.policyReplacement>)execute(new Map<String,String>());
    }
     
    public List<HttpCalloutVO.policyReplacement> processPolicyReplacementChangeResult(Dom.document doc){
        List<HttpCalloutVO.policyReplacement> oList=new List<HttpCalloutVO.policyReplacement>();
        system.debug('PolicyCalloutHelper.processAuditTrailListBasic');
        if(!this.isCalloutSuccessfully){
            return oList;
        }
        Dom.XmlNode root=doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode=getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode=getChildNodeIfNotNull('OLifE',TXLifeResponseNode);
        List<Dom.XmlNode> childNodes=getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode:childNodes){
            if(childNode.getName()=='Holding'){
                Dom.XmlNode policyNode=getChildNodeIfNotNull('Policy',childNode);
                HttpCalloutVO.policyReplacement rInfo=new HttpCalloutVO.policyReplacement();
                rInfo.polNumber=getChildNodeTextIfNotEmpty('PolNumber',policyNode);
                rInfo.policyReplacementEffectiveDate=getChildNodeDateIfNotEmpty('PolicyReplacementEffectiveDate',policyNode,'yyyy-MM-dd');
                rInfo.applicationDate=getChildNodeDateIfNotEmpty('ApplicationDate',policyNode,'yyyy-MM-dd');
                
                Dom.XmlNode clientNotification=getChildNodeIfNotNull('ClientNotification',policyNode);
                rInfo.notificationDate=getChildNodeDateIfNotEmpty('NotificationDate',clientNotification,'yyyy-MM-dd');
                rInfo.notificationType=getChildNodeTextIfNotEmpty('NotificationType',clientNotification);
                
                Dom.XmlNode clientAcknowledgement=getChildNodeIfNotNull('ClientAcknowledgement',policyNode);
                rInfo.acknowledgementDate=getChildNodeDateIfNotEmpty('AcknowledgementDate',clientAcknowledgement,'yyyy-MM-dd');
                rInfo.acknowledgementType=getChildNodeTextIfNotEmpty('AcknowledgementType',clientAcknowledgement);
                
                List<HttpCalloutVO.replacementInfo> replacementList=new List<HttpCalloutVO.replacementInfo>();
                List<Dom.XmlNode> policyChildNodes=getChildElementsIfNotNull(policyNode);
                system.debug('processPolicyReplacementChangeResult policyChildNodes'+policyChildNodes.size());
                for(Dom.XmlNode pchild:policyChildNodes){
                    if(pchild.getName()=='ReplacementPolicy'){
                        HttpCalloutVO.replacementInfo replacement=new HttpCalloutVO.replacementInfo();
                        replacement.replacementPolicyNumber=getChildNodeTextIfNotEmpty('ReplacementPolicyNumber',pchild);
                        replacement.productCode=getChildNodeTextIfNotEmpty('ProductCode',pchild);
                        replacement.planName=getChildNodeTextIfNotEmpty('PlanName',pchild);
                        replacement.sourceSystem=getChildNodeTextIfNotEmpty('SourceSystem',pchild);
                        replacement.changeDate=getChildNodeDateIfNotEmpty('ChangeDate',pchild,'yyyy-MM-dd');
                        replacement.shortCode=getChildNodeTextIfNotEmpty('ShortCode',pchild);
                        replacement.details=getChildNodeTextIfNotEmpty('Details',pchild);
                        replacementList.add(replacement);
                    }
                }
                rInfo.replacementInfoList=replacementList;
                oList.add(rInfo);
            }
        }
        return oList;
    }
    //policy replacement jack add end

    //added by Connor CP-156(Client Portal)
    public List<HttpCalloutVO.Shortfall> GetPersonShortfallBasicByCriteria(String policyNumber,String memberName, String govtID, String employeeId, String shortfallStatus, String shortfallDate, String branchCode,String familyRecInd,String claimNo){
        system.debug('PolicyCalloutHelper.GetPersonShortfallBasicByCriteria');
        this.functionName = PolicyCalloutHelper.GetPersonShortfallBasicByCriteria;
        paramsMap = new Map<String, String>();
        paramsMap.put('ShorfallDate', String.isNotBlank(shortfallDate) ? shortfallDate : '');
        paramsMap.put('PolNumber', String.isNotBlank(policyNumber) ? policyNumber : '');
        paramsMap.put('InsuredMemberFullName', memberName);
        paramsMap.put('ssnNumber', String.isNotBlank(govtID) ? govtID : '');
        paramsMap.put('StaffId', String.isNotBlank(employeeId) ? employeeId : '');
        paramsMap.put('ShortfallStatus', String.isNotBlank(shortfallStatus) ? shortfallStatus : '');
        paramsMap.put('BranchCode', String.isNotBlank(branchCode) ? branchCode : '');
        paramsMap.put('FamilyRecInd', String.isNotBlank(familyRecInd) ? familyRecInd : '');
        paramsMap.put('ClaimNumber', String.isNotBlank(claimNo) ? claimNo : '');
        return (List<HttpCalloutVO.Shortfall>)execute(new Map<String, String>());

    }

    //added by chris (Client Portal)
    public List<HttpCalloutVO.Shortfall> GetPersonShortfallBasicByCriteria(String policyNumber,String hOClaimReferenceID){
        system.debug('PolicyCalloutHelper.GetPersonShortfallBasicByCriteria');
        this.functionName = PolicyCalloutHelper.GetPersonShortfallBasicByCriteria;
        paramsMap = new Map<String, String>();
        paramsMap.put('PolNumber', String.isNotBlank(policyNumber) ? policyNumber : '');
        paramsMap.put('hOClaimReferenceID', String.isNotBlank(hOClaimReferenceID) ? hOClaimReferenceID : '');
        return (List<HttpCalloutVO.Shortfall>)execute(new Map<String, String>());
    }

    //added by Connor CP-156(Client Portal)
    public List<HttpCalloutVO.Shortfall> processPersonShortfallBasicByCriteria(Dom.document doc){
        List<HttpCalloutVO.Shortfall> oList = new List<HttpCalloutVO.Shortfall>();
        system.debug('PolicyCalloutHelper.processPersonShortfallBasicByCriteria');
        if(!this.isCalloutSuccessfully){
            return oList;
        }

        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode = getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode = getChildNodeIfNotNull('OLifE', TXLifeResponseNode);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oLifeNode);
        Map<String,String> policyMap = new Map<String,String>();
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Holding'){
                String holdId = childNode.getAttributeValue('id',null);
                System.debug('holdId-='+holdId);
                Dom.XmlNode holdChildNodes = getChildNodeIfNotNull('Policy',childNode);
                String policyNo = getChildNodeTextIfNotEmpty('PolNumber',holdChildNodes);
                policyMap.put(holdId, policyNo);
                System.debug('policyNo1-='+policyNo);
            }else if(childNode.getName() == 'Party'){
                String partyId = childNode.getAttributeValue('id',null);
                System.debug('policyMap1-='+policyMap.size());
                if(policyMap.size()>0){
                    System.debug('policyMap2-='+policyMap.size());
                    Integer i;
                    for(i=0;i<policyMap.size();i++){
                        if(policyMap.containsKey('Holding'+String.valueOf(i+1))&&partyId=='Party'+String.valueOf(i)){
                            List<Dom.XmlNode> partyChildNodes = getChildElementsIfNotNull(childNode);
                            for(Dom.XmlNode partyChildNode : partyChildNodes){
                                if(partyChildNode.getName() == 'OLifEExtension'){
                                    List<Dom.XmlNode> oLifEExtensionchildNodes = getChildElementsIfNotNull(partyChildNode);
                                    for(Dom.XmlNode oLifEExtensionchildNode : oLifEExtensionchildNodes){
                                        HttpCalloutVO.Shortfall shortfall = new HttpCalloutVO.Shortfall();
                                        // shortfall.PolicyNumber = policyNo;
                                        shortfall.PolicyNumber = policyMap.get('Holding'+String.valueOf(i+1));
                                        shortfall.FullName = getChildNodeTextIfNotEmpty('FullName',childNode);
                                        shortfall.CertificateNo = getChildNodeTextIfNotEmpty('CertificateNo',partyChildNode);
                                        if(oLifEExtensionchildNode.getName() == 'Shortfall'){

                                            shortfall.ShortfallDate = getChildNodeDateFromSpecialDateTimeIfNotEmpty('ShortfallDate',oLifEExtensionchildNode);
                                            shortfall.PlanName = getChildNodeTextIfNotEmpty('PlanName',oLifEExtensionchildNode);
                                            shortfall.ConsultationDate = getChildNodeTextIfNotEmpty('ConsultationDate',oLifEExtensionchildNode);
                                            shortfall.HoldClaimIndicator = getChildNodeTextIfNotEmpty('HoldClaimIndicator',oLifEExtensionchildNode);
                                            shortfall.ShortfallFullySettledDate=getChildNodeTextIfNotEmpty('ShortfallFullySettledDate',oLifEExtensionchildNode);
                                            shortfall.ShortfallAmount = getChildNodeTextIfNotEmpty('ShortfallAmount',oLifEExtensionchildNode);
                                            shortfall.ShortfallAmountCurrencyCode = getChildNodeTextIfNotEmpty('ShortfallAmountCcyCode',oLifEExtensionchildNode);
                                            shortfall.ShortfallOutStandingAmount = getChildNodeTextIfNotEmpty('ShortfallOutStandingAmount',oLifEExtensionchildNode);
                                            shortfall.DebitNoteNo = getChildNodeTextIfNotEmpty('DebitNoteNo',oLifEExtensionchildNode);
                                            shortfall.ClaimNo = getChildNodeTextIfNotEmpty('ClaimNo',oLifEExtensionchildNode);
                                            shortfall.DateOfService = getChildNodeDateFromSpecialDateTimeIfNotEmpty('DateOfService',oLifEExtensionchildNode);
                                            shortfall.NameOfClaimant = getChildNodeTextIfNotEmpty('NameOfClaimant',oLifEExtensionchildNode);
                                            shortfall.ShortfallOutStandingDate = getChildNodeTextIfNotEmpty('ShortfallOutStandingDate',oLifEExtensionchildNode);
                                            shortfall.ShortfallStatus = getChildNodeTextIfNotEmpty('ShortfallStatus',oLifEExtensionchildNode);
                                            //shortfall.CertificateNo = getChildNodeTextIfNotEmpty('CertificateNo',oLifEExtensionchildNode);
                                            shortfall.BranchDesc = getChildNodeTextIfNotEmpty('BranchDesc',oLifEExtensionchildNode);
                                            //shortfall.FullName = getChildNodeTextIfNotEmpty('FullName',oLifEExtensionchildNode);
                                            shortfall.ShortfallAmountwCurrency = ((isDecimal(shortfall.ShortfallAmount))?shortfall.ShortfallAmountCurrencyCode+' '+shortfall.ShortfallAmount:shortfall.ShortfallAmount);
                                            shortfall.ShortfallOSAmountwCurrency = ((isDecimal(shortfall.ShortfallOutStandingAmount))?shortfall.ShortfallAmountCurrencyCode+' '+shortfall.ShortfallOutStandingAmount:shortfall.ShortfallOutStandingAmount);
                                            oList.add(shortfall);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return oList;
    }

    //added by Connor CP-156(Client Portal)
    public List<HttpCalloutVO.PersonMovement> GetPersonMovementHistory(String memberName, String endorsementNo, String memberCertNo, String policyYear,String policyNumber){
        system.debug('PolicyCalloutHelper.GetPersonMovementHistory');
        this.functionName = PolicyCalloutHelper.GetPersonMovementHistory;
        paramsMap = new Map<String, String>();
        paramsMap.put('InsuredMemberFullName', String.isNotBlank(memberName) ? memberName : '');
        paramsMap.put('CertificateNo', String.isNotBlank(memberCertNo) ? memberCertNo : '');
        paramsMap.put('EndorsementNo', String.isNotBlank(endorsementNo) ? endorsementNo : '');
        paramsMap.put('PolYear', String.isNotBlank(policyYear) ? policyYear : '');
        paramsMap.put('PolNumber', String.isNotBlank(policyNumber) ? policyNumber : '');
        return (List<HttpCalloutVO.PersonMovement>)execute(new Map<String, String>());

    }

    //added by Connor CP-156(Client Portal)
    public List<HttpCalloutVO.PersonMovement> processPersonMovementHistory(Dom.document doc){
        List<HttpCalloutVO.PersonMovement> oList = new List<HttpCalloutVO.PersonMovement>();
        system.debug('PolicyCalloutHelper.processPersonMovementHistory');
        if(!this.isCalloutSuccessfully){
            return oList;
        }

        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode = getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode = getChildNodeIfNotNull('OLifE', TXLifeResponseNode);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oLifeNode);

        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Party'){
                HttpCalloutVO.PersonMovement movement = new HttpCalloutVO.PersonMovement();
                movement.MaritalStatus = getChildNodeTextIfNotEmpty('MaritalStatus',childNode);
                movement.CountryOfResidence = getChildNodeTextIfNotEmpty('CountryOfResidence',childNode);
                movement.Nationality = getChildNodeTextIfNotEmpty('NationalityDesc',childNode);
                List<Dom.XmlNode> partyChildNodes = getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode partyChildNode : partyChildNodes){
                    if(partyChildNode.getName() == 'Person'){
                        List<Dom.XmlNode> oLifEExtensionchildNodes = getChildElementsIfNotNull(partyChildNode);
                        for(Dom.XmlNode oLifEExtensionchildNode : oLifEExtensionchildNodes){
                            if(oLifEExtensionchildNode.getName() == 'OLifEExtension'){
                                movement.EndorsementNo = getChildNodeTextIfNotEmpty('EndorsementNo',oLifEExtensionchildNode);
                                movement.EndorsementDate = getChildNodeDateIfNotEmpty('EndorsementDate',oLifEExtensionchildNode,'yyyy-MM-dd');
                                movement.MemberName = getChildNodeTextIfNotEmpty('MemberName',oLifEExtensionchildNode);
                                movement.EffectiveDate = getChildNodeDateIfNotEmpty('EffectiveDate',oLifEExtensionchildNode,'yyyy-MM-dd');
                                movement.PlanNumber = getChildNodeTextIfNotEmpty('PlanDesc',oLifEExtensionchildNode);
                                movement.SubPlanNumber = getChildNodeTextIfNotEmpty('SubPlanNumber',oLifEExtensionchildNode);
                                movement.Sex = getChildNodeTextIfNotEmpty('Sex',oLifEExtensionchildNode);
                                movement.DateOfBirth = getChildNodeDateIfNotEmpty('DateOfBirth',oLifEExtensionchildNode,'yyyy-MM-dd');
                                movement.Age = getChildNodeIntegerIfNotEmpty('Age',oLifEExtensionchildNode);
                                movement.IDType = getChildNodeTextIfNotEmpty('IDType',oLifEExtensionchildNode);
                                movement.IDNumber = getChildNodeTextIfNotEmpty('IDNumber',oLifEExtensionchildNode);
                                movement.groupPersonMovement = getChildNodeTextIfNotEmpty('Group',oLifEExtensionchildNode);
                                movement.Branch = getChildNodeTextIfNotEmpty('BranchCode',oLifEExtensionchildNode);
                                movement.Department = getChildNodeTextIfNotEmpty('Department',oLifEExtensionchildNode);
                                movement.EmploymentDate = getChildNodeDateIfNotEmpty('EmploymentDate',oLifEExtensionchildNode,'yyyy-MM-dd');
                                movement.PreExist = getChildNodeTextIfNotEmpty('PreExist',oLifEExtensionchildNode);
                                movement.CertNo = getChildNodeTextIfNotEmpty('CertificateNo',oLifEExtensionchildNode);
                                List<Dom.XmlNode> bankAccountNodes = getChildElementsIfNotNull(oLifEExtensionchildNode);
                                for(Dom.XmlNode bankAccountNode : bankAccountNodes){
                                    if(bankAccountNode.getName() == 'BankAccount'){
                                        movement.BankAccNo = getChildNodeTextIfNotEmpty('AccountNumber',bankAccountNode);
                                        movement.BankCode = getChildNodeTextIfNotEmpty('BankCode',bankAccountNode);
                                    }
                                }
                                //movement.MaritalStatus = getChildNodeTextIfNotEmpty('MaritalStatus',oLifEExtensionchildNode);
                                movement.EmailAddress = getChildNodeTextIfNotEmpty('EmailAddress',oLifEExtensionchildNode);
                                movement.Salary = getChildNodeTextIfNotEmpty('Salary',oLifEExtensionchildNode).equalsIgnoreCase('null') ? '' : getChildNodeTextIfNotEmpty('Salary',oLifEExtensionchildNode);
                                movement.Occupation = getChildNodeTextIfNotEmpty('Occupation',oLifEExtensionchildNode);
                                movement.StationedCountry = getChildNodeTextIfNotEmpty('StationedCountry',oLifEExtensionchildNode);
                                movement.StaffID = getChildNodeTextIfNotEmpty('StaffID',oLifEExtensionchildNode);
                                movement.Alias = getChildNodeTextIfNotEmpty('Alias',oLifEExtensionchildNode);
                                movement.CorrespondenceAddress = getChildNodeTextIfNotEmpty('CorrespondenceAddress',oLifEExtensionchildNode);
                                //movement.CountryOfResidence = getChildNodeTextIfNotEmpty('CountryOfResidence',oLifEExtensionchildNode);
                                //movement.Nationality = getChildNodeTextIfNotEmpty('Nationality',oLifEExtensionchildNode);
                                movement.MobileNumber = getChildNodeTextIfNotEmpty('MobileNumber',oLifEExtensionchildNode);
                                movement.HomeNumber = getChildNodeTextIfNotEmpty('HomeNumber',oLifEExtensionchildNode);
                                movement.OfficeNumber = getChildNodeTextIfNotEmpty('OfficeNumber',oLifEExtensionchildNode);
                                movement.FamilyRecInd = getChildNodeTextIfNotEmpty('FamilyRecInd',oLifEExtensionchildNode);
                                oList.add(movement);
                            }
                        }
                    }
                }
            }
        }
        return oList;
    }

    //added by Connor CP-163(Client Portal)
    public List<HttpCalloutVO.MovementResult> GetClientMemberMovementResult(String companyCode, String branchCode, String policyNumber, String deptCode){
        system.debug('PolicyCalloutHelper.GetClientMemberMovementResult');
        this.functionName = PolicyCalloutHelper.GetClientMemberMovementResult;
        paramsMap = new Map<String, String>();
        paramsMap.put('CompanyCode', String.isNotBlank(companyCode) ? companyCode : '');
        paramsMap.put('BranchCode', String.isNotBlank(branchCode) ? branchCode : '');
        paramsMap.put('PolNumber', String.isNotBlank(policyNumber) ? policyNumber : '');
        paramsMap.put('DeptCode', String.isNotBlank(deptCode) ? deptCode : '');
        return (List<HttpCalloutVO.MovementResult>)execute(new Map<String, String>());

    }

    //added by Connor CP-163(Client Portal)
    public List<HttpCalloutVO.MovementResult> processMemberMovementResult(Dom.document doc){
        List<HttpCalloutVO.MovementResult> oList = new List<HttpCalloutVO.MovementResult>();
        system.debug('PolicyCalloutHelper.processMemberMovementResult');
        if(!this.isCalloutSuccessfully){
            return oList;
        }

        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode = getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode = getChildNodeIfNotNull('OLifE', TXLifeResponseNode);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Holding'){
                HttpCalloutVO.MovementResult movementResult = new HttpCalloutVO.MovementResult();
                Dom.XmlNode processNodes = getChildNodeIfNotNull('Process',childNode);
                movementResult.ProcessID = getChildNodeTextIfNotEmpty('ProcessID',processNodes);
                movementResult.ProcessStatus = getChildNodeTextIfNotEmpty('ProcessStatus',processNodes);
                movementResult.FileName = getChildNodeTextIfNotEmpty('FileName',processNodes);
                movementResult.FileID = getChildNodeTextIfNotEmpty('FileID',processNodes);
                movementResult.ActionDate = getChildNodeTextIfNotEmpty('ActionDate',processNodes);
                Dom.XmlNode resultNodes = getChildNodeIfNotNull('Result',childNode);
                movementResult.ResultFileName = getChildNodeTextIfNotEmpty('FileName',resultNodes);
                movementResult.ResultFileID = getChildNodeTextIfNotEmpty('FileID',resultNodes);
                Dom.XmlNode reportListNodes = getChildNodeIfNotNull('ReportList',childNode);
                List<Dom.XmlNode> reportNodes = getChildElementsIfNotNull(reportListNodes);
                List<HttpCalloutVO.Report> reports = new List<HttpCalloutVO.Report>();
                for(Dom.XmlNode reportNode : reportNodes){
                    if(reportNode.getName() == 'Report'){
                        HttpCalloutVO.Report report = new HttpCalloutVO.Report();
                        report.PolicyNum = getChildNodeTextIfNotEmpty('PolicyNum',reportNode);
                        if(getChildNodeTextIfNotEmpty('FileExt',reportNode)=='pdf'){
                            report.FilePdfName = report.PolicyNum+' PDF';
                            report.FilePDFID = getChildNodeTextIfNotEmpty('FileID',reportNode);
                        }else if(getChildNodeTextIfNotEmpty('FileExt',reportNode)=='csv'){
                            report.FileExcelName = report.PolicyNum + ' CSV';
                            report.FileExcelID = getChildNodeTextIfNotEmpty('FileID',reportNode);
                        }
                        report.FileDesp = getChildNodeTextIfNotEmpty('FileDesp',reportNode);
                        report.FileName = getChildNodeTextIfNotEmpty('FileName',reportNode);
                        report.FileID = getChildNodeTextIfNotEmpty('FileID',reportNode);
                        report.FileExt = getChildNodeTextIfNotEmpty('FileExt',reportNode);
                        report.PolicyNum = getChildNodeTextIfNotEmpty('PolicyNum',reportNode);
                        reports.add(report);
                    }
                }
                reports = combineReports(reports);
                movementResult.Reports = reports;
                oList.add(movementResult);
            }

        }
        return oList;

    }

    private static List<HttpCalloutVO.Report> combineReports(List<HttpCalloutVO.Report> reportList){ //added by Connor(Client Portal)
        Map<String,HttpCalloutVO.Report> newReportMap = new Map<String,HttpCalloutVO.Report>();

        for(HttpCalloutVO.Report report : reportList){
            if(newReportMap.containsKey(report.PolicyNum)){
                if(report.FileExt.equals('pdf')){
                    newReportMap.get(report.PolicyNum).FilePdfID = report.FileID;
                    newReportMap.get(report.PolicyNum).FilePdfName = report.PolicyNum + ' PDF';
                }else if(report.FileExt.equals('csv')){
                    newReportMap.get(report.PolicyNum).FileExcelID = report.FileID;
                    newReportMap.get(report.PolicyNum).FileExcelName = report.PolicyNum + ' CSV';
                }
            }else{
                HttpCalloutVO.Report newReport = new HttpCalloutVO.Report();
                newReport.PolicyNum = report.PolicyNum;
                newReportMap.put(newReport.PolicyNum,newReport);
                if(report.FileExt.equals('pdf')){
                    newReport.FilePdfID = report.FileID;
                    newReport.FilePdfName = newReport.PolicyNum + ' PDF';
                }else if(report.FileExt.equals('csv')){
                    newReport.FileExcelID = report.FileID;
                    newReport.FileExcelName = newReport.PolicyNum + ' CSV';
                }
            }
        }

        return newReportMap.values();
    }
    
    // 21-02-2024 BodyCheckEligibility
   /********************************************************************
     * @param policyNumber – policy number 
     * @param certificateNo – certificate number
     * @param userName -  user name
     * @decs:Call GetBodyCheckEligibility WS to get bodyCheckEligibility info 
     * @return List<HttpCalloutVO.BodyCheckEligibility>
   ********************************************************************/
    public List<HttpCalloutVO.BodyCheckEligibility> getBodyCheckEligibility(String policyNumber, String certificateNo, String userName){
        system.debug('PolicyCalloutHelper.getBodyCheckEligibility');
        this.functionName=PolicyCalloutHelper.getBodyCheckEligibility;
        paramsMap=new Map<String,String>();
        if(String.isNotBlank(policyNumber)){paramsMap.put('PolNumber', policyNumber);}
        if(String.isNotBlank(certificateNo)){paramsMap.put('CertificateNo', certificateNo);}
        if(String.isNotBlank(userName)){paramsMap.put('UserLoginName', username);}
        return (List<HttpCalloutVO.BodyCheckEligibility>)execute(new Map<String,String>());
    }
    

    /********************************************************************
     * @decs: Rancho_JOBR347_20231108 - get member list with criteria
     * @param policyType - policy type (I/G) - mandatory           |polNo - policy number - mandatory
     * @param certNo - cert number - mandatory for group policy    |polStatus - policy status
     * @param fullName - policy holder full name                   |sortOrder - sort by policy effective date (A/D)
     * @param username - current user login name
     * @return List<HttpCalloutVO.DocMember>
     ********************************************************************/
    public List<HttpCalloutVO.DocMember> getMemberListByCriteria(String policyType, String polNo, String certNo, String polStatus, String fullName, String sortOrder, String username){
        this.functionName = PolicyCalloutHelper.GetMemberListByCriteria;
        paramsMap = new Map<String, String>();
        if(String.isNotBlank(policyType)){paramsMap.put('PolicyType', policyType);}
        if(String.isNotBlank(polNo)){paramsMap.put('PolNumber', polNo);}
        if(String.isNotBlank(certNo)){paramsMap.put('CertificateNo', certNo);}
        if(String.isNotBlank(polStatus)){paramsMap.put('PolicyStatus', polStatus);}
        if(String.isNotBlank(fullName)){paramsMap.put('FullName', fullName);}
        if(String.isNotBlank(fullName)){paramsMap.put('SortOrder', sortOrder);}
        if(String.isNotBlank(fullName)){paramsMap.put('UserLoginName', username);}
        if(String.isNotBlank(fullName)){paramsMap.put('GovtID','');}//HKITSFFDC-57 blank value to get empty string of GovtID node
        return (List<HttpCalloutVO.DocMember>)execute(new Map<String, String>());
    }
    
    /********************************************************************
     * @decs: HKITSFDC-57 - overload method of get member list with criteria
     * @param policyType - policy type (I/G) - mandatory           |polNo - policy number - mandatory
     * @param certNo - cert number - mandatory for group policy    |polStatus - policy status
     * @param fullName - policy holder full name                   |sortOrder - sort by policy effective date (A/D)
     * @param username - current user login name
     *@param username - SSN of Holder 
     * @return List<HttpCalloutVO.DocMember>
     ********************************************************************/
    public List<HttpCalloutVO.DocMember> getMemberListByCriteria(String policyType, String polNo, String certNo, String polStatus, String fullName, String sortOrder, String username,String ssn){
        system.debug('HKITSFDC-57 overload method : '+ username);
        this.functionName = PolicyCalloutHelper.GetMemberListByCriteria;
        paramsMap = new Map<String, String>();
        if(String.isNotBlank(policyType)){paramsMap.put('PolicyType', policyType);}
        if(String.isNotBlank(polNo)){paramsMap.put('PolNumber', polNo);}
        if(String.isNotBlank(certNo)){paramsMap.put('CertificateNo', certNo);}
        if(String.isNotBlank(polStatus)){paramsMap.put('PolicyStatus', polStatus);}
        if(String.isNotBlank(fullName)){paramsMap.put('FullName', fullName);}
        if(String.isNotBlank(sortOrder)){paramsMap.put('SortOrder', sortOrder);}
        if(String.isNotBlank(username)){paramsMap.put('UserLoginName', username);}
        if(String.isNotBlank(ssn)){paramsMap.put('GovtID',ssn);}
        system.debug('HKITSFDC-57 overload method : '+ paramsMap.get('UserLoginName'));
        return (List<HttpCalloutVO.DocMember>)execute(new Map<String, String>());
    }

    
    /********************************************************************
     * @decs: Rancho_JOBR347_20231108 - get member list with criteria
     * @param Dom.document doc - response body
     * @return List<HttpCalloutVO.DocMember>
     ********************************************************************/
    public List<HttpCalloutVO.DocMember> processGetMemberListByCriteria(Dom.document doc){
        List<HttpCalloutVO.DocMember> resultList = new List<HttpCalloutVO.DocMember>();
        if(!this.isCalloutSuccessfully){
            return resultList;
        }

        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode = getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode = getChildNodeIfNotNull('OLifE', TXLifeResponseNode);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Party'){
                HttpCalloutVO.DocMember member = new HttpCalloutVO.DocMember();
                member.fullName = getChildNodeTextIfNotEmpty('FullName',childNode);
                member.ssnNumber = getChildNodeTextIfNotEmpty('GovtID',childNode);
                
                Dom.XmlNode memberNode = getChildNodeIfNotNull('OLifEExtension',childNode);
                member.policyNo = getChildNodeTextIfNotEmpty('PolicyNumber',memberNode);
                member.planName = getChildNodeTextIfNotEmpty('PlanDescription',memberNode);
                member.companyName = getChildNodeTextIfNotEmpty('CompanyName',memberNode);
                member.residence = getChildNodeTextIfNotEmpty('Residence',memberNode);
                member.age = getChildNodeTextIfNotEmpty('Age',memberNode);
                member.dob = getChildNodeTextIfNotEmpty('DOB',memberNode);
                member.sex = getChildNodeTextIfNotEmpty('Sex',memberNode);
                member.vasISOS = getChildNodeTextIfNotEmpty('VasISOS',memberNode);
                member.vasIMC = getChildNodeTextIfNotEmpty('VasIMC',memberNode);
                member.vasSMO = getChildNodeTextIfNotEmpty('VasSMO',memberNode);
                member.vasGMN = getChildNodeTextIfNotEmpty('VasGMN',memberNode);
                member.vasGC = getChildNodeTextIfNotEmpty('VasGC',memberNode);
                /***HKITSFDC-57 Virtus Search Begin***/
                member.opRider = getChildNodeTextIfNotEmpty('OPRider',memberNode);
                member.endoscopy = getChildNodeTextIfNotEmpty('Endoscopy',memberNode);
                /***HKITSFDC-57 End***/
                // Rancho_HKITSFDC207_20250327 - display deductible fields for doctor portal virtus
                member.deductiblePlan = getChildNodeTextIfNotEmpty('DeductiblePlan',memberNode);
                member.deductibleFulfilment = getChildNodeTextIfNotEmpty('DeductibleFulfilment',memberNode);
                resultList.add(member);
            }
        }
        return resultList;
    }

    public override List<Object> processResultFromResponse(Dom.document doc){
        system.debug('[PolicyCalloutHelper] functionName='+this.functionName);
        system.debug('[PolicyCalloutHelper] isCalloutSuccessfully='+this.isCalloutSuccessfully);
        if(this.functionName==PolicyCalloutHelper.GetPolicyListBasicByCriteria){
            return processPolicyListBasicByCriteriaResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.getPolicyPersonListBasic){
            return processPolicyPersonListBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyPersonListBasicByCriteria){
            return processPolicyPersonListBasicByCriteriaResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyPaymentBasic){
            return processPolicyPaymentBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.getPolicyBillingListBasic){
            return processPolicyBillingListBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyFundListBasic){
            return processPolicyFundListBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyFundListHistBasic){
            return processPolicyFundListHistBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyAvailFundListBasic){
            return processPolicyAvailFundListBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyPersonCoverageBasic){
            /*HKITSFDC-265 fix DIRT CHECK
            String oldReqAttachmentId = '00PA200000FZqXt';
            Attachment att = [SELECT Body from attachment where id=:oldReqAttachmentId limit 1];
            String xmlStr = att.Body.toString();
            system.debug('xlStr : '+ xmlStr);
            doc = new DOM.Document();
            doc.load(xmlStr);
            //END DIRT CHECK*/
            return processPolicyPersonCoverageBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyBasic){
            return processPolicyBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyClaimBasic){
            return processPolicyClaimBasicResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyDoc){
            return processPolicyDocResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyDocTypeList){
            return processPolicyDocTypeListResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetClinicVisitCount){
            return processClinicVisitCountResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetEMedicalCardsByCriteria || this.functionName==PolicyCalloutHelper.GetEMedicalCardsBasicByCriteria){
            return processGetEMedicalCardsResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetUWComments){
            return processUWCommentResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyTransactionHistory){
            return processPolicyTransactionHistoryResult(doc);
        // JR1774 - [[
        }else if(this.functionName==PolicyCalloutHelper.VerifyPolicyInfo){
            return processVerifyPolicyInfoResult(doc);
        // ]] - JR1774
        }else if(this.functionName==PolicyCalloutHelper.GetAuditTrail){// add by jack for cs member level
            return processAuditTrailListBasic(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetPolicyReplacementChangeHistory){// add by jack for policy replacement
            return processPolicyReplacementChangeResult(doc);
        }else if(this.functionName == PolicyCalloutHelper.GetPersonShortfallBasicByCriteria){// added by Connor CP-156(Client Portal)
            return processPersonShortfallBasicByCriteria(doc);
        }else if(this.functionName == PolicyCalloutHelper.GetPersonMovementHistory){// added by Connor CP-156(Client Portal)
            return processPersonMovementHistory(doc);
        }else if(this.functionName == PolicyCalloutHelper.GetClientMemberMovementResult){// added by Connor CP-163(Client Portal)
            return processMemberMovementResult(doc);
        }else if(this.functionName == PolicyCalloutHelper.UpdatePolicyDoc){// added by Connor CR-47
            return processUpdatePolicyDocResult(doc);
        }else if(this.functionName==PolicyCalloutHelper.GetMemberListByCriteria){// Rancho_JOBR347_20231108
            return processGetMemberListByCriteria(doc);
        }else{
            return new List<Object>();
        }
    }
    
    //SPS-400
    public String processPhoneNumString(String phoneNo){
        List<String> splitPhoneNo=String.isNotBlank(phoneNo)?phoneNo.split('/'):new List<String>();
        for(String s:splitPhoneNo){
            s.replace(' ','');
        }
        if(!splitPhoneNo.isEmpty() && splitPhoneNo.size()>1){
            return String.join(splitPhoneNo,',');
        }else{
            return phoneNo;
        }
    }
    //SPS-400
    
    public static Boolean isDecimal(String s){
        try{
            Decimal.valueOf(s);
            Return true;
        }catch(Exception e){
            Return false;
        }
    }

    /********************************************************************
     * setAllFamilyRecInd
     * @decs Rancho_PI66_20220428 - get all families' doc records if isAllFamilyRec = true when call GetPolicyDocTypeList
     * @return List<HttpCalloutVO.PolicyDocType>
     * @author ranzhao@deloitte.com.cn
   ********************************************************************/
    public void setAllFamilyRecInd(){
        this.isAllFamilyRec = true;
    }
}