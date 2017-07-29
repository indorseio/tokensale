pragma solidity ^0.4.11;
import "./StandardToken.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

// note introduced onlyPayloadSize in StandardToken.sol to protect against short address attacks
// Then Deploy IndorseToken and SCRToken
// Then deploy Sale Contract
// Then, using indFundDeposit account call approve(saleContract,<amount of offering>)

contract IndorseToken is SafeMath, StandardToken, Pausable {

    // metadata
    string public constant name = "Indorse Token";
    string public constant symbol = "IND";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public indFundDeposit;      // deposit address for Indorse reserve
    address public indFutureDeposit;    // deposit address for Indorse Future reserve
    address public indPresaleDeposit;   // deposit address for Indorse Future reserve
    address public indInflationDeposit; // deposit address for Indorse Inflation pool
    
    uint256 public constant indFund    = 301 * (10 ** 5) * 10**decimals;   // 30.1 million IND reserved for Indorse use
    uint256 public constant indPreSale =  17 * (10 ** 6) * 10**decimals; // 
    uint256 public constant indFuture  = 692 * (10**5) * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indInflation  = 100 * (10**6) * 10**decimals;  // 69.2 million IND for future token sale
   
    // constructor
    function IndorseToken(
        address _indFundDeposit,
        address _indFutureDeposit,
        address _indPresaleDeposit,
        address _indInflationDeposit
        )
    {
      indFundDeposit    = _indFundDeposit;
      indFutureDeposit  = _indFutureDeposit ;
      indPresaleDeposit = _indPresaleDeposit;
      indInflationDeposit = _indInflationDeposit;
      totalSupply       = indFund;

      balances[indFundDeposit]    = indFund;    // Deposit IND share
      balances[indFutureDeposit]  = indFuture;  // Deposit IND share
      balances[indPresaleDeposit] = indPreSale;    // Deposit IND future share
      balances[indInflationDeposit] = indInflation; // Deposit for inflation

      Transfer(0x0,indFundDeposit,indFund);
      Transfer(0x0,indFutureDeposit,indFuture);
      Transfer(0x0,indPresaleDeposit,indPreSale);
      Transfer(0x0,indInflationDeposit,indInflation);
   }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}