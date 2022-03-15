const DAO = artifacts.require("DAO");
const { syncBuiltinESMExports } = require('module');
const truffleAssert = require('truffle-assertions');




contract("DAO", async accounts => {
	let instance;
	beforeEach(async () => {
		instance = await DAO.new();
	})


	it("should mint only 20 tokens of each kind and revert othe mints", async () => {
		let tokenAmount;
		for (i = 0; i < 20; i++) {
			const goldTokenID = await instance.mintMetal(0);
			const silverTokenID = await instance.mintMetal(1);
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



		// await new Promise(r => setTimeout(r, 2000));
		// setTimeout(() => { console.log("World!"); }, 4000);
		await sleep(20000);

		const goldTokenURI = await instance.tokenURI(0);
		const silverTokenURI = await instance.tokenURI(1);
		const bronzeTokenURI = await instance.tokenURI(2);


		console.log(goldTokenURI);
		console.log(silverTokenURI);
		console.log(bronzeTokenURI);

	})
});



function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}
