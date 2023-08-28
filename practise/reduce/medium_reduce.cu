#include <cuda_runtime.h>
#include <stdio.h>


const int kBlockSize = 256;
const int KGridSize = 1;

#define CHECK(res) { if(res != cudaSuccess){printf("Error ：%s:%d , ", __FILE__,__LINE__);   \
printf("code : %d , reason : %s \n", res,cudaGetErrorString(res));exit(-1);}}


__device__ int warp_reduce(int x)
{
    #pragma unroll
    for(int i = 16; i>0; i>>=1)
    {
        x+=__shfl_down_sync(0xffffffff,x,i);
    }
    return x;
}


__global__ void ker_reduce(int* src, int len)
{
    __shared__ int shm[256];
    __shared__ int warp_shm[8];

    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    int warp_id = tid/32;
    int lane_id = tid%32;
    for(int i = tid; i < len; i+=2*(blockDim.x*gridDim.x))
    {
        shm[tid] += src[i] + src[i+blockDim.x*gridDim.x];
    }

    __syncthreads();

    int val = shm[tid];
    val = warp_reduce(val);
    if(lane_id == 0)
    {
        warp_shm[warp_id] = val;
    }

    __syncthreads();

    if(tid<8)
    {
        int val = warp_shm[tid];
        val += __shfl_down_sync(0xff,val,4);
        val += __shfl_down_sync(0xf,val,2);
        val += __shfl_down_sync(0x3,val,1);
        if(tid==0)
        {
            src[0] = val;
        }
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
    CHECK(cudaMalloc((void**)(&darr),numel*sizeof(int)));

    for(int i = 0; i < numel; ++i)
    {
        *(harr+i) = 1;
    }

    CHECK(cudaMemcpy(darr,harr,sizeof(int)*numel,cudaMemcpyHostToDevice));

    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start,0);

    ker_reduce<<<KGridSize,kBlockSize,0,0>>>(darr,numel);

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
