import '@rainbow-me/rainbowkit/styles.css';
import {
  http,
  WagmiProvider
} from 'wagmi';
import {
  RainbowKitProvider,
  getDefaultConfig,
  lightTheme,
  darkTheme
} from '@rainbow-me/rainbowkit';
import type { Theme } from '@rainbow-me/rainbowkit';
import {
  QueryClient,
  QueryClientProvider
} from '@tanstack/react-query';

import { anvilChain } from './chains';

const queryClient = new QueryClient();

const projectId = import.meta.env.VITE_WALLETCONNECT_PROJECT_ID ?? '';

const config = getDefaultConfig({
  appName: 'Dapp Pet Shop',
  projectId,
  chains: [anvilChain],
  ssr: false,
  transports: {
    [anvilChain.id]: http()
  }
});

const getShadcnVar = (name: string) => `hsl(var(${name}))`;

function shadcnRainbowKitTheme(isDark: boolean): Theme {
  const baseTheme = isDark ? darkTheme() : lightTheme();

  return {
    ...baseTheme,

    colors: {
      ...baseTheme.colors,

      // 核心背景与文字映射
      modalBackground: getShadcnVar('--background'),
      modalText: getShadcnVar('--foreground'),
      accentColor: getShadcnVar('--primary'),
      accentColorForeground: getShadcnVar('--primary-foreground'),
      
      // 辅助颜色映射
      modalBorder: getShadcnVar('--border'),
      profileForeground: getShadcnVar('--card'),
      closeButton: getShadcnVar('--muted-foreground'),
      closeButtonBackground: getShadcnVar('--muted'),

      // 按钮样式
      connectButtonBackground: getShadcnVar('--secondary'),
      connectButtonText: getShadcnVar('--secondary-foreground')
    },

    radii: {
      ...baseTheme.radii,

      // 映射 shadcn 的圆角变量
      modal: 'var(--radius)',
      actionButton: 'var(--radius)'
    },

    fonts: {
      body: 'inherit' // 继承 shadcn 的全局字体
    }
  };
}

export function Web3Provider({ children }: { children: React.ReactNode }) {
  // TODO: 后续若有需求, 此处可以配合 next-themes 动态切换主题,
  // 指定主题颜色是暗色还是亮色.
  const isDark = false;

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
          theme={shadcnRainbowKitTheme(isDark)}
          modalSize='compact'
        >
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
