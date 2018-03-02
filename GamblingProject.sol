//Write your own contracts here. Currently compiles using solc v0.4.15+commit.bbb8e64f.
pragma solidity ^0.4.18;

contract GambleTool {
  address owner;

  struct Bet { // Multiple People 
    address[] players;
    address winner;
    uint8 _betValue;
    uint8 _maxPlayers;
    bool open;
  }

  Bet[] public bets; 
  mapping (uint => address) public betToOwner;

  event newGame(uint index, uint maxPlayers, uint betValue);
  event joined(uint index, address playerAddress, uint balance);
  event win(uint index, address winnerAddress, uint payout);

  function setBet(uint betValue, uint maxPlayers) public { // This wont be public 
    require(msg.sender == owner); //Might not be the best place
    address[] memory blank;
    uint index = bets.push(Bet(blank, address(0), uint8(betValue), uint8(maxPlayers), true)) -1;
    betToOwner[index] = msg.sender; // a little confusing 
    newGame(index, maxPlayers, betValue);
  }

  function join(uint index) public payable {
    require(bets[index].players.length < bets[index]._maxPlayers); //Check for open
    require(msg.value == bets[index]._betValue);
    
    bets[index].players.push(msg.sender);
    joined(index, msg.sender, this.balance);
    
    if (bets[index].players.length == bets[index]._maxPlayers) {
      startGame(index);
    }
  }

  function getGame(uint index) public view returns (uint) {
    require(bets[index].players.length > 0);
    return bets[index]._maxPlayers - bets[index].players.length;
  }

  function ManualStartGame(uint index) public returns (address) { 
    require(msg.sender == owner);
    return startGame(index);
  }
  
  function startGame(uint index) internal returns (address) { //Not going to return
    require(bets[index].open);
    bets[index].open = false;
    uint playerCount = bets[index].players.length;
    uint winningPlayer = flip(bets[index].players.length);
    address winningAddress = bets[index].players[winningPlayer];
    uint ethPool = (bets[index]._betValue*playerCount*90)/100; //They win 90% of total pool.
    bets[index].players[winningPlayer].transfer(ethPool);
    win(index, winningAddress, ethPool);
    bets[index].winner = bets[index].players[winningPlayer];
    return winningAddress;
  }

  function flip(uint playerCount) internal view returns (uint) { //needs to be bool
    return uint(keccak256(now)) % playerCount; // Not Random
  }
  
  function getBet(uint index) public view returns (uint, address, uint, uint, bool){
    return (bets[index].players.length, bets[index].winner, bets[index]._betValue, bets[index]._maxPlayers, bets[index].open);
  }
  
  function totalGames() public view returns (uint) {
      return bets.length;
  }

  function deployGamble() public {
    owner = msg.sender;
  }

}
