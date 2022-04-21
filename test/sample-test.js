const { expect } = require("chai");
const { ethers } = require("hardhat");

let NFT;

describe("NFT Series2 Tests", function() {
  this.beforeEach(async function() {
    [account1, account2] = await ethers.getSigners();
    
    const nft = await ethers.getContractFactory("HtcNftSeries2");
    NFT = await nft.deploy(
        "NFT Series2",
        "NFT",
        account2.address,
        "0xdb09e807fcc52ca6f0e6092940a4e5fd2fdd9a80117eaecd71a81d90abbcdaf6",
        "0x37764ed7921ddd8321016b1ecfcb4d7e76ee66fbbee8b61159b66e38e1da7182",
        500,
        500
    );

        await NFT.deployed();
        console.log("NFT deployed:", NFT.address);
  })

  it("Main Test", async function() {
    [ account1, 
      account2, 
      account3,
      account4,
      account5,
      account6,
      account7,
    ] = await ethers.getSigners();

      console.log("account3=======>", account3.address);
      console.log("account4=======>", account4.address);
      console.log("account5=======>", account5.address);
      console.log("account6=======>", account6.address);
      console.log("account7=======>", account7.address);


      await NFT.connect(account1).setTeamBatchSupplyRemain(600);
      await NFT.connect(account1).setFounderWLSupplyRemain(200);

      await NFT.connect(account3).claim(28, [
				"0x0a2ff4a7b0692c6338a2e829b69f4b22465255279a1d1ba8b7452641676c330a",
				"0x44bccaf2bfaf2c7df2bb90d53b526d573efac18511e4ec2a945ead4b286094b5",
				"0xabb222f99ac236a43a7e541727945f88676f06acf72d32d23597eaee8179704d",
				"0xaccff934e59041870f4cb4767500a6a13c7419b907519890d7a874626612ea92",
				"0x5634832119dd90e4347bdb398bd6364922b601bcd681a7f2b98063dd672ae269",
				"0xd66dea0debe917fa1b7c80b702031fe8d7b627fb6d5f43ff314716d2c383f250",
				"0xe0e66e84f14eec77b95376c8db316682806d11f45055b2f41b287140a16999b3"
			]);

      console.log("NFT token balance account3", (await NFT.balanceOf(account3.address)));
      console.log("get Address 1", (await NFT.ownerOf(1)));

      await NFT.connect(account1).teamBatchMint(500);

      console.log("NFT token balance", (await NFT.balanceOf(account2.address)));
      console.log("NFT totalBalance", (await NFT.totalSupply()));


      
      await NFT.connect(account4).claim(59, [
				"0x90a9c5b56eddaa992ace4d7de8b225b27cb275bc39290adbb22853810d9a0c86",
				"0x5c60f645619ebc38629c3231077e7ccd6b7f6dd53a812d8eb6eea2f6c3f6c11d",
				"0x4472b99d2961f0d22242c2fd431a95ae10d1f0086750b5720cdb0593299a7e08",
				"0xb1e7a58ffc94e4a0e12f7a4b6a0cee11c674956265b36c11996a90587228be1a",
				"0xe95e05121cb51f964d3e459b3b4ea8691b1dc122b409a93c90f6b55b8e9dcc4c",
				"0x588808d40473b835fafe47feba0022d084460299d48cfcb37553b8934d9ed977",
				"0xe0e66e84f14eec77b95376c8db316682806d11f45055b2f41b287140a16999b3"
			]);
      console.log("NFT token balance account4", (await NFT.balanceOf(account4.address)));
      console.log("get Address 502", (await NFT.ownerOf(502)));

      
      await NFT.connect(account5).claim(10, [
				"0xe96a9952bcef6a243c91a00ea94fe99c5a361537cc03014f120f7b723e958292",
				"0x52152c2425e4c579bfc276cfbbf6cf2a297df5aa5c38bb3d261a02daa6f437a4",
				"0x309822b0730c6c1ee42dce067d8e2def918cbfba521efb38a6f6787f1a0d0bea",
				"0x615590d03390a512578dc8acdfeb791b7653e82ec4cff98854b7d01f11a860c4",
				"0x1bead9d0aed6c4aa1e2d0d6a1a3d5869a099f60c4604b77c6b61cb426a7bfd15",
				"0xc1182619ba5881d75ebe4148bc30c89b099c4f13304eedc20d0f51a7663204cf",
				"0xdddc0d331763515f55f042c1aa1e2c74319367b73cbf2e05042e9dc049b872cf"
			]);
      // claim ended


      // white list
      
      await NFT.connect(account3).mintItem(
        1, 120, 
        [
          "0x34e0b71cf53fe7881ae7807a560b9275d2c4a5a997bc8618ffb58d6edebc86e8",
          "0x5cb07c7fd484d3816d7b60181ddaa3621e86838d2cd6f5b2c1213afeaf07f5d2",
          "0xcd3fed5f9f245886874e41991922f17273ae967c341d12a852c77b02f692c068",
          "0x65a5afae1e01bb108bc6642eae9b77356ce47352be0784023864b4772fbee43a",
          "0x909a0897a0ad853d8ada812616ba43df6ca72c836328885b15d40cccc2dc2bbc",
          "0x4d79bf16018012c1fbe9625b3e2b8db83f780aa60afe1bf40661672eebf2e92a",
          "0x910521ac2c0484af84ee5ea47a485fdf439b2dd211dfe3957bb6a3fbbb20d3cf",
          "0xdbda97107fc3b90edbcc150495c5f566c5c2c8556b717d132108b9424d67ab4a",
          "0xbc5abc434c4a79ca904df91c455971c657f12848f14214ff4ea980d6c0d1594a"
        ]
      );

      
      await NFT.connect(account4).mintItem(
        1, 283, 
        [
          "0x14dd31197997663ab6432f472609111c62ef6cabeb0b888f24c1dc7c34fa906d",
          "0x4d60fb7eab704fc5c8d9dbfd6e2ae91f9acbeb54166cd4b929393338ea578a01",
          "0x06b603a154f2f682a9f6a2200d22093db9c54da0263630271e8cb578807722ee",
          "0xeb6672934e7caefed4c2effa4a82ee354e522ff4aeda501bae5be1a2e6811a12",
          "0x19cfea3faee00a87d3d36d9115483364ac88383a597d80131c3d76f11d922b6f",
          "0x32e8baff470f1e949cb9b689808e8b4290c054ee8dc4e3e1683e9a9914b28938",
          "0x6a31cf66399bb1bc5c8cbb5f07d7ffa0ecbda364f775dbdcd2572b0f2abf9747",
          "0xdbda97107fc3b90edbcc150495c5f566c5c2c8556b717d132108b9424d67ab4a",
          "0xbc5abc434c4a79ca904df91c455971c657f12848f14214ff4ea980d6c0d1594a"
        ]
      );


      await NFT.connect(account5).mintItem(
        1, 34, 
        [
          "0x5c2acee30b6c3e1dab94b6e9cf3ba3511500b17b1fb25b4fcf62e2934169a032",
          "0xebdc3058ba4d80db46458dff180591ddd91d81470c70fed49dac6f67dc2a1440",
          "0xfc7bcc1bc56633194551df2b98c5c234c59f30db0c25a6e5f81ed62749e8c494",
          "0xdc589662b92cc762d0e3b12c64143cd5ff1e2859279f537203d04aee1c20832a",
          "0xd0f937efad41d3517c1043438233f167e2ec62f4404272b694c9d407a6cec3ba",
          "0x37bb6b9ebda3bb8fff0da5a4853e8d3c98ddf0e5de0b83a277a98affae43a2f3",
          "0x052204e9bc403dc6fa4a07e3770e9977807fad47d6ac7c713793d728fe9fa1b5",
          "0x619146681dd0cd2e678ca0ba3755b651cbaeee410c0edaa94fe39d80f744d9c8",
          "0xbc5abc434c4a79ca904df91c455971c657f12848f14214ff4ea980d6c0d1594a"
        ]
      );

      console.log("NFT token balance account3", (await NFT.balanceOf(account3.address)));
      console.log("NFT totalBalance", (await NFT.totalSupply()));
      // set minstep2

        await NFT.connect(account1).setMintStep(2);

        await NFT.connect(account3).mintItem(
          3, 0, []
        );
        console.log("NFT token balance account3", (await NFT.balanceOf(account3.address)));

        // calculatePrice
        console.log( "get NFT item price: ", (await NFT.calculatePrice()) );

        
        await NFT.connect(account1).setMintStep(3);
        // calculatePrice
        console.log( "get NFT item price: ", (await NFT.calculatePrice()) );
        // get Minted Number
        console.log("get Minted Number: ", (await NFT.totalSupply()));
        
        
        
        await NFT.connect(account3).mintItem(
          5, 0, []
        );

        //set Calculate Price
        await NFT.connect(account1).setMintingPrice(3, ethers.utils.parseEther("0.5"));

        console.log( "get NFT item price: ", (await NFT.calculatePrice()) );

        await NFT.connect(account1).setMintStep(1);

        await NFT.connect(account6).mintItem(
          1, 305, 
          [
            "0xf1967578566c03c592659cfc3e41aca53d90ed811d76e0141f8f1211a6546d58",
            "0x9c40703f9bbd69dc511fd6e7914b3a899ca342d445532ce086602d6abd5b4879",
            "0x8951343f26f718e426dbfde15e5de308743b3e9898344c9295d99778582a6e10",
            "0x6423109aab1943322f5e3e54a594e905c123609571e573938808a2fce7221b93",
            "0xcaf9c740ef5ae8a3250adb2b22f3257535b7167f89ca69eaa63b0e0b5747dd7d",
            "0xf46d35ac99ba561bbd612f7df6acf6ab884106648529e96ab1c8b2b97617ecaf",
            "0x5c2bc243832f5ff7ca69935bc2480aef754fd77a27f1070bb6a573cb7c915d84",
            "0xfd0882149cfef74c23a4e337a81a969848b4c1ceb6e40c700d80e074a22f6356",
            "0xc0d6dcc39dcd25f9b5cb0c1c19fa47f588a19ed94e3d2f87c8fe1af3cfdd37e0"
          ]
      );

      console.log("get Minted Number: ", (await NFT.totalSupply()));

      await NFT.connect(account1).setBaseURI("https://base_uri/");
          
      
      console.log( "tokenURI(tokenID:602): ", (await NFT.tokenURI(510)) );

      await NFT.connect(account1).setTokenUriAddParam(".json");

      console.log( "tokenURI(tokenID:602): ", (await NFT.tokenURI(510)) );
  })
})
