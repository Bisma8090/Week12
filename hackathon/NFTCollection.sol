// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title NFTCollection  (PlatformNFT / PNFT)
 * @dev ERC-721 — max 20 NFTs, IPFS metadata, whitelist mint, reveal mechanism
 *      Royalty: 5% on secondary sales (ERC-2981 style stored here simply)
 */
contract NFTCollection {
    string public name   = "PlatformNFT";
    string public symbol = "PNFT";

    address public owner;
    uint256 public maxSupply  = 20;
    uint256 public royaltyBps = 500; // 5%

    bool    public revealed = false;
    string  public hiddenURI;
    string  public baseURI;

    uint256 private _nextId = 1;

    mapping(address => bool)    public whitelist;
    mapping(address => bool)    public minters;      // marketplace
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _approvals;
    mapping(address => mapping(address => bool)) private _opApprovals;
    mapping(uint256 => string)  private _uris;       // per-token override

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner_, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner_, address indexed operator, bool approved);

    modifier onlyOwner()  { require(msg.sender == owner, "Not owner"); _; }
    modifier onlyMinter() { require(minters[msg.sender] || msg.sender == owner, "Not minter"); _; }

    constructor(string memory _hiddenURI) {
        owner     = msg.sender;
        hiddenURI = _hiddenURI;
    }

    // ── ERC-721 ───────────────────────────────────────────────────────────────
    function balanceOf(address a) external view returns (uint256) { return _balances[a]; }
    function ownerOf(uint256 id) public view returns (address) {
        require(_owners[id] != address(0), "Nonexistent"); return _owners[id];
    }
    function tokenURI(uint256 id) external view returns (string memory) {
        require(_owners[id] != address(0), "Nonexistent");
        if (!revealed) return hiddenURI;
        if (bytes(_uris[id]).length > 0) return _uris[id];
        return string(abi.encodePacked(baseURI, _toString(id), ".json"));
    }
    function approve(address to, uint256 id) external {
        address o = ownerOf(id);
        require(msg.sender == o || _opApprovals[o][msg.sender], "Not auth");
        _approvals[id] = to; emit Approval(o, to, id);
    }
    function getApproved(uint256 id) external view returns (address) { return _approvals[id]; }
    function setApprovalForAll(address op, bool approved) external {
        _opApprovals[msg.sender][op] = approved; emit ApprovalForAll(msg.sender, op, approved);
    }
    function isApprovedForAll(address o, address op) external view returns (bool) { return _opApprovals[o][op]; }
    function transferFrom(address from, address to, uint256 id) external { _transfer(from, to, id); }
    function safeTransferFrom(address from, address to, uint256 id) external { _transfer(from, to, id); }

    // ── Minting ───────────────────────────────────────────────────────────────
    /// @notice Mint with per-token IPFS URI (called by marketplace)
    function mintNFT(address to, string calldata uri) external onlyMinter returns (uint256 id) {
        require(_nextId <= maxSupply, "Max supply");
        id = _nextId++;
        _owners[id] = to; _balances[to]++;
        _uris[id] = uri;
        emit Transfer(address(0), to, id);
    }

    /// @notice Whitelist mint (user pays ETH — optional, set price=0 for free)
    function whitelistMint() external payable {
        require(whitelist[msg.sender], "Not whitelisted");
        require(_nextId <= maxSupply, "Max supply");
        uint256 id = _nextId++;
        _owners[id] = msg.sender; _balances[msg.sender]++;
        emit Transfer(address(0), msg.sender, id);
    }

    function totalSupply() external view returns (uint256) { return _nextId - 1; }

    // ── Reveal ────────────────────────────────────────────────────────────────
    function reveal(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI; revealed = true;
    }

    // ── Admin ─────────────────────────────────────────────────────────────────
    function addMinter(address m) external onlyOwner { minters[m] = true; }
    function removeMinter(address m) external onlyOwner { minters[m] = false; }
    function addWhitelist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) whitelist[users[i]] = true;
    }
    function setRoyalty(uint256 bps) external onlyOwner { royaltyBps = bps; }

    /// @notice ERC-2981 royalty info
    function royaltyInfo(uint256, uint256 salePrice) external view returns (address, uint256) {
        return (owner, (salePrice * royaltyBps) / 10000);
    }

    // ── Internal ──────────────────────────────────────────────────────────────
    function _transfer(address from, address to, uint256 id) internal {
        require(ownerOf(id) == from, "Wrong owner");
        require(to != address(0), "Zero addr");
        require(msg.sender == from || _approvals[id] == msg.sender || _opApprovals[from][msg.sender], "Not auth");
        delete _approvals[id];
        _balances[from]--; _balances[to]++;
        _owners[id] = to;
        emit Transfer(from, to, id);
    }
    function _toString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 tmp = v; uint256 len;
        while (tmp != 0) { len++; tmp /= 10; }
        bytes memory buf = new bytes(len);
        while (v != 0) { buf[--len] = bytes1(uint8(48 + v % 10)); v /= 10; }
        return string(buf);
    }
}
