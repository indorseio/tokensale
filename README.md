# INDORSE TOKENS
=====================================================
You can more info about Indorse at http://indorse.io


TECH DETAILS ABOUT THE SUITE OF INDORSE CONTRACTS
=====================================================

These are the set of Smart Contracts for the token sale of Indorse. 

1. SaleContract

The sale contract launches with the following parameters
* multiSigWallet address
* Address that owns IND tokens to be disbursed
* address of indorseToken contract
* address of SCRToken contract
* Sale start timestamp
* duration in days

During the sale, 1 ether deposited earns 1,000 IDR and 1 SCR. 

* IDR is divisble to 18dp like ether so pro-rata purchases are possible.
* SCR is not divisbile and so are rewarded one per each whole ether deposited.
* The number of IDR tokens for sale is equal to the number of tokens in the IndFund account
* The sale will continue until either the cap or the end time is reached
* If the cap is reached and the final deposit passes the cap, the amount of ether required to reach the cap is retained, the rest returned. Should we not be able to return it, an event will be fired to allow an offline transfer tp be effected.
* There is NO minimum cap.
* All received ether are immediately forwarded to the indorse multisig with the exception of the part of the final deposit that is above the cap.

* Security Concerns*
We must ensure that 
* The final refund amount cannot be manipulated


---
2. IndorseToken.sol

The indorse (IDR) token contract is a standard ERC20 StandardToken contract.

On creation it mints to two addresses
* indFundDeposit   - for sale & allocation
* indFutureDeposit - for future use
* indPresaleDeposit - for presale allocation
* indInflationDeposit - for inflation

After launch the indFundDeposit account is expected to make an allowance of 30,100,000 tokens to the crowdsale contract;

---
3. SCRToken.sol

The SCRToken is an ownable dummy ERC20 token in that the only functions that works are

```
transferFrom(address from, address to, uint value)
```
This function is called with 
* from = 0x0 (Minting)
* to = 0x0 (Burning)

Minting may be called from the sale contract or the indorse framework.

Burning is only allowed from the indorse framework.


```
approve(address _crowdSale, address spender) constant returns (uint) onlyOwner {
```
This is called from the contract owner to set the crowdsale address. spender is ignored.
Throws if wrong sender.

```
totalAllocation
```
indicates number of tokens
