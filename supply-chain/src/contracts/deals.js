import web3 from './web3';

const address = '0xc0f359FE770F1b98932dB77dA3977A7174D35362'
const abi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_offersContractAddress",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "buyer",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "seller",
						"type": "address"
					},
					{
						"internalType": "enum DssSafeDeal.State",
						"name": "dealState",
						"type": "uint8"
					},
					{
						"internalType": "address",
						"name": "escrowAccoutAddress",
						"type": "address"
					}
				],
				"indexed": false,
				"internalType": "struct DssSafeDeal.Deal",
				"name": "deal",
				"type": "tuple"
			}
		],
		"name": "EscrowCreated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_UID",
				"type": "string"
			},
			{
				"internalType": "enum DssSafeDeal.State",
				"name": "_state",
				"type": "uint8"
			}
		],
		"name": "changeState",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_UID",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_buyer",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_ESMAddress",
				"type": "address"
			}
		],
		"name": "createEscrowDeal",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"name": "deals",
		"outputs": [
			{
				"internalType": "address",
				"name": "buyer",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "seller",
				"type": "address"
			},
			{
				"internalType": "enum DssSafeDeal.State",
				"name": "dealState",
				"type": "uint8"
			},
			{
				"internalType": "address",
				"name": "escrowAccoutAddress",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_UID",
				"type": "string"
			}
		],
		"name": "getDeal",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "buyer",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "seller",
						"type": "address"
					},
					{
						"internalType": "enum DssSafeDeal.State",
						"name": "dealState",
						"type": "uint8"
					},
					{
						"internalType": "address",
						"name": "escrowAccoutAddress",
						"type": "address"
					}
				],
				"internalType": "struct DssSafeDeal.Deal",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_UID",
				"type": "string"
			}
		],
		"name": "transactionDeal",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

const instance = new web3.eth.Contract(abi, address);

export default instance;
