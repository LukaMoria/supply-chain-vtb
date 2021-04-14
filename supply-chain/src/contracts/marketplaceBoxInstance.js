import web3 from './web3';

const address = '0xf2e9d38da2fe43c701e7e097905d548afe369e88'
const abi = [
	{
	 "inputs": [
	  {
	   "internalType": "string",
	   "name": "_title",
	   "type": "string"
	  },
	  {
	   "internalType": "uint256",
	   "name": "_price",
	   "type": "uint256"
	  },
	  {
	   "internalType": "string",
	   "name": "_description",
	   "type": "string"
	  },
	  {
	   "internalType": "uint256",
	   "name": "_quantity",
	   "type": "uint256"
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
	 "name": "offers",
	 "outputs": [
	  {
	   "internalType": "contract Offer",
	   "name": "",
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
	   "internalType": "contract Offer[]",
	   "name": "",
	   "type": "address[]"
	  }
	 ],
	 "stateMutability": "view",
	 "type": "function"
	}
	]

const instance = new web3.eth.Contract(abi, address);

export default instance;
