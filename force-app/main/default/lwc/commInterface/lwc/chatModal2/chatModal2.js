import { LightningElement, api } from 'lwc';

export default class ChatModal2 extends LightningElement {
    @api isModalOpen;

    // Method to close the child modal
    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}