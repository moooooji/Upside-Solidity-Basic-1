// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract Quiz{
    struct Quiz_item  {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }

   address public owner;
    
    mapping(uint256 => mapping(address => uint256)) public bets;
    uint public vault_balance;
    Quiz_item[] public quizzes; // Quiz_item 배열 추가

    modifier onlyOwner() {
        require(msg.sender == owner, "Only onwer can add quiz");
        _;
    }

    constructor () payable {

        owner = msg.sender;

        Quiz_item memory q0;
        q0.id = 1;
        q0.question = "1+1=?";
        q0.answer = "2";
        q0.min_bet = 1 ether;
        q0.max_bet = 2 ether;
        addQuiz(q0);

        Quiz_item memory q1;
        q1.id = 1;
        q1.question = "1+1=?";
        q1.answer = "123";
        q1.min_bet = 1 ether;
        q1.max_bet = 2 ether;
        addQuiz(q1);
    }
    receive() external payable {
    console.log("Contract received ETH: ", msg.value);
}

    function addQuiz(Quiz_item memory q) public onlyOwner {
        quizzes.push(q);
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quizzes[quizId-1].answer;
    }

    function getQuiz(uint quizId) public returns (Quiz_item memory) {

        quizzes[quizId].answer = "";

        return quizzes[quizId];
    }

    function getQuizNum() public view returns (uint){
        return (quizzes.length-1);
    }
    
    function betToPlay(uint quizId) public payable {
        require(msg.value >= quizzes[quizId].min_bet, "Bet too low");
        require(msg.value <= quizzes[quizId].max_bet, "Bet exceeds limit");
        bets[quizId-1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {

        if (keccak256(abi.encodePacked(quizzes[quizId-1].answer)) == keccak256(abi.encodePacked(ans))) {
            return true;
        } else {
            console.log("Test");
            bets[quizId-1][msg.sender] -= quizzes[quizId-1].min_bet; // 정답이 틀릴 경우 베팅한 금액 만큼 차감
            vault_balance += quizzes[quizId-1].min_bet; // 정답이 틀릴 경우 컨트랙트 총 잔액은 베팅한 금액 만큼 증가

            return false;
        }
        
    }

    function claim() public payable {
        uint256 betAmount = bets[0][msg.sender];

        uint256 reward = 2 * betAmount;

        uint256 balance = address(this).balance;
        
        bets[0][msg.sender] = 0;
        payable(msg.sender).call{value: reward}("");
    }

}