// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    uint public ticketPrice;
    uint public ticketCount;
    uint public maxTicketCount;
    uint[] public tickets;
    
    event NewTicket(address indexed player);
    event Winner(address indexed player, uint prize);
    
    constructor(uint _ticketPrice, uint _maxTicketCount) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        maxTicketCount = _maxTicketCount;
    }
    
    function buyTicket() public payable {
        require(msg.value == ticketPrice, "Ticket price is incorrect.");
        require(ticketCount < maxTicketCount, "All tickets have been sold.");
        
        ticketCount++;
        tickets.push(ticketCount);
        emit NewTicket(msg.sender);
        
        if (ticketCount == maxTicketCount) {
            selectWinner();
        }
    }
    
    function selectWinner() private {
        uint index = random() % maxTicketCount;
        address payable winner = payable(address(tickets[index]));
        uint prize = address(this).balance;
        winner.transfer(prize);
        emit Winner(winner, prize);
        
        resetLottery();
    }
    
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, tickets)));
    }
    
    function resetLottery() private {
        ticketCount = 0;
        delete tickets;
    }
    
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw.");
        payable(msg.sender).transfer(address(this).balance);
    }
}
