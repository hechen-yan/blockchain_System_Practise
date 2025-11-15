package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/rand"
	"strconv"
	"strings"
	"time"
)

func main() {
	var name = "Yan"
	var nonce = rand.Int63()
	start := time.Now()
	count := 0

	joinstring := name + strconv.FormatInt(nonce, 10)
	hashstring := sha256.Sum256([]byte(joinstring)) //返回是byte[32]
	hexstr := hex.EncodeToString(hashstring[:])

	for !strings.HasPrefix(hexstr, "00000") {
		nonce++
		count++
		joinstring = name + strconv.FormatInt(nonce, 10)
		hashstring = sha256.Sum256([]byte(joinstring))
		hexstr = hex.EncodeToString(hashstring[:])

	}
	elasped := time.Since(start)
	fmt.Println("耗时为：", elasped, "哈希值为：", hexstr, "哈希的内容为：", joinstring, "执行运算次数为：", count)
}
