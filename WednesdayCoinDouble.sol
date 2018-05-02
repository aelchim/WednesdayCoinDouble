pragma solidity ^0.4.18;

import "./ownable.sol";
import "./destructible.sol";
import "./tokenInterfaces.sol";

/**
 * @title WednesdayCoinDouble
 * @dev 
 */
contract WednesdayDouble is Ownable, Destructible {

    // WednesdayCoin contract being held
    WednesdayCoin public wednesdayCoin;

    // amount
    uint256 public maxBet;
    
    bool public stopGame;
    
    uint8 public difficulty;

    function WednesdayDouble() {
        //for testing 0xedfc38fed24f14aca994c47af95a14a46fbbaa16
        wednesdayCoin = WednesdayCoin(0x7848ae8f19671dc05966dafbefbbbb0308bdfabd);
        maxBet = 10000000000000000000000;
        stopGame = false;
        difficulty = 50;
    }

    function receiveApproval(address from, uint256 value, address tokenContract, bytes extraData) returns (bool) {
        require(stopGame == false);
        
        require(value <= maxBet);
        
        require(wednesdayCoin.balanceOf(this) >= (value * 2));
        
        //require Wednesday(3)
        uint8 dayOfWeek = uint8((now / 86400 + 4) % 7);
        require(dayOfWeek == 3);
        
        if (wednesdayCoin.transferFrom(from, this, value)) {
            if (difficulty < random(100)) {
                wednesdayCoin.transfer(msg.sender, (value * 2));
            } else {
                //send back 1
                wednesdayCoin.transfer(msg.sender, 1000000000000000000);
            }
        }
    }

    function setMaxBet(uint256 _maxBet) public onlyOwner {
        maxBet = _maxBet;
    }
    
    function setStopGame(bool _stopGame) public onlyOwner {
        stopGame = _stopGame;
    }

    function setDifficulty(uint8 _difficulty) public onlyOwner {
        difficulty = _difficulty;
    }

    function maxRandom() public returns (uint256 randomNumber) {
        uint256 _seed = uint256(keccak256(
                _seed,
                block.blockhash(block.number - 1),
                block.coinbase,
                block.difficulty
            ));
        return _seed;
    }

    // return a pseudo random number between lower and upper bounds
    // given the number of previous blocks it should hash.
    function random(uint256 upper) public returns (uint256 randomNumber) {
        return maxRandom() % upper;
    }
    // Used for transferring any accidentally sent ERC20 Token by the owner only
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    // Used for transferring any accidentally sent Ether by the owner only
    function transferEther(address dest, uint amount) public onlyOwner {
        dest.transfer(amount);
    }
}