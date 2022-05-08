// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol"; 

import "remix_accounts.sol";
import "../contracts/Main.sol";

contract testSuite {

    Main mainToTest;
    function beforeAll() public {
        mainToTest = new Main();
    }

    function checkSuccess() public returns (bool)  {
        mainToTest.addProperty(TestsAccounts.getAccount(0), "Marseille", 32, mainToTest.getPropertyType(1));
        mainToTest.addProperty(TestsAccounts.getAccount(0), "Langeais", 79, mainToTest.getPropertyType(2));

        mainToTest.addProperty(TestsAccounts.getAccount(1), "Aix", 36504, mainToTest.getPropertyType(0));

        Assert.equal(mainToTest.getMyPropertiesFrom(TestsAccounts.getAccount(0))[0].propertyAddress, "Marseille", "1 - Marseille");
        Assert.equal(mainToTest.getMyPropertiesFrom(TestsAccounts.getAccount(0))[1].propertyAddress, "Langeais", "1 - Langeais");
        Assert.equal(mainToTest.getMyPropertiesFrom(TestsAccounts.getAccount(1))[0].propertyAddress, "Aix", "1 - Aix");

        mainToTest.depositBalance();
        mainToTest.buyProperty(TestsAccounts.getAccount(0), 0);
        
        Assert.equal(mainToTest.getMyPropertiesFrom(TestsAccounts.getAccount(0))[0].propertyAddress, "Langeais", "2 - Langeais");
        Assert.equal(mainToTest.getMyPropertiesFrom(TestsAccounts.getAccount(1))[0].propertyAddress, "Aix", "2 - Aix");
        Assert.equal(mainToTest.getMyPropertiesFrom(TestsAccounts.getAccount(1))[1].propertyAddress, "Marseille", "2 - Marseille");
        return true;
    }
}
    