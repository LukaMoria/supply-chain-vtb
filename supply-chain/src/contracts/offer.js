import web3 from './web3';
//'0x971dfea71d158139cfb26c82af00c640329ad2cf' //vtb
export const address = '0x34cD9538D94f478eFB5CEc2E8e7a534D0Ba28FF1'

const abi = [
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
     "internalType": "uint16",
     "name": "_currencyCode",
     "type": "uint16"
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
    }
   ],
   "name": "getAmountByUID",
   "outputs": [
    {
     "internalType": "uint256",
     "name": "",
     "type": "uint256"
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
   "name": "getCodeByUID",
   "outputs": [
    {
     "internalType": "uint16",
     "name": "",
     "type": "uint16"
    }
   ],
   "stateMutability": "view",
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
     "internalType": "uint16",
     "name": "currencyCode",
     "type": "uint16"
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
       "internalType": "uint16",
       "name": "currencyCode",
       "type": "uint16"
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
  }
 ]

export const createContract = (address, from='') => {
  const instance = new web3.eth.Contract(abi, address, { from });
  return instance;
};

