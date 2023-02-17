// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowfund {

    struct Project {
        address creator;
        uint goal;
        uint pledgedFunds;
        uint startTime;
        uint endTime;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    uint public maxDuration;
    mapping(uint => Project) public projects;
    mapping(uint => mapping(address => uint)) public amountPledged;

    event ProjectStarted(uint id, address indexed creator, 
                        uint goal, uint32 startTime, 
                        uint32 endTime
                        );

    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event ClaimFunds(uint indexed id);
    event Refund(uint indexed id, address indexed caller, uint amount);
    event Cancel(uint id);

    constructor(address _token, uint _maxDuration){
        token = IERC20(_token);
        maxDuration = _maxDuration;
    }


    function startProject(uint _goal, uint32 _startTime, uint32 _endTime) external {
        require(_startTime >= block.timestamp, "The project start time is less than the current block timestamp");
        require(_endTime > _startTime, "The end time is less than the start time");
        require(_endTime <= block.timestamp + maxDuration, "The end time of the project can't exceed the max duration");

        count += 1;
        projects[count] = Project({
            creator: msg.sender,
            goal: _goal,
            pledgedFunds: 0, 
            startTime: _startTime,
            endTime: _endTime,
            claimed: false   
        });

        emit ProjectStarted(count, msg.sender, _goal, _startTime, _endTime);
    }

    function cancelProject(uint _id) external{
        Project memory project = projects[_id];
        require(project.creator == msg.sender, "You didn't create this Project");
        require(project.startTime > block.timestamp, "Project has already started");
        
        delete projects[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external{
        Project storage project = projects[_id];
        require(project.startTime <= block.timestamp, "Project hasn't started yet");
        require(project.endTime >= block.timestamp, "Project has ended");
        project.pledgedFunds += _amount;
        amountPledged[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint _id, uint _amount) external {
        Project storage project = projects[_id];
        require(project.startTime <= block.timestamp, "Project hasn't started yet");
        require(project.endTime >= block.timestamp, "Project has ended");
        require(amountPledged[_id][msg.sender] >= _amount, "You didn't pledged that many funds");
        project.pledgedFunds -= _amount;
        amountPledged[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);
    }

    function claimFunds(uint _id) external {
        Project storage project = projects[_id];
        require(project.creator == msg.sender, "You're not the creator of the project");
        require (project.endTime < block.timestamp, "The project didn't end yet");
        require(project.goal <= project.pledgedFunds, "The project didn't reach the goal"); 
        require(!project.claimed, "The funds have already been claimed");
        
        project.claimed = true;
        token.transfer(project.creator, project.pledgedFunds);
        emit ClaimFunds(_id);
    }

    function refund(uint _id) external{
        Project memory project = projects[_id];
        require (project.endTime < block.timestamp, "The project didn't end yet");
        require(project.goal > project.pledgedFunds, "The project reached the goal");

        uint userFunds = amountPledged[_id][msg.sender];
        amountPledged[_id][msg.sender] = 0;
        token.transfer(msg.sender, userFunds);
        emit Refund(_id, msg.sender, userFunds);
    }
}

