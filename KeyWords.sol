// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

error ContactNotFound(uint id);

contract AddressBook is Ownable {
    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
    }

    mapping(uint => Contact) private contacts;
    uint[] private contactIds;

    function addContact(
        uint _id,
        string calldata _firstName,
        string calldata _lastName,
        uint[] calldata _phoneNumbers
    ) external onlyOwner {
        Contact storage newContact = contacts[_id];
        newContact.id = _id;
        newContact.firstName = _firstName;
        newContact.lastName = _lastName;
        delete newContact.phoneNumbers;

        for (uint i = 0; i < _phoneNumbers.length; i++) {
            newContact.phoneNumbers.push(_phoneNumbers[i]);
        }

        contactIds.push(_id);
    }

    function deleteContact(uint _id) external onlyOwner {
        if (contacts[_id].id == 0) revert ContactNotFound(_id);
        delete contacts[_id];

        for (uint i = 0; i < contactIds.length; i++) {
            if (contactIds[i] == _id) {
                contactIds[i] = contactIds[contactIds.length - 1];
                contactIds.pop();
                break;
            }
        }
    }

    function getContact(uint _id) external view returns (Contact memory) {
        if (contacts[_id].id == 0) revert ContactNotFound(_id);
        return contacts[_id];
    }

    function getAllContacts() external view returns (Contact[] memory) {
        Contact[] memory result = new Contact[](contactIds.length);
        for (uint i = 0; i < contactIds.length; i++) {
            result[i] = contacts[contactIds[i]];
        }
        return result;
    }
}
