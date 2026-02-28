// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}

contract PredictionMarket {

    AggregatorV3Interface public priceFeed;

    struct Prediction {
        bytes32 commitHash;
        bool resolved;
    }

    mapping(address => Prediction) public predictions;

    event PredictionCommitted(address indexed user, bytes32 commitHash);
    event PredictionResolved(
        address indexed user,
        uint256 ethPrice,
        bool predictedAbove,
        bool actualAbove
    );

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function commitPrediction(bytes32 _commitHash) external {
        require(predictions[msg.sender].commitHash == bytes32(0), "Already committed");

        predictions[msg.sender] = Prediction({
            commitHash: _commitHash,
            resolved: false
        });

        emit PredictionCommitted(msg.sender, _commitHash);
    }

    function resolvePrediction(
        bool _predictedAbove,
        uint256 _targetPrice,
        string calldata _secret
    ) external {
        Prediction storage prediction = predictions[msg.sender];

        require(prediction.commitHash != bytes32(0), "No prediction committed");
        require(!prediction.resolved, "Already resolved");

        bytes32 computedHash = keccak256(
            abi.encodePacked(_predictedAbove, _targetPrice, _secret)
        );

        require(computedHash == prediction.commitHash, "Invalid reveal");

        (, int256 price,,,) = priceFeed.latestRoundData();
        uint256 ethPrice = uint256(price) / 1e8;

        bool actualAbove = ethPrice > _targetPrice;

        prediction.resolved = true;

        emit PredictionResolved(
            msg.sender,
            ethPrice,
            _predictedAbove,
            actualAbove
        );
    }
}
