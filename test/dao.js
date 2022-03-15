const DAO = artifacts.require("DAO");
const truffleAssert = require('truffle-assertions');

contract("DAO", async accounts => {
	let instance;
	beforeEach(async () => {
		instance = await DAO.new();
	})


	it("should mint only 20 tokens of each kind and revert othe mints", async () => {
		let tokenAmount;
		for (i = 0; i < 20; i++) {
			await instance.mintMetal(0);
			await instance.mintMetal(1);
			const bronzeTokenID = await instance.mintMetal(2);

			tokenAmount = bronzeTokenID.logs[0].args['2'].toNumber()
		}

		assert.equal(60, tokenAmount);
		await truffleAssert.reverts(instance.mintMetal(0));
		await truffleAssert.reverts(instance.mintMetal(1));
		await truffleAssert.reverts(instance.mintMetal(2));
	});

	it("should return URI for each token type", async () => {
		const goldTokenID = await instance.mintMetal(0);
		const silverTokenID = await instance.mintMetal(1);
		const bronzeTokenID = await instance.mintMetal(2);

		const goldTransactionHash = goldTokenID.logs[0].transactionHash;
		const silverTransactionHash = silverTokenID.logs[0].transactionHash;
		const bronzeTransactionHash = bronzeTokenID.logs[0].transactionHash;

		const expBlockTime = 200;
		await waitForTransactionToBeMined(goldTransactionHash, expBlockTime);
		await waitForTransactionToBeMined(silverTransactionHash, expBlockTime);
		await waitForTransactionToBeMined(bronzeTransactionHash, expBlockTime);

		const goldTokenURI = await instance.tokenURI(1);
		const silverTokenURI = await instance.tokenURI(2);
		const bronzeTokenURI = await instance.tokenURI(3);

		assert.equal(goldTokenURI, "https://bafybeiclahw6qhira3khhlnoqjvwddzo5p6xkvb2tlpq6i3usuoj3duaou.ipfs.infura-ipfs.io/")
		assert.equal(silverTokenURI, "https://bafybeid2azvpigjzxvop5dch4eicvhkg6sjyrduwlcvjhgasux47d2mqoq.ipfs.infura-ipfs.io/")
		assert.equal(bronzeTokenURI, "https://bafybeif3jivdintrywrvyqf6t342mn35kpwdcnhhxqzk4ik3ugfrnznkdu.ipfs.infura-ipfs.io/")
	})


	it("it should mint 20 tokens of each type and vote", async () => {
		// gold
		let tokenAmount = 0;
		for (i = 0; i < 20; i++) {
			const goldTokenId = await instance.mintMetal(0);
			tokenAmount = goldTokenId.logs[0].args['2'].toNumber();
		}

		assert.equal(tokenAmount, 20);
		for (i = 0; i < tokenAmount; i++) {
			await instance.vote(i + 1);
		}

		await truffleAssert.reverts(instance.vote(1));


		// silver
		tokenAmount = 0;
		for (i = 0; i < 20; i++) {
			const silverTokenId = await instance.mintMetal(1);
			tokenAmount = silverTokenId.logs[0].args['2'].toNumber();
		}

		assert.equal(tokenAmount, 40);
		for (i = tokenAmount - 20; i < tokenAmount; i++) {
			await instance.vote(i + 1);
		}

		await truffleAssert.reverts(instance.vote(21));


		// // bronze
		tokenAmount = 0;
		for (i = 0; i < 20; i++) {
			const bronzeTokenId = await instance.mintMetal(2);
			tokenAmount = bronzeTokenId.logs[0].args['2'].toNumber();
		}
		//
		assert.equal(tokenAmount, 60);
		for (i = tokenAmount - 20; i < tokenAmount; i++) {
			await instance.vote(i + 1);
		}
		await truffleAssert.reverts(instance.vote(41));

		// token which does not exist
		await truffleAssert.reverts(instance.vote(100));
	})

	it("creates tokens of each kind and inits treasury", async () => {
		await instance.createTreasury(0);
		await instance.createTreasury(1);
		await instance.createTreasury(2);

		await truffleAssert.reverts(instance.createTreasury(4));
	});

	it("creates tresuaries and transfers eth there", async () => {

		await instance.createTreasury(0);
		await instance.createTreasury(1);
		await instance.createTreasury(2);

		const contract = new web3.eth.Contract(
			instance.abi,
			instance.address
		);
		const addresses = await web3.eth.getAccounts();

		const goldTokenID = await instance.mintMetal(0);
		const goldTransactionHash = goldTokenID.logs[0].transactionHash;
		await waitForTransactionToBeMined(goldTransactionHash, 200);

		let res = await contract.methods.transferToTreasury(0).send({
			from: addresses[0],
			value: 1 * 1e18
		});
		await waitForTransactionToBeMined(res.transactionHash, 200);

		let balance = await instance.getContractBalance();
		let expBalance = (1 * 1e18).toString();
		assert.equal(balance.toString(), expBalance);

		const amountOfGold = await instance.amountGold();
		assert.equal(amountOfGold.toString(), expBalance);


		const silverTokenID = await instance.mintMetal(1);
		const silverTransactionHash = silverTokenID.logs[0].transactionHash;
		await waitForTransactionToBeMined(silverTransactionHash, 200);

		res = await contract.methods.transferToTreasury(1).send({
			from: addresses[0],
			value: 1 * 1e18
		});
		await waitForTransactionToBeMined(res.transactionHash, 200);

		balance = await instance.getContractBalance();
		expBalance = (2 * 1e18).toString();
		assert.equal(balance.toString(), expBalance);

		const amountOfSilver = await instance.amountSilver();
		assert.equal(amountOfSilver.toString(), (1 * 1e18).toString());


		const bronzeTokenID = await instance.mintMetal(2);
		const bronzeTransactionHash = bronzeTokenID.logs[0].transactionHash;
		await waitForTransactionToBeMined(bronzeTransactionHash, 200);

		res = await contract.methods.transferToTreasury(2).send({
			from: addresses[0],
			value: 1 * 1e18
		});
		await waitForTransactionToBeMined(res.transactionHash, 200);

		balance = await instance.getContractBalance();
		expBalance = (3 * 1e18).toString();
		assert.equal(balance.toString(), expBalance);

		const amountOfBronze = await instance.amountBronze();
		assert.equal(amountOfBronze.toString(), (1e18).toString());
	});


	it("should mint several tokens, add funds, vote and withdraw", async () => {

		await instance.createTreasury(0);
		const contract = new web3.eth.Contract(
			instance.abi,
			instance.address
		);
		const addresses = await web3.eth.getAccounts();

		const goldTokenIDFirst = await instance.mintMetal(0);
		const goldTokenIDSecond = await instance.mintMetal(0);
		const goldTokenIDThird = await instance.mintMetal(0);

		const goldTransactionHashFirst = goldTokenIDFirst.logs[0].transactionHash;
		const goldTransactionHashSecond = goldTokenIDSecond.logs[0].transactionHash;
		const goldTransactionHashThird = goldTokenIDThird.logs[0].transactionHash;

		await waitForTransactionToBeMined(goldTransactionHashFirst, 200);
		await waitForTransactionToBeMined(goldTransactionHashSecond, 200);
		await waitForTransactionToBeMined(goldTransactionHashThird, 200);

		let res = await contract.methods.transferToTreasury(0).send({
			from: addresses[0],
			value: 10 * 1e18
		});
		await waitForTransactionToBeMined(res.transactionHash, 200);

		const firstVote = await instance.vote(1);
		const secondVote = await instance.vote(2);

		const firstVoteTransactionHash = firstVote.receipt.transactionHash;
		const secondVoteTransactionHash = secondVote.receipt.transactionHash;

		await waitForTransactionToBeMined(firstVoteTransactionHash, 200);
		await waitForTransactionToBeMined(secondVoteTransactionHash, 200);

		const goldHoldersVotes = await instance.goldHoldersVotes();
		assert.equal(goldHoldersVotes.toString(), "2")



		let gol = await instance.amountGold();
		const withdrawTransactionReceipt = await instance.withdraw(web3.utils.toBN((5e18).toString()), 0);
		assert.equal(withdrawTransactionReceipt.logs[0].args["1"].toString(), (5 * 1e18).toString());
	})
});



async function waitForTransactionToBeMined(transactionHash, expectedBlockTime) {
	let transactionReceipt = null;
	while (transactionReceipt == null) {
		transactionReceipt = await web3.eth.getTransactionReceipt(transactionHash);
		await sleep(expectedBlockTime);
	}

	return transactionReceipt;
}


function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}
