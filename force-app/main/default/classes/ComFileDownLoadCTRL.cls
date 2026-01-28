global without sharing class ComFileDownLoadCTRL {
    private String pdfurl;//veraCode jack add
    public String selectedDowlAttId {get;set;}
    public boolean isDownloadComplete {get;set;}
    public String appName {get;set;}
    
    public ComFileDownLoadCTRL(){}
    
    public void init(){
        System.debug('getBaseUrl():'+Site.getBaseUrl());
        System.debug('Reference:'+ApexPages.currentPage().getHeaders().get('referer'));
        pdfurl='';
        Map<String,String> para=Apexpages.CurrentPage().getParameters();
        string attID=para.get('attID');        
        string pol=para.get('pol');
        string attKey=para.get('attKey');
        string lang=para.get('lang');
        //David Zhang - 190401 - Pending Memo Doc Async
        string requestId=para.get('requestId');
        string type=para.get('type');
        if(String.isEmpty(type)){
            type='policy';
        }
        selectedDowlAttId=para.get('attID');
        appName=para.get('appName');
        
        if(attKey!='Insurance_Certificate'){
            if(String.isBlank(type) || 'POLICY'.equalsIgnoreCase(type)){
                // Rancho_HKITSFDC321_20251013 - download file enhancement
                // System.enqueueJob(new downloadDocQueue(pol,attKey,lang,attID,appName,type)); 
                System.enqueueJob(new downloadDocQueue(pol,attKey,lang,'',appName,type,attID));
            } else if ('WORK'.equalsIgnoreCase(type)){
                System.enqueueJob(new downloadDocQueue(requestId,attKey,lang,attID,appName,type));  
            }
        }
    }
    
    public void checkIsDocumentDownloadComplete(){
        isDownloadComplete=false;
        if(selectedDowlAttId !=null){
            // Rancho_HKITSFDC321_20251013 - download file enhancement
            // Attachment a=[Select Id,Body From Attachment Where Id =:selectedDowlAttId];
            Attachment a;
            String type=Apexpages.CurrentPage().getParameters().get('type');
            if(String.isBlank(type) || 'POLICY'.equalsIgnoreCase(type)){
                a = [Select Id,BodyLength From Attachment Where ParentId =:selectedDowlAttId];
            } else {
                a = [Select Id,BodyLength From Attachment Where Id =:selectedDowlAttId];
            }
            
            if(a != null && a.BodyLength!=null && a.BodyLength > 0){
                // if(a.body.size()>0){
                    isDownloadComplete=true;
                    // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
                    pdfurl=Site.getBaseUrl()+'/servlet/servlet.FileDownload?file='+a.Id;
                    if (UserInfo.getUserType() == 'Guest') {
                        pdfurl=Portal_Settings__c.getInstance().File_Download_URL__c + a.Id  ; 
                    }
                    System.debug('pdfurl:'+pdfurl);
                // }
            }
        }
    }
    
    
    public PageReference redirectDownloadUrl(){
        PageReference pr= null;
        if (string.isNotBlank(pdfurl)){
            pr=new PageReference (pdfurl);
            pr.getHeaders().put('Title','File Download');
            pr.setRedirect(true);   
        }
        
        return pr;   
    }
}