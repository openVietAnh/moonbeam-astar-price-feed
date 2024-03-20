pragma solidity ^0.8.0;

import "contracts/Aggregator.sol";
import "contracts/XcmTransactorV3.sol";

contract CustomPrice {
    address public constant BTC_TO_USD_ADDRESS =
    0xa39d8684B8cd74821db73deEB4836Ea46E145300;

    address public constant XCM_PRECOMPILE_ADDRESS =
    0x0000000000000000000000000000000000000817;

    function getPrice() external returns (int256 answer) {

        // Fetch price
        int256 result;
        (, result, , ,) = AggregatorV3Interface(BTC_TO_USD_ADDRESS).latestRoundData();

        bytes[] memory interior = new bytes[](1);
        // Shibuya ChainId: 1000
        interior[0] = bytes.concat(hex"00", bytes4(uint32(1000)));
        // This MultiLocation only works for mainnet
        // TODO: Find the correct MultiAllocation for testnet
        // Moonbeam -> Alphanet Relay Chain -> ??? -> Tokio Relay Chain -> Shibuya
        XcmTransactorV3.Multilocation memory destination = XcmTransactorV3.Multilocation({
            parents: 1,
            interior: interior
        });

        // TODO: Find the correct address for SBY Token
        address feeLocationAddress = 
        0xa39d8684B8cd74821db73deEB4836Ea46E145300;

        // TODO: Find the suitable value using polkadot.js online tool
        XcmTransactorV3.Weight memory transactRequiredWeightAtMost = XcmTransactorV3.Weight({
            refTime: 1000000000, 
            proofSize: 5000
        });

        bytes memory _calldata = bytes.concat("0xd80deced", abi.encode(result));

        // TODO: Find the suitable value using polkadot.js online tool
        uint256 feeAmount = 100000000;

        // TODO: Find the suitable value using polkadot.js online tool
        XcmTransactorV3.Weight memory overallWeight = XcmTransactorV3.Weight({
            refTime: 18446744073709551615,
            proofSize: 10000
        });

        // Send XCM for remote execution of store(int256 result) on Shibuya network
        XcmTransactorV3(XCM_PRECOMPILE_ADDRESS).transactThroughSigned(
            destination,
            feeLocationAddress,
            transactRequiredWeightAtMost,
            _calldata,
            feeAmount,
            overallWeight,
            true // refund
        );

        return result;
    }
}