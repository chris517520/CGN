/*********************************************************************************
 * Name: SearchTemplateController
 *
 * Version History
 * Version           Author                 Date                      Description
 * ---------------  --------------------    -----------------------  ---------------------------------------------------------
 * V1.0              Patrick               2016-11-22                For common search function
 * V2.0              Franco                2017-03-14                Webservice Integration
*********************************************************************************/

public without sharing class CommonSearchCompController{
    
    public static final String POLICY_HOLDER_ID = 'POLICY_HOLDER_ID';
    public  static final String POLICY_HOLDER_NAME = 'POLICY_HOLDER_NAME';
    public static final String PERSON_INSURED_ID = 'PERSON_INSURED_ID';
    public static final String PERSON_INSURED_NAME = 'PERSON_INSURED_NAME';
    //Rancho_JR1878_20210104
    public static final String POLICY_NUMBER = 'POLICY_NUMBER';
    public static final String PAGE_TYPE_NAME='BrkMyClaimVFP';
    public Boolean isHolderSearch{get;set;}
    public String policyNumber{get;set;}
    public List<CommonObject> CommonPHResultList{get;set;}
    // public Map<String, List<HttpCalloutVO.Person>> personInsuredMap{get;set;}
    public Integer currentPageNoPH{get;set;}
    public Integer startIndexPH{get;set;}

    public string pageTypeNameParam{get;set;} 

    private static final Integer PAGE_SIZE = 20;
    private static final Integer DATE_LENGTH = 21;
    
    private PersonCalloutHelper helper;
      
    //Display result   
    public List<CommonObject> CommonResultList{get;set;}
    
    public String SearchInputText{get;set;}
    public String SearchType{get;set;}
    public String SelectOption{get;set;}
    
    public String backPolicyHolderId{get;set;}
    public String claimIdFromEdit{get;set;}
    public Boolean showTooManyRecordError{get;set;}
    public Boolean isFirstTimeComeHere{get;set;}
    public String errorMessage{get;set;}
    public String paramSearchType{get;set;}
    public String paramSeachValue{get;set;}
    
    public Integer currentPageNo{get;set;}
    public Integer startIndex{get;set;}
    
    public Boolean isDummyData{get;set;} {isDummyData = false;}

    //JR1840 jack add
    public String encryptedSearchCriteria{get;set;}
    public String searchInfo{get;set;}
    public final String URLParamName{get;private set;} {URLParamName = 'FLTR';}

    public CommonSearchCompController(){
        // Rancho_JR1878_20210104
        isHolderSearch = false;
        commonPHResultList = new List<CommonObject>();
        system.debug('test isClaimPage  ' + isClaimPage);
        showTooManyRecordError = false;
        isFirstTimeComeHere = true;
        currentPageNo = 1;
        startIndex = 0;
        CommonResultList = new List<CommonObject>();
        //helper = new PersonCalloutHelper(PAGE_SIZE);
        //JR1840 jack add
        system.debug('CommonSearchCompController');
        getSearchInfoAndSearch();
        system.debug('test isClaimPage  ' + isClaimPage);
        system.debug('pageTypeNameParam  ' + pageTypeNameParam);
    }
    
    //JR1840 jack add
    public void getSearchInfoAndSearch(){
        system.debug('searchInfo'+searchInfo+'pageTypeNameParam'+pageTypeNameParam);
        String filterDataString;
        if(String.isNotBlank(searchInfo)){
            filterDataString= searchInfo;
        }else{
            //Checkmarx high security: reflected XSS  20220518 Link
            String encryptedFilter = ApexPages.currentpage().getparameters().get(URLParamName);
            System.debug('encryptedFilter'+encryptedFilter);
            if(!String.isEmpty(encryptedFilter)){
                filterDataString = EncryptionUtil.decryptStrAES128(encryptedFilter);
            }
        }
        System.debug('filterDataString'+filterDataString);
        if(String.isNotBlank(filterDataString)){
            try{
                FilterData filterData = new FilterData(filterDataString);
                
                system.debug('filterData'+filterData+'pageTypeNameParam '+pageTypeNameParam);
                // Rancho_JR1878_20210104
                if(((filterData.URLFltrType == PERSON_INSURED_NAME || filterData.URLFltrType == Person_Insured_ID)) || ((filterData.URLFltrType == POLICY_HOLDER_NAME || filterData.URLFltrType == POLICY_HOLDER_ID)) || filterData.URLFltrType == POLICY_NUMBER){
                    SearchInputText = CignaUtil.SFDC_JSENCODE(filterData.URLFltrVal);/* add by Jack on 2022-06-22 for project: Checkmarx SOQL injection */
                    SearchType = CignaUtil.SFDC_JSENCODE(filterData.URLFltrType);/* add by Jack on 2022-06-22 for project: Checkmarx SOQL injection */
                }
                if(filterData.URLCatType ==PAGE_TYPE_NAME){
                    pageTypeNameParam = PAGE_TYPE_NAME;
                    System.debug('pageTypeNameParam:'+pageTypeNameParam);
                }
                if(String.isNotBlank(SearchInputText)){
                    String temp = String.join(SearchInputText.split(' '), '');
                    system.debug('temp'+temp);
                    if(temp.length() >= 2){
                        policyHolderSearch();
                        system.debug('totalPages'+totalPages +'filterData.URLCurPage'+filterData.URLCurPage);
                        if(totalPages >= filterData.URLCurPage ){
                            for(Integer i=1;i<filterData.URLCurPage;i++){
                                handleNextPage();
                            }
                        }
                    }
                }
            }catch(exception e){
                system.debug(e);
            }
        }
    }

    public void getEncryptedString(){
        encryptedSearchCriteria = '';
        system.debug('getEncryptedString() SearchType'+SearchType+' SearchInputText:'+SearchInputText+'currentPage'+currentPage);
        // Rancho_JR1878_20210104
        encryptedSearchCriteria = FilterData.encryptSearchCriteria(pageTypeNameParam,SearchType, SearchInputText, currentPage);
        system.debug('getEncryptedString() encryptedSearchCriteria:'+encryptedSearchCriteria);
    }

    //JR1840 jack add

    public void init(){
        // Control back button give back holderId and display the search result
        //Checkmarx high security: reflected XSS  20220518 Link
        /* add by Jack on 2022-06-22 for project: Checkmarx SOQL injection */
        backPolicyHolderId = CignaUtil.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('backId'));
        if(isESalesPage){
            paramSearchType = CignaUtil.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('searchType'));
            paramSeachValue = CignaUtil.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('searchValue'));
            if(String.isNotBlank(paramSearchType)){
                SearchType = paramSearchType;
            }
            if(String.isNotBlank(paramSeachValue)){
                SearchInputText = paramSeachValue;
            }
        }else{
            if(String.isNotBlank(backPolicyHolderId)){
                SearchType = POLICY_HOLDER_ID;
                SearchInputText = backPolicyHolderId;
                //policyHolderSearch();
            }else{
                //getCommonDataObjData();
            }
        }
        
        if(!isClaimPage){
            policyHolderSearch();
        }
    }

    
    //set the ESales and Policy Change
    public List<SelectOption> getSearchCriteria(){
       //Category picklist        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(POLICY_HOLDER_NAME, System.Label.Pol_Policy_holder_name));
        options.add(new SelectOption(POLICY_HOLDER_ID, System.Label.Policy_Holder_ID));
        return options;
    }
    
    // set the claim option
    public List<SelectOption> getClaimSearchCriteria(){
       //Category picklist        
        List<SelectOption> claimsOption = new List<SelectOption>();
        claimsOption.add(new SelectOption(PERSON_INSURED_NAME, System.Label.Person_Insured));
        claimsOption.add(new SelectOption(PERSON_INSURED_ID, System.Label.Person_Insured_ID));
        //Rancho_JR1878_20210104
        claimsOption.add(new SelectOption(POLICY_NUMBER, System.Label.Policy_Number));
        claimsOption.add(new SelectOption(POLICY_HOLDER_NAME, System.Label.Pol_Policy_holder_name));
        claimsOption.add(new SelectOption(POLICY_HOLDER_ID, System.Label.Policy_Holder_ID));
        return claimsOption;
    }
    
    public void getCommonDataObjData (){
        showTooManyRecordError = false;
        currentPageNo = 1;
        startIndex = 0;
        commonResultList = new List<CommonObject>();
        // get customer information from WS API
        List<HttpCalloutVO.Person> personResultList = new List<HttpCalloutVO.Person>();
        
        try{
            // old : personResultList = helper.getPersonListBasicByCriteria('', '', '', '', PersonCalloutHelper.ANYPERSON);
            PolicyCalloutHelper policyHelper = new PolicyCalloutHelper();
            List<HttpCalloutVO.Policy> wsPolicyList = new List<HttpCalloutVO.Policy>();
            wsPolicyList = policyHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', '', '', '');
            //wsPolicyList.addAll(policyHelper.getGroupPolicyListBasicByCriteria('', '', '', '', '', '', '', ''));
            for(HttpCalloutVO.Policy policy : wsPolicyList){
                personResultList.add(policy.holder);
                personResultList.addAll(policy.insuredList);
            }
            converWSObjectToCommonObject(personResultList);
        }catch(CignaWSResultTooLargeException e1){
            showTooManyRecordError = True;
            errorMessage = Label.WS_result_set_size_is_over_1000;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } /*catch(CignaWSTimeoutException e2){
            showTooManyRecordError = True;
            errorMessage = Label.WS_Connection_Timeout;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            showTooManyRecordError = True;
            errorMessage = e3.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e3.getMessage()));
        }catch(Exception e4){
            // Handle the exception
            showTooManyRecordError = True;
            errorMessage = e4.getMessage();
        }*/
        
    }

    public PageReference policyHolderSearch(){ 
        //call web service and get the result
        // pass id/name and page type
        // Rancho_JR1878_20210104
        isHolderSearch=false;
        // personInsuredMap = new Map<String, List<HttpCalloutVO.Person>>();

        showTooManyRecordError = false;
        currentPageNo = 1;
        startIndex = 0;
        commonResultList = new List<CommonObject>();
        List<HttpCalloutVO.Person> personList = new List<HttpCalloutVO.Person>();
        system.debug('test SearchType ' + SearchType);
        system.debug('test SearchInputText  ' + SearchInputText);
        system.debug('test isClaimPage  ' + isClaimPage);
        
        try{
            
            if(SearchType != null){
                /*String relationRoleCode = PersonCalloutHelper.ANYPERSON;
                if(searchType == POLICY_HOLDER_ID || searchType == POLICY_HOLDER_NAME){
                    relationRoleCode = PersonCalloutHelper.OWNER;
                }else if(searchType == PERSON_INSURED_ID || searchType == PERSON_INSURED_NAME){
                    relationRoleCode = PersonCalloutHelper.INSURED;
                }
                if(SearchType == POLICY_HOLDER_ID || SearchType == PERSON_INSURED_ID){
                    personList = helper.getPersonListBasicByCriteria(SearchInputText, '', '', '', relationRoleCode);
                }else if(SearchType == POLICY_HOLDER_NAME || SearchType == PERSON_INSURED_NAME){
                    personList = helper.getPersonListBasicByCriteria('', SearchInputText, '', '', relationRoleCode);
                }*/
                PolicyCalloutHelper policyHelper = new PolicyCalloutHelper();
                List<HttpCalloutVO.Policy> wsPolicyList = new List<HttpCalloutVO.Policy>();
                if(SearchType == POLICY_HOLDER_NAME){
                    // Rancho_JR1878_20210104
                    if(isClaimPage){
                        isHolderSearch = true;
                    }
                    wsPolicyList = policyHelper.getIndividualPolicyListBasicByCriteria('', SearchInputText, '', '', '', '', '', '');
                    //wsPolicyList.addAll(policyHelper.getGroupPolicyListBasicByCriteria('', SearchInputText, '', '', '', '', '', ''));
                    for(HttpCalloutVO.Policy policy : wsPolicyList){
                        HttpCalloutVO.Person person = policy.holder;
                        person.policyNumber = policy.policyNumber;
                        personList.add(person);
                        // if(!personInsuredMap.containsKey(policy.policyNumber)){
                        //     personInsuredMap.put(policy.policyNumber, policy.insuredList);
                        // }
                    }
                }else if(searchType == POLICY_HOLDER_ID){
                    // Rancho_JR1878_20210104
                    if(isClaimPage){
                        isHolderSearch = true;
                    }
                    wsPolicyList = policyHelper.getIndividualPolicyListBasicByCriteria('', '', SearchInputText, '', '', '', '', '');
                    //wsPolicyList.addAll(policyHelper.getGroupPolicyListBasicByCriteria('', '', SearchInputText, '', '', '', '', ''));
                    for(HttpCalloutVO.Policy policy : wsPolicyList){
                        HttpCalloutVO.Person person = policy.holder;
                        person.policyNumber = policy.policyNumber;
                        personList.add(person);
                        // if(!personInsuredMap.containsKey(policy.policyNumber)){
                        //     personInsuredMap.put(policy.policyNumber, policy.insuredList);
                        // }
                    }
                }else if(SearchType == PERSON_INSURED_NAME){
                    wsPolicyList = policyHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', SearchInputText, '', '', '');
                    //wsPolicyList.addAll(policyHelper.getGroupPolicyListBasicByCriteria('', '', '', '', SearchInputText, '', '', ''));
                    for(HttpCalloutVO.Policy policy : wsPolicyList){
                        personList.addAll(policy.insuredList);
                    }
                }else if(SearchType == PERSON_INSURED_ID){
                    wsPolicyList = policyHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', SearchInputText, '', '');
                    //wsPolicyList.addAll(policyHelper.getGroupPolicyListBasicByCriteria('', '', '', '', '', SearchInputText, '', ''));
                    for(HttpCalloutVO.Policy policy : wsPolicyList){
                        personList.addAll(policy.insuredList);
                    }
                // Rancho_JR1878_20210104
                }else if(SearchType==POLICY_NUMBER){
                    if(isClaimPage){
                        isHolderSearch=true;
                    }
                    wsPolicyList=policyHelper.getIndividualPolicyListBasicByCriteria(SearchInputText,'','','','','','','');
                    for(HttpCalloutVO.Policy policy : wsPolicyList){
                        HttpCalloutVO.Person person = policy.holder;
                        person.policyNumber = policy.policyNumber;
                        personList.add(person);
                        // if(!personInsuredMap.containsKey(policy.policyNumber)){
                        //     personInsuredMap.put(policy.policyNumber, policy.insuredList);
                        // }
                    }
                }
            }
            
            converWSObjectToCommonObject(personList);
            
        }catch(CignaWSResultTooLargeException e1){
            showTooManyRecordError = True;
            errorMessage = Label.WS_result_set_size_is_over_1000;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        } /*catch(CignaWSTimeoutException e2){
            showTooManyRecordError = True;
            errorMessage = Label.WS_Connection_Timeout;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            showTooManyRecordError = True;
            errorMessage = e3.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e3.getMessage()));
        }catch(Exception e4){
            // Handle the exception
            showTooManyRecordError = True;
            errorMessage = e4.getMessage();
        }*/
        
        return null;
    }
    
    public void converWSObjectToCommonObject(List<HttpCalloutVO.Person> personList){
        commonResultList = new List<CommonObject>();
        isFirstTimeComeHere = false;
        Map<String, CommonObject> commonResultMap = new Map<String, CommonObject>();
        if(personList != null && personList.size()>0){
            List<String> ssnList = new List<String>();
            Map<String, User> userMap = new Map<String, User>();
            for(HttpCalloutVO.Person p : personList){
                ssnList.add(p.ssnNumber);
            }
            system.debug('### ssnNumberList: ' + ssnList);
            for(User u : [Select id, Name, Username, Account.SSN__c, Contact_No__c, Contact_No_Country_Code__c From User where Account.SSN__c != null and Account.SSN__c in : ssnList]){
                userMap.put(u.Account.SSN__c, u);
            }
            for(HttpCalloutVO.Person p : personList){
                if(isClaimPage && p.isIndividual != null && !p.isIndividual){
                    continue;  // for claim, dont show group policy pi
                }
                ssnList.add(p.ssnNumber);
                CommonObject co = new CommonObject();
                co.policyNumber = p.policyNumber; // Rancho_JR1878_20210104
                co.Name = p.fullName;
                co.Id =  p.ssnNumber;
                //co.Email =  p.emailAddress;
                if(userMap.containsKey(p.ssnNumber)){
                    co.Email = userMap.get(p.ssnNumber).Username;
                }
                co.DateOfBitrh = p.birthDateInDate;
                co.ContactNo = p.mobilePhoneNo;
                co.countryCode = p.mobileCountryCode;
                if(userMap.containsKey(p.ssnNumber)){
                    /*if(userMap.get(p.ssnNumber).Contact_No_Country_Code__c != null && userMap.get(p.ssnNumber).Contact_No_Country_Code__c != ''){
                        co.ContactNo = userMap.get(p.ssnNumber).Contact_No_Country_Code__c + ' ';
                    }
                    else{
                        co.ContactNo = '';
                    }*/
                    if(userMap.get(p.ssnNumber).Contact_No__c != null && userMap.get(p.ssnNumber).Contact_No__c != ''){
                        co.ContactNo = userMap.get(p.ssnNumber).Contact_No__c;
                    }
                    
                    if(userMap.get(p.ssnNumber).Contact_No_Country_Code__c != null && userMap.get(p.ssnNumber).Contact_No_Country_Code__c != ''){
                        co.countryCode = userMap.get(p.ssnNumber).Contact_No_Country_Code__c;
                    }
                }
                co.fullContactNo = co.ContactNo;
                if(co.countryCode!=null && co.countryCode!=''){
                    co.fullContactNo = co.countryCode+' '+co.ContactNo;
                }
                co.firstName = p.firstName;
                co.lastName = p.lastName;
                //co.countryCode = p.mobileCountryCode;
                if(p.birthDateInDate != null){
                    co.phBirth = String.valueof(p.birthDateInDate);
                }
                co.phId = p.policyHolderId;
                System.Debug('co.phId: ' + co.phId);
                //commonResultList.add(co);
                commonResultMap.put(co.Id, co);
            }
            commonResultList = commonResultMap.values();
        }
        
        
        if(isDummyData){
            CommonObject co = new CommonObject();
            co.Name = 'Cherry Huang';
            co.Id =  'G708586';
            co.Email =  'testd@test.com';
            co.DateOfBitrh = Date.valueof('1990-01-01');
            co.ContactNo = '1234555'; 
            commonResultList.add(co);
        }
    }
    
    public Integer totalPages{
        get{
            //return helper.getTotalPage();
            return commonResultList.size() == 0 ? 1 : (commonResultList.size() + PAGE_SIZE - 1)/PAGE_SIZE;
        }
    }
    
    public Integer currentPage{
        get{
            //return helper.getCurrentPageNumber();
            return currentPageNo;
        }
    }
    
    public Integer pageSize{
        get{
            return PAGE_SIZE;
        }
    }
    
    public Boolean hasNext{
        get{
            //return helper.hasNext();
            return currentPage < totalPages;
        }
    }
    
    public Boolean hasPrev{
        get{
            //return helper.hasPrev();
            return currentPage > 1;
        }
    }
    
    public PageReference handleNextPage(){
        //List<HttpCalloutVO.Person> personList = (List<HttpCalloutVO.Person>) helper.nextPage();
        //converWSObjectToCommonObject(personList);
        if(hasNext){
            currentPageNo += 1;
            startIndex += PAGE_SIZE;
        }
        return null;
    }
    
    public PageReference handlePrevPage(){
        //List<HttpCalloutVO.Person> personList = (List<HttpCalloutVO.Person>) helper.prevPage();
        //converWSObjectToCommonObject(personList);
        if(hasPrev){
            currentPageNo -= 1;
            startIndex -= PAGE_SIZE;
        }
        return null;
    }

    public Boolean isESalesPage{
        get{
            return String.isNotBlank(pageTypeNameParam) && pageTypeNameParam.containsIgnoreCase('ESale');
        }
    }
    
    public Boolean isClaimPage{
        get{
            return String.isNotBlank(pageTypeNameParam) && pageTypeNameParam.containsIgnoreCase('Claim');
        }
    }
    
    public Boolean isPolicychangePage{
        get{
            return String.isNotBlank(pageTypeNameParam) && pageTypeNameParam.containsIgnoreCase('PolicyChange');
        }
    }
     
    public class CommonObject{
        public String Name{get;set;}
        public String Id{get;set;}
        public String Email{get;set;}
        public String ContactNo{get;set;}
        public String fullContactNo{get;set;}
        public Date DateOfBitrh{get;set;}
        
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String countryCode{get;set;}
        public String phBirth{get;set;}
        public String phId{get;set;}
        public String policyNumber{get;set;} //Rancho_JR1878_20210104
    }

    // Rancho_JR1878_20210104
    public void selectPolicyHolderToPersonInsured(){
        isHolderSearch=false;
        showTooManyRecordError = false;
        currentPageNoPH=currentPageNo;
        startIndexPH=startIndex;
        currentPageNo = 1;
        startIndex = 0;
        commonPHResultList = new List<CommonObject>();
        commonPHResultList = commonResultList;
        commonResultList = new List<CommonObject>();
        HttpCalloutVO.PolicyRequest request = new HttpCalloutVO.PolicyRequest();
        PolicyCalloutHelper polyCalHlp = new PolicyCalloutHelper();

        if(String.isNotBlank(policyNumber)){
            List<HttpCalloutVO.Person> personList=polyCalHlp.getPolicyInsuredListBasic(policyNumber, true);
            converWSObjectToCommonObject(personList);
        }
        // if(String.isNotBlank(policyNumber) && personInsuredMap!=null && !personInsuredMap.isEmpty()){
        //     if(personInsuredMap.containsKey(policyNumber)){
        //         List<HttpCalloutVO.Person> personList = personInsuredMap.get(policyNumber);
        //         converWSObjectToCommonObject(personList);
        //     }
        // }
    }
    public void phSearchBack(){
        isHolderSearch=true;
        isFirstTimeComeHere = false;
        showTooManyRecordError = false;
        currentPageNo = currentPageNoPH;
        startIndex = startIndexPH;
        commonResultList = new List<CommonObject>();
        if(commonPHResultList!=null){
            commonResultList = commonPHResultList;
        }
    }
}