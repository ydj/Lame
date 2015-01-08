# Lamemp3
Lamemp3-iOS 打包

####说明
-------
1.`fat-lame`下是合并后后的静态库文件，支持 `arm64、armv7、armv7s、i386、x86_64`

2.`thin-lame`下是每个指令生成的静态文件


-------
#####打包生成静态库


1.下载Lamemp3 源码地址:[http://sourceforge.net/projects/lame/files/lame/3.99/](http://sourceforge.net/projects/lame/files/lame/3.99/)

2.修改`lamemp3.sh`文件
  * SOURCE是下载lame源码包的目录，可以把sh脚本放到这个目录，source改为""
  * SCRATCH是下载lame源码包的目录，必须是绝对路径
  * 打开Terminals， 进入路径下 

`cd /Users/admin/Desktop/lame `

`chmod 777 lame-build.sh`

`sudo -s# `

 `输入系统密码`

 `./lame-build.sh`
`

执行完成后，`fat-lame`文件夹内容就是最后合并的文件。
