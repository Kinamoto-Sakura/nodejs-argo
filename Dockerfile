# 1. 使用稳定的 Node.js LTS 配合 Debian Slim 基础镜像
FROM node:22-slim

# 2. 设定环境变量，防止 tzdata 等包安装时弹出交互式配置卡死 Docker 构建
ENV DEBIAN_FRONTEND=noninteractive
# 设定默认时区（可根据你的实际主要用户群体调整）
ENV TZ=Asia/Shanghai

# 3. 使用标准的业务工作目录
WORKDIR /tmp

# 4. 安装底层系统依赖防坑包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        tzdata \
        procps \
        iproute2 \
        coreutils \
        bash \
        && \
    # 强制更新系统根证书链
    update-ca-certificates && \
    # 清理 apt 缓存，保持镜像极度轻量
    rm -rf /var/lib/apt/lists/*

# 5. 复制依赖并执行精简安装
COPY package.json ./
RUN npm install --omit=dev && \
    npm cache clean --force

# 6. 复制核心业务代码
COPY index.js index*.html ./

# 7. 赋予主脚本执行权限
RUN chmod +x index.js

# 8. 暴露 Web 服务端口
EXPOSE 3000/tcp

# 9. 启动容器进程
CMD ["node", "index.js"]
