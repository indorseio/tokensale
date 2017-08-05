pragma solidity ^0.4.10;

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/* taking ideas from FirstBlood token */
contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract StandardToken is ERC20, SafeMath {

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4) ;
     _;
  }


  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  returns (bool success){
    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require (paused) ;
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

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
    
    uint256 public constant indFund    = 29 * (10 ** 6) * 10**decimals;   // 30.1 million IND reserved for Indorse use
    uint256 public constant indPreSale =  676 * (10 ** 5) * 10**decimals; // 
    uint256 public constant indFuture  = 642 * (10**5) * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indInflation  = 151 * (10**5) * 10**decimals;  // 69.2 million IND for future token sale
   
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

contract INDvesting {
  mapping (address => uint256) allocations;
  uint256 public unlockDate;
  address public IND;
  address public indPresaleDeposit;
  uint256 public constant exponent = 10**18;

  function INDvesting(address _IND, address _indPresaleDeposit) {
    IND = _IND;
    indPresaleDeposit = _indPresaleDeposit;
    unlockDate = now + 240 days;
    allocations[0x00b92C9d330b1578c226F92cA4A07c267a58b77E] = 16000000;
    allocations[0x0035b1bf7a579a0e9E945Eb476365C42d8Df24E9] = 16000000;
    allocations[0x002a9FA6af0b680358830E0AfF66Ecd16b392137] = 16000000;
    allocations[0x009B891278716d68c68DDAeEed7b0Ab39504F417] = 16000000;
    allocations[0x000eFBCe70A85b1a63C62d26F7d620Fc458Dbc7a] = 8000000;
    allocations[0x00BbCd21da10C0ce9F67A7D4534b25D3602E8Cc0] = 8000000;
    allocations[0x007161DB7cB2E01cB5739b1c27C02486f619b8A9] = 8000000;
    allocations[0xF94BE6b93432b39Bc1637FDD656740758736d935] = 4000000;
  }

  function unlock() external {
    if(now < unlockDate) throw;
    uint256 entitled = allocations[msg.sender];
    allocations[msg.sender] = 0;
    if(!IndorseToken(IND).transferFrom(indPresaleDeposit, msg.sender, entitled * exponent)) throw;
  }

}
