public without sharing class CSPolicyDetailLWCCtrl {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getTranslations() {
        Map<String, String> translations = new Map<String, String>();
        for (Translate__mdt t : [SELECT DeveloperName, en_US__c FROM Translate__mdt WHERE Category__c='CSMemberLevel' OR Category__c='PolicyReplacement' OR Category__c='LevyII' OR Category__c='AsiaMiles']) {
            translations.put(t.DeveloperName, t.en_US__c);
        }
        return translations;
    }

    /******************************************************************
     * getPolicyBasic
     * @description: Call getPolicyBasic WS to get policy info
     ******************************************************************/
    @AuraEnabled
    public static PolicyBasic getPolicyBasic(String policyNo, String sourceAccId){
        PolicyBasic result = new PolicyBasic();
        if(String.isNotBlank(policyNo)){
            try{
                // get policy basic
                HttpCalloutVO.Policy policy = new HttpCalloutVO.Policy();
                PolicyCalloutHelper helper = new PolicyCalloutHelper();
                policy = helper.getPolicyBasic(policyNo);
                result.policy = policy;

                // get health migration cancel policy
                List<Health_Migration_Cancel_Policy__c> hMCPolList=[SELECT Id,Cancelled__c FROM Health_Migration_Cancel_Policy__c WHERE Policy_Number__c=:policyNo AND SSN__c=:policy.holder.ssnNumber];
                if (null != hMCPolList && !hMCPolList.isEmpty()) {
                    policy.isDisplayTooltip=hMCPolList[0].Cancelled__c;
                    result.healthMigrationCancelPolicyId=hMCPolList[0].Id;
                }
                
                // get policy holder info
                Boolean isTDUser = policyNo.startsWithIgnoreCase(CignaUtil.cusFuncTD)? true : false;
                String holderSSN = policy?.holder?.ssnNumber;
                result.holder = getPolicyHolderBasic(policyNo, isTDUser, holderSSN);
                if(isTDUser){
                    result.policy.holder = result.holder;
                }

                // get person insured list
                result.insuredList = getPolicyInsuredBasicList(policyNo, isTDUser, policy, holderSSN, result.holder);
                String insuredSSN = '';
                if(result.insuredList!=null && result.insuredList.size()>0 && String.isNotBlank(result.insuredList.get(0).ssnNumber)){
                    insuredSSN = result.insuredList.get(0).ssnNumber;
                    System.debug('insuredSSN: ' + insuredSSN);
                    List<Account> tmpList = [SELECT Id, SSN__c FROM Account where Recordtype.DeveloperName = 'Customer' And SSN__c=:insuredSSN];
                    System.debug('tmpList: ' + tmpList);
                    System.debug('tmpList.size(): ' + (null!=tmpList && tmpList.size()>0));
                    // result.personInsureId = ((null!=tmpList && tmpList.size()>0) ? tmpList.get(0).Id : '');
                    if(null!=tmpList && tmpList.size()>0){
                        result.personInsureId = tmpList.get(0).Id;
                    }
                } 

                updateTrackingHistory(sourceAccId, policyNo, insuredSSN);

                // get current login user info
                User user = [SELECT Id, Work_From_Home__c FROM User WHERE Id = :UserInfo.getUserId()];
                result.wfh = user.Work_From_Home__c?true:false;
                result.isCS = CignaUtil.isCSUser();
                result.isTM = CignaUtil.isTMUser(UserInfo.getUserId());
            }catch(Exception e){
                System.debug('Error getting policy basic: ' + e.getMessage());
                System.debug(e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        }
        return result;
    }

    @future
    public static void updateTrackingHistory(String accId, String policyNo, String insuredSSN){
        if(String.isBlank(accId) && String.isNotBlank(insuredSSN)){
            List<List<SObject>> result=[FIND :insuredSSN IN ALL FIELDS RETURNING Account(Id)];
            List<Account> aList=result.get(0);
            if(aList!=null && aList.size()>0){
                accId=aList.get(0).Id;
            }
        }

        try{
            List<User> uList=[SELECT Id,FirstName,LastName FROM User WHERE Id = :UserInfo.getUserId()]; 
            if(uList.size()>0){  
                User loginUser=uList.get(0);
                Tracking_History__c newTracking = new Tracking_History__c();
                if(loginUser.FirstName!=null && loginUser.FirstName!=''){
                    newTracking.Name=loginUser.FirstName+' '+loginUser.LastName;
                }else{
                    newTracking.Name=loginUser.LastName;
                }
                newTracking.Page__c='Policy Detail';
                newTracking.Policy_Number__c=policyNo;

                if(String.isNotBlank(accId)){
                    newTracking.Account__c=accId;
                }else if(String.isNotBlank(insuredSSN)){
                    List<List<SObject>> result = [FIND :insuredSSN IN ALL FIELDS RETURNING Account(Id)];
                    List<Account> aList=result.get(0);
                    if(aList!=null && aList.size()>0){
                        Account a=aList.get(0);
                        newTracking.Account__c=a.Id;
                    }
                }
                insert newTracking;
            }
        }catch(Exception e){            
            System.debug('UpdateTrackingHistory error: ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    /*****************************************************************************
     * getPolicyHolderBasic
     * @description: Call getPolicyHolderListBasic WS to get policy holder info 
     *****************************************************************************/
    public static HttpCalloutVO.Person getPolicyHolderBasic(String policyNo, Boolean isTDUser, String holderSSN){
        HttpCalloutVO.Person holder = new HttpCalloutVO.Person();
        if(!isTDUser){
            if(String.isNotBlank(policyNo)){
                PolicyCalloutHelper helper = new PolicyCalloutHelper();
                List<HttpCalloutVO.Person> personList = helper.getPolicyHolderListBasic(policyNo);
                if(!personList.isEmpty() && personList.size()>0){
                    holder = personList.get(0);
                }
            }
        }
        
        if(String.isNotBlank(holderSSN)){
            PersonCallOutHelper pHelper = new PersonCallOutHelper();
            List<HttpCalloutVO.Person> personList = pHelper.getPersonBasic(holderSSN);
            if(!personList.isEmpty() && personList.size()>0){
                if(isTDUser){
                    holder = personList.get(0);
                }
                holder.rPQStatus = personList[0].rPQStatus;
                holder.rPQEffectiveDate = personList[0].rPQEffectiveDate;
                holder.homePhoneNo = personList[0].homePhoneNo;
                holder.businessPhoneNo = personList[0].businessPhoneNo;
                holder.mobilePhoneNo = personList[0].mobilePhoneNo;
                if(String.isBlank(holder.emailAddress)){
                    holder.emailAddress = personList[0].emailAddress;
                }
            }
        }

        return holder;
    }

    /*****************************************************************************
     * getPolicyInsuredBasicList
     * @description: 1.If is group policy, call getPolicyPersonListBasicByCriteria WS
     *               2.If is individual policy,call getPolicyInsuredListBasic WS
     ***********************************************************************************/
    public static List<HttpCalloutVO.Person> getPolicyInsuredBasicList(String policyNo, Boolean isTDUser, HttpCalloutVO.Policy policy, String holderSSN, HttpCalloutVO.Person holder){
        List<HttpCalloutVO.Person> insuredList = new List<HttpCalloutVO.Person>();
        if(!isTDUser){
            insuredList=new List<HttpCalloutVO.Person>();
            if(String.isNotBlank(policyNo)){
                PolicyCalloutHelper helper = new PolicyCalloutHelper();
                insuredList=helper.getPolicyInsuredListBasic(policyNo);          
            }    
        }else{
            insuredList=new List<HttpCalloutVO.Person>();
            if(policy!=null && policy.insuredList!=null){
                PersonCallOutHelper pHelper = new PersonCallOutHelper();
                for(HttpCalloutVO.Person pi : insuredList){  //Since TD policy only have one PI, so it won't affect performnce to put getPersonBasic calling in loop
                    if(String.IsNotBlank(pi.ssnNumber)){
                        if(String.IsNotBlank(holderSSN) && holderSSN==pi.ssnNumber && holder!=null){
                            insuredList.add(holder);
                            continue;
                        }
                        
                        List<HttpCalloutVO.Person> personList=pHelper.getPersonBasic(pi.ssnNumber);
                        if(!personList.isEmpty() && personList.size()>0){
                            insuredList.add(personList.get(0));
                        }
                    }
                }
            }
        }
        return insuredList;
    }

    /***********************************************************************************
     * getPolicyBeneficiaryBasicList
     * @description: Call getPolicyBeneficiaryListBasic WS to get beneficiary data
     ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<HttpCalloutVO.Person> getPolicyBeneficiaryBasicList(String policyNo){
        List<HttpCalloutVO.Person> beneficiaryList = new List<HttpCalloutVO.Person>();
        if(String.isNotBlank(policyNo)){
            Boolean isTDUser = policyNo.startsWithIgnoreCase(CignaUtil.cusFuncTD)? true : false;
            if(!isTDUser){
                PolicyCalloutHelper helper = new PolicyCalloutHelper();
                beneficiaryList=helper.getPolicyBeneficiaryListBasic(policyNo);
            }
        }
        return beneficiaryList;
    }

    /***********************************************************************************
     * getPolicyPaymentBasic
     * @description: Call getPolicyPaymentBasic WS to get payment info
     ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static HttpCalloutVO.PolicyPayment getPolicyPaymentBasic(String policyNo){
        HttpCalloutVO.PolicyPayment payment = new HttpCalloutVO.PolicyPayment();
        if(String.isNotBlank(policyNo)){
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            List<HttpCalloutVO.PolicyPayment> paymentList=helper.getPolicyPaymentBasic(policyNo);
            if(!paymentList.isEmpty() && paymentList.size()>0){ 
                payment=paymentList.get(0); 
            }
        } 
        return payment;
    }

    /***********************************************************************************
     * getPolicyBillingListBasic
     * @description: Call getPolicyBillingListBasic WS to get billing detail
     ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<HttpCalloutVO.PolicyBilling> getPolicyBillingListBasic(String policyNo){
        List<HttpCalloutVO.PolicyBilling> paymentTransactionList = new List<HttpCalloutVO.PolicyBilling>();
        if(String.isNotBlank(policyNo)){
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            paymentTransactionList = helper.getPolicyBillingListBasic(policyNo);
            paymentTransactionList.sort();//add by kit
        }
        return paymentTransactionList;
    }

    @AuraEnabled(cacheable=true)
    public static PolicyBasic getCoverageBasic4PaymentInfo(String policyNo){
        PolicyBasic result = new PolicyBasic();
        if(String.isNotBlank(policyNo)){
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            List<HttpCalloutVO.PolicyPersonCoverage> coverageList = helper.getPolicyPersonCoverageBasic(policyNo,'');
            
            result.exclusionList = new List<HttpCalloutVO.Exclusion>();
            result.loadingList = new List<HttpCalloutVO.Loading>();
            
            for(HttpCalloutVO.PolicyPersonCoverage coverage : coverageList){
                result.exclusionList.addAll(coverage.exclusionList);
                
                if(coverage.loadingAmount!=null && coverage.loadingPercentage!=null && coverage.loadingAmountDuration!=null && coverage.loadingPercentageDuration!=null){
                    HttpCalloutVO.Loading obj=new HttpCalloutVO.Loading();
                    obj.loadingAmount=coverage.loadingAmount;
                    obj.loadingPercentageStr=String.valueOf(coverage.loadingPercentage)+' %';
                    obj.loadingAmountDuration=coverage.loadingAmountDuration;
                    obj.loadingPercentageDuration=coverage.loadingPercentageDuration;
                    result.loadingList.add(obj);
                }
            }
        }
        return result;
    }

    /***********************************************************************************
     * getPolicyClaimHistory
     * @description: Call GetClaimListBasicByCriteria WS to get claim History data
     ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static PolicyBasic getPolicyClaimHistory(String policyNo){
        PolicyBasic result = new PolicyBasic();
        ClaimCalloutHelper cHelper = new ClaimCalloutHelper();
        try{
            if(String.isNotBlank(policyNo)){
                List<HttpCalloutVO.Claim> claimList = cHelper.GetClaimListBasicByCriteria('', 'All', policyNo, '', '', '', '', null, null, null); 
                result.claimList = handleClaimTypes(claimList);

                result.claimHistoryList = new List<Claim__c>();
                List<Claim__c> tempList = [SELECT Policy__c,Claim_Type__c,Person_Insured_Name__c,Submission_Date__c,Name FROM Claim__c WHERE Status__c='Processing' AND Submission_Date__c=LAST_N_DAYS:13 Order BY Submission_Date__c DESC];
                if(tempList.size()>0){
                    for(Claim__c t:tempList){
                        if(t.Policy__c==policyNo){
                            result.claimHistoryList.add(t);
                        }
                    }
                }
            }
        }catch(CignaWSResultTooLargeException e){
            throw new AuraHandledException(Label.Error_Too_Many_Records);
        }catch(Exception e){
            throw new AuraHandledException(cHelper.getResultInfo().resultInfoDesc);
        }
        return result;
    }

    /***********************************************************************************
     * handleClaimTypes
     * @param List<HttpCalloutVO.Claim> cList
     * @return List<HttpCalloutVO.Claim>
     * @description: change the display type for the claim
     ***********************************************************************************/
    private static List<HttpCalloutVO.Claim> handleClaimTypes(List<HttpCalloutVO.Claim> cList){
        if(cList!=null){
            for(HttpCalloutVO.Claim c:cList){
                c.claimTypeDisplay=null;
                Set<String> claimTypeDisplaySet=new Set<String>();
                for(HttpCalloutVO.ClaimCoverage cc:c.coverageList){
                    if(!claimTypeDisplaySet.contains(cc.claimTypeDisplay)){
                        if(c.claimTypeDisplay==null){
                            c.claimTypeDisplay=cc.claimTypeDisplay+', ';
                        }else{
                            c.claimTypeDisplay +=cc.claimTypeDisplay+', ';
                        }
                        claimTypeDisplaySet.add(cc.claimTypeDisplay);
                    }
                }                
                if(c.claimTypeDisplay!=null && c.claimTypeDisplay.length()>0){
                    c.claimTypeDisplay=c.claimTypeDisplay.trim().substring(0, c.claimTypeDisplay.length()-2);
                }
            }
        }
        return cList;
    }

    /***********************************************************************************
     * getDocuments
     * @param String policyNo
     * @param Date effDate
     * @param String holderSSN
     * @return PolicyBasic
     * @description: get documents for individual policy
     ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static PolicyBasic getDocuments(String policyNo, Date effDate, String holderSSN){
        System.debug('get documents for '+policyNo);
        PolicyBasic result = new PolicyBasic();
        result = initCorDocList(policyNo, holderSSN, effDate);
        
        PolicyBasic tempResult = initDocList(policyNo, effDate);
        result.docYearMap = tempResult.docYearMap;
        result.docYearList = tempResult.docYearList;

        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.Name = 'Customer' AND SSN__c = :holderSSN LIMIT 1];
        if(accList.size()>0){
            result.customerAccountId = accList[0].Id;
        }
        
        return result;
    }

    /***********************************************************************************
     * initCorDocList
     * @param String policyNo
     * @param String holderSSN
     * @param Date effDate
     * @return PolicyBasic
     * @description: get Policy Correspondences for individual policy
    ***********************************************************************************/
    public static PolicyBasic initCorDocList(String policyNo, String holderSSN, Date effDate){
        PolicyBasic result = new PolicyBasic();
        try{
            PolicyCalloutHelper helper=new PolicyCalloutHelper();
            List<HttpCalloutVO.PolicyDocType> corDocList=helper.getPolicyDocTypeList(policyNo, true, 'Policy Correspondence','','','','','',holderSSN);//jack add ssn for annual statement
            processDocList(corDocList);  //added by Connor CR-47
            result = initCorDocYearMap(corDocList, effDate);
        }catch(Exception e){
            System.debug('get policy correspondence error: '+e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return result;
    }
    
     /***********************************************************************************
     * initCorDocYearMap
     * @description: for Individual 
    ***********************************************************************************/
    private static PolicyBasic initCorDocYearMap(List<HttpCalloutVO.PolicyDocType> corDocList, Date effDate){
        PolicyBasic result = new PolicyBasic();
        if(corDocList==null || corDocList.isEmpty()){
            return result;
        }

        Integer curYear=Date.today().year();
        Map<String, List<HttpCalloutVO.PolicyDocType>> corDocYearMap = new Map<String, List<HttpCalloutVO.PolicyDocType>>();
        
        corDocYearMap.put(string.valueOf(curYear),new List<HttpCalloutVO.PolicyDocType>());
        Integer effYear=effDate!=null?effDate.year():null;
        if(corDocYearMap.get(string.valueOf(effYear))==null){
            for(integer i=effYear; i<curYear ;i++){
                if(corDocYearMap.get(string.valueOf(i))==null){
                    corDocYearMap.put(string.valueOf(i),new List<HttpCalloutVO.PolicyDocType>());
                }
            }     
        }
        
        for(HttpCalloutVO.PolicyDocType d :corDocList){
            String docCreatedYear=String.isNotBlank(d.docCreatedYear)?d.docCreatedYear:'NULL';
            if(corDocYearMap.get(docCreatedYear)==null){
                List<HttpCalloutVO.PolicyDocType> tmp=new List<HttpCalloutVO.PolicyDocType>();
                tmp.add(d);
                corDocYearMap.put(docCreatedYear,tmp);
            }else{
                corDocYearMap.get(docCreatedYear).add(d);
            }
        }        
        result.corDocYearMap = corDocYearMap;
        
        List<PicklistOption> yearList = new List<PicklistOption>();
        for(String year : corDocYearMap.keySet()){
            if(year=='NULL'){
                yearList.add(new PicklistOption('',''));
            }else{
                yearList.add(new PicklistOption(year,year));
            }
        }
        yearList.sort();
        result.corDocYearList = yearList;
        return result;
    }

    /***********************************************************************************
     * initDocList
     * @param String policyNo
     * @return void
     * @description: initialize the policy document list
     ***********************************************************************************/
    public static PolicyBasic initDocList(String policyNo, Date effDate) {
        PolicyBasic result = new PolicyBasic();
        User user = [SELECT Account.SSN__c FROM User WHERE Id = :UserInfo.getUserId()];
        try{
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            List<HttpCalloutVO.PolicyDocType> documentList = helper.getPolicyDocTypeList(policyNo,true,'Policy Document','','','','','', user.Account.SSN__c);
            
            processDocList(documentList);  //added by Connor CR-47
            result = initDocYearMap(documentList, effDate);
        }catch(Exception e){
            System.debug('get policy document error:'+e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return result;
    }

    private static PolicyBasic initDocYearMap(List<HttpCalloutVO.PolicyDocType> docList, Date effDate){
        PolicyBasic result = new PolicyBasic();
        if(docList==null || docList.isEmpty()){
            return result;
        }

        Map<String, List<HttpCalloutVO.PolicyDocType>> docYearMap = new Map<String, List<HttpCalloutVO.PolicyDocType>>();
        Integer effYear = effDate!=null ? effDate.year() : (Date.today().year()-2);
        Integer latestDocYear = effYear;

        for(HttpCalloutVO.PolicyDocType d :docList){
            // if attachment policy year is not blank, use it as the document year
            // if attachment policy year is blank, use the created date as the document year
            String docCreatedYear=String.isNotBlank(d.docPolicyYear) ? d.docPolicyYear : (String.isNotBlank(d.createdDateStr)?d.createdDateStr.substring(0,4):'NULL');
            if(Integer.valueOf(docCreatedYear) > latestDocYear){
                latestDocYear = Integer.valueOf(docCreatedYear);
            }
            // Rancho_HKITSFDC150_20250210 - document name starts with _INB belongs to inital year
            String processedDocName = String.isBlank(d.fileName) ? '' : d.fileName.substring(d.fileName.indexOf('_'));
            System.debug('processed doc name: '+processedDocName);
            if(String.isNotBlank(processedDocName) && processedDocName.startsWith('_INB')){
                docCreatedYear = String.valueOf(effYear);
            }
            
            if(docYearMap.containsKey(docCreatedYear)){
                docYearMap.get(docCreatedYear).add(d);
            }else{
                docYearMap.put(docCreatedYear, new List<HttpCalloutVO.PolicyDocType>{d});
            }
        }
        result.docYearMap = docYearMap;
        result.docYearList = getYearList(String.valueOf(effYear), String.valueOf(latestDocYear));
        System.debug('doc year list: '+result.docYearList);
        return result;
    }

    private static List<PicklistOption> getYearList(String createdYear, String policyDocYear) {
        List<PicklistOption> returnOwList = new List<PicklistOption>();
        // Rancho_HKITSFDC70_20240802 - avoid duplicate values
        if(Integer.valueOf(createdYear) < (Integer.valueOf(policyDocYear) - 2)) {
            returnOwList.add(new PicklistOption(createdYear, createdYear));

            for(Integer i = Integer.valueOf(policyDocYear) - 2; i <= Integer.valueOf(policyDocYear); i++){
                returnOwList.add(new PicklistOption(String.valueOf(i), String.valueOf(i)));
            }
        }else{
            for(Integer i = Integer.valueOf(createdYear); i <= Integer.valueOf(policyDocYear); i++){
                returnOwList.add(new PicklistOption(String.valueOf(i), String.valueOf(i)));
            }
        }

        returnOwList.sort();

        return returnOwList;
    }

    private static void processDocList(List<HttpCalloutVO.PolicyDocType> docList){
        Set<String> attKeySet = new Set<String>();
        for(HttpCalloutVO.PolicyDocType pd : docList){
            attKeySet.add(pd.attachmentKey);
        }
        List<AccountChangeLog__c> logList = [SELECT CreatedBy.Name,Key__c,CreatedDate FROM AccountChangeLog__c WHERE Key__c IN :attKeySet ORDER BY CreatedDate DESC];
        Map<String,AccountChangeLog__c> logMap = new Map<String,AccountChangeLog__c>();
        for(AccountChangeLog__c reader : logList){
            if(!logMap.containsKey(reader.Key__c)){
                logMap.put(reader.Key__c, reader);
            }
        }   
        for(HttpCalloutVO.PolicyDocType pd : docList){
            if(logMap.containsKey(pd.attachmentKey)){
                pd.hiddenBy = logMap.get(pd.attachmentKey).CreatedBy.Name;
                pd.hiddenDateStr = String.valueOf(logMap.get(pd.attachmentKey).CreatedDate.date());
            }else{
                pd.hiddenBy = 'N/A';
                pd.hiddenDateStr = 'N/A';
            }
        }
    }

    @AuraEnabled
    public static HttpCalloutVO.PolicyDocType toggleDocState(HttpCalloutVO.PolicyDocType targetDoc, String holderSSN){
        if(null==targetDoc){
            return null;
        }

        String attKeyVisibility = targetDoc.attachmentKey;
        String docNameVisibility = targetDoc.description;
        String newStatus = 'Y'.equalsIgnoreCase(targetDoc.status) ? 'H' : 'Y'; //JL20211028 - AH23297 - Add

        try{
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            List<HttpCalloutVO.PolicyDocType> wsResult = helper.updatePolicyDoc(attKeyVisibility,newStatus);

            if('Success'.equals(wsResult[0].resultCode)){
                String customerAccountId = '';
                List<Account> accList = [SELECT Id FROM Account WHERE RecordType.Name = 'Customer' AND SSN__c = :holderSSN LIMIT 1];
                if(accList.size()>0){
                    customerAccountId = accList[0].Id;
                }

                targetDoc.status = newStatus;
                //JL20211028 - AH23297 if('N'.equalsIgnoreCase(newStatus)){  // N, to hide
                if('H'.equalsIgnoreCase(newStatus)){    //JL20211028 - AH23297 - Add - Change the hide statu from N to H
                    AccountChangeLog__c log = new AccountChangeLog__c();
                    log.Account__c = customerAccountId;
                    log.Key__c = attKeyVisibility;
                    log.event_detail__c = ' hide the document ' + docNameVisibility;
                    insert log;
                    targetDoc.hiddenBy = UserInfo.getName();
                    targetDoc.hiddenDateStr = String.valueOf(system.today()); 
                }else{  // Y, to show
                    AccountChangeLog__c log = new AccountChangeLog__c();
                    log.Account__c = customerAccountId;
                    log.Key__c = attKeyVisibility;
                    log.event_detail__c = ' showed the document ' + docNameVisibility;
                    insert log;
                }
                return targetDoc;
            }else{
                return null;
            }
        }catch(Exception e){
            System.debug('toggle doc state error: '+e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***********************************************************************************
     * getPolicyPersonCoverageBasic
     * @description: 1.Get Plan_Code_Claim_Type__c List from database
     *               2.Call getPolicyPersonCoverageBasic WS to get Coverage list
     ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static PolicyBasic getPolicyPersonCoverageBasic(String policyNo){
        PolicyBasic result = new PolicyBasic();
        if(String.isBlank(policyNo)){
            return null;
        }

        Boolean isTDUser = policyNo.startsWithIgnoreCase(CignaUtil.cusFuncTD)? true : false;
        System.debug('isTDUser: '+isTDUser + ' ' + policyNo + ' ' + CignaUtil.cusFuncTD);
        List<HttpCalloutVO.PolicyPersonCoverage> coverageList = new List<HttpCalloutVO.PolicyPersonCoverage>();
        if(!isTDUser){
            List<Plan_Code_Claim_Type__c> pccList = [SELECT Plan_Code__c, Rate_Scale__c FROM Plan_Code_Claim_Type__c WHERE TOPUP__c = TRUE]; 
            Map<String, Set<String>> planCodeMap = new Map<String, Set<String>>();           
            for(Plan_Code_Claim_Type__c pcc : pccList){
                if(planCodeMap.containsKey(pcc.Plan_Code__c)){
                    Set<String> rateScale = planCodeMap.get(pcc.Plan_Code__c);
                    rateScale.add(pcc.Rate_Scale__c);
                }else{
                    Set<String> rateScale = new Set<String>();
                    rateScale.add(pcc.Rate_Scale__c);
                    planCodeMap.put(pcc.Plan_Code__c, rateScale);
                }
            }   

            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            coverageList = helper.getPolicyPersonCoverageBasic(policyNo,'');
            if(!coverageList.isEmpty()){
                for(HttpCalloutVO.PolicyPersonCoverage c:coverageList){
                    if(planCodeMap.containsKey(c.benefitCode)){
                        Set<String> rateScale=planCodeMap.get(c.benefitCode);
                        if(rateScale.contains(c.rateScale)){
                            result.showDeductible=TRUE;
                        }
                    }
                }
            }

            // Maturity, Expiry Date
            Set<String> benefitCodeSet=new Set<String>();
            for(HttpCalloutVO.PolicyPersonCoverage c : coverageList){
                if(c.maturityexpiryDate==null || c.maturityexpiryDate==''){
                    c.maturityexpiryDate='N/A';
                }
                if(String.isNotBlank(c.benefitCode)){
                    benefitCodeSet.add(c.benefitCode);
                }
                if(c.benefitCode.startsWith('AFCR') || c.benefitCode.startsWith('AFCS')){
                    result.showAFCcolumns=true;
                }
            }
            
            // Benefit Code
            List<Plan_Code_Claim_Type__c> benefitList=[SELECT Plan_code__c, Plan_Title__c FROM Plan_Code_Claim_Type__c Where Plan_code__c in :benefitCodeSet];
            Map<String,String> benefitMap=new Map<String,String>();
            for(Plan_Code_Claim_Type__c c: benefitList){
                benefitMap.put(c.Plan_code__c, c.Plan_Title__c);
            }
            for(HttpCalloutVO.PolicyPersonCoverage c : coverageList){
                if(String.isNotBlank(c.benefitCode) && benefitMap.containsKey(c.benefitCode)){
                    c.benefitDesc=benefitMap.get(c.benefitCode);
                }
            }
        }
        result.coverageList = coverageList;
        
        return result;
    }

    /**
     * Health migration identify cancel policy
     * 20221216 - minghua - JOBR-285 Health Migration
     * 20230106 - minghua - JOBR-296 Indicator for L policies wrongly set up as G
     * @Author   Gong,Minghua
     * @DateTime 2022-12-16
     */
    @AuraEnabled
    public static String cancelPolicy(String recordId, String policyNo, String holderSSN, Boolean newStatus){
        Health_Migration_Cancel_Policy__c hMCancelPol = new Health_Migration_Cancel_Policy__c(Id=recordId, Policy_Number__c=policyNo, SSN__c=holderSSN, Cancelled__c=newStatus);
        upsert hMCancelPol;
        return hMCancelPol.Id;
    }

    /********************************************************************
     * resendWelcomeEmail
     * @decs call WS for sending welcome email to users
     * @author Rancho_JOBR57_20211115
     * @return null
     ********************************************************************/
    @AuraEnabled
    public static Boolean resendWelcomeEmail(String policyNo){
        if(String.isNotBlank(policyNo)){
            WelcomeEmailCalloutHelper helper = new WelcomeEmailCalloutHelper();
            try{
                Boolean result = helper.sendWelcomEmail(policyNo);
                return result;
            }catch(Exception e){
                System.debug('ErrorDetail: '+e.getMessage());
                System.debug(e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        }
        return false;
    }

    @AuraEnabled
    public static String getDoc2(String policyNo, String targetAttachmentKey){
        if(String.isNotBlank(policyNo) && String.isNotBlank(targetAttachmentKey)){
            File_Store__c fileStore=new File_Store__c();
            fileStore.OwnerId=UserInfo.getUserId();
            fileStore.Owner_id__c=UserInfo.getUserId();
            insert fileStore;
            
            // Rancho_HKITSFDC321_20251013 - WS insert document instead of insert in apex
            // Attachment tempAtt=new Attachment();
            // tempAtt.parentId=fileStore.Id;
            // tempAtt.contentType='application/pdf';
            // tempAtt.name=targetAttachmentKey;
            // tempAtt.body=Blob.valueOf('');
            // insert tempAtt;
            // System.enqueueJob(new downloadDocQueue(policyNo, targetAttachmentKey, UserInfo.getLanguage(), tempAtt.Id));
            // return tempAtt.Id;
            System.enqueueJob(new downloadDocQueue(policyNo, targetAttachmentKey, UserInfo.getLanguage(), '', '', '', fileStore.Id));
            return fileStore.Id;
        }
        return null;
    }

    // Rancho_HKITSFDC321_20251013 - search the attachment under file store
    // @AuraEnabled
    // public static Boolean checkIsDocumentDownloadComplete(String selectedDowlAttId){
    //     Boolean isDownloadComplete = false;
    //     if(selectedDowlAttId != null){
    //         Attachment a = [SELECT Id, Body FROM Attachment WHERE Id = :selectedDowlAttId];
    //         if(a.Body != null && a.Body.size() > 0){
    //             isDownloadComplete = true;
    //         }
    //     }
    //     return isDownloadComplete;
    // }

    @AuraEnabled
    public static String checkIsDocumentDownloadComplete(String fileStoreId){
        String attId;
        if(String.isNotBlank(fileStoreId)){
            List<Attachment> aList = [SELECT Id, BodyLength FROM Attachment WHERE ParentId = :fileStoreId];
            if(aList != null && aList.size() > 0){
                Attachment a = aList.get(0);
                if(a.BodyLength != null && a.BodyLength > 0){
                    attId = a.Id;
                }
            }
        }
        return attId;
    }

    @AuraEnabled
    public static String validateCreditCardNumber(String policyNo, String creditCardNo){
        Boolean isCreditCardNumberValid = false;
        Boolean isWebServiceCallSuccess = false;
        String validationResultMessage = Label.Invalid;
        
        if(null!=policyNo && null!=creditCardNo && 16==creditCardNo.length() && creditCardNo.isNumeric()){
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            List<HttpCalloutVO.CreditCardNumber> tempList = helper.verifyPolicyInfo(policyNo, creditCardNo);
            System.debug('validate result list: '+tempList);
            
            if(null!=tempList){
                System.debug('TEMP - tempList is not NULL'); 
                isWebServiceCallSuccess = tempList.get(0).isWebServiceCallSuccess;
                isCreditCardNumberValid = tempList.get(0).isCreditCardNumberValid;
            }
            
            if(isWebServiceCallSuccess){
                if(isCreditCardNumberValid){
                    validationResultMessage = Label.Valid;
                }
            }else{
                validationResultMessage = Label.VerifyPolicyInfo_WS_Failed;
            }
        }
        System.debug('message: '+validationResultMessage);
        
        return validationResultMessage;
    }

    public class PolicyBasic{
        @AuraEnabled public HttpCalloutVO.Policy policy;
        @AuraEnabled public HttpCalloutVO.Person holder;
        @AuraEnabled public List<HttpCalloutVO.Person> insuredList;
        @AuraEnabled public List<HttpCalloutVO.Exclusion> exclusionList;
        @AuraEnabled public List<HttpCalloutVO.Loading> loadingList;
        @AuraEnabled public List<HttpCalloutVO.Claim> claimList;
        @AuraEnabled public List<Claim__c> claimHistoryList;
        @AuraEnabled public String personInsureId;
        @AuraEnabled public String customerAccountId;
        @AuraEnabled public Map<String, List<HttpCalloutVO.PolicyDocType>> docYearMap;
        @AuraEnabled public List<PicklistOption> docYearList;
        @AuraEnabled public Map<String, List<HttpCalloutVO.PolicyDocType>> corDocYearMap;
        @AuraEnabled public List<PicklistOption> corDocYearList;
        @AuraEnabled public List<HttpCalloutVO.PolicyPersonCoverage> coverageList;
        @AuraEnabled public Boolean showDeductible = false;
        @AuraEnabled public Boolean showAFCcolumns = false;
        @AuraEnabled public Boolean wfh = false;
        @AuraEnabled public Boolean isCS = false;
        @AuraEnabled public Boolean isTM = false;
        @AuraEnabled public String healthMigrationCancelPolicyId;
    }

    public class PicklistOption implements Comparable {
        @AuraEnabled public String label{get; set;}
        @AuraEnabled public String value{get; set;}
        
        public PicklistOption(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public Integer compareTo(Object compareTo) {
            PicklistOption compareToPicklist = (PicklistOption)compareTo;
            return this.value.compareTo(compareToPicklist.value);
        }
    }
    
    // START HKITSFDC-416
    @AuraEnabled(cacheable=true)
    public static List<String> getCIProductCodes() {
    	List<String> codes = new List<String>();

        for (App_ProductFunction_Setting__c s :[SELECT ProductCode__c FROM App_ProductFunction_Setting__c WHERE Type__c = 'ShowCoverageCIFields' AND ProductCode__c != null]) 
        {
            codes.add(s.ProductCode__c);
        }

        return codes;
    }
    // END HKITSFDC-416
    
}