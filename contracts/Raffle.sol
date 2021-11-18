//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Raffle is VRFConsumerBase {
    uint256 public entranceFee = 10 gwei;
    address public recentWinner;
    address payable[] public players;

    enum State {Open, Calculating}
    State public state;

    constructor() VRFConsumerBase(vrfCoordinator, linkToken) {}

    address linkToken = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    address vrfCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
    bytes32 keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    uint256 chainlinkFee = 0.1 ether;

    function enterRaffle() public payable {
        require(msg.value == entranceFee, "Please send 10 gwei");
        require(state == State.Open, "State is closed");
        players.push(payable(msg.sender));

    }

    function closeRound() public {
        state = State.Calculating;
        require(LINK.balanceOf(address(this)) >= chainlinkFee, "Not enough link");
        requestRandomness(keyHash, chainlinkFee);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        uint256 randomWinner = randomness % players.length;
        address payable winner = players[randomWinner];
        (bool success,) = winner.call{value: address(this).balance}("");
        require(success, "Transfer to winner failed");
        delete players;
        state = State.Open;
    }

}
