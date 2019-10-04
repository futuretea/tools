```go
// firstLine returns the first line of a given byte slice.
func firstLine(buf []byte) []byte {
	idx := bytes.IndexByte(buf, '\n')
	if idx > 0 {
		buf = buf[:idx]
	}
	return bytes.TrimSpace(buf)
}
//func IndexByte(b []byte, c byte) int
//返回byte在[]byte中的位置,若不存在则返回-1

//func TrimSpace(s []byte) []byte
//去除white space
```



```go
// print another line (the one containing version string) in case of musl libc
if idx := bytes.IndexByte(out, '\n'); bytes.Index(out, []byte("musl")) != -1 && idx > -1 {
	fmt.Fprintf(w, "%s\n", firstLine(out[idx+1:]))
}

//func IndexByte(b []byte, c byte) int 
//索引byte位置

//func Index(s, sep []byte) int 
//索引[]byte位置
```



```go
// Cheap integer to fixed-width decimal ASCII. Give a negative width to avoid zero-padding.
func itoa(buf *[]byte, i int, wid int) {
	// Assemble decimal in reverse order.
	var b [20]byte
	bp := len(b) - 1
	for i >= 10 || wid > 1 {
		wid--
		q := i / 10
		b[bp] = byte('0' + i - q*10)
		bp--
		i = q
	}
	// i < 10
	b[bp] = byte('0' + i)
	*buf = append(*buf, b[bp:]...)
}
```