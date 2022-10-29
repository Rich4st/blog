---
icon: edit
date: 2022-06-25
category:
  - Guide
  - VuePress
---

# 使用Vuepress2社区主题vuepress-theme-hope部署个人博客

## 🚀 Getting Started

### 依赖环境

---

> ❗️**注意：**  
>
> * 需要`Node.js`版本大于14 [Node.js下载](https://nodejs.org/en/ )
> * 提示
>   - 使用 [pnpm在新窗口打开](https://pnpm.io/zh/) 时，你可能需要安装 `vue` 和 `@vuepress/client` 作为 peer-dependencies ，即 `pnpm add -D vue @vuepress/client@next` 。
>   - 使用 [yarn 2在新窗口打开](https://yarnpkg.com/) 时，你需要在 [`.yarnrc.yml`在新窗口打开](https://yarnpkg.com/configuration/yarnrc#nodeLinker) 文件中设置 `nodeLinker: 'node-modules'` 。



### 手动安装

---

* 步骤1： 创建并进入一个新目录

```po
mkdir vuepress-blog
cd vuepress-blog 
```

* 步骤2： 使用`vuepress-theme-hope`主题cli安装

```bash
npm init vuepress-theme-hope@next [dir]
```

> ❗️**注意：**
>
>  `[dir]` 是一个参数，表示要在哪个文件夹初始化你的项目，建议使用`docs`或`src`

* 步骤3： 根据提示配置你的项目之后等待项目初始化完成即可

![image-20220625210242856](http://182.61.149.102/blog/vuepress2.png)

### 项目目录结构

![image-20220625215823405](http://182.61.149.102/blog/vuepress1.png)

#### GitHub workflow可以在你将项目推送到远程仓库后自动部署到github pages

> 具体参考vuepress2官方文档：[VuePress2部署到Github Pages](https://v2.vuepress.vuejs.org/zh/guide/deployment.html#github-pages)

* 在`.github`目录下新建`docs.yml`文件并写入如下配置

```yaml
# docs.yml 
name: docs

on:
  # 每当 push 到 master 分支时触发部署
  push:
  # 如果仓库主分支是main则改为main
    branches: [master]
  # 手动触发部署
  workflow_dispatch:

jobs:
  docs:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
        with:
          # “最近更新时间” 等 git 日志相关信息，需要拉取全部提交记录
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v1
        with:
          # 选择要使用的 node 版本
          node-version: '16'

      # 缓存 node_modules
      - name: Cache dependencies
        uses: actions/cache@v2
        id: yarn-cache
        with:
          path: |
            **/node_modules
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-

      # 如果缓存没有命中，安装依赖
      - name: Install dependencies
        run: yarn

      # 运行构建脚本
      - name: Build VuePress site
        run: yarn docs:build

      # 查看 workflow 的文档来获取更多信息
      # @see https://github.com/crazy-max/ghaction-github-pages
      - name: Deploy to GitHub Pages
        uses: crazy-max/ghaction-github-pages@v2
        with:
          # 部署到 gh-pages 分支
          target_branch: gh-pages
          # 部署目录为 VuePress 的默认输出目录
          build_dir: src/.vuepress/dist
        env:
          # @see https://docs.github.com/cn/actions/reference/authentication-in-a-workflow#about-the-github_token-secret 
          GITHUB_TOKEN: ${{ secrets.ACCESS_TOKEN }}

```

* **注意：**

  * `branches: [master]` 修改为你的仓库主分支，如果为**main**则修改为**main**
  * `node-version: '16'` 修改为你的**Node**版本号，通过`node -v`在终端查看你的版本号
  * `build_dir: src/.vuepress/dist` 修改为你的项目打包路径，开头是你在创建项目时的`dir`参数

* `${{ secrets.ACCESS_TOKEN }}`

  * [Github生成personal access token](https://docs.github.com/cn/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
  * 生成token之后在你的项目Github仓库中Settings -> Secrets -> Actions -> New repository secret
  * 其中`Name`要`${{ secrets.ACCESS_TOKEN }}`中的一致，`Value`为上面生成的token

  ![image-20220625221537899](http://182.61.149.102/blog/vuepress3.png)

## 结语

剩下就看你的个人想象力了，Build you own Blog!
