
```go
filepath.Join(runtime.GOROOT(), "bin/go")
//func Join(elem ...string) string

//package os
// const (
// 	PathSeparator     = '/' // OS-specific path separator
// 	PathListSeparator = ':' // OS-specific path list separator
// )
```

```go
// expandPath returns the symlink-expanded form of path.
func expandPath(p string) string {
	x, err := filepath.EvalSymlinks(p)
	if err == nil {
		return x
	}
	return p
}
//func EvalSymlinks(path string) (string, error) 
```


