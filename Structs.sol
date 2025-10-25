// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GarageManager {
    // --- Types ---
    struct Car {
        string make;
        string model;
        string color;
        uint256 numberOfDoors;
    }

    // --- Storage ---
    mapping(address => Car[]) public garage;

    // --- Errors ---
    error BadCarIndex(uint256 index);

    // --- Add Car Garage ---
    function addCar(
        string calldata _make,
        string calldata _model,
        string calldata _color,
        uint256 _numberOfDoors
    ) external {
        garage[msg.sender].push(
            Car({make: _make, model: _model, color: _color, numberOfDoors: _numberOfDoors})
        );
    }

    // --- Get All Cars for the Calling User ---
    function getMyCars() external view returns (Car[] memory) {
        return garage[msg.sender];
    }

    // --- Get All Cars for Any User ---
    function getUserCars(address _user) external view returns (Car[] memory) {
        return garage[_user];
    }

    // --- Update Car ---
    function updateCar(
        uint256 _index,
        string calldata _make,
        string calldata _model,
        string calldata _color,
        uint256 _numberOfDoors
    ) external {
        if (_index >= garage[msg.sender].length) {
            revert BadCarIndex(_index);
        }
        garage[msg.sender][_index] = Car({
            make: _make,
            model: _model,
            color: _color,
            numberOfDoors: _numberOfDoors
        });
    }

    // --- Reset My Garage ---
    function resetMyGarage() public {
        delete garage[msg.sender];
    }
}
