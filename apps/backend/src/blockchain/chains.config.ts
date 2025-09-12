export interface Chain {
  chainId: number;
  name: string;
  rpcUrl: string;
  type: 'evm' | 'solana' | 'other'; // Láncok típusa
  symbol: string;
  blockExplorer?: string;
  contracts?: {
    vrfCoordinator?: string;
    // Egyéb szerződéscímek
  };
}

export const CHAINS: Chain[] = [
  {
    chainId: 11155111,
    name: 'Sepolia',
    rpcUrl: 'https://rpc.sepolia.org',
    type: 'evm', // Ethereum Virtual Machine kompatibilis
    symbol: 'ETH',
    blockExplorer: 'https://sepolia.etherscan.io',
    contracts: {
      vrfCoordinator: '0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625'
    }
  },
  {
    chainId: 421613,
    name: 'Arbitrum Goerli',
    rpcUrl: 'https://goerli-rollup.arbitrum.io/rpc',
    type: 'evm',
    symbol: 'ETH',
    blockExplorer: 'https://goerli.arbiscan.io'
  },
  {
    chainId: 420,
    name: 'Optimism Goerli',
    rpcUrl: 'https://goerli.optimism.io',
    type: 'evm',
    symbol: 'ETH',
    blockExplorer: 'https://goerli-optimism.etherscan.io'
  },
  {
    chainId: 80001,
    name: 'Polygon Mumbai',
    rpcUrl: 'https://rpc-mumbai.maticvigil.com',
    type: 'evm',
    symbol: 'MATIC',
    blockExplorer: 'https://mumbai.polygonscan.com'
  },
  {
    chainId: 43113,
    name: 'Avalanche Fuji',
    rpcUrl: 'https://api.avax-test.network/ext/bc/C/rpc',
    type: 'evm',
    symbol: 'AVAX',
    blockExplorer: 'https://testnet.snowtrace.io'
  },
  {
    chainId: 97,
    name: 'BNB Chain Testnet',
    rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545',
    type: 'evm',
    symbol: 'BNB',
    blockExplorer: 'https://testnet.bscscan.com'
  },
  {
    chainId: -1, // Példa nem-EVM láncra (Solana)
    name: 'Solana Devnet',
    rpcUrl: 'https://api.devnet.solana.com',
    type: 'solana',
    symbol: 'SOL',
    blockExplorer: 'https://explorer.solana.com/?cluster=devnet'
  }
];
