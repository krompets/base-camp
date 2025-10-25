
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FavoriteRecords {
    // --- helpers ---
    function _key(string memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(s));
    }

    // --- State ---
    // Публічний маппінг схвалених альбомів: ключ — keccak256(name)
    mapping(bytes32 => bool) public approvedRecords;
    // Для повернення назв схвалених альбомів
    string[] private approvedList;

    // Улюблені користувача: адреса -> (keccak256(name) -> bool)
    mapping(address => mapping(bytes32 => bool)) public userFavorites;
    // Для повернення назв улюблених альбомів користувача
    mapping(address => string[]) private userFavoriteList;

    // Кастомна помилка для не-схвалених альбомів
    error NotApproved(string submitted);

    // --- constructor: завантажити approvedRecords ---
    constructor() {
        _addApproved("Thriller");
        _addApproved("Back in Black");
        _addApproved("The Bodyguard");
        _addApproved("The Dark Side of the Moon");
        _addApproved("Their Greatest Hits (1971-1975)");
        _addApproved("Hotel California");
        _addApproved("Come On Over");
        _addApproved("Rumours");
        _addApproved("Saturday Night Fever");
    }

    function _addApproved(string memory name) internal {
        bytes32 k = _key(name);
        if (!approvedRecords[k]) {
            approvedRecords[k] = true;
            approvedList.push(name);
        }
    }

    // --- Get Approved Records ---
    function getApprovedRecords() external view returns (string[] memory) {
        return approvedList;
    }

    // Додатковий зручний геттер у форматі string (опційно)
    function isApproved(string calldata name) external view returns (bool) {
        return approvedRecords[_key(name)];
    }

    // --- Add Record to Favorites ---
    function addRecord(string calldata album) external {
        bytes32 k = _key(album);
        if (!approvedRecords[k]) revert NotApproved(album);

        // не дублюємо в списку
        if (!userFavorites[msg.sender][k]) {
            userFavorites[msg.sender][k] = true;
            userFavoriteList[msg.sender].push(album);
        }
    }

    // --- Users’ Lists ---
    function getUserFavorites(address user) external view returns (string[] memory) {
        return userFavoriteList[user];
    }

    // --- Reset My Favorites ---
    function resetUserFavorites() external {
        // проставити false у мапінгу для поточних вподобань
        string[] storage list = userFavoriteList[msg.sender];
        for (uint i = 0; i < list.length; i++) {
            userFavorites[msg.sender][_key(list[i])] = false;
        }
        // очистити список назв
        delete userFavoriteList[msg.sender];
    }
}
