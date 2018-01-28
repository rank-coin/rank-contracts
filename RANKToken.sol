pragma solidity ^0.4.18 ;

/*
	@title RANKToken
*/

import "./MigratableToken.sol";

/*
	Contract defines specific token
*/
contract RANKToken is MigratableToken {

    
    //Name of the token
    string public constant name = "RANKS Platform Token";
    //Symbol of the token
    string public constant symbol = "RANK";
    //Number of decimals of RANK
    uint8 public constant decimals = 18;

    //Team allocation
    //Team wallet that will be unlocked after ICO
    address public constant TEAM0 = 0x5750885e96a6728639c93433BceA2c5b4519F462;
    //Team wallet that will be unlocked after 0.5 year after ICO
    address public constant TEAM1 = 0xb22347E0Ee848aB56d8cCDf58F97fB0D0Ec272eA;
    //Team wallet that will be unlocked after 1 year after ICO
    address public constant TEAM2 = 0x78eC754C2103cF26676686b2e76a88553Bf7c0c2;
    //0.5 year after ICO
    uint256 public constant UNLOCK_TEAM_1 = 1528372800;
    //1 year after ICO
    uint256 public constant UNLOCK_TEAM_2 = 1544184000;
    //1st team wallet balance
    uint256 public team1Balance;
    //2nd team wallet balance
    uint256 public team2Balance;

    //Community allocation
    address public constant COMMUNITY = 0x24B738698EC3bccadb61Dc74b8DFb23a712074b0;

    //2.4%
    uint256 private constant TEAM0_THOUSANDTH = 24;
    //3.6%
    uint256 private constant TEAM1_THOUSANDTH = 36;
    //6%
    uint256 private constant TEAM2_THOUSANDTH = 60;
    //67%
    uint256 private constant ICO_THOUSANDTH = 670;
    //21%
    uint256 private constant COMMUNITY_THOUSANDTH = 210;
    //100%
    uint256 private constant DENOMINATOR = 1000;

    function RANKToken() {
        //67% of _totalSupply
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

    //Check if team wallet is unlocked
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

}
