({
    handleClick : function(component, event, helper) {
        const url = 'https://blah99k99.59.74.55b.bankwaale.us';
        const workspaceAPI = component.find("workspace");       
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.openSubtab({
                parentTabId: tabId,
                url: url,
                focus: true
            });
        }).catch(function(error) {
            alert('Error opening subtab');
            console.log(error);
        });
    }
})
