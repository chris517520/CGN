/********************************************************************************
Apex Class Name - CreateAccAndOpp
Version - 1.0
Created Date - Feb 11, 2018
@description Controlloer for TMCreateAccAndOppVFP

Modification Log : 
--------------------------------------------------------------------------------

*Version  Developer       Date          Description
* 1.0     Andy        2018/02/11       Create account and oppty
* 2.0     Andy        2018/06/01       Revision of logic in Avaya integration
* 3.0     Ringo       2026/06/22       Fix "Too many query rows: 50001" in checkDuplicateAccount: add LIMIT, null guard, and selective WHERE clause.
********************************************************************************/

public without sharing class TMCreateAccAndOppCtrl{
    public User currentUser{
        get{
            User currentUser = [select id, Name, ProfileId, UserRoleId, UserName, User_Type__c, LanguageLocaleKey, userrole.developername from User where id = : Userinfo.getUserId()];
            return currentUser;  
        }
        set;           
    }
    public final static String EMAIL_REGEX = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
    public static Pattern emailPattern = Pattern.compile(EMAIL_REGEX);

    // === FIX 2026-06-22 by Ringo: Junk phone blocklist to avoid huge duplicate scans ===
    private static final Set<String> JUNK_PHONES = new Set<String>{
        '00000000','11111111','22222222','33333333','44444444',
        '55555555','66666666','77777777','88888888','99999999',
        '12345678','87654321'
    };
    // === END FIX ===

    public Account newAccount{get;set;}
    public Opportunity newOppty{get;set;}
    public String lastName{get;set;}
    public String firstName{get;set;}
    public String salutation{get;set;}
    public String hotlineNumber{get;set;}  //Auto populate by CTI
    public String phoneNumber{get;set;}
      
    public Date birthday{get;set;} //newAccount.PersonBirthdate

    public List<SelectOption> oppRecordTypeOption{get;set;}
    public String accountRecordTypeStr{get;set;}
    public String opptyRecordTypeStr{get;set;}
    public Date opptyCloseDate{get;set;}

    public Integer duplicateCount{get;set;}
    public List<Account> possibleDuplicateAccount{get;set;}
    public Id duplicateAccountId{get;set;}

    public Integer duplicateOpptyCount{get;set;}
    public List<Opportunity> possibleDuplicateOppty{get;set;}

    public Campaign selectedCampaign{get;set;}


    //for Referral Opp Creation
    public boolean isReferralOpp{get;set;}
    public String referCampaignId{get;set;}
    public String referOpptyId{get;set;}
    public String referOpptyRecordTypeId{get;set;}
    public String referOpptyName{get;set;}   //show in VFP

    public List<SelectOption> giftSelectList{get;set;}
    public Map<String,String> recordTypeMap{get;set;}
    public String acctAge{get;set;}
    public List<String> shortHotlineNumList{get;set;}
    public boolean isEmailEmpty{get;set;}
    public boolean isMobileEmpty{get;set;}
    public Account accountAfterProcess{get;set;}

    public boolean isUnidentifiedCall{get;set;}
    public boolean isOverallOptout{get;set;}

    public Integer ACCage{get;set;}

    public boolean isDirectCreate{get;set;}

    public boolean isTransfer{get;set;}

    //For Transfer Request Change
    public boolean isShowTransferNotification{get;set;}
    public List<Opportunity> duplicateOpp{get;set;}
    //For Transfer Request Change end here

    //for oppty transfer request
    public String tOpptyId{get;set;}
    public String tOppAccountId{get;set;}

    public List<SelectOption> salutationList{
        get{ 
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pe : ple){
                if(pe.getValue() == 'Mr.' || pe.getValue() == 'Ms.' || pe.getValue() == 'Mrs.' || pe.getValue() == 'Dr.' || pe.getValue() == 'Prof.'){
                    options.add(new SelectOption(pe.getValue(), pe.getLabel()));
                }
            }
            return options;
        }
    }
  
    public TMCreateAccAndOppCtrl(){
        
        newAccount = new Account();
        newOppty = new Opportunity();
        newOppty.name = 'DO NOT MODIFY';
        isUnidentifiedCall = false;
        isOverallOptout = true;

        isTransfer = false;
        isDirectCreate = false;
        
        //For Transfer Request Change
        isShowTransferNotification = false;
        duplicateOpp = new List<Opportunity>();
        //For Transfer Request Change end here
        
        //Get input param
        Map<String, String> para = Apexpages.CurrentPage().getParameters();
        hotlineNumber = para.get('DNIS');  
        phoneNumber = para.get('ANI');
        //Get DNIS map in custom setting
        getHotLineList();
        
        //Get Account & Oppty Recordtype ID & init default value for some field.
        accountRecordTypeStr = 'TM Customer';
        
        RecordType accRecordType = [Select Id,Name,developerName From RecordType where sObjectType='Account' and isActive=true and developerName='TM_Customer'];
        system.debug('accRecordType.id' + accRecordType.id);    
        newAccount.RecordTypeid = accRecordType.id;
        
        newAccount.PersonMobilePhone = phoneNumber;
        
        RecordType opprt = [select Id, Name, developerName from RecordType where sobjectType = 'Opportunity' and isActive=true and developerName='TM_Opportunity'];
                            
        newOppty.RecordTypeid = opprt.id;
        newOppty.StageName = 'Cigna';
        
        //for referral opp creation case begin
        referCampaignId = para.get('referCampaignId');
        referOpptyId = para.get('referOpptyId');
        referOpptyRecordTypeId = para.get('referOpptyRecordTypeId');
        isReferralOpp = false;
        if(referCampaignId != null && referCampaignId != '' && referOpptyId != null && referOpptyId != ''){
            isReferralOpp = true;
            
            //get referral Oppty RecordType
            RecordType referralOpptyRecordType = [Select Name, Id From RecordType where sObjectType='Opportunity' and isActive=true and id= :referOpptyRecordTypeId];
            opptyRecordTypeStr = referralOpptyRecordType.Name;
            newOppty.RecordTypeid = referralOpptyRecordType.id;
            
            //for show referral Oppty name on VFP
            newOppty.Referee_Opportunity__c = referOpptyId;
            Opportunity referralOpp = [Select id,name from Opportunity where id = :referOpptyId];
            referOpptyName = referralOpp.name;
            
            /*check if is side order case
            * the logic of side order for oppty -- Oppty is marked with side order only when:
            * 1.respective campaign type = BUL; and
            * 2.oppty is a referral case
            */
            Campaign referCampaign = [Select id,name,Campaign_Type__r.Name from Campaign where id = :referCampaignId];
            if(referCampaign.Campaign_Type__r.Name == 'BUL'){
                newOppty.Is_Side_Order__c = true;
            }
            
            //get referral oppty campaign 
            newOppty.Campaign__c = referCampaignId;
            selectCampaign();
        }
        //for referral opp creation case end
        
        
        //for Oppty Transfer Request Page
        tOpptyId = para.get('toppId');
        if(tOpptyId != null && tOpptyId != ''){
            isTransfer = true;
            
            Opportunity o = [Select id,name,StageName,Referee_Opportunity__c,Referral_Relationship__c,Source__c,Phone_Source__c,Campaign__c,Gift__c, Category__c,CloseDate, accountid from Opportunity where id = :tOpptyId];
            
            newOppty = o.clone();
            
            tOppAccountId = newOppty.accountid;
            
            newAccount = [Select lastname,firstname,salutation,Chinese_Name__c,PersonMobilePhone,email__c,Fax,SSN__c,Gender__c, PersonBirthdate__c,Age__c,Nationality__c,TM_Industry__c,Home_Address_Line_1__c,Home_Address_Line_2__c, Home_Address_Line_3__c,Home_Address_Line_4__c,PersonHomePhone,LHB_policy_number__c, LHB_certificate_number__c from Account where id = :tOppAccountId];
                            
            if(String.isNotBlank(newAccount.lastName)){
                lastName = newAccount.lastName;
            }
            if(String.isNotBlank(newAccount.firstname)){
                firstname = newAccount.firstname;
            }
            if(String.isNotBlank(newAccount.salutation)){
                salutation = newAccount.salutation;
            }
            selectCampaign();
            autoCalculateAge();
        }
        
        //Pass Hotline number to oppty field.
        if(hotlineNumber != null && hotlineNumber != '' && hotlineNumber != 'null'){
            hotlineNumber = hotlineNumber.substring(hotlineNumber.length() - 3);
            newOppty.Hotline_Number__c = hotlineNumber;
        }else{
            newOppty.Hotline_Number__c = '';
        }
        
        // Auto pupulated field and retrive info in DNIS Mapping in Custom Setting 
        if(hotlineNumber != null && hotlineNumber != ''){
            List<DNIS__c> dnisInfo = [SELECT Avaya_VDN__c,Campaign_Code__c,Channel__c,Hotline_Type__c,TVC_version__c, Lead_Source__c,One_Call_Number__c,Product__c,Spot_Number__c, TD_hotline__c FROM DNIS__c WHERE Spot_Number__c = :hotlineNumber ];
            
            if(dnisInfo != null && dnisInfo.size() > 0){
                DNIS__c dnis = dnisInfo[0];
                newOppty.Hotline_Type__c = dnis.Hotline_Type__c;//Hotline Type
                newOppty.TVC_version__c = dnis.TVC_version__c;//TVC version
                newOppty.Avaya_VDN__c = dnis.Avaya_VDN__c;//Avaya VDN
                newOppty.Spot_Number__c = dnis.Spot_Number__c;//Spot Number
                newOppty.TD_hotline__c = dnis.TD_hotline__c;//TD hotline
                newOppty.Lead_Source__c = dnis.Lead_Source__c;//Lead Source
                newOppty.Hotline_Product__c = dnis.Product__c;//Hotline Product
                newOppty.Hotline_Channel__c = dnis.Channel__c;//Hotline Channel
                //newOppty.Referee_Opportunity__c   //Referee Opportunity
            }
        }
        
        //init duplicateCount
        duplicateCount = 0;
        duplicateOpptyCount = 0;
    }
    
    public PageReference saveAccAndOppty(){
        system.debug('TMCreateAccAndOppVFP Save');
        return saveData();
    }
    
    public PageReference directCreate(){
        system.debug('[TMCreateAccAndOppCtrl] directCreate');
        isDirectCreate = true;
        return saveData();
    }
    
    public PageReference saveData(){
        SavePoint sp = Database.setSavepoint(); 
        
        duplicateCount = 0;
        duplicateOpptyCount = 0;
        //newAccount.Owner = tmManager;  //Should be TM Manager. But the logic will be in Account Trigger.
        newAccount.LastName = lastName;
        newAccount.FirstName = firstName;
        newAccount.Salutation = salutation;
        newAccount.Overall_Opt_Out__pc = isOverallOptout;
        if(acctAge != null && acctAge != ''){
            newAccount.Age__c = Decimal.valueOf(acctAge);
        }
        newOppty.name = 'DO NOT MODIFY';
        
        PreProcessingHelper processingHelper = new PreProcessingHelper();
        
        try{
            
            //PreProcess  Begin
            
            //Validation Begin
            
            if(!isUnidentifiedCall){
                boolean validationPass = true;
                Matcher emailMatcher;
                
                if(selectedCampaign == null){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose the Campaign field again.');
                    ApexPages.addMessage(msg);
                    return null;
                }
                
                //Campaign Expiry date validation DPSP-781
                if(selectedCampaign.Expiry_Date__c < Date.today()){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Expired Campaign is not allowed for selection.');
                    ApexPages.addMessage(msg);
                    validationPass = false;
                }
                
                if(String.isBlank(tOpptyId)){
                    Id sid = selectedCampaign.Id;
                    Campaign selectedC = [Select id, name, recordType.developerName, Campaign_type__r.Is_Inbound_Campaign__c, Campaign_type__r.name from Campaign where id = :sid];
                    //if(selectedC.recordType.developerName == 'Core_Campaign_Executed_Outbound' || selectedC.Campaign_type__r.Is_Inbound_Campaign__c == false){
                    if((selectedC.recordType.developerName == 'Core_Campaign_Executed_Outbound' || selectedC.Campaign_type__r.Is_Inbound_Campaign__c == false)&&!'BUL'.equals(selectedC.Campaign_type__r.Name)){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Outbound Campaign is not allowed for selection.');
                        ApexPages.addMessage(msg);
                        return null;
                    }
                }
                
                //1.Email mandatory check
                if(!isEmailEmpty && (newAccount.email__c == null || newAccount.email__c == '')){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please input Email address.');
                    ApexPages.addMessage(msg);
                    validationPass = false;
                }
                if(String.isNotBlank(newAccount.email__c)){
                    emailMatcher = emailPattern.matcher(newAccount.email__c);
                    if(isEmailEmpty){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the email address field.');
                        ApexPages.addMessage(msg);
                        validationPass = false;
                    }
                    if(!emailMatcher.matches()){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the email address format.');
                        ApexPages.addMessage(msg);
                        validationPass = false;
                    }
                }
                //2.Phone Number validation 
                
                if(!isMobileEmpty){
                    if(String.isBlank(newAccount.personMobilePhone)){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Mobile Phone number. Please input again.');
                        ApexPages.addMessage(msg);
                        validationPass = false;
                    }else if(!processingHelper.isValidNumber(newAccount.personMobilePhone)){
                        system.debug('Invalid Mobile Phone number. Please input again.');
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Mobile Phone number. Please input again.');
                        ApexPages.addMessage(msg);
                        validationPass = false;
                    }
                }else if(isMobileEmpty && String.isNotBlank(newAccount.personMobilePhone)){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the mobile phone field.');
                    ApexPages.addMessage(msg);
                    validationPass = false;
                }
                
                //3. Hotline Number validation
                //DPSP-493 If is referral case , the "Hotline Number" should not mandatory
                if(!isReferralOpp){
                    if(!String.isNotBlank(newOppty.Hotline_Number__c) || !shortHotlineNumList.contains(newOppty.Hotline_Number__c)){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Hotline Number.');
                        ApexPages.addMessage(msg);
                        validationPass = false;
                    }
                }else{
                    if(String.isNotBlank(newOppty.Hotline_Number__c) && !shortHotlineNumList.contains(newOppty.Hotline_Number__c)){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Hotline Number.');
                        ApexPages.addMessage(msg);
                        validationPass = false;
                    }
                }
                
                //LastName 
                if(!String.isNotBlank(lastName)){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please input Account LastName.');
                    ApexPages.addMessage(msg);
                    validationPass = false;
                }
                //Gender
                if(!String.isNotBlank(newAccount.Gender__c)){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please input Account Gender.');
                    ApexPages.addMessage(msg);
                    validationPass = false;
                }
                
                //Residential address length limit  
                if(invalidAddress(newAccount.Home_Address_Line_1__c) || invalidAddress(newAccount.Home_Address_Line_2__c) ||
                   invalidAddress(newAccount.Home_Address_Line_3__c) || invalidAddress(newAccount.Home_Address_Line_4__c)){
                       ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'The length of each residential address has a limit of 80 characters.');
                       ApexPages.addMessage(msg);
                       validationPass = false; 
                   }
                
                //Portable CR begin
                if(String.isNotBlank(newAccount.LHB_policy_number__c) && 
                    (!newAccount.LHB_policy_number__c.isNumeric() || newAccount.LHB_policy_number__c.length() > 5 || newAccount.LHB_policy_number__c.length() < 4)){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'LHB policy number only allow 4-5 numeric characters.');
                    ApexPages.addMessage(msg);
                    validationPass = false; 
                }
                
                if(String.isNotBlank(newAccount.LHB_certificate_number__c) && newAccount.LHB_certificate_number__c.length() != 7){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'LHB certificate number allow 7 characters only.');
                    ApexPages.addMessage(msg);
                    validationPass = false; 
                }
                
                //Portable CR end
                
                if(!validationPass){
                    return null;
                }
                //Validation End
            }else{
                
                //Campaign Expiry date validation DPSP-781
                if(selectedCampaign.Expiry_Date__c < Date.today()){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Expired Campaign is not allowed for selection.');
                    ApexPages.addMessage(msg);
                    return null;
                }
                
                if(String.isBlank(tOpptyId)){
                    Id sid = selectedCampaign.Id;
                    Campaign selectedC = [Select id, name, recordType.developerName, Campaign_type__r.Is_Inbound_Campaign__c from Campaign where id = :sid];
                    if(selectedC.recordType.developerName == 'Core_Campaign_Executed_Outbound' || selectedC.Campaign_type__r.Is_Inbound_Campaign__c == false){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Outbound Campaign is not allowed for selection.');
                        ApexPages.addMessage(msg);
                        return null;
                    }
                }
                
                //for the case of recording unidentified inbound call.
                List<Account> dummyAccount = [Select id,name from Account where RecordType.developerName='TM_Dummy_Account' limit 1];
                if(!dummyAccount.isEmpty()){
                    Opportunity dummyOppty = createDummyOppty(dummyAccount[0].id);
                    
                    RecordType callRecordType = [Select Id,Name,developerName From RecordType where isActive=true and developerName='TM_Call'];
                     
                    Task invalidCallDetail = new Task();
                    
                    invalidCallDetail.whatId = dummyOppty.id;
                    invalidCallDetail.subject = 'Call';
                    invalidCallDetail.recordTypeId = callRecordType.id;
                    invalidCallDetail.Status = 'Completed';
                    insert invalidCallDetail;
                    
                    PageReference opptyDetailPage = new PageReference('/'+dummyOppty.id);
                    opptyDetailPage.setRedirect(true);
                    return opptyDetailPage;
                }else{
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Can not find Dummy Account, Please contact system admin.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            
            List<Account> accountProcessList = new List<Account>();
            accountProcessList.add(newAccount);
            processingHelper = new PreProcessingHelper();
            processingHelper.preProcessing(accountProcessList);
            accountAfterProcess = accountProcessList[0];
            
            newOppty.Mobile_Phone_2__c = accountAfterProcess.PersonMobilePhone;
            newOppty.Home_Phone_2__c = accountAfterProcess.PersonHomePhone;
            
            //PreProcess  End
            
            //if oppty is from oppty transfer request page, skip account/oppty duplicate checking
            if(tOpptyId != null && tOpptyId != ''){
                
                return checkDuplicateOppty();
            }
            //4. Check Duplicate Account
            if(!isMobileEmpty && !isDirectCreate){
                checkDuplicateAccount(accountAfterProcess);
            }
            if(duplicateCount > 0){
                return null;
            }else{
                List<Account> ssnDuplicatedAcc_all = new List<Account>();
                List<Account> ssnDuplicatedAcc = new List<Account>();
                if(String.isNotBlank(newAccount.ssn__c)){
                    boolean hasCustomerId = false;
                    // === FIX 2026-06-22 by Ringo: Added LIMIT to prevent row limit exception ===
                    ssnDuplicatedAcc_all = [select id, name, ssn__c, customer_id__c, createddate 
                                            from Account 
                                            where ssn__c = :newAccount.ssn__c 
                                            order by createddate asc 
                                            LIMIT 200];
                    // === END FIX ===
                    if(!ssnDuplicatedAcc_all.isEmpty()){
                        for(Account dacc : ssnDuplicatedAcc_all){
                            if(String.isNotBlank(dacc.customer_id__c)){
                                ssnDuplicatedAcc.add(dacc);
                                hasCustomerId = true;
                                break;
                            }
                        }
                        if(!hasCustomerId){
                            ssnDuplicatedAcc.add(ssnDuplicatedAcc_all[0]);
                        }
                    }
                }
                
                if(!isMobileEmpty || !isDirectCreate){
                    system.debug('insert newAccount');
                    
                    if(!ssnDuplicatedAcc.isEmpty()){
                        newOppty.Accountid = ssnDuplicatedAcc[0].id;
                        system.debug('[TMCreateAccAndOpp] newOppty.Accountid' + newOppty.Accountid);
                    }else{
                        insert accountAfterProcess;
                        system.debug('newAccount'+accountAfterProcess.id);
                        system.debug(accountAfterProcess);
                        newOppty.Accountid = accountAfterProcess.id;
                        system.debug('[TMCreateAccAndOpp] newOppty.Accountid' + newOppty.Accountid);
                    }
                }else{
                    if(!ssnDuplicatedAcc.isEmpty()){
                        newOppty.Accountid = ssnDuplicatedAcc[0].id;
                        system.debug('[TMCreateAccAndOpp] newOppty.Accountid' + newOppty.Accountid);
                    }else{
                        insert newAccount;
                        newOppty.Accountid = newAccount.Id;
                    }
                    newOppty.ownerId = currentUser.Id;
                    newOppty.name = 'DO NOT MODIFY';
                    system.debug('[TMCreateAccAndOpp] newOppty.Accountid' + newOppty.Accountid);
                }
                
                system.debug('[TMCreateAccAndOpp] retrive info in DNIS Mapping Begin');
                // for auto pupulated field and retrive info in DNIS Mapping in Custom Setting 
                if(newOppty.Hotline_Number__c != null && newOppty.Hotline_Number__c != ''){
                    String hlNum = newOppty.Hotline_Number__c;
                    List<DNIS__c> dnisInfo = [SELECT Avaya_VDN__c,Campaign_Code__c,Channel__c,Hotline_Type__c,TVC_version__c, Lead_Source__c,One_Call_Number__c,Product__c,Spot_Number__c, TD_hotline__c FROM DNIS__c WHERE Spot_Number__c = :hlNum];
                    
                    if(dnisInfo != null && dnisInfo.size() > 0){
                        DNIS__c dnis = dnisInfo[0];
                        newOppty.Hotline_Type__c = dnis.Hotline_Type__c;//Hotline Type
                        newOppty.TVC_version__c = dnis.TVC_version__c;//TVC version
                        newOppty.Avaya_VDN__c = dnis.Avaya_VDN__c;//Avaya VDN
                        newOppty.Spot_Number__c = dnis.Spot_Number__c;//Spot Number
                        newOppty.TD_hotline__c = dnis.TD_hotline__c;//TD hotline
                        newOppty.Lead_Source__c = dnis.Lead_Source__c;//Lead Source
                        newOppty.Hotline_Product__c = dnis.Product__c;//Hotline Product
                        newOppty.Hotline_Channel__c = dnis.Channel__c;//Hotline Channel
                        //newOppty.Referee_Opportunity__c   //Referee Opportunity
                    }
                }
                system.debug('[TMCreateAccAndOpp] retrive info in DNIS Mapping End');
                
                //If mobile phone is empty, skip opp dedup rule.
                
                Id opptyAfterInsertId;
                system.debug('[TMCreateAccAndOpp] Insert Oppty Begin [isMobileEmpty] ' + isMobileEmpty );
                
                if(ssnDuplicatedAcc.isEmpty()){
                    OpportunityDeDuplicationHelper odh = new OpportunityDeDuplicationHelper(newOppty.Campaign__c,new Set<Id> {newOppty.accountid});
                    List<Opportunity> opptyAfterInsertList = odh.deDuplicatedInsert(new List<Opportunity> {newOppty},true);
                    Opportunity opptyAfterInsert = new Opportunity();
                    opptyAfterInsert = opptyAfterInsertList[0];
                    opptyAfterInsertId = opptyAfterInsert.id;
                    system.debug('###newOppty###'+opptyAfterInsert.id);
                }else{
                    ApexPages.currentPage().getParameters().put('acctId', newOppty.accountid);
                    return checkDuplicateOppty();
                }
                
                system.debug('[TMCreateAccAndOpp] insertCampaignFreeGift Begin');
                insertCampaignFreeGift();
                system.debug('[TMCreateAccAndOpp] insertCampaignFreeGift End');
                
                PageReference opptyDetailPage = new PageReference('/'+opptyAfterInsertId);
                opptyDetailPage.setRedirect(true);
                return opptyDetailPage;
            }
        }catch(Exception e){
            if(!e.getMessage().contains('Salutation and Gender')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR:'+e.getMessage()));
            }
            if(!isTransfer && newAccount!= null && newAccount.Id != null){
                newAccount.Id = null;
            }
            Database.rollback(sp); 
            return null;
        }
    }
    
    /*
    * Check if duplicate account exist, if yes then block the save action
    *
    * === FIX 2026-06-22 by Ringo ===
    * Root cause: original query had no LIMIT and used non-selective OR on
    * PersonMobilePhone / SSN. When phone or SSN was blank/junk, the query
    * scanned the whole Account table and hit "Too many query rows: 50001".
    *
    * Changes:
    *   1. Skip the query when BOTH phone and SSN are blank (nothing to match).
    *   2. Skip the query when phone is a known junk value (e.g. 00000000).
    *   3. Build a dynamic SOQL so only non-blank fields are used in WHERE.
    *   4. Use RecordType.DeveloperName IN (...) instead of OR (uses index).
    *   5. Use ssn__c != null instead of ssn__c != '' (correct SOQL semantics).
    *   6. Add LIMIT 200 as a hard safety cap.
    * === END FIX ===
    */
    public void checkDuplicateAccount(Account acct){
        String dphone = acct.PersonMobilePhone;
        String dssn   = acct.SSN__c;

        // === FIX 2026-06-22 by Ringo: Init result list to avoid null ===
        possibleDuplicateAccount = new List<Account>();
        duplicateCount = 0;
        // === END FIX ===

        // === FIX 2026-06-22 by Ringo: Guard against blank/junk inputs ===
        if(String.isNotBlank(dphone) && JUNK_PHONES.contains(dphone)){
            dphone = null;  // treat junk phone as no input
        }
        if(String.isBlank(dphone) && String.isBlank(dssn)){
            system.debug('[checkDuplicateAccount] Both phone and SSN blank, skip dup check.');
            return;
        }
        // === END FIX ===

        // === FIX 2026-06-22 by Ringo: Build selective dynamic SOQL with LIMIT ===
        List<String> conditions = new List<String>();
        if(String.isNotBlank(dphone)){
            conditions.add('PersonMobilePhone = :dphone');
        }
        if(String.isNotBlank(dssn)){
            conditions.add('(ssn__c = :dssn AND ssn__c != null)');
        }

        String soql =
            'SELECT id, name, ssn__c, PersonMobilePhone, ownerid, owner.name, '
          + '       owner.userrole.developername, createddate '
          + 'FROM Account '
          + 'WHERE (' + String.join(conditions, ' OR ') + ') '
          + '  AND RecordType.DeveloperName IN (\'TM_Customer\',\'Customer\') '
          + 'ORDER BY CreatedDate DESC '
          + 'LIMIT 200';

        system.debug('[checkDuplicateAccount] SOQL: ' + soql);
        possibleDuplicateAccount = Database.query(soql);
        // === END FIX ===

        if(possibleDuplicateAccount != null && possibleDuplicateAccount.size() > 0){
            duplicateCount = possibleDuplicateAccount.size();
        }
    }
    
    //If have Duplicate Account, then let user select one, use account id as input param, de-dup oppty
    public PageReference checkDuplicateOppty(){
        Id acctId = Apexpages.currentPage().getParameters().get('acctId');
        if(tOpptyId != null && tOpptyId != ''){
            acctId = tOppAccountId;
        }
        newOppty.Accountid = acctId;
        duplicateAccountId = acctId;  //define duplicateAccountId, used in updateDuplicateOppty
        system.debug('acctId : ' + acctId);
        
        OpportunityDeDuplicationHelper odh = new OpportunityDeDuplicationHelper(newOppty.Campaign__c,new Set<Id> { acctId });
        
        if(odh.isDuplicated(newOppty)){
            /*
             *if has Duplicate oppty, find the duplicated Oppty and show it on front end.
            */
            //return null;
            if(odh.isSameOwner || Test.isRunningTest()){
                if(tOpptyId != null && tOpptyId != ''){
                    return updateDuplicateOppty();
                }else{
                    return updateDuplicateOppty();
                }
            }else{
                isShowTransferNotification = true;
                List<Opportunity> dupOpptyList = odh.findDuplicated(newOppty);
                    List<Id> dupOppIdList = new List<Id>();
                    for(Opportunity o : dupOpptyList){
                        if(!o.name.startsWith('XXXXXX-')){
                            dupOppIdList.add(o.id);
                        }
                    }

                    possibleDuplicateOppty = [Select id,name,ownerid,owner.name,Batch_No__c,Opportunity_ID__c,Result__c from Opportunity where id in :dupOppIdList];
                    duplicateOpptyCount = possibleDuplicateOppty.size();
                return null;
            }
        }else{
            //if no Duplicated oppty, create it and jump to the new oppty detail page.
            List<Opportunity> opptyAfterInsertList = odh.deDuplicatedInsert(new List<Opportunity> {newOppty},true);
            Opportunity opptyAfterInsert = new Opportunity();
            opptyAfterInsert = opptyAfterInsertList[0];
            system.debug('###newOppty###'+opptyAfterInsert.id);
            
            PageReference opptyDetailPage = new PageReference('/'+opptyAfterInsert.id);
            opptyDetailPage.setRedirect(true);
            return opptyDetailPage;
        }
    }
    
    /*
    * Use OpportunityDeDuplicationHelper to update exsiting oppty
    */
    public PageReference updateDuplicateOppty(){
        newOppty.Accountid = duplicateAccountId;
        OpportunityDeDuplicationHelper odh = new OpportunityDeDuplicationHelper(newOppty.Campaign__c,new Set<Id> {duplicateAccountId});
        List<Opportunity> opptyAfterInsertList = odh.deDuplicatedInsert(new List<Opportunity> {newOppty},true);
        Opportunity opptyAfterInsert = new Opportunity();
        opptyAfterInsert = opptyAfterInsertList[0];
        system.debug('newOppty '+opptyAfterInsert.id);
        
        if(opptyAfterInsert.ownerid == currentUser.id){
            PageReference opptyDetailPage = new PageReference('/'+opptyAfterInsert.id);
            opptyDetailPage.setRedirect(true);
            return opptyDetailPage;
        }else{
            Id oppId = opptyAfterInsert.id;
            // Rancho_AH25817_20221102 - approval is needed when update owner, no matter what the owner/login user is
            // if(!CignaUtil.isTMLeader(opptyAfterInsert.ownerid)){
                //Request transfer approval
                Opportunity o = [Select id,name,To_Be_Approved__c,ownerId,owner.UserRoleId from Opportunity where id = :oppId];
                o.To_Be_Approved__c = currentUser.id;
                update o;
                List<Id> approverIdList = getApproverIdList(o.owner.id,o.owner.UserRoleId);
                submitForApproval(o,currentUser,approverIdList );
                
                //TODO create dummy oppty
                Opportunity dummyOppty = createDummyOppty(duplicateAccountId);
                
                PageReference opptyDetailPage = new PageReference('/'+dummyOppty.id);
                opptyDetailPage.setRedirect(true);
                return opptyDetailPage;
            // }else{
            //     //If Oppty is owned by Team Lead, will auto transfer the owner to the agent
            //     Opportunity trasnferOpp = [Select id,ownerid from Opportunity where id = :oppId];
            //     trasnferOpp.ownerid = currentUser.id;
            //     update trasnferOpp;
                
            //     PageReference opptyDetailPage = new PageReference('/'+trasnferOpp.id);
            //     opptyDetailPage.setRedirect(true);
            //     return opptyDetailPage;
            // }
        }
    }
    
    /*
    * Create dummy oppty for invalid call
    */
    public Opportunity createDummyOppty(Id accId){
        
        Opportunity dummyOppty = new Opportunity();
        dummyOppty.ownerid = currentUser.id;
        dummyOppty.accountId = accId;
        dummyOppty.Name = 'XXXXXX-'+DateTime.now().format('yyyy-MM-dd-HH-mm');
        
        dummyOppty.campaign__c = newOppty.campaign__c;
        dummyOppty.Hotline_Number__c = newOppty.Hotline_Number__c;
        dummyOppty.CloseDate = newOppty.CloseDate;
        dummyOppty.StageName = newOppty.StageName;
        
        insert dummyOppty;
        
        return dummyOppty;
    }
    
    public void selectCampaign(){
        String camId = newOppty.Campaign__c;
        
        List<Campaign> clist = [SELECT id, name, Expiry_Date__c from Campaign WHERE Id =: camId LIMIT 1];
        if(!clist.isEmpty()){
            selectedCampaign = clist[0];
            opptyCloseDate = selectedCampaign.Expiry_Date__c;
            newOppty.CloseDate = opptyCloseDate;
            system.debug('exday ' + selectedCampaign.Expiry_Date__c);
        }
    }
    
    public void insertCampaignFreeGift(){
        if(newOppty.Campaign__c != null && newOppty.Gift__c != null){
            Id cId = newOppty.Campaign__c;
            Id giftId = newOppty.Gift__c;
            List<Campaign_Free_Gift__c> dupcfg = [Select id from Campaign_Free_Gift__c where Campaign__c = :cId and Free_Gift__c = :giftId];
            if(dupcfg != null && dupcfg.size() > 0){
                
            }else{
                Campaign_Free_Gift__c cfg = new Campaign_Free_Gift__c();
                cfg.Campaign__c = newOppty.Campaign__c;
                cfg.Free_Gift__c = newOppty.Gift__c;
                insert cfg;
            }
        }
    }
    
    /*
    * Get Hotline number from DNIS custom setting
    */
    public void getHotLineList(){
        List<DNIS__c> dnisInfo = [SELECT Avaya_VDN__c,Campaign_Code__c,Channel__c,Hotline_Type__c,TVC_version__c,Lead_Source__c,One_Call_Number__c,Product__c,Spot_Number__c,TD_hotline__c FROM DNIS__c];
        
        shortHotlineNumList = new List<String>();
        for(DNIS__c d : dnisInfo){
            shortHotlineNumList.add(d.Spot_Number__c);
        }
    }
    
    /*
    * Get team leader's id list. 
    */
    public List<Id> getApproverIdList(Id opptyOwnerId, Id opptyOwnerRoleId){
        system.debug('opptyOwnerRoleId '  + opptyOwnerRoleId);
        List<Id> approverIdList = new List<Id>(); 
        /*
        User owner = [Select id,name,managerid from User where id = :opptyOwnerId];
        if(owner != null && owner.managerid != null){
            User mgt = [Select id,name from User where id = :owner.managerid];
            if(mgt != null){
                approverIdList.add(mgt.id);
            }
        }
        */
        // Queue ID of Opportunity_Transfer_Request_Approver
        approverIdList.add('00G0K000004YkZb');
        
        return approverIdList;
    }
    
    public void autoCalculateAge(){
        if(null != newAccount.PersonBirthdate__c){
            ACCage = calculateAge(newAccount.PersonBirthdate__c);
            System.debug('newAccount.PersonBirthdate__c :' + newAccount.PersonBirthdate__c);
        }
    }
    
    public Integer calculateAge(Date d){
        
        // Leap Year handling
        Date d1 = Date.newInstance(2000, d.month(), d.day());
        Date d2 = Date.newInstance(2000, Date.today().month(), Date.today().day());
        if(d1 <= d2){
            return Date.today().year() - d.year();
        }else{
            return Math.max(Date.today().year() - d.year() - 1, 0);
        }
    }
    
    public void submitForApproval(Opportunity a, User submitter, List<Id> approverIdList){
        system.debug('approverIdList'+ approverIdList);
        // Create an approval request for the Opportunity 
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(a.id);
        
        // Submit on behalf of a specific submitter
        req.setSubmitterId(submitter.Id); 
        // Submit the record to specific process and skip the criteria evaluation
        req.setProcessDefinitionNameOrId('Opportunity_Transfer_Request');       
        req.setSkipEntryCriteria(true);
        system.debug('[TMCreateAccAndOppCtrl] submitForApproval oppty.To_Be_Approved__c = '+a.To_Be_Approved__c);

        req.setNextApproverIds(approverIdList);
        // Submit the approval request for the Opportunity 
        Approval.ProcessResult result = null;
        try {
            result = Approval.process(req);
        }catch(DmlException e){
            String errMsg = e.getMessage();
            if(errMsg.contains('ALREADY_IN_PROCESS')){
                a.addError('The Opportunity transfer is already in process. Please review.');
                return;
            }
        }
    }
    
    private boolean invalidAddress(String addr){
        if(String.isNotBlank(addr) && addr.length() > 80){
            return true;
        }
        return false;
    }
}