// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

import {CustomToken} from "../src/CustomToken.sol";
import {CustomPet} from "../src/CustomPet.sol";
import {Committee} from "../src/Committee.sol";
import {CommitteeTreasury} from "../src/CommitteeTreasury.sol";
import {ProposalFactory} from "../src/ProposalFactory.sol";
import {Exchange} from "../src/Exchange.sol";
import {TradeFactory} from "../src/TradeFactory.sol";
import {Viewer} from "../src/Viewer.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        console.log("Deploying contracts...");

        // 1. Initialise tokens
        CustomToken ct = new CustomToken();
        CustomPet cp = new CustomPet();

        // 2. Initialise committee and its treasury
        Committee committee = new Committee();
        CommitteeTreasury treasury = new CommitteeTreasury(address(ct), address(cp), committee);
        committee.setTreasury(treasury);

        // 3. Initialise proposal factory
        ProposalFactory proposalFactory = new ProposalFactory(committee, cp, treasury);

        // 4. Initialise exchange
        Exchange exchange = new Exchange(ct, proposalFactory, 1); // initial k = 1
        proposalFactory.setExchange(exchange);

        // 5. Initialise trade factory
        TradeFactory tradeFactory = new TradeFactory(address(ct), address(cp));

        // 6. Initialise viewer
        Viewer viewer = new Viewer(cp, tradeFactory, proposalFactory);

        // 7. Output deployed addresses
        console.log("Deployment finished.");
        console.log("CustomToken deployed at:", address(ct));
        console.log("CustomPet deployed at:", address(cp));
        console.log("Committee deployed at:", address(committee));
        console.log("CommitteeTreasury deployed at:", address(treasury));
        console.log("ProposalFactory deployed at:", address(proposalFactory));
        console.log("Exchange deployed at:", address(exchange));
        console.log("TradeFactory deployed at:", address(tradeFactory));
        console.log("Viewer deployed at:", address(viewer));

        vm.stopBroadcast();
    }
}
