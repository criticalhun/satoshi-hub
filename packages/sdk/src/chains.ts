import { Chain } from './types';

const chains: Chain[] = [
  {
    id: 11155111,
    name: 'Sepolia Testnet',
    isEvm: true,
    isTestnet: true,
    rpcUrl: 'https://eth-sepolia.g.alchemy.com/v2/demo',
  },
  {
    id: 80001,
    name: 'Mumbai Testnet',
    isEvm: true,
    isTestnet: true,
    rpcUrl: 'https://polygon-mumbai.g.alchemy.com/v2/demo',
  },
  {
    id: 421614,
    name: 'Arbitrum Sepolia Testnet',
    isEvm: true,
    isTestnet: true,
    rpcUrl: 'https://arb-sepolia.g.alchemy.com/v2/demo',
  },
];

export default chains;
