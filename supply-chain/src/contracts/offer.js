import web3 from './web3';

export const address = '0xF5Dd44A279B89d1e7E8CEB84cfFb1f0B3e4Dc7eD'

const abi = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "string",
				"name": "_UID",
				"type": "string"
			}
		],
		"name": "ProductCreated",
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
				"internalType": "string",
				"name": "_title",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_type_v",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_currency",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_wallet",
				"type": "address"
			}
		],
		"name": "createOffer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "offerList",
		"outputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "title",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "type_v",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "price",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "currency",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "OwnerWallet",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "uid",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "returnAllOffers",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "title",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "type_v",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "price",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "amount",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "currency",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "OwnerWallet",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "uid",
						"type": "string"
					}
				],
				"internalType": "struct Offers.Offer[]",
				"name": "",
				"type": "tuple[]"
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
		"name": "returnOfferByUID",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "title",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "type_v",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "price",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "amount",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "currency",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "OwnerWallet",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "uid",
						"type": "string"
					}
				],
				"internalType": "struct Offers.Offer",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]

export const createContract = (address, from='0x06221c24fBa452c2a2716F9Ec705fd001536296a') => { //hardcode wallet metamask
  // web3.eth.setProvider('http://95.163.208.208:19000/')
  const instance = new web3.eth.Contract(abi, address, { from });
  return instance;
};

