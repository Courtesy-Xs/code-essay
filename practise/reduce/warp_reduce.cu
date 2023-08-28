#include <stdio.h>

__global__ void ker_butterfly_warp_reduce()
{
    int laneId = threadIdx.x & 0x1f;
    // Seed starting value as inverse lane ID
    int value = 31 - laneId;

    // Use XOR mode to perform butterfly reduction
    for (int i=16; i>=1; i/=2)
        value += __shfl_xor_sync(0xffffffff, value, i, 32);

    // "value" now contains the sum across all threads
    printf("Thread %d final value = %d\n", threadIdx.x, value);
}

__global__ void ker_tree_warp_reduce()
{
    int tid = threadIdx.x;
    int val = 1;
    for(int i = 16; i > 0; i>>= 1)
    {
        val+=__shfl_down_sync(0xffffffff,val,i);
    }
    printf("Thread %d final value = %d\n", threadIdx.x, val);
}

__global__ void ker_test(int* data)
{
    int tid = threadIdx.x;
    int val = 1;
    if(tid < 16)
    {
        val+=__shfl_down_sync(0xffffffff,val,1);
    }
    printf("Thread %d final value = %d\n", threadIdx.x, val);
}

int main() {
    // ker_butterfly_warp_reduce<<< 1, 32 >>>();
    ker_tree_warp_reduce<<< 1, 32 >>>();

    // ker_test<<<1,64>>>();
    cudaDeviceSynchronize();

    return 0;
}
