#include <cuda_runtime.h>
#include <stdio.h>

const int kBlockSize = 256;
const int kNumWarp = kBlockSize/32;
const int KGridSize = 4;

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

__device__ int block_reduce(int* shm)
{
    int tid = threadIdx.x;
    int warp_id = tid/32;
    int lane_id = tid&0x1f;

    int val = shm[tid];
    int sum = 0;
    val=warp_reduce(val);

    __syncthreads();
    if(lane_id == 0)
    {
        shm[warp_id] = val;
    }
    if(warp_id==0)
    {
        sum = shm[warp_id];
        sum += __shfl_down_sync(0xf,sum,4);
        sum += __shfl_down_sync(0xf,sum,2);
        sum += __shfl_down_sync(0xf,sum,1);
    }

    return sum;
}

__device__ unsigned int count = 0;
__global__ void ker_reduce(int* src, int len, volatile int* result, unsigned int* k_count)
{
    __shared__ int shm[256];

    int tid = threadIdx.x;
    __shared__ unsigned is_last_block;

    shm[tid] = src[blockIdx.x*blockDim.x+tid];

    __syncthreads();

    result[blockIdx.x] = block_reduce(shm);

    __threadfence();

    if(threadIdx.x == 0)
    {
        is_last_block = atomicInc(&count,4);
    }

    __syncwarp();
    // __syncthreads();
    // 这个是用来sync is_last_block的，但是我这里最后只要第一个warp计算，所以没必要了，warp有隐式同步了
    // 考虑到indepentent thread schedule 的问题，还是加个sync_warp

    if(is_last_block == 3)
    {
        if(tid<8)
        {
            int val = result[tid];
            val+=__shfl_down_sync(0xf,val,2,2);
            val+=__shfl_down_sync(0x3,val,1,1);
            if(tid == 0)
            {
                src[0] = val;
            }
        }

    }
}

void initialize(int** harr, int** darr, int size)
{
    (*harr) = (int*)malloc(size*sizeof(int));
    CHECK(cudaMalloc((void**)(darr),size*sizeof(int)));

    for(int i = 0; i < size; ++i)
    {
        (*harr[i]) = 1;
    }
    CHECK(cudaMemcpy(darr,harr,sizeof(int)*size,cudaMemcpyHostToDevice));
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
    int *dres = nullptr;
    const int numel = 1024;
    unsigned int count = 0;

    harr = (int*)malloc(numel*sizeof(int));
    CHECK(cudaMalloc((void**)(&darr),numel*sizeof(int)));
    CHECK(cudaMalloc((void**)(&dres),4*sizeof(int)));
    CHECK(cudaMemset(dres,0,4*sizeof(int)));


    for(int i = 0; i < numel; ++i)
    {
        *(harr+i) = 1;
    }

    CHECK(cudaMemcpy(darr,harr,sizeof(int)*numel,cudaMemcpyHostToDevice));

    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start,0);

    ker_reduce<<<KGridSize,kBlockSize,0,0>>>(darr,numel,dres,&count);

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
