// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Original implementation contract containing core business logic
contract implementation_contract {
    address admin; // Address of the admin (deployer)
    mapping(address => uint256) public usersBalance; // Tracks balances per user

    constructor() {
        // Set the deployer as admin
        admin = msg.sender;
    }

    // Allows users to increase their balance by a specified value
    function setBalance(uint _value) public {
        usersBalance[msg.sender] += _value;
    }

    // Returns the admin's address
    function viewAdmin() public view returns (address) {
        return admin;
    }

    // Returns contract name (for identification)
    function name() public view virtual returns (string memory) {
        return "implementation_contract";
    }

    // Returns contract symbol (for identification)
    function symbol() public view virtual returns (string memory) {
        return "impl";
    }
}

// Proxy contract that delegates calls to an implementation contract using delegatecall
contract proxyContract {
    address public admin; // Admin who can upgrade implementation
    mapping(address => uint256) public usersBalance; // Storage shared with implementation contract
    address public implContract; // Current implementation contract address

    // Set admin and implementation contract during deployment
    constructor(address _implContract) {
        require(_implContract != address(0), "INVALID IMPLEMENTATION ADDRESS");
        admin = msg.sender;
        implContract = _implContract;
    }

    // Modifier to restrict functions to only the admin
    modifier onlyOwner() {
        require(msg.sender == admin, "NOT A VALID CALLER");
        _;
    }

    // Delegates the setBalance call to the current implementation contract
    // delegatecall preserves context (storage, msg.sender)
    function setBalance(uint256 _value) public {
        (bool success, ) = implContract.delegatecall(
            abi.encodeWithSignature("setBalance(uint256)", _value)
        );
        require(success, "FUNCTION CALL FAILED");
    }

    // Allows admin to upgrade implementation to new contract address
    function upgradeContract(address _newImpl) external onlyOwner {
        require(_newImpl != address(0), "INVALID ADDRESS");
        implContract = _newImpl;
    }

    // Proxy contract identification name
    function name() public view virtual returns (string memory) {
        return "proxyContract";
    }

    // Proxy contract symbol
    function symbol() public view virtual returns (string memory) {
        return "PC";
    }
}

// New upgraded implementation with different setBalance logic
contract upgraded_implementation_contract {
    address public admin; // Admin address
    mapping(address => uint256) public usersBalance; // User balances

    constructor() {
        // Admin set at deployment
        admin = msg.sender;
    }

    // Modified setBalance: instead of crediting caller, credits admin balance by 100x value
    // Demonstrates how logic can change when upgrading implementation
    function setBalance(uint _value) public {
        usersBalance[admin] += _value * 100;
    }

    // Returns new implementation contract's name
    function name() public view virtual returns (string memory) {
        return "upgraded_implementation_contract";
    }

    // Returns new implementation contract's symbol
    function symbol() public view virtual returns (string memory) {
        return "uImpl";
    }
}
