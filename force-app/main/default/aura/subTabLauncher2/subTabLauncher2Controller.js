({
    handleClick : function(component, event, helper) {
        const knowledgeUrl = 'https://blah99k99.59.74.55b.bankwaale.us';
        const workspaceAPI = component.find("workspace");       
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.openSubtab({
                parentTabId: tabId,
                url: knowledgeUrl,
                focus: true
            });
        }).catch(function(error) {
            alert('Error opening subtab');
            console.log(error);
        });
    },

    handleClick2 : function(component, event, helper) {
        const knowledgeUrl = 'https://blah99k99.59.74.55b.bankwaale.us';
        const workspaceAPI = component.find("workspace");       
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.openSubtab({
                parentTabId: tabId,
                pageReference: {    
                    "type": "standard__webPage",
                    "attributes": {
                        "url": "https://blah99k99.59.74.55b.bankwaale.us/"
                    }
                },
                focus: true
            });
        }).catch(function(error) {
            alert('Error opening subtab');
            console.log(error);
        });
    },

    handleClick3 : function(component, event, helper) {
        const knowledgeUrl = 'https://blah99k99.59.74.55b.bankwaale.us';
        const workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            $A.get("e.force:navigateToURL").setParams({
                "url": knowledgeUrl
            }).fire();
        }).catch(function(error) {
            alert('Error navigating to URL');
            console.log(error);
        });
    },



    
})
