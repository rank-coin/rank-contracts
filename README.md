# RANK Token Smart Contracts

---

**Last updated:** December 16, 2017

---

**Table of Contents**
- [RANK token smart contracts](#rank-token-smart-contracts)
    + [Overview](#overview)
    + [Contracts](#contracts)
      - [Main contracts](#main-contracts)
      - [Auxiliary contracts](#auxiliary-contracts)
      - [Libraries](#libraries)
    + [Schematic representation](#schematic-representation)
    + [Main contracts](#main-contracts-1)
      - [**Token**](#token)
        * [Description](#description)
        * [Variables](#variables)
        * [Events](#events)
        * [Functions](#functions)
        * [Modifiers](#modifiers)
      - [**GEEToken**](#geetoken)
        * [Description](#description-1)
        * [Variables](#variables-1)
        * [Functions](#functions-1)
      - [**GEECrowdsale**](#crowdsale)
        * [Description](#description-2)
        * [Variables](#variables-2)
        * [Events](#events-1)
        * [Functions](#functions-2)
    + [Auxiliary contracts](#auxiliary-contracts-1)
      - [**Ownable**](#ownable)
        * [Description](#description-3)
        * [Variables](#variables-3)
        * [Events](#events-2)
        * [Functions](#functions-3)
        * [Modifiers](#modifiers-1)
      - [**Trustable**](#trustable)
        * [Description](#description-4)
        * [Variables](#variables-4)
        * [Events](#events-3)
        * [Functions](#functions-4)
      - [**Pausable**](#pausable)
        * [Description](#description-5)
        * [Variables](#variables-5)
        * [Events](#events-4)
        * [Functions](#functions-5)
        * [Modifiers](#modifiers-2)
      - [**MigratableToken**](#migratabletoken)
        * [Description](#description-6)
        * [Variables](#variables-6)
        * [Enums](#enums)
        * [Events](#events-5)
        * [Functions](#functions-6)
    + [Libraries](#libraries-1)
      - [**SafeMath**](#safemath)
        * [Description](#description-7)
        * [Functions](#functions-7)
        
---

## Overview
RANK token system consists of multiple smart contracts written in Solidity programming language. This system allows issuing a standards-compliant custom token on the Ethereum network. This documentation explains the purpose and the realisation (including technical details) of each of these contracts.

These contracts were thoroughly tested and all parts were double checked many times. If you are a 'smart contracts' developer and see how these contracts can be optimized even better and made more efficient, please contact us.

During the following days, these contracts will continue to be updated. Before launching them on the main Ethereum network, the block numbers and hard-coded addresses will be modified.

The RANK Token sale will start on February 2, 2018. More details: http://rankcoin.name/how-to-buy-rank-tokens/

---

## Contracts

### Main contracts
* Token
* RANKToken
* RANKCrowdsale

### Auxiliary contracts
* Ownable
* Trustable
* Pausable
* MigratableToken

### Libraries
* SafeMath

## Main contracts


### Token

#### **Description**
This contract defines a standard ERC20 token with some extra functionalities. The contract does not contain 'self-destruct' function, so it has no expiration time.

#### **Variables**
```javascript
uint256 _totalSupply = 100 * (10**6) * (10**8);
```
Total supply of tokens is 100 million.
<br>
<br>
```javascript
 uint256 public crowdsaleEndBlock = 4795000;
```
A block number that indicates when the Crowdsale ends.
<br>
<br>
```javascript
uint256 public constant MAX_END_BLOCK_NUMBER = 4891000;
```
A block number that indicates the max possible end block number.
<br>
<br>
```javascript
mapping (address => uint256) balances;
```
An array that saves balances of the users.
<br>
<br>
```javascript
mapping (address => mapping (address => uint256)) allowed;
```
A mapping that saves allowances of the users. For example, user A has approved user B to transfer from him X tokens.
<br>
<br>
#### **Events**
```javascript
event Burn(address indexed _from, uint256 _value);
```
The event that is triggered when tokens are burned. The indexed parameters allow filtering events by specific addresses.
<br>
<br>
```javascript
event CrowdsaleEndChanged (uint256 _crowdsaleEnd, uint256 _newCrowdsaleEnd);
```
The event that is triggered when crowdsale end block has been changed. 
<br>
<br>
```javascript
    function totalSupply() external constant returns (uint256 totalTokenSupply) {
        totalTokenSupply = _totalSupply;
    }
 ```
 A function that return total supply of the token.
<br>
<br>
#### **Functions** 
```javascript
function transfer(address _to, uint256 _amount)
    external
    notZeroAddress(_to)
    whenNotPaused
    canTransferOnCrowdsale(msg.sender)
    returns (bool success)
{
    balances[msg.sender] = balances[msg.sender].SUB(_amount);
    balances[_to] = balances[_to].ADD(_amount);
    Transfer(msg.sender, _to, _amount);
    return true;
}
```
A function that allows transferring tokens to a specified address. During the Crowdsale only trusted address can call this function.
<br>
<br>
```javascript
function transferFrom(address _from, address _to, uint256 _amount)
    external
    notZeroAddress(_to)
    whenNotPaused
    canTransferOnCrowdsale(msg.sender)
    canTransferOnCrowdsale(_from)
    returns (bool success)
{
    //Require allowance to be not too big
    require(allowed[_from][msg.sender] >= _amount);
    balances[_from] = balances[_from].SUB(_amount);
    balances[_to] = balances[_to].ADD(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].SUB(_amount);
    Transfer(_from, _to, _amount);
    return true;
}
```
A function that allows transferring tokens from one address to another. During the Crowdsale only trusted address can call this function.
<br>
<br>
```javascript
function approve(address _spender, uint256 _amount)
    external
    whenNotPaused
    notZeroAddress(_spender)
    returns (bool success)
{
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
}
```
Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
<br>
<br>
```javascript
function allowance(address _owner, address _spender)
    external
    constant
    returns (uint256 remaining)
{
    return allowed[_owner][_spender];
}
```
Function to check the amount of tokens that an owner allowed to a spender.
<br>
<br>
```javascript
function increaseApproval(address _spender, uint256 _addedValue)
    external
    whenNotPaused
    returns (bool success)
{
    uint256 increased = allowed[msg.sender][_spender].ADD(_addedValue);
    require(increased <= balances[msg.sender]);
    //Cannot approve more coins then you have
    allowed[msg.sender][_spender] = increased;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
}
```
To increment allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined).
<br>
<br>
```javascript
function decreaseApproval(address _spender, uint256 _subtractedValue)
    external
    whenNotPaused
    returns (bool success)
{
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
    } else {
        allowed[msg.sender][_spender] = oldValue.SUB(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
}
```
To decrease allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined).
<br>
<br>
```javascript
    function burn(uint256 _value) external returns (bool success) {
        require(trusted[msg.sender]);
        //Subtract from the sender
        balances[msg.sender] = balances[msg.sender].SUB(_value);
        //Update _totalSupply
        _totalSupply = _totalSupply.SUB(_value);
        Burn(msg.sender, _value);
        return true;
    }
```
Allows trusted address burning a specific amount of his tokens. This function is intended to be called after the Crowdsale to burn the unsold tokens.
<br>
<br>
```javascript
    function updateCrowdsaleEndBlock (uint256 _crowdsaleEndBlock) external onlyOwner {

        require(block.number <= crowdsaleEndBlock);                 //Crowdsale must be active
        require(_crowdsaleEndBlock >= block.number);
        require(_crowdsaleEndBlock <= crowdsaleMaxEndBlock);        //Transfers can only be unlocked earlier

        uint256 currentEndBlockNumber = crowdsaleEndBlock;
        crowdsaleEndBlock = _crowdsaleEndBlock;
        CrowdsaleEndChanged (currentEndBlockNumber, _crowdsaleEndBlock);
    }
```
Allows owner setting the new end block number to extend/close Crowdsale.
<br>
<br>
```javascript
function transferOwnership(address _newOwner) public afterCrowdsale  {
    super.transferOwnership(_newOwner);
}
```
This function prohibits transferring the ownership when the Crowdsale is active.
<br>
<br>
```javascript
function pause() public afterCrowdsale  {
    super.pause();
}
```
This function prohibits pausing the contract when the Crowdsale is active.
<br>
<br>
#### **Modifiers**
```javascript
modifier canTransferOnCrowdsale (address _address) {
    if (block.number <= crowdsaleEndBlock) {
        //Require the end of funding or msg.sender to be trusted
        require(trusted[_address]);
    }
    _;
}
```
Only trusted addresses can call functions that are marked with this modifier.
<br>
<br>
```javascript
modifier afterCrowdsale {
    require(block.number > crowdsaleEndBlock);
    _;
}
```
Some functions may only be executed when the Crowdsale is over.
<br>
<br>

---

### RANKToken

#### **Description**
A contract that defines the essential information of the token and allocates a specified amount of tokens to the team.
<br>
<br>
#### **Variables**
```javascript
string public constant name = "Ranks Platform Token";
```
Name of the token is Ranks Platform Token. It cannot be changed later.
<br>
<br>
```javascript
string public constant symbol = "RANK";
```
Symbol of the token is RANK. It cannot be changed later.
<br>
<br>
```javascript
uint8 public constant decimals = 18;
```
Token has 18 decimal places. It cannot be changed later.
<br>
<br>
```javascript
address public constant TEAM0 = 0x6e5d4a29833e51a83539a57461e803bcff409050;
```
The zero address of the team that receives 2.4% of tokens.
<br>
<br>
```javascript
address public constant TEAM1 = 0xb22347E0Ee848aB56d8cCDf58F97fB0D0Ec272eA;
```
The first address of the team that receives 3.6% of tokens that can only be spent after the half of the year.
<br>
<br>
```javascript
address public constant TEAM2 = 0x5750885e96a6728639c93433BceA2c5b4519F462;
```
Second address of the team that receives 6% of tokens that can only be spent after the year.
<br>
<br>
```javascript
address public constant COMMUNITY = 0x24B738698EC3bccadb61Dc74b8DFb23a712074b0;
```
Community address receives 21% of tokens.
<br>
<br>
```javascript
 uint256 public constant UNLOCK_TEAM_1 = 1528372800;
```
A timestamp when the first team wallet's tokens are unlocked.
<br>
<br>
```javascript
 uint256 public constant UNLOCK_TEAM_2 = 1544184000;
```
A timestamp when the second team wallet's tokens are unlocked.
<br>
<br>
```javascript
uint256 public team1Balance;
```
Indicates how many tokens a first wallet of the team has.
<br>
<br>
```javascript
uint256 public team2Balance;
```
Indicates how many tokens a second wallet of the team has.
<br>
<br>
```javascript
uint256 private constant TEAM0_THOUSANDTH = 24;
```
2.4%
<br>
<br>
```javascript
uint256 private constant TEAM1_THOUSANDTH = 36;
```
3.6%
<br>
<br>
```javascript
uint256 private constant TEAM1_THOUSANDTH = 36;
```
6%
<br>
<br>
```javascript
    uint256 private constant ICO_THOUSANDTH = 670;
```
67%
<br>
<br>
```javascript
    uint256 private constant COMMUNITY_THOUSANDTH = 210;
```
21%
<br>
<br>
```javascript
uint256 private constant DENOMINATOR = 1000;
```
100%
<br>
<br>

#### **Functions**
```javascript
    function RANKToken() {
        //88% of _totalSupply
        balances[msg.sender] = _totalSupply * ICO_THOUSANDTH / DENOMINATOR;
        //2.4% of _totalSupply
        balances[TEAM0] = _totalSupply * TEAM0_THOUSANDTH / DENOMINATOR;
        //3.6% of _totalSupply
        team1Balance = _totalSupply * TEAM1_THOUSANDTH / DENOMINATOR;
        //6% of _totalSupply
        team2Balance = _totalSupply * TEAM2_THOUSANDTH / DENOMINATOR;
        //21% of _totalSupply
        balances[COMMUNITY] =  _totalSupply * COMMUNITY_THOUSANDTH / DENOMINATOR;

        Transfer (this, msg.sender, balances[msg.sender]);
        Transfer (this, TEAM0, balances[TEAM0]);
        Transfer (this, COMMUNITY, balances[COMMUNITY]);

    }
```
Upon creation of the contract, 88% of tokens are allocated to the owner of the contract, 3.6% to the first team wallet and 6% to the second team wallet.
<br>
<br>
```javascript
    function unlockTeamTokens(address _address) external onlyOwner {
        if (_address == TEAM1) {
            require(UNLOCK_TEAM_1 <= now);
            require (team1Balance > 0);
            balances[TEAM1] = team1Balance;
            team1Balance = 0;
            Transfer (this, TEAM1, balances[TEAM1]);
        } else if (_address == TEAM2) {
            require(UNLOCK_TEAM_2 <= now);
            require (team2Balance > 0);
            balances[TEAM2] = team2Balance;
            team2Balance = 0;
            Transfer (this, TEAM2, balances[TEAM2]);
        }
    }

```
A function that allows an owner of the contract unlocking tokens for the team wallet when specified block number is reached. Tokens are transferred to a specified wallet.
<br>
<br>

---

### RANKCrowdsale

#### **Description**
A contract that is responsible for handling the Crowdsale operations. It accepts Ether from contributors and issues the corresponding number of tokens.
<br>
<br>
#### **Variables**
```javascript
uint256 public soldTokens;
```
Counts how many tokens are sold.
<br>
<br>
```javascript
uint256 public hardCapInTokens = 67 * (10**6) * (10**8);
```
Hard Cap of the Crowdsale is 67 million (67% of total amount of tokens). This is the maximum amount of tokens that could be issued.
<br>
<br>
```javascript
uint256 public constant MIN_ETHER = 0.03 ether;
```
A minimum contribution in Ether.
<br>
<br>
```javascript
uint256 public constant MAX_ETHER = 1000 ether;
```
A maximum contribution in Ether.
<br>
<br>
```javascript
address fund = 0x24B738698EC3bccadb61Dc74b8DFb23a712074b0;
```
An address where the received Ether is forwarded.
<br>
<br>
```javascript
uint256 public constant DAY = 5082;
```
Indicates how many blocks are mined per day.
<br>
<br>
```javascript
uint256 public constant START_BLOCK_NUMBER = 4625526;
```
A number of the block when the Crowdsale should start.
<br>
<br>
```javascript
uint256 public TIER2 = 4725700;
```
A number of the block when the tier2Price price should be active.
<br>
<br>
```javascript
uint256 public TIER3 = 4769600;
```
A number of the block when the tier3Price price should be active.
<br>
<br>
```javascript
uint256 public TIER4 = 4742300;
```
A number of the block when the tier4Price price should be active.
<br>
<br>
```javascript
uint256 public endBlockNumber = 4795000;
```
A number of the block when the Crowdsale should end.
<br>
<br>
```javascript
uint256 public constant MAX_END_BLOCK_NUMBER = 4891000;
```
A max number of the block the Crowdsale can end.
<br>
<br>
```javascript
uint256 public price;
```
A price (in Wei) of one token.
<br>
<br>
```javascript
uint256 public constant TIER1_PRICE = 6000000;
```
A price (in Wei) of one token (when tier1 is active).
<br>
<br>
```javascript
uint256 public constant TIER2_PRICE = 6700000;
```
A price (in Wei) of one token (when tier2 is active).
<br>
<br>
```javascript
uint256 public constant TIER3_PRICE = 7400000;
```
A price (in Wei) of one token (when tier3 is active).
<br>
<br>
```javascript
uint256 public constant TIER4_PRICE = 8200000;
```
A price (in Wei) of one token (when tier4 is active).
<br>
<br>
```javascript
Token public rank;
```
Reference to the Token contract.
<br>
<br>
```javascript
uint256 public constant SOFT_CAP_IN_ETHER = 6000 ether;
```
Soft Cap of the Crowdsale is 6000 Ether. If the soft cap is not reached, contributors will be able to refund their Ether.
<br>
<br>
```javascript
mapping (address => uint256) public bought;
```
Indicates how many Ether has each contributor sent to this contract.
<br>
<br>
```javascript
uint256 public collected;
```
The total amount of Ether collected during the Crowdsale.
<br>
<br>
```javascript
uint256 public constant RANK100 = 100 * (10**8);
```
A constant corresponding to 100 RANK tokens.
<br>
<br>

#### **Events**
```javascript
event Buy (address indexed _who, uint256 _amount, uint256 indexed _price);
```
An event that is triggered when someone buys RANK tokens.
<br>
<br>
```javascript
event Refund (address indexed _who, uint256 _amount);
```
An event that is triggered when contributor refunds his Ether.
<br>
<br>
```javascript
event CrowdsaleEndChanged (uint256 _crowdsaleEnd, uint256 _newCrowdsaleEnd);
```
The event that is triggered when crowdsale end block has been changed. 
<br>
<br>

#### **Functions**
```javascript
function RANKCrowdsale(Token _rankToken)
    notZeroAddress(_rankToken)
    payable
{
    rank = _rankToken;
}
```
Before deploying this contract, Token contract must already be deployed. After the Crowdsale, owner can send back Ether if a refund is needed.
<br>
<br>
```javascript
function() external payable {
        if (isCrowdsaleActive()) {
            buy();
        } else { //after crowdsale owner can send back eth for refund
            require (msg.sender == fund || msg.sender == owner);
        }
}
```
A Fallback function that is called when someone sends Ether to the contract.
<br>
<br>
```javascript
function finalize() external  onlyOwner{
        require(soldTokens != hardCapInTokens);
        if (soldTokens < (hardCapInTokens - RANK100)) {
            require(block.number > endBlockNumber);
        }
        rank.burn(hardCapInTokens.SUB(soldTokens));
        hardCapInTokens = soldTokens;
    }
```
If the Crowdsale ends and the hard cap is not reached, this functions burns the unsold tokens.
<br>
<br>
```javascript
    function buy()
    public
    payable
    {
        uint256 amountWei = msg.value;
        uint256 blocks = block.number;

        require (isCrowdsaleActive());

        
        //Ether limitation
        require(amountWei >= MIN_ETHER);
        require(amountWei <= MAX_ETHER);

        price = getPrice();
        //Count how many RANK sender can buy
        uint256 amount = amountWei / price;
        //Add amount to soldTokens
        soldTokens = soldTokens.ADD(amount);

        require(soldTokens <= hardCapInTokens);

        if (soldTokens >= (hardCapInTokens - RANK100)) {
            endBlockNumber = blocks;
        }

        //counts ETH
        collected = collected.ADD(amountWei);
        bought[msg.sender] = bought[msg.sender].ADD(amountWei);

        //Transfer amount of Gee coins to msg.sender
        gee.transfer(msg.sender, amount);

        //Transfer contract Ether to fund
        fund.transfer(this.balance);

        Buy(msg.sender, amount, price);
    }

```
A function responsible for issuing tokens for a contributor. The minimum amount of Ether is 0.03, maximum - 1000. A number of tokens that user can buy are calculated and transferred to his account. Collected Ether is forwarded to a specified funds address. Finally, Buy event is invoked.
<br>
<br>
```javascript
function isCrowdsaleActive() public constant returns (bool) {

        if (endBlockNumber < block.number || START_BLOCK_NUMBER > block.number){
            return false;
        }
        return true;
    }

```
A function that returns whether the Crowdsale is active or not. The possible cases when the Crowdsale is not active are:
a) Crowdsale is already finished
b) Crowdsale hasn't started
c) Crowdsale has been stopped due to emergency situation
<br>
<br>
```javascript
function getPrice()
    internal
    constant
    returns (uint256)
    {
     if (block.number < TIER2) {
        return TIER1_PRICE;
    } else if (block.number < TIER3) {
        return TIER2_PRICE;
    } else if (block.number < TIER4) {
        return TIER3_PRICE;
    }
        
    return TIER4_PRICE;
}
```
Calculates which tier is currently active and returns the corresponding price.
<br>
<br>
```javascript
    function setEndBlockNumber(uint256 _newEndBlockNumber) external onlyOwner {
        require(isCrowdsaleActive());
        require(_newEndBlockNumber >= block.number);
        require(_newEndBlockNumber <= maxEndBlockNumber);

        uint256 currentEndBlockNumber = endBlockNumber;
        endBlockNumber = _newEndBlockNumber;
        CrowdsaleEndChanged (currentEndBlockNumber, _newEndBlockNumber);
    }
```
Allows owner setting the new end block number to extend/close Crowdsale.
<br>
<br>
```javascript
function refund() external
    {
        uint256 refund = bought[msg.sender];
        require (!isCrowdsaleActive());
        require (collected < SOFT_CAP_IN_ETHER);
        bought[msg.sender] = 0;
        msg.sender.transfer(refund);
        Refund(msg.sender, refund);
    }
```
A function that allows contributors receive their contributions back in case a soft cap is not reached or the Crowdsale was stopped due to an emergency situation.
<br>
<br>
```javascript
    function drainEther() external onlyOwner {
        fund.transfer(this.balance);
    }
```
A function that allows owner to drain Ether from contract to a specified funds address.
<br>
<br>

---

## Auxiliary contracts

### Ownable

#### **Description**
The Ownable contract has an owner address and provides basic authorization control functions, this simplifies the implementation of "user permissions".
Essentially, it is responsible for detecting and storing an address of its creator and preventing other addresses from executing certain functions. Any contract which inherits Ownable will have owner set to the caller at the time of its creation, and any of its functions implementing onlyOwner modifier will not accept calls from another account.
<br>
<br>
#### **Variables**
```javascript
address owner;
```
It is a 20-byte number (Ethereum address) representing the owner of the contract.
<br>
<br>
#### **Events**
```javascript
event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
```
The event that is triggered when a new owner is assigned to the contract. The indexed parameters allow filtering events by specific addresses.
<br>
<br>
#### **Functions**
```javascript
    function Ownable() {
        owner = msg.sender;
        OwnershipTransferred (address(0), owner);
    }
```
A constructor that is called upon creation of the contract. It assigns the ownership of this contract to the creator.
<br>
<br>
```javascript
    function transferOwnership(address _newOwner)
        public
        onlyOwner
        notZeroAddress(_newOwner)
    {
        owner = _newOwner;
        OwnershipTransferred(msg.sender, _newOwner);
    }
```
A function that allows current owner of the contract transferring the ownership to another address.
<br>
<br>
#### **Modifiers**
```javascript
modifier onlyOwner {
    require(msg.sender == owner);
    _;
}
```
A modifier that checks that the caller is an owner of the contract. This prevents other users from calling the function that should only be accessible to admin.
Only the owner of the contract can call a function that has this modifier. If this requirement is not met, the function will not get executed.
<br>
<br>
```javascript
modifier notZeroAddress(address _address) {
    require(_address != address(0));
    _;
}
```
A modifier that checks that the parameter of type address is not zero (0x0). This prevents from passing an invalid address to the functions.
<br>
<br>

---

### Trustable

#### **Description**
A contract that is responsible for storing addresses that are considered safe. These addresses are able to call certain functions that are otherwise is not available for a typical user. For example, to prevent from fraud, token transfers are locked during the Crowdsale. However, trusted addresses can transfer tokens even when the Crowdsale is ongoing.

#### **Variables**
```javascript
mapping (address => bool) trusted;
```
An array that indicates whether an address is privileged to call certain functions.
<br>
<br>
#### **Events**
```javascript
       event AddTrusted (address indexed _trustable);
```
The event that is triggered when a new trusted address is assigned. The indexed parameters allow filtering events by specific addresses.
```javascript
       event RemoveTrusted (address indexed _trustable);
```
The event that is triggered when a trusted address is unassigned. The indexed parameters allow filtering events by specific addresses.
<br>
<br>
#### **Functions**
```javascript
function Trustable() {
    trusted[msg.sender] = true;
    AddTrusted(msg.sender);
}
```
The creator of the contract is initially added to the trusted addresses list.
<br>
<br>
```javascript
function addTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
{
        trusted[_address] = true;
        AddTrusted(_address);
}
```
A function that allows the owner of the contract adding an address to the list of trusted addresses.
<br>
<br>
```javascript
function removeTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
{
        trusted[_address] = false;
        RemoveTrusted(_address);
}
```
A function that allows the owner of the contract removing an address from the list of trusted addresses.
<br>
<br>

---

### Pausable

#### **Description**
This contract allows pausing the contract in case of emergency situation. It also allows prohibiting certain functions from being executed when the contract is paused.

#### **Variables**
```javascript
bool public paused;
```
Indicates whether the contract is paused or not.
<br>
<br>
```javascript
uint256 public pauseBlockNumber;
```
Block number indicating when the contract was paused. Upon creation of the contract, its value is 0.
<br>
<br>
```javascript
uint256 public resumeBlockNumber;
```
Block number indicating when the contract was resumed. Upon creation of the contract, its value is 0.
<br>
<br>
#### **Events**
```javascript
event Pause(uint256 _blockNumber);
```
The event that is triggered when the contract is paused. It displays the block number indicating when this happened.
<br>
<br>
```javascript
event Unpause(uint256 _blockNumber);
```
The event that is triggered when the contract is unpaused. It displays the block number indicating when this happened.
<br>
<br>
#### **Functions**
```javascript
    function pause()
        public
        onlyOwner
        whenNotPaused
    {
        paused = true;
        pauseBlockNumber = block.number;
        resumeBlockNumber = 0;
        Pause(pauseBlockNumber);
    }

```
This function sets the variable "paused" to be true. The contract goes into the paused state.
<br>
<br>
```javascript
function unpause()
        public
        onlyOwner
        whenPaused
    {
        paused = false;
        resumeBlockNumber = block.number;
        pauseBlockNumber = 0;
        Unpause(resumeBlockNumber);
    }

```
This function sets the variable "paused" to be false. The contract reverts into the normal state.
<br>
<br>
#### **Modifiers**
```javascript
modifier whenNotPaused {
    require(!paused);
    _;
}
```
A modifier that checks if the contract is paused or not. If it is paused, the further execution of the function is not possible and the whole transaction is reverted.
<br>
<br>

```javascript
modifier whenPaused {
    require(paused);
    _;
}
```
A modifier that checks if the contract is paused or not. If it is not paused, the further execution of the function is not possible and the whole transaction is reverted.
<br>
<br>

---

### MigratableToken

#### **Description**
A contract that allows upgrading the token and migrate the balances from old contract to the new one.

#### **Variables**
```javascript
MigrateAgent public migrateAgent;
```
The new Token contract.
```javascript
uint256 public totalMigrated;
```
Indicates how many tokens are migrated so far.
v
#### **Enums**
```javascript
enum MigrateState {Unknown, NotAllowed, WaitingForAgent, ReadyToMigrate, Migrating}
```
List of states of the migration.
<br>
<br>
#### **Events**
```javascript
event Migrate (address indexed _from, address indexed _to, uint256 _value);
```
An event that is triggered when the tokens are migrated to the new contract.
<br>
<br>
```javascript
event MigrateAgentSet (address _agent);
```
An event that is triggered when the new migrate agent is set.
<br>
<br>
#### **Functions**
```javascript
function migrate(uint256 _value) external {
    MigrateState state = getMigrateState();
    //Migrating has started
    require(state == MigrateState.ReadyToMigrate || state == MigrateState.Migrating);
    //Migrates user balance
    balances[msg.sender] = balances[msg.sender].SUB(_value);
    //Migrates total supply
    _totalSupply = _totalSupply.SUB(_value);
    //Counts migrated tokens
    totalMigrated = totalMigrated.ADD(_value);
    //Upgrade agent reissues the tokens
    migrateAgent.migrateFrom(msg.sender, _value);
    Migrate(msg.sender, migrateAgent, _value);
}
```
If migration is enabled, transfer the balance from the old contract to the new one.
<br>
<br>
```javascript
 function setMigrateAgent(MigrateAgent _agent)
        external
        onlyOwner
        notZeroAddress(_agent)
        afterCrowdsale
    {
        //cannot interrupt migrating
        require(getMigrateState() != MigrateState.Migrating);
        //set migrate agent
        migrateAgent = _agent;
        //Emit event
        MigrateAgentSet(migrateAgent);
    }
```
Set a reference to the new Token. This is only possible when the migration has not already been started.
<br>
<br>
```javascript
function getMigrateState() public constant returns (MigrateState) {
    if (block.number <= crowdsaleEndBlock) {
        //Migration is not allowed on funding
        return MigrateState.NotAllowed;
    } else if (address(migrateAgent) == address(0)) {
        //Migrating address is not set
        return MigrateState.WaitingForAgent;
    } else if (totalMigrated == 0) {
        //Migrating hasn't started yet
        return MigrateState.ReadyToMigrate;
    } else {
        //Migrating
        return MigrateState.Migrating;
    }
}
```
Returns the current state of the Migration contract.
<br>
<br>

---

## Libraries

### SafeMath

#### **Description**
A contract that provides basic Math operations with safety checks that throw on error. This library is used instead of standard arithmetic operations to avoid integer overflows/underflows. Generally, an overflow happens when the limit of the type variable uint256 is exceeded. What happens is that the value resets to zero instead of incrementing more. An underflow happens when you try to subtract x minus a number bigger than x. For example, if you subtract 1-2 the result will be = 2^256 instead of -1. Note: this library provides safe addition, subtraction and multiplication. A safe division is not necessary, as all cases are already handled by Solidity and if overflow/underflow occurs, a Runtime Error is thrown.
<br>
<br>
#### **Functions**
```javascript
function ADD (uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
}
```
This function returns the sum of a and b. It checks that the result is not lower than the first parameter. If "assert" fails, all the gas provided is consumed.
<br>
<br>
```javascript
function SUB (uint256 a, uint256 b) internal returns (uint256)  {
    assert(a >= b);
    return a - b;
}
```
This function returns the difference between a and b. It checks that a is not lower than b. If "assert" fails, all the gas provided is consumed.
<br>
<br>

---

The RANK Token sale will start on February 2, 2018. More details: http://rankcoin.name/how-to-buy-rank-tokens/
