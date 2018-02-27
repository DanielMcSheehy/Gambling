//Write your own contracts here. Currently compiles using solc v0.4.15+commit.bbb8e64f.
pragma solidity ^0.4.18;

contract Gamble {
  address owner;

  struct Bet { // Multiple People 
    address[] players;
    uint8 _betValue;
    uint8 _maxPlayers;
    bool open;
  }

  Bet[] public bets; 
  mapping (uint => address) public betToOwner;

  event joined(uint sentValue, uint balance);
  event win(uint winner, uint amount);

  function setBet(uint betValue, uint maxPlayers) public { // This wont be public 
    require(msg.sender == owner); //Might not be the best place
    address[] memory blank;
    uint index = bets.push(Bet(blank, uint8(betValue), uint8(maxPlayers), true)) -1;
    betToOwner[index] = msg.sender; // a little confusing 
  }

  function join(uint index) public payable {
    require(bets[index].players.length < bets[index]._maxPlayers); //Check for open
    if (msg.value >= bets[index]._betValue) { // Require? 
      bets[index].players.push(msg.sender);
      joined(msg.value, this.balance);
    }
  }

  function getGame(uint index) public view returns (uint) {
    require(bets[index].players.length > 0);
    return bets[index].players.length;
  }

  function startGame(uint index) public returns (uint) { //Not going to return
    require(msg.sender == owner);
    require(bets[index].open);
    uint playerCount = bets[index].players.length;
    uint winningPlayer = flip(bets[index].players.length);
    uint ethPool = (bets[index]._betValue*playerCount*90)/100; //They win 90% of total pool.
    betToOwner[winningPlayer].transfer(ethPool);
    win(winningPlayer, ethPool);
    //return getGame(index); // Returns winner (index)
    return winningPlayer;
  }

  function flip(uint playerCount) internal view returns (uint) { //needs to be bool
    return uint(keccak256(now)) % playerCount; // Not Random
  }

  function deployGamble() public {
    owner = msg.sender;
  }

}