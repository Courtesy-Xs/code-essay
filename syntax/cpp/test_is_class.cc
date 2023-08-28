#include <iostream>

// https://stackoverflow.com/questions/2461630/why-this-works-templates-sfinae-c
template<typename T>
class IsClassT {
private:
    typedef char One;
    typedef struct { char a[2]; } Two;
    template<typename C> static One test(int C::*);
    template<typename C> static Two test(...);
public:
    enum {Yes = sizeof(IsClassT<T>::test<T>(0) == 1)};
    enum {No = !Yes};
};

class MyClass
{

};

int main()
{
    if(IsClassT<MyClass>::Yes)
    {
        std::cout << "MyClass is a class\n";
    }
    return 0;
}
