pragma solidity 0.8.10;

interface WormholeBridgeAnchor{

    function deposit(address token, uint256 amount) external;

    function redeem(address token, uint256 amount) external;

    function claimRewards() external;

}