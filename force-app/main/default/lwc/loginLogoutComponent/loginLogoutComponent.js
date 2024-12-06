import { LightningElement, track } from 'lwc';
import getCurrentUser from '@salesforce/apex/UserStatusController.getCurrentUser';
import updateUserStatus from '@salesforce/apex/UserStatusController.updateUserStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LoginLogoutComponent extends LightningElement {
    @track user;
    @track isLoading = false;
    userLocale = navigator.language || 'en'; // Fallback to 'en' (English)

    connectedCallback() {
        this.fetchUserDetails();
    }

    fetchUserDetails() {
        this.isLoading = true;
        getCurrentUser()
            .then((result) => {
                this.user = result;
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Error fetching user details:', error);
                this.showToast('Error', this.getTranslatedMessage('fetchError'), 'error');
                this.isLoading = false;
            });
    }

    handleWorkDayStart() {
        this.updateStatus('Logged In');
    }

    handleWorkDayEnd() {
        this.updateStatus('Logged Out');
    }

    handleBreak() {
        this.updateStatus('Break');
    }

    updateStatus(status) {
        this.isLoading = true;
        updateUserStatus({ status })
            .then((leadUrl) => {
                this.showToast('Success', this.getTranslatedMessage('statusUpdatedSuccess', status), 'success');
                if (leadUrl) {
                    // If a lead URL is returned (i.e., the user is 'Logged In'), redirect to the lead page
                    window.location.href = leadUrl;
                    console.log('this is lead URL', leadUrl);
                } else {
                    // Otherwise, refresh user details
                    this.fetchUserDetails();
                }
            })
            .catch((error) => {
                console.error('Error updating user status:', error);
                this.showToast('Error', this.getTranslatedMessage('statusUpdatedError', status), 'error');
                this.isLoading = false;
            });
    }

    getTranslatedMessage(key, status = '') {
        // A simple switch-case or map for user language-based message retrieval
        const messages = {
            en: {
                fetchError: 'Failed to fetch user details.',
                statusUpdatedSuccess: `Status updated to ${status}.`,
                statusUpdatedError: `Failed to update status to ${status}.`,
            },
            de: {
                fetchError: 'Benutzerdaten konnten nicht abgerufen werden.',
                statusUpdatedSuccess: `Status auf ${status} aktualisiert.`,
                statusUpdatedError: `Fehler beim Aktualisieren des Status auf ${status}.`,
            },
            // Add other languages as necessary
        };
        
        // Default to English if no translation is found for the user's locale
        return messages[this.userLocale]?.[key] || messages['en'][key];
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }
}