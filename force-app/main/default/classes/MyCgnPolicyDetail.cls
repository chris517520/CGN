/**
 * @description       : policy detail rest resource for MyCinga React Native project 
 * @author            : jackshao@deloitte.com.cn
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : Ardbert.Wang
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   06-01-2023   jackshao@deloitte.com.cn   Initial Version
**/
@RestResource(urlMapping='/policyDetail/*')
global with sharing class MyCgnPolicyDetail {
    public static final String POLICY_INFORMATION = 'policy_information';
    public static final String COVERAGE_INFORMATION = 'coverage_information';
    public static final String PAYMENT_INFORMATION = 'payment_information';
    public static final String CLAIM_HISTORY = 'claim_history';//jack
    public static final String POLICY_CHANGE_HISTORY = 'policy_change_history';//Rancho
    // public static final String PREMIUM_SETTLEMENT = 'premium_settlement';
    // public static final String MEMBER_LIST = 'member_list';
    public static final String BENEFIT_SCHEDULE = 'benefit_schedule';//jack
    public static final String REMAINING_CLINIC_VISITS = 'remaining_clinic_visits';
    public static final String REMAINING_INPATIENT_VISITS = 'remaining_inpatient_visits';//Rancho

    public static final String MAKE_A_CLAIM_BUTTON = 'Make_a_Claim_Button';
    public static final String MAKE_A_CHANGE_IN_POLICY = 'Make_a_Change_in_Policy';
    public static final String APPLY_ADMISSION_PREAPPROVAL_BUTTON = 'Apply_Admission_PreApproval_Button';
    public static final String DDA_FORM_BUTTON = 'DDA_Form_Button';
    public static final String FAKE_PLAN_NAME = 'FAKE';
    public static final String sectionType_Basic = 'Basic';
    public static final String sectionType_ASO = 'ASO';
    public static final String sectionType_TopUp = 'Top-up';
    public static List<String> polChangeOptionList = new List<String>{Label.Pol_Claim_All, Label.Processing, Label.Request_Completed, Label.Processed, Label.Pending_Information};

    public static PolicyCalloutHelper helper{ 
        get{
            if(helper ==null){
                helper = new PolicyCalloutHelper(); 
            }
            return helper;
        }
        set; 
    }

    public static Set<String> statusCodeSet{
        get{
            if(statusCodeSet == null){
                statusCodeSet=new Set<String>();
                List<Policy_Status_Mapping__c> psmList=[select id,PolicyCode__c,PolicyStatus__c from Policy_Status_Mapping__c where PolicyStatus__c ='Lapsed'];
                for(Policy_Status_Mapping__c psm:psmList){
                    statusCodeSet.add(psm.PolicyCode__c);
                }
            }
            return statusCodeSet;
        }
        set;
    }
    public static User user{
        get{
            if(user == null){
                user = [SELECT Account.SSN__c, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
            }
            return user;
        }
        set;
    }
    public class PolicyWrapper{
        HttpCalloutVO.Policy policy;
        HttpCalloutVO.Person holder;
        HttpCalloutVO.PolicyPayment payment;
        List<HttpCalloutVO.Person> insuredList;
        List<HttpCalloutVO.Person> beneficiaryList;    
        List<HttpCalloutVO.PolicyDocType> polDocList;
        List<HttpCalloutVO.PolicyDocType> polCorList;
        List<HttpCalloutVO.PolicyPersonCoverage> policyCoverageList;
        List<HttpCalloutVO.PolicyBilling> policyBillingList;
        List<HttpCalloutVO.Claim> claimList;
        List<HttpCalloutVO.WorkStatus> policyChangeList;
        List<OptionWrapper> workOptionList;
        List<OptionWrapper> docOptionList;
        List<OptionWrapper> corOptionList;
        List<HttpCalloutVO.Person> grpMemberList;
        Map<String, List<HttpCalloutVO.BenefitCategory>> grpVisitMap;
        Map<String,List<HttpCalloutVO.PolicyDocType>> groupDocMap;
        Map<String,List<HttpCalloutVO.PolicyDocType>> docMap;
        Map<String,List<HttpCalloutVO.PolicyDocType>> corMap;
        Map<String,Integer> groupDocMapCount;
        Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> planMap;
        Map<String, HttpCalloutVO.Person> groupMemberMap;
        HttpCalloutVO.PolicyPersonCoverage benefitScheduleInfo;
        Map<String,Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>> GSPlanMap;
        List<HttpCalloutVO.PolicyDocType> curGroupDocList;
        Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> effStsMap;
        List<HttpCalloutVO.Person> userPlanList;
        Map<String, String> certNoSSNMap;

        Integer totalClaimRecords;
        Boolean over90Days=false;      
        Boolean showDeductible=false;
        Boolean showAFCcolumns=false;
        Boolean showSumInsured=true;
        Boolean showApplyForGOPBtn=false;
        String docCertNo;
        Boolean isGSUser = false;
        Boolean displayInCert = false;
        Boolean curUserIsInactive = false;
        String insuranceCertId;
        String insuranceCertBody;
        Boolean displayOtherProductDoc = false;

        List<String> attIdList;
        List<String> docAttIdList;
        List<String> corAttIdList;
        List<String> tabList;
        List<String> buttonList;
        List<String> docYearList;
    }

    public class OptionWrapper{
        String key;
        String value;
        // Rancho_HKITSFDC130_20241126 - constructor
        public OptionWrapper(String key, String value){
            this.key = key;
            this.value = value;
        }
    }

    public class PolicyChange{ 
        public String policyChangeId{get;set;}
        public String policyChangeDate{get;set;}
        public String policyNo{get;set;} 
        public String policyChangeType{get;set;}
        public String status{get;set;}// for status filter
        public String displayStatus{get;set;} // for record status displaying
        public String policyHolderName{get;set;}
        public String policyHolderId{get;set;}
        public String changedContent{get;set;}
    }

    public class Response{
        public String status{get;set;}{status='error';}
        public List<Object> data; // ResponseBody
        public String message;
        public String eSign;
    }

    @HttpPost
    global static void policyDetail() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody?.toString();
        Map<String, Object> reqMap;
        if(String.isNotBlank(requestBody)){
            reqMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        }
        Response result=new Response();
        String reqUrl=RestContext.request.requestURI;
        try{ 
            if(reqUrl.equalsIgnoreCase('/policyDetail/searchAll')){
                List<Object> polList = searchAll();
                result.data = polList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/removePolicy')){
                deletePolicy(reqMap);
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getAllPolChangeRecord')){
                List<Object> polChangeList = getAllPolChangeRecord();
                result.data = polChangeList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/removeChangeRecord')){
                removeChangeRecord(reqMap);
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getPolicyInfo')){
                List<Object> polList = getPolicyInfo(reqMap);
                result.data = polList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getPolicyChangeList')){
                List<Object> pcList = getPolicyChangeList(reqMap);
                result.data = pcList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getPolicyChangeListByStatus')){
                List<Object> pcList = getPolicyChangeListByStatus(reqMap);
                result.data = pcList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getClinicVisitByCertNo')){
                List<Object> clinicList = getClinicVisitByCertNo(reqMap);
                result.data = clinicList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getCoverageInfo')){
                List<Object> covList = getPolicyPersonCoverageBasic(reqMap);
                result.data = covList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getBillingInfo')){
                List<Object> billList = getPolicyBillingListBasic(reqMap);
                result.data = billList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getClaimHistory')){
                List<Object> claimList = getPolicyClaimHistory(reqMap);
                result.data = claimList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getBenefitScheduleByCertNo')){
                List<Object> benefitList = getSpecificBenefitSchedule(reqMap);
                result.data = benefitList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getAttachment')){
                System.debug('get attachment: '+reqMap);
                List<Object> attList = getAttachment(reqMap);
                result.data = attList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getPolicyList')){
                List<Object> polList = getPolicyList();
                result.data = polList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getChangeRecordPI')){
                List<Object> resultList = getChangeRecordPI(reqMap);
                result.data = resultList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getAttBody')){
                List<Object> resultList = new List<object>{getAttBody(reqMap)};
                result.data = resultList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/checkIsDocumentDownloadComplete')){
                List<Object> resultList = new List<object>{checkIsDocumentDownloadComplete(reqMap)};
                result.data = resultList;
            }else if(reqUrl.equalsIgnoreCase('/policyDetail/getMedicalCardAction')){
                List<Object> resultList = new List<object>{getMedicalCardAction()};
                result.data = resultList;
            }
            else if(reqUrl.equalsIgnoreCase('/policyDetail/getPolicyBillingListTable')){
                String policyNumber = (String) reqMap.get('policyNumber');
                String dateFrom = (String) reqMap.get('dateFrom');
                String dateTo = (String) reqMap.get('dateTo');
                
                List <HttpCalloutVO.PolicyBilling> billingList = getPolicyBillingListTable(policyNumber, dateFrom, dateTo);
                result.data=(List<Object>) billingList;
            }

            result.status = 'success';
        }catch(Exception e){
            system.debug(e.getStackTraceString());
            system.debug(e.getMessage());
            result.message = e.getMessage();
        }
        res.statusCode=200;
        res.responseBody=Blob.valueOf(JSON.serialize(result));
    }

    /********************************************************************
     * @decs get policy information when init individual policy detail page
     * @param     Map<String, Object> reqMap    request params map
     * @return    List<PolicyWrapper>           policy
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<PolicyWrapper> getPolicyInfo(Map<String, Object> reqMap){
        PolicyWrapper wrap = new PolicyWrapper();
        if(null != reqMap){
            String polNo = (String)reqMap.get('polNo'); // policy number
            String polType = (null == reqMap.get('polType') || '' == reqMap.get('polType')) ? 'Group' : (String)reqMap.get('polType'); // group/ILAS...
            Boolean isILAS = 'ILAS'.equalsIgnoreCase(polType);

            System.debug('policy number: '+polNo);
            System.debug('policy type: '+polType);
            if(String.isNotBlank(polNo)){

                if(!'Group'.equalsIgnoreCase(polType)){
                    // 1. get policy basic info
                    wrap.policy = getPolicyBasic(polNo);
                    
                    // MRP-281 - detect inforce elite360 and current user is policy holder
                    List<String> prodCodeList = Custom_Value__c.getInstance('Elite 360 Product Code').Value__c?.split(';');
                    //String prodCode = Custom_Value__c.getInstance('Elite 360 Product Code').Value__c;
                    if(prodCodeList.contains(wrap.policy?.productCode)&&wrap.policy?.policyStatusCode=='1'&&user.Account.SSN__c==wrap.policy?.holder.ssnNumber){
                        wrap.displayOtherProductDoc = true;
                    }
                    // 2. ind policy could not submit claim if inactive days over 90 days
                    List<HttpCalloutVO.Policy> tempPolList = helper.getIndividualPolicyListBasicByCriteria(polNo,'','','','','');
                    if(null != tempPolList && !tempPolList.isEmpty()){
                        Integer inactiveDays = tempPolList[0].inactiveDays;
                        System.debug('inactive days checking: '+inactiveDays);
                        if(null != inactiveDays && inactiveDays >= 90){
                            wrap.over90Days = true;
                        }
                    }

                    // 3. get policy payment info
                    List<HttpCalloutVO.PolicyPayment> tempPayList = helper.getPolicyPaymentBasic(polNo);
                    if(null != tempPayList && !tempPayList.isEmpty()){
                        wrap.payment = tempPayList[0];
                    }

                    // 4. get policy holder info
                    HttpCalloutVO.Person holder = new HttpCalloutVO.Person();
                    List<HttpCalloutVO.Person> tempHoldList = helper.getPolicyHolderListBasic(polNo);
                    if(null != tempHoldList && !tempHoldList.isEmpty()){
                        holder = tempHoldList[0];

                        if(String.isNotBlank(holder.ssnNumber)){
                            PersonCalloutHelper pcHelper=new PersonCalloutHelper();
                            List<HttpCalloutVO.Person> pList = pcHelper.getPersonBasic(holder.ssnNumber);
                            if(null != pList && !pList.isEmpty()){
                                holder.homePhoneNo = pList[0].homePhoneNo;
                                holder.businessPhoneNo = pList[0].businessPhoneNo;
                                holder.mobilephoneNo = pList[0].mobilePhoneNo;
                                if(String.isBlank(holder.emailAddress)){holder.emailAddress = pList[0].emailAddress;}
                            }

                            /* if(isILAS){
                                RPQFormController.RPQInfo rpq = RPQFormController.getLatestStatusAndEffetiveDate(holder.ssnNumber);
                                if(null != rpq){
                                    holder.rPQStatus = rpq.status;
                                    holder.rPQEffectiveDate = rpq.effectiveDate;
                                }
                                wrap.beneficiaryList = helper.getPolicyBeneficiaryListBasic(polNo);
                            }  */
                        }
                        wrap.holder = holder;
                    }

                    // 5. get policy person insured info
                    wrap.insuredList = helper.getPolicyInsuredListBasic(polNo, true);

                    // 6. get policy document and policy correspondence list
                    
                    // wrap.docAttIdList = createTempAtt(wrap.docMap.values());
                    // wrap.corAttIdList = createTempAtt(wrap.corMap.values());

                    // 7. check IPMI policy and set variable to control the button/field display
                    if(IPMISettingUtil.isIPMIPolicy(wrap.policy)){
                        wrap.showSumInsured = false;
                        wrap.showApplyForGOPBtn = true;
                    }
                    if(IPMISettingUtil.isIPMITopUpPolicy(wrap.policy)||IPMISettingUtil.isGAOPPolicy(wrap.policy)||IPMISettingUtil.isLHBPolicy(wrap.policy)){
                        wrap.showSumInsured = IPMISettingUtil.isDisplaySumInsured(wrap.policy);
                        wrap.showApplyForGOPBtn = IPMISettingUtil.isEnableApplyForAOP(wrap.policy);
                    }
                }else{
                    wrap = getBenefitSchedule(reqMap);
                }
            }
        }
        return new List<PolicyWrapper>{wrap};
    }

    // Rancho_HKITSFDC130_20241126 - replace current year with policy doc year 
    public static List<OptionWrapper> getYearList(String createdYear, String policyDocYear) {
        // Integer currentYear = System.now().year();
        List<OptionWrapper> returnOwList = new List<OptionWrapper>();
        // Rancho_HKITSFDC70_20240802 - avoid duplicate values
        if (Integer.valueOf(createdYear) < (Integer.valueOf(policyDocYear) - 2)) {
            returnOwList.add(new OptionWrapper(createdYear, createdYear));

            for (Integer i = Integer.valueOf(policyDocYear) - 2; i <= Integer.valueOf(policyDocYear); i++) {
                returnOwList.add(new OptionWrapper(String.valueOf(i), String.valueOf(i)));
            }
        }else{
            for (Integer i = Integer.valueOf(createdYear); i <= Integer.valueOf(policyDocYear); i++) {
                returnOwList.add(new OptionWrapper(String.valueOf(i), String.valueOf(i)));
            }
        }

        return returnOwList;
    }

    /**
    * @description get attachment by pol num and pol type
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    * @return List<PolicyWrapper> 
    **/
    public static List<PolicyWrapper> getAttachment(Map<String, Object> reqMap){
        String polNo = (String)reqMap.get('polNo'); // policy number
        String polType = (null == reqMap.get('polType') || '' == reqMap.get('polType')) ? 'Group' : (String)reqMap.get('polType'); // group/ILAS...
        String nbYear = (String)reqMap.get('nbYear');
        PolicyWrapper wrap = new PolicyWrapper();
        Map<String, Map<String, Boolean>> fields2 = getSettingMap();
        String ssnNum;
        Map<String, HttpCalloutVO.Person> memberMap;
        String targetCertNo;
        if(polType=='Group'){
            Object tempMap = reqMap.get('groupMemberMap');
            memberMap = polType=='Group' && tempMap == null? getGroupMemberBasic(polNo) : (Map<String, HttpCalloutVO.Person>)JSON.deserializeStrict(JSON.serialize(tempMap),Map<String, HttpCalloutVO.Person>.class);
            Map<String, String> certMap = new Map<String,String>();
            for(HttpCalloutVO.Person p : memberMap.values()){
                certMap.put(p.certificateNo,p.ssnNumber);
            }
            targetCertNo = String.isBlank(String.valueOf(reqMap.get('certNo')))?memberMap.get('EMPLOYEE').certificateNo:String.valueOf(reqMap.get('certNo'));
            wrap.docCertNo = targetCertNo;
            ssnNum = certMap.get(targetCertNo);
        }
        
        List<HttpCalloutVO.PolicyDocType> docList;
        if(fields2.get('Policy Doc').get(polType)){
            
            if(polType!='Group'){
                docList = helper.getPolicyDocTypeList(polNo,true,'Policy Document','','','','','', user.Account.SSN__c); // docList = helper.getPolicyDocTypeList(polNo,true,'Policy Document','','','','','', user.Account.SSN__c); // docList = helper.getPolicyDocTypeList(polNo,'', user.Account.SSN__c)
            }else{
                docList = helper.getPolicyDocTypeList(polNo,false,'Policy Document',targetCertNo,'','','','',ssnNum);
            }
            // Rancho_HKITSFDC130_20241126 - get policy doc year
            String latestDocYear = nbYear;
            for(HttpCalloutVO.PolicyDocType d : docList){
                String docYear = String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : d.docCreatedYear;
                if(Integer.valueOf(docYear) > Integer.valueOf(latestDocYear)){
                    latestDocYear = docYear;
                }
            }
            wrap.docOptionList = getYearList(nbYear, latestDocYear); // new List<OptionWrapper>(); // getYearList(nbYear);
            wrap.docMap = getFileYearOption(docList, wrap.docOptionList, nbYear, 'Policy Document'); // Rancho_HKITSFDC150_20250210 - document name starts with _INB belongs to inital year
            // for(String s : wrap.docMap.keySet()){
            //     OptionWrapper op = new OptionWrapper();
            //     op.key = op.value = s;
            //     wrap.docOptionList.add(op);
            // }
            System.debug('docMap: ' + wrap.docMap);
            System.debug('docOptionList: ' + wrap.docOptionList);
        }
        List<HttpCalloutVO.PolicyDocType> corList;
        if(fields2.get('Policy Correspondence').get(polType)){
            if(polType!='Group'){
                corList= helper.getPolicyDocTypeList(polNo,true,'Policy Correspondence','','','','','',user.Account.SSN__c);
            }else{
                corList = helper.getPolicyDocTypeList(polNo,false,'Policy Correspondence',targetCertNo,'','','','',ssnNum);
            }
            // Rancho_HKITSFDC130_20241126 - get policy doc year
            String latestDocYear = nbYear;
            for(HttpCalloutVO.PolicyDocType d : corList){
                String docYear = String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : d.docCreatedYear;
                if(Integer.valueOf(docYear) > Integer.valueOf(latestDocYear)){
                    latestDocYear = docYear;
                }
            }
            wrap.corOptionList = getYearList(nbYear, latestDocYear); // new List<OptionWrapper>();
            wrap.corMap = getFileYearOption(corList, wrap.corOptionList, nbYear, 'Policy Correspondence'); // Rancho_HKITSFDC150_20250210 - document name starts with _INB belongs to inital year
            // for(String s : wrap.corMap.keySet()){
            //     OptionWrapper op = new OptionWrapper();
            //     op.key = op.value = s;
            //     wrap.corOptionList.add(op);
            // }
            System.debug('corMap: ' + wrap.corMap);
            System.debug('corOptionList: ' + wrap.corOptionList);
        }
        
        wrap.docAttIdList = createTempAtt(docList);
        wrap.corAttIdList = createTempAtt(corList);
        
        return new List<PolicyWrapper>{wrap};
    }
    /********************************************************************
     * @decs get ws policy change list
     * @param     Map<String, Object> reqMap    request map
     * @return    List<PolicyWrapper>           policy change status select options / ws policy change list
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<PolicyChange> getPolicyChangeList(Map<String, Object> reqMap){
        List<PolicyChange> polChangeList = new List<PolicyChange>();
        if(null != reqMap){
            String polNo = (String)reqMap.get('polNo');

            // wrap.workOptionList = new List<OptionWrapper>();
            // for(String s : polChangeOptionList){
            //     OptionWrapper op = new OptionWrapper();
            //     op.key = op.value = s;
            //     wrap.workOptionList.add(op);
            // }

            if(String.isNotBlank(polNo)){
                // wrap.policyChangeList = new List<HttpCalloutVO.WorkStatus>();
                // MR-709 missing changese policy change
                for(Policy_Change_Request__c temp : [SELECT Id, Policy_No__c, toLabel(RecordType.Name), RecordType.DeveloperName, Policy_Holder_Name__c, Policy_Holder_Id__c, toLabel(Status__c), LastModifiedDate FROM Policy_Change_Request__c WHERE Policy_No__c =:polNo and OwnerId=:UserInfo.getUserId() AND Status__c='Not Submitted' AND RecordType.Name!='Fund Management' AND RecordType.Name!='Fund Switching' AND RecordType.Name!='Fund Reallocation' AND RecordType.Name!='Fund Withdrawal' ORDER BY LastModifiedDate DESC]){
                    PolicyChange pc = new PolicyChange();
                         
                    pc.policyChangeId = temp.Id;
                    pc.policyChangeDate = temp.LastModifiedDate.format('dd/MM/yyyy');
                    pc.policyNo = temp.Policy_No__c;
                    pc.policyChangeType = temp.RecordType.Name;
                    pc.status = 'Draft';
                    pc.displayStatus = System.Label.Draft;
                    pc.policyHolderName =temp.Policy_Holder_Name__c;
                    pc.policyHolderId =temp.Policy_Holder_Id__c;
                    pc.changedContent = temp.RecordType.Name;
                    
                    polChangeList.add(pc);
                    system.debug('polChangeList:'+polChangeList);
                }
                WorkCalloutHelper wHelper = new WorkCalloutHelper();
                List<HttpCalloutVO.WorkStatus> tempList = wHelper.getWorkStatus(polNo, 'Policy Change Request', null, null);
                
                // Rancho_MR956_20231219 - hide invalid policy change type
                List<String> invalidTypeList = Label.Invalid_Policy_Change_Type.split(';');
                for(HttpCalloutVO.WorkStatus work : tempList){
                    if(null != invalidTypeList && invalidTypeList.contains(work.workType)){
                        continue;
                    }

                    PolicyChange p = new PolicyChange();
                    if(work.requestStatus == 'Pending' || work.requestStatus == 'Pending Information'){
                        p.status = 'Pending';
                        p.displayStatus = System.Label.Pol_Pending_for_Information;
                    }else if(work.requestStatus == 'Processing'){
                        p.status = 'Processing';
                        p.displayStatus = System.Label.Processing;
                    // Rancho_MR422_20231220 - status update
                    }else if(work.requestStatus == 'Completed' || work.requestStatus == 'Processed' || work.requestStatus == 'Request Closed'){
                        p.status = 'Completed';
                        p.displayStatus = System.Label.Completed;
                    }else if(work.requestStatus == 'Request Terminated' || work.requestStatus == 'Request Cancelled'){
                        p.status = 'Cancel';
                        p.displayStatus = System.Label.Cancel;
                    }else{
                        p.status = work.requestStatus;
                        p.displayStatus = work.requestStatus;
                    }

                    p.PolicyNo = work.policyNumber;
                    p.PolicyChangeType = work.salesForceWorkType;
                    p.PolicyChangeDate = work.submittedDateTime.format('dd/MM/yyyy');
                    p.changedContent = work.caseWorkItem;

                    polChangeList.add(p);
                }
                system.debug('after add work:'+polChangeList);
            }
        }
        system.debug('final list:'+polChangeList);
        return polChangeList;
    }

    /********************************************************************
     * @decs get filtered ws policy change list by status
     * @param     Map<String, Object> reqMap        request map
     * @return    List<HttpCalloutVO.WorkStatus>    filtered ws policy change list
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<HttpCalloutVO.WorkStatus> getPolicyChangeListByStatus(Map<String, Object> reqMap){
        List<HttpCalloutVO.WorkStatus> filteredList = new List<HttpCalloutVO.WorkStatus>();
        if(null != reqMap){
            List<HttpCalloutVO.WorkStatus> allList = (List<HttpCalloutVO.WorkStatus>)JSON.deserializeStrict(JSON.serialize(reqMap.get('policyChangeList')),List<HttpCalloutVO.WorkStatus>.class);
            String workStatus = (String)reqMap.get('workStatus');

            if(String.isBlank(workStatus) || workStatus == 'All'){
                filteredList = allList;
            }else{
                for(HttpCalloutVO.WorkStatus w : allList){
                    if(w.requestStatus == workStatus){
                        filteredList.add(w);
                    }
                }
            }
        }
        return filteredList;
    }

    /********************************************************************
     * @decs get clinic visit by cert number
     * @param     Map<String, Object> reqMap    request map
     * @return    List<PolicyWrapper>           group member list / ws clinic visit list
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<PolicyWrapper> getClinicVisitByCertNo(Map<String, Object> reqMap){
        PolicyWrapper wrap = new PolicyWrapper();
        if(null != reqMap){
            String polNo = (String)reqMap.get('polNo');
            String tabType = (String)reqMap.get('tabType');

            if(String.isNotBlank(polNo)){
                Map<String, HttpCalloutVO.Person> tempMap = getGroupMemberBasic(polNo);
                if(null != tempMap && !tempMap.isEmpty()){
                    // wrap.grpMemberList = tempMap.values();
                    wrap.grpMemberList = new List<HttpCalloutVO.Person>();
                    // get clinic / patient visit for every member
                    Map<String, List<HttpCalloutVO.BenefitCategory>> beMap = new Map<String, List<HttpCalloutVO.BenefitCategory>>();
                    Integer count = 0;
                    for(HttpCalloutVO.Person p : tempMap.values()){
                        if(String.isNotBlank(p.certificateNo)){
                            wrap.grpMemberList.add(p);
                            List<HttpCalloutVO.ClinicVisit> clinicVisitList = new List<HttpCalloutVO.ClinicVisit>();
                            clinicVisitList = helper.getClinicVisitCount(polNo, user.Account.SSN__c, p.certificateNo);
                            system.debug('clinicVisitList:'+clinicVisitList);
                            // display different list depend on selected tab type
                            if(!clinicVisitList.isEmpty() && clinicVisitList.size()>0){
                                for(HttpCalloutVO.BenefitCategory bc : clinicVisitList[0].benefitCategoryList){
                                    bc.benefitList.sort();
                                    
                                    for(Integer i = 0; i < bc.benefitList.size(); i++){   
                                        if(tabType.contains('clinic')){
                                            if(bc.benefitList[i].benefitSectionCode != 'OPB'){
                                                bc.benefitList.remove(i);
                                                i--;
                                            }
                                        }else{
                                            if(bc.benefitList[i].benefitSectionCode != 'HOS'){
                                                bc.benefitList.remove(i);
                                                i--;
                                            }
                                        }     
                                    }
                                }
                                beMap.put(p.certificateNo, clinicVisitList[0].benefitCategoryList);
                            }
                        }
                        if(++count>50){
                            break;
                        }
                    }
                    wrap.grpVisitMap = beMap;
                }
            }
        }
        return new List<PolicyWrapper>{wrap};
    }

    /********************************************************************
     * @decs get ws policy person list info
     * @param     String polNo                         policy number
     * @return    Map<String, HttpCalloutVO.Person>    ws policy person list info
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static Map<String, HttpCalloutVO.Person> getGroupMemberBasic(String polNo){
        Map<String, HttpCalloutVO.Person> groupMemberMap = new Map<String, HttpCalloutVO.Person>();
        
        List<HttpCalloutVO.Person> personList = helper.getPolicyPersonListBasicByCriteria(polNo,'','','',user.Account.SSN__c);
        if(null != personList && personList.size() > 0){
            Integer childIndex = 1;
            Integer spouseIndex = 1;
            for(HttpCalloutVO.Person p : personList){
                if(p.insurableInterestReason.equalsIgnoreCase('EMPLOYEE')){
                    p.index=1;
                    groupMemberMap.put('EMPLOYEE',p);
                }else if(p.insurableInterestReason.equalsIgnoreCase('SPOUSE')){
                    p.index=spouseIndex;
                    if(spouseIndex>1){
                        groupMemberMap.put('SPOUSE '+spouseIndex,p);
                    }else{
                        groupMemberMap.put('SPOUSE',p);
                    }
                    spouseIndex++;
                }else if(p.insurableInterestReason.equalsIgnoreCase('CHILD')){
                    p.index=childIndex;
                    if(childIndex > 1){
                        groupMemberMap.put('CHILD '+childIndex,p);
                    }else{
                        groupMemberMap.put('CHILD',p);
                    }
                    childIndex++;
                }
            }
        }
        return groupMemberMap;
    }

    /********************************************************************
     * @decs create temp file
     * @param     List<HttpCalloutVO.PolicyDocType> docList    ws policy doc list
     * @return    List<String>                                 inserted temp file id list
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<String> createTempAtt(List<HttpCalloutVO.PolicyDocType> docList){
        List<String> idList = new List<String>();
        if(null != docList && !docList.isEmpty()){
        List<File_Store__c> fileList = new List<File_Store__c>();
        List<Attachment> attList = new List<Attachment>();
        
        for(Integer i=0; i < docList.size(); i++){
            File_Store__c fileStore = new File_Store__c();
            fileStore.OwnerId = UserInfo.getUserId();
            fileStore.Owner_Id__c = UserInfo.getUserId();
            fileList.add(fileStore);
        }
        //insert file store
        if(!Test.isRunningTest()){
            insert fileList;
        }
        //insert attachment
        for(File_Store__c f : fileList){
            Attachment a = new Attachment();
            a.ParentId = f.Id;
            a.ContentType = 'application/pdf';
            a.Name = 'tempDoc4Broker';
            a.Body = Blob.valueOf('');
            attList.add(a);
        }
        if(!Test.isRunningTest()){
            insert attList;
        }

        for(Integer i = 0; i<docList.size();i++){
            docList[i].attId = attList[i].id;
        }
        for(Attachment a : attList){
            idList.add(a.Id);
        }
        }
        return idList;
    }

    /********************************************************************
     * @decs generate ws doc year select options           
     * @param     List<HttpCalloutVO.PolicyDocType> docList    ws policy doc list
     * @param     Integer effYear                              policy effective year  
     * @param     String type                                  policy document or policy correspondence
     * @return    Map<String, List<HttpCalloutVO.PolicyDocType>>
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    // Rancho_HKITSFDC150_20250210 - document name starts with _INB belongs to inital year
    public static Map<String, List<HttpCalloutVO.PolicyDocType>> getFileYearOption(List<HttpCalloutVO.PolicyDocType> docList, List<OptionWrapper> yearOptions, String effYear, String type){
        Map<String, List<HttpCalloutVO.PolicyDocType>> yearDocMap = new Map<String, List<HttpCalloutVO.PolicyDocType>>();
        /* Integer curYear = Date.today().year();
        yearDocMap.put(String.valueOf(curYear), new List<HttpCalloutVO.PolicyDocType>());
        
        // option should contain all the years from policy effective year to current year
        if(effYear != null){
            if(yearDocMap.get(String.valueof(effYear)) == null){
                for(Integer i = effYear; i < curYear; i++){
                    if(yearDocMap.get(String.valueOf(i))==null){
                        yearDocMap.put(String.valueOf(i), new List<HttpCalloutVO.PolicyDocType>());
                    }
                }
            }
        } */

        Set<String> optionValues = new Set<String>();
        for (OptionWrapper option : yearOptions) {
            optionValues.add(option.value);
        }

        // match doc with proper year
        // Rancho_HKITSFDC70_20240802 - use initial date, replace docCreatedYear with docPolicyYear
        for(HttpCalloutVO.PolicyDocType d : docList){
            String docYear = String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : d.docCreatedYear;
            
            // Rancho_HKITSFDC150_20250210 - document name starts with _INB belongs to inital year
            if (String.isNotBlank(type) && type.equals('Policy Document')){
                String processedDocName = String.isBlank(d.fileName) ? '' : d.fileName.substring(d.fileName.indexOf('_'));
                System.debug('processed doc name: '+processedDocName);
                if(String.isNotBlank(processedDocName) && processedDocName.startsWith('_INB')){
                    docYear = String.valueOf(effYear);
                }
            }
            
            if (optionValues.contains(docYear)) {
                if(yearDocMap.get(docYear) == null){
                    List<HttpCalloutVO.PolicyDocType> temp = new List<HttpCalloutVO.PolicyDocType>();
                    temp.add(d);
                    yearDocMap.put(docYear, temp);
                }else{
                    yearDocMap.get(docYear).add(d);
                }
            }
        }

        Set<String> ks = yearDocMap.keySet();

        Set<String> missingOptions = new Set<String>();
        for (OptionWrapper key : yearOptions) {
            if (!ks.contains(key.value)) {
                missingOptions.add(key.value); // Assuming value and label are the same
            }
        }

        for (String y: missingOptions) {
            yearDocMap.put(y, new List<HttpCalloutVO.PolicyDocType>());
        }

        System.debug('Get all yearDocMap keyset: ' + yearDocMap.keySet());

        return yearDocMap;
    }

    /**
    * @description get a map which indicate fields are available or not 
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @return Map<String, Map<String, Boolean>> 
    **/
    public static Map<String,Map<String,Boolean>> getSettingMap(){
        Map<String,Map<String,Boolean>> fields2=new Map<String,Map<String,Boolean>>();
        Map<String,PolicyFieldByType__c> policyFieldMap=PolicyFieldByType__c.getAll();
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

    /**
    * @description get tabs by policy type
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param String policyType 
    * @return List<String> 
    **/
    public static List<String> getTabs(String policyType){
        List<String> result;
        Map<String,Map<String,Boolean>> setting = getSettingMap();
        if(setting.get('individual').get(policyType) == true){
            result = new List<String>{POLICY_INFORMATION,COVERAGE_INFORMATION,PAYMENT_INFORMATION,CLAIM_HISTORY,POLICY_CHANGE_HISTORY};
        }else if(setting.get('group').get(policyType) == true){
            result = new List<String>{CLAIM_HISTORY,BENEFIT_SCHEDULE,REMAINING_CLINIC_VISITS,REMAINING_INPATIENT_VISITS};
        }
        return result;
    }
    
    /**
    * @description get available button by policy type //to do
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param String policyType 
    * @param Boolean showApplyForGOPBtn 
    * @param Boolean showDDABtn 
    * @return List<String> 
    **/
    public static List<String> getButtons(String policyType,Boolean showApplyForGOPBtn,Boolean showDDABtn){
        List<String> result;
        if(policyType == 'ILAS'){
            result = new List<String>{MAKE_A_CLAIM_BUTTON,MAKE_A_CHANGE_IN_POLICY};
        }else if(policyType == 'nonILAS'){
            result = new List<String>{MAKE_A_CLAIM_BUTTON,MAKE_A_CHANGE_IN_POLICY};
            if(showApplyForGOPBtn){
                result.add(APPLY_ADMISSION_PREAPPROVAL_BUTTON);
            }
        }else if(policyType == 'Group'){
            result = new List<String>{MAKE_A_CLAIM_BUTTON};
            if(showApplyForGOPBtn){
                result.add(APPLY_ADMISSION_PREAPPROVAL_BUTTON);
            }
            if(showDDABtn){
                result.add(DDA_FORM_BUTTON);
            }
        }
        return result;
    }

    // public static List<HttpCalloutVO.Person> getPolicyInsuredBasicList(String policyNumber){
    //     return helper.getPolicyInsuredListBasic(policyNumber,true);   
    // }

    /**
    * @description get coverage info by pol num and insured list
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    * @return List<PolicyWrapper> 
    **/
    public static List<PolicyWrapper> getPolicyPersonCoverageBasic(Map<String, Object> reqMap){
        
        List<HttpCalloutVO.Person> insuredList =(List<HttpCalloutVO.Person>)JSON.deserializeStrict(JSON.serialize(reqMap.get('insuredList')),List<HttpCalloutVO.Person>.class);
        String policyNumber = String.valueOf(reqMap.get('polNo'));
        //JR:COMBO-24,not diplay the specific product in coverage information list;2020-10-09
        Custom_Value__c exclFromCove=Custom_Value__c.getValues('Exclude_Code_from_Coverage');
        List<String> exclFrmCovrgList=new List<String>();
        if(exclFromCove!=NULL&&String.isNotBlank(exclFromCove.Value__c)){
            exclFrmCovrgList=exclFromCove.Value__c.split(';');
        }

        List<Plan_Code_Claim_Type__c> pccList=[Select Plan_code__c,Rate_Scale__c from Plan_Code_Claim_Type__c where TOPUP__C=TRUE];
        Map<String,Set<String>> planCodeMap=new Map<String,Set<String>>();

        // Rancho_MR1218_20240308 - hide special rider in page
        List<String> specialRiderList = Custom_Value__c.getInstance('Hide Product Rider').Value__c?.split(';');

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

        PolicyWrapper result = new PolicyWrapper();
        List<HttpCalloutVO.PolicyPersonCoverage> policyCoverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
        if((policyNumber!=null&&policyNumber!='')&&(!insuredList.isEmpty()&&insuredList.size()>0)){
            for(HttpCalloutVO.Person insure:insuredList){
                if(insure.ssnNumber!=null){
                    List<HttpCalloutVO.PolicyPersonCoverage> coverageList=new List<HttpCalloutVO.PolicyPersonCoverage>();
                    coverageList=helper.getPolicyPersonCoverageBasic(policyNumber,insure.ssnNumber);
                    if(!coverageList.isEmpty()&&coverageList.size()>0){
                        for(HttpCalloutVO.PolicyPersonCoverage c:coverageList){
                            c.insuredName=insure.fullName;
                            if(planCodeMap.containsKey(c.benefitCode)){
                                Set<String> rateScale=planCodeMap.get(c.benefitCode);
                                if(rateScale.contains(c.rateScale)){
                                    result.showDeductible=TRUE;
                                }
                            }
                        }
                        policyCoverageList.addAll(coverageList);
                    }
                    Set<String> benefitCodeSet=new Set<String>();
                    for(Integer i=policyCoverageList.size() - 1;i >=0;i--){
                        HttpCalloutVO.PolicyPersonCoverage plcCovg=policyCoverageList.get(i);

                        if(String.isNotBlank(plcCovg.benefitCode)&&exclFrmCovrgList.contains(plcCovg.benefitCode)){
                            result.showSumInsured=false;
                            policyCoverageList.remove(i);
                            continue;
                        }
                        // Rancho_MR1218_20240308 - hide special rider in page
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
                            result.showAFCcolumns=true;
                        }
                    }

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
                }
            }
        }
         //HKITSFDC-412 BEGIN
        result.policyCoverageList = formatCoverage(policyCoverageList);
        //HKITSFDC-412 ENDED
        result.policyCoverageList = sortCoverage(policyCoverageList);
        return new List<PolicyWrapper>{result};
    }

    // Rancho_JOBR382_20240730 - display base coverage on the top, sort rider in alphabetic order
    public static List<HttpCalloutVO.PolicyPersonCoverage> sortCoverage(List<HttpCalloutVO.PolicyPersonCoverage> covList){
        if(null != covList && covList.size()>1){
            HttpCalloutVO.PolicyPersonCoverage baseCov;
            Map<String, HttpCalloutVO.PolicyPersonCoverage> riderCovMap = new Map<String, HttpCalloutVO.PolicyPersonCoverage>();
            List<String> riderNameList = new List<String>();
            for(Integer i=covList.size()-1; i>=0; i--){
                HttpCalloutVO.PolicyPersonCoverage cov = covList.get(i);
                if(String.isNotBlank(cov.coverageIndicator) && cov.coverageIndicator.equals('Base')){
                    baseCov = cov;
                    covList.remove(i);
                }else if(String.isNotBlank(cov.coverageIndicator) && cov.coverageIndicator.equals('Rider')){
                    riderCovMap.put(cov.benefitEnName, cov);
                    riderNameList.add(cov.benefitEnName);
                }
            }
            covList.clear();
            if(null != baseCov){
                covList.add(baseCov);// ensure base coverage on the top
            }
            riderNameList.sort();// sort rider in alphabetic order
            for(String riderName : riderNameList){
                covList.add(riderCovMap.get(riderName));
            }
        }
        return covList;
    }

    // public static List<HttpCalloutVO.PolicyBilling> getPolicyPaymentInformation(String policyNumber){
    //     PolicyWrapper result = new PolicyWrapper();
    //     result.policyBillingList = getPolicyBillingListBasic(policyNumber);
    //     return result;
    // }
    
    // public static HttpCalloutVO.PolicyPayment getPolicyPaymentBasic(String policyNumber){
    //     List<HttpCalloutVO.PolicyPayment> tempPayList = helper.getPolicyPaymentBasic(policyNumber);
    //     HttpCalloutVO.PolicyPayment payment;
    //     if(null != tempPayList && !tempPayList.isEmpty()){
    //         payment = tempPayList[0];
    //     }
    //     return payment;
    // }

    /**
    * @description get policy billing by pol num
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    * @return List<HttpCalloutVO.PolicyBilling> 
    **/
    public static List<HttpCalloutVO.PolicyBilling> getPolicyBillingListBasic(Map<String,Object> reqMap){
        String policyNumber = String.valueOf(reqMap.get('polNo'));
        return helper.getPolicyBillingListBasic(policyNumber);
    }

    /**
    * @description get policy claim history by pol num
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    * @return List<ClaimHelper.WrapperClaim> 
    **/
    static final Integer DEFAULTPAGESIZE = 100;
    static final Integer MAXPAGE = 10;
    static final Integer STARTINDEX = 1;
    public static List<ClaimHelper.WrapperClaim> getPolicyClaimHistory(Map<String,Object> reqMap){
        String policyNumber = String.valueOf(reqMap.get('polNo'));
        Integer claimStartIndex = STARTINDEX;//Integer.valueOf(reqMap.get('claimStartIndex'));
        Integer pageSize = DEFAULTPAGESIZE;//Integer.valueOf(reqMap.get('pageSize'));
        Boolean isChineseUser = false;
        PolicyWrapper result = new PolicyWrapper();
        List<HttpCalloutVO.Claim> claimList;
        result.claimList = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper cHelper=new ClaimCalloutHelper();
        for(Integer i= 0; i < MAXPAGE; i++){
            claimList=cHelper.GetClaimListBasicByCriteria('','All',policyNumber,'','','','',null,claimStartIndex,pageSize);
            handleClaimTypes(claimList);
            system.debug('claimList:'+claimList.size());
            result.claimList.addAll(claimList);
            if(claimList.size()!=DEFAULTPAGESIZE){
                break;
            }
            claimStartIndex=claimStartIndex+pageSize;
        }
        system.debug('result ws claimList:'+result.claimList.size());
        result.totalClaimRecords=(cHelper.getLastCallTotalRecords()>0)?cHelper.getLastCallTotalRecords():1;
        // MR-992 show sfdc claim records.
        //MRP-242 get map of CB Claims to replace the sfdc claim records (hide sfdc respective records)
        Map<String, HttpCalloutVO.Claim> mapSfClaimNoAndCBClaim = new Map<String, HttpCalloutVO.Claim>();
        List <ClaimHelper.WrapperClaim> wClaimList_current = new List <ClaimHelper.WrapperClaim>();
        List <ClaimHelper.WrapperClaim> wClaimList_all_WS = new List <ClaimHelper.WrapperClaim>();
        List <ClaimHelper.WrapperClaim> wClaimList_all_SF = new List <ClaimHelper.WrapperClaim>();

        // get user info
        String userId = UserInfo.getUserId();
        List <User> uList = [select id, Name, LanguageLocaleKey, username, User_Type__c, UserRoleId, ProfileId, Profile.Name, AccountId, Account.ssn__c from User where id=: userId];
        system.debug('to see uList: '+uList);
        if(uList[0].LanguageLocaleKey == 'zh_TW' || uList[0].LanguageLocaleKey == 'zh_HK')    {isChineseUser = true;}
        // // map userInfo to claimRequest
        // claimRequest.userLoginName = uList[0].username;
        // claimRequest.holderId = (!String.isBlank(uList[0].AccountId) && uList[0].Account.ssn__c != null) ? uList[0].Account.ssn__c : '';
        // claimRequest.insuredSSNnumber = (!String.isBlank(uList[0].AccountId) && uList[0].Account.ssn__c != null) ? uList[0].Account.ssn__c : '';
        // claimRequest.recordCount = 250;

        // get claims from WS
        // List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        // if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null) {
        //     claimList_tmp = cHelper.GetClaimListBasicByCriteria(claimRequest.claimNumber, claimRequest.claimStatus, claimRequest.policyNumber, claimRequest.holderId, claimRequest.holderName,
        //                                                         claimRequest.insuredSSNnumber, claimRequest.insuredName, claimRequest.memberName, claimRequest.certNo, claimRequest.brokerAgentCode,
        //                                                         claimRequest.isBrokerClaim, claimRequest.startRecordIndex, claimRequest.recordCount, claimRequest.isHolderAndInsured,
        //                                                         claimRequest.familyRecordIndicator, claimRequest.userLoginName, claimRequest.holderRelation, claimRequest.insuredRelation);
                                                                
        //     // claimList_tmp = cHelper.GetClaimListBasicByCriteria(claimRequest);
        // }

        // Set<String> sfdcClaimNumbersInCB = new Set<String>();
        // for(HttpCalloutVO.Claim cItem: claimList_tmp){
        //     if(String.isNotBlank(cItem.sfdcClaimNumber)){
        //     mapSfClaimNoAndCBClaim.put(cItem.sfdcClaimNumber, cItem);
        //     }
        // }
        // system.debug('mapSfClaimNoAndCBClaim keys ' + mapSfClaimNoAndCBClaim.keySet());

        String soql_claim = ClaimHelper.CLAIM_ALL_FIELD;
        soql_claim += ' where createdById = :userId and Status__c = \'Processing\' and ';
        soql_claim += ' ((Is_Displayed_For_Customer__c = true and RecordType.Name = \'Normal\' ) or (RecordType.Name = \'Pre Admission\' )) order by LastModifiedDate desc ';
        List <Claim__c> cList = new List <Claim__c>{};
        List <Claim__c> cListNeedToUpdate = new List <Claim__c>{};
        soql_claim = Test.isRunningTest() ? ClaimHelper.CLAIM_ALL_FIELD : soql_claim;
        system.debug('to see soql_claim: '+soql_claim);
        cList = (List<Claim__c>) Database.query(soql_claim);
        if(cList.size()>0){
            for(Claim__c cItem: cList){
                if(cItem.Policy__c != null && cItem.Policy__c.contains(policyNumber)){
                    system.debug('to see cItem:    '+cItem);
                    ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
                    tmpWClaim.cItem = cItem;
                    tmpWClaim.cItem_in = null;
                    tmpWClaim.cItem_grp = null;
                    // MR-1185 policy type incorrect.
                    tmpWClaim.policyType = cItem.Is_Contain_Individual_Policy__c ? 'Individual' : 'Group';
                    tmpWClaim.submitDate = cItem.lastModifiedDate.date();
                    if(cItem.Policy__c != null)    {tmpWClaim.policyNum = cItem.Policy__c;}
                    else    {tmpWClaim.policyNum = 'N/A';}
                    if(cItem.Person_Insured_Name__c != null)    {tmpWClaim.PIName = cItem.Person_Insured_Name__c;}
                    else    {tmpWClaim.PIName = '';}
                    
                    tmpWClaim.claimNum = 'N/A';
                    if(cItem.Display_Selected_Benefit_Type_s__c != null && !isChineseUser)    {tmpWClaim.claimType = cItem.Display_Selected_Benefit_Type_s__c;}         
                    else if(cItem.Display_Selected_Benefit_Type_s__c != null && isChineseUser)    {tmpWClaim.claimType = cItem.Display_Selected_Benefit_Type_s_In_Chi__c;}         
                    else    {tmpWClaim.claimType = 'N/A';}
                    if(cItem.get('status_translated')!= null)    {tmpWClaim.status = String.valueOf(cItem.get('status_translated'));}
                    else    {tmpWClaim.status ='N/A';}
    
                    if('Not Submitted'.equals(tmpWClaim.status)) {tmpWClaim.status = 'Draft';}
                    
                    tmpWClaim.accId = cItem.Account__c;
                    //record from SF is in all / in progress
                    wClaimList_current.add(tmpWClaim.clone());
                }
            }
            result.totalClaimRecords=result.totalClaimRecords+cList.size();
            wClaimList_current.sort();
        }
        system.debug('result sfdc claimList:'+wClaimList_current.size());
        wClaimList_all_WS=MyCgnGetClaim.getWarpClaim(result.claimList);
        wClaimList_current.addAll(wClaimList_all_WS);
        system.debug('result wClaimList_current:'+wClaimList_current.size());
        system.debug('response : '+JSON.serialize(wClaimList_current));
        return wClaimList_current;
        // MR-992 show sfdc claim records.
        //may need to handle CignaWSResultTooLargeException
    }

        
    /**
    * @description claim type handle
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param List<HttpCalloutVO.Claim> cList 
    **/
    private static void handleClaimTypes(List<HttpCalloutVO.Claim> cList){
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

    /**
    * @description get group policy basic info
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    * @return PolicyWrapper 
    **/
    public static PolicyWrapper getBenefitSchedule(Map<String,Object> reqMap){
        String policyNumber = String.valueOf(reqMap.get('polNo'));
        String targetCertNo = String.valueOf(reqMap.get('targetCertNo'));
        List<HttpCalloutVO.Person> userPlanList=new List<HttpCalloutVO.Person>();
        HttpCalloutVO.Policy policy = getPolicyBasic(policyNumber);
        Map<String,List<HttpCalloutVO.PolicyPersonCoverage>> planMap=new Map<String,List<HttpCalloutVO.PolicyPersonCoverage>>();
        Map<String, HttpCalloutVO.Person> groupMemberMap = getGroupMemberBasic(policyNumber);
        system.debug(groupMemberMap);
        PolicyWrapper polWrap = new PolicyWrapper();
        polWrap.certNoSSNMap=  new Map<String,String>();
        polWrap.policy = policy;
        polWrap.planMap = planMap;
        polWrap.groupMemberMap = groupMemberMap;
        for(String g:groupMemberMap.keyset()){
            planMap.put(groupMemberMap.get(g).certificateNo,new List<HttpCalloutVO.PolicyPersonCoverage>());
            userPlanList.add(groupMemberMap.get(g));
            polWrap.certNoSSNMap.put(groupMemberMap.get(g).certificateNo,groupMemberMap.get(g).ssnNumber);
            if(g=='EMPLOYEE'){
                targetCertNo=groupMemberMap.get(g).certificateNo;
            }
        }
            // Added by IBM(Roy) due to PEI-156/PORTABLE R2 --START
        userPlanList.sort();
        polWrap.userPlanList = userPlanList;
        // planMap.put(targetCertNo,new List<HttpCalloutVO.PolicyPersonCoverage>());
        MemberManagementHelper memberHelper=new MemberManagementHelper();
        polWrap.isGSUser = memberHelper.isGSUser(user.account.SSN__c,policyNumber);
        if(polWrap.isGSUser){
            PersonCallOutHelper pHelper=new PersonCallOutHelper();
            List<HttpCalloutVO.Person> personList=pHelper.getPersonBasic(user.account.ssn__c);
            if(personList.size()>0){
                if(personList[0].memberStatusDesc=='Inactive'){
                    polWrap.curUserIsInactive=true;
                }
            }
            if(!polWrap.curUserIsInactive){
                polWrap.displayInCert = memberHelper.isUserEligibleICDownload(null,targetCertNo,policyNumber,polWrap.curUserIsInactive);
                if(polWrap.displayInCert){
                    polWrap.insuranceCertBody = generateInsuranceCertificate(policyNumber,targetCertNo);
                }
            }
            system.debug('polWrap.curUserIsInactive'+polWrap.curUserIsInactive);
            system.debug('polWrap.displayInCert'+polWrap.displayInCert);
            system.debug('polWrap.insuranceCertBody'+polWrap.insuranceCertBody);
        }
        return polWrap;
    }
    
    /**
    * @description filter benefit schedule to display
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param List<HttpCalloutVO.PolicyPersonCoverage> l 
    **/
    private static void filterBenefitSchedule(List<HttpCalloutVO.PolicyPersonCoverage> l){
        for(HttpCalloutVO.PolicyPersonCoverage b:l){
            system.debug('co:'+b);
            if(b.benefitDetailItemDesc=='Reimbursement %'&&b.benefitItemDescDtl=='Combine no. of visits'){
                b.isDisplay=false;
            }else if(b.benefitDetailItemDesc=='Annual Premium'){
                b.isDisplay=false;
            }else if(String.IsEmpty(b.benefitLevel)&&String.IsEmpty(b.benefitLevelDesc)){
                b.isDisplay=false;
            }
        }
    }

    /**
    * @description get benefit schedule detail info by pol no and cert no
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    * @return List<HttpCalloutVO.PolicyPersonCoverage> 
    **/
    public static  List<HttpCalloutVO.PolicyPersonCoverage> getSpecificBenefitSchedule(Map<String,Object> reqMap){
        String policyNumber = String.valueOf(reqMap.get('polNo'));
        String targetCertNo = String.valueOf(reqMap.get('certNo'));
        Map<String, String> certNoSSNMap = (Map<String,String>) JSON.deserialize(JSON.serialize(reqMap.get('certNoSSNMap')), Map<String,String>.class);
        // PolicyWrapper policyWrap = (PolicyWrapper)json.deserializeStrict(JSON.serialize(reqMap.get('policyWrap')), PolicyWrapper.class);
        List<HttpCalloutVO.PolicyPersonCoverage> result = getBenefitScheduleByCertNo(policyNumber,targetCertNo,certNoSSNMap);
        return result;
    }
    
    // public class Card{
    //     String cardTitle;
    //     List<Section> sectionList;
    // }

    // public class Section{
    //     String title;
    //     String description;
    //     List<property> properties;
    // }

    // public class Property{
    //     String property;
    //     String text;
    // }

    /**
    * @description get benefit schedule detail info by pol no and cert no
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param String policyNumber 
    * @param string targetCertNo 
    * @param PolicyWrapper policyWrap 
    * @return List<HttpCalloutVO.PolicyPersonCoverage> 
    **/
    public static List<HttpCalloutVO.PolicyPersonCoverage> getBenefitScheduleByCertNo(String policyNumber,string targetCertNo,Map<String,String> certNoSSNMap){
            system.debug('certNoSSNMap:'+certNoSSNMap);
            system.debug('targetCertNo:'+targetCertNo);
            String tempSSN = certNoSSNMap.get(targetCertNo);
            system.debug('tempSSN:'+tempSSN);
            system.debug('policyNumber:'+policyNumber);
            List<HttpCalloutVO.PolicyPersonCoverage> temp = new List<HttpCalloutVO.PolicyPersonCoverage>();
            //20210105 - David - CR-55 Performance Tuning
            if(String.isNotBlank(tempSSN)){                
                temp=helper.getPolicyPersonCoverageBasic(policyNumber, tempSSN);
            }else{
                temp=helper.getPolicyPersonCoverageBasic(policyNumber,'','',targetCertNo);
            }            
            filterBenefitSchedule(temp);
            return temp;
    }

    /**
    * @description get policy basic by pol no
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param String policyNumber 
    * @return HttpCalloutVO.Policy 
    **/
    public static HttpCalloutVO.Policy getPolicyBasic(String policyNumber){
        HttpCalloutVO.Policy policy=helper.getPolicyBasic(policyNumber);
        String hgProdCode = Portal_Settings__c.getInstance().HG_Product_Code__c;
        if(policy.productCode!=null&&policy.policyStatusCode!=null&&String.isNotBlank(hgProdCode)&&!statusCodeSet.isEmpty()){
            if(hgProdCode.contains(policy.productCode)&&statusCodeSet.contains(policy.policyStatusCode)){
                policy.isDisplayTooltip=true;
            }
        }
        return policy;
    }


    /**
    * @description search all policy within salesforce(draft) and WS(other status)
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @return List<HttpCalloutVO.Policy> 
    **/
    public static List<HttpCalloutVO.Policy> searchAll(){
        // List<HttpCalloutVO.Policy> policyList=helper.getIndividualPolicyListBasicByCriteria(policyNumber, policyHolderName, policyHolderID, policyHolderPhoneNumber, personInsuredName, personInsuredID);
        List<HttpCalloutVO.Policy> policyList=helper.getIndividualPolicyListBasicByCriteria('', '', user.account.SSN__c, '', '', '');
        if(policyList.size()>0) {
            List<HttpCalloutVO.Policy> result = new List<HttpCalloutVO.Policy>();
            for (HttpCalloutVO.Policy p: policyList) {
                if (!CustomizeSearchPolicyPageCtrl.cmClaimList.contains(p.policyNumber)) {
                    result.add(p);
                }
            }
            policyList.clear();
            policyList.addAll(result);
        }
        // Comment by Rancho - since we won’t have eSales in Phase 1, hide policy with Draft status
        // List <HttpCalloutVO.Policy> outStandingPolicy=CustomizeSearchPolicyPageCtrl.searchMyOutstandingPolicies();
        // policyList.addAll(outStandingPolicy);
        if(policyList.size()>0){
            // showIndTab=true;
            CustomizeSearchPolicyPageCtrl.initInsuredNameStr(policyList);
            policyList.sort();
            // cusIndTotalPage=(policyList.size() + CUS_PAGE_SIZE - 1) / CUS_PAGE_SIZE;
            string productCode= Portal_Settings__c.getInstance().HG_Product_Code__c;
            Set<String> statusCodeList=new Set<String>();
            for(Policy_Status_Mapping__c psm:[select id,PolicyCode__c,PolicyStatus__c from Policy_Status_Mapping__c where PolicyStatus__c ='Lapsed']){
                statusCodeList.add(psm.PolicyCode__c);
            }
            for(HttpCalloutVO.Policy p:policyList){
                if(p.policyStatusDisplayName == '未提交' || p.policyStatusDisplayName == 'Not Submitted'){
                    p.policyStatusDisplayName = 'Draft';
                }
                if(String.isNotBlank(p.productCode)&&String.isNotBlank(p.policyStatusCode)&&String.isNotBlank(productCode)&&!statusCodeList.isEmpty()){
                    if(productCode.contains(p.productCode)&&statusCodeList.contains(p.policyStatusCode)){
                        p.isDisplayTooltip=true;
                    }
                }
            }
        }
        // load Group data
        List<HttpCalloutVO.Policy> policyListGroup=helper.getGroupPolicyListBasicByCriteria(null, null);
        // List<HttpCalloutVO.Policy> policyListGroup=helper.getGroupPolicyListBasicByCriteria(policyNumberG, policyHolderNameG);
        
        List<HttpCalloutVO.Policy> result = new List<HttpCalloutVO.Policy>();
        for (HttpCalloutVO.Policy p: policyListGroup) {
            if (!CustomizeSearchPolicyPageCtrl.cmClaimList.contains(p.policyNumber)) {
                result.add(p);
            }
        }
        policyList.addAll(result);
        system.debug('searchAll result:'+policyList.size());
        return policyList;
    }

    /********************************************************************
     * @decs get policy change records for all policies from SFDC or WS
     * @param     N/A
     * @return    List<PolicyChange>            policy change list from SFDC/WS
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<PolicyChange> getAllPolChangeRecord(){
        List<PolicyChange> polChangeList = new List<PolicyChange>();

        // get outstanding records from SFDC
        // MR-709 missing changese policy change
        for(Policy_Change_Request__c temp : [SELECT Id, Policy_No__c, toLabel(RecordType.Name), RecordType.DeveloperName, Policy_Holder_Name__c, Policy_Holder_Id__c, toLabel(Status__c), LastModifiedDate FROM Policy_Change_Request__c WHERE OwnerId=:UserInfo.getUserId() AND Status__c='Not Submitted' AND RecordType.Name!='Fund Management' AND RecordType.Name!='Fund Switching' AND RecordType.Name!='Fund Reallocation' AND RecordType.Name!='Fund Withdrawal' ORDER BY LastModifiedDate DESC]){
            PolicyChange pc = new PolicyChange();
                 
            pc.policyChangeId = temp.Id;
            pc.policyChangeDate = temp.LastModifiedDate.format('dd/MM/yyyy');
            pc.policyNo = temp.Policy_No__c;
            pc.policyChangeType = temp.RecordType.Name;
            pc.status = 'Draft';
            pc.displayStatus = System.Label.Draft;
            pc.policyHolderName =temp.Policy_Holder_Name__c;
            pc.policyHolderId =temp.Policy_Holder_Id__c;
            pc.changedContent = temp.RecordType.Name;
            
            polChangeList.add(pc);
        }

        // get submitted records from WS
        WorkCalloutHelper wHelper = new WorkCalloutHelper();
        List<HttpCalloutVO.WorkStatus> tempList = wHelper.getWorkStatusByUserLoginName('Policy Change Request', null, null, null, null, null);
    
        Datetime dateScope = Datetime.now().addMonths(-3);
        System.debug('date scope: '+dateScope);
        for(HttpCalloutVO.WorkStatus work : tempList){
            
            // only display those records submitted within 3 months
            if(work.submittedDateTime != null && work.submittedDateTime < dateScope){
                continue;
            }

            PolicyChange p = new PolicyChange();
            if(work.requestStatus == 'Pending' || work.requestStatus == 'Pending Information'){
                p.status = 'Pending';
                p.displayStatus = System.Label.Pol_Pending_for_Information;
            }else if(work.requestStatus == 'Processing'){
                p.status = 'Processing';
                p.displayStatus = System.Label.Processing;
            // Rancho_MR422_20231220 - status update
            }else if(work.requestStatus == 'Completed' || work.requestStatus == 'Processed' || work.requestStatus == 'Request Closed'){
                p.status = 'Completed';
                p.displayStatus = System.Label.Completed;
            }else if(work.requestStatus == 'Request Terminated' || work.requestStatus == 'Request Cancelled'){
                p.status = 'Cancel';
                p.displayStatus = System.Label.Cancel;
            }else{
                p.status = work.requestStatus;
                p.displayStatus = work.requestStatus;
            }

            p.PolicyNo = work.policyNumber;
            p.PolicyChangeType = work.salesForceWorkType;
            p.PolicyChangeDate = work.submittedDateTime.format('dd/MM/yyyy');
            p.changedContent = work.caseWorkItem;

            polChangeList.add(p);
        }
        System.debug('change record list size: '+polChangeList.size());
        return polChangeList;
    }

    /********************************************************************
     * @decs delete draft policy change request record from SFDC
     * @param     Map<String, Object> reqMap    request params map
     * @return    N/A
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static void removeChangeRecord(Map<String, Object> reqMap){
        String id = (String)reqMap.get('id');
        if(String.isNotBlank(id)){
            List<Policy_Change_Request__c> tempList = [SELECT Id FROM Policy_Change_Request__c WHERE Id =:id];
            if(null != tempList && !tempList.isEmpty()){
                delete tempList[0];
            }
        }
    }

    /**
    * @description delete draft policy in SFDC
    * @author jackshao@deloitte.com.cn | 06-26-2023 
    * @param Map<String Object> reqMap 
    **/
    public static void deletePolicy(Map<String, Object> reqMap){
        String polId = (String)reqMap.get('polId');
        List <ESales_Transaction__c> nbList=[SELECT Id FROM ESales_Transaction__c where id=: polId];
        List <ESales_Policy_Transaction__c> vhisList=[SELECT Id FROM ESales_Policy_Transaction__c where id=: polId];
        if(nbList.size()>0){
            Delete nbList;
        }else if(vhisList.size()>0){
            delete vhisList;
        }
    }

    public class ListWrap{
        string key;
        string value;
    }
    /********************************************************************
     * @decs get policy insured list when user selected policy
     * @param     Map<String, Object> reqMap    request params map
     * @return    List<PersonInsured>
     * @author    ranzhao@deloitte.com.cn
     ********************************************************************/
    public static List<PersonInsured> getChangeRecordPI(Map<String, Object> reqMap){
        List<PersonInsured> insuredList = new List<PersonInsured>();
        System.debug('request value: '+reqMap);
        // Object temp = reqMap.get('req');
        // Request req = (Request)temp;
        // String polNo = req.polNo;
        String polNo = (String)reqMap.get('polNo');
        
        if(String.isNotBlank(polNo)){
            List<String> inforceList = new List<String>();
            Set<String> uniquePISet = new Set<String>();

            for(Policy_Status_Mapping__c psm : [SELECT Description__c FROM Policy_Status_Mapping__c WHERE PolicyStatus__c='Inforce' OR PolicyStatus__c='Lapsed']){
                inforceList.add(psm.Description__c);
            }

            List<HttpCalloutVO.Policy> tempList = helper.getIndividualPolicyListBasicByCriteria(polNo,'','','','','',inforceList,'');
            if(null != tempList && !tempList.isEmpty()){
                uniquePISet.add(tempList[0].holderSSN);
                
                ListWrap temp = new ListWrap();
                temp.key = tempList[0].holderSSN;
                temp.value = tempList[0].holderName;

                PersonInsured holder = new PersonInsured();
                holder.title = 'Policy Holder';
                holder.label = tempList[0].holderName;
                system.debug(JSON.serialize(temp));
                holder.value = JSON.serialize(temp);
                insuredList.add(holder);

                for(HttpCalloutVO.Person person : tempList[0].insuredList){
                    if(!uniquePISet.contains(person.ssnNumber)){
                        uniquePISet.add(person.ssnNumber);

                        ListWrap temp1 = new ListWrap();
                        temp1.key = person.ssnNumber;
                        temp1.value = person.fullName;
                        
                        PersonInsured insured = new PersonInsured();
                        insured.title = 'Person Insured';
                        insured.label = person.fullName;
                        system.debug(JSON.serialize(temp1));
                        insured.value = JSON.serialize(temp1);
                        insuredList.add(insured);
                    }
                }
            }
        }

        return insuredList;
    }

    public class PersonInsured{
        String title;
        String label;
        String value;
    }

    public static List<HttpCalloutVO.Policy> getPolicyListbyAPI(){
        List<HttpCalloutVO.Policy> polList=new List<HttpCalloutVO.Policy>();
        PolicyCalloutHelper policyHelper=new PolicyCalloutHelper();

        List<String> listStatus=new List<String>();
        List<Policy_Status_Mapping__c> polStatus=[SELECT Description__c FROM Policy_Status_Mapping__c WHERE PolicyStatus__c='Inforce' OR PolicyStatus__c='Lapsed'];

        if(polStatus.size()>0){
            for(Policy_Status_Mapping__c status: polStatus){
                listStatus.add(status.Description__c);
            }
        }

        String holderSsn='';
        List<User> userList=[Select Id,AccountId,Account.SSN__c From User Where Id=:Userinfo.getUserId()];
        if(userList.size()>0){
            if(userList[0].AccountId!=null&&String.IsNotBlank(userList[0].Account.SSN__c)){
                holderSsn=userList[0].Account.SSN__c;
            }
        }

        polList=policyHelper.getIndividualPolicyListBasicByCriteria('','',holderSsn,'','','','','');
        return polList ;
    }

    /**
     * [Get PolicyList]
     * @Author   Gong,Minghua
     * @DateTime 2023-07-03
     * @return   [Policy List]
     */
    public static List<Policy> getPolicyList(){
        List<HttpCalloutVO.Policy> polList=getPolicyListbyAPI();
        list<Policy> policyList=new list<Policy>();
        if(polList.size()>0){
            for(HttpCalloutVO.Policy policy : polList){
                Policy tempolicy=new Policy();
                tempolicy.policyNo=policy.policyNumber ;
                tempolicy.policyName=policy.marketingName;
                tempolicy.policyHolderId=policy.holderSSN ;
                tempolicy.personName=policy.holderName;
                tempolicy.status=policy.policyStatusDisplayName;
                tempolicy.agentCode=policy.agentCode ;
                tempolicy.brokerName=policy.brokerName ;
                tempolicy.allowChangeOwner=policy.allowChangeOwner ;
                tempolicy.allowChangePaymentDate=policy.allowChangePaymentDate ;
                tempolicy.isLifePolicy=policy.isLifePolicy;
                tempolicy.isILAS=policy.isILAS ;
                tempolicy.isIPMIPolicy=policy.isIPMIPolicy;
                tempolicy.productCode=policy.productCode;
                tempolicy.policyType='Individual';
                System.debug('policy.planTypeCode:'+policy.planTypeCode+'policy.planName:'+policy.planName+'policy.productCode:'+policy.productCode);
                policyList.add(tempolicy);
            }
        }
        return policyList;
    }

    public class Policy{
        public String policyName{get;set;}
        public String policyNo{get;set;}
        public String policyHolderId{get;set;}
        public String status{get;set;}
        public String policyStatusChecking{get;set;}
        public String personName{get;set;}
        public String agentCode{get;set;}
        public String brokerName{get;set;}
        public Boolean allowChangeOwner{get;set;}
        public Boolean allowChangePaymentDate{get;set;}
        public Boolean isLifePolicy{get;set;}
        public Boolean isILAS{get;set;}
        public Boolean isIPMIPolicy{get;set;}
        public Boolean policySelected{get;set;}
        public Boolean policyHolderSelected{get;set;}
        public String productCode{get;set;}
        public String policyType{get;set;}
    }

    //Add by Owen for generate pdf in React Native 2023.12.05
    public Class DocumentInfo{
        String result;
        String body;
        String attachmentId; //HKIDSFDC-438
    }

  

    public static DocumentInfo checkIsDocumentDownloadComplete(Map<String, Object> reqMap){
        DocumentInfo docInf = new DocumentInfo();
        String fileStoreId = String.valueOf(reqMap.get('fileStoreId'));
        if(String.isNotBlank(fileStoreId)){
            // to do if file store id 
            // else attid 
            for(attachment att : [Select Id, Body From Attachment Where ParentId =: fileStoreId]){
                if(att.Body!=null && att.Body.size()>0){
                    docInf.result='true';
                    // docInf.body=EncodingUtil.base64Encode(a.Body);
                    //HKITSFDC-438  
                    docInf.body='file='+ att.Id + '&operationContext=S1';
                    docInf.attachmentId=att.Id;
                }
            }
        }else{
            docInf.result = 'false';
        }
       
        return docInf;
    }
    //{!downloadSitePrefix}apex/ComFileDownLoadVFP?lang={!curLang}&attID={!indDocAttIDList[tmpIdx]}&attKey={!myList.attachmentKey}&pol={!JSINHTMLENCODE(policyNumber)}&appName=CUSTOMER_PORTAL
    Class AttBodyInfo {
        String fileStoreId;
    }
    public static AttBodyInfo getAttBody(Map<String, Object> reqMap){
        AttBodyInfo attInfo = new AttBodyInfo();
        system.debug(' getAttBody ' + reqMap) ;//20250801 debug
        string attID = String.valueOf(reqMap.get('attID'));        
        string pol = String.valueOf(reqMap.get('pol'));
        string attKey = String.valueOf(reqMap.get('attKey'));
        string lang = user.LanguageLocaleKey;
        //David Zhang - 190401 - Pending Memo Doc Async
        // string requestId = String.valueOf(reqMap.get('requestId'));
        string type = 'policy';//String.valueOf(reqMap.get('type'));
        
        // String selectedDowlAttId = String.valueOf(reqMap.get('attID'));
        String appName = 'CUSTOMER_PORTAL';//String.valueOf(reqMap.get('appName'));
        system.debug('[MyCgnPolicyDetail] parameters ' + ' ' + pol + ' attKey ' +  attKey + 'lang ' + lang + ' attID ' + attID + ' appName ' + appName + 'type ' + type ) ;//20250801 debug
        if(attKey!='Insurance_Certificate'){
            File_Store__c fs = new File_Store__c();
            fs.OwnerId = UserInfo.getUserId();
            fs.Owner_id__c = UserInfo.getUserId();
            insert fs;
            attInfo.fileStoreId = fs.Id;
            system.debug(' getAttBody fileStoreId ' + attInfo.fileStoreId) ;
            if  ('policy'.equalsIgnoreCase(type)){
                system.debug(' enqueueJob ' + ' ' + pol + ' attKey ' +  attKey + 'lang ' + lang + ' attID ' + attID + ' appName ' + appName + 'type ' + type ) ;//20250801 debug
                try{
                   Id jid = System.enqueueJob(new downloadDocQueue(pol, attKey, lang, attID, appName, type, fs.Id)); 
                   system.debug('enequeue jid  ' + jid +' total running ' + Limits.getQueueableJobs() );
                }
                catch(Exception ex){
                    system.debug('enequeue Exception: ' + ex.getStackTraceString());
                }
                finally{
                    system.debug(' enqueueJob done') ;//20250801 debug
                }
            }
        } else {
            attInfo.fileStoreId = '';
        }
        return attInfo;
    }

    Class MedicalcardInfo{
        String result;
        String employeeName;
    }
    public static MedicalcardInfo getMedicalCardAction(){
        MedicalcardInfo mi = new MedicalcardInfo();
        MemberManagementHelper helper = new MemberManagementHelper();
        if(helper.isUserRequiredSignDDA(user.account.SSN__c,'')){
            List<Member_Management__c> memList =[SELECT id,Policy_Number__c,Cert_Number__c,Related_Cert_Number__c,Relationship__c FROM Member_Management__c WHERE (SSN__c = :user.account.SSN__c or Cert_Number__c=:user.account.SSN__c)  Order by Policy_Year__c DESC];
            if(memList[0].Relationship__c == 'Employee'){
                mi.result='Sign DDA';
            }else{
                String employeeCertNo=memList[0].Related_Cert_Number__c;
                String policyNumber=memList[0].Policy_Number__c;
                for(Member_Management__c member:[SELECT id,First_Name__c,Last_Name__c,Relationship__c FROM Member_Management__c WHERE Policy_Number__c=:policyNumber and Relationship__c='Employee' and DDA_signature_reqiured__c = 'Y' and (Related_Cert_Number__c=:employeeCertNo or Cert_Number__c=:employeeCertNo)  Order by Policy_Year__c DESC]){
                    mi.employeeName=member.First_Name__c + ' ' + member.Last_Name__c;
                }
                mi.result='Required employee sign DDA';
            }
        }else{
            mi.result='Medical Card';
        }
        return mi;
    }

    public static string generateInsuranceCertificate(String policyNumber,String targetCertNo){
        String result;
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
            result=EncodingUtil.base64Encode(att.Body);
        }catch(Exception e){
            //            system.debug(e.getMessage());
        }
        return result;
    }
    
     //HKITSFDC-211 Begin MSHAH10 
      public static List<HttpCalloutVO.PolicyBilling> getPolicyBillingListTable(String policyNumber, String dateFrom, String dateTo){
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            Boolean isBrokerPortalBillingIndicator = true;// HKITSFDC-211 202507729 updated from false to true according to user request ;
          
            List<HttpCalloutVO.PolicyBilling> billingList = helper.getPolicyBillingListBasic(policyNumber, isBrokerPortalBillingIndicator);
    
            return billingList;
        }
        
        //HKITSFDC-211 End MSHAH10 
       
       //HKITSFDC-412 BEGIN
    public static List<HttpCalloutVO.PolicyPersonCoverage> formatCoverage(List<HttpCalloutVO.PolicyPersonCoverage> covList){
        
        List<HttpCalloutVO.PolicyPersonCoverage> formattedCovList = new List<HttpCalloutVO.PolicyPersonCoverage>();
        List<String> ciProductCodeList = new List<String>();
        
        
        for(App_ProductFunction_Setting__c appSetting:[SELECT ProductCode__c FROM App_ProductFunction_Setting__c WHERE Type__c ='ShowCoverageCIFields']) {
            ciProductCodeList.add( appSetting.ProductCode__c.toUpperCase() );
        }
        
        if( covList != null && covList.size()>=1) {
           
           //Check is CI Base or CI Rider 
           Boolean isCI = false;
           for(HttpCalloutVO.PolicyPersonCoverage cov : covList){
                
        
                if(String.isNOTBlank(cov.benefitCode) && String.isNotBlank(cov.coverageIndicator) &&  cov.coverageIndicator.equals('Base') ){ // confirm by that CI wont be in rider ( cov.coverageIndicator.equals('Base') || cov.coverageIndicator.equals('Rider'))){
                   if ( ciProductCodeList.contains(cov.benefitCode.toUpperCase()) ){
                       isCI = true;
                       break;
                   }
                   
                }
                
            }
             system.debug('[MyCgnPolicyDetail] is CI ' + isCI);
            //Format the date output , hide columns 
            for(HttpCalloutVO.PolicyPersonCoverage cov : covList){
                
                if ( isCI ){
                  
                    //Format the coverage date and sum insured
                    cov.benefitAmountInNumber = cov.faceAmt ;// overwrite the current figure used in UI 
                    
                    if ( cov.coverageStatus != null ) {
                        system.debug('[MyCgnPolicyDetail] cov.coverageStatus : ' + cov.coverageStatus);
                        if ( !cov.coverageStatus.equalsIgnoreCase('Not taken') ) {
                            if ( String.isNotBlank(cov.CoveragePeriodFrom) && cov.CoveragePeriodFromInDate != null ) {
                                cov.CoveragePeriodFrom = dateTimeString(cov.CoveragePeriodFromInDate);
                                //cov.CoveragePeriodFrom =  String.valueOf(cov.CoveragePeriodFromInDate.day())+ '/' + String.valueOf(cov.CoveragePeriodFromInDate.month()) + '/' + String.valueOf(cov.CoveragePeriodFromInDate.year());
                            }
                            if ( String.isNotBlank(cov.CoveragePeriodTo) && cov.CoveragePeriodToInDate != null ) {
                                 cov.CoveragePeriodTo = dateTimeString(cov.CoveragePeriodToInDate);
                                //cov.CoveragePeriodTo = String.valueOf(cov.CoveragePeriodToInDate.day()) + '/' + String.valueOf(cov.CoveragePeriodToInDate.month()) + '/' + String.valueOf(cov.CoveragePeriodToInDate.year());
                            }
                        }
                        else{
                            system.debug('not taken coverage');
                            cov.CoveragePeriodFrom = null;
                            cov.CoveragePeriodTo = null;
                        }
                    }
                    else {
                         system.debug('[MyCgnPolicyDetail] coverageStatus null');
                         cov.CoveragePeriodFrom = null;
                         cov.CoveragePeriodTo = null;
                    }
                }
                else{
                    //Hide covergae date and sum insured
                    cov.benefitAmountInNumber = null;
                    cov.CoveragePeriodFrom = null;
                    cov.CoveragePeriodTo = null;
                }
                formattedCovList.add(cov);
            }
        }
        else{
            formattedCovList = covList;
        }
        return formattedCovList;
    }
    
    public static String dateTimeString(Date inDate){
        String dtStr = '';
        Integer d = inDate.day();
        Integer mo = inDate.month();
        Integer yr = inDate.year();
        
        DateTime dt = DateTime.newInstance(yr, mo, d);
        dtStr = dt.format('dd/MM/yyyy');
        return dtStr;
    }

    //HKITSFDC-412 ENDED 
        
}