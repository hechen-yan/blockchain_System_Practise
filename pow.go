package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"
	"strconv"
	"strings"
	"time"
)

func main() {

	var name = "Yan"
	var nonce int64
	n, err := rand.Int(rand.Reader, big.NewInt(1<<60))
	if err != nil {
		panic(err)
	}
	nonce = n.Int64()

	start := time.Now()
	count := int64(0)

	privatekey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		panic(err)
	}
	PublicKey := &privatekey.PublicKey

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
	signature, err := rsa.SignPKCS1v15(rand.Reader, privatekey, crypto.SHA256, hashstring[:])
	fmt.Println("签名为：", signature)
	if err != nil {
		panic(err)
	}
	err1 := rsa.VerifyPKCS1v15(PublicKey, crypto.SHA256, hashstring[:], signature)
	if err1 != nil {
		fmt.Println("验证失败")
	} else {
		fmt.Println("验证成功")
	}

	fmt.Println("耗时为：", elasped, "哈希值为：", hexstr, "哈希的内容为：", joinstring, "执行运算次数为：", count)

}
