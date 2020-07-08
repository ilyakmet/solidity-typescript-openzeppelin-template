// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipient.sol";

contract Recipient is GSNRecipientUpgradeSafe {
    address public target;

    address private _owner;

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(address _target) public initializer {
        target = _target;
        _owner = msg.sender;
        __GSNRecipient_init();
    }

    fallback() external {
        target.call(msg.data);
    }

    function setOwner(address newOwner) external {
        _owner = newOwner;
    }

    function deposit() external payable {
        IRelayHub(getHubAddr()).depositFor(address(this));
    }

    function withdraw(uint256 amount, address payable payee)
        external
        payable
        onlyOwner
    {
        _withdrawDeposits(amount, payee);
    }

    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    ) external override view returns (uint256, bytes memory) {
        (
            relay,
            from,
            encodedFunction,
            transactionFee,
            gasPrice,
            gasLimit,
            nonce,
            approvalData,
            maxPossibleCharge
        );
        return _approveRelayedCall();
    }

    // We won't do any pre or post processing, so leave _preRelayedCall and _postRelayedCall empty
    function _preRelayedCall(bytes memory context)
        internal
        override
        returns (bytes32)
    {}

    function _postRelayedCall(
        bytes memory context,
        bool,
        uint256 actualCharge,
        bytes32
    ) internal override {}
}
