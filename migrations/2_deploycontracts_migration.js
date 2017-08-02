var SCRToken = artifacts.require("./SCRToken.sol");
var INDToken = artifacts.require("./IndorseToken.sol");
var IndorseSaleContract = artifacts.require("./IndorseSaleContract.sol");

// "0x3568ad428a3878a8fa55d41fef163891999ce2e9", "0xe46b854e221807c2319de20f38700d00133264ce", "0xc28bab8b8c4d348945ce0e071f015caea139c92a", "0xf7fcf34e057a70bfb490755d1f5d68ead901472e", "0xbf4dd8b8b9f2c88493865cd62b6757fcb30b6615"

// IND = 0x9cb5FbA4e661FC4A7e2eeF889DC2ED106cC050CC
// SCR = 0x0c3706bfDd2BB02Fb983E1b0b441c151DEf9da1f
// Sale = 0x40F2ED44da82719d796C8BC198223dFDc1B7fB36



var _indFundDeposit = "0x3568ad428a3878a8fa55d41fef163891999ce2e9",
    _indFutureDeposit = "0xe46b854e221807c2319de20f38700d00133264ce",
    _indPresaleDeposit = "0xc28bab8b8c4d348945ce0e071f015caea139c92a",
    _indInflationDeposit = "0xf7fcf34e057a70bfb490755d1f5d68ead901472e"

var _ethFundDeposit = "0xbf4dd8b8b9f2c88493865cd62b6757fcb30b6615",
    _INDtoken, 
    _SCRtoken,
    _fundingStartTime = 1501643908,
    duration = 20;

var INDAddress, SCRAddress, SaleContractAddress;

module.exports = function(deployer){
	// console.log("Deploying IND");
	deployer.deploy(INDToken, _indFundDeposit, _indFutureDeposit, _indPresaleDeposit, _indInflationDeposit).then(function() {
		INDAddress = INDToken.address;
		console.log("IND address = ", INDAddress);
	  	return deployer.deploy(SCRToken).then(function(){
	  		SCRAddress = SCRToken.address;
	  		console.log("SCR address = ", SCRAddress);
	  		return deployer.deploy(IndorseSaleContract, _ethFundDeposit, _indFundDeposit, INDAddress, SCRAddress, _fundingStartTime, duration);
  		}).then(function(instance2){
  			console.log("Deployed IndorseSaleContract");
	  		console.log("Sale Contract address = ", IndorseSaleContract.address);
  		});
	});
}