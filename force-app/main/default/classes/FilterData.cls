public with sharing class FilterData {
    public Integer URLCurPage;
    public String URLCatType;
    public String URLFltrType;
    public String URLFltrVal;
    public static final String PARAM_NAME_CATEGORY ='Cat';
    public static final String PARAM_NAME_FILTER_TYPE ='Type';
    public static final String PARAM_NAME_FILTER_VALUE ='Value';
    public static final String PARAM_NAME_CURRENT_PAGE ='CurPg';
    
    public FilterData(String decryptedFltrStr) {
        Map<String,String> filterMap = new Map<String,String>();
        filterMap =(Map<String,String>)JSON.deserialize(decryptedFltrStr, Map<String,String>.class);
        system.debug('Search filterMap='+filterMap);

        URLCatType = filterMap.containsKey(PARAM_NAME_CATEGORY) ? filterMap.get(PARAM_NAME_CATEGORY) : '';
        URLFltrType = filterMap.containsKey(PARAM_NAME_FILTER_TYPE) ? filterMap.get(PARAM_NAME_FILTER_TYPE) : '';
        URLFltrVal = filterMap.containsKey(PARAM_NAME_FILTER_VALUE) ? filterMap.get(PARAM_NAME_FILTER_VALUE): '';
        if(filterMap.containsKey(PARAM_NAME_CURRENT_PAGE)){
            URLCurPage = Integer.valueOf(filterMap.get(PARAM_NAME_CURRENT_PAGE));
        }
    }

    public FilterData(String decryptedFltrStr,Map<String, List<String>> checkingMap) {
        this(decryptedFltrStr);
        if(checkingMap != null && checkingMap.containsKey(URLCatType)){
            if(!checkingMap.get(URLCatType).contains(URLFltrType)){
                URLFltrType = '';
                URLFltrVal = '';
            }
        }else{
            URLCatType = '';
        }
    }

    public static String encryptSearchCriteria(String tabType, String searchInputType, String searchInputText, Integer currentPage){
        String encryptedSearchCriteria='';
        Map<String,String> filterMap = new Map<String,String>();
        if(!String.isEmpty(tabType) ){
            filterMap.put(PARAM_NAME_CATEGORY, tabType);
            
            if(!String.isEmpty(searchInputType)){
                filterMap.put(PARAM_NAME_FILTER_TYPE, searchInputType);
                if(!String.isEmpty(searchInputText)){
                    filterMap.put(PARAM_NAME_FILTER_VALUE, searchInputText);
                }
            }
            
            if(currentPage!=null){
                filterMap.put(PARAM_NAME_CURRENT_PAGE, String.valueOf(currentPage));
            }

            encryptedSearchCriteria = EncryptionUtil.encryptStrAES128( JSON.serialize(filterMap));
            encryptedSearchCriteria = EncodingUtil.urlEncode(encryptedSearchCriteria, 'UTF-8');
        }
        return encryptedSearchCriteria;
    }

    public static String encryptSearchCriteria( String searchInputType, String searchInputText, Integer currentPage){
        String encryptedSearchCriteria='';
        Map<String,String> filterMap = new Map<String,String>();
            
        if(!String.isEmpty(searchInputType)){
            filterMap.put(PARAM_NAME_FILTER_TYPE, searchInputType);
            if(!String.isEmpty(searchInputText)){
                filterMap.put(PARAM_NAME_FILTER_VALUE, searchInputText);
            }
        }
        
        if(currentPage!=null){
            filterMap.put(PARAM_NAME_CURRENT_PAGE, String.valueOf(currentPage));
        }

        encryptedSearchCriteria = EncryptionUtil.encryptStrAES128( JSON.serialize(filterMap));
        encryptedSearchCriteria = EncodingUtil.urlEncode(encryptedSearchCriteria, 'UTF-8');
        
        return encryptedSearchCriteria;
    }
}