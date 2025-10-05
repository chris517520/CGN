/********************************************************************************
Apex Class Name - EncryptionUtil
Created Date - Jun 16, 2020
@description EncryptionUtil: to consolidate common methods related to the encryption,e.g. AES, MD5
Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer       Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       TC@Cigna        16/06/2020              First Version
********************************************************************************/

public class EncryptionUtil{

    //16 byte string. since characters used are ascii, each char is 1 byte.
    private static String keyStr ='3L97o6g29Ac234=6';       //Default key value if Custom Setting is missing
    private static Blob privateKey;
 	private static final String CB_UNION_KEY = 'CB_Union';    
    
    //Initiate the Private Key from Custom Setting:
    static{
        Portal_Settings__c ps = Portal_Settings__c.getInstance();
        if(ps!=null && !String.isEmpty(ps.Broker_Encryption_Private_Key_AES128__c) && ps.Broker_Encryption_Private_Key_AES128__c.length()== 16){
            keyStr = ps.Broker_Encryption_Private_Key_AES128__c;
        }

        privateKey = Blob.valueOf(keyStr);
    }

    //Encrypt String based on AES128:
    public static String encryptStrAES128(String strToEntrypt){
        
        String encryptedStr = '';
        if(!String.isEmpty(strToEntrypt)){
            //Blob cryptoKey = Crypto.generateAesKey(128);
            Blob blobData = Blob.valueOf(strToEntrypt);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', privateKey, blobData);
            encryptedStr=EncodingUtil.base64Encode(encryptedData);
            
        }
        system.debug('encryptedStr='+encryptedStr);
        return encryptedStr;
    }
	
    
    //Decrypt String based on AES128:
    public static String decryptStrAES128(String strToDetrypt){
        String decryptedStr = '';
        if(!String.isEmpty(strToDetrypt)){
            Blob decodedEncryptedBlob =EncodingUtil.base64Decode(strToDetrypt);
            Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', privateKey, decodedEncryptedBlob);
            decryptedStr=decryptedBlob.toString();
            
        }
        system.debug('decryptedStr='+decryptedStr);
        return decryptedStr;
    }
    
    
    public static String signURL(String strToSign){ 
        String signingString = strToSign;
        API_Auth_Setting__mdt[] key = [SELECT api_key__c from API_Auth_Setting__mdt  where DeveloperName=:CB_UNION_KEY];
    	
        if(key.size()>0){
            String privateKey = key[0].api_key__c;
            Blob urlBlob = Blob.valueOf(signingString);   
            Blob privateKeyBlob= EncodingUtil.base64Decode(privateKey);
            Blob signatureBlob = Crypto.sign('RSA-SHA256', urlBlob, privateKeyBlob);
            String signature = EncodingUtil.base64Encode(signatureBlob);
            return  signature;
        }else{
            return 'sign_error';
        }
    }

    /**********************************************************************
     * AM project coupon jack add
     * signURL
     * @description:build signature with specific key
     * param String->String need to build signature, String -> key name 
     * @return String ->generated signature
     **********************************************************************/
    public static String signURL(String strToSign,String keyName,String algorithmName){ 
        String signingString = strToSign;
        API_Auth_Setting__mdt[] key = [SELECT api_key__c from API_Auth_Setting__mdt  where DeveloperName=:keyName];
    	
        if(key.size()>0){
            String privateKey = key[0].api_key__c;
            Blob urlBlob = Blob.valueOf(signingString);   
            Blob privateKeyBlob= EncodingUtil.base64Decode(privateKey);
            Blob signatureBlob = Crypto.sign(algorithmName, urlBlob, privateKeyBlob);
            String signature = EncodingUtil.base64Encode(signatureBlob);
            return  signature;
        }else{
            return 'sign_error';
        }
    }

    /********************************************************************
     * Rancho_CallCenterUCID_20210618
     * encryptStr
     * @decs: encypt string with private key
     * @param Blob blobToSign: string need to encrypt, String keyName: key API name, String algorithmName: encrypt method
     * @return String
     ********************************************************************/
    public static String encryptStr(Blob blobToSign,String keyName,String algorithmName){
        List<API_Auth_Setting__mdt> keyList = [SELECT api_key__c FROM API_Auth_Setting__mdt  WHERE DeveloperName=:keyName];
        if(!keyList.isEmpty()){
            String privateKey = keyList[0].api_key__c;
            String signature = EncodingUtil.base64Encode(Crypto.generateMac(algorithmName, blobToSign, Blob.valueOf(privateKey)));
            return signature;
        }else{
            return 'sign_error';
        }
    }
}