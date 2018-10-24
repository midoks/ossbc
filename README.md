# 	ossbc
奥,手撕包菜

## 网站说明
这是 www.shousibaocai.com 的网站源代码。是xiaoxia的项目，自己拿来修改并优化学习。

### 安装依赖
- pip install -r requirements.txt

### 创建数据

- 本地授权root密码为空
```
grant all privileges on *.* to 'ssbc'@'127.0.0.1' identified by 'ssbc';
```

```
python manage.py makemigrations
python manage.py migrate
```

### 开启爬虫

```
python simdht_worker.py
python index_worker.py
```


### 自动安装

```
curl -fsSL  https://raw.githubusercontent.com/midoks/ossbc/master/scripts/ssbc-setup.sh | sh
```

```
curl -fsSL  https://raw.githubusercontent.com/midoks/ossbc/master/scripts/ssbc-setup-msm.sh | sh
```