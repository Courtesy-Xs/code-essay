#include <iostream>
#include <string>
#include <chrono>
#include <random>
#include <vector>

//其实虚函数还有一个分支预测的问题，这个测试并没有体现出来

enum class Type {
    A,B,C,D,E
};

class IVisitor {
public:
    virtual int visit(Type& type)
    {
        switch (type)
        {
            case Type::A:
                return visit1();
            case Type::B:
                return visit2();
            case Type::C:
                return visit3();
            case Type::D:
                return visit4();
            case Type::E:
                return visit5();
            default:
                return 0;
        }
    }
private:
    virtual int visit1() = 0;
    virtual int visit2() = 0;
    virtual int visit3() = 0;
    virtual int visit4() = 0;
    virtual int visit5() = 0;
};

class Visitor1 : public IVisitor {
public:
    virtual int visit(Type& type) override
    {
        return IVisitor::visit(type);
    }
private:
    virtual int visit1() override
    {
        return 1;
    }
    virtual int visit2() override
    {
        return 2;
    }
    virtual int visit3() override
    {
        return 3;
    }
    virtual int visit4() override
    {
        return 4;
    }
    virtual int visit5() override
    {
        return 5;
    }
};

class Visitor2 {
public:
    int visit(Type& type)
    {
        switch (type)
        {
            case Type::A:
                return visit1();
            case Type::B:
                return visit2();
            case Type::C:
                return visit3();
            case Type::D:
                return visit4();
            case Type::E:
                return visit5();
            default:
                return 0;
        }
    }
private:
    int visit1()
    {
        return 1;
    }
    int visit2()
    {
        return 2;
    }
    int visit3()
    {
        return 3;
    }
    int visit4()
    {
        return 4;
    }
    int visit5()
    {
        return 5;
    }
};


int main()
{
    Visitor1 visitor1;
    Visitor2 visitor2;
    Type type1  = Type::E;
    std::vector<Type> v_types;
    std::vector<Type> map_types;
    map_types.push_back(Type::A);
    map_types.push_back(Type::B);
    map_types.push_back(Type::C);
    map_types.push_back(Type::D);
    map_types.push_back(Type::E);
    long long sum = 0;
    for(int i = 0;i<232776706;++i)
    {
        v_types.push_back(map_types[rand() % map_types.size()]);
    }

    auto start = std::chrono::high_resolution_clock::now();
    for(int i = 0; i < v_types.size(); ++i)
    {
        sum+=visitor1.visit(v_types[i]);
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    std::cout <<  "vistor1 cost "
    << duration.count()
    << "ms" << std::endl;

    start = std::chrono::high_resolution_clock::now();
    for(int i = 0; i < v_types.size(); ++i)
    {
        sum+=visitor2.visit(v_types[i]);
    }
    end   = std::chrono::high_resolution_clock::now();
    duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    std::cout <<  "vistor2 cost "
    << duration.count()
    << "ms" << std::endl;
    std::cout << sum << std::endl;

    return 0;
}
