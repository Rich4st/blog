---
icon: edit
date: 2022-06-27
category:
  - Guide
  - OpenLayers
---
# Vue3使用OpenLayers

### 环境 Environment

>**Vue版本：** 3.2.25
>
>**Vite版本：** 2.9.9
>
>**Node版本：** 16.15.1
>
>**OpenLayers版本：** 6.14.1 



---

### OpenLayers简介 Introductino

[OpenLayers](https://openlayers.org/) 是一个用来开发地图应用的高性能、功能丰富且完全免费的**JavaScript**库，可以满足几乎所有的地图开发需求。



---

### 🛠 创建项目 Init project

#### 1. 通过Vite创建Vue3项目

Npm: 

```shel
npm create vite@latest
```

Yarn:

```shel
yarn create vite
```

pnpm:

```she
pnpm create vite
```

之后根据引导配置项目。

---

#### 2. 安装OpenLayers

```she
npm install ol
```

---

#### 3. 生成一个简单的地图

```vue
<template>
  <div class="ol-map" ref="olMap"></div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import Map from 'ol/Map'
import View from 'ol/View'
import { Tile as TileLayer } from 'ol/layer'
import { XYZ, OSM } from 'ol/source'
import { fromLonLat } from 'ol/proj'
const olMap = ref<HTMLElement>()

function initMap() {

  // fromLonLat方法能将坐标从经度/纬度转换为其他投影

  // 使用内置的OSM
  //const tileLayer = new TileLayer({
  //    source: new OSM()
  //})
  // 使用高德
  const tileLayer = new TileLayer({
    source: new XYZ({
      url: 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}'
    })
  })
  let map = new Map({
    layers: [tileLayer],
    view: new View({
      center: fromLonLat([120.771441, 30.756433]),//地图中心点
      zoom: 15,// 缩放级别
      minZoom: 0,// 最小缩放级别
      maxZoom: 18,// 最大缩放级别
      constrainResolution: true// 因为存在非整数的缩放级别，所以设置该参数为true来让每次缩放结束后自动缩放到距离最近的一个整数级别，这个必须要设置，当缩放在非整数级别时地图会糊
    }),
    target: olMap.value// DOM容器
  })
}

onMounted(() => {
  initMap()
})

</script>

<style scoped>
.ol-map {
  width: 100%;
  height: 100vh;
}
</style>

```

> **注意：**⚠️
>
> * 需要在**onMounted**生命周期钩子中初始化地图
> * 要为ol-map设置宽高，否则渲染地图会失败❗️❗️❗️



---

###  📦 OOTB 开箱即用的控件

#### 💻 FullScreen

>  全屏切换
>
> **官方文档：**  [FullScreen Docs](https://openlayers.org/en/latest/apidoc/module-ol_control_FullScreen-FullScreen.html)

* 引入控件

```js
import { defaults, FullScreen } from 'ol/control' // 需要引入控件再引入FullScreen控件让默认控件继承全屏控件
```

* 使用控件

```js
...
let map = new Map(
 {
   ...
   controls： default.extends([
     	new FullScreen({  
		 // 全屏控件的配置，可在官方文档查看
 		})
     ])
 })
```

* 通过class选择控件将按钮`innerHTML`设置为图标

```js
const fsFalse = document.querySelector('.ol-full-screen-false')
fsFalse!.innerHTML = '<img src="https://img.icons8.com/ios/50/000000/full-screen.png" style="width: 26px;height: 32px;" alt="">'
```



---

#### 🖱 MousePosition 

> 显示鼠标位置
>
> **官方文档：** [MousePosition Docs](https://openlayers.org/en/latest/apidoc/module-ol_control_MousePosition-MousePosition.html)

* 引入控件

```js
import { defaults, MousePosition } from 'ol/control'
```

* 使用控件

```js
...
let map = new Map(
 {
   ...
   controls： default.extends([
     	new MousePosition({  
		  projection: 'EPSG:4326', // 投影坐标系 
          coordinateFormat: (coordinate) => { // 坐标格式化函数
            return `经度：${coordinate![0].toFixed(5)}，纬度：${coordinate![1].toFixed(5)}`
          },
          className: 'ol-mouse-position', // 控件class名称
          target: document.getElementById('mouse-position')!, // 控件显示位置的DOM容器,默认不需要设置
          undefinedHTML: '未知', // 未定义坐标时显示的文字，比如鼠标移到地图或网页外
          // ...更多配置参考官方文档
 		})
     ])
 })
```



---

#### 📏 ScaleLine

> 显示地图比例尺
>
> **官方文档：** [ScaleLine Docs](https://openlayers.org/en/latest/apidoc/module-ol_control_ScaleLine-ScaleLine.html)

* 引入控件

```js
import { defaults, ScaleLine } from 'ol/control'
```

* 使用控件

```js
...
let map = new Map(
 {
   ...
   controls： default.extends([
     	new ScaleLine({
        className: 'ol-scale-line', // 控件class名称
        // target: document.getElementById('scale-line')!, // 控件显示位置的DOM容器，默认不需要配置
        minWidth: 200, // 最小宽度
        units: 'metric', // 单位，可选值：'degrees', 'imperial', 'nautical', 'metric', 'us'
        bar: true, // 渲染比例尺，默认为false渲染当前比例的值
        // steps: 8, // 比例尺刻度数量，默认为4个刻度，仅在bar为true时有效
        // text: true // 渲染比例尺上方的文本比例，默认为false渲染当前比例的值，仅在bar为true时有效
     	// ...更多配置参考官方文档
      }),
     ])
 })
```



---

### 🪝 地图事件

#### on

> 监听特定类型的事件
>
> **官方文档：** [On Doc](https://openlayers.org/en/latest/apidoc/module-ol_Map-Map.html#on)

##### moveend

> 地图拖动事件，事件已经配置**节流**

```js
map.on('moveend', (event) => {
   console.log(event,'moveend') 
})
```

##### rendercomplete

> 地图渲染完成后的回调，地图进行缩放后也会触发

```js
map.on('rendercomplete', (event) => {
   console.log(event,'rendercomplete') 
})
```



---

#### once

> 监听**一次**特定类型的事件
>
> **官方文档：** [Once Docs](https://openlayers.org/en/latest/apidoc/module-ol_Map-Map.html#once)
>
> on中的**所有事件**都可以通过once来只监听**一次**



---
