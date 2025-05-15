# 🧠 Proxy Pattern Explanation

This project demonstrates a **basic proxy contract pattern** in Solidity, which is a common design used to enable **upgradability** in smart contracts. The proxy pattern separates the contract's **logic** from its **data**, allowing the logic (implementation) to be upgraded without changing the contract address or losing stored data.

## 🏗️ Contracts Overview

There are **three contracts** in this project:

1. `implementation_contract`: The original logic contract.
2. `proxyContract`: The proxy contract that delegates calls to the logic contract.
3. `upgraded_implementation_contract`: A new version of the logic with modified behavior.

## 🔁 How the Proxy Pattern Works

The `proxyContract` stores all the state variables (e.g., `usersBalance`) and delegates function calls to an external `implContract` using `delegatecall`. This low-level function runs the code of another contract **in the context of the proxy's storage**.

```solidity
(bool success, ) = implContract.delegatecall(
    abi.encodeWithSignature("setBalance(uint256)", _value)
);
```

Here’s how the system works:

1. **Deployment**:

   - First, deploy an `implementation_contract`.
   - Then deploy the `proxyContract`, passing the address of the `implementation_contract` to it.

2. **Interaction**:

   - When a user calls `proxyContract.setBalance`, the proxy uses `delegatecall` to execute the function inside the implementation contract **while modifying the proxy's storage**.

3. **Upgrade**:
   - The proxy supports logic upgrades via `upgradeContract(address _newImpl)`, which allows the admin to set a new implementation contract (e.g., `upgraded_implementation_contract`).
   - The storage remains the same, but the logic changes.

## ⚙️ Key Features

| Feature              | Description                                          |
| -------------------- | ---------------------------------------------------- |
| `delegatecall`       | Executes implementation code in the proxy's context. |
| `usersBalance`       | Stored in the proxy to persist across upgrades.      |
| `upgradeContract()`  | Admin-only function to upgrade logic.                |
| `onlyOwner` modifier | Restricts upgrade access to the admin.               |

## 🔄 Upgrade Example

**Before Upgrade**  
User calls `setBalance(100)`  
→ Adds `100` to their balance.

**After Upgrade**  
Admin upgrades to `upgraded_implementation_contract`.  
User calls `setBalance(100)`  
→ Adds `90` to user, `10` to admin.

## ⚠️ Limitations

- **No fallback**: The proxy contract does not implement a fallback function, so only specific delegated functions work.
- **Manual ABI syncing**: The proxy’s interface must be known beforehand since it doesn't dynamically forward all calls.
- **Storage layout must match**: The implementation and proxy must have the same storage layout to avoid data corruption.

## 📌 Why Use Proxy Pattern?

- **Upgradability**: Avoid redeploying and migrating state.
- **Gas efficiency**: Share logic across multiple proxies.
- **Security**: Bug fixes without contract redeployment.

## 🛠️ Technologies

- Solidity `^0.8.18`
- EVM's `delegatecall` for low-level delegation

## 📚 Resources

- [OpenZeppelin Transparent Proxy Pattern](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies)
- [Solidity delegatecall Documentation](https://docs.soliditylang.org/en/v0.8.18/introduction-to-smart-contracts.html#delegatecall-callcode-and-libraries)

---

This implementation is a simplified educational version of the proxy pattern, useful for understanding how contract upgrades and logic delegation work on Ethereum.
