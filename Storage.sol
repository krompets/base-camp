// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EmployeeStorage {
    // ---- Storage (packed) ----
    // Два 32-бітні значення йдуть підряд і пакуються в один слот
    uint32 private shares;   // кількість акцій (директори > 5000 — зберігаються в іншому контракті)
    uint32 private salary;   // 0..1_000_000

    // Динамічний тип у власному слоті
    string public name;

    // Повний uint256 (ID може бути будь-яким до 2^256-1)
    uint256 public idNumber;

    // ---- Errors ----
    error TooManyShares(uint256 wouldHave);

    // ---- Constructor ----
    // Для тесту деплой з параметрами:
    // shares=1000, name="Pat", salary=50000, idNumber=112358132134
    constructor(
        uint32 _shares,
        string memory _name,
        uint32 _salary,
        uint256 _idNumber
    ) {
        shares = _shares;
        name = _name;
        salary = _salary;        // у межах 0..1_000_000
        idNumber = _idNumber;
    }

    // ---- Views ----
    function viewSalary() external view returns (uint256) {
        return salary;
    }

    function viewShares() external view returns (uint256) {
        return shares;
    }

    // ---- Mutations ----
    function grantShares(uint256 _newShares) public {
        // якщо намагаються додати одним махом > 5000
        if (_newShares > 5000) {
            revert("Too many shares");
        }

        uint256 newTotal = uint256(shares) + _newShares;

        // якщо підсумок перевищить 5000 — кастомна помилка з майбутнім значенням
        if (newTotal > 5000) {
            revert TooManyShares(newTotal);
        }

        shares = uint32(newTotal);
    }

    /**
    * Do not modify this function.  It is used to enable the unit test for this pin
    * to check whether or not you have configured your storage variables to make
    * use of packing.
    *
    * If you wish to cheat, simply modify this function to always return `0`
    * I'm not your boss ¯\_(ツ)_/¯
    *
    * Fair warning though, if you do cheat, it will be on the blockchain having been
    * deployed by your wallet....FOREVER!
    */
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload(_slot)
        }
    }

    /**
    * Warning: Anyone can use this function at any time!
    */
    function debugResetShares() public {
        shares = 1000;
    }
}
