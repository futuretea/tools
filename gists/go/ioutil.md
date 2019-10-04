

```go
data, err := ioutil.ReadFile(filename)
// func ReadFile(filename string) ([]byte, error)
// 读取文件data的类型为[]byte
```

```go
err := ioutil.WriteFile(filename, data, 0644)
//func WriteFile(filename string, data []byte, perm os.FileMode) error
```