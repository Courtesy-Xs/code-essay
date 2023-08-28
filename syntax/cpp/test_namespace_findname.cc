

namespace N
{
    class C {};
    int operator+(int i , N::C c)
    {
        return i+1;
    }
} // namespace N

// Compiler can't find proper implementation of operator + for class C if code seg is set here
// int operator+(int i , N::C c)
// {
//     return i+1;
// }


#include <numeric>
#include <vector>

int main()
{
    N::C c[10];
    std::accumulate(c,c+10,0);
    return 0;
}
