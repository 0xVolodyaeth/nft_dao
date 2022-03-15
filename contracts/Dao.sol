// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// import "./ERC721Full.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DAO is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // address can own only one metal
    enum metal {
        Gold,
        Silver,
        Bronze
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {}

    // function _burn() public view,

    function mint2() public returns (string memory) {
        _setTokenURI(1, "url");
        return "minted";
    }

    mapping(uint256 => string) tokenIdToURI;
    mapping(uint256 => metal) tokenIdToMetalType;
    mapping(uint256 => bool) tokenIdToVote;
    mapping(address => metal) addressToMetal;

    address owner;
    address payable public contractAddress;

    uint256 amountGold = 0;
    uint256 amountSilver = 0;
    uint256 amountBronze = 0;

    Counters.Counter public goldHodlers;
    Counters.Counter public silverHodlers;
    Counters.Counter public bronzeHodlers;

    bool public goldTreasuryInited = false;
    bool public silverTreasuryInited = false;
    bool public bronzeTreasuryInited = false;

    uint256 public goldHodlersVotes = 0;
    uint256 public silverHodlersVotes = 0;
    uint256 public bronzeHodlersVotes = 0;

    string goldURI =
        "https://bafybeiclahw6qhira3khhlnoqjvwddzo5p6xkvb2tlpq6i3usuoj3duaou.ipfs.infura-ipfs.io/";
    string silverURI =
        "https://bafybeid2azvpigjzxvop5dch4eicvhkg6sjyrduwlcvjhgasux47d2mqoq.ipfs.infura-ipfs.io/";
    string bronzeURI =
        "https://bafybeif3jivdintrywrvyqf6t342mn35kpwdcnhhxqzk4ik3ugfrnznkdu.ipfs.infura-ipfs.io/";

    constructor() payable ERC721("metals", "METALS") {
        owner = msg.sender;
        contractAddress = payable(address(this));
    }

    function getContractAddress() public view returns (address) {
        return address(this);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // TODO: use safemath instead of + sign
    function transferToTreasury() public payable {
        // uint256 nftType = addressToTokenType[msg.sender];
        // require(nftType != 0, "address does not own any token");
        // if (nftType == 1) {
        //     require(
        //         goldTreasuryInited,
        //         "treasury should be inted by the admin first"
        //     );
        //     amountGold += msg.value;
        // }
        // if (nftType == 2) {
        //     require(
        //         silverTreasuryInited,
        //         "treasury should be inted by the admin first"
        //     );
        //     amountSilver += msg.value;
        // }
        // if (nftType == 3) {
        //     require(
        //         bronzeTreasuryInited,
        //         "treasury should be inted by the admin first"
        //     );
        //     amountBronze += msg.value;
        // }
    }

    function getBalance(uint256 _nftType) public view returns (uint256 amount) {
        metal tokenMetal = metal(_nftType);

        if (tokenMetal == metal.Gold) {
            return amountGold;
        }

        if (tokenMetal == metal.Silver) {
            return amountSilver;
        }

        if (tokenMetal == metal.Bronze) {
            return amountBronze;
        }
    }

    // vote:
    // one token == one vote, user can vote as
    // many times as many tokens he has
    function vote(uint256 _tokenId) public {
        metal tokenMetal = tokenIdToMetalType[_tokenId];
        require(ownerOf(_tokenId) == msg.sender, "address is not token owner");
        require(!tokenIdToVote[_tokenId], "token has voted already");

        if (tokenMetal == metal.Gold) {
            goldHodlersVotes++;
        }

        if (tokenMetal == metal.Silver) {
            silverHodlersVotes++;
        }

        if (tokenMetal == metal.Bronze) {
            bronzeHodlersVotes++;
        }

        tokenIdToVote[_tokenId] = true;
    }

    function mintMetal(uint256 _tokenType) public {
        require(
            owner == msg.sender,
            "mint is allowed to be used only by the owner"
        );
        require(
            (_tokenType >= 0) && (_tokenType <= 2),
            "nft type should be 1, 2, or 3"
        );

        _tokenIds.increment();
        uint256 current = _tokenIds.current();
        _safeMint(msg.sender, current);

        metal metalType = metal(_tokenType);

        if (metalType == metal.Gold) {
            require(goldHodlers.current() < 20, "only 20 can be minted");
            _setTokenURI(current, goldURI);
            goldHodlers.increment();
        }

        if (metalType == metal.Silver) {
            require(silverHodlers.current() < 20, "only 20 can be minted");
            _setTokenURI(current, silverURI);
            silverHodlers.increment();
        }

        if (metalType == metal.Bronze) {
            require(bronzeHodlers.current() < 20, "only 20 can be minted");
            _setTokenURI(current, bronzeURI);
            bronzeHodlers.increment();
        }

        tokenIdToMetalType[current] = metalType;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        // require(
        //     _exists(_tokenId),
        //     "ERC721Metadata: URI query for nonexistent token"
        // );

        // string memory _tokenURI = tokenIdToURI[_tokenId];
        // if (bytes(_tokenURI).length == 0) {
        //     return _baseURI();
        // }

        // return _tokenURI;
        return tokenURI(_tokenId);
    }

    // Create treasury for specified token type
    // could be invoced only by dao admin
    function createTreasury(uint256 _nftType) public pure {
        // require(owner == address(msg.sender), "only dao admin can create a treasury");
        // if ((_nftType = 1) && !goldTreasuryInited) {
        // 	goldTreasuryInited = true;
        // 	return;
        // }
        // if ((_nftType = 2) && !silverTreasuryInited) {
        // 	silverTreasuryInited = true;
        // 	return;
        // }
        // if ((_nftType = 3) && !bronzeTreasuryInited){
        // 	bronzeTreasuryInited = true;
        // 	return;
        // }
        // revert("unknown nft type or treasury has been inited already");
    }

    function withdraw(uint256 _amount, metal _metal)
        public
        payable
        returns (uint256)
    {
        // require(_amount <= 0, "amount should be positive");
        // uint nftType = addressToNFTType[msg.sender];
        // require(nftType != 0, "user doe not own nft and cannot withdraw");
        // if (nftType == 1){
        // 	require(_amount <= amountGold, "withdraw amount should be less or equal to the amount in treasury");
        // 	// TODO: check that 2/3 voted and then withdraw
        // 	if (){
        // 		// TODO: check that withdraw works
        // 		(bool sent, ) = msg.sender.call{value: _amount}("");
        // 		amountGold -= _amount;
        // 	}
        // }
        // if (nftType == 2){
        // 	require(_amount <= amountSilver, "withdraw amount should be less or equal to the amount in treasury");
        // }
        // if (nftType == 3){
        // 	require(_amount <= amountBronze, "withdraw amount should be less or equal to the amount in treasury");
        // }
        // require(sent, "Failed to send Ether");
        // if (twoThirds(_metal)) {
        //     return _amount;
        // }
    }

    // uint256 public tres = 0;
    // uint256 public amount = 0;

    // function addFunds(uint256 _amount) public payable {
    //     amount = _amount;
    //     tres += msg.value;
    // }

    // checks that 60% of holders voted
    function votesAmountAllowToWithdraw(uint256 holders, uint256 votes)
        public
        pure
        returns (bool)
    {
        uint256 twoThirds = ((holders * 1000) / 3) * 2;
        return (votes * 1000 >= twoThirds);
    }

    // receive() external payable {
    //     require(balanceOf(msg.sender) != 0, "address does not own any token");
    // }
}
