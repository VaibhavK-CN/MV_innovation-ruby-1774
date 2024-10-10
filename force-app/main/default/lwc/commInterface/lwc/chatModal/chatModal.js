import { LightningElement, api, track } from 'lwc';

export default class ChatModal extends LightningElement {
    @api isModalOpen;
    @track isChildModalOpen = false; // Track if the child modal is open

    // Array of tabs for the tabset
    @track tabs = [
        { label: 'Article 45', value: 'Article45', content: 'You have got 0 new notifications' },
        { label: 'SMS', value: 'sms', content: 'This is SMS content.' },
        { label: 'Email', value: 'Lorem ipsum dolor sit amet...' },
        { label: 'WhatsApp', value: 'whatsapp', content: 'This is WhatsApp content.' },
    ];

    // Method to close the parent modal
    closeModal() {
        this.isModalOpen = false; // Close the parent modal when the close button is clicked
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    // Method to open the child modal and close the parent modal
    openChildModal() {
        this.isChildModalOpen = true;  // Open the child modal
        this.isModalOpen = false;      // Close the parent modal
    }

    // Method to close the child modal and reopen the parent modal
    closeChildModal() {
        this.isChildModalOpen = false; // Close the child modal
        this.isModalOpen = true;       // Reopen the parent modal
    }
}