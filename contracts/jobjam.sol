// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract jobjam is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _jobIds;
    Counters.Counter private _proposalIds;
    // Counters.Counter private _milestoneIds;

    address public owner;

    // enum PaymentType { MILESTONE, ONCE_OFF }

    struct Job {
        uint256 id;
        address employer;
        string title;
        string description;
        uint256 budget;
        // PaymentType paymentType;
        bool isOpen;
    }

    struct Proposal {
        uint256 id;
        uint256 jobId;
        address freelancer;
        string description;
        uint256 bid;
        bool isAccepted;
        // Milestone[] milestones;
    }

    // struct Milestone {
    //     uint256 id;
    //     string description;
    //     uint256 amount;
    //     bool isCompleted;
    //     bool isPaid;
    // }

    struct UserProfileInfo {
        uint256 jobId;
        bool isEmployer;
        bool isCompleted;
    }

    uint256 public jobIdCounter = 0;

    mapping(uint256 => Job) public jobs;
    mapping(uint256 => Proposal[]) public jobProposals;
    mapping(address => uint256[]) public userJobs;
    mapping(address => uint256[]) public userProposals;
    mapping(uint256 => bool) public completedJobs;

    event JobCreated(uint256 indexed jobId, address indexed employer, string title, uint256 budget);
    event ProposalSubmitted(uint256 indexed jobId, uint256 indexed proposalId, address indexed freelancer);
    event ProposalAccepted(uint256 indexed jobId, uint256 indexed proposalId, address indexed freelancer);
    // event MilestoneCreated(uint256 indexed jobId, uint256 indexed proposalId, uint256 indexed milestoneId, string description, uint256 amount);
    // event MilestoneUpdated(uint256 indexed jobId, uint256 indexed proposalId, uint256 indexed milestoneId, string description, uint256 amount);
    // event MilestoneCompleted(uint256 indexed jobId, uint256 indexed proposalId, uint256 indexed milestoneId);
    event PaymentReleased(uint256 indexed jobId, uint256 indexed proposalId, address indexed freelancer, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function createJob(string memory _title, string memory _description, uint256 _budget) external payable {
        require(msg.value == _budget, "Sent value must match the job budget");

        jobIdCounter++;
        jobs[jobIdCounter] = Job(jobIdCounter, msg.sender, _title, _description, _budget, true);
        userJobs[msg.sender].push(jobIdCounter);
        emit JobCreated(jobIdCounter, msg.sender, _title, _budget);
    }

    function getUserJobs(address _user) public view returns (uint256[] memory) {
        return userJobs[_user];
    }

    function submitProposal(uint256 _jobId, string memory _description, uint256 _bid) external {
        require(jobs[_jobId].isOpen, "Job is not open");

        _proposalIds.increment();
        uint256 newProposalId = _proposalIds.current();

        Proposal storage newProposal = jobProposals[_jobId].push();
        newProposal.id = newProposalId;
        newProposal.jobId = _jobId;
        newProposal.freelancer = msg.sender;
        newProposal.description = _description;
        newProposal.bid = _bid;
        newProposal.isAccepted = false;

        userProposals[msg.sender].push(newProposalId);
        emit ProposalSubmitted(_jobId, newProposalId, msg.sender);
    }

    function acceptProposal(uint256 _jobId, uint256 _proposalId) external {
        require(jobs[_jobId].employer == msg.sender, "Only the employer can accept proposals");
        require(jobs[_jobId].isOpen, "Job is not open");

        Proposal[] storage proposals = jobProposals[_jobId];
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].id == _proposalId) {
                proposals[i].isAccepted = true;
                jobs[_jobId].isOpen = false;
                emit ProposalAccepted(_jobId, _proposalId, proposals[i].freelancer);
                break;
            }
        }
    }

    // function updateMilestone(uint256 _jobId, uint256 _proposalId, uint256 _milestoneId, string memory _newDescription, uint256 _newAmount) external {
    //     Proposal[] storage proposals = jobProposals[_jobId];
    //     for (uint i = 0; i < proposals.length; i++) {
    //         if (proposals[i].id == _proposalId && proposals[i].freelancer == msg.sender) {
    //             for (uint j = 0; j < proposals[i].milestones.length; j++) {
    //                 if (proposals[i].milestones[j].id == _milestoneId) {
    //                     proposals[i].milestones[j].description = _newDescription;
    //                     proposals[i].milestones[j].amount = _newAmount;
    //                     emit MilestoneUpdated(_jobId, _proposalId, _milestoneId, _newDescription, _newAmount);
    //                     break;
    //                 }
    //             }
    //             break;
    //         }
    //     }
    // }

    // function completeMilestone(uint256 _jobId, uint256 _proposalId, uint256 _milestoneId) external {
    //     require(jobs[_jobId].employer == msg.sender, "Only the employer can complete milestones");

    //     Proposal[] storage proposals = jobProposals[_jobId];
    //     for (uint i = 0; i < proposals.length; i++) {
    //         if (proposals[i].id == _proposalId && proposals[i].isAccepted) {
    //             for (uint j = 0; j < proposals[i].milestones.length; j++) {
    //                 if (proposals[i].milestones[j].id == _milestoneId) {
    //                     proposals[i].milestones[j].isCompleted = true;
    //                     emit MilestoneCompleted(_jobId, _proposalId, _milestoneId);
    //                     break;
    //                 }
    //             }
    //             break;
    //         }
    //     }
    // }

    function releasePayment(uint256 _jobId, uint256 _proposalId) external nonReentrant {
        Job storage job = jobs[_jobId];
        require(job.employer == msg.sender, "Only the employer can release payments");

        Proposal[] storage proposals = jobProposals[_jobId];
        uint256 proposalIndex = type(uint256).max;

        // Find the accepted proposal
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].id == _proposalId && proposals[i].isAccepted) {
                proposalIndex = i;
                break;
            }
        }

        require(proposalIndex != type(uint256).max, "Accepted proposal not found");

        uint256 totalAmount = proposals[proposalIndex].bid;

        require(totalAmount > 0, "No payment to release");

        address payable freelancer = payable(proposals[proposalIndex].freelancer);

        require(address(this).balance >= totalAmount, "Insufficient contract balance");
        freelancer.transfer(totalAmount);

        completedJobs[_jobId] = true; // Mark the job as completed


        emit PaymentReleased(_jobId, _proposalId, freelancer, totalAmount);
    }

    // Fallback function to accept native token payments
    receive() external payable {}

    // Utility function to get proposals for a specific job
    function getProposalsForJob(uint256 _jobId) external view returns (Proposal[] memory) {
        return jobProposals[_jobId];
    }

    function getUserProfile(address _user) external view returns (UserProfileInfo[] memory) {
        uint256[] memory createdJobs = userJobs[_user];
        uint256[] memory proposedJobs = userProposals[_user];
        
        UserProfileInfo[] memory profileInfo = new UserProfileInfo[](createdJobs.length + proposedJobs.length);
        uint256 index = 0;

        // Add created jobs
        for (uint256 i = 0; i < createdJobs.length; i++) {
            profileInfo[index] = UserProfileInfo({
                jobId: createdJobs[i],
                isEmployer: true,
                isCompleted: completedJobs[createdJobs[i]]
            });
            index++;
        }

        // Add jobs worked on as a freelancer
        for (uint256 i = 0; i < proposedJobs.length; i++) {
            uint256 jobId = jobProposals[proposedJobs[i]][0].jobId;
            profileInfo[index] = UserProfileInfo({
                jobId: jobId,
                isEmployer: false,
                isCompleted: completedJobs[jobId]
            });
            index++;
        }

        return profileInfo;
    }

    // Utility function to get milestones for a specific proposal
    // function getMilestonesForProposal(uint256 _jobId, uint256 _proposalId) external view returns (Milestone[] memory) {
    //     Proposal[] storage proposals = jobProposals[_jobId];
    //     for (uint i = 0; i < proposals.length; i++) {
    //         if (proposals[i].id == _proposalId) {
    //             return proposals[i].milestones;
    //         }
    //     }
    //     revert("Proposal not found");
    // }
}