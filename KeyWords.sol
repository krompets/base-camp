// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/* ========= Minimal Ownable (сумісний з 0.8.17) ========= */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address old = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(old, newOwner);
    }
}

/* ======================= AddressBook ======================= */
error ContactNotFound(uint id);

contract AddressBook is Ownable {
    struct Contact {
        uint id;
        string firstName;
        string lastName;
        uint[] phoneNumbers;
    }

    // Зберігання: id => Contact
    mapping(uint => Contact) private contacts;
    // Список існуючих id (для getAllContacts)
    uint[] private contactIds;

    /**
     * @dev Додає/оновлює контакт (тільки власник).
     * Якщо контакт із таким _id новий — додаємо id у індекс.
     * Якщо існує — перезаписуємо поля та список номерів.
     */
    function addContact(
        uint _id,
        string calldata _firstName,
        string calldata _lastName,
        uint[] calldata _phoneNumbers
    ) external onlyOwner {
        Contact storage c = contacts[_id];
        bool isNew = (c.id == 0);

        c.id = _id;
        c.firstName = _firstName;
        c.lastName  = _lastName;

        // перезаписуємо номери
        delete c.phoneNumbers;
        for (uint i = 0; i < _phoneNumbers.length; i++) {
            c.phoneNumbers.push(_phoneNumbers[i]);
        }

        if (isNew) contactIds.push(_id);
    }

    /**
     * @dev Видаляє контакт за _id (тільки власник). Якщо немає — ContactNotFound(_id).
     */
    function deleteContact(uint _id) external onlyOwner {
        if (contacts[_id].id == 0) revert ContactNotFound(_id);

        // видаляємо контакт
        delete contacts[_id];

        // прибираємо _id із масиву (swap & pop)
        for (uint i = 0; i < contactIds.length; i++) {
            if (contactIds[i] == _id) {
                contactIds[i] = contactIds[contactIds.length - 1];
                contactIds.pop();
                break;
            }
        }
    }

    /**
     * @dev Повертає контакт за _id або кидає ContactNotFound(_id).
     */
    function getContact(uint _id) external view returns (Contact memory) {
        if (contacts[_id].id == 0) revert ContactNotFound(_id);
        return contacts[_id];
    }

    /**
     * @dev Повертає всі наявні (не видалені) контакти.
     */
    function getAllContacts() external view returns (Contact[] memory) {
        Contact[] memory out = new Contact[](contactIds.length);
        for (uint i = 0; i < contactIds.length; i++) {
            out[i] = contacts[contactIds[i]];
        }
        return out;
    }
}

/* =================== AddressBookFactory ==================== */
contract AddressBookFactory {
    event AddressBookCreated(address indexed owner, address addressBook);

    /**
     * @dev Створює нову AddressBook і передає власність викликачу.
     * Повертає адресу створеного контракту.
     */
    function deploy() external returns (address) {
        AddressBook book = new AddressBook();   // тимчасово owner = фабрика
        book.transferOwnership(msg.sender);     // робимо власником викликача
        emit AddressBookCreated(msg.sender, address(book));
        return address(book);
    }
}
