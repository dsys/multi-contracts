pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract IdentityToken is ERC721 {

    // TODO: Should be a non-transferable ERC721 token, issued by an IdentityProvider

    function transfer(address _to, uint _amount)  public {
        require(false);
    }

}
