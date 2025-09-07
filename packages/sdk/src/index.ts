// Types
export * from './types';

// Chain data
export * from './chains';

// Utilities
export const formatTransactionHash = (hash: string): string => {
  return `${hash.slice(0, 6)}...${hash.slice(-4)}`;
};

export const formatAddress = (address: string): string => {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

export const formatAmount = (amount: string, decimals: number = 18): string => {
  const num = parseFloat(amount);
  if (num === 0) return '0';
  if (num < 0.001) return '<0.001';
  return num.toFixed(4);
};
