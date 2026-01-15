/********************************************************************************
 * Apex Class Name - TMProductStrategyNELG2
 * Created Date - Aug 31, 2023
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Owen             31/08/2023              Revise Version
 ********************************************************************************/
public class TMProductStrategyNELG2 extends TMProductStrategyNEL{

    public static final string productCode = 'NELG2';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyNELG2(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode);  
        this.ptvs = ptvs;
    }
}