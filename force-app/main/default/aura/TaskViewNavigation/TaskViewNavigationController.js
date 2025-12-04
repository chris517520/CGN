({
    doInit : function(component, event, helper) {
        const workspaceAPI = component.find('workspaceAPI');
        workspaceAPI.isConsoleNavigation().then(isConsole => {
            if (isConsole) {
                //issubtab
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    console.log('to see tab'+response.tabId);
                    workspaceAPI.isSubtab({
                        tabId: response.tabId
                    }).then(function(response) {
                        console.log('to see juge'+response);
                        if (response) {
                            //delete tab
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                                var focusedTabId = response.tabId;
                                workspaceAPI.getTabURL({
                                    tabId: focusedTabId
                                }).then(function(response) {
                                    console.log('to see URL:'+response);
                                    if(response.includes('?')){
                                        workspaceAPI.openTab({
                                            url: response+'&nooverride=1&count=3&overrideNavRules=true',
                                            focus: true
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    }else{
                                        workspaceAPI.openTab({
                                            url: response+'?nooverride=1&count=3&overrideNavRules=true',
                                            focus: true
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    } 
                                })
                                .catch(function(error) {
                                    console.log(error);
                                });
                                
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        }
                        else {
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                                var focusedTabId = response.tabId;
                                console.log('to new pop tab:'+focusedTabId);
                                workspaceAPI.getTabURL({
                                    tabId: focusedTabId
                                }).then(function(response) {
                                    console.log('to see URL:'+response);
                                    if(response.includes('?')){
                                        workspaceAPI.openTab({
                                            url: response+'&nooverride=1&count=3&overrideNavRules=true',
                                            focus: true
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    }else{
                                        workspaceAPI.openTab({
                                            url: response+'?nooverride=1&count=3&overrideNavRules=true',
                                            focus: true
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    }
                                })
                                .catch(function(error) {
                                    console.log(error);
                                });
                            })
                            .catch(function(error) {
                                console.log(error);
                            });      
                        }
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})