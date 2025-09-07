import { ChainInfo } from './types';

export const SUPPORTED_CHAINS: ChainInfo[] = [
  {
    chainId: 11155111,
    name: 'Sepolia Testnet',
    shortName: 'sep',
    networkId: 11155111,
    nativeCurrency: {
      name: 'Sepolia Ether',
      symbol: 'ETH',
      decimals: 18,
    },
    rpc: ['https://rpc.sepolia.org'],
    faucets: ['https://sepoliafaucet.com'],
    explorers: [
      {
        name: 'Etherscan',
        url: 'https://sepolia.etherscan.io',
        standard: 'EIP3091',
      },
    ],
    infoURL: 'https://sepolia.otterscan.io',
    isEVM: true,
    testnet: true,
  },
  {
    chainId: 80002,
    name: 'Polygon Amoy',
    shortName: 'amoy',
    networkId: 80002,
    nativeCurrency: {
      name: 'MATIC',
      symbol: 'MATIC',
      decimals: 18,
    },
    rpc: ['https://rpc-amoy.polygon.technology'],
    faucets: ['https://faucet.polygon.technology'],
    explorers: [
      {
        name: 'PolygonScan',
        url: 'https://amoy.polygonscan.com',
        standard: 'EIP3091',
      },
    ],
    infoURL: 'https://polygon.technology',
    isEVM: true,
    testnet: true,
  },
  {
    chainId: 421614,
    name: 'Arbitrum Sepolia',
    shortName: 'arb-sep',
    networkId: 421614,
    nativeCurrency: {
      name: 'Arbitrum Ether',
      symbol: 'ETH',
      decimals: 18,
    },
    rpc: ['https://sepolia-rollup.arbitrum.io/rpc'],
    faucets: ['https://bridge.arbitrum.io'],
    explorers: [
      {
        name: 'Arbiscan',
        url: 'https://sepolia.arbiscan.io',
        standard: 'EIP3091',
      },
    ],
    infoURL: 'https://arbitrum.io',
    isEVM: true,
    testnet: true,
  },
  {
    chainId: 43113,
    name: 'Avalanche Fuji',
    shortName: 'fuji',
    networkId: 43113,
    nativeCurrency: {
      name: 'Avalanche',
      symbol: 'AVAX',
      decimals: 18,
    },
    rpc: ['https://api.avax-test.network/ext/bc/C/rpc'],
    faucets: ['https://faucet.avax.network'],
    explorers: [
      {
        name: 'SnowTrace',
        url: 'https://testnet.snowtrace.io',
        standard: 'EIP3091',
      },
    ],
    infoURL: 'https://www.avax.network',
    isEVM: true,
    testnet: true,
  },
  {
    chainId: 97,
    name: 'BNB Chain Testnet',
    shortName: 'bnbt',
    networkId: 97,
    nativeCurrency: {
      name: 'BNB',
      symbol: 'tBNB',
      decimals: 18,
    },
    rpc: ['https://data-seed-prebsc-1-s1.binance.org:8545'],
    faucets: ['https://testnet.bnbchain.org/faucet-smart'],
    explorers: [
      {
        name: 'BscScan',
        url: 'https://testnet.bscscan.com',
        standard: 'EIP3091',
      },
    ],
    infoURL: 'https://www.bnbchain.org',
    isEVM: true,
    testnet: true,
  },
];

export const getChainInfo = (chainId: number): ChainInfo | undefined => {
  return SUPPORTED_CHAINS.find(chain => chain.chainId === chainId);
};

export const getEVMChains = (): ChainInfo[] => {
  return SUPPORTED_CHAINS.filter(chain => chain.isEVM);
};

export const getTestnetChains = (): ChainInfo[] => {
  return SUPPORTED_CHAINS.filter(chain => chain.testnet);
};
