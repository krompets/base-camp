// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ArraysExercise {
    uint[] public numbers = [1,2,3,4,5,6,7,8,9,10];
    address[] public senders;
    uint[] public timestamps;

    uint256 private constant Y2K = 946702800;

    // --- Return a Complete Array ---
    function getNumbers() external view returns (uint[] memory) {
        return numbers;
    }

    // --- Reset Numbers ---
    function resetNumbers() public {
        delete numbers; // очищуємо масив
        for (uint i = 1; i <= 10; i++) {
            numbers.push(i);
        }
    }

    // --- Append to Existing Array ---
    function appendToNumbers(uint[] calldata _toAppend) external {
        for (uint i = 0; i < _toAppend.length; i++) {
            numbers.push(_toAppend[i]);
        }
    }

    // --- Save Timestamp ---
    function saveTimestamp(uint _unixTimestamp) external {
        senders.push(msg.sender);
        timestamps.push(_unixTimestamp);
    }

    // --- Return timestamps and senders after Y2K ---
    function afterY2K() external view returns (uint[] memory, address[] memory) {
        uint count;
        for (uint i = 0; i < timestamps.length; i++) {
            if (timestamps[i] > Y2K) count++;
        }

        uint[] memory recentTimestamps = new uint[](count);
        address[] memory recentSenders = new address[](count);

        uint idx;
        for (uint i = 0; i < timestamps.length; i++) {
            if (timestamps[i] > Y2K) {
                recentTimestamps[idx] = timestamps[i];
                recentSenders[idx] = senders[i];
                idx++;
            }
        }

        return (recentTimestamps, recentSenders);
    }

    // --- Resets ---
    function resetSenders() public {
        delete senders;
    }

    function resetTimestamps() public {
        delete timestamps;
    }
}
