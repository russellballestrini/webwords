CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -DCPPHTTPLIB_OPENSSL_SUPPORT
LDFLAGS = -lssl -lcrypto -lpthread

TARGET = webwords
SRC = webwords.cpp

all: $(TARGET)

$(TARGET): $(SRC) httplib.h
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
