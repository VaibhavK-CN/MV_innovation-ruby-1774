public class CommissionCalculationCntrl {
    public static void commissionCalculate(List<Lead>leadList){
        System.debug('leadList from class '+leadList);
        for(Lead le: leadList) {
            if(le.Call_Agent_Name__c !=null && le.Source__c == 'Appointment MIAVITA'){
                String percentageStr = le.Percentage__c.replaceAll('%', '');
                Decimal percentage = Decimal.valueOf(percentageStr);
                //Decimal percentage = Decimal.valueOf(le.Percentage__c);
                Decimal vvgFee = le.VVG_Fee__c;
                Decimal comm = vvgFee * 12 * percentage/100;
                le.Commission__c = comm;  
                System.debug('Commission__c from class for last loop '+le.Commission__c);
            }
            else if(le.Call_Agent_Name__c !=null && le.Source__c == 'Premium'){
                String percentageStr = le.Percentage__c.replaceAll('%', '');
                Decimal percentage = Decimal.valueOf(percentageStr);
                //Decimal percentage = Decimal.valueOf(le.Percentage__c);
                Decimal vvgFee = le.VVG_Fee__c;
                Decimal comm = vvgFee * 12 * percentage/100;
                le.Commission__c = comm;               
            }
            else if(le.Call_Agent_Name__c !=null && le.Source__c == 'Recommendation'){
                String percentageStr = le.Percentage__c.replaceAll('%', '');
                Decimal percentage = Decimal.valueOf(percentageStr);
                //Decimal percentage = Decimal.valueOf(le.Percentage__c);
                Decimal vvgFee = le.VVG_Fee__c;
                Decimal comm = vvgFee * 12 * percentage/100;
                le.Commission__c = comm;                
            }
            else if(le.Call_Agent_Name__c !=null && le.Source__c == 'Conclusion by Consultant'){
                String percentageStr = le.Percentage__c.replaceAll('%', '');
                Decimal percentage = Decimal.valueOf(percentageStr);
                //Decimal percentage = Decimal.valueOf(le.Percentage__c);
                Decimal vvgFee = le.VVG_Fee__c;
                Decimal comm = vvgFee * 12 * percentage/100;
                le.Commission__c = comm;
                System.debug('Commission__c from class for last loop '+le.Commission__c);
            }
        }
        
    }
    /* public static void totalCommissionCalculateForLegalProIns(List<LifeInsurance__c> lifeInsList) {
for (LifeInsurance__c lifeIns : lifeInsList) {
List<String> productList = new List<String>(); // Initialize inside the loop

productList.addAll(lifeIns.Products__c.split(';'));
System.debug('productList ' + productList);

String comm1 = '0';
String comm2 = '0';
String comm3 = '0';

if (lifeIns.Products__c == 'Verkehrsrechtsschutz TOP') {
comm1 = '50';
System.debug('comm1 ' + comm1);
System.debug('productList 1' + productList);
}
if (lifeIns.Products__c == 'Privatrechtsschutz') {
if (lifeIns.Rate__c == '225.00') {
comm2 = '75';
System.debug('lifeIns.Rate__c 1 ' + lifeIns.Rate__c);
} else if (lifeIns.Rate__c == '290.00') {
comm2 = '100';
}
}
if (lifeIns.Products__c == 'Kombinationsrechtsschutz') {
if (lifeIns.Rate__c == '295.00') {
comm3 = '125';
} else if (lifeIns.Rate__c == '395.00') {
comm3 = '150';
System.debug('comm3 ' + comm3);
}
}
if(lifeIns.Products__c == 'Verkehrsrechtsschutz TOP;Privatrechtsschutz'){
if((lifeIns.Rate__c == '90.00' || lifeIns.Rate__c == '125.00') && lifeIns.Rate__c == '225.00'){               
lifeIns.Commission__c = '50';
lifeIns.Commission_Legal_protection_Privatrech__c = '75';

}
if((lifeIns.Rate__c == '90.00' || lifeIns.Rate__c == '125.00') && lifeIns.Rate__c == '290.00'){               
lifeIns.Commission__c = '50';
lifeIns.Commission_Legal_protection_Privatrech__c = '100';

}

}

if(lifeIns.Products__c == 'Verkehrsrechtsschutz TOP;Kombinationsrechtsschutz TOP'){
if((lifeIns.Rate__c == '90.00' || lifeIns.Rate__c == '125.00') && lifeIns.Rate__c == '295.00'){               
lifeIns.Commission__c = '50';
lifeIns.Commission_Legal_protection_Kombinatio__c = '125';

}
if((lifeIns.Rate__c == '90.00' || lifeIns.Rate__c == '125.00') && lifeIns.Rate__c == '395.00'){               
lifeIns.Commission__c = '50';
lifeIns.Commission_Legal_protection_Kombinatio__c = '150';

}
}
if(lifeIns.Products__c == 'Privatrechtsschutz;Kombinationsrechtsschutz TOP'){
//225.00;290.00;295.00;395.00
if(lifeIns.Rate__c == '225.00' && lifeIns.Rate__c == '295.00' ){               
// lifeIns.Commission__c = '0';
lifeIns.Commission_Legal_protection_Privatrech__c = '75';
lifeIns.Commission_Legal_protection_Kombinatio__c = '125';  
}
if(lifeIns.Rate__c == '290.00' && lifeIns.Rate__c == '395.00'){               
lifeIns.Commission_Legal_protection_Privatrech__c = '100';
lifeIns.Commission_Legal_protection_Kombinatio__c = '150';    
}
if(lifeIns.Rate__c == '225.00' && lifeIns.Rate__c == '395.00' ){               
// lifeIns.Commission__c = '0';
lifeIns.Commission_Legal_protection_Privatrech__c = '75';
lifeIns.Commission_Legal_protection_Kombinatio__c = '150';  
}
if(lifeIns.Rate__c == '290.00' && lifeIns.Rate__c == '295.00'){               
lifeIns.Commission_Legal_protection_Privatrech__c = '100';
lifeIns.Commission_Legal_protection_Kombinatio__c = '125';    
}

}
if(lifeIns.Products__c =='Verkehrsrechtsschutz TOP;Privatrechtsschutz;Kombinationsrechtsschutz TOP'){
if((lifeIns.Rate__c == '90.00' || lifeIns.Rate__c == '125.00') && lifeIns.Rate__c == '295.00' ){               
lifeIns.Commission__c = '50';
lifeIns.Commission_Legal_protection_Kombinatio__c = '125';

}
if((lifeIns.Rate__c == '90.00' || lifeIns.Rate__c == '125.00') && lifeIns.Rate__c == '395.00'){               
lifeIns.Commission__c = '50';
lifeIns.Commission_Legal_protection_Kombinatio__c = '150';

}
}

lifeIns.Commission__c = Decimal.valueOf(comm1).toString();
lifeIns.Commission_Legal_protection_Privatrech__c = Decimal.valueOf(comm2).toString();
lifeIns.Commission_Legal_protection_Kombinatio__c = Decimal.valueOf(comm3).toString();

System.debug('lifeIns.Commission__c ' + lifeIns.Commission__c); 
}
} */
    /*public static void calculateCommission(List<LifeInsurance__c> lifeInsuranceRecords) {
        for (LifeInsurance__c record : lifeInsuranceRecords) {
            List<SelectOption> selectedProducts = record.Products__c;
            List<SelectOption> selectedRates = record.Rate__c;
            
            if (selectedProducts.size() == 1) {
                // Single product selected
                SelectOption selectedProduct = selectedProducts[0];
                SelectOption selectedRate = selectedRates[0];
                
                if (selectedProduct.equals('Verkehrsrechtsschutz TOP')) {
                    if (selectedRate.equals('Individual')) {
                        record.Commission__c = 50;
                    } else if (selectedRate.equals('Family')) {
                        record.Commission__c = 50;
                    }
                } else if (selectedProduct.equals('Privatrechtsschutz')) {
                    if (selectedRate.equals('Individual')) {
                        record.Commission__c = 75;
                    } else if (selectedRate.equals('Family')) {
                        record.Commission__c = 100;
                    }
                } else if (selectedProduct.equals('Kombinationsrechtsschutz TOP')) {
                    if (selectedRate.equals('Individual')) {
                        record.Commission__c = 125;
                    } else if (selectedRate.equals('Family')) {
                        record.Commission__c = 150;
                    }
                }
            } else if (selectedProducts.size() == 2) {
                // Two products selected
                if (selectedProducts.contains('Verkehrsrechtsschutz TOP') && selectedProducts.contains('Privatrechtsschutz')) {
                    if (selectedRates.contains('Individual')) {
                        record.Commission__c = 125;
                    } else if (selectedRates.contains('Family')) {
                        record.Commission__c = 175;
                    }
                } else if (selectedProducts.contains('Verkehrsrechtsschutz TOP') && selectedProducts.contains('Kombinationsrechtsschutz TOP')) {
                    if (selectedRates.contains('Individual')) {
                        record.Commission__c = 175;
                    } else if (selectedRates.contains('Family')) {
                        record.Commission__c = 225;
                    }
                } else if (selectedProducts.contains('Privatrechtsschutz') && selectedProducts.contains('Kombinationsrechtsschutz TOP')) {
                    if (selectedRates.contains('Individual')) {
                        record.Commission__c = 150;
                    } else if (selectedRates.contains('Family')) {
                        record.Commission__c = 200;
                    }
                }
            }
        }
    }*/
}