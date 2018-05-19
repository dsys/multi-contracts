pragma solidity ^0.4.23;

// import "./Ownable.sol";
// 
// contract ClaimRegistry is Ownable {
// 
//     struct Claim {
//         address issuer;
//         address subject;
//         bytes32 key;
//         bytes value;
//         uint256 nonce;
//         uint256 expires;
//         uint8 sigV;
//         bytes32 sigR;
//         bytes32 sigS;
//     }
// 
//     mapping(address => mapping(bytes32 => Claim)) public registry;
//     mapping(address => mapping(bytes32 => bool)) public presence;
// 
//     event ClaimSet(address indexed _subject, bytes32 indexed _key, bytes _val, uint _setAt);
//     event ClaimRemoved(address indexed _subject, bytes32 indexed _key, uint _setAt);
// 
//     function hasClaim(address _subject, bytes32 _key) external view returns (bool) {
//         return presence[_subject][_key];
//     }
// 
//     function getClaim(address _subject, bytes32 _key) external view returns (Claim) {
//         return registry[_subject][_key];
//     }
// 
//     function setClaim(address _subject, bytes32 _key, bytes _val) onlyOwner external {
//         registry[_subject][_key] = _val;
//         presence[_subject][_key] = true;
//         emit ClaimSet(_subject, _key, _val, block.timestamp);
//     }
// 
//     function removeClaim(address _subject, bytes32 _key) onlyOwner external {
//         presence[_subject][_key] = false;
//         emit ClaimRemoved(_subject, _key, block.timestamp);
//     }
// 
// }
