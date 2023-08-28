#include <iostream>
#include <sstream>

// 我稍微看了一点STL的源码，而且从 << 的实现来说，这个一半要做成类似虚函数的功能都是 operator << 封装一层虚函数，但是这里并不是，STL里面的<<的实现并不是虚函数，也没有调用虚函数看起来
// 直观感受上好像是通过缓冲队列的方式实现了类多态的效果
int main()
{
    std::stringstream ss;
    std::ostream& os_ref = std::cout; //std::cout;
    int val = 3;
    os_ref << "hello os_ref\n";
    os_ref << val;
    return 0;
}
