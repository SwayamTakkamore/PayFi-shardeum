// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TipJar {
    event TipSent(
        address indexed from,
        address indexed to,
        uint256 amount,
        string message,
        uint256 timestamp
    );

    struct Tip {
        address from;
        address to;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    mapping(address => Tip[]) public tipsSent;
    mapping(address => Tip[]) public tipsReceived;
    mapping(address => uint256) public totalSent;
    mapping(address => uint256) public totalReceived;

    function sendTip(address _to, string memory _message) external payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        require(_to != address(0), "Invalid recipient address");
        require(_to != msg.sender, "Cannot tip yourself");

        Tip memory newTip = Tip({
            from: msg.sender,
            to: _to,
            amount: msg.value,
            message: _message,
            timestamp: block.timestamp
        });

        tipsSent[msg.sender].push(newTip);
        tipsReceived[_to].push(newTip);
        
        totalSent[msg.sender] += msg.value;
        totalReceived[_to] += msg.value;

        // Transfer the tip
        payable(_to).transfer(msg.value);

        emit TipSent(msg.sender, _to, msg.value, _message, block.timestamp);
    }

    function getTipsSent(address _user) external view returns (Tip[] memory) {
        return tipsSent[_user];
    }

    function getTipsReceived(address _user) external view returns (Tip[] memory) {
        return tipsReceived[_user];
    }

    function getTipCount(address _user) external view returns (uint256 sent, uint256 received) {
        return (tipsSent[_user].length, tipsReceived[_user].length);
    }

    function hasSentTips(address _user) external view returns (bool) {
        return tipsSent[_user].length > 0;
    }

    function hasReceivedTips(address _user) external view returns (bool) {
        return tipsReceived[_user].length > 0;
    }
}
