// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public owner;

    enum Move {NONE, ROCK, PAPER, SCISSORS}

    struct Game {
        address player;
        Move playerMove;
        Move contractMove;
        uint256 amount;
        bool played;
    }

    mapping(bytes32 => Game) public games;

    event GameCreated(bytes32 indexed gameId, address indexed player, uint256 amount);
    event GamePlayed(bytes32 indexed gameId, address indexed player, uint8 playerMove, uint8 contractMove, uint256 amount, bool win);

    constructor() {
        owner = msg.sender;
    }

    function createGame(bytes32 gameId) public payable {
        require(msg.value > 0, "Amount should be greater than 0");
        require(games[gameId].player == address(0), "Game already exists");
        games[gameId].player = msg.sender;
        games[gameId].amount = msg.value;
        emit GameCreated(gameId, msg.sender, msg.value);
    }

    function play(bytes32 gameId, uint8 playerMove) public payable returns (int8) {
        require(games[gameId].played == false, "Game already played");
        require(games[gameId].player != address(0), "Game does not exist");
        require(msg.value == games[gameId].amount, "Amount should be equal to the game amount");

        // Set player move
        if (playerMove == 1) {
            games[gameId].playerMove = Move.ROCK;
        } else if (playerMove == 2) {
            games[gameId].playerMove = Move.PAPER;
        } else if (playerMove == 3) {
            games[gameId].playerMove = Move.SCISSORS;
        }

        // Generate contract move
        uint256 seed = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, block.number)));
        uint8 contractMove = uint8(seed % 3) + 1;
        if (contractMove == 1) {
            games[gameId].contractMove = Move.ROCK;
        } else if (contractMove == 2) {
            games[gameId].contractMove = Move.PAPER;
        } else if (contractMove == 3) {
            games[gameId].contractMove = Move.SCISSORS;
        }

        // Determine winner
        int8 result = determineWinner(games[gameId].playerMove, games[gameId].contractMove);

        // Update game state
        games[gameId].played = true;


        // Emit event
        emit GamePlayed(gameId, games[gameId].player, playerMove, contractMove, games[gameId].amount, result == 1);

        return result;
    }

    function determineWinner(Move playerMove, Move contractMove) private pure returns (int8) {
        if (playerMove == Move.ROCK && contractMove == Move.SCISSORS) {
            return 1;
        } else if (playerMove == Move.PAPER && contractMove == Move.ROCK) {
            return 1;
        } else if (playerMove == Move.SCISSORS && contractMove == Move.PAPER) {
            return 1;
        } else if (playerMove == contractMove) {
            return 0;
        } else {
            return -1;
        }
    }
}

