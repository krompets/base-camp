// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/* ============ Бібліотека SillyStringUtils ============ */
library SillyStringUtils {
    struct Haiku {
        string line1;
        string line2;
        string line3;
    }

    function shruggie(string memory _input) internal pure returns (string memory) {
        return string.concat(_input, unicode" 🤷");
    }
}

/* ============ Контракт ImportsExercise ============ */
contract ImportsExercise {
    using SillyStringUtils for string;

    // Публічна змінна для зберігання хайку
    SillyStringUtils.Haiku public haiku;

    /**
     * @dev Зберігає три рядки як хайку.
     */
    function saveHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) public {
        haiku.line1 = _line1;
        haiku.line2 = _line2;
        haiku.line3 = _line3;
    }

    /**
     * @dev Повертає весь хайку як структуру типу Haiku.
     */
    function getHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return haiku;
    }

    /**
     * @dev Створює копію хайку, додаючи 🤷 до кінця третього рядка.
     * Не змінює оригінальний хайку.
     */
    function shruggieHaiku() public view returns (SillyStringUtils.Haiku memory) {
        SillyStringUtils.Haiku memory newHaiku = haiku;
        newHaiku.line3 = newHaiku.line3.shruggie();
        return newHaiku;
    }
}
