```go
// printCmdOut prints the output of running the given command.
// It ignores failures; 'go bug' is best effort.
func printCmdOut(w io.Writer, prefix, path string, args ...string) {
	cmd := exec.Command(path, args...)
	out, err := cmd.Output()
	if err != nil {
		if cfg.BuildV {
			fmt.Printf("%s %s: %v\n", path, strings.Join(args, " "), err)
		}
		return
	}
	fmt.Fprintf(w, "%s%s\n", prefix, bytes.TrimSpace(out))
}
//func Command(name string, arg ...string) *Cmd
//定义命令

//func (c *Cmd) Output() ([]byte, error) 
//执行命令并获得标准输出
```

```go
cmd := exec.Command("gcc", "-o", outfile, srcfile)
if _, err = cmd.CombinedOutput(); err != nil {
	return
}
//func (c *Cmd) CombinedOutput() ([]byte, error)
//执行命令并获得所有输出
```