```go
    b, err := json.MarshalIndent(m, "", "\t")
    if err != nil {
        base.Fatalf("%v", err) // %v 用于输出接口
    }
}

//func MarshalIndent(v interface{}, prefix, indent string) ([]byte, error) 
//序列化并格式化
```