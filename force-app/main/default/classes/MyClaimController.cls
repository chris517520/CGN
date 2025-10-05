/********************************************************************************
Apex Class Name - MyClaimcontroller
Version - 1.0
Created Date - Oct 26, 2016
@description 
Controlloer for MyClaimVFP 
- list all record that allow to show on screen
- different status may affect display on screen or not, please check submit on claim at JIRA

remarks: 
public List<HttpCalloutVO.Claim> GetClaimListBasicByCriteria(String claimNumber, String claimStatus, String policyNumber, String holderSSNnumber, String holderName, String insuredSSNnumber, String insuredName, Boolean isBrokerClaim, Integer startRecordIndex, Integer recordCount) 
@claimStatus eg. All/Completed/InProgress 
        
Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer             Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       Wincy             26/10/2016               Original Version
********************************************************************************/

public with sharing class MyClaimController{
    //JR1840 jack add
    public String selectedCategory{get;set;}
    public String encryptedSearchCriteria{get;set;}
    public final String CATEGORY_ALL{get;private set;}{CATEGORY_ALL ='1';}
    public final String CATEGORY_INPROGRESS{get;private set;}{CATEGORY_INPROGRESS ='2';}
    public final String CATEGORY_COMPLETED{get;private set;}{CATEGORY_COMPLETED ='3';}
    public final String URLParamName{get;private set;}{URLParamName = 'FLTR';}
    public final Map<String, List<String>> CatFltrMap = new Map<String, List<String>>{
        CATEGORY_ALL => new List<String>{'Person_Insured','Person_Insured_ID'},
        CATEGORY_INPROGRESS => new List<String>{'Person_Insured','Person_Insured_ID'},
        CATEGORY_COMPLETED => new List<String>{'Person_Insured','Person_Insured_ID'}
    };
    public Boolean haveRecord{get;set;}
    //JR1840 jack add

    public Boolean isCustomer{get;set;}    //flag - is using customer community or broker community
    public Boolean isChineseUser{get;set;}
    
    public Boolean hasNext{get;set;}
    public Boolean hasPrev{get;set;}
    public Integer totalPages{get;set;}
    public Integer currentPage{get;set;}
    public Integer currentTabIdx{get;set;}
    
    /** For WS Async Callout */
    public ClaimCalloutHelper asynHelper;
    public String requestLabel;
   
    public Integer totalNumOfRecord_all_WS{get;set;}
    public Integer totalNumOfRecord_in_progress_WS{get;set;}
    public Integer totalNumOfRecord_completed_WS{get;set;}
    
    public Integer currentIdxFinal_all_WS{get;set;}
    public Integer currentIdxFinal_in_progress_WS{get;set;}
    public Integer currentIdxFinal_completed_WS{get;set;}
    
    public String searchPINameStr{get;set;}
    public String searchPISsnStr{get;set;}
    
    public String errorMsg{get;set;}
    public String selectedSearchType{get;set;}
    public String selectedSearchValue{get;set;}
    //Rancho_JR1878_20210104
    public Integer currentPagePH{get;set;}
    public String searchPNStr{get;set;}
    public String selectedPN{get;set;}
    public String selectedPHName{get;set;}
    public String selectedPHSsn{get;set;}
    public String selectedInsuredSsn{get;set;}
    public Boolean searchByPI{get;set;}
    public Boolean searchPolicyAll{get;set;}
    public Boolean searchPolicyInPro{get;set;}
    public Boolean searchPolicyComplete{get;set;}
    public Boolean haveplRecord{get;set;}
    public Boolean displayPI{get;set;}
    public List<HttpCalloutVO.Policy> policyList{get;set;}
    public List<HttpCalloutVO.Person> personInsuredList{get;set;}
    public List<HttpCalloutVO.Person> personList{get;set;}
    public List<HttpCalloutVO.Person> currentPersonList{get;set;}
    // public Map<String, List<HttpCalloutVO.Person>> personInsuredMap{get;set;}
    
    public String username{get;set;}    //login username: login Id for WS
    public String userSsn{get;set;}    //login username: login Id for WS
    
    public String idx{get;set;}    //all
    public String idx_progress{get;set;}    //in progress
    public String idx_completed{get;set;}    //completed - should be useless
    
    public String progress_str{get;set;}
    public String not_submitted_str{get;set;}
    public String paid_str{get;set;}
    
    public Set <String> statusStrSet_all{get;set;}
    public Set <String> statusStrSet_in_progress{get;set;}
    public Set <String> statusStrSet_completed{get;set;}
    
    public List <User> uList{get;set;}
    
    public List <ClaimHelper.WrapperClaim> wClaimList_current{get;set;}
    public List <ClaimHelper.WrapperClaim> wClaimList_In_Progress_current{get;set;}
    public List <ClaimHelper.WrapperClaim> wClaimList_Completed_current{get;set;}
    
    /** for Salesforce **/
    public List <ClaimHelper.WrapperClaim> wClaimList_all_SF{get;set;}    //for all
    public List <ClaimHelper.WrapperClaim> wClaimList_in_progress_SF{get;set;}    //for in progress
    public List <ClaimHelper.WrapperClaim> wClaimList_completed_SF{get;set;}    //for completed
    
    /** for WS **/
    public List <ClaimHelper.WrapperClaim> wClaimList_all_WS{get;set;}    //for all
    public List <ClaimHelper.WrapperClaim> wClaimList_in_progress_WS{get;set;}    //for in progress
    public List <ClaimHelper.WrapperClaim> wClaimList_completed_WS{get;set;}    //for completed
    
    private static final Integer PAGE_SIZE = ClaimHelper.MAX_PAGING_COUNT_RECORD;    //get limit for each page for paging
    
    public Boolean showPreApprovalButton{get;set;}
    public Boolean showApplyForGOPBtn{get;set;}{showApplyForGOPBtn = false;}
    public Boolean showTooManyRecordError{get;set;}
    public Boolean searched{get;set;}

    // 2023.02.28 Add By Owen for JOBR-301, hide buttons when broker user company code is AMG
    public Boolean showMakeClaimButton{get;set;}{showMakeClaimButton = true;}
    
    public List<SelectOption> getSearchType(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Person_Insured',Label.Person_Insured));
        options.add(new SelectOption('Person_Insured_ID',Label.Person_Insured_ID));
        //Rancho_JR1878_20210104
        options.add(new SelectOption('Policy_Number',Label.Policy_Number));
        options.add(new SelectOption('Policy_Holder_Name',Label.Pol_Policy_holder_name));
        options.add(new SelectOption('Policy_Holder_ID',Label.Policy_Holder_ID));
        return options;
    }
    
    
    public MyClaimController(){
        init();
        
        if(isCustomer){
            searchByPI=true;//Rancho_JR1878_20210104
            SearchAllClaim();
        }

        getFilterData();//JR1840 jack add
    }
    
    //JR1840 jack add
    private void getFilterData(){

        String URLFilterParam = ApexPages.currentpage().getparameters().get(URLParamName);   //Get Parameters method already auto decodes params 
        system.debug('URLParamName'+URLParamName);
        if(!String.isEmpty(URLFilterParam)){
            String decryptedFltrStr =EncryptionUtil.decryptStrAES128(URLFilterParam);
            system.debug('decryptedFltrStr'+decryptedFltrStr);
            FilterData filterData= new FilterData(decryptedFltrStr,CatFltrMap);
            system.debug('filterData.URLCatType '+filterData.URLCatType);
            if(String.isNotBlank(filterData.URLCatType)){
                currentTabIdx = Integer.valueOf(filterData.URLCatType);
                
                selectedSearchType = filterData.URLFltrType;
                selectedSearchValue = filterData.URLFltrVal;
                system.debug('selectedSearchValue '+selectedSearchValue+' selectedSearchType '+selectedSearchType);
                if(String.isNotBlank(selectedSearchType) && String.isNotBlank(selectedSearchValue)){
                    SearchClaimRecords();
                    initPaging();
                    system.debug('totalPages'+totalPages+' filterData.URLCurPage '+filterData.URLCurPage);
                    if(totalPages != null && filterData.URLCurPage <= totalPages){
                        for(Integer i=1;i < filterData.URLCurPage;i++){
                            handleNextPage();
                        }
                    }
                }
            }
            
        }
    }

    public void getEncryptedString(){
        encryptedSearchCriteria = '';
        encryptedSearchCriteria = FilterData.encryptSearchCriteria(String.valueOf(currentTabIdx), selectedSearchType, selectedSearchValue, currentPage);

        system.debug('getEncryptedString() encryptedSearchCriteria:'+encryptedSearchCriteria);
    }
    //JR1840 jack add

    public void reloadAllRecord(){

        //Rancho_JR1878_20210104
        policyList.clear();
        if((selectedSearchType=='Policy_Holder_Name' || selectedSearchType=='Policy_Holder_ID') && !searchByPI){
            currentPage = 1;
            searchPolicyRecords();
            return;
        }

        currentPage = 1;
        resetTempList();
        showTooManyRecordError = false;
        
        if(isCustomer){
            SearchAllClaim();
            loadCurrentDisplayRecord();
        }else{
            searched = false;
            System.debug('selectedSearchType:'+selectedSearchType+' | '+'selectedSearchValue:'+selectedSearchValue);
            //Rancho_JR1878_20210104
            if(selectedSearchType == 'Person_Insured_ID' && String.isNotBlank(selectedSearchValue) || 
               selectedSearchType == 'Person_Insured' && String.isNotBlank(selectedSearchValue) && selectedSearchValue.length()>=2 ||
               selectedSearchType == 'Policy_Number' && String.isNotBlank(selectedSearchValue)){
               searchWSRecords();
            }else{
                wClaimList_current.clear();
                wClaimList_In_Progress_current.clear();
                wClaimList_Completed_current.clear();
            }
        }

        initPaging();
    }
    
    public void refreshTabWithoutInitialSearch(){
        System.Debug('currentTabIdx: ' + currentTabIdx);
    }
    
    public void init(){
        searched = false;
        selectedSearchValue = '';
        searchPINameStr = '';
        searchPISsnStr = '';
        
        totalNumOfRecord_all_WS = 0;
        totalNumOfRecord_in_progress_WS = 0;
        totalNumOfRecord_completed_WS = 0;
        
        currentIdxFinal_all_WS = 0;
        currentIdxFinal_in_progress_WS = 0;
        currentIdxFinal_completed_WS = 0;
        
        statusStrSet_all = new Set<String>{'Not Submitted','未提交','Paid', '支付','Reject', '拒賠','Pending', '跟進中','Assessing','審批中','Pending', '跟進中'};
        statusStrSet_in_progress = new Set<String>{'Not Submitted','未提交','Pending', '跟進中','Assessing', '審批中','Pending', '跟進中'};
        statusStrSet_completed = new Set<String>{'Paid', '支付','Reject', '拒賠'};
        
        currentTabIdx = 1;    // 1: all, 2: in progress, 3: completed
        isCustomer = false;
        userSsn = '';
        progress_str = ClaimHelper.CLAIM_STATUS_PROCESSING;
        not_submitted_str = ClaimHelper.CLAIM_STATUS_NOT_SUBMITTED;
        paid_str = ClaimHelper.CLAIM_STATUS_PAID;
        
        //hard code status value in which list - 'Not yet paid' no yet assign
        //'Not Submitted','未提交' at SF
        //other status from WS
        
        showPreApprovalButton = false;
        
        String userId = UserInfo.getUserId();
        
        uList = [select id, LanguageLocaleKey, username, ProfileId, Profile.Name, AccountId, Account.ssn__c,Company_Code__c from User where id=: userId ];
        system.debug('to see uList:    '+uList);
        isChineseUser = false;
        for(User u:    uList){
            if(u.LanguageLocaleKey == 'zh_TW' || u.LanguageLocaleKey == 'zh_HK')    {isChineseUser = true;}
            if(u.ProfileId != null && u.Profile.Name.contains('Customer'))    {isCustomer = true;}
            if(!String.isBlank(u.AccountId) && u.Account.ssn__c != null)    {userSsn = u.Account.ssn__c;}
            username = u.username;
        }
        
        wClaimList_current = new List <ClaimHelper.WrapperClaim>{};
        wClaimList_In_Progress_current = new List <ClaimHelper.WrapperClaim>{};
        wClaimList_Completed_current = new List <ClaimHelper.WrapperClaim>{};
        
        wClaimList_all_WS = new List <ClaimHelper.WrapperClaim>{};
        wClaimList_in_progress_WS = new List <ClaimHelper.WrapperClaim>{};
        wClaimList_completed_WS = new List <ClaimHelper.WrapperClaim>{};
        
        wClaimList_all_SF = new List <ClaimHelper.WrapperClaim>{};
        wClaimList_in_progress_SF = new List <ClaimHelper.WrapperClaim>{};
        wClaimList_completed_SF = new List <ClaimHelper.WrapperClaim>{};

        //Rancho_JR1878_20210104
        searchPNStr = '';
        policyList = new List<HttpCalloutVO.Policy>();
        personList = new List<HttpCalloutVO.Person>();
        personInsuredList = new List<HttpCalloutVO.Person>();
        currentPersonList = new List<HttpCalloutVO.Person>();
        
        currentPage = 1;

        // 2023.02.28 Add By Owen for JOBR-301, hide buttons when broker user company code is AMG
        if(CignaUtil.isBrokerPortal() && String.isNotBlank(uList[0].Company_Code__c)){
            List<Company__c> tempList = [SELECT Id, Claims_Submit_Button_Disabled__c FROM Company__c WHERE Company_Code__c =: uList[0].Company_Code__c AND Claims_Submit_Button_Disabled__c != null];
            if(null != tempList && !tempList.isEmpty()){
                for(String profileString : tempList[0].Claims_Submit_Button_Disabled__c.split(',')){
                    if(profileString == uList[0].Profile.Name){
                        showMakeClaimButton = false;
                    }
                }   
            }
        }
    }
       
    public void loadCurrentDisplayRecord(){   
        // system.debug('to see loadCurrentDisplayRecord start');
        try{
            
            showTooManyRecordError = false;
            //throw new CignaWSResultTooLargeException('Exception');
            Boolean isWSRecordNotEnd = false;
            // system.debug('to see loadCurrentDisplayRecord start');
            Integer currentNum = 0;
            system.debug('to see currentPage:    '+currentPage);
            
            wClaimList_current.clear();
            wClaimList_In_Progress_current.clear();
            wClaimList_Completed_current.clear();
            //Rancho_JR1878_20210104
            currentPersonList = new List<HttpCalloutVO.Person>();
            if((selectedSearchType=='Policy_Holder_Name' || selectedSearchType=='Policy_Holder_ID') && !displayPI && !searchByPI){
                for(HttpCalloutVO.Person p : personList){
                    if(((currentPage-1)*PAGE_SIZE)<= currentNum){
                        currentPersonList.add(p);
                    }
                    currentNum++;
                    if(currentNum >= (currentPage*PAGE_SIZE)){
                        break;    //prevent long loop
                    }
                }
                return;
            }else if((selectedSearchType=='Policy_Holder_Name' || selectedSearchType=='Policy_Holder_ID') && displayPI && !searchByPI){
                for(HttpCalloutVO.Person p : personInsuredList){
                    if(((currentPage-1)*PAGE_SIZE)<= currentNum){
                        currentPersonList.add(p);
                    }
                    currentNum++;
                    if(currentNum >= (currentPage*PAGE_SIZE)){
                        break;    //prevent long loop
                    }
                }
                return;
            }
            
            system.debug('to see currentTabIdx:    '+currentTabIdx);
            if(currentTabIdx == 1){
                Integer currentNumOfRecordToDisplay = 0;
                wClaimList_current.clear();
                //get record as SF first
                for(ClaimHelper.WrapperClaim wItem : wClaimList_all_SF){
                    if((((currentPage-1)*PAGE_SIZE))<= currentNum){
                        wClaimList_current.add(wItem);
                        currentNumOfRecordToDisplay ++;
                    }
                    currentNum++;
                    if(currentNum >= (currentPage*PAGE_SIZE)){
                        break;    //prevent long loop
                    }
                }
                system.debug('to see currentNumOfRecordToDisplay:    '+currentNumOfRecordToDisplay );
                system.debug('to see currentNum:    '+currentNum);
                system.debug('to see currentIdxFinal_all_WS start:    '+currentIdxFinal_all_WS);
                wClaimList_all_WS.clear();
                system.debug('to see isCustomer:    '+isCustomer);
                if(isCustomer){
                    wClaimList_all_WS = GetClaimListBasicByCriteriaAll(1+currentIdxFinal_all_WS, PAGE_SIZE+1, null);
                }else{
                    // for broker
                    //Rancho_JR1878_20210104
                    wClaimList_all_WS = GetClaimListBasicByCriteriaAllForBroker(1+currentIdxFinal_all_WS, PAGE_SIZE+1, null, searchPINameStr , searchPISsnStr, searchPNStr);
                }
                Integer tmp_currentIdxFinal_all_WS = currentIdxFinal_all_WS;
                system.debug('to see tmp_currentIdxFinal_all_WS:    '+tmp_currentIdxFinal_all_WS );
                //then get record from WS

                for(ClaimHelper.WrapperClaim wItem: wClaimList_all_WS){
                    system.debug('to see wClaimList_current:    '+wClaimList_current.size());
                    //system.debug('to see PAGE_SIZE:    '+PAGE_SIZE);
                    if(wClaimList_current.size()>= PAGE_SIZE){
                        isWSRecordNotEnd = true;
                        system.debug('to see isWSRecordNotEnd:    '+isWSRecordNotEnd);
                        break;    //prevent long loop
                    }
                    wClaimList_current.add(wItem);
                    tmp_currentIdxFinal_all_WS ++;
                    
                }
                if(currentIdxFinal_all_WS == 0 || (((tmp_currentIdxFinal_all_WS - currentIdxFinal_all_WS) == PAGE_SIZE) && isWSRecordNotEnd)){
                    currentIdxFinal_all_WS = tmp_currentIdxFinal_all_WS;
                    system.debug('to see currentIdxFinal_all_WS assign:    '+currentIdxFinal_all_WS);
                }
            
                system.debug('to see currentIdxFinal_all_WS end:    '+currentIdxFinal_all_WS);
                
            }else if(currentTabIdx == 2){
                Integer currentNumOfRecordToDisplay = 0;
                wClaimList_In_Progress_current.clear();
                for(ClaimHelper.WrapperClaim wItem:    wClaimList_in_progress_SF){
                    if((((currentPage-1)*PAGE_SIZE))<= currentNum){
                        wClaimList_In_Progress_current.add(wItem);
                        currentNumOfRecordToDisplay ++;
                    
                    }
                    currentNum++;
                    if(currentNum >= (currentPage*PAGE_SIZE)){
                        break;    //prevent long loop
                    }
                }
                wClaimList_in_progress_WS.clear();
                // pass null for now since value is all null in current data - Zoe
                if(isCustomer){
                    wClaimList_in_progress_WS = GetClaimListBasicByCriteriaInProgress(1+currentIdxFinal_in_progress_WS, PAGE_SIZE+1, null);
                }else{
                    // for broker
                    //Rancho_JR1878_20210104
                    wClaimList_in_progress_WS = GetClaimListBasicByCriteriaInProgressForBroker(1+currentIdxFinal_in_progress_WS, PAGE_SIZE+1, null, searchPINameStr , searchPISsnStr,searchPNStr);
                }
                
                Integer tmp_currentIdxFinal_in_progress_WS = currentIdxFinal_in_progress_WS;
                system.debug('to see tmp_currentIdxFinal_in_progress_WS start :    '+tmp_currentIdxFinal_in_progress_WS );
                
                for(ClaimHelper.WrapperClaim wItem:    wClaimList_in_progress_WS){
                    if(wClaimList_In_Progress_current.size()>= PAGE_SIZE){
                        isWSRecordNotEnd = true;
                        break;    //prevent long loop
                    }
                    wClaimList_In_Progress_current.add(wItem);
                    tmp_currentIdxFinal_in_progress_WS ++;
                    
                }
                if(currentIdxFinal_in_progress_WS == 0 || (((tmp_currentIdxFinal_in_progress_WS - currentIdxFinal_in_progress_WS) == PAGE_SIZE) && isWSRecordNotEnd))    {currentIdxFinal_in_progress_WS = tmp_currentIdxFinal_in_progress_WS ;}
                system.debug('to see currentIdxFinal_in_progress_WS  end:    '+currentIdxFinal_in_progress_WS );

            }else if(currentTabIdx == 3){
                Integer currentNumOfRecordToDisplay = 0;
                wClaimList_Completed_current.clear();
                for(ClaimHelper.WrapperClaim wItem: wClaimList_completed_SF){
                    
                    if((((currentPage-1)*PAGE_SIZE))<= currentNum){
                        wClaimList_Completed_current.add(wItem);
                        currentNumOfRecordToDisplay ++;
                    }
                    currentNum++;
                    if(currentNum >= (currentPage*PAGE_SIZE)){
                        break;    //prevent long loop
                    }
                }
                
                wClaimList_completed_WS.clear();
                // pass null for now since value is all null in current data - Zoe
                if(isCustomer){
                    wClaimList_completed_WS = GetClaimListBasicByCriteriaCompleted(1+currentIdxFinal_completed_WS, PAGE_SIZE+1, null);
                }else{
                    // for broker
                    //Rancho_JR1878_20210104
                    wClaimList_completed_WS = GetClaimListBasicByCriteriaCompletedForBroker(1+currentIdxFinal_completed_WS, PAGE_SIZE+1, null, searchPINameStr, searchPISsnStr, searchPNStr);
                }
                
                Integer tmp_currentIdxFinal_completed_WS = currentIdxFinal_completed_WS;
                system.debug('to see tmp_currentIdxFinal_completed_WS start:    '+tmp_currentIdxFinal_completed_WS );
                
                for(ClaimHelper.WrapperClaim wItem: wClaimList_completed_WS){
                    if(wClaimList_Completed_current.size()>= PAGE_SIZE){
                        isWSRecordNotEnd = true;
                        break;    //prevent long loop
                    }
                    wClaimList_Completed_current.add(wItem);
                    tmp_currentIdxFinal_completed_WS ++;
                    
                }
                
                if(currentIdxFinal_completed_WS == 0 || (((tmp_currentIdxFinal_completed_WS - currentIdxFinal_completed_WS) == PAGE_SIZE) && isWSRecordNotEnd))    {currentIdxFinal_completed_WS= tmp_currentIdxFinal_completed_WS;}
                system.debug('to see currentIdxFinal_completed_WS end:    '+currentIdxFinal_completed_WS);
                
            }else{
                //init or currentTabIdx == 1
                Integer currentNumOfRecordToDisplay = 0;
                wClaimList_current.clear();
                //get record as SF first
                for(ClaimHelper.WrapperClaim wItem: wClaimList_all_SF){
                    if((((currentPage-1)*PAGE_SIZE))<= currentNum){
                        wClaimList_current.add(wItem);
                        currentNumOfRecordToDisplay ++;
                    }
                    currentNum++;
                    if(currentNum >= (currentPage*PAGE_SIZE)){
                        break;    //prevent long loop
                    }
                }
                system.debug('to see currentNumOfRecordToDisplay:    '+currentNumOfRecordToDisplay );
                system.debug('to see currentNum:    '+currentNum);
                
                wClaimList_all_WS.clear();
                // pass null for now since value is all null in current data - Zoe
                if(isCustomer){
                    wClaimList_all_WS = GetClaimListBasicByCriteriaAll(1+currentIdxFinal_all_WS, PAGE_SIZE+1, null);
                }else{
                    // for broker
                    //Rancho_JR1878_20210104
                    wClaimList_all_WS = GetClaimListBasicByCriteriaAllForBroker(1+currentIdxFinal_all_WS, PAGE_SIZE+1, null, searchPINameStr , searchPISsnStr,searchPNStr);
                
                }
                Integer tmp_currentIdxFinal_all_WS = currentIdxFinal_all_WS;
                system.debug('to see tmp_currentIdxFinal_all_WS:    '+tmp_currentIdxFinal_all_WS );
                //then get record from WS
                for(ClaimHelper.WrapperClaim wItem: wClaimList_all_WS){
                    if(wClaimList_current.size()>= PAGE_SIZE){
                        isWSRecordNotEnd = true;
                        break;    //prevent long loop
                    }
                    wClaimList_current.add(wItem);
                    tmp_currentIdxFinal_all_WS ++;
                    
                }

                if(currentIdxFinal_all_WS == 0 || (((tmp_currentIdxFinal_all_WS - currentIdxFinal_all_WS) == PAGE_SIZE ) && isWSRecordNotEnd))    {currentIdxFinal_all_WS = tmp_currentIdxFinal_all_WS;}
                system.debug('to see currentIdxFinal_all_WS end:    '+currentIdxFinal_all_WS );

            }
            //System.debug('rancho_wClaimList_current---->'+wClaimList_current.size());
       }catch (CignaWSResultTooLargeException e){
           showTooManyRecordError = true;
           searched = false;
           wClaimList_current.clear();
           wClaimList_In_Progress_current.clear();
           wClaimList_Completed_current.clear();
           System.debug('to see Too Many Record!');
       } 
    
    }
    
    
    public PageReference initPaging(){
        totalPages = 1;
        Integer totalNumOfRecords = 0;
        haveRecord = false;//JR1840 jack add
        system.debug('to see currentTabIdx:    '+currentTabIdx);

        //Rancho_JR1878_20210104
        if((selectedSearchType=='Policy_Holder_Name' || selectedSearchType=='Policy_Holder_ID') && !searchByPI){
            if(!displayPI){
                totalNumOfRecords = personList.size();
            }else{
                totalNumOfRecords = personInsuredList.size();
            }
            if(Math.mod(totalNumOfRecords, PAGE_SIZE) == 0){
                totalPages = totalNumOfRecords/ PAGE_SIZE;
            }else{
                totalPages = (totalNumOfRecords/ PAGE_SIZE) + 1;
            }
            if(totalNumOfRecords>0){
                haveRecord=true;
            }

            if(currentPage < totalPages){
                hasNext = true;
            }else{
                hasNext = false;
            }

            if(currentPage <= totalPages &&  currentPage >1){
                hasPrev = true;
            }else{
                hasPrev = false;
            }
            return null;
        }
        
        if(currentTabIdx == 1){
            totalNumOfRecords = wClaimList_all_SF.size() + totalNumOfRecord_all_WS; 
        }else if(currentTabIdx == 2){
            totalNumOfRecords = wClaimList_in_progress_SF.size() + totalNumOfRecord_in_progress_WS; 
        }else if(currentTabIdx == 3){
            totalNumOfRecords = wClaimList_completed_SF.size() + totalNumOfRecord_completed_WS; 
        }else{
            //init or currentTabIdx == 1
            currentTabIdx = 1;
            totalNumOfRecords = wClaimList_all_SF.size() + totalNumOfRecord_all_WS; 
        }
        system.debug('to see totalNumOfRecords:    '+totalNumOfRecords);
        if(Math.mod(totalNumOfRecords, PAGE_SIZE) == 0){
            totalPages = totalNumOfRecords/ PAGE_SIZE;
        }else{
            totalPages = (totalNumOfRecords/ PAGE_SIZE) + 1;
        }
        if(totalNumOfRecords>0) {haveRecord = true;}//JR1840 jack add
        if(totalPages ==0)    {totalPages = 1;}
        system.debug('to see totalPages:    '+totalPages);
        
        if(currentPage < totalPages){
            hasNext = true;
        }else{
            hasNext = false;
        }
        
        if(currentPage <= totalPages &&  currentPage >1){
            hasPrev = true;
        }else{
            hasPrev = false;
        }
        
        return null;
    }
    
    
    
    public PageReference handleNextPage(){
        // system.debug('to see hasNext:    '+hasNext );
        system.debug('to see currentPage:    '+currentPage );
        system.debug('to see totalPages:    '+totalPages );
        if(hasNext && currentPage < totalPages){
            currentPage += 1;
            if(!Test.isRunningTest()){
                loadCurrentDisplayRecord();
            }
            initPaging();
        }
        return null;
    }
    
    public PageReference handlePrevPage(){
        if(hasPrev && currentPage >0){
            currentPage -= 1;
            //Rancho_JR1878_20210104
            if((selectedSearchType=='Policy_Holder_Name' || selectedSearchType=='Policy_Holder_ID') && !searchByPI){
                loadCurrentDisplayRecord();
                initPaging();
                return null;
            }
            
            if(currentIdxFinal_all_WS >= (PAGE_SIZE*2) && wClaimList_current.size() == PAGE_SIZE )    {currentIdxFinal_all_WS -= (PAGE_SIZE*2);}
            else if(currentIdxFinal_all_WS >= (PAGE_SIZE*2) && wClaimList_current.size() < PAGE_SIZE )    {currentIdxFinal_all_WS -= (PAGE_SIZE);}
            else{
                currentIdxFinal_all_WS = 0;
            }
            
            if(currentIdxFinal_in_progress_WS >= (PAGE_SIZE*2) && wClaimList_In_Progress_current.size() == PAGE_SIZE  )    {currentIdxFinal_in_progress_WS -= (PAGE_SIZE*2);}
            else if(currentIdxFinal_in_progress_WS >= (PAGE_SIZE*2) && wClaimList_In_Progress_current.size() < PAGE_SIZE  )    {currentIdxFinal_in_progress_WS -= (PAGE_SIZE);}
            else{
                currentIdxFinal_in_progress_WS = 0;
            }
            
            if(currentIdxFinal_completed_WS >= (PAGE_SIZE*2) && wClaimList_Completed_current.size() == PAGE_SIZE  )    {currentIdxFinal_completed_WS -= (PAGE_SIZE*2);}
            else if(currentIdxFinal_completed_WS >= (PAGE_SIZE*2) && wClaimList_Completed_current.size() < PAGE_SIZE  )    {currentIdxFinal_completed_WS -= (PAGE_SIZE);}
            else{
                currentIdxFinal_completed_WS = 0;
            }
            if(!Test.isRunningTest()){
                loadCurrentDisplayRecord();
                initPaging();
            }
        }
        return null;
    }

    //Rancho_JR1878_20210104
    public void searchPolicyRecords(){
        searchByPI=false;
        displayPI=false;
        currentpage = 1;

        if(currentTabIdx==1){
            searchPolicyAll=true;

            searchPolicyInPro=false;
            searchPolicyComplete=false;
        }else if(currentTabIdx==2){
            searchPolicyInPro=true;

            searchPolicyAll=false;
            searchPolicyComplete=false;
        }else if(currentTabIdx==3){
            searchPolicyComplete=true;

            searchPolicyAll=false;
            searchPolicyInPro=false;
        }
        //get policy holder list and person insured list from ws
        personList = new List<HttpCalloutVO.Person>();
        // personInsuredMap = new Map<String, List<HttpCalloutVO.Person>>();
        HttpCalloutVO.PolicyRequest request = new HttpCalloutVO.PolicyRequest();
        PolicyCalloutHelper polyCalHlp = new PolicyCalloutHelper();

        if(selectedSearchType=='Policy_Holder_Name'){
            request.holderName=selectedSearchValue;
        }else if(selectedSearchType=='Policy_Holder_ID'){
            request.holderId=selectedSearchValue;
        }
        policyList=polyCalHlp.GetPolicyListBasicByCriteria(request);

        if(policyList.size()>0){
            haveplRecord=true;
            for(HttpCalloutVO.Policy policy : policyList){
                HttpCalloutVO.Person person = policy.holder;
                person.policyNumber = policy.policyNumber;
                personList.add(person);

                // List<HttpCalloutVO.Person> perInsured = new List<HttpCalloutVO.Person>();
                // perInsured = policy.insuredList;
                // for (HttpCalloutVO.Person p : perInsured){
                //     p.policyHolderName = person.fullName;
                // }
                // if (!personInsuredMap.containsKey(policy.policyNumber)){
                //     personInsuredMap.put(policy.policyNumber, perInsured);
                // }
            }
        }else{
            haveplRecord=false;
        }

        if(selectedSearchType=='Policy_Holder_Name'||selectedSearchType=='Policy_Holder_ID'){
            searched=true;
        }else{
            searched=false;
        }
        if(!Test.isRunningTest()){
            loadCurrentDisplayRecord();
            initPaging();
        }
    }
    
    //Rancho_JR1878_20210104
    public void displayPIRecords(){
        displayPI=true;
        currentPagePH = currentPage;
        currentPage = 1;
        personInsuredList = new List<HttpCalloutVO.Person>();
        HttpCalloutVO.PolicyRequest request = new HttpCalloutVO.PolicyRequest();
        PolicyCalloutHelper polyCalHlp = new PolicyCalloutHelper();

        if(String.isNotBlank(selectedPN)){
            personInsuredList=polyCalHlp.getPolicyInsuredListBasic(selectedPN, true);
            if(personInsuredList.size() > 0 && String.isNotBlank(selectedPHName)){
                for (HttpCalloutVO.Person p : personInsuredList){
                    p.policyHolderName = selectedPHName;
                }
            }
        }
        // if(selectedPN != null && personInsuredMap != null && personInsuredMap.containsKey(selectedPN)){
        //     personInsuredList = personInsuredMap.get(selectedPN);
        //     System.debug('rancho_personInsuredList:  '+personInsuredList);
        // }
        if(!Test.isRunningTest()){
            loadCurrentDisplayRecord();
            initPaging();
        }
    }

    //Rancho_JR1878_20210104
    public void backToPolHolder(){
        displayPI=false;
        currentPage = currentPagePH;

        if(currentTabIdx==1){
            searchPolicyAll=true;
        }
        else if(currentTabIdx==2){
            searchPolicyInPro=true;
        }
        else if(currentTabIdx==3){
            searchPolicyComplete=true;
        }
        if(!Test.isRunningTest()){
            loadCurrentDisplayRecord();
            initPaging();
        }
    }

    public PageReference SearchClaimRecords()
    {   currentPage = 1;//JR1840 jack add
        searchWSRecords();
        return null;     
    }

    public void searchWSRecords(){
        searched = true;
        system.debug('to see selectedSearchValue:    '+selectedSearchValue);
        searchPINameStr = '';
        searchPISsnStr = '';
        
        //Rancho_JR1878_20210104
        searchByPI=true;
        haveplRecord=false;
        displayPI=false;
        searchPNStr = '';

        //system.debug('to see selectedSearchType:    ');
        if(selectedSearchType == 'Person_Insured'){
            searchPINameStr = selectedSearchValue;
        }else if(selectedSearchType == 'Person_Insured_ID'){
            searchPISsnStr = selectedSearchValue;
        }
        //Rancho_JR1878_20210104
        else if(selectedSearchType == 'Policy_Number'){
            searchPNStr = selectedSearchValue;
        }
        if((selectedSearchType == 'Policy_Holder_Name' || selectedSearchType == 'Policy_Holder_ID') && selectedInsuredSsn != null){
            searchPISsnStr = selectedInsuredSsn;
        }
        
        system.debug('to see searchPINameStr:    '+searchPINameStr);
        system.debug('to see searchPISsnStr:    '+searchPISsnStr);
        System.debug('rancho_searchPNStr:       '+searchPNStr);
        
        SearchAllClaim();
        loadCurrentDisplayRecord();
    }
    
    public void resetTempList(){
        
        wClaimList_all_SF.clear();
        wClaimList_in_progress_SF.clear();
        wClaimList_completed_SF.clear();
        
        currentIdxFinal_all_WS = 0;
        currentIdxFinal_in_progress_WS = 0;
        currentIdxFinal_completed_WS = 0;
        
    }
    
    // for customer
    public List <ClaimHelper.WrapperClaim> GetClaimListBasicByCriteriaAll(Integer startIdx, Integer recordCount, Boolean isBrokerClaim){
        List <ClaimHelper.WrapperClaim> wClaimList_all_WS_tmp = new List <ClaimHelper.WrapperClaim>{};
        List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper helper = new ClaimCalloutHelper();
        
        if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null)    
            //claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', '', uList[0].Account.ssn__c, '', '', '', isBrokerClaim, startIdx, recordCount);
            // Ray's Updates
            {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', '', uList[0].Account.ssn__c, '', uList[0].Account.ssn__c, '', '', '', '', isBrokerClaim, startIdx, recordCount, false);}
        else    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', '', '', '', '', '', isBrokerClaim, startIdx, recordCount);}
        
        /**
        try{
            if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null)    claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', '', uList[0].Account.ssn__c, '', '', '', isBrokerClaim, startIdx, recordCount);
            else    claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', '', '', '', '', '', isBrokerClaim, startIdx, recordCount);
        }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
            // Handle the exception
        }catch(Exception e4){
            // Handle the exception
            system.debug('to see error:    '+e4);
        }
        **/
        
        if(!helper.getResultInfo().isSuccess ){
            system.debug('to see helper_all error: ' + helper.getResultInfo().resultInfoDesc);
        }
        system.debug('to see recordsFound:    '+helper.getResultInfo().recordsFound);
        totalNumOfRecord_all_WS = Integer.valueOf(helper.getResultInfo().recordsFound);
        
        //all
        for(HttpCalloutVO.Claim cItem: claimList_tmp){
            system.debug('to see cItem:    '+cItem);
            ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
            tmpWClaim.cItem = null;
            tmpWClaim.isIndividual = cItem.isIndividual;
            if(cItem.isIndividual)    {tmpWClaim.policyType = 'Individual';}
            else    {tmpWClaim.policyType = 'Group';}
            tmpWClaim.cItem_in = cItem;
            tmpWClaim.cItem_grp = null;
            if(!String.isBlank(cItem.submitDate))    {tmpWClaim.submitDate = Date.valueOf(cItem.submitDate);}

            if(!String.isBlank(cItem.consultationDate))    {tmpWClaim.consultationDate = cItem.consultationDate.replace('-','/');}  //IBM KOU 20180627 PPS-17
            tmpWClaim.policyNum = cItem.polNumber ;
            tmpWClaim.claimNum = cItem.claimNumber;
            tmpWClaim.PIName = cItem.policyInsuredName;
            
            
            /** get Claim type Name by pass Claim type code in map cTypeCodeValueMap **/
            if(!String.isBlank(cItem.claimTypeCode)){
                
                tmpWClaim.claimType = cItem.claimTypeDisplay;
            
            }
            tmpWClaim.status = cItem.claimStatusDescription;
            tmpWClaim.accId = null;         
            
            system.debug('to see tmpWClaim:    '+tmpWClaim);
            
            system.debug('to see cItem.claimStatusDescription:    '+cItem.claimStatusDescription);
            wClaimList_all_WS_tmp.add(tmpWClaim.clone());
            
        }
        return wClaimList_all_WS_tmp;
    }
    
    // for broker
    //Rancho_JR1878_20210104
    public List <ClaimHelper.WrapperClaim> GetClaimListBasicByCriteriaAllForBroker(Integer startIdx, Integer recordCount, Boolean isBrokerClaim, String PIName, String PISsn, String PolNum){
        List <ClaimHelper.WrapperClaim> wClaimList_all_WS_tmp = new List <ClaimHelper.WrapperClaim>{};
        List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper helper = new ClaimCalloutHelper();
        system.debug('to see startIdx:    '+startIdx);
        //Rancho_JR1878_20210104
        claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', PolNum, '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount);
        
        /**
        try{
            claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'All', '', '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount);
        }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
            // Handle the exception
        }catch(Exception e4){
            // Handle the exception
            system.debug('to see error:    '+e4);
        }
        **/
        
        if(!helper.getResultInfo().isSuccess){
            system.debug('to see helper_all error: ' + helper.getResultInfo().resultInfoDesc);
            //errorMsg = helper.getResultInfo().resultInfoDesc;
        }
        system.debug('to see recordsFound:    '+helper.getResultInfo().recordsFound);
        totalNumOfRecord_all_WS = Integer.valueOf(helper.getResultInfo().recordsFound);
        
        //all
        for(HttpCalloutVO.Claim cItem: claimList_tmp){
            system.debug('to see cItem:    '+cItem);
            ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
            tmpWClaim.cItem = null;
            tmpWClaim.isIndividual = cItem.isIndividual;
            if(cItem.isIndividual)    {tmpWClaim.policyType = 'Individual';}
            else    {tmpWClaim.policyType = 'Group';}
            tmpWClaim.cItem_in = cItem;
            tmpWClaim.cItem_grp = null;
            if(!String.isBlank(cItem.submitDate))    {tmpWClaim.submitDate = Date.valueOf(cItem.submitDate);}
            if(!String.isBlank(cItem.consultationDate))    {tmpWClaim.consultationDate = cItem.consultationDate.replace('-','/');}  //IBM KOU 20180627 PPS-17
            tmpWClaim.policyNum = cItem.polNumber ;
            tmpWClaim.claimNum = cItem.claimNumber;
            tmpWClaim.PIName = cItem.policyInsuredName;
            //if(cItem.isIndividual)    tmpWClaim.PIName = cItem.policyInsuredName;
            //else    tmpWClaim.PIName = cItem.memberName;
            /** get Claim type Name by pass Claim type code in map cTypeCodeValueMap **/
            if(!String.isBlank(cItem.claimTypeCode)){
                
                tmpWClaim.claimType = cItem.claimTypeDisplay;
            
            }
            tmpWClaim.status = cItem.claimStatusDescription;
            tmpWClaim.accId = null;         
            
            system.debug('to see tmpWClaim:    '+tmpWClaim);
            
            system.debug('to see cItem.claimStatusDescription:    '+cItem.claimStatusDescription);
            wClaimList_all_WS_tmp.add(tmpWClaim.clone());
            
        }
        
        return wClaimList_all_WS_tmp;
    }
    
    // for customer
    public List <ClaimHelper.WrapperClaim> GetClaimListBasicByCriteriaInProgress(Integer startIdx, Integer recordCount, Boolean isBrokerClaim){
        List <ClaimHelper.WrapperClaim> wClaimList_in_progress_WS_tmp = new List <ClaimHelper.WrapperClaim>{};
        List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper helper = new ClaimCalloutHelper();
        
        if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null)    
            //claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', '', uList[0].Account.ssn__c, '', '', '', isBrokerClaim, startIdx, recordCount);
            //Ray's Updates
            {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', '', uList[0].Account.ssn__c, '', uList[0].Account.ssn__c, '', '', '', '', isBrokerClaim, startIdx, recordCount, false);}
        else    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', '', '', '', '', '', isBrokerClaim, startIdx, recordCount);}
        
        /**
        try{
            if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null)    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', '', uList[0].Account.ssn__c, '', '', '', isBrokerClaim, startIdx, recordCount);}
            else    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', '', '', '', '', '', isBrokerClaim, startIdx, recordCount);}
        }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
            // Handle the exception
        }catch(Exception e4){
            // Handle the exception
            system.debug('to see error:    '+e4);
        }
        **/
        
        if(!helper.getResultInfo().isSuccess){
            system.debug('to see helper_all error: ' + helper.getResultInfo().resultInfoDesc);
            //errorMsg = helper.getResultInfo().resultInfoDesc;
        }
        system.debug('to see recordsFound:    '+helper.getResultInfo().recordsFound);
        totalNumOfRecord_in_progress_WS = Integer.valueOf(helper.getResultInfo().recordsFound);
        
        //in progress
        for(HttpCalloutVO.Claim cItem: claimList_tmp){
            system.debug('to see cItem:    '+cItem);
            ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
            tmpWClaim.cItem = null;
            tmpWClaim.isIndividual = cItem.isIndividual;
            if(cItem.isIndividual)    {tmpWClaim.policyType = 'Individual';}
            else    {tmpWClaim.policyType = 'Group';}
            tmpWClaim.cItem_in = cItem;
            tmpWClaim.cItem_grp = null;
            if(!String.isBlank(cItem.submitDate))    {tmpWClaim.submitDate = Date.valueOf(cItem.submitDate);}
            if(!String.isBlank(cItem.consultationDate))    {tmpWClaim.consultationDate = cItem.consultationDate.replace('-','/');}  //IBM KOU 20180627 PPS-17
            tmpWClaim.policyNum = cItem.polNumber ;
            tmpWClaim.claimNum = cItem.claimNumber;
            tmpWClaim.PIName = cItem.policyInsuredName;
            //if(cItem.isIndividual)    tmpWClaim.PIName = cItem.policyInsuredName;
            //else    tmpWClaim.PIName = cItem.memberName;
            /** get Claim type Name by pass Claim type code in map cTypeCodeValueMap **/
            if(!String.isBlank(cItem.claimTypeCode)){
                
                tmpWClaim.claimType = cItem.claimTypeDisplay;
            
            }
            tmpWClaim.status = cItem.claimStatusDescription;
            tmpWClaim.accId = null;         
            
            system.debug('to see tmpWClaim:    '+tmpWClaim);
            
            system.debug('to see cItem.claimStatusDescription:    '+cItem.claimStatusDescription);
            wClaimList_in_progress_WS_tmp.add(tmpWClaim.clone());
            
        }
        
        return wClaimList_in_progress_WS_tmp;
    }
    
    // for broker
    //Rancho_JR1878_20210104
    public List <ClaimHelper.WrapperClaim> GetClaimListBasicByCriteriaInProgressForBroker(Integer startIdx, Integer recordCount, Boolean isBrokerClaim, String PIName, String PISsn, String PolNum){
        List <ClaimHelper.WrapperClaim> wClaimList_in_progress_WS_tmp = new List <ClaimHelper.WrapperClaim>{};
        List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper helper = new ClaimCalloutHelper();
        system.debug('to see startIdx:    '+startIdx);
        //Rancho_JR1878_20210104
        claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', PolNum, '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount);
        
        /**
        try{
            claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'InProgress', '', '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount);
        }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
            // Handle the exception
        }catch(Exception e4){
            // Handle the exception
            system.debug('to see error:    '+e4);
        }
        **/
        
        if(!helper.getResultInfo().isSuccess){
            system.debug('to see helper_all error: ' + helper.getResultInfo().resultInfoDesc);
            //errorMsg = helper.getResultInfo().resultInfoDesc;
        }
        system.debug('to see recordsFound:    '+helper.getResultInfo().recordsFound);
        totalNumOfRecord_in_progress_WS = Integer.valueOf(helper.getResultInfo().recordsFound);
        
        //in progress
        for(HttpCalloutVO.Claim cItem: claimList_tmp){
            system.debug('to see cItem:    '+cItem);
            ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
            tmpWClaim.cItem = null;
            tmpWClaim.isIndividual = cItem.isIndividual;
            if(cItem.isIndividual)    {tmpWClaim.policyType = 'Individual';}
            else    {tmpWClaim.policyType = 'Group';}
            tmpWClaim.cItem_in = cItem;
            tmpWClaim.cItem_grp = null;
            if(!String.isBlank(cItem.submitDate))    {tmpWClaim.submitDate = Date.valueOf(cItem.submitDate);}
            if(!String.isBlank(cItem.consultationDate))    {tmpWClaim.consultationDate = cItem.consultationDate.replace('-','/');}  //IBM KOU 20180627 PPS-17
            tmpWClaim.policyNum = cItem.polNumber ;
            tmpWClaim.claimNum = cItem.claimNumber;
            tmpWClaim.PIName = cItem.policyInsuredName;
            
            /** get Claim type Name by pass Claim type code **/
            if(!String.isBlank(cItem.claimTypeCode)){
                tmpWClaim.claimType = cItem.claimTypeDisplay;
            
            }
            tmpWClaim.status = cItem.claimStatusDescription;
            tmpWClaim.accId = null;         
            
            system.debug('to see tmpWClaim:    '+tmpWClaim);
            
            system.debug('to see cItem.claimStatusDescription:    '+cItem.claimStatusDescription);
            wClaimList_in_progress_WS_tmp.add(tmpWClaim.clone());
            
        }
        
        return wClaimList_in_progress_WS_tmp;
    }
    
    // for customer
    public List <ClaimHelper.WrapperClaim> GetClaimListBasicByCriteriaCompleted(Integer startIdx, Integer recordCount, Boolean isBrokerClaim){
        List <ClaimHelper.WrapperClaim> wClaimList_completed_WS_tmp = new List <ClaimHelper.WrapperClaim>{};
        List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper helper = new ClaimCalloutHelper();
        
        if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null)    
            //claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', '', uList[0].Account.ssn__c, '', '', '', isBrokerClaim, startIdx, recordCount);
            //Ray's Updates
            {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', '', uList[0].Account.ssn__c, '', uList[0].Account.ssn__c, '', '', '', '', isBrokerClaim, startIdx, recordCount, false);}
        else    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', '', '', '', '', '', isBrokerClaim, startIdx, recordCount);}
        
        /**
        try{
            if(uList.size()>0 && uList[0].AccountId != null && uList[0].Account.ssn__c != null)    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', '', uList[0].Account.ssn__c, '', '', '', isBrokerClaim, startIdx, recordCount);}
            else    {claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', '', '', '', '', '', isBrokerClaim, startIdx, recordCount);}
       }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
            // Handle the exception
        }catch(Exception e4){
            // Handle the exception
            system.debug('to see error:    '+e4);
        }
        **/
        
        if(!helper.getResultInfo().isSuccess){
            system.debug('to see helper_all error: ' + helper.getResultInfo().resultInfoDesc);
            //errorMsg = helper.getResultInfo().resultInfoDesc;
        }
        system.debug('to see recordsFound:    '+helper.getResultInfo().recordsFound);
        totalNumOfRecord_completed_WS = Integer.valueOf(helper.getResultInfo().recordsFound);
        
        //completed
        for(HttpCalloutVO.Claim cItem: claimList_tmp){
            system.debug('to see cItem:    '+cItem);
            ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
            tmpWClaim.cItem = null;
            tmpWClaim.isIndividual = cItem.isIndividual;
            if(cItem.isIndividual)    {tmpWClaim.policyType = 'Individual';}
            else    {tmpWClaim.policyType = 'Group';}
            tmpWClaim.cItem_in = cItem;
            tmpWClaim.cItem_grp = null;
            if(!String.isBlank(cItem.submitDate))    {tmpWClaim.submitDate = Date.valueOf(cItem.submitDate);}
            if(!String.isBlank(cItem.consultationDate))    {tmpWClaim.consultationDate = cItem.consultationDate.replace('-','/');}  //IBM KOU 20180627 PPS-17
            tmpWClaim.policyNum = cItem.polNumber ;
            tmpWClaim.claimNum = cItem.claimNumber;
            tmpWClaim.PIName = cItem.policyInsuredName;
            
            /** get Claim type Name by pass Claim type code **/
            if(!String.isBlank(cItem.claimTypeCode)){
                tmpWClaim.claimType = cItem.claimTypeDisplay;
            }
            tmpWClaim.status = cItem.claimStatusDescription;
            tmpWClaim.accId = null;         
            
            system.debug('to see tmpWClaim:    '+tmpWClaim);
            
            system.debug('to see cItem.claimStatusDescription:    '+cItem.claimStatusDescription);
            wClaimList_completed_WS_tmp.add(tmpWClaim.clone());
        }
        return wClaimList_completed_WS_tmp ;
    }
    
    // for broker
    //Rancho_JR1878_20210104
    public List <ClaimHelper.WrapperClaim> GetClaimListBasicByCriteriaCompletedForBroker(Integer startIdx, Integer recordCount, Boolean isBrokerClaim, String PIName, String PISsn, String PolNum){
        List <ClaimHelper.WrapperClaim> wClaimList_completed_WS_tmp = new List <ClaimHelper.WrapperClaim>{};
        List<HttpCalloutVO.Claim> claimList_tmp = new List<HttpCalloutVO.Claim>();
        ClaimCalloutHelper helper = new ClaimCalloutHelper();
        system.debug('to see startIdx:    '+startIdx);
        //Rancho_JR1878_20210104
        claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', PolNum, '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount);
        /**
        try{
            claimList_tmp = helper.GetClaimListBasicByCriteria( '', 'Completed', '', '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount);
        }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
            // Handle the exception
            // eg: ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
            // Handle the exception
        }catch(Exception e4){
            // Handle the exception
            system.debug('to see error:    '+e4);
        }
        **/
        
        if(!helper.getResultInfo().isSuccess){
            system.debug('to see helper_all error: ' + helper.getResultInfo().resultInfoDesc);
            //errorMsg = helper.getResultInfo().resultInfoDesc;
        }
        system.debug('to see recordsFound:    '+helper.getResultInfo().recordsFound);
        totalNumOfRecord_completed_WS = Integer.valueOf(helper.getResultInfo().recordsFound);
        
        //completed
        for(HttpCalloutVO.Claim cItem: claimList_tmp){
            system.debug('to see cItem:    '+cItem);
            ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
            tmpWClaim.cItem = null;
            tmpWClaim.isIndividual = cItem.isIndividual;
            if(cItem.isIndividual)    {tmpWClaim.policyType = 'Individual';}
            else    {tmpWClaim.policyType = 'Group';}
            tmpWClaim.cItem_in = cItem;
            tmpWClaim.cItem_grp = null;
            if(!String.isBlank(cItem.submitDate))    {tmpWClaim.submitDate = Date.valueOf(cItem.submitDate);}
            if(!String.isBlank(cItem.consultationDate))    {tmpWClaim.consultationDate = cItem.consultationDate.replace('-','/');}  //IBM KOU 20180627 PPS-17
            tmpWClaim.policyNum = cItem.polNumber ;
            tmpWClaim.claimNum = cItem.claimNumber;
            tmpWClaim.PIName = cItem.policyInsuredName;
            
            /** get Claim type Name by pass Claim type code in map cTypeCodeValueMap **/
            if(!String.isBlank(cItem.claimTypeCode)){
                tmpWClaim.claimType = cItem.claimTypeDisplay;
            
            }
            tmpWClaim.status = cItem.claimStatusDescription;
            tmpWClaim.accId = null;         
            
            system.debug('to see tmpWClaim:    '+tmpWClaim);
            
            system.debug('to see cItem.claimStatusDescription:    '+cItem.claimStatusDescription);
            wClaimList_completed_WS_tmp.add(tmpWClaim.clone());
        }
        return wClaimList_completed_WS_tmp ;
    }
    
    //get all claim record from SF
    public void SearchAllClaim(){
        
        String soql_claim = ClaimHelper.CLAIM_ALL_FIELD;
        /* add by Jack on 2022-05-16 for project: Checkmarx SOQL injection */
        String userId = UserInfo.getUserId();
        if(!String.isBlank(searchPINameStr)){
            //soql_claim += ' where createdById =\''+ UserInfo.getUserId()+'\' and Person_Insured_Name__c like \'%'+searchPINameStr+'%\' and Status__c= \'Not Submitted\' and ((Is_Displayed_For_Customer__c = true and RecordType.Name = \'Normal\' and steps__c <=9 ) or (RecordType.Name = \'Pre Admission\' )) order by LastModifiedDate desc ';
            //Comment by Nicole for Encryption CR
            soql_claim += ' where createdById = :userId and Status__c= \'Not Submitted\' and ((Is_Displayed_For_Customer__c = true and RecordType.Name = \'Normal\' and steps__c <=9 ) or (RecordType.Name = \'Pre Admission\' )) order by LastModifiedDate desc ';        
        }else if(!String.isBlank(searchPISsnStr)){
            soql_claim += ' where createdById = :userId and Person_s_Insured__c = :searchPISsnStr and Status__c= \'Not Submitted\' and ((Is_Displayed_For_Customer__c = true and RecordType.Name = \'Normal\' and steps__c <=9 ) or (RecordType.Name = \'Pre Admission\')) order by LastModifiedDate desc ';
        }
        //Rancho_JR1878_20210104
        else if(!String.isBlank(searchPNStr)){
            soql_claim += ' where createdById = :userId and Status__c= \'Not Submitted\' and ((Is_Displayed_For_Customer__c = true and RecordType.Name = \'Normal\' and steps__c <=9 ) or (RecordType.Name = \'Pre Admission\')) order by LastModifiedDate desc ';
        }
        else{
            soql_claim += ' where createdById = :userId and Status__c= \'Not Submitted\' and ((Is_Displayed_For_Customer__c = true and RecordType.Name = \'Normal\' and steps__c <=9 ) or (RecordType.Name = \'Pre Admission\' )) order by LastModifiedDate desc ';
        }
        /* add by Jack on 2022-05-16 for project: Checkmarx SOQL injection */
        
        List <Claim__c> cList = new List <Claim__c>{};
        system.debug('to see soql_claim:    '+soql_claim);
        cList = Database.query(soql_claim);

        //Rancho_JR1878_20210104 filter by policy number start
        if(!String.isBlank(searchPNStr)){
            if(cList.size()>0){
                List <Claim__c> temClaimList = new List <Claim__c>();
                for(Claim__c temClaim : cList){
                    if(temClaim.Policy__c!=null && temClaim.Policy__c==searchPNStr){
                        temClaimList.add(temClaim);
                    }
                }
                cList = new List <Claim__c>(); 
                if(temClaimList.size()>0){
                    cList.addAll(temClaimList);
                }
            }
        }
        //Rancho_JR1878_20210104 filter by policy number end
        
        //Filter by PI name for Encryption CR start
        if(!String.isBlank(searchPINameStr)){
            if(cList.size()>0){
                List <Claim__c> temClaimList = new List <Claim__c>();
                for(Claim__c temClaim : cList){
                    if(temClaim.Person_Insured_Name__c!=null){
                        if(temClaim.Person_Insured_Name__c.containsIgnoreCase(searchPINameStr)){
                            temClaimList.add(temClaim);
                        }
                    }
                }
                
                cList = new List <Claim__c>(); 
                if(temClaimList.size()>0){
                    cList.addAll(temClaimList);
                }
            }
        }
        //Filter by PI name for Encryption CR end
        
        resetTempList();
        
        if(cList.size()>0){
            for(Claim__c cItem: cList){
                system.debug('to see cItem:    '+cItem);
                ClaimHelper.WrapperClaim tmpWClaim = new ClaimHelper.WrapperClaim();
                tmpWClaim.cItem = cItem;
                tmpWClaim.cItem_in = null;
                tmpWClaim.cItem_grp = null;
                tmpWClaim.submitDate = cItem.lastModifiedDate.date();
                if(cItem.Policy__c != null)    {tmpWClaim.policyNum = cItem.Policy__c;}
                else    {tmpWClaim.policyNum = 'N/A';}
                if(cItem.Person_Insured_Name__c != null)    {tmpWClaim.PIName = cItem.Person_Insured_Name__c;}
                else    {tmpWClaim.PIName = '';}
                
                tmpWClaim.claimNum = 'N/A';
                System.debug('draft claim status: '+cItem.get('status_translated'));
                if(cItem.Display_Selected_Benefit_Type_s__c != null && !isChineseUser)    {tmpWClaim.claimType = cItem.Display_Selected_Benefit_Type_s__c;}         
                else if(cItem.Display_Selected_Benefit_Type_s__c != null && isChineseUser)    {tmpWClaim.claimType = cItem.Display_Selected_Benefit_Type_s_In_Chi__c;}         
                else    {tmpWClaim.claimType = 'N/A';}
                if(cItem.get('status_translated')!= null)    {tmpWClaim.status = String.valueOf(cItem.get('status_translated'));}
                else    {tmpWClaim.status ='N/A';}
                
                tmpWClaim.accId = cItem.Account__c;
                //record from SF is in all / in progress
                wClaimList_all_SF.add(tmpWClaim.clone());
                wClaimList_in_progress_SF.add(tmpWClaim.clone());
            }
        }
    }
    
    public PageReference deleteSingleClaimAllRecord(){
        
        Savepoint sp = Database.setSavePoint();
        if(!String.isBlank(idx) && wClaimList_current.size()> Integer.valueOf(idx)){
            //select from all list
            try{
                delete wClaimList_current[Integer.valueOf(idx)].cItem;
            }catch(Exception ex){
                Database.rollback(sp);
                errorMsg = 'error: '+ex;
            }
        }
        idx = '';
        //reloadAllRecord();
        return null;
    }
    
    public PageReference deleteSingleClaimProgressRecord(){
        
        Savepoint sp = Database.setSavePoint();
        if(!String.isBlank(idx_progress) && wClaimList_In_Progress_current.size()> Integer.valueOf(idx_progress)){
            //select from all list
            try{
                delete wClaimList_In_Progress_current[Integer.valueOf(idx_progress)].cItem;
            }catch(Exception ex){
                Database.rollback(sp);
                errorMsg = 'error: '+ex;
            }
        }
        idx_progress = '';
        //reloadAllRecord();
        return null;
    }
    
    public PageReference deleteSingleClaimCompletedRecord(){
        
        Savepoint sp = Database.setSavePoint();
        if(!String.isBlank(idx_completed) && wClaimList_Completed_current.size()> Integer.valueOf(idx_completed)){
            //select from all list
            try{
                delete wClaimList_Completed_current[Integer.valueOf(idx_completed)].cItem;
            }catch(Exception ex){
                Database.rollback(sp);
                errorMsg = 'error: '+ex;
            }
        }
        idx_completed = '';
        
        return null;
    }
    
    public void checkIPMIPolicy(){  
        system.debug('to see checkIPMIPolicy start');  
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        List<HttpCalloutVO.Policy> policyList = new List<HttpCalloutVO.Policy>{};
        User currentUser = [select id, Name, ProfileId, UserRoleId, UserName, User_Type__c, LanguageLocaleKey, AccountId, Account.ssn__c from User where id = : Userinfo.getUserId()];
        try{
            if(isCustomer){
                policyList = helper.getIndividualPolicyListBasicByCriteria('','',currentUser.account.ssn__c,'','','',null,'',null);
                policyList.addAll(helper.getGroupPolicyListBasicByCriteria('', '', currentUser.account.ssn__c, '', '', '', '', ''));
            }else{
                /* Comment by David for Testing
                policyList = helper.getIndividualPolicyListBasicByCriteria('','','','','','',null,'',null);
                policyList.addAll(helper.getGroupPolicyListBasicByCriteria('', '', null, '', '', '', '', ''));
                */
                showPreApprovalButton = true;
                showApplyForGOPBtn = true;
            }
            if(policyList.size()>0){
                showPreApprovalButton = true;
                for(HttpCalloutVO.Policy policy : policyList){
                    if(IPMISettingUtil.isIPMIPolicy(policy)){
                        showApplyForGOPBtn = true;
                    }
                    if(IPMISettingUtil.isIPMITopUpPolicy(policy) || IPMISettingUtil.isGAOPPolicy(policy) || IPMISettingUtil.isLHBPolicy(policy)){
                        showApplyForGOPBtn = IPMISettingUtil.isEnableApplyForAOP(policy);
                    }
                    if(showApplyForGOPBtn){
                        break;
                    }
                }
            }
            system.debug('to see showPreApprovalButton:    '+showPreApprovalButton );
        }catch(CignaWSResultTooLargeException e1){
            system.debug('to see error:    '+e1);
        }catch(CignaWSTimeoutException e2){
            system.debug('to see error:    '+e2);
        }catch(CignaWSException e3){
            system.debug('to see error:    '+e3);
        }catch(Exception e4){
            system.debug('to see error:    '+e4);
        }         
    }
    
    public void loadData(){
        if(isCustomer){
            loadCurrentDisplayRecord();
        }
    }
    
    /**
    public Object asyncGetClaimList('', 'Completed', '', '', '', PISsn, PIName, isBrokerClaim, startIdx, recordCount){
                asynHelper = new PolicyCalloutHelper(true);
                asynHelper.getIndividualPolicyListBasicByCriteria('', '', '', '', '', '', '', '');
                AsynCalloutInfo aci = asynHelper.asynExecute('processResponse');
                this.requestLabel = aci.requestLabel;
                return aci.con;
    }
    
    public Object processResponse(){   
                HttpResponse res = Continuation.getResponse(this.requestLabel);
                List<HttpCalloutVO.Policy> policyList = (List<HttpCalloutVO.Policy>)asynHelper.processResponse(res);
                return null;
    }
    */
}