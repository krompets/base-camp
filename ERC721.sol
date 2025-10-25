// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract WeightedVoting is ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;

    error TokensClaimed();
    error AllTokensClaimed();
    error NoTokensHeld();
    error QuorumTooHigh(uint256 quorum);
    error AlreadyVoted();
    error VotingClosed();

    enum Vote {
        AGAINST,
        FOR,
        ABSTAIN
    }

    struct Issue {
        EnumerableSet.AddressSet voters;
        string issueDesc;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 totalVotes;
        uint256 quorum;
        bool passed;
        bool closed;
    }

    struct SerializedIssue {
        address[] voters;
        string issueDesc;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 totalVotes;
        uint256 quorum;
        bool passed;
        bool closed;
    }

    Issue[] internal issues;
    mapping(address => bool) public tokensClaimed;

    uint256 public constant maxSupply = 1_000_000;
    uint256 public constant claimAmount = 100;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        issues.push();
    }

    function claim() public {
        if (totalSupply() + claimAmount > maxSupply) revert AllTokensClaimed();
        if (tokensClaimed[msg.sender]) revert TokensClaimed();
        tokensClaimed[msg.sender] = true;
        _mint(msg.sender, claimAmount);
    }

    function createIssue(string calldata _issueDesc, uint256 _quorum)
        external
        returns (uint256)
    {
        if (balanceOf(msg.sender) == 0) revert NoTokensHeld();
        if (_quorum > totalSupply()) revert QuorumTooHigh(_quorum);
        Issue storage isr = issues.push();
        isr.issueDesc = _issueDesc;
        isr.quorum = _quorum;
        return issues.length - 1;
    }

    function getIssue(uint256 _issueId)
        external
        view
        returns (SerializedIssue memory)
    {
        Issue storage isr = issues[_issueId];
        return SerializedIssue({
            voters: isr.voters.values(),
            issueDesc: isr.issueDesc,
            votesFor: isr.votesFor,
            votesAgainst: isr.votesAgainst,
            votesAbstain: isr.votesAbstain,
            totalVotes: isr.totalVotes,
            quorum: isr.quorum,
            passed: isr.passed,
            closed: isr.closed
        });
    }

    function vote(uint256 _issueId, Vote _vote) public {
        Issue storage isr = issues[_issueId];
        if (isr.closed) revert VotingClosed();
        if (isr.voters.contains(msg.sender)) revert AlreadyVoted();
        uint256 weight = balanceOf(msg.sender);
        if (weight == 0) revert NoTokensHeld();
        if (_vote == Vote.AGAINST) {
            isr.votesAgainst += weight;
        } else if (_vote == Vote.FOR) {
            isr.votesFor += weight;
        } else {
            isr.votesAbstain += weight;
        }
        isr.voters.add(msg.sender);
        isr.totalVotes += weight;
        if (isr.totalVotes >= isr.quorum) {
            isr.closed = true;
            if (isr.votesFor > isr.votesAgainst) {
                isr.passed = true;
            }
        }
    }
}
