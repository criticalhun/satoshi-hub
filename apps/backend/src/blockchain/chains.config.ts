export interface ChainConfig {
  chainId: number;
  name: string;
  rpcUrl: string;
  nativeCurrency: string;
}

export const SUPPORTED_CHAINS: ChainConfig[] = [
  {
    chainId: 11155111,
    name: "Sepolia Testnet",
    rpcUrl: "https://rpc.sepolia.org",
    nativeCurrency: "ETH",
  },
  {
    chainId: 80002,
    name: "Polygon Amoy",
    rpcUrl: "https://rpc-amoy.polygon.technology/",
    nativeCurrency: "MATIC",
  },
  {
    chainId: 421614,
    name: "Arbitrum Sepolia",
    rpcUrl: "https://arb-sepolia.g.alchemy.com/v2/demo",
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
    chainId: -1, // Speciális: nem EVM kompatibilis
    name: "Solana Devnet",
    rpcUrl: "https://api.devnet.solana.com",
    nativeCurrency: "SOL",
  },
];
