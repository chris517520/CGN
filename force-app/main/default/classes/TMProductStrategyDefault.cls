/********************************************************************************
 * Apex Class Name - TMProductStrategyDefault
 * Created Date - Apr 23, 2018
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMProductStrategyDefault extends TMproductStrategy{
    
    public String productCode;
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyDefault(TMPolicyUtil.PolicyTransactionValidationStruct ptvs, String productCode){ 
        super();
        this.ptvs = ptvs;
        this.productCode = productCode;
    }

    public override void discountValidation(){
        super.discountValidation(ptvs, productCode);
    }
    
    public override void piValidation(){        
        super.piValidation(ptvs,productCode);
    }
    
    public override void transactionValidation(){
        super.transactionValidation(ptvs,productCode);
    }

}