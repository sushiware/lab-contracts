// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract TheHodlIsYours {
    event Hodl(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);

    struct Hodler {
        address account;
        uint256 balance;
    }

    uint256 public constant MAX_HODL_ETH = 100000 ether;
    uint256 public constant THE_DAY = 1893456000; // 2030-01-01 00:00:00(UTC)

    mapping(address => Hodler) public addressToHodlers;
    address[] private hodlers;

    uint256 totalBalance;

    function hodl() public payable {
        require(msg.value > 0, "Hodl amount must be greater than 0");
        require(
            !isFull(msg.value),
            "Total hodl balance must be less than 100000 ether"
        );
        Hodler storage hodler = addressToHodlers[msg.sender];
        if (hodler.account == address(0)) {
            hodler.account = msg.sender;
            hodlers.push(msg.sender);
        }

        hodler.balance += msg.value;
        totalBalance += msg.value;

        emit Hodl(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(
            hasTheTimeCome(),
            "Withdraw can only be made after 2030-01-01 00:00:00(UTC)"
        );

        Hodler storage hodler = addressToHodlers[msg.sender];
        require(hodler.balance >= amount, "Not enough hodl amount");
        hodler.balance -= amount;
        totalBalance -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }

    function isFull(uint256 amount) public view returns (bool) {
        return totalBalance + amount >= MAX_HODL_ETH;
    }

    function hasTheTimeCome() public view returns (bool) {
        return block.timestamp >= THE_DAY;
    }

    function getHodlers()
        external
        view
        returns (address[] memory accounts, uint256[] memory balances)
    {
        accounts = new address[](hodlers.length);
        balances = new uint256[](hodlers.length);
        for (uint256 i = 0; i < hodlers.length; i++) {
            Hodler storage hodler = addressToHodlers[hodlers[i]];
            accounts[i] = hodler.account;
            balances[i] = hodler.balance;
        }
    }
}
