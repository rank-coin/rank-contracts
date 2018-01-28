pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./SafeMath.sol";


/*	Interface of RankToken contract */
contract Token {

    function transfer(address _to, uint256 _value) 
        external;

    function burn(uint256 _value) 
        external;

}


contract RankCrowdsale is Ownable {

    using SafeMath for uint256;

    //VARIABLE
    uint256 public soldTokens;                                  //Counts how many Rank coins are soldTokens
    
    uint256 public hardCapInTokens = 67 * (10**6) * (10**8);    //Hard cap in Rank coins (with 8 decimals)
    
    uint256 public constant MIN_ETHER = 0.01 ether;             //Min amount of Ether
    uint256 public constant MAX_ETHER = 1000 ether;             //Max amount of Ether

    
    address fund = 0x24B738698EC3bccadb61Dc74b8DFb23a712074b0;  //Address where funds are forwarded during the ICO

    
    uint256 public constant START_BLOCK_NUMBER = 4625526;       //Start block
    
    uint256 public constant TIER2 = 4645700;                      //Start + 3 days
    uint256 public constant TIER3 = 4669600;                     //Start + 10 days ( 3 days + 7 days)
    uint256 public constant TIER4 = 4662300;                     //Start + 20 days ( 3 days + 7 days + 10 days)
    uint256 public endBlockNumber = 4697000;                        //Start + 30 days
    uint256 public constant MAX_END_BLOCK_NUMBER = 4890000;         //End + 30 days

    uint256 public price;                                       //Rank price
   
    uint256 public constant TIER1_PRICE = 6000000;              //Price in 1st tier
    uint256 public constant TIER2_PRICE = 6700000;              //Price in 2nd tier
    uint256 public constant TIER3_PRICE = 7400000;              //Price in 3rd tier
    uint256 public constant TIER4_PRICE = 8200000;              //Price in 4th tier

    Token public rank;                                           //RankToken contract

    uint256 public constant SOFT_CAP_IN_ETHER = 4000 ether;    //softcap in ETH

    uint256 public collected;                                   //saves how much ETH was collected

    uint256 public constant Rank100 = 100 * (10**8);


    //MAP
    mapping (address => uint256) public bought;                 //saves how much ETH user spent on Rank


    //EVENT
    event Buy    (address indexed _who, uint256 _amount, uint256 indexed _price);   //Keep track of buyings
    event Refund (address indexed _who, uint256 _amount);                           //Keep track of refunding
    event CrowdsaleEndChanged (uint256 _crowdsaleEnd, uint256 _newCrowdsaleEnd);    //Notifies users about end block change


    //FUNCTION
    //Payable - can store ETH
    function RankCrowdsale (Token _rankToken)
        public
        notZeroAddress(_rankToken)
        payable
    {
        rank = _rankToken;
    }


    /* Fallback function is called when Ether is sent to the contract */
    function() 
        external 
        payable 
    {
        if (isCrowdsaleActive()) {
            buy();
        } else { 
            require (msg.sender == fund || msg.sender == owner);    //after crowdsale owner can send back eth for refund
        }
    }


    /* Burn unsold RANK after crowdsale */
    function finalize() 
        external
        onlyOwner
    {
        require(soldTokens != hardCapInTokens);
        if (soldTokens < (hardCapInTokens - RANK100)) {
            require(block.number > endBlockNumber);
        }
        hardCapInTokens = soldTokens;
        gee.burn(hardCapInTokens.SUB(soldTokens));
    }


    /* Buy tokens */
    function buy()
        public
        payable
    {
        uint256 amountWei = msg.value;
        uint256 blocks = block.number;


        require (isCrowdsaleActive());
        require(amountWei >= MIN_ETHER);                            //Ether limitation
        require(amountWei <= MAX_ETHER);

        price = getPrice();
        
        uint256 amount = amountWei / price;                         //Count how many RANK sender can buy

        soldTokens = soldTokens.ADD(amount);                        //Add amount to soldTokens

        require(soldTokens <= hardCapInTokens);

        if (soldTokens >= (hardCapInTokens - RANK100)) {
            endBlockNumber = blocks;
        }
        
        collected = collected.ADD(amountWei);                       //counts ETH
        bought[msg.sender] = bought[msg.sender].ADD(amountWei);

        gee.transfer(msg.sender, amount);                           //Transfer amount of Rank coins to msg.sender
        fund.transfer(this.balance);                                //Transfer contract Ether to fund

        Buy(msg.sender, amount, price);
    }


    /* Return Crowdsale status, depending on block numbers and stopInEmergency() state */
    function isCrowdsaleActive() 
        public 
        constant 
        returns (bool) 
    {

        if (endBlockNumber < block.number || START_BLOCK_NUMBER > block.number) {
            return false;
        }
        return true;
    }


    /* Change tier taking block numbers as time */
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


    /* Refund, if the soft cap is not reached */
    function refund() 
        external 
    {
        uint256 refund = bought[msg.sender];
        require (!isCrowdsaleActive());
        require (collected < SOFT_CAP_IN_ETHER);
        bought[msg.sender] = 0;
        msg.sender.transfer(refund);
        Refund(msg.sender, refund);
    }


    function drainEther() 
        external 
        onlyOwner 
    {
        fund.transfer(this.balance);
    }

    /*
    Allows owner setting the new end block number to extend/close Crowdsale.
    */
    function setEndBlockNumber(uint256 _newEndBlockNumber) external onlyOwner {
        require(isCrowdsaleActive());
        require(_newEndBlockNumber >= block.number);
        require(_newEndBlockNumber <= MAX_END_BLOCK_NUMBER);

        uint256 currentEndBlockNumber = endBlockNumber;
        endBlockNumber = _newEndBlockNumber;
        CrowdsaleEndChanged (currentEndBlockNumber, _newEndBlockNumber);
    }

}
