#include <cassert>
#include <exception>
#include <iostream>
#include <cstdint>

#include <boost/safe_numerics/safe_integer.hpp>

int main()
{
	std::cout << "Using safe numerics" << std::endl;
    try{
        using namespace boost::safe_numerics;
        safe<int> x = INT_MAX - 5;
        ++x;
    }
    catch(const std::exception & e){
        std::cout << e.what() << std::endl;
        std::cout << "error detected!" << std::endl;
    }

    return 0;
}