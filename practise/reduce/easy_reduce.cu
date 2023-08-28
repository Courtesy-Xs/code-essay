#include <stdio.h>

#define CUDA_CHECK(res) if(res!=cudaSuccess) { printf("Error: %s%d\n",__FILE__,__LINE__);   \
printf("Error code: %d, Reason: %s\n",res,cudaGetErrorString(res));}

const int kGridSize = 1;
const int kBlockSize = 1024;

__global__ void ker_reduce(int* src, int len)
{
    __shared__ int shm[1024];

    int tid = threadIdx.x + blockIdx.x*blockDim.x;

    shm[tid] = src[tid];

    __syncthreads();

    for(int i = len>>1; i > 0 ; i>>=1)
    {
        if(tid < i)
        {
            shm[tid] += shm[tid+i];
        }
        __syncthreads();
    }
    if(tid == 0)
    {
        src[0] = shm[0];
    }
}


void destory(int* harr, int* darr)
{
    delete harr;
    cudaFree(darr);
}

int main()
{
    int *harr = nullptr;
    int *darr = nullptr;
    const int numel = 1024;

    harr = (int*)malloc(numel*sizeof(int));
    CUDA_CHECK(cudaMalloc((void**)(&darr),numel*sizeof(int)));

    for(int i = 0; i < numel; ++i)
    {
        *(harr+i) = 1;
    }

    CUDA_CHECK(cudaMemcpy(darr,harr,sizeof(int)*numel,cudaMemcpyHostToDevice));

    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start,0);

    ker_reduce<<<kGridSize,kBlockSize,0,0>>>(darr,numel);

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    float elapsed_time = 0.0f;
    cudaEventElapsedTime(&elapsed_time,start,stop);
    float bandwidth = float(numel*sizeof(int))/1024/1024/(elapsed_time)*1000;

    cudaMemcpy(harr,darr,sizeof(int)*1024,cudaMemcpyDeviceToHost);
    printf("sum is %d\n",harr[0]);
    printf("cost time is %fms\n",elapsed_time);
    printf("bandWidth is %fGB/s\n",bandwidth);

    destory(harr,darr);
    return 1;
}
