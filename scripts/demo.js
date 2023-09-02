const hre = require("hardhat");
const ethers = hre.ethers;

const main = async () => {
  const [deployer, alice, bob] = await hre.ethers.getSigners();

  const registryFactory = await ethers.getContractFactory("ERC6551Registry");
  const registry = await registryFactory.deploy();

  const ecr6551AccountFactory = await ethers.getContractFactory(
    "ERC6551Account"
  );
  const erc6551Account = await ecr6551AccountFactory.deploy();

  const erc20Factory = await ethers.getContractFactory("MockERC20");
  const erc20 = await erc20Factory.deploy();

  const erc721Factory = await ethers.getContractFactory("MockERC721");
  const erc721 = await erc721Factory.deploy(
    erc6551Account.target,
    registry.target,
    erc20.target
  );

  const tokenId = 0;
  const salt = 0;

  const tx0 = await erc721.mint(deployer.address, tokenId);
  await tx0.wait();

  console.log(erc6551Account.target);
  // console.log(await (await ethers.getDefaultProvider()).getNetwork());

  const tx1 = await registry.createAccount(
    erc6551Account.target,
    hre.network.config.chainId,
    erc721.target,
    tokenId,
    salt, // salt
    "0x"
  );
  await tx1.wait();

  const tba0 = await registry.account(
    erc6551Account.target,
    hre.network.config.chainId,
    erc721.target,
    0, // tokenId
    0 // salt
  );
  console.log("tba0", tba0);

  const tx = await erc20.mint(tba0, 200);
  await tx.wait();

  console.log("deployer.address", deployer.address);
  console.log("erc721.ownerOf(0)", await erc721.ownerOf(0));

  const tba0Impl = await ecr6551AccountFactory.attach(tba0);

  console.log(alice.address);
  const tx2 = await tba0Impl
    .connect(deployer)
    .execute(erc721.target, "0x11", "0x", 0);
  await tx2.wait();

  console.log("balance", await erc20.balanceOf(tba0));
  console.log("owner", await tba0Impl.owner());

  const uri = await erc721.tokenURI(0);
  console.log("uri", uri);
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
