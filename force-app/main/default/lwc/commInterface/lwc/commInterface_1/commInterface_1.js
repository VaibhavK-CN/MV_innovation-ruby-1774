import { LightningElement } from 'lwc';

export default class CommInterface_1 extends LightningElement {
   
    isModalOpen = false;

    handleOpenModal() {
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }
}