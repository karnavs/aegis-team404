// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AegisCommitReveal {

    struct Prediction {
        bytes32 commitmentHash;
        uint256 targetTimestamp;
        bool revealed;
        bool resolved;
        bool success;
    }

    struct AgentStats {
        uint256 totalPredictions;
        uint256 successfulPredictions;
    }

    mapping(address => Prediction[]) public predictions;
    mapping(address => AgentStats) public agentStats;

    event PredictionCommitted(address indexed agent, uint256 index, bytes32 commitmentHash, uint256 targetTimestamp);
    event PredictionRevealed(address indexed agent, uint256 index, bool success);

    function commitPrediction(bytes32 _commitmentHash, uint256 _targetTimestamp) external {
        require(_targetTimestamp > block.timestamp, "Target time must be in future");

        predictions[msg.sender].push(
            Prediction({
                commitmentHash: _commitmentHash,
                targetTimestamp: _targetTimestamp,
                revealed: false,
                resolved: false,
                success: false
            })
        );

        uint256 index = predictions[msg.sender].length - 1;

        agentStats[msg.sender].totalPredictions += 1;

        emit PredictionCommitted(msg.sender, index, _commitmentHash, _targetTimestamp);
    }

    function revealPrediction(
        uint256 _index,
        string memory asset,
        string memory direction,
        uint256 targetTimestamp,
        string memory nonce,
        bool result
    ) external {

        Prediction storage prediction = predictions[msg.sender][_index];

        require(!prediction.revealed, "Already revealed");

        bytes32 recalculatedHash = keccak256(
            abi.encodePacked(
                msg.sender,
                asset,
                direction,
                targetTimestamp,
                nonce
            )
        );

        require(recalculatedHash == prediction.commitmentHash, "Hash mismatch");

        prediction.revealed = true;
        prediction.resolved = true;
        prediction.success = result;

        if (result) {
            agentStats[msg.sender].successfulPredictions += 1;
        }

        emit PredictionRevealed(msg.sender, _index, result);
    }

    function getAccuracy(address agent) external view returns (uint256) {
        AgentStats memory stats = agentStats[agent];

        if (stats.totalPredictions == 0) {
            return 0;
        }

        return (stats.successfulPredictions * 100) / stats.totalPredictions;
    }
}