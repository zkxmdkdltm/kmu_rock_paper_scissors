//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract RockPaperScissors {
    enum Choice { None, Rock, Paper, Scissors }
    enum Outcome { None, Draw, PlayerWins, ComputerWins }

    uint public playerBalance;
    uint public computerBalance;
    Choice public playerChoice;
    Choice public computerChoice;
    Outcome public outcome;

    function play(uint choice) public payable {
        require(msg.value == 0.1 ether, "Please send exactly 0.1 ether");
        require(playerBalance == 0 && computerBalance == 0, "Game in progress");
        require(choice >= uint(Choice.Rock) && choice <= uint(Choice.Scissors), "Invalid choice");

        playerBalance = msg.value;
        playerChoice = Choice(choice);

        computerBalance = msg.value;
        computerChoice = Choice(uint(keccak256(abi.encodePacked(block.timestamp, block.basefee, address(this)))) % 3);

        uint winner = (uint(playerChoice) - uint(computerChoice) + 3) % 3;
        if (winner == 0) {
            outcome = Outcome.Draw;
            playerBalance = 0;
            computerBalance = 0;
        } else if (winner == 1) {
            outcome = Outcome.PlayerWins;
            playerBalance = playerBalance * 2;
            computerBalance = 0;
            payable(msg.sender).transfer(playerBalance);
        } else {
            outcome = Outcome.ComputerWins;
            playerBalance = 0;
            computerBalance = computerBalance * 2;
        }
    }
}
