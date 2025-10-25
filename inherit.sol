// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// -------- Employee (abstract) --------
abstract contract Employee {
    uint public idNumber;
    uint public managerId;

    constructor(uint _idNumber, uint _managerId) {
        idNumber = _idNumber;
        managerId = _managerId;
    }

    function getAnnualCost() public view virtual returns (uint);
}

// -------- Salaried --------
contract Salaried is Employee {
    uint public annualSalary;

    constructor(uint _annualSalary, uint _idNumber, uint _managerId)
        Employee(_idNumber, _managerId)
    {
        annualSalary = _annualSalary;
    }

    function getAnnualCost() public view override returns (uint) {
        return annualSalary;
    }
}

// -------- Hourly --------
contract Hourly is Employee {
    uint public hourlyRate;

    constructor(uint _hourlyRate, uint _idNumber, uint _managerId)
        Employee(_idNumber, _managerId)
    {
        hourlyRate = _hourlyRate;
    }

    // 2080 годин на рік
    function getAnnualCost() public view override returns (uint) {
        return hourlyRate * 2080;
    }
}

// -------- Manager --------
contract Manager {
    uint[] public employeeIds;

    function addReport(uint _employeeId) external {
        employeeIds.push(_employeeId);
    }

    function resetReports() external {
        delete employeeIds;
    }
}

// -------- Salesperson (inherits Hourly) --------
contract Salesperson is Hourly {
    constructor(uint _hourlyRate, uint _idNumber, uint _managerId)
        Hourly(_hourlyRate, _idNumber, _managerId)
    {}
}

// -------- EngineeringManager (inherits Salaried and Manager) --------
contract EngineeringManager is Salaried, Manager {
    constructor(uint _annualSalary, uint _idNumber, uint _managerId)
        Salaried(_annualSalary, _idNumber, _managerId)
    {}
}

// -------- Given wrapper for submission --------
contract InheritanceSubmission {
    address public salesPerson;
    address public engineeringManager;

    constructor(address _salesPerson, address _engineeringManager) {
        salesPerson = _salesPerson;
        engineeringManager = _engineeringManager;
    }
}
