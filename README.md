# 	ossbc
奥,手撕包菜

## 网站说明
这是 www.shousibaocai.com 的网站源代码。是xiaoxia的项目，自己拿来修改并优化学习。

### 安装依赖
- pip install -r requirements.txt

### 创建数据

```
python manage.py makemigrations
python manage.py migrate
```

- 本地授权root密码为空
```
grant all privileges on *.* to 'root'@'127.0.0.1' identified by '';
```

### 开启爬虫

```
python simdht_worker.py
python index_worker.py
```