public class TMProductStrategyABAG extends TMProductStrategyAB{
    public static final string productCode = 'ABAG';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyABAG(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode); 
        this.ptvs = ptvs;
    }
}