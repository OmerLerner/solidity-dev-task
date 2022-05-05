// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "src/Vault.sol";
import {WormholeBridgeAnchor} from "src/interfaces/IWormholeAnchor.sol";
import {AggregatorV3Interface} from "src/interfaces/IAggregatorV3Interface.sol";



contract aUSTVault is Vault {

    IERC20 public aUST;
    WormholeBridgeAnchor public wormholeBridge;
    AggregatorV3Interface public chainlinkAggregator;

    function initialize(
        address _underlying,
        string memory _name,
        string memory _symbol,
        uint256 _adminFee,
        uint256 _callerFee,
        uint256 _maxReinvestStale,
        address _WAVAX,
        address _aUST,
        address _wormholeBridge,
        address _chainlinkAggregator
    ) public {
        initialize(_underlying,
                    _name,
                    _symbol,
                    _adminFee,
                    _callerFee,
                    _maxReinvestStale,
                    _WAVAX
                    );
        aUST = IERC20(_aUST);
        wormholeBridge = WormholeBridgeAnchor(_wormholeBridge);
        chainlinkAggregator = AggregatorV3Interface(_chainlinkAggregator);
        underlying.approve(address(wormholeBridge),MAX_INT);
    }
    //Override Vault.sol functions with wormhole functions
    function _triggerDepositAction(uint256 _amt) internal override{
        wormholeBridge.deposit(address(underlying), _amt);
    }

    function _triggerWithdrawAction(uint256 amtToReturn) internal override {
        wormholeBridge.redeem(address(aUST), amtToReturn);
    }

    function _pullRewards() internal override {
        wormholeBridge.claimRewards();
    }

    //Override Vault.sol functions with Chainlink Aggregator functions
    function receiptPerUnderlying() public override view returns (uint256){
        if (totalSupply == 0) {
            return 10 ** (18 + 18 - underlyingDecimal);
        }
        uint256 _ustAmount = (aUST.balanceOf(address(this)) * getCurrentPrice()) / 1e18;
        return (1e18 * totalSupply) / (_ustAmount / 1e18);
    }

    function underlyingPerReceipt() public override view returns (uint256) {
        if (totalSupply == 0) {
            return 10 ** underlyingDecimal;
        }
        uint256 _ustAmount = (aUST.balanceOf(address(this)) * getCurrentPrice()) / 1e18;
        return (_ustAmount * 1e18) / totalSupply;
    }

    function totalHoldings() public override view returns (uint256) {
        uint256 _ustAmount = (aUST.balanceOf(address(this)) * getCurrentPrice()) / 1e18;
        return _ustAmount;
    }


    //Use chainlink's aggregator to get current price of aUST in UST

    function getCurrentPrice() public view returns (uint256) {
        (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = chainlinkAggregator.latestRoundData();
        return uint256(price);

    }
}
