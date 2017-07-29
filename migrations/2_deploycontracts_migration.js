var SCRToken = artifacts.require("./SCRToken.sol");
var INDToken = artifacts.require("./IndorseToken.sol");
var IndorseSaleContract = artifacts.require("./IndorseSaleContract.sol");

var _indFundDeposit = "",
    _indFutureDeposit = "",
    _indPresaleDeposit = "",
    _indInflationDeposit = ""

var _ethFundDeposit = "",
    _INDtoken, 
    _SCRtoken,
    _fundingStartTime = 1501323695,
    duration = 20;

var INDAddress, SCRAddress, SaleContractAddress;

module.exports = function(deployer){
	deployer.deploy(INDToken, _indFundDeposit, _indFutureDeposit, _indPresaleDeposit, _indInflationDeposit).then(function() {
		INDAddress = INDToken.address;
	  	return deployer.deploy(SCRToken).then(function(){
	  		SCRAddress = SCRToken.address;
	  		deployer.deploy(IndorseSaleContract, _ethFundDeposit, _indFundDeposit, INDAddress, SCRAddress, _fundingStartTime, duration);
	  	});
	});
}