/********************************************************************************
Apex Class Name - PolicyChangeController
Version - 1.0
Created Date - Sep 22, 2016
@description Controlloer for PolicyChangeVFP

Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer             Date                    Description
* ------    -----------     ------------            -----------------------
* 0.1       Connie            22/09/2016               Original Version
* 0.2       Kevani            02/11/2016               Dummy Logic
* 1.0       Kevani            16/02/2016               Finalising For Customer Portal
********************************************************************************/

public with sharing class PolicyChangeController{ 
    //JR1840 jack add
    public String selectedCategory{get;set;}
    public String encryptedSearchCriteria{get;set;}
    public final String CATEGORY_ALL{get;private set;}{CATEGORY_ALL ='all';}
    public final String CATEGORY_INPROGRESS{get;private set;}{CATEGORY_INPROGRESS ='inprogress';}
    public final String CATEGORY_COMPLETED{get;private set;}{CATEGORY_COMPLETED ='completed';}
    public final String CATEGORY_CANCEL{get;private set;}{CATEGORY_CANCEL ='cancel';}//HKITSFDC-44
    public final String URLParamName{get;private set;}{URLParamName = 'FLTR';}
    public final Map<String, List<String>> CatFltrMap = new Map<String, List<String>>{
        CATEGORY_ALL => new List<String>{'Policy Holder Name','Policy Holder Id'},
        CATEGORY_INPROGRESS => new List<String>{'Policy Holder Name','Policy Holder Id'},
        CATEGORY_COMPLETED => new List<String>{'Policy Holder Name','Policy Holder Id'},
        CATEGORY_CANCEL => new List<String>{'Policy Holder Name','Policy Holder Id'}//HKITSFDC-44
    };
    //JR1840 jack add

    public Integer PAGE_SIZE = 20;
    public String Request_Type = 'Policy Change Request';
    public String PolicyHolderLoginIn{get;set;}
    public String PolicyHolderId{get;set;}
    public String PolicyHolderName{get;set;}
    public String recordOwner{get;set;}
    public String sitePrefix{get;set;}
    
    public list<PolicyChange> listPolicyChange{get;set;}
    public list<PolicyChange> listSearchSavePolicyChange{get;set;}
    public list<PolicyChange> listSearchInProgressPolicyChange{get;set;}
    public list<PolicyChange> listSearchAllPolicyChange{get;set;}
    public list<PolicyChange> listSearchCompletedPolicyChange{get;set;}
    public list<PolicyChange> listSearchCancelPolicyChange{get;set;}    //HKITSFDC-44
    
    public list<PolicyChange> listCancelPolicyChangebyAPI{get;set;}     //HKITSFDC-44
    public list<PolicyChange> listCompletedPolicyChangebyAPI{get;set;}
    public list<PolicyChange> listInProgressPolicyChangebyAPI{get;set;}
    public list<PolicyChange> listAllPolicyChangebyAPI{get;set;}
    public list<PolicyChange> listSavePolicyChange{get;set;}
    
    public map<String, HttpCalloutVO.Policy> mapPolicyInfo{get;set;}
    
    public String removePolicyChangeId{get;set;}
    
    public String searchType{get;set;}
    public String searchInput{get;set;}
    public String SelectOption{get;set;}
    
    public String backId{get;set;}
    public String fromTab{get;set;}
    
    public Boolean hasNoPolicyChange{get;set;} 
    public Boolean hasNoProgressPolicyChange{get;set;} 
    public Boolean hasNoCompletedPolicyChange{get;set;}  
    public Boolean hasNoCancelPolicyChange{get;set;}    //HKITSFDC-44  
    
    /**Pagination**/
    public String tabStatus{get;set;}
    
    //BEGIN HKITSFDC-44
    public Boolean hasCancelListNext{get;set;}
    public Boolean hasCancelListPrevious{get;set;}
    public Integer totalCancelPage{get;set;}
    public Integer currentCancelPage{get;set;}
    public list<PolicyChange> totalCancelList{get;set;}
    public list<PolicyChange> getTotalCancelList{get;set;}
    //END HKITSFDC-44
    
    public Boolean hasCompletedListNext{get;set;}
    public Boolean hasCompletedListPrevious{get;set;}
    public Integer totalCompletedPage{get;set;}
    public Integer currentCompletedPage{get;set;}
    public list<PolicyChange> totalCompletedList{get;set;}
    public list<PolicyChange> getTotalCompletedList{get;set;}
    
    public Boolean hasAllListNext{get;set;}
    public Boolean hasAllListPrevious{get;set;}
    public list<PolicyChange> totalAllList{get;set;}
    public list<PolicyChange> getTotalAllList{get;set;}
    public Integer totalAllPage{get;set;}
    public Integer currentAllPage{get;set;}
    public Integer startAllRecordCount{get;set;}
    public Integer currentStartAllRecordCount{get;set;}
    
    public Boolean hasInprogressListNext{get;set;}
    public Boolean hasInprogressListPrevious{get;set;}
    public list<PolicyChange> totalInprogressList{get;set;}
    public list<PolicyChange> getTotalInprogressList{get;set;}
    public Integer totalInprogressPage{get;set;}
    public Integer currentInprogressPage{get;set;}
    public Integer startInprogressRecordCount{get;set;}
    public Integer currentStartInprogressRecordCount{get;set;}

    public list<PolicyChange> totalSaveList{get;set;}
    public list<PolicyChange> getTotalSaveList{get;set;}
    public Integer remainingSavelistsize{get;set;}
    public Integer currentStartSaveRecord{get;set;}
    
    /*exception from web service*/
    public Boolean showTooManyRecordError{get;set;}
    public String errorMessage{get;set;}
    public Boolean callSuccess{get;set;}
    public Boolean getWorkStatusSuccess{get;set;}
    public Integer getPolicyChangeCount{get;set;}

    /*useless*/
    public Boolean hasPrev{get;set;}
    public Boolean hasNext{get;set;}
    public Integer totalPages{get;set;}
    public Integer currentPage{get;set;}
    /********/
    
    // 20200306 - minghua - ILAS
    public Map<String, Map<String, String>> transField{ 
        get{
            if(transField ==null){
                transField = new Map<String, Map<String, String>>();
                for(Translate__mdt t : [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c = 'ILASStatus']){
                    transField.put(t.DeveloperName, new Map<String, String>{'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c });            
                } 
            }
            return transField ;
        }
        set; 
    }
    public Boolean isCustomer{get;set;}{isCustomer = false;}
    
    public PolicyChangeController(){ 
        if(CignaUtil.isCustomerPortal()){
            isCustomer = true;
            sitePrefix = '/customer';
        }else{
            sitePrefix = '/broker';
        }
        
        searchType = '';
        searchInput = '';
        PolicyHolderLoginIn = '';
        PolicyHolderId = '';
        remainingSavelistsize=0;
        tabStatus = '';
        hasCompletedListNext = false;
        hasCompletedListPrevious = false;
        totalCompletedPage = 1;
        currentCompletedPage = 1;
        
        //[HKITSFDC-44] [S]
        hasCancelListNext = false;
        hasCancelListPrevious = false;
        totalCancelPage = 1;
        currentCancelPage = 1;
        //[HKITSFDC-44] [E]
        
        hasAllListNext =false;
        hasAllListPrevious =false;
        totalAllPage = 1;
        currentAllPage = 1;
        startAllRecordCount = 1;
        currentStartAllRecordCount = 1;
    
        hasInprogressListNext = false;
        hasInprogressListPrevious= false;
        totalInprogressPage  = 1;
        currentInprogressPage  = 1;
        startInprogressRecordCount = 1;
        currentStartInprogressRecordCount  = 1;

        remainingSavelistsize = 1;
        currentStartSaveRecord  = 1;

        hasPrev = false;
        hasNext = false;
        totalPages = 1;
        currentPage = 1;
        getPolicyChangeCount = 0;
        
        if(ApexPages.currentPage().getParameters().get('backId')!=null && ApexPages.currentPage().getParameters().get('backId')!=''){
            backId = ApexPages.currentPage().getParameters().get('backId');
        }
        
        if(ApexPages.currentPage().getParameters().get('tab')!=null && ApexPages.currentPage().getParameters().get('tab')!=''){
            fromTab = ApexPages.currentPage().getParameters().get('tab');
        }
        
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        //junda update for plus profile
        String profile =  Portal_Settings__c.getInstance().Customer_User_Profile__c;
        if(profileName == profile||profileName=='Cigna Customer User'){
            PolicyHolderLoginIn = userinfo.getUserName();
        }
        //junda update end
         
        recordOwner = userinfo.getuserid();
        
        mapPolicyInfo = new map<String, HttpCalloutVO.Policy>();
        
        listCancelPolicyChangebyAPI = new list<PolicyChange>(); //[HKITSFDC-44]
        listCompletedPolicyChangebyAPI = new list<PolicyChange>();
        listInProgressPolicyChangebyAPI = new list<PolicyChange>();
        listAllPolicyChangebyAPI = new list<PolicyChange>();
        listSavePolicyChange = new list<PolicyChange>();
        totalSaveList = new list<PolicyChange>();

        totalAllList = new list<PolicyChange>();
        totalInprogressList = new list<PolicyChange>();
        totalCompletedList = new list<PolicyChange>();
        totalCancelList = new list<PolicyChange>(); //[HKITSFDC-44]
         
        getTotalSaveList = new list<PolicyChange>();
        getTotalAllList = new list<PolicyChange>();
        getTotalInprogressList = new list<PolicyChange>();
        getTotalCompletedList = new list<PolicyChange>();
        getTotalCancelList = new list<PolicyChange>(); //[HKITSFDC-44]
        
        listSearchSavePolicyChange = new list<PolicyChange>();
        listSearchAllPolicyChange = new list<PolicyChange>();
        listSearchInProgressPolicyChange  = new list<PolicyChange>();
        listSearchCompletedPolicyChange = new list<PolicyChange>();
        listSearchCancelPolicyChange = new list<PolicyChange>(); //[HKITSFDC-44]
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
            if(String.isNotBlank(filterData.URLCatType)){
                fromTab = filterData.URLCatType;
                tabStatus = filterData.URLCatType;
                
                SearchType = filterData.URLFltrType;
                SearchInput = filterData.URLFltrVal;
                if(String.isNotBlank(SearchType) && String.isNotBlank(SearchInput)){
                    SearchPolicyChange();
                    Integer totalPage;
                    if(fromTab == CATEGORY_ALL){
                        totalPage = totalAllPage;
                    }else if(fromTab == CATEGORY_INPROGRESS){
                        totalPage = totalInprogressPage;
                    }else if(fromTab == CATEGORY_COMPLETED){
                        totalPage = totalCompletedPage;
                    }//BEGIN HKITSFDC-44
                    else if(fromTab == CATEGORY_CANCEL){
                        totalPage = totalCancelPage;
                    }
                    //END HKITSFDC-44
                    if(totalPage != null && filterData.URLCurPage <= totalPage){
                        for(Integer i=1;i < filterData.URLCurPage;i++){
                            handleNextPageBroker();
                        }
                    }
                }
            }
        }
    }

    public void getEncryptedString(){
        encryptedSearchCriteria = '';
        String catType = tabStatus;
        system.debug('getEncryptedString() catType'+catType+' currentAllPage:'+currentAllPage);
          
        if(catType == CATEGORY_ALL){
            encryptedSearchCriteria = FilterData.encryptSearchCriteria(tabStatus, SearchType, SearchInput, currentAllPage);
        }else if(catType == CATEGORY_INPROGRESS){
            encryptedSearchCriteria = FilterData.encryptSearchCriteria(tabStatus, SearchType, SearchInput, currentInprogressPage);
        }else if(catType == CATEGORY_COMPLETED){
            encryptedSearchCriteria = FilterData.encryptSearchCriteria(tabStatus, SearchType, SearchInput, currentCompletedPage);
        }//BEGIN HKITSFDC-44
        else if(catType == CATEGORY_CANCEL){
            encryptedSearchCriteria = FilterData.encryptSearchCriteria(tabStatus, SearchType, SearchInput, currentCancelPage);
        }
        //END HKITSFDC-44
        system.debug('getEncryptedString() encryptedSearchCriteria:'+encryptedSearchCriteria);
    }
    //JR1840 jack add

    public void init(){
        if(sitePrefix =='/customer'){
            if(fromTab == null || fromTab == '' || fromTab =='all'){
                getTotalAllList.addAll(getPolicyChange('', null, null, '', ''));
                system.debug('sanika getTotalAllList size in init() ' + getTotalAllList.size());
                system.debug('sanika getTotalAllList size in init() ' + getTotalAllList);
                if(getTotalAllList!=null){
                    totalAllList.addAll(getTotalAllList);
                }
            }else if(fromTab == 'inprogress'){
                getTotalInprogressList.addAll(getPolicyChange('inprogress', null, null, '', ''));
                if(getTotalInprogressList!=null){
                    totalInprogressList.addAll(getTotalInprogressList);
                }
            }else if(fromTab == 'completed'){
                getTotalCompletedList.addAll(getPolicyChange('completed', null, null, '', ''));
                if(getTotalCompletedList!=null){
                    totalCompletedList.addAll(getTotalCompletedList);
                }
            }//BEGIN HKITSFDC-44
            else if(fromTab == 'cancel'){ 
                system.debug('in cancel sanika');
                getTotalCancelList.addAll(getPolicyChange('cancel', null, null, '', ''));
                system.debug('in cancel sanika getTotalCancelList' + getTotalCancelList.size());
                if(getTotalCancelList!=null){
                    totalCancelList.addAll(getTotalCancelList);
                    system.debug('in cancel sanika totalCancelList' + totalCancelList.size());
                }
            } //END HKITSFDC-44
            initDisplayPagination();
        }else{
           // SearchPolicyChange();
        }  
    }
     
    public void reCalculatePagination(){
        totalSaveList = new list<PolicyChange>();
        getTotalSaveList = new list<PolicyChange>();
        if(sitePrefix =='/customer'){
            system.debug('sanika tabStatus in reCalculatePagination : '+ tabStatus);
            getTotalSaveList.addAll(getSaveListPolicyChange());
            if(getTotalSaveList != null){
                totalSaveList.addAll(getTotalSaveList);
            }

            getTotalAllList = new list<PolicyChange>();
            getTotalInprogressList = new list<PolicyChange>();
            getTotalCompletedList = new list<PolicyChange>();
            getTotalCancelList = new list<PolicyChange>(); //HKITSFDC-44
             
            if(tabStatus == 'inprogress'){
                if(totalInprogressList.size()==0){
                    getTotalInprogressList.addAll(getPolicyChange('inprogress', null, null, '', ''));
                    if(getTotalInprogressList!=null){
                        totalInprogressList.addAll(getTotalInprogressList);
                    }
                }
            }else if(tabStatus == 'completed'){
                if(totalCompletedList.size()==0){
                    getTotalCompletedList.addAll(getPolicyChange('completed', null, null, '', ''));
                    if(getTotalCompletedList!=null){
                        totalCompletedList.addAll(getTotalCompletedList);
                    }
                }
            }//BEGIN HKITSFDC-44
            else if(tabStatus == 'cancel'){
                if(totalCancelList.size()==0){
                    getTotalCancelList.addAll(getPolicyChange('cancel', null, null, '', ''));
                    if(getTotalCancelList!=null){
                        totalCancelList.addAll(getTotalCancelList);
                    }
                }
            }//END HKITSFDC-44
            else{
                //all
                if(totalAllList.size()==0){
                    getTotalAllList.addAll(getPolicyChange('', null, null, '', ''));
                    if(getTotalAllList!=null){
                        totalAllList.addAll(getTotalAllList);
                    }
                }
            }

            Integer totalAllRecord = totalSaveList.size() + totalAllList.size();
            if(totalAllRecord > 0){
                if(Math.mod(totalAllRecord, PAGE_SIZE) == 0){
                    totalAllPage = totalAllRecord/ PAGE_SIZE;
                }else{
                    totalAllPage = (totalAllRecord/ PAGE_SIZE) + 1;
                }
            }else{
                totalAllPage = 1;
            }
             
            Integer totalInprogressRecord = totalSaveList.size() + totalInprogressList.size();
            if(totalInprogressRecord > 0){
                if(Math.mod(totalInprogressRecord, PAGE_SIZE) == 0){
                    totalInprogressPage = totalInprogressRecord/ PAGE_SIZE;
                }else{
                    totalInprogressPage = (totalInprogressRecord/ PAGE_SIZE) + 1;
                }
            }else{
                totalInprogressPage = 1;
            }
                
            if(listCompletedPolicyChangebyAPI.size()>0){
                if(Math.mod(listCompletedPolicyChangebyAPI.size(), PAGE_SIZE) == 0){
                    totalCompletedPage = listCompletedPolicyChangebyAPI.size()/ PAGE_SIZE;
                }else{
                        totalCompletedPage = (listCompletedPolicyChangebyAPI.size()/ PAGE_SIZE) + 1;
                }
            }else{
                totalCompletedPage = 1;
            } 
            
            //BEGIN HKITSFDC-44
            if(listCancelPolicyChangebyAPI.size()>0){
                if(Math.mod(listCancelPolicyChangebyAPI.size(), PAGE_SIZE) == 0){
                    totalCancelPage = listCancelPolicyChangebyAPI.size()/ PAGE_SIZE;
                }else{
                        totalCancelPage = (listCancelPolicyChangebyAPI.size()/ PAGE_SIZE) + 1;
                }
            }else{
                totalCancelPage = 1;
            }
            //END HKITSFDC-44
        }
        checkPolicyChangeRecord(); 
    }
     
    public void initDisplayPagination(){
        if(sitePrefix =='/customer'){
            if(totalSaveList!=null){
                reCalculatePagination();
                system.debug('initDisplayPagination totalSaveList.size(): '+totalSaveList.size());
                system.debug('sanika tabStatus :' + tabStatus + ' fromTab: ' + fromTab);
                /****Init All list****/
                if(fromTab == 'all' || String.isBlank(tabStatus) || tabStatus =='all'){
                    currentAllPage = 1;
                    Integer maxAllRecord = 0;
                        
                    startAllRecordCount = 1; 
                    currentStartAllRecordCount = 1;
                    currentStartSaveRecord = 0;
        
                    if(totalSaveList.size()>0){
                        
                        if(totalSaveList.size() > PAGE_SIZE){
                                
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            listAllPolicyChangebyAPI.clear(); // dont get record from API
                                
                        }else if(totalSaveList.size() == PAGE_SIZE && listAllPolicyChangebyAPI.size()>0){
                                
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            } 
                            listAllPolicyChangebyAPI.clear();// dont get record from API
                                
                        }else{
                                
                            listSavePolicyChange.clear();//clear the list
                            listSavePolicyChange.addAll(totalSaveList);
                            if( totalAllList.size() >= (PAGE_SIZE - totalSaveList.size())){
                                maxAllRecord  = (PAGE_SIZE - totalSaveList.size());
                            }else{
                                maxAllRecord = totalAllList.size();
                            }
                                
                            // get remining record from API List
                            listAllPolicyChangebyAPI.clear();
                            for(Integer i=0; i < maxAllRecord ;i++){
                                listAllPolicyChangebyAPI.add(totalAllList[i]); 
                            }
                                
                            startAllRecordCount = (listAllPolicyChangebyAPI.size()+1);
                        }
                            
                        remainingSavelistsize = totalSaveList.size()-listSavePolicyChange.size();
                            
                        system.debug('listSavePolicyChange.size() '+listSavePolicyChange.size());
                        system.debug('remainingSavelistsize '+remainingSavelistsize );
                            
                    }else{
                        //no saved record from SFDC
                        if( totalAllList.size() >= PAGE_SIZE){
                            maxAllRecord = PAGE_SIZE;
                        }else{
                            maxAllRecord = totalAllList.size();
                        }
                            
                        //no saved record from SFDC
                        listAllPolicyChangebyAPI.clear();
                        for(Integer i=0; i < maxAllRecord ;i++){
                            listAllPolicyChangebyAPI.add(totalAllList[i]); 
                        }
                    }
                }
                
                /****Init in progress list****/
                if(fromTab == 'inprogress' || tabStatus =='inprogress'){
                    currentInprogressPage = 1; 
                    startInprogressRecordCount = 1; 
                    currentStartInprogressRecordCount = 1;
                    currentStartSaveRecord = 0;
                    Integer maxInProgressRecord = 0;
            
                    if(totalSaveList.size()>0){
            
                        if(listSavePolicyChange.size() > PAGE_SIZE){
                                
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            listInprogressPolicyChangebyAPI.clear(); // dont get record from API
            
                        }else if(totalSaveList.size() == PAGE_SIZE && totalInprogressList.size()>0){
                                
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            listInprogressPolicyChangebyAPI.clear();// dont get record from API
                                
                        }else{
                            listSavePolicyChange.clear();//clear the list
                            listSavePolicyChange.addAll(totalSaveList);
                            //calculate how many records should get from WS
                            if( totalInprogressList.size() >= (PAGE_SIZE - totalSaveList.size()) ){
                                maxInProgressRecord = (PAGE_SIZE - totalSaveList.size());
                            }else{
                                maxInProgressRecord = totalInprogressList.size();
                            }
        
                            //get remining record from API List
                            listInprogressPolicyChangebyAPI.clear();
                            for(Integer i=0; i < maxInProgressRecord ;i++){
                                listInprogressPolicyChangebyAPI.add(totalInprogressList[i]); 
                            }
                            startInprogressRecordCount = (listAllPolicyChangebyAPI.size()+1);
                        }
                        remainingSavelistsize = totalSaveList.size()-listSavePolicyChange.size();   
                    }else{
                            
                        if(totalInprogressList.size() >= PAGE_SIZE){
                            maxInProgressRecord = PAGE_SIZE;
                        }else{
                            maxInProgressRecord = totalInprogressList.size();
                        }
                            
                        //no saved record from SFDC
                        listInprogressPolicyChangebyAPI.clear();
                        for(Integer i=0; i < maxInProgressRecord ;i++){
                            listInprogressPolicyChangebyAPI.add(totalInprogressList[i]); 
                        }
                    }
                }
                    
                /****Init completed list****/
                if(fromTab == 'completed' || tabStatus =='completed'){
                    currentCompletedPage = 1;
                    listCompletedPolicyChangebyAPI.clear();
        
                    /**get completed list from totalCompletedList**/
                    Integer maxCompleteRecord = 0;
                    if(totalCompletedList.size() >= PAGE_SIZE){
                        maxCompleteRecord = PAGE_SIZE;
                    }else{
                        maxCompleteRecord = totalCompletedList.size();
                    }
                    for(Integer i = 0; i < maxCompleteRecord ; i++){
                        listCompletedPolicyChangebyAPI.add(totalCompletedList[i]);
                    }
                }
                
                //BEGIN HKITSFDC-44
                /****Init cancel list****/
                if(fromTab == 'cancel' || tabStatus =='cancel'){
                    system.debug('in cancel condition  579 sanika');
                    system.debug('totalCancelList size sanika 580'+totalCancelList);
                    currentCancelPage = 1;
                    listCancelPolicyChangebyAPI.clear();
        
                    /**get completed list from totalCompletedList**/
                    Integer maxCancelRecord = 0;
                    if(totalCancelList.size() >= PAGE_SIZE){
                        maxCancelRecord = PAGE_SIZE;
                    }else{
                        maxCancelRecord = totalCancelList.size();
                    }
                    for(Integer i = 0; i < maxCancelRecord ; i++){
                        listCancelPolicyChangebyAPI.add(totalCancelList[i]);
                    }
                }                
                //END HKITSFDC-44
                
                /***check has next and previous page***/
                if(totalAllPage ==  currentAllPage){
                    hasAllListNext = false;
                }else{
                    hasAllListNext = true;
                }
                    
                if(totalInprogressPage ==  currentInprogressPage){
                    hasInprogressListNext = false;
                }else{
                    hasInprogressListNext = true;
                }

                if(totalCompletedPage ==  currentCompletedPage){
                    hasCompletedListNext = false;
                }else{
                    hasCompletedListNext = true;
                }
                
                //BEGIN HKITSFDC-44
                if(totalCancelPage ==  currentCancelPage){
                    hasCancelListNext = false;
                }else{
                    hasCancelListNext = true;
                }
                //END HKITSFDC-44    
                hasAllListPrevious = false;
                hasInprogressListPrevious = false;
                hasCompletedListPrevious = false;
                hasCancelListPrevious = false;  //HKITSFDC-44
                /*************************************/
                    
            }
        }else{
            /*Save Policy Change*/ 
           /* String searchPolicyHolderId  = '';  
            String searchPolicyHolderName  = '';  
            if(searchType=='Policy Holder Id' && String.isNotBlank(searchInput)){ 
                searchPolicyHolderId = searchInput;
            }
            if(searchType=='Policy Holder Name' && String.isNotBlank(searchInput)){ 
                searchPolicyHolderName = searchInput;
            }*/
            
            totalSaveList = new list<PolicyChange>();
            
            /*getTotalSaveList = new list<PolicyChange>();

            getTotalSaveList.addAll(getSearchSaveListPolicyChange());
            if(getTotalSaveList != null){
               totalSaveList.addAll(getTotalSaveList);
            }*/
            
            totalSaveList.addAll(listSearchSavePolicyChange);

            if(totalSaveList!=null){
                checkPolicyChangeRecord();
                System.debug('totalAllPage '+totalAllPage);
                System.debug('totalInprogressPage '+totalInprogressPage);
                System.debug('totalCompletedPage '+totalCompletedPage);
                System.debug('totalCancelPage '+totalCancelPage);   //HKITSFDC-44
                System.debug('fromTab '+fromTab);
                System.debug('tabStatus '+ tabStatus);
                //for All list
                if(fromTab == 'all' || String.isBlank(tabStatus) || tabStatus =='all'){
                    System.debug('all '+ tabStatus);
                    startAllRecordCount = 1; 
                    currentStartAllRecordCount = 1;
                    currentStartSaveRecord = 0;
                    currentAllPage = 1;
                    List<PolicyChange> tempSearchAllList = new list<PolicyChange>();
                    system.debug('totalSaveList: '+totalSaveList.size());
                    if(totalSaveList.size()>0){
                        
                        if(totalSaveList.size() > PAGE_SIZE){
                            listSearchSavePolicyChange.clear();//clear the list
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                listSearchSavePolicyChange.add(totalSaveList[i]);
                            } 
                            listSearchAllPolicyChange.clear(); // dont get record from API
                                
                        }else if(totalSaveList.size() == PAGE_SIZE && listSearchAllPolicyChange.size()>0){
                        
                            listSearchAllPolicyChange.clear();// dont get record from API
                            
                        }else if(listSearchAllPolicyChange.size() > 0){
                            Integer maxRecord  = (PAGE_SIZE - totalSaveList.size());

                            //kevani's update 12042017
                            if(listSearchAllPolicyChange.size() < maxRecord){
                                maxRecord = listSearchAllPolicyChange.size();
                            }
                            
                            for(Integer i = 0 ; i< maxRecord ; i++){
                                tempSearchAllList.add(listSearchAllPolicyChange[i]);
                            }

                            listSearchAllPolicyChange.clear();
                            listSearchAllPolicyChange = tempSearchAllList;
                            //listSearchAllPolicyChange = getPolicyChange('', 1, maxRecord, searchPolicyHolderName, searchPolicyHolderId);// get remining record from API
                            startAllRecordCount = (listSearchAllPolicyChange.size()+1);
                        }
                            
                        remainingSavelistsize = totalSaveList.size()-listSearchSavePolicyChange.size();  
                    }else if(listSearchAllPolicyChange.size() > 0){
                        //no saved record from SFDC
                        
                        //kevani's update 12042017
                        if(listSearchAllPolicyChange.size() < PAGE_SIZE){
                            for(Integer i = 0 ; i < listSearchAllPolicyChange.size() ; i++){
                                tempSearchAllList.add(listSearchAllPolicyChange[i]);
                            }
                            
                        }else{
                            for(Integer i = 0 ; i < PAGE_SIZE ; i++){
                                tempSearchAllList.add(listSearchAllPolicyChange[i]);
                            }
                        }
                        listSearchAllPolicyChange.clear();
                        listSearchAllPolicyChange = tempSearchAllList;
                        //listSearchAllPolicyChange.addAll(getPolicyChange('', 1, PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
                    }
                        
                    if(totalAllPage ==  currentAllPage){
                        hasAllListNext = false;
                    }else{
                        hasAllListNext = true;
                    }
                }

                // for in progress list
                if(fromTab == 'inprogress' || tabStatus =='inprogress'){
                    System.debug('inprogress '+ tabStatus);
                    startInprogressRecordCount = 1; 
                    currentStartInprogressRecordCount = 1;
                    currentStartSaveRecord = 0;
                    currentInprogressPage = 1;
                    List<PolicyChange> tempSearchInprogressList = new list<PolicyChange>();
                    System.debug('inprogress '+currentInprogressPage);
                    if(totalSaveList.size()>0){
                        if(listSearchSavePolicyChange.size() > PAGE_SIZE){
                            listSearchSavePolicyChange.clear();//clear the list
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                listSearchSavePolicyChange.add(totalSaveList[i]);
                            } 
                            listSearchInProgressPolicyChange.clear(); // dont get record from API
            
                        }else if(totalSaveList.size() == PAGE_SIZE && listSearchInProgressPolicyChange.size()>0){
            
                            listSearchInProgressPolicyChange.clear();// dont get record from API
                                
                        }else if(listSearchInProgressPolicyChange.size() > 0){
                            
                            Integer maxRecord  = (PAGE_SIZE - totalSaveList.size());
                            //kevani update 12042017
                            if(listSearchInProgressPolicyChange.size() < maxRecord){
                                maxRecord = listSearchInProgressPolicyChange.size();
                            }
                            for(Integer i = 0 ; i < maxRecord; i++){
                                tempSearchInprogressList.add(listSearchInProgressPolicyChange[i]);
                            }
                            listSearchInProgressPolicyChange.clear();
                            listSearchInProgressPolicyChange = tempSearchInprogressList;
                            //listSearchInProgressPolicyChange = getPolicyChange('inprogress', 1, maxRecord, searchPolicyHolderName, searchPolicyHolderId);// get remining record from API
                            startInprogressRecordCount = (listSearchAllPolicyChange.size()+1);
                        }
                        remainingSavelistsize = totalSaveList.size()-listSearchSavePolicyChange.size();
                            
                    }else if(listSearchInProgressPolicyChange.size() > 0){
                        //no saved record from SFDC
                        //kevani update 12042017
                        if(listSearchInProgressPolicyChange.size() < PAGE_SIZE){
                            for(Integer i = 0 ; i < listSearchInProgressPolicyChange.size(); i++){
                                tempSearchInprogressList.add(listSearchInProgressPolicyChange[i]);
                            }
                        }else{
                            for(Integer i = 0 ; i < PAGE_SIZE; i++){
                                tempSearchInprogressList.add(listSearchInProgressPolicyChange[i]);
                            }
                        }
                        listSearchInProgressPolicyChange.clear();
                        listSearchInProgressPolicyChange = tempSearchInprogressList;
                        //listSearchInProgressPolicyChange.addAll(getPolicyChange('Inprogress', 1 , PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
            
                    }
                        
                    if(totalInprogressPage ==  currentInprogressPage){
                        hasInprogressListNext = false;
                    }else{
                        hasInprogressListNext = true;
                    }
                    System.debug('currentInprogressPage==='+currentInprogressPage);
                }   
                // for completed list
                if(fromTab == 'completed' || tabStatus =='completed'){
                    List<PolicyChange> tempSearchCompletedList = new list<PolicyChange>();
                    System.debug('completed==='+ tabStatus);
                    currentCompletedPage = 1;
                     //kevani update 12042017
                     if(listSearchCompletedPolicyChange.size()>PAGE_SIZE){
                        for(Integer i = 0 ; i < PAGE_SIZE; i++){
                            tempSearchCompletedList.add(listSearchCompletedPolicyChange[i]);
                        }
                        listSearchCompletedPolicyChange.clear();
                        listSearchCompletedPolicyChange = tempSearchCompletedList;
                        //listSearchCompletedPolicyChange.addAll(getPolicyChange('completed', 1, PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
                    }else{
                        for(Integer i = 0 ; i < listSearchCompletedPolicyChange.size(); i++){
                            tempSearchCompletedList.add(listSearchCompletedPolicyChange[i]);
                        }
                        listSearchCompletedPolicyChange.clear();
                        listSearchCompletedPolicyChange = tempSearchCompletedList;
                    }  
                    if(totalCompletedPage ==  currentCompletedPage){
                        hasCompletedListNext = false;
                    }else{
                        hasCompletedListNext = true;
                    }
                }
                //BEGIN HKITSFDC-44 for cancel list
                if(fromTab == 'cancel' || tabStatus =='cancel'){
                    List<PolicyChange> tempSearchCancelList = new list<PolicyChange>();
                    System.debug('cancel==='+ tabStatus);
                    currentCancelPage = 1;

                    if(listSearchCancelPolicyChange.size()>PAGE_SIZE){
                        for(Integer i = 0 ; i < PAGE_SIZE; i++){
                            tempSearchCancelList.add(listSearchCancelPolicyChange[i]);
                        }
                        listSearchCancelPolicyChange.clear();
                        listSearchCancelPolicyChange = tempSearchCancelList;
                    }else{
                        for(Integer i = 0 ; i < listSearchCancelPolicyChange.size(); i++){
                            tempSearchCancelList.add(listSearchCancelPolicyChange[i]);
                        }
                        listSearchCancelPolicyChange.clear();
                        listSearchCancelPolicyChange = tempSearchCancelList;
                    }  
                    if(totalCancelPage ==  currentCancelPage){
                        hasCancelListNext = false;
                    }else{
                        hasCancelListNext = true;
                    }
                }
                //END HKITSFDC-44
                hasAllListPrevious = false;
                hasInprogressListPrevious = false;
                hasCompletedListPrevious = false;
                hasCancelListPrevious = false; //HKITSFDC-44
            }  
        }
        checkPolicyChangeRecord();
        system.debug('remainingsave at the end of init: '+remainingSavelistsize);
        system.debug('at the end of init totalSaveList: '+this.totalSaveList);
    }

    public void handleNextPage(){ 
        if(totalSaveList==null){
            init();
        }
        
        if(totalSaveList!=null){
            // All list
            if(fromTab == 'all' || String.isBlank(tabStatus) || tabStatus == 'all'){
                if(totalSaveList.size()>0){
                    if(remainingSavelistsize>0){
                        Integer startSaveRecord = (PAGE_SIZE*currentAllPage);
                        Integer endSaveRecord = ((PAGE_SIZE*(currentAllPage+1))-1);
                        currentStartSaveRecord = startSaveRecord;
                        system.debug('currentStartSaveRecord expected = 20 of first click: '+currentStartSaveRecord);
                        if(remainingSavelistsize >= PAGE_SIZE){
                     
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = startSaveRecord ; i < endSaveRecord ; i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            listAllPolicyChangebyAPI.clear();// dont get record from API   
                            remainingSavelistsize = (remainingSavelistsize -PAGE_SIZE);                     
                            
                        }else if(remainingSavelistsize < PAGE_SIZE){
                            system.debug('remainingSavelistsize < PAGE_SIZE remainingSavelistsize: '+remainingSavelistsize);
                            system.debug('remainingSavelistsize < PAGE_SIZE startSaveRecord : '+startSaveRecord);
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = startSaveRecord ; i < totalSaveList.size(); i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                                
                            Integer maxRecord  = (PAGE_SIZE - listSavePolicyChange.size());
                            system.debug('maxRecord: '+maxRecord);
                            listAllPolicyChangebyAPI.clear();
                            listAllPolicyChangebyAPI.addAll(getPolicyChange('', 1, maxRecord,'',''));// get remaining record from API
                            system.debug('listAllPolicyChangebyAPI: '+listAllPolicyChangebyAPI);
                            system.debug('listAllPolicyChangebyAPI.size: '+listAllPolicyChangebyAPI.size());
                            startAllRecordCount = (listAllPolicyChangebyAPI.size()+1);
                            remainingSavelistsize = 0;
                        }
                    }else if(listAllPolicyChangebyAPI.size()>0){
                        //no more saved record from SFDC
                        listSavePolicyChange.clear();//clear the list
                        system.debug('no more record from SFDC listSavePolicyChange: '+listSavePolicyChange);
                            
                        // have got records from API in previous page before startAllRecordCount > 1
                        // havent got records from API in previous page before startAllRecordCount = 1
                        listAllPolicyChangebyAPI.clear();
                        listAllPolicyChangebyAPI.addAll(getPolicyChange('', startAllRecordCount , PAGE_SIZE, '', ''));
                        currentStartAllRecordCount = startAllRecordCount;
                        if(listAllPolicyChangebyAPI.size() <  PAGE_SIZE){
                            startAllRecordCount = startAllRecordCount + listAllPolicyChangebyAPI.size();// for handleprevpage use
                        }else{
                            startAllRecordCount = startAllRecordCount + PAGE_SIZE;
                        }  
                    }
        
                }else if(listAllPolicyChangebyAPI.size()>0){
                    //no saved record from SFDC
                    listAllPolicyChangebyAPI.clear();
                    listAllPolicyChangebyAPI.addAll(getPolicyChange('', (PAGE_SIZE*currentAllPage) , PAGE_SIZE,'',''));
                }
                currentAllPage = currentAllPage + 1; 
                if( totalAllPage ==  currentAllPage){
                    hasAllListNext = false;
                }else{
                    hasAllListNext = true;
                }
                hasAllListPrevious = true;
            }
                
            //in progress list
            if(tabStatus == 'inprogress'){
                if(totalSaveList.size()>0){
                    if(remainingSavelistsize>0){
                        Integer startSaveRecord = (PAGE_SIZE*currentAllPage);
                        Integer endSaveRecord = ((PAGE_SIZE*(currentAllPage+1))-1);
                        currentStartSaveRecord = startSaveRecord;
                        if(remainingSavelistsize >= PAGE_SIZE){
                            
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = startSaveRecord ; i < endSaveRecord; i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            } 
                            listInprogressPolicyChangebyAPI.clear();// dont get record from API   
                            remainingSavelistsize = (remainingSavelistsize -PAGE_SIZE);                     
                            
                        }else if(remainingSavelistsize < PAGE_SIZE){
                            
                            listSavePolicyChange.clear();//clear the list
                            for(Integer i = startSaveRecord ; i < totalSaveList.size(); i++){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                                
                            Integer maxRecord  = (PAGE_SIZE - listSavePolicyChange.size());
                            system.debug('>>>>maxRecord>>>: '+maxRecord);
                            listInprogressPolicyChangebyAPI.clear();
                            listInprogressPolicyChangebyAPI.addAll(getPolicyChange('inprogress', 1, maxRecord,'',''));// get remaining record from API
                            system.debug('>>>>listInprogressPolicyChangebyAPI>>>: '+listInprogressPolicyChangebyAPI);
                            system.debug('>>>>listInprogressPolicyChangebyAPI.size>>>: '+listInprogressPolicyChangebyAPI.size());
                            startInprogressRecordCount = (listInprogressPolicyChangebyAPI.size()+1);
                            remainingSavelistsize = 0;
                        }
                    }else{
                        //no more saved record from SFDC
                        listSavePolicyChange.clear();//clear the list
                        system.debug('>>>>>>no more record from SFDC>>>listSavePolicyChange: '+listSavePolicyChange);
                            
                        // have got records from API in previous page before startInprogressRecordCount > 1
                        // havent got records from API in previous page before startInprogressRecordCount = 1
                        listInprogressPolicyChangebyAPI.clear();
                        listInprogressPolicyChangebyAPI.addAll(getPolicyChange('Inprogress', startInprogressRecordCount , PAGE_SIZE, '', ''));
                        currentStartInprogressRecordCount  = startInprogressRecordCount;
                        if(listInprogressPolicyChangebyAPI.size() <  PAGE_SIZE){
                            startInprogressRecordCount = startInprogressRecordCount + listInprogressPolicyChangebyAPI.size();// for handleprevpage use
                        }else{
                            startInprogressRecordCount = startInprogressRecordCount + PAGE_SIZE;
                        }   
                    }
                }else{
                    //no saved record from SFDC
                    listInprogressPolicyChangebyAPI.clear();
                    listInprogressPolicyChangebyAPI.addAll(getPolicyChange('Inprogress', (PAGE_SIZE*currentInprogressPage) , PAGE_SIZE, '', ''));
    
                }
                currentInprogressPage = currentInprogressPage + 1; 
                if(totalInprogressPage ==  currentInprogressPage){
                    hasInprogressListNext = false;
                }else{
                    hasInprogressListNext = true;
                }
                hasInprogressListPrevious = true;
            }
                
            //completed next page
            if(tabStatus == 'completed'){
                listCompletedPolicyChangebyAPI.clear();
                listCompletedPolicyChangebyAPI.addAll(getPolicyChange('completed', (PAGE_SIZE*currentCompletedPage) , PAGE_SIZE, '', ''));
                     
                currentCompletedPage = currentCompletedPage + 1;  
                if(totalCompletedPage ==  currentCompletedPage){
                    hasCompletedListNext = false;
                }else{
                    hasCompletedListNext = true;
                }  
                hasCompletedListPrevious = true;         
            }
            
            //BEGIN HKITSFDC-44 completed next page
            if(tabStatus == 'cancel'){
                listCancelPolicyChangebyAPI.clear();
                listCancelPolicyChangebyAPI.addAll(getPolicyChange('cancel', (PAGE_SIZE*currentCancelPage) , PAGE_SIZE, '', ''));
                     
                currentCancelPage = currentCancelPage + 1;  
                if(totalCancelPage ==  currentCancelPage){
                    hasCancelListNext = false;
                }else{
                    hasCancelListNext = true;
                }  
                hasCancelListPrevious = true;         
            }
            //END HKITSFDC-44
        }
    }
    
    public void handlePrevPage(){ 
        //All list
        if(fromTab == 'all' || String.isBlank(tabStatus) || tabStatus == 'all'){
            currentAllPage = currentAllPage - 1;
            if(totalSaveList.size()>0){
                if(listAllPolicyChangebyAPI.size()>0){
                    if(listSavePolicyChange.size()>0){
                        // with save list and API list currently
                        listAllPolicyChangebyAPI.clear();
                        Integer startIndex = (totalSaveList.size() - listSavePolicyChange.size() - PAGE_SIZE);
                        Integer endIndex = (totalSaveList.size() - listSavePolicyChange.size());
                        listSavePolicyChange.clear();
                        for(Integer i = startIndex ; i < endIndex ; i++ ){
                            listSavePolicyChange.add(totalSaveList[i]);
                        }
                        remainingSavelistsize = listSavePolicyChange.size();
                    }else{
                        // only API list currently
                        if(currentStartAllRecordCount == 1){
                            //first time get API list, previous page must be all save list
                            system.debug('kevani expected first time get API list, previous page must be all save list');
                            startAllRecordCount = 1;
                            listAllPolicyChangebyAPI.clear();
                            Integer startIndex = (totalSaveList.size() - PAGE_SIZE);
                            Integer endIndex = totalSaveList.size();
                            listSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            remainingSavelistsize = 0;
    
                        }else if(currentStartAllRecordCount < PAGE_SIZE){
                            //previous API not full page, must have save list
                            system.debug('kevani expected previous API not full page, must have save list');
                            Integer maxRecord = (currentStartAllRecordCount - 1);
                            listAllPolicyChangebyAPI.clear();
                            listAllPolicyChangebyAPI.addAll(getPolicyChange('', 1, maxRecord, '', ''));
                            Integer startIndex = (totalSaveList.size() - (PAGE_SIZE - listAllPolicyChangebyAPI.size()));
                            Integer endIndex = totalSaveList.size();
                            listSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            startAllRecordCount = (listAllPolicyChangebyAPI.size() + 1);
                            remainingSavelistsize = 0;
                        }else{
                            //previous API full page
                            system.debug('kevani expected previous API full page');
                            system.debug('startAllRecordCount: '+startAllRecordCount);
                            startAllRecordCount = (currentStartAllRecordCount - PAGE_SIZE);
                            Integer maxRecord = PAGE_SIZE;
                            listAllPolicyChangebyAPI.clear();
                            listAllPolicyChangebyAPI.addAll(getPolicyChange('', startAllRecordCount , maxRecord,'',''));
                            listSavePolicyChange.clear();
                            currentStartAllRecordCount = startAllRecordCount;
                            remainingSavelistsize = 0;
                        }
                    }
                }else{
                    //only save list currently
                    System.debug('kevani expected only save list currently');
                    listSavePolicyChange.clear();
                    for(Integer i = (currentStartSaveRecord - PAGE_SIZE) ; i < currentStartSaveRecord ; i++ ){
                        listSavePolicyChange.add(totalSaveList[i]);
                    }
                    
                    if((currentStartSaveRecord + PAGE_SIZE) == totalSaveList.size()){
                        remainingSavelistsize = 0;
                    }else{
                        remainingSavelistsize = (totalSaveList.size() - currentStartSaveRecord - PAGE_SIZE);
                    }
                }
            }else{
                if(currentAllPage > 1){
                    listAllPolicyChangebyAPI = getPolicyChange('', (PAGE_SIZE*currentAllPage - PAGE_SIZE)  , PAGE_SIZE+1, '', '');
                }
            }
        
            if(currentAllPage > 1){
                hasAllListPrevious = true;
            }else{
                initDisplayPagination();
                hasAllListPrevious = false;
            }
            hasAllListNext = true;
        }
        
        //in progress list
        if(tabStatus == 'inprogress'){
            currentInprogressPage = currentInprogressPage -1;
            if(totalSaveList.size()>0){
                if(listInprogressPolicyChangebyAPI.size()>0){
                    if(listSavePolicyChange.size()>0){
                        // with save list and API list currently
                        listInprogressPolicyChangebyAPI.clear();
                        Integer startIndex = (totalSaveList.size() - listSavePolicyChange.size() - PAGE_SIZE);
                        Integer endIndex = (totalSaveList.size() - listSavePolicyChange.size());
                        listSavePolicyChange.clear();
                        for(Integer i = startIndex ; i < endIndex ; i++ ){
                            listSavePolicyChange.add(totalSaveList[i]);
                        }
                        
                        remainingSavelistsize = listSavePolicyChange.size();
                    }else{
                        // only API list currently
                        if(currentStartInprogressRecordCount == 1){
                           //first time get API list, previous page must be all save list
                            startInprogressRecordCount = 1;
                            listInprogressPolicyChangebyAPI.clear();
                            Integer startIndex = (totalSaveList.size() - PAGE_SIZE);
                            Integer endIndex = totalSaveList.size();
                            listSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            remainingSavelistsize = 0;
                        }else if(currentStartInprogressRecordCount < PAGE_SIZE){
                            //previous API not full page, must have save list
                            Integer maxRecord = (currentStartInprogressRecordCount - 1);
                            listInprogressPolicyChangebyAPI.clear();
                            listInprogressPolicyChangebyAPI.addAll(getPolicyChange('Inprogress', 1, maxRecord, '', ''));
                            
                            Integer startIndex = (totalSaveList.size() - (PAGE_SIZE - listInprogressPolicyChangebyAPI.size()));
                            Integer endIndex = totalSaveList.size();
                            listSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSavePolicyChange.add(totalSaveList[i]);
                            }
                            startInprogressRecordCount = (listInprogressPolicyChangebyAPI.size() + 1);
                            remainingSavelistsize = 0;
                        }else{
                            //previous API full page
                            startInprogressRecordCount = (currentStartInprogressRecordCount - PAGE_SIZE);
                            Integer maxRecord = PAGE_SIZE;
                            listInprogressPolicyChangebyAPI.addAll(getPolicyChange('Inprogress', startInprogressRecordCount , maxRecord, '', ''));
                            listSavePolicyChange.clear();
                            currentStartInprogressRecordCount = startInprogressRecordCount;
                            remainingSavelistsize = 0;
                        }
                    }
                }else{
                    //only save list currently
                    listSavePolicyChange.clear();
                    for(Integer i = (currentStartSaveRecord - PAGE_SIZE) ; i < currentStartSaveRecord ; i++ ){
                        listSavePolicyChange.add(totalSaveList[i]);
                    }
                    
                    if((currentStartSaveRecord + PAGE_SIZE) == totalSaveList.size()){
                        remainingSavelistsize = 0;
                    }else{
                        remainingSavelistsize = (totalSaveList.size() - currentStartSaveRecord - PAGE_SIZE);
                    
                    }
                }
            }else{
                if(currentInprogressPage > 1){
                    listInprogressPolicyChangebyAPI = getPolicyChange('inprogress', (PAGE_SIZE*currentInprogressPage - PAGE_SIZE)  , PAGE_SIZE+1, '', '');
                }
            }
        
            if(currentInprogressPage > 1){
                hasInprogressListPrevious = true;
            }else{
                initDisplayPagination();
                hasInprogressListPrevious = false;
            }
            hasInprogressListNext = true;
        }
        
        if(tabStatus == 'completed'){
            currentCompletedPage = currentCompletedPage -1;

            if(currentCompletedPage > 1){
                listCompletedPolicyChangebyAPI = getPolicyChange('completed', (PAGE_SIZE*currentCompletedPage - PAGE_SIZE)  , PAGE_SIZE+1, '', '');
                hasCompletedListPrevious = true;
            }else{
                initDisplayPagination();
                hasCompletedListPrevious = false;
            }
            hasCompletedListNext = true;
        }
        
        //BEGIN HKITSFDC-44
        if(tabStatus == 'cancel'){
            currentCancelPage = currentCancelPage -1;

            if(currentCancelPage > 1){
                listCancelPolicyChangebyAPI = getPolicyChange('cancel', (PAGE_SIZE*currentCancelPage - PAGE_SIZE)  , PAGE_SIZE+1, '', '');
                hasCancelListPrevious = true;
            }else{
                initDisplayPagination();
                hasCancelListPrevious = false;
            }
            hasCancelListNext = true;
        }
        //END HKITSFDC-44
    }
     
    public void checkPolicyChangeRecord(){
        list<PolicyChange> tempListCheckAllPolicyChange = new list<PolicyChange>();
        list<PolicyChange> tempListCheckProgressPolicyChange = new list<PolicyChange>();
        list<PolicyChange> tempListCheckCompletedPolicyChange = new list<PolicyChange>();
        list<PolicyChange> tempListCheckCancelPolicyChange = new list<PolicyChange>();  //HKITSFDC-44
        
        if(sitePrefix == '/customer'){
            tempListCheckAllPolicyChange.addall(totalAllList);
            tempListCheckAllPolicyChange.addall(totalSaveList);

            tempListCheckProgressPolicyChange.addall(totalInprogressList);
            tempListCheckProgressPolicyChange.addall(totalSaveList);
         
            tempListCheckCompletedPolicyChange.addall(totalCompletedList);
            tempListCheckCancelPolicyChange.addall(totalCancelList);    //HKITSFDC-44
        }else if(sitePrefix == '/broker'){
            tempListCheckAllPolicyChange.addall(listSearchAllPolicyChange);
            tempListCheckAllPolicyChange.addall(listSearchSavePolicyChange);
         
            tempListCheckProgressPolicyChange.addall(listSearchInProgressPolicyChange);
            tempListCheckProgressPolicyChange.addall(listSearchSavePolicyChange);
            
            tempListCheckCompletedPolicyChange.addall(listSearchCompletedPolicyChange);
            tempListCheckCancelPolicyChange.addall(listSearchCancelPolicyChange);   //HKITSFDC-44
        }
        //BEGIN HKITSFDC-44
        //if(tempListCheckAllPolicyChange.size()>0 || tempListCheckProgressPolicyChange.size()>0 || tempListCheckCompletedPolicyChange.size()>0){
        if(tempListCheckAllPolicyChange.size()>0 || tempListCheckProgressPolicyChange.size()>0 || tempListCheckCompletedPolicyChange.size()>0 || tempListCheckCancelPolicyChange.size()>0){
        //END HKITSFDC-44    
            hasNoPolicyChange = false;
        }else{
            hasNoPolicyChange = true;
        }
        
        if(hasNoPolicyChange){
            hasNoProgressPolicyChange = false;
            hasNoCompletedPolicyChange = false;
            hasNoCancelPolicyChange = false; //HKITSFDC-44
        }else{
            if(tempListCheckProgressPolicyChange.size()>0){
                hasNoProgressPolicyChange = false;
            }else{
                hasNoProgressPolicyChange = true;
            }
    
            if(tempListCheckCompletedPolicyChange.size()>0){
                hasNoCompletedPolicyChange = false;
            }else{
                hasNoCompletedPolicyChange = true;
            }
            //BEGIN HKITSFDC-44
            if(tempListCheckCancelPolicyChange.size()>0){
                hasNoCancelPolicyChange = false;
            }else{
                hasNoCancelPolicyChange = true;
            }
            //END HKITSFDC-44
        }
    }

    public void handleNextPageBroker(){ 
        // All list
        system.debug('remainingsave: '+remainingSavelistsize);
        system.debug('currentAllPage '+ currentAllPage);
        system.debug('totalAllPage '+ totalAllPage);
        String searchPolicyHolderId = '';  
        String searchPolicyHolderName = '';  
        if(searchType=='Policy Holder Id' && String.isNotBlank(searchInput)){ 
            searchPolicyHolderId = searchInput;
        }
        if(searchType=='Policy Holder Name' && String.isNotBlank(searchInput)){ 
            searchPolicyHolderName = searchInput;
        }
        System.debug('NextPage '+tabStatus);
        if(fromTab == 'all' || String.isBlank(tabStatus) || tabStatus == 'all'){
            System.debug('NextPage=totalSaveList=='+totalSaveList.size());
            if(totalSaveList!=null && totalSaveList.size()>0){
                System.debug('NextPage=remainingSavelistsize=='+remainingSavelistsize);
                if(remainingSavelistsize>0){
                    Integer startSaveRecord = (PAGE_SIZE*currentAllPage);
                    Integer endSaveRecord = ((PAGE_SIZE*(currentAllPage+1))-1);
                    currentStartSaveRecord = startSaveRecord;
                    if(remainingSavelistsize >= PAGE_SIZE){
                        System.debug('startSaveRecord==all '+startSaveRecord);
                        System.debug('endSaveRecord==all '+endSaveRecord);
                        listSearchSavePolicyChange.clear();//clear the list
                        System.debug('totalSaveList==all '+totalSaveList.size());
                        for(Integer i = startSaveRecord ; i < endSaveRecord ; i++){
                            listSearchSavePolicyChange.add(totalSaveList[i]);
                        }
                        
                        listSearchAllPolicyChange.clear();// dont get record from API   
                        remainingSavelistsize = (remainingSavelistsize -PAGE_SIZE);                     
                    
                    }else if(remainingSavelistsize < PAGE_SIZE){
                        system.debug('remainingSavelistsize < PAGE_SIZE remainingSavelistsize: '+remainingSavelistsize);
                        system.debug('remainingSavelistsize < PAGE_SIZE startSaveRecord : '+startSaveRecord);
                        listSearchSavePolicyChange.clear();//clear the list
                        for(Integer i = startSaveRecord ; i < totalSaveList.size(); i++){
                            listSearchSavePolicyChange.add(totalSaveList[i]);
                        }
                        
                        Integer maxRecord  = (PAGE_SIZE - listSearchSavePolicyChange.size());
                        system.debug('>>>>maxRecord>>>: '+maxRecord);
                        listSearchAllPolicyChange.clear();
                        listSearchAllPolicyChange.addAll(getPolicyChange('', 1, maxRecord,searchPolicyHolderName, searchPolicyHolderId));// get remaining record from API
                        system.debug('>>>>listSearchAllPolicyChange>>>: '+listSearchAllPolicyChange);
                        system.debug('>>>>listSearchAllPolicyChange.size>>>: '+listSearchAllPolicyChange.size());
                        startAllRecordCount = (listSearchAllPolicyChange.size()+1);
                        
                        remainingSavelistsize = 0;
                    }
                }else if(listSearchAllPolicyChange !=null && listSearchAllPolicyChange.size()>0){
                    //no more saved record from SFDC
                    listSearchSavePolicyChange.clear();//clear the list
                    system.debug('>>>>>>no more record from SFDC>>>listSearchSavePolicyChange: '+listSearchSavePolicyChange);
                    system.debug('broker next page: ' + startAllRecordCount);
                
                    // have got records from API in previous page before startAllRecordCount > 1
                    // havent got records from API in previous page before startAllRecordCount = 1
                    listSearchAllPolicyChange.clear();
                    listSearchAllPolicyChange.addAll(getPolicyChange('', startAllRecordCount , PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
                    currentStartAllRecordCount = startAllRecordCount;
                    if(listSearchAllPolicyChange.size() <  PAGE_SIZE){
                        startAllRecordCount = startAllRecordCount + listSearchAllPolicyChange.size();// for handleprevpage use
                    }else{
                        startAllRecordCount = startAllRecordCount + PAGE_SIZE;
                    }
                }
            }else if(listSearchAllPolicyChange!=null && listSearchAllPolicyChange.size()>0){
                //no saved record from SFDC
                System.debug('listSearchAllPolicyChange==='+listSearchAllPolicyChange);
                listSearchAllPolicyChange.clear();
                listSearchAllPolicyChange.addAll(getPolicyChange('', (PAGE_SIZE*currentAllPage) , PAGE_SIZE,searchPolicyHolderName, searchPolicyHolderId));
            }
            
            currentAllPage = currentAllPage + 1; 
            
            if(totalAllPage ==  currentAllPage){
                hasAllListNext = false;
            }else{
                hasAllListNext = true;
            }
            hasAllListPrevious = true;
            system.debug('currentAllPage11 '+ currentAllPage);
            system.debug('totalAllPage 11 '+ totalAllPage);
        }
            
        //in progress list
        if(tabStatus == 'inprogress'){
            if(totalSaveList !=null && totalSaveList.size()>0){
                if(remainingSavelistsize>0){
                    Integer startSaveRecord = (PAGE_SIZE* currentInprogressPage);
                    Integer endSaveRecord = ((PAGE_SIZE*(currentInprogressPage +1))-1);
                    currentStartSaveRecord = startSaveRecord;
                    if(remainingSavelistsize >= PAGE_SIZE){
                        listSearchSavePolicyChange.clear();//clear the list
                        System.debug('totalSaveList=inprogress '+totalSaveList.size());
                        System.debug('startSaveRecord=inprogress '+startSaveRecord);
                        System.debug('endSaveRecord=inprogress '+endSaveRecord);
                        for(Integer i = startSaveRecord ; i < endSaveRecord; i++){
                            listSearchSavePolicyChange.add(totalSaveList[i]);
                        }
                        
                        listSearchInProgressPolicyChange.clear();// dont get record from API   
                        remainingSavelistsize = (remainingSavelistsize -PAGE_SIZE);
                    }else if(remainingSavelistsize < PAGE_SIZE){
                        listSearchSavePolicyChange.clear();//clear the list
                        for(Integer i = startSaveRecord ; i < totalSaveList.size(); i++){
                            listSearchSavePolicyChange.add(totalSaveList[i]);
                        }
                        
                        Integer maxRecord  = (PAGE_SIZE - listSearchSavePolicyChange.size());
                        system.debug('>>>>maxRecord>>>: '+maxRecord);
                        listSearchInProgressPolicyChange.clear();
                        listSearchInProgressPolicyChange.addAll(getPolicyChange('inprogress', 1, maxRecord,searchPolicyHolderName, searchPolicyHolderId));// get remaining record from API
                        system.debug('>>>>listSearchInProgressPolicyChange>>>: '+listSearchInProgressPolicyChange);
                        system.debug('>>>>listSearchInProgressPolicyChange.size>>>: '+listSearchInProgressPolicyChange.size());
                        startInprogressRecordCount = (listSearchInProgressPolicyChange.size()+1);
                        remainingSavelistsize = 0;
                    }
                }else{
                    //no more saved record from SFDC
                    listSearchSavePolicyChange.clear();//clear the list
                    system.debug('no more record from SFDC>>>listSearchSavePolicyChange: '+listSearchSavePolicyChange);
                    
                    // have got records from API in previous page before startInprogressRecordCount > 1
                    // havent got records from API in previous page before startInprogressRecordCount = 1
                    listSearchInProgressPolicyChange.clear();
                    listSearchInProgressPolicyChange.addAll(getPolicyChange('Inprogress', startInprogressRecordCount , PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
                    currentStartInprogressRecordCount  = startInprogressRecordCount;
                    if(listSearchInProgressPolicyChange.size() <  PAGE_SIZE){
                        startInprogressRecordCount = startInprogressRecordCount + listSearchInProgressPolicyChange.size();// for handleprevpage use
                    }else{
                        startInprogressRecordCount = startInprogressRecordCount + PAGE_SIZE;
                    }
                }
            }else{
                //no saved record from SFDC
                listSearchInProgressPolicyChange.clear();
                listSearchInProgressPolicyChange.addAll(getPolicyChange('Inprogress', (PAGE_SIZE*currentInprogressPage) , PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
            }
            currentInprogressPage = currentInprogressPage + 1; 
            if( totalInprogressPage ==  currentInprogressPage){
                hasInprogressListNext = false;
            }else{
                hasInprogressListNext = true;
            
            }
            hasInprogressListPrevious = true;
        }
        
        //completed next page
        if(tabStatus == 'completed'){
            listSearchCompletedPolicyChange.clear();
            listSearchCompletedPolicyChange.addAll(getPolicyChange('completed', (PAGE_SIZE*currentCompletedPage) , PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
             
            currentCompletedPage = currentCompletedPage + 1;  
            if( totalCompletedPage ==  currentCompletedPage ){
                hasCompletedListNext = false;
            }else{
                hasCompletedListNext = true;
            }
            hasCompletedListPrevious = true;         
        }
        
        //BEGIN HKITSFDC-44
        if(tabStatus == 'cancel'){
            listSearchCancelPolicyChange.clear();
            listSearchCancelPolicyChange.addAll(getPolicyChange('cancel', (PAGE_SIZE*currentCancelPage) , PAGE_SIZE, searchPolicyHolderName, searchPolicyHolderId));
             
            currentCancelPage = currentCancelPage + 1;  
            if( totalCancelPage ==  currentCancelPage ){
                hasCancelListNext = false;
            }else{
                hasCancelListNext = true;
            }
            hasCancelListPrevious = true;         
        }
        //END HKITSFDC-44
        
    }
    
    public void handlePrevPageBroker(){ 
        System.debug('currentStartAllRecordCount: '+currentStartAllRecordCount);
        
        //All list
        String searchPolicyHolderId  = '';  
        String searchPolicyHolderName  = '';  
        if(searchType=='Policy Holder Id' && String.isNotBlank(searchInput)){ 
            searchPolicyHolderId = searchInput;
        }
        if(searchType=='Policy Holder Name' && String.isNotBlank(searchInput)){ 
            searchPolicyHolderName = searchInput;
        }
        System.debug('PrevPage==='+tabStatus);
        if(fromTab == 'all' || String.isBlank(tabStatus) || tabStatus == 'all'){
        currentAllPage = currentAllPage - 1;
        system.Debug('handlePrevPageBroker totalSaveList:'+totalSaveList .size());
            if(totalSaveList !=null && totalSaveList.size()>0){
                if(listSearchAllPolicyChange !=null && listSearchAllPolicyChange.size()>0){
                    if(listSearchSavePolicyChange !=null && listSearchSavePolicyChange.size()>0){
                        // with save list and API list currently
                        system.debug('kevani expected with save list and API list currently');
                        listSearchAllPolicyChange.clear();
                        Integer startIndex = (totalSaveList.size() - listSearchSavePolicyChange.size() - PAGE_SIZE);
                        Integer endIndex = (totalSaveList.size() - listSearchSavePolicyChange.size());
                        listSearchSavePolicyChange.clear();
                        for(Integer i = startIndex ; i < endIndex ; i++ ){
                            listSearchSavePolicyChange.add(totalSaveList[i]);
                        }
                        
                        remainingSavelistsize = listSearchSavePolicyChange.size();
    
                    }else{
                        // only API list currently
                        system.debug('kevani expected only API list currently');
                        if(currentStartAllRecordCount == 1){
                           //first time get API list, previous page must be all save list
                            startAllRecordCount = 1;
                            listSearchAllPolicyChange.clear();
                            Integer startIndex = (totalSaveList.size() - PAGE_SIZE);
                            Integer endIndex = totalSaveList.size();
                            listSearchSavePolicyChange.clear();
                            system.debug('startIndex:'+startIndex+'startIndex:'+startIndex);
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSearchSavePolicyChange.add(totalSaveList[i]);
                            }
                            remainingSavelistsize = 0;
    
                        }else if(currentStartAllRecordCount < PAGE_SIZE){
                            //previous API not full page, must have save list
                            system.debug('kevani expected previous API not full page, must have save list');
                            Integer maxRecord = (currentStartAllRecordCount - 1);
                            listSearchAllPolicyChange.clear();
                            listSearchAllPolicyChange.addAll(getPolicyChange('', 1, maxRecord, searchPolicyHolderName, searchPolicyHolderId));
                            Integer startIndex = (totalSaveList.size() - (PAGE_SIZE - listSearchAllPolicyChange.size()));
                            Integer endIndex = totalSaveList.size();
                            listSearchSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSearchSavePolicyChange.add(totalSaveList[i]);
                            }
                            startAllRecordCount = (listSearchAllPolicyChange.size() + 1);
                            remainingSavelistsize = 0;
                        }else{
                            //previous API full page
                            system.debug('kevani expected previous API full page');
                            startAllRecordCount = (currentStartAllRecordCount - PAGE_SIZE);
                            Integer maxRecord = PAGE_SIZE;
                            listSearchAllPolicyChange.clear();
                            listSearchAllPolicyChange.addAll(getPolicyChange('', startAllRecordCount , maxRecord,searchPolicyHolderName, searchPolicyHolderId));
                            listSearchSavePolicyChange.clear();
                            currentStartAllRecordCount = startAllRecordCount;
                            remainingSavelistsize = 0;
                        }
                    }
                }else{
                    //only save list currently
                    system.debug('kevani expected only save list currently');
                    listSearchSavePolicyChange.clear();
                    for(Integer i = (currentStartSaveRecord - PAGE_SIZE) ; i < currentStartSaveRecord ; i++ ){
                        listSearchSavePolicyChange.add(totalSaveList[i]);
                    }
                    
                    if((currentStartSaveRecord + PAGE_SIZE) == totalSaveList.size()){
                        remainingSavelistsize = 0;
                    }else{
                        remainingSavelistsize = (totalSaveList.size() - currentStartSaveRecord - PAGE_SIZE);
                    }
                }
            }else{
                if(currentAllPage > 1){
                    listSearchAllPolicyChange = getPolicyChange('', (PAGE_SIZE*currentAllPage - PAGE_SIZE)  , PAGE_SIZE+1, searchPolicyHolderName, searchPolicyHolderId);
                }
            }
        
            if(currentAllPage > 1){
                hasAllListPrevious = true;
            }else{
                SearchPolicyChange();
                //initDisplayPagination();
                hasAllListPrevious = false;
            }
            hasAllListNext = true;
        }
        
        //in progress list
        if(tabStatus == 'inprogress'){
            currentInprogressPage = currentInprogressPage -1;
            if(totalSaveList !=null && totalSaveList.size()>0){
                if(listSearchInProgressPolicyChange !=null && listSearchInProgressPolicyChange.size()>0){
                    if(listSearchSavePolicyChange !=null && listSearchSavePolicyChange.size()>0){
                        // with save list and API list currently
                        listSearchInProgressPolicyChange.clear();
                        Integer startIndex = (totalSaveList.size() - listSearchSavePolicyChange.size() - PAGE_SIZE);
                        Integer endIndex = (totalSaveList.size() - listSearchSavePolicyChange.size());
                        listSearchSavePolicyChange.clear();
                        for(Integer i = startIndex ; i < endIndex ; i++ ){
                            listSearchSavePolicyChange.add(totalSaveList[i]);
                        }
                        remainingSavelistsize = listSearchSavePolicyChange.size();
                    }else{
                        // only API list currently
                        if(currentStartInprogressRecordCount == 1){
                           //first time get API list, previous page must be all save list
                            startInprogressRecordCount = 1;
                            listSearchInProgressPolicyChange.clear();
                            Integer startIndex = (totalSaveList.size() - PAGE_SIZE);
                            Integer endIndex = totalSaveList.size();
                            listSearchSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSearchSavePolicyChange.add(totalSaveList[i]);
                            }
                            remainingSavelistsize = 0;
                        }else if(currentStartInprogressRecordCount < PAGE_SIZE){
                            //previous API not full page, must have save list
                            Integer maxRecord = (currentStartInprogressRecordCount - 1);
                            listSearchInProgressPolicyChange.clear();
                            listSearchInProgressPolicyChange.addAll(getPolicyChange('Inprogress', 1, maxRecord, searchPolicyHolderName, searchPolicyHolderId));
                            
                            Integer startIndex = (totalSaveList.size() - (PAGE_SIZE - listSearchInProgressPolicyChange.size()));
                            Integer endIndex = totalSaveList.size();
                            listSearchSavePolicyChange.clear();
                            for(Integer i = startIndex ; i < endIndex ; i++ ){
                                listSearchSavePolicyChange.add(totalSaveList[i]);
                            }
                            startInprogressRecordCount = (listSearchInProgressPolicyChange.size() + 1);
                            remainingSavelistsize = 0;
                        }else{
                            //previous API full page
                            startInprogressRecordCount = (currentStartInprogressRecordCount - PAGE_SIZE);
                            Integer maxRecord = PAGE_SIZE;
                            listSearchInProgressPolicyChange.addAll(getPolicyChange('Inprogress', startInprogressRecordCount , maxRecord, searchPolicyHolderName, searchPolicyHolderId));
                            listSearchSavePolicyChange.clear();
                            currentStartInprogressRecordCount = startInprogressRecordCount;
                            remainingSavelistsize = 0;
                        }
                    }
                }else{
                    //only save list currently
                    listSearchSavePolicyChange.clear();
                    for(Integer i = (currentStartSaveRecord - PAGE_SIZE) ; i < currentStartSaveRecord ; i++ ){
                        listSearchSavePolicyChange.add(totalSaveList[i]);
                    }
                    
                    if((currentStartSaveRecord + PAGE_SIZE) == totalSaveList.size()){
                        remainingSavelistsize = 0;
                    }else{
                        remainingSavelistsize = (totalSaveList.size() - currentStartSaveRecord - PAGE_SIZE);
                    }
                }
            }else{
                if(currentInprogressPage > 1){
                    listSearchInProgressPolicyChange = getPolicyChange('inprogress', (PAGE_SIZE*currentInprogressPage - PAGE_SIZE)  , PAGE_SIZE+1, searchPolicyHolderName, searchPolicyHolderId);
                }
            }
        
            if(currentInprogressPage > 1){
                hasInprogressListPrevious = true;
            }else{
                initDisplayPagination();
                hasInprogressListPrevious = false;
            }
            hasInprogressListNext = true;
        }
        
        if(tabStatus == 'completed'){
            currentCompletedPage = currentCompletedPage - 1;

            if(currentCompletedPage > 1){
                listSearchCompletedPolicyChange = getPolicyChange('completed', (PAGE_SIZE*currentCompletedPage - PAGE_SIZE)  , PAGE_SIZE+1, searchPolicyHolderName, searchPolicyHolderId);
                hasCompletedListPrevious = true;
            }else{
                initDisplayPagination();
                hasCompletedListPrevious = false;
            }
            hasCompletedListNext = true;
        }
        
        //BEGIN HKITSFDC-44
        if(tabStatus == 'cancel'){
            currentCancelPage = currentCancelPage - 1;

            if(currentCancelPage > 1){
                listSearchCancelPolicyChange = getPolicyChange('completed', (PAGE_SIZE*currentCancelPage - PAGE_SIZE)  , PAGE_SIZE+1, searchPolicyHolderName, searchPolicyHolderId);
                hasCancelListPrevious = true;
            }else{
                initDisplayPagination();
                hasCancelListPrevious = false;
            }
            hasCancelListNext = true;
        }
        //END HKITSFDC-44
    }

    /**Search Input and SelectList**/
    public list<SelectOption> getSearchCriteria(){ 
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('Policy Holder Name', System.Label.Pol_Policy_holder_name));
        options.add(new SelectOption('Policy Holder Id', System.Label.Policy_Holder_ID));
    
        return options;
    }

    /*Get search Save Policy list for broker */
    public list<PolicyChange> getSearchSaveListPolicyChange(){ 
        list<Policy_Change_Request__c> tempListSearchSavePolicyChange = new list<Policy_Change_Request__c>();
        list<PolicyChange> SearchSaveListPolicyChange = new list<PolicyChange>();
        String saveSearchFieldStr='';
        String searchFieldStr = 'SELECT Id, policy_no__c, Policy_Holder_Name__c, Policy_Holder_Id__c, tolabel(Status__c), tolabel(recordType.Name), recordTypeId, CreatedDate, LastModifiedDate FROM Policy_Change_Request__c WHERE ownerId=\'' + userinfo.getuserid() + '\' AND recordType.Name!=\'Fund Management\' AND recordType.Name!=\'Fund Switching\' AND recordType.Name!=\'Fund Reallocation\' AND recordType.Name!=\'Fund Withdrawal\'';
        /*Save Policy Change*/ 
        
        System.debug('searchInput: '+searchInput);

        if(searchType=='Policy Holder Id' && searchInput!=''){
            saveSearchFieldStr = searchFieldStr + ' AND Status__c=\'Not Submitted\' AND Policy_Holder_Id__c = \''+ String.escapeSingleQuotes(searchInput) +'\' ORDER BY LastModifiedDate DESC';/* add by Jack on 2021-09-03 for project: Veracode sep */
        }
    
        if(searchType=='Policy Holder Name' && searchInput!=''){ 
            //saveSearchFieldStr = searchFieldStr + ' AND Status__c=\'Not Submitted\' AND Policy_Holder_Name__c LIKE \'%'+ searchInput +'%\' ORDER BY LastModifiedDate DESC';
            //Comment by Nicole for Encryption CR in 2018.04.25
            saveSearchFieldStr = searchFieldStr + ' AND Status__c=\'Not Submitted\' ORDER BY LastModifiedDate DESC';
        }   
        System.debug('saveSearchFieldStr: '+saveSearchFieldStr);
        if(saveSearchFieldStr!=''){
            tempListSearchSavePolicyChange = Database.query(saveSearchFieldStr);
            
            //Filter by policy holder name for Encryption start
            if(searchType=='Policy Holder Name' && searchInput!=''){
                if(tempListSearchSavePolicyChange.size()>0){
                    List<Policy_Change_Request__c> temPolicyChangeList = new list<Policy_Change_Request__c>();
                    for(Policy_Change_Request__c policyChange : tempListSearchSavePolicyChange){
                        if(policyChange.Policy_Holder_Name__c!=null){
                            if(policyChange.Policy_Holder_Name__c.containsIgnoreCase(searchInput)){
                                temPolicyChangeList.add(policyChange);
                            }
                        }
                    }
                    
                    tempListSearchSavePolicyChange = new list<Policy_Change_Request__c>();
                    if(temPolicyChangeList.size()>0){
                        tempListSearchSavePolicyChange.addAll(temPolicyChangeList);
                    }
                }
            }
            //Filter by policy holder name for Encryption end
            
            system.debug('>>>tempListSearchSavePolicyChange >>>>: '+tempListSearchSavePolicyChange );
            /*Search Save List Result*/                        
            
            for(Policy_Change_Request__c pcr: tempListSearchSavePolicyChange){ 
                PolicyChange wpc = new PolicyChange();
                wpc.PolicyChangeId =pcr.id;
                wpc.PolicyChangeDate = pcr.LastModifiedDate;
                wpc.PolicyNo =pcr.policy_no__c;
                wpc.PolicyChangeType = pcr.Recordtype.Name;
                wpc.PolicyStatus = pcr.status__c;
                wpc.PolicyHolderName = pcr.Policy_Holder_Name__c;
                wpc.PolicyHolderId = pcr.Policy_Holder_Id__c;
                    
                SearchSaveListPolicyChange.add(wpc);
            }
        }else{
            //no search result, temp show all saveResult
            SearchSaveListPolicyChange.addAll(getSaveListPolicyChange());
        }
        return SearchSaveListPolicyChange;
    }
     
    /**Search Policy Change**/
    public void SearchPolicyChange(){ 
        getWorkStatusSuccess = true;
        callSuccess = true;
        showTooManyRecordError = false;
        listSearchSavePolicyChange = new list<PolicyChange>();
        listSearchAllPolicyChange = new list<PolicyChange>();
        listSearchInProgressPolicyChange  = new list<PolicyChange>();
        listSearchCompletedPolicyChange = new list<PolicyChange>();
        listSearchCancelPolicyChange = new list<PolicyChange>();    //HKITSFDC-44
        
        list<PolicyChange> temlistSearchSavePolicyChange = new list<PolicyChange>();
        list<PolicyChange> temlistSearchAllPolicyChange = new list<PolicyChange>();
        list<PolicyChange> temlistSearchInProgressPolicyChange = new list<PolicyChange>();
        list<PolicyChange> temlistSearchCompletedPolicyChange = new list<PolicyChange>();
        list<PolicyChange> temlistSearchCancelPolicyChange = new list<PolicyChange>();  //HKITSFDC-44

        /*Save Policy Change*/    
        if(searchType == 'Policy Holder Id' && searchInput!=''){ 
            if(fromTab == 'all' || tabStatus =='' || tabStatus =='all'){
                temlistSearchAllPolicyChange.addAll(getPolicyChange('', null, null, null, searchInput));
                if(temlistSearchAllPolicyChange!=null){
                    listSearchAllPolicyChange.addAll(temlistSearchAllPolicyChange);
                }
            }else if(fromTab == 'inprogress' || tabStatus =='inprogress'){
                temlistSearchInProgressPolicyChange.addAll(getPolicyChange('inprogress', null, null, null, searchInput));
                if(temlistSearchInProgressPolicyChange!=null){
                    listSearchInProgressPolicyChange.addAll(temlistSearchInProgressPolicyChange);
                }
            }else if(fromTab == 'completed' || tabStatus == 'completed'){
                temlistSearchCompletedPolicyChange.addAll(getPolicyChange('completed', null, null, null, searchInput));
                if(temlistSearchCompletedPolicyChange!=null){
                    listSearchCompletedPolicyChange.addAll(temlistSearchCompletedPolicyChange);
                }
            }//BEGIN HKITSFDC-44
            else if(fromTab == 'cancel' || tabStatus == 'cancel'){
                temlistSearchCancelPolicyChange.addAll(getPolicyChange('cancel', null, null, null, searchInput));
                if(temlistSearchCancelPolicyChange!=null){
                    listSearchCancelPolicyChange.addAll(temlistSearchCancelPolicyChange);
                }
            }//END HKITSFDC-44
            
        }else if(searchType =='Policy Holder Name' && searchInput!=''){ 
            if(fromTab =='all' ||tabStatus =='' || tabStatus =='all'){
                temlistSearchAllPolicyChange.addAll(getPolicyChange('', null, null, searchInput, null));
                if(temlistSearchAllPolicyChange!=null){
                    listSearchAllPolicyChange.addAll(temlistSearchAllPolicyChange);
                }
            }else if(fromTab == 'inprogress' || tabStatus =='inprogress'){
                temlistSearchInProgressPolicyChange.addAll(getPolicyChange('inprogress', null, null, searchInput, null));
                if(temlistSearchInProgressPolicyChange!=null){
                    listSearchInProgressPolicyChange.addAll(temlistSearchInProgressPolicyChange);
                }
            }else if(fromTab == 'completed' || tabStatus == 'completed'){
                temlistSearchCompletedPolicyChange.addAll(getPolicyChange('completed', null, null, searchInput, null));
                if(temlistSearchCompletedPolicyChange!=null){
                    listSearchCompletedPolicyChange.addAll(temlistSearchCompletedPolicyChange);
                }
            }//BEGIN HKITSFDC-44
            else if(fromTab == 'cancel' || tabStatus == 'cancel'){
                temlistSearchCancelPolicyChange.addAll(getPolicyChange('cancel', null, null, searchInput, null));
                if(temlistSearchCancelPolicyChange!=null){
                    listSearchCancelPolicyChange.addAll(temlistSearchCancelPolicyChange);
                }
            }//END HKITSFDC-44
            
        }else{

        /*Kevani update
        * if no search input - get all result from WS*
            if(fromTab =='all' ||tabStatus =='' || tabStatus =='all'){
                temlistSearchAllPolicyChange.addAll(getPolicyChange('', null, null, null, null));
                if(temlistSearchAllPolicyChange!=null){
                    listSearchAllPolicyChange.addAll(temlistSearchAllPolicyChange);
                }
            }else if(fromTab == 'inprogress' || tabStatus =='inprogress'){
                temlistSearchInProgressPolicyChange.addAll(getPolicyChange('inprogress', null, null, null, null));
                if(temlistSearchInProgressPolicyChange!=null){
                    listSearchInProgressPolicyChange.addAll(temlistSearchInProgressPolicyChange);
                }
            }else if(fromTab == 'completed' || tabStatus == 'completed'){
                temlistSearchCompletedPolicyChange.addAll(getPolicyChange('completed', null, null, null, null));
                if(temlistSearchCompletedPolicyChange!=null){
                    listSearchCompletedPolicyChange.addAll(temlistSearchCompletedPolicyChange);
                }
            }*/
    
        }
        
        listSearchSavePolicyChange = getSearchSaveListPolicyChange();
        system.debug('Is there anything? listSearchSavePolicyChange:'+listSearchSavePolicyChange.size());
        
        if(listSearchSavePolicyChange !=null){
            //reCalculatePagination
            Integer totalAllRecord = listSearchSavePolicyChange.size() + listSearchAllPolicyChange.size();
            if(totalAllRecord > 0){
                if(Math.mod(totalAllRecord, PAGE_SIZE) == 0){
                    totalAllPage = totalAllRecord/ PAGE_SIZE;
                }else{
                    totalAllPage = (totalAllRecord/ PAGE_SIZE) + 1;
                }
            }else{
                totalAllPage = 1;
            }
         
            Integer totalInprogressRecord = listSearchSavePolicyChange.size() + listSearchInProgressPolicyChange.size();
            if(totalInprogressRecord > 0){
                if(Math.mod(totalInprogressRecord, PAGE_SIZE) == 0){
                    totalInprogressPage = totalInprogressRecord/ PAGE_SIZE;
                }else{
                    totalInprogressPage = (totalInprogressRecord/ PAGE_SIZE) + 1;
                }
            }else{
                totalInprogressPage = 1;
            }
            
            if(listSearchCompletedPolicyChange.size()>0){
                if(Math.mod(listSearchCompletedPolicyChange.size(), PAGE_SIZE) == 0){
                    totalCompletedPage = listSearchCompletedPolicyChange.size()/ PAGE_SIZE;
                }else{
                    totalCompletedPage = (listSearchCompletedPolicyChange.size()/ PAGE_SIZE) + 1;
                }
            }else{
                totalCompletedPage = 1;
            }
            
            //BEGIN HKITSFDC-44
            if(listSearchCancelPolicyChange.size()>0){
                if(Math.mod(listSearchCancelPolicyChange.size(), PAGE_SIZE) == 0){
                    totalCancelPage = listSearchCancelPolicyChange.size()/ PAGE_SIZE;
                }else{
                    totalCancelPage = (listSearchCancelPolicyChange.size()/ PAGE_SIZE) + 1;
                }
            }else{
                totalCancelPage = 1;
            }
            //END HKITSFDC-44
        }
        initDisplayPagination();
     }
     
    /*Get Save Policy list*/
    public list<PolicyChange> getSaveListPolicyChange(){ 
        system.debug('getSaveListPolicyChange'+searchType);
        list<PolicyChange> SaveListPolicyChange = new list<PolicyChange>();
        // 20200306 - minghua - ILAS
        List<Policy_Change_Request__c> listPolicyChangeNotSubmitTemp = null;
        if(isCustomer){
            listPolicyChangeNotSubmitTemp = [Select id, policy_no__c, tolabel(Recordtype.Name), Policy_Holder_Name__c, Policy_Holder_Id__c, tolabel(Status__c), recordTypeId, CreatedDate, LastModifiedDate 
                FROM Policy_Change_Request__c WHERE ownerId=:recordOwner AND ((Status__c='Not Submitted' AND recordType.Name!='Fund Management' AND recordType.Name!='Fund Switching' AND recordType.Name!='Fund Reallocation' AND recordType.Name!='Fund Withdrawal') OR (Status__c ='Draft' AND recordType.Name='Fund Switching') OR (Status__c ='Draft' AND recordType.Name='Fund Reallocation')) ORDER BY LastModifiedDate DESC];
        }else{
            listPolicyChangeNotSubmitTemp = [Select id, policy_no__c, tolabel(Recordtype.Name), Policy_Holder_Name__c, Policy_Holder_Id__c, tolabel(Status__c), recordTypeId, CreatedDate, LastModifiedDate 
                FROM Policy_Change_Request__c WHERE ownerId=:recordOwner AND Status__c='Not Submitted' AND recordType.Name!='Fund Management' AND recordType.Name!='Fund Switching' AND recordType.Name!='Fund Reallocation' AND recordType.Name!='Fund Withdrawal' ORDER BY LastModifiedDate DESC];
        }
        if(listPolicyChangeNotSubmitTemp != null){
            for(Policy_Change_Request__c temp :listPolicyChangeNotSubmitTemp){ 
                PolicyChange pc= new PolicyChange();
                     
                pc.PolicyChangeId =temp.id;
                pc.PolicyChangeDate = temp.LastModifiedDate;
                pc.PolicyNo =temp.policy_no__c;
                pc.PolicyChangeType = temp.Recordtype.Name;
                
                // 20200306 - minghua - ILAS
                if(temp.Status__c =='Draft'){
                    String fundType = temp.Recordtype.Name;
                    pc.OldStatus = 'Draft';
                    if(fundType == 'Fund Switching'){
                        if(System.UserInfo.getLanguage().contains('zh')){
                            pc.PolicyChangeType = Label.Fund_Switch;
                            pc.PolicyStatus = transField.get('Draft_for_Fund_Switching').get('zh_TW');
                        }else{
                            pc.PolicyStatus = transField.get('Draft_for_Fund_Switching').get('en_US');
                        }
                    }else if(fundType == 'Fund Reallocation'){
                        if(System.UserInfo.getLanguage().contains('zh')){
                            pc.PolicyChangeType = Label.Fund_Reallocation;
                            pc.PolicyStatus = transField.get('Draft_for_Fund_Reallocation').get('zh_TW');
                        }else{
                            pc.PolicyStatus = transField.get('Draft_for_Fund_Reallocation').get('en_US');
                        }
                    }
                }else{
                    pc.PolicyStatus = temp.status__c;
                }

                pc.PolicyHolderName =temp.Policy_Holder_Name__c;
                pc.PolicyHolderId =temp.Policy_Holder_Id__c;
                
                SaveListPolicyChange.add(pc);
            }
        }
        return SaveListPolicyChange;
    }
    
    /*
    *Get All Policy list*
    public list<PolicyChange> getAllListPolicyChange(){ 
        if(searchType!='' && searchInput!=''){ 
              return listSearchAllPolicyChange;
           }else{ 
               return listAllPolicyChangebyAPI;
        }
     }

    *Get In Progress Policy list*
    public list<PolicyChange> getInProgressListPolicyChange(){ 
        if(searchType!='' && searchInput!=''){ 
              return listSearchInProgressPolicyChange;
           }else{ 
               return listInProgressPolicyChangebyAPI;
        }
     }
    
    *Get Completed Policy list*
    public list<PolicyChange> getCompletedListPolicyChange(){
        if(searchType!='' && searchInput!=''){ 
            return listSearchCompletedPolicyChange;
           }else{     
            return listCompletedPolicyChangebyAPI;
        }
     }

    public list<PolicyHolderInfo> getListPolicyHolderInfo(){ 
        
        list<PolicyHolderInfo> listPolicyHolderInfo= new list<PolicyHolderInfo>();
        ***Dummy***
        PolicyHolderInfo ph = new PolicyHolderInfo();
        
        ph.Name='Cherry Huang';
        ph.Id='H0001';
        ph.Email= 'chanht@gmail.com';
        ph.ContactNo='9999 8888';
        
        listPolicyHolderInfo.add(ph);
        
        PolicyHolderInfo ph2 = new PolicyHolderInfo();
        
        ph2.Name='Tsang Ju Shang';
        ph2.Id='H0002';
        ph2.Email= 'tsangjs@gmail.com';
        ph2.ContactNo='9999 6767';
        
        listPolicyHolderInfo.add(ph2);

        return listPolicyHolderInfo;
    
    }
    */
    
    /*remove Policy Change*/
    public void removePolicyChange(){ 
        if(String.isNotBlank(removePolicyChangeId)){ 
            list<Policy_Change_Request__c> checkExit = [SELECT id FROM Policy_Change_Request__c WHERE id=:removePolicyChangeId limit 1];
            
            if(!checkExit.isEmpty()){
                Policy_Change_Request__c pc = new Policy_Change_Request__c();
                pc.id = removePolicyChangeId;

                // 20200306 - minghua - ILAS
                try{
                    delete(pc);
                    List <Policy_Change_Request_Detail__c> pcqDList = [SELECT Id FROM Policy_Change_Request_Detail__c where Policy_Change_Request__c =: removePolicyChangeId];
                    if(pcqDList!= null && pcqDList.size() > 0){
                        Delete pcqDList;
                    }
                }catch(Exception ex){}
                
                if(listSavePolicyChange.size() == 1){
                    listSavePolicyChange.clear();
                }
                initDisplayPagination();
            }else{
                System.debug(removePolicyChangeId + 'has been removed');
            }
        }
    } 

    public class PolicyChange{ 
        public String PolicyChangeId{get;set;}
        public Datetime PolicyChangeDate{get;set;}
        public String PolicyNo{get;set;} 
        public String PolicyChangeType{get;set;}
        public String PolicyStatus{get;set;}
        public String PolicyHolderName{get;set;}
        public String PolicyHolderId{get;set;}
        public String OldStatus{get;set;} //20200306 - minghua - ILAS
    }
    
    /*public class PolicyHolderInfo { 
        
        public String Name{get;set;}
        public String Id{get;set;}
        public String Email{get;set;}
        public String ContactNo{get;set;}
    
    }*/
    
    /*Nicole Modify Srtart*/
    public list<PolicyChange> getPolicyChange(String Status, Integer startRecord, Integer maxRecord, String PolicyHolderName, String PolicyHolderId){
        getPolicyChangeCount = getPolicyChangeCount + 1;
        PolicyCalloutHelper policyHelper = new PolicyCalloutHelper();
        List<HttpCalloutVO.Policy> policyListbyHolder = new List<HttpCalloutVO.Policy>();
        List<HttpCalloutVO.WorkStatus> policyChangeList = new List<HttpCalloutVO.WorkStatus>();
        WorkCalloutHelper workHelper = new WorkCalloutHelper();
        
        if(sitePrefix =='/customer'){        //get Customer SSN Number
            //Get Holder Infornmation
            String holderSsnNumber='';
            //Id holderContactId = [Select Id,ContactId From User Where Id = :Userinfo.getUserId()].ContactId;
            //Id holderAccountId = [Select Id,AccountId From Contact Where Id = :holderContactId].AccountId;
            //String holderSsnNumber = [Select Id, SSN__c From Account Where Id = :holderAccountId].SSN__c;
            User userIns = [Select Id,ContactId,Contact.AccountId, Contact.Account.SSN__c From User Where Id=:Userinfo.getUserId()];
            if(userIns !=null && userIns.Contact.Account.SSN__c !=null){
                holderSsnNumber = userIns.Contact.Account.SSN__c;
            }
            //getWorkStatus
            try{
                // Rancho_PI69_20220609 - remove PendingMemoRequest parameter for getting all records
                policyChangeList = workHelper.getWorkStatusByUserLoginName('Policy Change Request', null, null, startRecord, maxRecord, status);
                system.debug('sanika policyChangeList size in getWorkStatusByUserLoginName loop' +  policyChangeList.size());
                system.debug('sanika policyChangeList size in getWorkStatusByUserLoginName loop' +  policyChangeList);
            }catch(exception e){
            
            }

        }else if(sitePrefix =='/broker'){   //get Holder Customer Under Login Broker
            //Get policy List
           try{
                if(!test.isrunningtest()){
                    policyListbyHolder = policyHelper.getIndividualPolicyListBasicByCriteria('', PolicyHolderName, PolicyHolderId, '', '', '');//default get userloginName
                }
                callSuccess = true;
                showTooManyRecordError = false;
            }catch(CignaWSResultTooLargeException e1){
                system.debug('There is error on calling getIndividualPolicyListBasicByCriteria');
                showTooManyRecordError = True;
                errorMessage = Label.WS_result_set_size_is_over_1000;
                callSuccess = false;
                getWorkStatusSuccess  = false;
                System.debug('**e**'+e1);
                System.debug('**getStackTraceString**'+e1.getStackTraceString());
            } 
            
            /*catch(CignaWSTimeoutException e2){
                system.debug('There is error on calling getIndividualPolicyListBasicByCriteria');
                showTooManyRecordError = True;
                errorMessage = Label.WS_Connection_Timeout;
                callSuccess = false;
                getWorkStatusSuccess  = false;
                System.debug('**getStackTraceString**'+e2.getStackTraceString());
            } catch(CignaWSException e3){
                system.debug('There is error on calling getIndividualPolicyListBasicByCriteria');
                showTooManyRecordError = True;
                errorMessage = e3.getMessage(); 
                callSuccess = false;
                getWorkStatusSuccess  = false;
                System.debug('**getStackTraceString**'+e3.getStackTraceString());
            } catch(Exception e4){
                system.debug('There is error on calling getIndividualPolicyListBasicByCriteria');
                showTooManyRecordError = True;
                errorMessage = e4.getMessage();
                callSuccess = false; 
                getWorkStatusSuccess  = false;
                System.debug('**getStackTraceString**'+e4.getStackTraceString());
            } */
            
            if(callSuccess){
                String policyNos='';
                Integer i = 1;
                for(HttpCalloutVO.Policy policy : policyListbyHolder){
                    if(i<policyListbyHolder.size()){
                        policyNos = policyNos + policy.policyNumber + ',';
                        i++;
                    }else{
                        policyNos = policyNos + policy.policyNumber;
                    }
                    mapPolicyInfo.put(policy.policyNumber,policy);
                }
                
                system.debug('check policy change: '+policyNos);
                //getWorkStatus
                try{
                    if(!test.isrunningtest() && policyNos!=''){
                        // Rancho_PI69_20220609 - remove PendingMemoRequest parameter for getting all records
                        policyChangeList = workHelper.getWorkStatus(policyNos.replace(' ', ''), 'Policy Change Request', null, null, startRecord, maxRecord, status);
                        system.debug('sanika policyChangeList size in getWorkstatus' +  policyChangeList.size());
                        system.debug('sanika policyChangeList size in getWorkstatus' +  policyChangeList);
                    }
                    getWorkStatusSuccess = true;
                }catch(CignaWSResultTooLargeException e1){
                    showTooManyRecordError = True;
                    errorMessage = Label.WS_result_set_size_is_over_1000;
                    getWorkStatusSuccess  = false;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_result_set_size_is_over_1000));
                } 
                /*catch(CignaWSTimeoutException e2){
                    showTooManyRecordError = True;
                    errorMessage = Label.WS_Connection_Timeout;
                    getWorkStatusSuccess  = false;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.WS_Connection_Timeout));
                } catch(CignaWSException e3){
                    showTooManyRecordError = True;
                    errorMessage = e3.getMessage(); 
                    getWorkStatusSuccess  = false; //Label.WS_result_set_size_is_over_1000;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e3.getMessage()));
                } catch(Exception e4){
                    // Handle the exception
                    showTooManyRecordError = True;
                    errorMessage = e4.getMessage(); 
                    getWorkStatusSuccess  = false; //Label.WS_result_set_size_is_over_1000;
                }*/
            }
        }
        
        // Rancho_MR956_20231219 - hide invalid policy change type
        List<String> invalidTypeList = Label.Invalid_Policy_Change_Type.split(';');
        Datetime dateScope = datetime.now().addMonths(-3);//Temp for HKITSFDC-44
      
        //Datetime dateScope = datetime.now().addMonths(-30);//added sanika for testing
        System.debug('dateScope '+dateScope);
        list<PolicyChange> listPolicyChange = new list<PolicyChange>();
        system.debug('sanika policyChangeList size in date scope : ' + policyChangeList.size());
        for(HttpCalloutVO.WorkStatus work : policyChangeList){
            if(work.submittedDateTime != null && work.submittedDateTime < dateScope){
                continue;
            }else if(null != invalidTypeList && invalidTypeList.contains(work.workType)){
                continue;
            }
            PolicyChange policyChange = new PolicyChange();
            policyChange.PolicyNo = work.policyNumber ;
            policyChange.PolicyChangeType = work.salesForceWorkType;
            //BEGIN HKITSFDC-44
            system.debug('sanika work.requestStatus : ' + work.requestStatus);
            if(work.requestStatus.containsIgnoreCase('Pending Information')||work.requestStatus.containsIgnoreCase('Work in Progress')){
                policyChange.PolicyStatus = system.label.Additional_Information_Required;
            }
            //if(work.requestStatus.containsIgnoreCase('processing')||work.requestStatus.containsIgnoreCase('pending')){
            else if(work.requestStatus.containsIgnoreCase('processing')||work.requestStatus.containsIgnoreCase('pending')||work.requestStatus.containsIgnoreCase('Additional')){
            //END HKITSFDC-44
                policyChange.PolicyStatus = system.label.Processing;
            }else if(work.requestStatus.containsIgnoreCase('Completed')||work.requestStatus.containsIgnoreCase('Processed')|| (work.requestStatus.containsIgnoreCase('Request') && work.requestStatus.containsIgnoreCase('Closed')) ){
                policyChange.PolicyStatus = system.label.Completed;
            }//BEGIN HKITSFDC-44
            else if(work.requestStatus.containsIgnoreCase('Cancel') || work.requestStatus.containsIgnoreCase('Terminated') ||  work.requestStatus.containsIgnoreCase('Cancelled')){
                policyChange.PolicyStatus = system.label.Cancel;
            }
            //END HKITSFDC-44
            else{
                policyChange.PolicyStatus = work.requestStatus ;
            }
            system.debug('sanika policyChange.PolicyStatus: ' +policyChange.PolicyStatus);
            policyChange.PolicyChangeDate = work.submittedDateTime;
            if(mapPolicyInfo!=null){
                if(mapPolicyInfo.get(work.policyNumber)!=null){
                    policyChange.PolicyHolderName = mapPolicyInfo.get(work.policyNumber).holderName;//work.policyHolder;
                    policyChange.PolicyHolderId = mapPolicyInfo.get(work.policyNumber).holderSSN;//work.policyHolderId;
                }
            }
            listPolicyChange.add(policyChange);

        }
        system.debug('sanika listPolicyChange size in date scope : ' + listPolicyChange.size());
        system.debug('Status'+Status+listPolicyChange);          
        return listPolicyChange;
    }
    /*Nicole Modify End*/
    
    //Ray's Updates
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
}