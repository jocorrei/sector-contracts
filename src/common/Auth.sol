// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract Auth is AccessControl {
	event OwnershipTransferInitiated(address owner, address pendingOwner);
	event OwnershipTransferred(address oldOwner, address newOwner);

	////////// CONSTANTS //////////

	/// Update vault params, perform time-sensitive operations, set manager
	bytes32 public constant GUARDIAN = keccak256("GUARDIAN");

	/// Hot-wallet bots that route funds between vaults, rebalance and harvest strategies
	bytes32 public constant MANAGER = keccak256("MANAGER");

	/// Add and remove vaults and strategies and other critical operations behind timelock
	/// Default admin role
	/// There should only be one owner, so it is not a role
	address public owner;
	address public pendingOwner;

	modifier onlyOwner() {
		require(msg.sender == owner, "ONLY_OWNER");
		_;
	}

	constructor(
		address _owner,
		address guardian,
		address manager
	) {
		/// Set up the roles
		// owner can manage all roles
		owner = _owner;
		emit OwnershipTransferred(address(0), owner);

		// TODO do we want cascading roles like this?
		_grantRole(DEFAULT_ADMIN_ROLE, owner);
		_grantRole(GUARDIAN, owner);
		_grantRole(GUARDIAN, guardian);
		_grantRole(MANAGER, owner);
		_grantRole(MANAGER, guardian);
		_grantRole(MANAGER, manager);

		/// Allow the guardian role to manage manager
		_setRoleAdmin(MANAGER, GUARDIAN);
	}

	// ----------- Ownership -----------

	/// @dev Init transfer of ownership of the contract to a new account (`_pendingOwner`).
	/// @param _pendingOwner pending owner of contract
	/// Can only be called by the current owner.
	function transferOwnership(address _pendingOwner) external onlyOwner {
		pendingOwner = _pendingOwner;
		emit OwnershipTransferInitiated(owner, pendingOwner);
	}

	/// @dev Accept transfer of ownership of the contract.
	/// Can only be called by the pendingOwner.
	function acceptOwnership() external {
		require(msg.sender == pendingOwner, "ONLY_PENDING_OWNER");
		address oldOwner = owner;
		owner = pendingOwner;

		// revoke the DEFAULT ADMIN ROLE from prev owner
		_revokeRole(DEFAULT_ADMIN_ROLE, oldOwner);
		_revokeRole(GUARDIAN, oldOwner);
		_revokeRole(MANAGER, oldOwner);

		_grantRole(DEFAULT_ADMIN_ROLE, owner);
		_grantRole(GUARDIAN, owner);
		_grantRole(MANAGER, owner);

		emit OwnershipTransferred(oldOwner, owner);
	}
}
