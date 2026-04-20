public class BaseBrkDoctorCNListCtrl {

    public List<Clinic__c> allClinic { get; set; }
    public List<id> allClinicID { get; set; }

    public String theSpecialty { get; set; }

    public String theCity { get; set; }
    public String theState { get; set; }
    public String theCountry { get; set; }

    public List<Network_clinic__c> availableClinicList { get; set; }
    public Set<Id> clinicIdByKeyWord { get; set; }

    public String currentPanel { get; set; }

    public Network_clinic__c searchCriteriaDesktop { get; set; }

    public String lang { get; set; }

    public List<SelectOption> doctorSpecialtyList { get; set; }

    public List<SelectOption> policyProductList { get; set; }
    public Boolean isForWW { get; set; }
    public Boolean showWWTab { get; set; }
    public boolean filterByKeyword { get; set; }

    private Integer recordPerPage;

    public Integer currentpage { get; set; }
    public Integer totalRecord { get; set; }
    public boolean renderShowMore { get; set; }
    public Integer totalPages { get; set; }
    private boolean resetTotalRecord { get; set; }
    public boolean hideHeader { get; set; }
    private boolean IPMIChecked { get; set; }

    public User currentUser = [
        SELECT id, Name, ProfileId, UserRoleId, UserName, User_Type__c, LanguageLocaleKey, AccountId, Account.ssn__c
        FROM User
        WHERE id = :Userinfo.getUserId()
    ];

    public Boolean isMobile { get; set; }
    public static DoctorList__c DoctorListSetting { get; set; }

    public static Integer TOTAL_STEP = 14;
    public List<Integer> stepNos { get; set; }

    public String CLICK_HERE_URL { get; set; }
    {
        DoctorListSetting = DoctorList__c.getOrgDefaults();
        if (DoctorListSetting != null) {
            CLICK_HERE_URL = DoctorListSetting.click_here_url__c;
        } else {
            CLICK_HERE_URL = '';
        }
    }

    public Map<String, Map<String, String>> transField {
        get {
            if (transField == null) {
                transField = new Map<String, Map<String, String>>();
                for (Translate__mdt t : [
                    SELECT DeveloperName, zh_TW__c, en_US__c
                    FROM Translate__mdt
                    WHERE Category__c = 'BrkDoctorList'
                ]) {
                    system.debug(t.DeveloperName);
                    transField.put(
                        t.DeveloperName,
                        new Map<String, String>{ 'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c }
                    );
                }
            }
            return transField;
        }
        set;
    }
    public String transKey {
        get {
            if (transKey == null) {
                transKey = '';
                for (String s : transField.keySet()) {
                    transKey += '~' + s + '~';
                }
            }
            return transKey;
        }
        set;
    }

    public Boolean enableNextBtn { get; set; }

    public String selectedPolicyProduct { get; set; }

    public Map<String, China_Newwork_Provider_Product__mdt> proMap { get; set; }
    public String policyProductName {
        get {
            if (String.isNotBlank(selectedPolicyProduct)) {
                if (lang == 'en') {
                    return proMap.get(selectedPolicyProduct).MasterLabel;
                } else {
                    return proMap.get(selectedPolicyProduct).Name_TC__c;
                }
            }
            return '';
        }
        set;
    }
    public void isEnableNextBtn() {
        EnableNextBtn = false;
        if (String.isNotBlank(selectedPolicyProduct)) {
            EnableNextBtn = true;
        }
    }

    public void resetParams() {
        renderShowMore = false;
        totalPages = 0;
        clinicIdByKeyWord = new Set<Id>();
        filterByKeyword = false;

        searchCriteriaDesktop = new Network_clinic__c();
        theSpecialty = '';
        currentpage = 1;

        searchCriteriaDesktop.Area__c = 'Choose Region';

        availableClinicList = new List<Network_clinic__c>();
    }

    public PageReference backToSearchRefresh() {
        currentPanel = 'S';
        PageReference pg = new PageReference('/CusDoctorListVFP');
        pg.setRedirect(false);

        //resetParams();
        //searchAvailableClinicList();
        return pg;
    }

    public PageReference backToSearch() {
        if (isForWW) {
            showWWTab = true;
        } else {
            showWWTab = false;
        }
        System.debug('showWWTab:' + showWWTab);
        isForWW = false;
        currentPanel = 'S';
        hideHeader = true;
        return null;
    }

    public BaseBrkDoctorCNListCtrl() {
        isMobile = false;
        IPMIChecked = false;
        filterByKeyword = false;
        isForWW = false;
        showWWTab = false;
        currentpage = 1;
        resetTotalRecord = true;
        totalPages = 0;
        hideHeader = false;

        lang = 'en';
        if (UserInfo.getLanguage() == 'zh_TW') {
            lang = 'zh';
        }

        policyProductList = new List<SelectOption>();
        proMap = new Map<String, China_Newwork_Provider_Product__mdt>();
        List<China_Newwork_Provider_Product__mdt> lstCNPmdt = [
            SELECT MasterLabel, Name_TC__c, Name_EN__c
            FROM China_Newwork_Provider_Product__mdt
            ORDER BY Display_Order__c
        ];
        if (lang == 'en') {
            policyProductList.add(new SelectOption('', 'Choose Policy Type'));
        } else {
            policyProductList.add(new SelectOption('', '選擇保單類型'));
        }
        for (China_Newwork_Provider_Product__mdt mtd : lstCNPmdt) {
            if (lang == 'en') {
                policyProductList.add(new SelectOption(mtd.Name_EN__c, mtd.Name_EN__c));
                proMap.put(mtd.Name_EN__c, mtd);
            } else {
                policyProductList.add(new SelectOption(mtd.Name_TC__c, mtd.Name_TC__c));
                proMap.put(mtd.Name_TC__c, mtd);
            }
        }

        searchCriteriaDesktop = new Network_clinic__c();
        currentPanel = 'S';
        clinicIdByKeyWord = new Set<Id>();

        doctorSpecialtyList = new List<SelectOption>();
        List<Schema.PicklistEntry> picklistValues = Network_Doctor__c.Specialty__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe : picklistValues) {
            doctorSpecialtyList.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }

        DoctorListSetting = DoctorList__c.getOrgDefaults();

        if (DoctorListSetting != null) {
            recordPerPage = (Integer) DoctorListSetting.Record_Per_Page__c;
        } else {
            recordPerPage = 20;
        }

        stepNos = new List<Integer>();
        for (Integer i = 1; i <= TOTAL_STEP; i++) {
            stepNos.add(i);
        }
    }

    public void loadMore() {
        resetTotalRecord = false;
        if (isForWW) {
            //searchWWAvailableClinicList();
        } else {
            searchClinicByKeyWord();
        }
    }

    public PageReference searchClinicByKeyWord() {
        clinicIdByKeyWord = new Set<Id>();
        currentpage = currentpage == null || currentpage < 1 ? 1 : currentpage;
        System.debug('theSpecialty:' + theSpecialty);
        if (String.isNotBlank(theSpecialty)) {
            searchByKeyWord();
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

    public void searchByKeyWord() {
        String soslStr;
        filterByKeyword = true;
        String searchStr = escapeSosl(theSpecialty);
        if (!String.isBlank(searchStr) && searchStr.remove('\\').length() > 1) {
            soslStr =
                'FIND \'' +
                searchStr +
                '*\' IN ALL FIELDS RETURNING Network_clinic__c(id, Specialty__c WHERE Worldwide_Provider__c = TRUE AND Province_Municipality__c != Null AND Province_City__c != Null)';

            List<List<sObject>> searchList = search.query(soslStr);
            List<Network_clinic__c> clinicList = ((List<Network_clinic__c>) searchList[0]);
            for (Network_clinic__c c : clinicList) {
                if (c.Specialty__c != null && c.Specialty__c.containsIgnoreCase(searchStr)) {
                    clinicIdByKeyWord.add(c.id);
                }
            }
        }
    }

    public void searchAvailableClinicList() {
        if (UserInfo.getLanguage() == 'zh_TW') {
            lang = 'zh';
        }

        availableClinicList = new List<Network_clinic__c>();

        String limitStr = '';
        String offsetStr = '';

        String total = ' Select Count() ';
        
        String details =
            ' Select id,Notice__c, Coordinate_Available__c, Name , Network_Clinic_Name_en__c, Address_en__c,toLabel(Hospital_Category__c), ' +
            ' Province_City__c, Province_Municipality__c, Specialty__c, toLabel(Language__c), toLabel(Clinic_Type__c), toLabel(Patient_Type__c), ' +
            ' Opening_Hours_en__c, Telephone__c, Direct_Billing_Method__c,Cashless_Availability_zh__c, Cashless_Availability_en__c ';
        String queryStr =
            ' From Network_clinic__c ' +
            ' Where id != null and Worldwide_Provider__c = TRUE AND Province_Municipality__c != Null AND Province_City__c != Null';

        
        String strProvince;
        if (
            String.isNotBlank(searchCriteriaDesktop.Province_Municipality__c) &&
            !searchCriteriaDesktop.Province_Municipality__c.containsIgnoreCase('Choose')
        ) {
            strProvince = searchCriteriaDesktop.Province_Municipality__c;
            queryStr += ' and Province_Municipality__c = :strProvince ';
        }

        String strCity;
        if (
            String.isNotBlank(searchCriteriaDesktop.Province_City__c) &&
            !searchCriteriaDesktop.Province_City__c.containsIgnoreCase('Choose')
        ) {
            strCity = searchCriteriaDesktop.Province_City__c;
            queryStr += ' and Province_City__c = :strCity ';
        }

        if (filterByKeyword) {
            queryStr += ' and id in :clinicIdByKeyWord ';
        }

        Integer limitCount = recordPerPage;
        Integer offsetCount = (currentpage - 1) * recordPerPage;
        limitStr = ' ORDER BY Network_Clinic_Name_en__c ASC, Id ASC LIMIT ' + String.valueOf(limitCount);
        offsetStr = ' OFFSET ' + String.valueOf(offsetCount);

        System.debug('queryStr:' + details + queryStr + limitStr + offsetStr);
        System.debug('searchCriteriaDesktop:' + searchCriteriaDesktop);

        availableClinicList = Database.query(details + queryStr + limitStr + offsetStr);

        if (resetTotalRecord) {
            totalRecord = Database.countQuery(total + queryStr);
        }

        totalPages = totalRecord == null || totalRecord == 0
            ? 0
            : Integer.valueOf(Math.ceil((Decimal) totalRecord / recordPerPage));

        if (totalPages > 0 && currentpage > totalPages) {
            currentpage = totalPages;
            offsetCount = (currentpage - 1) * recordPerPage;
            offsetStr = ' OFFSET ' + String.valueOf(offsetCount);
            availableClinicList = Database.query(details + queryStr + limitStr + offsetStr);
        }

        renderShowMore = totalPages != null && totalPages > 0;

        System.debug('totalRecord:' + totalRecord);
        System.debug('availableClinicList:' + availableClinicList);

        for (Network_clinic__c aClinic : availableClinicList) {
            if (String.isBlank(aClinic.Telephone__c)) {
                aClinic.Telephone__c = '-';
            }
            if (String.isBlank(aClinic.Opening_Hours_en__c)) {
                aClinic.Opening_Hours_en__c = '-';
            }
            if (String.isBlank(aClinic.Notice__c)) {
                aClinic.Notice__c = '-';
            }
        }
    }

    public String escapeSosl(String text) {
        // handle single quotes
        String escapedText = String.escapeSingleQuotes(text);

        // remove reserved logical operators
        escapedText = escapedText.replaceAll('(?i)( AND NOT | AND | OR )', ' ');

        // match special characters to escape
        Pattern myPattern = Pattern.compile('(\\?|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\(|\\)|\\^|\\~|\\*|\\:|\\"|\\+|\\-)');
        Matcher myMatcher = myPattern.matcher(escapedText);

        // escape special characters
        escapedText = myMatcher.replaceAll('\\\\\\\\$1');

        // collapse extra whitespace
        escapedText = escapedText.replaceAll('( )+', ' ').trim();

        return escapedText;
    }

    public Boolean getHasPreviousPage() {
        return currentpage != null && currentpage > 1;
    }

    public Boolean getHasNextPage() {
        return totalPages != null && currentpage != null && currentpage < totalPages;
    }

    public List<Integer> getPaginationPages() {
        List<Integer> pageNumbers = new List<Integer>();
        if (totalPages == null || totalPages == 0) {
            return pageNumbers;
        }

        Integer windowSize = 10;
        Integer startPage = ((currentpage - 1) / windowSize) * windowSize + 1;
        Integer endPage = Math.min(startPage + windowSize - 1, totalPages);

        for (Integer pageNumber = startPage; pageNumber <= endPage; pageNumber++) {
            pageNumbers.add(pageNumber);
        }

        return pageNumbers;
    }
}