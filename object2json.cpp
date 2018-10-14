//
//  main.cpp
//  cppreflect
//
//  Created by Phillip Voyle on 12/06/15.
//

#include <iostream>
#include <string>
#include <vector>

class AClass
{
public:
    int aValue;
    char anotherValue;
    char thirdValue[32];
    int fourthValue[4];
};

template<typename T>
class PrimitiveTypeDescriptor
{
};

template<typename TClass>
class ClassDescriptor
{
public:
    typedef PrimitiveTypeDescriptor<TClass> descriptor_t;
};

template<typename T>
class ArrayTypeDescriptor
{
};

template<typename T, int N>
class ArrayTypeDescriptor<T[N]>
{
public:
    size_t get_size(const T(&t)[N]) const
    {
        return N;
    }
};

template<typename T, int N>
class ClassDescriptor<T[N]>
{
public:
    typedef ArrayTypeDescriptor<T[N]> descriptor_t;
};

template<int N>
class ClassDescriptor<char[N]>
{
public:
    typedef PrimitiveTypeDescriptor<char[N]> descriptor_t;
};

template<>
class ClassDescriptor<AClass>
{
public:
    typedef ClassDescriptor<AClass> descriptor_t;

template<typename TCallback>
        void for_each_property(TCallback& callback) const
        {
            callback("aValue", &AClass::aValue);
            callback("anotherValue", &AClass::anotherValue);
            callback("thirdValue", &AClass::thirdValue);
            callback("fourthValue", &AClass::fourthValue);
        }
};

template<typename T>
typename ClassDescriptor<T>::descriptor_t GetTypeDescriptor(const T& t)
{
    return typename ClassDescriptor<T>::descriptor_t {};
}

template<typename T>
void WriteJSON(std::string &out, const T& t);

template <typename TClass>
class WriteJSONFunctor
{
    std::string& m_out;
    const TClass& m_t;
    bool m_first;
public:
    WriteJSONFunctor(std::string& out, const TClass& t):m_out(out), m_t(t)
    {
        m_first = true;
    }

template<typename TPropertyType>
        void operator()(const char* szProperty, TPropertyType TClass::*pPropertyOffset)
        {
            if(m_first)
            {
                m_first = false;
            }
            else
            {
                m_out += ",";
            }
            m_out += "\"" + std::string(szProperty) + "\": ";
            WriteJSON(m_out, m_t.*pPropertyOffset);
        }
};

template<typename T>
void DispatchWriteJSON(const PrimitiveTypeDescriptor<T>& descriptor, std::string &out, const T& t)
{
    out += std::to_string(t);
}

template<std::size_t N>
void DispatchWriteJSON(const PrimitiveTypeDescriptor<char[N]>& descriptor, std::string &out, const char (&t)[N])
{
    out += "\"" + std::string(t) + "\"";
}

template<typename T>
void DispatchWriteJSON(const ArrayTypeDescriptor<T>& descriptor, std::string &out, const T& t)
{
    out += "[";
    size_t size = descriptor.get_size(t);
    for(int n = 0; n < size; n++)
    {
        if(n != 0)
        {
            out += ",";
        }
        WriteJSON(out, t[n]);
    }
    out += "]";
}

template<typename T>
void DispatchWriteJSON(const ClassDescriptor<T>& descriptor, std::string &out, const T &t)
{
    WriteJSONFunctor<T> functor(out, t);
    out += "{";
    descriptor.for_each_property(functor);
    out += "}";
}

template<typename T>
void WriteJSON(std::string &out, const T& t)
{
    DispatchWriteJSON(GetTypeDescriptor(t), out, t);
}

int main(int argc, const char * argv[])
{
    const AClass c1 = { 1, 2, "this is a test", { 1, 2, 3, 4} };
    const AClass *pc1 = &c1;
    std::string out;

    out = "";
    WriteJSON(out, c1);
    std::cout << out<< std::endl;

    out = "";
    WriteJSON(out, *pc1);
    std::cout << out<< std::endl;

    return 0;
}

