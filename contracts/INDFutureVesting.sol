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
    address public indSaleDeposit;      // deposit address for Indorse reserve
    address public indSeedDeposit;    // deposit address for Indorse Future reserve
    address public indPresaleDeposit;   // deposit address for Indorse Future reserve
    address public indVestingDeposit; // deposit address for Indorse Inflation pool
    address public indCommunityDeposit; // deposit address for Indorse Inflation pool
    address public indFutureDeposit; // deposit address for Indorse Inflation pool
    address public indInflationDeposit; // deposit address for Indorse Inflation pool
    
    uint256 public constant indSale = 31603785 * 10**decimals;   // 29 million IND reserved for Indorse use
    uint256 public constant indSeed = 3842011 * 10**decimals; // 
    uint256 public constant indPreSale = 22995270 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indVesting  = 28079514 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indCommunity  = 10919811 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indFuture  = 58556909 * 10**decimals;  // 69.2 million IND for future token sale
    uint256 public constant indInflation  = 14624747 * 10**decimals;  // 69.2 million IND for future token sale
   
    // constructor
    function IndorseToken(
        address _indSaleDeposit,
        address _indSeedDeposit,
        address _indPresaleDeposit,
        address _indVestingDeposit,
        address _indCommunityDeposit,
        address _indFutureDeposit,
        address _indInflationDeposit
        )
    {
      indSaleDeposit = _indSaleDeposit;
      indSeedDeposit = _indSeedDeposit;
      indPresaleDeposit = _indPresaleDeposit;
      indVestingDeposit = _indVestingDeposit;
      indCommunityDeposit = _indCommunityDeposit;
      indFutureDeposit = _indFutureDeposit;
      indInflationDeposit = _indInflationDeposit;
      
      balances[indSaleDeposit]    = indSale;    // Deposit IND share
      balances[indSeedDeposit]  = indSeed;  // Deposit IND share
      balances[indPresaleDeposit] = indPreSale;    // Deposit IND future share
      balances[indVestingDeposit] = indVesting;    // Deposit IND future share
      balances[indCommunityDeposit] = indCommunity;    // Deposit IND future share
      balances[indFutureDeposit] = indFuture;    // Deposit IND future share
      balances[indInflationDeposit] = indInflation; // Deposit for inflation

      totalSupply = indSale + indSeed + indPreSale + indVesting + indCommunity + indFuture + indInflation;

      Transfer(0x0,indSaleDeposit,indSale);
      Transfer(0x0,indSeedDeposit,indSeed);
      Transfer(0x0,indPresaleDeposit,indPreSale);
      Transfer(0x0,indVestingDeposit,indVesting);
      Transfer(0x0,indCommunityDeposit,indCommunity);
      Transfer(0x0,indFutureDeposit,indFuture);
      Transfer(0x0,indInflationDeposit,indInflation);
   }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}

contract INDFutureVesting {
  mapping (address => uint256) public allocations;
  uint256 public unlockDate;
  uint256 public entitled;
  address public IND;
  uint256 public constant exponent = 10**18;

  function INDFutureVesting(address _IND) {
    IND = _IND;
    unlockDate = now + 540 days;
    
    // Advisors
    allocations[0x00BbCd21da10C0ce9F67A7D4534b25D3602E8Cc0] = 58556909;
  }

  function unlock() external {
    require (now > unlockDate);
    entitled = allocations[msg.sender];
    allocations[msg.sender] = 0;
    require(IndorseToken(IND).transfer(msg.sender, entitled * exponent));
  }
}
