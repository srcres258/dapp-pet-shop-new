import { useReadContract, useConnection } from 'wagmi';
import { type Address } from 'viem';
import { contractAddress, contractABI } from '@/constants';
import { useQueries } from '@tanstack/react-query';

export function useOwnedCPs(address?: Address) {
  const { address: connectedAddress } = useConnection();
  const user = address || connectedAddress;

  const { data, isLoading, error } = useReadContract({
    address: contractAddress.Viewer,
    abi: contractABI.Viewer,
    functionName: 'getOwnedCPs',
    args: user ? [user] : undefined,
    query: {
      enabled: !!user,
      refetchInterval: 5000
    }
  });

  return {
    tokenIds: data?.[0] || [],
    tokenURIs: data?.[1] || [],
    isLoading,
    error
  };
}

export function useUserAllTrades(address?: Address) {
  const { address: connectedAddress } = useConnection();
  const user = address || connectedAddress;

  const { data, isLoading, error } = useReadContract({
    address: contractAddress.Viewer,
    abi: contractABI.Viewer,
    functionName: 'getUserAllTrades',
    args: user ? [user] : undefined,
    query: {
      enabled: !!user,
      refetchInterval: 5000
    }
  });

  return {
    trades: data || [],
    isLoading,
    error
  };
}

export function useTradeDetails(tradeAddress: Address, userAddress: Address) {
  const { data: seller, isLoading: sellerLoading } = useReadContract({
    address: tradeAddress,
    abi: contractABI.Trade,
    functionName: 'seller',
    query: {
      enabled: !!tradeAddress
    }
  });

  const { data: buyer, isLoading: buyerLoading } = useReadContract({
    address: tradeAddress,
    abi: contractABI.Trade,
    functionName: 'buyer',
    query: {
      enabled: !!tradeAddress
    }
  });

  const role = seller === userAddress ? 'Seller' : buyer === userAddress ? 'Buyer' : null;

  return {
    seller,
    buyer,
    role,
    isLoading: sellerLoading || buyerLoading
  };
}