export interface Chain {
  id: number;
  name: string;
  isEvm: boolean;
  isTestnet: boolean;
  rpcUrl?: string;
}
