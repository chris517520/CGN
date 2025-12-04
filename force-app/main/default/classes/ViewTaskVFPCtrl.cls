/**************************************************************************************************
 * Name: ViewTaskVFPCtrl
 * Object: Task
 * Purpose: overwrite standard task view page layout, and check if need to auto click to dial
 * Author: ranzhao@deloitte.com.cn
 * Create Date: 2021-09-23
 * Modify History:
 * Ver.  Author        Date        Detail
 * 1.0   Rancho        2021-09-23  Create this class
 **************************************************************************************************/
public without sharing class ViewTaskVFPCtrl{
    public static Task currentTask{get;set;}
    public Boolean autoClickToDial{get;set;}

    public ViewTaskVFPCtrl(ApexPages.StandardController stdController){
        currentTask=(Task) stdController.getRecord();
        autoClickToDial=false;
    }

    /********************************************************************
     * initAction
     * @decs: init data when ViewTaskVFP loaded
     * @return: null
     ********************************************************************/
    public void initAction(){
        checkAutoClickToDial();
    }

    /********************************************************************
     * checkAutoClickToDial
     * @decs: After TM Agent logged a call, auto click to dial to inform Aspect update UCID and other call details
     *        auto click to dial in below situations:
     *        1. task record type developer name is TM_Call
     *        2. task field - UCID is blank
     *        3. task field - Have Clicked to Dial is true
     *        4. task created in one minute
     * @return: null
     ********************************************************************/
    public void checkAutoClickToDial(){
        List<Task> taskList=[SELECT UCID__c,Have_Clicked_to_Dial__c,CreatedDate FROM Task WHERE Id = :currentTask.Id AND RecordType.DeveloperName = :TMCallCenterUtility.TM_DFT_CALL_RC FOR UPDATE];
        if(taskList.size()>0){
            Task tempTask=taskList[0];
            if(tempTask.Have_Clicked_to_Dial__c && String.isBlank(tempTask.UCID__c) && tempTask.CreatedDate.addMinutes(1)>Datetime.now()){
                autoClickToDial=true;
                tempTask.Have_Clicked_to_Dial__c=false;
                update tempTask;
            }
        }
        system.debug('autoClickToDial: '+autoClickToDial);
    }
}