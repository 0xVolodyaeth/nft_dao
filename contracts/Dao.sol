// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ERC721Full.sol";

contract DAO is ERC721 {
    // address can own only one metal
    enum metal {
        Gold,
        Silver,
        Bronze
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

    uint256 public goldHodlers = 0;
    uint256 public silverHodlers = 0;
    uint256 public bronzeHodlers = 0;

    bool public goldTreasuryInited = false;
    bool public silverTreasuryInited = false;
    bool public bronzeTreasuryInited = false;

    uint256 public goldHodlersVotes = 0;
    uint256 public silverHodlersVotes = 0;
    uint256 public bronzeHodlersVotes = 0;

    uint256 tokenIdCounter = 0;

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

    function mint(uint256 _tokenType) public {
        require(
            owner == msg.sender,
            "mint is allowed to be used only by the owner"
        );
        require(
            (_tokenType >= 0) && (_tokenType <= 2),
            "nft type should be 1, 2, or 3"
        );

        _safeMint(msg.sender, tokenIdCounter);
        metal metalType = metal(_tokenType);

        if (metalType == metal.Gold) {
            require(goldHodlers < 20, "only 20 addresses can own a token");
            tokenIdToURI[
                tokenIdCounter
            ] = "https://bafybeiclahw6qhira3khhlnoqjvwddzo5p6xkvb2tlpq6i3usuoj3duaou.ipfs.infura-ipfs.io/";
            goldHodlers++;
        }

        if (metalType == metal.Silver) {
            require(silverHodlers < 20, "only 20 addresses can own a token");
            tokenIdToURI[
                tokenIdCounter
            ] = "https://bafybeid2azvpigjzxvop5dch4eicvhkg6sjyrduwlcvjhgasux47d2mqoq.ipfs.infura-ipfs.io/";
            silverHodlers++;
        }

        if (metalType == metal.Bronze) {
            require(bronzeHodlers < 20, "only 20 addresses can own a token");
            tokenIdToURI[
                tokenIdCounter
            ] = "https://bafybeif3jivdintrywrvyqf6t342mn35kpwdcnhhxqzk4ik3ugfrnznkdu.ipfs.infura-ipfs.io/";
            bronzeHodlers++;
        }

        tokenIdToMetalType[tokenIdCounter] = metalType;
        tokenIdCounter++;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = tokenIdToURI[_tokenId];
        if (bytes(_tokenURI).length == 0) {
            return _baseURI();
        }

        return _tokenURI;
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

    uint256 public tres = 0;
    uint256 public amount = 0;

    function addFunds(uint256 _amount) public payable {
        amount = _amount;
        tres += msg.value;
    }

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
