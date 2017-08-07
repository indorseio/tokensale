pragma solidity ^0.4.11;

// for test
import "./IndorseToken.sol";
import "./SCRtoken.sol";


import "./SafeMath.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract IndorseSaleContract is  Ownable,SafeMath,Pausable {
    IndorseToken    ind;

    // crowdsale parameters
    uint256 public fundingStartTime;
    uint256 public fundingEndTime;
    uint256 public totalSupply;
    address public ethFundDeposit;      // deposit address for ETH for Indorse Fund
    address public indFundDeposit;      // deposit address for Indorse reserve

    bool public isFinalized;                                    // switched to true in operational state
    uint256 public constant decimals = 18;  // #dp in Indorse contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenExchangeRate = 1000;               // 1000 IND tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;    // maximum gas price for contribution transactions
 
    function IndorseSaleContract(   address _ethFundDeposit,
                                    address _indFundDeposit,
                                    address _INDtoken, 
                                    uint256 _fundingStartTime,
                                    uint256 duration    ) { // duration in days
        ethFundDeposit   = _ethFundDeposit;
        indFundDeposit   = _indFundDeposit;
        ind = IndorseToken(_INDtoken);
        fundingStartTime = _fundingStartTime;
        fundingEndTime   = fundingStartTime + duration * 1 days;

        tokenCreationCap = ind.balanceOf(_indFundDeposit);
        isFinalized = false;
    }

    event MintIND(address from, address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);

    function CreateIND(address to, uint256 val) internal returns (bool success){
        MintIND(indFundDeposit,to,val);
        return ind.transferFrom(indFundDeposit,to,val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether and creates new IND tokens.
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
      require (tokenCreationCap > totalSupply);  // CAP reached no more please
      require (now >= fundingStartTime);
      require (now <= fundingEndTime);
      require (_value >= minContribution);         // To avoid spam transactions on the network    
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

      uint256 tokens = safeMult(_value, tokenExchangeRate); // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      require (ind.balanceOf(msg.sender) + tokens <= maxTokens);
      
      // DA 8/6/2017 to fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {        
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreateIND(_beneficiary,tokensToAllocate));            // Create IDR
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
      // DA 8/6/2017 end of fair allocation code

      totalSupply = checkedSupply;
      require(CreateIND(_beneficiary, tokens));  // logs token creation
      ethFundDeposit.transfer(this.balance);
    }
    
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external onlyOwner {
      require (!isFinalized);
      // move to operational
      isFinalized = true;
      ethFundDeposit.transfer(this.balance);                     // send the eth to Indorse multi-sig
    }
}