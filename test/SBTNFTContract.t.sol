// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/contract/SBTNFTContract.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";


contract TestSBTNFTContract is Test {
    address constant SENDER_ADDRESS =
        0x42e8bA50cA28e2B5557F909185ec5ad50f82675e;
    address constant SINGER_ADDRESS =
        0x42e8bA50cA28e2B5557F909185ec5ad50f82675e;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0xb84C357F5F6BB7f36632623105F10cFAD3DA18A6;

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
        SBTNFTContract.MintParam[] memory params;
        params[0] = SBTNFTContract.MintParam({ 
            to: 0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9,
            tokenId: 1});
        params[1] = SBTNFTContract.MintParam({ 
            to: 0x3De70dA882f101b4b3d5f3393c7f90e00E64edB9,
            tokenId: 2});
        params[2] = SBTNFTContract.MintParam({ 
            to: 0xC565FC29F6df239Fe3848dB82656F2502286E97d,
            tokenId: 3});
        instance.mintBatch(params);
       
        vm.stopPrank();
    }
}
