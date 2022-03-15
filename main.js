const Web3 = require('web3');
const MyContract = require('./build/contracts/dao.json');


const init = async () => {
	const web3 = new Web3("http://localhost:7545");
	const id = await web3.eth.net.getId();
	const deployedNetwork = MyContract.networks[id];

	const contract = new web3.eth.Contract(
		MyContract.abi,
		deployedNetwork.address
	);

	const addresses = await web3.eth.getAccounts();
	console.log(addresses)

	// await contract.methods.addFunds(1).send({
	// 	from: addresses[0],
	// 	value: 20000000000000000
	// });

	// console.log(await contract.methods.tres().call());
	// console.log(await contract.methods.amount().call());
	const okenId = await contract.methods.mintMetal(0).send({ from: addresses[0], gas: 1000000 });
	console.log(okenId.events.Transfer)
	console.log(okenId)
}


init()