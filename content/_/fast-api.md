# 微前端初体验——qiankun

## 🧐 什么是微前端

>  Techniques, strategies and recipes for building a **modern web app** with **multiple teams** that can **ship features independently**. -- [Micro Frontends](https://micro-frontends.org/)
>
> 微前端是一种多个团队通过独立发布功能的方式来共同构建现代化 web 应用的技术手段及方法策略。

### 核心思想

* 技术栈无关

​		 主框架不限制接入应用的技术栈，部署完成后主框架自动完成同步更新。即不论你使用的是React、Vue或是其他任何框架都可以部署到主应用上。

* 独立开发、独立部署

​		 微应用仓库独立，前后端可独立开发，部署完成后主框架自动完成同步更新。主框架只负责将子应用的功能进行组合展示，每个子应用都是一个独立的的应用，而对于主应用来说每个子应用都是一个组件。

* 增量升级

​		 在面对各种复杂场景时，我们通常很难对一个已经存在的系统做全量的技术栈升级或重构，而微前端是一种非常好的实施渐进式重构的手段和策略。因为每个子应用都是一个独立的应用，代码耦合度更小，在需要更新迭代时更清晰。

* 独立运行时

​		 每个微应用之间状态隔离，运行时状态不共享。每个子应用也可以脱离主框架独立运行。

### 实现方案

#### 1. [iframe](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/iframe)

​	嵌套网页，通过window.postMessage通信。



#### 2. [single-spa](https://single-spa.js.org/)

* 官网介绍：一个**前端微服务**的javascript框架
* 阿里团队的微前端框架[qiankun](https://qiankun.umijs.org/zh)也是基于**single-spa**实现的



#### 3. [qiankun](https://qiankun.umijs.org/zh)

> 官方文档：https://qiankun.umijs.org/zh/guide
>
> 官方文档为中文，这里不做过多介绍，下面将使用**qiankun**完成一个简单的demo



---

## 🚀 快速上手

### 环境

> Node: v16.15.1
>
> Npm: 8.17.0

### 选定基座项目

* qiankun对基座项目没有限制，官方也有三大流行框架搭建微前端项目的教程，该文章以**Vue**为基座搭建项目。
  * [React微应用](https://qiankun.umijs.org/zh/guide/tutorial#react-%E5%BE%AE%E5%BA%94%E7%94%A8)
  * [Vue微应用](https://qiankun.umijs.org/zh/guide/tutorial#vue-%E5%BE%AE%E5%BA%94%E7%94%A8)
  * [Angular微应用](https://qiankun.umijs.org/zh/guide/tutorial#angular-%E5%BE%AE%E5%BA%94%E7%94%A8)

---

1. 通过Npm初始化一个Vue项目

**注意:**  目前qiankun暂不支持接入基于Vite的子应用, 但是对于主应用没有限制,所以此处创建一个Vite项目.

```powershell
npm init vue
```

输入命令后跟着[官方文档](https://vuejs.org/guide/quick-start.html#with-build-tools)或根据自己的需求创建一个项目即可.

---

2. 基座项目中安装乾坤

```powershell
npm i qiankun 
```

* 在`main.ts`中配置乾坤

```typescript
//  main.js
import { registerMicroApps, start } from "qiankun";

registerMicroApps(
  [
    // 每个对象表示注册一个子应用
    {
      name: "vue-project",
      entry: "//localhost:20000", // 应用入口，上线后为应用部署的地址
      container: "#container", // 子应用需要挂载到哪个元素上
      activeRule: "/vue", // 激活子应用的路由，表示跳转到/vue路由下则激活该子应用
    },
    {
      name: "react-project",
      entry: "//localhost:30000",
      container: "#container",
      activeRule: "/react",
    },
  ],
  // 乾坤子应用生命周期，这里列出三个，更多参考官方文档
  {
    beforeLoad: () => {
      console.log("加载前");
    },
    beforeUnmount: () => {
      console.log("卸载前");
    },
    beforeMount: () => {
      console.log("挂载前");
    },
  }
);

start();
```

* 配置路由

```vue
// App.vue
<template>
    <div class="wrapper">
      <HelloWorld msg="You did it!" />

      <nav>
        <RouterLink to="/react">React Application</RouterLink>
        <RouterLink to="/vue">Vue Application</RouterLink>
      </nav>
      <div id="container"></div>
    </div>
</template>
```



---

### 创建子应用

> 注意: 官方目前不支持接入Vite创建的项目，所以子应用需要使用vue-cli创建Webpack项目

* 跟着[Vue Cli官网](https://cli.vuejs.org/zh/guide/creating-a-project.html#vue-create)的教程即可完成子应用的创建

1. 改写Webpack打包配置并配置跨域，因为基座访问子应用会跨域

```js
module.exports = {
  // publicPath: "//localhost:20000",
  devServer: {
    port: 20000,
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
  },
  configureWebpack: {
    output: {
      libraryTarget: "umd",
      library: "vue-project",
    },
  },
};
```

2. 改写路由

```typescript
// router/index.ts
import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
import HomeView from "../views/HomeView.vue";

const routes: Array<RouteRecordRaw> = [
  {
    path: "/",
    name: "home",
    component: HomeView,
  },
  {
    path: "/about",
    name: "about",.
    component: () =>
      import(/* webpackChunkName: "about" */ "../views/AboutView.vue"),
  },
];

export default routes;
```

为了在挂载和卸载子应用时路由也一起销毁和创建，路由的`index`中改为仅导出routes



3. 将子应用渲染改写为一个`render`函数

```typescript
let history;
let router;
let app;
function render(props?: any) {
  history = createWebHistory("vue");
  router = createRouter({
    history,
    routes,
  });
  app = createApp(App);
  const container = props?.container;
  app.use(router).mount(container ? container.querySelector("#app") : "#app");
}
```

4. 导出子应用相应的生命周期钩子，详细配置参考[官方](https://qiankun.umijs.org/zh/guide/getting-started#1-%E5%AF%BC%E5%87%BA%E7%9B%B8%E5%BA%94%E7%9A%84%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E9%92%A9%E5%AD%90)

```typescript
export async function bootstrap() {
  console.log("vue3 app bootstrap");
}

export async function mount(props: any) {
  console.log("vue3 app mount", props);
  render(props);
}

export async function unmount() {
  // 在卸载子应用时候销毁app和router
  console.log("vue3 app unmount");
  history = null;
  router = null;
  app = null;
}

```

5. 启动子应用后再在基座中切换到对应的路由，效果如下

![image-20220828161859329](http://182.61.149.102/micro-fronted.png)

* 该文中仅接入了一个vue项目，多个项目也是同样的接入流程。
