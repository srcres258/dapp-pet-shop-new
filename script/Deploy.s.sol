// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

import {CustomToken} from "../src/CustomToken.sol";
import {CustomPet} from "../src/CustomPet.sol";
import {Exchange} from "../src/Exchange.sol";
import {TradeFactory} from "../src/TradeFactory.sol";
import {Viewer} from "../src/Viewer.sol";

contract DeployScript is Script {
    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        console.log("Deploying contracts...");

        // 1. Initialise tokens
        CustomToken ct = new CustomToken();
        CustomPet cp = new CustomPet();

        // 2. Initialise exchange
        // Initially: k = 1 ether = 10^18 wei
        Exchange exchange = new Exchange(ct, 1 ether);

        // 3. Initialise trade factory
        TradeFactory tradeFactory = new TradeFactory(address(ct), address(cp));

        // 4. Initialise viewer
        Viewer viewer = new Viewer(cp, tradeFactory);

        // 5. Output deployed addresses
        console.log("Deployment results:");
        console.log("CustomToken: \"", address(ct), "\"");
        console.log("CustomPet: \"", address(cp), "\"");
        console.log("Exchange: \"", address(exchange), "\"");
        console.log("TradeFactory: \"", address(tradeFactory), "\"");
        console.log("Viewer: \"", address(viewer), "\"");

        vm.stopBroadcast();
    }
}
