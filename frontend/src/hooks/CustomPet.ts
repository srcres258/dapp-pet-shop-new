import {
  useReadContract,
  useConnection,
  usePublicClient
} from 'wagmi';
import { useMemo } from 'react';
import { type Address } from 'viem';
import {
  contractAddress,
  contractABI
} from '@/constants';
import { useQueries } from '@tanstack/react-query';

export function useOwnedPets(address: Address) {
  const client = usePublicClient();

  const { address: connectedAddress } = useConnection();
  const owner = address || connectedAddress;

  const { data: balance } = useReadContract({
    address: contractAddress.CustomPet,
    abi: contractABI.CustomPet,
    functionName: 'balanceOf',
    args: owner ? [owner] : undefined,
    query: {
      enabled: !!owner,
      refetchInterval: 2000
    }
  });

  // balance: 通常是 bigint 类型
  const count = Number(balance || 0n);

  // 动态生成多个查询
  // const results = Array.from({ length: count }, (_, index) => {
  //   return useReadContract({
  //     address: contractAddress.CustomPet,
  //     abi: contractABI.CustomPet,
  //     functionName: 'tokenOfOwnerByIndex',
  //     args: owner ? [owner, BigInt(index)] : undefined,
  //     query: {
  //       enabled: !!owner && count > 0
  //     }  
  //   });
  // });
  const rawResults = client ? useQueries({
    queries: Array.from({ length: count }, (_, index) => {
      return {
        queryKey: ['readContract', contractAddress.CustomPet, 'tokenOfOwnerByIndex', owner, index],
        queryFn: async () => {
          if (!owner) throw new Error('Owner address is required');
          const result = await client.readContract({
            address: contractAddress.CustomPet,
            abi: contractABI.CustomPet,
            functionName: 'tokenOfOwnerByIndex',
            args: [owner, BigInt(index)]
          });
          return result;
        },
        enabled: !!owner && count > 0
      };
    })
  }) : null;
  const results = rawResults || [];

  // 收集结果
  const tokenIds = useMemo(() => {
    return results
      .map(r => r.data)
      .filter((id): id is bigint => id !== undefined);
  }, [results]);

  return {
    tokenIds,
    isLoading: results.some(r => r.isLoading) || !!balance === undefined,
    error: results.find(r => r.error)?.error,
    count
  };
}
