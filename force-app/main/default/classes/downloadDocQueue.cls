public class downloadDocQueue implements Queueable, Database.AllowsCallouts {
    private string pol;
    private string attKey;
    private string lang;
    private string attID;
    private String appName;
    private String type;
    private String parentId;// Rancho_HKITSFDC321_20251013 - add file store id
    
    //David Zhang - 190401 - Pending Memo Doc Async
    private String requestId;   
    //Atutumn_SMT_20210408
    public static final Map<String, String> MimeTypeTCMapping; 
    static{

        MimeTypeTCMapping=new Map<String, String>();
        MimeTypeTCMapping.put('0','Unknown');
        MimeTypeTCMapping.put('3','image/jpeg');
        MimeTypeTCMapping.put('11','image/tiff');
        MimeTypeTCMapping.put('17','application/pdf');
        MimeTypeTCMapping.put('33','image/png');
        MimeTypeTCMapping.put('59','application/msword');
        MimeTypeTCMapping.put('2147483647','application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    }

   public downloadDocQueue(string pol,string attKey,string lang,string attID){
        this.pol = pol;//'CTM0041437';
        this.attKey = attKey;//'380';
        this.lang = lang;
        this.attID = attID;
        this.appName = '';
    }
    
    public downloadDocQueue(string pol,string attKey,string lang,string attID, String appName){
        this.pol = pol;//'CTM0041437';
        this.attKey = attKey;//'380';
        this.lang = lang;
        this.attID = attID;
        this.appName = appName;
    }
    
    public downloadDocQueue(string id,string attKey,string lang,string attID, String appName, String type){
        this.attKey = attKey;
        this.lang = lang;
        this.attID = attID;
        this.appName = appName;
        this.type = type;
        
        if(String.isBlank(type) || 'POLICY'.equalsIgnoreCase(type)){
            this.pol = id;
        } else if ('WORK'.equalsIgnoreCase(type)){
            this.requestId = id;
        }
    }

    // Rancho_HKITSFDC321_20251013 - add file store id
    public downloadDocQueue(String pol, String attKey, String lang, String attID, String appName, String type, String parentId){
        this.pol = pol;
        this.attKey = attKey;
        this.lang = lang;
        this.appName = appName;
        this.type = type;
        this.parentId = parentId;
    }

    //junda add
    public downloadDocQueue(string attKey,string attID,String type){
        this.type = type;
        this.attKey = attKey;
        this.attID = attID;
    }
    //junda add end
    
    public void execute(QueueableContext context) {
        try{
            if(String.isBlank(type) || 'POLICY'.equalsIgnoreCase(type)){
                HttpCalloutVO.PolicyDoc policyDoc = null;
                PolicyCalloutHelper helper = new PolicyCalloutHelper();
                if (string.isNotBlank(lang)){
                    helper = new PolicyCalloutHelper(lang);
                }
                System.debug (pol + ', '+attKey);
                System.debug ('before get policy doc');
                // Rancho_HKITSFDC321_20251013 - add file store id
                List<HttpCalloutVO.PolicyDoc> docList = helper.getPolicyDoc(pol,attKey,appName,parentId);
                System.debug ('after get policy doc');

                // if(!docList.isEmpty() && docList.size()>0){
                //     policyDoc = docList.get(0);
                // }
                // if (policyDoc !=null){
                //     //Autumn_SMT_20210408
                //     system.debug ('policyDoc.mimeTypeTCNumber '+ policyDoc.mimeTypeTCNumber);
                //     if(MimeTypeTCMapping.containsKey(policyDoc.mimeTypeTCNumber)){
                //         att.contentType=MimeTypeTCMapping.get(policyDoc.mimeTypeTCNumber);
                //     }else{
                //         att.contentType = 'application/pdf';
                //     }
                //     att.name = policyDoc.fileName;
                //     // att.name = attKey;
                //     att.body = null;
                //     //att.body = EncodingUtil.base64Decode(policyDoc.attachmentData64Binary);    //Comment by Nicole for Storage Save
                //     if(policyDoc.attBody!=null){
                //         att.body = policyDoc.attBody;
                //     }
                //     if (!Test.isRunningTest()){
                //         upsert att;
                //     }   
                // }
            }
            
            List<Attachment> attls = [select id from attachment where id=:attID];        
            if (attls.size()>0){
                Attachment att = attls[0];
                if ('WORK'.equalsIgnoreCase(type)){
                   WorkCalloutHelper workHelper = new WorkCalloutHelper();
                   HttpCalloutVO.Attachment workDoc = null;
                    
                   List<HttpCalloutVO.Attachment> docList = workHelper.getWorkDoc(attKey, this.requestId);
                   if(!docList.isEmpty() && docList.size()>0){
                        workDoc = docList.get(0);
                    }
                    if (workDoc !=null){
                        att.contentType = workDoc.mimeTypeTC;
                        att.name = workDoc.fileName;
                        att.body = null;
                        att.body = EncodingUtil.base64Decode(workDoc.attachmentData64Binary);
                        /*
                        if(workDoc.fileBody!=null){
                            att.body = workDoc.fileBody;
                        }
                        */
                        if (!Test.isRunningTest()){
                            upsert att;
                        }      
                    } 
                }
                //junda add
                else if('Prescription'.equalsIgnoreCase(type)){
                    PrescriptionCalloutHelper helper = new PrescriptionCalloutHelper();
                    HttpCalloutVO.Attachment workDoc = null;

                    List<HttpCalloutVO.Attachment> docList = helper.GetPrescriptionDoc(attKey);
                    if(!docList.isEmpty() && docList.size()>0){
                        workDoc = docList.get(0);
                    }
                    if (workDoc !=null){
                        att.name = workDoc.fileName;
                        List<String> splitList=att.name.split('\\.');
                        System.debug('splitList---'+splitList);
                        if(splitList.size()>0){
                            //att.contentType = 'application/'+splitList[splitList.size()-1];
                            if(splitList[splitList.size()-1]=='pdf'){
                                att.contentType = 'application/'+splitList[splitList.size()-1];
                            }else if(splitList[splitList.size()-1]=='jpg'){
                                att.contentType = 'image/jpeg';
                            }else{
                                att.contentType = 'image/'+splitList[splitList.size()-1];
                            }
                        }
                        att.body = null;
                        att.body = EncodingUtil.base64Decode(workDoc.attachmentData64Binary);
                        if (!Test.isRunningTest()){
                            upsert att;
                        }
                    }
                }
                //junda add end
            }
        }catch(Exception e){
            system.debug('invalid download parameter!');
            system.debug(e.getMessage());
        }
    }
}