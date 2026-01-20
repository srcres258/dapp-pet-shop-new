import type { Chain } from '@rainbow-me/rainbowkit';

export const ephemeryChain = {
  id: 39438155,
  name: 'Ephemery Chain',
  nativeCurrency: {
    name: 'Ephemery ETH',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['https://otter.bordel.wtf/erigon']
    }
  },
  blockExplorers: {
    default: {
      name: 'Testnet Ethereum Explorer',
      url: 'https://explorer.ephemery.dev'
    }
  }
} as const satisfies Chain;

export const anvilChain = {
  id: 31337,
  name: 'Anvil Chain',
  nativeCurrency: {
    name: 'Anvil ETH',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['http://127.0.0.1:8545']
    }
  }
} as const satisfies Chain;
