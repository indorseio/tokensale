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
    
    uint256 public constant indSale = 31603785 * 10**decimals;   // 29 million IND reserved for Indorse use
    uint256 public constant indSeed = 3975202 * 10**decimals; // 
    uint256 public constant indPreSale = 23166575 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indVesting  = 28167614 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indCommunity  = 10954072 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indFuture  = 58619494 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indInflation  = 14670632 * 10**decimals;  // 69.2 million IND for future token sale
   
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
      
      balances[indFundDeposit]    = indFund;    // Deposit IND share
      balances[indFutureDeposit]  = indFuture;  // Deposit IND share
      balances[indPresaleDeposit] = indPreSale;    // Deposit IND future share
      balances[indInflationDeposit] = indInflation; // Deposit for inflation

      totalSupply = indFund + indPreSale + indFuture + indInflation;

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