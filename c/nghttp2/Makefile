# C WebWords Implementation with nghttp2

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -D_GNU_SOURCE $(shell pkg-config --cflags libnghttp2)
LDFLAGS = $(shell pkg-config --libs libnghttp2) -lssl -lcrypto
TARGET = webwords
SOURCE = webwords.c

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE) $(LDFLAGS)

clean:
	rm -f $(TARGET)

test: $(TARGET)
	@echo "Starting WebWords nghttp2 server for testing..."
	@./$(TARGET) &
	@sleep 2
	@echo "Testing positive case (should return 'true'):"
	@curl -s "http://localhost:31337/?keyword=potato&target=https://www.remarkbox.com" || echo "Test failed"
	@echo ""
	@echo "Testing negative case (should return 'false'):"
	@curl -s "http://localhost:31337/?keyword=lemon&target=https://www.remarkbox.com" || echo "Test failed"
	@echo ""
	@pkill -f webwords || true