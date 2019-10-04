```go
re := regexp.MustCompile(`libc\.so[^ ]* => ([^ ]+)`)
m := re.FindStringSubmatch(string(out))
if m == nil {
    return
}
//func MustCompile(str string) *Regexp
//编译正则表达式,如果出错则panic,其实是包装了Compile
//想要统一处理错误的话还是用Compile,然后自己处理错误
//func Compile(expr string) (*Regexp, error)


//func (re *Regexp) FindStringSubmatch(s string) []string 
//获取匹配正则的部分切片,类似grep -o,如果没有则为nil
```