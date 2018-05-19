pragma solidity ^0.4.23;

// import "./ClaimRegistry.sol";
// import "./Ownable.sol";
// 
// contract IdentityRegistry {
// 
//     mapping(address => ClaimRegistry) public claimRegistries;
//     mapping(address => uint) public nonces;
// 
//     modifier onlyOwner(address _subject) {
//         require(msg.sender == _subject);
//         _;
//     }
// 
//     function getClaimRegistry() external view returns (ClaimRegistry) {
//         return claimRegistries[msg.sender];
//     }
// 
//     function getClaimRegistry(address _subject) external view returns (ClaimRegistry) {
//         return claimRegistries[_subject];
//     }
// 
//     function setClaimRegistry(ClaimRegistry claimRegistry) external {
//         claimRegistries[msg.sender] = claimRegistry;
//     }
// 
//     function setClaimRegistry(address _subject, ClaimRegistry claims, uint8 sigV, bytes32 sigR, bytes32 sigS) external {
//         bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", _subject, claims, nonces[_subject]);
//         address signer = ecrecover(prefixedHash, sigV, sigR, sigS);
//         require(signer == _subject);
//         claimRegistries[_subject] = claims;
//         nonces[_subject]++;
//     }
// 
//     function hasClaim(address _subject, bytes32 _key) external view returns (bool) {
//         ClaimRegistry claims = claimRegistries[_subject];
//         return address(claims) != 0 && claims.hasClaim(0, _key);
//     }
// 
//     function hasClaim(address _issuer, address _subject, bytes32 _key) external view returns (bool) {
//         ClaimRegistry claims = claimRegistries[_subject];
//         if (address(claims) == 0) return false;
//         return true;
//     }
// 
//     function hasClaim(address[] _issuers, address _subject, bytes32 _key) external view returns (bool) {
//         for (uint i = 0; i < _issuers.length; i++) {
//             address issuer = _issuers[i];
//             ClaimRegistry claims = claimRegistries[issuer];
//             if (claims.hasClaim(_subject, _key)) {
//                 return true;
//             }
//         }
//         return false;
//     }
// 
//     function getClaim(address _subject, bytes32 _key) external returns (ClaimRegistry.Claim) {
//         ClaimRegistry claims = claimRegistries[_subject];
//         require(address(claims) != 0);
//         return claims.getClaim(0, _key);
//     }
// 
//     function getClaim(address _issuer, address _subject, bytes32 _key) external pure returns (ClaimRegistry.Claim) {
//         ClaimRegistry claims = claimRegistries[_issuer];
//         require(address(claims) != 0);
//         return claims.getClaim(_issuer, _subject, _key);
//     }
// 
//     function getClaim(address[] _issuers, address _subject, bytes32 _key) external pure returns (ClaimRegistry.Claim) {
//         for (uint i = 0; i < _issuers.length; i++) {
//             address issuer = _issuers[i];
//             ClaimRegistry claims = claimRegistries[issuer];
//             if (claims.hasClaim(_subject, _key)) {
//                 return claims.getClaim(issuer, _key);
//             }
//         }
//         return ClaimRegistry.Claim(0);
//     }
// 
//     function verifyClaim(address _issuer, address _subject, bytes32 _key) external pure returns (ClaimRegistry.Claim) {
//         ClaimRegistry.Claim storage claim = this.getClaim(_issuer, _subject, _key);
//         require(address(claim) != 0 && checkClaimSignature(claim, _subject));
//         return claim;
//     }
// 
//     function verifyClaim(address[] _issuers, address _subject, bytes32 _key) external pure returns (ClaimRegistry.Claim) {
//         ClaimRegistry.Claim storage claim = this.getClaim(_issuers, _subject, _key);
//         require(address(claim) != 0 && checkClaimSignature(claim, _subject));
//         return claim;
//     }
// 
//     function checkClaimSignature(ClaimRegistry.Claim _claim, address _subject) internal pure returns (bool) {
//         bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", _claim.issuer, _claim.key, _claim.value, _claim.nonce, _claim.expires);
//         return ecrecover(prefixedHash, _claim.sigV, _claim.sigR, _claim.sigS) == _subject;
//     }
// 
// }
