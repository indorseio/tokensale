// // Specifically request an abstraction for MetaCoin
var INDToken = artifacts.require("IndorseToken");

var num_tokens = 2163 * Math.pow(10,23);
var indFundDeposit_balance = 301 * Math.pow(10,23);

contract('INDToken', function(accounts){
  it("should have a total supply of x million tokens", function(){
    return INDToken.deployed().then(function(instance){
      return instance.totalSupply();
    }).then(function(supply){
    	// console.log(supply.valueOf());
      assert.equal(supply.valueOf(), num_tokens, "Total supply isn't zero");
    });
  });

  it("should have indFundDeposit set as account 0", function(){
  	return INDToken.deployed().then(function(instance){
  		return instance.indFundDeposit();
  	}).then(function(address){
  		// console.log("indFundDeposit address = ", address);
  		assert.equal(address, accounts[0]);
  	});
  });

  // it("indFundDeposit should have a supply of 30.1 million tokens", function(){
  // 	return INDToken.deployed().then(function(instance){
  // 		console.log(instance.address);
  // 		console.log(accounts[0]);
  // 		return instance.balanceOf.call(accounts[0], {from: accounts[0]});
  // 	}).then(function(balance){
  // 		console.log("Balance of indFundDeposit =", balance.toNumber());
  // 		assert.equal(balance.toNumber(), indFundDeposit_balance);
  // 	});
  // });
});
