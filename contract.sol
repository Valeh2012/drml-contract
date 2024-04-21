// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity ^0.8.20;

import "fhevm/abstracts/Reencrypt.sol";
import "fhevm/lib/TFHE.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";
// import "fhevm-contracts/contracts/token/ERC20/EncryptedERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DRMLicense is Reencrypt{
    // using EnumerableSet for EnumerableSet.UintSet;
    // using EnumerableMap for EnumerableMap.UintToAddressMap;

    uint32 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 public constant decimals = 6;

    event Transfer(uint32 indexed tokenId, address indexed from, address indexed to);
    // event Approval(address indexed owner, address indexed spender);
    event Mint(address indexed to, uint32 amount);

    mapping(uint32 => address) private _owners;

    // mapping(address => euint32) internal balances;

    // mapping(address => uint32[]) private _holderTokens;

    // // Optional mapping for token URIs
    mapping (uint32 tokenId => string) private _tokenURIs;

    // // Optional mapping for token URIs
    mapping (uint32 => euint32) internal _tokenKEYs;


    // Access rights
    // mapping(address => mapping(uint32 => ebool)) private _accessRights;


    constructor() {
    // _mint(1000000, msg.sender);
    _name = "LICENSE";
    _symbol = "DRML";
  }


    // Returns the name of the token.
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // Returns the symbol of the token, usually a shorter version of the name.
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // Returns the total supply of the token.
    function totalSupply() public view virtual returns (uint32) {
        return _totalSupply;
    }

    // function _setTokenKeys(uint32 tokenId, euint32 encryptedKey) internal virtual{
    //     _tokenKEYs[tokenId] = encryptedKey;
    // }

    function mint(uint32 amount, string memory URI) public virtual {
        // balances[msg.sender] = TFHE.add(balances[msg.sender], amount); // overflow impossible because of next line
        uint32 _tokenId = _totalSupply;
        _totalSupply = _totalSupply + amount;
        emit Mint(msg.sender, amount);
        for(uint32 i=0; i<amount; i++){
            _owners[_tokenId + i] = msg.sender;
            _tokenKEYs[_tokenId + i] = TFHE.asEuint32(_tokenId);
            _tokenURIs[_tokenId + i] = URI;
        }
    }


    function ownerOf(uint32 tokenId) public view virtual returns (address){
        return _owners[tokenId];
    }

    function tokenURI(uint32 tokenId) public view virtual returns (string memory){
        return _tokenURIs[tokenId];
    }

    function tokenKey(uint32 tokenId, 
        bytes32 publicKey,
        bytes calldata signature) external view virtual onlySignedPublicKey(publicKey, signature) returns (bytes memory)  {
            require(_owners[tokenId] == msg.sender, "Owners can access");
        return TFHE.reencrypt(_tokenKEYs[tokenId], publicKey);
    }    

    /*
        Buy token
    */
    function transfer(address to, uint32 tokenId) public payable  returns (bool){
        require(_owners[tokenId] != to, "ERC721: transfer of token already is own");
        require(to != address(0), "ERC721: transfer to the zero address");
        // require(msg.value >= 1, "Minimum price 1 DRML");
        emit Transfer(tokenId, _owners[tokenId], to);
        _owners[tokenId] = to;
        return true;
    }

}
