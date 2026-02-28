const { ethers } = require("hardhat");

async function main() {
  const Aegis = await ethers.getContractFactory("AegisCommitReveal");
  const aegis = await Aegis.deploy();

  await aegis.deployed();

  console.log("Aegis deployed to:", aegis.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 