# Vue3开发移动端（vw/vh适配方案）

## ✨ 简介

以往开发移动端应用的方法大致有以下几种：

* 百分比方案（**不推荐**）
* 基于媒体查询的方案（**不推荐**）
* REM方案，根据HTML的font-size进行适配，手机屏幕大，元素就大。（推荐）

这篇博客的内容就是讲另外一种移动端适配方案——vw/vh适配。

* vw：视口的宽度，1vw等于视口宽度的1%，例如手机屏幕宽度的为370px，1vw就等于37px。
* vh： 视口的高度，1vh等于视口高度的1%。



---

## 🛠 创建项目

* 使用`npm`创建一个Vue3项目

```powershell
npm init vue@latest
```

根据提示创建一个项目

![image-20220703204140545](http://182.61.149.102/blog/PostcssViewPort/img0.png)

* 安装依赖

```powershell
npm i postcss-px-to-viewport -D
```

> ⚠️ **注意：**
>
> 因为`vite`中已经内置了**PostCss**，所以不需要额外再创建`postcss.config.js`配置文件，在`vite.config.ts`直接配置即可

* 配置`postcss-px-to-viewport`

```typescript
import { fileURLToPath, URL } from 'url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import pxToViewPort from 'postcss-px-to-viewport'; // postcss插件

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue(), vueJsx()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  css: {
    postcss: {
      plugins: [
        pxToViewPort({          
  		 /* 一般仅需配置前两个属性即可  */
          unitToConvert: 'px', // 要转化的单位
          viewportWidth: 750, // UI设计稿的宽度
          unitPrecision: 6, // 转换后的精度，即小数点位数
          propList: ['*'], // 指定转换的css属性的单位，*代表全部css属性的单位都进行转换
          viewportUnit: 'vw', // 指定需要转换成的视窗单位，默认vw
          fontViewportUnit: 'vw', // 指定字体需要转换成的视窗单位，默认vw
          selectorBlackList: ['ignore-'], // 指定不转换为视窗单位的类名，
          minPixelValue: 1, // 默认值1，小于或等于1px则不进行转换
          mediaQuery: true, // 是否在媒体查询的css代码中也进行转换，默认false
          replace: true, // 是否转换后直接更换属性值
          landscape: false // 是否处理横屏情况
        })
      ]
    }
  }
})
```

**注意：**因为插件还没有声明文件，所以配置中会报如下错误

`找不到模块“postcss-px-to-viewport”或其相应的类型声明。ts(2307)`

> 修复该错误只需要在根目录下创建一个`postcss-px-to-viewport.d.ts`文件，然后写入以下的类型声明

```typescript
// postcss-px-to-viewport.d.ts
// 来自：https://blog.csdn.net/qq1195566313/article/details/125490078?spm=1001.2014.3001.5501
declare module 'postcss-px-to-viewport' {

type Options = {
  unitToConvert: 'px' | 'rem' | 'cm' | 'em',
  viewportWidth: number,
  viewportHeight: number, // not now used; TODO: need for different units and math for different properties
  unitPrecision: number,
  viewportUnit: string,
  fontViewportUnit: string,  // vmin is more suitable.
  selectorBlackList: string[],
  propList: string[],
  minPixelValue: number,
  mediaQuery: boolean,
  replace: boolean,
  landscape: boolean,
  landscapeUnit: string,
  landscapeWidth: number
}

  export default (options:Partial<Options>) => any
}
```

在`tsconfig.config.json`中引入该声明文件

```json
// tsconfig.config.json
{
  ...
  "include": ["vite.config.*", "vitest.config.*", "cypress.config.*", "postcss-px-to-viewport.*"],
  ...
}
```

* 安装`sass`

```powershell
npm i sass -D
```

## 📝 Demo

* 主要代码

```vue
// App.vue
<template>
  <div class="wraps">

    <header class="header">
      <div>left</div>
      <div>middle</div>
      <div>right</div>
    </header>

    <main class="main">
      <div class="main-item" v-for="item in 100">
        <div class="main-avatar"></div>
        <div class="main-desc">
          <div>Rich4$t {{ item }}</div>
          <div>foooooooooooooo</div>
        </div>
      </div>
    </main>

    <footer class="footer">
      <div v-for="item in footer">
        <div>{{ item.icon }}</div>
        <div>{{ item.text }}</div>
      </div>
    </footer>

  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue';

type Footer<T> = {
  icon: T,
  text: T,
}

const footer = reactive<Footer<string>[]>([
  {
    icon: 'Home',
    text: '首页',
  },
  {
    icon: 'Search',
    text: '搜索',
  },
  {
    icon: 'Message',
    text: '消息',
  },
  {
    icon: 'User',
    text: '我的',
  },
]);

</script>

<style lang="scss">
* {
  padding: 0;
  margin: 0;
}

body,
html,
#app {
  overflow: hidden;
  height: 100%;
}


.wraps {
  height: inherit;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.header {
  display: flex;
  height: 30px;
  align-items: center;
  justify-content: space-around;
  background-color: aquamarine;
}

.main {
  flex: 1;
  overflow: auto;

  &-item {
    display: flex;
    align-items: center;
    border-bottom: 1px solid #ccc;
    padding: 5px;
  }
  &-avatar {
    width: 30px;
    height: 30px;
    background-color: bisque;
    border-radius: 50%;
  }

  &-desc {
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin-left: 10px;
  }
}

.footer {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr;
  text-align: center;
  border-top: 1px solid #000;
}
</style>

```

* 效果：

![image-20220703210944552](http://182.61.149.102/blog/PostcssViewPort/img1.png)

* 将项目打包成**APK**需要使用**Android Studio**，那么就需要配置安卓的环境

> Android Studio下载地址：[Android Studio](https://r3---sn-i3belnlz.gvt1.com/edgedl/android/studio/install/2021.2.1.15/android-studio-2021.2.1.15-windows.exe?cms_redirect=yes&mh=Dq&mip=20.205.43.162&mm=28&mn=sn-i3belnlz&ms=nvh&mt=1656853704&mv=m&mvi=3&pl=18&shardbypass=sd&smhost=r2---sn-i3belnl6.gvt1.com)
>
> JDK下载地址：[JDK](https://www.oracle.com/java/technologies/downloads/#java8-windows)

* 新建安卓项目

1. 新建一个空的Activity

![image-20220703212751767](http://182.61.149.102/blog/PostcssViewPort/img2.png)

1. 语言选择Java（会Kotlin无视）

![image-20220703212822867](http://182.61.149.102/blog/PostcssViewPort/img3.png)

1. 修改布局文件

```xml
<!--activity_main.xml-->
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout  xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/activity_main"
    android:layout_width="match_parent"
    android:orientation="vertical"
    android:layout_height="match_parent">

    <WebView
        android:id="@+id/web_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
</LinearLayout  >
```

4. 在`MainActivity`中配置WebView

```java
// MainActivity.java
package com.example.vue_mobile;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;

import android.webkit.WebView;

import android.webkit.WebViewClient;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        WebView view = (WebView) findViewById(R.id.web_view);
        view.getSettings().setJavaScriptEnabled(true); // 配置WebView能执行JS代码
        view.loadUrl("http://10.0.2.2:3000"); // 加载需要显示的网页，不能使用局域网地址，只能虚拟机专属地址 http://10.0.2.2 端口是我们vue 项目端口
        view.setWebViewClient(new WebViewClient());
    }
}
```

5. WebView的本质就是访问web中的网页，所以还需要在`AndroidManifest.xml`为虚拟机配置使用网络的权限

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.example.vue_mobile">
    <uses-permission android:name="android.permission.INTERNET" />   <!--访问网络-->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />  <!--访问网络状态-->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />  <!--访问wifi状态-->

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:usesCleartextTraffic="true"   <!--该项也需要配置，复制代码删掉该注释即可-->
        android:theme="@style/Theme.Vuemobile"
        tools:targetApi="m">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
```

6. 虚拟机中运行效果

![image-20220703213832586](http://182.61.149.102/blog/PostcssViewPort/img4.png)

1. 打包**APK**安装到手机

![image-20220703214652294](http://182.61.149.102/blog/PostcssViewPort/img5.png)

## 🖨 总结

​		viewport适配方案与rem适配方案大同小异，都是使用`postcss`的插件实现（rem方案使用`postcss-pxtorem`插件将**px**转换为**rem**）。开发移动端应用只是简单的套一个`WebView`的壳。

​		参考：[CSDN：小满zs](https://www.bilibili.com/video/BV1dS4y1y7vd?p=52&vd_source=15cacb2eb176693886be6d648b84ebc2), [bilibili：小满zs](https://www.bilibili.com/video/BV1dS4y1y7vd?p=52&vd_source=15cacb2eb176693886be6d648b84ebc2)

​		
