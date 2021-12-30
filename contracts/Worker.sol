// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Worker {
    event LogNewSalaryRegistered(uint256 salaryNumber);
    event LogSalaryBooked(
        uint256 salaryNumber,
        address worker,
        uint256 bookedUntil
    );
    event LogSSalaryDeregistered(uint256 salaryNumber);
    event LogWithdrawn(uint256 amount);

    address public owner;
    address public salaryToken;
    uint256 public salaryPerDay;

    modifier onlyOwner() {
        require(msg.sender == owner, "ERROR::AUTH");
        _;
    }

    struct SSalary {
        bool available;
        address worker;
        uint256 bookedUntil;
    }
 
    mapping(uint256 => SSalary) public numberOfDaysSalary;

    constructor(
        address owner_,
        address salaryToken_,
        uint256 salaryPerDay_
    ) {
        owner = owner_;
        salaryToken = salaryToken_;
        salaryPerDay = salaryPerDay_;
    }

    function registerSSalary(uint256 counterDays_) external onlyOwner {  
        require(counterDays_ > 0 && numberOfDaysSalary[counterDays_].available == false, "ERROR::ALREADY_AVAILABLE");
        numberOfDaysSalary[counterDays_].available = true;
        emit LogNewSalaryRegistered(counterDays_);
    }

    function deregisterSSalary(uint256 counterDays_) external onlyOwner {
        require(
            numberOfDaysSalary[counterDays_].available == true &&
            numberOfDaysSalary[counterDays_].bookedUntil < block.timestamp,
            "ERROR::INVALID_ACTION"
        );

        delete numberOfDaysSalary[counterDays_];

        emit LogSSalaryDeregistered(counterDays_);
    }

    function pay(uint256 counterDays_, uint256 days_) external {
        require(
            days_ > 0 && days_ <= 30 &&
            numberOfDaysSalary[counterDays_].available == true &&
            numberOfDaysSalary[counterDays_].bookedUntil <= block.timestamp,
            "ERROR::NOT_AVAILABLE"
        );

        uint256 total = salaryPerDay * days_;

        numberOfDaysSalary[counterDays_].worker = msg.sender;
        numberOfDaysSalary[counterDays_].bookedUntil = block.timestamp + days_ * 1 days;

        IERC20(salaryToken).transferFrom(msg.sender, address(this), total);

        emit LogSalaryBooked(counterDays_, msg.sender, numberOfDaysSalary[counterDays_].bookedUntil);
    }

    function salaryIsAvailable(uint256 counterDays_, address currentWorker_) external view returns (bool) {
        return numberOfDaysSalary[counterDays_].worker == currentWorker_ && block.timestamp < numberOfDaysSalary[counterDays_].bookedUntil;
    }

    function withdraw() external onlyOwner {
        uint256 balance = IERC20(salaryToken).balanceOf(address(this));
        IERC20(salaryToken).transferFrom(address(this), owner, balance);
        emit LogWithdrawn(balance);
    }
}
