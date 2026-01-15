/********************************************************************************
 * Apex Class Name - TMProductStrategyNESG2
 * Created Date - Aug 31, 2023
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Owen             31/08/2023              Revise Version
 ********************************************************************************/
public class TMProductStrategyNESG2 extends TMProductStrategyNEL{

    public static final string productCode = 'NESG2';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyNESG2(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode); 
        this.ptvs = ptvs;
    }
}