//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "../PositionFixtures.sol";
import "./StubFixtures.sol";

/// @dev relies on StubETHUSDCFixtures._configureStubs()
abstract contract CollateralManagementETHUSDCFixtures is PositionFixtures {
    function testAddCollateral() public {
        // Open position
        (PositionId positionId, ModifyCostResult memory result) = _openPosition(2 ether, 800e6);

        Position memory position = contango.position(positionId);
        assertEqDecimal(position.openQuantity, 2 ether, quoteDecimals, "open openQuantity");
        assertApproxEqAbsDecimal(position.openCost, 1402.134078e6, costBuffer, quoteDecimals, "open openCost");
        assertEqDecimal(position.protocolFees, 2.103202e6, quoteDecimals, "open protocolFees");
        assertEqDecimal(position.collateral, 797.896798e6, quoteDecimals, "open collateral");

        _assertNoBalances(trader, "trader");

        // Add collateral
        result = _modifyCollateral(positionId, 100e6);
        assertEqDecimal(result.collateralUsed, 100e6, quoteDecimals, "add collateral result.collateralUsed");
        assertEqDecimal(result.cost, 10.497237e6, quoteDecimals, "add collateral result.cost");
        assertEqDecimal(result.debtDelta, -110.497237e6, quoteDecimals, "add collateral result.debtDelta");

        position = contango.position(positionId);
        assertEqDecimal(position.openQuantity, 2 ether, quoteDecimals, "add collateral openQuantity");

        // open cost - cost
        // 1402.134078 - 10.497237 = 1391.636842
        assertApproxEqAbsDecimal(position.openCost, 1391.636842e6, costBuffer, quoteDecimals, "add collateral openCost");

        // 0.15% debtDelta
        // 110.497237 * 0.0015 = 0.165746 fees (rounded up)
        // open fees + fees
        // 2.103202 + 0.165746 = 2.268948 (rounded up)
        assertEqDecimal(position.protocolFees, 2.268948e6, quoteDecimals, "add collateral protocolFees");

        // open collateral + collateral - fee
        // 797.896798 + 100 - 0.165746 = 897.731052
        assertEqDecimal(position.collateral, 897.731052e6, quoteDecimals, "add collateral collateral");

        _assertNoBalances(trader, "trader");
    }

    function testRemoveCollateral() public {
        // Open position
        (PositionId positionId, ModifyCostResult memory result) = _openPosition(2 ether, 800e6);

        Position memory position = contango.position(positionId);
        assertEqDecimal(position.openQuantity, 2 ether, quoteDecimals, "open openQuantity");
        assertApproxEqAbsDecimal(position.openCost, 1402.134079e6, costBuffer, quoteDecimals, "open openCost");
        assertEqDecimal(position.protocolFees, 2.103202e6, quoteDecimals, "open protocolFees");
        assertEqDecimal(position.collateral, 797.896798e6, quoteDecimals, "open collateral");

        _assertNoBalances(trader, "trader");

        // Remove collateral
        result = _modifyCollateral(positionId, -100e6);
        assertEqDecimal(result.collateralUsed, -100e6, quoteDecimals, "remove collateral result.collateralUsed");
        assertApproxEqAbsDecimal(result.cost, -11.731843e6, costBuffer, quoteDecimals, "remove collateral result.cost");
        assertApproxEqAbsDecimal(
            result.debtDelta, 111.731843e6, costBuffer, quoteDecimals, "remove collateral result.debtDelta"
        );

        position = contango.position(positionId);
        assertEqDecimal(position.openQuantity, 2 ether, quoteDecimals, "remove collateral openQuantity");

        // open cost - cost
        // 1402.134079 + 11.731843 = 1413.865922
        assertApproxEqAbsDecimal(
            position.openCost, 1413.865922e6, costBuffer, quoteDecimals, "remove collateral openCost"
        );

        // 0.15% debtDelta
        // 111.731843 * 0.0015 = 0.167598 fees (rounded up)
        // open fees + fees
        // 2.103202 + 0.167598 = 2.2708 (rounded up)
        assertEqDecimal(position.protocolFees, 2.2708e6, quoteDecimals, "remove collateral protocolFees");

        // open collateral + collateral - fee
        // 797.896798 - 100 - 0.167598 = 697.7292
        assertEqDecimal(position.collateral, 697.7292e6, quoteDecimals, "remove collateral collateral");

        assertEqDecimal(quote.balanceOf(trader), 100e6, quoteDecimals, "trader USDC balance");
    }
}
