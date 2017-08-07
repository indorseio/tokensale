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

contract INDFutureVesting {
  mapping (address => uint256) allocations;
  uint256 public unlockDate1;
  uint256 public unlockDate2;
  uint256 public entitled;
  address public IND;
  uint256 public constant exponent = 10**18;

  function INDFutureVesting(address _IND) {
    IND = _IND;
    unlockDate1 = now + 540 days;
    unlockDate2 = now + 720 days;

    // Advisors
    allocations[0xe8C67375D802c9Ae9583df38492Ff3be49e8Ca89] = 29309747;
    allocations[0x3DFb8A970e8d11B4002b2bc98d5a09b09Da3482c] = 29309747;
  }

  function unlock() external {
    if (msg.sender == 0xe8C67375D802c9Ae9583df38492Ff3be49e8Ca89){
      require (now < unlockDate1);
      entitled = allocations[msg.sender];
      allocations[msg.sender] = 0;
      require(StandardToken(IND).transfer(msg.sender, entitled * exponent));
    } 
    if (msg.sender == 0x3DFb8A970e8d11B4002b2bc98d5a09b09Da3482c){
      require (now < unlockDate2);
      entitled = allocations[msg.sender];
      allocations[msg.sender] = 0;
      require(StandardToken(IND).transfer(msg.sender, entitled * exponent));
    }
    throw;
  }
}
