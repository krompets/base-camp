// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ErrorTriageExercise {
    /**
     * @dev Обчислює різницю між кожним числом і його сусідом (a з b, b з c тощо)
     * та повертає масив uint з абсолютними різницями кожної пари.
     * 
     * @param _a Перше беззнакове ціле число.
     * @param _b Друге беззнакове ціле число.
     * @param _c Третє беззнакове ціле число.
     * @param _d Четверте беззнакове ціле число.
     * 
     * @return results Масив, який містить абсолютні різниці між кожною парою чисел.
     */
    function diffWithNeighbor(
        uint _a,
        uint _b,
        uint _c,
        uint _d
    ) public pure returns (uint[] memory) {
        uint[] memory results = new uint[](3);

        results[0] = _a > _b ? _a - _b : _b - _a;
        results[1] = _b > _c ? _b - _c : _c - _b;
        results[2] = _c > _d ? _c - _d : _d - _c;

        return results;
    }
    /**
     * @dev Змінює базове значення на величину модифікатора.
     * Базове значення завжди >= 1000. Модифікатор може бути в діапазоні від -100 до 100.
     * 
     * @param _base Базове значення, яке буде змінено.
     * @param _modifier Значення, на яке змінюється база.
     * 
     * @return returnValue Нове значення бази після модифікації.
     */
    function applyModifier(
        uint _base,
        int _modifier
    ) public pure returns (uint returnValue) {
        // Застосування модифікатора до бази
        if(_modifier > 0) {
            return _base + uint(_modifier);
        }
        return _base - uint(-_modifier);
    }

    uint[] arr;

    /**
     * @dev Видаляє останній елемент з масиву та повертає його значення.
     */
    function popWithReturn() public returns (uint returnNum) {
        if(arr.length > 0) {
            uint result = arr[arr.length - 1];
            arr.pop();
            return result;
        }
    }

    // Нижче — допоміжні функції
    function addToArr(uint _num) public {
        arr.push(_num);
    }

    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function resetArr() public {
        delete arr;
    }
}
