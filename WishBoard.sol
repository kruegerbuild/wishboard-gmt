// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title WishBoard
/// @notice Pay a small amount of BOT to post a public, permanent message.
contract WishBoard {
    struct Wish {
        address sender;
        string message;
        uint256 timestamp;
    }

    Wish[] public wishes;

    // Minimum payment required to post, in wei (18 decimals, same as BOT).
    // shorthand for 10^18, it works the same for any EVM chain's native token.
    uint256 public minFee = 0;

    event WishPosted(
        address indexed sender,
        string message,
        uint256 timestamp,
        uint256 wishId
    );

    /// @notice Post a wish. Must send at least minFee BOT with the transaction.
    function postWish(string calldata _message) external payable {
        require(msg.value >= minFee, "Send at least minFee BOT to post");
        require(bytes(_message).length > 0, "Message cannot be empty");
        require(bytes(_message).length <= 280, "Keep it under 280 characters");

        wishes.push(
            Wish({
                sender: msg.sender,
                message: _message,
                timestamp: block.timestamp
            })
        );

        emit WishPosted(msg.sender, _message, block.timestamp, wishes.length - 1);
    }

    /// @notice How many wishes have been posted so far.
    function getWishCount() external view returns (uint256) {
        return wishes.length;
    }

    /// @notice Fetch a single wish by index.
    function getWish(uint256 _index)
        external
        view
        returns (address sender, string memory message, uint256 timestamp)
    {
        require(_index < wishes.length, "Wish does not exist");
        Wish memory w = wishes[_index];
        return (w.sender, w.message, w.timestamp);
    }

    /// @notice Fetch every wish at once — handy for your frontend to render the whole wall.
    function getAllWishes() external view returns (Wish[] memory) {
        return wishes;
    }
}
