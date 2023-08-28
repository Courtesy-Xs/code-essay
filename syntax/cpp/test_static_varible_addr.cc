

static int init_global_static_x = 3;   //data
static int init_global_static_k = 0;    //bss
static int uninit_global_static_y;    //bss

void func1()
{
    static int init_local_static_z = 1;   //data
    static int uninit_local_static_j;  //bss
}

class Point3d
{
public:
    // 符号表里没有这个文件
    static int point3d_x;
    const static int point3d_y = 3;
    static int point3d_z;
};

int Point3d::point3d_z = 3;

int main()
{
    Point3d point;
    return 0;
}
