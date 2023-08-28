

namespace N
{
    class C {};
    int operator+(int i , N::C c)
    {
        return i+1;
    }
} // namespace N



#include <numeric>
#include <vector>

int main()
{
    N::C c[10];
    std::accumulate(c,c+10,0);
    return 0;
}
