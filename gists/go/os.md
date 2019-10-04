
```go
info, err := os.Stat(name)
// func Stat(name string) (FileInfo, error)
// 返回文件信息FileInfo接口
```


```go
os.IsNotExist(err)
// func IsNotExist(err error) bool
// 判断出错原因是否为文件不存在
```

```go
latest := map[string]string{} // path → version
// 在map后面写上含义
```


```go

os.Stdout.Write(append(b, '\n')) //os.Stdout标准输出也是文件
// func (f *File) Write(b []byte) (n int, err error) 
// 将字节写入文件,返回写入大小和错误

// func append(slice []Type, elems ...Type) []Type
// 切片添加元素
```

```go
tempdir := os.TempDir()
if tempdir == "" {
	return
}

//func TempDir() string
//跨平台返回临时文件夹路径
```

```go
defer os.Remove(srcfile)
//func Remove(name string) error
//最后删除文件
```


```go
path := os.Getenv("path")
//func Getenv(key string) string
//获取环境变量
```

```go
os.Exit(2)
//func Exit(code int)
//非0可以直接使用syscall.Exit(code)
```
