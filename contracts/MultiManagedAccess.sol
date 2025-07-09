// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MultiManagedAccess {
    uint constant MANAGER_NUMBERS = 5;
    uint immutable BACKUP_MANAGER_NUMBERS;

    address public owner;
    address[MANAGER_NUMBERS] public managers;
    bool[MANAGER_NUMBERS] public confirmed;

    uint public rewardPerBlock;

    constructor(address _owner, address[] memory _managers, uint _manager_numbers) {
        require(_manager_numbers == _managers.length, "size unmatched");
        require(_manager_numbers >= 3, "at least 3 managers required");
        owner = _owner;
        BACKUP_MANAGER_NUMBERS = _manager_numbers;
        for (uint i = 0; i < _manager_numbers; i++) {
            managers[i] = _managers[i];
        }
    }

    modifier onlyAllConfirmed() {
        require(isManager(msg.sender), "You are not a manager");
        require(allConfirmed(), "Not all confirmed yet");
        _;
        reset();
    }

    function isManager(address _addr) internal view returns (bool) {
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            if (managers[i] == _addr) return true;
        }
        return false;
    }

    function allConfirmed() internal view returns (bool) {
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            if (!confirmed[i]) return false;
        }
        return true;
    }

    function reset() internal {
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            confirmed[i] = false;
        }
    }

    function confirm() public virtual {
        bool found = false;
        for (uint i = 0; i < MANAGER_NUMBERS; i++) {
            if (managers[i] == msg.sender) {
                confirmed[i] = true;
                found = true;
                break;
            }
        }
        require(found, "You are not a manager");
    }

    function setRewardPerBlock(uint256 _amount) public virtual onlyAllConfirmed {
        rewardPerBlock = _amount;
    }
}
