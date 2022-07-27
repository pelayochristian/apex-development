/**
 * Created by christianpelayo on 9/29/21.
 */

@IsTest
public with sharing class BGBasicAccountBatchTest {

    @IsTest
    public static void BGBasicAccountBatchTest() {
        // Instantiate Account Records
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account ac = new Account(Name = 'AccountName ' + i);
            accounts.add(ac);
        }
        // insert records
        if (accounts.size() > 0) {
            insert accounts;
        }

        System.Test.startTest();
        BGBasicAccountBatch ab = new BGBasicAccountBatch();
        Database.executeBatch(ab);
        System.Test.stopTest();

        // Assert Records
        List<Account> assertAccounts = new List<Account>([SELECT Id, Name FROM Account]);
        System.assert(assertAccounts[0].Name.contains('updated'));
    }
}