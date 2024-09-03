// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract SBTNFTContract is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using Strings for uint256;

    address public signer;

    mapping(uint256 => bool) public claimedTokens;
    event TokenClaimed(address indexed owner, uint256 tokenId);

    bytes32 internal DOMAIN_SEPARATOR;

    string private _defaultURI;
    string private _dynamicURI;

    error SignerUnauthorizedAccount(address account);

    struct MintParam {
        address to;
        uint256 tokenId;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) external initializer {
        __ERC721_init("SafeGrowthNFT", "SBT");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        DOMAIN_SEPARATOR = _computeDomainSeparator();
    }
    /**
     * @dev Throws if called by any account other than the signer.
     */
    modifier onlySigner() {
        if (signer != _msgSender()) {
            revert SignerUnauthorizedAccount(_msgSender());
        }
        _;
    }

    function setSigner(address _signer) external onlyOwner {
        require(
            _signer != address(0),
            "The input parameters of the address type must not be zero address."
        );
        signer = _signer;
    }

    function mint(address to, uint256 tokenId) external onlySigner {
        require(balanceOf(to) == 0, "SBT: one address can only own one token");
        _mint(to, tokenId);
    }
    function mintBatch(MintParam[] calldata params) external onlySigner {
        for (uint256 i = 0; i < params.length; ) {
            MintParam calldata param = params[i];
            this.mint(param.to, param.tokenId);
            unchecked {
                ++i;
            }
        }
    }

    function claim(
        uint256 tokenId,
        uint256 _amount,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    ) external {
        address owner = _requireOwned(tokenId);
        address sender = _msgSender();

        require(sender == owner, "SBT: incorrect token owner");
        require(!claimedTokens[tokenId], "SBT: token has already been claimed");
        require(_amount == 1, "SBT: one address can only own one token");
        require(
            _verifySigner(sender, _amount, _v, _r, _s) == signer,
            "Invalid signer"
        );

        claimedTokens[tokenId] = true;
        emit TokenClaimed(owner, tokenId);
    }

    function setDynamicURI(string calldata uri) external onlyOwner {
        _dynamicURI = uri;
    }
    function setDefaultURI(string calldata uri) external onlyOwner {
        _defaultURI = uri;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        return
            claimedTokens[tokenId]
                ? string.concat(_dynamicURI, tokenId.toString())
                : _defaultURI;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(false, "SBT: Soul Bound Token");
        super.transferFrom(from, to, tokenId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function _verifySigner(
        address recipient,
        uint256 totalRewards,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns (address _signer) {
        _signer = ECDSA.recover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            keccak256("claim(address owner,uint256 amounts)"),
                            recipient,
                            totalRewards
                        )
                    )
                )
            ),
            _v,
            _r,
            _s
        );
    }

    function _computeDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("SBTNFTContract")),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
}
