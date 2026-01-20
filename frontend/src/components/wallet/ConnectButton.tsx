import { ConnectButton as RKConnectButton } from "@rainbow-me/rainbowkit";
import { Button } from "@/components/ui/button";

export function ConnectButton() {
  return (
    <RKConnectButton.Custom>
      {({
        account,
        chain,
        openAccountModal,
        openChainModal,
        openConnectModal,
        mounted
      }) => {
        if (!mounted || !account) {
          return (
            <Button onClick={openConnectModal}>
              Connect Wallet
            </Button>
          );
        }

        if (chain?.unsupported) {
          return (
            <Button variant="destructive" onClick={openChainModal}>
              Unsupported Network
            </Button> 
          );
        }

        const chainName = chain?.name ?? "Chain";
        return (
          <div className="flex gap-3">
            <Button variant="outline" onClick={openChainModal}>
              {chain?.hasIcon && chain.iconUrl && (
                <img
                  src={chain.iconUrl}
                  alt={chainName}
                  className="h-4 w-4 mr-2"
                />
              )}
              {chainName}
            </Button>

            <Button onClick={openAccountModal}>
              {account.displayName}
              {account.displayBalance ? ` (${account.displayBalance})` : ""}
            </Button>
          </div>
        );
      }}
    </RKConnectButton.Custom>
  );
}
