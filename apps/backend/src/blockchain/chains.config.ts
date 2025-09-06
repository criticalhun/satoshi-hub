export interface ChainConfig {
  chainId: number;
  name: string;
  rpcUrl: string;
  nativeCurrency: string;
}

export const SUPPORTED_CHAINS: ChainConfig[] = [
  {
    chainId: 11155111,
    name: "Base Sepolia",
    rpcUrl: "https://base-sepolia.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 421613,
    name: "Arbitrum Sepolia",
    rpcUrl: "https://arbitrum-sepolia.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 420,
    name: "Optimism Sepolia",
    rpcUrl: "https://optimism-sepolia.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 80001,
    name: "Polygon Amoy",
    rpcUrl: "https://polygon-amoy.rpc-url.com",
    nativeCurrency: "MATIC",
  },
  {
    chainId: 280,
    name: "zkSync Testnet",
    rpcUrl: "https://zksync-testnet.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 534353,
    name: "Scroll Testnet",
    rpcUrl: "https://scroll-testnet.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 59140,
    name: "Linea Sepolia",
    rpcUrl: "https://linea-sepolia.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 43113,
    name: "Avalanche Fuji",
    rpcUrl: "https://api.avax-test.network/ext/bc/C/rpc",
    nativeCurrency: "AVAX",
  },
  {
    chainId: 97,
    name: "BNB Chain Testnet",
    rpcUrl: "https://data-seed-prebsc-1-s1.binance.org:8545",
    nativeCurrency: "BNB",
  },
  {
    chainId: 5001,
    name: "Mantle Testnet",
    rpcUrl: "https://mantle-testnet.rpc-url.com",
    nativeCurrency: "BIT",
  },
  {
    chainId: 167004,
    name: "Taiko",
    rpcUrl: "https://taiko-testnet.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: 1,
    name: "StarkNet Testnet",
    rpcUrl: "https://starknet-testnet.rpc-url.com",
    nativeCurrency: "ETH",
  },
  {
    chainId: -1, // Speciális jelzés, nem EVM kompatibilis
    name: "Solana Devnet",
    rpcUrl: "https://api.devnet.solana.com",
    nativeCurrency: "SOL",
  },
];
