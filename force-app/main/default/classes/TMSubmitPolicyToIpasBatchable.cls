/*********************************************************************************
* Name: TMSubmitPolicyToIpasBatchable
*
* Version History
* Version           Author                 Date                      Description
* ---------------  --------------------    -----------------------  ---------------------------------------------------------
* V1.0             Franco                  2018-05-14               Batch Submit Policy to IPAS
********************************************************************************/
global without sharing class TMSubmitPolicyToIpasBatchable implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public String policyTransactionId = '';
    public Date lastModifiedDate = null;
    public Set<Id> policyTransactionIdSet = new Set<Id>();
    private Map<String,String> nationalityEnMap;
    private List<String> opportunityList = new List<String>(); // TM Work From Home_20200828
    private List<String> failedOppList = new List<String>(); //Rancho_SpeechAnalytics_20210607
    public static Map<String,String> uwResultMap = new Map<String,String>{'Accept' => '1','Accepted' => '1','Accepted with Exclusion' => '1','Referred' => '3','Declined' => '2','' => '',null => ''};
    
    public static Map<String,String> businessPartnerMap = new Map<String,String>{'賭博（賭場，棋牌中心，麻將館等） - Gambling (casino, card club, mahjong centre, etc.)' => 'GAMBLC','貨幣兌換 - Money changer' => 'MNYCLC','匯款代理 - Remittance agent' => 'REMTLC','放債人 - Money lender' => 'MONLLC','當舖 / 典當 - Pawnbroker / pawning' => 'PAWNLC','虛擬商品交易商 / 虛擬商品營運商（例如: 比特幣） - Virtual commodity trader / virtual commodity scheme operator (e.g. Bitcoin)' => 'VCTCLC','貴金屬經銷 / 零售商（例如: 金，銀等） - Dealer of precious metals (e.g. gold, silver, etc.)' => 'DLPMLC','寶石或珠寶商 - Dealer of precious stones or jewels' => 'DLPSLC','汽車、船或飛機經銷 /零售商 - Dealer of car, boat or plane' => 'DLCBLC','藝術品商 - Art dealer' => 'ARTDLC','拍賣 / 拍賣商 / 拍賣行 - Auctioneer' => 'AUCTLC','夜總會、的士高、酒吧、按摩店 - Night club, disco, bar, massage shop' => 'NGTCLC','武器及彈藥製造 - Weapon and ammunition manufacturing' => 'WEAPLC','現金密集型業務 - Cash-intensive business' => 'CASHLC','以上皆否 - None of the above' => 'ZZZZZZ','' => '',null => ''};
    
    public static Map<String,String> sourceOfFundMap = new Map<String,String>{'01 - Salary' => '01','02 - Savings' => '02','03 - Investment Income' => '03','04 - Rental Income' => '04','05 - Business gain' => '05','06 - Other (Please specify)' => '06','' => '',null => ''};
    
    public static Map<String,String> meansOfIncomeMap = new Map<String,String>{'Full time work with regular and stable income' => '01','Part time/temporary/freelance (unstable income)' => '02','Housewife, retired, unemployed, student' => '03','Others' => '04','' => '',null => ''};
    
    public static Map<String,String> educationLevelMap  = new Map<String,String>{'Primary or below' => '01','Secondary' => '02','Non-degree tertiary' => '03','University degree' => '04','Postgraduate' => '05','Others' => '06','' => '',null => ''};
    
    public static List<Discount_Code__c> discountCodeList = [select Code__c, Description__c, Group__c from Discount_Code__c ];// jack add for friend and family discount in SFDC
    public static Map<String,String> discountCodeDecripMap{get{
        
        Map<String,String> tmpMap = new Map<String,String>();
        for(Discount_Code__c dc : discountCodeList){
            tmpMap.put(dc.Description__c, dc.Code__c);
        }
        return tmpMap;
        
    }set;}
    // jack add for friend and family discount in SFDC
    public static Map<String, Discount_Code__c> tmpDiscountCodeMap{get{
        Map<String, Discount_Code__c> tmpMap = new Map<String,Discount_Code__c>();
        for(Discount_Code__c dc : discountCodeList){
            tmpMap.put(dc.Description__c,dc);
        }
        return tmpMap;
    }set;}
    
    //wellness
    public static Map<String,Refund_Code_Mapping__c> wellnessRemarkMap = Refund_Code_Mapping__c.getAll();
    //wellness
    //SPS-667 jack add
    public static final String TO_IPAS_FIALED= 'ToIPASFailed';
    public static final String TO_APPLIAN_FIALED= 'ToAppianFailed';
    public static final String TO_ILAS_AND_APPLIAN_FIALED= 'ToIPAS & AppianFailed';
    public Map<Id,String> policyTransSubmitResultMap = new Map<Id,String>();
    public Boolean enableFailedStatus=false;//SPS-728 jack add
    //Rancho_SPS728_20210602
    public Set<String> otherErrMsgSet = new Set<String>();
    public Set<String> dupliErrMsgSet = new Set<String>();
        
    public TMSubmitPolicyToIpasBatchable(){
        
    }
    
    /*
     * wil submit those policy under the specified policy transaction
     */
    public TMSubmitPolicyToIpasBatchable(Id ptId){
        this.policyTransactionId = ptId;
    }

    //SPS-728 jack add
    public TMSubmitPolicyToIpasBatchable(Id ptId,Boolean enableFailedStatus){
        this.policyTransactionId=ptId;
        this.enableFailedStatus=enableFailedStatus;
    }
    
    /*
     * will submit those earlier than the specified which date
     */
    public TMSubmitPolicyToIpasBatchable(Date lastModifiedDate){
        this.lastModifiedDate = lastModifiedDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        system.debug('TMSubmitPolicyToIpasBatchable start()');
        nationalityEnMap = new Map<String, String>();
        //Call WS to Get Nationality Code Map
        if(!Test.isRunningTest()){
            /* add by Jack on 2021-12-20 for project: IA AML nationality mandatory */
            MasterListCalloutHelper enNationalityCalloutHelper = new MasterListCalloutHelper(15, 'en');
            nationalityEnMap = covertMasterListtoMapwithSort((List<HttpCalloutVO.MasterList>)enNationalityCalloutHelper.RequestMasterList());
        }
        
        List<String> tmrRoleList = new List<String>();
        tmrRoleList.add('TM_Build_Team_TMR');
        tmrRoleList.add('TM_DTC_Sub_Team_1_TMR');
        tmrRoleList.add('TM_DTC_Sub_Team_2_TMR');
        
        // What policies can be submitted ?
        // Policy transaction status must be 'Completed'
        // The opportunity must has a call log (Term_Code_Level__c = '4')
        // The opportunity's owner must be a TM agent
        String soql = 'SELECT Id,Name, CreatedById,CreatedDate, Effective_Date__c, eSales_Transaction_Id__c, '
                    + 'Master_Policy_No__c, Number_of_Person_Insured__c, Policy_Number__c, Product_Code__c, Product_Name__c, '
                    + 'Status__c, Step__c, Submission_Date_Time__c, Total_Annual_Premium__c, '
                    + 'Objectives_Question__c, Which_type_s_of_medical_insurance__c, '//GL31 jack add 
                    
                    + 'Selected_Campaign__c, Selected_Campaign__r.Core_Product__r.License__c, Selected_Campaign__r.Campaign_No__c, '
                    + 'Selected_Campaign__r.Core_Product__r.Currency__c, '
                    
                    // campaign, product related
                    + 'Core_Campaign__c, Core_Campaign__r.Campaign_Code__c, Core_Campaign__r.IPAS_Campaign_Code__c, Core_Campaign__r.StartDate, Core_Campaign__r.EndDate, Core_Campaign__r.Channel__r.Channel_Code__c, '
                    + 'Core_Campaign__r.Campaign_Type__r.Name, Core_Campaign__r.Business_Partner__r.Sponsor_Code__c, Core_Campaign__r.Split_No_Text__c, Core_Campaign__r.Split_No__c, Core_Campaign__r.Campaign_No__c, '
                    + 'Core_Campaign__r.Core_Product__r.Currency__c, Core_Campaign__r.Core_Product__r.License__c, '
                    
                    // opportunity related
                    + 'Opportunity__c, Opportunity__r.createdDate, Opportunity__r.LastModifiedDate, Opportunity__r.Owner.TM_Agent_ID__c, Opportunity__r.Owner.Supervisor_ID__c, '
                    + 'Opportunity__r.IPAS_Remarks1__c, Opportunity__r.IPAS_Remarks2__c, Opportunity__r.IPAS_Remarks3__c, Opportunity__r.IPAS_Remarks4__c, Opportunity__r.IPAS_Remarks5__c, '
                    + 'Opportunity__r.Running_No__c, Opportunity__r.IQ_ID__c, Opportunity__r.Source_of_Activity__c, '
                    + 'Opportunity__r.Prospect_Id__c, Opportunity__r.Owner.Seller_ID__c, Opportunity__r.Term_Code__c, Opportunity__r.Batch_No__c, '
                    + 'Opportunity__r.Submission_Date__c, Opportunity__r.Overall_Opt_Out__c, Opportunity__r.Maturity_Policy_Number__c, '
                    // account related
                    + 'Account__c, Account__r.Account_Id__c, Account__r.Prospect_reference1__c, Account__r.Reference2__pc, Account__r.Reference3__pc, Account__r.Reference4__pc, Account__r.Reference5__pc '
                    
                    //+' FROM Policy_Transaction__c Where Status__c = \'Completed\' ';
                    //Add by Manuel for VHIS products handling
                    +' FROM Policy_Transaction__c Where (Status__c = \'Completed\' or (Status__c = \'Pending Payment\' and (Product_Code__c = \'VSTDG\' or Product_Code__c = \'VSMMG\' or Product_Code__c = \'VSUPG\'))) ';
        
        //SPS-728 jack add
        if(enableFailedStatus){
            soql=soql.removeEnd(') ');
            soql=soql+ ' or (Status__c=\''+TO_IPAS_FIALED+'\' or Status__c=\''+TO_ILAS_AND_APPLIAN_FIALED+'\' or Status__c=\''+TO_APPLIAN_FIALED+'\')'+')';
        }
        
        //Jobr-328,add by Owen 2023-09-13 to allow '500' term code pass
        //Rancho_20240604 - remove 500, only 400 can be submitted
        if(!Test.isRunningTest()){
            soql = soql + ' and Opportunity__r.Term_Code_Level__c = \'4\' and Opportunity__r.owner.userRole.developerName in :tmrRoleList ';
        }
        
        if(String.isNotBlank(policyTransactionId)){
            soql = soql + ' and id = \'' + policyTransactionId + '\' ';
        }
        
        if(lastModifiedDate != null){
            String dateStr = lastModifiedDate.year() + '-' + String.valueOf(lastModifiedDate.month()).leftPad(2, '0') + '-' + String.valueOf(lastModifiedDate.day()).leftPad(2, '0') + 'T00:00:00.000+0000';
            soql = soql + ' and lastmodifieddate < ' + dateStr + ' ';
        }

        system.debug('soql:' + soql);
        return Database.getQueryLocator(soql);
    }
    
    global void execute(Database.BatchableContext info, List<Policy_Transaction__c> scope){
        System.debug('record count: ' + scope.size());
        try{
            Datetime now = Datetime.now();
            Date today = Date.today();
            
            Map<String, Country_List_Settings__c> countryMap = new Map<String, Country_List_Settings__c>();
            for(Country_List_Settings__c country : Country_List_Settings__c.getAll().Values()){
                countryMap.put(country.name, country);
            }
            
            Map<String, String> relationMap = new Map<String, String>();
            for(Relationship_Mapping__c relation : Relationship_Mapping__c.getAll().Values()){
                relationMap.put(relation.name, relation.Code__c);
            }
            
            Map<String, String> discountCodeMap = new Map<String, String>();
            for(Discount_Code__c dis : Discount_Code__c.getAll().values()){
                discountCodeMap.put(dis.Description__c, dis.Code__c);
            }
            
            List<Id> ptIds = new List<Id>();
            Map<Id, Policy_Transaction__c> ptMap = new Map<Id, Policy_Transaction__c>();
            for(Policy_Transaction__c pt : scope){
                Id ptId = pt.Id;
                ptIds.add(ptId);
                ptMap.put(ptId, pt);
            }
            
            
            Schema.DescribeSObjectResult policyDSR = New_Policy__c.sObjectType.getDescribe();
            List<String> policyFieldNames = new list<String>();
            for(string apiName : policyDSR.fields.getMap().keySet()){
                policyFieldNames.add(apiName);
            }
            Date dateToday = System.today(); //Add by Manuel for VHIS product handling
            String policySoql = 'select ' + String.join(policyFieldNames, ',') + ', '
                + ' Policy_Transaction__r.Opportunity__c,'//SPS-667 jack add
                + ' (SELECT Id,Premium__c,Plan_Level__c,Product_Code__c,Is_Rider__c,Is_Mandatory_Rider__c,Rate_Scale__c FROM Plan_Quote__r), Product__r.Is_Life__c, '
                + ' (SELECT Id,Name, Beneficiary_Type__c, First_Name__c, Gender__c, Last_Name__c, Percent__c, Policy__c, Person_Insured__c, Person_ID__c, Relationship__c FROM Beneficiary__r), '
                
                + ' (SELECT Id,Name, UW_EXCL_1__c, UW_EXCL_2__c, UW_EXCL_3__c, UW_EXCL_4__c, UW_EXCL_5__c, UW_EXCL_6__c, UW_EXCL_7__c, UW_EXCL_9__c, UW_EXCL_10__c, Is_Basic_Plan__c, '
                + ' Loading__c, UW_EXCL_8__c, UW_Remark_1__c, UW_Remark_2__c, UW_Remark_4__c, UW_Remark_3__c, UW_Remark_5__c, '
                + ' UW_Remark_6__c, UW_Remark_7__c, UW_Remark_8__c, UW_Remark_9__c, UW_Remark_10__c, Case_Id__c, risk_type__c, product_code__c, Product_UW_Result__c FROM UW_Result__r )'
                + ',(SELECT id,Coupon_Amount__c,Coupon_Number__c,Coupon_Status__c from Coupons__r)'//AM project coupon jack add
                
                + ' from New_Policy__c '
                + ' where Policy_Transaction__c In :ptIds '
                //+ ' and (Policy_Status__c = \'Completed\' or Policy_Status__c = \'Rejected\' ) ';  //add Rejected by andy 
                //Add by Manuel for VHIS products handling
                + ' and (Policy_Status__c = \'Completed\' or Policy_Status__c = \'Rejected\' '+ (enableFailedStatus?'or Policy_Status__c = \'Submitted\' ':'') +'or (Policy_Status__c = \'Pending Payment\' and (Product_Code__c = \'VSTDG\' or Product_Code__c = \'VSMMG\' or Product_Code__c = \'VSUPG\'))) '//SPS-728 jack add
                //Nicole_20200409_CDD
                + ' and Missing_CDD_Info__c = false ';
            
            List<New_Policy__c> npList = Database.query(policySoql);
            System.debug('npList.size(): ' + npList.size());
            System.debug('npList: ' + npList);
            List<Id> npIds = new List<Id>();
            Map<Id, New_Policy__c> npMap = new Map<Id, New_Policy__c>();
            for(New_Policy__c np : npList){
                //Add by Manuel for VHIS products handling
                if(np.Policy_Status__c=='Pending Payment'&&(np.Product_Code__c=='VSTDG'||np.Product_Code__c=='VSMMG'||np.Product_Code__c=='VSUPG')){
                    /*
                    if(np.UW_Date__c.daysBetween(dateToday)>30){
                    Id npId = np.Id;
                    npIds.add(npId);
                    npMap.put(npId, np);
                }
                */
                }else{
                    Id npId = np.Id;
                    npIds.add(npId);
                    npMap.put(npId,np);
                }
            }
            System.debug('npIds: ' + npIds);
            List<Person_Insured__c> piList = [SELECT Id,Benefit_Level__c, Corresponding_Address_1__c, Corresponding_Address_2__c, Corresponding_Address_3__c, Corresponding_Address_4__c,Corresponding_Address_Country__c, Date_of_Birth__c, Email__c, Gender__c, Height__c, Height_Unit__c, Home_Phone__c,ID_Type__c, Income_HKD__c, Insured_First_Name__c, Insured_Last_Name__c, Insured_Name_Chi__c, Insured_Type__c, Marital_Status__c, Mobile_Phone__c,Nationality__c, Office_Phone__c, Person_Insured_Name__c, Name, Personal_ID__c,PI_Age__c, Position__c, Rider__c, Smoker__c, Weight__c, Weight_Unit__c, Relationship__c, Residential_Address_1__c, Residential_Address_2__c, Residential_Address_3__c, Residential_Address_4__c, Place_of_Residence_picklist__c,New_Policy__c,New_Policy__r.Policy_Transaction__c,LHB_policy_number__c, LHB_certificate_number__c,Asia_Miles_Membership_First_Name__c,Asia_Miles_Membership_Last_Name__c,Asia_Miles_Membership_Num__c,Other_Reason_for_PI_age_over_18__c,Reason_for_PI_age_over_18__c,Residential_Address_Country__c,Place_of_Birth__c FROM Person_Insured__c where New_Policy__c In :npIds AND Personal_ID__c != null AND Insured_Type__c != null];//AM project jack add/* add by Jack on 2021-12-03 for project: JR1829 *//* add by Jack on 2022-01-13 for project: IA AML */
            System.debug('piList.size(): ' + piList.size());
            List<Id> piIds = new List<Id>();
            Map<Id,Person_Insured__c> piMap = new Map<Id,Person_Insured__c>();
            String groupId ='';
            Map<Id,Person_Insured__c> policyIdPiMap=new Map<Id,Person_Insured__c>();/* add by Jack on 2021-12-03 for project: JR1829 */
            for(Person_Insured__c pi : piList){
                if(pi.Insured_Type__c.equals('PH = PI')){
                    groupId= String.isNotBlank(pi.LHB_policy_number__c)&&String.isNotBlank(pi.LHB_certificate_number__c)?(pi.LHB_policy_number__c+'-'+pi.LHB_certificate_number__c):'';
                }
                Id piId = pi.Id;
                piIds.add(piId);
                piMap.put(piId,pi);
                policyIdPiMap.put(pi.New_Policy__c,pi);/* add by Jack on 2021-12-03 for project: JR1829 */
            }
            
            TMNBCalloutHelper helper = new TMNBCalloutHelper('TM');
            PolicyCalloutHelper pHelper = new PolicyCalloutHelper();
            List<New_Policy__c> submittedPolicies = new List<New_Policy__c>();
            List<New_Policy__c> failedPolicies = new List<New_Policy__c>();
            List<New_Policy__c> submitWorkRequestPolicies = new List<New_Policy__c>(); // add by kermit for SPS-89
            for(Person_Insured__c pi : piList){
                
                HttpCalloutVO.NBCriteria criteria = new HttpCalloutVO.NBCriteria();
                
                Policy_Transaction__c pt = ptMap.get(pi.New_Policy__r.Policy_Transaction__c);
                New_Policy__c np = npMap.get(pi.New_Policy__c);
                system.debug('np: ' + np);
                
                //add by Deloitte Andy 2019-04-12
                criteria.LHBPolicyNo = pi.LHB_policy_number__c;
                criteria.LHBCertificateNo = pi.LHB_certificate_number__c;
                if(String.isNotBlank(pi.LHB_policy_number__c)){
                    HttpCalloutVO.Policy p = pHelper.getPolicyBasic(pi.LHB_policy_number__c);
                    criteria.LHBBrokerCode = p.broker.organization.orgCode;
                    system.debug('andy add the debug=== p='+p);
                    system.debug('andy add the debug=== brokerCode='+p.broker.organization.orgCode);
                }
                //AM project jack add
                HttpCalloutVO.Membership piMembership=new HttpCalloutVO.Membership();
                piMembership.membershipFirstName = pi.Asia_Miles_Membership_First_Name__c;
                piMembership.membershipLastName = pi.Asia_Miles_Membership_Last_Name__c;
                piMembership.membershipId = pi.Asia_Miles_Membership_Num__c;
                criteria.membership = piMembership;
                
                
                criteria.polNumber = np.Policy_No__c;
                if(np.UW_Requirement__c == 'GA'){
                    //add by jack for policy replacement for GA policyStatus
                    //criteria.policyStatus = '1';
                    if((np.UW_Overrall_Result__c == 'Accepted' || np.UW_Overrall_Result__c == 'Accepted with Exclusion') && np.Appeal_For_UW_Result__c == TMCreatePolicyCtrl.APPEAL_NO){
                        criteria.policyStatus = '1';
                    }else if(np.Appeal_For_UW_Result__c == 'Withdrawn'){ 
                        criteria.policyStatus = '5';
                    }else if(np.UW_Overrall_Result__c == 'Referred'){
                        criteria.policyStatus = '6';
                    }
                }else{
                    //if(np.UW_Overrall_Result__c == 'Accepted' || np.UW_Overrall_Result__c == 'Accepted with Exclusion'){
                    if((np.UW_Overrall_Result__c == 'Accepted' || np.UW_Overrall_Result__c == 'Accepted with Exclusion') && np.Appeal_For_UW_Result__c != 'Withdrawn'){
                        criteria.policyStatus = '4';
                    } //else if(np.UW_Overrall_Result__c == 'Withdrawn'){//np.UW_Overrall_Result__c == 'Rejected'
                    else if(np.Appeal_For_UW_Result__c == 'Withdrawn'){ // add by kermit 20190318
                        criteria.policyStatus = '5';
                    }else if(np.UW_Overrall_Result__c == 'Referred'){
                        criteria.policyStatus = '6';
                    }else if(np.UW_Result__c == 'Declined' && np.UW_Overrall_Result__c == 'Declined' && np.Pre_Sales_Result__c != 'Declined'){//added by Andy 20181219 for day2 DPSP-1183
                        // If the policy is declined by rulebook2, it should be uploaded to IPAS.
                        criteria.policyStatus = '5';
                    }
                    /*
                    //Add by Manuel for VHIS products handling
                    if(np.UW_Date__c.daysBetween(dateToday)>30&&np.Policy_Status__c=='Pending Payment'&&(np.Product_Code__c=='VSTDG'||np.Product_Code__c=='VSMMG'||np.Product_Code__c=='VSUPG')){
                    criteria.policyStatus = '5';
                    }
                    */
                }
                system.debug('[TMSubmitPolicyToIpasBatchable] criteria.policyStatus'+criteria.policyStatus);
                
                criteria.transId = String.valueOf(np.Id).left(15);
                //criteria.applicantNumber
                criteria.policyProduct = pt.Product_Name__c;
                criteria.productCode = pt.Product_Code__c.replace('@', '');
                criteria.rateScale = pi.Benefit_Level__c;
                //criteria.rateScale = String.isNotBlank(pi.Benefit_Level__c) ? pi.Benefit_Level__c : '1'; //Add by Manuel to test
                criteria.BenefitLevel = pi.Benefit_Level__c;
                
                if(np.Submission_Date_Time__c != null){
                    Date submissionDate = np.Submission_Date_Time__c.date();
                    if(!'RSM'.equals(criteria.productCode)){
                        criteria.policyEffDate = submissionDate;
                    }else{
                        criteria.policyEffDate = np.Policy_Effective_Date__c;
                    }
                    criteria.initialBillDate = submissionDate;
                    if(submissionDate.day() > 28 && !'RSM'.equals(criteria.productCode)){
                        criteria.policyEffDate = Date.newInstance(submissionDate.year(), submissionDate.month(), 28);
                        criteria.initialBillDate = Date.newInstance(submissionDate.year(), submissionDate.month(), 28);
                    }
                }
                
                //PI residential address
                criteria.resAddrLine1 = pi.Residential_Address_1__c;
                criteria.resAddrLine2 = pi.Residential_Address_2__c;
                criteria.resAddrLine3 = pi.Residential_Address_3__c;
                criteria.resAddrLine4 = pi.Residential_Address_4__c;
                /* add by Jack on 2021-12-20 for project: IA AML nationality mandatory */
                if(countryMap.get(pi.Residential_Address_Country__c) != null){
                    criteria.resCountry = countryMap.get(pi.Residential_Address_Country__c).Country_Id__c;
                }

                List<String> riderCodeList = new List<String>();
                if(String.isNotBlank(pi.Rider__c)){
                    riderCodeList = pi.Rider__c.split(';');
                }
                
                system.debug('np.Plan_Quote__r: ' + np.Plan_Quote__r);
                if(np.Plan_Quote__r != null){
                    for(Plan_Quote__c pq : np.Plan_Quote__r){
                        // basic plan and 6 riders 
                        // mandatory rider no need to pass to ipas
                        if(!pq.Is_Mandatory_Rider__c){
                            if(!pq.is_Rider__c){
                                criteria.productPremium = String.valueOf(pq.Premium__c);
                                criteria.rateScale = pq.Plan_Level__c;
                                //criteria.rateScale = String.isNotBlank(pq.Plan_Level__c) ? pq.Plan_Level__c : '1'; //Add by Manuel to test
                            }else if(String.isBlank(criteria.rider1)){
                                criteria.rider1 = pq.Product_Code__c;
                                
                                criteria.riderRateScale1 = getRiderRateScale(riderCodeList, criteria.rider1, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale1 = resetRateScaleForDETG(criteria.rider1,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale1);
                                //criteria.riderRateScale1 = String.isNotBlank(pq.Rate_Scale__c) ? pq.Rate_Scale__c : pq.Plan_Level__c;
                                criteria.riderPremium1 = String.valueOf(pq.Premium__c);
                            }else if(String.isBlank(criteria.rider2)){
                                criteria.rider2 = pq.Product_Code__c;
                                criteria.riderRateScale2 = getRiderRateScale(riderCodeList, criteria.rider2, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale2 = resetRateScaleForDETG(criteria.rider2,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale2);
                                criteria.riderPremium2 = String.valueOf(pq.Premium__c);
                            }else if(String.isBlank(criteria.rider3)){
                                criteria.rider3 = pq.Product_Code__c;
                                criteria.riderRateScale3 = getRiderRateScale(riderCodeList, criteria.rider3, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale3 = resetRateScaleForDETG(criteria.rider3,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale3);
                                criteria.riderPremium3 = String.valueOf(pq.Premium__c);
                            }else if(String.isBlank(criteria.rider4)){
                                criteria.rider4 = pq.Product_Code__c;
                                criteria.riderRateScale4 = getRiderRateScale(riderCodeList, criteria.rider4, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale4 = resetRateScaleForDETG(criteria.rider4,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale4);
                                criteria.riderPremium4 = String.valueOf(pq.Premium__c);
                            }else if(String.isBlank(criteria.rider5)){
                                criteria.rider5 = pq.Product_Code__c;
                                criteria.riderRateScale5 = getRiderRateScale(riderCodeList, criteria.rider5, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale5 = resetRateScaleForDETG(criteria.rider5,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale5);
                                criteria.riderPremium5 = String.valueOf(pq.Premium__c);
                            }else if(String.isBlank(criteria.rider6)){
                                criteria.rider6 = pq.Product_Code__c;
                                criteria.riderRateScale6 = getRiderRateScale(riderCodeList, criteria.rider6, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale6 = resetRateScaleForDETG(criteria.rider6,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale6);
                                criteria.riderPremium6 = String.valueOf(pq.Premium__c);
                            }else if(String.isBlank(criteria.rider7)){ //Combo: maybe has 7 riders 20201209
                                criteria.rider7 = pq.Product_Code__c;
                                criteria.riderRateScale7 = getRiderRateScale(riderCodeList, criteria.rider7, pq.Rate_Scale__c, pq.Plan_Level__c);
                                criteria.riderRateScale7 = resetRateScaleForDETG(criteria.rider7,np.Discount_1__c,np.Discount_2__c,pq.Rate_Scale__c,pi,np,criteria.riderRateScale7);
                                criteria.riderPremium7 = String.valueOf(pq.Premium__c);
                            }
                        }
                    }
                }
                
                criteria.productLicense = (pt.Selected_Campaign__c == null) ? pt.Core_Campaign__r.Core_Product__r.License__c : pt.Selected_Campaign__r.Core_Product__r.License__c ; //pt.Core_Campaign__r.Core_Product__r.License__c;
                /* add by Jack on 2021-10-28 for project: Bug 134865 incorrect plan type*/
                // criteria.planType = 'A';
                // if(pi.PI_Age__c < 18){
                //     criteria.planType = 'C';
                // }
                /* Comment by Andy 20181228 for DPSP-1189
                if(String.isNotBlank(np.Plan_Type__c)){
                if(np.Plan_Type__c.equalsIgnoreCase('MI')){
                    criteria.planType = 'A';
                }else if(np.Plan_Type__c.equalsIgnoreCase('Spouse')){
                    criteria.planType = 'S';
                }else if(np.Plan_Type__c.equalsIgnoreCase('Child')){
                    criteria.planType = 'C';
                }
                }
                */
                // Added by Andy 20181228 for DPSP-1189 pass plantype = 'S' when np.Relationship_Of_Policy__c = 'SP'
                // if(np.Relationship_Of_Policy__c == 'SP'){
                //     criteria.planType = 'S';
                // }
                if(pi.Insured_Type__c=='PH = PI'){
                    criteria.planType='A';
                }else if(pi.Insured_Type__c=='Spouse'){
                    criteria.planType='S';
                }else{
                    criteria.planType='C';
                }
                /* add by Jack on 2021-10-28 for project: Bug 134865 incorrect plan type*/

                //criteria.RiderPremium1 = '111';
                system.debug('pt.Selected_Campaign__c'+pt.Selected_Campaign__c);
                // TS-671 if product selected is from alt campaign, then alt campaign campaign code should be passed to ipas.
                criteria.campaignCode = (pt.Selected_Campaign__c == null) ? pt.Core_Campaign__r.Campaign_No__c : pt.Selected_Campaign__r.Campaign_No__c;  //pt.Core_Campaign__r.Campaign_No__c; // old: pt.Core_Campaign__r.Campaign_Code__c;
                criteria.policyHolderList = new List<HttpCalloutVO.NBPolicyHolder>();
                HttpCalloutVO.NBPolicyHolder holder = new HttpCalloutVO.NBPolicyHolder();
                holder.firstName = np.Policy_Holder_First_Name__c;
                holder.lastName = np.Policy_Holder_Last_Name__c;               
                if(String.IsNotBlank(np.Policy_Holder_Name_Chi__c)){
                    holder.chineseName = np.Policy_Holder_Name_Chi__c.left(10);
                    if(!holder.chineseName.isAsciiPrintable()){
                        holder.chineseName = '';
                    }
                }
                //add by lihao fro setNBcomplete 
                holder.loginId = groupId;
                //holder.gender = (np.Gender__c == 'Male')? 'M': 'F';
                holder.gender = ((np.Gender__c == 'Male')? 'M' : ((np.Gender__c == 'Female') ? 'F':np.Gender__c));
                //holder.title = (np.Gender__c == 'Male')? 'Mr': 'Ms';
                holder.title = (holder.gender == 'M')? 'Mr': 'Ms';
                
                system.debug('nationalityEnMap:'+nationalityEnMap.size()+' nationalityEnMap.get(np.Nationality__c):'+nationalityEnMap.containsKey(np.Nationality__c));
                holder.nationality = np.Nationality__c;
                if(nationalityEnMap.get(np.Nationality__c) != null){
                    holder.nationalityCode = nationalityEnMap.get(np.Nationality__c);
                }
                
                if(String.isNotBlank(np.ID_Type__c)){
                    String IDType = String.ValueOf(np.ID_Type__c);
                    if(IDType == 'None'){
                        holder.IDType = 'XX';
                    }else if(IDType == 'HK PERM RESIDENT'){
                        holder.IDType = '01';
                    }else if(IDType == 'HK NON-PERM RESIDENT'){
                        holder.IDType = '02';
                    }else if(IDType == 'NON-HK RESIDENT'){
                        holder.IDType = '03';
                    }
                    
                }
                holder.ssnNumber = np.Personal_ID__c;
                holder.IDExpiryDate = np.ID_Expiry_Date__c;
                holder.birthDate = String.ValueOf(np.Date_of_Birth__c);
                if(countryMap.get(np.Place_of_Birth__c) != null){
                    holder.birthPlace = countryMap.get(np.Place_of_Birth__c).Country_Id__c;
                }
                holder.emailAddress = np.Policy_Holder_Email_Address__c;
                if(String.isBlank(np.Policy_Holder_Email_Address__c)){
                    holder.emailAddress = 'N/A';
                }
                holder.homePhoneNumber = np.Home_Phone__c;
                holder.officePhoneNumber = np.Office_Phone__c;      
                holder.phoneNumber = '00000000';            
                if(String.isNotBlank(np.Mobile_Phone__c)){
                    holder.phoneNumber = np.Mobile_Phone__c;               
                }
                
                //If non life product, residential address is empty.
                // if(np.Product__r.Is_Life__c || np.Product_Code__c == '@NELG' || np.Product_Code__c == '@NESG'){//JR1641/* add by Jack on 2022-01-19 for project: IA AML */
                holder.resAddrLine1 = np.Residential_Address_1__c;
                holder.resAddrLine2 = np.Residential_Address_2__c;
                holder.resAddrLine3 = np.Residential_Address_3__c;
                holder.resAddrLine4 = np.Residential_Address_4__c;
                if(countryMap.get(np.Residential_Address_Country__c) != null){
                    holder.resCountry = countryMap.get(np.Residential_Address_Country__c).Country_Id__c;
                }
                // }
                
                holder.permAddrLine1 = np.Permanent_Address_1__c;
                holder.permAddrLine2 = np.Permanent_Address_2__c;
                holder.permAddrLine3 = np.Permanent_Address_3__c;
                holder.permAddrLine4 = np.Permanent_Address_4__c;
                if(countryMap.get(np.Permanent_Address_Country__c) != null){
                    holder.permCountry = countryMap.get(np.Permanent_Address_Country__c).Country_Id__c;
                }
                holder.corrAddrLine1 = String.isNotBlank(np.Corresponding_Address_1__c) ? np.Corresponding_Address_1__c : np.Residential_Address_1__c ;
                holder.corrAddrLine2 = String.isNotBlank(np.Corresponding_Address_2__c) ? np.Corresponding_Address_2__c : np.Residential_Address_2__c ;
                holder.corrAddrLine3 = String.isNotBlank(np.Corresponding_Address_3__c) ? np.Corresponding_Address_3__c : np.Residential_Address_3__c ;
                holder.corrAddrLine4 = String.isNotBlank(np.Corresponding_Address_4__c) ? np.Corresponding_Address_4__c : np.Residential_Address_4__c ;
                if(countryMap.get(np.Corresponding_Address_Country__c) != null){
                    holder.corrCountry = countryMap.get(np.Corresponding_Address_Country__c).Country_Id__c;
                }
                holder.taxNumber1 = np.Tax_Num_1__c;
                if(countryMap.get(np.Tax_Residence_1__c) != null){
                    holder.taxCountry1 = countryMap.get(np.Tax_Residence_1__c).Country_Id__c;
                }
                holder.taxNumber2 = np.Tax_Num_2__c;
                if(countryMap.get(np.Tax_Residence_2__c) != null){
                    holder.taxCountry2 = countryMap.get(np.Tax_Residence_2__c).Country_Id__c;
                }
                holder.taxNumber3 = np.Tax_Num_3__c;
                if(countryMap.get(np.Tax_Residence_3__c) != null){
                    holder.taxCountry3 = countryMap.get(np.Tax_Residence_3__c).Country_Id__c;
                }
                holder.planType = np.Plan_Type__c;
                
                //AML field
                holder.businessNature = businessPartnerMap.get(np.Business_Nature__c); 
                holder.sourceOfFund = sourceOfFundMap.get(np.Source_of_Fund__c);
                holder.sourceOfFundOther = np.Other_Source_of_Fund__c;
                holder.meansOfIncome = meansOfIncomeMap.get(np.Means_of_Income__c);
                holder.meansOfIncomeOther = np.Means_of_Income_Additional_Information__c;
                holder.position = np.Position__c;
                if(np.Company__c != null){//jack modify for null value handle
                    holder.companyName = np.Company__c.left(50);
                }
                if(countryMap.get(np.Country__c) != null){
                    holder.companyCountry = countryMap.get(np.Country__c).Country_Id__c;
                }
                //holder.companyCountry = np.Country__c;
                holder.educationLevel = educationLevelMap.get(np.Education_Level__c);
                holder.educationLevelOther = np.Education_Level_Additional_Information__c;
                
                //AM project jack add
                HttpCalloutVO.Membership phMembership=new HttpCalloutVO.Membership();
                phMembership.membershipFirstName = np.Asia_Miles_Membership_First_Name__c;
                phMembership.membershipLastName = np.Asia_Miles_Membership_Last_Name__c;
                phMembership.membershipId = np.Asia_Miles_Membership_Num__c;
                holder.membership = phMembership;

                criteria.policyHolderList.add(holder);
                
                criteria.firstName = 'Unnamed';
                criteria.lastName = 'Unnamed';
                if(String.isNotBlank(pi.Insured_First_Name__c)){
                    criteria.firstName = pi.Insured_First_Name__c;
                }
                if(String.isNotBlank(pi.Insured_Last_Name__c)){
                    criteria.lastName = pi.Insured_Last_Name__c;
                }
                criteria.maritalStatus = pi.Marital_Status__c;
                criteria.gender = (pi.Gender__c == 'Male')? 'M': 'F';
                criteria.title = (pi.Gender__c == 'Male')? 'Mr': 'Ms';
                criteria.nationality = pi.Nationality__c;
                if(nationalityEnMap.get(pi.Nationality__c) != null){
                    criteria.nationalityCode = nationalityEnMap.get(pi.Nationality__c);
                }
                criteria.relationship = relationMap.get(pi.Relationship__c);
                if(String.isNotBlank(pi.ID_Type__c)){
                    String IDType = String.ValueOf(pi.ID_Type__c);
                    if(IDType == 'None'){
                        criteria.IDType = 'XX';
                    }else if(IDType == 'HK PERM RESIDENT'){
                        criteria.IDType = '01';
                    }else if(IDType == 'HK NON-PERM RESIDENT'){
                        criteria.IDType = '02';
                    }else if(IDType == 'NON-HK RESIDENT'){
                        criteria.IDType = '03';
                    }
                    
                }
                criteria.ssnNumber = pi.Personal_ID__c;
                criteria.birthDate = String.ValueOf(pi.Date_of_Birth__c);
                /* add by Jack on 2021-12-20 for project: IA AML nationality mandatory */
                if(countryMap.get(pi.Place_of_Birth__c) != null){
                    criteria.birthPlace = countryMap.get(pi.Place_of_Birth__c).Country_Id__c;
                }
                criteria.emailAddress = pi.Email__c;
                if(String.isBlank(pi.Email__c)){
                    criteria.emailAddress = 'N/A';
                }
                
                criteria.phoneNumber = np.Mobile_Phone__c;  //only SetNBComplete set PI phone number default to PH phone number 
                
                criteria.occupation = pi.Position__c;
                
                criteria.corrAddrLine1 = pi.Corresponding_Address_1__c;
                criteria.corrAddrLine2 = pi.Corresponding_Address_2__c;
                criteria.corrAddrLine3 = pi.Corresponding_Address_3__c;
                criteria.corrAddrLine4 = pi.Corresponding_Address_4__c;
                
                //Add by Manuel for VHIS products
                if(pi.Place_of_Residence_picklist__c!=null&&countryMap.containsKey(pi.Place_of_Residence_picklist__c)){
                    criteria.placeOfRes = countryMap.get(pi.Place_of_Residence_picklist__c).Country_Id__c; 
                }
                
                //add by Andy for DPSP-658
                if(np.UW_Requirement__c == 'SU'){
                    criteria.height = String.ValueOf(pi.Height__c);
                    criteria.weight = String.ValueOf(pi.Weight__c);
                    criteria.smokeInd = (pi.Smoker__c == 'yes')? 'Y': 'N';
                }else{   // if(np.UW_Requirement__c == 'GA')
                    criteria.height = '';
                    criteria.weight = '';
                    criteria.smokeInd = (pi.Smoker__c == 'yes')? 'Y': 'N';
                    /*
                    if(np.Product_Code__c == 'RSM'){
                    criteria.smokeInd = (pi.Smoker__c == 'yes')? 'Y': 'N';
                    }else{
                    criteria.smokeInd = 'N';
                    }
                    */
                }
                
                criteria.income = pi.Income_HKD__c;
                if(String.isNotBlank(np.Payment_Frequency__c)){
                    if(np.Payment_Frequency__c.equalsIgnoreCase('Monthly')){
                        criteria.paymentMode = 'M';
                    }else{
                        criteria.paymentMode = 'A';
                    }
                }
                
                //if(discountCodeMap.get(np.Discount_1__c) != null){
                //    criteria.discountCode1 = discountCodeMap.get(np.Discount_1__c);
                //}
                //if(discountCodeMap.get(np.Discount_2__c) != null){
                //    criteria.discountCode2 = discountCodeMap.get(np.Discount_2__c);
                //}
                //Add by Owen on 2024.1.10,for elite360 product code check                                           
                if((np.product_Code__c=='@NESG2'||np.product_Code__c=='@NELG2')&&(discountCodeDecripMap.get('CHILD DISCOUNT*')==np.Discount_Code_1_to_IPAS__c)&&(discountCodeDecripMap.get('ELITE 360 3 MONTH REFUND')==np.Discount_Code_2_to_IPAS__c)){
                    criteria.discountCode1 = np.Discount_Code_1_to_IPAS__c;
                }else if((np.product_Code__c=='@NESG2'||np.product_Code__c=='@NELG2')&&(discountCodeDecripMap.get('CHILD DISCOUNT*')==np.Discount_Code_2_to_IPAS__c)&&(discountCodeDecripMap.get('ELITE 360 3 MONTH REFUND')==np.Discount_Code_1_to_IPAS__c)){
                    criteria.discountCode2 = np.Discount_Code_2_to_IPAS__c;
                }else{
                    criteria.discountCode1 = np.Discount_Code_1_to_IPAS__c;
                    criteria.discountCode2 = np.Discount_Code_2_to_IPAS__c;
                }
                
                //criteria.billMethod = np.payment_type__c;     commented by Andy 
                //criteria.billFreq = np.Payment_Frequency__c;  commented by Andy 
                
                // 70 - Credit card. Field "creditcard_number" is not allowed null.
                // 20 - Direct Debit. Field "bank_accnumber" is not allowed null.
                // 30 - Cheque
                if(np.Payment_Type__c == 'Credit Card Billing'){
                    criteria.accountNumber = np.Credit_Card_Number__c;
                    criteria.creditCardExpiryDate = np.Card_Expiry_Date__c;
                    criteria.PayType = '70';
                    // 20200717 - minghua - SF Modeling
                    criteria.newAccountNumberInd = np.Is_Masked_Payment_Info__c ? false : true;
                }
                if(np.Payment_Type__c == 'Direct Billing'){
                    criteria.accountNumber = np.Bank_Account_No__c;
                    criteria.creditCardExpiryDate = null;
                    criteria.PayType = '20';
                }
                if(np.Payment_Type__c == 'Cheque' || String.isBlank(np.Payment_Type__c)){
                    criteria.accountNumber = null;
                    criteria.creditCardExpiryDate = null;
                    criteria.PayType = '30';
                }
                if(np.Actual_Premium__c != null){
                    if(criteria.policyStatus != '5'){
                        criteria.PayAmount = np.Actual_Premium__c.toPlainString();
                    }else{
                        criteria.PayAmount = '0';
                    }
                }
                // Rancho_HKITSFDC402_20250930 - replace annual premium with sum insured
                // if(np.Annual_Premium__c != null){
                //     if(criteria.policyStatus != '5'){
                //         criteria.sumInsured = np.Annual_Premium__c.toPlainString();
                //     }else{
                //         criteria.sumInsured = '0';
                //     }
                // }
                criteria.sumInsured = np.Sum_Insured__c != null ? np.Sum_Insured__c.toPlainString() : '0';

                criteria.policyCurrency = (pt.Selected_Campaign__c == null) ? pt.Core_Campaign__r.Core_Product__r.Currency__c : pt.Selected_Campaign__r.Core_Product__r.Currency__c; //pt.Core_Campaign__r.Core_Product__r.Currency__c
                criteria.AMLHighRiskInd = (np.AML_High_Risk_Ind__c == 'Y');
                criteria.optOutInd = (pt.Opportunity__r.Overall_Opt_Out__c == true ? 'Y' : 'N');
                criteria.policyRef = pt.Opportunity__r.Maturity_Policy_Number__c;
                // jack add for friend and family discount in SFDC
                // criteria.masterPolicy = np.Master_Policy_No__c;
                // criteria.relationshipOfPolicy = np.Relationship_Of_Policy__c;
                if((String.isNotBlank(np.Discount_1__c)&&tmpDiscountCodeMap.containsKey(np.Discount_1__c)&&tmpDiscountCodeMap.get(np.Discount_1__c).Group__c=='FAMILY DISCOUNT') || (String.isNotBlank(np.Discount_2__c)&&tmpDiscountCodeMap.containsKey(np.Discount_2__c)&&tmpDiscountCodeMap.get(np.Discount_2__c).Group__c=='FAMILY DISCOUNT')){
                    criteria.masterPolicy = np.Master_Policy_of_Friend_Discount__c;
                    criteria.relationshipOfPolicy = np.Relationship_of_Friend_Discount__c;
                }else{
                    criteria.masterPolicy = np.Master_Policy_No__c;
                    criteria.relationshipOfPolicy = np.Relationship_Of_Policy__c;
                }
                
                
                //criteria.policyPremium = '1'; // can be removed
                //criteria.exclusion = '2';  // can be removed
                //criteria.medicalLoading = '2';  // can be removed
                
                criteria.UWFullUWResult = uwResultMap.get(np.UW_Overrall_Result__c); // np.UW_Result__c;
                
                //criteria.loadingDuration = '2';
                //criteria.transactionDate = System.now().format('yyyy-MM-dd HH:mm:ss.SSS\'Z\'');
                criteria.transactionDate = String.valueOf(now.date());
                criteria.transactionTime = String.valueOf(now.time());
                
                //criteria.assessment = ESalesUtility.getAssessment(pt.Opportunity__r.Objectives_Question__c, pt.Opportunity__r.Which_type_s_of_medical_insurance__c);//GL31 jack add
                criteria.assessment = ESalesUtility.getAssessment(pt.Objectives_Question__c, pt.Which_type_s_of_medical_insurance__c);//GL31 jack add//add by jack for policy replacement
                if(np.Product__r.Is_Life__c){
                    criteria.appDate = now.date();
                }
                //criteria.loadingPremiumRate = '+' + String.valueOf(Integer.valueOf(np.Loading__c)).leftpad(3, '0');
                criteria.loadingPremiumRate = String.valueOf(Integer.valueOf(np.Loading__c));
                criteria.fullUWProductCode = np.Plan_code__c;
                
                //AM project coupon jack add
                List<Coupon> couponList=new List<Coupon>();
                if(np.Coupons__r != null){
                    for(Coupon__c couponS:np.Coupons__r){
                        Coupon coupon=new Coupon(couponS);
                        couponList.add(coupon);
                    }
                }
                criteria.couponList=couponList;
                //AM project coupon jack add

                //Nicole_20200105_SPS-340
                Map<String, String> UWMap = new Map<String, String>();
                if(np.UW_Result__r != null){
                    for(UW_Result__c uw : np.UW_Result__r){
                        UWMap.put(np.Policy_No__c+uw.Product_Code__c,uw.Product_UW_Result__c);
                    }
                }
                
                /*
* Below is for UWFullUW Tag Related
* UWFullUWId/UWFullUWResult/UWFullUWProductCode/UWFullUWRiskType/UWFullUWBasicPlanResult/LoadingPremiumRate 
* Will use respective field in Basic Plan (uwresult.is_Basic_plan__c = true)
*/
                
                system.debug('Test start');
                if(np.UW_Result__r != null){
                    system.debug('uw result');
                    List<HttpCalloutVO.NBFullUWRiskResult> fullUWRiskList = new List<HttpCalloutVO.NBFullUWRiskResult>();
                    for(UW_Result__c uw : np.UW_Result__r){
                        if(uw.is_Basic_plan__c){
                            criteria.uwFullUWId = uw.Case_Id__c;
                            criteria.uwFullUWRiskType = uw.risk_type__c;
                            
                            //Nicole_20200105_SPS-340
                            //criteria.uwBasicProductResult = uwResultMap.get(np.UW_Result__c);
                            criteria.uwBasicProductResult = uwResultMap.get(uw.Product_UW_Result__c);
                        }else{
                            //Nicole_20200105_SPS-340                                               
                            /*if(String.isBlank(criteria.uwRiderResult1)){
                                criteria.uwRiderResult1 = uwResultMap.get(np.UW_Result__c);                            
                            }else if(String.isBlank(criteria.uwRiderResult2)){
                                criteria.uwRiderResult2 = uwResultMap.get(np.UW_Result__c);                            
                            }else if(String.isBlank(criteria.uwRiderResult3)){
                                criteria.uwRiderResult3 = uwResultMap.get(np.UW_Result__c);                           
                            }else if(String.isBlank(criteria.uwRiderResult4)){
                                criteria.uwRiderResult4 = uwResultMap.get(np.UW_Result__c);
                            }else if(String.isBlank(criteria.uwRiderResult5)){
                                criteria.uwRiderResult5 = uwResultMap.get(np.UW_Result__c);
                            }else if(String.isBlank(criteria.uwRiderResult6)){
                                criteria.uwRiderResult6 = uwResultMap.get(np.UW_Result__c);                            
                            }else if(String.isBlank(criteria.uwRiderResult7)){//Combo: maybe 7 riders -20201209
                                criteria.uwRiderResult7 = uwResultMap.get(np.UW_Result__c);
                            }*/
                            //TEMPORARY
                            criteria.uwRiderResult1 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider1));
                            criteria.uwRiderResult1 = String.isBlank(criteria.uwRiderResult1)?null:criteria.uwRiderResult1;
                            criteria.uwRiderResult2 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider2));
                            criteria.uwRiderResult2 = String.isBlank(criteria.uwRiderResult2)?null:criteria.uwRiderResult2;
                            criteria.uwRiderResult3 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider3));
                            criteria.uwRiderResult3 = String.isBlank(criteria.uwRiderResult3)?null:criteria.uwRiderResult3;
                            criteria.uwRiderResult4 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider4));
                            criteria.uwRiderResult4 = String.isBlank(criteria.uwRiderResult4)?null:criteria.uwRiderResult4;
                            criteria.uwRiderResult5 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider5));
                            criteria.uwRiderResult5 = String.isBlank(criteria.uwRiderResult5)?null:criteria.uwRiderResult5;
                            criteria.uwRiderResult6 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider6));
                            criteria.uwRiderResult6 = String.isBlank(criteria.uwRiderResult6)?null:criteria.uwRiderResult6;
                            //Combo: maybe 7 riders -20201209
                            criteria.uwRiderResult7 = uwResultMap.get(UWMap.get(np.Policy_No__c+criteria.rider7));
                            criteria.uwRiderResult7 = String.isBlank(criteria.uwRiderResult7)?null:criteria.uwRiderResult7;
                            //TEMPORARY
                        }
                        
                        //UW Result Exclusion
                        for(Integer i = 1; i <= 10; i++){
                            Object exl = uw.get('UW_EXCL_'+String.valueOf(i)+'__c');
                            if(String.isNotBlank(String.valueOf(exl))){
                                //split into code and description
                                String exlStr = String.valueOf(exl);
                                List<String> codeDes = exlStr.split(' : ');
                                
                                HttpCalloutVO.NBFullUWRiskResult uwr = new HttpCalloutVO.NBFullUWRiskResult();
                                uwr.fullUWPlan = uw.product_code__c;
                                uwr.fullUWCode = codeDes[0];
                                uwr.fullUWDescription = codeDes[1];
                                uwr.fullUWType = 'Exclusion';
                                
                                fullUWRiskList.add(uwr);
                            }
                        }
                        
                        List<HttpCalloutVO.NBFullUWProductLoadingResult> fullUWProductLoadingResultList = new List<HttpCalloutVO.NBFullUWProductLoadingResult>();
                        //UW Result Remark
                        for(Integer i = 1; i <= 10; i++){
                            Object exl = uw.get('UW_Remark_'+String.valueOf(i)+'__c');
                            if(String.isNotBlank(String.valueOf(exl))){
                                //split into code and description
                                String exlStr = String.valueOf(exl);
                                List<String> codeDes = exlStr.split(' : ');
                                
                                HttpCalloutVO.NBFullUWRiskResult uwr = new HttpCalloutVO.NBFullUWRiskResult();
                                uwr.fullUWPlan = uw.product_code__c;
                                uwr.fullUWCode = codeDes[0];
                                uwr.fullUWDescription = codeDes[1];
                                uwr.fullUWType = 'Remark';
                                uwr.fullUWDeclineInd = ''; //Add by Manuel for VHIS products
                                fullUWRiskList.add(uwr);
                                
                                if(uwr.fullUWCode.contains('LOAD')){
                                    HttpCalloutVO.NBFullUWProductLoadingResult fuwLoad = new HttpCalloutVO.NBFullUWProductLoadingResult();
                                    fuwLoad.fullUWProductCode = criteria.fullUWProductCode;
                                    fuwLoad.fullUWLoadingType = '1';
                                    fuwLoad.fullUWLoadingValue = criteria.loadingPremiumRate;
                                    fuwLoad.fullUWLoadingDuration = '999';
                                    
                                    fullUWProductLoadingResultList.add(fuwLoad);
                                    break;
                                }
                            }
                        }
                        criteria.fullUWProductLoadingResultList = fullUWProductLoadingResultList;
                    }
                    criteria.fullUWRiskList = fullUWRiskList;
                }
                
                if(np.UW_Result__r != null && np.UW_Result__r.size()==0){
                    //Nicole_20200114_SPS-340
                    system.debug('uw result null');
                    criteria.uwBasicProductResult = uwResultMap.get('Accept');
                    if(String.IsNotBlank(criteria.rider1)){criteria.uwRiderResult1 = uwResultMap.get('Accept');}
                    if(String.IsNotBlank(criteria.rider2)){criteria.uwRiderResult2 = uwResultMap.get('Accept');}
                    if(String.IsNotBlank(criteria.rider3)){criteria.uwRiderResult3 = uwResultMap.get('Accept');}
                    if(String.IsNotBlank(criteria.rider4)){criteria.uwRiderResult4 = uwResultMap.get('Accept');}
                    if(String.IsNotBlank(criteria.rider5)){criteria.uwRiderResult5 = uwResultMap.get('Accept');}
                    if(String.IsNotBlank(criteria.rider6)){criteria.uwRiderResult6 = uwResultMap.get('Accept');}
                    // Combo: maybe has 7 riders -20201209
                    if(String.IsNotBlank(criteria.rider7)){criteria.uwRiderResult7 = uwResultMap.get('Accept');}
                }    
                
                //Wellness
                if(np.Refund_Discount__c == 'Personal Choice premium refund'){
                    criteria.refundPolicyRef = String.isNotBlank(np.Personal_Choice_Policy_Number__c)?np.Personal_Choice_Policy_Number__c:'';
                }else if(np.Refund_Discount__c == 'Bundle premium refund' || np.Refund_Discount__c == 'Loyalty premium refund'){
                    criteria.refundPolicyRef = String.isNotBlank(np.Master_Policy_No__c)?np.Master_Policy_No__c:'';
                }
                if(String.isNotBlank(np.Refund_Discount__c)){
                    criteria.refundDiscountCode = wellnessRemarkMap.containsKey(np.Refund_Discount__c)?wellnessRemarkMap.get(np.Refund_Discount__c).Code__c:'';
                }
                //Wellness
                
                // Prospect
                HttpCalloutVO.NBProspect prospect = new HttpCalloutVO.NBProspect();
                prospect.runningNumber = np.Running_No__c;
                prospect.prospectID = pt.Opportunity__r.Prospect_Id__c;
                prospect.IQID = np.IQ_ID__c;
                prospect.activity = pt.Opportunity__r.Source_of_Activity__c;
                prospect.supervisorID = pt.Opportunity__r.Owner.Supervisor_ID__c;
                prospect.agentID = pt.Opportunity__r.Owner.TM_Agent_ID__c;
                prospect.callStartTime = now.format('yyyy-MM-dd HH:mm:ss.SSS\'Z\'');
                prospect.callEndTime = now.format('yyyy-MM-dd HH:mm:ss.SSS\'Z\'');
                //Jobr-328,add by Owen 2023-09-13 to allow '500' term code pass
                prospect.callID = pt.Opportunity__r.Term_Code__c=='500'?'400':pt.Opportunity__r.Term_Code__c;
                prospect.callListID = pt.Opportunity__r.Batch_No__c;
                prospect.callListStartDate = pt.Core_Campaign__r.StartDate;
                prospect.callListEndDate = pt.Core_Campaign__r.EndDate;
                prospect.sponsorCode = pt.Core_Campaign__r.Business_Partner__r.Sponsor_Code__c;
                prospect.channelCode = pt.Core_Campaign__r.Channel__r.Channel_Code__c;
                prospect.campaignType = pt.Core_Campaign__r.Campaign_Type__r.Name;
                if(pt.Account__c != null){
                    prospect.remark1 = pt.Account__r.Prospect_reference1__c;
                    // Rancho_20240619 - do not sync to cigna due to CX lucky draw may insert a long text, cigna limit is 100
                    // prospect.remark2 = pt.Account__r.Reference2__pc;
                    // prospect.remark3 = pt.Account__r.Reference3__pc;
                    // prospect.remark4 = pt.Account__r.Reference4__pc;
                    prospect.remark5 = pt.Account__r.Reference5__pc;
                }
                //VHIS REVamp jack add
                if(pt.Opportunity__r.Submission_Date__c != null){
                    prospect.createDate=pt.Opportunity__r.Submission_Date__c;
                }else{
                    prospect.createDate=now.date();
                }
                prospect.optOutDate = pt.Opportunity__r.LastModifiedDate.date();
                criteria.prospect = prospect;
                
                // Beneficiary
                criteria.beneficiaryOwnerList = new List<HttpCalloutVO.BeneficiaryOwner>();
                for(Beneficiary__c ben : np.Beneficiary__r){
                    HttpCalloutVO.BeneficiaryOwner be = new HttpCalloutVO.BeneficiaryOwner();
                    be.firstName = ben.First_Name__c;
                    be.lastName = ben.Last_Name__c;
                    if(String.isNotBlank(ben.Gender__c)){
                        be.gender = (ben.Gender__c == 'Male') ? 'M': 'F';
                    }
                    //be.gender = (ben.Gender__c == 'Male') ? 'M': 'F';
                    be.SSNNumber = ben.Person_ID__c;
                    be.relationship = relationMap.get(ben.Relationship__c);
                    criteria.beneficiaryOwnerList.add(be);
                }
                
                //add by kermit at 20190718 for JR1727
                if('Accept'.equalsIgnoreCase(np.Appeal_For_UW_Result__c)){
                    criteria.clientDecision = '1';
                }else if('Withdrawn'.equalsIgnoreCase(np.Appeal_For_UW_Result__c)){
                    criteria.clientDecision = '2';
                }else if('Appeal'.equalsIgnoreCase(np.Appeal_For_UW_Result__c)){
                    criteria.clientDecision = '3';
                }else if(String.isBlank(np.Appeal_For_UW_Result__c)){
                    criteria.clientDecision = '1'; //WEI-315: "null" client decision for website case
                }
                if('Accepted'.equalsIgnoreCase(np.Pre_Sales_Result__c)){
                    criteria.uwPreUWResult = '1';
                }else if('Declined'.equalsIgnoreCase(np.Pre_Sales_Result__c)){
                    criteria.uwPreUWResult = '2';
                }else if('Referred'.equalsIgnoreCase(np.Pre_Sales_Result__c)){
                    criteria.uwPreUWResult = '3';
                }
                //end add
                
                try{
                    List<HttpCalloutVO.NBResult> NBResult = helper.setNBComplete(criteria);
                    if(NBResult != null && NBResult.size() > 0){
                        New_Policy__c submittedPolicy = new New_Policy__c();
                        submittedPolicy.id = pi.New_Policy__c;
                        submittedPolicy.Product_Code__c = np.Product_Code__c;//add by ken 20181212, reason: product code is null
                        submittedPolicy.UW_Overrall_Result__c = np.UW_Overrall_Result__c;  //add by Andy 20180802 Get Policy overall result
                        
                        if(submittedPolicy.Policy_Status__c != 'Rejected'){
                            submittedPolicy.Policy_Status__c = 'Submitted';
                        }
                        //added by Charles, mark down setNBComplete WS date time
                        submittedPolicy.SetNBComplete_Date_Time__c = now;
                        submittedPolicy.Control_Report_Date__c = today;
                        
                        if(np.Submission_Date_Time__c != null){
                            Date submissionDate = np.Submission_Date_Time__c.date();
                            if(String.isNotBlank(submittedPolicy.Product_Code__c) && !'RSM'.equals(submittedPolicy.Product_Code__c.replace('@', ''))){
                                submittedPolicy.Policy_Effective_Date__c = submissionDate;
                            }
                            submittedPolicy.Billing_Date__c = submissionDate;
                            System.debug('>>>>>>>submissionDate='+submissionDate+'   submittedPolicy='+submittedPolicy);
                            if(submissionDate.day() > 28 && !'RSM'.equals(submittedPolicy.Product_Code__c.replace('@', ''))){
                                submittedPolicy.Policy_Effective_Date__c = Date.newInstance(submissionDate.year(), submissionDate.month(), 28);
                                submittedPolicy.Billing_Date__c = Date.newInstance(submissionDate.year(), submissionDate.month(), 28);
                            }
                        }
                        submittedPolicy.SetNBComplete_Failure_Reason__c = null;

                        // 20200717 - minghua - SF Modeling
                        if(np.Payment_Type__c == 'Credit Card Billing'){
                            submittedPolicy.Credit_Card_Number__c = TMPolicyUtil.maskBankAccountNumber(np.Credit_Card_Number__c);
                        }
                        
                        submittedPolicies.add(submittedPolicy);
                        if('400'.equals(criteria.prospect.callID)){ //add for SPS-89
                            submitWorkRequestPolicies.add(submittedPolicy);
                        }

                        // TM Work From Home_20200828
                        System.debug('NBResult[0].statusCode:'+NBResult[0].statusCode);
                        if(NBResult[0].statusCode == 'SUCCESS'){
                            opportunityList.add(np.Policy_Transaction__r.Opportunity__c);
                        }else{//SPS-667 jack add
                            policyTransSubmitResultMap.put(np.Policy_Transaction__c,TO_IPAS_FIALED);
                            failedOppList.add(np.Policy_Transaction__r.Opportunity__c);// Rancho_SpeechAnalytics_20210607
                        }//SPS-667 jack add
                    }
                    system.debug('NBResult: ' + NBResult);
                }catch(Exception e){
                    system.debug('>>> ' + e.getMessage());
                    system.debug('>>> ' + e.getLineNumber());
                    system.debug('>>> ' + e.getStackTraceString());
                    New_Policy__c failedPolicie = new New_Policy__c();
                    failedPolicie.id = pi.New_Policy__c;
                    failedPolicie.SetNBComplete_Failure_Reason__c = e.getMessage();
                    failedPolicies.add(failedPolicie);
                    policyTransSubmitResultMap.put(np.Policy_Transaction__c,TO_IPAS_FIALED);//SPS-667 jack add
                    // Rancho_SPS728_20210602
                    // only duplicate submittion error will be added into dupliErrMsgSet, and all the other error added into otherErrMsgSet
                    if(!e.getMessage().contains(Label.setNBComplete_Duplicate_Submission_Error)){
                        otherErrMsgSet.add(np.Policy_Transaction__c+e.getMessage());
                    }else{
                        dupliErrMsgSet.add(np.Policy_Transaction__c+e.getMessage());
                    }
                }
                policyTransactionIdSet.add(np.Policy_Transaction__c);
                
            }
            system.debug('submittedPolicies.size(): ' + submittedPolicies.size());
            system.debug('submittedPolicies: ' + submittedPolicies);
            if(piList.size()>0){
                storeTheErrorInfo(String.valueOf(npIds),String.valueOf(piList),String.valueOf(npList),String.valueOf(submittedPolicies), String.valueOf(failedPolicies), String.valueOf(submitWorkRequestPolicies));
            }

            // Call Submit Work Request for those Reffered case
            if(!submittedPolicies.isEmpty()){
                system.debug('Update submittedPolicy.Billing_Date__c='+submittedPolicies[0].Billing_Date__c);
                update submittedPolicies;
                
                List<String> policyNoList = new List<String>();
                List<Attachment> attList = new List<Attachment>();
                List<Boolean> sideOrderIndList = new List<Boolean>();
                List<Boolean> postDeduplicationIndList = new List<Boolean>();
                List<String> remarks2cignaunderwriterList = new List<String>();//add by ken, pass appeal message to Appian through submitworkrequest
                List<String> uwAppealList = new List<String>(); //add by Andy
                List<Person_Insured__c> PersonInsuredList=new List<Person_Insured__c>();/* add by Jack on 2021-12-03 for project: JR1829 */
                
                // add by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
                List<String> policyNoListAccept = new List<String>();
                List<Attachment> attListAccept = new List<Attachment>();
                List<Boolean> sideOrderIndListAccept = new List<Boolean>();
                List<Boolean> postDeduplicationIndLisAcceptt = new List<Boolean>();
                List<String> remarks2cignaunderwriterListAccept = new List<String>();
                List<String> uwAppealListAccept = new List<String>();
                
                //for(New_Policy__c np : submittedPolicies){
                for(New_Policy__c np : submitWorkRequestPolicies){
                    system.debug('submiited policy:' + np);
                    //Will only call submitworkrequest when UW_Overrall_Result__c == 'Referred'
                    // update by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
                    if(String.isNotBlank(np.UW_Overrall_Result__c)){
                        New_Policy__c npc = npMap.get(np.Id);
                        String uwexcl = '';
                        Decimal loadInt = 0;
                        if(npc.UW_Result__r != null && npc.UW_Result__r.size() > 0){
                            uwexcl = npc.UW_Result__r[0].UW_EXCL_1__c;
                            loadInt = npc.UW_Result__r[0].Loading__c;
                        }
                        
                        Attachment att = getAutoUWApplicationPDF(npc.Policy_No__c);
                        Boolean sideOrderInd = npc.is_Side_Order__c != null ? npc.is_Side_Order__c : false;
                        Boolean postDeduplicationInd = (String.isNotBlank(npc.UW_Requirement__c) && npc.UW_Requirement__c.equalsIgnoreCase('GA')) ? true : false;
                        String remarks2cignaunderwriter = npc.Remarks_to_Cigna_Underwriter_2__c;
                        String appealRemark = npc.Appeal_For_UW_Result__c;
                        
                        if(np.UW_Overrall_Result__c == 'Referred'){
                            policyNoList.add(npc.Policy_No__c);
                            attList.add(att);
                            sideOrderIndList.add(sideOrderInd);
                            postDeduplicationIndList.add(postDeduplicationInd);
                            remarks2cignaunderwriterList.add(null==remarks2cignaunderwriter?'':remarks2cignaunderwriter);
                            uwAppealList.add(null==appealRemark?'':appealRemark);
                            PersonInsuredList.add(policyIdPiMap.get(np.id));/* add by Jack on 2021-12-03 for project: JR1829 */
                        }else if(np.UW_Overrall_Result__c == 'Accepted'&&(loadInt>0||String.isNotBlank(uwexcl))){
                            policyNoListAccept.add(npc.Policy_No__c);
                            attListAccept.add(att);
                            sideOrderIndListAccept.add(sideOrderInd);
                            postDeduplicationIndLisAcceptt.add(postDeduplicationInd);
                            remarks2cignaunderwriterListAccept.add(null==remarks2cignaunderwriter?'':remarks2cignaunderwriter);
                            uwAppealListAccept.add(null==appealRemark?'':appealRemark);
                        }
                    }
                }
                if(!policyNoList.isEmpty() && !Test.isRunningTest()){
                        String jobId = System.enqueueJob(new TMSubmitWorkRequestQueue(policyNoList, postDeduplicationIndList, sideOrderIndList, attList, remarks2cignaunderwriterList,uwAppealList,PersonInsuredList)); /* add by Jack on 2021-12-03 for project: JR1829 *///change by ken, pass appeal message to Appian through submitworkrequest
                }
                
                // update by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
                if(!policyNoListAccept.isEmpty() && !Test.isRunningTest()){
                    // String jobId = System.enqueueJob(new TMSubmitWorkRequestQueue(policyNoListAccept, postDeduplicationIndLisAcceptt, sideOrderIndListAccept, attListAccept, remarks2cignaunderwriterListAccept,uwAppealListAccept,'TM cases'));
                }
            }
            
            // Update the failed reason for failed submitted policies
            if(!failedPolicies.isEmpty()){
                update failedPolicies;
            }
        }catch(Exception e){
            Checking_Log__c clog = new Checking_Log__c();
            clog.Function_Name__c = 'TMSubmitPolicyToIpasBatchable.execute';
            clog.ErrorMessage_Long__c = e.getMessage();
            clog.TmpString1__c = String.valueOf(e.getLineNumber());
            clog.TmpString2__c = e.getStackTraceString();
            insert clog;
        }
    }
    
    /********************************************************************************
     * Generate Auto UW Application PDF by policy number
     ********************************************************************************/
    public Attachment getAutoUWApplicationPDF(String policyNumber){
        system.debug('[getAutoUWApplicationPDF] policyNumber='+policyNumber);
        Blob theBlob; 
        String TargetFileName = 'Auto_UW_Application_Form_' + policyNumber;
        PageReference pdf = page.TMReportAutoUWApplicationPDFVFP;
        pdf.getParameters().put('Name', policyNumber); 
        if(!Test.isRunningTest()){ 
            theBlob = pdf.getContentAsPDF();
        }else{
            theBlob = blob.valueof('unit.test');
        }
        File_Store__c fileStore = new File_Store__c();
        fileStore.OwnerId = UserInfo.getUserId();
        fileStore.Owner_id__c = UserInfo.getUserId();
        Insert fileStore;

        Attachment att = new Attachment();
        att.parentId = fileStore.Id;
        att.contentType = 'application/pdf';
        att.name = TargetFileName;
        att.body = theBlob;
        Insert att;
        system.debug('[getAutoUWApplicationPDF] attachmentId='+att.Id);
        return att;
    }  
    
    global void finish(Database.BatchableContext info){
        system.debug('finish ' + info);
        List<Policy_Transaction__c> ptList = new List<Policy_Transaction__c>();
        Map<Id,New_Policy__c> submittedPTAccIdPolicyMap = new Map<Id,New_Policy__c>();
        
        Map<String,String> ssnIdMap = new Map<String,String>();
        Map<String,String> accidSSNMap = new Map<String,String>();
        Boolean isAllPoliciesSubmitted = true;
        for(Policy_Transaction__c pt : [select Account__r.SSN__c,Id,Status__c, Account__r.Id,( select Id,policy_status__c, Policy_Holder_First_Name__c,Policy_Holder_Last_Name__c,Policy_Holder_Name_Chi__c,Mobile_Phone__c,Policy_Holder_Email_Address__c,Personal_ID__c,Gender__c,Date_of_Birth__c,Age__c,Office_Phone__c, Nationality__c, Home_Phone__c, Residential_Address_1__c, Residential_Address_2__c, Residential_Address_3__c, Residential_Address_4__c from NewPolicies__r ) from Policy_Transaction__c where id != null and id in :policyTransactionIdSet]){
     
            /*
            isAllPoliciesSubmitted = true;
            for(New_Policy__c np : pt.NewPolicies__r){
                if(np.policy_status__c != 'Submitted' && np.policy_status__c != 'Invalid' && np.policy_status__c != 'Rejected'){
                    isAllPoliciesSubmitted = false;
                    break;
                }
            }
            if(isAllPoliciesSubmitted && pt.NewPolicies__r.size() > 0){
            */
            //SPS-667 jack add
            String errorResult = policyTransSubmitResultMap.get(pt.id);

            System.debug('errorResult:'+errorResult);
            if(errorResult != null && errorResult.contains(TO_IPAS_FIALED) && errorResult.contains(TO_APPLIAN_FIALED)){
                pt.Status__c = TO_ILAS_AND_APPLIAN_FIALED;
            }else if(errorResult != null && errorResult.contains(TO_IPAS_FIALED)){
                pt.Status__c = TO_IPAS_FIALED;
            }else if(errorResult != null && errorResult.contains(TO_APPLIAN_FIALED)){
                pt.Status__c = TO_APPLIAN_FIALED;
            }else{
                pt.Status__c = 'Submitted';
            }
            //SPS-667 jack add
            // Rancho_SPS728_20210602
            // if policy transaction id is not existing in otherErrMsgSet and is existing in dupliErrMsgSet, 
            // means only duplicate submittion error for the record, and then update status
            System.debug('otherErrMsgSet: '+otherErrMsgSet);
            System.debug('dupliErrMsgSet: '+dupliErrMsgSet);
            if(otherErrMsgSet.isEmpty()){
                if(!dupliErrMsgSet.isEmpty()){
                    for(String s : dupliErrMsgSet){
                        if(s.contains(pt.Id)){pt.Status__c = 'Submitted';}
                        System.debug('1: '+pt.Status__c);
                    }
                }
            }else{
                for(String es : otherErrMsgSet){
                    if(!es.contains(pt.Id) && !dupliErrMsgSet.isEmpty()){
                        for(String s : dupliErrMsgSet){
                            if(s.contains(pt.Id)){pt.Status__c = 'Submitted';}
                            System.debug('2: '+pt.Status__c);
                        }
                    }
                }
            }
            submittedPTAccIdPolicyMap.put(pt.Account__r.id,pt.NewPolicies__r[0]);
            
            ssnIdMap.put(pt.NewPolicies__r[0].Personal_ID__c,pt.Account__r.id);
            accidSSNMap.put(pt.Account__r.id,pt.Account__r.SSN__c);
            
            ptList.add(pt);
            //}
        }
        if(!ptList.isEmpty()){
            update ptList;
        }

        // Rancho_SpeechAnalytics_20210607
        if(!opportunityList.isEmpty()){
            List<String> speechOppList = new List<String>();
            for(String oppId : opportunityList){
                if(!failedOppList.isEmpty() && !failedOppList.contains(oppId)){speechOppList.add(oppId);}
                else if(failedOppList.isEmpty()){speechOppList.add(oppId);}
            }
            if(!speechOppList.isEmpty()){
                CreateNewSpeechAnalyticsLogCtrl newSARecd = new CreateNewSpeechAnalyticsLogCtrl();
                newSARecd.newRecord(speechOppList);
            }
        }
        
        
        /*
        * TS-609
        * update respective account with PH information (DPSP-675)
        * change account record type
        * if currently the account (record type=customer) exists, merge account record 
        * (i.e. move TM customer records and related lists to customer records then delete TM customer records)
        */
        try{
            Map<Id,Id> oldNewAccountIdMap = new Map<Id,Id>();
            List<String> duplicateAccIdList = new List<String>(); 
            List<Id> possibleDuplicateAccIdList = new List<Id>();
            Map<Id,Account> tmCustomerMap = new Map<Id,Account>();
            
                        List<Account> submitPolicyAccountList = [Select Id,lastname, firstname,salutation, Chinese_Name__c, PersonMobilePhone, PersonEmail, Fax, SSN__c, Gender__c, PersonBirthdate__c, Age__c, Nationality__c, TM_Industry__c, Home_Address_Line_1__c, Home_Address_Line_2__c,Home_Address_Line_3__c, Home_Address_Line_4__c, PersonHomePhone, RecordType.developerName from Account where id in :submittedPTAccIdPolicyMap.keySet()];
            
            if(!submitPolicyAccountList.isEmpty()){
                for(Account acc : submitPolicyAccountList){
                    tmCustomerMap.put(acc.id,acc);
                }
            }       
            
            if(!ssnIdMap.keySet().isEmpty()){
                List<Account> possibleDuplicateAccList = [Select Id,lastname, firstname,salutation, Chinese_Name__c, PersonMobilePhone, PersonEmail, Fax, SSN__c, Gender__c, PersonBirthdate__c, Age__c,Nationality__c, TM_Industry__c, Home_Address_Line_1__c, Home_Address_Line_2__c, Home_Address_Line_3__c, Home_Address_Line_4__c, PersonHomePhone, RecordType.developerName from Account where SSN__c in :ssnIdMap.keySet() and (RecordType.developerName = 'Customer' or RecordType.developerName = 'TM_Customer') order by createddate desc];
                if(!possibleDuplicateAccList.isEmpty()){
                    system.debug('possibleDuplicateAccList size ' + possibleDuplicateAccList.size());
                    for(Account ac : possibleDuplicateAccList){
                        //If these two a different account then put it into delete list
                        if(ac.id != ssnIdMap.get(ac.ssn__c)){
                        //Account tmCustomerAccount = tmCustomerMap.get(ssnIdMap.get(ac.SSN__c));
                            New_Policy__c tmCustomerAccount = submittedPTAccIdPolicyMap.get(ssnIdMap.get(ac.ssn__c));
                            
                            system.debug('TM Customer ' + ssnIdMap.get(ac.ssn__c) + ' has existing account' + ac.id);
                            
                            oldNewAccountIdMap.put(ssnIdMap.get(ac.ssn__c), ac.Id);
                            String ptAccountSSN = accidSSNMap.get(ssnIdMap.get(ac.ssn__c));
                            system.debug('ptAccountSSN ' + ptAccountSSN);
                            List<New_Policy__c> EffectivePolicy = [Select id from New_Policy__c where (Policy_transaction__r.status__c = 'Completed' or Policy_transaction__r.status__c = 'Submitted') and Personal_ID__c = :ptAccountSSN];
                            if(!(EffectivePolicy.size()>0)){
                                duplicateAccIdList.add(ssnIdMap.get(ac.ssn__c));
                            }
                        }
                    }
                    update possibleDuplicateAccList;
                    //Database.SaveResult[] possibleDuplicateAccListSr = Database.update(possibleDuplicateAccList,false);
                    
                    //Update Opportunity Related List (Task will auto transfer with oppty)
                    List<Opportunity> needTransferOppty = [Select id,accountId from Opportunity where accountId in :oldNewAccountIdMap.keySet()];
                    if(!needTransferOppty.isEmpty()){
                        system.debug('Process transfer Oppty size ' + needTransferOppty.size());
                        for(Opportunity opp : needTransferOppty){
                            system.debug('Processing transfer Oppty ' + opp.id);
                            opp.accountId = oldNewAccountIdMap.get(opp.accountId);
                            system.debug('Oppty Account Id: ' + opp.accountId);
                        }
                        update needTransferOppty;
                        //Database.SaveResult[] needTransferOpptySr = Database.update(needTransferOppty,false);
                        //system.debug('needTransferOpptySr >>>> ' + needTransferOpptySr);
                    }
                    
                    /*
                    //Update Opt-out History Related list
                    List<Opt_out_History__c> needTransferOptOutHistory = [Select id, Account__c, Account__r.id from Opt_out_History__c where Account__r.id in :oldNewAccountIdMap.keySet()];
                    if(!needTransferOptOutHistory.isEmpty()){
                        system.debug('Process transfer Opt-out History size >>> ' + needTransferOptOutHistory.size());
                        for(Opt_out_History__c oph : needTransferOptOutHistory){
                            system.debug('Processing transfer Opt-out History >>> ' + oph.id);
                            oph.Account__c = oldNewAccountIdMap.get(oph.Account__r.id);
                        }
                        Database.SaveResult[] needTransferOptOutHistorySr = Database.update(needTransferOptOutHistory,false);
                        system.debug('needTransferOptOutHistorySr >>>> ' + needTransferOptOutHistorySr);
                    }
                    */
                    
                    //Update Policy Transaction Related List
                    List<Policy_Transaction__c> needTransferPolicyTransaction = [Select id,Account__c, Account__r.id from Policy_Transaction__c where Account__r.id in :oldNewAccountIdMap.keySet()];
                    if(!needTransferPolicyTransaction.isEmpty()){
                        system.debug('Process transfer Policy Transaction size ' + needTransferPolicyTransaction.size());
                        for(Policy_Transaction__c pt : needTransferPolicyTransaction){
                            system.debug('Processing transfer Policy Transaction ' + pt.id);
                            pt.Account__c = oldNewAccountIdMap.get(pt.Account__r.id);
                        }
                        update needTransferPolicyTransaction;
                        //Database.SaveResult[] needTransferPolicyTransactionSr = Database.update(needTransferPolicyTransaction,false);
                        //system.debug('needTransferPolicyTransactionSr >>>> ' + needTransferPolicyTransactionSr);
                    }
                    
                    //Update Related Field in New_Policy__c
                    List<New_Policy__c> needTransferPolicy = [Select id,Account__c, Account__r.id from New_Policy__c where Account__r.id in :oldNewAccountIdMap.keySet()];
                    if(!needTransferPolicy.isEmpty()){
                        system.debug('Process transfer New_Policy__c size ' + needTransferPolicy.size());
                        for(New_Policy__c policy : needTransferPolicy){
                            system.debug('Processing transfer New_Policy__c ' + policy.id);
                            policy.Account__c = oldNewAccountIdMap.get(policy.Account__r.id);
                        }
                        update needTransferPolicy;
                        //Database.SaveResult[] needTransferPolicySr = Database.update(needTransferPolicy,false);
                        //system.debug('needTransferPolicySr >>>> ' + needTransferPolicySr);
                    }
                    
                    //Query "Customer" recordtype Id
                    List<RecordType> customerRt = [Select id,name from RecordType where developerName = 'Customer' and isActive = true and SObjectType = 'Account' ];
                    
                    //Update new Customer recordType from "TM_Customer" to "Customer" 
                    //Delete old Customer's account which account recordType is "TM_Customer"
                    List<Account> newCustomerList = [Select id,recordTypeId,recordType.developerName from Account where id in :tmCustomerMap.keySet()];
                    List<Id> deleteCustomerList = new List<Id>();
                    List<Id> changeRecordTypeCustomer = new List<Id>();
                    
                    system.debug('Handling change RecordType/Delete duplicate account');
                    
                    for(Account acct : newCustomerList){
                        if(duplicateAccIdList.contains(String.valueOf(acct.Id))){
                            system.debug('Account ID : ' + acct.Id + ' is duplicated account');
                            deleteCustomerList.add(acct.id);
                        }else{
                            system.debug('Account ID : ' + acct.Id + ' is new account');
                            changeRecordTypeCustomer.add(acct.id);
                        }
                    }
                    
                    if(!deleteCustomerList.isEmpty()){
                        List<Account> deleteAccount = [Select id from Account where id in :deleteCustomerList];
                        delete deleteAccount;
                        CignaUtil.createCheckingLog('TMSubmitPolicyToIpasBatchable finish()', '', '',String.valueOf(deleteCustomerList)+' is deleted' , '');
                    }
                    if(!changeRecordTypeCustomer.isEmpty()){
                        List<Account> changeAccount = [Select id from Account where id in :changeRecordTypeCustomer];
                        for(Account acc : changeAccount){
                            acc.recordTypeId = customerRt[0].Id;
                        }
                        update changeAccount;
                    }
                }                       
            }
            
            //TM Work From Home_20200828
            BankAccountHelper helper = new BankAccountHelper();
            helper.maskBankAccountbyOpportunity(opportunityList);
        }catch(Exception e){
            system.debug('[TMSubmitPolicyToIpasBatchable] finish Exception during combine account ' + e.getMessage());
        }
    }
    
    private Map<String,String> covertMasterListtoMapwithSort(List<HttpCalloutVO.MasterList> masterLists){
        Map<String,String> masterMaps = new Map<String,String>();
        masterLists.sort();
        for(HttpCalloutVO.MasterList masterList: masterLists){
            /* add by Jack on 2021-12-20 for project: IA AML nationality mandatory */
            // masterMaps.put(masterList.name.toUpperCase(), masterList.code);
            masterMaps.put(masterList.name, masterList.code);
        }
        return masterMaps;
    }
    
    /*
    * For some rider plan level is not = basic plan level, need to get the actual plan level and pass to IT
    */
    private String getRiderRateScale(List<String> riderCodeList, String riderCode, String planQuoteRateScale, String basicPlanLevel){
        String actualRateScale = basicPlanLevel;
        if(!riderCodeList.isEmpty()){
            for(String r : riderCodeList){
                if(r.contains(riderCode)){
                    actualRateScale = r.substringBefore(':');
                    break;
                }
            }
        }
        if(String.isNotBlank(planQuoteRateScale)){
            actualRateScale = planQuoteRateScale;
        }
        return actualRateScale;
    }
    
    //Add by Owen, 2024.1.12 add for elite360 for DETG child rate scale plus 1.
    private String resetRateScaleForDETG(String riderCode, String discount1, String discount2, String planQuoteRateScale, Person_Insured__c pi, New_Policy__c np, String originalRateScale){
        if(String.IsNotBlank(riderCode)){
            if(String.IsNotBlank(planQuoteRateScale) && (riderCode.equalsIgnoreCase('DETG')||riderCode.equalsIgnoreCase('DETG2'))){
                Integer newRateScale = Integer.valueOf(planQuoteRateScale);
                system.debug('pi= '+ pi);
                system.debug('discount1= '+discount1);
                system.debug('discount2= '+discount2);
                if(String.isNotBlank(discount1)||String.isNotBlank(discount2)){
                    // Rancho_VMIS Discount Fix_20240812 - add new child discount
                    if((riderCode.equalsIgnoreCase('DETG')||riderCode.equalsIgnoreCase('DETG2'))&&(
                        (discountCodeDecripMap.get('CHILD DISCOUNT*')==np.Discount_Code_1_to_IPAS__c)||(discountCodeDecripMap.get('CHILD DISCOUNT*')==np.Discount_Code_2_to_IPAS__c)||
                        (discountCodeDecripMap.get('CHILD DISCOUNT (GROUP)')==np.Discount_Code_1_to_IPAS__c)||(discountCodeDecripMap.get('CHILD DISCOUNT (GROUP)')==np.Discount_Code_2_to_IPAS__c)
                    )){
                        if(newRateScale==1||newRateScale==4||newRateScale==7){
                            system.debug('[TMSubmitPolicyToIpasBatchable] resetRateScaleForDETG');
                            newRateScale += 1;
                        }
                    }
                }
                return String.valueOf(newRateScale);
            }
            return originalRateScale;
        }
        return originalRateScale;
    }

    public void storeTheErrorInfo(String npIds,String piList, String npList,String submittedPolicies,String failedPolicies, String submitWorkRequestPolicies){
        try{
            Checking_Log__c tmp = new Checking_Log__c();
            String userInfoString = UserInfo.getUserId()+' '+UserInfo.getUserName();
            tmp.Function_Name__c = 'SubmitWorkRequest';
            tmp.UserInfo_String__c = userInfoString;
            tmp.ErrorMessage__c = npIds;
            tmp.Attachment_List_String__c = submittedPolicies;
            tmp.WS_Log_Attachment_Map_String__c =npList;
            tmp.TmpString3__c = piList;
            tmp.TmpString2__c = submitWorkRequestPolicies;
            tmp.TmpString1__c = failedPolicies;
            insert tmp;
        }catch(Exception e){

        }
    }

    /**Rancho_SPS728_20210521 for submit policy manually
    *@param     List<String> ptIdList: policy transaction list
    **/
    public void manualSubmitPolicy(List<String> ptIdList){
        Set<String> ptIds = new Set<String>();
        List<String> policyNoList = new List<String>();
        List<String> uwAppealList = new List<String>();
        List<String> policyFieldNames = new List<String>();
        List<String> uwAppealListAccept = new List<String>();
        List<String> policyNoListAccept = new List<String>();
        List<String> remarks2cignaunderwriterList = new List<String>();
        List<String> remarks2cignaunderwriterListAccept = new List<String>();
        List<Boolean> sideOrderIndList = new List<Boolean>();
        List<Boolean> sideOrderIndListAccept = new List<Boolean>();
        List<Boolean> postDeduplicationIndList = new List<Boolean>();
        List<Boolean> postDeduplicationIndLisAcceptt = new List<Boolean>();
        List<Attachment> attList = new List<Attachment>();
        List<Attachment> attListAccept = new List<Attachment>();
        Map<Id, New_Policy__c> npMap = new Map<Id, New_Policy__c>();
        Schema.DescribeSObjectResult policyDSR = New_Policy__c.sObjectType.getDescribe();

        for(String apiName : policyDSR.fields.getMap().keySet()){
            policyFieldNames.add(apiName);
        }

        String policySoql = 'select ' + String.join(policyFieldNames, ',') + ', '
            + ' (SELECT Id,Premium__c,Plan_Level__c,Product_Code__c,Is_Rider__c,Is_Mandatory_Rider__c,Rate_Scale__c FROM Plan_Quote__r), Product__r.Is_Life__c, '
            + ' (SELECT Id, Name, Beneficiary_Type__c, First_Name__c, Gender__c, Last_Name__c, Percent__c, Policy__c, Person_Insured__c, Person_ID__c, Relationship__c FROM Beneficiary__r), '
            + ' (SELECT Id, Name, UW_EXCL_1__c, UW_EXCL_2__c, UW_EXCL_3__c, UW_EXCL_4__c, UW_EXCL_5__c, UW_EXCL_6__c, UW_EXCL_7__c, UW_EXCL_9__c, UW_EXCL_10__c, Is_Basic_Plan__c, '
            + ' Loading__c, UW_EXCL_8__c, UW_Remark_1__c, UW_Remark_2__c, UW_Remark_4__c, UW_Remark_3__c, UW_Remark_5__c, '
            + ' UW_Remark_6__c, UW_Remark_7__c, UW_Remark_8__c, UW_Remark_9__c, UW_Remark_10__c, Case_Id__c, risk_type__c, product_code__c, Product_UW_Result__c FROM UW_Result__r )'
            + ' from New_Policy__c '
            + ' where Policy_Transaction__c in :ptIdList ';

        List<New_Policy__c> npList = Database.query(policySoql);
        System.debug('npList: '+npList);
        for(New_Policy__c np : npList){
            if(np.Policy_Status__c=='Pending Payment'&&(np.Product_Code__c=='VSTDG'||np.Product_Code__c=='VSMMG'||np.Product_Code__c=='VSUPG')){
                /*
                if(np.UW_Date__c.daysBetween(dateToday)>30){
                Id npId = np.Id;
                npIds.add(npId);
                npMap.put(npId, np);
            }
            */
            }else{
                Id npId = np.Id;
                npMap.put(npId, np);
            }
        }

        for(New_Policy__c newp : npList){
            String uwexcl = '';
            Decimal loadInt = 0;
            if(newp.UW_Result__r != null && newp.UW_Result__r.size() > 0){
                uwexcl = newp.UW_Result__r[0].UW_EXCL_1__c;
                loadInt = newp.UW_Result__r[0].Loading__c;
            }
            System.debug('uwexcl: '+uwexcl+'loadInt: '+loadInt);
            Attachment att = getAutoUWApplicationPDF(newp.Policy_No__c);
            Boolean sideOrderInd = newp.is_Side_Order__c != null ? newp.is_Side_Order__c : false;
            Boolean postDeduplicationInd = (String.isNotBlank(newp.UW_Requirement__c) && newp.UW_Requirement__c.equalsIgnoreCase('GA')) ? true : false;
            String remarks2cignaunderwriter = newp.Remarks_to_Cigna_Underwriter_2__c;
            String appealRemark = newp.Appeal_For_UW_Result__c;

            // update policy UW_Overrall_Result__c to referred before submit 
            List<New_Policy__c> needUpdateList = new List<New_Policy__c>();
            for(New_Policy__c np : npList){
                if(np.UW_Overrall_Result__c != 'Referred'){
                    np.UW_Overrall_Result__c = 'Referred';
                    needUpdateList.add(np);
                }
            }
            System.debug('needUpdateList: '+needUpdateList);
            if(needUpdateList.size()>0){update needUpdateList;}
            
            if(newp.UW_Overrall_Result__c == 'Referred'){
                policyNoList.add(newp.Policy_No__c);
                attList.add(att);
                sideOrderIndList.add(sideOrderInd);
                postDeduplicationIndList.add(postDeduplicationInd);
                remarks2cignaunderwriterList.add(null==remarks2cignaunderwriter?'':remarks2cignaunderwriter);
                uwAppealList.add(null==appealRemark?'':appealRemark);
            }else if(newp.UW_Overrall_Result__c == 'Accepted'&&(loadInt>0||String.isNotBlank(uwexcl))){
                policyNoListAccept.add(newp.Policy_No__c);
                attListAccept.add(att);
                sideOrderIndListAccept.add(sideOrderInd);
                postDeduplicationIndLisAcceptt.add(postDeduplicationInd);
                remarks2cignaunderwriterListAccept.add(null==remarks2cignaunderwriter?'':remarks2cignaunderwriter);
                uwAppealListAccept.add(null==appealRemark?'':appealRemark);
            }
        }
        System.debug('policyNoList: '+policyNoList);
        if(!policyNoList.isEmpty() && !Test.isRunningTest()){
            String jobId = System.enqueueJob(new TMSubmitWorkRequestQueue(policyNoList, postDeduplicationIndList, sideOrderIndList, attList, remarks2cignaunderwriterList,uwAppealList));
            // update policy transaction status to submitted once submit
            List<Policy_Transaction__c> ptList = [SELECT Id, Status__c FROM Policy_Transaction__c WHERE Id IN :ptIdList];
            System.debug('ptList: '+ptList);
            for(Policy_Transaction__c pt : ptList){
                pt.Status__c = 'Submitted';
            }
            update ptList;
        }
    }
}