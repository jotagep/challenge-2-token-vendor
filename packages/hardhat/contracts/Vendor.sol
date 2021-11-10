pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    YourToken yourToken;

    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountETH, uint256 amountToken);
    event SellTokens(address seller, uint256 amountToken, uint256 amountETH);

    constructor(address tokenAddress) public {
        yourToken = YourToken(tokenAddress);
    }

    //ToDo: create a payable buyTokens() function:
    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "Send ETH to buy tokens");

        uint256 amountToBuy = msg.value * tokensPerEth;
        uint256 vendorBalance = yourToken.balanceOf(address(this));

        require(vendorBalance >= amountToBuy, "Vendor has not enough balance");

        bool sent = yourToken.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);

        return amountToBuy;
    }

    //ToDo: create a sellTokens() function:
    function sellTokens(uint256 tokenAmount)
        public
        returns (uint256 ethAmount)
    {
        require(tokenAmount > 0, "Introduce an amount greater than zero");

        uint256 userBalance = yourToken.balanceOf(msg.sender);
        require(userBalance >= tokenAmount, "You don't have enough tokens :(");

        uint256 amountETHToReceive = tokenAmount / tokensPerEth;
        uint256 vendorETHBalance = address(this).balance;
        require(
            vendorETHBalance >= amountETHToReceive,
            "Vendor has not enough funds to accept your request :("
        );

        bool sent = yourToken.transferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );
        require(sent, "Failed transfer from user to vendor");

        (sent, ) = msg.sender.call{value: amountETHToReceive}("");
        require(sent, "Failed to send ETH to the user");

        emit SellTokens(msg.sender, tokenAmount, amountETHToReceive);

        return amountETHToReceive;
    }

    //ToDo: create a withdraw() function that lets the owner, you can
    //use the Ownable.sol import above:
}
