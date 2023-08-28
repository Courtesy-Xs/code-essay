#include <iostream>
#include <string>
#include <chrono>
#include <sstream>

int main ()
{
    typedef std::chrono::high_resolution_clock clock;
    typedef std::chrono::duration<float, std::milli> mil;
    std::string l_czTempStr;
    std::string l_czTempStr1;
    std::string l_czTempStr2;
    std::string l_czTempStr3;
    std::string s1="Test data1";
    int repeat_times = 10000;

    auto t0 = clock::now();
    for (int i = 0; i < repeat_times; ++i)
    {
        l_czTempStr = l_czTempStr + s1 + "Test data2" + "Test data3";
    }
    auto t1 = clock::now();
    // std::cout << l_czTempStr << '\n';
    std::cout << mil(t1-t0).count() << "ms\n";

    l_czTempStr1 = "";
    t0 = clock::now();
    for (int i = 0; i < repeat_times; ++i)
    {
        l_czTempStr1 += "Test data1";
        l_czTempStr1 += "Test data2";
        l_czTempStr1 += "Test data3";
    }
    t1 = clock::now();
    // std::cout << l_czTempStr1 << '\n';
    std::cout << mil(t1-t0).count() << "ms\n";

    l_czTempStr2 = "";
    // l_czTempStr2.reserve(10000);
    t0 = clock::now();
    for (int i = 0; i < repeat_times; ++i)
    {
        l_czTempStr2.append("Test data1");
        l_czTempStr2.append("Test data2");
        l_czTempStr2.append("Test data3");
    }
    t1 = clock::now();
    // std::cout << l_czTempStr2 << '\n';
    std::cout << mil(t1-t0).count() << "ms\n";

    l_czTempStr3 = "";
    t0 = clock::now();

    std::ostringstream oss;
    for (int i = 0; i < repeat_times; ++i)
    {
        oss << "Test data1";
        oss << "Test data2";
        oss << "Test data3";
    }
    l_czTempStr3 = oss.str();
    t1 = clock::now();

    // std::cout << l_czTempStr3 << '\n';
    std::cout << mil(t1-t0).count() << "ms\n";
    bool is_equal = (l_czTempStr3 == l_czTempStr1);
    std::cout << is_equal << '\n';

}
