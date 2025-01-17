import hre = require("hardhat");
import { ethers } from "hardhat";

const ownerAddress = "0x60b4e7742328eF121ff4f5df513ca1d4e3ba2E04"
const USDC = "0x5FfbaC75EFc9547FBc822166feD19B05Cd5890bb"
// Goerli
const layerZeroEndpointGoerli = "0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23"
// Fuji
const layerZeroEndpointFuji = "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706"

async function main() {

    // Get contract's factory
    const VAULT = await ethers.getContractFactory("SectorCrossVault");

    const vault = await VAULT.deploy(USDC, 'PichaToken', 'PTK', ownerAddress, ownerAddress, ownerAddress, ownerAddress, 0, layerZeroEndpointFuji);
    await vault.deployed();

    console.log("lockRewards deployed to:", vault.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});