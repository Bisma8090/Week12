// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMintable {
    function mint(address to, uint256 amount) external;
}

/**
 * @title TokenFaucet
 * @dev Gives 100 PLAT per claim, once every 24 hours per address
 */
contract TokenFaucet {
    IMintable public platformToken;
    address   public owner;

    uint256 public constant CLAIM_AMOUNT = 100 * 10 ** 18; // 100 PLAT
    uint256 public constant COOLDOWN     = 24 hours;

    mapping(address => uint256) public lastClaimed;
    mapping(address => uint256) public totalClaimed;

    event TokensClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }

    constructor(address _platformToken) {
        platformToken = IMintable(_platformToken);
        owner = msg.sender;
    }

    /// @notice Claim 100 PLAT — once per 24 h
    function claimTokens() external {
        require(
            block.timestamp >= lastClaimed[msg.sender] + COOLDOWN,
            "Cooldown: wait 24 hours"
        );
        lastClaimed[msg.sender]   = block.timestamp;
        totalClaimed[msg.sender] += CLAIM_AMOUNT;
        platformToken.mint(msg.sender, CLAIM_AMOUNT);
        emit TokensClaimed(msg.sender, CLAIM_AMOUNT);
    }

    /// @notice Seconds until user can claim again (0 = can claim now)
    function getTimeUntilNextClaim(address user) external view returns (uint256) {
        uint256 next = lastClaimed[user] + COOLDOWN;
        return block.timestamp >= next ? 0 : next - block.timestamp;
    }

    /// @notice Lifetime PLAT claimed by user
    function getTotalClaimed(address user) external view returns (uint256) {
        return totalClaimed[user];
    }

    function canClaim(address user) external view returns (bool) {
        return block.timestamp >= lastClaimed[user] + COOLDOWN;
    }

    function updateToken(address newToken) external onlyOwner {
        platformToken = IMintable(newToken);
    }
}
