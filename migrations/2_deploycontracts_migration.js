var SCRToken = artifacts.require("./SCRToken.sol");
var INDToken = artifacts.require("./IndorseToken.sol");
var IndorseSaleContract = artifacts.require("./IndorseSaleContract.sol");

var _indFundDeposit = "0x3568ad428a3878a8fa55d41fef163891999ce2e9",
    _indFutureDeposit = "0xe46b854e221807c2319de20f38700d00133264ce",
    _indPresaleDeposit = "0xc28bab8b8c4d348945ce0e071f015caea139c92a",
    _indInflationDeposit = "0xf7fcf34e057a70bfb490755d1f5d68ead901472e"

var _ethFundDeposit = "0xbf4dd8b8b9f2c88493865cd62b6757fcb30b6615",
    _INDtoken, 
    _fundingStartTime = 1501643908,
    duration = 20;

var INDAddress, SCRAddress, SaleContractAddress;

module.exports = function(deployer){
	// console.log("Deploying IND");
	deployer.deploy(INDToken, _indFundDeposit, _indFutureDeposit, _indPresaleDeposit, _indInflationDeposit).then(function() {
		INDAddress = INDToken.address;
		console.log("IND address = ", INDAddress);
		return deployer.deploy(IndorseSaleContract, _ethFundDeposit, _indFundDeposit, INDAddress, _fundingStartTime, duration).then(function(instance2){
			console.log("Deployed IndorseSaleContract");
	  		console.log("Sale Contract address = ", IndorseSaleContract.address);
		});
  	});
}