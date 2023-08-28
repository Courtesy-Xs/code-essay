#include <iostream>
#include <sstream>

int main()
{
    std::stringstream ss;
    std::ostream& os_ref = std::cout; //std::cout;
    int val = 3;
    os_ref << "hello os_ref\n";
    os_ref << val;
    return 0;
}
