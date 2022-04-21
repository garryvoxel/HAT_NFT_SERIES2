const hre = require("hardhat");
async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    
    const nft = await ethers.getContractFactory("HtcNftSeries2");

    const NFT = await nft.deploy(
        "NFT Series2",
        "NFT",
        "0x2A2c1b6f2Be8eD53626F1d0578EDb6010E9C52fe",
        "0x0410a4dc2e59f2754bfe71435b4d03f74707af21230a2a49c413c9b167e6eeae",
        "0x736a942fedf6b71956805590d30ca1ccd07efebe8333bcaa90eb74c9c02ec6e0",
        500,
        500
    );

    await NFT.deployed();
    console.log("NFT deployed to:", NFT.address);
}

main()
.then(() => process.exit(0))
.catch((error) => { 
    console.error(error);
    process.exit(1);
});
