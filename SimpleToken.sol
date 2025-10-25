// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error TokensClaimed();        // Якщо користувач уже отримав свої токени
error AllTokensClaimed();     // Якщо всі токени вже роздані
error UnsafeTransfer(address to); // Якщо передача небезпечна (0x0 або одержувач без ETH)

contract UnburnableToken {
    // Баланси користувачів
    mapping(address => uint) public balances;
    // Всього токенів у системі
    uint public totalSupply;
    // Скільки токенів уже роздано
    uint public totalClaimed;
    // Відстеження, хто вже зробив claim
    mapping(address => bool) private hasClaimed;

    uint private constant CLAIM_AMOUNT = 1000;

    constructor() {
        totalSupply = 100_000_000; // 100 мільйонів токенів
        totalClaimed = 0;
    }

    /**
     * @dev Кожен користувач може один раз отримати 1000 токенів.
     * Якщо токени закінчились або користувач уже отримував — revert.
     */
    function claim() external {
        if (hasClaimed[msg.sender]) revert TokensClaimed();
        if (totalClaimed + CLAIM_AMOUNT > totalSupply) revert AllTokensClaimed();

        balances[msg.sender] += CLAIM_AMOUNT;
        hasClaimed[msg.sender] = true;
        totalClaimed += CLAIM_AMOUNT;
    }

    /**
     * @dev Безпечне переведення токенів на адресу `_to`.
     * Перевіряє:
     *  - `_to` не дорівнює 0x0
     *  - `_to` має ненульовий баланс ETH (Base Sepolia)
     */
    function safeTransfer(address _to, uint _amount) external {
        if (_to == address(0)) revert UnsafeTransfer(_to);
        if (_to.balance == 0) revert UnsafeTransfer(_to);
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}
