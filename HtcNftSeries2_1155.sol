// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "HtcNftSeries2(Address): insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "HtcNftSeries2(Address): unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "HtcNftSeries2(Address): low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "HtcNftSeries2(Address): low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "HtcNftSeries2(Address): insufficient balance for call");
        require(isContract(target), "HtcNftSeries2(Address): call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "HtcNftSeries2(Address): low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "HtcNftSeries2(Address): static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "HtcNftSeries2(Address): low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "HtcNftSeries2(Address): delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
    */   
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;               
    }
}

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
    */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Trustable is Context {
    address private _owner;
    mapping (address => bool) private _isTrusted;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(_owner == _msgSender(), "HtcNftSeries2: Caller is not the owner");
        _;
    }

    modifier isTrusted {
        require(_isTrusted[_msgSender()] == true || _owner == _msgSender(), "HtcNftSeries2: Caller is not trusted");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "HtcNftSeries2: New owner is the zero address");
        _owner = newOwner;
    }

    function addTrusted(address user) public onlyOwner {
        _isTrusted[user] = true;
    }

    function removeTrusted(address user) public onlyOwner {
        _isTrusted[user] = false;
    }
}

contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "HtcNftSeries2: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "HtcNftSeries2: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "HtcNftSeries2: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "HtcNftSeries2: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "HtcNftSeries2: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "HtcNftSeries2: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "HtcNftSeries2: ids and amounts length mismatch");
        require(to != address(0), "HtcNftSeries2: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "HtcNftSeries2: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "HtcNftSeries2: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "HtcNftSeries2: mint to the zero address");
        require(ids.length == amounts.length, "HtcNftSeries2: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "HtcNftSeries2: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "HtcNftSeries2: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "HtcNftSeries2: burn from the zero address");
        require(ids.length == amounts.length, "HtcNftSeries2: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "HtcNftSeries2: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "HtcNftSeries2: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("HtcNftSeries2: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("HtcNftSeries2: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("HtcNftSeries2: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("HtcNftSeries2: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) internal virtual pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

contract HtcNftSeries2 is Trustable, ERC1155, ReentrancyGuard {
    string private _name;
    string private _symbol;

    uint8[] private _randomTokenIds;
    mapping(uint256 => string) private _tokenURIs;

    address private _teamAirdropWallet;
    /*
    Mint Step
    1: Team Batch & Airdrop  // Founder WL @ 0.05ETH (500)
    2: Public Sale Pre-Integration @ 0.1ETH
    3: Public Sale Post-Integration @ 0.2ETH
    */
    uint256 private _mintStep = 1;
    uint256 private _nftSeriesTotalSupply = 2500;
    uint256 public _mintedItems = 0;

    mapping(uint256 => uint256) private _claimedHtcBuyers;
    uint256 public _teamBatchSupplyRemain;  // 250
    uint256 public _airdropCount = 50;
    bytes32 public _airdropMerkleRoot;

    mapping(address => bool) private _additionFounderWL;
    mapping(address => bool) private _mintedAddFounderWL;

    mapping(uint256 => uint256) private _mintedFounderWL;
    uint256 public _founderWLSupplyRemain;  // 500
    bytes32 public _whitelistMerkleRoot;
    
    event TeamBatchMint(address teamAirdropWallet, uint256 batchCount, uint256 timestamp);
    event Claimed(address account, uint256 tokenId, uint256 timestamp);
    event MintItem(address account, uint256[] tokenIds, uint256 timestamp);

    constructor(
        string memory name_, 
        string memory symbol_,
        address teamAirdropWallet,
        bytes32 airdropMerkleRoot,
        bytes32 whitelistMerkleRoot,
        uint256 teamBatchSupplyRemain,
        uint256 founderWLSupplyRemain) ERC1155("") {
        _name = name_;
        _symbol = symbol_;
        _teamAirdropWallet = teamAirdropWallet;
        _airdropMerkleRoot = airdropMerkleRoot;
        _teamBatchSupplyRemain = teamBatchSupplyRemain;
        _founderWLSupplyRemain = founderWLSupplyRemain;
        _whitelistMerkleRoot = whitelistMerkleRoot;

        //set token uri
        _tokenURIs[1] = "https://~~~~~~~~~~~~~";
        _tokenURIs[2] = "https://~~~~~~~~~~~~~";
        _tokenURIs[3] = "https://~~~~~~~~~~~~~";
        _tokenURIs[4] = "https://~~~~~~~~~~~~~";
        _tokenURIs[5] = "https://~~~~~~~~~~~~~";
        _tokenURIs[6] = "https://~~~~~~~~~~~~~";
        _tokenURIs[7] = "https://~~~~~~~~~~~~~";
        _tokenURIs[8] = "https://~~~~~~~~~~~~~";
        _tokenURIs[9] = "https://~~~~~~~~~~~~~";
        _tokenURIs[10] = "https://~~~~~~~~~~~~~";
        _tokenURIs[11] = "https://~~~~~~~~~~~~~";
        _tokenURIs[12] = "https://~~~~~~~~~~~~~";
        _tokenURIs[13] = "https://~~~~~~~~~~~~~";
        _tokenURIs[14] = "https://~~~~~~~~~~~~~";
        _tokenURIs[15] = "https://~~~~~~~~~~~~~";
        _tokenURIs[16] = "https://~~~~~~~~~~~~~";
        _tokenURIs[17] = "https://~~~~~~~~~~~~~";
        _tokenURIs[18] = "https://~~~~~~~~~~~~~";
        _tokenURIs[19] = "https://~~~~~~~~~~~~~";
        _tokenURIs[20] = "https://~~~~~~~~~~~~~";
        _tokenURIs[21] = "https://~~~~~~~~~~~~~";
        _tokenURIs[22] = "https://~~~~~~~~~~~~~";
        _tokenURIs[23] = "https://~~~~~~~~~~~~~";
        _tokenURIs[24] = "https://~~~~~~~~~~~~~";
        _tokenURIs[25] = "https://~~~~~~~~~~~~~";
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function getMintStep() public view isTrusted returns (uint256) {
        return _mintStep;
    }

    function getTeamAirdropWallet() public view isTrusted returns(address) {
        return _teamAirdropWallet;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "HtcNftSeries2: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function calculatePrice() public view returns (uint256) {
        if(_mintStep == 1) {
            return 0.05 ether;
        }
        else if(_mintStep == 2) {
            return 0.1 ether;
        }
        else if(_mintStep == 3) {
            return 0.2 ether;
        }
        else {
            return 0 ether;
        }
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI_) public isTrusted {
        require(_exists(tokenId), "HtcNftSeries2: This token is not existed");   
        _setURI(tokenId, tokenURI_);
    }

    function setMintStep(uint256 mintStep) public isTrusted {
        _mintStep = mintStep;
    }

    function setTeamAirdropWallet(address newTeamAirdropWallet) external isTrusted {
        require(newTeamAirdropWallet != address(0x0), "HtcNftSeries2: INVALID_NEW_TEAM_AIRDROP_WALLET");
        _teamAirdropWallet = newTeamAirdropWallet;
    }

    function setAirdropMerkleRoot(bytes32 merkleRoot) public isTrusted {
        _airdropMerkleRoot = merkleRoot;
    }

    function setWhitelistMerkleRoot(bytes32 merkleRoot) public isTrusted {
        _whitelistMerkleRoot = merkleRoot;
    }

    function setRandomTokenIds(uint8[] memory tokenIds) public isTrusted {
        require(tokenIds.length > 0, "HtcNftSeries2: Paramter length should not be zero");
        require(_randomTokenIds.length + tokenIds.length <= _nftSeriesTotalSupply, 
        "HtcNftSeries2: exceeds than totalSupply");

        for(uint256 i = 0; i < tokenIds.length; i ++) {
            _randomTokenIds.push(tokenIds[i]);
        }
    }

    function addFounderWhiteList(address[] calldata addr) external isTrusted {
        for(uint256 i = 0; i < addr.length; i ++) {
            _additionFounderWL[addr[i]] = true;
        }
    }

    function teamBatchMint(uint256 batchCount) external isTrusted {
        require(_mintStep == 1, "HtcNftSeries2: Team batch mint is not possible for now");
        require(_teamBatchSupplyRemain == 0, "HtcNftSeries2: Team batch mint has already done");
        require(batchCount > 0 && batchCount <= _teamBatchSupplyRemain, "HtcNftSeries2: Batch count is not valid");

        uint256[] memory amounts = new uint256[](batchCount);
        uint256[] memory tokenIds = new uint256[](batchCount);

        uint256 mintedItems = _mintedItems;

        for(uint256 i = 0; i < batchCount; i ++) {
            tokenIds[i] = _randomTokenIds[i + mintedItems];
            amounts[i] = 1;
        }

        _mintBatch(_teamAirdropWallet, tokenIds, amounts, "");

        _teamBatchSupplyRemain = _teamBatchSupplyRemain - batchCount;
        _mintedItems = _mintedItems + batchCount;

        emit TeamBatchMint(_teamAirdropWallet, batchCount, block.timestamp);
    }

    function claim(
        uint256 index,
        uint256 tokenId,
        bytes32[] calldata merkleProof
    ) external {
        require(_airdropCount > 0, "HtcNftSeries2: Exceeds than airdrop count");
        require(!_isClaimed(index), "HtcNftSeries2: You've already claimed");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, _msgSender(), tokenId));
        require(
            MerkleProof.verify(merkleProof, _airdropMerkleRoot, node),
            "HtcNftSeries2: Invalid claim proof"
        );

        // Mark Claimed
        _setClaimed(index);
        _safeTransferFrom(_teamAirdropWallet, _msgSender(), tokenId, 1, "");

        _airdropCount = _airdropCount - 1;

        emit Claimed(_msgSender(), tokenId, block.timestamp);
    }

    function mintItem(
        uint256 mintAmount, uint256 index, bytes32[] calldata merkleProof    
    ) public payable nonReentrant {
        if(_mintStep == 1) {
            require(mintAmount == 1, "HtcNftSeries2: You can only mint 1 item");
        }
        else { // _mintStep: 2,3
            require(mintAmount >= 1 && mintAmount <= 10, "HtcNftSeries2: Mint amount is not valid");
        }

        uint256 _currentMintedItems = _mintedItems;
        require(_currentMintedItems + mintAmount <= _nftSeriesTotalSupply, "HtcNftSeries2: Exceeds than total supply");

        require(msg.value >= calculatePrice() * mintAmount, "HtcNftSeries2: Mint price is not enough");

        _mintedItems = _mintedItems + mintAmount;

        if(_mintStep == 1) { //Founder WL @ 0.05ETH (500)
            _canFounderWLMint(index, merkleProof);
            uint256 tokenId = _randomTokenIds[_currentMintedItems];
            _mint(_msgSender(), tokenId, 1, "");

            emit MintItem(_msgSender(), _asSingletonArray(tokenId), block.timestamp);
        }
        else { // _mintStep: 2,3
            uint256[] memory amounts = new uint256[](mintAmount);
            uint256[] memory tokenIds = new uint256[](mintAmount);
            for(uint256 i = 0; i < mintAmount; i ++) {
                tokenIds[i] = _randomTokenIds[i + _currentMintedItems];
                amounts[i] = 1;
            }
            _mintBatch(_msgSender(), tokenIds, amounts, "");

            emit MintItem(_msgSender(), tokenIds, block.timestamp);
        }
    }

    function withdrawMintFunding(address addr) external isTrusted { //tested
      (bool sent, ) = addr.call{ value: address(this).balance }("");
      require(sent, "Failed to withdraw ETH !");
    }

    function _setURI(uint256 tokenId, string memory uri_) internal virtual {
        _tokenURIs[tokenId] = uri_;
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        if (bytes(_tokenURIs[tokenId]).length != 0)
            return true;
        return false;
    }

    function _isClaimed(uint256 index) internal virtual returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = _claimedHtcBuyers[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);

        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) internal virtual {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        _claimedHtcBuyers[claimedWordIndex] =
            _claimedHtcBuyers[claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    function _isMinted(uint256 index) internal virtual returns (bool) {
        uint256 mintedWordIndex = index / 256;
        uint256 mintedBitIndex = index % 256;
        uint256 mintedWord = _mintedFounderWL[mintedWordIndex];
        uint256 mask = (1 << mintedBitIndex);

        return mintedWord & mask == mask;
    }

    function _setMinted(uint256 index) internal virtual {
        uint256 mintedWordIndex = index / 256;
        uint256 mintedBitIndex = index % 256;

        _mintedFounderWL[mintedWordIndex] =
            _mintedFounderWL[mintedWordIndex] |
            (1 << mintedBitIndex);       
    }

    function _canFounderWLMint(uint256 index, bytes32[] memory merkleProof) internal virtual {
        require(_founderWLSupplyRemain > 0, "HtcNftSeries2: Exceeds than Founder Whitelist supply");

        if(_additionFounderWL[_msgSender()]) {
            require(!_mintedAddFounderWL[_msgSender()], "HtcNftSeries2: You've already minted FounderWL NFT");

            // Mark Minted
            _mintedAddFounderWL[_msgSender()] = true;
        }
        else {
            require(merkleProof.length > 0, "HtcNftSeries2: You are not in Founder Whitelist");
            require(!_isMinted(index), "HtcNftSeries2: You've already minted FounderWL NFT");

            uint256 _mintAmount = 1;
            // Verify the merkle proof. 
            bytes32 node = keccak256(abi.encodePacked(index, _msgSender(), _mintAmount));
            require(
                MerkleProof.verify(merkleProof, _whitelistMerkleRoot, node),
                "HtcNftSeries2: Invalid FounderWL mint proof"
            );

            // Mark Minted
            _setMinted(index);
        }

        _founderWLSupplyRemain = _founderWLSupplyRemain - 1;
    }
}