// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract WeightedVoting is ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ───── Errors ─────
    error TokensClaimed();
    error AllTokensClaimed();
    error NoTokensHeld();
    error QuorumTooHigh(uint256 quorum); // повертаємо кворум, як вимагається
    error AlreadyVoted();
    error VotingClosed();

    // ───── Vote enum ─────
    enum Vote {
        AGAINST,
        FOR,
        ABSTAIN
    }

    // ───── Issue (порядок полів строго за умовою!) ─────
    struct Issue {
        EnumerableSet.AddressSet voters; // 1
        string issueDesc;                // 2
        uint256 votesFor;                // 3
        uint256 votesAgainst;            // 4
        uint256 votesAbstain;            // 5
        uint256 totalVotes;              // 6
        uint256 quorum;                  // 7
        bool passed;                     // 8
        bool closed;                     // 9
    }

    // Для повернення назовні (без internal-типу)
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

    // ───── Storage ─────
    Issue[] internal issues;                 // не public через internal-тип
    mapping(address => bool) public tokensClaimed;

    uint256 public constant maxSupply   = 1_000_000;
    uint256 public constant claimAmount = 100;

    // ───── Constructor ─────
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        // "спалюємо" нульовий елемент, щоб id починався з 1
        issues.push();
    }

    // ───── Claim ─────
    function claim() public {
        // спочатку перевіряємо, чи не закінчилась макс. емісія
        if (totalSupply() + claimAmount > maxSupply) revert AllTokensClaimed();
        if (tokensClaimed[msg.sender]) revert TokensClaimed();

        tokensClaimed[msg.sender] = true;
        _mint(msg.sender, claimAmount);
    }

    // ───── Create Issue ─────
    // ВАЖЛИВО: перевірка "є токени" має стояти ПЕРЕД перевіркою кворуму (так вимагає тест)
    function createIssue(string calldata _issueDesc, uint256 _quorum)
        external
        returns (uint256)
    {
        if (balanceOf(msg.sender) == 0) revert NoTokensHeld();
        if (_quorum > totalSupply()) revert QuorumTooHigh(_quorum);

        Issue storage isr = issues.push();
        isr.issueDesc = _issueDesc;
        isr.quorum = _quorum;

        return issues.length - 1; // індекс нового issue (0 — порожній)
    }

    // ───── Get Issue (серіалізований) ─────
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

    // ───── Vote ─────
    function vote(uint256 _issueId, Vote _vote) public {
        Issue storage isr = issues[_issueId];

        if (isr.closed) revert VotingClosed();
        if (isr.voters.contains(msg.sender)) revert AlreadyVoted();

        uint256 weight = balanceOf(msg.sender);
        if (weight == 0) revert NoTokensHeld();

        // додаємо голоси за вагою
        if (_vote == Vote.AGAINST) {
            isr.votesAgainst += weight;
        } else if (_vote == Vote.FOR) {
            isr.votesFor += weight;
        } else {
            isr.votesAbstain += weight;
        }

        isr.voters.add(msg.sender);
        isr.totalVotes += weight;

        // закриття по досягненню/перевищенню кворуму
        if (isr.totalVotes >= isr.quorum) {
            isr.closed = true;
            if (isr.votesFor > isr.votesAgainst) {
                isr.passed = true;
            }
        }
    }
}
