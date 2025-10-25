// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ErrorTriageExercise {
    /**
     * Finds the absolute difference between neighbors: |a-b|, |b-c|, |c-d|
     * Уникаємо підпере-току (revert у 0.8.x) через від’ємне віднімання.
     */
    function diffWithNeighbor(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint;
        results[0] = _absDiff(_a, _b);
        results[1] = _absDiff(_b, _c);
        results[2] = _absDiff(_c, _d);
        return results;
    }

    function _absDiff(uint x, uint y) private pure returns (uint) {
        return x >= y ? (x - y) : (y - x);
    }

    /**
     * Changes the _base by the value of _modifier.
     * За умовою: base >= 1000, modifier ∈ [-100, 100].
     * Обробляємо знак без небезпечних кастів.
     */
    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (uint) {
        require(_base >= 1000, "base < 1000");
        require(_modifier >= -100 && _modifier <= 100, "modifier out of range");

        if (_modifier < 0) {
            uint dec = uint(-_modifier);          // величина зменшення
            require(dec <= _base, "result < 0");  // захист від піднульового результату
            return _base - dec;
        } else {
            return _base + uint(_modifier);
        }
    }

    /**
     * Pop the last element and return it.
     * Старий код лише робив delete (залишає довжину та повертає 0).
     */
    uint[] arr;

    function popWithReturn() public returns (uint) {
        require(arr.length > 0, "empty array");
        uint lastIndex = arr.length - 1;
        uint val = arr[lastIndex];
        arr.pop();               // реально зменшуємо довжину
        return val;              // повертаємо видалене значення
    }

    // --- Utility (як було) ---
    function addToArr(uint _num) public { arr.push(_num); }
    function getArr() public view returns (uint[] memory) { return arr; }
    function resetArr() public { delete arr; }
}
