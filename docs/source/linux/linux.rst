.. _topics-linux:

==============================
Linux基础
==============================

简介
==============================


常用命令
==============================

**ln**
---------------

``ln -s /full/path/of/original/file /full/path/of/symbolic/link/file``

.. _topics-linux-EOF:

**EOF**
---------------

``cat > test.sh <<EOF
$arr #转义
...
EOF``

``cat > test.sh <<EOF
\$arr #不转义
...
EOF``

``cat > test.sh <<\EOF
$arr #不转义
...
EOF``

``cat > test.sh <<"EOF"
$arr #不转义
...
EOF``

``cat > test.sh <<'EOF'
$arr #不转义
...
EOF``

``cat >> test.sh <<EOF #追加
$arr
...
EOF``

``python >> test.sh <<EOF #写入文件并执行
$arr
...
EOF``



2. 变量转义

``test.sh <<EOF
...
EOF``

``cat > test.sh <<EOF
...
EOF``

3. 变量转义

``cat > test.sh <<\EOF
...
EOF``

``python > test.sh <<\EOF
...
EOF``

**awk**
---------------

**解压**
---------------
.tgz 或者 .tar.gz 后缀的文件通常用: ``tar -zvcf filename.tgz`` 来解压缩
bunzip

zip

后缀名: .zip

压缩: zip -r newfilename.zip filename

解压: unzip filename.zip

指定解压目录: -d dir






安装Centos
==============================


Windows-WSL2-Ubuntu
==============================


初始化服务器
==============================

config_linux_server
-----------------------------
#!/bin/bash
