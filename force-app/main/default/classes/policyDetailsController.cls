/********************************************************************************
Apex Class Name - Policy Details
Version - 1.0
Created Date - Nov 01,2016
@description Controlloer for Policy details page

Modification Log:
--------------------------------------------------------------------------------

*Version    Developer             Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       Nicole          2016/02/11              Get policy detail information
                                                    by web service.
* 1.1		Alif, LPS		2025/10/01				HKITSFDC - 412
********************************************************************************/
public with sharing class policyDetailsController{
    public String PLAN_NAME_PREFIX{get{return 'Plan:';}set;}
    public String FAKE_PLAN_NAME{get{return 'FAKE';}set;}
    public Boolean showTooManyRecordError{get;set;}
    //Policy Information Tab
    public HttpCalloutVO.Policy policy{get;set;}
    public List<HttpCalloutVO.Person> insuredList{get;set;}
    public Map<String,List<HttpCalloutVO.Person>> insuredMap{get;set;}
    public String insuredPage{get;set;}
    public List<HttpCalloutVO.Person> beneficiaryList{get;set;}
    public HttpCalloutVO.Person holder{get;set;}
    public List<HttpCalloutVO.PolicyDocType> policyDocList{get;set;}
    public HttpCalloutVO.PolicyDoc policyDoc{get;set;}
    public String TargetFileName{get;set;}
    public String FileName{get;set;}
    //JOBR24-KIRK-20220119-Separate inpatient visit counts into another tab
    public String clinicOrInpatient{get;set;}
    
    //Coverage Information Tab
    public List<HttpCalloutVO.PolicyPersonCoverage> policyCoverageList{get;set;}
    public Map<Integer,List<HttpCalloutVO.PolicyPersonCoverage>> coverageMap{get;set;}
    public Integer coveragePage{get;set;}
    public Integer coverageTotalPage{get;set;}
    public Boolean coveragehasPrev{get;set;}
    public Boolean coveragehasNext{get;set;}

    //Payment Information Tab
    public HttpCalloutVO.PolicyPayment payment{get;set;}
    public List<HttpCalloutVO.PolicyBilling> paymentTransactionList{get;set;}
    public Map<Integer,List<HttpCalloutVO.PolicyBilling>> paymentTranMap{get;set;}
    public Integer paymentTranPage{get;set;}
    public Integer paymentTranTotalPage{get;set;}
    public Boolean paymenthasPrev{get;set;}
    public Boolean paymenthasNext{get;set;}
    //BEGIN HKITSFDC-148
    public Date pyBillingDateFrom {get;set;}
    public Date pyBillingDateTo {get;set;}
    public String pyBillingErrMsg {get;set;}
    public Integer pyCurrentPage {get;set;}
    public Integer pyTotalRecords {get;set;}
    public Integer pySelectedPageNum {get;set;}
    public List<HttpCalloutVO.PolicyBilling> pyFilteredList{get;set;}
    public Date fromDateMin { get; set; }
    public Date fromDateMax { get; set; }
    public Date toDateMin { get; set; }
    public Date toDateMax { get; set; }
    //END HKITSFDC-148
    
    //Policy Change Tab
    public List<HttpCalloutVO.WorkStatus> policyChangeList{get;set;}
    public List<HttpCalloutVO.WorkStatus> allPolicyChangeList{get;set;}
    public String selectedpolicyChangeStatus{get;set;}
    public Map<Integer,List<HttpCalloutVO.WorkStatus>> policyChangeMap{get;set;}
    public Integer policyChangePage{get;set;}
    public Integer policyChangeTotalPage{get;set;}
    public Boolean policyChangehasPrev{get;set;}
    public Boolean policyChangehasNext{get;set;}

    //Claim HIstory Tab
    public List<HttpCalloutVO.Claim> claimList{get;set;}
    public List<HttpCalloutVO.Claim> allClaimList{get;set;}
    public String selectedClaimStatus{get;set;}
    public Map<Integer,List<HttpCalloutVO.Claim>> claimMap{get;set;}
    public Integer claimPage{get;set;}
    public Integer claimTotalPage{get;set;}
    public Integer claimStartIndex{get;set;}
    public Integer totalClaimRecords{get;set;}
    public Boolean claimhasPrev{get;set;}
    public Boolean claimhasNext{get;set;}
    private String currentGroupSearchValue;
    private String currentGroupClaimSearchCriteria;

    //Premium Settlement Tab
    public List<HttpCalloutVO.PolicyBilling> premiumSettlementList{get;set;}
    public List<HttpCalloutVO.PolicyBilling> allPremiumSettlementList{get;set;}
    public String selectedPremiumBranch{get;set;}
    public Map<Integer,List<HttpCalloutVO.PolicyBilling>> settlementMap{get;set;}
    public Integer settlementPage{get;set;}
    public Integer settlementTotalPage{get;set;}
    public Boolean settlementhasPrev{get;set;}
    public Boolean settlementhasNext{get;set;}

    //Member List Tab
    public List<HttpCalloutVO.Person> memberList{get;set;}
    public List<HttpCalloutVO.Person> allMemberList{get;set;}
    public String selectedMemberBranch{get;set;}
    public Map<Integer,List<HttpCalloutVO.Person>> memberMap{get;set;}
    public Integer memberPage{get;set;}
    public Integer memberTotalPage{get;set;}
    public Boolean memberhasPrev{get;set;}
    public Boolean memberhasNext{get;set;}
    public String memberSearchCriteria{get;set;}
    public String memberSearchInputText{get;set;}

    //Remaining Clinic Visits
    public List<HttpCalloutVO.BenefitDetailItem> benefitList{get;set;}
    public HttpCalloutVO.CombinedBenefit clinicVisitSummary{get;set;}
    public Map<Integer,List<HttpCalloutVO.BenefitDetailItem>> benefitMap{get;set;}
    public Integer benefitPage{get;set;}
    public Integer benefitTotalPage{get;set;}
    public Boolean benefithasPrev{get;set;}
    public Boolean benefithasNext{get;set;}

    //Add by Manuel that customized union struct with two classes (start)
    public List<HttpCalloutVO.UnionStructBenefitCombined> usBenefitCombinedList{get;set;}
    public Map<Integer,List<HttpCalloutVO.UnionStructBenefitCombined>> usBenefitCombinedMap{get;set;}
    public Integer usBenefitCombinedPage{get;set;}
    public Integer usBenefitCombinedTotalPage{get;set;}
    public Boolean usBenefitCombinedhasPrev{get;set;}
    public Boolean usBenefitCombinedhasNext{get;set;}
    //Add by Manuel that customized union struct with two classes (stop)

    //Added by Nicole start for getClinicVisits WS sturcture update,combined benefit aligned to normal benefit.
    public List<HttpCalloutVO.BenefitCategory> benefitCategoryList{get;set;}
    public Map<Integer,List<HttpCalloutVO.BenefitCategory>> cBenefitMap{get;set;}
    private Integer totalClinicCount{get;set;}
    public String categoryCode_Basic{get{Return 'Basic Benefit';}set;}
    public String categoryCode_TopUp{get{Return 'Top Up Benefit';}set;}
    //Added by Nicole end

    //fund transaction
    public List<HttpCalloutVO.PolicyFundHist> fundTransaction{get;set;}
    public Map<Integer,List<HttpCalloutVO.PolicyFundHist>> fundTransactionMap{get;set;}
    public Integer fundTransactionPage{get;set;}
    public Integer fundTransactionTotalPage{get;set;}
    public Boolean fundTransactionhasPrev{get;set;}
    public Boolean fundTransactionhasNext{get;set;}
    public Boolean hideChart{get;set;}

    //page turning
    private static final Integer PAGE_SIZE=20;
    private static final Integer BILL_PAGE_SIZE=12; //HKITSFDC-148

    //Constant variable for unlimited clinic visit count by Caden
    private static final String unlimitedVisCount='999999';
    private static final String unlimitedVisCountDesc='Unlimited';
    public String policyNumber{get;set;}
    public String policyType{get;set;}
    public boolean isGroup{get;set;}
    public boolean isILAS{get;set;}
    public boolean isGSUser{get;set;}
    public PolicyCalloutHelper helper{get;set;}
    private Map<String,Map<String,Boolean>> fields2;
    private List<SelectOption> policyChangeStatusList;
    private List<SelectOption> claimStatusList;
    private List<SelectOption> branchList;
    public String dataType{get;set;}
    public String selectedCategory{get;set;}
    public List<SelectOption> categoryList{get;set;}

    //Fund Portfolio
    public List<String> ChartLabel{get;set;}
    public List<String> ChartData{get;set;}
    public HttpCalloutVO.PolicyFund fundSummary{get;set;}
    public List<HttpCalloutVO.PolicyAvailFund> basicFundDetails{get;set;}
    public List<HttpCalloutVO.PolicyAvailFund> singleFundDetails{get;set;}
    public List<HttpCalloutVO.PolicyAvailFund> regularFundDetails{get;set;}

    //Benefit Schedule
    public List<HttpCalloutVO.PolicyPersonCoverage> benefitScheduleList{get;set;}
    public HttpCalloutVO.PolicyPersonCoverage benefitScheduleInfo{get;set;}

    //insurance certificate PDF
    public String PDFAttachmentId{get;set;}
    public String PDFDescription{get;set;}
    public Boolean displayPDF{get;set;}
    public Boolean displayInCert{get;set;}
    public Boolean isNew{get;set;}
    public Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> planMap{get;set;}
    public Map<String,Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>> GSPlanMap{get;set;}
    public String sectionType_Basic{get{ Return 'Basic';}set;}
    public String sectionType_ASO{get{ Return 'ASO';}set;}
    public String sectionType_TopUp{get{ Return 'Top-up';}set;}
    public String targetPlanName{get;set;}
    public String targetCertNo{get;set;}
    public Boolean initPlan{get;set;}
    public List<HttpCalloutVO.Person> userPlanList{get;set;}
    public Map<String, String> planNoMap{get;set;}    // Added by Linus JR1904

    //Group
    public Map<String,HttpCalloutVO.Person> groupMemberMap{get;set;}
    /* Added by IBM(Roy) due to PEI-156/PORTABLE R2 --START */
    public Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> effStsMap{get;set;}
    public List<HttpCalloutVO.Person> effStatusPList{get;set;}
    /* Added by IBM(Roy) due to PEI-156/PORTABLE R2 --END */
    public HttpCalloutVO.Person groupMemberDetail{get;set;}
    public HttpCalloutVO.Policy groupPolicyDetail{get;set;}

    //Group Claim
    public String groupClaimSearchCriteria{get;set;}
    public String groupClaimInputText{get;set;}
    public boolean isBrokerUser{get;set;}
    public boolean isCustomerUser{get;set;}
    public boolean showPreApprovalButton{get;set;}
    public User currentUser=[select id,Name,ProfileId,UserRoleId,UserName,User_Type__c,LanguageLocaleKey,AccountId,Account.ssn__c from User where id=:Userinfo.getUserId()];
    public List<FundContribution> fundContList{get;set;}
    public boolean showAFCcolumns{get;set;}
    public boolean showDeductible{get;set;}
    public List<SelectOption> premiumbranchList{get;set;}
    public Set<String> hidePolicyDocType=new Set<String>{'249','2147483647'};
    public Boolean showSumInsured{get;set;}{showSumInsured=true;}
    public Boolean showFaceAmt{get;set;}{showFaceAmt=false;} // HKITSFDC - 412
    public Boolean showApplyForGOPBtn{get;set;}{showApplyForGOPBtn=false;}

    //Added by Nicole to get translation by Custom Metadata Types
    public Map<String,Map<String,String>> transField{get;set;}
    
    // START HKITSFDC-416
    public Boolean showCoverageFields {get;set;}{showCoverageFields=false;}
    public Boolean showCoverageStatus {get;set;}{showCoverageStatus=false;}
    // END HKITSFDC-416

    //Nicole_20200107_Policy Detail Security Access
    public Boolean validateKey{get;set;}
    public String SHA256Key{get;set;}
    public String paraSHA256Key{get;set;}
    public Boolean showDDABtn{
        get{
            String currentUserSSN=currentUser.account.ssn__c;
            if(currentUserSSN!=null){
                MemberManagementHelper memberManagementHelper=new MemberManagementHelper();
                return memberManagementHelper.isUserCanSignDDA(currentUserSSN,policyNumber,curUserIsInactive);
            }else{
                return false;
            }
        }
        set;
    }

    public String DDAFormBtnVal{
        get{
            Map<String,Map<String,String>> transField=new Map<String,Map<String,String>>();
            for(Translate__mdt t:[select DeveloperName,zh_TW__c,en_US__c from Translate__mdt where Category__c like '%DDA%']){
                transField.put(t.DeveloperName,new Map<String,String>{'zh_TW'=>t.zh_TW__c,'en_US'=>t.en_US__c });
            }
            String signDDABtn=transField.containsKey('signDDABtn')?(transField.get('signDDABtn')).get(label.Header_Language_Code_Current):'';

            String editOrCancelDDABtn=transField.containsKey('editOrCancelDDABtn')?(transField.get('editOrCancelDDABtn')).get(label.Header_Language_Code_Current):'';

            String currentUserSSN=currentUser.account.ssn__c;
            if(currentUserSSN!=null){
                MemberManagementHelper memberManagementHelper=new MemberManagementHelper();
                if(memberManagementHelper.isUserRequiredSignDDA(currentUserSSN,policyNumber)){
                    return signDDABtn;
                }else{
                    return editOrCancelDDABtn;
                }
            }else{
                return editOrCancelDDABtn;
            }
        }
        set;
    }

    public Boolean curUserIsInactive{get;set;}{curUserIsInactive=false;}

    public void initCategoryList(){
        this.categoryList=new List<SelectOption>();
        this.categoryList.add(new SelectOption('#Information',Label.Pol_Policy_Information));
        this.categoryList.add(new SelectOption('#CoverageInformation',Label.Pol_Coverage_Information));
    }

    public void generateInsuranceCertificate(){
        //        system.debug('###downloadInsuranceCertificate###');
        try{
            PageReference Page=Page.InsuranceCertificatePDFVFP;
            Page.getParameters().put('policyNumber',policyNumber);
            Page.getParameters().put('certNumber',targetCertNo);

            File_Store__c fileStore=new File_Store__c();
            fileStore.OwnerId=UserInfo.getUserId();
            fileStore.Owner_id__c=UserInfo.getUserId();
            insert fileStore;

            Attachment att=new Attachment();
            att.Name=policyNumber +'_'+targetCertNo+'_Insurance_Certificate_PDF_'+Datetime.now().format('yyyy-MM-dd HH:mm')+'.pdf';
            att.Body=page.getContentAsPDF();
            //add content type to avoid judge content type is null validation
            att.contentType = 'application/pdf';
            att.ParentId=fileStore.Id;
            insert att;
            PDFAttachmentId=att.Id;
        }catch(Exception e){
            //            system.debug(e.getMessage());
        }
    }

    //Nicole_20190826_GS TopUp
    public String transKey{
        get{
            if(transKey ==null){
                transKey ='';
                for( String s:transField.keySet()){
                    transKey +='~'+s+'~';
                }
            }
            return transKey ;
        }set;
    }

    // Nicole_20200331_Tax Statement Issue
    public Map<String,String> certNoSSNMap{get;set;}
    public String ssnNum{get;set;}

    //JR1840 jack add
    public String encryptedSearchCriteria{get;private set;}
    public final String URLParamName{ get;private set;}{URLParamName='FLTR';}

    // Rancho_PI61_20220222
    public Boolean over90Days{get;set;}
    public static final String inforceStatusStr{get{return 'Inforce,生效';} set;}
    public static final String eligibleStatusStr{get{return 'Inforce,生效,Lapsed,已逾期';} set;}
    public Boolean displayOtherProductDoc{get;set;}{displayOtherProductDoc=false;}// Rancho_JOBR340_20231107
    //Rancho_JOBR324_20230905 - hide special rider
    public List<String> specialRiderList{get;set;}
    public String termDate{get;set;}// Rancho_JOBR376_20240612 - could not submit claim if policy expired more than 90 days
    //Rancho_HKITSFDC83_20240829 - not allow submit claim for pending policy
    public static List<Policy_Status_Mapping__c> polStatusList = Policy_Status_Mapping__c.getAll().values();
    //junda add 20201202
    /*public Set<String> planCodeList{
        get{
            planCodeList=new Set<String>();
            List<Plan_Code_Claim_Type__c> pcctList=[select id,Plan_code__c,HG__c from Plan_Code_Claim_Type__c where HG__c=true];
            for(Plan_Code_Claim_Type__c pcct:pcctList){
                planCodeList.add(pcct.Plan_code__c);
            }
            return planCodeList;
        }
        set;
    }*/

    public Set<String> statusCodeList{
        get{
            statusCodeList=new Set<String>();
            List<Policy_Status_Mapping__c> psmList=[select id,PolicyCode__c,PolicyStatus__c from Policy_Status_Mapping__c where PolicyStatus__c ='Lapsed'];
            for(Policy_Status_Mapping__c psm:psmList){
                statusCodeList.add(psm.PolicyCode__c);
            }
            return statusCodeList;
        }
        set;
    }
    public String productCode{
        get{
            string proCode=Portal_Settings__c.getInstance().HG_Product_Code__c;
            return proCode;
        }
        set;
    }
    //junda add end

    public Set<Id> altruistAdminSet {get;set;}//HKITSFDC-148

    public policyDetailsController(){
        //initCategoryList();
        isBrokerUser=CignaUtil.isBrokerPortal();
        isCustomerUser=CignaUtil.isCustomerPortal();
        helper=new PolicyCalloutHelper();
        showPreApprovalButton=false;
        showDeductible=false;
        policyDocList=new List<HttpCalloutVO.PolicyDocType>();
        //BEGIN HKITSFDC-148
        pyFilteredList = new List<HttpCalloutVO.PolicyBilling>(); 
        pyTotalRecords = 0;
        pyCurrentPage = 1;
        //END HKITSFDC-148
        /*efulfillment added start*/
        curCorDocList=new List<HttpCalloutVO.PolicyDocType>();
        corDocList=new List<HttpCalloutVO.PolicyDocType>();
        // claimDocList =new List<HttpCalloutVO.PolicyDocType>();
        yearList=new List<SelectOption>();

        // curDocList=new List<HttpCalloutVO.PolicyDocType>();
        documentList=new List<HttpCalloutVO.PolicyDocType>();
        docYearList=new List<SelectOption>();

        tempAttList=new List<String>();
        indDocAttIDList=new List<String>();
        indCorsAttIDList=new List<String>();
        grpDocAttIDList=new List<String>();
        // 20210105 - David - CR-55 Performance Tuning
        certNoSSNMap=new Map<String,String>();
        // 20200706 - minghua - Cigna SME Package Plan - Vision Benefit
        grpPCDocAttIDList=new List<String>();
        grpPCorDocList=new List<HttpCalloutVO.PolicyDocType>();
        pCorDocList=new List<HttpCalloutVO.PolicyDocType>();
        grpYearList=new List<SelectOption>();
        pCorDocYearMap=new Map<String,List<HttpCalloutVO.PolicyDocType>>();
        specialRiderList=Custom_Value__c.getInstance('Hide Product Rider').Value__c?.split(';'); //Rancho_JOBR324_20230905 - hide special rider

        /*efulfillment added end*/
        Map<String,String> para=Apexpages.CurrentPage().getParameters();
        policyNumber=para.get('policyNumber');
        policyType=para.get('policyType');
        dataType=para.get('dataType');
        termDate=para.get('termDate');// Rancho_JOBR376_20240612

        //Nicole_20200107_Policy Detail Security Access
        KeyGenerationStrategy keyGenerationStrategy=new SHA256KeyGenerationStrategy();
        paraSHA256Key=para.get('SHA256Key');
        SHA256Key=keyGenerationStrategy.generate(policyNumber+policyType);
        validateKey=false;
        if(SHA256Key==paraSHA256Key){
            validateKey=true;
        }
        //        system.debug(' paraSHA256Key '+paraSHA256Key +' SHA256Key '+SHA256Key);
        //        system.debug(' policyNumber'+policyNumber+' policyType'+policyType+' validateKey'+validateKey);
        if(policyType==null||policyType==''){
            policyType='Group';
        }

        if(policyType=='Group'){
            isGroup=true;
        }else{
            isGroup=false;
        }

        if(policyType.equalsIgnoreCase('ILAS')){
            isILAS=true;
        }else{
            isILAS=false;
        }

        over90Days=false;// Rancho_PI61_20220222
        showAFCcolumns=false;
        paginationInit();

        targetPlanName=FAKE_PLAN_NAME;
        targetCertNo=FAKE_PLAN_NAME;
        initPlan=false;
        allMemberList=new List<HttpCalloutVO.Person>();

        // 20200610 - minghua - levyII
        transField=new Map<String,Map<String,String>>();
        for(Translate__mdt t:[select DeveloperName,zh_TW__c,en_US__c from Translate__mdt where Category__c='policyDetailsController' OR Category__c='LevyII']){
            transField.put(t.DeveloperName,new Map<String,String>{'zh_TW'=>t.zh_TW__c,'en_US'=>t.en_US__c });
        }

        //CR-55 enhancement performance: call only for GS member to get member status  2021-12-28 Zane
        isGSUser = false;
        MemberManagementHelper memberHelper=new MemberManagementHelper();
        isGSUser = memberHelper.isGSUser(currentUser.account.ssn__c,policyNumber);
        if(isGSUser){
            PersonCallOutHelper pHelper=new PersonCallOutHelper();
            List<HttpCalloutVO.Person> personList=pHelper.getPersonBasic(currentUser.account.ssn__c);
            if(personList.size()>0){
                if(personList[0].memberStatusDesc=='Inactive'){
                    curUserIsInactive=true;
                }
            }
        }
        //CR-55 end
        //JR1840 jack add
        String encryptedFilter=ApexPages.currentpage().getparameters().get(URLParamName);
        //        System.debug('encryptedFilter'+encryptedFilter);
        if(!String.isEmpty(encryptedFilter)){
            encryptedSearchCriteria=EncodingUtil.urlEncode(encryptedFilter,'UTF-8');
        }
        //JR1840 jack add

        // Rancho_JOBR376_20240612 - group policy term date limit
        if(String.isNotBlank(termDate)){
            Date termDateInDate = Date.valueOf(termDate);
            if(termDateInDate.addDays(90) <= Date.today()){
                over90Days = true;
            }
        }

        //BEGIN HKITSFDC-148 NOTE:TEMPORARY
        loadAltruistAdminProfileSet();
        //END HKITSFDC-148 NOTE:TEMPORARY

    }

    public void getPolicyInfomation(){
        if(policy==null&&validateKey){
            //            System.debug('getPolicyInfomation:'+policyNumber);
            PersonCalloutHelper pcHelper=new PersonCalloutHelper();
            if(policyNumber!=null&&policyNumber!=''){
                getPolicyBasic();
                System.debug('policy:'+policy);
                //Only for the paid to date field!!!!
                //List<HttpCalloutVO.PolicyPayment> paymentList=helper.getPolicyPaymentBasic(policyNumber);
                if(!isGroup){
                    //CR-55 enhancement performance: call only for individual policy  2021-12-28 Zane
                    getPolicyPaymentBasic();
                    //cr-55 end
                    getPolicyHolderBasic();
                    if(holder!=null&&String.isNotBlank(holder.ssnNumber)){
                        List<HttpCalloutVO.Person> p1=pcHelper.getPersonBasic(holder.ssnNumber);
                        if(p1!=null&&p1.size()>0){
                            holder.homePhoneNo=p1[0].homePhoneNo;
                            holder.businessPhoneNo=p1[0].businessPhoneNo;
                            // Bug fix of AH18955   Linus 2020-May-7
                            holder.mobilephoneNo=p1[0].mobilePhoneNo;
                            // END - Linus
                            if(String.isBlank(holder.emailAddress)){
                                holder.emailAddress=p1[0].emailAddress;
                            }
                        }
                        System.debug('person information:'+p1);
                    }
                    getPolicyInsuredBasicList();
                    if(isILAS){
                        // 20200306 - minghua - ILAS
                        if(holder!=null&&String.isNotBlank(holder.ssnNumber)){
                            system.debug('holder.ssnNumber'+holder.ssnNumber);
                            RPQFormController.RPQInfo rPQInfo=RPQFormController.getLatestStatusAndEffetiveDate(holder.ssnNumber);
                            if(rPQInfo!=null){
                                holder.rPQStatus=rPQInfo.status;
                                holder.rPQEffectiveDate=rPQInfo.effectiveDate;
                            }
                        }
                        //                        system.debug('policyDetailsController rPQStatus'+holder.rPQStatus+'holder.rPQEffectiveDate'+holder.rPQEffectiveDate);
                        getPolicyBeneficiaryBasicList();
                    }else{
                        if(policy!=null&&policy.isIPMIPolicy!=null&&policy.isIPMIPolicy){
                            showPreApprovalButton=true;
                        }
                    }
                    if(getFields2().get('Policy Doc').get('ILAS')||getFields2().get('Policy Doc').get('nonILAS')){
                        getPolicyDocTypeList();
                    }
                }
                // CR-IPMI
                if(IPMISettingUtil.isIPMIPolicy(policy)){
                    showSumInsured=false;
                    showApplyForGOPBtn=true;
                }
                if(IPMISettingUtil.isIPMITopUpPolicy(policy)||IPMISettingUtil.isGAOPPolicy(policy)||IPMISettingUtil.isLHBPolicy(policy)){
                    showSumInsured=IPMISettingUtil.isDisplaySumInsured(policy);
                    showApplyForGOPBtn=IPMISettingUtil.isEnableApplyForAOP(policy);
                }

                //Rancho_HKITSFDC83_20240829 - not allow submit claim for pending policy
                if(null != polStatusList){
                    for(Policy_Status_Mapping__c psm : polStatusList){
                        if(psm.PolicyCode__c == policy.policyStatusCode && psm.PolicyStatus__c.contains('Pending')){
                            over90Days = true;
                            showApplyForGOPBtn = false;
                        }
                    }
                }
            }
        }
        //efulfillment
        //InitEfulfillment();
    }
    
        // START HKITSFDC-412
    public void getFaceAmtShow() {
        if (policy == null && validateKey) {
            PersonCalloutHelper pcHelper = new PersonCalloutHelper();
            if (policyNumber != null && policyNumber != '') {
                getPolicyBasic();
                if (!isGroup) {
                    getPolicyPaymentBasic();
                    getPolicyHolderBasic();
                    if (holder != null && String.isNotBlank(holder.ssnNumber)) {
                        List<HttpCalloutVO.Person> p1 = pcHelper.getPersonBasic(holder.ssnNumber);
                        if (p1 != null && p1.size() > 0) {
                            holder.homePhoneNo = p1[0].homePhoneNo;
                            holder.businessPhoneNo = p1[0].businessPhoneNo;
                            holder.mobilephoneNo = p1[0].mobilePhoneNo;
                            if (String.isBlank(holder.emailAddress)) {
                                holder.emailAddress = p1[0].emailAddress;
                            }
                        }
                    }

                    GetPolicyPersonCoverageBasic();

                    if (showSumInsured) {
                        System.debug('showSumInsured is TRUE');
                    } else {
                        Map<String, Policy_Change_Hide_Setting__c> hideSettings = Policy_Change_Hide_Setting__c.getAll();

                        Boolean productFound = false;
                        for (Policy_Change_Hide_Setting__c setting : hideSettings.values()) {
                            if (setting.Product_Code__c == ProductCode) {
                                productFound = true;
                                break;
                            }
                        }

                        if (productFound) {
                            showFaceAmt = true;
                            System.debug('ProductCode found in custom setting; showFaceAmt set to TRUE');
                        } else {
                            System.debug('ProductCode not found in custom setting; showFaceAmt remains FALSE');
                        }
                    }
                }
            }
        }
    }
 
    private Boolean shouldShowCoverageFields(String productCode) {
        if (String.isBlank(productCode)) {
            return false;
        }
        List<App_ProductFunction_Setting__c> appProSettings = [SELECT ProductCode__c FROM App_ProductFunction_Setting__c WHERE Type__c = 'ShowCoverageCIFields'];
        for (App_ProductFunction_Setting__c s : appProSettings) {
            if (s.ProductCode__c == productCode) {
                return true;
            }
        }
        return false;
    }
    
    public void CoverageFieldSetting() {
        System.debug('CoverageFieldSetting is executing!');
        if (policy != null && String.isNotBlank(policy.productCode)) {
            showCoverageFields = shouldShowCoverageFields(policy.productCode);
            System.debug('showCoverageFields (from existing policy) = ' + showCoverageFields);
        } else {
            System.debug('Policy not yet loaded');
        }
    }
    // END HKITSFDC-412
    
    public void getPolicyBasic(){
        //        System.debug('getPolicyBasic===');
        if(policy==null){
            if(policyNumber!=null&&policyNumber!=''){
                policy=new HttpCalloutVO.Policy();
                policy=helper.getPolicyBasic(policyNumber);
                //junda add 20201202
                System.debug('productCode---'+productCode);
                System.debug('statusCodeList---'+statusCodeList);
                System.debug('p.planTypeCode111---'+policy.planTypeCode);
                System.debug('p.policyStatusCode111---'+policy.policyStatusCode);
                if(policy.productCode!=null&&policy.policyStatusCode!=null&&String.isNotBlank(productCode)&&!statusCodeList.isEmpty()){
                    if(productCode.contains(policy.productCode)&&statusCodeList.contains(policy.policyStatusCode)){
                        policy.isDisplayTooltip=true;
                    }
                }
                // Rancho_JOBR340_20231107 - detect inforce elite360 and current user is policy holder
                List<String> prodCodeList = Custom_Value__c.getInstance('Elite 360 Product Code').Value__c?.split(';');
                if(prodCodeList.contains(policy.productCode)&&policy.policyStatusCode=='1'&&currentUser.Account.SSN__c==policy.holder.ssnNumber){
                    displayOtherProductDoc = true;
                }
                //System.debug('policy---'+policy);
                //junda add end
                // Rancho_PI61_20220222
                if(!policyType.equalsIgnoreCase('Group')){
                    Integer inactiveDays = helper.getIndividualPolicyListBasicByCriteria(policyNumber,'','','','','')[0].inactiveDays;
                    System.debug('inactive days checking: '+inactiveDays);
                    if(null != inactiveDays && inactiveDays >= 90){
                        over90Days = true;
                    }
                }
                // Owen_JOBR_301 hide the make a claim button
                String userId = UserInfo.getUserId();
                List <User> uList = [select id, LanguageLocaleKey, username, ProfileId, Profile.Name, AccountId, Account.ssn__c,Company_Code__c from User where id=: userId ];
                if(CignaUtil.isBrokerPortal() && String.isNotBlank(uList[0].Company_Code__c)){
                    List<Company__c> tempList = [SELECT Id, Claims_Submit_Button_Disabled__c FROM Company__c WHERE Company_Code__c =: uList[0].Company_Code__c AND Claims_Submit_Button_Disabled__c != null];
                    if(null != tempList && !tempList.isEmpty()){
                        for(String profileString : tempList[0].Claims_Submit_Button_Disabled__c.split(',')){
                            if(profileString == uList[0].Profile.Name){
                                over90Days = true;
                            }
                        }   
                    }
                }
            }
        }
    }

    public void getGroupMemberBasic(){
        if(groupMemberMap==null){
            List<HttpCalloutVO.Person> personList=helper.getPolicyPersonListBasicByCriteria(policyNumber,'','','',currentUser.account.ssn__c);
            groupMemberMap=new Map<String,HttpCalloutVO.Person>();
            if(personList.size()>0){
                Integer childIndex=1;
                Integer spouseIndex=1;
                effStatusPList=new List<HttpCalloutVO.Person>();// Added by IBM(Roy) due to PEI-156/PORTABLE R2
                for(HttpCalloutVO.Person p:personList){
                    ////CR-55 David - performance Tuning
                    certNoSSNMap.put(p.certificateNo,p.ssnNumber);
                    if(p.insurableInterestReason.equalsIgnoreCase('EMPLOYEE')){
                        p.index=1;
                        groupMemberMap.put('EMPLOYEE',p);
                        groupMemberDetail=p;
                        effStatusPList.add(p);// Added by IBM(Roy) due to PEI-156/PORTABLE R2
                    }else if(p.insurableInterestReason.equalsIgnoreCase('SPOUSE')){
                        p.index=spouseIndex;
                        if(spouseIndex>1){
                            groupMemberMap.put('SPOUSE '+spouseIndex,p);
                        }else{
                            groupMemberMap.put('SPOUSE',p);
                        }
                        spouseIndex++;
                        effStatusPList.add(p);// Added by IBM(Roy) due to PEI-156/PORTABLE R2
                    }else if(p.insurableInterestReason.equalsIgnoreCase('CHILD')){
                        p.index=childIndex;
                        if(childIndex > 1){
                            groupMemberMap.put('CHILD '+childIndex,p);
                        }else{
                            groupMemberMap.put('CHILD',p);
                        }
                        childIndex++;
                        effStatusPList.add(p);// Added by IBM(Roy) due to PEI-156/PORTABLE R2
                    }
                }

                if(groupMemberDetail==null){
                    groupMemberDetail=personList[0];
                }
            }
            System.debug('groupMemberMap:'+groupMemberMap);
            /*
            for(HttpCalloutVO.Person p:p1){
              if(p.ssnNumber==currentUser.account.ssn__c&& String.isNotBlank(p.CertificateNo)){
                groupMemberDetail=p;
              }
            }
            */
        }
    }

    public void getPolicyHolderBasic(){
        if(holder==null){
            //            system.debug('getPolicyHolderBasic');
            holder=new HttpCalloutVO.Person();
            if(policyNumber!=null&&policyNumber!=''){
                List<HttpCalloutVO.Person> personList=new List<HttpCalloutVO.Person>();
                personList=helper.getPolicyHolderListBasic(policyNumber);
                if(!personList.isEmpty()&&personList.size()>0){
                    holder=personList.get(0);
                }
            }
            //            System.debug('getPolicyHolderBasic:'+holder);
        }
    }

    public void getPolicyInsuredBasicList(){
        if(insuredList==null){
            //            system.debug('getPolicyInsuredBasicList');
            insuredList=new List<HttpCalloutVO.Person>();
            if(policyNumber!=null&&policyNumber!=''){
                insuredList=helper.getPolicyInsuredListBasic(policyNumber,true);       // AH18767 - David
            }
            System.debug('getPolicyInsuredBasicList:'+insuredList);
        }
    }

    public void getPolicyBeneficiaryBasicList(){
        beneficiaryList=new List<HttpCalloutVO.Person>();
        //policy.policyNumber='STP0001606';
        if(policyNumber!=null&&policyNumber!=''){
            beneficiaryList=helper.getPolicyBeneficiaryListBasic(policyNumber);
        }
        System.debug('getPolicyBeneficiaryBasicList:'+beneficiaryList);
    }

    /*efulfillment enhanced start */
    public void getPolicyDocTypeList(){
        //System.debug('=========getPolicyDocTypeList============');
        //System.debug('Host:'+ApexPages.currentPage().getHeaders().get('Host'));
        if(policyNumber!=null&&policyNumber!=''){
            //Nicole_20200331_Tax Statement Issue
            getPolicySSNNum();
            //List<HttpCalloutVO.PolicyDocType> tempPolicyDocList=helper.getPolicyDocTypeList(policyNumber);
            List<HttpCalloutVO.PolicyDocType> tempPolicyDocList=helper.getPolicyDocTypeList(policyNumber,'',ssnNum);
            System.debug('tempPolicyDocList:'+tempPolicyDocList);
            for(HttpCalloutVO.PolicyDocType pd:tempPolicyDocList){
                policyDocList.add(pd);
            }
            //Rancho_PI64_20220411 - enhance the code
            // HKITSFDC-438_20260107 - attachment is created by WS, so comment the code block below
            // List<File_Store__c> fileList = new List<File_Store__c>();
            // List<Attachment> attList = new List<Attachment>();
            // for(HttpCalloutVO.PolicyDocType pd:tempPolicyDocList){
            //     //System.debug('code:'+pd.attachmentTypeCode);
            //     //if(!hidePolicyDocType.contains(pd.attachmentTypeCode)){       //Comment by Nicole for DPSP-905
            //     policyDocList.add(pd);
            //     //}
            //     File_Store__c fileStore=new File_Store__c();
            //     fileStore.OwnerId=UserInfo.getUserId();
            //     fileStore.Owner_id__c=UserInfo.getUserId();
            //     fileList.add(fileStore);
            // }
            // //insert file store
            // if(!Test.isRunningTest()){
            //     insert fileList;
            // }
            // //insert attachment
            // for(File_Store__c f : fileList){
            //     Attachment tatt = new Attachment();
            //     tatt.parentId=f.Id;
            //     tatt.contentType='application/pdf';
            //     tatt.name='tempDoc4Broker';
            //     tatt.body=Blob.valueOf('');
            //     attList.add(tatt);
            // }
            // if(!Test.isRunningTest()){
            //     insert attList;
            // }
            // for(Attachment a : attList){
            //     indDocAttIDList.add(a.Id);
            // }
        }
        InitDocYearMap();
        //System.debug('getPolicyDocTypeList:'+policyDocList);
    }
    /*efulfillment enhanced end */
    /*
   public PageReference getDoc(){
       policyDoc=new HttpCalloutVO.PolicyDoc();
       Blob theBlob;
       List<HttpCalloutVO.PolicyDoc> docList=new List<HttpCalloutVO.PolicyDoc>();
       if(policyNumber!=null&&policyNumber!=''){
          docList=helper.getPolicyDoc(policyNumber,TargetFileName);

          if(!docList.isEmpty()&&docList.size()>0){
             policyDoc=docList.get(0);
          }
       }
       system.debug('policyDoc.attachmentData64Binary'+policyDoc.attachmentData64Binary);
       theBlob=EncodingUtil.base64Decode(policyDoc.attachmentData64Binary);
       File_Store__c fileStore=new File_Store__c();
       fileStore.OwnerId=UserInfo.getUserId();
       fileStore.Owner_id__c=UserInfo.getUserId();
       Insert fileStore;

       Attachment tempAtt;
       tempAtt=new Attachment();
       tempAtt.parentId=fileStore.Id;
       tempAtt.contentType='application/pdf';
       tempAtt.name=TargetFileName;
       tempAtt.body=theBlob;
       Insert tempAtt;

       String downloadURL='/servlet/servlet.FileDownload?file='+tempAtt.Id+'&date='+system.Now().millisecondGmt();


       String mobileDownloadURL='/apex?downloadLink='+downloadURL;

       PageReference redirectPage=new PageReference(downloadURL);
       redirectPage.setRedirect(true);
       return redirectPage;
   }
   */
    //Member List
    public void getMemberList(){
        showTooManyRecordError=false;
        if(memberList==null&&validateKey){
            try{
                if(isGroup&&memberList==null){
                    if(String.isNotBlank(policyNumber)){
                        memberList=helper.getPolicyPersonListBasicByCriteria(policyNumber,'','','');
                        // 20210105 - David - CR-55 Performance Tuning
                        for(HttpCalloutVO.Person person:memberList){
                            certNoSSNMap.put(person.certificateNo,person.ssnNumber);
                        }
                        allMemberList=memberList;
                    }
                    memberPagingMethod();
                }
                //                System.debug('memberList:'+memberList);
            }catch(CignaWSResultTooLargeException e){
                showTooManyRecordError=true;
                //                System.debug('Too many record');
            }
        }
    }

    public void memberListSearch(){
        try{
            showTooManyRecordError=false;
            selectedMemberBranch='All';
            if(memberSearchCriteria=='Member Name'){
                memberList=helper.getPolicyPersonListBasicByCriteria(policyNumber,memberSearchInputText,'','');
                allMemberList=memberList;
            }else if(memberSearchCriteria=='Member Id'){
                memberList=helper.getPolicyPersonListBasicByCriteria(policyNumber,'',memberSearchInputText,'');
                allMemberList=memberList;
            }
            //            System.debug('memberList:'+memberList);
            memberPagingMethod();

        }catch(CignaWSResultTooLargeException e){
            //            System.debug('Too many records!');
            showTooManyRecordError=True;
        }
    }

    public void groupClaimSearch(){
        try{
            ClaimCalloutHelper cHelper=new ClaimCalloutHelper();
            currentGroupClaimSearchCriteria=groupClaimSearchCriteria;
            currentGroupSearchValue=groupClaimInputText;
            selectedClaimStatus='All';

            showTooManyRecordError=false;
            if(groupClaimSearchCriteria=='Member Name'){
                claimList=cHelper.GetClaimListBasicByCriteria('','All',policyNumber,'','','',groupClaimInputText,'',null,1,null);
            }else if(groupClaimSearchCriteria=='Member Id'){
                claimList=cHelper.GetClaimListBasicByCriteria('','All',policyNumber,'','','','','',groupClaimInputText,null,1,null);
            }

            totalClaimRecords=claimList.size()==0?1:claimList.size();
            handleClaimTypes(claimList);
            claimPagingMethod();
        }catch(CignaWSResultTooLargeException e){
            //            System.debug('Too many records!');
            showTooManyRecordError=True;
        }
    }

    public void getPolicyPersonCoverageBasic(){
        /*if(isGroup&&memberList==null){
           memberList =new List<HttpCalloutVO.PolicyPersonCoverage>();
           if(policyNumber!=null&&policyNumber!=''){
              memberList=helper.getPolicyPersonCoverageBasic(policyNumber,'');
              allMemberList=memberList;
              memberPagingMethod();
           }*/
        if(!isGroup&&policyCoverageList==null&&validateKey){
            getPolicyInsuredBasicList();

            //JR:COMBO-24,not diplay the specific product in coverage information list;2020-10-09
            Custom_Value__c exclFromCove=Custom_Value__c.getValues('Exclude_Code_from_Coverage');
            List<String> exclFrmCovrgList=new List<String>();
            if(exclFromCove!=NULL&&String.isNotBlank(exclFromCove.Value__c)){
                exclFrmCovrgList=exclFromCove.Value__c.split(';');
            }

            List<Plan_Code_Claim_Type__c> pccList=[Select Plan_code__c,Rate_Scale__c from Plan_Code_Claim_Type__c where TOPUP__C=TRUE];
            Map<String,Set<String>> planCodeMap=new Map<String,Set<String>>();

            for(Plan_Code_Claim_Type__c pcc:pccList){
                if(planCodeMap.containsKey(pcc.Plan_code__c)){
                    Set<String> rateScale=planCodeMap.get(pcc.Plan_code__c);
                    rateScale.add(pcc.Rate_Scale__c);
                }else{
                    Set<String> rateScale=new Set<String>();
                    rateScale.add(pcc.Rate_Scale__c);
                    planCodeMap.put(pcc.Plan_code__c,rateScale);
                }
            }

            policyCoverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
            if((policyNumber!=null&&policyNumber!='')&&(!insuredList.isEmpty()&&insuredList.size()>0)){
                for(HttpCalloutVO.Person insure:insuredList){
                    if(insure.ssnNumber!=null){
                        List<HttpCalloutVO.PolicyPersonCoverage> coverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
                        coverageList=helper.getPolicyPersonCoverageBasic(policyNumber,insure.ssnNumber);
                        //coverageList=helper.getPolicyPersonCoverageBasic('HMKHK0000229825','A932622');
                        //                        system.debug('coverageList:'+coverageList);
                        //BEGIN HKITSFDC-47 
                        if(!coverageList.isEmpty()&&coverageList.size()>0){
                            coverageList.sort();
                        }
                        //END HKITSFDC-47 
                        // Person Insured Name
                        if(!coverageList.isEmpty()&&coverageList.size()>0){
                            for(HttpCalloutVO.PolicyPersonCoverage c:coverageList){
                                c.insuredName=insure.fullName;
                                if(planCodeMap.containsKey(c.benefitCode)){
                                    Set<String> rateScale=planCodeMap.get(c.benefitCode);
                                    if(rateScale.contains(c.rateScale)){
                                        showDeductible=TRUE;
                                    }
                                }
                            }
                            policyCoverageList.addAll(coverageList);
                        }
                        System.debug('policyCoverageList:'+policyCoverageList);
                        // Maturity,Expiry Date
                        Set<String> benefitCodeSet=new Set<String>();

                        //JR:COMBO-24,not diplay the specific product in coverage information list;2020-10-09
                        for(Integer i=policyCoverageList.size() - 1;i >=0;i--){
                            HttpCalloutVO.PolicyPersonCoverage plcCovg=policyCoverageList.get(i);

                            if(String.isNotBlank(plcCovg.benefitCode)&&exclFrmCovrgList.contains(plcCovg.benefitCode)){
                                showSumInsured=false;
                                policyCoverageList.remove(i);
                                continue;
                            }
                            // Rancho_JOBR324_20230905 - hide special rider
                            if(String.isNotBlank(plcCovg.benefitCode)&&specialRiderList.contains(plcCovg.benefitCode)){
                                policyCoverageList.remove(i);
                                continue;
                            }
                            if(String.isBlank(plcCovg.maturityexpiryDate)){
                                plcCovg.maturityexpiryDate='N/A';
                            }
                            if(String.isNotBlank(plcCovg.benefitCode)){
                                benefitCodeSet.add(plcCovg.benefitCode);
                            }
                            if(plcCovg.benefitCode.startsWith('AFCR')||plcCovg.benefitCode.startsWith('AFCS')){
                                showAFCcolumns=true;
                            }
                        }

                        // Benefit Code
                        List<Plan_Code_Claim_Type__c> benefitList=[SELECT Plan_code__c,Plan_Title__c FROM Plan_Code_Claim_Type__c Where Plan_code__c in :benefitCodeSet];
                        Map<String,String> benefitMap=new Map<String,String>();
                        for(Plan_Code_Claim_Type__c c:benefitList){
                            benefitMap.put(c.Plan_code__c,c.Plan_Title__c);
                        }

                        for(HttpCalloutVO.PolicyPersonCoverage c:policyCoverageList){
                            if(String.isNotBlank(c.benefitCode)&&benefitMap.containsKey(c.benefitCode)){
                                c.benefitDesc=benefitMap.get(c.benefitCode);
                            }
                        }
                        coveragePagingMethod();
                    }
                }
            }

            /**
            getPolicyPaymentBasic();

            // Check whether to display pre-aprroval button
            for(HttpCalloutVO.PolicyPersonCoverage ppc:policyCoverageList){
               System.debug('ppc.benefitCode:'+ppc.benefitCode);
               System.debug('ppc.rateScale:'+ppc.rateScale);

               ppc.paymentMode=payment.paymentMode;
               ppc.paymentModeCode=payment.paymentModeCode;
               ppc.annualPremium=PolicyCalloutHelper.calculateAnnualModalPremium(ppc.modalPremium,ppc.paymentModeCode);
            }
            */
            // Zoe updated on 0614,PPCP-33
        }
        CoverageFieldSetting();//HKITSFDC-412 20251126 Added to reload showCovergae Fields
        
        
    }

    public PageReference searchMemberListbybranch(){
        memberList=new List<HttpCalloutVO.Person >();
        if(selectedMemberBranch=='All'){
            memberList=allMemberList ;
        }else{
            for( HttpCalloutVO.Person coverage:allMemberList){
                if(coverage.branchCode==selectedMemberBranch){
                    memberList.add(coverage);
                }
            }
        }
        memberPagingMethod();
        return null;
    }

    // For Benefit Schedule Tab
    public void getBenefitSchedule(){
        if(validateKey){
            /*
            if(benefitScheduleList==null){
              benefitScheduleInfo=new HttpCalloutVO.PolicyPersonCoverage();
              if(String.isNotBlank(policyNumber)){
                getPolicyBasic();
                benefitScheduleList=helper.getPolicyPersonCoverageBasic(policyNumber,currentUser.account.ssn__c);

                filterBenefitSchedule(benefitScheduleList);

                if(benefitScheduleList.size()>0){
                  benefitScheduleList.sort();
                  benefitScheduleInfo=benefitScheduleList[0];
                }
              }
            }
            */
            userPlanList=new List<HttpCalloutVO.Person>();
            if(planMap==null){
                if(String.isNotBlank(policyNumber)){
                    getPolicyBasic();
                }
                //                System.debug('here');
                planMap=new Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>();
                if(groupMemberMap==null){
                    getGroupMemberBasic();
                }
                /*
                benefitScheduleList=helper.getPolicyPersonCoverageBasic(policyNumber,'','',groupMemberDetail.certificateNo);
                filterBenefitSchedule(benefitScheduleList);

                if(benefitScheduleList.size()>0){
                  benefitScheduleInfo=benefitScheduleList[0];
                }

                for(String g:groupMemberMap.keyset()){
                  if(g.equalsIgnoreCase('EMPLOYEE')){
                    planMap.put(groupMemberMap.get(g).certificateNo,benefitScheduleList);
                  }else{
                    planMap.put(groupMemberMap.get(g).certificateNo,new List<HttpCalloutVO.PolicyPersonCoverage>());
                  }
                  userPlanList.add(groupMemberMap.get(g));
                }

                userPlanList.sort();

                //Order UserPlanList

                planMap.put(targetCertNo,new List<HttpCalloutVO.PolicyPersonCoverage>());
                */
                for(String g:groupMemberMap.keyset()){
                    planMap.put(groupMemberMap.get(g).certificateNo,new List<HttpCalloutVO.PolicyPersonCoverage>());
                    userPlanList.add(groupMemberMap.get(g));
                    /*efulfillment enhanced added start*/

                    if(targetCertNo!=''&& targetCertNo ==groupMemberMap.get(g).certificateNo){
                        addGroupDocMap(groupMemberMap.get(g).certificateNo);
                        curGroupDocList=groupDocMap.get(targetCertNo);
                    }
                    /*efulfillment enhanced added end*/
                }
                userPlanList.sort();
                planMap.put(targetCertNo,new List<HttpCalloutVO.PolicyPersonCoverage>());
            }
        }
    }

    private void filterBenefitSchedule(List<HttpCalloutVO.PolicyPersonCoverage>l){
        for(HttpCalloutVO.PolicyPersonCoverage b:l){
            if(b.benefitDetailItemDesc=='Reimbursement %'&&b.benefitItemDescDtl=='Combine no. of visits'){
                b.isDisplay=false;
            }else if(b.benefitDetailItemDesc=='Annual Premium'){
                b.isDisplay=false;
            }
        }
    }

    // For Payment Information Tab
    public void getPolicyPaymentInformation(){
        if(validateKey){
            getPolicyPaymentBasic();
            getPolicyBillingListBasic();
            initializeDateConstraints();	//HKITSFDC-148
        }
    }

    //Need policyCoverageList
    public void getPolicyPaymentBasic(){
        List<HttpCalloutVO.PolicyPayment> paymentList=new List<HttpCalloutVO.PolicyPayment>();
        if(payment==null){
            payment=new HttpCalloutVO.PolicyPayment();
            if(policyNumber!=null&&policyNumber!=''){
                paymentList=helper.getPolicyPaymentBasic(policyNumber);
                if(!paymentList.isEmpty()&&paymentList.size()>0){
                    payment=paymentList.get(0);
                    /*
                    getPolicyPersonCoverageBasic();

                    payment.modalPremium=0;

                    getPolicyInfomation();

                    if(String.isNotBlank(policy.policyStatusCode)&&policy.policyStatusCode =='1'){
                      for(HttpCalloutVO.PolicyPersonCoverage coverage:policyCoverageList){
                         if(coverage.modalPremium!=null&&!(coverage.benefitCode.startsWith('AFCR')||coverage.benefitCode.startsWith('AFCS'))){
                            if(coverage.maturityexpiryDateinDate==null||coverage.maturityexpiryDateinDate > Date.today()){
                              payment.modalPremium +=coverage.modalPremium;
                            }
                         }
                      }
                    }

                    payment.annualPremium=PolicyCalloutHelper.calculateAnnualModalPremium(payment.modalPremium,payment.paymentModeCode);
                    */
                }
            }
            System.debug('getPolicyPaymentBasic:'+payment);
        }
    }

    public void getPremiumSettlement(){
        if(premiumSettlementList==null&&validateKey){
            Set<String> tempMap=new Set<String>();
            premiumSettlementList=new List<HttpCalloutVO.PolicyBilling>();
            if(policyNumber!=null&&policyNumber!=''){
                premiumSettlementList=helper.getPolicyBillingListBasic(policyNumber);
                for(HttpCalloutVO.PolicyBilling pb:premiumSettlementList){
                    if(String.isNotBlank(pb.branchDesc)&&!tempMap.contains(pb.branchDesc)){
                        tempMap.add(pb.branchDesc);
                    }
                }

                allPremiumSettlementList=premiumSettlementList;
                settlementPagingMethod();
                System.debug('getPolicyBillingListBasic:'+premiumSettlementList);
            }
        }
    }

    public void getPolicyBillingListBasic(){
        if(paymentTransactionList==null){
            paymentTransactionList=new List<HttpCalloutVO.PolicyBilling>();
            if(policyNumber!=null&&policyNumber!=''){
                //BEGIN HKITSFDC-148
                // paymentTransactionList=helper.getPolicyBillingListBasic(policyNumber);
                refreshGetPolicyBillingListBasic();
                filterByAnnuallyOrMonthly();
                
                //paymentTranPagingMethod();
                //END HKITSFDC-148
                System.debug('getPolicyBillingListBasic:'+paymentTransactionList);
            }
        }

    }
    
     //BEGIN HKITSFDC-148
    public List<HttpCalloutVO.PolicyBilling> getPyCurrentPageRecords(){
        List<HttpCalloutVO.PolicyBilling> pgRec = new List<HttpCalloutVO.PolicyBilling>();
        Integer startIdx = (pyCurrentPage - 1) * BILL_PAGE_SIZE;
        pyTotalRecords = pyFilteredList.size();
        system.debug('20250503 : ' + pyTotalRecords );
        for(Integer i = startIdx; i < startIdx + BILL_PAGE_SIZE && i < pyTotalRecords; i++){
            pgRec.add(pyFilteredList[i]);
        }
        system.debug('20250503b : ' + pgRec.size());
        return pgRec;
    }
    
    public Integer getPyTotalPages(){
        return Math.ceil(pyTotalRecords * 1.0 / BILL_PAGE_SIZE).intValue();
    }
    
    public List<Integer> getPyPageNumbers(){
        List<Integer> pageNumbers = new List<Integer>();
        for(Integer i = 1; i <= getPyTotalPages(); i++){
            pageNumbers.add(i);
        }
        return pageNumbers;
    }
    
    public Boolean getPyHasNext(){
        return pyCurrentPage < getPyTotalPages();
    }
    
    public Boolean getPyHasPrevious(){
        return pyCurrentPage > 1;
    }
    
    public Integer getPyCurrentPageNumber(){
        return pyCurrentPage;
    }
    
    public void pyNext(){
        if(getPyHasNext()){
            pyCurrentPage++;
        }
    }
    
    public void pyPrevious(){
        if(getPyHasPrevious()){
            pyCurrentPage--;
        }
    }
    
    public void goToPage(){
        if(pySelectedPageNum >= 1 && pySelectedPageNum <= getPyTotalPages()){
            pyCurrentPage = pySelectedPageNum;
        }
    }
    
    public void refreshGetPolicyBillingListBasic(){
        paymentTransactionList=new List<HttpCalloutVO.PolicyBilling>();
        if(policyNumber!=null&&policyNumber!=''){
            paymentTransactionList=helper.getPolicyBillingListBasic(policyNumber,true);
        }
    }
    
    private Date getMaxDateFromPaymentTransactionList(){
        Date maxDate = Date.today();
        for(HttpCalloutVO.PolicyBilling pb : paymentTransactionList) {
            if(pb.payDate > maxDate) {
                maxDate = pb.payDate;
            }
        }
        return maxDate;
    }
    
    public void filterByAnnuallyOrMonthly(){
        system.debug('filterByAnnuallyOrMonthly Called');
        if(paymentTransactionList != null){
            system.debug('Before filterByAnnuallyOrMonthly paymentTransactionList: '+paymentTransactionList.size());
            Date maxDate = getMaxDateFromPaymentTransactionList();
            system.debug('filterByAnnuallyOrMonthly maxDate: '+maxDate);
            //Check the policy.PaymentMode
            Date startDate;
            if(null != policy.paymentMode && policy.paymentMode.equalsIgnoreCase('Annually')){
            	startDate = maxDate.addYears(-3);
            }else{
                startDate = maxDate.addMonths(-36);
            }
            system.debug('filterByAnnuallyOrMonthly startDate: '+startDate);
            
            // Filter the list
            List<HttpCalloutVO.PolicyBilling> filteredList = new List<HttpCalloutVO.PolicyBilling>();
            for(HttpCalloutVO.PolicyBilling pb : paymentTransactionList) {
                if(pb.payDate >= startDate && pb.payDate <= maxDate) {
                    filteredList.add(pb);
                }
            }
            
            //replace Current paymentTransactionList
            pyFilteredList = filteredList;
            system.debug('filterByAnnuallyOrMonthly pyFilteredList: '+pyFilteredList.size());
        }
    }
    
    public void filterBillingListBasicByDateRange(){
        system.debug('filterBillingListBasicByDateRange Called: DFrom: '+pyBillingDateFrom+' DTo: '+pyBillingDateTo);
        
        if(!isBillingDateRangeValid()){
            system.debug('isBillingDateRangeValid is False');
            return;
        }
        pyCurrentPage = 1;
        filterByAnnuallyOrMonthly();
        //filter records based on date range selected: update paymentTransactionList
        List<HttpCalloutVO.PolicyBilling> dateRangeList = new List<HttpCalloutVO.PolicyBilling>();
        for(HttpCalloutVO.PolicyBilling pb : pyFilteredList) {
        	if(pb.payDate >= pyBillingDateFrom && pb.payDate <= pyBillingDateTo) {
            	dateRangeList.add(pb);
            }
        }
        pyFilteredList = dateRangeList;
        system.debug('filterBillingListBasicByDateRange pyFilteredList: '+pyFilteredList.size());
    }
    //True if validation is alright, False otherwise
    public Boolean isBillingDateRangeValid(){
        pyBillingErrMsg = '';
        
            if(pyBillingDateFrom == null || pyBillingDateTo == null) {
                pyBillingErrMsg = 'Please select both dates';
                return false;
            }
            
            if(pyBillingDateFrom > pyBillingDateTo) {
                pyBillingErrMsg = 'Invalid date range: From Date must be before To Date';
                return false;
            }
            
            // Add more specific error messages for different validation failures
            if (pyBillingDateFrom < fromDateMin) {
                pyBillingErrMsg = 'From Date cannot be earlier than ' + fromDateMin.format();
                return false;
            }
            
            if (pyBillingDateFrom > fromDateMax) {
                pyBillingErrMsg = 'From Date cannot be later than ' + fromDateMax.format();
                return false;
            }
            
            if (pyBillingDateTo < toDateMin) {
                pyBillingErrMsg = 'To Date cannot be earlier than ' + toDateMin.format();
                return false;
            }
            
            if (pyBillingDateTo > toDateMax) {
                pyBillingErrMsg = 'To Date cannot be later than ' + toDateMax.format();
                return false;
            }
        
        return true;
    }
    //END HKITSFDC-148

    public void searchPremiumSettlementbybranch(){
        premiumSettlementList=new List<HttpCalloutVO.PolicyBilling>();
        if(selectedPremiumBranch=='All'){
            premiumSettlementList=allPremiumSettlementList ;
        }else{
            for( HttpCalloutVO.PolicyBilling billing:allPremiumSettlementList){
                if(billing.branchCode==selectedPremiumBranch){
                    premiumSettlementList.add(billing);
                }
            }
        }
        settlementPagingMethod();
        system.debug('premiumSettlementList '+premiumSettlementList);
        //return null;
    }

    public void getBenefitScheduleByPlanName(){
        System.debug('targetPlanName:'+targetPlanName);
        initPlan=true;
        if(targetPlanName!=FAKE_PLAN_NAME){
            List<HttpCalloutVO.PolicyPersonCoverage> temp=helper.getPolicyPersonCoverageBasic(policyNumber,'',targetPlanName);
            //filterBenefitSchedule(temp);
            planMap.put(targetPlanName,temp);
            /*efulfillment enhanced added start*/
            addGroupDocMap(targetPlanName);
            curGroupDocList=groupDocMap.get(targetPlanName);
            /*efulfillment enhanced added end*/
        }
    }

    public void getBenefitScheduleByCertNo(){
        initPlan=true;
        if(targetCertNo!=FAKE_PLAN_NAME){
            String tempSSN = certNoSSNMap.get(targetCertNo);
            List<HttpCalloutVO.PolicyPersonCoverage> temp = new List<HttpCalloutVO.PolicyPersonCoverage>();
            //20210105 - David - CR-55 Performance Tuning
            if(String.isNotBlank(tempSSN)){                
                temp=helper.getPolicyPersonCoverageBasic(policyNumber, tempSSN);
            }else{
                temp=helper.getPolicyPersonCoverageBasic(policyNumber,'','',targetCertNo);
            }            
            filterBenefitSchedule(temp);
            if(temp.size()>0&&groupMemberDetail.certificateNo.equalsIgnoreCase(targetCertNo)){
                benefitScheduleInfo=temp[0];
            }
            planMap.put(targetCertNo,temp);

            //Top Up Benefit Enhancement Start:Added by Nicole
            GSPlanMap=new Map<String,Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>>();
            Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> temPlanMap=new Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>();
            for(HttpCalloutVO.PolicyPersonCoverage benefit:temp){
                String sectionType='';
                if(benefit.sectionType.equals(sectionType_ASO)||benefit.sectionType.equals(sectionType_Basic)){
                    sectionType=sectionType_Basic;
                }else{
                    sectionType=benefit.sectionType;
                }

                if(temPlanMap.containsKey(sectionType)){
                    temPlanMap.get(sectionType).add(benefit);
                }else{
                    temPlanMap.put(sectionType,new List<HttpCalloutVO.PolicyPersonCoverage>{benefit});
                }
            }
            GSPlanMap.put(targetCertNo,temPlanMap);
            //Top Up Benefit Enhanced End:Added by Nicole

            /*efulfillment enhanced added start*/
            addGroupDocMap(targetCertNo);
            curGroupDocList=groupDocMap.get(targetCertNo);
            /*efulfillment enhanced added end*/
            // Added by IBM(Roy) due to PEI-156/PORTABLE R2 --START
            List<HttpCalloutVO.PolicyPersonCoverage> rtnList=new List<HttpCalloutVO.PolicyPersonCoverage>();
            if(effStatusPList!=null){
                for(HttpCalloutVO.Person p:effStatusPList){
                    if(p.certificateNo.equalsIgnoreCase(targetCertNo)){
                        effStsMap=new Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>();
                        HttpCalloutVO.PolicyPersonCoverage ppcEffeObj=new HttpCalloutVO.PolicyPersonCoverage();
                        ppcEffeObj.benefitItemDescDtl='Effective Date';
                        ppcEffeObj.benefitDetailItemDesc='Member Coverage Effective Date';
                        if(String.isNotBlank(p.effDate)){
                            ppcEffeObj.BenefitLevelDesc=p.effDate.substring(0,10);
                        }else{
                            ppcEffeObj.BenefitLevelDesc='N/A';//ppcEffeObj.BenefitLevelDesc='';//Add by Manuel to set the string as 'N/A' if no available date
                        }
                        rtnList.add(ppcEffeObj);

                        HttpCalloutVO.PolicyPersonCoverage ppcStatusObj=new HttpCalloutVO.PolicyPersonCoverage();
                        ppcStatusObj.benefitItemDescDtl='Status';
                        ppcStatusObj.benefitDetailItemDesc='Member Status';
                        ppcStatusObj.BenefitLevelDesc=p.memberStatusDesc;
                        rtnList.add(ppcStatusObj);
                        effStsMap.put(targetCertNo,rtnList);
                    }
                }
            }
            // Added by IBM(Roy) due to PEI-156/PORTABLE R2 --END
        }

        //Added by Nicole for Top Up Insurance Certificate
        MemberManagementHelper mHelper=new MemberManagementHelper();
        displayInCert=mHelper.isUserEligibleICDownload(null,targetCertNo,policyNumber,curUserIsInactive);
        if(displayInCert){
            generateInsuranceCertificate();
        }
        System.debug('planMap:'+planMap);
    }

    public void getPlanNameFullList(){
        if(planMap==null&&validateKey){
            planMap=new Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>();
            ServiceCalloutHelper sc=new ServiceCalloutHelper();
            HttpCalloutVO.FullPlan fp=sc.getPolicyPlanNumberList(policyNumber);
            for(String planNo:fp.planList){
                planMap.put(planNo,new List<HttpCalloutVO.PolicyPersonCoverage>()); 
            }            
            planMap.put(targetPlanName,new List<HttpCalloutVO.PolicyPersonCoverage>());
            
            planNoMap = fp.planNoMap;     // Added by Linus JR1904
        }
    }

    public void getPolicyChangeList(){
        if(validateKey){
            // Rancho_PI69_20220609 - remove PendingMemoRequest parameter for getting all records
            // Boolean isPendingMemoRequest=false;
            //String trackingId='';
            WorkCalloutHelper wHelper=new WorkCalloutHelper ();
            if(policyChangeList==null){
                policyChangeList=new List<HttpCalloutVO.WorkStatus>();
                if(policyNumber!=null&&policyNumber!=''){
                    // policyChangeList=wHelper.getWorkStatus(policyNumber,'Policy Change Request',isPendingMemoRequest,null);
                    // Rancho_MR956_20231219 - hide invalid policy change type
                    List<String> invalidTypeList = Label.Invalid_Policy_Change_Type.split(';');
                    List<HttpCalloutVO.WorkStatus> tempList = wHelper.getWorkStatus(policyNumber,'Policy Change Request',null,null);
                    for(HttpCalloutVO.WorkStatus p : tempList){
                        if(null != invalidTypeList && invalidTypeList.contains(p.workType)){
                            continue;
                        }
                        if(p.requestStatus.trim()=='Processing'){
                            p.requestStatus=System.label.Processing;
                        }else if(p.requestStatus.trim()=='Pending Information'){
                            p.requestStatus=System.label.Pending_Information;
                        }else if(p.requestStatus.trim()=='Processed'){
                            p.requestStatus=System.label.Processed;
                        }else if(p.requestStatus.trim()=='Request Completed'){
                            p.requestStatus=System.label.Request_Completed;
                        }
                        policyChangeList.add(p);
                    }

                    allpolicyChangeList=policyChangeList;
                    policyChangePagingMethod();
                }
                System.debug('policyChangeList:'+policyChangeList);
            }
        }
    }

    public PageReference searchPolicyChangebyStatus(){
        policyChangeList=new List<HttpCalloutVO.WorkStatus>();
        if(String.isBlank(selectedpolicyChangeStatus)){
            policyChangeList=allPolicyChangeList;
        }else{
            for(HttpCalloutVO.WorkStatus word:allPolicyChangeList){
                if(word.requestStatus==selectedpolicyChangeStatus){
                    policyChangeList.add(word);
                }
            }
        }
        policyChangePagingMethod();
        //        system.debug('selectedpolicyChangeStatus'+selectedpolicyChangeStatus);
        return null;
    }

    public void getChartData(){
        // ---------------TO DO ------------------
        // ADD WEB SERVICE HERE WHEN AVAILABLE
        if(this.fundSummary==null&&validateKey){
            hideChart=false;
            this.fundContList=new List<FundContribution>();
            this.ChartLabel=new List<String>();
            this.ChartData=new List<String>();
            this.fundSummary=new HttpCalloutVO.PolicyFund();
            this.basicFundDetails=new List<HttpCalloutVO.PolicyAvailFund>();
            this.singleFundDetails=new List<HttpCalloutVO.PolicyAvailFund>();
            this.regularFundDetails=new List<HttpCalloutVO.PolicyAvailFund>();
            this.fundTransaction=new List<HttpCalloutVO.PolicyFundHist>();

            Map<String,ChartValue> cvSet=new Map<String,ChartValue>();
            Map<String,FundContribution> fCMap=new Map<String,FundContribution>();
            if(String.isNotBlank(policyNumber)){
                Decimal totalV=0;
                this.basicFundDetails=helper.getPolicyAvailFundListBasic(policyNumber,'B');
                this.singleFundDetails=helper.getPolicyAvailFundListBasic(policyNumber,'S');
                this.regularFundDetails=helper.getPolicyAvailFundListBasic(policyNumber,'R');
                /* comment by David on Aug 11
              this.fundTransaction=helper.getPolicyFundListHistBasic(policyNumber);
              this.fundTransaction.sort();
              fundTransactionPagingMethod();


              // ----

              for(HttpCalloutVO.PolicyFundHist ft:this.fundTransaction){
                if(ft.unitValueBuyRate!=null&&ft.totValue!=null){
                  ft.totalHKDValue=ft.unitValueBuyRate * ft.totValue;
                  System.debug('productFullName:'+ft.productFullName);
                }
              }
              //-------------end---f
            */
                //server back wrong total data,so calculate manually
                List<HttpCalloutVO.PolicyAvailFund> allDetails=new List<HttpCalloutVO.PolicyAvailFund>();
                allDetails.addAll(basicFundDetails);
                allDetails.addAll(singleFundDetails);
                allDetails.addAll(regularFundDetails);

                for(HttpCalloutVO.PolicyAvailFund item:allDetails){
                    if(item.totValue!=0&&item.totValue!=null){
                        totalV +=item.totValue;
                        item.totalHKDValue=(item.totValue * item.unitValueBuyRate);

                        if(cvSet.containsKey(item.productCode)){
                            ChartValue cv=cvSet.get(item.productCode);
                            cv.total +=item.totValue.setScale(2);
                        }else{
                            ChartValue cv=new ChartValue();
                            cv.label=item.productFullName;
                            cv.total=item.totValue.setScale(2);
                            cvSet.put(item.productCode,cv);
                        }
                    }

                    if(item.totValue<0){
                        hideChart=true;
                    }
                }
                //Calculation end

                for(HttpCalloutVO.PolicyAvailFund item:basicFundDetails){
                    if(item.basicPlanPercentInNumber > 0){
                        FundContribution fc=new FundContribution();
                        if(fCMap.containsKey(item.productCode)){
                            fc=fcMap.get(item.productCode);
                        }else{
                            fc.fundName=item.productFullName;
                            fcMap.put(item.productCode,fc);
                        }

                        fc.basicPercentage=item.basicPlanPercentInNumber.setScale(2);
                        fc.basicPercentageDisplay=fc.basicPercentage*100+'%';
                    }
                }

                for(HttpCalloutVO.PolicyAvailFund item:regularFundDetails){
                    if(item.regularAFCPercentInNumber > 0){
                        FundContribution fc=new FundContribution();
                        if(fCMap.containsKey(item.productCode)){
                            fc=fcMap.get(item.productCode);
                        }else{
                            fc.fundName=item.productFullName;
                            fcMap.put(item.productCode,fc);
                        }

                        fc.regularPercentage=item.regularAFCPercentInNumber.setScale(2);
                        fc.regularPercentageDisplay=fc.regularPercentage*100+'%';
                    }
                }

                for(FundContribution fc:fcMap.values()){
                    this.fundContList.add(fc);
                }

                List<HttpCalloutVO.PolicyFund> pfList=helper.getPolicyFundListBasic(policyNumber);
                if(pfList!=null&&pfList.size()>0){
                    this.fundSummary=pfList[0];
                }
                //this.fundSummary.accountValue=totalV;
            }

            Decimal chartTotal=0;

            // percentage and name for each fund
            for(String item:cvSet.keyset()){
                ChartValue cv=cvSet.get(item);
                if(cv.total>0){
                    chartTotal +=cv.total;
                    this.ChartData.add(cv.total+'');
                }
            }

            for(String item:cvSet.keyset()){
                ChartValue cv=cvSet.get(item);
                if(cv.total>0){
                    cv.percentage=(cv.total/chartTotal).setScale(4);
                    cv.percentageDisplay=(cv.percentage * 100).setScale(2)+'%';
                    this.ChartLabel.add(cv.percentageDisplay+' '+cv.label);
                }
            }
            //            System.debug('Chart:'+this.ChartLabel+' - '+this.ChartData);
        }
    }

    private void handleClaimTypes(List<HttpCalloutVO.Claim> cList){
        if(cList!=null){
            for(HttpCalloutVO.Claim c:cList){
                c.claimTypeDisplay=null;
                Set<String> claimTypeDisplaySet=new Set<String>();
                for(HttpCalloutVO.ClaimCoverage cc:c.coverageList){
                    if(!claimTypeDisplaySet.contains(cc.claimTypeDisplay)){
                        if(c.claimTypeDisplay==null){
                            c.claimTypeDisplay=cc.claimTypeDisplay+',';
                        }else{
                            c.claimTypeDisplay +=cc.claimTypeDisplay+',';
                        }
                        claimTypeDisplaySet.add(cc.claimTypeDisplay);
                    }
                }

                if(c.claimTypeDisplay!=null&&c.claimTypeDisplay.length()>0){
                    c.claimTypeDisplay=c.claimTypeDisplay.trim().substring(0,c.claimTypeDisplay.length()-1);
                }
            }
        }
    }

    public void getPolicyClaimHistory(){
        if(validateKey){
            try{
                showTooManyRecordError=false;
                if(claimList==null){
                    claimStartIndex=1;
                    claimList=new List<HttpCalloutVO.Claim>();
                    allClaimList=new List<HttpCalloutVO.Claim>();
                    ClaimCalloutHelper cHelper=new ClaimCalloutHelper();
                    //                    system.debug ('cxcx '+policyNumber+' '+currentUser.account.ssn__c  );
                    if(policyNumber!=null&&policyNumber!=''){
                        if(isGroup){
                            if(isBrokerUser){
                                claimList=cHelper.GetClaimListBasicByCriteria('','All',policyNumber,'','','','',null,claimStartIndex,PAGE_SIZE);
                            }else{
                                claimList=cHelper.GetClaimListBasicByCriteria('','All',policyNumber,'','',currentUser.account.ssn__c,'',null,claimStartIndex,PAGE_SIZE);
                            }
                        }else{
                            claimList=cHelper.GetClaimListBasicByCriteria('','All',policyNumber,'','','','',null,claimStartIndex,PAGE_SIZE);
                        }

                        handleClaimTypes(claimList);
                        //                        System.debug('cHelper.getLastCallTotalRecords():'+cHelper.getLastCallTotalRecords());
                        totalClaimRecords=(cHelper.getLastCallTotalRecords()>0)?cHelper.getLastCallTotalRecords():1;
                        //totalClaimRecords=claimList.size() ==0? 1:claimList.size();
                        claimPagingMethod();
                    }
                    System.debug('claimMapdd:'+claimMap);
                    //                    System.debug('totalClaimRecords:'+totalClaimRecords);
                }
            }catch(CignaWSResultTooLargeException e){
                showTooManyRecordError=true;
                //                System.debug('Too many record');
            }
        }
    }

    public void claimPrevPage(){
        claimStartIndex -=PAGE_SIZE;
        claimPage--;

        if(!claimMap.containsKey(claimPage)){
            ClaimCalloutHelper cHelper=new ClaimCalloutHelper();
            List<HttpCalloutVO.Claim> tempClaimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','',currentUser.account.ssn__c,'',null,claimStartIndex,PAGE_SIZE);
            claimMap.put(claimPage,tempClaimList);
            handleClaimTypes(tempClaimList);
        }

        claimhasNext=true;
        claimhasPrev=false;
        if(claimPage>1){
            claimhasPrev=true;
        }
    }

    public void claimNextPage(){
        claimStartIndex +=PAGE_SIZE;
        claimPage++;

        if(!claimMap.containsKey(claimPage)){
            ClaimCalloutHelper cHelper=new ClaimCalloutHelper();
            List<HttpCalloutVO.Claim> tempClaimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','',currentUser.account.ssn__c,'',null,claimStartIndex,PAGE_SIZE);
            claimMap.put(claimPage,tempClaimList);
            handleClaimTypes(tempClaimList);
        }

        claimhasPrev=true;
        claimhasNext=false;
        if(claimPage<claimtotalPage){
            claimhasNext=true;
        }
    }

    public void claimPagingMethod(){
        claimPage=1;
        claimTotalPage=Math.ceil(totalClaimRecords/Double.valueOf(PAGE_SIZE)).intValue();
        System.debug('sdfd:'+totalClaimRecords+'  - '+claimTotalPage);
        claimhasPrev=false;
        claimhasNext=false;

        if(claimTotalPage>1){
            claimhasNext=true;
            setDeparateResultList('getPolicyClaim');
        }else{
            claimMap=new Map<Integer,List<HttpCalloutVO.Claim>>();
            claimMap.put(1,claimList);
        }
        //        system.debug('claimPagingMethod'+claimMap);
    }

    public PageReference searchClaimbyStatus(){
        ClaimCalloutHelper cHelper=new ClaimCalloutHelper();
        if(!isGroup){
            claimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','','','','',null,1,PAGE_SIZE);
        }else{
            if(isBrokerUser){
                if(currentGroupClaimSearchCriteria=='Member Name'){
                    claimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','','',currentGroupSearchValue,'',null,1,PAGE_SIZE);
                }else if(currentGroupClaimSearchCriteria=='Member Id'){
                    claimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','','','','',currentGroupSearchValue,null,1,PAGE_SIZE);
                }else{
                    claimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','','','','',null,1,PAGE_SIZE);
                }
            }else{
                claimList=cHelper.GetClaimListBasicByCriteria('',selectedClaimStatus,policyNumber,'','',currentUser.account.ssn__c,'','',null,1,PAGE_SIZE);
            }

        }
        handleClaimTypes(claimList);
        totalClaimRecords=(cHelper.getLastCallTotalRecords()>0)?cHelper.getLastCallTotalRecords():1;
        //totalClaimRecords=claimList.size() ==0? 1:claimList.size();
        claimPagingMethod();
        //        system.debug('selectedClaimStatus'+selectedClaimStatus);
        return null;
    }

    public List<SelectOption> getclaimStatusList(){
        List<SelectOption> claimStatusList=new List<SelectOption>();
        claimStatusList.add(new SelectOption('All',Label.Pol_Claim_All));

        if(this.isGroup){
            List<Claim_Status__C> cs=[SELECT code__C,Desc_EN__c,Desc_ZH__c,Group__C,Individual__C,IPMI__C,Non_IPMI__C FROM Claim_Status__C Where Group__C=TRUE AND Display__C=TRUE];
            if(UserInfo.getLanguage().contains('zh')){
                for(Claim_Status__C c:cs){
                    claimStatusList.add(new SelectOption(c.Desc_EN__c,c.Desc_ZH__c));
                }
            }else{
                for(Claim_Status__C c:cs){
                    claimStatusList.add(new SelectOption(c.Desc_EN__c,c.Desc_EN__c));
                }
            }
        }else{
            List<Claim_Status__C> cs=[SELECT code__C,Desc_EN__c,Desc_ZH__c,Group__C,Individual__C,IPMI__C,Non_IPMI__C FROM Claim_Status__C Where Individual__C=TRUE AND Display__C=TRUE];
            if(UserInfo.getLanguage().contains('zh')){
                for(Claim_Status__C c:cs){
                    claimStatusList.add(new SelectOption(c.Desc_EN__c,c.Desc_ZH__c));
                }
            }else{
                for(Claim_Status__C c:cs){
                    claimStatusList.add(new SelectOption(c.Desc_EN__c,c.Desc_EN__c));
                }
            }
        }
        return claimStatusList;
    }

    public void getClinicVisitCount(){
        if(benefitList==null&&validateKey){
            List<HttpCalloutVO.ClinicVisit> clinicVisitList=new List<HttpCalloutVO.ClinicVisit>();
            this.clinicVisitSummary=new HttpCalloutVO.CombinedBenefit();
            this.benefitList=new List<HttpCalloutVO.BenefitDetailItem>();
            this.benefitCategoryList=new List<HttpCalloutVO.BenefitCategory>();
            totalClinicCount=0;

            this.usBenefitCombinedList=new List<HttpCalloutVO.UnionStructBenefitCombined>();//Add by Manuel that customized union struct with two classes
            if(policyNumber!=null&&policyNumber!=''){
                getGroupMemberBasic();
                if(groupMemberDetail!=null){
                    clinicVisitList=helper.getClinicVisitCount(policyNumber,currentUser.account.ssn__c,groupMemberDetail.certificateNo);
                }
            }
            if(!clinicVisitList.isEmpty()&&clinicVisitList.size()>0){
                this.benefitCategoryList=clinicVisitList[0].benefitCategoryList;
                for(HttpCalloutVO.BenefitCategory benCategory:clinicVisitList[0].benefitCategoryList){
                    benCategory.benefitList.sort();
                    for(HttpCalloutVO.BenefitDetailItem benefit:benCategory.benefitList){
                        totalClinicCount ++;
                    }
                }
                //usBenefitCombinedPagingMethod();

                //Add by Manuel that customized union struct with two classes
                /* Comment by Nicole for getClinicVisits WS structure update in 20190730,referrence to Digital WS XML Specification v1.17.xlsx
                if(!clinicVisitList[0].benefitList.isEmpty()&&clinicVisitList[0].benefitList.size()>0){
                    for(integer j=0;j<clinicVisitList[0].benefitList.size();j++){
                        HttpCalloutVO.UnionStructBenefitCombined usTmpJ=new HttpCalloutVO.UnionStructBenefitCombined();
                        usTmpJ.usBenefitDetailItem=clinicVisitList[0].benefitList.get(j);
                        //if(usTmpJ.usBenefitDetailItem.maxNoofVisitPerYear!=null&&usTmpJ.usBenefitDetailItem.visitedCount!=null&&usTmpJ.usBenefitDetailItem.benefitVisitBalance!=null){
                        if(usTmpJ.usBenefitDetailItem.maxNoofVisitPerYear!=null&&usTmpJ.usBenefitDetailItem.visitedCount!=null){
                            this.usBenefitCombinedList.add(usTmpJ);
                        }
                    }
                }

                if(!clinicVisitList[0].combinedBenefitList.isEmpty()&&clinicVisitList[0].combinedBenefitList.size()>0){
                    this.clinicVisitSummary=clinicVisitList[0].combinedBenefitList.get(0);

                    //Add by Manuel that customized union struct with two classes
                    for(integer i=0;i<clinicVisitList[0].combinedBenefitList.size();i++){
                        HttpCalloutVO.UnionStructBenefitCombined usTmpI=new HttpCalloutVO.UnionStructBenefitCombined();
                        usTmpI.usCombinedBenefit=clinicVisitList[0].combinedBenefitList.get(i);
                        //by caden modifiy for 999999 unlimited combined benefit
                        if(usTmpI.usCombinedBenefit.overallOutpatientMaximumNo!=null&&usTmpI.usCombinedBenefit.overallOutpatientMaximumNo==integer.valueOf(unlimitedVisCount)){
                            if(usTmpI.usCombinedBenefit.totalVisitBalance!=null&&usTmpI.usCombinedBenefit.totalVisitBalance!=0){
                                usTmpI.usCombinedBenefit.totalRemainingVisitBalanceStr=unlimitedVisCountDesc;

                            }
                            usTmpI.usCombinedBenefit.overallOutpatientMaximumNoStr=unlimitedVisCountDesc;
                        }else{
                            Integer balance=usTmpI.usCombinedBenefit.overallOutpatientMaximumNo - usTmpI.usCombinedBenefit.totalVisitedCount;
                            usTmpI.usCombinedBenefit.totalRemainingVisitBalanceStr=String.valueOf(balance);
                        }
                        this.usBenefitCombinedList.add(usTmpI);
                    }
                }
                this.benefitList=clinicVisitList[0].benefitList;

                if(this.clinicVisitSummary.overallOutpatientMaximumNo!=null&&this.clinicVisitSummary.totalVisitedCount!=null){
                  this.clinicVisitSummary.totalRemainingVisitBalance=this.clinicVisitSummary.overallOutpatientMaximumNo - this.clinicVisitSummary.totalVisitedCount;
                }

                //20190219 Change the variable type from Integer to String by Caden
                for(HttpCalloutVO.BenefitDetailItem b:this.benefitList){
                  if(b.maxNoofVisitPerYear!=null&&b.visitedCount!=null){
                       if(b.maxNoofVisitPerYearStr!=null&&b.maxNoofVisitPerYearStr==unlimitedVisCount){
                            if(b.benefitVisitBalance!=0){
                                b.visitBalance=unlimitedVisCountDesc;
                            }
                        b.maxNoofVisitPerYearStr=unlimitedVisCountDesc;

                    }else{
                        Integer bal=b.maxNoofVisitPerYear - b.visitedCount;
                        b.visitBalance=String.valueOf(bal);
                    }
                  }

                }
                benefitPagingMethod();

                usBenefitCombinedPagingMethod();//Add by Manuel that customized union struct with two classes
                Comment by Nicole End*/
            }
        }
    }
    
    //JOBR23-Kirk-20210106
    public void getClinicVisitCountByCertNo(){
        List<HttpCalloutVO.ClinicVisit> clinicVisitList=new List<HttpCalloutVO.ClinicVisit>();
        this.clinicVisitSummary=new HttpCalloutVO.CombinedBenefit();
        this.benefitList=new List<HttpCalloutVO.BenefitDetailItem>();
        this.benefitCategoryList=new List<HttpCalloutVO.BenefitCategory>();
        totalClinicCount=0;

        this.usBenefitCombinedList=new List<HttpCalloutVO.UnionStructBenefitCombined>();
        system.debug('to see policyNumber'+policyNumber);
        if(policyNumber!=null&&policyNumber!=''){
            getGroupMemberBasic();
            if(groupMemberDetail!=null){
                clinicVisitList=helper.getClinicVisitCount(policyNumber,currentUser.account.ssn__c,targetCertNo);    
            }
        }
        if(!clinicVisitList.isEmpty()&&clinicVisitList.size()>0){
            //JOBR24-KIRK-20220119-Separate inpatient visit counts into another tab
            for(HttpCalloutVO.BenefitCategory benCategory:clinicVisitList[0].benefitCategoryList){
                benCategory.benefitList.sort();
                for(Integer i = 0; i < benCategory.benefitList.size(); i++){   
                    if(clinicOrInpatient=='Clinic'){
                        if(benCategory.benefitList[i].benefitSectionCode!='OPB'){
                            benCategory.benefitList.remove(i);
                            i--;
                        }else{
                            totalClinicCount ++;
                        }
                    }else{
                        if(benCategory.benefitList[i].benefitSectionCode!='HOS'){
                            benCategory.benefitList.remove(i);
                            i--;
                        }else{
                            totalClinicCount ++;
                        }
                    }     
                }
            }
            this.benefitCategoryList=clinicVisitList[0].benefitCategoryList;
            system.debug('to see benefitCategoryList'+this.benefitCategoryList[0].benefitList);
            usBenefitCombinedPagingMethod();
        }
    }

    public List<SelectOption> getbranchList(){
        if(branchList==null){
            branchList=new List<SelectOption>();
            branchList.add(new SelectOption('All','All'));
            ServiceCalloutHelper sc=new ServiceCalloutHelper();
            HttpCalloutVO.FullBranch fb=sc.getPolicyBranchCodeList(policyNumber);
            for(HttpCalloutVO.Branch b:fb.branchList){
                branchList.add(new SelectOption(b.branchCode,b.branchDesc));
            }
        }
        return branchList;
    }

    public List<SelectOption> getpolicyChangeStatusList(){
        List<SelectOption> policyChangeStatusList=new List<SelectOption>();
        policyChangeStatusList.add(new SelectOption('',Label.Pol_Claim_All));
        policyChangeStatusList.add(new SelectOption(Label.Processing,Label.Processing));
        policyChangeStatusList.add(new SelectOption(Label.Request_Completed,Label.Request_Completed));
        policyChangeStatusList.add(new SelectOption(Label.Processed,Label.Processed));
        policyChangeStatusList.add(new SelectOption(Label.Pending_Information,Label.Pending_Information));
        return policyChangeStatusList;
    }

    public Map<String,PolicyFieldByType__c> getFieldAvailabilities(){
        return PolicyFieldByType__c.getAll();
    }

    public Map<String,Map<String,Boolean>> getFields2(){
        fields2=new Map<String,Map<String,Boolean>>();
        Map<String,PolicyFieldByType__c> policyFieldMap=getFieldAvailabilities();
        for(String key:policyFieldMap.keyset()){
            Map<String,Boolean> temMap=new Map<String,Boolean>();
            if(policyFieldMap.get(key)!=null){
                temMap.put('ILAS',policyFieldMap.get(key).ILAS__c);
                temMap.put('nonILAS',policyFieldMap.get(key).Non_ILAS__c);
                temMap.put('Group',policyFieldMap.get(key).Group__c);
            }
            fields2.put(key,temMap);
        }
        return fields2;
    }

    /*
    public PageReference getPolicyDetailData(){
       //information

       policy=new HttpCalloutVO.Policy();
       policy.policyNumber=policyNumber ;
       policy.policyPackage=new List<String>();
       policy.policyPackage.add('Waiver Insured Premium');
       policy.policyPackage.add('Health Protected');

        if(UserInfo.getLanguage()=='zh_TW'){
            policy.planTypeDescription='團體醫療';
        }else{
            policy.planTypeDescription='Group Medical';
        }

        if(UserInfo.getLanguage()=='zh_TW'){
            if(policyType=='ILAS'){
                policy.planName='金牌計劃';
            }else{
                policy.planName='信諾自選醫療保 - 半私家房';
            }
        }else{
             if(policyType=='ILAS'){
                policy.planName='Gold Medal Plan';
            }else{
                policy.planName='HealthFirst Choice Medical Plan - Semi-Private';
            }
        }

       policy.policyHolder='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           policy.policyHolder=' Chan Hung Tak';
       }
       policy.effDate='03/12/2016';

       if(UserInfo.getLanguage()=='zh_TW'){
            policy.policyStatus='生效';
        }else{
            policy.policyStatus='Inforce';
        }

       policy.currencyCode='HKD';
       policy.paymentMode='Annually';
       policy.currencyCode='HKD';
       policy.paymentAmt=2000.00;
       policy.paidToDate='09/12/2017';
       policy.brokerCompany='AGEAS Insurance Brokers (HK) Ltd';

       policy.brokerContactPerson='Demon Wong';
       policy.brokerContactNo='89999999';
       policy.coveragePeriodFrom='03/12/2016';
       policy.coveragePeriodTo='09/12/2017';
       policy.numberofEmployees='221';

       policy.numberofSpouse='1';
       policy.numberofChildren='2';
       policy.validUntil='09/12/2017';
       policy.brokerName='Jessica Lee';
       policy.brokerCode='BK201';

       policy.holderContactNumber='85226111';
       policy.mailingAddress='Flat Z,1/F,Block B,ABC Court,Ho Man Tin,Kowloon,Hong Kong';

       holder=new HttpCalloutVO.Person();
       holder.personId='1';
       holder.fullName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           holder.fullName=' Chan Hung Tak';
       }
       holder.gender='Male';
       holder.birthDate='15/11/1975';
       holder.ssnNumber='8149519';
       holder.emailAddress='huangtaiman123@hotmail.com';

       HttpCalloutVO.Person person=new HttpCalloutVO.Person();
       person.personId='2';
       person.fullName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           person.fullName=' Chan Hung Tak';
       }
       person.gender='Male';
       person.birthDate='15/11/1975';
       person.ssnNumber='8149519';
       person.emailAddress='huangtaiman123@hotmail.com';

       holder.emailAddress='huangtaiman123@hotmail.com';
       insuredList=new List<HttpCalloutVO.Person>();
       insuredList.add(holder);
       beneficiaryList=new List<HttpCalloutVO.Person>();
       beneficiaryList.add(holder);
       beneficiaryList.add(person);
       policyDocList=new List<HttpCalloutVO.PolicyDocType>();
       policyDoc=new HttpCalloutVO.PolicyDoc();


       //Coverage Information Tab
       policyCoverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
       HttpCalloutVO.PolicyPersonCoverage Coverage=new HttpCalloutVO.PolicyPersonCoverage();
       Coverage.benefit='Altruist,Private,HKD 150k deductible';
       Coverage.sumInsured=180000;
       Coverage.deductibleAmount=115000;
       Coverage.effectiveDate='03/12/2016';
       Coverage.modalPremium=12892.00;

       Coverage.additionalFundContributionAmount='HKD180,000';
       Coverage.annualPremium=910990;
       Coverage.additionalFundContributionAnnualAmount='HKD910,990';
       Coverage.insuredName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           Coverage.insuredName=' Chan Hung Tak';
       }
       Coverage.maturityexpiryDate='09/12/2017';

       HttpCalloutVO.PolicyPersonCoverage Coverage1=new HttpCalloutVO.PolicyPersonCoverage();
       Coverage1.benefit='Altruist,Private,HKD 150k deductible';
       Coverage1.sumInsured=290000;
       Coverage1.deductibleAmount=185000;
       Coverage1.effectiveDate='03/12/2016';
       Coverage1.modalPremium=14892.00;

       Coverage1.additionalFundContributionAmount='HKD185,000';
       Coverage1.annualPremium=910990;
       Coverage1.additionalFundContributionAnnualAmount='HKD110,990';
       Coverage1.insuredName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           Coverage1.insuredName=' Chan Hung Tak';
       }
       Coverage1.maturityexpiryDate='12/10/2017';
       policyCoverageList.add(Coverage);
       policyCoverageList.add(Coverage1);
       policyCoverageList.add(Coverage1);
       policyCoverageList.add(Coverage1);
       policyCoverageList.add(Coverage1);
       policyCoverageList.add(Coverage1);

       coveragePagingMethod();

       //Payment Information Tab
       payment=new HttpCalloutVO.PolicyPayment();
       payment.annualPremium=11000;
       payment.paymentMode='Annually';
       payment.paymentMethod='Autopay';
       payment.polDebitDay='03/12/2016';
       payment.modalPremium=111000.01;

       payment.PayerName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           payment.PayerName=' Chan Hung Tak';
       }
       payment.accountNumber='122-345678-886';
       payment.polAdditionalFundContribution=11000;
       payment.startDateofAutomaticPremiumPayment='03/12/2016';
       payment.endDateofAutomaticPremiumPayment='09/10/2016';

       payment.modalPremium=payment.modalPremium+coverage.modalPremium;

       paymentTransactionList=new List<HttpCalloutVO.PolicyBilling>();
       HttpCalloutVO.PolicyBilling billing=new HttpCalloutVO.PolicyBilling();
       billing.finActivityDate='03/12/2016';
       billing.description='Payment Information';
       billing.paymentAmt=24892.00;
       billing.automaticPremiumPayment=24892.00;
       paymentTransactionList.add(billing);

       HttpCalloutVO.PolicyBilling billing1=new HttpCalloutVO.PolicyBilling();
       billing1.finActivityDate='09/01/2016';
       billing1.description='Payment Information';
       billing1.paymentAmt=24892.00;
       billing1.automaticPremiumPayment=24892.00;
       paymentTransactionList.add(billing1);

       HttpCalloutVO.PolicyBilling billing2=new HttpCalloutVO.PolicyBilling();
       billing2.finActivityDate='09/02/2016';
       billing2.description='Payment Information';
       billing2.paymentAmt=24892.00;
       billing2.automaticPremiumPayment=24892.00;
       paymentTransactionList.add(billing2);

       HttpCalloutVO.PolicyBilling billing3=new HttpCalloutVO.PolicyBilling();
       billing3.finActivityDate='09/03/2016';
       billing3.description='Payment Information';
       billing3.paymentAmt=24892.00;
       billing3.automaticPremiumPayment=24892.00;
       paymentTransactionList.add(billing3);

       HttpCalloutVO.PolicyBilling billing4=new HttpCalloutVO.PolicyBilling();
       billing4.finActivityDate='09/04/2016';
       billing4.description='Payment Information';
       billing4.paymentAmt=24892.00;
       billing4.automaticPremiumPayment=24892.00;
       paymentTransactionList.add(billing4);

       HttpCalloutVO.PolicyBilling billing5=new HttpCalloutVO.PolicyBilling();
       billing5.finActivityDate='09/05/2016';
       billing5.description='Payment Information';
       billing5.paymentAmt=24892.00;
       billing5.automaticPremiumPayment=24892.00;
       paymentTransactionList.add(billing5);

       paymentTranPagingMethod();

       //Policy Change Tab
       policyChangeList=new List<HttpCalloutVO.WorkStatus>();
       HttpCalloutVO.WorkStatus work=new HttpCalloutVO.WorkStatus();
       work.workType='Change of Address';
       work.workStatus='Request Completed';
       work.receivedDate='09/12/2017';
       work.lastUpdateDate='10/12/2016';
       policyChangeList.add(work);

       HttpCalloutVO.WorkStatus work1=new HttpCalloutVO.WorkStatus();
       work1.workType='Change of Amount';
       work1.workStatus='Request Completed';
       work1.receivedDate='03/12/2016';
       work1.lastUpdateDate='12/12/2015';
       policyChangeList.add(work1);

       HttpCalloutVO.WorkStatus work2=new HttpCalloutVO.WorkStatus();
       work2.workType='Change of Address';
       work2.workStatus='Processing';
       work2.receivedDate='10/11/2016';
       work2.lastUpdateDate='11/11/2016';
       policyChangeList.add(work2);
       policyChangeList.add(work2);
       policyChangeList.add(work2);
       policyChangeList.add(work2);
       allPolicyChangeList=policyChangeList;

       policyChangePagingMethod();

       //Claim HIstory Tab
       claimList=new List<HttpCalloutVO.Claim>();
       HttpCalloutVO.Claim claim=new HttpCalloutVO.Claim();
       claim.claimNumber='Claim101';
       claim.certNumber='MCN0015';
       claim.benefitType='Outpatient Benefit';
       claim.incurredAmount=100.00;
       claim.paidAmount =100.00;

       claim.paymentDate='03/12/2016';
       claim.claimStatusDescription='Paid';
       claim.branch='Branch20013';
       claim.receivedDate='03/12/2016';
       claim.policyInsuredName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           claim.policyInsuredName=' Chan Hung Tak';
       }
       claim.lastUpdateDate='03/12/2016';
       claim.memberName='Chan May May';
       claimList.add(claim);

       HttpCalloutVO.Claim claim1=new HttpCalloutVO.Claim();
       claim1.claimNumber='Claim102';
       claim1.certNumber='MCN0015';
       claim1.benefitType='Outpatient Benefit';
       claim1.incurredAmount=100.00;
       claim1.paidAmount =100.00;

       claim1.paymentDate='09/01/2015';
       claim1.claimStatusDescription='Processing';
       claim1.branch='Branch20013';
       claim1.receivedDate='09/01/2015';
       claim1.policyInsuredName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           claim1.policyInsuredName=' Chan Hung Tak';
       }
       claim1.lastUpdateDate='09/01/2015';
       claim1.memberName='Chan May May';
       claimList.add(claim1);

       HttpCalloutVO.Claim claim2=new HttpCalloutVO.Claim();
       claim2.claimNumber='Claim105';
       claim2.certNumber='MCN0015';
       claim2.benefitType='Outpatient Benefit';
       claim2.incurredAmount=100.00;
       claim2.paidAmount =100.00;

       claim2.paymentDate='09/03/2016';
       claim2.claimStatusDescription='Paid';
       claim2.branch='Branch20013';
       claim2.receivedDate='09/03/2016';
       claim2.policyInsuredName='Huang Tai Man';
       if(policy.policyNumber=='HL00006747'){
           claim2.policyInsuredName=' Chan Hung Tak';
       }
       claim2.lastUpdateDate='09/03/2016';
       claim2.memberName='Chan May May';
       claimList.add(claim2);
       claimList.add(claim2);
       claimList.add(claim2);
       claimList.add(claim2);
       claimList.add(claim2);
       allClaimList=claimList;

       claimPagingMethod();

       //Premium Settlement Tab
       premiumSettlementList=new List<HttpCalloutVO.PolicyBilling>();
       billing.invoiceNumber='INV-0102931';
       billing.issueDate='03/12/2016';
       billing.invoiceAmount=5000.00;
       billing.settledAmount=5000.00;
       billing.paymentStatusDate='03/12/2016';
       billing.unsettleBalance=0.00;
       billing.commissionAmt=100.00;
       billing.branchDesc='HongKong';
       premiumSettlementList.add(billing);

       billing1.invoiceNumber='INV-0102935';
       billing1.issueDate='09/01/2016';
       billing1.invoiceAmount=5000.00;
       billing1.settledAmount=4500.00;
       billing1.paymentStatusDate='09/01/2016';
       billing1.unsettleBalance=500.00;
       billing1.commissionAmt=100.00;
       billing1.branchDesc='HongKong';
       premiumSettlementList.add(billing1);

       billing2.invoiceNumber='INV-0102939';
       billing2.issueDate='09/02/2016';
       billing2.invoiceAmount=5000.00;
       billing2.settledAmount=5000.00;
       billing2.paymentStatusDate='09/02/2016';
       billing2.unsettleBalance=0.00;
       billing2.commissionAmt=100.00;
       billing2.branchDesc='HongKong';
       premiumSettlementList.add(billing2);

       billing3.invoiceNumber='INV-0103001';
       billing3.issueDate='09/05/2016';
       billing3.invoiceAmount=5000.00;
       billing3.settledAmount=5000.00;
       billing3.paymentStatusDate='09/05/2016';
       billing3.unsettleBalance=0.00;
       billing3.commissionAmt=100.00;
       billing3.branchDesc='HongKong';
       premiumSettlementList.add(billing3);

       billing4.invoiceNumber='INV-0103003';
       billing4.issueDate='09/07/2016';
       billing4.invoiceAmount=5000.00;
       billing4.settledAmount=5000.00;
       billing4.paymentStatusDate='09/07/2016';
       billing4.unsettleBalance=0.00;
       billing4.commissionAmt=100.00;
       billing4.branchDesc='Macau';
       premiumSettlementList.add(billing4);
       premiumSettlementList.add(billing4);
       allPremiumSettlementList=premiumSettlementList;

       settlementPagingMethod();

       //Member List Tab
       /*memberList=new List<HttpCalloutVO.Person>();
       HttpCalloutVO.Person coveragep=new HttpCalloutVO.Person();
       coveragep.memberCertNo='MCN0015';
       coveragep.memberName='Lam Shun Chi';
       coveragep.relation='Employee';
       coveragep.plan='plan 0914';
       coveragep.memberEffDate='10/05/2015';
       coveragep.memberStatus='Active';
       coveragep.benefitType='Outpatient Benefit';
       coveragep.lifeSumAssured='HKD100,000.00';
       coveragep.TPDSumAssured='HKD100,000.00';
       coveragep.ADandDSumAssured='HKD2,000,000.00';
       coveragep.LTDSumAssured='HKD1,000,000.00';
       coveragep.CIBSumAssured='HKD8,000';
       coverage.branch='Macau';
       memberList.add(coveragep);

       HttpCalloutVO.Person coverage1p=new HttpCalloutVO.Person();
       coverage1p=new HttpCalloutVO.Person();
       coverage1p.memberCertNo='MCN1005';
       coverage1p.memberName='Chan May May';
       coverage1p.relation='Employee';
       coverage1p.plan='plan 1021';
       coverage1p.memberEffDate='10/05/2015';
       coverage1p.memberStatus='Active';
       coverage1p.benefitType='Outpatient Benefit';
       coverage1p.lifeSumAssured='HKD150,000.00';
       coverage1p.TPDSumAssured='HKD150,000.00';
       coverage1p.ADandDSumAssured='HKD2,000,000.00';
       coverage1p.LTDSumAssured='HKD1,000,000.00';
       coverage1p.CIBSumAssured='HKD8,000';
       coverage1p.branch='HongKong';
       memberList.add(coverage1);
       memberList.add(coverage1);
       memberList.add(coverage1);
       memberList.add(coverage1);
       memberList.add(coverage1);
       allMemberList=memberList;

       memberPagingMethod();
       //Remaining Clinic Visits
       /*
       clinicVisitSummary=new HttpCalloutVO.CombinedBenefit();
       clinicVisitSummary.overallOutpatientMaximumNo='420';
       clinicVisitSummary.totalVisitedCount='6500';
       clinicVisitSummary.totalRemainingVisitBalance='6500';

       benefitList=new List<HttpCalloutVO.BenefitDetailItem>();
       HttpCalloutVO.BenefitDetailItem item1=new HttpCalloutVO.BenefitDetailItem();
       item1.benefitDetailItemCode='Employee';
       item1.benefitType='User';
       item1.maxNoofVisitPerYear='50';
       item1.visitedCount='3000';
       item1.benefitVisitBalance='2000';
       benefitList.add(item1);

       HttpCalloutVO.BenefitDetailItem item2=new HttpCalloutVO.BenefitDetailItem();
       item2.benefitDetailItemCode='Employee';
       item2.benefitType='User';
       item2.maxNoofVisitPerYear='200';
       item2.visitedCount='2000';
       item2.benefitVisitBalance='2500';
       benefitList.add(item2);

       HttpCalloutVO.BenefitDetailItem item3=new HttpCalloutVO.BenefitDetailItem();
       item3.benefitDetailItemCode='Employee';
       item3.benefitType='User';
       item3.maxNoofVisitPerYear='170';
       item3.visitedCount='1500';
       item3.benefitVisitBalance='2000';
       benefitList.add(item3);
       benefitPagingMethod();

       return null;
    }
    */

    public void setDeparateResultList(String selectedTab){
        if(selectedTab=='getPaymentTransaction'){
            List<HttpCalloutVO.PolicyBilling> paymentList=new List<HttpCalloutVO.PolicyBilling>();
            paymentTranMap=new Map<Integer,List<HttpCalloutVO.PolicyBilling>>();
            Integer j=1;
            for(Integer i=1;i<=paymentTransactionList.size();i++){
                paymentList.add(paymentTransactionList[i-1]);
                if(paymentList.size()==PAGE_SIZE){
                    paymentTranMap.put(j,paymentList);
                    paymentList=new List<HttpCalloutVO.PolicyBilling>();
                    if(i!=paymentTransactionList.size()){
                        j++;
                    }
                }else if(i==paymentTransactionList.size()){
                    paymentTranMap.put(j,paymentList);
                }
            }
            paymentTranTotalPage=j;
        }else if(selectedTab=='getPolicyCoverage'){
            List<HttpCalloutVO.PolicyPersonCoverage> coverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
            coverageMap=new Map<Integer,List<HttpCalloutVO.PolicyPersonCoverage>>();
            Integer j=1;
            for(Integer i=1;i<=policyCoverageList.size();i++){
                coverageList.add(policyCoverageList[i-1]);
                if(coverageList.size()==PAGE_SIZE){
                    coverageMap.put(j,coverageList);
                    coverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
                    if(i!=policyCoverageList.size()){
                        j++;
                    }
                }else if(i==policyCoverageList.size()){
                    coverageMap.put(j,coverageList);
                }
            }
            coveragetotalPage=j;
        }else if(selectedTab=='getPolicyChange'){
            List<HttpCalloutVO.WorkStatus> changeList=new List<HttpCalloutVO.WorkStatus>();
            policyChangeMap=new Map<Integer,List<HttpCalloutVO.WorkStatus>>();
            Integer j=1;
            for(Integer i=1;i<=policyChangeList.size();i++){
                changeList.add(policyChangeList[i-1]);
                if(changeList.size()==PAGE_SIZE){
                    policyChangeMap.put(j,changeList);
                    changeList=new List<HttpCalloutVO.WorkStatus>();
                    if(i!=policyChangeList.size()){
                        j++;
                    }
                }else if(i==policyChangeList.size()){
                    policyChangeMap.put(j,changeList);
                }
            }
            policyChangeTotalPage=j;
        }else if(selectedTab=='getPolicyClaim'){
            List<HttpCalloutVO.Claim> policyclaimList=new List<HttpCalloutVO.Claim>();
            claimMap=new Map<Integer,List<HttpCalloutVO.Claim>>();
            Integer j=1;
            for(Integer i=1;i<=claimList.size();i++){
                policyclaimList.add(claimList[i-1]);
                if(policyclaimList.size()==PAGE_SIZE){
                    claimMap.put(j,policyclaimList);
                    policyclaimList=new List<HttpCalloutVO.Claim>();
                    if(i!=claimList.size()){
                        j++;
                    }
                }else if(i==claimList.size()){
                    claimMap.put(j,policyclaimList);
                }
            }
            //            System.debug('claimMap:'+claimMap);
            //claimTotalPage=j;
        }else if(selectedTab=='getPremiumSettlement'){
            List<HttpCalloutVO.PolicyBilling> settlementList=new List<HttpCalloutVO.PolicyBilling>();
            settlementMap=new Map<Integer,List<HttpCalloutVO.PolicyBilling>>();
            Integer j=1;
            for(Integer i=1;i<=premiumSettlementList.size();i++){
                settlementList.add(premiumSettlementList[i-1]);
                if(settlementList.size()==PAGE_SIZE){
                    settlementMap.put(j,settlementList);
                    settlementList=new List<HttpCalloutVO.PolicyBilling>();
                    if(i!=premiumSettlementList.size()){
                        j++;
                    }
                }else if(i==premiumSettlementList.size()){
                    settlementMap.put(j,settlementList);
                }
            }
            settlementTotalPage=j;

        }else if(selectedTab=='getMemberList'){
            List<HttpCalloutVO.Person> policymemberList=new List<HttpCalloutVO.Person>();
            memberMap=new Map<Integer,List<HttpCalloutVO.Person>>();
            Integer j=1;
            for(Integer i=1;i<=memberList.size();i++){
                policymemberList.add(memberList[i-1]);
                if(policymemberList.size()==PAGE_SIZE){
                    memberMap.put(j,policymemberList);
                    policymemberList=new List<HttpCalloutVO.Person>();
                    if(i!=memberList.size()){
                        j++;
                    }
                }else if(i==memberList.size()){
                    memberMap.put(j,policymemberList);
                }
            }
            memberTotalPage=j;
        }else if(selectedTab=='getBenefitDetail'){
            List<HttpCalloutVO.BenefitDetailItem> itemList=new List<HttpCalloutVO.BenefitDetailItem>();
            benefitMap=new Map<Integer,List<HttpCalloutVO.BenefitDetailItem>>();
            Integer j=1;
            for(Integer i=1;i<=benefitList.size();i++){
                itemList.add(benefitList[i-1]);
                if(itemList.size()==PAGE_SIZE){
                    benefitMap.put(j,itemList);
                    itemList=new List<HttpCalloutVO.BenefitDetailItem>();
                    if(i!=benefitList.size()){
                        j++;
                    }
                }else if(i==benefitList.size()){
                    benefitMap.put(j,itemList);
                }
            }
            benefitTotalPage=j;

            //Add by Manuel that customized union struct with two classes (start)
            List<HttpCalloutVO.UnionStructBenefitCombined> usBenefitCombinedItemList=new List<HttpCalloutVO.UnionStructBenefitCombined>();
            usBenefitCombinedMap=new Map<Integer,List<HttpCalloutVO.UnionStructBenefitCombined>>();
            Integer m=1;
            for(Integer n=1;n<=usBenefitCombinedList.size();n++){
                usBenefitCombinedItemList.add(usBenefitCombinedList[n-1]);
                if(usBenefitCombinedItemList.size()==PAGE_SIZE){
                    usBenefitCombinedMap.put(m,usBenefitCombinedItemList);
                    usBenefitCombinedItemList=new List<HttpCalloutVO.UnionStructBenefitCombined>();
                    if(n!=usBenefitCombinedList.size()){
                        m++;
                    }
                }else if(n==usBenefitCombinedList.size()){
                    usBenefitCombinedMap.put(m,usBenefitCombinedItemList);
                }
            }
            usBenefitCombinedTotalPage=m;
            //Add by Manuel that customized union struct with two classes (stop)

        }else if(selectedTab=='getFundTransaction'){
            List<HttpCalloutVO.PolicyFundHist> itemList=new List<HttpCalloutVO.PolicyFundHist>();
            fundTransactionMap=new Map<Integer,List<HttpCalloutVO.PolicyFundHist>>();
            Integer j=1;
            for(Integer i=1;i<=fundTransaction.size();i++){
                itemList.add(fundTransaction[i-1]);
                if(itemList.size()==PAGE_SIZE){
                    fundTransactionMap.put(j,itemList);
                    itemList=new List<HttpCalloutVO.PolicyFundHist>();
                    if(i!=fundTransaction.size()){
                        j++;
                    }
                }else if(i==fundTransaction.size()){
                    fundTransactionMap.put(j,itemList);
                }
            }
            fundTransactionTotalPage=j;
        }else if(selectedTab=='getCategoryBenefitDetail'){
            //Added by Nicole for getClinicVisits WS structure update in 20190730,referrence to Digital WS XML Specification v1.17.xlsx
            cBenefitMap=new Map<Integer,List<HttpCalloutVO.BenefitCategory>>();
            Integer benefitCount=0;
            Integer pageIndex=1;

            for(HttpCalloutVO.BenefitCategory category:this.benefitCategoryList){
                HttpCalloutVO.BenefitCategory temCategory=new HttpCalloutVO.BenefitCategory();
                temCategory.benefitList=new List<HttpCalloutVO.BenefitDetailItem>();
                temCategory.categoryCode=category.categoryCode;
                temCategory.categoryDescription=category.categoryDescription;

                for(HttpCalloutVO.BenefitDetailItem benefit:category.benefitList){
                    temCategory.benefitList.add(benefit);
                    benefitCount++;

                    if(benefitCount==PAGE_SIZE){
                        cBenefitMap.put(pageIndex,new List<HttpCalloutVO.BenefitCategory>{temCategory});
                        temCategory=new HttpCalloutVO.BenefitCategory();
                        temCategory.benefitList=new List<HttpCalloutVO.BenefitDetailItem>();
                        temCategory.categoryCode=category.categoryCode;
                        temCategory.categoryDescription=category.categoryDescription;
                        benefitCount=0;
                        pageIndex ++;
                    }
                }
                //Nicole_20190924_SPS-279
                cBenefitMap.put(pageIndex,new List<HttpCalloutVO.BenefitCategory>{temCategory});
            }
            usBenefitCombinedTotalPage=pageIndex;
        }
    }

    public void coverageprevPage(){
        coveragePage--;
        coveragehasNext=true;
        coveragehasPrev=false;
        if(coveragePage>1){
            coveragehasPrev=true;
        }
    }

    public void coveragenextPage(){
        coveragePage++;
        coveragehasPrev=true;
        coveragehasNext=false;
        if(coveragePage<coverageTotalPage){
            coveragehasNext=true;
        }
    }

    public void paymentprevPage(){
        paymentTranPage--;
        paymenthasNext=true;
        paymenthasPrev=false;
        if(paymentTranPage>1){
            paymenthasPrev=true;
        }
    }

    public void paymentnextPage(){
        paymentTranPage++;
        paymenthasPrev=true;
        paymenthasNext=false;
        if(paymentTranPage<paymentTrantotalPage){
            paymenthasNext=true;
        }
    }

    public void policyChangeprevPage(){
        policyChangePage--;
        policyChangehasNext=true;
        policyChangehasPrev=false;
        if(policyChangePage>1){
            policyChangehasPrev=true;
        }
    }

    public void policyChangenextPage(){
        policyChangePage++;
        policyChangehasPrev=true;
        policyChangehasNext=false;
        if(policyChangePage<policyChangetotalPage){
            policyChangehasNext=true;
        }
    }

    public void settlementprevPage(){
        settlementPage--;
        settlementhasNext=true;
        settlementhasPrev=false;
        if(settlementPage>1){
            settlementhasPrev=true;
        }
    }

    public void settlementnextPage(){
        settlementPage++;
        settlementhasPrev=true;
        settlementhasNext=false;
        if(settlementPage<settlementtotalPage){
            settlementhasNext=true;
        }
    }

    public void memberprevPage(){
        memberPage--;
        memberhasNext=true;
        memberhasPrev=false;
        if(memberPage>1){
            memberhasPrev=true;
        }
    }

    public void membernextPage(){
        memberPage++;
        memberhasPrev=true;
        memberhasNext=false;
        if(memberPage<membertotalPage){
            memberhasNext=true;
        }
    }

    public void benefitprevPage(){
        benefitPage--;
        benefithasNext=true;
        benefithasPrev=false;
        if(benefitPage>1){
            benefithasPrev=true;
        }
    }

    public void benefitnextPage(){
        benefitPage++;
        benefithasPrev=true;
        benefithasNext=false;
        if(benefitPage<benefittotalPage){
            benefithasNext=true;
        }
    }

    //Add by Manuel that customized union struct with two classes (start)
    public void usBenefitCombinedprevPage(){
        usBenefitCombinedPage--;
        usBenefitCombinedhasNext=true;
        usBenefitCombinedhasPrev=false;
        if(usBenefitCombinedPage>1){
            usBenefitCombinedhasPrev=true;
        }
    }

    public void usBenefitCombinednextPage(){
        usBenefitCombinedPage++;
        usBenefitCombinedhasPrev=true;
        usBenefitCombinedhasNext=false;
        if(usBenefitCombinedPage<usBenefitCombinedtotalPage){
            usBenefitCombinedhasNext=true;
        }
    }

    public void usBenefitCombinedPagingMethod(){
        usBenefitCombinedPage=1;
        usBenefitCombinedTotalPage=1;
        usBenefitCombinedhasPrev=false;
        usBenefitCombinedhasNext=false;

        /*Comment by Nicole for getClinicVisits WS structure update in 20190730,referrence to Digital WS XML Specification v1.17.xlsx
        if(usBenefitCombinedList.size()>PAGE_SIZE){
           usBenefitCombinedhasNext=true;
           setDeparateResultList('getUnionStructBenefitCombined');
        }else{
           usBenefitCombinedMap=new Map<Integer,List<HttpCalloutVO.UnionStructBenefitCombined>>();
           usBenefitCombinedMap.put(1,usBenefitCombinedList);
        }*/

        if(totalClinicCount>PAGE_SIZE){
            usBenefitCombinedhasNext=true;
            setDeparateResultList('getCategoryBenefitDetail');
        }else{
            cBenefitMap=new Map<Integer,List<HttpCalloutVO.BenefitCategory>>();
            cBenefitMap.put(1,benefitCategoryList);
        }
        //        system.debug('benefitCategoryList:'+benefitCategoryList);
    }
    //Add by Manuel that customized union struct with two classes (stop)

    public void fundTxprevPage(){
        fundTransactionPage--;
        fundTransactionhasNext=true;
        fundTransactionhasPrev=false;
        if(fundTransactionPage>1){
            fundTransactionhasPrev=true;
        }
    }

    public void fundTxnextPage(){
        fundTransactionPage++;
        fundTransactionhasPrev=true;
        fundTransactionhasNext=false;
        if(fundTransactionPage<fundTransactionTotalPage){
            fundTransactionhasNext=true;
        }

    }

    public void benefitPagingMethod(){
        benefitPage=1;
        benefitTotalPage=1;
        benefithasPrev=false;
        benefithasNext=false;
        if(benefitList.size()>PAGE_SIZE){
            benefithasNext=true;
            setDeparateResultList('getBenefitDetail');
        }else{
            benefitMap=new Map<Integer,List<HttpCalloutVO.BenefitDetailItem>>();
            benefitMap.put(1,benefitList);
        }
    }

    public void settlementPagingMethod(){
        settlementPage=1;
        settlementTotalPage=1;
        settlementhasPrev=false;
        settlementhasNext=false;
        if(premiumSettlementList.size()>PAGE_SIZE){
            settlementhasNext=true;
            setDeparateResultList('getPremiumSettlement');
        }else{
            settlementMap=new Map<Integer,List<HttpCalloutVO.PolicyBilling>>();
            settlementMap.put(1,premiumSettlementList);
        }
    }

    public void fundTransactionPagingMethod(){
        fundTransactionPage=1;
        fundTransactionTotalPage=1;
        fundTransactionhasPrev=false;
        fundTransactionhasNext=false;
        if(fundTransaction.size()>PAGE_SIZE){
            fundTransactionhasNext=true;
            setDeparateResultList('getFundTransaction');
        }else{
            fundTransactionMap=new Map<Integer,List<HttpCalloutVO.PolicyFundHist>>();
            fundTransactionMap.put(1,fundTransaction);
        }
    }

    public void paymentTranPagingMethod(){
        paymentTranPage=1;
        paymentTranTotalPage=1;
        paymenthasPrev=false;
        paymenthasNext=false;
        if(paymentTransactionList.size()>PAGE_SIZE){
            paymenthasNext=true;
            setDeparateResultList('getPaymentTransaction');
        }else{
            paymentTranMap=new Map<Integer,List<HttpCalloutVO.PolicyBilling>>();
            paymentTranMap.put(1,paymentTransactionList);
        }
    }

    public void coveragePagingMethod(){
        coveragePage=1;
        coverageTotalPage=1;
        coveragehasPrev=false;
        coveragehasNext=false;
        if(policyCoverageList.size()>PAGE_SIZE){
            coveragehasNext=true;
            setDeparateResultList('getPolicyCoverage');
        }else{
            coverageMap=new Map<Integer,List<HttpCalloutVO.PolicyPersonCoverage>>();
            coverageMap.put(1,policyCoverageList);
        }
        //        system.debug('coveragePagingMethod:'+coverageMap);
    }

    public void memberPagingMethod(){
        memberPage=1;
        memberTotalPage=1;
        memberhasPrev=false;
        memberhasNext=false;
        if(memberList.size()>PAGE_SIZE){
            memberhasNext=true;
            setDeparateResultList('getMemberList');
        }else{
            memberMap=new Map<Integer,List<HttpCalloutVO.Person >>();
            memberMap.put(1,memberList);
        }
    }

    public void policyChangePagingMethod(){
        policyChangePage=1;
        policyChangeTotalPage=1;
        policyChangehasPrev=false;
        policyChangehasNext=false;
        if(policyChangeList.size()>PAGE_SIZE){
            policyChangehasNext=true;
            setDeparateResultList('getPolicyChange');
        }else{
            policyChangeMap=new Map<Integer,List<HttpCalloutVO.WorkStatus>>();
            policyChangeMap.put(1,policyChangeList);
        }
    }

    private void paginationInit(){
        coveragePage=1;
        coverageTotalPage=1;
        coveragehasPrev=false;
        coveragehasNext=false;

        paymentTranPage=1;
        paymentTranTotalPage=1;
        paymenthasPrev=false;
        paymenthasNext=false;

        policyChangePage=1;
        policyChangeTotalPage=1;
        policyChangehasPrev=false;
        policyChangehasNext=false;

        claimPage=1;
        claimTotalPage=1;
        claimhasPrev=false;
        claimhasNext=false;

        settlementPage=1;
        settlementTotalPage=1;
        settlementhasPrev=false;
        settlementhasNext=false;

        memberPage=1;
        memberTotalPage=1;
        memberhasPrev=false;
        memberhasNext=false;

        benefitPage=1;
        benefitTotalPage=1;
        benefithasPrev=false;
        benefithasNext=false;

        //Add by Manuel that customized union struct with two classes
        usBenefitCombinedPage=1;
        usBenefitCombinedTotalPage=1;
        usBenefitCombinedhasPrev=false;
        usBenefitCombinedhasNext=false;

        fundTransactionPage=1;
        fundTransactionTotalPage=1;
        fundTransactionhasPrev=false;
        fundTransactionhasNext=false;

        //efulfillment enhanced added start
        groupDocMap=new Map <string,List<HttpCalloutVO.PolicyDocType> >();
        groupDocMapCount=new Map <string,Integer> ();
        curGroupDocList=new List<HttpCalloutVO.PolicyDocType>();
        curGrpCorDocList=new List<HttpCalloutVO.PolicyDocType>();
        pdfUrl='';
        //efulfillment enhanced added end
    }

    public List<SelectOption> getMemberSearchType(){
        //Category picklist
        List<SelectOption> options=new List<SelectOption>();
        options.add(new SelectOption('Member Name',System.Label.Pol_Member_Name));
        options.add(new SelectOption('Member Id',System.Label.Pol_Member_Cert_No));
        return options;
    }

    public List<SelectOption> getGroupClaimSearchType(){
        //Category picklist
        List<SelectOption> options=new List<SelectOption>();
        options.add(new SelectOption('Member Name',System.Label.Pol_Member_Name));
        options.add(new SelectOption('Member Id',System.Label.Pol_Member_Cert_No));
        return options;
    }

    public class ChartValue{
        public String label;
        public String percentageDisplay;
        public Decimal percentage;
        public Decimal total;
    }

    public class FundContribution{
        public String fundName{get;set;}
        public Decimal basicPercentage{get;set;}
        public Decimal regularPercentage{get;set;}
        public String basicPercentageDisplay{get;set;}
        public String regularPercentageDisplay{get;set;}
    }

    /*efulfillment start */
    public List<HttpCalloutVO.PolicyDocType> curGrpCorDocList{get;set;}
    public List<HttpCalloutVO.PolicyDocType> curCorDocList{get;set;}
    public List<HttpCalloutVO.PolicyDocType> corDocList{get;set;}

    /*policy document start */
    public List<HttpCalloutVO.PolicyDocType> curDocList{get;set;}
    public List<HttpCalloutVO.PolicyDocType> documentList{get;set;}

    // public List<HttpCalloutVO.PolicyDocType> claimDocList{get;set;}
    public Map <string,List<HttpCalloutVO.PolicyDocType> > corDocYearMap;
    public Map <string,List<HttpCalloutVO.PolicyDocType> > docYearMap;
    public List<SelectOption> yearList{get;set;}
    public String selectedYear{get;set;}
    public List<SelectOption> docYearList{get;set;}
    public String docSelectedYear{get;set;}
    public String targetAttachmentKey{get;set;}
    public Map <string,List<HttpCalloutVO.PolicyDocType> > groupDocMap{get;set;}
    public Map <string,Integer> groupDocMapCount{get;set;}
    public List<HttpCalloutVO.PolicyDocType> curGroupDocList{get;set;}
    public String pdfUrl{get;set;}
    public List<String> tempAttList{get;set;}
    public string tempAttID{get;set;}
    public string selectedAttID{get;set;}
    public List<String> indDocAttIDList{get;set;}
    public List<String> indDocsAttIDList{get;set;}
    public List<String> indCorsAttIDList{get;set;}
    public List<String> grpDocAttIDList{get;set;}

    // 20200706 - minghua - Cigna SME Package Plan - Vision Benefit
    public List<String> grpPCDocAttIDList{get;set;}
    public List<HttpCalloutVO.PolicyDocType> grpPCorDocList{get;set;}
    public List<HttpCalloutVO.PolicyDocType> pCorDocList{get;set;}
    public Map <String,List<HttpCalloutVO.PolicyDocType>> pCorDocYearMap{get;set;}
    public List<SelectOption> grpYearList{get;set;}
    public String grpSelectedYear{get;set;}

    public string downloadSitePrefix{
        get{
            // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
            // string prefix=Portal_Settings__c.getInstance().File_Download_URL__c;
            // prefix=prefix.split('servlet')[0] ;
            string prefix=Site.getBaseUrl()+'/';
            return prefix;
        }
        set;
    }
    public string curLang{
        get{
            return currentUser.LanguageLocaleKey;
        }
    }

    public void InitEfulfillment (){
        if(validateKey){
            //if(isCustomerUser&&(getFields2().get('Policy Correspondence').get('ILAS')||getFields2().get('Policy Correspondence').get('nonILAS')) ){  //Comment by Nicoel for DPSP-988
            //CR-55 enhance performance: call only for individual policy: getPolicyDocTypeList  2021-12-30 Zane
            if((getFields2().get('Policy Correspondence').get('ILAS')||getFields2().get('Policy Correspondence').get('nonILAS')) && !isGroup ){
                initCorDocList();
            }
        }
    }

    public void addGroupDocMap(string targetCertNo){

        if(planMap!=null&&planMap.size()>0&&getFields2().get('Policy Correspondence').get('Group')){

            //Nicole_20200331_Tax Statement Issue
            getPolicySSNNum();
            //List<HttpCalloutVO.PolicyDocType> tmpList=helper.getPolicyDocTypeList(policyNumber,false,'Policy Document',targetCertNo,'','','');
            List<HttpCalloutVO.PolicyDocType> tmpList=helper.getPolicyDocTypeList(policyNumber,false,'Policy Document',targetCertNo,'','','','',ssnNum);

            // 20200706 - minghua - Cigna SME Package Plan - Vision Benefit
            if(isGroup&&isCustomerUser){
                grpPCorDocList=new List<HttpCalloutVO.PolicyDocType>();
                grpPCorDocList=helper.getPolicyDocTypeList(policyNumber,false,'Policy Correspondence',targetCertNo,'','','','',ssnNum);
            }

            grpDocAttIDList=new List<String>();
            // Rancho_PI64_20220411 - enhance the code
            List<File_Store__c> fileList = new List<File_Store__c>();
            List<Attachment> attList = new List<Attachment>();
            for(HttpCalloutVO.PolicyDocType doctype:tmpList){
                File_Store__c fileStore=new File_Store__c();
                fileStore.OwnerId=UserInfo.getUserId();
                fileStore.Owner_id__c=UserInfo.getUserId();
                fileList.add(fileStore);
            }
            //insert file store
            if(!Test.isRunningTest()){
                insert fileList;
            }
            //insert attachment
            for(File_Store__c f : fileList){
                Attachment tatt = new Attachment();
                tatt.parentId=f.Id;
                tatt.contentType='application/pdf';
                tatt.name='tempDoc4Broker';
                tatt.body=Blob.valueOf('');
                attList.add(tatt);
            }
            if(!Test.isRunningTest()){
                insert attList;
            }
            for(Attachment a : attList){
                grpDocAttIDList.add(a.Id);
            }
            //List<HttpCalloutVO.PolicyDocType> tmpList=helper.getPolicyDocTypeList('CTM0048083',true,'Policy Document','','','','');
            groupDocMap.put (targetCertNo,tmpList);
            groupDocMapCount.put(targetCertNo,tmpList.size());
            System.debug(planMap.size()+' added pol:'+targetCertNo);
            System.debug(groupDocMap);

            // 20200706 - minghua - Cigna SME Package Plan - Vision Benefit
            if(isGroup&&isCustomerUser){
                grpPCDocAttIDList=new List<String>();
                // Rancho_PI79_20220921 - clear list to avoid vs page error
                pCorDocList=new List<HttpCalloutVO.PolicyDocType>();
                // Rancho_PI64_20220411 - enhance the code
                List<File_Store__c> cFileList = new List<File_Store__c>();
                List<Attachment> cAttList = new List<Attachment>();
                for(HttpCalloutVO.PolicyDocType doctype:grpPCorDocList){
                    File_Store__c fileStore=new File_Store__c();
                    fileStore.OwnerId=UserInfo.getUserId();
                    fileStore.Owner_id__c=UserInfo.getUserId();
                    cFileList.add(fileStore);
                }
                //insert file store
                if(!Test.isRunningTest()){
                    insert cFileList;
                }
                //insert attachment
                for(File_Store__c f : cFileList){
                    Attachment tatt = new Attachment();
                    tatt.parentId=f.Id;
                    tatt.contentType='application/pdf';
                    tatt.name='tempDoc4Broker';
                    tatt.body=Blob.valueOf('');
                    cAttList.add(tatt);
                }
                if(!Test.isRunningTest()){
                    insert cAttList;
                }
                for(Attachment a : cAttList){
                    grpPCDocAttIDList.add(a.Id);
                }
                InitPCorDocYearMap();
            }
        }
    }

    // 20200706 - minghua - Cigna SME Package Plan - Vision Benefit
    public void InitPCorDocYearMap(){
        Integer curYear=Date.today().year();
        pCorDocYearMap=new Map<String,List<HttpCalloutVO.PolicyDocType>>();
        pCorDocYearMap.put(String.valueOf(curYear),new List<HttpCalloutVO.PolicyDocType>());
        if(policy!=null&&policy.effDateInDate!=null){
            Integer effYear=policy.effDateInDate.year();
            if(pCorDocYearMap.get(String.valueof(effYear))==null){
                for(Integer i=effYear;i<curYear;i++){
                    if(pCorDocYearMap.get(String.valueOf(i))==null){
                        pCorDocYearMap.put(String.valueOf(i),new List<HttpCalloutVO.PolicyDocType>());
                    }
                }
            }
        }

        for(HttpCalloutVO.PolicyDocType d :grpPCorDocList){
            if(pCorDocYearMap.get(d.docCreatedYear)==null){
                List<HttpCalloutVO.PolicyDocType>  tmp=new List<HttpCalloutVO.PolicyDocType>();
                tmp.add(d);
                pCorDocYearMap.put(d.docCreatedYear,tmp);
            }else{
                pCorDocYearMap.get(d.docCreatedYear).add(d);
            }
        }

        List<String> temYearList=new List<String>();
        for(String year:pCorDocYearMap.keySet()){
            if(pCorDocYearMap.get(year).size()>0){
                temYearList.add(year);
            }
        }
        temYearList.sort();

        grpYearList=new List<SelectOption>();
        if(temYearList.size()>0){
            for(Integer i=temYearList.size()-1;i>=0;i--){
                grpYearList.add(new SelectOption(temYearList[i],temYearList[i]));
            }
        }

        if(grpPCorDocList.size()>0){
            grpSelectedYear=grpPCorDocList[0].docCreatedYear;
            switchPCorList();
        }
    }
    public void switchPCorList(){
        System.debug('###grpSelectedYear:'+grpSelectedYear);
        // System.debug('###pCorDocYearMap:'+pCorDocYearMap);
        // pCorDocList=pCorDocYearMap.get(grpSelectedYear);
        List<HttpCalloutVO.PolicyDocType> tempPCorDocList = pCorDocYearMap.get(grpSelectedYear);
        tempPCorDocList = tempPCorDocList == null ? new List<HttpCalloutVO.PolicyDocType>():tempPCorDocList;
        pCorDocList=tempPCorDocList;

        System.debug('###pCorDocList:'+pCorDocList);
    }

    public PageReference refreshGrpCor(){

        //Nicole_20200331_Tax Statement Issue
        getPolicySSNNum();
        //curGrpCorDocList=helper.getPolicyDocTypeList(policyNumber,false,'Policy Document',targetCertNo,'','','');
        curGrpCorDocList=helper.getPolicyDocTypeList(policyNumber,false,'Policy Document',targetCertNo,'','','','',ssnNum);

        tempAttList=new List<String>();
        // Rancho_PI64_20220411 - enhance the code
        List<File_Store__c> fileList = new List<File_Store__c>();
        List<Attachment> attList = new List<Attachment>();
        for(HttpCalloutVO.PolicyDocType doctype:curGrpCorDocList){
            File_Store__c fileStore=new File_Store__c();
            fileStore.OwnerId=UserInfo.getUserId();
            fileStore.Owner_id__c=UserInfo.getUserId();
            fileList.add(fileStore);
        }
        //insert file store
        if(!Test.isRunningTest()){
            insert fileList;
        }
        //insert attachment
        for(File_Store__c f : fileList){
            Attachment tatt = new Attachment();
            tatt.parentId=f.Id;
            tatt.contentType='application/pdf';
            tatt.name='tempDoc4Broker';
            tatt.body=Blob.valueOf('');
            attList.add(tatt);
        }
        if(!Test.isRunningTest()){
            insert attList;
        }
        for(Attachment a : attList){
            tempAttList.add(a.Id);
        }
        return null;
    }

    // Rancho_HKITSFDC130_20241126 - replace current year with policy doc year 
    public static List<SelectOption> getYearList(String createdYear, String policyDocYear) {
        // Integer currentYear = System.now().year();
        List<SelectOption> returnOwList = new List<SelectOption>();
        if(Integer.valueOf(createdYear) < (Integer.valueOf(policyDocYear) - 2)) {
            returnOwList.add(new SelectOption(createdYear, createdYear));

            for(Integer i = Integer.valueOf(policyDocYear) - 2; i <= Integer.valueOf(policyDocYear); i++){
                returnOwList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }else{
            for(Integer i = Integer.valueOf(createdYear); i <= Integer.valueOf(policyDocYear); i++){
                returnOwList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }
        return returnOwList;
    }

    public void initDocList() {
        documentList=new List<HttpCalloutVO.PolicyDocType>();
        helper=new PolicyCalloutHelper();

        //Nicole_20200331_Tax Statement Issue
        getPolicySSNNum();
        //corDocList=helper.getPolicyDocTypeList(policyNumber,true,'Policy Correspondence','','','','');
        if(policyType!='Group'){
            documentList = helper.getPolicyDocTypeList(policyNumber,true,'Policy Document','','','','','', currentUser.Account.SSN__c); 
        }else{
            documentList = helper.getPolicyDocTypeList(policyNumber,false,'Policy Document',targetCertNo,'','','','',ssnNum);
        }

        indDocsAttIDList=new List<String>();
        // Rancho_PI64_20220411 - enhance the code
        List<File_Store__c> fileList = new List<File_Store__c>();
        List<Attachment> attList = new List<Attachment>();
        for(HttpCalloutVO.PolicyDocType doctype:documentList){
            File_Store__c fileStore=new File_Store__c();
            fileStore.OwnerId=UserInfo.getUserId();
            fileStore.Owner_id__c=UserInfo.getUserId();
            fileList.add(fileStore);
        }
        //insert file store
        // if(!Test.isRunningTest()){
        //     insert fileList;
        // }
        //insert attachment
        for(File_Store__c f : fileList){
            Attachment tatt = new Attachment();
            tatt.parentId=f.Id;
            tatt.contentType='application/pdf';
            tatt.name='tempDoc4Broker';
            tatt.body=Blob.valueOf('');
            attList.add(tatt);
        }
        // if(!Test.isRunningTest()){
        //     insert attList;
        // }
        for(Attachment a : attList){
            indDocsAttIDList.add(a.Id);
        }
        InitDocYearMap();
    }

    public void InitDocYearMap(){
        Integer curYear=Date.today().year();
        docYearMap=new Map<string,List<HttpCalloutVO.PolicyDocType>>();
        Integer effYear = null == policy.effDateInDate ? curYear-2 : policy.effDateInDate.year();
        // Rancho_HKITSFDC130_20241126 - get policy doc year
        System.debug('check docYearList: ' + docYearList);
        System.debug('check policyDocList: ' + policyDocList);
        // for(SelectOption i: docYearList){
        //     List<HttpCalloutVO.PolicyDocType> tmp=new List<HttpCalloutVO.PolicyDocType>();
        //     for(HttpCalloutVO.PolicyDocType d :policyDocList){
        //         // Rancho_HKITSFDC70_20240802 - use initial date
        //         String docCreatedYear=String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : (String.isNotBlank(d.createdDateStr)?d.createdDateStr.substring(0,4):'NULL');
        //         if(docCreatedYear.equals(i.getLabel())) {
        //             tmp.add(d);
        //         }
        //     }
        //     docYearMap.put(i.getLabel(), tmp);
        // }
        Integer latestDocYear = effYear;
        for(HttpCalloutVO.PolicyDocType d : policyDocList){
            String docCreatedYear = String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : (String.isNotBlank(d.createdDateStr)?d.createdDateStr.substring(0,4):'NULL');
            if(Integer.valueOf(docCreatedYear) > latestDocYear){
                latestDocYear = Integer.valueOf(docCreatedYear);
            }
            // Rancho_HKITSFDC150_20250210 - document name starts with _INB belongs to inital year
            String processedDocName = String.isBlank(d.fileName) ? '' : d.fileName.substring(d.fileName.indexOf('_'));
            System.debug('processed doc name: '+processedDocName);
            if(String.isNotBlank(processedDocName) && processedDocName.startsWith('_INB')){
                docCreatedYear = String.valueOf(effYear);
            }
            if(!docYearMap.containsKey(docCreatedYear)){
                docYearMap.put(docCreatedYear, new List<HttpCalloutVO.PolicyDocType>{d});
            }else{
                docYearMap.get(docCreatedYear).add(d);
            }
        }
        docYearList=getYearList(String.valueOf(effYear), String.valueOf(latestDocYear));

        if(policyDocList.size()>0){
            // docSelectedYear=policyDocList[0].docCreatedYear;
            docSelectedYear = String.valueOf(latestDocYear);
            System.debug('Check docSelectedYear: ' + docSelectedYear);
            switchDocList();
        }

        System.debug('Check docYearMap: ' + docYearMap);
    }

    public void switchDocList(){

        // curDocList=docYearMap.get(docSelectedYear);

        List<HttpCalloutVO.PolicyDocType> tempCurDocList = docYearMap.get(docSelectedYear);
        tempCurDocList = tempCurDocList == null ? new List<HttpCalloutVO.PolicyDocType>():tempCurDocList;
        curDocList=tempCurDocList;

        System.debug('Check curDocList: ' + curDocList + ', ' + docSelectedYear);
    }

    public void initCorDocList(){
        corDocList=new List<HttpCalloutVO.PolicyDocType>();
        helper=new PolicyCalloutHelper();

        //Nicole_20200331_Tax Statement Issue
        getPolicySSNNum();
        //corDocList=helper.getPolicyDocTypeList(policyNumber,true,'Policy Correspondence','','','','');
        corDocList=helper.getPolicyDocTypeList(policyNumber,true,'Policy Correspondence','','','','','',ssnNum);

        // indCorsAttIDList=new List<String>();
        // // Rancho_PI64_20220411 - enhance the code
        // List<File_Store__c> fileList = new List<File_Store__c>();
        // List<Attachment> attList = new List<Attachment>();
        // for(HttpCalloutVO.PolicyDocType doctype:corDocList){
        //     File_Store__c fileStore=new File_Store__c();
        //     fileStore.OwnerId=UserInfo.getUserId();
        //     fileStore.Owner_id__c=UserInfo.getUserId();
        //     fileList.add(fileStore);
        // }
        // //insert file store
        // if(!Test.isRunningTest()){
        //     insert fileList;
        // }
        // //insert attachment
        // for(File_Store__c f : fileList){
        //     Attachment tatt = new Attachment();
        //     tatt.parentId=f.Id;
        //     tatt.contentType='application/pdf';
        //     tatt.name='tempDoc4Broker';
        //     tatt.body=Blob.valueOf('');
        //     attList.add(tatt);
        // }
        // if(!Test.isRunningTest()){
        //     insert attList;
        // }
        // for(Attachment a : attList){
        //     indCorsAttIDList.add(a.Id);
        // }
        InitCorDocYearMap();
    }

    public void InitCorDocYearMap(){
        Integer curYear=Date.today().year();
        corDocYearMap=new Map<string,List<HttpCalloutVO.PolicyDocType>>();
        Integer effYear= Test.isRunningTest() ? curYear : (null == policy.effDateInDate ? curYear-2 : policy.effDateInDate.year());
        // Rancho_HKITSFDC130_20241126 - get policy doc year
        // for(SelectOption i: yearList){
        //     List<HttpCalloutVO.PolicyDocType> tmp=new List<HttpCalloutVO.PolicyDocType>();
        //     for(HttpCalloutVO.PolicyDocType d :corDocList){
        //         // Rancho_HKITSFDC70_20240802 - use initial date
        //         String corCreatedYear=String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : (String.isNotBlank(d.createdDateStr)?d.createdDateStr.substring(0,4):'NULL');
        //         if(corCreatedYear.equals(i.getLabel())) {
        //             tmp.add(d);
        //         }
        //     }
        //     corDocYearMap.put(i.getLabel(), tmp);
        // }
        //Added by Nicole for DPSP-1063 end
        Integer latestDocYear = effYear;
        for(HttpCalloutVO.PolicyDocType d :corDocList){
            String docCreatedYear = String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : (String.isNotBlank(d.createdDateStr)?d.createdDateStr.substring(0,4):'NULL');
            if(Integer.valueOf(docCreatedYear) > latestDocYear){
                latestDocYear = Integer.valueOf(docCreatedYear);
            }
            if(!corDocYearMap.containsKey(docCreatedYear)){
                corDocYearMap.put(docCreatedYear, new List<HttpCalloutVO.PolicyDocType>{d});
            }else{
                corDocYearMap.get(docCreatedYear).add(d);
            }
        }
        yearList=getYearList(String.valueOf(effYear), String.valueOf(latestDocYear));

        if(corDocList.size()>0){
            // selectedYear=corDocList[0].docCreatedYear;
            selectedYear = String.valueOf(latestDocYear);
            switchCorList();
        }
    }

    public void switchCorList(){
        system.debug('###selectedYear:'+selectedYear);
        system.debug('###corDocYearMap:'+corDocYearMap);
        // curCorDocList=corDocYearMap.get(selectedYear);


        List<HttpCalloutVO.PolicyDocType> tempCurDocList = corDocYearMap.get(selectedYear);
        tempCurDocList = tempCurDocList == null ? new List<HttpCalloutVO.PolicyDocType>():tempCurDocList;
        curCorDocList=tempCurDocList;
        system.debug('###curCorDocList:'+curCorDocList);
    }

    public String selectedDowlAttId{get;set;}
    public String selectedDowlAttKey{get;set;}
    public String dlFileStoreId{get;set;}
    public void downloadDocument(){
        File_Store__c fileStore = new File_Store__c();
        fileStore.OwnerId = UserInfo.getUserId();
        fileStore.Owner_id__c = UserInfo.getUserId();
        insert fileStore;
        dlFileStoreId=fileStore.Id;
        //add by kermit
        String appName='';
        if(CignaUtil.isCustomerPortal()){
            appName=PolicyCalloutHelper.CUSTOMER_PORTAL_APPNAME;
        }else if(CignaUtil.isBrokerPortal()){
            appName=PolicyCalloutHelper.BROKER_PORTAL_APPNAME;
        }else if(CignaUtil.isCSUser()){
            appName=PolicyCalloutHelper.SERVICE_CONSOLE_APPNAME;
        }
        //add by kermit
        system.debug('selectedDowlAttId'+selectedDowlAttId);
        System.debug('selectedDowlAttKey'+selectedDowlAttKey);
        // HKITSFDC-438 - Update file download process
        // System.enqueueJob(new downloadDocQueue(policyNumber,selectedDowlAttKey,curLang,selectedDowlAttId,appName));
        System.enqueueJob(new downloadDocQueue(policyNumber, selectedDowlAttKey, curLang, '', '', '', dlFileStoreId));
    }

    public boolean isDownloadComplete{get;set;}
    public void checkIsDocumentDownloadComplete(){
        // HKITSFDC-438 - Update file download process
        isDownloadComplete=false;
        List<Attachment> aList = [SELECT Id, BodyLength FROM Attachment WHERE ParentId = :dlFileStoreId];
        if(aList != null && aList.size() > 0){
            selectedDowlAttId = aList[0].Id;
            isDownloadComplete=true;
        }
        // if(selectedDowlAttId!=null){
        //     Attachment a=[Select Id,Body From Attachment Where Id =:selectedDowlAttId];
        //     if(a.Body!=null){
        //         if(a.body.size()>0){
        //             isDownloadComplete=true;
        //         }
        //     }
        // }
    }

    /*
     public PageReference getDoc2(){
      // system.debug('targetAttachmentKey:'+targetAttachmentKey+' -- '+policyNumber+' -- '+TargetFileName);

           genDownloadURL();
         PageReference redirectPage=new PageReference(pdfUrl);
         redirectPage.setRedirect(false);
         return redirectPage;

         return getDocForMobile();
     }
    */
    /*
    public PageReference getDocForMobile(){
      genDownloadURL();

   //system.debug(tempAttID+' updated to '+targetatt.id);
      return null;

    }

    public void genDownloadURL(){
     HttpCalloutVO.PolicyDoc  policyDoc=new HttpCalloutVO.PolicyDoc();
        Blob theBlob;
        List<HttpCalloutVO.PolicyDoc> docList=new List<HttpCalloutVO.PolicyDoc>();
        if(policyNumber!=null&&policyNumber!=''){
           docList=helper.getPolicyDoc(policyNumber,targetAttachmentKey);
           if(!docList.isEmpty()&&docList.size()>0){
              policyDoc=docList.get(0);
           }
        }
        theBlob=EncodingUtil.base64Decode(policyDoc.attachmentData64Binary);
        Attachment tempAtt;
        if( string.isBlank(selectedAttID)){
          File_Store__c fileStore=new File_Store__c();
          fileStore.OwnerId=UserInfo.getUserId();
          fileStore.Owner_id__c=UserInfo.getUserId();
          Insert fileStore;
          tempAtt=new Attachment();
          tempAtt.parentId=fileStore.Id;
        }else{
           tempAtt=[select id,name,body from Attachment where id=:selectedAttID];
        }

        tempAtt.contentType='application/pdf';
        tempAtt.name=targetAttachmentKey;
        tempAtt.body=theBlob;
        upsert tempAtt;
          tempAttID=tempAtt.id;

        string downloadURL='/servlet/servlet.FileDownload?file='+tempAtt.Id+'&date='+system.Now().millisecondGmt();
        String mobileDownloadURL='/apex?downloadLink='+downloadURL;
        //pdfUrl=downloadURL;


        pdfUrl=Portal_Settings__c.getInstance().File_Download_URL__c+tempAtt.Id  ;
          system.debug ('pdfUrl:'+pdfUrl);

    }
    */
    /*efulfillment end */
    //CR-55 enhance performance:  init value in constructor  2021-12-30 Zane
    public boolean getIsGSUser(){
        
        return isGSUser;
    }

    // Nicole_20200331_Tax Statement Issue
    public void getPolicySSNNum(){
        ssnNum='';
        if(isCustomerUser){
            ssnNum=currentUser.account.ssn__c;
        }else{
            if(isGroup){
                // 20210105 - David - CR-55 Performance Tuning
                if(certNoSSNMap.isEmpty()){
                    if(memberList==null){
                        getMemberList();
                    }
                }
                if(certNoSSNMap.containsKey(targetCertNo)){
                    ssnNum=certNoSSNMap.get(targetCertNo);
                }
            }else{
                if(holder!=null&&String.isNotBlank(holder.ssnNumber)){
                    ssnNum=holder.ssnNumber;
                }
            }
        }
        //        System.debug('getPolicySSNNum ssnNum:'+ssnNum);
    }

    //BEGIN HKITSFDC-148 NOTE:TEMPORARY
    public void loadAltruistAdminProfileSet(){
        altruistAdminSet = new Set<Id>();
        Profile prf = [SELECT Id,Name FROM Profile WHERE Name IN ('Cigna Altruist Broker Admin') LIMIT 1];
        if(prf != null){
            altruistAdminSet.add(prf.Id);
        }
    }

    public Boolean getIsAltruistAdmin(){
        system.debug('>> getIsAltruistAdmin: '+userInfo.getProfileId());
        if(altruistAdminSet.contains(userInfo.getProfileId())){
            return true;
        }else{
            return false;
        }
    }
    
    public void initializeDateConstraints() {
        // Default values using TODAY
        Date today = Date.today();
        Date threeYearsAgo = today.addYears(-3);
        Date endOfYear = Date.newInstance(today.year(), 12, 31);
        
        // Initialize with default values
        fromDateMin = threeYearsAgo;
        fromDateMax = today;
        toDateMin = threeYearsAgo;
        toDateMax = endOfYear;
        
        // Apply special logic for Monthly payment method
        if (payment != null && payment.paymentMethod == 'Monthly' && payment.paidToDateInDate != null) {
            Date paidToDate = payment.paidToDateInDate;
            Date paidToDateMinus3Years = paidToDate.addYears(-3);
            Date paidToDateEndOfYear = Date.newInstance(paidToDate.year(), 12, 31);
            
            fromDateMin = paidToDateMinus3Years;
            fromDateMax = paidToDate;
            toDateMin = paidToDateMinus3Years;
            toDateMax = paidToDateEndOfYear;
        }
    }
    //END HKITSFDC-148
}