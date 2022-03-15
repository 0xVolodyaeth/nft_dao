// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DAO is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    event WithDrawal(address to, uint256 amount);

    // address can own only one metal and several tokens of the metal
    enum metal {
        Gold,
        Silver,
        Bronze
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    mapping(uint256 => metal) tokenIdToMetalType;
    mapping(uint256 => bool) tokenIdToVote;

    address owner;

    uint256 public amountGold = 0;
    uint256 public amountSilver = 0;
    uint256 public amountBronze = 0;

    Counters.Counter public goldHodlers;
    Counters.Counter public silverHodlers;
    Counters.Counter public bronzeHodlers;

    bool public goldTreasuryInited = false;
    bool public silverTreasuryInited = false;
    bool public bronzeTreasuryInited = false;

    uint256 public goldHoldersVotes = 0;
    uint256 public silverHoldersVotes = 0;
    uint256 public bronzeHoldersVotes = 0;

    string goldURI =
        "https://bafybeiclahw6qhira3khhlnoqjvwddzo5p6xkvb2tlpq6i3usuoj3duaou.ipfs.infura-ipfs.io/";
    string silverURI =
        "https://bafybeid2azvpigjzxvop5dch4eicvhkg6sjyrduwlcvjhgasux47d2mqoq.ipfs.infura-ipfs.io/";
    string bronzeURI =
        "https://bafybeif3jivdintrywrvyqf6t342mn35kpwdcnhhxqzk4ik3ugfrnznkdu.ipfs.infura-ipfs.io/";

    constructor() payable ERC721("metals", "METALS") {
        owner = msg.sender;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // TODO: use safemath instead of + sign
    function transferToTreasury(metal _tokenMetal) public payable {
        require(balanceOf(msg.sender) != 0, "address does not own any tokens");

        metal metalType = metal(_tokenMetal);
        if (metalType == metal.Gold) {
            require(
                goldTreasuryInited,
                "treasury should be inted by the admin first"
            );
            amountGold += msg.value;
            return;
        }

        if (metalType == metal.Silver) {
            require(
                silverTreasuryInited,
                "treasury should be inted by the admin first"
            );
            amountSilver += msg.value;
            return;
        }

        if (metalType == metal.Bronze) {
            require(
                bronzeTreasuryInited,
                "treasury should be inted by the admin first"
            );
            amountBronze += msg.value;
            return;
        }

        revert("unknown metal type");
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

        revert("unknown metal type");
    }

    // vote:
    // one token == one vote, user can vote as
    // many times as many tokens he has
    function vote(uint256 _tokenId) public {
        require(_exists(_tokenId), "token does not exists");
        metal tokenMetal = tokenIdToMetalType[_tokenId];
        require(ownerOf(_tokenId) == msg.sender, "address is not token owner");
        require(!tokenIdToVote[_tokenId], "token has voted already");

        if (tokenMetal == metal.Gold) {
            goldHoldersVotes++;
        }

        if (tokenMetal == metal.Silver) {
            silverHoldersVotes++;
        }

        if (tokenMetal == metal.Bronze) {
            bronzeHoldersVotes++;
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
        super._safeMint(msg.sender, current);

        metal metalType = metal(_tokenType);

        if (metalType == metal.Gold) {
            require(goldHodlers.current() < 20, "only 20 can be minted");
            super._setTokenURI(current, goldURI);
            goldHodlers.increment();
        }

        if (metalType == metal.Silver) {
            require(silverHodlers.current() < 20, "only 20 can be minted");
            super._setTokenURI(current, silverURI);
            silverHodlers.increment();
        }

        if (metalType == metal.Bronze) {
            require(bronzeHodlers.current() < 20, "only 20 can be minted");
            super._setTokenURI(current, bronzeURI);
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
        return super.tokenURI(_tokenId);
    }

    // Creates treasury for specified token type
    // could be invoced only by dao admin
    function createTreasury(uint256 _nftType) public {
        require(
            owner == address(msg.sender),
            "only dao admin can create a treasury"
        );

        metal tokenMetal = metal(_nftType);

        if ((tokenMetal == metal.Gold) && !goldTreasuryInited) {
            goldTreasuryInited = true;
            return;
        }
        if ((tokenMetal == metal.Silver) && !silverTreasuryInited) {
            silverTreasuryInited = true;
            return;
        }
        if ((tokenMetal == metal.Bronze) && !bronzeTreasuryInited) {
            bronzeTreasuryInited = true;
            return;
        }

        revert("unknown nft type or treasury has been inited already");
    }

    function withdraw(uint256 _amount, metal _metal) public payable {
        require(_amount >= 0, "amount should be positive");
        require(msg.sender == owner, "only owner can withdraw funds");

        metal metalType = metal(_metal);
        if (metalType == metal.Gold) {
            require(
                _amount <= amountGold,
                "withdraw amount should be less or equal to the amount in treasury"
            );
            if (
                votesAmountAllowToWithdraw(
                    goldHodlers.current(),
                    goldHoldersVotes
                )
            ) {
                (bool sent, ) = msg.sender.call{value: _amount}("");
                emit WithDrawal(msg.sender, _amount);
                require(sent, "failed to send transaction");
                return;
            }
        }
        if (metalType == metal.Silver) {
            require(
                _amount <= amountSilver,
                "withdraw amount should be less or equal to the amount in treasury"
            );
            if (
                votesAmountAllowToWithdraw(
                    silverHodlers.current(),
                    silverHoldersVotes
                )
            ) {
                (bool sent, ) = msg.sender.call{value: _amount}("");
                emit WithDrawal(msg.sender, _amount);
                require(sent, "failed to send transaction");
                return;
            }
        }
        if (metalType == metal.Bronze) {
            require(
                _amount <= amountBronze,
                "withdraw amount should be less or equal to the amount in treasury"
            );
            if (
                votesAmountAllowToWithdraw(
                    bronzeHodlers.current(),
                    bronzeHoldersVotes
                )
            ) {
                (bool sent, ) = msg.sender.call{value: _amount}("");
                emit WithDrawal(msg.sender, _amount);
                require(sent, "failed to send transaction");
                return;
            }
        }
        revert("unknown token metal type");
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
}
