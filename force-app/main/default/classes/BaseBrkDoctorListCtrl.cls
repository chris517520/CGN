public class BaseBrkDoctorListCtrl {
    public List<Double> allLat{get;set;}
    public List<Double> allLng{get;set;}
    public List<String> allName{get;set;}
    public List<Clinic__c> allClinic{get;set;}
    public List<id> allClinicID{get;set;}

    public String theAddress{get;set;}
    public String theAddress_mb{get;set;}
    public String theDistrict{get;set;}
    public String theArea{get;set;}
    public String theSpecialty{get;set;}
    public String theCity{get;set;}
    public String theState{get;set;}
    public String theCountry{get;set;}
    public Double MaxDis;
    
    //HKTISFDC-413 BEGIN
    public List<String> hideBrkDoctorProductList {  get; set; }{
        hideBrkDoctorProductList = new List<String>();
        List<App_ProductFunction_Setting__c> hideDoctorSettingList = [ select ProductCode__c, TypeUI__c from App_ProductFunction_Setting__c where TypeUI__c ='Find_A_Doctor' and ShowHide__c='Hide' and Active__c=true];
        
        for ( App_ProductFunction_Setting__c hideDoctorSetting: hideDoctorSettingList ){
            hideBrkDoctorProductList.add(hideDoctorSetting.ProductCode__c);
        }
    }//HKTISFDC-413 ENDED
    
    public List<Network_clinic__c> availableClinicList { get; set; }
    public Set<Id> clinicIdByKeyWord { get; set ;}
    public String contactId { get; set; }

    public String currentLong { get; set; }
    public String currentLat { get; set; }
    public String currentPanel { get; set; }
    public Boolean showMap {get;set;}

    public Network_clinic__c searchCriteria { get; set; }
    public Network_clinic__c searchCriteriaDesktop { get; set; }

    public String lang { get; set; }
    public Boolean noUserLocation { get; set; }

    public List<SelectOption> myAvailablePolicys { get; set; }
    public String selectedPolicy {get;set;}
    public String selectedPolicyMB {get;set;}

    public List<SelectOption> doctorSpecialtyList {get; set;}
    public String selectedSpecialty {get;set;}
    public String selectedSpecialtyMB {get;set;}

    public List<SelectOption> policyProductList{get;set;}

    public List<SelectOption> doctorConsultType {get; set;}
    public String selectedConsultType {get;set;}
    public String selectedConsultTypeMB {get;set;}

    //Worldwide Tab
    public List<SelectOption> wwCityList {get;set;}
    public List<SelectOption> wwSpecialtyList {get;set;}
    public Network_Clinic__c wwSearchCriteriaDesktop {get;set;}
    public Network_Clinic__c wwSearchCriteria {get;set;}

    public Boolean wwShowState {get;set;}
    public List<SelectOption> wwFakeStateList {get;set;} //For US only
    private String stateLabel {get;set;}
    private String cityLabel {get;set;}

    public String wwSelectedCountry {get;set;}
    public String wwSelectedCity {get;set;}
    public String wwFakeSelectedState {get;set;}
    public String wwSelectedSpecialty {get;set;}

    public Integer wwDistanceAround {get;set;}
    public String wwKeyword {get;set;}
    public String wwSpecialty {get;set;}
    public String wwSelectedType {get;set;}

    public Boolean isForWW {get;set;}
    public String wwKeywordMB {get;set;}
    public Boolean showWWTab {get;set;}
    public boolean filterByKeyword {get;set;}

    public String appointedDoctor {get;set;}
    public String appointedDate {get;set;}
    public String appointedTime {get;set;}
    public String remark {get;set;}

    private Integer recordPerPage;
    public String googleKey {get;set;}
    public String emailAddress {get;set;}

    public Integer currentpage {get;set;}
    public Integer totalRecord {get;set;}
    public boolean renderShowMore {get;set;}
    private boolean resetTotalRecord {get;set;}
    public boolean hideHeader {get;set;}
    private boolean IPMIChecked {get;set;}

    public Boolean availableAppointment  {get;set;}
    public Boolean showMakeAnAppointment { get; set; } { showMakeAnAppointment = false; }
    public User currentUser = [select id, Name, ProfileId, UserRoleId, UserName, User_Type__c, LanguageLocaleKey, AccountId, Account.ssn__c
    from User where id = : Userinfo.getUserId()];

    public Boolean isMobile {get;set;}
    public static DoctorList__c DoctorListSetting {get;set;}
    public Boolean showWWList {get;set;}
    public Boolean hideVCMap {get;set;}

    public static Integer TOTAL_STEP = 14;
    public List<Integer> stepNos {get;set;}

    public Boolean hasGroup {get;set;}
    public Boolean hasInd {get;set;}
    public Boolean policyTypeReadOnly {get;set;}
    public Boolean consultTypeReadOnly {get;set;}
    public List<String> productList{
        get{
            if(productList == null){
                productList = new List<String>();
            }
            return productList;
        }
        private set;/* add by Jack on 2021-09-03 for project: Veracode sep */
    }
    //JOBR-332,add by Owen to add elite 360 policy and coverage contain outpatient benefit or not return docotor list logic
    public Boolean isElite360{get;set;}{isElite360 = false;}
    public List<String> eliteList{
        get{
            if (eliteList==null) {
                eliteList=new List<String>();
                if (DoctorListSetting==null) {
                    DoctorListSetting=DoctorList__c.getOrgDefaults();
                }
                eliteList=DoctorListSetting.Elite_360_Product_Code__c.split(';');
            }
            return eliteList;
        }
        set;
    }

    public String CLICK_HERE_URL{ get; set; }{
    DoctorListSetting = DoctorList__c.getOrgDefaults();
    if (DoctorListSetting != null) {
        CLICK_HERE_URL = DoctorListSetting.click_here_url__c;
    } else {
        CLICK_HERE_URL = '';
    }
}

    //20190709 - hide VC for GS
    public String excludedVCFunction {get;set;}
    public Boolean hideVC {get;set;}

    //add by Andy for Clinic display enhancement 2020-05-27
    //Default value is false
    //when the login user have inforce ESF function, the showESF will be true
    //when the showESF is true, the search will include the ESF clinic
    public Boolean showESF {get;set;}
    //when the showIPMIWithoutOP=true, will show the clinic that Individual_IPMI_Without_OP__c = true
    public String showIPMIWithoutOP {get;set;}
    //add by Andy for Clinic display enhancement end

    public Map<String, Map<String, String>> transField {
        get{
            if(transField == null){
                transField = new Map<String, Map<String, String>>();
                for(Translate__mdt t : [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c = 'BrkDoctorList']){
                    system.debug(t.DeveloperName);
                    transField.put(t.DeveloperName, new Map<String, String>{'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c });
                }
            }
            return transField ;
        }
        set;
    }
    public String transKey {
        get{
            if (transKey ==null){
                transKey ='';
                for( String s : transField.keySet() ){
                    transKey += '~' + s + '~';
                }
            }
            return transKey ;
        }set;
    }

    public Boolean enableNextBtn {get;set;}
    public Boolean displayDoes {get;set;} {displayDoes=false;}
    public String selectedPolicyProduct {get;set;}
    public List<HttpCalloutVO.MasterProductList> proList {get;set;}
    public Map<String,HttpCalloutVO.MasterProductList> proMap {get;set;}
    public String policyProductName {get;set;}
    public void isEnableNextBtn(){
//      System.debug('isEnableNextBtn');
//      System.debug('displayDoes111'+displayDoes);
//      System.debug('selectedPolicyProduct111'+selectedPolicyProduct);
//      System.debug('showIPMIWithoutOP111'+showIPMIWithoutOP);
        EnableNextBtn=false;
        if((displayDoes==false&&String.isNotBlank(selectedPolicyProduct))||(displayDoes==true&&String.isNotBlank(selectedPolicyProduct)&&showIPMIWithoutOP!='')){
            EnableNextBtn=true;
            //System.debug('EnableNextBtn'+EnableNextBtn);
        }
    }
    public void displayDoes() {
        //System.debug('selectedPolicyProduct---'+selectedPolicyProduct);
        displayDoes=false;
        showIPMIWithoutOP='';
        if(selectedPolicyProduct!=null&&selectedPolicyProduct!=''){
            if(selectedPolicyProduct=='G'){
                selectedPolicy='G';
                consultTypeReadOnly=false;
                if(lang=='en'){
                    policyProductName='Group Policy';
                }else{
                    policyProductName='團體保險';
                }
            }else{
                if(selectedPolicyProduct!='O'){
                    displayDoes=true;
                    if(lang=='en'){
                        policyProductName=proMap.get(selectedPolicyProduct).masterProductNameEng;
                    }else{
                        policyProductName=proMap.get(selectedPolicyProduct).masterProductNameChi;
                    }
                }else{
                    if(lang=='en'){
                        policyProductName='Other Products';
                    }else{
                        policyProductName='其他產品';
                    }
                }
                selectedConsultType=null;
                selectedPolicy='I';
                consultTypeReadOnly=true;
//              if(proMap.get(selectedPolicyProduct).ipmiIndicator==1){
//                  displayDoes=true;
//              }
            }
        }else{
            policyProductName='';
        }
        //JOBR-332,add by Owen to add elite 360 policy and coverage contain outpatient benefit or not return docotor list logic
        if(eliteList.contains(selectedPolicyProduct)){
            isElite360=true;
        }else{
            isElite360=false;
        }
//      System.debug('showIPMIWithoutOP---'+showIPMIWithoutOP);
//      System.debug('selectedPolicy---'+selectedPolicy);
//      System.debug('displayDoes---'+displayDoes);
    }
    public void resetParams() {
        renderShowMore = false;
        clinicIdByKeyWord = new Set<Id>();
        filterByKeyword = false;
        selectedPolicy = null;
        selectedPolicyMB = null;
        selectedSpecialty = null;
        selectedSpecialtyMB = null;
        searchCriteria = new Network_clinic__c();
        searchCriteriaDesktop = new Network_clinic__c();
        selectedConsultType = null;
        selectedConsultTypeMB = null;
        theAddress='';
        theAddress_mb='';
        currentpage = 1;


        searchCriteria.Area__c = 'Choose Region';
        searchCriteriaDesktop.Area__c = 'Choose Region';
        wwSearchCriteriaDesktop = new Network_Clinic__c();
        wwSearchCriteria = new Network_Clinic__c();
        availableClinicList = new List<Network_clinic__c>();
        wwSearchCriteriaDesktop.Country_pl__C = 'Choose Country';
        wwSearchCriteriaDesktop.State_pl__C = 'Choose State';
        wwSearchCriteria.Country_pl__C = 'Choose Country';
        wwSearchCriteria.State_pl__C = 'Choose State';

        checkAvailPolicyType();
    }


    public PageReference wwSearchDoctorList(){
        isForWW = true;
        currentPanel = 'L';

        clinicIdByKeyWord = new Set<Id>();

        if(String.isNotBlank(wwKeyword)){
            searchByKeyWord(true);
        } else if(String.isNotBlank(wwKeywordMB)){
            searchByKeyWord(true);
        } else {
            filterByKeyword = false;
        }


        //searchWWAvailableClinicList();


        resetTotalRecord = true;

        //only for mobile;
        hideHeader = true;

        return null;
    }

    public void wwInitWorldWideTab(){
        resetParams();
        wwShowState = true;
        hideVCMap = false;

        wwCityList = new List<SelectOption>();
        wwCityList.add(new SelectOption('',cityLabel));


        wwFakeStateList = new List<SelectOption>();
        wwFakeStateList.add(new SelectOption('',stateLabel));

        wwSearchDoctorList();

    }

    public void wwTriggerCityList(){
        wwSearchCriteriaDesktop.State_pl__C = 'Choose State';

        if(wwSearchCriteriaDesktop.Country_pl__C == 'USA' || wwSearchCriteriaDesktop.Country_pl__C == 'Choose Country'){
            wwShowState = true;
            wwCityList = new List<SelectOption>();
            wwCityList.add(new SelectOption('',cityLabel));
        } else {
            wwShowState = false;
            wwSearchCriteriaDesktop.State_pl__C = wwSearchCriteriaDesktop.Country_pl__C;
            wwTriggerCityByState();
        }
    }

    public void wwTriggerCityByState(){
        wwCityList = new List<SelectOption>();
        wwCityList.add(new SelectOption('',cityLabel));

        if(String.isNotBlank(wwSearchCriteriaDesktop.State_pl__C)
                && wwSearchCriteriaDesktop.State_pl__C != 'Choose State'){
            System.debug('wwSearchCriteriaDesktop.State_pl__C:'+wwSearchCriteriaDesktop.State_pl__C);
            List<Worldwide_City__c> wcc = [SELECT Name FROM Worldwide_City__c
            WHERE State__c =:wwSearchCriteriaDesktop.State_pl__C ORDER BY Name];
            for(Worldwide_City__c w: wcc){
                wwCityList.add(new SelectOption(w.name, w.name));
            }
        }
    }


    public void dummyAction(){
        System.debug('wwShowState:'+wwShowState);
        System.debug('tyep:'+wwSelectedType);
    }

    public void initHKTab(){
        isForWW = false;
        hideVCMap = false;
        resetParams();
        //initial search
        if(!isMobile){
            searchAvailableClinicList();
        }
    }


    public PageReference iFoundYou() {
        if(!isForWW){
            System.debug('Lng:'+currentLong);
            System.debug('Lat:'+currentLat);


            if(currentLong == 'NULL'){
                noUserLocation = true;
            } else {
                noUserLocation = false;
            }
            //initial search
            System.debug('isMobile:'+isMobile);

            if(!IPMIChecked){
                checkAppointmentAvail();
                checkAvailPolicyType();
                IPMIChecked = true;
            }

            if(!isMobile){
                searchAvailableClinicList();
            }
            //

            showMap = true;

            System.debug('1 noUserLocation:'+noUserLocation);
        }
        return null;
    }

    public PageReference saveAppointment() {
        currentPanel = 'F';
        //sendAppointmentMail(appointedDoctor,appointedDate,appointedTime,remark);
        insertAppointmentHistory();
        return null;
    }

    public void insertAppointmentHistory() {
        Network_Doctor__c doctor = [Select name from Network_Doctor__c where id =: appointedDoctor];
        Online_Appointment_History__c history = new Online_Appointment_History__c();
        history.Appointment_Date__c =Date.valueOf(appointedDate.replaceAll('/','-'));
        history.Preferred_Appointment_Time__c =  appointedTime;
        history.Preferred_Doctor__c = doctor.name;
        history.Network_Doctor__c = appointedDoctor;
        history.Remark__c =remark;
        insert history;
    }

    public PageReference backToSearchRefresh(){
        currentPanel = 'S';
        PageReference pg = new PageReference('/CusDoctorListVFP');
        pg.setRedirect(false);


        //resetParams();
        //searchAvailableClinicList();
        return pg;
    }

    public PageReference backToSearch(){
        if(isForWW){
            showWWTab = true;
        } else {
            showWWTab = false;
        }
        System.debug('showWWTab:'+showWWTab);
        isForWW = false;
        currentPanel = 'S';
        hideHeader = true;
        hideVCMap = false;
        return null;
    }

    private void checkAvailPolicyType(){
        if(hasGroup && hasInd){
            //has both policies
            policyTypeReadOnly = false;
            consultTypeReadOnly = false;
            if(hideVC){
                consultTypeReadOnly = true;
                selectedConsultTypeMB = 'P';
                selectedConsultType = 'P';
            }
        } else if(hasGroup){
            // only with group
            policyTypeReadOnly = true;
            selectedPolicy = 'G';
            selectedPolicyMB = 'G';
            if(hideVC){
                consultTypeReadOnly = true;
                selectedConsultTypeMB = 'P';
                selectedConsultType = 'P';
            }
        } else {
            // only with individual
            policyTypeReadOnly = true;
            consultTypeReadOnly = true;
            selectedPolicy = 'I';
            selectedPolicyMB = 'I';
            selectedConsultType = 'P';
            selectedConsultTypeMB = 'P';
        }
    }


    public PageReference refreshList(){
        searchCriteria.District__c = 'Choose District';
        searchCriteriaDesktop.District__c = 'Choose District';
        return null;
    }

    public void checkAppointmentAvail(){

        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        List<HttpCalloutVO.Policy> policyList = helper.getIndividualPolicyListBasicByCriteria('','',currentUser.account.ssn__c,'','','','','');
        if(policyList.size()>0){
            hasInd = true;
        }

        List<HttpCalloutVO.Policy> grpPolicyList = helper.getGroupPolicyListBasicByCriteria('', '', currentUser.account.ssn__c, '', '', '', '', '');
        if(grpPolicyList.size()>0){
            hasGroup = true;
            Iterator<HttpCalloutVO.Policy> iter = grpPolicyList.iterator();
            while(iter.hasNext() && hideVC){
                HttpCalloutVO.Policy temp = iter.next();
                if(temp.functionMap != null && temp.functionMap.size() > 0){
                    System.debug('temp.functionMap:'+temp.functionMap);
                    if(!temp.functionMap.containsKey(excludedVCFunction)){
                        hideVC = false;
                    }
                } else {
                    hideVC = false;
                }
            }
        }
        System.debug('hideVC:'+hideVC);

        policyList.addAll(grpPolicyList); // CR-IPMI: also check group policies
        Set<String> planSet = new Set<String>();

        if(policyList.size()>0){
            for(HttpCalloutVO.Policy policy : policyList){
                planSet.add(policy.productCode);
            }
            // CR-IMPI: if has IPMI and Non-IPMI, show make appointment once one policy is enable
            for(HttpCalloutVO.Policy policy : policyList){
                if(IPMISettingUtil.isIPMIPolicy(policy)){
                    showMakeAnAppointment = true;
                }
                if(IPMISettingUtil.isIPMITopUpPolicy(policy) || IPMISettingUtil.isGAOPPolicy(policy) || IPMISettingUtil.isLHBPolicy(policy)){
                    showMakeAnAppointment = IPMISettingUtil.isEnableMakeAppointment(policy);
                }
                if(showMakeAnAppointment){
                    break;
                }
            }
        }

        Set<String> productSet = new Set<String>();
        productSet.add('All');
        productSet.add('');
        List<Product__c> policyProducts = [SELECT Product__r.Product_Code__c FROM Product__c WHERE Product_Code__c IN :planSet];
        if(policyProducts.size() > 0){
            for(Product__c prod: policyProducts){
                if(prod.Product__r.Product_Code__c != null){
                    productSet.add(prod.Product__r.Product_Code__c);
                }
            }
        }
        System.Debug('productSet.size()'+productSet.size());
        productList.addAll(productSet);

        system.debug('>>>showMakeAnAppointment: ' + showMakeAnAppointment);
    }

    public BaseBrkDoctorListCtrl() {
        displayDoes=false;
        isMobile = false;
        IPMIChecked = false;
        availableAppointment = false;
        filterByKeyword = false;
        isForWW = false;
        showWWTab= false;
        myAvailablePolicys = new List<SelectOption>();
        wwSelectedType = 'D';
        wwSelectedCity = '';
        currentpage = 1;
        resetTotalRecord = true;
        hideHeader = false;
        //add by Andy for Clinic display enhancement 2020-05-27
        showESF = false; //default as false
        //check login user whether have ESF function
        if(!Test.isRunningTest()){
            //checkESFAndOPRiderFunction();
        }
        //add by Andy for Clinic display enhancement end

        lang = 'en';
        showMap = false;
        noUserLocation = true;

        stateLabel = 'Choose State';
        cityLabel = 'Choose City';

        hideVCMap = false;

        hasGroup = false;
        hasInd = false;
        policyTypeReadOnly = false;
        consultTypeReadOnly = false;


        //checkAppointmentAvail();

        if(UserInfo.getLanguage() == 'zh_TW'){
            lang = 'zh';
            stateLabel = '選擇州';
            cityLabel = '選擇城市';
        }

//      if(lang == 'en'){
//          myAvailablePolicys.add(new SelectOption('','Choose Policy Type'));
//          myAvailablePolicys.add(new SelectOption('I','Individual'));
//          myAvailablePolicys.add(new SelectOption('G','Group'));
//      } else {
//          myAvailablePolicys.add(new SelectOption('','選擇保單類型'));
//          myAvailablePolicys.add(new SelectOption('I','個人'));
//          myAvailablePolicys.add(new SelectOption('G','團體'));
//      }

        policyProductList=new List<SelectOption>();
        proList=new List<HttpCalloutVO.MasterProductList>();
        proMap=new Map<String,HttpCalloutVO.MasterProductList>();
        if(!Test.isRunningTest()){
            if(lang == 'en'){
                policyProductList.add(new SelectOption('','Choose Policy Type'));
                policyProductList.add(new SelectOption('G','Group Policy'));
                policyProductList.add(new SelectOption('O','Other Products'));
                MasterProductListCalloutHelper enCountryCalloutHelper = new MasterProductListCalloutHelper(13,13,'en');
                proList=(List<HttpCalloutVO.MasterProductList>)enCountryCalloutHelper.RequestMasterProductList();
                System.debug('proList111---'+proList);
                if(proList!=null&&proList.size()>0){
                    for(HttpCalloutVO.MasterProductList mp:proList){
                        //if(mp.ipmiIndicator==1 && mp.MasterProductCode!='CIB25'){ //HKITSFDC-413 Ivan
                        if(mp.ipmiIndicator==1 && !hideBrkDoctorProductList.contains(mp.MasterProductCode) ){ //HKITSFDC-413 
                            policyProductList.add(new SelectOption(mp.masterProductCode,mp.masterProductNameEng ));
                            
                            proMap.put(mp.masterProductCode,mp);
                        }
                    }
                }
            } else {
                policyProductList.add(new SelectOption('','選擇保單類型'));
                policyProductList.add(new SelectOption('G','團體保險'));
                policyProductList.add(new SelectOption('O','其他產品'));
                MasterProductListCalloutHelper zhCountryCalloutHelper = new MasterProductListCalloutHelper(13,13,'zh');
                proList=(List<HttpCalloutVO.MasterProductList>)zhCountryCalloutHelper.RequestMasterProductList();
                System.debug('proList222---'+proList);
                if(proList!=null&&proList.size()>0){
                    for(HttpCalloutVO.MasterProductList mp:proList){
                        if(mp.ipmiIndicator==1 && !hideBrkDoctorProductList.contains(mp.MasterProductCode) ){//HKITSFDC-413
                        //if(mp.ipmiIndicator==1 && mp.MasterProductCode!='CIB25'){ //HKITSFDC-413 Ivan
                            policyProductList.add(new SelectOption(mp.masterProductCode,mp.masterProductNameChi));
                            proMap.put(mp.masterProductCode,mp);
                        }
                    }
                }
            }
        }

        System.debug('policyProductList---'+policyProductList);

        searchCriteria = new Network_clinic__c();
        searchCriteriaDesktop = new Network_clinic__c();
        currentPanel = 'S';
        clinicIdByKeyWord = new Set<Id>();

        doctorSpecialtyList = new List<SelectOption>();
        List<Schema.PicklistEntry> picklistValues = Network_Doctor__c.Specialty__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe: picklistValues) {
            doctorSpecialtyList.add(new SelectOption(pe.getValue(),pe.getLabel()));
        }

        doctorConsultType  = new List<SelectOption>();

        if(lang == 'en'){
            doctorConsultType.add(new SelectOption('','Choose Consultation Type'));
            doctorConsultType.add(new SelectOption('V','Virtual Consultation'));
            doctorConsultType.add(new SelectOption('P','Physical Consultation'));
        } else {
            doctorConsultType.add(new SelectOption('','選擇診療類型'));
            doctorConsultType.add(new SelectOption('V','視像診療'));
            doctorConsultType.add(new SelectOption('P','門診'));
        }

        DoctorListSetting = DoctorList__c.getOrgDefaults();

        if(DoctorListSetting != null){
            googleKey = DoctorListSetting.Google_JavaScript_API_Key__c;
            recordPerPage = (Integer)DoctorListSetting.Record_Per_Page__c;
            emailAddress = DoctorListSetting.Appointment_Email_Address__c;
            //showWWList = DoctorListSetting.Display_Worldwide_List__c;
            showWWList=false;
            //20190709 - hide VC for GS
            excludedVCFunction = DoctorListSetting.VC_Excluded__c.trim();
            System.debug('recordPerPage:'+recordPerPage);
        }  else {
            recordPerPage = 20;
        }

        stepNos = new List<Integer>();
        for(Integer i = 1; i <= TOTAL_STEP; i++){
            stepNos.add(i);
        }

        //20190709 - hide VC for GS
        hideVC = true;

        //appointedDate = DateTime.newInstance(Date.today(),Time.newInstance(0, 0, 0, 0)).getTime();
        
        
    }

    public void loadMore(){
        //currentpage = pageNo;
        resetTotalRecord = false;
        if(isForWW){
            //searchWWAvailableClinicList();
        } else {
            searchClinicByKeyWord();
        }

    }

    public PageReference searchClinicByKeyWord() {

        clinicIdByKeyWord = new Set<Id>();

        System.debug('theAddress:'+theAddress);
        System.debug('theAddress_mb:'+theAddress_mb);

        if(String.isNotBlank(theAddress)){
            searchByKeyWord(false);
        } else if(String.isNotBlank(theAddress_mb)){
            searchByKeyWord(false);
        } else {
            filterByKeyword = false;
        }
        searchAvailableClinicList();

        resetTotalRecord = true;

        currentPanel = 'L';

        //only for mobile;
        hideHeader = true;

        return null;
    }


    public void searchAvailableClinicList() {

        if('V' == selectedConsultType || 'V' == selectedConsultTypeMB){
            hideVCMap = true;
        } else {
            hideVCMap = false;
        }

        if(UserInfo.getLanguage() == 'zh_TW'){
            lang = 'zh';
        }
        System.debug('2 noUserLocation:'+noUserLocation);

        availableClinicList = new List<Network_clinic__c>();
        allLat=new List<Double>();
        allLng=new List<Double>();
        allName=new List<String>();

        Location myPosition;
        Double latitude,longitude;

        if(!noUserLocation){
            longitude  = Double.valueOf(currentLong);
            latitude = Double.valueOf(currentLat);
            myPosition = Location.newInstance(latitude, longitude);
        }

        String limitStr = '';

        String total = ' Select Count() ';
        // 20231113 - minghua - JOBR-339 Elite 360 - Doctor list
        String details = ' Select id,Appointment_Hotline__c,Appointment_Whatsapp__c, Coordinate_Available__c, Name, distanceToMe__c , Network_Clinic_Name__c, Address__c, Address_Display__c, '+
                ' Area__c, District__c, Coordinate__c, BookOnline__c, Group__c, Individual_IPMI_With_OP__c, '+
                ' Opening_Hours_en__c, Telephone__c, Opening_Hours_zh__c, Virtual__c,Function_Code__c,Individual_IPMI_Without_OP__c, ';

        if(!noUserLocation){
            details += 'DISTANCE( Coordinate__c, GEOLOCATION( :latitude, :longitude ), \'km\') dist,';
        }

        details  += ' (Select id, Qualification__c, '+
                ' Network_Doctor_Name__c, toLabel(Specialty__c), IsBookable__c, Network_Clinic__c, Virtual__c from Network_doctors__r) ';
        String queryStr = ' From Network_clinic__c '+
                ' Where id != null and (Coordinate_Available__c = TRUE OR Virtual__c = TRUE)';

        if(!noUserLocation){
            //Not filter by distance now
            //queryStr += ' and DISTANCE( Coordinate__c, GEOLOCATION( :latitude, :longitude ), \'km\') < :MaxDis';
        }
        //JOBR-332,add by Owen to add elite 360 policy and coverage contain outpatient benefit or not return docotor list logic
        if(!isElite360){
            if(String.isNotBlank(selectedPolicy)){
                if(selectedPolicy == 'G'){
                    queryStr += ' and Group__c = true ';
                } else if (selectedPolicy == 'I'){
                    //queryStr += ' and Individual__c = true ';
                    //add by Andy for Clinic display enhancement 2020-05-27
                    if(showIPMIWithoutOP=='false' ){
                        queryStr += ' and Individual_IPMI_Without_OP__c = true ';
                    }else{
                        queryStr += ' and Individual_IPMI_With_OP__c = true  ';
                    }
                    //add by Andy for Clinic display enhancement end
                }
            } else if(String.isNotBlank(selectedPolicyMB)) {
                if(selectedPolicyMB == 'G'){
                    queryStr += ' and Group__c = true ';
                } else if (selectedPolicyMB == 'I'){
                    //queryStr += ' and Individual__c = true ';
                    //add by Andy for Clinic display enhancement 2020-05-27
                    if(showIPMIWithoutOP=='false' ){
                        queryStr += ' and Individual_IPMI_Without_OP__c = true ';
                    }else{
                        queryStr += ' and Individual_IPMI_With_OP__c = true  ';
                    }
                    //add by Andy for Clinic display enhancement end
                }
            } else {
                if(showIPMIWithoutOP=='false' ){
                    queryStr += ' and (Individual_IPMI_Without_OP__c = true or Group__c = true) ';
                }else{
                    queryStr += ' and (Individual_IPMI_With_OP__c = true or Group__c = true) ';
                }
            }

            if(String.isNotBlank(selectedConsultType)){
                if(selectedConsultType == 'V'){
                    queryStr += ' and Virtual__c = true ';
                } else if (selectedConsultType == 'P'){
                    queryStr += ' and Virtual__c = false ';
                }
            } else if(String.isNotBlank(selectedConsultTypeMB)) {
                if(selectedConsultTypeMB == 'V'){
                    queryStr += ' and Virtual__c = true ';
                } else if (selectedConsultTypeMB == 'P'){
                    queryStr += ' and Virtual__c = false ';
                }
            }
        }

        if(String.isNotBlank(searchCriteria.District__c) && !searchCriteria.District__c.containsIgnoreCase('Choose')){
            theDistrict = String.escapeSingleQuotes(searchCriteria.District__c);
            queryStr += ' and District__c = :theDistrict ';
        } else if (String.isNotBlank(searchCriteriaDesktop.District__c) && !searchCriteriaDesktop.District__c.containsIgnoreCase('Choose')){
            theDistrict = String.escapeSingleQuotes(searchCriteriaDesktop.District__c);
            queryStr += ' and District__c = :theDistrict ';
        }

        if(String.isNotBlank(searchCriteria.Area__c) && !searchCriteria.Area__c.containsIgnoreCase('Choose')) {
            theArea = String.escapeSingleQuotes(searchCriteria.Area__c);
            queryStr += ' and Area__c = :theArea ';

        } else if (String.isNotBlank(searchCriteriaDesktop.Area__c) && !searchCriteriaDesktop.Area__c.containsIgnoreCase('Choose')){
            theArea = String.escapeSingleQuotes(searchCriteriaDesktop.Area__c);
            queryStr += ' and Area__c = :theArea ';
        }


        if(String.isNotBlank(selectedSpecialty) && !selectedSpecialty.containsIgnoreCase('Choose')) {
            theSpecialty = String.escapeSingleQuotes(selectedSpecialty);
            queryStr += ' and id in (select Network_Clinic__c from Network_Doctor__c where Specialty__c =: theSpecialty ) ';
        } else if(String.isNotBlank(selectedSpecialtyMB) && !selectedSpecialtyMB.containsIgnoreCase('Choose')) {
            theSpecialty = String.escapeSingleQuotes(selectedSpecialtyMB);
            queryStr += ' and id in (select Network_Clinic__c from Network_Doctor__c where Specialty__c =: theSpecialty ) ';
        }

        if(filterByKeyword){
            queryStr += ' and id in :clinicIdByKeyWord ';
        }

        //add by Andy for Clinic display enhancement 2020-05-27
        //JOBR-332,add by Owen to add elite 360 policy and coverage contain outpatient benefit or not return docotor list logic
        if(!showESF&&!isElite360){
            queryStr += ' and Function_Code__c EXCLUDES(\'ESF\')  ';
        }
        //add by Andy for Clinic display enhancement end

        //JOBR-332,add by Owen to add elite 360 policy and coverage contain outpatient benefit or not return docotor list logic
        if(isElite360){
            if(showIPMIWithoutOP=='true'){
                queryStr += ' and Offer_OP_Direct_Billing__c = true  ';
            }
            else{
                queryStr += ' and Offer_OP_Cash_Discount__c = true  ';
            }
        }

        if(productList.size() > 0){
            queryStr += ' and available_product__c includes (';
            for(Integer i=0; i<productList.size(); i++){
                queryStr += '\''+productList[i]+'\',';
                System.Debug('productList:'+productList[i]);
            }
            queryStr = queryStr.substring(0, queryStr.length()-1) + ')';
        }

        if(!noUserLocation){
            limitStr += ' ORDER BY Show_Prioritization_Flag__c DESC,DISTANCE( Coordinate__c, GEOLOCATION( :latitude, :longitude ), \'km\') ';
        } else {
            limitStr += ' ORDER BY Show_Prioritization_Flag__c DESC,Name ';
        }

        /*add by Tovid on 2021-09-15 for project: Veracode sep */
        //limitStr += ' LIMIT '+ currentpage*recordPerPage;
        Integer limitCount = currentpage*recordPerPage;
        String limiCountStr = String.valueOf(limitCount);
        limitStr += ' LIMIT '+ String.escapeSingleQuotes(limiCountStr); 

        System.debug('queryStr:'+details+ queryStr+limitStr);
        System.debug('searchCriteria:'+searchCriteria);
        System.debug('searchCriteriaDesktop:'+searchCriteriaDesktop);
        System.debug('selectedSpecialty:'+selectedSpecialty);

        System.debug('selectedPolicy---:'+selectedPolicy);
        System.debug('showIPMIWithoutOP---:'+showIPMIWithoutOP);

        availableClinicList = Database.query(details+ queryStr+limitStr);

        if(resetTotalRecord){
            totalRecord = Database.countQuery(total + queryStr);
        }

        if(totalRecord > currentpage*recordPerPage){
            renderShowMore = true;
        } else {
            renderShowMore =  false;
        }

        System.debug('totalRecord:'+totalRecord);


        System.debug('availableClinicList:'+availableClinicList);

        for(Network_clinic__c aClinic : availableClinicList) {
            // 20231113 - minghua - JOBR-339 Elite 360 - Doctor list
            if (String.isBlank(aClinic.Appointment_Hotline__c)) {
                aClinic.Appointment_Hotline__c='-';
            }
            if (String.isBlank(aClinic.Appointment_Whatsapp__c)) {
                aClinic.Appointment_Whatsapp__c='-';
            }
            Location loc = aClinic.Coordinate__c;
            allName.add(aClinic.Network_Clinic_Name__c);
            if(aClinic.Address__c != null){
                aClinic.Address_Display__c = aClinic.Address__c.unescapeHtml4();
            }

            if(loc != null){

                allLat.add(loc.latitude);
                allLng.add(loc.longitude);

                if(!noUserLocation){
                    System.debug('3 noUserLocation:'+noUserLocation);
                    aClinic.distanceToMe__c = ((Decimal)Location.getDistance(loc, myPosition, 'km')).setscale(1);
                    System.debug('distanceToMe__c :'+aClinic.distanceToMe__c);
                }

            }

        }

        System.debug('allName:'+allName);
    }

    /*public void searchWWAvailableClinicList() {

        availableClinicList = new List<Network_clinic__c>();
        allLat=new List<Double>();
        allLng=new List<Double>();
        allName=new List<String>();

        Location myPosition;
        Double latitude,longitude;

        if(!noUserLocation){
            longitude  = Double.valueOf(currentLong);
            latitude = Double.valueOf(currentLat);
            myPosition = Location.newInstance(latitude, longitude);
        }

        String limitStr = '';

        String total = ' Select Count() ';
        String details = ' Select id, Coordinate_Available__c, distanceToMe__c , Network_Clinic_Name__c, Address__c, Address_Display__c, '+
                ' State_pl__c, Country_pl__c, City__c, Coordinate__c, Worldwide_Provider__c,Function_Code__c,Individual_IPMI_Without_OP__c, ';

        if(!noUserLocation){
            details += 'DISTANCE( Coordinate__c, GEOLOCATION( :latitude, :longitude ), \'km\') dist';
        }

        String queryStr = ' From Network_clinic__c '+
                ' Where id != null and Coordinate_Available__c = TRUE AND Worldwide_Provider__c = TRUE';

        if(String.isNotBlank(wwSearchCriteria.Country_pl__c) && !wwSearchCriteria.Country_pl__c.containsIgnoreCase('Choose')){
            theCountry = String.escapeSingleQuotes(wwSearchCriteria.Country_pl__c);
            queryStr += ' and Country_pl__c = :theCountry ';
        } else if (String.isNotBlank(wwSearchCriteriaDesktop.Country_pl__c) && !wwSearchCriteriaDesktop.Country_pl__c.containsIgnoreCase('Choose')){
            theCountry = String.escapeSingleQuotes(wwSearchCriteriaDesktop.Country_pl__c);
            queryStr += ' and Country_pl__c = :theCountry ';
        }

        if(String.isNotBlank(wwSearchCriteria.State_pl__c) && !wwSearchCriteria.State_pl__c.containsIgnoreCase('Choose')) {
            theState = String.escapeSingleQuotes(wwSearchCriteria.State_pl__c);
            queryStr += ' and State_pl__c = :theState ';

        } else if (String.isNotBlank(wwSearchCriteriaDesktop.State_pl__c) && !wwSearchCriteriaDesktop.State_pl__c.containsIgnoreCase('Choose')){
            theState = String.escapeSingleQuotes(wwSearchCriteriaDesktop.State_pl__c);
            queryStr += ' and State_pl__c = :theState ';
        }

        if(String.isNotBlank(wwSearchCriteria.City__c) && !wwSearchCriteria.City__c.containsIgnoreCase('Choose')) {
            theCity = String.escapeSingleQuotes(wwSearchCriteria.City__c);
            queryStr += ' and City__c = :theCity ';

        } else if (String.isNotBlank(wwSearchCriteriaDesktop.City__c) && !wwSearchCriteriaDesktop.City__c.containsIgnoreCase('Choose')){
            theCity = String.escapeSingleQuotes(wwSearchCriteriaDesktop.City__c);
            queryStr += ' and City__c = :theCity ';
        }

        if(filterByKeyword){
            queryStr += ' and id in :clinicIdByKeyWord ';
        }

        if(productList.size() > 0){
            queryStr += ' and available_product__c includes (';
            for(Integer i=0; i<productList.size(); i++){
                queryStr += '\''+productList[i]+'\',';
                System.Debug('productList:'+productList[i]);
            }
            queryStr = queryStr.substring(0, queryStr.length()-1) + ')';
        }

        if(!noUserLocation){
            limitStr += ' ORDER BY DISTANCE( Coordinate__c, GEOLOCATION( :latitude, :longitude ), \'km\') ';
        } else {
            limitStr += ' ORDER BY Name ';
        }

        limitStr += ' LIMIT '+currentpage*recordPerPage;


        System.debug('queryStr:'+details+ queryStr+limitStr);
        System.debug('wwSearchCriteria:'+wwSearchCriteria);
        System.debug('wwSearchCriteriaDesktop:'+wwSearchCriteriaDesktop);

        availableClinicList = Database.query(details+ queryStr+limitStr);

        if(resetTotalRecord){
            totalRecord = Database.countQuery(total + queryStr);
        }

        if(totalRecord > currentpage*recordPerPage){
            renderShowMore = true;
        } else {
            renderShowMore =  false;
        }

        System.debug('totalRecord:'+totalRecord);


        System.debug('availableClinicList:'+availableClinicList);

        for(Network_clinic__c aClinic : availableClinicList) {
            Location loc = aClinic.Coordinate__c;
            allName.add(aClinic.Network_Clinic_Name__c);
            if(aClinic.Address__c != null){
                aClinic.Address_Display__c = aClinic.Address__c.unescapeHtml4();
            }

            if(loc != null){

                allLat.add(loc.latitude);
                allLng.add(loc.longitude);

                if(!noUserLocation){
                    System.debug('3 noUserLocation:'+noUserLocation);
                    aClinic.distanceToMe__c = ((Decimal)Location.getDistance(loc, myPosition, 'km')).setscale(1);
                    System.debug('distanceToMe__c :'+aClinic.distanceToMe__c);
                }

            }

        }

        System.debug('allName:'+allName);
    }*/

    public void searchByKeyWord(Boolean forWW){

        String soslStr;

        if(selectedConsultType == 'V' || selectedConsultTypeMB == 'V'){
            hideVCMap = true;
        } else {
            hideVCMap = false;
        }

        if(forWW && (String.isNotBlank(wwKeyword) || String.isNotBlank(wwKeywordMB))){
            filterByKeyword = true;
            String searchStr = escapeSosl((String.isNotBlank(wwKeyword)?wwKeyword:wwKeywordMB));
            System.debug('searchStr.length():'+searchStr.remove('\\').length());
            if(!String.isBlank(searchStr) && searchStr.remove('\\').length()>1){
                soslStr = 'FIND \'' + searchStr + '*\' IN ALL FIELDS RETURNING Network_clinic__c(id)';
                List<List<sObject>> searchList = search.query(soslStr);
                List<Network_clinic__c> clinicList = ((List<Network_clinic__c>)searchList[0]);
                for(Network_clinic__c c : clinicList){
                    clinicIdByKeyWord.add(c.id);
                }
            }

        } else if(String.isNotBlank(theAddress) || String.isNotBlank(theAddress_mb)){
            filterByKeyword = true;
            String searchStr = escapeSosl((String.isNotBlank(theAddress)?theAddress:theAddress_mb));
            if(!String.isBlank(searchStr) && searchStr.remove('\\').length()>1){
                soslStr = 'FIND \'' + searchStr + '*\' IN ALL FIELDS RETURNING Network_clinic__c(id), Network_Doctor__c(id, Network_clinic__c)';

                List<List<sObject>> searchList = search.query(soslStr);
                List<Network_clinic__c> clinicList = ((List<Network_clinic__c>)searchList[0]);
                for(Network_clinic__c c : clinicList){
                    clinicIdByKeyWord.add(c.id);
                }
                List<Network_doctor__c> doctorList = ((List<Network_doctor__c>)searchList[1]);
                for(Network_doctor__c d : doctorList){
                    clinicIdByKeyWord.add(d.Network_clinic__c);
                }
            }
        } else {
            filterByKeyword = false;
        }
    }


//  public void sendAppointmentMail(String appointedDoctor,String appointedDate,String appointedTime,String remark){
//
//      // grab the email template
//      EmailTemplate emailTemplate = [Select Id, Subject, HtmlValue, Body  from EmailTemplate where name = 'Doctor Appointment'];
//      OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Cigna Hong Kong'];
//      User u = [select contactid from user where id =: UserInfo.getUserId()];
//
//      Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.id, UserInfo.getUserId(), appointedDoctor);
//
//      String body = email.getHTMLBody();
//      if(!Test.isRunningTest()){
//          body = body.replace('###Date###',appointedDate);//DateTime.newInstance(appointedDate).date().format());
//          body = body.replace('###Time###',appointedTime);
//          body = body.replace('###Remarks###',remark);
//      }
//      /*
//      email.setHtmlBody(body);
//
//      System.debug('toEmail:'+emailAddress);
//
//      if(String.isBlank(emailAddress)){
//          emailAddress = 'cignacus1@gmail.com';
//      }
//
//      List<String> toEmail = new List<String>();
//      toEmail.add(emailAddress);
//      //email.setReplyTo('no-reply@cigna.com.hk');
//      //email.setSenderDisplayName('Cigna Hong Kong');
//      email.setToAddresses(toEmail);
//
//      //uncomment when verified
//      email.setOrgWideEmailAddressId(owa.id);
//
//      if(!Test.isRunningTest()){
//          Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
//      }
//      */
//
//      HttpCalloutVO.EmailRequest para = new HttpCalloutVO.EmailRequest();
//      para.MailTo = emailAddress;
//      //para.MailCC = 'strawberryloki@gmail.com';
//      para.MailTitle = email.getSubject();
//      para.MailBody = '<![CDATA['+body+']]>';
//      para.SecureMailInd = true;
//
//      System.debug('start to send email');
//      EmailCalloutHelper helper = new EmailCalloutHelper();
//      // helper.sendEmail(para);
//      helper.sendEmail(para);
//      System.debug('email end');
//  }

    public String escapeSosl( String text ) {
        // handle single quotes
        String escapedText = String.escapeSingleQuotes( text ) ;

        // remove reserved logical operators
        escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );

        // match special characters to escape
        Pattern myPattern = Pattern.compile( '(\\?|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\(|\\)|\\^|\\~|\\*|\\:|\\"|\\+|\\-)' );
        Matcher myMatcher = myPattern.matcher( escapedText );

        // escape special characters
        escapedText = myMatcher.replaceAll( '\\\\\\\\$1' );

        // collapse extra whitespace
        escapedText = escapedText.replaceAll( '( )+', ' ' ).trim();

        return escapedText;
    }
    //add by Andy for Clinic display enhancement 2020-05-27
    /*public void checkESFAndOPRiderFunction(){
        PolicyCalloutHelper helper = new PolicyCalloutHelper();
        List<HttpCalloutVO.Policy> policyList = helper.getIndividualPolicyListBasicByCriteria('','',currentUser.account.ssn__c,'','','','','');
        List<HttpCalloutVO.Policy> grpPolicyList = helper.getGroupPolicyListBasicByCriteria('', '', currentUser.account.ssn__c, '', '', '', '', '');

        if(grpPolicyList.size()>0){
            Iterator<HttpCalloutVO.Policy> iter = grpPolicyList.iterator();
            while(iter.hasNext()){
                HttpCalloutVO.Policy temp = iter.next();
                if(temp.functionMap != null && temp.functionMap.size() > 0){
                    System.debug('temp.functionMap:'+temp.functionMap);
                    if(temp.functionMap.get('ESF')!=null && temp.functionMap.get('ESF').isActive=='Y'){
                        showESF = true;
                        break;
                    }
                }
            }
        }
        System.debug('showESF:'+showESF);
        policyList.addAll(grpPolicyList); //also check group policies
        Set<String> planCodeRateString = new Set<String>();
        List<Plan_Code_Claim_Type__c> searchResultList = [select Id,Plan_code__c,Rate_Scale__c, IPMI_Outpatient_Rider__c from Plan_Code_Claim_Type__c where IPMI_Outpatient_Rider__c=true];
        for(Plan_Code_Claim_Type__c tmpRider : searchResultList){
            String keyString = tmpRider.Plan_code__c+tmpRider.Rate_Scale__c;
            planCodeRateString.add(keyString);
        }

        Boolean hasOP = false;

        if(policyList.size()>0){
            //chech if has IPMI
            for(HttpCalloutVO.Policy policy : policyList){
                if(IPMISettingUtil.isIPMIPolicy(policy)){
                    if(policy.insuredList!=null && policy.insuredList.size()>0){
                        for(HttpCalloutVO.Person person : policy.insuredList){
                            List<HttpCalloutVO.PolicyPersonCoverage> coverageList = helper.getPolicyPersonCoverageBasic(policy.policyNumber, person.ssnNumber);
                            for(HttpCalloutVO.PolicyPersonCoverage ppc : coverageList){
                                String productCodeRate = ppc.benefitCode+ppc.rateScale;
                                if(planCodeRateString.contains(productCodeRate)){
                                    hasOP = true;
                                    break;
                                }
                            }
                            if(hasOP){
                                break;
                            }
                        }
                    }
                }
                if(hasOP){
                    break;
                }
            }
        }

        //showIPMIWithoutOP = true -> List B
        //Non-IPMI members  List B
        //IPMI members with OP rider    List A
        //IPMI members without OP rider List B
        //Members have non-IPMI policy and IPMI policy with OP rider    List A
        //Members have non-IPMI policy and IPMI policy without OP rider List B

        //      if(hasOP){
        //          showIPMIWithoutOP = false;
        //      }else{
        //          showIPMIWithoutOP = true;
        //      }
    }*/
    //add by Andy for Clinic display enhancement end
}