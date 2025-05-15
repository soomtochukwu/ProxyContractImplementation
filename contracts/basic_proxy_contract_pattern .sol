// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//
// 🧱 Contract 1: implementation_contract
// This is the original logic contract. It holds a usersBalance mapping and allows users to set their own balance.
//
contract implementation_contract {
    address admin; // Stores the address of the contract deployer (admin)
    mapping(address => uint256) public usersBalance; // Maps user addresses to their balances

    constructor() {
        admin = msg.sender; // Sets the admin as the account that deploys the contract
    }

    // Allows users to increase their balance by a specified value
    function setBalance(uint _value) public {
        usersBalance[msg.sender] += _value;
    }

    // Returns the admin's address
    function viewAdmin() public view returns (address) {
        return admin;
    }

    // Returns the name of the contract
    function name() public view virtual returns (string memory) {
        return "implementation_contract";
    }

    // Returns the symbol of the contract
    function symbol() public view virtual returns (string memory) {
        return "impl";
    }
}

//
// 🔁 Contract 2: proxyContract
// This is the proxy contract that delegates function calls to an external implementation contract using delegatecall.
// It stores the same state variables and allows for upgradeable logic.
//
contract proxyContract {
    address public admin; // Admin who can upgrade the contract
    mapping(address => uint256) public usersBalance; // Storage for user balances (shared with implementation)
    address public implContract; // Address of the current implementation contract

    // On deployment, admin is set and an implementation contract address is provided
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

    // Delegates the call to setBalance(uint256) in the implementation contract
    function setBalance(uint256 _value) public {
        // Delegatecall executes the function in the context of *this* proxy contract's storage
        (bool success, ) = implContract.delegatecall(
            abi.encodeWithSignature("setBalance(uint256)", _value)
        );
        require(success, "FUNCTION CALL FAILED");
    }

    // Allows the admin to upgrade the implementation logic
    function upgradeContract(address _newImpl) external onlyOwner {
        require(_newImpl != address(0), "INVALID ADDRESS");
        implContract = _newImpl;
    }

    // Returns the proxy's name
    function name() public view virtual returns (string memory) {
        return "proxyContract";
    }

    // Returns the proxy's symbol
    function symbol() public view virtual returns (string memory) {
        return "PC";
    }
}

//
// 🔄 Contract 3: upgraded_implementation_contract
// This is a new version of the logic contract. It modifies how balances are set.
// Now, only 90% of the deposited value goes to the user. 10% goes to the admin.
//
contract upgraded_implementation_contract {
    address public admin; // Admin who deployed this logic contract
    mapping(address => uint256) public usersBalance; // Same storage layout as proxyContract

    constructor() {
        admin = msg.sender;
    }

    // Modified logic: 90% goes to the user, 10% is collected by the admin
    function setBalance(uint _value) public {
        uint ninetyPercent = (_value * 90) / 100;
        usersBalance[msg.sender] += ninetyPercent;
        usersBalance[admin] += _value - ninetyPercent;
    }

    // Returns the contract name
    function name() public view virtual returns (string memory) {
        return "upgraded_implementation_contract";
    }

    // Returns the contract symbol
    function symbol() public view virtual returns (string memory) {
        return "uImpl";
    }
}
