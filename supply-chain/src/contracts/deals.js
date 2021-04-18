import web3 from './web3';

export const address = '0x7aa919aEC9655690A4DC2F815c1c3Dea9E3aCafB'

const abi = [
  {
   "anonymous": false,
   "inputs": [
    {
     "indexed": false,
     "internalType": "string",
     "name": "UID",
     "type": "string"
    },
    {
     "indexed": false,
     "internalType": "address payable",
     "name": "buyer",
     "type": "address"
    },
    {
     "indexed": false,
     "internalType": "address payable",
     "name": "seller",
     "type": "address"
    }
   ],
   "name": "ESMCreated",
   "type": "event"
  },
  {
   "anonymous": false,
   "inputs": [
    {
     "indexed": false,
     "internalType": "string",
     "name": "UID",
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
     "internalType": "address payable",
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
     "internalType": "address payable",
     "name": "OwnerWallet",
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
     "name": "",
     "type": "string"
    }
   ],
   "name": "offers",
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
     "internalType": "address payable",
     "name": "OwnerWallet",
     "type": "address"
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
       "internalType": "address payable",
       "name": "OwnerWallet",
       "type": "address"
      }
     ],
     "internalType": "struct Offers.Offer[]",
     "name": "",
     "type": "tuple[]"
    }
   ],
   "stateMutability": "view",
   "type": "function"
  }
 ]

export const createContract = (address, from='') => { //hardcode wallet metamask
  web3.eth.setProvider('http://95.163.208.208:19000/')
  const instance = new web3.eth.Contract(abi, address, { from });
  return instance;
};

