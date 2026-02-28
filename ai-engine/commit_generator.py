from web3 import Web3
import time
import secrets

w3 = Web3()

def generate_prediction_commitment(agent_address, asset, direction, target_timestamp):
    nonce = secrets.token_hex(16)

    encoded = Web3.solidity_keccak(
        ["address", "string", "string", "uint256", "string"],
        [agent_address, asset, direction, target_timestamp, nonce]
    )

    return {
        "agent": agent_address,
        "asset": asset,
        "direction": direction,
        "target_timestamp": target_timestamp,
        "nonce": nonce,
        "commitment_hash": encoded.hex()
    }


if __name__ == "__main__":
    agent = "0x0000000000000000000000000000000000000001"
    asset = "ETH/USD"
    direction = "UP"
    target_time = int(time.time()) + 600

    result = generate_prediction_commitment(agent, asset, direction, target_time)

    print("\nGenerated Prediction:")
    for key, value in result.items():
        print(f"{key}: {value}")