import chains from './chains';

export const ALL_CHAINS = chains;

export function getChainById(id: number) {
  return chains.find((c) => c.id === id);
}

// Exportáljuk az összes típust a types.ts fájlból
export * from './types';
