/**
 * Basic implementation of Apex Batch. For this demo we process Account
 * Records.
 * Batchable Class Implements the following method:
 *  - start()
 *  - execute()
 *  - finish()
 *
 * @author Christian Pelayo (pelayochristian.dev@gmail.com)
 */
public class BGBasicAccountBatch implements Database.Batchable<SObject> {

    /**
     * Entry method of our Batch Class
     * @param context batch context
     * @return `Iterable<Account>`
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, Name FROM Account');
    }

    /**
     * Main execution of out Batch Class. In our demo this we've just
     * updating account name by adding ' - updated'.
     * @param context batch context
     * @param scope list if Accounts
     */
    public void execute(Database.BatchableContext context, List<Account> scope) {
        List<Account> accountToUpdate = new List<Account>();
        try {
            for (Account account : scope) {
                account.Name = account.Name + ' - updated';
                accountToUpdate.add(account);
            }
            update accountToUpdate;
        } catch (Exception e) {
            System.debug('Exception message: ' + e.getMessage());
        }
    }

    /**
     * Finished method of out Batch Class. For our demo we added some
     * monitoring by sending an email to the user after the batch
     * execution finished.
     * @param context batch context
     */
    public void finish(Database.BatchableContext context) {
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :context.getJobId()
        ];
        //Send an email to the user who executed the Batch Job
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{
                a.CreatedBy.Email
        };
        mail.setToAddresses(toAddress);
        mail.setSubject('Apex job Status' + a.Status);
        mail.setPlainTextBody('The apex job processed ' + a.TotalJobItems +
                ' Batches with ' + a.NumberOfErrors + ' failures');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}