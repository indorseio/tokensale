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

contract INDvesting {
  mapping (address => uint256) public allocations;
  uint256 public unlockDate;
  address public IND;
  uint256 public constant exponent = 10**18;

  function INDvesting(address _IND) {
    IND = _IND;
    unlockDate = now + 240 days;

    // Advisors
    allocations[0xe8C67375D802c9Ae9583df38492Ff3be49e8Ca89] = 100000;
    allocations[0x3DFb8A970e8d11B4002b2bc98d5a09b09Da3482c] = 100000;
    allocations[0xC865a2220960585A0D365E8D0d7897d4E3547ae6] = 10000;
    allocations[0x0DC77D48f290aCaC0e831c835714Ae45e65Ac3d8] = 150000;
    allocations[0x9628dB0f162665C34BFC0655D55c6B637552B9ec] = 50000;
    allocations[0x89B7c9c2D529284F9E942389D0894EEadF34f037] = 150000;
    allocations[0xee4918fbd8Cd49a46B66488C523c3C24d9426270] = 100000;
    allocations[0xc8A1DAb586DEe8a30Cb88C87b8A3614E0a391fC5] = 100000;
    allocations[0x0ed1374A831744aF48174a890BbA5ac333e76717] = 50000;
    allocations[0x293a0369D58aF2433C3A435A6B5343C5455C4eD4] = 100000;
    allocations[0xf190f0193b694d9d2bb865a66f0c17cbd8280c71] = 50000;
    allocations[0xB0D9693eEC83452BD54FA5E0318850cc1B1a4a19] = 150000;

    // Team
    allocations[0x00e21B56A62ff177331C38A359AE0b316fa432Cc] = 6259469;
    allocations[0xa6565606564282E2E23a86689d43448F6fc3236E] = 6259469;
    allocations[0xFaa2480cbCe8FAa7fb706f0f16C9AB33873A1E38] = 3129734;
    allocations[0x60FA8f4324c8082B6155253C3DFe46728Ef6fa20] = 3129734;
  }

  function unlock() external {
    require (now < unlockDate);
    uint256 entitled = allocations[msg.sender];
    allocations[msg.sender] = 0;
    require(StandardToken(IND).transfer(msg.sender, entitled * exponent));
  }

}
