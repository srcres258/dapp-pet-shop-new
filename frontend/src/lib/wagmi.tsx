import {
  http,
  WagmiProvider
} from 'wagmi';
import {
  RainbowKitProvider,
  getDefaultConfig
} from '@rainbow-me/rainbowkit';
import type { Chain } from '@rainbow-me/rainbowkit';
import {
  QueryClient,
  QueryClientProvider
} from '@tanstack/react-query';

const queryClient = new QueryClient();

const projectId = import.meta.env.VITE_WALLETCONNECT_PROJECT_ID ?? '';

const ephemeryChain = {
  id: 1337,
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

const config = getDefaultConfig({
  appName: 'Dapp Pet Shop',
  projectId,
  chains: [ephemeryChain],
  ssr: false,
  transports: {
    [ephemeryChain.id]: http()
  }
});

export function Web3Provider({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>{children}</RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
