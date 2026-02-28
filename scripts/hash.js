import { ethers } from "ethers";

// ===== PREDICTION VALUES (MUST MATCH REVEAL) =====
const predictedAbove = true;        // true = ETH price > target
const targetPrice = 3000;           // ETH price in USD (no decimals)
const secret = "test123";           // nonce / secret
// ===============================================

// Encode exactly like Solidity abi.encodePacked
const encoded = ethers.solidityPacked(
  ["bool", "uint256", "string"],
  [predictedAbove, targetPrice, secret]
);

// Hash
const hash = ethers.keccak256(encoded);

console.log("COMMIT HASH:", hash);