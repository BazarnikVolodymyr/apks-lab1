#include "add.h"

#include <gtest/gtest.h>

TEST(BasicAddition, AddsTwoIntegers) {
    EXPECT_EQ(add(2, 3), 5);
}
