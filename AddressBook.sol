
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { _transferOwnership(_msgSender()); }

    function owner() public view returns (address) { return _owner; }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is zero");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address old = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(old, newOwner);
    }
}

contract AddressBook is Ownable {
    string private salt = "value";

    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
    }

    Contact[] private contacts;
    mapping(uint => uint) private idToIndex;
    uint private nextId = 1;

    error ContactNotFound(uint id);

    function addContact(
        string calldata firstName,
        string calldata lastName,
        uint[] calldata phoneNumbers
    ) external onlyOwner {
        contacts.push(Contact(nextId, firstName, lastName, phoneNumbers));
        idToIndex[nextId] = contacts.length - 1;
        nextId++;
    }

    function deleteContact(uint id) external onlyOwner {
        uint index = idToIndex[id];
        if (index >= contacts.length || contacts[index].id != id) revert ContactNotFound(id);
        uint last = contacts.length - 1;
        if (index != last) {
            contacts[index] = contacts[last];
            idToIndex[contacts[index].id] = index;
        }
        contacts.pop();
        delete idToIndex[id];
    }

    function getContact(uint id) external view returns (Contact memory) {
        uint index = idToIndex[id];
        if (index >= contacts.length || contacts[index].id != id) revert ContactNotFound(id);
        return contacts[index];
    }

    function getAllContacts() external view returns (Contact[] memory) {
        return contacts;
    }
}

contract AddressBookFactory {
    event AddressBookCreated(address indexed owner, address addressBook);

    function deploy() external returns (address) {
        AddressBook book = new AddressBook();
        book.transferOwnership(msg.sender);
        emit AddressBookCreated(msg.sender, address(book));
        return address(book);
    }
}
