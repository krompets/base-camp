// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title ControlStructures
/// @notice Демонстрація керуючих конструкцій: FizzBuzz та Do Not Disturb
contract ControlStructures {
    // ---- FizzBuzz ----
    /// @dev Повертає "Fizz", "Buzz", "FizzBuzz" або "Splat" за класичними правилами
    function fizzBuzz(uint _number) external pure returns (string memory) {
        bool fizz = _number % 3 == 0;
        bool buzz = _number % 5 == 0;

        if (fizz && buzz) return "FizzBuzz";
        if (fizz) return "Fizz";
        if (buzz) return "Buzz";
        return "Splat";
    }

    // ---- Do Not Disturb ----
    error AfterHours(uint256 providedTime);

    /// @dev Якщо _time >= 2400 — тригеримо panic (assert)
    /// Якщо _time > 2200 або _time < 800 — revert з кастомним AfterHours(_time)
    /// Якщо 1200..1259 — revert з повідомленням "At lunch!"
    /// Якщо 800..1199 — "Morning!"
    /// Якщо 1300..1799 — "Afternoon!"
    /// Якщо 1800..2200 — "Evening!"
    function doNotDisturb(uint _time) external pure returns (string memory) {
        if (_time >= 2400) {
            assert(false); // Panic(0x01)
        } else if (_time > 2200 || _time < 800) {
            revert AfterHours(_time);
        } else if (_time >= 1200 && _time <= 1259) {
            revert("At lunch!");
        } else if (_time >= 800 && _time <= 1199) {
            return "Morning!";
        } else if (_time >= 1300 && _time <= 1799) {
            return "Afternoon!";
        } else if (_time >= 1800 && _time <= 2200) {
            return "Evening!";
        }

        // На випадок нестандартних значень типу 1260..1299 (не обумовлено в завданні)
        revert("Unsupported time");
    }
}
