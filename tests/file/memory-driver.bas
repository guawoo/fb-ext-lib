#include once "ext/testly.bi"
#include once "ext/file/file.bi"

namespace ext.tests.memorydriver

private sub fill_data( byval x as ubyte ptr )
    for n as ubyte = 1 to 128
        x[n-1] = n
    next
end sub

private function verify( byval lhs as ubyte ptr, byval rhs as ubyte ptr ) as bool

    for n as ubyte = 0 to 127
        if lhs[n] <> rhs[n] then
            return false
        end if
    next

    return true
end function

private sub test_memory_driver

    var dat = new ubyte[128]
    var dat_len = 128u
    fill_data(dat)

    var x = new ext.File(newMemoryFileDriver(dat,dat_len))

    TESTLY_ASSERT_TRUE( x->open() )
    TESTLY_ASSERT_TRUE( x->lof() = dat_len )
    TESTLY_ASSERT_TRUE( x->loc() = 0 )

    var dat2 = new ubyte[dat_len]

    x->get(, *dat2,dat_len)

    TESTLY_ASSERT_TRUE( x->loc() = dat_len )

    var dat2_ret = x->getBytesRW

    TESTLY_ASSERT_TRUE( dat2_ret = dat_len )

    TESTLY_ASSERT_TRUE( verify(dat,dat2) )

    delete[] dat
    delete[] dat2
    delete x

end sub

private sub test_memory_driver_put

    var dat = new ubyte[128]
    var dat2 = new ubyte[128]

    var x = new ext.File(newMemoryFileDriver(dat,128))

    for n as ubyte = 0 to 127
        x->put(,n)
    next

    for n as integer = 0 to 127
        dat2[n] = n
    next

    TESTLY_ASSERT_TRUE( verify(dat,dat2) )

    delete[] dat
    delete[] dat2
    delete x
end sub

private sub test_memory_driver_string

    var test_string = "The fast fox runs through the forest."

    var dat = new ubyte[64]
    var x = new ext.file(newMemoryFileDriver(dat,64))
    x->print(test_string)
    x->seek = 0
    TESTLY_ASSERT_TRUE( x->loc = 0 )
    var ts = x->readLine()
    TESTLY_ASSERT_TRUE( test_string = ts )
    delete x
    delete[] dat

end sub

'' :::::
private sub register_tests constructor
    ext.testly.addSuite("File::MemoryDriver")
    ext.testly.addTest("General Usage",@test_memory_driver)
    ext.testly.addTest("String functions",@test_memory_driver_string)
    ext.testly.addTest("put",@test_memory_driver_put)
end sub

end namespace
