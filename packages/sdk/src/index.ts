import chains from '../chains.json';

export interface Chain {
  id: number;
  name: string;
  isTestnet: boolean;
  isEvm: boolean;
  rpcUrl: string;
}

export const ALL_CHAINS: Chain[] = chains;

export function getChainById(id: number): Chain | undefined {
  return ALL_CHAINS.find(chain => chain.id === id);
}
