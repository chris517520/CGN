public without sharing class BrkSubmitHospitalController{ 
    /* Page variables */
    public Claim__c claimRequest{get;set;} 
    public Decimal currentStep{get;set;}
    public string claimId{get;set;}
    public string policyNo{get;set;}
    public string removePreAdminationId{get;set;}
    public String userLanguage{get;set;}
    public List<PersonInsured> personInsuredList{get;set;}
    public String uSSN{get;set;}
    public String phName{get;set;} // TO DO
    public Boolean eligible{get;set;}
    public String brokerContactNo{get;set;}
    public Boolean isSearched{get;set;}
    /*translate fields*/
    public Map<String, Map<String, String>> transField{
        get{
            if(transField == null){
            transField = new Map<String, Map<String, String>>();
                for(Translate__mdt t : [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c like '%uploadFile%']){
                    // system.debug(t.DeveloperName);
                    transField.put(t.DeveloperName, new Map<String, String>{'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c });
                }
            }
            return transField;
        }
        set;
    }
    public String transKey{
        get{
            if(transKey ==null){
                transKey ='';
                for(String s : transField.keySet()){
                    transKey += '~' + s + '~';
                }
            }
            return transKey;
        }set;
    }
    /* PI search */
    public String errorMsg{get;set;}
    public String selectedSearchType{get;set;}
    public String selectedSearchValue{get;set;}
    public Boolean showTooManyRecordError{get;set;}
    public List<SelectOption> getSearchType(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Person_Insured',Label.Person_Insured)); //Ray's Updates
        options.add(new SelectOption('Person_Insured_ID',Label.Person_Insured_ID));
        //Rancho_JR1878_20210104
        options.add(new SelectOption('Policy_Number',Label.Policy_Number));
        options.add(new SelectOption('Policy_Holder_Name',Label.Pol_Policy_holder_name));
        options.add(new SelectOption('Policy_Holder_ID',Label.Policy_Holder_ID));
        return options;
    }
    // Rancho_JR1878_20210104
    public String policyNumber{get;set;}
    public Boolean isSearchHolder{get;set;}
    public List<PersonInsured> policyHolderList{get;set;}
    // public Map<String, List<HttpCalloutVO.Person>> personInsuredMap{get;set;}
    
    /* Selected options */
    public String selectedPersonInsuredId{get;set;}
    public String selectedPersonInsuredName{get;set;}
    public Boolean uploadAdmissionNote{get;set;}
    public Boolean hasCreditCard{get;set;}
    public Boolean acceptPaymentTC{get;set;}
    public Boolean phIsPi{get;set;}
    public Boolean phIsNotPi{get;set;}
    public Boolean piIsAdult{get;set;}
    
    /* For pagging */
    private static final Integer PAGE_SIZE = 5;
    private static final Integer DATE_LENGTH = 21;

    /* For upload attachment */
    public String removeAttId{get;set;}
    public Boolean hasAtt{get;set;}  
    
    /* Datepicker variables */
    public Long admissionDateTimestamp{get;set;}
    
    /* Credit Card */
    public String paramCreditCardNum1{get;set;}
    public String paramCreditCardNum2{get;set;}
    public String paramCreditCardNum3{get;set;}
    public String paramCreditCardNum4{get;set;}
    public String savedCreditCardWithMask{get;set;}
    public String expiryMonth{get;set;}
    public String expiryYear{get;set;}
    
    /* E-signature */
    public String picLink{get;set;}
    public String picString{get;set;}    // TO BE DELETED
    public String phEmail{get;set;}
    public String eSignature{get;set;}    
    public String esignatureEmail{get;set;}
    public String brokerEmail{get;set;}
    
    //Nicole_2019.12.21_GOP_Select_Policy_Event_Log
    public String selectedPolicyNo{get;set;}

    //Nicole_20200107_Policy Detail Security Access
    public String SHA256Key{get;set;} 

    //SPS-421_chris_2020_05_20
    public String brokerEsignAddress{get;set;} //send e-sign to broker by this email address

    //JR1840 jack add
    public String encryptedSearchCriteria{get;private set;}
    public final String URLParamName{get;private set;} {URLParamName = 'FLTR';}

    public BrkSubmitHospitalController(ApexPages.StandardController controller){
        // Rancho_JR1878_20210104
        isSearchHolder=false;
        // personInsuredMap=new Map<String, List<HttpCalloutVO.Person>>();

        //initPersonInsuredList();
        this.eligible = true;
        
        this.policyNo = ApexPages.currentPage().getParameters().get('policyNo');
        
         //Nicole_20200107_Policy Detail Security Access
         SHA256Key = ApexPages.currentPage().getParameters().get('SHA256Key');
        
        if(ApexPages.currentPage().getParameters().get('claimId')!=null && ApexPages.currentPage().getParameters().get('claimId')!='' && ApexPages.currentPage().getParameters().get('claimId') != 'test'){
            claimId = ApexPages.currentPage().getParameters().get('claimId');
            // minghua - 20221013 - JOBR-184 - JOBR-233
            For(Claim__c c : [Select Id, Name, Steps__c,Is_Contain_Life_Policy__c,Is_Contain_GI_Policy__c, Policy_Holder_Name__c, Policy__c, Broker_Company__c, Person_s_Insured__c, Person_Insured_Name__c, Person_Insured_Date_Of_Birth_Text__c, Person_Insured_Gender__c, Upload_Admission_Note__c, Has_Credit_Card__c, Policy_Holder_Email_Address__c, Card_Holder_Name__c, Card_Holder_HKID__c, Credit_Card_No__c, Expiry_Date_of_Credit_Card_Month__c, Expiry_Date_of_Credit_Card_Year__c, E_Signature_Type__c,Is_Created_By_Broker__c, Attending_Dr_Name__c, Dr_or_Clinic_Phone_Number__c, Dr_or_Clinic_Phone_Number_Country_Code__c, Hospital_Name__c, Admission_Date__c, Contact_No__c, Contact_No_Country_Code__c, Submission_Date__c, GOP_Payment_T_C__c,Broker_Contact_No__c, Broker_Contact_No_Country_Code__c From Claim__c Where Id =: claimId Limit 1]){
                this.claimRequest = c;
                this.currentStep = c.Steps__c;
                this.acceptPaymentTC = c.GOP_Payment_T_C__c;
                this.hasCreditCard = c.Has_Credit_Card__c;
                this.uploadAdmissionNote = c.Upload_Admission_Note__c;
                
                if(c.Credit_Card_No__c != '' && c.Credit_Card_No__c != null){
                    if(CignaValidationUtil.isValidCreditCard(c.Credit_Card_No__c)){
                        this.paramCreditCardNum1 = '****';
                        this.paramCreditCardNum2 = '****';
                        this.paramCreditCardNum3 = '****';
                        this.paramCreditCardNum4 = c.Credit_Card_No__c.substring(12,16);
                        this.savedCreditCardWithMask = this.paramCreditCardNum1 + this.paramCreditCardNum2 + this.paramCreditCardNum3 + this.paramCreditCardNum4;
                    }
                }
                
                this.expiryMonth = String.ValueOf(c.Expiry_Date_of_Credit_Card_Month__c);
                if(c.Expiry_Date_of_Credit_Card_Month__c < 10){
                    this.expiryMonth = '0' + this.expiryMonth;
                }
                this.expiryYear = String.ValueOf(c.Expiry_Date_of_Credit_Card_Year__c);

                // minghua - 20221013 - JOBR-184 - JOBR-233
                String picsDocName = '';
                Portal_Settings__c portalDocumentURL = Portal_Settings__c.getInstance();
                if(claimRequest.Is_Contain_Life_Policy__c && !claimRequest.Is_Contain_GI_Policy__c){
                    picsDocName = Label.Life_PIC_Doc_Customer;
                }else if(!claimRequest.Is_Contain_Life_Policy__c && claimRequest.Is_Contain_GI_Policy__c){
                    picsDocName = Label.GI_PIC_Doc_Customer;
                }else{
                    picsDocName = Label.Both_Life_And_GI_PIC_Doc_Customer;
                }
                List<Document> picsDoc = [SELECT Id FROM Document WHERE DeveloperName = :picsDocName LIMIT 1];
                if(picsDoc.size() == 1){
                    picLink = portalDocumentURL.Broker_Portal_Url__c + '/servlet/servlet.FileDownload?file='+picsDoc.get(0).Id;
                }
            }
        }else if(ApexPages.currentPage().getParameters().get('claimId') == 'test'){
            claimId = ApexPages.currentPage().getParameters().get('claimId');
            this.claimRequest = new Claim__c();
        }else{
            this.claimRequest = new Claim__c();
        }
        
        /** Prefill default values such as PH Name, Contact No. etc */
        getPrefilledValueFromContact();
        
        /** Admission Note */
        if(this.claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c == '' || this.claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c == null){
            this.claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c = '+852';
        }
        
        /** Page variables */
        checkAtt();
        this.userLanguage = UserInfo.getLanguage();
        
        /** E-signature T&C */
        picString = '';
        String docName;
        // Portal_Settings__c portalDocumentURL = Portal_Settings__c.getInstance();
        if(this.userLanguage == 'zh_TW'){
            docName = 'PIC_Statement_Text_Chinese';
            // picLink = CignaUtil.getPersonalInformationCollectionStatement_chi();
            //picLink = portalDocumentURL.File_Download_URL__c + CignaUtil.getBrokerPersonalInformationCollectionStatement_chi();
        }else{
            docName = 'PIC_Statement_Text';
            // picLink = CignaUtil.getPersonalInformationCollectionStatement_eng();
            //picLink = portalDocumentURL.File_Download_URL__c + CignaUtil.getBrokerPersonalInformationCollectionStatement_eng();
        }
        List <Document> dList = [SELECT Id, body FROM Document WHERE DeveloperName = :docName LIMIT 1];
        if(dList.size() == 1){    
            picString = dList[0].body.toString();
        }

        //JR1840 jack add
        String encryptedFilter = ApexPages.currentpage().getparameters().get(URLParamName); 
        System.debug('encryptedFilter'+encryptedFilter);
        if(!String.isEmpty(encryptedFilter)){
            encryptedSearchCriteria = EncodingUtil.urlEncode(encryptedFilter, 'UTF-8');
        }
        //JR1840 jack add
    }
    
    
    public List<Claim__c> getPreAdmissionList(){
        //Tovid comment 20210528
        /*List<Claim__c> PreAdmissionList = [Select Id, Name, Steps__c, Status__c, Expiry_Date_of_Credit_Card_Month__c From Claim__c Where recordType.Name = :Label.Record_Type_Pre_Admission Order By Name DESC];
        return PreAdmissionList;*/
        return null;
    }    
    
    /*get Current Step*/
    Public void InputCurrentStep(){
        system.debug('currentStep: '+currentStep);
        system.debug('claimId: '+claimId);
    }
    
    /* JustForSaveCurrentStep */
    public void JustForSaveCurrentStep(){
        this.claimRequest.Steps__c = this.currentStep;
        upsert this.claimRequest;
    }
    
    /*get attachment list*/  
    public List<Attachment> getListHkidAtt(){
        return getListAtt('PreAdmissionAtt');
    }
    
    /*get general attachment list*/
    public List<Attachment> getListAtt(String attType){

        List<Attachment> lstAtt= new List<Attachment>();
        List<Attachment> lstAttrename = new List<Attachment>();
        
        if(claimId!=''&& claimId!=null){
            lstAtt= [SELECT Name FROM Attachment Where parentId=:claimId];
            lstAttrename = new List<Attachment>(); 
            
            for(Attachment att :lstAtt){
                Attachment tempAtt = new Attachment();
                tempAtt.Name = att.name.removeStart(attType+'_');
                tempAtt.Id = att.id;
                lstAttrename.add(tempAtt);
            }
        }
        
        return lstAttrename;
    }

    /*check attachment list*/
    public void checkAtt(){
    
        hasAtt=false;
        
        if((getListHkidAtt().size()>0)){
            hasAtt=true;
            system.debug('should true hasAtt: '+hasAtt);
        }
    }  
    
    /*remove attachment*/
    public void removeAtt(){
    
        if(removeAttId!=null && removeAttId!=''){
        
            system.debug('removeAttId: '+ removeAttId);
            List<Attachment> checkExit = [SELECT id FROM Attachment WHERE id=:removeAttId];
            
            system.debug('checkExit : '+ checkExit );
            
            Attachment att = new Attachment();
            att.id = removeAttId;
              
            if(checkExit !=null && checkExit.size()>0){
                system.debug('delete : '+ att);
                delete(att);
            }else{
                system.debug(removeAttId + 'has been removed');
            }
            checkAtt();
        } 
    } 
    
    /*Selected Person Insured*/
    public void selectedPolicyMember(){
        
        if(selectedPersonInsuredName !='' && selectedPersonInsuredName != null){
            
            this.claimRequest.Person_s_Insured__c = selectedPersonInsuredId;
            this.claimRequest.Person_Insured_Name__c = selectedPersonInsuredName;
            
            
            for(PersonInsured pi : this.personInsuredList){
                //Nicole_20191223_Wrong Policy Issue
                //if(pi.personInsuredId == selectedPersonInsuredId){
                if(pi.personInsuredId == selectedPersonInsuredId && pi.PolicyNo == selectedPolicyNo){
                    pi.personInsuredselected = true;
                    this.policyNo = pi.policyNo;
                    this.uSSN = pi.personInsuredId;
                }else{
                    pi.personInsuredselected = false;
                }
            }
            
            getPIBasic();
            String policyHolderSSN;
            for(PersonInsured pi : this.personInsuredList){
                if(pi.personInsuredselected == true){
                    
                    // determine if ph == pi and if under 18 for different T&C
                    if(pi.personInsuredId == this.uSSN){
                        this.phIsPi = true;
                    }else{
                        this.phIsPi = false;
                        String[] dateParam = pi.personInsuredBirthDate.split('-');
                        Date piDOB = Date.newInstance(Integer.ValueOf(dateParam[0]), Integer.ValueOf(dateParam[1]), Integer.ValueOf(dateParam[2]));
                        
                        if(Date.today() > piDOB.addYears(18)){
                            piIsAdult = true;
                        }else{
                            piIsAdult = false;
                        }
                    }
                    
                    this.claimRequest.Person_Insured_Date_Of_Birth_Text__c = pi.personInsuredBirthDate;
                    this.claimRequest.Person_Insured_Gender__c = pi.personInsuredGender;
                    this.claimRequest.Is_Created_By_Broker__c = true;
                    policyHolderSSN = pi.policyHolderSSN;
                    this.claimRequest.Policy_Holder_ID__c = policyHolderSSN;
                    try{
                        this.claimRequest.Person_Insured_Date_Of_Birth__c = Date.valueOf(pi.personInsuredBirthDate);
                    }catch(Exception e){}
                }
            }
            
            //get policy info
            PersonCalloutHelper pcHelper = new PersonCalloutHelper();
            if(String.isNotBlank(policyNo)){
                //get policy basic info
                HttpCalloutVO.Policy policy = new HttpCalloutVO.Policy();
                PolicyCalloutHelper helper = new PolicyCalloutHelper();
                policy = helper.getPolicyBasic(policyNo);
                if(policy.broker != null && policy.broker.organization != null){
                    this.claimRequest.Broker_Company__c = policy.broker.organization.fullname;
                }
                // minghua - 20221013 - JOBR-184 - JOBR-233
                System.debug('isLife:'+policy.isLifePolicy);
                if (policy.isLifePolicy) {
                    claimRequest.Is_Contain_Life_Policy__c=true;
                    claimRequest.Is_Contain_GI_Policy__c=false;
                }else{
                    claimRequest.Is_Contain_Life_Policy__c=false;
                    claimRequest.Is_Contain_GI_Policy__c=true;
                }
                String picsDocName = '';
                Portal_Settings__c portalDocumentURL = Portal_Settings__c.getInstance();
                if(claimRequest.Is_Contain_Life_Policy__c && !claimRequest.Is_Contain_GI_Policy__c){
                    picsDocName = Label.Life_PIC_Doc_Customer;
                }else if(!claimRequest.Is_Contain_Life_Policy__c && claimRequest.Is_Contain_GI_Policy__c){
                    picsDocName = Label.GI_PIC_Doc_Customer;
                }else{
                    picsDocName = Label.Both_Life_And_GI_PIC_Doc_Customer;
                }
                List<Document> picsDoc = [SELECT Id FROM Document WHERE DeveloperName = :picsDocName LIMIT 1];
                if(picsDoc.size() == 1){
                    picLink = portalDocumentURL.Broker_Portal_Url__c + '/servlet/servlet.FileDownload?file='+picsDoc.get(0).Id;
                }

                //get policy holder info
                List<HttpCalloutVO.Person> holder = pcHelper.getPersonBasic(policyHolderSSN);
                if(holder!= null && holder.size()>0){
                    //this.claimRequest.Policy_Holder_Email_Address__c = holder[0].emailAddress;
                    
                    if(holder[0].mobilePhoneNo != null){
                        this.claimRequest.Contact_No__c = holder[0].mobilePhoneNo;
                        this.claimRequest.Contact_No_Country_Code__c = holder[0].mobileCountryCode;
                    }else if(holder[0].homePhoneNo != null){
                        this.claimRequest.Contact_No__c = holder[0].homePhoneNo;
                        this.claimRequest.Contact_No_Country_Code__c = holder[0].homePhoneCountryCode;
                    }else if(holder[0].businessPhoneNo != null){
                        this.claimRequest.Contact_No__c = holder[0].businessPhoneNo;
                        this.claimRequest.Contact_No_Country_Code__c = holder[0].businessPhoneCountryCode;
                    }
                    
                } 
                
                //get policy holder email
                try{
                    Id accRecordTypeId = [select id from RecordType Where SobjectType = 'Account' and DeveloperName = 'Customer' limit 1].Id;
                    User customer = [select id,Email From User Where Contact.Account.RecordTypeId = :accRecordTypeId and Contact.Account.SSN__c = :policyHolderSSN.toUpperCase() limit 1];
                    this.claimRequest.Policy_Holder_Email_Address__c = customer.Email;
                }catch(Exception e){
                    
                }
            }
            
        } 
        
        //Nicole_2019.12.21_GOP_Select_Policy_Event_Log
        if(String.IsNotBlank(selectedPolicyNo)){
            System.PageReference pageRef = ApexPages.currentPage();        
            EventTrackingHistoryUtil.insertEventLog('Select_Policy',(pageRef != null && pageRef.getUrl() != null)?EncodingUtil.urlEncode(pageRef.getUrl(), 'UTF-8') : '',selectedPolicyNo);
        }
    }
    
    /*Select Whether upload Admission Note or fill in form*/
    public void selectedUploadAdmissionNote(){
        System.Debug('uploadAdmissionNote' + uploadAdmissionNote);
        this.claimRequest.Upload_Admission_Note__c = uploadAdmissionNote;
        SavePreAdmission();
    }
    
    /*Select Whether fill in credit card information */
    public void selectedFillInCreditCard(){
        this.claimRequest.Has_Credit_Card__c = hasCreditCard;
        SavePreAdmission();
    }
    
    /* save the form and update the status to Not Submitted */
    public void SavePreAdmission(){

        List<RecordType> recordTypeID = [Select Id From RecordType Where SobjectType = 'Claim__c' and Name = 'Pre Admission' Limit 1];
        claimRequest.RecordTypeId = recordTypeID[0].Id;
        claimRequest.Steps__c = currentStep;
        claimRequest.Status__c = 'Not Submitted';
        if(this.policyNo != null && this.policyNo != ''){
            claimRequest.Policy__c = this.policyNo;
        }
        claimRequest.Policy_Holder_Name__c = this.phName;
        if(this.expiryMonth != null && this.expiryMonth != ''){
            System.Debug('expiryMonth: ' + expiryMonth);
            claimRequest.Expiry_Date_of_Credit_Card_Month__c = Integer.ValueOf(this.expiryMonth);
        }
        if(this.expiryYear != null && this.expiryYear != ''){
            System.Debug('expiryYear : ' + expiryYear );
            claimRequest.Expiry_Date_of_Credit_Card_Year__c = Integer.ValueOf(this.expiryYear);
        }
        claimRequest.GOP_Payment_T_C__c = (this.acceptPaymentTC==true);
        
        /** Quick Fix: The Expiry month and year will be auto saved as 0 if not filled */
        if(claimRequest.Expiry_Date_of_Credit_Card_Month__c == null || claimRequest.Expiry_Date_of_Credit_Card_Month__c == 0){
            claimRequest.Expiry_Date_of_Credit_Card_Month__c = null;
        }
        if(claimRequest.Expiry_Date_of_Credit_Card_Year__c == null || claimRequest.Expiry_Date_of_Credit_Card_Year__c == 0){
            claimRequest.Expiry_Date_of_Credit_Card_Year__c = null;
        }
        
        String tempCreditCard = paramCreditCardNum1 + paramCreditCardNum2 + paramCreditCardNum3 + paramCreditCardNum4;
        if(tempCreditCard != this.savedCreditCardWithMask){
            claimRequest.Credit_Card_No__c = tempCreditCard;
        }
        
        
        claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c = processCountryCodeBeforeSave(claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c);
        claimRequest.Broker_Contact_No_Country_Code__c = processCountryCodeBeforeSave(claimRequest.Broker_Contact_No_Country_Code__c);
        if(admissionDateTimestamp != null){
            claimRequest.Admission_Date__c = DateTime.newInstance(admissionDateTimestamp).date();
        }
        
        try{
            upsert claimRequest;
        }catch(Exception e){
            System.Debug('upsert fail:' + e);
        }
        
        claimId = claimRequest.id;
        system.debug('claimId: '+ claimId);
    }
    
    

    /* Submit change and update the status to Processing */
    public PageReference submitPreAdmission(){
        //add Bob 20201218 CM User
        //put code into !Test.isRunningTest() for running test class Rancho_JR1878_20210104
        if (!Test.isRunningTest()){
            if(CignaUtil.isCMLoginAsUser()){
                CignaUtil.stopSubmittionforCMUser();
                return null;
            }
        }

        // JOBR-126 File Scaning Security: check file scaning before submit 2022-06-10 Zane
        claimRequest.Sync_to_GOP__c=true;
        //check whether upload attachement.
        if(claimRequest.Upload_Admission_Note__c){
            if (OpswatWebService.checkScanStatus(claimId)){
                System.debug('submitPreAdmission: File virus scan done.');
                // will check the scan result
                if (!OpswatWebService.checkScanResult(claimId)){
                    claimRequest.Sync_to_GOP__c=false;
                    System.debug(LoggingLevel.INFO, '***submitPreAdmission scanPopup: ' + 'has file virus' );
                }
            }else{
                System.debug('File virus scan not done. will display success message');
                claimRequest.Sync_to_GOP__c=false;
            }
        }

        SavePreAdmission();
        claimRequest.Steps__c = 12;
        claimRequest.Status__c = 'Processing';
        claimRequest.Submission_Date__c = System.Today();
        
        cleanUpClaimForPDF(claimRequest);
        
        if(claimId!=null && claimId!=''){
            /*e-signature For Customer single signature*/
            if(this.eSignature!='' && this.eSignature!=null){
                eSignature = eSignature.substring(eSignature.indexOf(',') + 1, eSignature.length());
                system.debug('eSignature : '+eSignature );
                Blob fileContent = EncodingUtil.base64Decode(eSignature);
                Attachment a = new Attachment(parentId = claimId);
                a.body = fileContent;
                a.ContentType = 'image/png';
                a.name = 'gop_esignature'+String.valueOf(DateTime.now());
                system.debug('a.name: '+a.name);
                                
                insert a;
            }
        }

        // JOBR-126 File Scaning Security: moved from submitGOPFromEmail method. occurs exception by future in future 2022-06-30 Zane
        //generate GOP Form PDF and save as attachment
        pageReference thePage = Page.CustomerGOPPDFExportVFP; //IBM KOU HKSIR3865
        thePage.getParameters().put('id', claimId);
        
        //for test class
        blob tmpBody;
        if(!test.isRunningTest()){
            tmpBody = thePage.getContent();
        }else{
            tmpBody = blob.valueof('TEST');
        }
        blob body = tmpBody;
        
        //Rename PDF Form
        Attachment att= new attachment();
        att.ContentType = 'application/pdf';
        att.name = claimRequest.Policy__c + '-GOP.pdf';
        att.body = body;
        att.ParentId = claimId;
        att.isPrivate = false;
        insert att;

        sendGOPFormEmail();
        return null;
    }
    
    // Function of the trash icon, delete the pre admission claim in the first page the claim list
    public void removePreAdmination(){
       List<Claim__c> delPreAdmissionList = [select id from Claim__c where id =:removePreAdminationId];
       
       if(delPreAdmissionList != null){
           delete delPreAdmissionList ;
       }
       
    }
    
    /** Prefill values */    
    private void getPrefilledValueFromContact(){
        For(User u : [SELECT Id, Name, Contact.Id, Contact.Name, Contact.Account.Id, Contact.Account.SSN__c, Contact.MobilePhone, Contact.Mobile_Country_Code__c, Contact.Email, Email, Contact_No_Country_Code__c, Contact_No__c,Agent_Code__c,Notification_Channel__c,Notification_Email_Address__c,Profile.Name FROM User Where Id = :UserInfo.getUserId() LIMIT 1]){
            
            claimRequest.Broker_Contact_No_Country_Code__c = u.Contact_No_Country_Code__c;
            claimRequest.Broker_Contact_No__c = u.Contact_No__c;
            claimRequest.Broker_Financial_Consultant_Name__c = u.Name;
            claimRequest.Broker_Financial_Consultant_Code__c = u.Agent_Code__c;
            brokerEmail = u.Email;
            
            //SPS-421_chris_2020_05_20
            if(u.Profile.Name.contains('Customer') || u.Profile.Name.contains('System Administrator')){

            }else{
                brokerEsignAddress = u.Notification_Channel__c == 'SMS' ? UserInfo.getUserEmail() : u.Notification_Email_Address__c;
            }
        }
        
    }
    
    public void initPersonInsuredList(){
        try{
            this.personInsuredList = new List<PersonInsured>();
            PolicyCalloutHelper helper = new PolicyCalloutHelper();
            List<HttpCalloutVO.Policy> policyListbyHolder = new List<HttpCalloutVO.Policy>(); 
            //Map<String, List<HttpCalloutVO.PolicyPersonCoverage>> policyCoverageListMap = new Map<String, List<HttpCalloutVO.PolicyPersonCoverage>>();
            //List<String> planCodeList = new List<String>();
            //Map<String, Boolean> GOPEligibilityMap = new Map<String, Boolean>();
            List<HttpCalloutVO.Policy> eligiblePolicyList = new List<HttpCalloutVO.Policy>(); 
            
            eligiblePolicyList = helper.getIndividualPolicyListBasicByCriteria(this.policyNo, '', '' , '', '', ''); //'G689080' this.uSSN
            
            for(HttpCalloutVO.Policy p : eligiblePolicyList ){
                System.Debug('Policy Number: ' + p.policyNumber);
                this.phName = p.holderName;
                for(HttpCalloutVO.Person ps : p.insuredList ){
                    PersonInsured tempPI = new PersonInsured();
                    tempPI.policyNo = p.policyNumber;
                    tempPI.personInsured = ps.fullName;
                    tempPI.personInsuredId = ps.ssnNumber;
                    tempPI.personInsuredselected = false;
                    tempPI.contactNoCountryCode = claimRequest.Broker_Contact_No_Country_Code__c;
                    tempPI.contactNo = p.holderContactNumber;
                    tempPI.policyHolderSSN = p.holderSSN;
                    this.personInsuredList.add(tempPI);
                }
            }
            
            // toggle selected PI
            for(PersonInsured pi : this.personInsuredList){
                if(pi.personInsuredId == this.claimRequest.Person_s_Insured__c){
                    pi.personInsuredselected = true;
                }
            }
            
            if(this.personInsuredList.isEmpty()){
                this.eligible = false;
            }
        }catch(Exception e){
            showTooManyRecordError = true;
        }
        
    }
    
    public void searchPI(){
        // Rancho_JR1878_20210104
        isSearchHolder=false;
        // personInsuredMap = new Map<String, List<HttpCalloutVO.Person>>();
        showTooManyRecordError = false;
        isSearched = true;
        this.personInsuredList = new List<PersonInsured>();
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        List<HttpCalloutVO.Policy> eligiblePolicyList = new List<HttpCalloutVO.Policy>(); 
        try{
            if(selectedSearchType == 'Person_Insured'){
                eligiblePolicyList = helper.getIndividualPolicyListBasicByCriteria('', '', '' , '', selectedSearchValue, '');
            }else if(selectedSearchType == 'Person_Insured_ID'){
                eligiblePolicyList = helper.getIndividualPolicyListBasicByCriteria('', '', '' , '','', selectedSearchValue);
            }else if(selectedSearchType == 'Policy_Number'){//Rancho_JR1878_20210104
                isSearchHolder=true;
                eligiblePolicyList = helper.getIndividualPolicyListBasicByCriteria(selectedSearchValue, '', '' , '','', '');
            }else if(selectedSearchType == 'Policy_Holder_Name'){
                isSearchHolder=true;
                eligiblePolicyList = helper.getIndividualPolicyListBasicByCriteria('', selectedSearchValue, '' , '','', '');
            }else if(selectedSearchType == 'Policy_Holder_ID'){
                isSearchHolder=true;
                eligiblePolicyList = helper.getIndividualPolicyListBasicByCriteria('', '', selectedSearchValue , '','', '');
            }else{//Rancho_JR1878_20210104
                return;
            }
            for(HttpCalloutVO.Policy p : eligiblePolicyList){
                if(p.isIPMIPolicy){
                    System.Debug('Policy Number: ' + p.policyNumber);
                    System.Debug('isLifePolicy: ' + p.isLifePolicy);
                     //JR1809 see if policy is inactive, if yes then bypass it
                    System.Debug('Policy Status: ' + p.policyStatusCode);
                    System.Debug('Policy system: ' + p.sourceSystem);
                    if(String.isNotBlank(p.policyStatusCode))  {
                        if(p.policyStatusCode == '1052500019' || p.policyStatusCode == '7'
                            || p.policyStatusCode == '4' || p.policyStatusCode == '1052500004'
                            || p.policyStatusCode == '6' || p.policyStatusCode == '40'
                            || p.policyStatusCode == '17' || p.policyStatusCode == '1052500027'
                            ||(p.sourceSystem !=null && p.sourceSystem == 'CAPSIL' && p.policyStatusCode == '1052500003')){
                            continue;
                        }
                    }
                    // Rancho_JR1878_20210104
                    this.phName = p.holderName;
                    if(isSearchHolder){
                        PersonInsured tempPH = new PersonInsured();
                        tempPH.policyNo = p.policyNumber;
                        tempPH.personInsured = p.holderName;
                        tempPH.policyHolderSSN = p.holderSSN;
                        this.personInsuredList.add(tempPH);
                        // if(!personInsuredMap.containsKey(p.policyNumber)){
                        //     personInsuredMap.put(p.policyNumber, p.insuredList);
                        // }
                    }else{
                        for(HttpCalloutVO.Person ps : p.insuredList){
                            PersonInsured tempPI = new PersonInsured();
                            tempPI.policyNo = p.policyNumber;
                            tempPI.personInsured = ps.fullName;
                            tempPI.personInsuredId = ps.ssnNumber;
                            tempPI.personInsuredselected = false;
                            tempPI.policyHolderSSN = p.holderSSN;
                            /*
                            tempPI.email = holder[0].emailAddress;
                            if(holder[0].mobilePhoneNo != null){
                                tempPI.contactNo = holder[0].mobilePhoneNo;
                                tempPI.contactNoCountryCode = holder[0].mobileCountryCode;
                            }else if(holder[0].homePhoneNo != null){
                                tempPI.contactNo = holder[0].homePhoneNo;
                                tempPI.contactNoCountryCode = holder[0].homePhoneCountryCode;
                            }else if(holder[0].businessPhoneNo != null){
                                tempPI.contactNo = holder[0].businessPhoneNo;
                                tempPI.contactNoCountryCode = holder[0].businessPhoneCountryCode;
                            }
                            */
                            this.personInsuredList.add(tempPI);
                        }
                    }
                }
            }
            system.debug('personInsuredList:'+personInsuredList);
            // toggle selected PI
            // Rancho_JR1878_20210104
            if(!isSearchHolder){
                for(PersonInsured pi : this.personInsuredList){
                    if(pi.personInsuredId == this.claimRequest.Person_s_Insured__c){
                        pi.personInsuredselected = true;
                    }
                }
                
                if(this.personInsuredList.isEmpty()){
                    this.eligible = false;
                }
            }
        }catch(Exception e){
            showTooManyRecordError = true;
        }
        
    }
    
    
    public void sendEmailSignature(){
        this.claimRequest.Steps__c = 11;
        cleanUpClaimForPDF(this.claimRequest);
    }
    
    //@future(callout=true)
    //    cannot use @future, will result in wrong base url
    //public static void toSendGOPEmailSignature(String cId, String emailAddr, String lang){
    public void toSendGOPEmailSignature(){
        String type;
        // Zoe updated on 0428 to change to send email by ws
        if(UserInfo.getLanguage() == 'en_US'){
            //type = 'Email_to_send_signature_brk_GOP_English';
            type = 'Email to send signature brk GOP English';
        }else{
            //type = 'Email_to_send_signature_Brk_GOP_Chinese';
            type = 'Email to send signature brk GOP Chinese';
        }
        //ESignatureUtil.sendEmail(this.claimId, type , esignatureEmail , true, 'Claims_T_and_C_Customer', 'Cigna Hong Kong') ;
        ESignatureUtil.sendEmailWebService(this.claimId, type , esignatureEmail , true, 'Claims_T_and_C_Customer', 'Cigna Hong Kong');

        // SPS-421_chris_2020_05_14
        if(claimRequest.Is_Created_By_Broker__c && String.isNotBlank(brokerEsignAddress)){
            if(UserInfo.getLanguage() == 'en_US'){
                List<emailTemplate> tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send GOP PDF to brk English'];
                if(tempList.size() > 0){
                    //system.debug('1123344');
                    ESignatureUtil.sendOutEmailWebserive(tempList[0].Id, UserInfo.getUserId(), this.claimId, brokerEsignAddress);   
                }
            }else{
                List<emailTemplate> tempList = [SELECT Id,Name FROM emailTemplate WHERE Name = 'Email to send GOP PDF to brk Chinese'];
                if(tempList.size() > 0){
                    ESignatureUtil.sendOutEmailWebserive(tempList[0].Id, UserInfo.getUserId(), this.claimId, brokerEsignAddress);   
                }
            }
        }
        
        //20191224 - Terry - Signature Require
        List<E_Signature_Request__c> signatureReq = [SELECT id, name, E_Signature_URL__c, Request_Type__c, Policy_Number__c, Claim__c FROM E_Signature_Request__c WHERE Claim__c=:this.claimId AND Completed__c=False];
        String eSignLink = '';
        String policyNo = '';
        String phId = '';
        for(Claim__c claim : [SELECT E_Signature_Link__c, Policy__c, Policy_Holder_ID__c FROM Claim__c WHERE id=:this.claimId]){
            eSignLink = claim.E_Signature_Link__c;
            policyNo = claim.Policy__c;
            phId = claim.Policy_Holder_ID__c;
        }
        
        if(signatureReq != null && signatureReq.size() > 0){
            for(E_Signature_Request__c signReq : signatureReq){
                signReq.E_Signature_URL__c=eSignLink;
            }
            update signatureReq;
        }else{
            Id phUserId = UserInfo.getUserId();
            if(phId != null && phId != ''){
                List<User> phUsers = [SELECT id FROM User WHERE AccountId IN (SELECT id FROM Account WHERE SSN__c=:phId)];
                if(phUsers.size() > 0){
                    phUserId = phUsers[0].Id;
                }
            }
            E_Signature_Request__c signReq = new E_Signature_Request__c(E_Signature_URL__c=eSignLink, Claim__c=this.claimId, Policy_Number__c=policyNo, Request_Type__c='Claim', OwnerId=phUserId);
            insert signReq;
        }
    }
    
    public void sendGOPFormEmail(){    //send email to QHMS with claim form pdf in attachement for IPMI policy
        system.debug('to see sendClaimFormEmail');
        
        //String EMAIL_ADDRESS_QHMS = Label.IPMI_Email_Address;
        String EMAIL_ADDRESS_QHMS = Claim_Setting__c.getInstance('Cigna').GOP_Email_Recipient__c;
        if(!String.isBlank(EMAIL_ADDRESS_QHMS) && this.claimId != null){
            //Ray's Updates
            //toSendGOPFormEmail(this.claimId, EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong' );
            submitGOPFormEmail(this.claimId, EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong');
        }
    }
    
    public static void submitPreAdmissionFromEmail(Id claimId, Boolean virusScan){
        // JOBR-126 File Scaning Security: not submit claim to other system if found virus file. 2022-06-26 Zane 
        Claim__c claimRequest = [Select Id, Name, Policy__c, Person_s_Insured__c, Steps__c, Status__c, Submission_Date__c, Upload_Admission_Note__c, Dr_or_Clinic_Phone_Number_Country_Code__c, Dr_or_Clinic_Phone_Number__c, Attending_Dr_Name__c, Hospital_Name__c, Admission_Date__c, CreatedById, Has_Credit_Card__c, Card_Holder_Name__c, Card_Holder_HKID__c, Credit_Card_No__c, Expiry_Date_of_Credit_Card_Month__c, Expiry_Date_of_Credit_Card_Year__c From Claim__c Where Id = :claimId Limit 1];
        if(virusScan){
            claimRequest.Sync_to_GOP__c=false;
        }
        claimRequest.Steps__c = 12;
        claimRequest.Status__c = 'Processing';
        claimRequest.Submission_Date__c = System.Today();
        
        cleanUpClaimForPDF(claimRequest);

        // JOBR-126 File Scaning Security: moved from submitGOPFromEmail method. occurs exception by future in future 2022-06-30 Zane
        //generate GOP Form PDF and save as attachment
        pageReference thePage = Page.CustomerGOPPDFExportVFP; //IBM KOU HKSIR3865
        thePage.getParameters().put('id', claimId);
        
        //for test class
        blob tmpBody;
        if(!test.isRunningTest()){
            tmpBody = thePage.getContent();
        }else{
            tmpBody = blob.valueof('TEST');
        }
        blob body = tmpBody;
        
        //Rename PDF Form
        Attachment att= new attachment();
        att.ContentType = 'application/pdf';
        att.name = claimRequest.Policy__c + '-GOP.pdf';
        att.body = body;
        att.ParentId = claimId;
        att.isPrivate = false;
        insert att;
        
        String EMAIL_ADDRESS_QHMS = Claim_Setting__c.getInstance('Cigna').GOP_Email_Recipient__c;
        
        //Ray's Updates
        //toSendGOPFormEmail(claimId, EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong');
        submitGOPFormEmail(claimId, EMAIL_ADDRESS_QHMS, 'Cigna Hong Kong');
        
    }
    
    public static void cleanUpClaimForPDF(Claim__c claimRequest){
        // clean up irrelevant data
        if(claimRequest.Upload_Admission_Note__c ){
            claimRequest.Dr_or_Clinic_Phone_Number_Country_Code__c = '';
            claimRequest.Dr_or_Clinic_Phone_Number__c = '';
            claimRequest.Attending_Dr_Name__c = '';
            claimRequest.Hospital_Name__c = '';
            claimRequest.Admission_Date__c = null;
        }
        update claimRequest;
    }
    
    //Ray's Updates - Start
    @future(callout=true)
    public static void submitGOPFormEmail(String cId, String tmpEmailAddr, String oEmailAddrName){
        
        // JOBR-126 File Scaning Security: not submit claim to other system if found virus file. 2022-06-26 Zane
        for (Claim__c c : [SELECT Id, Name, Policy__c, GOP_Case_Id__c,Person_s_Insured__c, Sync_to_GOP__c FROM Claim__c WHERE Id =: cId]){
            
            /*Boolean toShareFolder = true;
            if(String.isNotBlank(c.Policy__c)){
                List<String> policyNoList = c.Policy__c.split(',');
                PolicyCalloutHelper pHelper = new PolicyCalloutHelper();
                for(String policyNo : policyNoList){
                    HttpCalloutVO.Policy p = pHelper.getPolicyBasic(policyNo.trim());
                    if(IPMISettingUtil.isIPMIPolicy(p)){
                        toShareFolder = false;
                    }
                    if(IPMISettingUtil.isIPMITopUpPolicy(p) || IPMISettingUtil.isGAOPPolicy(p) || IPMISettingUtil.isLHBPolicy(p)){
                        toShareFolder = IPMISettingUtil.isClaimsSendToShareFolder(p);
                    }
                    if(toShareFolder){
                        break;
                    }
                }
            }*/
            //add by andy for get ward level
            String wardLevel = GOPUtil.getProductWardLevel(c.Policy__c, c.Person_s_Insured__c);
            
            // Rancho_HKITSFDC384_20250829 - remove Body from query
            List<Attachment> renameAttList = [select Name, BodyLength From Attachment Where ParentId = :cId And (Not Name Like :cId + '%') And (Not Name Like 'gop_esignature%') And (Not Name Like '%-GOP.pdf')];
            Integer attCount = 1;
            for (Attachment a : renameAttList){
                String tmpExtension = '';
                String tmpName = '';
                if (a.Name != null && a.Name != ''){
                    System.Debug('*************original file name: ' + a.Name);
                    
                    String[] tmpNameArray = a.Name.split('\\.');
                    System.Debug('*************tmpNameArray : ' + tmpNameArray );
                    
                    tmpExtension = '.' + tmpNameArray[tmpNameArray.size() - 1];
                    System.Debug('*************tmpExtension : ' + tmpExtension);
                }
                if (attCount < 10){
                    tmpName = c.Policy__c + '-0' + String.valueOf(attCount);
                }
                else{
                    tmpName = c.Policy__c + '-' + String.valueOf(attCount);
                }
                if (tmpName != ''){
                    a.Name = tmpName + tmpExtension;
                    // update a; //need more thinking !!!!!!!!
                }
                attCount++;                                                 
            }
            update renameAttList;

            //20191224 - Terry - Signature Require
            List<E_Signature_Request__c> signatureReq = [SELECT id, name, E_Signature_URL__c, Request_Type__c, Claim__c FROM E_Signature_Request__c WHERE Claim__c=:cId AND Completed__c=False];
            for(E_Signature_Request__c signReq : signatureReq){
                signReq.Completed__c=True;
            }
            update signatureReq;
                

            //Add by Andy for GOP enhancment start
            // JOBR-126 File Scaning Security: not submit claim to other system if found virus file. 2022-06-26 Zane
            System.debug(LoggingLevel.INFO, '***SubmitHospitalController.c.Sync_to_GOP__c : ' + c.Sync_to_GOP__c);
            if(!c.Sync_to_GOP__c){
                GetScandeatils getScan = new GetScandeatils();
                getScan.type = 'BrkSubmitGOP';
                getScan.parentId = cId;
                getScan.isCustomerPortal = false;
                getScan.wardLevel = wardLevel;
                System.enqueueJob(getScan);
            }else{

                GOPUtil.syncGOPRequestToHC(c,wardLevel);
            }

            //Add by Andy for GOP enhancement end
            //System.enqueueJob(new SubmitClaimQueue(c.id, attIdList, tmpEmailAddr, 1, attIdList.size(), null, true, false ));
            //Commented by Andy Li for GOP: disable the send mail function incase create dulplicate case
            /*if(toShareFolder){
                System.enqueueJob(new SubmitClaimQueue(c.id, attIdList, tmpEmailAddr, 1, attIdList.size(), null, false, true));
            }else{
                System.enqueueJob(new SubmitClaimQueue(c.id, attIdList, tmpEmailAddr, 1, attIdList.size(), null, true, false));
            }*/
        }           
             

        
    }
    
    //Ray's Updates - End
    
    
    /*@future(callout=true)
    public static void toSendGOPFormEmail(String cId, String tmpEmailAddr, String oEmailAddrName){
        if( !String.isBlank(cId) && !String.isBlank(tmpEmailAddr) && !String.isBlank(oEmailAddrName)){
            //send claim form in pdf to send to QHMS server for IPMI policy only
            List<EmailTemplate> templateList = [Select id, Subject, HtmlValue, Body from EmailTemplate where developername = 'Email_to_QHMS_for_GOP_by_WS_New'];
            //Update by Nicole: Remove Is_PI_Greater_Then_18__c
            for(Claim__c c : [Select  id,Submission_Date__c,Policy_Holder_Name__c, Policy_Holder_ID__c, Person_s_Insured__c,Person_Insured_Name__c,Person_Insured_Date_Of_Birth_Text__c,Person_Insured_Gender__c, Policy__c,Contact_No_Country_Code__c,Contact_No__c,Upload_Admission_Note__c,Broker_Company__c, Attending_Dr_Name__c,Dr_or_Clinic_Phone_Number_Country_Code__c,Dr_or_Clinic_Phone_Number__c, Hospital_Name__c,Admission_Date__c,Has_Credit_Card__c,Card_Holder_Name__c, Status__c, Credit_Card_No__c,Expiry_Date_of_Credit_Card_Year__c,Expiry_Date_of_Credit_Card_Month__c, Card_Holder_HKID__c,Policy_Holder__r.Name, Policy_Holder_Email_Address__c From Claim__c Where Id =: cId Limit 1]){
                EmailTemplate template = templateList.get(0);
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, null, null);
                
                HttpCalloutVO.EmailRequest EmailRequest = new HttpCalloutVO.EmailRequest();
                
                EmailRequest.MailTo = tmpEmailAddr;
                EmailRequest.MailTitle = email.getSubject() + c.Policy__c;
                EmailRequest.MailBody = '<![CDATA['+email.getHTMLBody()+']]>';
                EmailRequest.SecureMailInd = true;
                EmailRequest.AttachmentList = new List<HttpCalloutVO.Attachment>();
                    
                //generate PDF first
                //ExportSubmitClaimPDFController.generatePDF(cId);
                pageReference thePage = Page.BrokerGOPPDFExportVFP;
                thePage.getParameters().put('id', cId);
                
                blob body;
                if(Test.IsRunningTest()){
                    body = Blob.valueOf('UNIT.TEST');
                }else{
                    body = thePage.getContent();
                }
                
                HttpCalloutVO.Attachment pdfAttachment = new HttpCalloutVO.Attachment();
                pdfAttachment.fileBody = body;
                pdfAttachment.fileName = c.Policy__c + '-GOP.pdf';
                pdfAttachment.attachmentType = 'Document';
                EmailRequest.AttachmentList.add(pdfAttachment);
                
                //get uploaded attachments
                Integer attCount = 1;
                for(Attachment a : [select Name, Body, BodyLength From Attachment Where ParentId = :cId And (Not Name Like :cId + '%') And (Not Name Like 'gop_esignature%')]){
                    
                    // ---- confirmed format for attachment
                    String tmpExtension = '';
                    String tmpName = '';
                    if(a.Name != null && a.Name != ''){
                        String[] tmpNameArray = a.Name.split('\\.');
                        tmpExtension = '.' + tmpNameArray[tmpNameArray.size() - 1];
                    }
                    
                    if(attCount < 10){
                        tmpName = c.Policy__c + '-0' + String.valueOf(attCount);
                    }else{
                        tmpName = c.Policy__c + '-' + String.valueOf(attCount);
                    }                                     
                                     
                    HttpCalloutVO.Attachment attachment = new HttpCalloutVO.Attachment();
                    attachment.fileBody = a.body;
                    //attachment.fileName = a.name;
                    attachment.fileName = tmpName + tmpExtension;
                    attachment.attachmentType = 'Document';
                    EmailRequest.AttachmentList.add(attachment);
                    
                    attCount++;
                }
                EmailCalloutHelper helper = new EmailCalloutHelper();
                helper.sendEmailOnebyOne(EmailRequest);
                if(helper.getResultInfo() != null && helper.getResultInfo().isSuccess){
                    // SubmitHospitalController.clearGOPDetailsAfterSubmit(cId);
                    // Zoe commented on 0515, will not enable for the moment
                }
                
            }
        }else{
            system.debug('to see fail to see toSendClaimFormEmail:    cId'+ cId +'    tmpEmailAddr:    '+tmpEmailAddr+'    oEmailAddrName:    '+oEmailAddrName);
        }    
    }*/
    
    private void getPIBasic(){
        PersonCalloutHelper helper = new PersonCalloutHelper();
        
        for(PersonInsured pi : this.personInsuredList){
            if(pi.personInsuredselected == true){
                List<HttpCalloutVO.Person> PIBasiclist = helper.getPersonBasic(pi.personInsuredId);
                for(HttpCalloutVO.Person p : PIBasiclist ){
                    pi.personInsuredBirthDate = p.birthDate;
                    pi.personInsuredGender = p.gender;
                }
            }
        }
        
        System.Debug('personInsuredList' + personInsuredList);
    }
    
    private String processCountryCodeBeforeSave(String code){
        if(code != null && code != ''){
            if(code.startsWith('00') || code.startsWith('+')){
                return code;
            }else{
                return '+' + code;
            }
        }else{
            return '';
        }
    }
    
    public class PersonInsured{
        public String policyNo{get;set;}
        public String personInsured{get;set;}
        public String personInsuredId{get;set;}
        public String personInsuredBirthDate{get;set;}
        public String personInsuredGender{get;set;}
        public String contactNo{get;set;}
        public String contactNoCountryCode{get;set;}
        public String policyHolderSSN{get;set;}
        public String email{get;set;}
        
        /*for reteriving the selected policy Insured*/
        public Boolean personInsuredselected{get;set;}
    }

    // Rancho_JR1878_20210104
    public void selectPolicyHolderToPersonInsured(){
        isSearchHolder=false;
        policyHolderList=this.personInsuredList;
        this.personInsuredList = new List<PersonInsured>();
        HttpCalloutVO.PolicyRequest request = new HttpCalloutVO.PolicyRequest();
        PolicyCalloutHelper polyCalHlp = new PolicyCalloutHelper();
        // if(String.isNotBlank(policyNumber) && personInsuredMap!=null && !personInsuredMap.isEmpty()){
        //     if(personInsuredMap.containsKey(policyNumber)){
        //          List<HttpCalloutVO.Person> personList = personInsuredMap.get(policyNumber);
        if(String.isNotBlank(policyNumber)){
            List<HttpCalloutVO.Person> personList = polyCalHlp.getPolicyInsuredListBasic(policyNumber, true);
            for(HttpCalloutVO.Person ps : personList){
                PersonInsured tempPI = new PersonInsured();
                tempPI.policyNo = policyNumber;
                tempPI.personInsured = ps.fullName;
                tempPI.personInsuredId = ps.ssnNumber;
                tempPI.personInsuredselected = false;
                if(tempPI.personInsuredId == this.claimRequest.Person_s_Insured__c){
                    tempPI.personInsuredselected = true;
                }

                // Rancho_CTUI226_20220706 - set policy holder ssn when search by PH
                for(PersonInsured p : policyHolderList){
                    if(p.policyNo.equalsIgnoreCase(policyNumber)){
                        tempPI.policyHolderSSN = p.policyHolderSSN;
                    }
                }

                this.personInsuredList.add(tempPI);
            }
            System.debug('personInsuredList:'+personInsuredList);
            if(this.personInsuredList.isEmpty()){
                this.eligible = false;
            }
            // }
        }
    }
    public void phSearchBack(){
        isSearchHolder=true;
        showTooManyRecordError = false;
        this.personInsuredList = new List<PersonInsured>();
        this.personInsuredList = policyHolderList;
    }
}