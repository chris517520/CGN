/********************************************************************************
 * Apex Class Name - TMCreatePolicyStepStrategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps Interface
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Ken     23/4/2018              Original Version
 ********************************************************************************/
public interface TMCreatePolicyStepStrategy {

    void stepInit();
    boolean stepValidation();
    void nextStep();
}