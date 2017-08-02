var saleContract = artifacts.require("IndorseSaleContract");
var INDToken = artifacts.require("IndorseToken");
var SCRToken = artifacts.require("SCRToken");

var instance_IND;
var instance_SCR;
var saleContractAddress;
var supply_sale = 30100000000000000000000000;
var num_tokens  = 1000000000000000000000000;

contract('saleContract', function(accounts){
  it("should not have a total supply of 30.1 million tokens to begin with", function(){
    return saleContract.deployed().then(function(instance){
      saleContractAddress = instance.address;
      return instance.totalSupply();
    }).then(function(supply){
    	console.log("Supply of Sale Contract =", supply.valueOf());
      assert.notEqual(supply.valueOf(), 30100000000000000000000000, "Total supply isn't zero");
    });
  });

  it("should have a supply after approval", function(){
  	INDToken.deployed().then(function(instance){
  		instance_IND = instance;
  		// console.log(saleContractAddress);
  		return instance_IND.approve(saleContractAddress, supply_sale, {from: accounts[0]});
  	}).then(function(){
  		return instance_IND.allowance.call(accounts[0], saleContractAddress);
  	}).then(function(supply){
      assert.equal(supply.valueOf(), 30100000000000000000000000, "allowance of Sale Contract isn't set properly");
    });
  });

  it("SCR contract should have Sale Contract set as host", function(){
    SCRToken.deployed().then(function(instance){
      instance_SCR = instance;
      // console.log("SCR token address =", instance_SCR.address);
      return instance_SCR.approve(saleContractAddress, 1000, {from: accounts[0]});
    }).then(function(){
      return instance_SCR.crowdSale();
    }).then(function(address){
      // console.log("Address of the Indorse Platform in the SCR contract =", address);
      assert.equal(address, saleContractAddress, "Indorse Platform address isn't set properly");
    });
  });

  it("should have IND balance of account 5 to be 0", function(){
    INDToken.deployed().then(function(instance){
      return instance.balanceOf.call(accounts[5]);
    }).then(function(balance){
      console.log("Balance of accounts[5] =", balance.toNumber());
      assert.equal(balance.toNumber(), 0, "Balance of Account 5 is not 0");
    });
  });

  it("should have IND balance of account 6 to be 0", function(){
    INDToken.deployed().then(function(instance){
      return instance.balanceOf.call(accounts[6]);
    }).then(function(balance){
      console.log("Balance of accounts[6] =", balance.toNumber());
      assert.equal(balance.toNumber(), 0, "Balance of Account 6 is not 0");
    });
  })

  it("should be able to send Ether to the sale contract", function(){
    saleContract.deployed().then(function(sale_instance){
      console.log("Trying to send Ether to this instance = ", sale_instance);
      return sale_instance.sendTransaction({
        from: accounts[6],
        value: web3.toWei(1, "ether"),
        gas: 200000
      });
    }).then(function(result){
      console.log("After sending ether =", result);
    });

    INDToken.deployed().then(function(ind_instance){
      return ind_instance.balanceOf.call(accounts[6], {from: accounts[0]});
    }).then(function(balance){
      console.log("Balance of tokens in account 6 after sending Ether = ", balance.toNumber());
      assert.equal(balance.toNumber(), num_tokens, "IND Token balance of the account wasn't right after sending Ether")
    });  
  });
});

// // it("should send coin correctly", function() {
// //     var meta;

// //     // Get initial balances of first and second account.
// //     var account_one = accounts[0];
// //     var account_two = accounts[1];

// //     var account_one_starting_balance;
// //     var account_two_starting_balance;
// //     var account_one_ending_balance;
// //     var account_two_ending_balance;

// //     var amount = 10;

// //     return MetaCoin.deployed().then(function(instance) {
// //       meta = instance;
// //       return meta.getBalance.call(account_one);
// //     }).then(function(balance) {
// //       account_one_starting_balance = balance.toNumber();
// //       return meta.getBalance.call(account_two);
// //     }).then(function(balance) {
// //       account_two_starting_balance = balance.toNumber();
// //       return meta.sendCoin(account_two, amount, {from: account_one});
// //     }).then(function() {
// //       return meta.getBalance.call(account_one);
// //     }).then(function(balance) {
// //       account_one_ending_balance = balance.toNumber();
// //       return meta.getBalance.call(account_two);
// //     }).then(function(balance) {
// //       account_two_ending_balance = balance.toNumber();

// //       assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
// //       assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
// //     });