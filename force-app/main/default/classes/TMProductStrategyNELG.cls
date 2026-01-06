/********************************************************************************
 * Apex Class Name - TMProductStrategyNELG
 * Created Date - Apr 23, 2018
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMProductStrategyNELG extends TMProductStrategyNEL{

    public static final string productCode = 'NELG';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyNELG(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode); 
        this.ptvs = ptvs;
    }
}