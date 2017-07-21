pragma solidity ^0.4.11;

// for test
import "./IndorseToken.sol";
import "./SCRtoken.sol";


import "./SafeMath.sol";
import "./Ownable.sol";

contract mockToken {
    uint256 public indFund;

    function balanceOf(address who) constant returns (uint256);

    function transferFrom(address _from, address _to, uint _value) returns (bool success);
}



contract IndorseSaleContract is  Ownable,SafeMath {

    event badCreateSCR(address _beneficiary,uint256 tokens);

    address SCRtoken;
    address INDtoken;

    // crowdsale parameters
    bool    public isFinalized;              // switched to true in operational state
    uint256 public fundingStartTime;
    uint256 public fundingEndTime;
    uint256 public totalSupply;
    address public ethFundDeposit;      // deposit address for ETH for Indorse Fund
    address public indFundDeposit;      // deposit address for Indorse reserve


    uint256 public constant decimals = 18;  // #dp in Indorse contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenCreationMin = 1 * (10**6) * 10**decimals; // 1,000,000 tokens minimum
    uint256 public constant tokenExchangeRate = 1000;               // 1000 IND tokens per 1 ETH
 
 
    mapping (address => uint256) deposits;

    event LogRefund(address indexed _to, uint256 _value);

    function IndorseSaleContract(   address _ethFundDeposit,
                                    address  _indFundDeposit,
                                    address _INDtoken, 
                                    address _SCRtoken,
                                    uint256 _fundingStartTime,
                                    uint256 duration    ) { // duration in days
        ethFundDeposit   = _ethFundDeposit;
        indFundDeposit   = _indFundDeposit;
        SCRtoken = _SCRtoken;
        INDtoken = _INDtoken;
        fundingStartTime = _fundingStartTime;
        fundingEndTime   = fundingStartTime + duration * 1 days;

        mockToken tok = mockToken(INDtoken);
        tokenCreationCap = tok.balanceOf(_indFundDeposit);
    }

    event MintIND(address from, address to, uint256 val);

    function CreateIND(address to, uint256 val) internal returns (bool success){
        MintIND(indFundDeposit,to,val);
        mockToken ind = mockToken(INDtoken);
        return ind.transferFrom(indFundDeposit,to,val);
    }

    function CreateSCR(address to, uint256 val) internal returns (bool success){
        mockToken scr = mockToken(SCRtoken);
        return scr.transferFrom(0x0,to,val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

/// @dev Accepts ether and creates new IND tokens.
    function createTokens(address _beneficiary, uint256 _value) internal {
      require (!isFinalized);
      require (now >= fundingStartTime);
      require (now <= fundingEndTime);
      require (_value > 0);

      uint256 tokens = safeMult(_value, tokenExchangeRate); // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);
      
      // DA 8/6/2017 to fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {
        require (tokenCreationCap > totalSupply);  // CAP reached no more please
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreateIND(_beneficiary,tokensToAllocate));            // Create IDR
        if (!CreateSCR(_beneficiary,tokensToAllocate / 1 ether)) {
            badCreateSCR(_beneficiary,tokensToAllocate / 1 ether);
        }
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
      // DA 8/6/2017 end of fair allocation code

      totalSupply = checkedSupply;
      deposits[_beneficiary] = safeAdd(deposits[_beneficiary],_value);
      require(CreateIND(_beneficiary, tokens));  // logs token creation
      if (!CreateSCR(_beneficiary, tokens / 1 ether)) {
          badCreateSCR(_beneficiary,tokens / 1 ether);
      }
      if (totalSupply > tokenCreationMin) {
          ethFundDeposit.transfer(this.balance);
      }
    }


    /// @dev Ends the funding period and sends the ETH home
    function finalize() external {
      require (!isFinalized) ;
      require (msg.sender == ethFundDeposit) ; // locks finalize to the ultimate ETH owner
      // if(totalSupply < tokenCreationMin) throw;      // have to sell minimum to move to operational
      require (now > fundingEndTime || totalSupply == tokenCreationCap) ;
      // move to operational
      isFinalized = true;
      ethFundDeposit.transfer(this.balance);  // send the eth to Indorse
    }

    // Might not need this if we hit the pre-sale cap 

    /// @dev Allows contributors to recover their ether in the case of a failed funding campaign.
    function refund() external {
      require(!isFinalized);                       // prevents refund if operational
      require (now > fundingEndTime); // prevents refund until sale period is over
      require(totalSupply < tokenCreationMin);  // no refunds if we sold enough
      require(deposits[msg.sender] > 0);    // Brave Intl not entitled to a refund
      uint256 refund = deposits[msg.sender];
      deposits[msg.sender] = 0;
      LogRefund(msg.sender, refund);               // log it 
      msg.sender.transfer(refund); 
    }




}