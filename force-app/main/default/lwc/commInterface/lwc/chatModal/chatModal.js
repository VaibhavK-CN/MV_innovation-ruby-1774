import { LightningElement, api, track } from 'lwc';

export default class ChatModal extends LightningElement {
    // @api property to receive modal state from parent
    @api isModalOpen;
    

    // Array of tabs for the tabset
    @track tabs = [
        { label: 'Article 45', value: 'Article45', content: 'This is the Article 45 Related notifications.' },
        { label: 'SMS', value: 'sms', content: 'This is SMS content.' },
        { label: 'Email', value: 'email', content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lorem libero, scelerisque sed urna eu, sodales commodo magna. Vestibulum eget enim at velit interdum consequat. Nullam consectetur tortor eu sapien lobortis, congue pulvinar risus dapibus. Pellentesque massa dolor, varius dignissim aliquet vel, placerat id elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec gravida malesuada erat sed rutrum. Suspendisse potenti. Donec ornare nulla metus, eu accumsan nisi ultrices vel. Pellentesque vitae orci leo. Nam sed quam neque. Praesent dictum laoreet ipsum, eu blandit nibh cursus in. Ut enim orci, semper quis nulla in, laoreet imperdiet libero.' },
        { label: 'WhatsApp', value: 'whatsapp', content: 'This is WhatsApp content.' },
    ];

    // Method to close the modal
    closeModal() {
        // Dispatch an event to inform the parent component to close the modal
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }



    // Method to close the modal
    closeModal() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    // Method to trigger opening of the second modal
    handleReply() {
        const replyEvent = new CustomEvent('reply');
        this.dispatchEvent(replyEvent);
    }
}
