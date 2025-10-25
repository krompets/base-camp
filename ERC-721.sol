// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/* --------------------- Custom Errors --------------------- */
error HaikuNotUnique();
error NotYourHaiku(uint id);
error NoHaikusShared();

/* --------------------- Minimal ERC721 Implementation --------------------- */
contract MinimalERC721 {
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    string public name;
    string public symbol;

    mapping(uint => address) internal _owners;
    mapping(address => uint) internal _balances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function ownerOf(uint tokenId) public view returns (address) {
        return _owners[tokenId];
    }

    function balanceOf(address owner) public view returns (uint) {
        return _balances[owner];
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "Mint to zero address");
        require(_owners[tokenId] == address(0), "Token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
}

/* --------------------- Main Contract --------------------- */
contract HaikuNFT is MinimalERC721 {
    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    Haiku[] public haikus;                     // Усі хайку
    mapping(address => uint[]) public sharedHaikus; // кому поділились → id хайку
    uint public counter = 1;                   // id починається з 1

    // Для перевірки унікальності рядків
    mapping(bytes32 => bool) private usedLines;

    constructor() MinimalERC721("HaikuNFT", "HAIKU") {}

    /**
     * @dev Мінтить новий хайку NFT, якщо всі рядки унікальні.
     */
    function mintHaiku(
        string memory line1,
        string memory line2,
        string memory line3
    ) external {
        // Перевірка унікальності рядків (будь-який дубль — revert)
        if (usedLines[keccak256(bytes(line1))] ||
            usedLines[keccak256(bytes(line2))] ||
            usedLines[keccak256(bytes(line3))]) revert HaikuNotUnique();

        // Позначаємо рядки як використані
        usedLines[keccak256(bytes(line1))] = true;
        usedLines[keccak256(bytes(line2))] = true;
        usedLines[keccak256(bytes(line3))] = true;

        uint tokenId = counter;
        counter++; // лічильник для наступного ID

        // Мінт токена
        _mint(msg.sender, tokenId);

        // Зберігаємо хайку
        haikus.push(Haiku(msg.sender, line1, line2, line3));
    }

    /**
     * @dev Дозволяє власнику хайку поділитися ним з іншою адресою.
     */
    function shareHaiku(uint id, address _to) public {
        address owner = ownerOf(id);
        if (owner != msg.sender) revert NotYourHaiku(id);

        sharedHaikus[_to].push(id);
    }

    /**
     * @dev Повертає всі хайку, якими поділилися з викликачем.
     */
    function getMySharedHaikus() public view returns (Haiku[] memory) {
        uint[] memory ids = sharedHaikus[msg.sender];
        uint len = ids.length;

        if (len == 0) revert NoHaikusShared();

        Haiku[] memory result = new Haiku[](len);
        for (uint i = 0; i < len; i++) {
            result[i] = haikus[ids[i] - 1]; // бо id починається з 1
        }
        return result;
    }
}

