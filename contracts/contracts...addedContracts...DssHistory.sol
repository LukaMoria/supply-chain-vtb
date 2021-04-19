pragma solidity ^0.4.18;

/**
 * @title DssHistory
 * @dev История использованных сигнатур.
 */
contract DssHistory {

    mapping(bytes32 => bool) private hashes;

    /**
     * @dev Проверка на наличие сигнатуры в истории.
     */
    function check(uint8 v, bytes32 r, bytes32 s) public returns (bool){
        bytes32 hash = generate(v, r, s);
        bool result = hashes[hash];
        if (!result) {
            hashes[hash] = true;
        }
        return result;
    }

    /**
     * @dev Генерация хэша сигнатуры.
     */
    function generate(uint8 v, bytes32 r, bytes32 s) internal pure returns (bytes32){
        bytes memory tempBytes = new bytes(65);
        tempBytes[0] = byte(v);
        uint i;
        for (i = 0; i < 32; i ++) {
            tempBytes[i + 1] = r[i];
        }
        for (i = 0; i < 32; i ++) {
            tempBytes[i + 33] = s[i];
        }
        return keccak256(tempBytes);
    }
}

