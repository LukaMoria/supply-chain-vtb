import Web3 from 'web3';

if (window.ethereum) {
  window.web3 = new Web3(window.ethereum);
  //window.web3.eth.setProvider('http://95.163.208.208:19000/')
  try {
    // Request account access if needed
    window.ethereum.enable();
    console.log('success')
  } catch (error) {
    // User denied account access...
  }
} else if (window.web3) { // Legacy dapp browsers...
  window.web3 = new Web3(window.web3.currentProvider);
} else { // Non-dapp browsers...
  console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
}
console.log(window.web3);
export default window.web3;