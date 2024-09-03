// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/contract/SBTNFTContract.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";


contract TestSBTNFTContract is Test {
    address constant SENDER_ADDRESS =
        0x42e8bA50cA28e2B5557F909185ec5ad50f82675e;
   
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;

    address constant OWNER_ADDRESS = 0xC565FC29F6df239Fe3848dB82656F2502286E97d;
    address constant SINGER_ADDRESS = 0xC565FC29F6df239Fe3848dB82656F2502286E97d;

    address private proxy;
    SBTNFTContract private instance;

    function setUp() public {
        console.log("=======setUp============");
        proxy = Upgrades.deployUUPSProxy(
            "SBTNFTContract.sol",
            abi.encodeCall(SBTNFTContract.initialize, OWNER_ADDRESS)
        );

        console.log("uups proxy -> %s", proxy);

        instance = SBTNFTContract(proxy);
        assertEq(instance.owner(), OWNER_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);

        console.log("impl proxy -> %s", implAddressV1);
    }

    function testMint() public {
        // =========================testMint=============================
        console.log("testMint");
        // vm.prank(OWNER_ADDRESS);
        vm.startPrank(OWNER_ADDRESS);

        console.log("setSigner");
        instance.setSigner(SINGER_ADDRESS);
        // assertEq(
        //     instance.signer,SINGER_ADDRESS
            
        // );
        console.log();


        console.log("mintBatch");
        address[] memory params= new address[](2);
        params[0] = 0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9;
        params[1] = 0xC565FC29F6df239Fe3848dB82656F2502286E97d;
        instance.mintBatch(params);
       
        vm.stopPrank();
    }
}
