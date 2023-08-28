#include<iostream>


namespace A
{
    class X {};
    void funcA(X x)
    {
        std::cout<<"hello this is A\n";
    }
}

namespace B
{
    void func(A::X x)
    {
        funcA(x);
    }
}

int main()
{
    for(int i = 0; i < 2; ++i)
        std::cout<<"hello\n";
    return 0;
}
