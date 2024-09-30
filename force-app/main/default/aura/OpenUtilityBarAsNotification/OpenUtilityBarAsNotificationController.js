({
    getValueFromLwc: function(component, event, helper) {
        console.log('from aura');
        console.log('event entry ' + JSON.stringify(event));
        
        // console.log('event ' + JSON.stringify(event.detail));
        // let value = event.detail.val;
        console.log('event val ' + event.Ep.val);
        let isLoginUserCorrectUser = event.Ep.val;
        
        if (isLoginUserCorrectUser === 'true') {
            helper.openUtilityPopUp(component, event, helper);
            console.log('correct user::::');
        } else if (isLoginUserCorrectUser === 'false') {
            helper.closeUtilityPopUp(component, event, helper);
            console.log('Close Modal::::');
        }
    }
})